<script setup>
import { ref, onMounted, computed } from 'vue';
import { useComparaison } from '@/composables/useComparaison';
import AreaChart from '@/components/atoms/Chart/AreaChart.vue';
import Texte from '@/components/atoms/Texte.vue';
import InterpretationCardCout from '@/components/atoms/Chart/InterpretationCardCout.vue';
import FilterSelect from '@/components/atoms/Filter-select.vue';

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
    const data = await useComparaison.getDonneesMensuelles(filters.value);
    chartData.value = data;
    console.log('Données reçues:', data);
    const center = await useComparaison.getCentres();
    centerdata.value = center;
    console.log('centres reçues:', center);
    const type = await useComparaison.getType();
    typedata.value = type;
    console.log('type reçues:', type);
  } catch (err) {
    error.value = 'Erreur lors du chargement des données';
    console.error('Erreur détaillée:', err);
  } finally {
    loading.value = false;
  }
};
  
const getMonthName = (monthNumber) => {
  const months = [
    'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
  ];
  return months[parseInt(monthNumber) - 1] || monthNumber;
};

// const formatMontant = (montant) => {
//   return new Intl.NumberFormat('fr-FR', { 
//     style: 'currency', 
//     currency: 'EUR' 
//   }).format(parseFloat(montant) || 0);
// };
// Formater les valeurs monétaires
const formatMontant = (value) => {
  if (value === null || value === undefined) return '';
  return new Intl.NumberFormat('mg-MG', {
    // style: 'currency',
    // currency: 'MGA',
    minimumFractionDigits: 0,
    maximumFractionDigits: 0
  }).format(value);
};


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
  return item ? formatMontant(item.montant_brut || item.montant_ventile) : '-';
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

// Computed: Trouver le mois avec la plus grande augmentation
const moisPlusGrandeAugmentation = computed(() => {
  if (chartData.value.length === 0 || uniqueMonths.value.length < 2) return null;
  
  const totalsByMonth = {};
  
  // Calculer le total par mois
  uniqueMonths.value.forEach(month => {
    const total = chartData.value
      .filter(item => item.mois === month)
      .reduce((sum, item) => sum + (parseFloat(item.montant_brut) || 0), 0);
    totalsByMonth[month] = total;
  });
  
  let maxIncrease = 0;
  let maxIncreaseMonth = null;
  let maxIncreasePercentage = 0;
  let previousMonthValue = 0;
  
  // Trier les mois pour les traiter dans l'ordre
  const sortedMonths = [...uniqueMonths.value].sort((a, b) => a - b);
  
  // Calculer les augmentations mois par mois
  for (let i = 1; i < sortedMonths.length; i++) {
    const currentMonth = sortedMonths[i];
    const previousMonth = sortedMonths[i - 1];
    
    const currentValue = totalsByMonth[currentMonth] || 0;
    const previousValue = totalsByMonth[previousMonth] || 0;
    
    // Éviter la division par zéro
    if (previousValue > 0) {
      const increase = currentValue - previousValue;
      const percentage = (increase / previousValue) * 100;
      
      if (increase > 0 && percentage > maxIncreasePercentage) {
        maxIncrease = increase;
        maxIncreaseMonth = currentMonth;
        maxIncreasePercentage = percentage;
        previousMonthValue = previousValue;
      }
    }
  }
  
  if (!maxIncreaseMonth) return null;
  
  return {
    mois: maxIncreaseMonth,
    moisNom: getMonthName(maxIncreaseMonth),
    augmentation: maxIncrease,
    pourcentage: maxIncreasePercentage,
    valeurMoisPrecedent: previousMonthValue,
    valeurMoisActuel: totalsByMonth[maxIncreaseMonth] || 0
  };
});

// Computed: Trouver le mois avec la plus grande baisse (version corrigée)
const moisPlusGrandeBaisse = computed(() => {
  if (chartData.value.length === 0 || uniqueMonths.value.length < 2) return null;
  
  const totalsByMonth = {};
  
  uniqueMonths.value.forEach(month => {
    const total = chartData.value
      .filter(item => item.mois === month)
      .reduce((sum, item) => sum + (parseFloat(item.montant_brut) || 0), 0);
    totalsByMonth[month] = total;
  });
  
  let maxDecrease = 0;
  let maxDecreaseMonth = null;
  let maxDecreasePercentage = 0; // Cette valeur sera négative pour les baisses
  let previousMonthValue = 0;
  
  const sortedMonths = [...uniqueMonths.value].sort((a, b) => a - b);
  
  for (let i = 1; i < sortedMonths.length; i++) {
    const currentMonth = sortedMonths[i];
    const previousMonth = sortedMonths[i - 1];
    
    const currentValue = totalsByMonth[currentMonth] || 0;
    const previousValue = totalsByMonth[previousMonth] || 0;
    
    // Calcul du pourcentage (peut être positif ou négatif)
    if (previousValue !== 0) {
      const percentage = ((currentValue - previousValue) / previousValue) * 100;
      
      // Pour une baisse, le pourcentage doit être NÉGATIF et plus bas que le précédent
      if (percentage < 0 && percentage < maxDecreasePercentage) {
        maxDecrease = currentValue - previousValue; // Ce sera négatif
        maxDecreaseMonth = currentMonth;
        maxDecreasePercentage = percentage; // Valeur négative
        previousMonthValue = previousValue;
      }
    } else if (currentValue < previousValue) {
      // Cas particulier: previousValue = 0 mais on a une baisse
      const percentage = -100; // Baisse de 100% (à partir de 0)
      if (percentage < maxDecreasePercentage) {
        maxDecrease = currentValue - previousValue;
        maxDecreaseMonth = currentMonth;
        maxDecreasePercentage = percentage;
        previousMonthValue = previousValue;
      }
    }
  }
  
  // Si aucune baisse n'a été trouvée (tous les mois ont augmenté)
  if (!maxDecreaseMonth) {
    // On peut retourner le mois avec la plus petite augmentation (proche de 0)
    let minIncreasePercentage = Infinity;
    let minIncreaseMonth = null;
    let minIncrease = 0;
    let minPreviousValue = 0;
    
    for (let i = 1; i < sortedMonths.length; i++) {
      const currentMonth = sortedMonths[i];
      const previousMonth = sortedMonths[i - 1];
      
      const currentValue = totalsByMonth[currentMonth] || 0;
      const previousValue = totalsByMonth[previousMonth] || 0;
      
      if (previousValue > 0) {
        const percentage = ((currentValue - previousValue) / previousValue) * 100;
        
        // Cherche l'augmentation la plus faible (la plus proche de 0)
        if (percentage >= 0 && percentage < minIncreasePercentage) {
          minIncreasePercentage = percentage;
          minIncreaseMonth = currentMonth;
          minIncrease = currentValue - previousValue;
          minPreviousValue = previousValue;
        }
      }
    }
    
    if (minIncreaseMonth) {
      return {
        mois: minIncreaseMonth,
        moisNom: getMonthName(minIncreaseMonth),
        baisse: minIncrease, // Ce sera positif ou 0
        pourcentage: minIncreasePercentage, // Ce sera positif
        valeurMoisPrecedent: minPreviousValue,
        valeurMoisActuel: totalsByMonth[minIncreaseMonth] || 0,
        note: "Aucune baisse cette année - mois avec la plus faible augmentation"
      };
    }
    
    return null;
  }
  
  return {
    mois: maxDecreaseMonth,
    moisNom: getMonthName(maxDecreaseMonth),
    baisse: maxDecrease, // Valeur négative
    pourcentage: maxDecreasePercentage, // Valeur négative
    valeurMoisPrecedent: previousMonthValue,
    valeurMoisActuel: totalsByMonth[maxDecreaseMonth] || 0
  };
});
// Cycle de vie
onMounted(() => {
  fetchData();
});
</script>
<template>
    <div class="analyse-mensuelle">
      <div class="filters-container">
        <!-- <Texte :type="'bold-dark'" :texte="'Analyse Mensuelle des Montants'" /> -->
        <div class="filters">
          <Texte :type="'thin-dark'" :texte="'Année'" />
          <FilterSelect v-model="filters.year" :label="''" @change="fetchData">
            <option v-for="year in availableYears" :key="year" :value="year">
              {{ year }}
            </option>
          </FilterSelect>
          
          <Texte :type="'thin-dark'" :texte="'Centre'" />
          <FilterSelect v-model="filters.id_centre" :label="''" @change="fetchData">
            <option value="">Tous les centres</option>
            <option v-for="centre in centerdata" :key="centre.id_centre" :value="centre.id_centre">
              {{ centre.nom }}
            </option>
          </FilterSelect>
          
          <Texte :type="'thin-dark'" :texte="'Type'" />
          <FilterSelect v-model="filters.id_type" :label="''" @change="fetchData">
            <option v-for="type in typedata" :key="type.id_type" :value="type.id_type">
              {{ type.code }}
            </option>
          </FilterSelect>
          
          <!-- <div class="filter-group">
            <label for="centre">Centre:</label>
            <select id="centre" v-model="filters.id_centre" @change="fetchData">
              <option value="">Tous les centres</option>
              <option v-for="centre in centerdata" :key="centre.id_centre" :value="centre.id_centre">
                {{ centre.nom }}
              </option>
            </select>
          </div> -->
  
          <!-- <div class="filter-group">
            <label for="type">Type:</label>
            <select id="type" v-model="filters.id_type" @change="fetchData">
              <option v-for="type in typedata" :key="type.id_type" :value="type.id_type">
                {{ type.code }}
              </option>
            </select>
          </div>
  
          <button @click="fetchData" :disabled="loading" class="refresh-btn">
            {{ loading ? 'Chargement...' : 'Actualiser' }}
          </button> -->
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
          <div class="stat-value">{{ filters.year }}</div>
          <div class="stat-label">Année d'exercice</div>
        </div>
        <div class="stat-card">
          <div class="stat-value">{{ centresUniques.length }}</div>
          <div class="stat-label">Centres</div>
        </div>
      </div> -->
      <div class="chart-container">
        <AreaChart 
          :chartData="chartData"
          :loading="loading"
          :error="error"
        />
        <InterpretationCardCout
          v-if="moisPlusGrandeAugmentation"
          :type="'comparaison-mois'"
          :dataComparaison="moisPlusGrandeAugmentation"
          :loading="loading"
          :idType="filters.id_type || 1" 
      />

      <!-- Pour afficher le mois avec la plus grande baisse -->
      <!-- <InterpretationCardCout
          v-if="moisPlusGrandeBaisse"
          :type="'comparaison-mois'"
          :dataComparaison="moisPlusGrandeBaisse"
          :loading="loading"
      /> -->
      </div>
  
      <!-- Tableau de données -->
<div class="table-div"  v-if="chartData.length > 0">
  <div class="ok">
    <div class="info">
    <Texte :type="'bold-dark'" :texte="'Données mensuelles détaillées'" />
    <Texte :type="'dark'" :texte="'Montants en Ariary (Ar).'" />
    </div>
    <div class="iconbtn">
      <i class="bi bi-file-earmark-pdf-fill"></i>
    </div>
  </div>
  <table class="table" id="axesTable">
    <thead>
      <tr>
        <th>Centre</th>
        <th v-for="month in uniqueMonths" :key="month">{{ getMonthName(month) }}</th>
        <th>Total</th>
      </tr>
    </thead>
    <tbody>
      <tr v-for="centre in uniqueCentres" :key="centre">
        <td class="centre-name">{{ centre }}</td>
        <td v-for="month in uniqueMonths" :key="month">
          {{ getMontantForCentreAndMonth(centre, month) }}
        </td>
        <td class="total-cell">
          {{ getTotalForCentre(centre) }}
        </td>
      </tr>
      <tr class="total-row">
        <td class="total-cell">Total</td>
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
    .table-div {
    width: 100%;
    height: 100%;
    // overflow-x: auto;
    @include glass();
    border-radius: $radius-pm;
    padding: 18px;
    gap: 8px;
  }
  .graphics{
    @include position-contenus(flex, center, center);
  }
  .analyse-mensuelle {
    // @include glass();
    width: 100%;
    border-radius: $radius-pm;
    margin: 0 auto;
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
    display: flex;
    width: 100%;
    gap: 20px;
    margin-bottom: 30px;
  }
  
  .data-table {
    overflow-x: auto;
  }
  
  .data-table table {
    width: 100%;
    border-collapse: collapse;
    min-width: 800px;
  }
  
  .data-table th,
  .data-table td {
    padding: 12px;
    text-align: left;
    border-bottom: 1px solid #ddd;
  }
  
  .data-table th {
    background: #f8f9fa;
    font-weight: bold;
  }
  
  .data-table tr:hover {
    background: #f5f5f5;
  }
  
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