// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
pragma abicoder v2;

import './TweetData.sol';
import './UserStorage.sol';

/*
 * Basic idea:  
 *     - Deploy main contract and TweetData which holds mappings to all tweets
 *     - Deploy TweetStorage which manages storage.
 *     - Bind TweetStorage
 *
 *     If the validation or data access needs to be changed - deploy the updated UserStorage contract and rebind.
 */

// Used for data access and validation; binds to TweetData. Can be modified and redeployed.
contract TweetStorage is OwnedObject  {
    address tweetDataAddr;
       
    modifier tweetDataBinded() {
        require(tweetDataAddr != address(0));
        _;
    }

    modifier validTweetId(uint _id) {
        require(_id != 0);
        TweetData tweets = TweetData(tweetDataAddr);
        require(tweets.getTweet(_id).id == _id);
        _;
    }

    modifier validTweetCount(uint count) {
        require(count <= 32);
        _;
    }

    modifier validTweetLength(string memory _text) {
        require(bytes(_text).length <= 170);
        _;
    }

    function bindData(address _addr) public onlyOwner {
        tweetDataAddr = _addr;
    }

    function getTweet(uint _tweetId) public validTweetId(_tweetId) view returns(TweetContent memory) {
        TweetData tweets = TweetData(tweetDataAddr);
        return tweets.getTweet(_tweetId);
    }


    // Get _count tweets starting from _startNum (newest to oldest)
    // Can't load more than 32 tweets at a time
    function getTweetBatch(uint _startNum, uint _userId, uint _count) public onlyOwner 
                                                                            validTweetId(uint(keccak256(abi.encodePacked(_userId,  _startNum)))) 
                                                                            validTweetCount(_count) view returns(TweetContent[] memory) {
        uint len = _startNum + 1 > _count ? _count : _startNum + 1;
        TweetContent[] memory batch = new TweetContent[](len);
        TweetData tweets = TweetData(tweetDataAddr);
        uint curId;
        for (uint i = 0; i < len; ++i) {
            curId = uint(keccak256(abi.encodePacked(_userId, _startNum - i)));
            batch[_startNum - i] = tweets.getTweet(curId);
        }
        return batch;
    }

    function addTweet(uint _userId, uint _tweetNum, TweetContent memory _tweet) private returns(uint _id) {
        // Mostly done to minimize code duplication
        _tweet.id = uint(keccak256(abi.encodePacked(_userId,  _tweetNum)));
        _tweet.authorId = _userId;
        _tweet.timestamp = block.timestamp;
        TweetData tweets = TweetData(tweetDataAddr);
        tweets.addTweet(_tweet);
        
        if (bytes(_tweet.content).length == 0 && _tweet.originalTweet != 0) {
            // retweet
            TweetContent memory originalTweet = tweets.getTweet(_tweet.originalTweet);
            tweets.updateRetweets(_tweet.originalTweet, originalTweet.retweets + 1);
        } else if (_tweet.originalTweet != 0) {
            //reply
            tweets.addReply(_tweet.originalTweet, _id);
        }
        _id = _tweet.id;
    }

    function tweet(uint _userId, uint _tweetNum, string memory _text) public onlyOwner validTweetLength(_text) returns(uint _id) {
        TweetContent memory newTweet;
        newTweet.content = _text;
        return addTweet(_userId, _tweetNum, newTweet);
    }

    // Note that a reply can be added only to an existing valid tweet
    function reply(uint _userId, uint _tweetNum, uint _originalTweet, string memory _text) 
            public onlyOwner validTweetLength(_text) validTweetId(_originalTweet) returns(uint _id) {
        TweetContent memory newTweet;
        newTweet.content = _text;
        newTweet.originalTweet =_originalTweet;
        return addTweet(_userId, _tweetNum, newTweet);
    }

     // Note that only a valid tweet can be retweeted
    function retweet(uint _userId, uint _tweetNum, uint _originalTweet)
            public onlyOwner validTweetId( _originalTweet) returns(uint _id) {
        TweetContent memory newTweet;
        // Treat retweets basically as empty replies
        newTweet.originalTweet =_originalTweet;
        return addTweet(_userId, _tweetNum, newTweet);
    }

    function getReply(uint _tweetId, uint _replyNum) public validTweetId(_tweetId) view returns(uint _id) {
        TweetData tweets = TweetData(tweetDataAddr);
        TweetContent memory _tweet = tweets.getTweet(_tweetId);
        require(_tweet.replies.length > _replyNum);
        return _tweet.replies[_replyNum]; 
    }
}