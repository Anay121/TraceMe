from web3 import Web3
import os
class Connection :
    def create_conn(self):
        my_provider = Web3.HTTPProvider('http://127.0.0.1:7545')
        w3 = Web3(my_provider)
        w3.eth.defaultAccount = w3.eth.accounts[0]
        print("Connection established:", w3.isConnected())
        my_abi =[
            {
                "inputs": [
                    {
                        "internalType": "string",
                        "name": "_username",
                        "type": "string"
                    },
                    {
                        "internalType": "string",
                        "name": "_password",
                        "type": "string"
                    },
                    {
                        "internalType": "string",
                        "name": "_fullname",
                        "type": "string"
                    },
                    {
                        "internalType": "string",
                        "name": "_role",
                        "type": "string"
                    }
                ],
                "name": "addParticipant",
                "outputs": [
                    {
                        "internalType": "uint256",
                        "name": "",
                        "type": "uint256"
                    }
                ],
                "stateMutability": "nonpayable",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "string",
                        "name": "_productName",
                        "type": "string"
                    },
                    {
                        "internalType": "int256[]",
                        "name": "_parentId",
                        "type": "int256[]"
                    },
                    {
                        "internalType": "uint256[]",
                        "name": "_childrenId",
                        "type": "uint256[]"
                    },
                    {
                        "internalType": "uint256",
                        "name": "_currentOwnerId",
                        "type": "uint256"
                    },
                    {
                        "internalType": "string",
                        "name": "_encProdProps",
                        "type": "string"
                    }
                ],
                "name": "addProduct",
                "outputs": [
                    {
                        "internalType": "uint256",
                        "name": "",
                        "type": "uint256"
                    }
                ],
                "stateMutability": "nonpayable",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "uint256",
                        "name": "_parentId",
                        "type": "uint256"
                    },
                    {
                        "internalType": "uint256",
                        "name": "_ownerId",
                        "type": "uint256"
                    }
                ],
                "name": "addToOwner",
                "outputs": [],
                "stateMutability": "nonpayable",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "uint256[]",
                        "name": "_childrenIds",
                        "type": "uint256[]"
                    },
                    {
                        "internalType": "uint256",
                        "name": "_ownerId",
                        "type": "uint256"
                    }
                ],
                "name": "deleteProducts",
                "outputs": [],
                "stateMutability": "nonpayable",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "uint256",
                        "name": "_id",
                        "type": "uint256"
                    }
                ],
                "name": "getProductsOwned",
                "outputs": [
                    {
                        "internalType": "uint256[]",
                        "name": "",
                        "type": "uint256[]"
                    }
                ],
                "stateMutability": "nonpayable",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "uint256",
                        "name": "_ownerId",
                        "type": "uint256"
                    },
                    {
                        "internalType": "uint256",
                        "name": "_productId",
                        "type": "uint256"
                    }
                ],
                "name": "removeFromOwner",
                "outputs": [],
                "stateMutability": "nonpayable",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "uint256",
                        "name": "_senderId",
                        "type": "uint256"
                    },
                    {
                        "internalType": "uint256",
                        "name": "_receiverId",
                        "type": "uint256"
                    },
                    {
                        "internalType": "uint256",
                        "name": "_productId",
                        "type": "uint256"
                    },
                    {
                        "internalType": "string",
                        "name": "_location",
                        "type": "string"
                    },
                    {
                        "internalType": "string",
                        "name": "_time",
                        "type": "string"
                    }
                ],
                "name": "TransferOwnership",
                "outputs": [],
                "stateMutability": "nonpayable",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "uint256",
                        "name": "_id",
                        "type": "uint256"
                    }
                ],
                "name": "getParticipant",
                "outputs": [
                    {
                        "components": [
                            {
                                "internalType": "string",
                                "name": "username",
                                "type": "string"
                            },
                            {
                                "internalType": "string",
                                "name": "password",
                                "type": "string"
                            },
                            {
                                "internalType": "string",
                                "name": "fullname",
                                "type": "string"
                            },
                            {
                                "internalType": "string",
                                "name": "role",
                                "type": "string"
                            }
                        ],
                        "internalType": "struct SupplyChain.Participant",
                        "name": "",
                        "type": "tuple"
                    }
                ],
                "stateMutability": "view",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "uint256",
                        "name": "_pid",
                        "type": "uint256"
                    }
                ],
                "name": "getProduct",
                "outputs": [
                    {
                        "components": [
                            {
                                "internalType": "string",
                                "name": "productName",
                                "type": "string"
                            },
                            {
                                "internalType": "string",
                                "name": "encProdProps",
                                "type": "string"
                            },
                            {
                                "internalType": "int256[]",
                                "name": "parentId",
                                "type": "int256[]"
                            },
                            {
                                "internalType": "uint256[]",
                                "name": "childrenId",
                                "type": "uint256[]"
                            },
                            {
                                "internalType": "uint256",
                                "name": "currentOwnerId",
                                "type": "uint256"
                            }
                        ],
                        "internalType": "struct SupplyChain.Product",
                        "name": "",
                        "type": "tuple"
                    }
                ],
                "stateMutability": "view",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "uint256",
                        "name": "",
                        "type": "uint256"
                    },
                    {
                        "internalType": "uint256",
                        "name": "",
                        "type": "uint256"
                    }
                ],
                "name": "productsOwned",
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
                "inputs": [
                    {
                        "internalType": "uint256",
                        "name": "",
                        "type": "uint256"
                    },
                    {
                        "internalType": "uint256",
                        "name": "",
                        "type": "uint256"
                    }
                ],
                "name": "productTrace",
                "outputs": [
                    {
                        "internalType": "string",
                        "name": "time",
                        "type": "string"
                    },
                    {
                        "internalType": "string",
                        "name": "location",
                        "type": "string"
                    },
                    {
                        "internalType": "uint256",
                        "name": "senderId",
                        "type": "uint256"
                    },
                    {
                        "internalType": "uint256",
                        "name": "receiverId",
                        "type": "uint256"
                    }
                ],
                "stateMutability": "view",
                "type": "function"
            }
        ]
        greeter = w3.eth.contract(address=os.getenv('CONTRACT_ADDRESS') , abi=my_abi)
        return greeter,w3
