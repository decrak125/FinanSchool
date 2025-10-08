<script setup>
import { ref, onMounted, computed, watch } from "vue";
import { useCoutEtProfit } from "@/composables/useCoutEtProfit";
import PageAnalyse from '@/components/template/Page-analyse.vue';

const {
  centresList, filters, centres, affectations, sousComptesVentiles, verificationVentilations,
  fetchCentresList, fetchCentres, fetchAffectations, fetchSousComptesVentiles, fetchVerificationVentilations,
  formatMontant, formatPourcentage, calculerMontantVentile, statsGlobales, ventilationsIncompletes
} = useCoutEtProfit();

const selectedCentre = ref('');
const activeTab = ref('centres'); // 'centres', 'affectations', 'sous-comptes', 'verification'

// Données pour les camemberts - ADAPTÉ AVEC VENTILATION
const chartOptionsCentres = ref({
  chart: {
    type: 'pie',
    width: '100%',
    height: 350
  },
  labels: [],
  legend: {
    position: 'bottom'
  },
  responsive: [{
    breakpoint: 480,
    options: {
      chart: {
        width: 300
      },
      legend: {
        position: 'bottom'
      }
    }
  }],
  title: {
    text: 'Répartition des coûts ventilés par centre',
    align: 'center',
    style: {
      fontSize: '16px',
      fontWeight: 'bold'
    }
  }
});

const seriesCentres = ref([]);

const chartOptionsAffectations = ref({
  chart: {
    type: 'pie',
    width: '100%',
    height: 350
  },
  labels: [],
  legend: {
    position: 'bottom'
  },
  responsive: [{
    breakpoint: 480,
    options: {
      chart: {
        width: 300
      },
      legend: {
        position: 'bottom'
      }
    }
  }],
  title: {
    text: 'Détails des affectations ventilées',
    align: 'center',
    style: {
      fontSize: '16px',
      fontWeight: 'bold'
    }
  }
});

const seriesAffectations = ref([]);

// Mettre à jour le camembert des centres avec données ventilées
const updateCentresChart = () => {
  if (centres.value && centres.value.length > 0) {
    console.log('Mise à jour chart centres ventilés:', centres.value);
    chartOptionsCentres.value.labels = centres.value.map(c => c.centre);
    seriesCentres.value = centres.value.map(c => parseFloat(c.montant_ventile) || 0);
  } else {
    console.log('Aucune donnée centres');
    chartOptionsCentres.value.labels = ['Aucune donnée'];
    seriesCentres.value = [1];
  }
};

// Mettre à jour le camembert des affectations avec données ventilées
const updateAffectationsChart = (centre) => {
  selectedCentre.value = centre.centre;
  if (affectations.value && affectations.value.length > 0) {
    console.log('Mise à jour chart affectations ventilées:', affectations.value);
    chartOptionsAffectations.value.labels = affectations.value.map(a => a.affectation_description || a.centre);
    seriesAffectations.value = affectations.value.map(a => parseFloat(a.montant_ventile) || 0);
    chartOptionsAffectations.value.title.text = `Détails ventilés - ${centre.centre}`;
  } else {
    console.log('Aucune donnée affectations');
    chartOptionsAffectations.value.labels = ['Aucune donnée'];
    seriesAffectations.value = [1];
  }
};

// Wrapper pour fetchAffectations
const handleFetchAffectations = async (centre) => {
  await fetchAffectations(centre);
  await fetchSousComptesVentiles(centre);
  updateAffectationsChart(centre);
  activeTab.value = 'affectations';
};

// Charger toutes les données
const loadAllData = async () => {
  await fetchCentres();
  await fetchVerificationVentilations();
  updateCentresChart();
};

// Watch pour mettre à jour automatiquement le graphique centres
watch(centres, () => {
  updateCentresChart();
}, { deep: true });

// Watch pour mettre à jour automatiquement le graphique affectations
watch(affectations, () => {
  if (selectedCentre.value) {
    const centre = centres.value.find(c => c.centre === selectedCentre.value);
    if (centre) {
      updateAffectationsChart(centre);
    }
  }
}, { deep: true });

onMounted(async () => {
  await loadAllData();
});
</script>

<template>
  <PageAnalyse>
    <div class="main">
      <div class="p-6 w-full">
        <!-- Filtres -->
        <div class="flex gap-4 mb-6 flex-wrap">
          <div>
            <label class="block mb-1">Date début :</label>
            <input type="date" v-model="filters.dateStart" class="border rounded p-1" />
          </div>
          <div>
            <label class="block mb-1">Date fin :</label>
            <input type="date" v-model="filters.dateEnd" class="border rounded p-1" />
          </div>
          <div>
            <label class="block mb-1">Centre :</label>
            <select v-model="filters.idCentre" class="border rounded p-1">
              <option value="">Tous</option>
              <option v-for="centre in centresList" :key="centre.id_centre" :value="centre.id_centre">
                {{ centre.nom }}
              </option>
            </select>
          </div>
          <div class="self-end">
            <button @click="loadAllData()" class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600">
              Rechercher
            </button>
          </div>
        </div>

        <!-- Statistiques globales -->
        <div v-if="statsGlobales" class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
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
        </div>

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

        <!-- Section Graphiques -->
        <div v-if="activeTab === 'centres'" class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
          <!-- Camembert des centres ventilés -->
          <div class="bg-white p-4 rounded-lg shadow border">
            <apexchart
              type="pie"
              height="350"
              :options="chartOptionsCentres"
              :series="seriesCentres"
            ></apexchart>
          </div>

          <!-- Camembert des affectations -->
          <div class="bg-white p-4 rounded-lg shadow border" v-if="affectations.length > 0">
            <apexchart
              type="pie"
              height="350"
              :options="chartOptionsAffectations"
              :series="seriesAffectations"
            ></apexchart>
          </div>
          
          <!-- Placeholder quand pas d'affectations -->
          <div class="bg-white p-4 rounded-lg shadow border border-gray-200 flex items-center justify-center" v-else>
            <div class="text-center text-gray-500">
              <p class="text-lg">👆</p>
              <p>Cliquez sur un centre pour voir le détail</p>
            </div>
          </div>
        </div>

        <!-- Tableau global des centres (Onglet Centres) -->
        <div v-if="activeTab === 'centres'" class="mb-8">
          <h2 class="text-xl font-bold mb-3">Coûts ventilés par centre</h2>
          <table class="w-full border">
            <thead class="bg-gray-200">
              <tr>
                <th class="border p-2">Centre</th>
                <th class="border p-2">Montant Ventilé</th>
                <th class="border p-2">Montant Brut</th>
                <th class="border p-2">% Ventilé</th>
                <th class="border p-2">% Brut</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="centre in centres"
                :key="centre.id_centre"
                class="cursor-pointer hover:bg-gray-100"
                @click="handleFetchAffectations(centre)"
              >
                <td class="border p-2">{{ centre.centre }}</td>
                <td class="border p-2">{{ formatMontant(centre.montant_ventile) }}</td>
                <td class="border p-2">{{ formatMontant(centre.montant_brut) }}</td>
                <td class="border p-2" :class="formatPourcentage(centre.pourcentage_ventile).classe">
                  {{ formatPourcentage(centre.pourcentage_ventile).valeur }}
                </td>
                <td class="border p-2">{{ centre.pourcentage_brut }}%</td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Détails des affectations (Onglet Affectations) -->
        <div v-if="activeTab === 'affectations' && affectations.length > 0" class="mt-8">
          <h2 class="text-xl font-bold mb-3">
            Détails ventilés du centre : {{ selectedCentre }}
          </h2>
          <table class="w-full border">
            <thead class="bg-gray-200">
              <tr>
                <th class="border p-2">Description</th>
                <th class="border p-2">Centre</th>
                <th class="border p-2">Taux Ventilation</th>
                <th class="border p-2">Montant Ventilé</th>
                <th class="border p-2">Montant Brut</th>
                <th class="border p-2">% Ventilé</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="a in affectations" :key="a.affectation_description">
                <td class="border p-2">{{ a.affectation_description || 'N/A' }}</td>
                <td class="border p-2">{{ a.centre_nom }}</td>
                <td class="border p-2">{{ a.taux_ventilation }}%</td>
                <td class="border p-2">{{ formatMontant(a.montant_ventile) }}</td>
                <td class="border p-2">{{ formatMontant(a.montant_brut) }}</td>
                <td class="border p-2" :class="formatPourcentage(a.pourcentage_ventile).classe">
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
          <table class="w-full border">
            <thead class="bg-gray-200">
              <tr>
                <th class="border p-2">Code</th>
                <th class="border p-2">Libellé</th>
                <th class="border p-2">Taux Ventilation</th>
                <th class="border p-2">Montant Ventilé</th>
                <th class="border p-2">Montant Total</th>
                <th class="border p-2">% Effectif</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="sc in sousComptesVentiles" :key="sc.Code_sous_compte">
                <td class="border p-2">{{ sc.Code_sous_compte }}</td>
                <td class="border p-2">{{ sc.libelle_sous_compte }}</td>
                <td class="border p-2">{{ sc.taux_ventilation }}%</td>
                <td class="border p-2">{{ formatMontant(sc.montant_ventile) }}</td>
                <td class="border p-2">{{ formatMontant(sc.montant_total_sous_compte) }}</td>
                <td class="border p-2" :class="formatPourcentage(sc.pourcentage_effectif).classe">
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

          <table class="w-full border">
            <thead class="bg-gray-200">
              <tr>
                <th class="border p-2">Code Sous-compte</th>
                <th class="border p-2">Libellé</th>
                <th class="border p-2">Total Taux</th>
                <th class="border p-2">Nombre Ventilations</th>
                <th class="border p-2">Statut</th>
              </tr>
            </thead>
            <tbody>
              <tr 
                v-for="v in verificationVentilations" 
                :key="v.Code_sous_compte"
                :class="v.ventilation_complete ? 'bg-green-50' : 'bg-red-50'"
              >
                <td class="border p-2">{{ v.Code_sous_compte }}</td>
                <td class="border p-2">{{ v.Libelle }}</td>
                <td class="border p-2">{{ v.total_taux_ventilation }}%</td>
                <td class="border p-2">{{ v.nombre_ventilations }}</td>
                <td class="border p-2">
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
  </PageAnalyse>
</template>

<style scoped>
table {
  border-collapse: collapse;
}
</style>

<style lang="scss" scoped>
.main {
  @include position-contenus(flex, flex-start, center);
}
</style>