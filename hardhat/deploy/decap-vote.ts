import * as fs from 'fs'
import { ethers } from "hardhat";

module.exports = async function main({deployments,getNamedAccounts}) {
  const {execute, deploy} = deployments;
  const {deployer} = await getNamedAccounts();

  console.log(`Deploying VotingToken with account: ${deployer}`);

  const deCapVote = await deploy('DeCapVote', {
    from: deployer,
    args: [
      deployer,
    ]
  });

  console.log("DeCapVote deployed to:", deCapVote.address);
  console.log(`Deploying Governor with account: ${deployer}`);

  let deCapGovernor = await deploy('DeCapGovernor', {
    from: deployer,
    args: [
      deCapVote.address,
    ]
  });

  console.log("DeCapGovernonr deployed to:", deCapGovernor.address);

  fs.writeFileSync("../static/contracts.json", JSON.stringify({
      decapvote: deCapVote.address,
      decapgov: deCapGovernor.address,
  }))
};

module.exports.tags = ['DeCap'];
module.exports.dependencies = ['DAO'];