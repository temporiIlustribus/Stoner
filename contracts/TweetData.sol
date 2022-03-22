// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
pragma abicoder v2;

import './Storage.sol';

/*
 * Basic idea:  
 *     - Deploy main contract and TweetData which holds mappings to all tweets
 *     - Deploy TweetStorage which manages storage.
 *     - Bind TweetStorage
 *
 *     If the validation or data access needs to be changed - deploy the updated UserStorage contract and rebind.
 */

// Basic representation of all contents of a single tweet
struct TweetContent {
    uint id;
    uint authorId;
    uint timestamp;
    uint originalTweet; // Used for replies and retweets
    string content;

    uint retweets;
    uint[] replies;     // Stores all reply ids
}

// Stores TweetContents for all users; does not do any complicated validation.
// Use TweetStorage to manage data access
contract TweetData is BaseData {
    mapping (uint => TweetContent) public contentMapper;     // Map tweet id to tweet 

    function getTweet(uint _tweetId) public onlyManager view returns(TweetContent memory) {
        return contentMapper[_tweetId];
    }

    function addTweet(TweetContent memory _tweet) public onlyManager {
        contentMapper[_tweet.id] = _tweet;
    }

    function updateRetweets(uint _tweetId, uint _newRetweetCount) public onlyManager {
        TweetContent storage tweet = contentMapper[_tweetId];
        tweet.retweets = _newRetweetCount;
    }

    function addReply(uint _originalTweetId, uint _tweetId) public onlyManager returns(uint _len) {
        TweetContent storage tweet = contentMapper[_originalTweetId];
        tweet.replies.push(_tweetId);
        _len = tweet.replies.length;
    }

}