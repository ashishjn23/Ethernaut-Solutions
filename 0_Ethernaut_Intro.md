# Hello World!

## Welcome to the Ethernaut CTF journey with me!

Link to Ethernaut series: https://ethernaut.openzepplin.com

Before we start lets get ourselves aquainted with few nitty gritties of the problems:
For the introduction to Ethereun basics follow this link: <Link to Eth notes>
**Setting Metamask:**
- Metamask is a wallet which holds the player's identity stored in ethereum networks. This wallet can contain your Ethers in main network and also in any test networks. It also helps the player interact with the network by creating and signing transactions on player's behalf. This eleminates the need of signing up on any Web3 website.
- Every major browser has a metamask extension available to download and sign in to. Player will need to create an account on metamask website and then log in with same credentials in the extension. The identity created by the wallet will be used to play the CTFs in Ethernaut.
**To play the CTFs:**
- The player will have to interact with the site using the Metamask wallet identity on one of the test Ethereum networks. The test network used in Ethernaut is Rinkby. Player can select the test network on the Metamask extension. 
- While interacting with the site (to solve the CTF problems), the player will need to pay Ether on the test network. The good part is that the Ether is not real Ether but the one on Rinkby network. Ether on the Rinkby network can be obtained for free. The place where we can obtain Ribkby or any other test network Ether is called a Faucet. As the name suggests, it is a faucet, where if you specify your Eth wallet id, your wallet will receive Ether. You can use this Ether to interact with Ethernaut and play the CTFs. The recommended faucet is https://faucets.chain.link/rinkeby.
- The player has to request for a new instance to solve the CTF. An instance will be a fresh deployment of the smart contract for that session with which the player can interact using his own wallet.
- The most important tool to solve this CTF series is the browser console. It can be opened by doing a right click anywhere on the Ethernaut webpage and then clicking on insect. There the player can find multiple tabs and the second tab should be console. The player can interact with the instance of smart code using the console by writing javascript code. Some examples will be discussed in the later sections.
- Player will need some kind of IDE with capabilities of compiling the smart contract. It should also have the ability to deploy to a test network, in our case Rinkby. After conpiling the smart contract, we can immediately deploy the code and test all tthe functions. The IDE recommended in this series is Remix: https://remix.ethereum.org

**Few important console command to play the game: **
- "player" command will give us the player's ethereum address which will correspond to the Metamask wallet address.
- "getBalance" command will get us the current balance of player which will again correspond to Metamask wallet balance.
- "help" this command will provide all the important commands available for the player like the ones mentioned till now.
- "ethernaut" this is the game's main smart contract object. It is a TruffleContract object that wraps the ethernaut.sol contract that has been deployed on the blockchain.
- The ABI (Application Binary Interface) of a smart contract gives a contract the ability to communicate and interact with external applications and other smart contracts. The player can interact with the smart contract deployed on the Rinkby blockchain and try to solve the game by interacting with this ABI.
- Among other things, the contract's ABI exposes all of Ethernaut.sol's public methods, such as owner. Player can use the command ethernaut.owner() to get the owner of the current contract it is interacting with.
