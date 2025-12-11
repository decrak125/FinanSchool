<script setup>
import { ref, onMounted, computed } from 'vue';
import { useComparaison } from '@/composables/useComparaison';
import CoutProfitChart from '@/components/atoms/Chart/CoutProfitChart.vue';
import Texte from '@/components/atoms/Texte.vue';
import InterpretationCardCoutProfit from '@/components/atoms/Chart/InterpretationCardCoutProfit.vue';
import FilterSelect from '@/components/atoms/Filter-select.vue';

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

// Computed: Obtenir les 12 mois de l'année sélectionnée
const allMonths = computed(() => {
  const months = [];
  for (let i = 1; i <= 12; i++) {
    const monthNum = i.toString().padStart(2, '0');
    const date = new Date(parseInt(filters.value.annee), i - 1, 1);
    months.push({
      numero: i,
      numeroFormate: monthNum,
      nom: date.toLocaleDateString('fr-FR', { month: 'long' }),
      nomCourt: date.toLocaleDateString('fr-FR', { month: 'short' }),
      periode: `${filters.value.annee}-${monthNum}`
    });
  }
  return months;
});

// Computed: Mois qui ont des données
const monthsWithData = computed(() => {
  if (chartData.value.length === 0) return [];
  
  const monthsSet = new Set();
  chartData.value.forEach(item => {
    if (item.mois && item.annee === filters.value.annee) {
      monthsSet.add(parseInt(item.mois));
    }
  });
  
  return Array.from(monthsSet).sort((a, b) => a - b);
});

// Computed: Total des coûts par mois
const costsByMonth = computed(() => {
  const costs = {};
  
  // Initialiser tous les mois à 0
  allMonths.value.forEach(month => {
    costs[month.numero] = 0;
  });
  
  // Remplir avec les données
  chartData.value.forEach(item => {
    if (item.annee === filters.value.annee && item.mois) {
      const mois = parseInt(item.mois);
      costs[mois] += parseFloat(item.total_couts_ventiles) || 0;
    }
  });
  
  return costs;
});

// Computed: Total des profits par mois
const profitsByMonth = computed(() => {
  const profits = {};
  
  // Initialiser tous les mois à 0
  allMonths.value.forEach(month => {
    profits[month.numero] = 0;
  });
  
  // Remplir avec les données
  chartData.value.forEach(item => {
    if (item.annee === filters.value.annee && item.mois) {
      const mois = parseInt(item.mois);
      profits[mois] += parseFloat(item.total_profits_ventiles) || 0;
    }
  });
  
  return profits;
});

// Computed: Solde net par mois
const soldeByMonth = computed(() => {
  const solde = {};
  
  allMonths.value.forEach(month => {
    const profit = profitsByMonth.value[month.numero] || 0;
    const cost = costsByMonth.value[month.numero] || 0;
    solde[month.numero] = profit - cost;
  });
  
  return solde;
});

// Computed: Totaux globaux
const totalCosts = computed(() => {
  return Object.values(costsByMonth.value).reduce((sum, cost) => sum + cost, 0);
});

const totalProfits = computed(() => {
  return Object.values(profitsByMonth.value).reduce((sum, profit) => sum + profit, 0);
});

const totalSolde = computed(() => {
  return totalProfits.value - totalCosts.value;
});

// Fonction pour formater les montants
const formatMontant = (montant) => {
  return new Intl.NumberFormat('mg-MG', {
    minimumFractionDigits: 0,
    maximumFractionDigits: 0
  }).format(parseFloat(montant) || 0);
};

// Fonction pour obtenir la classe CSS selon la valeur
const getValueClass = (value, type = 'solde') => {
  if (type === 'solde') {
    return value >= 0 ? 'positive' : 'negative';
  }
  return '';
};

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
// Computed: Données d'analyse pour la carte d'interprétation
const analyseData = computed(() => {
  if (chartData.value.length === 0) {
    console.log('❌ analyseData: chartData est vide');
    return {
      pointBascule: null,
      moisRentables: 0,
      totalMois: 12,
      meilleurMois: null,
      pireMois: null,
      totalProfits: 0,
      totalCosts: 0,
      soldeAnnuel: 0
    };
  }
  
  console.log('✅ analyseData: chartData contient', chartData.value.length, 'éléments');
  
  // 1. Créer un tableau des 12 mois
  const moisLabels = ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 
                     'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'];
  
  // 2. Calculer le solde pour chaque mois
  const soldeParMois = {};
  const moisInfos = {};
  
  for (let i = 1; i <= 12; i++) {
    const moisNum = i;
    const moisStr = i.toString();
    
    // Filtrer les données pour ce mois et cette année
    const items = chartData.value.filter(item => 
      item.mois === moisStr && item.annee === filters.value.annee
    );
    
    const profit = items.reduce((sum, item) => sum + (parseFloat(item.total_profits_ventiles) || 0), 0);
    const cost = items.reduce((sum, item) => sum + (parseFloat(item.total_couts_ventiles) || 0), 0);
    const solde = profit - cost;
    
    soldeParMois[moisNum] = solde;
    moisInfos[moisNum] = {
      nomMois: moisLabels[i-1],
      nomCourt: moisLabels[i-1].substring(0, 3) + '.',
      profit,
      cost,
      solde
    };
  }
  
  console.log('📊 Solde par mois:', soldeParMois);
  console.log('📋 Détails par mois:', moisInfos);
  
  // 3. Trouver le point de bascule (premier mois rentable)
  let pointBascule = null;
  let moisAvantBascule = 0;
  let trouve = false;
  
  for (let i = 1; i <= 12; i++) {
    if (!trouve) {
      if (soldeParMois[i] > 0) {
        pointBascule = {
          numero: i,
          nomMois: moisInfos[i].nomMois,
          solde: soldeParMois[i],
          moisAvantBascule: moisAvantBascule
        };
        trouve = true;
        console.log('🎯 Point de bascule trouvé:', pointBascule);
      } else if (soldeParMois[i] < 0) {
        moisAvantBascule++;
        console.log(`Mois ${i} déficitaire, compteur: ${moisAvantBascule}`);
      } else {
        console.log(`Mois ${i} équilibré (solde=0)`);
      }
    }
  }
  
  // 4. Compter les mois rentables
  const moisRentables = Object.values(soldeParMois).filter(solde => solde > 0).length;
  const moisDeficitaires = Object.values(soldeParMois).filter(solde => solde < 0).length;
  const moisEquilibre = Object.values(soldeParMois).filter(solde => solde === 0).length;
  
  console.log('📈 Statistiques:', {
    rentables: moisRentables,
    deficitaires: moisDeficitaires,
    equilibre: moisEquilibre,
    total: moisRentables + moisDeficitaires + moisEquilibre
  });
  
  // 5. Trouver le meilleur et pire mois
  let meilleurMois = null;
  let pireMois = null;
  let maxSolde = -Infinity;
  let minSolde = Infinity;
  
  for (let i = 1; i <= 12; i++) {
    const solde = soldeParMois[i];
    
    // Meilleur mois (solde le plus élevé)
    if (solde > maxSolde) {
      maxSolde = solde;
      meilleurMois = {
        numero: i,
        nomMois: moisInfos[i].nomMois,
        solde: solde
      };
    }
    
    // Pire mois (solde le plus bas)
    if (solde < minSolde) {
      minSolde = solde;
      pireMois = {
        numero: i,
        nomMois: moisInfos[i].nomMois,
        solde: solde
      };
    }
  }
  
  console.log('🏆 Meilleur mois:', meilleurMois);
  console.log('📉 Pire mois:', pireMois);
  
  // 6. Calculer les totaux
  let totalProfits = 0;
  let totalCosts = 0;
  
  for (let i = 1; i <= 12; i++) {
    totalProfits += moisInfos[i].profit;
    totalCosts += moisInfos[i].cost;
  }
  
  const soldeAnnuel = totalProfits - totalCosts;
  
  console.log('💰 Totaux:', {
    profits: totalProfits,
    costs: totalCosts,
    solde: soldeAnnuel
  });
  
  return {
    pointBascule,
    moisRentables,
    totalMois: 12,
    meilleurMois,
    pireMois,
    totalProfits,
    totalCosts,
    soldeAnnuel
  };
});
onMounted(() => {
  fetchData();
  fetchTypes();
});
</script>

<template>
  <div class="comparaison-cout-profit">
    <div class="filters-container">
      <!-- <Texte :type="'bold-dark'" :texte="'Analyse Coûts vs Profits'" /> -->
      <div class="filters">
        <Texte :type="'thin-dark'" :texte="'Année'" />
        <FilterSelect v-model="filters.annee" :label="''" @change="fetchData">
            <option v-for="year in availableYears" :key="year" :value="year">
              {{ year }}
            </option>
        </FilterSelect>
        <Texte :type="'thin-dark'" :texte="'Mois'" />
        <FilterSelect v-model="filters.mois" :label="''" @change="fetchData">
            <!-- <option value="">Tout les mois</option> -->
            <option v-for="month in availableMonths" :key="month.value" :value="month.value">
              {{ month.label }}
            </option>
        </FilterSelect>

        <!-- <div class="filter-group">
          <label for="type">Type:</label>
          <select id="type" v-model="filters.id_type" @change="fetchData">
            <option value="">Tous les types</option>
            <option v-for="type in typedata" :key="type.id_type" :value="type.id_type">
              {{ type.code }}
            </option>
          </select>
        </div> -->

        <!-- <button @click="fetchData" :disabled="loading" class="refresh-btn">
          {{ loading ? 'Chargement...' : 'Actualiser' }}
        </button> -->
      </div>
    </div>

    <div class="chart-container">
      <CoutProfitChart 
        :chartData="chartData"
        :loading="loading"
        :error="error"
      />
      <InterpretationCardCoutProfit 
        :data-analyse="analyseData"
        :annee="filters.annee"
        :loading="loading"
      />
    </div>

    <!-- Tableau des 12 mois -->
    <div class="table-div" v-if="chartData.length > 0">
      <div class="ok">
        <div class="info">
          <Texte :type="'bold-dark'" :texte="'Analyse détaillée par mois'" />
          <Texte :type="'dark'" :texte="'Montants en Ariary (Ar).'" />
        </div>
        <div class="iconbtn">
          <i class="bi bi-file-earmark-pdf-fill"></i>
        </div>
      </div>  
        <table class="table" id="axesTable">
          <thead>
            <tr>
              <th>Type</th>
              <th v-for="month in allMonths" :key="month.numero">
                {{ month.nomCourt }}
              </th>
              <th>Total</th>
            </tr>
          </thead>
          <tbody>
            <!-- Ligne des Coûts -->
            <tr>
              <td>
                <span>Coûts</span>
              </td>
              <td v-for="month in allMonths" :key="`costs-${month.numero}`">
                {{ formatMontant(costsByMonth[month.numero]) }}
              </td>
              <td>
                {{ formatMontant(totalCosts) }}
              </td>
            </tr>
            
            <!-- Ligne des Profits -->
            <tr>
              <td>
                <span>Profits</span>
              </td>
              <td v-for="month in allMonths" :key="`profits-${month.numero}`">
                {{ formatMontant(profitsByMonth[month.numero]) }}
              </td>
              <td>
                {{ formatMontant(totalProfits) }}
              </td>
            </tr>
            
            <!-- Ligne du Solde Net -->
            <tr>
              <td>
                <span>Solde Net</span>
              </td>
              <td v-for="month in allMonths" :key="`solde-${month.numero}`" 
                  >
                {{ formatMontant(soldeByMonth[month.numero]) }}
              </td>
              <td >
                {{ formatMontant(totalSolde) }}
              </td>
            </tr>
          </tbody>
        </table>
      
      <!-- Résumé statistique -->
      <!-- <div class="stats-summary" v-if="monthsWithData.length > 0">
        <div class="stat-item">
          <span class="stat-label">Mois avec données:</span>
          <span class="stat-value">{{ monthsWithData.length }}</span>
        </div>
        <div class="stat-item">
          <span class="stat-label">Moyenne mensuelle (Coûts):</span>
          <span class="stat-value">{{ formatMontant(totalCosts / monthsWithData.length) }} Ar</span>
        </div>
        <div class="stat-item">
          <span class="stat-label">Moyenne mensuelle (Profits):</span>
          <span class="stat-value">{{ formatMontant(totalProfits / monthsWithData.length) }} Ar</span>
        </div>
        <div class="stat-item">
          <span class="stat-label">Solde net moyen:</span>
          <span :class="['stat-value', getValueClass(totalSolde / monthsWithData.length)]">
            {{ formatMontant(totalSolde / monthsWithData.length) }} Ar
          </span>
        </div>
      </div> -->
    </div>
  </div>
</template>

<style lang="scss" scoped>
.iconbtn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 49px;
  height: 49px;
  border-radius: 50%;
  @include glass();
  cursor: pointer;

  i {
    color: #e25252;
    font-size: 20px;
  }
}
.ok {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
}
.info{
  @include position-contenus(flex, flex-start, flex-start);
  flex-direction: column;
  gap: 0;
  margin: 0;
  padding: -10px 0;
}
.comparaison-cout-profit {
  width: 100%;
  margin: 0 auto;
}

.filters-container {
  position: fixed;
  left: 612px;
  top: 112px;
  display: flex;
  align-items: baseline;
  flex-direction: column;
  gap: 20px;
  margin-bottom: 30px;
}

.filters {
  display: flex;
  gap: 8px;
  align-items: center;
  justify-content: baseline;
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
  display: flex;
  gap: 20px;
  margin-bottom: 30px;
}

/* Styles pour le tableau */
.table-div {
  width: 100%;
    height: 100%;
    // overflow-x: auto;
    @include glass();
    border-radius: $radius-pm;
    padding: 18px;
    gap: 8px;
}

.table-subtitle {
  font-size: 14px;
  color: #666;
  margin-bottom: 16px;
  font-style: italic;
}

.table-wrapper {
  overflow-x: auto;
  border-radius: 6px;
  border: 1px solid #e5e7eb;
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

.type-header {
  text-align: left !important;
  padding-left: 16px !important;
  min-width: 120px;
}

.month-header {
  min-width: 80px;
  font-weight: 500 !important;
}

.total-header {
  min-width: 100px;
  font-weight: 600 !important;
  background-color: #f1f5f9 !important;
}

#coutProfitTable td {
  padding: 14px 8px;
  border-bottom: 1px solid #f1f5f9;
  text-align: center;
  font-size: 12px;
  color: #4b5563;
}

.type-name {
  text-align: left !important;
  padding-left: 16px !important;
  font-weight: 500;
  display: flex;
  align-items: center;
  gap: 8px;
}

.type-indicator {
  width: 12px;
  height: 12px;
  border-radius: 2px;
  flex-shrink: 0;
}

.costs-row td:not(.type-name) {
  color: #dc2626;
  font-weight: 500;
}

.profits-row td:not(.type-name) {
  color: #059669;
  font-weight: 500;
}

.solde-row {
  background-color: #f8fafc;
  font-weight: 600;
}

.month-value.positive {
  color: #059669;
}

.month-value.negative {
  color: #dc2626;
}

.total-value {
  font-weight: 600;
  background-color: #f1f5f9;
}

.total-value.positive {
  color: #059669;
  background-color: rgba(5, 150, 105, 0.1);
}

.total-value.negative {
  color: #dc2626;
  background-color: rgba(220, 38, 38, 0.1);
}

/* Stats summary */
.stats-summary {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 16px;
  margin-top: 24px;
  padding: 16px;
  background-color: #f8fafc;
  border-radius: 6px;
  border: 1px solid #e5e7eb;
}

.stat-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.stat-label {
  font-size: 12px;
  color: #6b7280;
  font-weight: 500;
}

.stat-value {
  font-size: 14px;
  color: #1f2937;
  font-weight: 600;
}

.stat-value.positive {
  color: #059669;
}

.stat-value.negative {
  color: #dc2626;
}

/* Hover effects */
#coutProfitTable tr:hover {
  background-color: #f9fafb;
}

/* Responsive */
@media (max-width: 768px) {
  .filters {

    flex-direction: column;
    align-items: stretch;
  }
  
  .filter-group {
    width: 100%;
  }
  
  .table-div {
    padding: 16px;
  }
  
  #coutProfitTable th,
  #coutProfitTable td {
    padding: 12px 6px;
    font-size: 11px;
  }
  
  .type-header,
  .type-name {
    min-width: 100px;
  }
  
  .month-header {
    min-width: 60px;
  }
  
  .stats-summary {
    grid-template-columns: 1fr;
    gap: 12px;
  }
}

@media (max-width: 480px) {
  #coutProfitTable {
    font-size: 10px;
  }
  
  #coutProfitTable th,
  #coutProfitTable td {
    padding: 8px 4px;
  }
  
  .type-name {
    padding-left: 8px !important;
    gap: 4px;
  }
  
  .type-indicator {
    width: 8px;
    height: 8px;
  }
}
</style>