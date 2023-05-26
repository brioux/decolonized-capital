# decolonized-capital

This project implements web3/blockchain/distributed ledger solutions that may be of use to the [Decolonized Capital (DC)](https://decolonizedcapital.com/) project.

- [Public Voting and DC NFT Art](app/decap-vote/README.md)
- [Anonymous Voting Contract](app/zktree-vote/README.md)

The DApps use the smart contracts in [hardhat/README.md](hardhat/README.md).

## Build & Run

- Install dependencies with `npm install`
- `cd hardhat` and start node with `npx hardhat node`
- In another terminal `cd hardhat` and `npx hardhat deploy`
- Start either app from root with
    - `npm run zktree-vote`
    - `npm run decap-vote`
