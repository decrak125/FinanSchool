<script setup>
import { ref, onMounted, computed, watch } from 'vue';
import { useComparaison } from '@/composables/useComparaison';
import EvolutionChart from '@/components/atoms/Chart/EvolutionChart.vue';
import InterpretationCardEvolution from '@/components/atoms/Chart/InterpretationCardEvolution.vue';
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

// Computed pour trouver le meilleur/pire mois selon id_type
const meilleurPireMoisData = computed(() => {
  if (chartData.value.length === 0) return null;

  // Regrouper les données par mois
  const dataByMonth = {};
  
  chartData.value.forEach(item => {
    const month = item.mois;
    const date = new Date(month);
    const nomMois = date.toLocaleDateString('fr-FR', { 
      month: 'long',
      year: 'numeric'
    });
    
    if (!dataByMonth[month]) {
      dataByMonth[month] = {
        nomMois: nomMois,
        total: 0,
        centre: filters.value.id_centre ? 
          chartData.value.find(d => d.id_centre == filters.value.id_centre)?.centre : 'Tous'
      };
    }
    
    dataByMonth[month].total += parseFloat(item.montant_brut) || parseFloat(item.montant_ventile) || 0;
  });

  const monthsArray = Object.values(dataByMonth);
  
  if (monthsArray.length === 0) return null;
  
  // Trier selon l'id_type
  if (parseInt(filters.id_type) === 1) {
    // Pour id_type = 1 (coûts), on veut le PIRE mois (montant le plus élevé = mauvais)
    monthsArray.sort((a, b) => b.total - a.total); // Décroissant
  } else {
    // Pour id_type = 2 (bénéfices), on veut le MEILLEUR mois (montant le plus élevé = bon)
    monthsArray.sort((a, b) => b.total - a.total); // Décroissant
  }
  
  const selectedMonth = monthsArray[0];
  
  // Calculer l'évolution par rapport au mois précédent
  let moyenne = 0;
  for (let i = 0; i < monthsArray.length; i++) {
    moyenne += monthsArray[i].total;
  }
  moyenne /= monthsArray.length;
  let evolution = 0;
  let montantevolution = 0;
  if (monthsArray.length > 1) {
    const prevMonth = monthsArray[1];
    if (prevMonth.total > 0) {
      evolution = ((selectedMonth.total - moyenne) / moyenne) * 100;
      montantevolution = selectedMonth.total - moyenne;
    }
  }
  
  return {
    nomMois: selectedMonth.nomMois,
    montant: montantevolution,
    centre: selectedMonth.centre,
    evolution: evolution
  };
});

// Computed pour le formatage des montants
const totalMontantFormatted = computed(() => {
  const total = chartData.value.reduce((sum, item) => {
    return sum + (parseFloat(item.montant_brut) || 0);
  }, 0);
  return new Intl.NumberFormat('mg-MG', {
    minimumFractionDigits: 0,
    maximumFractionDigits: 0
  }).format(total);
});

const periodDescription = computed(() => {
  if (chartData.value.length === 0) return '';
  
  const dates = [...new Set(chartData.value.map(item => new Date(item.mois)))];
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
    minimumFractionDigits: 0,
    maximumFractionDigits: 0
  }).format(parseFloat(montant) || 0);
};

// Computed properties pour le tableau
const uniqueMonths = computed(() => {
  const months = [...new Set(chartData.value.map(item => item.mois))];
  return months.sort((a, b) => a - b);
});

const uniqueCentresTableau = computed(() => {
  const centres = [...new Set(chartData.value.map(item => item.centre))];
  return centres.sort();
});

// Méthodes pour le tableau
const getMontantForCentreAndMonth = (centre, month) => {
  const item = chartData.value.find(d => 
    d.centre === centre && d.mois === month
  );
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

// Watch les filtres
watch(filters, () => {
  fetchData();
}, { deep: true });
</script>

<template>
  <div class="evolution-12-mois">
    <div class="filters-container">
      <h2>Évolution sur 12 Mois</h2>
      
      <div class="filters">
        <div class="filter-group">
          <label for="centre">Centre:</label>
          <select id="centre" v-model="filters.id_centre">
            <option value="">Tous les centres</option>
            <option v-for="centre in centerdata" :key="centre.id_centre" :value="centre.id_centre">
              {{ centre.nom }}
            </option>
          </select>
        </div>

        <div class="filter-group">
          <label for="type">Type:</label>
          <select id="type" v-model="filters.id_type">
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

    <!-- Carte d'interprétation unique -->

    <div class="chart-container">
      <EvolutionChart 
        :chartData="chartData"
        :loading="loading"
        :error="error"
      />
      <InterpretationCardEvolution 
        :data-mois="meilleurPireMoisData"
        :id-type="parseInt(filters.id_type)"
        :loading="loading"
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
          <tr v-for="centre in uniqueCentresTableau" :key="centre">
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

<style lang="scss" scoped>
.evolution-12-mois {
  width: 100%;
  margin: 0 auto;
}

.filters-container {
  width: 100%;
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

/* Style pour la carte d'interprétation */
.interpretation-card {
  margin-bottom: 30px;
}

.chart-container {
  width: 100%;
  display: flex;
  gap: 20px;
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
  }
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