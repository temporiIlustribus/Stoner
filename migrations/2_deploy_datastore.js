const UserData = artifacts.require('UserData');
const TweetData = artifacts.require('TweetData');
const UserStorage = artifacts.require('UserStorage');
const TweetStorage = artifacts.require('TweetStorage');

module.exports = (deployer) => {
  deployer.deploy(UserData);
  deployer.deploy(TweetData);
}


