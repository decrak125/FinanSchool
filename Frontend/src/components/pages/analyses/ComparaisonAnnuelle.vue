<script setup>
import { ref, onMounted, computed } from 'vue';
import { useComparaison } from '@/composables/useComparaison';
import AnnualChart from '@/components/atoms/Chart/AnnualChart.vue';
import Texte from '@/components/atoms/Texte.vue';
import InterpretationCardAnnuelle from '@/components/atoms/Chart/InterpretationCardAnnuelle.vue';
import FilterSelect from '@/components/atoms/Filter-select.vue';

// Réactifs
const chartData = ref([]);
const loading = ref(false);
const error = ref('');
const centerdata = ref([]);
const typedata = ref([]);

const filters = ref({
  annee1: (new Date().getFullYear() - 1).toString(),
  annee2: new Date().getFullYear().toString(),
  id_centre: '',
  id_type: '1'
});

// Génération dynamique des années
const availableYears = computed(() => {
  const currentYear = new Date().getFullYear();
  const years = [];
  for (let i = 0; i <= 10; i++) {
    years.push((currentYear - i).toString());
  }
  return years;
});

// Computed
const totalComparaison = computed(() => {
  const annee1Total = chartData.value
    .filter(item => item.annee === filters.value.annee1)
    .reduce((sum, item) => sum + (parseFloat(item.montant_brut) || 0), 0);
  
  const annee2Total = chartData.value
    .filter(item => item.annee === filters.value.annee2)
    .reduce((sum, item) => sum + (parseFloat(item.montant_brut) || 0), 0);
  
  const evolution = annee1Total > 0 ? ((annee2Total - annee1Total) / annee1Total) * 100 : 0;
  
  return {
    annee1: annee1Total,
    annee2: annee2Total,
    evolution: evolution
  };
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
    const data = await useComparaison.getDonneesComparaisonAnnuelle(filters.value);
    chartData.value = data;
    console.log('Données de comparaison reçues:', data);
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

const formatMontant = (montant) => {
  return new Intl.NumberFormat('mg-MG', {
    // style: 'currency',
    // currency: 'MGA',
    minimumFractionDigits: 0,
    maximumFractionDigits: 0
  }).format(parseFloat(montant) || 0);
};

// CORRECTION : Gestion des valeurs undefined/null
const formatEvolution = (evolution) => {
  // Vérifier si evolution est défini et est un nombre
  if (evolution === undefined || evolution === null || isNaN(evolution)) {
    return 'N/A';
  }
  if (evolution === 0) return 'Stable';
  const sign = evolution > 0 ? '+' : '';
  return `${sign}${parseFloat(evolution).toFixed(1)}%`;
};

const getEvolutionClass = (evolution) => {
  // Vérifier si evolution est défini et est un nombre
  if (evolution === undefined || evolution === null || isNaN(evolution)) {
    return 'evolution-stable';
  }
  if (evolution > 0) return 'evolution-positive';
  if (evolution < 0) return 'evolution-negative';
  return 'evolution-stable';
};
// ------------------------------------

// Computed properties
const uniqueAnnees = computed(() => {
  const annees = [...new Set(chartData.value.map(item => item.annee))];
  return annees.sort((a, b) => b - a); // Tri décroissant pour avoir les années récentes en premier
});

const uniqueCentres = computed(() => {
  const centres = [...new Set(chartData.value.map(item => item.centre))];
  return centres.sort();
});

// Méthodes pour les données par centre et année
const getMontantForCentreAndAnnee = (centre, annee, typeMontant) => {
  const item = chartData.value.find(d => 
    d.centre === centre && d.annee === annee
  );
  if (!item) return '-';
  return typeMontant === 'montant_ventile' 
    ? formatMontant(item.montant_ventile)
    : formatMontant(item.montant_brut);
};

const getSousComptesForCentreAndAnnee = (centre, annee) => {
  const item = chartData.value.find(d => 
    d.centre === centre && d.annee === annee
  );
  return item ? item.nombre_sous_comptes : '-';
};

// Méthodes pour les totaux par année
const getTotalForAnnee = (annee, typeMontant) => {
  const items = chartData.value.filter(d => d.annee === annee);
  const total = items.reduce((sum, item) => 
    sum + (parseFloat(item[typeMontant]) || 0), 0
  );
  return formatMontant(total);
};

const getTotalSousComptesForAnnee = (annee) => {
  const items = chartData.value.filter(d => d.annee === annee);
  const total = items.reduce((sum, item) => 
    sum + (parseInt(item.nombre_sous_comptes) || 0), 0
  );
  return total > 0 ? total : '-';
};

// Méthodes pour l'évolution par centre
const getEvolutionForCentre = (centre) => {
  const annees = uniqueAnnees.value;
  if (annees.length < 2) return 'N/A';
  
  const currentYear = annees[0];
  const previousYear = annees[1];
  
  const currentItem = chartData.value.find(d => d.centre === centre && d.annee === currentYear);
  const previousItem = chartData.value.find(d => d.centre === centre && d.annee === previousYear);
  
  if (!currentItem || !previousItem) return 'N/A';
  
  const currentMontant = parseFloat(currentItem.montant_brut) || 0;
  const previousMontant = parseFloat(previousItem.montant_brut) || 0;
  
  if (previousMontant === 0) return 'N/A';
  
  const evolution = ((currentMontant - previousMontant) / previousMontant) * 100;
  return formatEvolution(evolution);
};

const getEvolutionClassForCentre = (centre) => {
  const evolutionValue = getEvolutionForCentre(centre);
  if (evolutionValue === 'N/A' || evolutionValue === 'Stable') return 'evolution-stable';
  
  const evolution = parseFloat(evolutionValue);
  if (evolution > 0) return 'evolution-positive';
  if (evolution < 0) return 'evolution-negative';
  return 'evolution-stable';
};

// Méthodes pour l'évolution totale
const getEvolutionForTotal = () => {
  const annees = uniqueAnnees.value;
  if (annees.length < 2) return 'N/A';
  
  const currentTotal = getTotalForAnnee(annees[0], 'montant_brut');
  const previousTotal = getTotalForAnnee(annees[1], 'montant_brut');
  
  const current = parseFloat(currentTotal.replace(/[^\d.-]/g, '')) || 0;
  const previous = parseFloat(previousTotal.replace(/[^\d.-]/g, '')) || 0;
  
  if (previous === 0) return 'N/A';
  
  const evolution = ((current - previous) / previous) * 100;
  return formatEvolution(evolution);
};

const getEvolutionClassForTotal = () => {
  const evolutionValue = getEvolutionForTotal();
  if (evolutionValue === 'N/A' || evolutionValue === 'Stable') return 'evolution-stable';
  
  const evolution = parseFloat(evolutionValue);
  if (evolution > 0) return 'evolution-positive';
  if (evolution < 0) return 'evolution-negative';
  return 'evolution-stable';
};
// Computed: Écart entre les deux années (montant et pourcentage)
const ecartAnnuel = computed(() => {
  if (uniqueAnnees.value.length < 2) return null;
  
  const annee1 = uniqueAnnees.value[1]; // Année la plus ancienne
  const annee2 = uniqueAnnees.value[0]; // Année la plus récente
  
  const totalAnnee1 = chartData.value
    .filter(item => item.annee === annee1)
    .reduce((sum, item) => sum + (parseFloat(item.montant_ventile) || parseFloat(item.montant_brut) || 0), 0);
  
  const totalAnnee2 = chartData.value
    .filter(item => item.annee === annee2)
    .reduce((sum, item) => sum + (parseFloat(item.montant_ventile) || parseFloat(item.montant_brut) || 0), 0);
  
  const difference = totalAnnee2 - totalAnnee1;
  const pourcentage = totalAnnee1 !== 0 ? (difference / totalAnnee1) * 100 : 0;
  
  return {
    annee1: annee1,
    annee2: annee2,
    totalAnnee1: totalAnnee1,
    totalAnnee2: totalAnnee2,
    difference: difference,
    pourcentage: pourcentage,
    isPositive: difference >= 0
  };
});

// Computed: Centre avec la plus forte augmentation
const centrePlusForteAugmentation = computed(() => {
  if (uniqueAnnees.value.length < 2 || uniqueCentres.value.length === 0) return null;
  
  const annee1 = uniqueAnnees.value[1];
  const annee2 = uniqueAnnees.value[0];
  
  let maxPourcentage = -Infinity;
  let maxCentre = null;
  let maxDifference = 0;
  let montantAnnee1 = 0;
  let montantAnnee2 = 0;
  
  uniqueCentres.value.forEach(centre => {
    const itemAnnee1 = chartData.value.find(d => d.centre === centre && d.annee === annee1);
    const itemAnnee2 = chartData.value.find(d => d.centre === centre && d.annee === annee2);
    
    if (itemAnnee1 && itemAnnee2) {
      const montant1 = parseFloat(itemAnnee1.montant_ventile) || parseFloat(itemAnnee1.montant_brut) || 0;
      const montant2 = parseFloat(itemAnnee2.montant_ventile) || parseFloat(itemAnnee2.montant_brut) || 0;
      
      if (montant1 > 0) {
        const difference = montant2 - montant1;
        const pourcentage = (difference / montant1) * 100;
        
        if (pourcentage > maxPourcentage) {
          maxPourcentage = pourcentage;
          maxCentre = centre;
          maxDifference = difference;
          montantAnnee1 = montant1;
          montantAnnee2 = montant2;
        }
      }
    }
  });
  
  if (!maxCentre || maxPourcentage <= 0) return null;
  
  return {
    centre: maxCentre,
    pourcentage: maxPourcentage,
    difference: maxDifference,
    montantAnnee1: montantAnnee1,
    montantAnnee2: montantAnnee2,
    annee1: annee1,
    annee2: annee2
  };
});

// Computed: Centre avec la plus forte diminution
const centrePlusForteDiminution = computed(() => {
  if (uniqueAnnees.value.length < 2 || uniqueCentres.value.length === 0) return null;
  
  const annee1 = uniqueAnnees.value[1];
  const annee2 = uniqueAnnees.value[0];
  
  let minPourcentage = Infinity;
  let minCentre = null;
  let minDifference = 0;
  let montantAnnee1 = 0;
  let montantAnnee2 = 0;
  
  uniqueCentres.value.forEach(centre => {
    const itemAnnee1 = chartData.value.find(d => d.centre === centre && d.annee === annee1);
    const itemAnnee2 = chartData.value.find(d => d.centre === centre && d.annee === annee2);
    
    if (itemAnnee1 && itemAnnee2) {
      const montant1 = parseFloat(itemAnnee1.montant_ventile) || parseFloat(itemAnnee1.montant_brut) || 0;
      const montant2 = parseFloat(itemAnnee2.montant_ventile) || parseFloat(itemAnnee2.montant_brut) || 0;
      
      if (montant1 > 0) {
        const difference = montant2 - montant1;
        const pourcentage = (difference / montant1) * 100;
        
        if (pourcentage < minPourcentage) {
          minPourcentage = pourcentage;
          minCentre = centre;
          minDifference = difference;
          montantAnnee1 = montant1;
          montantAnnee2 = montant2;
        }
      }
    }
  });
  
  if (!minCentre || minPourcentage >= 0) return null;
  
  return {
    centre: minCentre,
    pourcentage: minPourcentage,
    difference: minDifference,
    montantAnnee1: montantAnnee1,
    montantAnnee2: montantAnnee2,
    annee1: annee1,
    annee2: annee2
  };
});
// Cycle de vie
onMounted(() => {
  fetchData();
  fetchCentres();
  fetchTypes();
});
</script>

<template>
  <div class="comparaison-annuelle">
    <div class="filters-container">
      <!-- <Texte :type="'bold-dark'" :texte="'Comparaison Annuelle'" /> -->
      
      <div class="filters">
          <Texte :type="'thin-dark'" :texte="'Année 1'" />
          <FilterSelect id="annee1" v-model="filters.annee1" @change="fetchData">
            <option v-for="year in availableYears" :key="`a1-${year}`" :value="year">
              {{ year }}
            </option>
          </FilterSelect>

          <Texte :type="'thin-dark'" :texte="'Année 2'" />
          <FilterSelect id="annee2" v-model="filters.annee2" @change="fetchData">
            <option v-for="year in availableYears" :key="`a2-${year}`" :value="year">
              {{ year }}
            </option>
          </FilterSelect>

          <Texte :type="'thin-dark'" :texte="'Centre'" />
          <FilterSelect id="centre" v-model="filters.id_centre" @change="fetchData">
            <option value="">Tous les centres</option>
            <option v-for="centre in centerdata" :key="centre.id_centre" :value="centre.id_centre">
              {{ centre.nom }}
            </option>
          </FilterSelect>

          <Texte :type="'thin-dark'" :texte="'Type'" />
          <FilterSelect id="type" v-model="filters.id_type" @change="fetchData">
            <option v-for="type in typedata" :key="type.id_type" :value="type.id_type">
              {{ type.code }}
            </option>
          </FilterSelect>

      </div>
    </div>

    <!-- Statistiques de comparaison -->
    <!-- <div class="stats-container" v-if="chartData.length > 0">
      <div class="stat-card comparison-stat">
        <div class="stat-year">{{ filters.annee1 }}</div>
        <div class="stat-value">{{ formatMontant(totalComparaison.annee1) }}</div>
        <div class="stat-label">Total Année 1</div>
      </div>

      <div class="stat-card comparison-stat">
        <div class="stat-year">{{ filters.annee2 }}</div>
        <div class="stat-value">{{ formatMontant(totalComparaison.annee2) }}</div>
        <div class="stat-label">Total Année 2</div>
      </div>

      <div class="stat-card comparison-stat">
        <div class="stat-evolution" :class="getEvolutionClass(totalComparaison.evolution)">
          {{ formatEvolution(totalComparaison.evolution) }}
        </div>
        <div class="stat-label">Évolution</div>
      </div>

      <div class="stat-card">
        <div class="stat-value">{{ centresUniques.length }}</div>
        <div class="stat-label">Centres comparés</div>
      </div>
    </div> -->

    <div class="chart-container">
      <AnnualChart 
        :chartData="chartData"
        :loading="loading"
        :error="error"
        :annee1="filters.annee1"
        :annee2="filters.annee2"
      />
      <InterpretationCardAnnuelle
        v-if="ecartAnnuel"
        :dataComparaison="ecartAnnuel"
        type="ecart-annuel"
        :loading="loading"
        :idType="filters.id_type || 1"
      />
    </div>

    <!-- Tableau de données -->
<div class="data-table" v-if="chartData.length > 0">
  <div class="ok">
    <div class="info">
    <Texte :type="'bold-dark'" :texte="'Comparaison annuelle par centre'" />
    <Texte :type="'dark'" :texte="'Montants en Ariary (Ar).'" />
    </div>
    <div class="iconbtn">
      <i class="bi bi-file-earmark-pdf-fill"></i>
    </div>
  </div>
    <table class="table" id="axesTable">
      <thead>
        <tr>
          <th class="centre-header">Centre</th>
          <th v-for="annee in uniqueAnnees" :key="annee" colspan="3" class="annee-group-header">
            {{ annee }}
          </th>
          <th class="evolution-header" rowspan="2">Évolution</th>
        </tr>
        <tr>
        </tr>
      </thead>
      <tbody>
        <tr v-for="centre in uniqueCentres" :key="centre">
          <td class="centre-name">{{ centre }}</td>
          <td v-for="annee in uniqueAnnees" :key="`${centre}-${annee}`" colspan="3" class="annee-data-group">
            <div class="data-cells">
              <span class="data-cell ventile">{{ getMontantForCentreAndAnnee(centre, annee, 'montant_ventile') }}</span>
            </div>
          </td>
          <td class="evolution-cell">
            <span class="evolution-badge" :class="getEvolutionClassForCentre(centre)">
              {{ getEvolutionForCentre(centre) }}
            </span>
          </td>
        </tr>
        <tr class="total-row">
          <td class="total-label">Total</td>
          <td v-for="annee in uniqueAnnees" :key="`total-${annee}`" colspan="3" class="total-data-group">
            <div class="data-cells">
              <span class="data-cell ventile">{{ getTotalForAnnee(annee, 'montant_ventile') }}</span>
            </div>
          </td>
          <td class="evolution-total">
            <span class="evolution-badge" :class="getEvolutionClassForTotal()">
              {{ getEvolutionForTotal() }}
            </span>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</div>
</template>

<!-- Le reste du style reste inchangé -->
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
.comparaison-annuelle {
  width: 100%;
  margin: 0 auto;
}

.filters-container {
  position: fixed;
  left: 635px;
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
  position: relative;
}

.comparison-stat {
  border-top: 4px solid #017AFF;
}

.stat-year {
  position: absolute;
  top: -10px;
  left: 50%;
  transform: translateX(-50%);
  background: #017AFF;
  color: white;
  padding: 4px 12px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: bold;
}

.stat-value {
  font-size: 24px;
  font-weight: bold;
  color: #007bff;
  margin: 10px 0;
}

.stat-evolution {
  font-size: 20px;
  font-weight: bold;
  margin: 10px 0;
  padding: 8px 16px;
  border-radius: 20px;
}

.evolution-positive {
  background-color: #d1fae5;
  color: #065f46;
}

.evolution-negative {
  background-color: #fee2e2;
  color: #991b1b;
}

.evolution-stable {
  background-color: #f3f4f6;
  color: #374151;
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

.stat-label {
  font-size: 14px;
  color: #666;
  margin-top: 5px;
}

.chart-container {
  width: 100%;
  display: flex;
  gap: 20px;
  margin-bottom: 30px;
}

.data-table {
  padding: 18px;
  gap: 8px;
  @include glass();
  border-radius: $radius-pm;
  overflow-x: auto;
}


.evolution-badge {
  padding: 4px 8px;
  border-radius: 12px;
  font-size: 11px;
  font-weight: 600;
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