// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import './OwnedObject.sol';

contract BaseData is OwnedObject {
    address storageManager;

    function setManagerAddr(address _managerAddr) public onlyOwner {
        storageManager = _managerAddr; 
    }

    modifier onlyManager() {
        require(msg.sender == storageManager);
        _;
    }

}