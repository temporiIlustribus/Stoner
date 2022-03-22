// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
pragma abicoder v2;

import './UserData.sol';

/*
 * Basic idea:  
 *     - Deploy main contract and UserData which holds mappings to all userProfiles
 *     - Deploy UserStorage which manages storage.
 *     - Bind UserStorage
 *
 *     If the validation or data access needs to be changed - deploy the updated UserStorage contract and rebind
 */

// Used for data access and validation; binds to UserData. Can be modified and redeployed.
contract UserStorage is OwnedObject {
    address userDataAddr;

    modifier userDataBinded() {
        require(userDataAddr != address(0));
        _;
    }

    modifier validUserId(uint _id) {
        require(_id != 0);
        UserData userData = UserData(userDataAddr);
        require(_id == userData.getProfile(_id).id);
        _;
    }

    modifier validUser(address _addr) {
        UserData userData = UserData(userDataAddr);
        uint userId = userData.getId(_addr);
        require(userId != 0);
        _;
    }

    modifier validLengthName(string memory _name) {
        require(bytes(_name).length <= 64);
        _;
    }

    modifier validLengthBio(string memory _bio) {
        require(bytes(_bio).length <= 160);
        _;
    }

    modifier validProfileValues(bytes32 _username, string memory _publicName) {
        require(bytes(_publicName).length <= 64);
        UserData userData = UserData(userDataAddr);
        // We require username to be unique
        require(userData.getAddress(_username) == address(0));
        _;
    }

    modifier validNewAddr(address _addr) {
        UserData userData = UserData(userDataAddr);
        require(userData.getId(_addr) == 0);
        _;
    }

    function bindData(address _addr) public onlyOwner {
        userDataAddr = _addr;
    }

    function getUserProfile(uint _id) public userDataBinded validUserId(_id) view returns(UserProfile memory) {
        UserData userData = UserData(userDataAddr);
        return userData.getProfile(_id);
    }

    function getUserAddress(bytes32 _username) public userDataBinded view returns(address _addr) {
        UserData userData = UserData(userDataAddr);
        return userData.getAddress(_username); 
    }

    function getUserId(address _addr) public userDataBinded view returns(uint) {
        UserData userData = UserData(userDataAddr);
        uint userId = userData.getId(_addr);
        return userId; // 0 means unregistered
    }
    
    // Profile info access - mostly needed to save on eth tbh

    function getUsername(uint _id) public userDataBinded validUserId(_id) view returns(bytes32) {
        UserData userData = UserData(userDataAddr);
        return userData.getUsername(_id);
    }

    function getUserPublicName(uint _id) public userDataBinded validUserId(_id) view returns(string memory) {
        UserData userData = UserData(userDataAddr);
        return userData.getPublicName(_id);
    }

    function getUserBio(uint _id) public userDataBinded validUserId(_id) view returns(string memory) {
        UserData userData = UserData(userDataAddr);
        return userData.getBio(_id);
    }

    // Actually important for getting user tweets

    function getUserTweetNum(uint _id) public userDataBinded validUserId(_id) view returns(uint) {
        UserData userData = UserData(userDataAddr);
        return userData.getTweetNum(_id);
    }

    function getUserProfilePicture(uint _id) public userDataBinded validUserId(_id) view returns(string memory) {
        UserData userData = UserData(userDataAddr);
        return userData.getProfile(_id).profilePicture;
    }

    function setUserProfilePicture(uint _id, string memory _pictureAddr) public onlyOwner userDataBinded validUserId(_id) {
        require(bytes(_pictureAddr).length < 64);
        UserData userData = UserData(userDataAddr);
        UserProfile memory profile = userData.getProfile(_id);
        profile.profilePicture = _pictureAddr;
        userData.updateProfile(_id, profile);
    }

    function incrementUserTweetNum(uint _id) public onlyOwner userDataBinded validUserId(_id) returns(uint) {
        UserData userData = UserData(userDataAddr);
        UserProfile memory profile = userData.getProfile(_id);
        profile.tweetNum++;
        userData.updateProfile(_id, profile);
        return profile.tweetNum;
    }

    function addUserSubscription(uint _id, uint _subId) public onlyOwner userDataBinded validUserId(_id) {
        UserData userData = UserData(userDataAddr);
        userData.addSub(_id, _subId);
    }

    function removeUserSubscription(uint _id, uint _subId) public onlyOwner userDataBinded validUserId(_id) {
        UserData userData = UserData(userDataAddr);
        userData.addSub(_id, _subId);
    }

    function getUserSubscription(uint _id, uint _index) public onlyOwner userDataBinded validUserId(_id) view returns(uint subId) {
        UserData userData = UserData(userDataAddr);
        subId = userData.getSub(_id, _index);
    }

    function getUserSubscriptionCount(uint _id) public onlyOwner userDataBinded validUserId(_id) view returns(uint subCount) {
        UserData userData = UserData(userDataAddr);
        subCount = userData.getSubCount(_id);
    }

     function getUserSubscriptionBatch(uint _id, uint _offset) public onlyOwner userDataBinded validUserId(_id) view returns(uint[] memory) {
        UserData userData = UserData(userDataAddr);
        return userData.getSubBatch(_id, _offset);
     }

    function updateBio(uint _id, string memory _newBio) public onlyOwner userDataBinded validUserId(_id) validLengthBio(_newBio) {
        UserData userData = UserData(userDataAddr);
        UserProfile memory profile = userData.getProfile(_id);
        profile.bio = _newBio;
        userData.updateProfile(_id, profile);
    }
    
    function updatePublicName(uint _id, string memory _newName) public onlyOwner userDataBinded validUserId(_id) validLengthName(_newName) {
        UserData userData = UserData(userDataAddr);
        UserProfile memory profile = userData.getProfile(_id);
        profile.publicName = _newName;
        userData.updateProfile(_id, profile);
    }

    // Only create a new Profile if it doesn't yet exist and both username and publicName are valid 
    function createUserProfile(address _addr, bytes32 _username, string memory _publicName, string memory _bio) 
        public onlyOwner userDataBinded validNewAddr(_addr) validProfileValues(_username, _publicName) validLengthBio(_bio)
        returns(uint _id) 
    {
        UserData userData = UserData(userDataAddr);
        return userData.createProfile(_addr, _username, _publicName, _bio);
    }
}