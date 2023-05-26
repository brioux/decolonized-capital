# Deployment with Hardhat and hardhat-deploy

This project uses [hardhat-deploy](https://hardhat.org/plugins/hardhat-deploy.html) for replicable deployments. It provides a few useful features, including:

- Automatic setup after deploying the contracts (including initializing the admin of the Timelock contract and granting cross-contract permissions)
- When `npx hardhat node` is run to start the Hardhat Network for testing contracts locally, the deployment process is automatically called
- The tests (run with `npx hardhat test`) run hardhat-deploy locally before they are called so that the deployment process doesn't have to replicated
- Deployment information is saved in the `deployments/` folder
- Contracts can be deployed individually using the `--tags` argument

## Under the hood

The deploy scripts are located in the `deploy/` folder.  All the contracts referenced in these files will be deployed.  If you do not want to deploy some of the contracts, move them out of the directory before running `npx hardhat deploy`

## Deploy Contracts

- start node with `npx hardhat node`
- deploy all contracts with `npm run deploy`

By default will deploy to local network.

Finally, `deployer` represents the deployer account defined in `hardhat.config.js` and `.ethereum-config.js`. 


## Deploying contracts to a public testnet

If you'd like to deploy the contract (e.g. the Goerli testnet) for yourself, you will need a network URL and account to deploy with.

To connect to a common Ethereum testnet like Goerli, set up a developer account on [Infura.io](https://infura.io/) and create a free project under the Ethereum tab. You will need the project ID.

Next, create an account on MetaMask and connect to Goerli under the networks tab. This account will be used to deploy the contract -- so it needs to be loaded with free testnet ETH from a [Goerli faucet](https://faucet.goerli.mudit.blog) by copy and pasting your public key and waiting for the ETH to arrive to your wallet. 

Now follow these steps to deploy the contract to the Goerli testnet and update references to the address:

1. Create `.ethereum-config.js` by copying the template with 

```bash
cp .ethereum-config.js.template .ethereum-config.js
```

2.  Edit `.ethereum-config.ts` and set the private key for your Ethereum deployment address and Infura key.

3. Edit the file `hardhat.config.js` and uncomment these lines (or uncomment the network you want to deploy to):

```javascript
     const ethereumConfig = require("./.ethereum-config");
     ...
     goerli: {
       url: `https://goerli.infura.io/v3/${goerliConfig.INFURA_PROJECT_ID}`,
       accounts: [`0x${goerliConfig.GOERLI_CONTRACT_OWNER_PRIVATE_KEY}`]
     },
```

4. Deploy by via the deploy script (or replacing goerli with the network you want to deploy to):

```bash
npx hardhat deploy --network goerli
```
