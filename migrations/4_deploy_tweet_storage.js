const TweetData = artifacts.require('TweetData');
const TweetStorage = artifacts.require('TweetStorage');

module.exports = (deployer) => {

  deployer.deploy(TweetStorage)
  .then(() => { 
    return TweetStorage.deployed()
  })
  .then(tweetStore => { 
    tweetStore.bindData(TweetData.address)
    return TweetData.deployed()
  })
  .then(tweetData => {
      tweetData.setManagerAddr(TweetStorage.address)
  })
}


