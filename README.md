## Stoner
---

Distributed, reliable, solid.

Stoner is a Twitter clone built on Ethereum with Solidity, designed to set tweets in stone.

### Architecture
---
Stoner is built up from multiple contracts, interfaces of which allow for easy upgrades, without losing user data and tweets.
The main contract provides user-facing interface and is repsonsible for some user access validation, which requires access both to user datastore and tweet datastore. 
Specialized input validation logic is confined to two "manager" contracts - `UserStorage` and  `TweetStorage`. These contracts interact both with the main user-facing contract, and `UserData` and `TweetData` datastore contracts. 
The datastore contracts represent don't contain any sophisticated logic but provide a sufficiently flexible interface for the logic layer.
This project structure is chosen specifically to decouple data and logic, following the Data-orientated programming paradigm. By doing so, we allow for both the internal logic and outward-facing interface to be updated post-deployment easily. 

### Running Stoner
---

This project can be deployed easily with [Remix](http://remix.ethereum.org/) by clonning the `contract` and `migration` directories.

To run Stoner localy:
Make sure to install [Node](https://nodejs.org/en/), solidity compiler, [Truffle](https://www.trufflesuite.com/) and [Ganache CLI](https://github.com/trufflesuite/ganache-cli) and [Web3](https://github.com/ChainSafe/web3.js).
You can do all of this with
```
sudo apt install nodejs
```
```
npm install solc
npm install truffle -g
npm install -g ganache-cli
npm install web3
```
Clone this repository. (You might need to re-initialize for npm to properly operate, depending on your version.)
Start the ganache server. This project is configured so it should be sufficient to run:
```
ganache-cli
```
(In case this or any of the following steps don't work it is suggested to check Ganache CLI documentation for potential fixes.)

Deploy the project with
```
truffle migrate
```
This will run all necessary orchestration to setup a working instance on the local Ganache server.

To run all tests use
```
truffle test
```
You can also specify which tests to run. For example, to run just the intgreation tests, focused on `Tweets`, use
```
truffle test test/integration/TestTweets.js
```
---
What about UI, and any beautiful frontend integration? 

This project has a simple frontend implementation, but a nicer looking frontend would be nice. Web3 simplifies interaction with contracts with abstractions, with generated `.js` files coresponding to all project contracts. To interract with them you only need to make sure to import them into your web project directory. So feel free to try and help if you want to!

