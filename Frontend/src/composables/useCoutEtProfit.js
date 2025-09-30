import { ref, computed } from "vue";
import axios from "axios";

const API_URL = "http://127.0.0.1:8000/api";

export function useCoutEtProfit() {
  const currentYear = new Date().getFullYear();

  const filters = ref({
    dateStart: `${currentYear}-01-01`,
    dateEnd: `${currentYear}-12-31`,
    idCentre: "",
  });

  const centresList = ref([]);
  const centres = ref([]);
  const affectations = ref([]);
  const selectedCentre = ref(null);

  // 🔎 recherche centre
  const searchTerm = ref("");
  const showSuggestions = ref(false);

  const suggestions = computed(() => {
    if (!centresList.value) return [];
    if (!searchTerm.value) return centresList.value; // 👉 tout afficher
    return centresList.value.filter((c) =>
      c.nom.toLowerCase().includes(searchTerm.value.toLowerCase())
    );
  });
  

  const searchCentre = () => {
  showSuggestions.value = suggestions.value.length > 0;
};


  const selectCentre = (centre) => {
    filters.value.idCentre = centre.id_centre; // applique le filtre
    searchTerm.value = centre.nom; // affiche le nom
    showSuggestions.value = false;
  };

  const clearCentre = () => {
    filters.value.idCentre = "";
    searchTerm.value = "";
    showSuggestions.value = false;
    fetchCentres();  // recharge tout
  };

  // 📌 API
  const fetchCentresList = async () => {
    const resCentres = await axios.get(`${API_URL}/centres`);
    centresList.value = resCentres.data;
  };

  const fetchCentres = async () => {
    try {
      await fetchCentresList();
      const response = await axios.get(`${API_URL}/cout-et-profit`, {
        params: {
          date_start: filters.value.dateStart,
          date_end: filters.value.dateEnd,
          id_centre: filters.value.idCentre || null,
        },
      });
      centres.value = response.data;
      affectations.value = [];
      selectedCentre.value = null;
    } catch (error) {
      console.error(error);
    }
  };

  const fetchAffectations = async (centre) => {
    try {
      selectedCentre.value = centre.centre;
      const response = await axios.get(`${API_URL}/detail-affectation`, {
        params: {
          date_start: filters.value.dateStart,
          date_end: filters.value.dateEnd,
          id_centre: centre.id_centre,
        },
      });
      affectations.value = response.data;
    } catch (error) {
      console.error(error);
    }
  };

  const formatMontant = (val) => {
    return new Intl.NumberFormat("mg-MG", {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
    }).format(val);
  };
  

  return {
    filters,
    centresList,
    centres,
    affectations,
    selectedCentre,

    // API
    fetchCentresList,
    fetchCentres,
    fetchAffectations,

    // utils
    formatMontant,

    // recherche
    searchTerm,
    showSuggestions,
    suggestions,
    searchCentre,
    selectCentre,
    clearCentre,
  };
}
