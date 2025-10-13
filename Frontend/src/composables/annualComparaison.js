import axios from 'axios';
import { ref, computed } from 'vue';

const API_BASE_URL = 'http://localhost:8000/api';

// État global simple
export const globalState = {
  centers: ref([]),
  types: ref([])
};

// Fonctions utilitaires pures (non réactives)
export const formatters = {
  currency: (value) => {
    const numValue = parseFloat(value) || 0;
    return new Intl.NumberFormat('fr-FR', { 
      style: 'currency', 
      currency: 'EUR',
      maximumFractionDigits: 0 
    }).format(numValue);
  },
  
  percentage: (value) => {
    if (value === undefined || value === null || isNaN(value)) {
      return 'N/A';
    }
    if (value === 0) return '→ Stable';
    const sign = value > 0 ? '↗' : '↘';
    return `${sign} ${Math.abs(value).toFixed(1)}%`;
  },
  
  evolutionClass: (value) => {
    if (value === undefined || value === null || isNaN(value)) {
      return 'evolution-stable';
    }
    if (value > 0) return 'evolution-positive';
    if (value < 0) return 'evolution-negative';
    return 'evolution-stable';
  }
};

export const calculations = {
  calculateEvolution: (newValue, oldValue) => {
    if (!oldValue || oldValue === 0) return 0;
    return ((newValue - oldValue) / oldValue) * 100;
  },
  
  calculateProfitCostComparison: (data) => {
    if (!data || !Array.isArray(data)) {
      return {
        totalProfit: 0,
        totalCost: 0,
        netResult: 0,
        profitMargin: 0
      };
    }
    
    const profits = data.filter(item => item.id_type === 2);
    const costs = data.filter(item => item.id_type === 1);
    
    const totalProfit = profits.reduce((sum, item) => sum + (parseFloat(item.montant_brut) || 0), 0);
    const totalCost = costs.reduce((sum, item) => sum + (parseFloat(item.montant_brut) || 0), 0);
    
    return {
      totalProfit,
      totalCost,
      netResult: totalProfit - totalCost,
      profitMargin: totalProfit > 0 ? ((totalProfit - totalCost) / totalProfit) * 100 : 0
    };
  }
};

// Fonctions API
export const apiMethods = {
  async getDonneesComparaisonAnnuelle(filters = {}) {
    try {
      const params = new URLSearchParams();
      if (filters.annee1) params.append('annee1', filters.annee1);
      if (filters.annee2) params.append('annee2', filters.annee2);
      if (filters.id_centre) params.append('id_centre', filters.id_centre);
      if (filters.id_type) params.append('id_type', filters.id_type);
      
      const response = await axios.get(`${API_BASE_URL}/analyse/comparaison-annuelle?${params}`);
      return response.data;
    } catch (error) {
      console.error('Erreur lors de la récupération des données de comparaison:', error);
      throw error;
    }
  },

  async getCentres() {
    try {
      const response = await axios.get(`${API_BASE_URL}/centres`);
      globalState.centers.value = response.data;
      return response.data;
    } catch (error) {
      console.error('Erreur lors de la récupération des centres:', error);
      return [];
    }
  },
  
  async getType() {
    try {
      const response = await axios.get(`${API_BASE_URL}/types`);
      globalState.types.value = response.data;
      return response.data;
    } catch (error) {
      console.error('Erreur lors de la récupération des types:', error);
      return [];
    }
  }
};

// Composables spécifiques
export const useAnnualComparison = () => {
  const chartData = ref([]);
  const loading = ref(false);
  const error = ref('');
  
  const defaultFilters = {
    annee1: (new Date().getFullYear() - 1).toString(),
    annee2: new Date().getFullYear().toString(),
    id_centre: '',
    id_type: ''
  };
  
  const filters = ref({...defaultFilters});

  // Génération des années (simple array, pas computed)
  const getAvailableYears = () => {
    const currentYear = new Date().getFullYear();
    const years = [];
    for (let i = 0; i <= 10; i++) {
      years.push((currentYear - i).toString());
    }
    return years;
  };

  // Computed properties simplifiées
  const comparisonStats = computed(() => {
    if (!chartData.value || chartData.value.length === 0) {
      return {
        annee1: 0,
        annee2: 0,
        evolution: 0,
        profitCostComparison: calculations.calculateProfitCostComparison([])
      };
    }

    const annee1Data = chartData.value.filter(item => item.annee === filters.value.annee1);
    const annee2Data = chartData.value.filter(item => item.annee === filters.value.annee2);
    
    const annee1Total = annee1Data.reduce((sum, item) => sum + (parseFloat(item.montant_brut) || 0), 0);
    const annee2Total = annee2Data.reduce((sum, item) => sum + (parseFloat(item.montant_brut) || 0), 0);
    
    const evolution = calculations.calculateEvolution(annee2Total, annee1Total);
    
    return {
      annee1: annee1Total,
      annee2: annee2Total,
      evolution,
      profitCostComparison: calculations.calculateProfitCostComparison(chartData.value)
    };
  });

  const centresUniques = computed(() => {
    if (!chartData.value || chartData.value.length === 0) return [];
    return [...new Set(chartData.value.map(item => item.centre))];
  });

  // Méthodes
  const fetchData = async () => {
    loading.value = true;
    error.value = '';
    
    try {
      const data = await apiMethods.getDonneesComparaisonAnnuelle(filters.value);
      chartData.value = data;
      console.log('Données de comparaison reçues:', data);
    } catch (err) {
      error.value = 'Erreur lors du chargement des données';
      console.error('Erreur détaillée:', err);
    } finally {
      loading.value = false;
    }
  };

  const resetFilters = () => {
    filters.value = {...defaultFilters};
  };

  return {
    // State
    chartData,
    loading,
    error,
    filters,
    
    // Computed
    comparisonStats,
    centresUniques,
    
    // Methods
    fetchData,
    resetFilters,
    getAvailableYears
  };
};