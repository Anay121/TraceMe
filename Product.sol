pragma solidity >=0.7.0 <0.8.0;
pragma experimental ABIEncoderV2;

// SPDX-License-Identifier: MIT;

contract SupplyChain {
    
    uint pid = 0;
    
    // SRUCTS
    
    // Participant Struct
    struct Participant {
        string username;
        string password;
        string fullname;
        string role;
    }
    
    // Trace Struct
    struct Trace {
        string time;
        string location;
        string senderId;
        string receiverId;
    }
    
    // Product Struct
    struct Product {
        string productName;
        // mapping(string => string) productProperties;
        string encProdProps;
        // Trace trace;
        int[] parentId;
        uint[] childrenId;
        string currentOwnerId;
    }
    
    // MAPPINGS
    
    mapping(string => Participant) participant;   // userId -> User Object
    string[] participantIds;
    
    mapping(string => string) loginDetails; // username -> hashed password mapping
    
    mapping (string => uint[]) public productsOwned; // ParticipantId -> current products
    
    mapping (uint => Trace[]) public productTrace; // productId -> Trace array
    
    mapping (uint => Product) products;      // productId -> Product Object
    
    // UTILITY FUNCTIONS
    
    function compareStrings(string memory a, string memory b) public pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
    
    modifier onlyOwner(string memory _senderId, uint _productId){
        // require(products[_productId].currentOwnerId == _senderId, "Its not yours");
        require(compareStrings(products[_productId].currentOwnerId,_senderId),"You dont own this product");
        _;
    }
    
    // VIEW FUNCTIONS
    
    function getProductsOwned(string memory _id) public view returns(uint[] memory){
        return(productsOwned[_id]);
    }
   
    function getLoginDetails (string memory _username) public view returns(string memory) {
        return(loginDetails[_username]);
    }
    
    function getParticipant (string memory _id) public view returns(Participant memory) {
        return( participant[_id]);
    }
    
    function getProduct(uint _pid) public view returns(Product memory){
        return(products[_pid]);
    }
    
    // IMPORTANT FUNCTIONS
    
    function addParticipant (string memory _username, string memory _password, string memory _fullname, string memory _role, string memory hashedId) public returns(string memory) {
        Participant memory p = Participant(_username, _password, _fullname, _role);
        string memory uid = hashedId;
        participant[uid] = p;
        participantIds.push(uid);
        loginDetails[_username]=_password;
        
        return(uid);
    }
    
    function addProduct( 
        string memory _productName, int[] memory _parentId, uint[] memory _childrenId, string memory _currentOwnerId, 
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
                // require(products[uint(_parentId[j])].currentOwnerId == _currentOwnerId, "You dont own this product");
                require(compareStrings(products[uint(_parentId[j])].currentOwnerId,_currentOwnerId),"You dont own this product");
                products[uint(_parentId[j])].childrenId.push(pid+1);
            }
        }
        productsOwned[_currentOwnerId].push(pid+1);
        products[++pid] = p;
        
        return pid;
    }
    
    function TransferOwnership(
        string memory _senderId, string memory _receiverId, uint _productId, string memory _location, string memory _time
        ) public onlyOwner(_senderId, _productId) {
        
        // Update Trace array
        productTrace[_productId].push(Trace(_time, _location, _senderId, _receiverId));
        
        // update products owned
        removeFromOwner(_senderId, _productId);
        productsOwned[_receiverId].push(_productId);
        
        // Change owner
        products[_productId].currentOwnerId = _receiverId;
    }
    
    function deleteProducts(uint[] memory _childrenIds, string memory _ownerId) public {
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
    
    function addToOwner(uint _parentId, string memory _ownerId) public { //where is this used??
        // require(products[_parentId].currentOwnerId == _ownerId, "The old product was not yours");
        require(compareStrings(products[_parentId].currentOwnerId,_ownerId),"The old product was not yours");
        productsOwned[_ownerId].push(_parentId);
    }
    
    function removeFromOwner(string memory _ownerId, uint _productId) public onlyOwner(_ownerId, _productId) {
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
    
    // function makeTrace(int _productId) public pure returns(Product[] memory p){
    //     p = products;
    //     // flag = true;
    //     // while (flag) {
            
    //     // }
    // }
}