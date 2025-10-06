<template>
    <div class="multi-digit-counter">
      <div 
        v-for="(digit, index) in numberDigits" 
        :key="index"
        class="digit-container"
      >
        <AnimatedDigit
          :number="digit"
          :duration="duration"
          :delay="index * 100"
        />
      </div>
    </div>
  </template>
  
  <script setup>
  import { computed } from 'vue'
import AnimatedDigit from './AnimatedDigit.vue'  
  const props = defineProps({
    number: {
      type: Number,
      required: true,
      validator: (value) => value >= 0
    },
    duration: {
      type: Number,
      default: 2000
    }
  })
  
  const numberDigits = computed(() => {
    return props.number.toString().split('').map(Number)
  })
  </script>
  
  <style scoped>
  .multi-digit-counter {
    display: flex;
    align-items: center;
    /* gap: 2px; */
    padding-right: 5px;

  }
  
  .digit-container {
    display: flex;
  }
  </style>