<script setup>
import { ref, onMounted, computed } from "vue";
import { useCout } from "@/composables/useCout";
import PageAnalyse from '@/components/template/Page-analyse.vue';
import DonutChart from "@/components/atoms/Chart/DonutChart.vue";
import ContentHeader from "@/components/molecules/Analyse/Content-header.vue";
import Card from "@/components/atoms/Chart/Card.vue";
import Texte from "@/components/atoms/Texte.vue";
import BoutonIcon from "@/components/atoms/Bouton-icon.vue";
import searchbar from "@/components/atoms/searchbar.vue";
import FilterInput from "@/components/atoms/Filter-input.vue";
import FilterSelect from "@/components/atoms/Filter-select.vue";
import Leaderboard from "@/components/atoms/Chart/Leaderboard.vue";

const {
  filters,
  selectedCentre,
  centresFiltres,
  exercicesOptions,

  // API
  fetchCentres,
  fetchVerificationVentilations,

  // 🔥 NOUVELLES FONCTIONS
  initializeData,
  changeExercice,
  resetFilters,

  // Utils
  formatMontant,

} = useCout(1);

// Gestion du changement d'exercice
const handleExerciceChange = async (event) => {
  const idExercice = event.target.value;
  await changeExercice(idExercice);
};

const activeTab = ref('centres');
const showGlobalView = ref(true);

// 🔥 MODIFICATION : Utiliser les données filtrées pour les charts
const centresChartData = computed(() => ({
  data: centresFiltres.value.map(c => parseFloat(c.montant_ventile) || 0),
  labels: centresFiltres.value.map(c => c.centre),
  title: 'Répartition des centres'
}));


// Retour à la vue globale
const handleBackToGlobal = () => {
  selectedCentre.value = '';
  showGlobalView.value = true;
  activeTab.value = 'centres';
  // 🔥 Réinitialiser les filtres de recherche
  filters.searchCentre = "";
};

// 🔥 CORRECTION : FONCTION POUR RÉINITIALISER TOUT
const handleReset = async () => {
  await resetFilters();
  // S'assurer qu'on revient à la vue globale
  showGlobalView.value = true;
  selectedCentre.value = '';
};

// Charger toutes les données au montage
const loadAllData = async () => {
  await fetchCentres();
  await fetchVerificationVentilations();
};

onMounted(async () => {
  await initializeData();
});
</script>
<template>
    <div class="main">
      <!-- Bouton retour vers la vue globale -->

      <!-- 🔥 FILTRES PRINCIPAUX (DATES ET CENTRES) - DYNAMIQUES -->
      <!-- <div class="filtres">
        <BoutonIcon v-if="!showGlobalView" @click="handleBackToGlobal" icon-name="arrow-left" :type="'cancel-stroke'"
          :texte="'Retour à la vue globale'" />
        <Texte :type="'thin-dark'" :texte="'Du'" />
        <div>

          <FilterInput type="date" v-model="filters.dateStart" />
        </div>
        <Texte :type="'thin-dark'" :texte="'au'" />
        <div>
          <FilterInput type="date" v-model="filters.dateEnd" />
        </div>
        <FilterSelect v-if="showGlobalView" v-model="filters.idExercice" @change="handleExerciceChange">
          <option value="">Actuel</option>
          <option v-for="exo in exercicesOptions" :key="exo.value" :value="exo.value"
            :selected="exo.value === filters.idExercice">
            {{ exo.label }}
          </option>
        </FilterSelect>

        <div v-if="!showGlobalView" class="filtre-affectation mb-4">
          <div class="relative">
            <searchbar v-model="filters.searchAffectation" type="text"
              placeholder="Rechercher une affectation, montant..." />
            <div class="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400">
            </div>
          </div>
        </div>
      </div> -->


      <!-- Le reste du template reste identique -->
      <!-- ... -->
      <!-- Statistiques globales -->
            <div class="donuts">
              <!-- Vue Globale : Donut de tous les centres -->
              <div class="chart-container">
                <DonutChart :data="centresChartData.data" :labels="centresChartData.labels"
                  :title="centresChartData.title" chart-id="chartCentres" :formatter="formatMontant"
                  :separate-legend="true" :legend-height="'500px'" :height="293" />
              </div>
            </div>
          </div>
</template>


<style lang="scss" scoped>
html,
body {
  height: 100%;
  margin: 0;
}
.milieu{
  display: flex;
  // flex-direction: column;
  gap: 24px;
}
.table-div {
  width: 100%;
  height: 100%;
  @include glass();
  border-radius: $radius-pm;
  padding: 18px;
  gap: 8px;
}

.table-title {
  padding: 12px
}

.content {
  @include position-contenus(flex, flex-start, flex-start);
  // overflow-y: auto;
  width: 100%;
  height: 100%;
  // max-height: 60vh;
  border-radius: $radius-pm;
  align-self: stretch;
  gap: 24px;

  // @media (max-width: $mobile) {
  //   max-height: 50vh;
  // }
}


// .content::-webkit-scrollbar {
//   width: 10px;
// }

// .content::-webkit-scrollbar-track {
//   background: $light;
//   border-radius: 10px;
// }

// .content::-webkit-scrollbar-thumb {
//   background: $gris;
//   border-radius: 10px;
// }

// .content::-webkit-scrollbar-thumb:hover {
//   background: $light;
// }

.graphic {
  @include position-contenus(flex, flex-start, flex-start);
  padding: 18px 0;
  align-self: stretch;
  gap: 24px;
}

.cartes {
  @include position-contenus(grid, center, center);
  padding: 0;
  gap: 24px;
}

.hauteur {
  @include position-contenus(flex, center, center);
  padding: 0;
  gap: 24px;
}

.gauche {
  @include position-contenus(grid, center, center);
  gap: 9px;
}

.droite {
  padding: 10px 0;
  height: 100%;
  @include position-contenus(flex, center, center);
  gap: 24px;

  @media (max-width: $tablet) {
    grid-template-columns: repeat(2, 1fr);
  }

  @media (max-width: $mobile) {
    grid-template-columns: 1fr;
    gap: 8px;
  }
}

#axesTable {
  @include table();
  // @include glass();
  border-radius: $radius-pm;
}

.chart-container {
  width: fit-content;
  height: fit-content;
}

.chart-container :deep(.apexcharts-pie-series) path {
  transition: all 0.3s ease;
  transform-origin: center;
}

.chart-container :deep(.apexcharts-pie-series):hover path {
  transform: scale(1.02);
  filter: brightness(1.3);
}

.chart-container :deep(.apexcharts-donut-series) path,
.chart-container :deep(.apexcharts-pie-series) path {
  transition: transform 0.3s ease, filter 0.3s ease;
}

.main {
  @include position-contenus(flex, center, center);
  padding: 0 18px;
  flex-direction: column;
  gap: 10px;
  flex: 1 0 0;
  align-self: stretch;
  animation: appear 0.6s ease-out forwards;
}

.informations {
  @include position-contenus(flex, center, center);
  padding: 10px 0;
  align-self: stretch;
  border-bottom: 1px solid #C5C5C5;
  gap: 10px;
}

.filtres {
  @include position-contenus(flex, flex-start, center);
  padding: 0 0;
  align-self: self-start;
  gap: 10px;
}

.donuts {
  @include position-contenus(flex, flex-start, flex-start);
  gap: 32px;
}

.back-button {
  margin-top: 20px;
}

.info-lalina {
  align-self: baseline;
  @include position-contenus(flex, center, center);
  gap: 16px;
}

.filtres {
  @include position-contenus(flex, flex-start, center);
  padding: 0 0;
  align-self: self-start;
  gap: 10px;
}
</style>