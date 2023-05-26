import { HardhatUserConfig, task, types} from "hardhat/config";
import { Contract } from 'ethers';

import "hardhat-deploy";
import "@nomicfoundation/hardhat-toolbox";

/**
 * @type import('hardhat/config').HardhatUserConfig
 */

const config: HardhatUserConfig = {
  solidity: "0.8.17",
};

// Uncomment and populate .ethereum-config.js if deploying contract to Goerli, Kovan, xDai, or verifying with Etherscan
// const ethereumConfig = require("./.ethereum-config");

module.exports = {

  namedAccounts: {
    // these are based on the accounts you see when run $ npx hardhat node --show-acounts
    deployer: { default: 0 },
    verifier: { default: 1 },
    voter: { default: 2 }
  },

  solidity: {

    compilers: [
      {
        version: "0.7.6",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          }
        }
      },
      {
        version: "0.8.3",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          }
        }
      },
      {
        version: "0.8.9",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          }
        }
      },
      {
        version: "0.8.17",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          }
        }
      }
    ]
  },
  gasReporter: {
    currency: 'USD',
  },
  networks: {
    hardhat: {
      chainId: 1337
    },
    ovm_localhost: {
      url: `http://localhost:9545`
    },
    // Uncomment the following lines if deploying contract to Hedera testnet
    // Deploy with npx hardhat deploy --network hedera-testnet scripts/___.js
    // "hedera-testnet": {
    //   //HashIO testnet endpoint from the TESTNET_ENDPOINT variable in the project .env the file
    //   url: ethereumConfig.HEDERA_TESTNET_ENDPOINT,
    //   chainId: 296,
    //   //the Hedera testnet account ECDSA private
    //   //the public address for the account is derived from the private key
    //   accounts: [
    //     `${ethereumConfig.HEDERA_TESTNET_OPERATOR_PRIVATE_KEY}`
    //   ],
    //   gasPrice: 225000000000000,
    // },
    // Deploy with npx hardhat --network hedera-testnet deploy --reset

    // Uncomment the following lines if deploying contract to Avalanche testnet
    // "avalanche-testnet": {
    //   url: "https://api.avax-test.network/ext/bc/C/rpc",
    //   chainId: 43113,
    //   accounts: [`0x${ethereumConfig.AVALANCHE_PRIVATE_KEY}`]
    // },
    // Deploy with npx hardhat --network avalanche-testnet deploy --reset

    // Uncomment the following lines if deploying contract to Avalanche
    // avalanche: {
    //   url: "https://api.avax.network/ext/bc/C/rpc",
    //   chainId: 43114,
    //   accounts: [`0x${ethereumConfig.AVALANCHE_PRIVATE_KEY}`],
    //   gasPrice: 225000000000,
    // },
    // Deploy with npx hardhat --network avalanche deploy --reset

    // Uncomment the following lines if deploying contract to Binance BSC testnet
    //bsctestnet: {
    //  url: "https://data-seed-prebsc-1-s1.binance.org:8545",
    //  chainId: 97,
    //  gasPrice: 20000000000,
    //  accounts: [`0x${ethereumConfig.BSC_PRIVATE_KEY}`]
    //}
    // Deploy with npx hardhat --network bsctestnet deploy --reset

    // Uncomment the following lines if deploying contract to Optimism on Kovan
    // Deploy with npx hardhat run --network optimism_kovan scripts/___.js
    // optimism_kovan: {
    //   url: `https://kovan.optimism.io/`,
    //   accounts: [`0x${ethereumConfig.CONTRACT_OWNER_PRIVATE_KEY}`]
    // },

    // Uncomment the following lines if deploying contract to Arbitrum on Kovan
    // Deploy with npx hardhat run --network arbitrum_kovan scripts/___.js
    // arbitrum_kovan: {
    //   url: `https://kovan4.arbitrum.io/rpc`,
    //   accounts: [`0x${ethereumConfig.CONTRACT_OWNER_PRIVATE_KEY}`]
    // },

    // Uncomment the following lines if deploying contract to Goerli or running Etherscan verification
    // Deploy with npx hardhat run --network goerli scripts/___.js
    // goerli: {
    //   url: `https://goerli.infura.io/v3/${ethereumConfig.INFURA_PROJECT_ID}`,
    //   accounts: [`0x${ethereumConfig.CONTRACT_OWNER_PRIVATE_KEY}`,`0x${ethereumConfig.VERIFIER_PRIVATE_KEY}`]
    // },

    // Uncomment the following lines if deploying contract to Mumbai or running Etherscan verification
    // Deploy with npx hardhat run --network mumbai scripts/___.js
    //mumbai: {
    //  url: `https://mumbai.infura.io/v3/${ethereumConfig.INFURA_PROJECT_ID}`,
    //  accounts: [`0x${ethereumConfig.CONTRACT_OWNER_PRIVATE_KEY}`,
    //    `0x${ethereumConfig.OPERATOR_REGISTRY_PRIVATE_KEY}`,`0x${ethereumConfig.BUILDING_OWNER_PRIVATE_KEY}`]
    //},

    // Uncomment the following lines if deploying contract to xDai
    // Deploy with npx hardhat run --network xdai scripts/___.js
    // xdai: {
    //   url: "https://xdai.poanetwork.dev",
    //   chainId: 100,
    //   accounts: [`0x${ethereumConfig.CONTRACT_OWNER_PRIVATE_KEY}`]
    // }

    // Uncomment the following lines if deploying contract to Kovan
    // Deploy with npx hardhat run --network kovan scripts/___.js
    // kovan: {
    //   url: `https://kovan.infura.io/v3/${ethereumConfig.INFURA_PROJECT_ID}`,
    //   accounts: [`0x${ethereumConfig.CONTRACT_OWNER_PRIVATE_KEY}`]
    // }

    // Uncomment the following lines if deploying contract to Ropsten - See https://infura.io/docs/ethereum#section/Choose-a-Network
    // Deploy with npx hardhat run --network ropsten scripts/___.js
    // ropsten: {
    //   url: `https://ropsten.infura.io/v3/${ethereumConfig.INFURA_PROJECT_ID}`,
    //   accounts: [`0x${ethereumConfig.CONTRACT_OWNER_PRIVATE_KEY}`]
    // },
    // besu:{
    //   url: `http://localhost:8545`,
    //   chainId: 2018,
    //   accounts: [`0x${ethereumConfig.CONTRACT_OWNER_PRIVATE_KEY}`]
    // }

  },
  // Uncomment if running contract verification
  // etherscan: {
  //   apiKey: `${ethereumConfig.ETHERSCAN_API_KEY}`
  // },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  ovm: {
    solcVersion: '0.8.9'
  }
};

