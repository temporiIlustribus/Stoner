// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract ReEntrancyGuard {
    bool internal locked;

    modifier noReentrant() {
        require(!locked);
        locked = true;
        _;
        locked = false;
    }
}