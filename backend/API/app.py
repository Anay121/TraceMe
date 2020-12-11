from flask import Flask, request, url_for, jsonify
import json
import time
import os
from .web3connection import Connection
from .treeStruct import treeNode
import dotenv
from hashlib import sha256
from flask_jwt_extended import (
    JWTManager, jwt_required, create_access_token,
    jwt_refresh_token_required, create_refresh_token,
    get_jwt_identity
)

app = Flask(__name__)
app.config['JWT_SECRET_KEY'] = os.getenv('JWT_SECRET_KEY')
jwt = JWTManager(app)
connection = Connection()
conn, w3 = connection.create_conn()
print("connection:", conn)
print("connection address:", conn.address)


def init():
    # add more init stuff here
    print("executing init function")
    conn.functions.addParticipant(
        "anjum_k", "pass", "Anjum Khandeshi", "farmer", "1").transact()
    conn.functions.addProduct("prod1", [], [], "1", "100").transact()
    conn.functions.addProduct("prod2", [], [], "1", "200").transact()


def split_product(p_id, p_name, parent_array, children_array, user_id, quantities):  # TODO user string
    children = []
    print("split_products() called with quantities", quantities)
    for q in quantities:
        # TODO encode the quanitities and the prop what algo??
        tx_hash = conn.functions.addProduct(
            p_name, parent_array, children_array, str(user_id), str(q)).transact()
        event_filter = conn.events.childAdded.createFilter(fromBlock="latest")
        for event in event_filter.get_all_entries():
            print(event)
            # the id of the child newly produced, already added to products owned.
            children.append(event['args']['_child'])
        # check and change ownership
    # remove from parent
    tx_hash = conn.functions.removeFromOwner(str(user_id), p_id).transact()
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
    print("here", input_json)
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
    # addProduct will add the new product into the productsOwned but will not remove the parent.
    children = split_product(parent_id, p[0], [parent_id], [], current_user, quantities)

    # check owned after:
    print(conn.functions.getProductsOwned(current_user).call())
    return jsonify(children), 204


@app.route('/parents', methods=['POST'])
def add_from_multiple_products():
    '''
    {
            "user_id":123,
            "parents": [{product_id:1,quantity:30},{product_id:2,quantity:10},...]
    }

    we could fetch the total from here but were better off pasing it in from flutter beacuse flutter has all
    this data to be displayed anyways.
    '''
    data = request.get_json(force=True)
    user_id = data['user_id']
    # print("user_id",user_id)
    parent_products = data['parents']
    # print("parent_products",parent_products)
    parent_ids = []
    for p in parent_products:
        parent_id = p['product_id']
        # print("curretn parent id is :",parent_id)
        # p is a tuple with the product structure type.
        parent_prod = conn.functions.getProduct(parent_id).call()
        print(parent_prod)
        quan = int(p['quantity'])
        total = int(parent_prod[1])  # get the product quantity from here
        # print(parent_prod[1])
        parent_ids.append(parent_id)
        # print("parent id:",parent_ids)
        # print(quan,total)
        if(quan < total):
            print("quan less than!")
            children = split_product(parent_id, parent_prod[0], [
                                     parent_id], [], user_id, [quan, total-quan])
            # children is an array of children product ids cvreated
            parent_ids.pop()
            # first child is the correct quantity.
            parent_ids.append(children[0])
    print("\nParent ids of the new product to add------", parent_ids)
    conn.functions.addProduct("new_product_name", parent_ids, [], str(
        user_id), "quan1+quant2...").transact()  # TODO quantitites here
    event_filter = conn.events.childAdded.createFilter(fromBlock="latest")
    for event in event_filter.get_all_entries():
        print(event)
        child_id = event['args']['_child']
    print("ID of child newly added:", child_id)
    # now the child has x parents that are no longer viable:
    for p_id in parent_ids:
        conn.functions.removeFromOwner(str(user_id), p_id).transact()
    print(conn.functions.getProductsOwned("1").call())
    return jsonify({"new_child": child_id})


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
    hashedId = sha256((username+password).encode()
                      ).hexdigest()  # for hashed userId
    print(hashedId)

    # check if username exists and for that username is password is same
    p = conn.functions.getLoginDetails(username).call()
    # print("HASHED PASSWORD",p)
    if (p != ""):
        return ("Username already exists!", 500)

    # call addParticipant function of Product.sol
    tx_hash = conn.functions.addParticipant(
        username, password, fullname, role, hashedId).transact()
    tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
    print("RECEIPT", tx_receipt)

    # confirm added participant --- no return value of user hash as of now
    print("GET PARTICIPANT", conn.functions.getParticipant(
        hashedId).call())  # why calling with hashed ID? **
    return ('Added Participant successfully', 204)

# @app.route('/get_user', methods=['GET'])
# def getparticipant():
# 	print(conn.functions.getParticipant("137f8dd76837941037a63f22cc277577bf41c94d3be55c232ee6e9fea8cb465e").call())
# 	return ('', 204)


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

    # delete childrenIds
    tx_hash = conn.functions.deleteProducts(childrenIds, ownerId).transact()
    tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
    print("Delete RECEIPT", tx_receipt)

    # NOT ALL Logic -> delete the products and add a new product with their quantities added together else
    # add parent id to products owned

    if len(parent[3]) != len(childrenIds):
        tx_hash = conn.functions.addProduct(
            p[0], [parent_id], [], p[4], "new prop with ADDED quantities OF 2 CHILDS").transact()
        tx_receipt = w3.eth.waitForTransactionReceipt(
            tx_hash)  # how to get returned value?
        print("AddNewProduct", tx_receipt)
    else:
        # add the parent id to products owned
        tx_hash = conn.functions.addToOwner(parent_id, ownerId).transact()
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
    location = input_json['location']
    props = input_json.get('props', '')
    # do the encoding

    # assume only one product is being transfered
    # call transfer
    try:
        tx_hash = conn.functions.TransferOwnership(
            sender_id, receiver_id, product_id, location, str(time.time()), props).transact()
        tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
    # print(tx_receipt)
    except Exception as e:
        print(e)
        return str(e), 400
    # after returning maybe smoe way to send an OK message to both the parties
    #
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
    print(access_token)
    # return the generated token
    return jsonify({'userid': hashedId, 'JWTAccessToken': access_token, 'JWTRefreshToken': refresh_token}), 200


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
    product_properties = str(input_json["product_properties"])
    user_id = input_json["user_id"]

    # TODO - Encrypt all the additional information aka "product_properties"

    # parent_id and children_id are populated by calling split (?) at the front ent
    parent_id, children_id = [-1], []

    # transacting the data to the blockchain using the addProduct function defined in the smart contract
    tx_hash = conn.functions.addProduct(
        product_name, parent_id, children_id, user_id, product_properties).transact()
    tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
    print("addProduct Receipt", tx_receipt)

    # Calling the childAdded event to acquire the child_id as a return value
    event_filter = conn.events.childAdded.createFilter(fromBlock="latest")
    child_id = None
    for event in event_filter.get_all_entries():
        print(event)
        child_id = event['args']['_child']
        print("id of the newly added child:", child_id)

    return jsonify({"product_id": child_id})


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

    return product_dict

# utility function to generate product trace
def makeTree(product, product_id):
    t = treeNode(product[0])
    trace = conn.functions.getTrace(product_id).call()
    arr = []
    # print(trace, 'trace')
    
    if trace:
        t.maker = trace[0][2]
        t.owner = trace[-1][3]
        for i in trace: 
            arr.append(f'Transfered to {i[3]}')
    t.trace = arr
    print(t)
    # get children and enumerate
    for i in product[3]:
        product_child = conn.functions.getProduct(i).call()
        t.children.append(makeTree(product_child, i))
    # get parents and enumerate
    
    # t.parents = 

    return t

# tracing function
@app.route('/trace', methods=['POST'])
def trace():
    input_json = request.get_json(force=True)
    product_id = int(input_json.get('product_id', ''))
    user_id = input_json.get('user_id', '')
    is_owned = conn.functions.isOwner(user_id, product_id).call()
    if not is_owned:
        return "Can't view trace of unowned products", 402
    product = conn.functions.getProduct(product_id).call()
    print(product, 'product')
    makeTree(product, product_id)

    return 'Kay', 200
    
