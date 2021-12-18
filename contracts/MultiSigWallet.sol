// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

contract MultiSigWallet{
    address[] public owners;
    event TxApproved(address indexed approvedBy, uint indexed index_, address receiver, uint amount);
    uint limits;
    //  ["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4", "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2", "0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db"] 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db
    constructor(address[] memory _owners) {
        bool senderInList=false;
        for (uint i=0; i<_owners.length; i++) {
            if (_owners[i]==msg.sender) {
                senderInList=true;
            }
        }
        if (senderInList==false) {
            owners=_owners;
            owners.push(msg.sender);
            limits=((owners.length*2)/3)*10**18;
        }else{
            owners=_owners;
            limits=((owners.length*2)/3)*10**18;
        }
    }
    
    modifier isOwner {
        bool owner = false;
        for (uint i=0; i<owners.length; i++){
            if (owners[i] == msg.sender) {
                owner=true;
            }
        }
        require(owner==true, "You're not a signatory of this contract.");
        _;
    }
    
    struct Transaction {
        uint amount;
        address payable receiver;
        uint approvals;
        bool hasBeenSent;
        uint id;
    }
    
    // Approval maps an owner to the id of a transaction which maps to True/False, depending on whether a user has approved a given transaction or not.
    mapping(address=>mapping(uint=>bool)) public approvals; 
    Transaction[] public txRequests; // Transaction list
    
    // Performs a transfer from the multisig wallet. which in turn requires two-third of signatories to approve in order to complete.
    function makeTransfer(address payable _to, uint _amount) public {
        require(address(this).balance>=_amount, "Insufficient balance!");
        uint _index=txRequests.length;
        txRequests.push(Transaction(_amount, _to, 1, false, _index));
        approvals[msg.sender][_index]=true;
    }
    
    // Owners can approve Transactions from this function. 
    // It also checks to confirm if up to two-third of the owners have approved the transaction in order to confirm said transaction.
    // Also makes sure an owner can not approve a transaction twice.
    function approveTransfer(uint _index) public isOwner{
        if (_index>=txRequests.length) return;
        require(approvals[msg.sender][_index]==false);
        require(txRequests[_index].hasBeenSent==false);
        approvals[msg.sender][_index]=true;
        txRequests[_index].approvals+=1;
        uint count=(txRequests[_index].approvals)*10**18;
        if (count>=limits) {
            txRequests[_index].receiver.transfer(txRequests[_index].amount);
            txRequests[_index].hasBeenSent=true;
        }
        emit TxApproved(msg.sender, _index, txRequests[_index].receiver, txRequests[_index].amount);
    }
    
    // Deposit Function anybody can deposit to this contract using deposit()
    function deposit() public payable returns(uint) {}
    
    // Get MultiSig Wallet balance. Only owners can access this function
    function getBalance() public view isOwner returns(uint) {
        return address(this).balance;
    }
    
    // Returns List of Transactions
    function getTxRequests() public view returns (Transaction[] memory){
        return txRequests;
    }
}
