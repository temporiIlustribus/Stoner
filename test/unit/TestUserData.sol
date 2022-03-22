// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
pragma abicoder v2;

// From truffle docs 
import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";

import "../../contracts/UserData.sol";

contract TestUserData {
    UserData userData;

    constructor() {
        userData = new UserData();
        userData.setManagerAddr(address(this));
    }

    function testProfileCreation() public {
        uint userId = userData.createProfile(address(this), "test", "Test User", "Hello World!");
        Assert.equal(userData.getId(address(this)), userId, "User id wasn't set propperly");
        Assert.equal(userData.getAddress(bytes32("test")), address(this), "User address wasn't set");
        Assert.equal(userData.getProfile(userId).publicName, "Test User", "Profile information wasn't set");
    }
}