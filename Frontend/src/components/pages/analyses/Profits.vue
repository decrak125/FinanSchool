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

const {
  centresList, filters, centres, affectations, sousComptesVentiles, verificationVentilations,
  fetchCentresList, fetchCentres, fetchAffectations, fetchSousComptesVentiles, fetchVerificationVentilations,
  formatMontant, formatPourcentage, statsGlobales,
  // 🔥 NOUVEAUX FILTRES
  centresFiltres,
  affectationsFiltrees,
  resetFilters
} = useCout(2);

const selectedCentre = ref('');
const activeTab = ref('centres');
const showGlobalView = ref(true);

// 🔥 MODIFICATION : Utiliser les données filtrées pour les charts
const centresChartData = computed(() => ({
  data: centresFiltres.value.map(c => parseFloat(c.montant_ventile) || 0),
  labels: centresFiltres.value.map(c => c.centre),
  title: 'Coûts ventilés par centres'
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

// Charger toutes les données au montage
const loadAllData = async () => {
  await fetchCentres();
  await fetchVerificationVentilations();
};

onMounted(async () => {
  await loadAllData();
});
</script>
<template>
  <PageAnalyse>
    <div class="main">
      <!-- Bouton retour vers la vue globale -->
      <div v-if="!showGlobalView" class="info-lalina">
        <div class="back-button">
          <BoutonIcon @click="handleBackToGlobal" icon-name="arrow-left" :type="'cancel-stroke'"
            :texte="'Retour à la vue globale'" />
        </div>
        <ContentHeader v-if="!showGlobalView && affectations.length > 0" :menu="selectedCentre"
          :sousmenu="'Répartition des profits'" />
      </div>
      <ContentHeader v-else :menu="'Analyse des profits'" :sousmenu="'Répartition des profits'" />

      <!-- 🔥 FILTRES PRINCIPAUX (DATES ET CENTRES) - DYNAMIQUES -->
      <div class="filtres">
        <label class="block mb-1">Date début :</label>
        <div>

          <FilterInput type="date" v-model="filters.dateStart" />
        </div>
        <label class="block mb-1">Date fin :</label>
        <div>
          <FilterInput type="date" v-model="filters.dateEnd" />
          <!-- <input type="date" v-model="filters.dateEnd" class="border rounded p-1" /> -->
        </div>
        <div v-if="showGlobalView" class="filtre-centre mb-4">
          <div class="relative">
            <searchbar v-model="filters.searchCentre" type="text" placeholder="Rechercher un centre, montant..." />
          </div>
          <!-- <div v-if="filters.searchCentre" class="text-sm text-gray-600 mt-1">
            {{ centresFiltres.length }} centre(s) trouvé(s)
          </div> -->
        </div>

        <!-- Filtre pour les affectations (vue détaillée) -->
        <div v-if="!showGlobalView" class="filtre-affectation mb-4">
          <div class="relative">
            <searchbar v-model="filters.searchAffectation" type="text"
              placeholder="Rechercher une affectation, montant..." />
            <div class="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400">
            </div>
          </div>
          <!-- <div v-if="filters.searchAffectation" class="text-sm text-gray-600 mt-1">
            {{ affectationsFiltrees.length }} affectation(s) trouvée(s)
          </div> -->
        </div>
        <div>
          <BoutonIcon v-if="filters" @click="handleReset" type="cancel" :icon-name="'x-lg'" class="reset-filter-btn" />
        </div>
      </div>


      <!-- Le reste du template reste identique -->
      <!-- ... -->
      <!-- Statistiques globales -->
      <div class="content">
        <div class="gauche">
          <div class="graphic">
            <div class="cartes" v-if="statsGlobales != null">
              <div class="hauteur">
                <Card v-if="showGlobalView" :chiffre="statsGlobales.totalMontantVentile"
                  :texte="'Total des profits ventilés.'" :icon="'bi bi-currency-dollar'" :icon-color="'orange'"
                  :format="'money'" />
                <Card v-else :chiffre="selectedCentreStats?.montantVentile" :texte="`Coût ventilé - ${selectedCentre}`"
                  :icon="'bi bi-currency-dollar'" :icon-color="'orange'" :format="'money'" />

                <Card v-if="showGlobalView" :chiffre="statsGlobales.totalMontantBrut" :texte="'Total brut.'"
                  :icon="'bi bi-cash'" :icon-color="'green'" :format="'money'" />
                <Card v-else :chiffre="selectedCentreStats?.montantBrut" :texte="`Coût brut - ${selectedCentre}`"
                  :icon="'bi bi-cash'" :icon-color="'green'" :format="'money'" />
              </div>
              <div class="hauteur">
                <Card v-if="showGlobalView" :chiffre="statsGlobales.difference" :texte="'Différence.'"
                  :icon="'bi bi-calculator-fill'" :icon-color="'grey'" :format="'money'" />
                <Card v-else :chiffre="selectedCentreStats?.pourcentageVentile" :texte="`% Ventilé - ${selectedCentre}`"
                  :icon="'bi bi-percent'" :icon-color="'blue'" :format="'percentage'" />

                <Card v-if="showGlobalView" :chiffre="statsGlobales.nombreCentres" :texte="'Centres des profits actifs.'"
                  :icon="'bi bi-activity'" :icon-color="'green'" />
                <Card v-else :chiffre="selectedCentreStats?.pourcentageBrut" :texte="`% Brut - ${selectedCentre}`"
                  :icon="'bi bi-percent'" :icon-color="'purple'" :format="'percentage'" />
              </div>
            </div>

            <!-- Section Graphiques -->
            <div class="donuts">
              <!-- Vue Globale : Donut de tous les centres -->
              <div v-if="showGlobalView" class="chart-container">
                <DonutChart :data="centresChartData.data" :labels="centresChartData.labels"
                  :title="centresChartData.title" chart-id="chartCentres" :formatter="formatMontant"
                  :separate-legend="true" :legend-height="'500px'" :height="350" />
              </div>

              <!-- Vue Détail Centre : Donut des affectations du centre sélectionné -->
              <div v-if="!showGlobalView && affectationsFiltrees.length > 0" class="chart-container">
                <DonutChart :data="affectationsChartData.data" :labels="affectationsChartData.labels"
                  :title="affectationsChartData.title" chart-id="chartAffectations" :formatter="formatMontant"
                  :separate-legend="true" :legend-height="'500px'" :height="350" />
              </div>

              <!-- Vue Détail Centre : Donut des sous-comptes du centre sélectionné -->
              <!-- <div v-if="!showGlobalView && sousComptesVentiles.length > 0" class="chart-container">
                <DonutChart :data="sousComptesChartData.data" :labels="sousComptesChartData.labels"
                  :title="sousComptesChartData.title" chart-id="chartSousComptes" :formatter="formatMontant"
                  :separate-legend="true" :legend-height="'500px'" :height="350" type="pie" />
              </div> -->
            </div>
          </div>

          <!-- Tableau global des centres (visible seulement en vue globale) -->
          <div v-if="showGlobalView" class="mb-8">
            <Texte :type="'bold-dark'" :texte="'Coûts ventilés par centre'" />
            <table class="table" id="axesTable">
              <thead class="">
                <tr>
                  <th class="col">Centre</th>
                  <th class="col">Montant Ventilé</th>
                  <th class="col">Montant Brut</th>
                  <th class="col">% Ventilé</th>
                  <th class="col">% Brut</th>
                  <th class="col">Action</th>
                </tr>
              </thead>
              <tbody>
                <!-- 🔥 MODIFICATION : Utiliser centresFiltres au lieu de centres -->
                <tr v-for="centre in centresFiltres" :key="centre.id_centre" class="cursor-pointer hover:bg-gray-100">
                  <td class="col">{{ centre.centre }}</td>
                  <td class="col">{{ formatMontant(centre.montant_ventile) }}</td>
                  <td class="col">{{ formatMontant(centre.montant_brut) }}</td>
                  <td class="col" :class="formatPourcentage(centre.pourcentage_ventile).classe">
                    {{ formatPourcentage(centre.pourcentage_ventile).valeur }}
                  </td>
                  <td class="col">{{ centre.pourcentage_brut }}%</td>
                  <td class="col">
                    <BoutonIcon @click="handleFetchAffectations(centre)" icon-name="eye" :type="'edit'" />
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Détails des affectations (visible seulement en vue détaillée) -->
          <div v-if="!showGlobalView && affectationsFiltrees.length > 0" class="mt-8">
            <Texte :type="'bold-dark'" :texte="`Détails ventilés du centre : ${selectedCentre}`" />
            <table class="table" id="axesTable">
              <thead class="">
                <tr>
                  <th class="col">Description</th>
                  <th class="col">Centre</th>
                  <th class="col">Taux Ventilation</th>
                  <th class="col">Montant Ventilé</th>
                  <th class="col">Montant Brut</th>
                  <th class="col">% Ventilé</th>
                </tr>
              </thead>
              <tbody>
                <!-- 🔥 MODIFICATION : Utiliser affectationsFiltrees au lieu de affectations -->
                <tr v-for="a in affectationsFiltrees" :key="a.affectation_description">
                  <td class="col">{{ a.libelle_sous_compte || 'N/A' }}</td>
                  <td class="col">{{ a.centre_nom }}</td>
                  <td class="col">{{ a.taux_ventilation }}%</td>
                  <td class="col">{{ formatMontant(a.montant_ventile) }}</td>
                  <td class="col">{{ formatMontant(a.montant_brut) }}</td>
                  <td class="col" :class="formatPourcentage(a.pourcentage_ventile).classe">
                    {{ formatPourcentage(a.pourcentage_ventile).valeur }}
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

        </div>
      </div>
    </div>
  </PageAnalyse>
</template>


<style lang="scss" scoped>
.content {
  @include position-contenus(flex, flex-start, flex-start);
  overflow-y: auto;
  width: 100%;
  max-height: 60vh;
  border-radius: $radius-pm;
  align-self: stretch;
}

.content::-webkit-scrollbar {
  width: 10px;
}

.content::-webkit-scrollbar-track {
  background: $light;
  border-radius: 10px;
}

.content::-webkit-scrollbar-thumb {
  background: $gris;
  border-radius: 10px;
}

.content::-webkit-scrollbar-thumb:hover {
  background: $light;
}

.graphic {
  @include position-contenus(flex, flex-start, flex-start);
  padding: 10px 0;
  align-self: stretch;
  gap: 32px;
}

.cartes {
  @include position-contenus(grid, center, center);
  padding: 0;
  gap: 32px;
}

.hauteur {
  @include position-contenus(flex, center, center);
  padding: 0;
  gap: 32px;
}

.gauche {
  @include position-contenus(grid, center, center);
  gap: 10px;
}

#axesTable {
  @include table(#f5f5f5);
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
  padding: 0 32px;
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