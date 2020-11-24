from web3 import Web3
from flask import Flask
import json

my_provider = Web3.HTTPProvider('http://127.0.0.1:7545')

w3 = Web3(my_provider)

w3.eth.defaultAccount = w3.eth.accounts[0]
print(w3.isConnected())

my_abi = [
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "initCount",
                "type": "uint256"
            }
        ],
        "stateMutability": "nonpayable",
        "type": "constructor"
    },
    {
        "inputs": [],
        "name": "func",
        "outputs": [
            {
                "components": [
                    {
                        "internalType": "uint256[]",
                        "name": "a1",
                        "type": "uint256[]"
                    },
                    {
                        "internalType": "uint256[]",
                        "name": "a2",
                        "type": "uint256[]"
                    }
                ],
                "internalType": "struct Coursetro.IDK",
                "name": "o",
                "type": "tuple"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "getCount",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "getInstructor",
        "outputs": [
            {
                "internalType": "string",
                "name": "",
                "type": "string"
            },
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "incrementCount",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "string",
                "name": "_fName",
                "type": "string"
            },
            {
                "internalType": "uint256",
                "name": "_age",
                "type": "uint256"
            }
        ],
        "name": "setInstructor",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    }
]

greeter = w3.eth.contract(address="0x8e4b7b314A8Fe447A06f0D2aC8444EC868b16961", abi=my_abi)

app = Flask(__name__)

@app.route('/view')
def home():

    tx_hash = greeter.functions.incrementCount().transact()
    tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
    
    print(tx_receipt)
    
    # calling
    x = greeter.functions.func().call()
    print(x)
    d = {'value':json.dumps(x)}
    print(d)
    return d