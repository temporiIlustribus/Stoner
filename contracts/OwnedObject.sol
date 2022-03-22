// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
pragma abicoder v2;

// Based on example from https://docs.soliditylang.org/en/latest/structure-of-a-contract.html
contract OwnedObject {
    address payable owner;
    constructor() payable { 
        owner = payable(msg.sender); 
    }

    modifier onlyOwner() {
        require(payable(msg.sender) == owner, "Can only be called by owner");
        _;
    }

    function makeOwner(address _addr) public onlyOwner {
        owner = payable(_addr);
    }
}