pragma solidity ^0.6.6;
pragma experimental ABIEncoderV2;

// SPDX-License-Identifier: MIT;

contract SupplyChain {
    // Participant
    
    struct Participant {
        string username;
        string password;
        string fullname;
        string role;
    }
    
    mapping(uint => Participant) participant;   // userId -> User Object
    uint uid = 0;
    
    function addParticipant (string memory _username, string memory _password, string memory _fullname, string memory _role) public returns(uint) {
        Participant memory p = Participant(_username, _password, _fullname, _role);
        participant[++uid] = p;
        return(uid);
    }
    // TODO:login?
    
    function getParticipant (uint _id) public view returns(Participant memory) {
        return( participant[_id]);
    }

    // Trace
    struct Trace {
        string time;
        string location;
        uint senderId;
        uint receiverId;
    }
    
    // Product
    
    struct Product {
        string productName;
        // mapping(string => string) productProperties;
        string encProdProps;
        // Trace trace;
        int[] parentId;
        uint[] childrenId;
        uint currentOwnerId;
    }
    
    mapping (uint => uint[]) productsOwned; // ParticipantId -> all products 
    mapping (uint => Trace[]) productTrace; // productId -> Trace array
    mapping (uint => Product) products;      // productId -> Product Object
    uint pid = 0;
    
    function addProduct( 
        string memory _productName, int[] memory _parentId, uint[] memory _childrenId, uint _currentOwnerId, 
        string memory _encProdProps  // encoded product properties
        ) public returns(uint) {
        Product memory p; 
        
        p.productName = _productName;
        p.parentId = _parentId;
        p.childrenId = _childrenId;
        p.currentOwnerId = _currentOwnerId;
        p.encProdProps = _encProdProps;
        // productTrace[pid+1].push(Trace(_time, _location, _currentOwnerId, _newOwnerId));
        
        for(uint j = 0; j<_parentId.length; j++) {
            if(_parentId[j] != -1) {
                require(products[uint(_parentId[j])].currentOwnerId == _currentOwnerId, "You dont own this product");
                products[uint(_parentId[j])].childrenId.push(pid+1);
            }
        }
        productsOwned[_currentOwnerId].push(pid+1);
        products[++pid] = p;
        
        return pid;
    }
    
    
    function getProduct(uint _pid) public view returns(Product memory){
        return(products[_pid]);
    }
    
    function removeFromOwner(uint _ownerId, uint _productId) private{
        bool flag = false;
        for(uint i = 0; i < productsOwned[_ownerId].length - 1; i++){
            
            if(productsOwned[_ownerId][i] == _productId){
                flag = true;
            }
            
            if(flag){
                productsOwned[_ownerId][i] = productsOwned[_ownerId][i+1];
            }
        }
        productsOwned[_ownerId].pop();
    }

    // transfer ownership
    
    modifier onlyOwner(uint _senderId, uint _productId){
        require(products[_productId].currentOwnerId == _senderId, "Its not yours");
        _;
    }
    
    function TransferOwnership(
        uint _senderId, uint _receiverId, uint _productId, string memory _location, string memory _time
        ) onlyOwner(_senderId, _productId) public {
        
        // Update Trace array
        productTrace[_productId].push(Trace(_time, _location, _senderId, _receiverId));
        
        // Change owner
        products[_productId].currentOwnerId = _receiverId;
        
        // update products owned
        bool flag = false;
        for(uint i = 0; i < productsOwned[_senderId].length - 1; i++){
            if(productsOwned[_senderId][i] == _productId){
                flag = true;
            }
            if(flag){
                productsOwned[_senderId][i] = productsOwned[_senderId][i+1];
            }
        }
        productsOwned[_senderId].pop();
        productsOwned[_receiverId].push(_productId);
        
        
    }
    
    function deleteProducts(uint[] memory _childrenIds, uint _ownerId) public {
        
        for(uint i=0; i < _childrenIds.length; i++){
            // remove from productsOwned
            
            bool flag = false;
            for(uint j = 0; j < productsOwned[_ownerId].length - 1; j++){
                
                if(productsOwned[_ownerId][j] == _childrenIds[i]){
                    flag = true;
                }
                
                if(flag){
                    productsOwned[_ownerId][j] = productsOwned[_ownerId][j+1];
                }
            }
            productsOwned[_ownerId].pop();
            
            
            //remove from parents    
            
            for( uint j = 0; j < products[_childrenIds[i]].parentId.length; j++){  // maybe change later
                
                flag = false;
                Product memory p = products[uint(products[_childrenIds[i]].parentId[j])];
                for(uint k = 0; k < p.childrenId.length - 1; k++){
                    
                    if(p.childrenId[k] == _childrenIds[i]){
                        flag = true;
                    }
                    if(flag){
                        p.childrenId[k] = p.childrenId[k+1];
                    }
                }

                products[uint(products[_childrenIds[i]].parentId[j])] = p;
                products[uint(products[_childrenIds[i]].parentId[j])].childrenId.pop();
            }
            
            //remove from products
            delete products[_childrenIds[i]];
        }
    }
    
    // split
    
    function split(uint _productId, string[] memory _encProdProps, uint _ownerId) public {
        Product memory p = products[_productId];
        for(uint i = 0; i < _encProdProps.length; i++){
            // make a new product
            // uint[] memory t1;
            // = [uint(_productId)];
            // t1.push(uint(_productId));
            // uint newId = addProduct(p.productName, t1,  [], _ownerId, _encProdProps[i]);
            
        }
        // remove from owned
        removeFromOwner(_ownerId, _productId);
        
    }
    
    
    // function for tracing
}
