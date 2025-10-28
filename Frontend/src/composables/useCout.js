import { ref, computed, watch } from "vue";
import axios from "axios";

const API_URL = "http://127.0.0.1:8000/api";

export function useCout(type) {
  const exercice = ref(null);
  const exercicesList = ref([]); // 📌 Nouveau: liste de tous les exercices
  const loading = ref(false);
  const idType = ref(type);
  
  // 📌 Filtres avec dates basées sur l'exercice
  const filters = ref({
    dateStart: "",
    dateEnd: "",
    idCentre: "",
    idType: type,
    searchCentre: "",
    searchAffectation: "",
    idExercice: "" // 📌 Nouveau: filtre par exercice
  });

  const centresList = ref([]);
  const centres = ref([]);
  const affectations = ref([]);
  const sousComptesVentiles = ref([]);
  const verificationVentilations = ref([]);
  const selectedCentre = ref(null);
  const classement = ref([]);

  const fetchClassement = async () => {
    try {
      loading.value = true;
      const response = await axios.get(`${API_URL}/analyse/cout-profit/classementCentre`, {
        params: {
          date_start: formatDateForAPI(filters.value.dateStart),
          date_end: formatDateForAPI(filters.value.dateEnd),
          id_centre: filters.value.idCentre || null,
          id_type: type,
        },
      });
      classement.value = response.data;
    } catch (error) {
      console.error("Erreur fetchClassement:", error);
    } finally {
      loading.value = false;
    }
  };

  // 📌 Fonction pour convertir le format de date
  const formatDateForInput = (dateString) => {
    if (!dateString) return '';
    
    // Si la date est déjà au format YYYY-MM-DD
    if (/^\d{4}-\d{2}-\d{2}$/.test(dateString)) {
      return dateString;
    }
    
    // Si la date est au format avec timezone "2025-07-01T00:00:00.000000Z"
    if (dateString.includes('T')) {
      const date = new Date(dateString);
      return date.toISOString().split('T')[0];
    }
    
    // Pour les autres formats, essayer de parser
    const date = new Date(dateString);
    if (!isNaN(date.getTime())) {
      return date.toISOString().split('T')[0];
    }
    
    console.warn('Format de date non reconnu:', dateString);
    return '';
  };

  // 📌 Récupérer tous les exercices
  const fetchExercicesList = async () => {
    try {
      const response = await axios.get(`${API_URL}/exercices`);
      exercicesList.value = response.data;
      
      // Trier par année décroissante
      exercicesList.value.sort((a, b) => b.Annee_fiscale - a.Annee_fiscale);
      
      return exercicesList.value;
    } catch (error) {
      console.error("Erreur fetchExercicesList:", error);
      return [];
    }
  };

  // 📌 Récupérer l'exercice et mettre à jour les dates
  const fetchExercice = async (idExercice = null) => {
    try {
      loading.value = true;
      
      let response;
      if (idExercice) {
        // Récupérer un exercice spécifique
        response = await axios.get(`${API_URL}/exercices/${idExercice}`);
      } else {
        // Récupérer l'exercice ouvert par défaut
        response = await axios.get(`${API_URL}/exercices/ouvert`);
      }
      
      exercice.value = response.data;
      
      // Mettre à jour les dates des filtres avec le format correct pour les inputs
      if (exercice.value) {
        filters.value.dateStart = formatDateForInput(exercice.value.Date_debut);
        filters.value.dateEnd = formatDateForInput(exercice.value.Date_fin);
        filters.value.idExercice = exercice.value.Id_Exercice_comptable;
        
        console.log('Exercice chargé:', {
          id: exercice.value.Id_Exercice_comptable,
          annee: exercice.value.Annee_fiscale,
          dates: `${filters.value.dateStart} à ${filters.value.dateEnd}`
        });
      }
      
      return exercice.value;
    } catch (error) {
      console.error("Erreur fetchExercice:", error);
      // Dates par défaut si l'exercice n'est pas trouvé
      const currentYear = new Date().getFullYear();
      filters.value.dateStart = `${currentYear}-01-01`;
      filters.value.dateEnd = `${currentYear}-12-31`;
      filters.value.idExercice = "";
      return null;
    } finally {
      loading.value = false;
    }
  };

  // 📌 Changer d'exercice
  const changeExercice = async (idExercice) => {
    try {
      if (!idExercice) {
        // Si aucun exercice sélectionné, charger l'exercice ouvert
        await fetchExercice();
      } else {
        // Charger l'exercice spécifique
        await fetchExercice(idExercice);
      }
      
      // Recharger toutes les données avec le nouvel exercice
      await fetchCentres();
      await fetchVerificationVentilations();
      
      // Réinitialiser les données de détail
      selectedCentre.value = null;
      affectations.value = [];
      sousComptesVentiles.value = [];
      
    } catch (error) {
      console.error("Erreur changeExercice:", error);
    }
  };

  // 📌 Fonction pour formater les dates pour l'API (si nécessaire)
  const formatDateForAPI = (dateString) => {
    if (!dateString) return '';
    return dateString;
  };

  // 📌 API Centres List
  const fetchCentresList = async () => {
    try {
      const resCentres = await axios.get(`${API_URL}/centres`);
      centresList.value = resCentres.data;
    } catch (error) {
      console.error("Erreur fetchCentresList:", error);
    }
  };

  // 📌 Analyse principale par centre avec ventilation
  const fetchCentres = async () => {
    try {
      loading.value = true;
      
      // S'assurer que l'exercice est chargé
      if (!exercice.value) {
        await fetchExercice();
      }
      
      const response = await axios.get(`${API_URL}/analyse/cout-profit`, {
        params: {
          date_start: formatDateForAPI(filters.value.dateStart),
          date_end: formatDateForAPI(filters.value.dateEnd),
          id_centre: filters.value.idCentre || null,
          id_type: idType.value,
        },
      });
      centres.value = response.data;
    } catch (error) {
      console.error("Erreur fetchCentres:", error);
    } finally {
      loading.value = false;
    }
  };

  // 📌 Détails par affectation avec ventilation
  const fetchAffectations = async (centre) => {
    try {
      loading.value = true;
      selectedCentre.value = centre.centre;
      
      const response = await axios.get(`${API_URL}/analyse/affectation`, {
        params: {
          date_start: formatDateForAPI(filters.value.dateStart),
          date_end: formatDateForAPI(filters.value.dateEnd),
          id_centre: centre.id_centre,
          id_type: idType.value,
        },
      });
      affectations.value = response.data;
    } catch (error) {
      console.error("Erreur fetchAffectations:", error);
    } finally {
      loading.value = false;
    }
  };

  // 📌 Analyse détaillée par sous-compte avec ventilation
  const fetchSousComptesVentiles = async (centre = null) => {
    try {
      loading.value = true;
      
      const response = await axios.get(`${API_URL}/analyse/sous-compte-ventilation`, {
        params: {
          date_start: formatDateForAPI(filters.value.dateStart),
          date_end: formatDateForAPI(filters.value.dateEnd),
          id_centre: centre ? centre.id_centre : (filters.value.idCentre || null),
          id_type: idType.value,
        },
      });
      sousComptesVentiles.value = response.data;
    } catch (error) {
      console.error("Erreur fetchSousComptesVentiles:", error);
    } finally {
      loading.value = false;
    }
  };

  // 📌 Vérification de la cohérence des ventilations
  const fetchVerificationVentilations = async () => {
    try {
      loading.value = true;
      
      const response = await axios.get(`${API_URL}/analyse/verification-ventilations`, {
        params: {
          date_start: formatDateForAPI(filters.value.dateStart),
          date_end: formatDateForAPI(filters.value.dateEnd),
        },
      });
      verificationVentilations.value = response.data;
    } catch (error) {
      console.error("Erreur fetchVerificationVentilations:", error);
    } finally {
      loading.value = false;
    }
  };

  // 📌 Chargement initial avec exercice
  const initializeData = async () => {
    try {
      loading.value = true;
      await fetchExercicesList(); // 📌 Charger la liste des exercices
      await fetchExercice(); // Charge l'exercice ouvert et met à jour les dates
      await fetchCentresList();
      await fetchCentres();
      await fetchVerificationVentilations();
      await fetchClassement();
    } catch (error) {
      console.error("Erreur initializeData:", error);
    } finally {
      loading.value = false;
    }
  };

  // 🔥 WATCH POUR RECHARGER AUTOMATIQUEMENT LES DONNÉES
  watch(
    () => [filters.value.dateStart, filters.value.dateEnd, filters.value.idCentre],
    async () => {
      if (filters.value.dateStart && filters.value.dateEnd) {
        await fetchCentres();
        await fetchVerificationVentilations();
        await fetchClassement();
      }
    },
    { immediate: false }
  );

  // 🔥 COMPUTED POUR LES FILTRES EN TEMPS RÉEL
  const centresFiltres = computed(() => {
    if (!centres.value.length) return [];
    
    if (!filters.value.searchCentre) return centres.value;
    
    const searchTerm = filters.value.searchCentre.toLowerCase();
    return centres.value.filter(centre => 
      centre.centre.toLowerCase().includes(searchTerm) ||
      centre.montant_ventile.toString().includes(searchTerm) ||
      centre.montant_brut.toString().includes(searchTerm)
    );
  });

  const classementFiltrees = computed(() => {
    if (!classement.value.length) return [];
    
    if (!filters.value.searchClassement) return classement.value;
    
    const searchTerm = filters.value.searchClassement.toLowerCase();
    return classement.value.filter(classement => 
      classement.centre_nom.toLowerCase().includes(searchTerm) ||
      classement.montant_ventile.toString().includes(searchTerm) ||
      classement.montant_brut.toString().includes(searchTerm)
    );
  });

  const affectationsFiltrees = computed(() => {
    if (!affectations.value.length) return [];
    
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

  // 🔥 RÉINITIALISATION AVEC EXERCICE COURANT
  const resetFilters = async () => {
    try {
      // Recharger l'exercice pour réinitialiser aux dates de l'exercice courant
      await fetchExercice();
      
      // Réinitialiser les autres filtres
      filters.value.idCentre = "";
      filters.value.searchCentre = "";
      filters.value.searchAffectation = "";
      
      // Recharger les données
      await fetchCentres();
      await fetchVerificationVentilations();
      
      // Réinitialiser les données de détail
      selectedCentre.value = null;
      affectations.value = [];
      sousComptesVentiles.value = [];
    } catch (error) {
      console.error("Erreur resetFilters:", error);
    }
  };

  // 🔥 STATS GLOBALES
  const statsGlobales = computed(() => {
    if (!centresFiltres.value.length) return null;
    
    const totalMontantVentile = centresFiltres.value.reduce((sum, centre) => 
      sum + Number(centre.montant_ventile || 0), 0
    );
    const totalMontantBrut = centresFiltres.value.reduce((sum, centre) => 
      sum + Number(centre.montant_brut || 0), 0
    );

    return {
      totalMontantVentile,
      totalMontantBrut,
      difference: totalMontantBrut - totalMontantVentile,
      nombreCentres: centresFiltres.value.length,
      nombreAffectations: affectations.value.length,
      exercice: exercice.value,
      periode: `${filters.value.dateStart} à ${filters.value.dateEnd}`
    };
  });

  // 🔥 INFORMATIONS SUR L'EXERCICE
  const infoExercice = computed(() => {
    if (!exercice.value) return null;
    
    return {
      id: exercice.value.Id_Exercice_comptable,
      code: exercice.value.Code_exercice,
      annee: exercice.value.Annee_fiscale,
      dateDebut: exercice.value.Date_debut,
      dateFin: exercice.value.Date_fin,
      dateDebutFormatted: filters.value.dateStart,
      dateFinFormatted: filters.value.dateEnd,
      statut: exercice.value.Statut_exercice
    };
  });

  // 🔥 LISTE DES EXERCICES FORMATÉE POUR LE SELECT
  const exercicesOptions = computed(() => {
    return exercicesList.value.map(exo => ({
      value: exo.Id_Exercice_comptable,
      label: `Exercice ${exo.Annee_fiscale}`,
      annee: exo.Annee_fiscale,
      statut: exo.Statut_exercice,
      dates: `${formatDateForInput(exo.Date_debut)} - ${formatDateForInput(exo.Date_fin)}`
    }));
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
    // Données
    exercice,
    exercicesList,
    filters,
    centresList,
    centres,
    affectations,
    sousComptesVentiles,
    verificationVentilations,
    selectedCentre,
    loading,

    // Computed
    statsGlobales,
    infoExercice,
    centresFiltres,
    affectationsFiltrees,
    exercicesOptions,
    classement,
    classementFiltrees,
    // API
    fetchCentresList,
    fetchCentres,
    fetchAffectations,
    fetchClassement,
    fetchSousComptesVentiles,
    fetchVerificationVentilations,

    // 🔥 NOUVELLES FONCTIONS
    initializeData,
    changeExercice,
    resetFilters,
    fetchExercicesList,
    formatDateForInput,
    formatDateForAPI,

    // Utils
    formatMontant,
    formatPourcentage,
  };
}