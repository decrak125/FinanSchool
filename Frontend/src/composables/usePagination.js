import { ref, computed } from "vue";

export function usePagination(data){
    // Pagination
const currentPage = ref(1)
const itemsPerPage = ref(10)

// Computed properties pour la pagination
const totalPages = computed(() =>
  Math.ceil(data.value.length / itemsPerPage.value)
)

const startIndex = computed(() =>
  (currentPage.value - 1) * itemsPerPage.value
)

const endIndex = computed(() =>
  Math.min(currentPage.value * itemsPerPage.value, data.value.length)
)

const donneesPagination = computed(() =>
  data.value.slice(startIndex.value, endIndex.value)
)

// Méthodes de pagination
function previousPage() {
  if (currentPage.value > 1) {
    currentPage.value--
  }
}

function nextPage() {
  if (currentPage.value < totalPages.value) {
    currentPage.value++
  }
}

function goToPage(page) {
  currentPage.value = page
}

// Reset à la page 1 quand les données changent
function resetPagination() {
  currentPage.value = 1
}

return {
    currentPage,
    itemsPerPage,
    totalPages,
    startIndex,
    endIndex,
    donneesPagination,
    previousPage,
    nextPage,
    goToPage,
    resetPagination
}
}