// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
pragma abicoder v2;

import './Storage.sol';
import './IdList.sol';
using IdContainers for GList;

struct UserProfile {
    uint id;
    bytes32 username;
    string publicName;
    string bio;
    string profilePicture; // Use profile picture addresses with files stored on separate service (for example - ipfs)

    uint tweetNum;
}

// Stores UserProfiles; does not do any complicated validation.
// Use UserStorage to manage data access
contract UserData is BaseData {
    
    mapping (address => uint) public ids;
    mapping (uint => UserProfile) public profileMapper;
    mapping (bytes32 => address) public usernameMapper;
    mapping (uint => GList) subscribtions; 

    function createProfile(address _addr, bytes32 _username, string memory _publicName, string memory _bio) 
        public onlyManager returns(uint _id) 
    {
        _id = uint(keccak256(abi.encodePacked(_addr, _username)));
        profileMapper[_id] = UserProfile(_id, _username, _publicName, _bio, "", 0);
        ids[_addr] = _id;
        usernameMapper[_username] = _addr;
        return _id;
    }

    function getAddress(bytes32 _username) public onlyManager view returns(address) {
        return usernameMapper[_username];
    }

    function getId(address _addr) public onlyManager view returns(uint) {
        return ids[_addr];
    }

    function getUsername(uint _id) public onlyManager view returns(bytes32) {
        return profileMapper[_id].username;
    }

    function getPublicName(uint _id) public onlyManager view returns(string memory) {
        return profileMapper[_id].publicName;
    }

    function getBio(uint _id) public onlyManager view returns(string memory) {
        return profileMapper[_id].bio;
    }

    function getTweetNum(uint _id) public onlyManager view returns(uint) {
        return profileMapper[_id].tweetNum;
    }

    function getProfile(uint _id) public onlyManager view returns(UserProfile memory) {
        return profileMapper[_id];
    }

    // Sadly this seems to be the only way to propperly copy from storage to memory
    function getSubBatch(uint _id, uint _offset) public onlyManager view returns(uint[] memory) {
        uint len = subscribtions[_id].length() > 32 + _offset ? 32 + _offset : subscribtions[_id].length();
        uint[] memory batch = new uint[](len - _offset);
        uint subId;
        bool flag;
        uint j = 0;
        for (uint i = _offset; i < len; ++i) {
            (subId, flag) = subscribtions[_id].getRecord(i);
            if (flag) {
                batch[j] = subId;
                j += 1;
            }
        }
        return batch;
    }

    function getSub(uint _id, uint _index) public onlyManager view returns(uint subId) {
        subId = subscribtions[_id].get(_index);
    }

    function getSubCount(uint _id) public onlyManager view returns(uint subCount) {
        subCount = subscribtions[_id].count;
    }

    function addSub(uint _id, uint subId) public onlyManager returns(uint index){
        index = subscribtions[_id].add(subId);
    }

    function removeSub(uint _id, uint subId) public onlyManager returns(bool success, uint pos){
        (success, pos) = subscribtions[_id].remove(subId);
    }

    function updateProfile(uint _id, UserProfile memory _newProfile) public onlyManager {
        profileMapper[_id] = _newProfile;
    }
}