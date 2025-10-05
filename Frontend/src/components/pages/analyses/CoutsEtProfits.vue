<script setup>
  import { ref, onMounted } from "vue";
  import { useCoutEtProfit } from "@/composables/useCoutEtProfit";
  import PageAnalyse from '@/components/template/Page-analyse.vue';
  const {
        centresList, filters, centres, affectations,
        fetchCentresList, fetchCentres, fetchAffectations,
        formatMontant
    } = useCoutEtProfit();

  onMounted(fetchCentres);
  </script>
  
  <style scoped>
  table {
    border-collapse: collapse;
  }
  </style>


  <template>
    <PageAnalyse>
      <div class="main">
      <div class="p-6">
        <!-- Filtres -->
        <div class="flex gap-4 mb-6">
          <div>
            <label>Date début :</label>
            <input type="date" v-model="filters.dateStart" class="border rounded p-1" />
          </div>
          <div>
            <label>Date fin :</label>
            <input type="date" v-model="filters.dateEnd" class="border rounded p-1" />
          </div>
          <div>
            <label>Centre :</label>
            <select v-model="filters.idCentre" class="border rounded p-1">
              <option value="">Tous</option>
              <option v-for="centre in centresList" :key="centre.id_centre" :value="centre.id_centre">
                {{ centre.nom }}
              </option>
            </select>
          </div>
          <button @click="fetchCentres" class="bg-blue-500 text-white px-4 py-1 rounded">
            Rechercher
          </button>
        </div>
    
        <!-- Tableau global des centres -->
        <h2 class="text-xl font-bold mb-3">Coûts par centre</h2>
        <table class="w-full border">
          <thead class="bg-gray-200">
            <tr>
              <th class="border p-2">Centre</th>
              <th class="border p-2">Montant</th>
              <th class="border p-2">Pourcentage</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="centre in centres"
              :key="centre.id_centre"
              class="cursor-pointer hover:bg-gray-100"
              @click="fetchAffectations(centre)"
            >
              <td class="border p-2">{{ centre.centre }}</td>
              <td class="border p-2">{{ formatMontant(centre.montant) }}</td>
              <td class="border p-2">{{ centre.pourcentage }} %</td>
            </tr>
          </tbody>
        </table>
    
        <!-- Détails d'un centre -->
        <div v-if="affectations.length > 0" class="mt-8">
          <h2 class="text-xl font-bold mb-3">
            Détails du centre : {{ selectedCentre }}
          </h2>
          <table class="w-full border">
            <thead class="bg-gray-200">
              <tr>
                <th class="border p-2">Affectation</th>
                <th class="border p-2">Montant</th>
                <th class="border p-2">Pourcentage</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="a in affectations" :key="a.centre">
                <td class="border p-2">{{ a.centre }}</td>
                <td class="border p-2">{{ formatMontant(a.montant) }}</td>
                <td class="border p-2">{{ a.pourcentage }} %</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      </div>
    </PageAnalyse>
  </template>
  <style lang="scss" scoped>
  .main {
    @include position-contenus(flex, flex-start, center);
  }
  </style>
  
  