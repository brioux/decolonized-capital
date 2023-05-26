<template>
  <component :is="getMainComponent()"></component>
</template>

<script lang="ts">
import { Component, Vue } from "vue-facing-decorator";

import Home from "./Home.vue";
import Register from "./Register.vue";

@Component
export default class App extends Vue {
  public locationHash = "";

  created() {
    this.locationHash = window.location.hash;
  }

  mounted() {
    window.addEventListener("hashchange", () => {
      this.locationHash = window.location.hash;
    });
  }

  getMainComponent() {
    const currentPath = this.locationHash.slice(1) || "/";
    if (currentPath == "/") return Home;
    if (currentPath == "/register") return Register;
  }
}
</script>