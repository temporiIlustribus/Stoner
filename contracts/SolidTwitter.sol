// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
pragma abicoder v2;

import './UserStorage.sol';
import './TweetStorage.sol';

contract SolidTwitter is OwnedObject  {
    
    address public userStorageAddr;
    address public tweetStorageAddr;

    // Aware of the actual data, so that the storage contract can be updated easily
    address public userDataAddr;
    address public tweetDataAddr;

    modifier storageBinded() {
        require(userStorageAddr != address(0));
        require(tweetStorageAddr != address(0));
        require(userDataAddr != address(0));
        require(tweetDataAddr != address(0));
        _;
    }

    modifier validUser(address _addr) {
        UserStorage userStorage = UserStorage(userStorageAddr); 
        uint userId = userStorage.getUserId(_addr);
        require(userId != 0);
        _;
    }

    function bindUserStorage(address _addr) public onlyOwner {
        userStorageAddr = _addr;
    }

    function bindTweetStorage(address _addr) public onlyOwner {
        tweetStorageAddr = _addr;
    }

    function bindUserData(address _addr) public onlyOwner {
        userDataAddr = _addr;
    }

    function bindTweetData(address _addr) public onlyOwner {
        tweetDataAddr = _addr;
    }

    function createUser(bytes32 _username, string memory _publicName) public storageBinded returns(uint _id) {
        UserStorage userStorage = UserStorage(userStorageAddr); 
        return userStorage.createUserProfile(msg.sender, _username, _publicName, "");
    }

    function getUserId(address _addr) public storageBinded view returns(uint _id) {
        UserStorage userStorage = UserStorage(userStorageAddr); 
        return userStorage.getUserId(_addr);
    }

    function getUserAddress(bytes32 _username) public storageBinded view returns(address _addr) {
        UserStorage userStorage = UserStorage(userStorageAddr);
        return userStorage.getUserAddress(_username);
    }

    function getUserTweetNum(uint _userId) public storageBinded view returns(uint _tweetNum) {
        UserStorage userStorage = UserStorage(userStorageAddr); 
        _tweetNum = userStorage.getUserTweetNum(_userId);
    }

    function getUserProfile(uint _userId) public storageBinded view returns(UserProfile memory) {
        UserStorage userStorage = UserStorage(userStorageAddr);
        return userStorage.getUserProfile(_userId);
    }

    function addSubscription(uint _id, uint _subId) public storageBinded {
        UserStorage userStorage = UserStorage(userStorageAddr);
        userStorage.addUserSubscription(_id, _subId);
    }

    function removeSubscription(uint _id, uint _subId) public storageBinded {
        UserStorage userStorage = UserStorage(userStorageAddr);
        userStorage.removeUserSubscription(_id, _subId);
    }

    function getSubscription(uint _id, uint _index) public storageBinded view returns(uint _subId) {
        UserStorage userStorage = UserStorage(userStorageAddr);
        _subId = userStorage.getUserSubscription(_id, _index);
    }

    function getSubscriptionCount(uint _id) public storageBinded view returns(uint _count) {
        UserStorage userStorage = UserStorage(userStorageAddr);
        _count = userStorage.getUserSubscriptionCount(_id);
    }

    function getSubscriptionBatch(uint _id, uint _offset) public storageBinded view returns(uint[] memory) {
        UserStorage userStorage = UserStorage(userStorageAddr);
        return userStorage.getUserSubscriptionBatch(_id, _offset);
    }

    function changePublicName(string memory _newName) public storageBinded validUser(msg.sender) {
        UserStorage userStorage = UserStorage(userStorageAddr);
        uint userId = userStorage.getUserId(msg.sender);
        userStorage.updatePublicName(userId, _newName);
    }

    function changeProfilePicture(string memory _newPicture) public storageBinded validUser(msg.sender) {
        UserStorage userStorage = UserStorage(userStorageAddr);
        uint userId = userStorage.getUserId(msg.sender);
        userStorage.setUserProfilePicture(userId, _newPicture);
    }

    function updateBio(string memory _newBio) public storageBinded validUser(msg.sender) {
        UserStorage userStorage = UserStorage(userStorageAddr);
        uint userId = userStorage.getUserId(msg.sender);
        userStorage.updateBio(userId, _newBio);
    }

    function tweet(string memory _text) public storageBinded validUser(msg.sender) returns(uint _id) {
        UserStorage userStorage = UserStorage(userStorageAddr); 
        uint userId = userStorage.getUserId(msg.sender);
        TweetStorage tweetStorage = TweetStorage(tweetStorageAddr);
        // Let storage handle the rest
        _id = tweetStorage.tweet(userId, userStorage.getUserTweetNum(userId), _text);
        userStorage.incrementUserTweetNum(userId);
    }

    function reply(uint _tweetId, string memory _text) public storageBinded validUser(msg.sender) returns(uint _id) {
        // Don't allow empty replies
        require((bytes(_text).length > 0));
        UserStorage userStorage = UserStorage(userStorageAddr); 
        uint userId = userStorage.getUserId(msg.sender);
        TweetStorage tweetStorage = TweetStorage(tweetStorageAddr);
        _id = tweetStorage.reply(userId, userStorage.getUserTweetNum(userId), _tweetId, _text);
        userStorage.incrementUserTweetNum(userId);
    }

    // We treat ReTweets as empty replies without adding this tweet as a reply and incrementing tweet retweet count
    function retweet(uint _originalTweetId) public storageBinded validUser(msg.sender) returns(uint _id) {
        UserStorage userStorage = UserStorage(userStorageAddr); 
        uint userId = userStorage.getUserId(msg.sender);
        
        TweetStorage tweetStorage = TweetStorage(tweetStorageAddr);
        // Can't retweet own tweet
        TweetContent memory originalTweet = tweetStorage.getTweet(_originalTweetId);
        require(originalTweet.authorId != userId);
        _id = tweetStorage.retweet(userId, userStorage.getUserTweetNum(userId), _originalTweetId);
        userStorage.incrementUserTweetNum(userId);
    }

    function getTweet(uint _tweetId) public storageBinded view returns(TweetContent memory) {
        TweetStorage tweetStorage = TweetStorage(tweetStorageAddr);
        return tweetStorage.getTweet(_tweetId);
    }

    function getTweet(uint _userId, uint _tweetNum) public storageBinded view returns(TweetContent memory) {
        TweetStorage tweetStorage = TweetStorage(tweetStorageAddr);
        uint tweetId = uint(keccak256(abi.encodePacked(_userId,  _tweetNum)));
        return tweetStorage.getTweet(tweetId);
    }

    function getTweetBatch(uint _userId, uint _startNum, uint _count) public storageBinded view returns(TweetContent[] memory) {
        TweetStorage tweetStorage = TweetStorage(tweetStorageAddr);
        return tweetStorage.getTweetBatch(_startNum, _userId, _count);
    } 

}