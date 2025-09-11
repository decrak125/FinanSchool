<script setup>
defineProps({
  label: String,
  options: Array,
  modelValue: String // ou Number si nécessaire
});
defineEmits(['update:modelValue']);

import Texte from './Texte.vue';
</script>

<template>
  <div class="select-container">
    <div class="label">
      <Texte :type="'light'" :texte="label"/>
    </div>
      <select :value="modelValue" @change="$emit('update:modelValue', $event.target.value)" class="select">
        <option value="" disabled>Choisir une option</option>
        <option v-for="option in options" :key="option.value" :value="option.value">
          {{ option.label }}
        </option>
      </select>
    </div>  
  </template>
  
  <style lang="scss" scoped>
.select{
    @include bouton-variant($primary, $light, $radius-pm, $stara);
    width: 245px;
    appearance: none;
    padding-right: 30px;
}
option{
    @include bouton-variant($primary, $dark, $radius-pm, $stara);
}
.label{
  padding-left:30px;
}

  </style>
  