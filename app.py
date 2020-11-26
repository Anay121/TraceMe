from flask import Flask, request, url_for, jsonify
import json, time, os
from web3connection import Connection
import dotenv
from hashlib import sha256
from flask_jwt_extended import (
    JWTManager, jwt_required, create_access_token,
    get_jwt_identity
)

app = Flask(__name__)
app.config['JWT_SECRET_KEY'] = os.getenv('JWT_SECRET')
jwt = JWTManager(app)
c = Connection()
conn, w3 = c.create_conn()
print(conn)


#https://stackoverflow.com/questions/10313001/is-it-possible-to-make-post-request-in-flask 
@app.route('/split', methods=['POST'])
def home():
	input_json = request.get_json(force=True)
	# expectation for input_json is product_id and quantities_array[]
	# check quantities (can be done on flutter - should be done on flutter)
	# call add products, if successful
	print("here",input_json)
	quantities = input_json["quantities"]
	#get the product:
	parent_id = input_json["product_id"]

	#check owned before:
	# print(conn.functions.getProductsOwned(1).call())

	p = conn.functions.getProduct(parent_id).call() #p is a tuple with the product structure type.
	print(p)
	#addProduct will add the new product into the productsOwned but will not remove the parent.
	for q in quantities:
		#TODO encode the quanitities and the prop
		tx_hash = conn.functions.addProduct(p[0],[parent_id],[],p[4],"new prop with new quantities"+str(q)).transact()
		tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash) #how to get returned value?
		
		print(tx_receipt)
		# flag = conn.functions.addProduct(p[0],[parent_id],[],p[4],"new prop with new quantities"+str(q)).call()
		# print("Added new product with ID",flag)
	# check and change ownership
	# remove from parent
	tx_hash = conn.functions.removeFromOwner(p[4],parent_id).transact()
	tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)

	#check owned after:
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
	print(conn.functions.getProductsOwned(1).call())
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
	
	# assume only one product is being transfered
	# call transfer
	try:
		tx_hash = conn.functions.TransferOwnership(sender_id, receiver_id, product_id, location, str(time.time())).transact()
		tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
	# print(tx_receipt)
	except:
		return "Failed, Please check if all details entered were correct or not", 400
	# after returning maybe smoe way to send an OK message to both the parties
	#
	return ('', 204)


@app.route('/login', methods=['POST'])
def login():
	# get username and password
	input_json = request.get_json(force=True)
	print('Received params', input_json)
	username = input_json['username']
	password = input_json['password']

	# check if username exists
	val = conn.functions.getLoginDetails(username).call()
	# check if username password combo is correct
	# print('ret', ret)
	if val == '':
		return 'Invalid Username', 401
	
	if sha256(password.encode()).hexdigest() != val:
		return 'Invalid Attempt', 401

	hashedId = sha256((username + val).encode()).hexdigest()	#for hashed userId
	# print(hashedId)
	user_details = conn.functions.getParticipant(hashedId).call()
	print('User Details', user_details)
	# generate a token also maybe?
	access_token = create_access_token(identity = hashedId)
	# return the generated token
	return jsonify({'userid': hashedId, 'JWTAccessToken': access_token}), 200