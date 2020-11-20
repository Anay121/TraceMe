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
    
    mapping(uint => Participant) participant;   // userId -> User Object
    uint[] participantIds;
    uint uid = 0;
    
    mapping (uint => uint[]) productsOwned; // ParticipantId -> all products 
    mapping (uint => Trace[]) public productTrace; // productId -> Trace array
    mapping (uint => Product) products;      // productId -> Product Object
    uint pid = 0;
    
    modifier onlyOwner(uint _senderId, uint _productId){
        require(products[_productId].currentOwnerId == _senderId, "Its not yours");
        _;
    }
    
    function addParticipant (string memory _username, string memory _password, string memory _fullname, string memory _role) public returns(uint) {
        Participant memory p = Participant(_username, _password, _fullname, _role);
        participant[++uid] = p;
        participantIds.push(uid);
        return(uid);
    }
    // TODO:login?
    
    function getParticipant (uint _id) public view returns(Participant memory) {
        return( participant[_id]);
    }
    
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
    
    function removeFromOwner(uint _ownerId, uint _productId) public onlyOwner(_ownerId, _productId) {
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
    
    function TransferOwnership(
        uint _senderId, uint _receiverId, uint _productId, string memory _location, string memory _time
        ) public onlyOwner(_senderId, _productId) {
        
        // Update Trace array
        productTrace[_productId].push(Trace(_time, _location, _senderId, _receiverId));
        
        // update products owned
        removeFromOwner(_senderId, _productId);
        productsOwned[_receiverId].push(_productId);
        
        // Change owner
        products[_productId].currentOwnerId = _receiverId;
        
        
    }
    
    function addToOwner(uint _parentId, uint _ownerId) public {
        require(products[_parentId].currentOwnerId == _ownerId, "The old product was not yours");
        productsOwned[_ownerId].push(_parentId);
    }
    
    function deleteProducts(uint[] memory _childrenIds, uint _ownerId) public {
        
        for(uint i=0; i < _childrenIds.length; i++){
            // remove from productsOwned
            removeFromOwner(_ownerId, _childrenIds[i]);
            
            //remove from parents    
            
            for( uint j = 0; j < products[_childrenIds[i]].parentId.length; j++){  // maybe change later
                
                bool flag = false;
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
    
    
    
    // function split(int[] memory _productId, string[] memory _encProdProps, uint _ownerId) public returns(uint[] memory finalProducts) {
    //     string memory p = products[uint(_productId[0])].productName;
    //     uint[] memory t1;
    //     // int[] memory t2;
    //     // t2[t2.length] = _productId;
    //     for(uint i = 0; i < _encProdProps.length; i++){
    //         uint newId = addProduct(p, _productId, t1, _ownerId, _encProdProps[i]);
            
    //         finalProducts;
    //     }
    //     // remove from owned
    //     removeFromOwner(_ownerId, uint(_productId[0]));
        
    // }
    
    
    // function for tracing
    
    // function makeTrace(int _productId) public pure returns(Product[] memory p){
    //     p = products;
    //     // flag = true;
    //     // while (flag) {
            
    //     // }
    // }
}