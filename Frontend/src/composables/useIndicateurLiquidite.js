import { ref, onMounted, computed } from "vue";
import axios from "axios";

export function useIndicateurLiquidite(filters) {
  const API_URL = "http://127.0.0.1:8000/api";
  
  const exercice = ref(null);
  const exercicesList = ref([]);
  const LiquiditeGenerale = ref(null);
  const TresorerieNette = ref(null);
  const BFR = ref(null);
  const loading = ref(false);

  // 📌 NOUVEAU : Données de l'année N-1
  const previousYearData = ref({
    LiquiditeGenerale: null,
    TresorerieNette: null,
    BFR: null,
  });

  // 📌 Fonction pour obtenir l'année précédente
  const getPreviousYear = (currentYear) => {
    return currentYear - 1;
  };
  

  // 📌 Fonction pour obtenir les dates de l'année précédente
  const getPreviousYearDates = (currentDateStart, currentDateEnd) => {
    const start = new Date(currentDateStart);
    const end = new Date(currentDateEnd);
    
    const previousStart = new Date(start.getFullYear() - 1, start.getMonth(), start.getDate());
    const previousEnd = new Date(end.getFullYear() - 1, end.getMonth(), end.getDate());
    
    return {
      dateStart: previousStart.toISOString().split('T')[0],
      dateEnd: previousEnd.toISOString().split('T')[0]
    };
  };

  // 📌 Récupérer les données de l'année N-1
  const fetchPreviousYearData = async (currentDateStart, currentDateEnd) => {
    try {
      const previousDates = getPreviousYearDates(currentDateStart, currentDateEnd);
      
      const [Liquidite, Tresorerie, fondRoulement] = await Promise.all([
        axios.get(`${API_URL}/analyse/ratio-liquidite-generale`, {
          params: { date_debut: previousDates.dateStart, date_fin: previousDates.dateEnd }
        }).catch(() => ({ data: null })),
        
        axios.get(`${API_URL}/analyse/tresorerie-nette`, {
          params: { date_debut: previousDates.dateStart, date_fin: previousDates.dateEnd }
        }).catch(() => ({ data: null })),
        
        
        axios.get(`${API_URL}/analyse/bfr`, {
          params: { date_debut: previousDates.dateStart, date_fin: previousDates.dateEnd }
        }).catch(() => ({ data: null }))
      ]);

      previousYearData.value = {
        LiquiditeGenerale: Liquidite.data,
        TresorerieNette: Tresorerie.data,
        BFR: fondRoulement.data,
      };
      console.log(previousYearData);
      
      return previousYearData.value;
    } catch (error) {
      console.error("Erreur lors de la récupération des données N-1:", error);
      return null;
    }
  };

  // 📌 Fonction de comparaison entre N et N-1
  const getComparison = (currentValue, previousValue, type = 'montant' ) => {
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
      percentage: Math.abs(percentage).toFixed(1),
      trend,
      hasData: true,
      currentValue: current,
      previousValue: previous
    };
  };

  // 📌 Computed pour les comparaisons
  const comparisons = computed(() => {
    return {
      Liquidite: getComparison(
        LiquiditeGenerale.value?.ratio_liquidite_generale, 
        previousYearData.value.LiquiditeGenerale?.ratio_liquidite_generale,
        'pourcentage'
      ),
      Tresorerie: getComparison(
        TresorerieNette.value?.tresorerie_nette, 
        previousYearData.value.TresorerieNette?.tresorerie_nette
      ),
      fondRoulement: getComparison(
        BFR.value?.bfr, 
        previousYearData.value.BFR?.bfr
      )
    };
  });

  // 📌 Fonction pour formater le format de date
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

// 📌 Récupérer tous les exercices
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
    
    console.log('Exercices filtrés (avec sélectionné):', exercicesList.value);
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
      await refreshAllData();
    } catch (error) {
      console.error("Erreur changeExercice:", error);
    }
  };

  const getLiquidite = async () => {
    try {
      const response = await axios.get(`${API_URL}/analyse/ratio-liquidite-generale`, {
        params: {
          date_debut: filters.value.dateStart,
          date_fin: filters.value.dateEnd,
        },
      });
      LiquiditeGenerale.value = response.data;
    } catch (error) {
      console.error("Erreur lors de la récupération des Liquidite", error);
      throw error;
    }
  };

  const getTresorerie = async () => {
    try {
      const response = await axios.get(`${API_URL}/analyse/tresorerie-nette`, {
        params: {
          date_debut: filters.value.dateStart,
          date_fin: filters.value.dateEnd,
        },
      });
      TresorerieNette.value = response.data;
    } catch (error) {
      console.error("Erreur lors de la récupération des Tresorerie", error);
      throw error;
    }
  };


  const getBFR = async () => {
    try {
      const response = await axios.get(`${API_URL}/analyse/bfr`, {
        params: {
          date_debut: filters.value.dateStart,
          date_fin: filters.value.dateEnd,
        },
      });
      BFR.value = response.data;
    } catch (error) {
      console.error("Erreur lors de la récupération du résultat net", error);
      throw error;
    }
  };


  // Fonction pour rafraîchir toutes les données
  const refreshAllData = async () => {
    try {
      loading.value = true;
      await Promise.all([
        getLiquidite(),
        getTresorerie(),
        getBFR(),
        fetchPreviousYearData(formatDateForInput(filters.value.dateStart), formatDateForInput(filters.value.dateEnd))
      ]);
      
      // 📌 NOUVEAU : Récupérer les données de l'année précédente
      // if (filters.value.dateStart && filters.value.dateEnd) {
        // await fetchPreviousYearData(formatDateForInput(filters.value.dateStart), formatDateForInput(filters.value.dateEnd));
      // }
    } catch (error) {
      console.error("Erreur lors du rafraîchissement des données", error);
    } finally {
      loading.value = false;
    }
  };

  // 📌 Chargement initial avec exercice
  const initializeData = async () => {
    try {
      loading.value = true;
      await fetchExercicesList();
      await fetchExercice();
      await refreshAllData();
    } catch (error) {
      console.error("Erreur initializeData:", error);
    } finally {
      loading.value = false;
    }
  };

  // Charger les données au montage
  // onMounted(() => {
  //   if (filters) {
  //     initializeData();
  //   }
  // });

  // Computed pour des calculs dérivés
  const ratioTresorerieLiquidite = computed(() => {
    if (LiquiditeGenerale.value?.ratio_liquidite_generale?.valeur && TresorerieNette.value?.tresorerie_nette?.valeur) {
      return (TresorerieNette.value.tresorerie_nette.valeur / LiquiditeGenerale.value.ratio_liquidite_generale.valeur * 100).toFixed(2);
    }
    return 0;
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
    LiquiditeGenerale,
    TresorerieNette,
    BFR,
    loading,
    previousYearData,

    // Computed
    infoExercice,
    exercicesOptions,
    ratioTresorerieLiquidite,
    comparisons, // 📌 NOUVEAU : Comparaisons N vs N-1

    // Fonctions
    getLiquidite,
    getTresorerie,
    getBFR,
    refreshAllData,
    initializeData,
    changeExercice,
    fetchExercicesList,
    formatDateForInput,
    getComparison, // 📌 NOUVEAU : Fonction de comparaison
    fetchPreviousYearData // 📌 NOUVEAU : Récupération données N-1
  };
}