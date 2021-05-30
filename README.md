<p align="center">
  <a href="" rel="noopener">
 <img width=40% src="trace_me\assets\icon\logo1.png" alt="TraceMe-logo"></a>
</p>

# TraceMe
Trace Me is a mobile application developed in flutter which utilises the Ethereum blockchain to keep track of the farm produce and transactions with the intention to help towards food security. It is a secure system which provides transparency and auditing for farmers, supply chain entities, and consumers.

The system is developed using - 
1) Ethereum Blockchain (Ganache & Remix).
2) Solidity (Domain-specific language for smart contract development).
3) Python - Flask (for API development).
4) Flutter (Cross-platform app development).

## Usage

1) Add backend/smart_contract/product.sol code to remix and connect with Ganache.
2) Setup the .env in the root folder with -
   - JWT_SECRET_KEY (eg: "keyboard cat"; preferably a randomly generated string using os.urandom())
   - GANACHE_ADDRESS (usually: http://127.0.0.1:7545)
   - CONTRACT_ADDRESS (The contract address in Ganache)   
3) Setup .flaskenv in the root folder with -
   - FLASK_APP=main, and other config variables which can be found in the Flask documentation
4) Install dependencies.
``` bash
    pip install -r requirements.txt
```
6) Run the Flask server (in the root folder).
``` bash
    flask run 
```

## Testing

1) The Flask server is tested using the VSCode HTTP Client extension.
2) The HTTP requests are to be contained within the test.http file in Backend/API/Testing.
3) Refer the HTTP Client documentation for usage.

## Running the Flutter App

1) cd to trace_me
```bash
cd trace_me
```
2) Connect the phone to the computer with USB Debugging enabled
```bash
flutter run
```
3) You can also make the apk for installing directly via flutter build
```bash
flutter build apk --release
```

## Style Guide

1) Try to conform to the PEP 8 rules (for any python code) as in: https://www.python.org/dev/peps/pep-0008/.

## Contributors

This application has been build as part of the Final year BE project by [fate2703](https://github.com/fate2703), [anay121](https://github.com/anay121), [chumba-wamba](https://github.com/chumba-wamba), [anjum-k](https://github.com/Anjum-K99) 

