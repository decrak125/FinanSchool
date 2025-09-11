<script setup>
defineProps({
  color: String,
  icon : String,
});
</script>
<template>
<div v-bind:class="`icon-${color}`">
    <i v-bind:class="`button-${icon}`"></i>
</div>
</template>
  <style lang="scss" scoped>

    .icon-primary {
        @include iconCircle($primary);
    }
    .icon-secondary {
        @include iconCircle($secondary);
    }
    .icon-light {
        @include iconCircle($light);
    }
    .icon-dark {
        @include iconCircle($dark);
    }
    .icon-rouge {
        @include iconCircle($rouge);
    }
    .icon-vert {
        @include iconCircle($vert);
    }
    .icon-jaune {
        @include iconCircle($jaune);
    }

    i {
        font-size: 34px;
        color: $light;
    }
  </style>
  