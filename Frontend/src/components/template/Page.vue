<script setup>
</script>
<template>
    <body>
        <slot/>
    </body>
</template>
<style scoped lang="scss">
body {
  @include position-container();
  @include position-contenus();
  width: 100vw;
  // min-height: 768px;
  // height: 100vh;
  background-color: $primary;
}
</style>