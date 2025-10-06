<script setup>
import { defineProps, defineEmits, ref } from 'vue';
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
    type: Boolean,
    default: false
  },
  read: {
    type: Boolean,
    default: false
  },
  modelValue: {
    type: String,
    default: ''
  }
});

// État pour gérer l'agrandissement
const isExpanded = ref(false);

const handleInput = (event) => {
  emit('update:modelValue', event.target.value);
};

// Fonction pour agrandir au focus
const handleFocus = () => {
  isExpanded.value = true;
};

// Fonction pour réduire quand on perd le focus
const handleBlur = () => {
  isExpanded.value = false;
};
</script>

<template>
  <div class="container">
    <div class="label">
      <Texte :type="'dark'" :texte="label"/>
    </div>
    <textarea
      :type="type"
      :placeholder="placeholder"
      :name="name"
      :value="modelValue"
      @input="handleInput"
      @focus="handleFocus"
      @blur="handleBlur"
      :required="required"
      :readonly="read"
      :class="{ 'expanded': isExpanded }"
    />
  </div>
</template>

<style lang="scss" scoped>
textarea{
  @include input($dark, $dark, $radius-pm, $stara-medium);
  width: 250px;
  height: 40px;
  transition: all 0.3s ease-in-out;
  resize: none;
  overflow: hidden;
  
  &::placeholder{
    color: $dark;
  }
  
  // Quand le textarea est agrandi
  &.expanded {
    height: 150px;
    overflow-y: auto;
  }
}

.container{
  display: flex;
  flex-direction: column;
  align-items: flex-start;
}
</style>