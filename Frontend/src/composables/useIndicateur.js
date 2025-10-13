import { ref, onMounted, computed } from "vue";
import axios from "axios";
import { forEach } from "lodash";

export function useIndicateur(filters) {
  const API_URL = "http://127.0.0.1:8000/api"; // variable pour l'API
    const general = ref([]);
    const resultat = ref(0);
    const getAnalyseRentabiliteParType = async (filters) => {
        try {
          const params = new URLSearchParams();
          if (filters) params.append('annee', filters.annee);
      
          const response = await axios.get(`${API_URL}/analyse/cout-profit/rentabilite-type?${params}`);
          general.value = response.data;
      
          // Calcul de la somme des solde_net
          resultat.value = general.value.reduce((sum, item) => {
            return sum + parseFloat(item.solde_net || 0);
          }, 0);
      
        } catch (error) {
          console.error("Erreur lors de l'analyse de rentabilité par type:", error);
          throw error;
        }
      };
  // Charger les données au montage
  onMounted(() => {
    getAnalyseRentabiliteParType();
  });

  return {
    general, getAnalyseRentabiliteParType, resultat
  };
}