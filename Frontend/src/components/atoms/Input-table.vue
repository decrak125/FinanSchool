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
    type: [String, Number],
    default: ''
  }
});

// Quand la valeur de l'input change, émettre l'événement 'update:modelValue'
const handleInput = (event) => {
  emit('update:modelValue', event.target.value);
};
</script>

<template>

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
</template>

<style lang="scss" scoped>

input{
  font-family: $stara-medium;
    color: $dark;
    border: none !important;
    outline: none !important;
    background-color: transparent;
    .input::placeholder{
        color: $dark;
    }

}

.container{
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  // gap: 10px;
}
</style>