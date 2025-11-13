<script setup>
import { toRef, computed } from 'vue'

const props = defineProps({
  donnees: {
    type: Array,
    required: true,
    default: () => []
  },
  currentPage: {
    type: Number,
    required: true
  },
  itemsPerPage: {
    type: Number,
    required: true
  },
  totalPages: {
    type: Number,
    required: true
  },
  goToPage: {
    type: Function,
    required: true
  },
  previousPage: {
    type: Function,
    required: true
  },
  nextPage: {
    type: Function,
    required: true
  }
})

const donneesRef = toRef(props, 'donnees')

// Calcul des pages à afficher
const visiblePages = computed(() => {
  const current = props.currentPage
  const total = props.totalPages
  const delta = 2 // Nombre de pages à afficher de chaque côté
  const range = []
  
  for (let i = 1; i <= total; i++) {
    if (
      i === 1 || // Première page
      i === total || // Dernière page
      (i >= current - delta && i <= current + delta) // Pages autour de la courante
    ) {
      range.push(i)
    }
  }
  
  // Ajouter les points de suspension
  const pagesWithDots = []
  let lastPage = 0
  
  range.forEach(page => {
    if (lastPage && page - lastPage > 1) {
      pagesWithDots.push(' . . . ')
    }
    pagesWithDots.push(page)
    lastPage = page
  })
  
  return pagesWithDots
})
</script>

<template>
  <div v-if="donneesRef.length > itemsPerPage" class="pagination">
    <button @click="previousPage" :disabled="currentPage === 1" class="previousnext">
      <i class="bi bi-chevron-left"></i>
    </button>

    <div class="numpage">
      <button 
        v-for="(page, index) in visiblePages" 
        :key="index" 
        @click="typeof page === 'number' ? goToPage(page) : null" 
        :class="[
          'px-3 py-1 border rounded',
          typeof page === 'number' 
            ? (currentPage === page ? 'previousnext-dsbl' : 'previousnext')
            : 'dots'
        ]"
        :disabled="typeof page !== 'number'"
      >
        {{ page }}
      </button>
    </div>

    <button @click="nextPage" :disabled="currentPage === totalPages" class="previousnext">
      <i class="bi bi-chevron-right"></i>
    </button>
  </div>
</template>

<style lang="scss" scoped>
.pagination{
  @include position-contenus(flex, center, center);
  gap: 5px;
}

.previousnext{
  cursor: pointer;
  @include bouton($light, $dark, $radius-pm, $stara-medium);
  @include glass();
  transition: all 0.5s ease-in-out;
}

.previousnext-dsbl{
  @include bouton(transparent, $dark, $radius-pm, $stara-medium);
  transition: all 0.5s ease-in-out;
}

.numpage{
  @include position-contenus(flex, center, center);
  gap: 5px;
}

.dots {
  cursor: default;
  background: transparent;
  border: none;
  color: $dark;
  padding: 0 8px;
  
  &:hover {
    background: transparent;
  }
}
</style>