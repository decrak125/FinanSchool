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
      @include bouton($primary, $light, $radius-pm, $stara-medium);
      transition: all 0.5s ease-in-out;
  }
  .button-primary:hover {
    @include bouton($secondary, $light, $radius-pm, $stara-medium);
  }

  .button-input {
    cursor: pointer;
      @include bouton($primary, $light, $radius-pm, $stara-medium, 250px);
      transition: all 0.5s ease-in-out;
  }
  .button-input:hover {
    @include bouton($secondary, $light, $radius-pm, $stara-medium, 250px);
  }
  .button-loading {
    cursor: not-allowed;
      @include bouton($secondary, $light, $radius-pm, $stara-medium, 250px);
      transition: all 0.5s ease-in-out;
      
  }

  .button-cancel {
    cursor: pointer;
      @include input($primary, $primary, $radius-pm, $stara-medium);
      width: 250px;
      transition: all 0.5s ease-in-out;
  }
  .button-cancel:hover {
    width: 250px;
    @include input($rouge, $rouge, $radius-pm, $stara-medium);
  }
  </style>
  