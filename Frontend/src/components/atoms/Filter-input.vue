<script setup>
import { defineProps, defineEmits, readonly } from 'vue';
import Texte from './Texte.vue';

const emit = defineEmits();
const props = defineProps({
  label: {
    type: String,
    default: ''
  },
  name: {
    type: String,
    default: ''
  },
  type: {
    type: String,
    default: 'text'
  },
  placeholder: {
    type: String,
    default: ''
  },
  required: {
    Boolean: String,
    default: false
  },
  read: {
    type: Boolean,
    default: false
  },
  modelValue: {  // Changement de 'value' à 'modelValue'
    type: String,
    default: ''
  }
});

// Quand la valeur de l'input change, émettre l'événement 'update:modelValue'
const handleInput = (event) => {
  emit('update:modelValue', event.target.value);
};
</script>

<template>
  <div class="container">
  <input
    v-bind:type="type"
    v-bind:placeholder="placeholder"
    v-bind:name="name"
    v-bind:v-model="name"
    :value="modelValue"
    @input="handleInput"
    v-bind:required="required"
    v-bind:readonly="read"
  />
  </div>
</template>

<style lang="scss" scoped>
i{
    color: #8d8d8d;
}
input{
    border: none;
    outline: none;
    background: transparent;
    font-family: $stara-medium;
    font-size: 14px;
    font-style: normal;
    font-weight: 400;
    line-height: normal;
    color: $dark;
    // width: 100%;
}
.container{
    display: flex;
    @include glass();
    // width: 320px;
    padding: 12px 18px;
    align-items: center;
    gap: 10px;
    border-radius: $radius-pm;
    
}
</style>