# zktree-vote
Anonymous voting on Ethereum blockchain using zero knowledge proof

## Usage

- Spin up a local network and or deploy to to your desired public network as described in [`hardhat/`](../hardhat/README.md)
- Start app with `npm start`. 

The app uses MetaMask to connect the blockchain, so the MetaMask extension have to be installed, and connected to the Hardhat local node. The smart contract owner is the first Hardhat account, and the second account is set as a validator by the deployment script.

For more details, please read the original article on [Medium](https://thebojda.medium.com/how-i-built-an-anonymous-voting-system-on-the-ethereum-blockchain-using-zero-knowledge-proof-d5ab286228fd)
