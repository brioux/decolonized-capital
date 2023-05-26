<template>
  <main role="main" class="container">
    <div style="padding-top: 7rem" class="d-none d-lg-block"></div>
    <div class="row justify-content-md-center">
      <div class="col-lg-4">
        <div class="text-center vstack gap-3">
          <h1>Issue Public Vote</h1>
          
          <label for="reader">
            Generate hash of voter's artwork
            <p>Each vote is registered as an NFT that can include a hash to any digital media file</p>
            <input id="reader" width="400px" type="file">
          </label>
          
          <input id="uniqueHash" type="text" placeholder="unique hash" v-model="uniqueHash" />
          <input id="voterAddress" type="text" placeholder="voter address" v-model="voterAddress" />
          <button class="btn btn-info" @click="sendToBlockchain">
            Register vote
          </button>
          <a href="#/" class="btn btn-primary">Back</a>
        </div>
      </div>
    </div>
  </main>
</template>

<script lang="ts">
import { Component, Vue } from "vue-facing-decorator";
import * as ethers from "ethers";

import keccak256 from 'keccak256';

@Component
export default class Issue extends Vue {
  public uniqueHash = "";
  public voterAddress = "";
  public provider = new ethers.providers.Web3Provider(
      (window as any).ethereum);

  mounted() {document.getElementById('reader').addEventListener('input', async function (e){     

      const files = e.target.files || e.dataTransfer.files;
      const file = files[0];
      const reader = new FileReader("reader");
      reader.readAsDataURL(file);

      reader.onloadend = function (event) {
        //this.image = reader.result.split(',')[1];
        document.getElementById('uniqueHash').value = keccak256(Buffer.from(event.target.result)).toString('hex')
      };

    })
  }

  async getAddress() { 
    await this.provider.send("eth_requestAccounts", []);
    const signer = this.provider?.getSigner();
    if(signer){
      this.voterAddress = await signer.getAddress()
    }
  }
  beforeMount() {
     //this.getAddress()
  }

  async sendToBlockchain() {
    const abi = [
      "function issueVote(address _voter, bytes32 _hash)"
    ];
    const provider = new ethers.providers.Web3Provider((window as any).ethereum);
    await provider.send("eth_requestAccounts", []);
    const signer = provider.getSigner();
    const contracts = await (await fetch("contracts.json")).json();
    const contract = new ethers.Contract(contracts.decapvote, abi, signer);
    this.uniqueHash = document.getElementById('uniqueHash').value

    if (!this.voterAddress) {
      await this.getAddress()
      if (!this.voterAddress) {
        alert("Voter address is required");
        return;
      }
    }
    if (!this.uniqueHash) {
      alert("Unique hash is required");
      return;
    }
    this.uniqueHashBuffer = keccak256(Buffer.from(this.uniqueHash));
    
    const contractView = new ethers.Contract(contracts.decapvote, ['function getTokenId(bytes32 _hash) public view returns (uint256)'], provider)
    this.tokenId = await contractView.getTokenId(this.uniqueHashBuffer);

    if (!this.tokenId === 0){
      alert(`Hash is already registered to a voter on tokenId ${this.tokenId}`);
      return;
    }
    try {
      //console.log(this.voterAddress)
      //console.log(this.uniqueHash)
      //console.log(keccak256(Buffer.from(this.uniqueHash)))
      await contract.issueVote(this.voterAddress,this.uniqueHashBuffer);
    } catch (e) {
      console.log(e)
      alert(e.reason);
    }
  }
}
</script>