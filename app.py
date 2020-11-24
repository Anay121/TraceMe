from flask import Flask, request, url_for, jsonify
import json
from web3connection import Connection

app = Flask(__name__)
c = Connection()
conn,w3 = c.create_conn()
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
	print(conn.functions.getProductsOwned(1).call())

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
	print(conn.functions.getProductsOwned(1).call())

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
	password = input_json["password"]
	fullname = input_json["fullname"]
	role = input_json["role"]
	#TODO could pass username+password hash for user id here OR could calc hash in product.sol

	#call addParticipant function of Product.sol
	tx_hash = conn.functions.addParticipant(username,password,fullname,role).transact()
	tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
	print("RECEIPT",tx_receipt)
	
	#confirm added participant --- no return value of user hash as of now
	# print("GET PARTICIPANT",conn.functions.getParticipant(1).call())
	return ('', 204)

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
	print("Parent_id: ", parent_id)
	
	# delete childrenIds
	tx_hash = conn.functions.deleteProducts(childrenIds,ownerId).transact()
	tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
	print("Delete RECEIPT",tx_receipt)

	# add the parent id to products owned
	tx_hash = conn.functions.addToOwner(parent_id,ownerId).transact()
	tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
	print("AddtoOwner RECEIPT",tx_receipt)

	# check owned
	print(conn.functions.getProductsOwned(1).call())
	return ('', 204)