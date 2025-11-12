<template>
  <div class="carousel-container">
    <!-- Indicateurs de progression -->
    <div class="indicators" v-if="cards.length > 1">
      <span 
        v-for="(card, index) in cards" 
        :key="index"
        :class="['indicator', { active: currentIndex === index }]"
        @click="goToSlide(index)"
      ></span>
    </div>
    
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
      >
        <InterpretationCard
          v-for="(card, index) in cards"
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
          class="carousel-card"
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
      ‹
    </button>
    <button 
      v-if="cards.length > 1 && showNavigation"
      class="nav-button next"
      @click="nextSlide"
      :disabled="currentIndex === cards.length - 1"
    >
      ›
    </button>
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
    default: 5000 // 5 secondes
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
const startPos = ref(0)
const currentTranslate = ref(0)
const prevTranslate = ref(0)
const animationId = ref(null)

// Style du track pour l'animation
const trackStyle = computed(() => {
  return {
    transform: `translateX(${currentTranslate.value}px)`,
    transition: isDragging.value ? 'none' : 'transform 0.3s ease-out'
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

// Gestion du swipe/touch
const getPositionX = (event) => {
  return event.type.includes('mouse') ? event.pageX : event.touches[0].clientX
}

const onTouchStart = (event) => {
  startPos.value = getPositionX(event)
  isDragging.value = true
  animationId.value = requestAnimationFrame(animation)
  if (cardsTrack.value) {
    cardsTrack.value.style.cursor = 'grabbing'
  }
}

const onTouchMove = (event) => {
  if (isDragging.value) {
    const currentPosition = getPositionX(event)
    const diff = currentPosition - startPos.value
    currentTranslate.value = prevTranslate.value + diff
  }
}

const onTouchEnd = () => {
  if (isDragging.value) {
    isDragging.value = false
    cancelAnimationFrame(animationId.value)
    
    const wrapperWidth = cardsWrapper.value.offsetWidth
    const movedBy = currentTranslate.value - prevTranslate.value
    
    // Déterminer si on change de slide
    if (Math.abs(movedBy) > wrapperWidth * 0.1) {
      if (movedBy < 0 && currentIndex.value < props.cards.length - 1) {
        currentIndex.value++
      } else if (movedBy > 0 && currentIndex.value > 0) {
        currentIndex.value--
      }
    }
    
    updateSlidePosition()
    
    if (cardsTrack.value) {
      cardsTrack.value.style.cursor = 'grab'
    }
  }
}

// Animation pour un déplacement fluide
const animation = () => {
  if (isDragging.value) {
    animationId.value = requestAnimationFrame(animation)
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
    autoPlayTimer.value = setInterval(() => {
      if (currentIndex.value === props.cards.length - 1) {
        currentIndex.value = 0
      } else {
        currentIndex.value++
      }
      updateSlidePosition()
    }, 5000)
  }
}

const stopAutoPlay = () => {
  if (autoPlayTimer.value) {
    clearInterval(autoPlayTimer.value)
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
  
  .indicators {
    display: flex;
    justify-content: center;
    gap: 8px;
    margin-bottom: 16px;
    
    .indicator {
      width: 10px;
      height: 10px;
      border-radius: 50%;
      background-color: #ccc;
      cursor: pointer;
      transition: background-color 0.3s;
      
      &.active {
        background-color: #007bff;
      }
    }
  }
  
  .cards-wrapper {
    overflow: hidden;
    cursor: grab;
    
    .cards-track {
      display: flex;
      transition: transform 0.3s ease-out;
      
      .carousel-card {
        flex: 0 0 100%;
        min-width: 0;
      }
    }
  }
  
  .nav-button {
    position: absolute;
    top: 50%;
    transform: translateY(-50%);
    background: rgba(255, 255, 255, 0.8);
    border: none;
    border-radius: 50%;
    width: 40px;
    height: 40px;
    font-size: 20px;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    box-shadow: 0 2px 5px rgba(0, 0, 0, 0.2);
    transition: all 0.3s;
    z-index: 10;
    
    &:hover:not(:disabled) {
      background: white;
      box-shadow: 0 4px 8px rgba(0, 0, 0, 0.3);
    }
    
    &:disabled {
      opacity: 0.5;
      cursor: not-allowed;
    }
    
    &.prev {
      left: 10px;
    }
    
    &.next {
      right: 10px;
    }
  }
}

// Responsive
@media (max-width: 768px) {
  .carousel-container .nav-button {
    width: 35px;
    height: 35px;
    font-size: 18px;
    
    &.prev {
      left: 5px;
    }
    
    &.next {
      right: 5px;
    }
  }
}
</style>