<script setup>
import { ref, onMounted, computed } from 'vue';
import { useComparaison } from '@/composables/useComparaison';
import AnnualChart from '@/components/atoms/Chart/AnnualChart.vue';

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
  return new Intl.NumberFormat('fr-FR', { 
    style: 'currency', 
    currency: 'EUR' 
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
      <h2>Comparaison Annuelle</h2>
      
      <div class="filters">
        <div class="filter-group">
          <label for="annee1">Année 1:</label>
          <select id="annee1" v-model="filters.annee1" @change="fetchData">
            <option v-for="year in availableYears" :key="`a1-${year}`" :value="year">
              {{ year }}
            </option>
          </select>
        </div>

        <div class="filter-group">
          <label for="annee2">Année 2:</label>
          <select id="annee2" v-model="filters.annee2" @change="fetchData">
            <option v-for="year in availableYears" :key="`a2-${year}`" :value="year">
              {{ year }}
            </option>
          </select>
        </div>

        <div class="filter-group">
          <label for="centre">Centre:</label>
          <select id="centre" v-model="filters.id_centre" @change="fetchData">
            <option value="">Tous les centres</option>
            <option v-for="centre in centerdata" :key="centre.id_centre" :value="centre.id_centre">
              {{ centre.nom }}
            </option>
          </select>
        </div>

        <div class="filter-group">
          <label for="type">Type:</label>
          <select id="type" v-model="filters.id_type" @change="fetchData">
            <option v-for="type in typedata" :key="type.id_type" :value="type.id_type">
              {{ type.code }}
            </option>
          </select>
        </div>

        <button @click="fetchData" :disabled="loading" class="refresh-btn">
          {{ loading ? 'Chargement...' : 'Actualiser' }}
        </button>
      </div>
    </div>

    <!-- Statistiques de comparaison -->
    <div class="stats-container" v-if="chartData.length > 0">
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
    </div>

    <div class="chart-container">
      <AnnualChart 
        :chartData="chartData"
        :loading="loading"
        :error="error"
        :annee1="filters.annee1"
        :annee2="filters.annee2"
      />
    </div>

    <!-- Tableau de données -->
    <div class="data-table" v-if="chartData.length > 0">
      <h3>Données détaillées de comparaison</h3>
      <table>
        <thead>
          <tr>
            <th>Centre</th>
            <th>Année</th>
            <th>Montant Ventilé</th>
            <th>Montant Brut</th>
            <th>Nombre Sous-comptes</th>
            <th>Évolution</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="item in chartData" :key="`${item.centre}-${item.annee}`">
            <td>{{ item.centre }}</td>
            <td>{{ item.annee }}</td>
            <td>{{ formatMontant(item.montant_ventile) }}</td>
            <td>{{ formatMontant(item.montant_brut) }}</td>
            <td>{{ item.nombre_sous_comptes }}</td>
            <td>
              <!-- CORRECTION : Passer l'évolution calculée ou 0 si non définie -->
              <span class="evolution-badge" :class="getEvolutionClass(item.evolution || 0)">
                {{ formatEvolution(item.evolution || 0) }}
              </span>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<!-- Le reste du style reste inchangé -->
<style scoped>
.comparaison-annuelle {
  padding: 20px;
  max-width: 1400px;
  margin: 0 auto;
}

.filters-container {
  background: #f5f5f5;
  padding: 20px;
  border-radius: 8px;
  margin-bottom: 30px;
}

.filters {
  display: flex;
  gap: 20px;
  align-items: end;
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

.stat-label {
  font-size: 14px;
  color: #666;
  margin-top: 5px;
}

.chart-container {
  background: white;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  margin-bottom: 30px;
}

.data-table {
  background: white;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
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