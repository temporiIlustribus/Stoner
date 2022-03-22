const SolidTwitter = artifacts.require('SolidTwitter');
const UserData = artifacts.require('UserData');
const TweetData = artifacts.require('TweetData');
const UserStorage = artifacts.require('UserStorage');
const TweetStorage = artifacts.require('TweetStorage');

module.exports = (deployer) => {
  deployer.deploy(SolidTwitter)
  .then(() =>  { 
    return SolidTwitter.deployed() 
  })
  .then(solidTwitter => { 
    solidTwitter.bindUserData(UserData.address)
    solidTwitter.bindTweetData(TweetData.address)
    solidTwitter.bindUserStorage(UserStorage.address)
    solidTwitter.bindTweetStorage(TweetStorage.address)

    return Promise.all([
      UserStorage.deployed(),
      TweetStorage.deployed(),
    ])
  })
  .then(([userStore, tweetStore]) => {
    return Promise.all([
      userStore.makeOwner(SolidTwitter.address),
      tweetStore.makeOwner(SolidTwitter.address),
    ])
  })
}


