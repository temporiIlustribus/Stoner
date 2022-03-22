const UserData = artifacts.require('UserData');
const UserStorage = artifacts.require('UserStorage');
const SolidTwitter = artifacts.require('SolidTwitter');

// Fun trick from StackOverflow
assertVMException = err => {
    const hasVMException = err.toString().search("VM Exception");
    assert(hasVMException, "Should expect an exception");
}

contract("UserStorage", async accounts => {
    it("user profile creation", async () => {
        const userStorageInstance = await UserStorage.deployed();
        const solidTwitter = await SolidTwitter.deployed();
        const username = web3.utils.fromUtf8("test");
        await solidTwitter.createUser(username, "Test User", {from: accounts[0]});
        const resAddr = await solidTwitter.getUserAddress.call(username);
        assert.equal(resAddr, accounts[0], "User address wasn't set");
        const userId = await solidTwitter.getUserId.call(resAddr);
        const profile = await solidTwitter.getUserProfile.call(userId);
        assert.equal(profile.id, userId, "User id wasn't set propperly");
        assert.equal(web3.utils.toUtf8(profile.username), web3.utils.toUtf8(username), "User username wasn't set");
        assert.equal(profile.publicName, "Test User", "User profile information wasn't set");
    });
    it("user profile unqiueness", async () => {
        const userStorageInstance = await UserStorage.deployed();
        const solidTwitter = await SolidTwitter.deployed();
        // Try creating a duplicate. Should not complete
        try {
            await solidTwitter.createUser("test", "Test User", {from: accounts[0]});
            assert.fail();
        } catch (err) {
            assertVMException(err);
        }
        // Note that this time its a request from e different address
        try {
            await solidTwitter.createUser("test", "Test User", {from: accounts[1]});
            assert.fail();
        } catch (err) {
            assertVMException(err);
        }
    });

    it("user profile public name update and access", async () => {
        const userStorageInstance = await UserStorage.deployed();
        const solidTwitter = await SolidTwitter.deployed();
        const userId = await solidTwitter.getUserId.call(accounts[0]);
        const profile = await solidTwitter.getUserProfile.call(userId);
        assert.equal(profile.publicName, "Test User", "User profile information wasn't set");
        try {
            await userStorageInstance.updatePublicName(userId, "New Test Name", {from: accounts[0]});
            assert.fail();
        } catch(err) {
            assertVMException(err);
        }

        try {
            await solidTwitter.changePublicName("New Test Name");
            assert.fail();
        } catch(err) {
            assertVMException(err);
        }

        await solidTwitter.changePublicName("New Test Name", {from: accounts[0]});
        const newProfile = await userStorageInstance.getUserProfile.call(userId);
        assert.equal(newProfile.publicName, "New Test Name", "User profile information wasn't updated");
    });

    it("user profile bio update and access", async () => {
        const userStorageInstance = await UserStorage.deployed();
        const solidTwitter = await SolidTwitter.deployed();
        const userId = await solidTwitter.getUserId.call(accounts[0]);
        try {
            await userStorageInstance.updateBio(userId, "New bio!", {from: accounts[0]});
            assert.fail();
        } catch(err) {
            assertVMException(err);
        }

        try {
            await solidTwitter.updateBio("New bio!");
            assert.fail();
        } catch(err) {
            assertVMException(err);
        }

        await solidTwitter.updateBio("New bio!", {from: accounts[0]});
        const newProfile = await userStorageInstance.getUserProfile.call(userId);
        assert.equal(newProfile.bio, "New bio!", "User profile information wasn't updated");
    });

    it("user profile picture update and access", async () => {
        const userStorageInstance = await UserStorage.deployed();
        const solidTwitter = await SolidTwitter.deployed();
        const userId = await solidTwitter.getUserId.call(accounts[0]);
        try {
            await userStorageInstance.setUserProfilePicture(userId, "Pretend this is a hash or something", {from: accounts[0]});
            assert.fail();
        } catch(err) {
            assertVMException(err);
        }

        try {
            await solidTwitter.changeProfilePicture("Pretend this is a hash or something");
            assert.fail();
        } catch(err) {
            assertVMException(err);
        }

        await solidTwitter.changeProfilePicture("Pretend this is a hash or something", {from: accounts[0]});
        const newProfile = await userStorageInstance.getUserProfile.call(userId);
        assert.equal(newProfile.profilePicture, "Pretend this is a hash or something", "User profile information wasn't updated");
    });

    it("data reads/writes interface access", async () => { 
        const userDataInstance = await UserData.deployed();
        const userStorageInstance = await UserStorage.deployed();
        // Try accessing data without using UserStorage interface
        try {
            const userId = await userDataInstance.getId(accounts[0]);
            assert.fail();
        } catch (err) {
            assertVMException(err);
        }
        const userId = await userStorageInstance.getUserId.call(accounts[0]);
        const profile = await userStorageInstance.getUserProfile.call(userId);
        profile.publicName = "Another Test Name";
        // Try updating user profile not through userStorage
        try {
            await userDataInstance.updateProfile(userId, profile);
            assert.fail();
        } catch (err) {
            assertVMException(err);
        }
        const newProfile = await userStorageInstance.getUserProfile.call(userId);
        assert.equal(newProfile.publicName, "New Test Name", "User profile information was updated. Expected no updates");
    });
})