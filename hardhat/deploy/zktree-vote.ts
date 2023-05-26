import * as fs from 'fs'
import { ethers } from "hardhat";
import { mimcSpongecontract } from 'circomlibjs'

const SEED = "mimcsponge";
const TREE_LEVELS = 20;

module.exports = async function main({deployments, getNamedAccounts}) {

    const {execute, deploy} = deployments;
    const {deployer} = await getNamedAccounts();

    const signers = await ethers.getSigners()
    const MiMCSponge = new ethers.ContractFactory(mimcSpongecontract.abi, mimcSpongecontract.createCode(SEED, 220), signers[0])
    const mimcsponge = await MiMCSponge.deploy()
    console.log(`MiMC sponge hasher address: ${mimcsponge.address}`)

    console.log(`Deploying Verifier with account: ${deployer}`);

    const verifier = await deploy('Verifier', {
      from: deployer
    });


    //const Verifier = await ethers.getContractFactory("Verifier");
    //const verifier = await Verifier.deploy();
    console.log(`Verifier address: ${verifier.address}`)

    console.log(`Deploying zktreevote with account: ${deployer}`);

    const zktreevote = await deploy('ZKTreeVote', {
        from: deployer,
        args: [
            TREE_LEVELS, mimcsponge.address, verifier.address, 4
        ]
    });

    //const ZKTreeVote = await ethers.getContractFactory("ZKTreeVote");
    //const zktreevote = await ZKTreeVote.deploy(TREE_LEVELS, mimcsponge.address, verifier.address, 4);
    console.log(`ZKTreeVote address: ${zktreevote.address}`)

    // add the 2nd hxardhat account as a validator
    await execute(
      'ZKTreeVote',
      { from: deployer },
      'registerValidator',
      signers[1].address
    );
    //await zktreevote.registerValidator(signers[1].address)


    fs.readFile('../static/contracts.json', function (err, data) {
        var json = JSON.parse(data)
        fs.writeFile("../static/contracts.json", JSON.stringify({...json,
            ...{mimc: mimcsponge.address,verifier: verifier.address,zktreevote: zktreevote.address}}
        ), function(err){
            if (err) throw err;
            console.log('The "data to append" was appended to file!');
        })
    })
}