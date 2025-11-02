import { ref, computed, watch } from "vue";
import axios from "axios";

const API_URL = "http://127.0.0.1:8000/api";

export function useCout(type) {
  const exercice = ref(null);
  const exercicesList = ref([]);
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
    idExercice: "",
    idCode: "" // ← NOUVEAU : filtre par code analytique
  });

  const centresList = ref([]);
  const codesAnalytiques = ref([]);
  const centres = ref([]);
  const centresFiltresParCode = ref([]); // ← NOUVEAU : centres filtrés par code
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
          id_code: filters.value.idCode || null,
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
    
    if (/^\d{4}-\d{2}-\d{2}$/.test(dateString)) {
      return dateString;
    }
    
    if (dateString.includes('T')) {
      const date = new Date(dateString);
      return date.toISOString().split('T')[0];
    }
    
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
      exercicesList.value.sort((a, b) => b.Annee_fiscale - a.Annee_fiscale);
      return exercicesList.value;
    } catch (error) {
      console.error("Erreur fetchExercicesList:", error);
      return [];
    }
  };

  // 📌 Récupérer tous les codes analytiques
  const fetchCodesAnalytiques = async () => {
    try {
      const response = await axios.get(`${API_URL}/codes`);
      codesAnalytiques.value = response.data;
      return codesAnalytiques.value;
    } catch (error) {
      console.error("Erreur fetchCodesAnalytiques:", error);
      return [];
    }
  };

  // 📌 Récupérer l'exercice et mettre à jour les dates
  const fetchExercice = async (idExercice = null) => {
    try {
      loading.value = true;
      
      let response;
      if (idExercice) {
        response = await axios.get(`${API_URL}/exercices/${idExercice}`);
      } else {
        response = await axios.get(`${API_URL}/exercices/ouvert`);
      }
      
      exercice.value = response.data;
      
      if (exercice.value) {
        filters.value.dateStart = formatDateForInput(exercice.value.Date_debut);
        filters.value.dateEnd = formatDateForInput(exercice.value.Date_fin);
        filters.value.idExercice = exercice.value.Id_Exercice_comptable;
      }
      
      return exercice.value;
    } catch (error) {
      console.error("Erreur fetchExercice:", error);
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
        await fetchExercice();
      } else {
        await fetchExercice(idExercice);
      }
      
      await fetchCentres();
      await fetchVerificationVentilations();
      
      selectedCentre.value = null;
      affectations.value = [];
      sousComptesVentiles.value = [];
      
    } catch (error) {
      console.error("Erreur changeExercice:", error);
    }
  };

  // 📌 Fonction pour formater les dates pour l'API
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

  // 📌 NOUVELLE FONCTION : Filtrer les centres par code analytique
  const filterCentresByCode = async () => {
    try {
      loading.value = true;
      
      if (!filters.value.idCode) {
        // Si aucun code sélectionné, utiliser les centres normaux
        centresFiltresParCode.value = centres.value;
        return;
      }

      // Récupérer les affectations filtrées par code
      const response = await axios.get(`${API_URL}/analyse/affectation`, {
        params: {
          date_start: formatDateForAPI(filters.value.dateStart),
          date_end: formatDateForAPI(filters.value.dateEnd),
          id_type: idType.value,
          id_code: filters.value.idCode,
        },
      });

      // Regrouper les affectations par centre
      const affectationsFiltrees = response.data;
      const centresGroupes = {};

      affectationsFiltrees.forEach(aff => {
        const centreId = aff.id_centre;
        if (!centresGroupes[centreId]) {
          centresGroupes[centreId] = {
            id_centre: centreId,
            centre: aff.centre_nom,
            montant_ventile: 0,
            montant_brut: parseFloat(aff.montant_brut || 0), // Prendre le montant brut de la première affectation
            pourcentage_ventile: 0,
            affectations_count: 0
          };
        }
        
        centresGroupes[centreId].montant_ventile += parseFloat(aff.montant_ventile || 0);
        centresGroupes[centreId].affectations_count += 1;
      });

      // Calculer les pourcentages
      Object.values(centresGroupes).forEach(centre => {
        if (centre.montant_brut > 0) {
          centre.pourcentage_ventile = (centre.montant_ventile / centre.montant_brut) * 100;
        } else {
          centre.pourcentage_ventile = 0;
        }
      });

      centresFiltresParCode.value = Object.values(centresGroupes);
      
      console.log('Centres filtrés par code:', centresFiltresParCode.value);
      
    } catch (error) {
      console.error("Erreur filterCentresByCode:", error);
      centresFiltresParCode.value = [];
    } finally {
      loading.value = false;
    }
  };

  // 📌 Analyse principale par centre avec ventilation
  const fetchCentres = async () => {
    try {
      loading.value = true;
      
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
      
      // Appliquer le filtre par code si nécessaire
      if (filters.value.idCode) {
        await filterCentresByCode();
      } else {
        centresFiltresParCode.value = centres.value;
      }
      
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
          id_code: filters.value.idCode || null,
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
          id_code: filters.value.idCode || null,
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
          id_code: filters.value.idCode || null,
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
      await fetchExercicesList();
      await fetchCodesAnalytiques();
      await fetchExercice();
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

  // 🔥 NOUVEAU WATCH : Recharger quand le code change
  watch(
    () => filters.value.idCode,
    async (newCode, oldCode) => {
      if (filters.value.dateStart && filters.value.dateEnd) {
        if (newCode) {
          await filterCentresByCode();
        } else {
          centresFiltresParCode.value = centres.value;
        }
        await fetchVerificationVentilations();
        await fetchClassement();
      }
    },
    { immediate: false }
  );

  // 🔥 COMPUTED POUR LES FILTRES EN TEMPS RÉEL
  const centresFiltres = computed(() => {
    const centresSource = filters.value.idCode ? centresFiltresParCode.value : centres.value;
    
    if (!centresSource.length) return [];
    
    if (!filters.value.searchCentre) return centresSource;
    
    const searchTerm = filters.value.searchCentre.toLowerCase();
    return centresSource.filter(centre => 
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
      affectation.montant_brut.toString().includes(searchTerm) || 
      affectation.code.toLowerCase().includes(searchTerm)
    );
  });

  // 🔥 COMPUTED POUR LES OPTIONS DES CODES ANALYTIQUES
  const codesAnalytiquesOptions = computed(() => {
    return codesAnalytiques.value.map(code => ({
      value: code.id_code,
      label: `${code.code} - ${code.libelle}`,
      code: code.code,
      libelle: code.libelle
    }));
  });

  // 🔥 RÉINITIALISATION AVEC EXERCICE COURANT
  const resetFilters = async () => {
    try {
      await fetchExercice();
      
      filters.value.idCentre = "";
      filters.value.idCode = "";
      filters.value.searchCentre = "";
      filters.value.searchAffectation = "";
      
      await fetchCentres();
      await fetchVerificationVentilations();
      
      selectedCentre.value = null;
      affectations.value = [];
      sousComptesVentiles.value = [];
    } catch (error) {
      console.error("Erreur resetFilters:", error);
    }
  };

  // 🔥 STATS GLOBALES
  const statsGlobales = computed(() => {
    const centresSource = filters.value.idCode ? centresFiltresParCode.value : centres.value;
    
    if (!centresSource.length) return null;
    
    const totalMontantVentile = centresSource.reduce((sum, centre) => 
      sum + Number(centre.montant_ventile || 0), 0
    );
    const totalMontantBrut = centresSource.reduce((sum, centre) => 
      sum + Number(centre.montant_brut || 0), 0
    );

    return {
      totalMontantVentile,
      totalMontantBrut,
      difference: totalMontantBrut - totalMontantVentile,
      nombreCentres: centresSource.length,
      nombreAffectations: affectations.value.length,
      exercice: exercice.value,
      periode: `${filters.value.dateStart} à ${filters.value.dateEnd}`,
      codeAnalytique: filters.value.idCode ? codesAnalytiques.value.find(c => c.id_code == filters.value.idCode)?.libelle : null
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
    codesAnalytiques,
    centres,
    centresFiltresParCode,
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
    codesAnalytiquesOptions,
    classement,
    classementFiltrees,
    
    // API
    fetchCentresList,
    fetchCentres,
    fetchAffectations,
    fetchClassement,
    fetchSousComptesVentiles,
    fetchVerificationVentilations,
    filterCentresByCode,

    // 🔥 NOUVELLES FONCTIONS
    initializeData,
    changeExercice,
    resetFilters,
    fetchExercicesList,
    fetchCodesAnalytiques,
    formatDateForInput,
    formatDateForAPI,

    // Utils
    formatMontant,
    formatPourcentage,
  };
}