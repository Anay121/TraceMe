from flask import Flask, request, url_for, jsonify
import json
from web3connection import Connection
import dotenv

app = Flask(__name__)
c = Connection()
conn,w3 = c.create_conn()
print(conn)

#https://stackoverflow.com/questions/10313001/is-it-possible-to-make-post-request-in-flask 
@app.route('/split', methods=['POST'])
def home():
	input_json = request.get_json(force=True)
	#expectation for input_json is product_id and quantities_array[]
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

	# return 

@app.route('/trial', methods=['GET'])
def current_ownership():
	print(conn.functions.getProductsOwned(1).call())