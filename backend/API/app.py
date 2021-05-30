from flask import Flask, request, jsonify
import json
# import time
import os
from datetime import date, datetime
import pytz
# from toolz import recipes
# from web3 import method
from .web3connection import Connection
from .treeStruct import makeTree
from hashlib import sha256
from random import random, randint
from flask_jwt_extended import (
    JWTManager, jwt_required, create_access_token,
    jwt_refresh_token_required, create_refresh_token,
    get_jwt_identity
)

JWT_SECRET_KEY = 'a9346b0068335c634304afa5de1d51232a80966775613d8c1c5a0f6d231c8b1a'
app = Flask(__name__)
app.config['JWT_SECRET_KEY'] = os.getenv('JWT_SECRET_KEY')
jwt = JWTManager(app)
connection = Connection()
conn, w3 = connection.create_conn()
print("connection:", conn)
print("connection address:", conn.address)

# user : {product : status}
#status: 1=added, 2=transaction deets added by recv, 3=rejected by receiver, 4=deets accepted by sender, 5=rejected by sender
pendingTransactions = {}

# userid : [productid]
transactionStarted = {}

# code: (sender, qty, prod, prodname)
codeTransactions = {}

# tracing function
@app.route('/trace', methods=['POST'])
def trace():
    input_json = request.get_json(force=True)
    product_id = int(input_json.get('product_id', ''))
    user_id = input_json.get('user_id', '')
    is_owned = conn.functions.isOwner(user_id, product_id).call()

    product = conn.functions.getProduct(product_id).call()

    t = makeTree(product, product_id, conn)
    print("t",type(t))
    return jsonify({"t": t})

@app.route("/getErrors/<product_id>", methods=["GET"])
def getErrors(product_id):
    errors = conn.functions.getErrors(int(product_id)).call()
    print('errors',errors)
    return jsonify({"errors":errors})

def split_product(p_id, p_name, parent_array, children_array, user_id, quantities,enc_props):  # TODO user string
    #get errors of parent to pass to children
    errors = conn.functions.getErrors(int(p_id)).call()
    print('errors',errors)
    
    children = []
    print("split_products() called with quantities", quantities)
    c=1
    for q in quantities:
        # TODO encode the quanitities and the prop what algo??
        #add parent properties but change quantity field
        enc_props["quantity"]=q
        tx_hash = conn.functions.addProduct(
             "C"+str(c)+"-"+str(p_id)+": "+p_name, parent_array, children_array, str(user_id), json.dumps(enc_props)).transact({'gas' : 400000})
        event_filter = conn.events.childAdded.createFilter(fromBlock="latest")
        for event in event_filter.get_all_entries():
            print(event)
            # the id of the child newly produced, already added to products owned.
            children.append(event['args']['_child'])
            #add error if any of parent to children
            for e in errors:
                tx_hash = conn.functions.setError(event['args']['_child'], e).transact({'gas' : 400000})
                tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
        c+=1

        # check and change ownership
    # remove from parent
    tx_hash = conn.functions.removeFromOwner(str(user_id), p_id).transact({'gas' : 400000})
    tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
    print("New children are:", children)
    return children


# https://stackoverflow.com/questions/10313001/is-it-possible-to-make-post-request-in-flask
@app.route('/split', methods=['POST'])
def split():
    input_json = request.get_json(force=True)
    # expectation for input_json is product_id and quantities_array[] also user_id
    # check quantities (can be done on flutter - should be done on flutter)
    # call add products, if successful
    # print("here", input_json)
    quantities = input_json["quantities"]
    # get the product:
    parent_id = input_json["product_id"]
    current_user = input_json["user_id"]  # TODO change to hashed string

    # check owned before:
    # list of products owned by caller.
    print(conn.functions.getProductsOwned(current_user).call())

    # p is a tuple with the product structure type.
    p = conn.functions.getProduct(parent_id).call()
    print(p)
    print("props",p[1],type(json.loads(p[1])))
    # addProduct will add the new product into the productsOwned but will not remove the parent.
    children = split_product(parent_id, p[0], [parent_id], [], current_user, quantities,json.loads(p[1]))

    # check owned after:
    print(conn.functions.getProductsOwned(current_user).call())
    return jsonify(children), 204


@app.route('/trial', methods=['GET'])
def current_ownership():
    print(conn.functions.getProductsOwned(1).call())
    return ('', 204)

# addParticipant


@app.route('/register', methods=['POST'])
def register_user():
    input_json = request.get_json(force=True)
    # username, password, fullname, role are expected as parameters - add more parameters here
    print("REG REQ FOR:", input_json)
    username = input_json["username"]
    password = sha256(input_json["password"].encode()
                      ).hexdigest()  # hash password
    fullname = input_json["fullname"]
    role = input_json["role"]
    hashedId = sha256((username+password).encode()).hexdigest()  # for hashed userId
    print(hashedId)

    # check if username exists and for that username is password is same
    p = conn.functions.getLoginDetails(username).call()
    # print("HASHED PASSWORD",p)
    if (p != ""):
        return ("Username already exists!", 500)

    # call addParticipant function of Product.sol
    tx_hash = conn.functions.addParticipant(
        username, password, fullname, role, hashedId).transact({'gas' : 600000})
    tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
    print("RECEIPT", tx_receipt)

    # confirm added participant --- no return value of user hash as of now
    print("GET PARTICIPANT", conn.functions.getParticipant(
        hashedId).call())  # why calling with hashed ID? **
    access_token = create_access_token(identity=hashedId)
    refresh_token = create_refresh_token(identity=hashedId)

    return jsonify({'userid': hashedId,  'role' : role}), 200

# merge -- deleteProducts + addToOwner
@app.route('/merge', methods=['POST'])
def merge_children():
    input_json = request.get_json(force=True)
    # expecting children id array and ownerid
    childrenIds = input_json["childrenIds"]
    ownerId = input_json["ownerId"]

    # extract the parent id from one of the children
    # (assuming that user selects "correct" and "all" children ids products corr to only 1 parent)
    # correctness: can check here or in flutter? not sure yet (could store parent ids flutter side -performance?)
    # not all: logic needs to be added here: make new product with remaining quantity (thats not merge though)

    # p is a tuple with the product structure type.
    p = conn.functions.getProduct(childrenIds[0]).call()
    parent_id = p[2][0]

    # check if not all
    parent = conn.functions.getProduct(parent_id).call()
    print("PARENT:", parent_id, parent)

    # get quant of childrenids
    childrenQuantities = []
    for c in childrenIds:
        p = conn.functions.getProduct(c).call()
        childrenQuantities.append(int(json.loads(p[1])["quantity"]))

    print(childrenQuantities)
    # delete childrenIds
    tx_hash = conn.functions.deleteProducts(childrenIds, ownerId).transact({'gas' : 600000})
    tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
    print("Delete RECEIPT", tx_receipt)

    # NOT ALL Logic -> delete the products and add a new product with their quantities added together else
    # add parent id to products owned

    if len(parent[3]) != len(childrenIds):
        enc_props = json.loads(parent[1])
        enc_props["quantity"] = str(sum(childrenQuantities))
        tx_hash = conn.functions.addProduct(
            p[0], [parent_id], [], p[4], json.dumps(enc_props)).transact({'gas' : 400000})
        tx_receipt = w3.eth.waitForTransactionReceipt(
            tx_hash)  # how to get returned value?
        print("AddNewProduct", tx_receipt)
    else:
        # add the parent id to products owned
        tx_hash = conn.functions.addToOwner(parent_id, ownerId).transact({'gas' : 400000})
        tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
        print("AddtoOwner RECEIPT", tx_receipt)

    # check owned
    # print(conn.functions.getProductsOwned().call())
    return ('', 204)


# transfer ownership
@app.route('/transfer', methods=['POST'])
def transfer_owner():
    # expecting senderId and productId (via qr code), and receiverId, location
    input_json = request.get_json(force=True)
    print('Received params', input_json)
    sender_id = input_json['senderId']
    receiver_id = input_json['receiverId']
    product_id = int(input_json['productId'])
    
    product = conn.functions.getProduct(product_id).call()
    new_props = json.loads(product[1])
    print('new', new_props)

    transf_props = json.loads(new_props['transfer'])
    location = transf_props['location']
    p = conn.functions.getProduct(product_id).call()
    if p[0].lower().find("juice"):
        if "temperature" in transf_props:
            if int(transf_props["temperature"]) > 5:
                sender_details = conn.functions.getParticipant(sender_id).call()
                receiver_details = conn.functions.getParticipant(receiver_id).call()
                tx_hash = conn.functions.setError(product_id,"Temperature of "+str(product_id)+" is not maintained during transfer from "+str(sender_details[2])+" to "+str(receiver_details[2])).transact({'gas' : 400000})
                tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)

    if 'transfer' in new_props:
        del new_props['transfer']
    # pendingTransactions
    tx_hash = conn.functions.setEncProps(product_id, json.dumps(new_props)).transact({'gas' : 400000})
    tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
    
    # if receiver_id in transactionStarted:
    #     if product_id in transactionStarted[receiver_id]:
    #         transactionStarted[receiver_id].remove(product_id)
    
    if sender_id in pendingTransactions:
        if product_id in pendingTransactions[sender_id]:
            del pendingTransactions[sender_id][product_id]
            if len(pendingTransactions[sender_id]) == 0:
                del pendingTransactions[sender_id]
    
    print(pendingTransactions, 'this')
    #changed here timestamp
    try:
        tx_hash = conn.functions.TransferOwnership(
            sender_id, receiver_id, product_id, location, datetime.now(pytz.timezone('Asia/Kolkata')).strftime('%d-%m-%Y %H:%M:%S'), json.dumps(transf_props)).transact({'gas' : 400000})
        tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
    # print(tx_receipt)
    except Exception as e:
        print(e)
        return str(e), 400

    return (f'Transfer completed between {sender_id} and {receiver_id}', 204)


@app.route('/refresh', methods=['POST'])
@jwt_refresh_token_required
def refresh():
    current_user = get_jwt_identity()
    access_token = create_access_token(identity=current_user)
    return jsonify({'JWTAccessToken': access_token}), 200


@app.route('/login', methods=['POST'])
def login():
    # get username and password
    input_json = request.get_json(force=True)
    username = input_json.get('username', None)
    password = input_json.get('password', None)

    # check if username exists
    if not username or not password:
        return "Invalid attempt", 401
    val = conn.functions.getLoginDetails(username).call()
    # check if username password combo is correct
    if val == '':
        return 'Invalid Username', 401

    if sha256(password.encode()).hexdigest() != val:
        return 'Invalid Attempt', 401

    hashedId = sha256((username + val).encode()
                      ).hexdigest()  # for hashed userId
    user_details = conn.functions.getParticipant(hashedId).call()
    print('User Details', user_details)
    # generate a token also maybe?
    access_token = create_access_token(identity=hashedId)
    refresh_token = create_refresh_token(identity=hashedId)
    role = user_details[3]
    print(role)
    # return the generated token
    return jsonify({'userid': hashedId, 'JWTAccessToken': access_token, 'JWTRefreshToken': refresh_token, 'role':role}), 200


@app.route("/add_product", methods=["POST"])
def add_product():
    """
    request (POST) - '/add_product'
    body - dict<string, ...>
        product_name (string)
        user_id (string)
        product_properties (dict<string, ...>)
    response - dict<string, id>
    {
        "product_id": product_id
    }
    """

    # Acquiring all the POST information from the body
    input_json = request.get_json(force=True)
    product_name = input_json["product_name"]
    product_properties = json.dumps(input_json["product_properties"])
    user_id = input_json["user_id"]

    # TODO - Encrypt all the additional information aka "product_properties"
    # print(product_properties)
    # parent_id and children_id are populated by calling split (?) at the front ent
    parent_id = input_json["parent_ids"]
    print("HERE",parent_id,type(parent_id))

    children_id = []

    # transacting the data to the blockchain using the addProduct function defined in the smart contract
    tx_hash = conn.functions.addProduct(
        product_name, parent_id, children_id, user_id, product_properties).transact({'gas' : 400000})
    tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)

    # Calling the childAdded event to acquire the child_id as a return value
    event_filter = conn.events.childAdded.createFilter(fromBlock="latest")
    child_id = None
    for event in event_filter.get_all_entries():
        # print(event)
        child_id = event['args']['_child']
        print("id of the newly added child:", child_id)

    #check for type of SCM of parent here (for sugarcane) and if it exists calculate cruch-harvest = 2
    #also add parent product erros to child
    if parent_id[0]!=-1:
        for pid in parent_id:
            p = conn.functions.getProduct(pid).call()
            errors = conn.functions.getErrors(int(pid)).call()
            # print('errors',errors)

            for k, v in json.loads(p[1]).items():
                if(k == "type" and v == "sugarcane_scm"):
                    # print("here!")
                    crush_date = json.loads(product_properties)["crush date"]
                    # print(crush_date)
                    crush = date(int(crush_date[6:]),int(crush_date[3:5]),int(crush_date[0:2]))
                    # print(crush)
                    harvest_date = json.loads(p[1])["harvest date"] 
                    # print(harvest_date)
                    harvest = date(int(harvest_date[6:]),int(harvest_date[3:5]),int(harvest_date[0:2]))
                    # print(harvest)
                    if (crush-harvest).days>=2:
                        tx_hash = conn.functions.setError(child_id, "Sugarcane exceeded crushing date! ID:"+str(pid)).transact({'gas' : 400000})
                        tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
            
            for e in errors:
                tx_hash = conn.functions.setError(child_id, e).transact({'gas' : 400000})
                tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)

            #remove parents from owner as they no longer exist and have made new product
            tx_hash = conn.functions.removeFromOwner(str(user_id), pid).transact({'gas' : 400000})

    return jsonify({"product_id": child_id})

#get participant details
@app.route("/get_participant/<user_id>", methods=["GET"])
def get_participant(user_id):
    p = conn.functions.getParticipant(user_id).call()
    return jsonify({"fullname":p[2],"role":p[3],"rating":p[4]})

#get participant details
@app.route("/get_all_participants/<role>", methods=["GET"])
def get_all_participants(role):
    print("Search for role:",role)
    allParts = conn.functions.getAllParticipants().call()
    # print(p)
    role_parts = []
    for p in allParts:
        if p[3].lower() == role.lower():
            role_parts.append([sha256((p[0]+p[1]).encode()).hexdigest(), p[2], int(float(p[4].split('#')[0]))])
    role_parts.sort(key=lambda x:x[2],reverse=True)
    print(role_parts)
    return jsonify({"participants":role_parts})

#get participant details
@app.route("/get_transactions/<product_id>", methods=["GET"])
def get_transactions(product_id):
    trace = conn.functions.getTrace(int(product_id)).call()
    print('trace', trace)
    t = []
    for i in trace:
        d = {}
        d["Timestamp"] = i[0]
        d["Location"] = i[1]
        p = conn.functions.getParticipant(i[2]).call()
        d["Sender"] = [i[2],p[2]+" - "+ p[3]]
        p = conn.functions.getParticipant(i[3]).call()
        d["Receiver"] = [i[3],p[2]+" - "+ p[3]]
        props = json.loads(i[4])
        print(props)
        for k,v in props.items():
            d[k] = v
        t.append(d)
    print(t)
    return jsonify(t)

#get products owned
@app.route("/get_products/<user_id>", methods=["GET"])
def get_products(user_id):
    """
    request (GET) - '/get_products/<user_id>'
    response - dict<string, dict>
    "user_id" -> {
                "name",
                "encoded_properties",
                "parent_id_list",
                "children_id_list",
                "current_owner_id",
    }
    """

    # Acquiring a list of product ids owned by user.
    tx_hash = conn.functions.getProductsOwned(str(user_id)).call()

    product_dict = {}
    for product_id in list(tx_hash):
        product = conn.functions.getProduct(product_id).call()
        product_dict[product_id] = {
            "name": product[0],
            "encoded_properties": product[1],
            "parent_id_list": product[2],
            "children_id_list": product[3],
            "current_owner_id": product[4]
        }
    print(product_dict)
    return jsonify({"product_dict": product_dict})
    
@app.route('/transactionInfo', methods=['POST'])
def transactionInfo():
    input_json = request.get_json(force=True)
    print(input_json)
    username = input_json['username']
    product_id = int(input_json['product_id'])
    print(username, product_id)
    print(pendingTransactions)
    if username not in pendingTransactions:
        return json.dumps({'status':0}), 200
    else:
        # print(pendingTransactions[username])
        if product_id not in pendingTransactions[username]:
            return json.dumps({'status':0}), 200
        else:
            print('right')
            return json.dumps({'status':pendingTransactions[username][product_id]}), 200

@app.route('/makeTransaction', methods=['POST'])
def addTransaction():
    input_json = request.get_json(force=True)
    username = input_json['username']
    product_id = int(input_json['product_id'])
    print(product_id)
    
    if username not in pendingTransactions:
        pendingTransactions[username] = {product_id : 1}
    print(pendingTransactions)
    return 'done', 200

@app.route('/makeCodeTransaction', methods=['POST'])
def addCodeTransaction():
    input_json = request.get_json(force=True)
    username = input_json['username']
    product_id = int(input_json['product_id'])
    quantity = int(input_json['quantity'])
    product = input_json['product']
    # print(product_id)
    
    if username not in pendingTransactions:
        pendingTransactions[username] = {product_id : 1}
    x = randint(0, 58)
    code = sha256(str(random()).encode()).hexdigest()[x : x+6]

    codeTransactions[code] = (username, quantity, product_id, product)

    print(codeTransactions)
    return code, 200


@app.route('/removeTransaction', methods=['POST'])
def deleteTransaction():
    input_json = request.get_json(force=True)
    username = input_json['username']
    product_id = int(input_json['product_id'])

    if username in pendingTransactions:
        if product_id in pendingTransactions[username]:
            del pendingTransactions[username][product_id]
            if len(pendingTransactions[username]) == 0:
                del pendingTransactions[username]
    
    print(pendingTransactions, 'this')
    return 'done', 200

@app.route('/removeCodeTransaction', methods=['POST'])
def deleteCodeTransaction():
    input_json = request.get_json(force=True)
    username = input_json['username']
    product_id = int(input_json['product_id'])
    code = input_json['code']

    if username in pendingTransactions:
        if product_id in pendingTransactions[username]:
            del pendingTransactions[username][product_id]
            if len(pendingTransactions[username]) == 0:
                del pendingTransactions[username]
    print(code, codeTransactions)
    if code in codeTransactions:

        del codeTransactions[code]
    print(codeTransactions, 'this')
    return 'done', 200

@app.route('/getCodeProps', methods = ['POST'])
def getCodeProps():
    input_json = request.get_json(force=True)
    code = input_json['code'].lower()
    print(code, codeTransactions[code], 'getting value!')
    if code in codeTransactions:
        ret = {"sender": codeTransactions[code][0], "quantity": str(codeTransactions[code][1]), "product_id": str(codeTransactions[code][2]), "product": codeTransactions[code][3]}
        return jsonify(ret), 200
    return 'Not Found', 404

@app.route('/sendMoreProps', methods=['POST'])
def sendMoreProps():
    input_json = request.get_json(force=True)
    product_id = int(input_json['product_id'])
    enc_props = input_json['enc_props']
    sender = input_json['owner']
    # receiver = input_json['new']

    product = conn.functions.getProduct(product_id).call()
    new_props = json.loads(product[1])
    new_props['transfer'] = enc_props
    
    print(new_props)

    tx_hash = conn.functions.setEncProps(product_id, json.dumps(new_props)).transact({'gas' : 400000})
    tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)

    if sender in pendingTransactions:
        if product_id in pendingTransactions[sender]:
            pendingTransactions[sender][product_id] = 2
        else:
            return 'unable', 404
    else:
        return 'unable', 404
    return 'done', 200 


@app.route('/getTransactionProps', methods=['POST'])
def getTransactionProps():
    input_json = request.get_json(force=True)
    product_id = int(input_json['product_id'])
    transfer = input_json['transfer']
    val = conn.functions.getProduct(product_id).call()
    print(transfer, type(transfer))
    if transfer == 'true':
        print(json.loads(val[1]))
        return json.loads(val[1])['transfer']
    else:
        return json.loads(val[1])

@app.route('/reject', methods=['POST'])
def reject():
    input_json = request.get_json(force=True)
    product_id = int(input_json['product_id'])
    sender = input_json['owner']
    person = input_json['person']

    if sender in pendingTransactions:
        if product_id in pendingTransactions[sender]:
            if person == 'sender':
                pendingTransactions[sender][product_id] = 5
            else:
                pendingTransactions[sender][product_id] = 3
        else:
            return 'unable', 404
    else:
        return 'unable', 404
    print(pendingTransactions)
    return 'done', 200

@app.route('/ownerAccept', methods=['POST'])
def senderAccept():
    input_json = request.get_json(force=True)
    product_id = int(input_json['product_id'])
    sender = input_json['owner']
    if sender in pendingTransactions:
        if product_id in pendingTransactions[sender]:
            pendingTransactions[sender][product_id] = 4
        else:
            return 'unable', 404
    else:
        return 'unable', 404
    print(pendingTransactions)
    return 'done', 200

@app.route('/rate', methods = ['POST'])
def rate():
    input_json = request.get_json(force=True)
    rating = float(input_json['rating'])
    sender = input_json['owner']

    p = conn.functions.getParticipant(sender).call()
    print(p, p[4])
    
    x = p[4].split('#')
    if len(x) < 2:
        x.append('0')

    new_rating = round((float(x[0])*int(x[1]) + rating) / (int(x[1]) + 1), 2)
    new_rating_str = str(new_rating) + '#' + str(int(x[1]) + 1)

    tx_hash = conn.functions.setRating(sender, new_rating_str).transact({'gas' : 400000})
    tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)

    p = conn.functions.getParticipant(sender).call()
    print(p, p[4])

    return 'done', 200

@app.route('/getUserTransactions', methods = ['POST'])
def getUserTransactions():
    input_json = request.get_json(force=True)
    user_id = float(input_json['user_id'])
    if user_id in transactionStarted:
        return jsonify(transactionStarted[user_id])
    else:
        return jsonify([])