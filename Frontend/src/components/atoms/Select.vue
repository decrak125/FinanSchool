<script setup>
defineProps({
  modelValue: String, // ou Number si nécessaire
  label: String,
});
defineEmits(['update:modelValue']);

import Texte from './Texte.vue';
</script>

<template>
  <div class="select-container">
    <div class="label" v-if="label">
      <Texte :type="'dark'" :texte="label"/>
    </div>
      <select :value="modelValue" @change="$emit('update:modelValue', $event.target.value)" class="select">
        <slot/>
      </select>
    </div>  
  </template>
  
  <style lang="scss" scoped>
.select{
    @include input($dark, $dark, $radius-pm, $stara-medium);
    @include glass();
    width: 250px;
    // appearance: none;
    padding-right: 15px;
}
option{
    @include input($dark, $dark, $radius-pm, $stara-medium);
}

  </style>
  