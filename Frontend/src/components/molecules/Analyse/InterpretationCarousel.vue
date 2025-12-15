<template>
  <div class="carousel-container">
    <!-- Indicateurs de progression -->
    
    <!-- Conteneur des cartes -->
    <div 
      class="cards-wrapper"
      ref="cardsWrapper"
      @touchstart="onTouchStart"
      @touchmove="onTouchMove"
      @touchend="onTouchEnd"
      @mousedown="onMouseDown"
      @mousemove="onMouseMove"
      @mouseup="onMouseEnd"
      @mouseleave="onMouseEnd"
    >
      <div 
        class="cards-track" 
        :style="trackStyle"
        ref="cardsTrack"
        :class="{ dragging: isDragging, swiping: isSwiping }"
      >
        <InterpretationCard
          v-for="(card, index) in cards"
          :valeur="card.valeur"
          :key="index"
          :texte="card.texte"
          :chiffre="card.chiffre"
          :icon="card.icon"
          :iconColor="card.iconColor"
          :format="card.format"
          :negative="card.negative"
          :loading="card.loading"
          :variation="card.variation"
          :colorVariation="card.colorVariation"
          :interpretation="card.interpretation"
          :reverse="card.reverse"
          class="carousel-card"
          :class="{ active: currentIndex === index }"
        />
      </div>
    </div>
    
    <!-- Boutons de navigation -->
    <button 
      v-if="cards.length > 1 && showNavigation"
      class="nav-button prev"
      @click="prevSlide"
      :disabled="currentIndex === 0"
    >
      <i class="bi bi-chevron-left"></i>
    </button>
    <button 
      v-if="cards.length > 1 && showNavigation"
      class="nav-button next"
      @click="nextSlide"
      :disabled="currentIndex === cards.length - 1"
    >
      <i class="bi bi-chevron-right"></i>
    </button>
        <div class="indicators" v-if="cards.length > 1">
      <span 
        v-for="(card, index) in cards" 
        :key="index"
        :class="['indicator', { active: currentIndex === index }]"
        @click="goToSlide(index)"
      ></span>
    </div>

  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import InterpretationCard from '@/components/atoms/Chart/InterpretationCard.vue'

// Props
const props = defineProps({
  cards: {
    type: Array,
    required: true,
    default: () => []
  },
  autoPlay: {
    type: Boolean,
    default: true
  },
  autoPlayInterval: {
    type: Number,
    default: 5000
  },
  showNavigation: {
    type: Boolean,
    default: true
  }
})

// Références
const cardsWrapper = ref(null)
const cardsTrack = ref(null)
const currentIndex = ref(0)
const autoPlayTimer = ref(null)
const isDragging = ref(false)
const isSwiping = ref(false)
const startPos = ref(0)
const currentTranslate = ref(0)
const prevTranslate = ref(0)
const animationId = ref(null)
const velocity = ref(0)
const lastPosition = ref(0)
const lastTime = ref(0)

// Style du track pour l'animation
const trackStyle = computed(() => {
  return {
    transform: `translateX(${currentTranslate.value}px)`,
    transition: isDragging.value ? 'none' : 'transform 0.4s cubic-bezier(0.25, 0.46, 0.45, 0.94)'
  }
})

// Navigation
const nextSlide = () => {
  if (currentIndex.value < props.cards.length - 1) {
    currentIndex.value++
    updateSlidePosition()
  }
}

const prevSlide = () => {
  if (currentIndex.value > 0) {
    currentIndex.value--
    updateSlidePosition()
  }
}

const goToSlide = (index) => {
  currentIndex.value = index
  updateSlidePosition()
}

// Mise à jour de la position du slide
const updateSlidePosition = () => {
  if (cardsWrapper.value && cardsTrack.value) {
    const wrapperWidth = cardsWrapper.value.offsetWidth
    currentTranslate.value = -currentIndex.value * wrapperWidth
    prevTranslate.value = currentTranslate.value
  }
}

// Calcul de la résistance pour les bords
const calculateResistance = (diff, wrapperWidth) => {
  const maxResistance = 0.6
  const resistanceArea = wrapperWidth * 0.15
  
  if (currentIndex.value === 0 && diff > 0) {
    return Math.max(maxResistance, 1 - (diff / resistanceArea))
  } else if (currentIndex.value === props.cards.length - 1 && diff < 0) {
    return Math.max(maxResistance, 1 - (Math.abs(diff) / resistanceArea))
  }
  
  return 1
}

// Gestion du swipe/touch
const getPositionX = (event) => {
  return event.type.includes('mouse') ? event.pageX : event.touches[0].clientX
}

const onTouchStart = (event) => {
  startPos.value = getPositionX(event)
  isDragging.value = true
  isSwiping.value = true
  lastPosition.value = startPos.value
  lastTime.value = Date.now()
  
  if (cardsTrack.value) {
    cardsTrack.value.style.cursor = 'grabbing'
  }
  
  animationId.value = requestAnimationFrame(smoothAnimation)
  stopAutoPlay()
}

const onTouchMove = (event) => {
  if (isDragging.value) {
    const currentPosition = getPositionX(event)
    const currentTime = Date.now()
    const diff = currentPosition - startPos.value
    
    // Calcul de la vélocité
    if (currentTime - lastTime.value > 0) {
      velocity.value = (currentPosition - lastPosition.value) / (currentTime - lastTime.value)
    }
    
    lastPosition.value = currentPosition
    lastTime.value = currentTime
    
    // Appliquer la résistance
    const wrapperWidth = cardsWrapper.value.offsetWidth
    const resistance = calculateResistance(diff, wrapperWidth)
    
    currentTranslate.value = prevTranslate.value + (diff * resistance)
  }
}

const onTouchEnd = () => {
  if (isDragging.value) {
    isDragging.value = false
    isSwiping.value = false
    cancelAnimationFrame(animationId.value)
    
    const wrapperWidth = cardsWrapper.value.offsetWidth
    const movedBy = currentTranslate.value - prevTranslate.value
    
    // Effet de momentum
    const momentum = velocity.value * 150
    const totalMovement = movedBy + momentum
    const threshold = wrapperWidth * 0.1 + Math.abs(momentum) * 0.3
    
    if (Math.abs(totalMovement) > threshold) {
      if (totalMovement < 0 && currentIndex.value < props.cards.length - 1) {
        currentIndex.value++
      } else if (totalMovement > 0 && currentIndex.value > 0) {
        currentIndex.value--
      }
    }
    
    updateSlidePosition()
    
    if (cardsTrack.value) {
      cardsTrack.value.style.cursor = 'grab'
    }
    
    setTimeout(() => {
      if (props.autoPlay) {
        startAutoPlay()
      }
    }, 2000)
  }
}

// Animation fluide
const smoothAnimation = () => {
  if (isDragging.value) {
    animationId.value = requestAnimationFrame(smoothAnimation)
  }
}

// Gestion des événements souris
const onMouseDown = (event) => {
  onTouchStart(event)
}

const onMouseMove = (event) => {
  onTouchMove(event)
}

const onMouseEnd = () => {
  onTouchEnd()
}

// Lecture automatique
const startAutoPlay = () => {
  if (props.autoPlay && props.cards.length > 1) {
    stopAutoPlay()
    autoPlayTimer.value = setInterval(() => {
      if (currentIndex.value === props.cards.length - 1) {
        currentIndex.value = 0
      } else {
        currentIndex.value++
      }
      updateSlidePosition()
    }, props.autoPlayInterval)
  }
}

const stopAutoPlay = () => {
  if (autoPlayTimer.value) {
    clearInterval(autoPlayTimer.value)
    autoPlayTimer.value = null
  }
}

// Redimensionnement
const handleResize = () => {
  updateSlidePosition()
}

// Cycle de vie
onMounted(() => {
  updateSlidePosition()
  startAutoPlay()
  window.addEventListener('resize', handleResize)
})

onUnmounted(() => {
  stopAutoPlay()
  window.removeEventListener('resize', handleResize)
  if (animationId.value) {
    cancelAnimationFrame(animationId.value)
  }
})
</script>

<style lang="scss" scoped>
.carousel-container {
  position: relative;
  width: 100%;
  overflow: hidden;
  @include glass();
  border-radius: $radius-pm;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);

  .indicators {
    display: flex;
    justify-content: center;
    gap: 8px;
    padding-bottom: 32px;
    // padding-top: 16px;
    
    .indicator {
      width: 10px;
      height: 10px;
      border-radius: 50%;
      background-color: #ccc;
      cursor: pointer;
      transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
      
      &.active {
        background-color: #007bff;
        transform: scale(1.3);
        animation: pulse 0.4s ease-out;
      }
      
      &:hover {
        transform: scale(1.2);
        background-color: #66b3ff;
      }
    }
  }
  
  .cards-wrapper {
    overflow: hidden;
    cursor: grab;
    border-radius: $radius-pm;
    
    &:active {
      cursor: grabbing;
    }
    
    .cards-track {
      display: flex;
      will-change: transform;
      transition: transform 0.4s cubic-bezier(0.25, 0.46, 0.45, 0.94);
      
      &.dragging {
        transition: none;
        
        .carousel-card {
          transition: none;
        }
      }
      
      &.swiping .carousel-card:not(.active) {
        filter: blur(1px);
        opacity: 0.8;
        transition: all 0.2s ease;
      }
      
      .carousel-card {
        flex: 0 0 100%;
        min-width: 0;
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        
        &.active {
          filter: none;
          opacity: 1;
        }
      }
    }
  }
  
  .nav-button {
    position: absolute;
    top: 90%;
    transform: translateY(-50%) scale(1);
    @include glass();
    border: none;
    border-radius: 50%;
    width: 42px;
    height: 42px;
    font-size: 16px;
    color: $gris;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    // box-shadow: 0 4px 16px rgba(0, 0, 0, 0.15);
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    z-index: 10;
    backdrop-filter: blur(10px);
    
    &:hover:not(:disabled) {
      // background: white;
      // box-shadow: 0 6px 20px rgba(0, 0, 0, 0.2);
      transform: translateY(-50%) scale(1.1);
    }
    
    &:active:not(:disabled) {
      transform: translateY(-50%) scale(0.95);
    }
    
    &:disabled {
      opacity: 0;
      cursor: not-allowed;
      transform: translateY(-50%) scale(1);
    }
    
    &.prev {
      left: 16px;
    }
    
    &.next {
      right: 16px;
    }
  }
}

.carousel-container:hover {
  transform: scale(1.01);
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.12);
}

// Animations
@keyframes pulse {
  0% { transform: scale(1); }
  50% { transform: scale(1.5); }
  100% { transform: scale(1.3); }
}

@keyframes gentleBounce {
  0% { transform: translateX(var(--bounce-start)); }
  60% { transform: translateX(calc(var(--bounce-start) + 10px)); }
  100% { transform: translateX(var(--bounce-end)); }
}

// Responsive
@media (max-width: 768px) {
  .carousel-container {
    .nav-button {
      width: 42px;
      height: 42px;
      font-size: 18px;
      
      &.prev {
        left: 12px;
      }
      
      &.next {
        right: 12px;
      }
    }
    
    .indicators {
      gap: 6px;
      
      .indicator {
        width: 8px;
        height: 8px;
      }
    }
  }
}

@media (max-width: 480px) {
  .carousel-container {
    .nav-button {
      width: 38px;
      height: 38px;
      font-size: 16px;
      
      &.prev {
        left: 8px;
      }
      
      &.next {
        right: 8px;
      }
    }
    
    .indicators {
      margin-bottom: 12px;
      padding-top: 12px;
    }
  }
}

// Overlay de feedback visuel pendant le swipe
.cards-wrapper::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(
    90deg,
    rgba(0, 123, 255, 0.08) 0%,
    transparent 15%,
    transparent 85%,
    rgba(0, 123, 255, 0.08) 100%
  );
  pointer-events: none;
  opacity: 0;
  transition: opacity 0.3s ease;
  z-index: 2;
  border-radius: $radius-pm;
}

.cards-wrapper:active::before {
  opacity: 1;
}
</style>