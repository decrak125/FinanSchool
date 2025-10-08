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
  const sousComptesVentiles = ref([]);
  const verificationVentilations = ref([]);
  const selectedCentre = ref(null);

  // 🔎 recherche centre
  const searchTerm = ref("");
  const showSuggestions = ref(false);

  const suggestions = computed(() => {
    if (!centresList.value) return [];
    if (!searchTerm.value) return centresList.value;
    return centresList.value.filter((c) =>
      c.nom.toLowerCase().includes(searchTerm.value.toLowerCase())
    );
  });

  const searchCentre = () => {
    showSuggestions.value = suggestions.value.length > 0;
  };

  const selectCentre = (centre) => {
    filters.value.idCentre = centre.id_centre;
    searchTerm.value = centre.nom;
    showSuggestions.value = false;
  };

  const clearCentre = () => {
    filters.value.idCentre = "";
    searchTerm.value = "";
    showSuggestions.value = false;
    fetchCentres();
  };

  // 📌 API
  const fetchCentresList = async () => {
    const resCentres = await axios.get(`${API_URL}/centres`);
    centresList.value = resCentres.data;
  };

  // Analyse principale par centre avec ventilation
  const fetchCentres = async () => {
    try {
      await fetchCentresList();
      const response = await axios.get(`${API_URL}/analyse/cout-profit`, {
        params: {
          date_start: filters.value.dateStart,
          date_end: filters.value.dateEnd,
          id_centre: filters.value.idCentre || null,
        },
      });
      centres.value = response.data;
      affectations.value = [];
      sousComptesVentiles.value = [];
      selectedCentre.value = null;
    } catch (error) {
      console.error("Erreur fetchCentres:", error);
    }
  };

  // Détails par affectation avec ventilation
  const fetchAffectations = async (centre) => {
    try {
      selectedCentre.value = centre.centre;
      const response = await axios.get(`${API_URL}/analyse/affectation`, {
        params: {
          date_start: filters.value.dateStart,
          date_end: filters.value.dateEnd,
          id_centre: centre.id_centre,
        },
      });
      affectations.value = response.data;
    } catch (error) {
      console.error("Erreur fetchAffectations:", error);
    }
  };

  // Analyse détaillée par sous-compte avec ventilation
  const fetchSousComptesVentiles = async (centre = null) => {
    try {
      const response = await axios.get(`${API_URL}/analyse/sous-compte-ventilation`, {
        params: {
          date_start: filters.value.dateStart,
          date_end: filters.value.dateEnd,
          id_centre: centre ? centre.id_centre : (filters.value.idCentre || null),
        },
      });
      sousComptesVentiles.value = response.data;
    } catch (error) {
      console.error("Erreur fetchSousComptesVentiles:", error);
    }
  };

  // Vérification de la cohérence des ventilations
  const fetchVerificationVentilations = async () => {
    try {
      const response = await axios.get(`${API_URL}/analyse/verification-ventilations`, {
        params: {
          date_start: filters.value.dateStart,
          date_end: filters.value.dateEnd,
        },
      });
      verificationVentilations.value = response.data;
    } catch (error) {
      console.error("Erreur fetchVerificationVentilations:", error);
    }
  };

  // Computed pour les statistiques globales
  const statsGlobales = computed(() => {
    if (!centres.value.length) return null;

    const totalMontantVentile = centres.value.reduce((sum, centre) => 
      sum + Number(centre.montant_ventile || 0), 0
    );
    
    const totalMontantBrut = centres.value.reduce((sum, centre) => 
      sum + Number(centre.montant_brut || 0), 0
    );

    return {
      totalMontantVentile,
      totalMontantBrut,
      difference: totalMontantBrut - totalMontantVentile,
      nombreCentres: centres.value.length,
      nombreAffectations: affectations.value.length,
    };
  });

  // Computed pour les ventilations problématiques
  const ventilationsIncompletes = computed(() => {
    return verificationVentilations.value.filter(v => 
      !v.ventilation_complete || v.total_taux_ventilation !== 100
    );
  });

  const formatMontant = (val) => {
    return new Intl.NumberFormat("mg-MG", {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
    }).format(val);
  };

  // Format pourcentage avec couleur selon la valeur
  const formatPourcentage = (val, type = 'ventile') => {
    const valeur = Number(val) || 0;
    let classe = '';
    
    if (type === 'ventile') {
      classe = valeur >= 80 ? 'text-green-600' : 
               valeur >= 50 ? 'text-amber-600' : 
               'text-red-600';
    }
    
    return {
      valeur: `${valeur.toFixed(2)}%`,
      classe
    };
  };

  // Calcul du montant ventilé pour un sous-compte
  const calculerMontantVentile = (montantBrut, tauxVentilation) => {
    return (Number(montantBrut) * (Number(tauxVentilation) / 100)) || 0;
  };

  return {
    filters,
    centresList,
    centres,
    affectations,
    sousComptesVentiles,
    verificationVentilations,
    selectedCentre,
    statsGlobales,
    ventilationsIncompletes,

    // API
    fetchCentresList,
    fetchCentres,
    fetchAffectations,
    fetchSousComptesVentiles,
    fetchVerificationVentilations,

    // utils
    formatMontant,
    formatPourcentage,
    calculerMontantVentile,

    // recherche
    searchTerm,
    showSuggestions,
    suggestions,
    searchCentre,
    selectCentre,
    clearCentre,
  };
}