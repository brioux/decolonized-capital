import { ethers } from "hardhat";
import { mimcSpongecontract } from 'circomlibjs'
import { readFile, writeFile } from 'node:fs/promises';

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

    //const verifier = await deploy('Verifier', {from: deployer, args:[]});

    const Verifier = await ethers.getContractFactory("Verifier");
    const verifier = await Verifier.deploy();
    console.log(`Verifier address: ${verifier.address}`)

    console.log(`Deploying zktreevote with account: ${deployer}`);
    /*const zktreevote = await deploy('ZKTreeVote', {
        from: deployer,
        args: [
            TREE_LEVELS, mimcsponge.address, verifier.address, 4
        ]
    });*/

    const ZKTreeVote = await ethers.getContractFactory("ZKTreeVote");
    const zktreevote = await ZKTreeVote.deploy(TREE_LEVELS, mimcsponge.address, verifier.address, 4);
    console.log(`ZKTreeVote address: ${zktreevote.address}`)

    // add the 2nd hxardhat account as a validator
    await execute(
      'ZKTreeVote',
      { from: deployer },
      'registerValidator',
      signers[1].address
    );
    //await zktreevote.registerValidator(signers[1].address)

    const contents = await readFile('../static/contracts.json',{ encoding: 'utf8' });
    var json = JSON.parse(contents)
    json = {...json,
        //...{mimc: "0x896FF204961431D1837C0DefaAbA62B00Fd48A10",verifier: "0x0E24d543FC4Af46340CfadCE205d48D4C989FA51",zktreevote: "0x9C4Db2Ea66e2EBb826CDF7542E152B9E3DB81591"}}
        ...{mimc: mimcsponge.address,verifier: verifier.address,zktreevote: zktreevote.address}
    }
    //console.log(json)
    await writeFile("../static/contracts.json", JSON.stringify(json)) 
}