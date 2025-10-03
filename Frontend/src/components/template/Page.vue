<script setup>
defineProps({
  type: String ? 'dark' : 'light',
});
</script>
<template>
    <body v-bind:class="`${type}`">
        <slot/>
    </body>
</template>
<style scoped lang="scss">
.dark {
  @include position-container();
  @include position-contenus();
  width: 100vw;
  // min-height: 768px;
  // height: 100vh;
  background-color: $primary;
}
.light {
  @include position-container();
  @include position-contenus();
  width: 100vw;
  // min-height: 768px;
  // height: 100vh;
  background-color: $light;
}
</style>