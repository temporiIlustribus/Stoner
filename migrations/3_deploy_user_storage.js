
const UserData = artifacts.require('UserData');
const UserStorage = artifacts.require('UserStorage');

module.exports = (deployer) => {

  deployer.deploy(UserStorage)
  .then(() => { 
    return UserStorage.deployed()
  })
  .then(userStore => { 
    userStore.bindData(UserData.address)
    return UserData.deployed()
  })
  .then(userData => {
      userData.setManagerAddr(UserStorage.address)
  })
}


