<script setup>
import { RouterLink, RouterView } from "vue-router";
</script>

<template>
      <RouterView />
</template>

<style scoped>
      @font-face {
      font-family: "Stara";
      src: url("../public/fonts/Stara-Medium.woff2") format("woff2"),
            url("../public/fonts/Stara-Medium.woff") format("woff");
      font-weight: normal;
      font-style: normal;
      font-display: swap;
      }

      body {
      font-family: "Stara", sans-serif;
      }
</style>
