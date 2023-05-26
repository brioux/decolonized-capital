<template>
  <main role="main" class="container">
    <div style="padding-top: 7rem" class="d-none d-lg-block"></div>
    <div class="row justify-content-md-center">
      <div class="col-lg-4">
        <div class="text-center vstack gap-3">
          <h1>Decolonized Capital </h1>
          <h2>Public Voter Registry</h2>
          <div>Number of registered votes: <span v-html="tokenBalance"/> </div>
          <a href="#/issue" class="btn btn-primary">Issue Vote</a>
        </div>
      </div>
    </div>
  </main>
</template>

<script lang="ts">
import { Component, Vue } from "vue-facing-decorator";
import * as ethers from "ethers";
@Component
export default class Home extends Vue {
  public tokenBalance = "";
    async getCount() {
      const contracts = await (await fetch("contracts.json")).json();
      
      const abi = [
        "function getNumOfUniqueTokens()",
      ];
      
      let provider = new ethers.providers.Web3Provider(
        (window as any).ethereum
      );

      const contract = new ethers.Contract(contracts.decapvote, [
        'function getNumOfUniqueTokens() public view returns (uint256)'
      ], provider)

      this.tokenBalance = await contract.getNumOfUniqueTokens();
    }
    beforeMount() {
       this.getCount()
    }
}

</script>