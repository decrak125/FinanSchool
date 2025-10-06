<script setup>
defineProps({
  type: String,
  iconName : String,
  redirection : String,
});
</script>
<template>
    <button v-bind:class="`button-${type}`"><i :class="`bi bi-${iconName}`"></i></button>
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

  .button-edit {
    cursor: pointer;
      @include bouton(transparent, $jaune, $radius-pm, $stara-medium);
      transition: all 0.5s ease-in-out;
  }
  .button-edit:hover {
    @include bouton($jaune, $light, $radius-pm, $stara-medium);
  }

  .button-cancel {
    cursor: pointer;
      @include bouton(transparent, $rouge, $radius-pm, $stara-medium);
      transition: all 0.5s ease-in-out;
  }
  .button-cancel:hover {
    @include bouton($rouge, $light, $radius-pm, $stara-medium);
  }
  </style>
  