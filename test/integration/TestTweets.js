const TweetData = artifacts.require('TweetData');
const TweetStorage = artifacts.require('TweetStorage');
const UserStorage = artifacts.require('UserStorage');
const SolidTwitter = artifacts.require('SolidTwitter');

// Fun trick from StackOverflow
assertVMException = err => {
    const hasVMException = err.toString().search("VM Exception");
    assert(hasVMException, "Should expect an exception");
}

contract("TweetStorage", async accounts => {
    it("tweet creation only accessible through main contract", async () => {
        const solidTwitter = await SolidTwitter.deployed();
        const username = web3.utils.fromUtf8("test");
        await solidTwitter.createUser(username, "Test User", {from: accounts[0]});
        const ownAddress = await solidTwitter.getUserAddress.call(username);
        const userId = await solidTwitter.getUserId.call(ownAddress);
        try {
            const tweetId = await tweetStorageInstance.tweet(userId, 0, "Hello World!", {from: ownAddress});
            assert.fail();
        } catch(err) {
            assertVMException(err);
        }
        await solidTwitter.tweet("Hello World!", {from: ownAddress});
        const newTweet = await solidTwitter.getTweet.call(userId, 0);
        assert.equal(newTweet.content, "Hello World!", "Tweet content wasn't set");
        assert.equal(newTweet.authorId, userId, "Tweet author wasn't set");
    });

    it("tweeting requires registration", async () => {
        const solidTwitter = await SolidTwitter.deployed();
        try {
            await solidTwitter.tweet("Hello World!");
            assert.fail();
        } catch(err) {
            assertVMException(err);
        }
    });

    it("tweet creation increments tweetNum", async () => {
        const solidTwitter = await SolidTwitter.deployed();
        const userId = await solidTwitter.getUserId.call(accounts[0]);
        const profile = await solidTwitter.getUserProfile.call(userId);
        const tweetNum = profile.tweetNum;

        await solidTwitter.tweet("Hello World 2: Electric Boogaloo", {from: accounts[0]});
        const updatedProfile = await solidTwitter.getUserProfile.call(userId);
        const newTweetNum = updatedProfile.tweetNum;
        assert.equal(Number(newTweetNum), 1 + Number(tweetNum), "Tweet number was not updated");
    });

    it("can retweet", async () => {
        const solidTwitter = await SolidTwitter.deployed();
        const username = web3.utils.fromUtf8("foobar");
        await solidTwitter.createUser(username, "Foo Bar", {from: accounts[1]});
        const userId0 = await solidTwitter.getUserId.call(accounts[0]);
        const userId1 = await solidTwitter.getUserId.call(accounts[1]);

        await solidTwitter.tweet("Retweet test test tweet", {from: accounts[1]});
        const testTweet = await solidTwitter.getTweet.call(userId1, 0);
        const tweetId = testTweet.id;
        
        await solidTwitter.retweet(tweetId, {from: accounts[0]});
        const profile = await solidTwitter.getUserProfile.call(userId0);
        const tweetNum = profile.tweetNum;
        const retweet = await solidTwitter.getTweet.call(userId0, Number(tweetNum) - 1);
        assert(retweet.originalTweet, tweetId, "Retweet original tweet id is not set. Didn't retweet.");
        const originalTweet = await solidTwitter.getTweet.call(userId1, 0, {from: accounts[1]});
        assert(originalTweet.content, testTweet.content, "Original tweet content changed.");
        assert(originalTweet.retweets, 1, "Original tweet retweet count wasn't incremented.");
    });
    
    it("retweeting requires registration", async () => {
        const solidTwitter = await SolidTwitter.deployed();
        const userId1 = await solidTwitter.getUserId.call(accounts[1]);
        const testTweet = await solidTwitter.getTweet.call(userId1, 0);
        const tweetId = testTweet.id;
        
        try {
            await solidTwitter.retweet(tweetId);
            assert.fail();
        } catch(err) {
            assertVMException(err);
        }
    });

    it("can't retweet own tweet", async () => {
        const solidTwitter = await SolidTwitter.deployed();
        const userId = await solidTwitter.getUserId.call(accounts[1]);
        const profile = await solidTwitter.getUserProfile.call(userId);
        const tweetNum = profile.tweetNum;
        const latestTweet = await solidTwitter.getTweet.call(userId, Number(tweetNum) - 1);
        try {
            await solidTwitter.retweet(latestTweet.id);
            assert.fail();
        } catch(err) {
            assertVMException(err);
        }
    });

    it("can reply", async () => {
        const solidTwitter = await SolidTwitter.deployed();
        const userId0 = await solidTwitter.getUserId.call(accounts[0]);
        const userId1 = await solidTwitter.getUserId.call(accounts[1]);

        await solidTwitter.tweet("Reply test test tweet", {from: accounts[1]});
        const user1Profile =  await solidTwitter.getUserProfile.call(userId1);
        const user1TN = user1Profile.tweetNum;
        const testTweet = await solidTwitter.getTweet.call(userId1, Number(user1TN) - 1);
        const tweetId = testTweet.id;
        
        await solidTwitter.reply(tweetId, "test reply to the reply test test tweet", {from: accounts[0]});
        await solidTwitter.reply(tweetId, "test reply 2: electric boogaloo", {from: accounts[1]});
        const user0Profile = await solidTwitter.getUserProfile.call(userId0);
        const tweetNum = user0Profile.tweetNum;
        const reply0 = await solidTwitter.getTweet.call(userId0, Number(tweetNum) - 1);
        const reply1 = await solidTwitter.getTweet.call(userId1, user1TN);
        assert(reply0.originalTweet, tweetId, "Reply original tweet id is not set. Didn't reply.");
        const originalTweet = await solidTwitter.getTweet.call(userId1, Number(user1TN) - 1);
        assert(originalTweet.content, testTweet.content, "Original tweet content changed.");
        assert(originalTweet.retweets, 1, "Original tweet retweet count was incremented unexpectedly.");
        assert(originalTweet.replies[0], reply0.id, "First reply tweet wasn't added to original tweet's replies. Didn't reply.");
        assert(reply0.content, "test reply to the reply test test tweet", "First reply tweet's content was not set.");
        assert(originalTweet.replies[1], reply1.id, "Second reply tweet wasn't added to original tweet's replies. Didn't reply.");
        assert(reply1.content, "test reply 2: electric boogaloo", "Second reply tweet's content was not set.");
    });

    it("replying requires registration", async () => {
        const solidTwitter = await SolidTwitter.deployed();
        const userId1 = await solidTwitter.getUserId.call(accounts[1]);
        const testTweet = await solidTwitter.getTweet.call(userId1, 0);
        const tweetId = testTweet.id;
        
        try {
            await solidTwitter.reply(tweetId, "Trying to reply without registering!");
            assert.fail();
        } catch(err) {
            assertVMException(err);
        }
    });
})