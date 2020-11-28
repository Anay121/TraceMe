from web3 import Web3
import os


class Connection:
    def create_conn(self):
        my_provider = Web3.HTTPProvider('http://127.0.0.1:7545')
        w3 = Web3(my_provider)
        w3.eth.defaultAccount = w3.eth.accounts[0]
        print("Connection established:", w3.isConnected())
        with open("abi.json") as f:
            my_abi = json.loads(f.read())
        # greeter = w3.eth.contract(address=os.getenv('CONTRACT_ADDRESS') , abi=my_abi)
        greeter = w3.eth.contract(
            address="0xECf196060c6e25869d4c5345fB17d3fd75D41863", abi=my_abi)
        return greeter, w3
