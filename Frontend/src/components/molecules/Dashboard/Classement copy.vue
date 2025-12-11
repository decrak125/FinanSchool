<script setup>
import { ref, onMounted, computed, defineProps, watch } from "vue";
import { useCout } from "@/composables/useCout";
import Leaderboard from "@/components/atoms/Chart/Leaderboard copy.vue";
import FilterSelect from "@/components/atoms/Filter-select.vue";
import DonutChart from "@/components/atoms/Chart/DonutChart.vue";

// Définir la prop annee
const props = defineProps({
  annee: {
    type: String,
    default: () => new Date().getFullYear().toString()
  }
});

const {
  exercice,
  exercicesList,
  filters,
  centresList,
  centres,
  affectations,
  sousComptesVentiles,
  verificationVentilations,
  selectedCentre,
  loading,
  classement,
  // Computed
  statsGlobales,
  infoExercice,
  centresFiltres,
  affectationsFiltrees,
  classementFiltrees,
  exercicesOptions,

  // API
  fetchCentresList,
  fetchCentres,
  fetchAffectations,
  fetchClassement,
  fetchSousComptesVentiles,

  // 🔥 NOUVELLES FONCTIONS
  initializeData,
  changeExercice,
  resetFilters,
  fetchExercicesList,
  formatDateForInput,

  // Utils
  formatMontant,
  formatPourcentage,

} = useCout(2);

// Fonction pour trouver l'exercice correspondant à l'année
const findExerciseIdByYear = async (year) => {
  try {
    // Récupérer la liste des exercices
    const exercises = await fetchExercicesList();
    
    // Chercher un exercice qui correspond à l'année
    const exerciseForYear = exercises.find(exo => 
      exo.Annee_fiscale === parseInt(year) || 
      exo.Date_debut.startsWith(year)
    );
    
    if (exerciseForYear) {
      return exerciseForYear.Id_Exercice_comptable;
    } else {
      // Si aucun exercice trouvé, essayer avec l'année ouverte
      const openExercise = exercises.find(exo => exo.Statut_exercice === 'ouvert');
      return openExercise ? openExercise.Id_Exercice_comptable : null;
    }
  } catch (error) {
    console.error('Erreur lors de la recherche de l\'exercice:', error);
    return null;
  }
};

// Fonction pour initialiser avec l'année
const initializeWithYear = async (year) => {
  try {
    console.log('Initialisation Classement avec l\'année:', year);
    
    // Trouver l'ID d'exercice correspondant à l'année
    const exerciseId = await findExerciseIdByYear(year);
    
    if (exerciseId) {
      // Charger l'exercice correspondant
      await changeExercice(exerciseId);
    } else {
      console.warn('Aucun exercice trouvé pour l\'année', year);
      // Initialiser avec les données par défaut
      await initializeData();
    }
    
    console.log('Classement initialisé pour l\'année:', year);
  } catch (error) {
    console.error('Erreur lors de l\'initialisation:', error);
  }
};

// Gestion du changement d'exercice via le select (optionnel maintenant)
const handleExerciceChange = async (event) => {
  const idExercice = event.target.value;
  await changeExercice(idExercice);
};

// const selectedCentre = ref('');
const activeTab = ref('centres');
const showGlobalView = ref(true);

// 🔥 MODIFICATION : Utiliser les données filtrées pour les charts
const centresChartData = computed(() => ({
  data: centresFiltres.value.map(c => parseFloat(c.montant_ventile) || 0),
  labels: centresFiltres.value.map(c => c.centre),
  title: 'Répartition des centres'
}));

const affectationsChartData = computed(() => ({
  data: affectationsFiltrees.value.map(a => parseFloat(a.montant_ventile) || 0),
  labels: affectationsFiltrees.value.map(a => a.libelle_sous_compte || a.affectation_description || a.centre),
  title: selectedCentre.value ? `Détails ventilés - ${selectedCentre.value}` : 'Détails des affectations ventilées'
}));

const sousComptesChartData = computed(() => ({
  data: sousComptesVentiles.value.map(sc => parseFloat(sc.montant_ventile) || 0),
  labels: sousComptesVentiles.value.map(sc => sc.libelle_sous_compte),
  title: selectedCentre.value ? `Sous-comptes - ${selectedCentre.value}` : 'Sous-comptes ventilés'
}));

const selectedCentreData = computed(() => {
  if (!selectedCentre.value) return null;
  return centres.value.find(c => c.centre === selectedCentre.value);
});

const selectedCentreStats = computed(() => {
  if (!selectedCentreData.value) return null;

  return {
    montantVentile: selectedCentreData.value.montant_ventile,
    montantBrut: selectedCentreData.value.montant_brut,
    pourcentageVentile: selectedCentreData.value.pourcentage_ventile,
    pourcentageBrut: selectedCentreData.value.pourcentage_brut
  };
});

// Wrapper pour fetchAffectations
const handleFetchAffectations = async (centre) => {
  await fetchAffectations(centre);
  await fetchSousComptesVentiles(centre);
  selectedCentre.value = centre.centre;
  showGlobalView.value = false;
  activeTab.value = 'affectations';
  // 🔥 Réinitialiser le filtre de recherche des affectations
  filters.searchAffectation = "";
};

// Retour à la vue globale
const handleBackToGlobal = () => {
  selectedCentre.value = '';
  showGlobalView.value = true;
  activeTab.value = 'centres';
  // 🔥 Réinitialiser les filtres de recherche
  filters.searchCentre = "";
  filters.searchAffectation = "";
};

// 🔥 CORRECTION : FONCTION POUR RÉINITIALISER TOUT
const handleReset = async () => {
  await resetFilters();
  // S'assurer qu'on revient à la vue globale
  showGlobalView.value = true;
  selectedCentre.value = '';
};

// Chargement initial avec l'année du parent
onMounted(async () => {
  await initializeWithYear(props.annee);
});

// Si vous voulez garder la possibilité de changer l'exercice manuellement, vous pouvez masquer le filtre
// Ou le modifier pour qu'il fonctionne avec l'année
</script>

<template>
  <!-- Option 1: Masquer le filtre d'exercice puisque c'est géré par le parent -->
  <!--
  <FilterSelect v-model="filters.idExercice" @change="handleExerciceChange">
    <option value="">Exercice ouvert (actuel)</option>
    <option v-for="exo in exercicesOptions" :key="exo.value" :value="exo.value"
      :selected="exo.value === filters.idExercice">
      {{ exo.label }}
    </option>
  </FilterSelect>
  -->
  
  <!-- Option 2: Garder le filtre mais l'initialiser avec l'année du parent -->
    <!-- <div class="donut">
    <DonutChart :data="centresChartData.data" :labels="centresChartData.labels"
              :title="centresChartData.title" chart-id="chartCentres" :formatter="formatMontant"
              :separate-legend="true" :legend-height="'500px'" :height="293" />
  </div> -->
    <div class="leaderboard">
      <Leaderboard :depenses="classementFiltrees" :texte="'Top 5 des revenus'" />
    </div>

</template>
<style lang="scss" scoped>
.main {
  @include position-contenus(flex, center, center);
  // justify-content: space-between;
  // align-items: center;
  // gap: 24px;
}
</style>