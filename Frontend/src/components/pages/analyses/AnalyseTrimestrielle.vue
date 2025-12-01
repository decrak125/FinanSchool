<script setup>
import { ref, onMounted, computed } from 'vue';
import { useComparaison } from '@/composables/useComparaison';
import ColumnChart from '@/components/atoms/Chart/ColumnChart.vue';
import Texte from '@/components/atoms/Texte.vue';

// Réactifs
const chartData = ref([]);
const loading = ref(false);
const error = ref('');
const centerdata = ref([]);
const typedata = ref([]);

const filters = ref({
  year: new Date().getFullYear().toString(),
  id_centre: '',
  id_type: '1'
});

// Génération dynamique des années (année actuelle jusqu'à 10 ans en arrière)
const availableYears = computed(() => {
  const currentYear = new Date().getFullYear();
  const years = [];
  for (let i = 0; i <= 10; i++) {
    years.push((currentYear - i).toString());
  }
  return years;
});

// Computed
const totalMontantFormatted = computed(() => {
  const total = chartData.value.reduce((sum, item) => {
    return sum + (parseFloat(item.montant_brut) || 0);
  }, 0);
  return new Intl.NumberFormat('mg-MG', {
    // style: 'currency',
    // currency: 'MGA',
    minimumFractionDigits: 0,
    maximumFractionDigits: 0
  }).format(total);
});

const centresUniques = computed(() => {
  const uniqueCentres = new Set();
  chartData.value.forEach(item => uniqueCentres.add(item.centre));
  return Array.from(uniqueCentres);
});

// Méthodes
const fetchData = async () => {
  loading.value = true;
  error.value = '';
  
  try {
    const data = await useComparaison.getDonneesTrimestrielles(filters.value);
    chartData.value = data;
    console.log('Données trimestrielles reçues:', data);
  } catch (err) {
    error.value = 'Erreur lors du chargement des données';
    console.error('Erreur détaillée:', err);
  } finally {
    loading.value = false;
  }
};

const fetchCentres = async () => {
  try {
    const center = await useComparaison.getCentres();
    centerdata.value = center;
  } catch (err) {
    console.error('Erreur lors du chargement des centres:', err);
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

const getTrimestreName = (trimestreNumber) => {
  const trimestres = [
    '1er Trimestre',
    '2ème Trimestre', 
    '3ème Trimestre',
    '4ème Trimestre'
  ];
  return trimestres[parseInt(trimestreNumber) - 1] || trimestreNumber;
};

const formatMontant = (montant) => {
  return new Intl.NumberFormat('mg-MG', {
    // style: 'currency',
    // currency: 'MGA',
    minimumFractionDigits: 0,
    maximumFractionDigits: 0
  }).format(parseFloat(montant) || 0);
};
// --------------------------------
// Computed properties
const uniqueTrimestres = computed(() => {
  const trimestres = [...new Set(chartData.value.map(item => item.trimestre))];
  return trimestres.sort((a, b) => a - b);
});

const uniqueCentres = computed(() => {
  const centres = [...new Set(chartData.value.map(item => item.centre))];
  return centres.sort();
});

// Méthodes
const getMontantForCentreAndTrimestre = (centre, trimestre) => {
  const item = chartData.value.find(d => 
    d.centre === centre && d.trimestre === trimestre
  );
  return item ? formatMontant(item.montant_brut || item.montant_ventile) : '-';
};

const getTotalForCentre = (centre) => {
  const items = chartData.value.filter(d => d.centre === centre);
  const total = items.reduce((sum, item) => 
    sum + (parseFloat(item.montant_brut) || parseFloat(item.montant_ventile) || 0), 0
  );
  return formatMontant(total);
};

const getTotalForTrimestre = (trimestre) => {
  const items = chartData.value.filter(d => d.trimestre === trimestre);
  const total = items.reduce((sum, item) => 
    sum + (parseFloat(item.montant_brut) || parseFloat(item.montant_ventile) || 0), 0
  );
  return formatMontant(total);
};

const getGrandTotal = () => {
  const total = chartData.value.reduce((sum, item) => 
    sum + (parseFloat(item.montant_brut) || parseFloat(item.montant_ventile) || 0), 0
  );
  return formatMontant(total);
};

// Cycle de vie
onMounted(() => {
  fetchData();
  fetchCentres();
  fetchTypes();
});
</script>

<template>
  <div class="analyse-trimestrielle">
    <div class="filters-container">
      <h2>Analyse Trimestrielle des Montants</h2>
      
      <div class="filters">
        <div class="filter-group">
          <label for="year">Année:</label>
          <select id="year" v-model="filters.year" @change="fetchData">
            <option v-for="year in availableYears" :key="year" :value="year">
              {{ year }}
            </option>
          </select>
        </div>

        <div class="filter-group">
          <label for="centre">Centre:</label>
          <select id="centre" v-model="filters.id_centre" @change="fetchData">
            <option value="">Tous les centres</option>
            <option v-for="centre in centerdata" :key="centre.id_centre" :value="centre.id_centre">
              {{ centre.nom }}
            </option>
          </select>
        </div>

        <div class="filter-group">
          <label for="type">Type:</label>
          <select id="type" v-model="filters.id_type" @change="fetchData">
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

    <!-- Statistiques résumées -->
    <!-- <div class="stats-container" v-if="chartData.length > 0">
      <div class="stat-card">
        <div class="stat-value">{{ totalMontantFormatted }}</div>
        <div class="stat-label">Total Montant Brut</div>
      </div>
      <div class="stat-card">
        <div class="stat-value">{{ chartData.length }}</div>
        <div class="stat-label">Enregistrements</div>
      </div>
      <div class="stat-card">
        <div class="stat-value">{{ centresUniques.length }}</div>
        <div class="stat-label">Centres</div>
      </div>
    </div> -->

    <div class="chart-container">
      <ColumnChart 
        :chartData="chartData"
        :loading="loading"
        :error="error"
      />
    </div>

    <!-- Tableau de données -->
<div class="data-table" v-if="chartData.length > 0">
  <Texte :type="'bold-dark'" :texte="'Données détaillées par trimestre'" />
    <table class="table" id="axesTable">
      <thead>
        <tr>
          <th class="centre-header">Centre</th>
          <th v-for="trimestre in uniqueTrimestres" :key="trimestre" class="trimestre-header">
            {{ getTrimestreName(trimestre) }}
          </th>
          <th class="total-header">Total</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="centre in uniqueCentres" :key="centre">
          <td class="centre-name">{{ centre }}</td>
          <td v-for="trimestre in uniqueTrimestres" :key="`${centre}-${trimestre}`" class="montant-cell">
            {{ getMontantForCentreAndTrimestre(centre, trimestre) }}
          </td>
          <td class="total-cell">
            {{ getTotalForCentre(centre) }}
          </td>
        </tr>
        <tr class="total-row">
          <td class="total-label">Total</td>
          <td v-for="trimestre in uniqueTrimestres" :key="`total-${trimestre}`" class="total-cell">
            {{ getTotalForTrimestre(trimestre) }}
          </td>
          <td class="grand-total">
            {{ getGrandTotal() }}
          </td>
        </tr>
      </tbody>
    </table>
</div>  </div>
</template>

<style  lang="scss"  scoped>
.analyse-trimestrielle {
  width: 100%;
    border-radius: $radius-pm;
    margin: 0 auto;
}

.filters-container {
  border-radius: 8px;
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

.refresh-btn:disabled {
  background: #6c757d;
  cursor: not-allowed;
}

.stats-container {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}

.stat-card {
  background: white;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  text-align: center;
}

.stat-value {
  font-size: 24px;
  font-weight: bold;
  color: #007bff;
}

.stat-label {
  font-size: 14px;
  color: #666;
  margin-top: 5px;
}

.chart-container {
  margin-bottom: 30px;
}

.data-table {
  width: 100%;
    height: 100%;
    // overflow-x: auto;
    @include glass();
    border-radius: $radius-pm;
    padding: 18px;
    gap: 8px;
}

  #axesTable {
  opacity: 0;
    transform: translateY(-1px);
    animation: slideInDown 0.5s ease-out forwards;
    thead tr:first-child{
        background: transparent;
        backdrop-filter: blur(50px);
        position: sticky;
        top: 0;
        z-index: 99;
    }
    th{
        background: fixed transparent;
        color: $primary;
        font-family: $stara-black;
        font-size: 12px;
        text-align:start;
        // z-index: 99;
        padding: 24px 0px;
        @media (max-width: $mobile) {
            font-size: 14px;
            padding: 12px 8px;
        }
    }
    tr:hover{
        background-color: transparent;
        cursor: pointer;
        transition: all 0.3s ease-in-out;
    }
    tr{
        transition: all 0.3s ease-in-out;
    }
    
    tr td:last-child,
    tr th:last-child {
        text-align:center;
    }
    
    td{
        padding: 24px 0px;
        animation: appear 0.6s ease-out forwards;
        font-size: 12px;
        @media (max-width: $mobile) {
            font-size: 13px;
            padding: 10px 8px;
        }
    }
    
    background: fixed;
    font-family: $stara-medium;
    border-radius: $radius-pm;
    color: $dark;
    
    @media (max-width: $mobile) {
        border-radius: $radius-sm;
        font-size: 14px;
    }}

@media (max-width: 768px) {
  .filters {
    flex-direction: column;
    align-items: stretch;
  }
  
  .filter-group {
    width: 100%;
  }
  
  .stats-container {
    grid-template-columns: 1fr;
  }
}
</style>