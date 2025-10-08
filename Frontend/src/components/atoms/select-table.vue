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
      <select :value="modelValue" @change="$emit('update:modelValue', $event.target.value)" class="select">
        <slot/>
      </select>
    </div>  
  </template>
  
  <style lang="scss" scoped>
.select{
    font-family: $stara-medium;
    color: $dark;
    border: none !important;
    outline: none !important;
    background-color: transparent;
}
option{
    font-family: $stara-medium;
    color: $dark;
    
}
</style>
  