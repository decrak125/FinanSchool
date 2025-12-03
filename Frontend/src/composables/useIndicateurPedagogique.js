import { ref, onMounted, computed } from "vue";
import axios from "axios";

export function useIndicateurPedagogique(filters) {
  const API_URL = "http://127.0.0.1:8000/api";
  
  const exercice = ref(null);
  const exercicesList = ref([]);
  const coutFonctionnement = ref(null);
  const chiffreAffaires = ref(null);
  const partMasseSalariale = ref(null);
  const margeParEleve = ref(null);
  const loading = ref(false);
  const loadingTable = ref(false);

  // 📌 NOUVEAU : Données de l'année N-1 (comme useIndicateurGeneral)
  const previousYearData = ref({
    coutFonctionnement: null,
    chiffreAffaires: null,
    partMasseSalariale: null,
    margeParEleve: null
  });

  // 📌 Fonction pour obtenir les dates de l'année précédente (identique à useIndicateurGeneral)
  const getPreviousYearDates = (currentDateStart, currentDateEnd) => {
    // Étape 1 : convertir en date "pure" (sans heures)
    const start = new Date(currentDateStart);
    const end = new Date(currentDateEnd);

    // On force l'heure à 00:00:00 pour éviter tout décalage
    start.setHours(0, 0, 0, 0);
    end.setHours(0, 0, 0, 0);

    // Étape 2 : faire les calculs de l'année précédente
    const previousStart = new Date(start);
    previousStart.setFullYear(previousStart.getFullYear() - 1);

    const previousEnd = new Date(end);
    previousEnd.setFullYear(previousEnd.getFullYear() - 1);

    // Étape 3 : convertir proprement en string locale au format ISO (YYYY-MM-DD)
    const formatDate = (d) => d.toLocaleDateString('fr-CA'); // format sûr

    return {
      dateStart: formatDate(previousStart),
      dateEnd: formatDate(previousEnd)
    };
  };

  // 📌 Récupérer les données de l'année N-1 (simplifié comme useIndicateurGeneral)
  const fetchPreviousYearData = async (currentDateStart, currentDateEnd) => {
    try {
      loadingTable.value = true;
      const previousDates = getPreviousYearDates(currentDateStart, currentDateEnd);
      
      const [coutFct, ca, masseSal, marge] = await Promise.all([
        axios.get(`${API_URL}/analyse/cout-fonctionnement-par-eleve`, {
          params: { 
            date_debut: previousDates.dateStart, 
            date_fin: previousDates.dateEnd
            // effectif_eleves: 228 // À adapter selon votre logique
          }
        }).catch(() => ({ data: null })),
        
        axios.get(`${API_URL}/analyse/chiffre-affaires-par-eleve`, {
          params: { 
            date_debut: previousDates.dateStart, 
            date_fin: previousDates.dateEnd
            // effectif_eleves: 228 // À adapter selon votre logique
          }
        }).catch(() => ({ data: null })),
        
        axios.get(`${API_URL}/analyse/part-masse-salariale-enseignante`, {
          params: { 
            date_debut: previousDates.dateStart, 
            date_fin: previousDates.dateEnd
          }
        }).catch(() => ({ data: null })),
        
        axios.get(`${API_URL}/analyse/marge-par-eleve`, {
          params: { 
            date_debut: previousDates.dateStart, 
            date_fin: previousDates.dateEnd
            // effectif_eleves: 228 // À adapter selon votre logique
          }
        }).catch(() => ({ data: null }))
      ]);

      previousYearData.value = {
        coutFonctionnement: coutFct.data,
        chiffreAffaires: ca.data,
        partMasseSalariale: masseSal.data,
        margeParEleve: marge.data
      };
      
      console.log("Données N-1 pédagogiques:", previousYearData.value);
      loadingTable.value = false;
      return previousYearData.value;
    } catch (error) {
      console.error("Erreur lors de la récupération des données N-1 pédagogiques:", error);
      return null;
    }
  };

  // 📌 Fonction de comparaison entre N et N-1 (identique à useIndicateurGeneral)
  const getComparison = (currentValue, previousValue, type = 'montant') => {
    if (!currentValue || !previousValue) {
      return {
        evolution: null,
        percentage: null,
        trend: 'stable',
        hasData: false
      };
    }

    const current = type === 'pourcentage' ? currentValue : currentValue?.valeur || currentValue;
    const previous = type === 'pourcentage' ? previousValue : previousValue?.valeur || previousValue;

    if (current === null || previous === null || previous === 0) {
      return {
        evolution: null,
        percentage: null,
        trend: 'stable',
        hasData: false
      };
    }

    const evolution = current - previous;
    const percentage = ((evolution / Math.abs(previous)) * 100);
    
    let trend = 'stable';
    if (evolution > 0) trend = 'up';
    if (evolution < 0) trend = 'down';

    return {
      evolution,
      percentage: Math.abs(percentage).toFixed(2),
      trend,
      hasData: true,
      currentValue: current,
      previousValue: previous
    };
  };

  // 📌 Computed pour les comparaisons N vs N-1 (comme useIndicateurGeneral)
  const comparisons = computed(() => {
    return {
      coutFonctionnement: getComparison(
        coutFonctionnement.value?.cout_fonctionnement_par_eleve?.valeur, 
        previousYearData.value.coutFonctionnement?.cout_fonctionnement_par_eleve?.valeur,
        'montant'
      ),
      chiffreAffaires: getComparison(
        chiffreAffaires.value?.chiffre_affaires_par_eleve?.valeur, 
        previousYearData.value.chiffreAffaires?.chiffre_affaires_par_eleve?.valeur,
        'montant'
      ),
      partMasseSalariale: getComparison(
        partMasseSalariale.value?.part_masse_salariale_enseignante?.valeur, 
        previousYearData.value.partMasseSalariale?.part_masse_salariale_enseignante?.valeur,
        'pourcentage'
      ),
      margeParEleve: getComparison(
        margeParEleve.value?.marge_par_eleve?.valeur, 
        previousYearData.value.margeParEleve?.marge_par_eleve?.valeur,
        'montant'
      )
    };
  });

  // 📌 Fonction pour formater le format de date (identique à useIndicateurGeneral)
  const formatDateForInput = (dateString) => {
    if (!dateString) return '';
    if (/^\d{4}-\d{2}-\d{2}$/.test(dateString)) return dateString;
    if (dateString.includes('T')) {
      const date = new Date(dateString);
      return date.toISOString().split('T')[0];
    }
    const date = new Date(dateString);
    if (!isNaN(date.getTime())) return date.toISOString().split('T')[0];
    return '';
  };

  // 📌 Récupérer tous les exercices (identique à useIndicateurGeneral)
  const fetchExercicesList = async () => {
    try {
      const response = await axios.get(`${API_URL}/exercices`);
      
      // Filtrer les exercices avec des dates dans le futur, mais inclure l'exercice sélectionné
      const currentDate = new Date();
      exercicesList.value = response.data.filter(exercice => {
        const dateDebut = new Date(exercice.Date_debut);
        const isSelected = exercice.Id_Exercice_comptable === filters.value.idExercice;
        
        // Inclure l'exercice s'il est terminé, en cours OU s'il est sélectionné
        return dateDebut <= currentDate || isSelected;
      });
      
      exercicesList.value.sort((a, b) => b.Annee_fiscale - a.Annee_fiscale);
      
      console.log('Exercices pédagogiques filtrés:', exercicesList.value);
      return exercicesList.value;
    } catch (error) {
      console.error("Erreur fetchExercicesList:", error);
      return [];
    }
  };

  // 📌 Récupérer l'exercice et mettre à jour les dates (identique à useIndicateurGeneral)
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

  // 📌 Changer d'exercice (identique à useIndicateurGeneral)
  const changeExercice = async (idExercice) => {
    try {
      if (!idExercice) {
        await fetchExercice();
      } else {
        await fetchExercice(idExercice);
      }
      await refreshAllData();
    } catch (error) {
      console.error("Erreur changeExercice:", error);
    }
  };

  // 📌 Récupérer les indicateurs individuels (inchangé)
  const getCoutFonctionnement = async () => {
    try {
      const response = await axios.get(`${API_URL}/analyse/cout-fonctionnement-par-eleve`, {
        params: {
          date_debut: filters.value.dateStart,
          date_fin: filters.value.dateEnd
          // effectif_eleves: 228 // À adapter selon votre logique
        }
      });
      coutFonctionnement.value = response.data;
    } catch (error) {
      console.error("Erreur récupération coût fonctionnement:", error);
      throw error;
    }
  };

  const getChiffreAffaires = async () => {
    try {
      const response = await axios.get(`${API_URL}/analyse/chiffre-affaires-par-eleve`, {
        params: {
          date_debut: filters.value.dateStart,
          date_fin: filters.value.dateEnd
          // effectif_eleves: 228 // À adapter selon votre logique
        }
      });
      chiffreAffaires.value = response.data;
    } catch (error) {
      console.error("Erreur récupération chiffre d'affaires:", error);
      throw error;
    }
  };

  const getPartMasseSalariale = async () => {
    try {
      const response = await axios.get(`${API_URL}/analyse/part-masse-salariale-enseignante`, {
        params: {
          date_debut: filters.value.dateStart,
          date_fin: filters.value.dateEnd
        }
      });
      partMasseSalariale.value = response.data;
    } catch (error) {
      console.error("Erreur récupération part masse salariale:", error);
      throw error;
    }
  };

  const getMargeParEleve = async () => {
    try {
      const response = await axios.get(`${API_URL}/analyse/marge-par-eleve`, {
        params: {
          date_debut: filters.value.dateStart,
          date_fin: filters.value.dateEnd
          // effectif_eleves: 228 // À adapter selon votre logique
        }
      });
      margeParEleve.value = response.data;
    } catch (error) {
      console.error("Erreur récupération marge par élève:", error);
      throw error;
    }
  };

  // 📌 Fonction pour rafraîchir toutes les données (avec N-1)
  const refreshAllData = async () => {
    try {
      loading.value = true;
      loadingTable.value = true;
      await Promise.all([
        getCoutFonctionnement(),
        getChiffreAffaires(),
        getPartMasseSalariale(),
        getMargeParEleve(),
        fetchPreviousYearData(formatDateForInput(filters.value.dateStart), formatDateForInput(filters.value.dateEnd))
      ]);
    } catch (error) {
      console.error("Erreur rafraîchissement données pédagogiques:", error);
    } finally {
      loading.value = false;
      loadingTable.value = false;
    }
  };

  // 📌 Chargement initial avec exercice (identique à useIndicateurGeneral)
  const initializeData = async () => {
    try {
      loading.value = true;
      await fetchExercice();
      await fetchExercicesList();
      await refreshAllData();
    } catch (error) {
      console.error("Erreur initializeData pédagogique:", error);
    } finally {
      loading.value = false;
    }
  };

  // 🔥 INFORMATIONS SUR L'EXERCICE (identique à useIndicateurGeneral)
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

  // 🔥 LISTE DES EXERCICES FORMATÉE POUR LE SELECT (identique à useIndicateurGeneral)
  const exercicesOptions = computed(() => {
    return exercicesList.value.map(exo => ({
      value: exo.Id_Exercice_comptable,
      label: exo.Annee_fiscale,
      annee: exo.Annee_fiscale,
      statut: exo.Statut_exercice,
      dates: `${formatDateForInput(exo.Date_debut)} - ${formatDateForInput(exo.Date_fin)}`
    }));
  });

  return {
    // Données
    exercice,
    exercicesList,
    coutFonctionnement,
    chiffreAffaires,
    partMasseSalariale,
    margeParEleve,
    loading,
    previousYearData, // 📌 NOUVEAU : Données N-1
    loadingTable,
    
    // Computed
    infoExercice,
    exercicesOptions,
    comparisons, // 📌 NOUVEAU : Comparaisons N vs N-1
    
    // Fonctions
    getCoutFonctionnement,
    getChiffreAffaires,
    getPartMasseSalariale,
    getMargeParEleve,
    refreshAllData,
    initializeData,
    changeExercice,
    fetchExercicesList,
    formatDateForInput,
    getComparison, // 📌 NOUVEAU : Fonction de comparaison
    fetchPreviousYearData // 📌 NOUVEAU : Récupération données N-1
  };
}