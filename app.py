from web3 import Web3
from flask import Flask
import json

app = Flask(__name__)

@app.route('/')

def home():
	return 'Hello World'