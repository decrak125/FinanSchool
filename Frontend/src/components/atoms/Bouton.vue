<script setup>
defineProps({
  type: String,
  texte : String,
  redirection : String,
});
</script>
<template>
    <button v-bind:class="`button-${type}`">{{ texte }}</button>
</template>
  <style lang="scss" scoped>

  .button-primary {
    cursor: pointer;
      @include bouton($primary, $light, $radius-pm, $stara);
      transition: all 0.5s ease-in-out;
  }
  .button-primary:hover {
    @include bouton($secondary, $light, $radius-pm, $stara);
  }

  .button-input {
    cursor: pointer;
      @include bouton($primary, $light, $radius-pm, $stara, 270px);
      transition: all 0.5s ease-in-out;
  }
  .button-input:hover {
    @include bouton($secondary, $light, $radius-pm, $stara, 270px);
  }
  </style>
  