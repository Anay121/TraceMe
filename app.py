from flask import Flask, request, url_for, jsonify
import json
from web3connection import Connection
import dotenv
from hashlib import sha256

app = Flask(__name__)
c = Connection()
conn,w3 = c.create_conn()
print(conn)

def split_product(p_id,p_name,parent_array,children_array,user_id,quantities):
	children = []
	for q in quantities:
		#TODO encode the quanitities and the prop what algo??
		tx_hash = conn.functions.addProduct(p_name,parent_array,children_array,user_id,"new prop with new quantities"+str(q)).transact()
		tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash) #how to get returned value?
		rich_logs = conn.events.childAdded().processReceipt(tx_receipt)
		flag = eth.getTransactionReceipt(tx_hash)['logs'][0]['data']
		print(tx_receipt)
		# flag = conn.functions.addProduct(p[0],[parent_id],[],p[4],"new prop with new quantities"+str(q)).call()
		print("Added new product with ID",flag)
		children.append(flag)
		# check and change ownership
	# remove from parent
	tx_hash = conn.functions.removeFromOwner(user_id,p_id).transact()
	tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
	return children


#https://stackoverflow.com/questions/10313001/is-it-possible-to-make-post-request-in-flask 
@app.route('/split', methods=['POST'])
def split():
	input_json = request.get_json(force=True)
	#expectation for input_json is product_id and quantities_array[] also user_id
	# check quantities (can be done on flutter - should be done on flutter)
	# call add products, if successful
	print("here",input_json)
	quantities = input_json["quantities"]
	#get the product:
	parent_id = input_json["product_id"]
	current_user = input_json["user_id"]

	#check owned before:
	print(conn.functions.getProductsOwned(current_user).call()) #list of products owned by caller.

	p = conn.functions.getProduct(parent_id).call() #p is a tuple with the product structure type.
	print(p)
	#addProduct will add the new product into the productsOwned but will not remove the parent.
	split_product(parent_id,p[0],[parent_id],[],current_user,quantities)
	
	#check owned after:
	print(conn.functions.getProductsOwned(current_user).call())
	# return 

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
	parent_products = data['parents']
	parent_ids = []
	for p in parent_products:
		parent_id = p['product_id']
		parent_prod = conn.functions.getProduct(parent_id).call() #p is a tuple with the product structure type.
		quan = int(p['quantity'])
		total = int(parent_prod[4])#get the product quantity from here
		parent_ids.append(parent_id)
		if(quan<total):
			children = split_product(parent_id,parent_prod[0],[parent_id],[],user_id,[quan,total-quan])#children is an array of children product ids cvreated
			parent_ids.pop()
			parent_ids.append(children[0])#first child is the correct quantity.
	
	tx_hash = conn.functions.addProduct("new_product_name",parent_ids,[],user_id,"new prop with new quantities").transact()
	tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash) #how to get returned value?
	print(tx_hash,tx_receipt)
	# print(conn.functions.getProductsOwned(1).call())

	return ('', 204)

@app.route('/trial', methods=['GET'])
def current_ownership():
	print(conn.functions.getProductsOwned(1).call())
	return ('', 204)

# addParticipant
@app.route('/register',methods=['POST'])
def register_user():
	input_json = request.get_json(force=True)
	# username, password, fullname, role are expected as parameters - add more parameters here
	print("REG REQ FOR:",input_json)
	username = input_json["username"]
	password = sha256(input_json["password"].encode()).hexdigest()	#hash password
	fullname = input_json["fullname"]
	role = input_json["role"]
	hashedId = sha256((username+password).encode()).hexdigest()	#for hashed userId
	print(hashedId)
	#DONE could pass username+password hash for user id here OR could calc hash in product.sol
	
	# check if username exists and for that username is password is same
	p = conn.functions.getLoginDetails(username).call()
	# print("HASHED PASSWORD",p)
	if (p!=""):
		return ("Username already exists!",500)

	#call addParticipant function of Product.sol
	tx_hash = conn.functions.addParticipant(username,password,fullname,role,hashedId).transact()
	tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
	print("RECEIPT",tx_receipt)
	
	#confirm added participant --- no return value of user hash as of now
	print("GET PARTICIPANT",conn.functions.getParticipant(hashedId).call())
	return ('Added Participant successfully', 204)

# @app.route('/getuser', methods=['GET'])
# def getparticipant():
# 	print(conn.functions.getParticipant("137f8dd76837941037a63f22cc277577bf41c94d3be55c232ee6e9fea8cb465e").call())
# 	return ('', 204)

# merge -- deleteProducts + addToOwner
@app.route('/merge',methods=['POST'])
def merge_children():
	input_json = request.get_json(force=True)
	# expecting children id array and ownerid
	childrenIds = input_json["childrenIds"]
	ownerId = input_json["ownerId"]

	# extract the parent id from one of the children 
	# (assuming that user selects "correct" and "all" children ids products corr to only 1 parent)
	# correctness: can check here or in flutter? not sure yet (could store parent ids flutter side -performance?)
	# not all: logic needs to be added here: make new product with remaining quantity (thats not merge though)

	p = conn.functions.getProduct(childrenIds[0]).call() #p is a tuple with the product structure type.
	parent_id = p[2][0]

	# check if not all
	parent = conn.functions.getProduct(parent_id).call()
	print("PARENT:",parent_id,parent)

	# delete childrenIds
	tx_hash = conn.functions.deleteProducts(childrenIds,ownerId).transact()
	tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
	print("Delete RECEIPT",tx_receipt)

	# NOT ALL Logic -> delete the products and add a new product with their quantities added together else
	# add parent id to products owned

	if len(parent[3]) != len(childrenIds):
		tx_hash = conn.functions.addProduct(p[0],[parent_id],[],p[4],"new prop with ADDED quantities OF 2 CHILDS").transact()
		tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash) #how to get returned value?
		print("AddNewProduct",tx_receipt)
	else:
		# add the parent id to products owned
		tx_hash = conn.functions.addToOwner(parent_id,ownerId).transact()
		tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
		print("AddtoOwner RECEIPT",tx_receipt)

	# check owned
	print(conn.functions.getProductsOwned(ownerId).call())
	return ('', 204)

