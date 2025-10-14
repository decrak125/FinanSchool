<template>
    <div class="animated-digit">
      <div class="digit-container">
        <div 
          class="digit-scroll" 
          :style="{ transform: `translateY(-${currentPosition}%)` }"
        >
          <span 
            v-for="n in digits" 
            :key="n"
            class="digit-number"
          >
            {{ n }}
          </span>
        </div>
      </div>
    </div>
  </template>
  
  <script setup>
  import { ref, onMounted, watch } from 'vue'
  
  const props = defineProps({
    number: {
      type: Number,
      required: true,
      validator: (value) => value >= 0 && value <= 9 && Number.isInteger(value)
    },
    duration: {
      type: Number,
      default: 2000
    },
    delay: {
      type: Number,
      default: 0
    }
  })
  
  const digits = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
  const currentPosition = ref(0)
  const isAnimating = ref(false)
  
  const startAnimation = () => {
    if (isAnimating.value) return
    
    isAnimating.value = true
    
    setTimeout(() => {
      const targetPosition = props.number * 10 // 10% par chiffre
      const startTime = Date.now()
      
      const animate = () => {
        const elapsed = Date.now() - startTime
        const progress = Math.min(elapsed / props.duration, 1)
        
        // Easing function pour un effet plus fluide
        const easeOutCubic = 1 - Math.pow(1 - progress, 3)
        
        currentPosition.value = easeOutCubic * targetPosition
        
        if (progress < 1) {
          requestAnimationFrame(animate)
        } else {
          isAnimating.value = false
          currentPosition.value = targetPosition
        }
      }
      
      requestAnimationFrame(animate)
    }, props.delay)
  }
  
  onMounted(() => {
    // Initial position
    currentPosition.value = props.number * 10
  })
  
  watch(() => props.number, () => {
    startAnimation()
  })
  </script>
    
  <style scoped>
  .animated-digit {
    display: inline-block;
  }
  
  .digit-container {
    position: relative;
    height: 1em;
    width: 1ch;
    overflow: hidden;
    display: inline-block;
  }
  
  .digit-scroll {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    transition: transform 0.8s cubic-bezier(0.22, 0.61, 0.36, 1);
  }
  
  .digit-number {
    display: block;
    height: 1em;
    line-height: 1.4;
    text-align: center;
    font-size: inherit;
    font-weight: 600;
  }
  </style>