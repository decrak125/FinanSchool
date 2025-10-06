<script setup>
import { toRef } from 'vue'

// Définition correcte de la prop
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

// Convertit la prop en ref réactive pour usePagination
const donneesRef = toRef(props, 'donnees')


</script>

<template>
  <div v-if="donneesRef.length > itemsPerPage" class="pagination">
    <!-- Contrôles de pagination -->
    <button @click="previousPage" :disabled="currentPage === 1" class="previousnext">
      <i class="bi bi-chevron-left"></i>
    </button>

    <!-- Numéros de page -->
    <div class="flex space-x-1">
      <button 
        v-for="page in totalPages" 
        :key="page" 
        @click="goToPage(page)" 
        :class="[
          'px-3 py-1 border rounded',
          currentPage === page ? 'previousnext-dsbl' : 'previousnext'
        ]"
      >
        {{ page }}
      </button>
    </div>

    <button @click="nextPage" :disabled="currentPage === totalPages" class="previousnext">
      <i class="bi bi-chevron-right"></i>
    </button>

    <!-- Sélecteur d'éléments par page -->
    <!-- <div class="flex items-center space-x-2">
      <label class="text-sm text-gray-600">Afficher :</label>
      <select 
        v-model="itemsPerPage" 
        @change="resetPagination()" 
        class="border rounded px-2 py-1"
      >
        <option value="5">5</option>
        <option value="10">10</option>
        <option value="20">20</option>
        <option value="50">50</option>
      </select>
      <span class="text-sm text-gray-600">par page</span>
    </div> -->
  </div>
</template>

<style lang="scss" scoped>
.pagination{
  @include position-contenus(flex, center, center);
  padding: 10px;
  gap: 5px;
}

.previousnext{
  cursor: pointer;
  @include bouton($light, $dark, $radius-pm, $stara-medium);
  transition: all 0.5s ease-in-out;
}

.previousnext-dsbl{
  @include bouton(transparent, $dark, $radius-pm, $stara-medium);
  transition: all 0.5s ease-in-out;
}
</style>