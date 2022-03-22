// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
pragma abicoder v2;

// From truffle docs 
import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";

import "../../contracts/TweetData.sol";

contract TestTweetData {
    TweetData tweetData;

    constructor() {
        tweetData = new TweetData();
        tweetData.setManagerAddr(address(this));
    }

    function testTweetCreation() public {
        uint userId = 195936478;
        uint tweetId = uint(keccak256(abi.encodePacked(userId,  uint(0))));
        TweetContent memory tweet;
        tweet.id = tweetId;
        tweet.content = "Test Tweet";
        tweetData.addTweet(tweet);
        TweetContent memory resTweet = tweetData.getTweet(tweetId);
        Assert.equal(resTweet.id, tweetId, "tweet id wans't set");
        Assert.equal(resTweet.content, "Test Tweet", "tweet content wasn't set");
    }
}