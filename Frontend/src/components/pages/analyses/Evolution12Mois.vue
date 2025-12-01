<script setup>
import { ref, onMounted, computed } from 'vue';
import { useComparaison } from '@/composables/useComparaison';
import EvolutionChart from '@/components/atoms/Chart/EvolutionChart.vue';
import Texte from '@/components/atoms/Texte.vue';
// Réactifs
const chartData = ref([]);
const loading = ref(false);
const error = ref('');
const centerdata = ref([]);
const typedata = ref([]);

const filters = ref({
  id_centre: '',
  id_type: '1'
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

const datesUniques = computed(() => {
  const uniqueDates = new Set();
  chartData.value.forEach(item => uniqueDates.add(item.mois));
  return Array.from(uniqueDates).sort();
});

const periodDescription = computed(() => {
  if (datesUniques.value.length === 0) return '';
  
  const dates = datesUniques.value.map(date => new Date(date));
  const minDate = new Date(Math.min(...dates));
  const maxDate = new Date(Math.max(...dates));
  
  return `Période : ${minDate.toLocaleDateString('fr-FR', { month: 'long', year: 'numeric' })} - ${maxDate.toLocaleDateString('fr-FR', { month: 'long', year: 'numeric' })}`;
});

// Méthodes
const fetchData = async () => {
  loading.value = true;
  error.value = '';
  
  try {
    const data = await useComparaison.getDonneesEvolution12Mois(filters.value);
    chartData.value = data;
    console.log('✅ Données évolution 12 mois reçues:', data);
    console.log('📊 Nombre de mois différents:', datesUniques.value.length);
    console.log('🏢 Centres différents:', centresUniques.value);
  } catch (err) {
    error.value = 'Erreur lors du chargement des données';
    console.error('❌ Erreur détaillée:', err);
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

const getMonthName = (dateString) => {
  const date = new Date(dateString);
  return date.toLocaleDateString('fr-FR', { 
    month: 'long',
    year: 'numeric'
  });
};

const formatMontant = (montant) => {
  return new Intl.NumberFormat('mg-MG', {
    // style: 'currency',
    // currency: 'MGA',
    minimumFractionDigits: 0,
    maximumFractionDigits: 0
  }).format(parseFloat(montant) || 0);
};
// --------------------------------------------

// Computed properties
const uniqueMonths = computed(() => {
  const months = [...new Set(chartData.value.map(item => item.mois))];
  return months.sort((a, b) => a - b); // Trier les mois dans l'ordre numérique
});

const uniqueCentres = computed(() => {
  const centres = [...new Set(chartData.value.map(item => item.centre))];
  return centres.sort(); // Trier par ordre alphabétique
});

// Méthodes
const getMontantForCentreAndMonth = (centre, month) => {
  const item = chartData.value.find(d => 
    d.centre === centre && d.mois === month
  );
  // Utilise montant_brut en priorité, sinon montant_ventile
  const montant = item ? (parseFloat(item.montant_brut) || parseFloat(item.montant_ventile) || 0) : 0;
  return montant > 0 ? formatMontant(montant) : '-';
};

const getTotalForCentre = (centre) => {
  const items = chartData.value.filter(d => d.centre === centre);
  const total = items.reduce((sum, item) => 
    sum + (parseFloat(item.montant_brut) || parseFloat(item.montant_ventile) || 0), 0
  );
  return formatMontant(total);
};

const getTotalForMonth = (month) => {
  const items = chartData.value.filter(d => d.mois === month);
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
  <div class="evolution-12-mois">
    <div class="filters-container">
      <h2>Évolution sur 12 Mois</h2>
      
      <div class="filters">
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
        <div class="stat-label">Total Période</div>
      </div>
      <div class="stat-card">
        <div class="stat-value">{{ chartData.length }}</div>
        <div class="stat-label">Enregistrements</div>
      </div>
      <div class="stat-card">
        <div class="stat-value">{{ centresUniques.length }}</div>
        <div class="stat-label">Centres</div>
      </div>
      <div class="stat-card">
        <div class="stat-value">{{ datesUniques.length }}</div>
        <div class="stat-label">Mois analysés</div>
      </div>
    </div> -->

    <div class="chart-container">
      <EvolutionChart 
        :chartData="chartData"
        :loading="loading"
        :error="error"
      />
    </div>

    <!-- Tableau de données -->
    <div class="data-table" v-if="chartData.length > 0">
  <Texte :type="'bold-dark'" :texte="periodDescription" />
    <table class="table" id="axesTable">
      <thead>
        <tr>
          <th class="centre-header">Centre</th>
          <th v-for="month in uniqueMonths" :key="month" class="month-header">
            {{ getMonthName(month) }}
          </th>
          <th class="total-header">Total</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="centre in uniqueCentres" :key="centre">
          <td class="centre-name">{{ centre }}</td>
          <td v-for="month in uniqueMonths" :key="`${centre}-${month}`" class="montant-cell">
            {{ getMontantForCentreAndMonth(centre, month) }}
          </td>
          <td class="total-cell">
            {{ getTotalForCentre(centre) }}
          </td>
        </tr>
        <tr class="total-row">
          <td class="total-label">Total</td>
          <td v-for="month in uniqueMonths" :key="`total-${month}`" class="total-cell">
            {{ getTotalForMonth(month) }}
          </td>
          <td class="grand-total">
            {{ getGrandTotal() }}
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</div>
</template>

<!-- Le style reste identique -->
<style lang="scss" scoped>
.evolution-12-mois {
  width: 100%;
  margin: 0 auto;
}

.filters-container {
  width: 100%;
  margin-bottom: 30px;
}

.period-info {
  font-family: 'stara';
  color: #666;
  font-style: italic;
  margin: 0 0 15px 0;
  font-size: 14px;
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
  width: 100%;
  border-radius: 8px;
  margin-bottom: 30px;
}

.data-table {
  @include glass();
  border-radius: $radius-pm;
  padding: 20px;
  overflow-x: auto;
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