# zktree-vote
Anonymous voting on Ethereum blockchain using zero knowledge proof

## Usage

- Spin up a local network and or deploy to the desired public network as described in [`deployment.md`](/hardhat/docs/deployment.md)
- Start app with `npm start`. 

The app uses MetaMask to connect the blockchain, so the MetaMask extension have to be installed, and connected to the Hardhat local node. The smart contract owner is the first Hardhat account, and the second account is set as a validator by the deployment script.

For further documentation ses [decap-vote.md](/hardhat/docs/zktree-vote.md)