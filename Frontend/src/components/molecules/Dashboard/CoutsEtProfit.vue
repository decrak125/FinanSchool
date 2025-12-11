<script setup>
import { ref, onMounted, computed, defineProps, watch } from 'vue'; // Ajouter watch
import { useComparaison } from '@/composables/useComparaison';
import CoutProfitChart from '@/components/atoms/Chart/CoutProfitChart.vue';
import Texte from '@/components/atoms/Texte.vue';
import InterpretationCardCoutProfit from '@/components/atoms/Chart/InterpretationCardCoutProfit.vue';
import FilterSelect from '@/components/atoms/Filter-select.vue';

const props = defineProps({
  annee: {
    type: String,
    default: () => new Date().getFullYear().toString()
  }
});

const chartData = ref([]);
const loading = ref(false);
const error = ref('');
const typedata = ref([]);

const filters = ref({
  annee: props.annee,
  mois: '',
  id_type: '',
  limit: 1000,
  offset: 0
});




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

const fetchData = async () => {
  loading.value = true;
  error.value = '';
  
  try {
    // Utiliser filters.value qui contient maintenant la nouvelle année
    const data = await useComparaison.getComparaisonCoutProfit(filters.value);
    chartData.value = data;
    console.log('Données coûts vs profits reçues pour l\'année:', filters.value.annee, data);
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
  // AJOUTER CE WATCH POUR SURVEILLER LES CHANGEMENTS DE LA PROP ANNEE
// watch(() => props.annee, (newYear) => {
//   console.log('Année reçue du parent:', newYear);
//   filters.value.annee = newYear;
//   fetchData();
// },{ immediate: true });
  
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
  </div>
</template>

<style lang="scss" scoped>
.comparaison-cout-profit {
  width: 100%;
  margin: 0 auto;
}
.chart-container {
  border-radius: 8px;
  display: flex;
  gap: 20px;
}
</style>