<script setup>
import { ref, onMounted, computed } from 'vue';
import { useComparaison } from '@/composables/useComparaison';
import CoutProfitChart from '@/components/atoms/Chart/CoutProfitChart.vue';
import Texte from '@/components/atoms/Texte.vue';

const chartData = ref([]);
const loading = ref(false);
const error = ref('');
const typedata = ref([]);

const filters = ref({
  annee: new Date().getFullYear().toString(),
  mois: '',
  id_type: '',
  limit: 1000,
  offset: 0
});

// Génération des années
const availableYears = computed(() => {
  const currentYear = new Date().getFullYear();
  const years = [];
  for (let i = 0; i <= 5; i++) {
    years.push((currentYear - i).toString());
  }
  return years;
});

// Mois disponibles
const availableMonths = [
  { value: '', label: 'Tous les mois' },
  { value: '1', label: 'Janvier' },
  { value: '2', label: 'Février' },
  { value: '3', label: 'Mars' },
  { value: '4', label: 'Avril' },
  { value: '5', label: 'Mai' },
  { value: '6', label: 'Juin' },
  { value: '7', label: 'Juillet' },
  { value: '8', label: 'Août' },
  { value: '9', label: 'Septembre' },
  { value: '10', label: 'Octobre' },
  { value: '11', label: 'Novembre' },
  { value: '12', label: 'Décembre' }
];

const fetchData = async () => {
  loading.value = true;
  error.value = '';
  
  try {
    const data = await useComparaison.getComparaisonCoutProfit(filters.value);
    chartData.value = data;
    console.log('Données coûts vs profits reçues:', data);
  } catch (err) {
    error.value = 'Erreur lors du chargement des données';
    console.error('Erreur détaillée:', err);
  } finally {
    loading.value = false;
  }
};

const fetchTypes = async () => {
  try {
    const type = await useComparaison.getType();
    typedata.value = type;
  } catch (err) {
    console.error('Erreur lors du chargement des types:', err);
  }
};

onMounted(() => {
  fetchData();
  fetchTypes();
});
</script>

<template>
  <div class="comparaison-cout-profit">
    <div class="filters-container">
      <h2>Analyse Coûts vs Profits</h2>
      
      <div class="filters">
        <div class="filter-group">
          <label for="annee">Année:</label>
          <select id="annee" v-model="filters.annee" @change="fetchData">
            <option v-for="year in availableYears" :key="year" :value="year">
              {{ year }}
            </option>
          </select>
        </div>

        <div class="filter-group">
          <label for="mois">Mois:</label>
          <select id="mois" v-model="filters.mois" @change="fetchData">
            <option v-for="month in availableMonths" :key="month.value" :value="month.value">
              {{ month.label }}
            </option>
          </select>
        </div>

        <div class="filter-group">
          <label for="type">Type:</label>
          <select id="type" v-model="filters.id_type" @change="fetchData">
            <option value="">Tous les types</option>
            <option v-for="type in typedata" :key="type.id_type" :value="type.id_type">
              {{ type.code }}
            </option>
          </select>
        </div>

        <button @click="fetchData" :disabled="loading" class="refresh-btn">
          {{ loading ? 'Chargement...' : 'Actualiser' }}
        </button>
      </div>
    </div>

    <div class="chart-container">
      <CoutProfitChart 
        :chartData="chartData"
        :loading="loading"
        :error="error"
      />
    </div>
  </div>
</template>

<style scoped>
.comparaison-cout-profit {
  width: 100%;
  margin: 0 auto;
}

.filters-container {
  margin-bottom: 30px;
}

.filters {
  display: flex;
  gap: 20px;
  align-items: end;
  flex-wrap: wrap;
}

.filter-group {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.filter-group label {
  font-weight: bold;
  font-size: 14px;
}

.filter-group select {
  padding: 8px 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  min-width: 150px;
}

.refresh-btn {
  padding: 8px 16px;
  background: #007bff;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  height: fit-content;
}

.chart-container {
  border-radius: 8px;
}

@media (max-width: 768px) {
  .filters {
    flex-direction: column;
    align-items: stretch;
  }
  
  .filter-group {
    width: 100%;
  }
}
</style>