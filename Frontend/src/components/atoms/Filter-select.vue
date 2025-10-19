<script setup>
defineProps({
  modelValue: String, // ou Number si nécessaire
  label: String
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
    cursor: pointer;
    border: none;
    outline: none;
    background: transparent;
    font-family: Stara;
    font-size: 14px;
    font-style: normal;
    font-weight: 400;
    line-height: normal;
    color: $dark;
}
.select-container{
    cursor: pointer;
    display: flex;
    padding: 12px 18px;
    align-items: center;
    gap: 10px;
    border-radius: var(--Border-radius, 32px);
    background: #EBEBEB;
}
option{
    @include input($dark, $dark, $radius-pm, $stara-medium);
}

  </style>
  