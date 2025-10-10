<script setup>
import { ref, onMounted, computed, watch } from "vue";
import { useCoutEtProfit } from "@/composables/useCout";
import PageAnalyse from '@/components/template/Page-analyse.vue';
import DonutChart from "@/components/atoms/Chart/DonutChart.vue";
import ContentHeader from "@/components/molecules/Analyse/Content-header.vue";

const {
  centresList, filters, centres, affectations, sousComptesVentiles, verificationVentilations,
  fetchCentresList, fetchCentres, fetchAffectations, fetchSousComptesVentiles, fetchVerificationVentilations,
  formatMontant, formatPourcentage, calculerMontantVentile, statsGlobales, ventilationsIncompletes
} = useCoutEtProfit();

const selectedCentre = ref('');
const activeTab = ref('centres');

// Données calculées pour les charts
const centresChartData = computed(() => ({
  data: centres.value.map(c => parseFloat(c.montant_ventile) || 0),
  labels: centres.value.map(c => c.centre),
  title: 'Coûts ventilés par centres'
}));

const affectationsChartData = computed(() => ({
  data: affectations.value.map(a => parseFloat(a.montant_ventile) || 0),
  labels: affectations.value.map(a => a.affectation_description || a.centre),
  title: selectedCentre.value ? `Détails ventilés - ${selectedCentre.value}` : 'Détails des affectations ventilées'
}));

const sousComptesChartData = computed(() => ({
  data: sousComptesVentiles.value.map(sc => parseFloat(sc.montant_ventile) || 0),
  labels: sousComptesVentiles.value.map(sc => sc.libelle_sous_compte),
  title: selectedCentre.value ? `Sous-comptes - ${selectedCentre.value}` : 'Sous-comptes ventilés'
}));

// Wrapper pour fetchAffectations
const handleFetchAffectations = async (centre) => {
  await fetchAffectations(centre);
  await fetchSousComptesVentiles(centre);
  selectedCentre.value = centre.centre;
  activeTab.value = 'affectations';
};

// Charger toutes les données
const loadAllData = async () => {
  await fetchCentres();
  await fetchVerificationVentilations();
};

onMounted(async () => {
  await loadAllData();
});</script>

<template>
  <PageAnalyse>
    <div class="main">
      <div class="p-6 w-full">
        <!-- Filtres -->
        <!-- <div class="flex gap-4 mb-6 flex-wrap">
          <div>
            <label class="block mb-1">Date début :</label>
            <input type="date" v-model="filters.dateStart" class="border rounded p-1" />
          </div>
          <div>
            <label class="block mb-1">Date fin :</label>
            <input type="date" v-model="filters.dateEnd" class="border rounded p-1" />
          </div>
          <div>
          <div class="self-end">
            <button @click="loadAllData()" class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600">
              Rechercher
            </button>
          </div>
        </div> -->

        <!-- Statistiques globales -->
        <!-- <div v-if="statsGlobales" class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
          <div class="bg-blue-50 p-4 rounded-lg border border-blue-200">
            <div class="text-blue-600 font-bold text-lg">{{ formatMontant(statsGlobales.totalMontantVentile) }}</div>
            <div class="text-sm text-blue-800">Total ventilé</div>
          </div>
          <div class="bg-gray-50 p-4 rounded-lg border border-gray-200">
            <div class="text-gray-600 font-bold text-lg">{{ formatMontant(statsGlobales.totalMontantBrut) }}</div>
            <div class="text-sm text-gray-800">Total brut</div>
          </div>
          <div class="bg-amber-50 p-4 rounded-lg border border-amber-200">
            <div class="text-amber-600 font-bold text-lg">{{ formatMontant(statsGlobales.difference) }}</div>
            <div class="text-sm text-amber-800">Différence</div>
          </div>
          <div class="bg-green-50 p-4 rounded-lg border border-green-200">
            <div class="text-green-600 font-bold text-lg">{{ statsGlobales.nombreCentres }}</div>
            <div class="text-sm text-green-800">Centres actifs</div>
          </div>
        </div> -->

        <!-- Navigation par onglets -->
        <div class="mb-6 border-b">
          <nav class="flex space-x-8">
            <button
              @click="activeTab = 'centres'"
              :class="[
                'py-2 px-1 border-b-2 font-medium text-sm',
                activeTab === 'centres'
                  ? 'border-blue-500 text-blue-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
              ]"
            >
              Vue par Centres
            </button>
            <button
              @click="activeTab = 'affectations'"
              :class="[
                'py-2 px-1 border-b-2 font-medium text-sm',
                activeTab === 'affectations'
                  ? 'border-blue-500 text-blue-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
              ]"
              :disabled="!selectedCentre"
            >
              Détails Affectations
            </button>
            <button
              @click="activeTab = 'sous-comptes'"
              :class="[
                'py-2 px-1 border-b-2 font-medium text-sm',
                activeTab === 'sous-comptes'
                  ? 'border-blue-500 text-blue-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
              ]"
              :disabled="!selectedCentre"
            >
              Sous-comptes Ventilés
            </button>
            <button
              @click="activeTab = 'verification'"
              :class="[
                'py-2 px-1 border-b-2 font-medium text-sm',
                activeTab === 'verification'
                  ? 'border-blue-500 text-blue-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
              ]"
            >
              Vérification
              <span v-if="ventilationsIncompletes.length > 0" class="ml-1 bg-red-100 text-red-800 text-xs px-2 py-1 rounded-full">
                {{ ventilationsIncompletes.length }}
              </span>
            </button>
          </nav>
        </div>
        <!-- Tableau global des centres (Onglet Centres) -->
        <div v-if="activeTab === 'centres'" class="mb-8">
          <h2 class="text-xl font-bold mb-3">Coûts ventilés par centre</h2>
          <table class="table" id="axesTable">
            <thead class="">
              <tr>
                <th class="col">Centre</th>
                <th class="col">Montant Ventilé</th>
                <th class="col">Montant Brut</th>
                <th class="col">% Ventilé</th>
                <th class="col">% Brut</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="centre in centres"
                :key="centre.id_centre"
                class="cursor-pointer hover:bg-gray-100"
                @click="handleFetchAffectations(centre)"
              >
                <td class="col">{{ centre.centre }}</td>
                <td class="col">{{ formatMontant(centre.montant_ventile) }}</td>
                <td class="col">{{ formatMontant(centre.montant_brut) }}</td>
                <td class="col" :class="formatPourcentage(centre.pourcentage_ventile).classe">
                  {{ formatPourcentage(centre.pourcentage_ventile).valeur }}
                </td>
                <td class="col">{{ centre.pourcentage_brut }}%</td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Détails des affectations (Onglet Affectations) -->
        <div v-if="activeTab === 'affectations' && affectations.length > 0" class="mt-8">
          <h2 class="text-xl font-bold mb-3">
            Détails ventilés du centre : {{ selectedCentre }}
          </h2>
          <table class="table" id="axesTable">
            <thead class="bg-gray-200">
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
              <tr v-for="a in affectations" :key="a.affectation_description">
                <td class="col">{{ a.affectation_description || 'N/A' }}</td>
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

        <!-- Sous-comptes ventilés (Onglet Sous-comptes) -->
        <div v-if="activeTab === 'sous-comptes' && sousComptesVentiles.length > 0" class="mt-8">
          <h2 class="text-xl font-bold mb-3">
            Sous-comptes ventilés du centre : {{ selectedCentre }}
          </h2>
          <table class="table" id="axesTable">
            <thead class="">
              <tr>
                <th class="col">Code</th>
                <th class="col">Libellé</th>
                <th class="col">Taux Ventilation</th>
                <th class="col">Montant Ventilé</th>
                <th class="col">Montant Total</th>
                <th class="col">% Effectif</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="sc in sousComptesVentiles" :key="sc.Code_sous_compte">
                <td class="col">{{ sc.Code_sous_compte }}</td>
                <td class="col">{{ sc.libelle_sous_compte }}</td>
                <td class="col">{{ sc.taux_ventilation }}%</td>
                <td class="col">{{ formatMontant(sc.montant_ventile) }}</td>
                <td class="col">{{ formatMontant(sc.montant_total_sous_compte) }}</td>
                <td class="col" :class="formatPourcentage(sc.pourcentage_effectif).classe">
                  {{ formatPourcentage(sc.pourcentage_effectif).valeur }}
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Vérification des ventilations (Onglet Vérification) -->
        <div v-if="activeTab === 'verification'" class="mt-8">
          <h2 class="text-xl font-bold mb-3">Vérification des ventilations</h2>
          
          <div v-if="ventilationsIncompletes.length > 0" class="mb-6 p-4 bg-red-50 border border-red-200 rounded-lg">
            <h3 class="text-lg font-semibold text-red-800 mb-2">
              ⚠️ {{ ventilationsIncompletes.length }} ventilation(s) incomplète(s)
            </h3>
            <p class="text-red-700">
              Certains sous-comptes n'ont pas une ventilation totale de 100%
            </p>
          </div>

          <table class="table" id="axesTable">
            <thead class="">
              <tr>
                <th class="col">Code Sous-compte</th>
                <th class="col">Libellé</th>
                <th class="col">Total Taux</th>
                <th class="col">Nombre Ventilations</th>
                <th class="col">Statut</th>
              </tr>
            </thead>
            <tbody>
              <tr 
                v-for="v in verificationVentilations" 
                :key="v.Code_sous_compte"
                :class="v.ventilation_complete ? 'bg-green-50' : 'bg-red-50'"
              >
                <td class="col">{{ v.Code_sous_compte }}</td>
                <td class="col">{{ v.Libelle }}</td>
                <td class="col">{{ v.total_taux_ventilation }}%</td>
                <td class="col">{{ v.nombre_ventilations }}</td>
                <td class="col">
                  <span 
                    :class="v.ventilation_complete ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'"
                    class="px-2 py-1 rounded-full text-xs font-medium"
                  >
                    {{ v.ventilation_complete ? '✓ Complète' : '✗ Incomplète' }}
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
            <!-- Section Graphiques pour l'onglet Centres -->
        <div v-if="activeTab === 'centres'" class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
          <!-- Camembert des centres ventilés -->
          <div class="chart-container">
            <DonutChart
              :data="centresChartData.data"
              :labels="centresChartData.labels"
              :title="centresChartData.title"
              chart-id="chartCentres"
              :formatter="formatMontant"
              :separate-legend="true"
              :legend-height="'500px'"
              :height="350"
            />
          </div>

          <!-- Camembert des affectations -->
          <div class="chart-container" v-if="affectations.length > 0">
            <DonutChart
              :data="affectationsChartData.data"
              :labels="affectationsChartData.labels"
              :title="affectationsChartData.title"
              chart-id="chartAffectations"
              :formatter="formatMontant"
              :separate-legend="true"
              :legend-height="'500px'"
              :height="350"
            />
          </div>

        </div>

        <!-- Section Graphiques pour l'onglet Sous-comptes -->
        <div v-if="activeTab === 'sous-comptes' && sousComptesVentiles.length > 0" class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
          <div class="chart-container">
            <apexchart
              type="pie"
              height="350"
              :options="sousComptesChartData"
              :series="seriesSousComptes"
              id="chartSousComptes"
            ></apexchart>
            
          </div>
          <div class="border-gray-200 flex items-center justify-center">
            <div class="text-center text-gray-500">
              <p class="text-lg">📊</p>
              <p>Répartition des sous-comptes ventilés</p>
            </div>
          </div>
        </div>

  </PageAnalyse>
</template>

<style lang="scss" scoped>
#axesTable {
  @include table(#f5f5f5);
}

.chart-container{
  width: fit-content;
  height: fit-content;
}
/* Styles pour l'effet de zoom au hover */
.chart-container :deep(.apexcharts-pie-series) path {
  transition: all 0.3s ease;
  transform-origin: center;
}

.chart-container :deep(.apexcharts-pie-series):hover path {
  transform: scale(1.02);
  filter: brightness(1.3);

}

/* Animation smooth pour les charts */
.chart-container :deep(.apexcharts-donut-series) path,
.chart-container :deep(.apexcharts-pie-series) path {
  transition: transform 0.3s ease, filter 0.3s ease;
}
</style>

<style lang="scss" scoped>
.main {
  @include position-contenus(flex, flex-start, center);
}

</style>