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
      @include bouton-icon($primary, $light, $radius-pm, $stara-medium);
      transition: all 0.5s ease-in-out;
  }
  .button-primary-disabled {
    cursor: pointer;
      @include bouton-icon(#838383, $light, $radius-pm, $stara-medium);
      transition: all 0.5s ease-in-out;
  }
  .button-primary:hover {
    @include bouton-icon($secondary, $light, $radius-pm, $stara-medium);
  }

  .button-edit {
    cursor: pointer;
      @include bouton-icon(transparent, $jaune, $radius-pm, $stara-medium);
      transition: all 0.5s ease-in-out;
  }
  .button-edit:hover {
    @include bouton-icon($jaune, $light, $radius-pm, $stara-medium);
  }

  .button-cancel {
    cursor: pointer;
      @include bouton-icon(transparent, $rouge, $radius-pm, $stara-medium);
      transition: all 0.5s ease-in-out;
  }
  .button-cancel:hover {
    @include bouton-icon($rouge, $light, $radius-pm, $stara-medium);
  }

  .button-cancel-stroke {
    cursor: pointer;
      @include bouton-icon(transparent, $rouge, $radius-pm, $stara-medium);
      border: 1px solid $rouge;
      font-size: large;
      transition: all 0.5s ease-in-out;
  }
  .button-cancel-stroke:hover {
    @include bouton-icon($rouge, $light, $radius-pm, $stara-medium);
  }
  .button-disabled {
    cursor: pointer;
      @include bouton-icon(transparent, #838383, $radius-pm, $stara-medium);
      transition: all 0.5s ease-in-out;
  }
  </style>
  