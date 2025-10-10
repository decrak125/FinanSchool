import { ref, computed, watch } from "vue";
import axios from "axios";

const API_URL = "http://127.0.0.1:8000/api";

export function useCout() {
  const currentYear = new Date().getFullYear();

  // 🔥 TOUS LES FILTRES DANS UN SEUL OBJET
  const filters = ref({
    dateStart: `${currentYear}-01-01`,
    dateEnd: `${currentYear}-12-31`,
    idCentre: "",
    idType: 1,
    // 🔥 FILTRES EN TEMPS RÉEL
    searchCentre: "",
    searchAffectation: ""
  });

  const centresList = ref([]);
  const centres = ref([]);
  const affectations = ref([]);
  const sousComptesVentiles = ref([]);
  const verificationVentilations = ref([]);
  const selectedCentre = ref(null);

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
          id_type: filters.value.idType,
        },
      });
      centres.value = response.data;
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

  // 🔥 WATCH POUR RECHARGER AUTOMATIQUEMENT LES DONNÉES
  watch(
    () => [filters.value.dateStart, filters.value.dateEnd, filters.value.idCentre],
    async () => {
      await fetchCentres();
      await fetchVerificationVentilations();
    },
    { immediate: false }
  );

  // 🔥 COMPUTED POUR LES FILTRES EN TEMPS RÉEL
  const centresFiltres = computed(() => {
    if (!filters.value.searchCentre) return centres.value;
    
    const searchTerm = filters.value.searchCentre.toLowerCase();
    return centres.value.filter(centre => 
      centre.centre.toLowerCase().includes(searchTerm) ||
      centre.montant_ventile.toString().includes(searchTerm) ||
      centre.montant_brut.toString().includes(searchTerm)
    );
  });

  const affectationsFiltrees = computed(() => {
    if (!filters.value.searchAffectation) return affectations.value;
    
    const searchTerm = filters.value.searchAffectation.toLowerCase();
    return affectations.value.filter(affectation => 
      (affectation.libelle_sous_compte && affectation.libelle_sous_compte.toLowerCase().includes(searchTerm)) ||
      (affectation.affectation_description && affectation.affectation_description.toLowerCase().includes(searchTerm)) ||
      (affectation.centre_nom && affectation.centre_nom.toLowerCase().includes(searchTerm)) ||
      affectation.montant_ventile.toString().includes(searchTerm) ||
      affectation.montant_brut.toString().includes(searchTerm)
    );
  });

  // 🔥 FONCTION POUR RÉINITIALISER TOUS LES FILTRES
  const resetFilters = () => {
    filters.value = {
      dateStart: `${currentYear}-01-01`,
      dateEnd: `${currentYear}-12-31`,
      idCentre: "",
      idType: 1,
      searchCentre: "",
      searchAffectation: ""
    };
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

  const formatMontant = (val) => {
    return new Intl.NumberFormat("mg-MG", {
      minimumFractionDigits: 0,
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

  return {
    filters,
    centresList,
    centres,
    affectations,
    sousComptesVentiles,
    verificationVentilations,
    selectedCentre,
    statsGlobales,

    // 🔥 COMPUTED FILTRÉS
    centresFiltres,
    affectationsFiltrees,

    // API
    fetchCentresList,
    fetchCentres,
    fetchAffectations,
    fetchSousComptesVentiles,
    fetchVerificationVentilations,

    // 🔥 FONCTION DE RÉINITIALISATION
    resetFilters,

    // utils
    formatMontant,
    formatPourcentage,
  };
}