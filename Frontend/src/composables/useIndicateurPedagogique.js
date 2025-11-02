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

  // 📌 Données des 3 dernières années
  const threeYearsData = ref({
    current: null,
    previous: null,
    twoYearsAgo: null
  });

  // 📌 Fonction pour obtenir les dates des années précédentes
  const getPreviousYearsDates = (currentDateStart, currentDateEnd, yearsBack = 1) => {
    const start = new Date(currentDateStart);
    const end = new Date(currentDateEnd);

    start.setHours(0, 0, 0, 0);
    end.setHours(0, 0, 0, 0);

    const previousStart = new Date(start);
    previousStart.setFullYear(previousStart.getFullYear() - yearsBack);

    const previousEnd = new Date(end);
    previousEnd.setFullYear(previousEnd.getFullYear() - yearsBack);

    const formatDate = (d) => d.toLocaleDateString('fr-CA');

    return {
      dateStart: formatDate(previousStart),
      dateEnd: formatDate(previousEnd)
    };
  };

  // 📌 Récupérer les données des 3 dernières années
  const fetchThreeYearsData = async (currentDateStart, currentDateEnd) => {
    try {
      loadingTable.value = true;
      
      const previousDates = getPreviousYearsDates(currentDateStart, currentDateEnd, 1);
      const twoYearsAgoDates = getPreviousYearsDates(currentDateStart, currentDateEnd, 2);

      // Récupération des données pour les 3 années
      const [currentData, previousData, twoYearsAgoData] = await Promise.all([
        // Année N (actuelle)
        fetchAllIndicateurs(currentDateStart, currentDateEnd),
        
        // Année N-1
        fetchAllIndicateurs(previousDates.dateStart, previousDates.dateEnd),
        
        // Année N-2
        fetchAllIndicateurs(twoYearsAgoDates.dateStart, twoYearsAgoDates.dateEnd)
      ]);

      threeYearsData.value = {
        current: currentData,
        previous: previousData,
        twoYearsAgo: twoYearsAgoData
      };

      console.log('Données 3 ans:', threeYearsData.value);
      loadingTable.value = false;
      return threeYearsData.value;
    } catch (error) {
      console.error("Erreur lors de la récupération des données sur 3 ans:", error);
      return null;
    }
  };

  // 📌 Récupérer tous les indicateurs pédagogiques pour une période
  const fetchAllIndicateurs = async (dateStart, dateEnd) => {
    try {
      // Récupérer l'effectif élèves (vous devrez adapter cette partie)
    //   const effectifEleves = await getEffectifEleves(dateStart, dateEnd);
      
      const response = await axios.get(`${API_URL}/analyse/tous-indicateurs`, {
        params: {date_debut: dateStart,
        date_fin: dateEnd,
        effectif_eleves: 100}
        // masse_salariale_enseignante: await getMasseSalarialeEnseignante(dateStart, dateEnd)
      });

      return response.data.indicateurs_pedagogiques;
    } catch (error) {
      console.error(`Erreur récupération indicateurs pour ${dateStart}-${dateEnd}:`, error);
      return null;
    }
  };

  // 📌 Fonctions pour récupérer l'effectif et la masse salariale (à adapter)
  const getEffectifEleves = async (dateStart, dateEnd) => {
    // À implémenter selon votre logique métier
    // Pour l'exemple, on retourne une valeur fixe
    return 200;
  };

  const getMasseSalarialeEnseignante = async (dateStart, dateEnd) => {
    // À implémenter selon votre logique métier
    // Pour l'exemple, on retourne une valeur fixe
    return 150000;
  };

  // 📌 Fonction de comparaison améliorée pour 3 ans
  const getComparison = (currentValue, previousValue, twoYearsAgoValue, type = 'montant') => {
    const current = type === 'pourcentage' ? currentValue : currentValue?.valeur || currentValue;
    const previous = type === 'pourcentage' ? previousValue : previousValue?.valeur || previousValue;
    const twoYearsAgo = type === 'pourcentage' ? twoYearsAgoValue : twoYearsAgoValue?.valeur || twoYearsAgoValue;

    const hasCurrent = current !== null && current !== undefined;
    const hasPrevious = previous !== null && previous !== undefined;
    const hasTwoYearsAgo = twoYearsAgo !== null && twoYearsAgo !== undefined;

    // Comparaison N vs N-1
    const evolutionVsPrevious = hasCurrent && hasPrevious ? current - previous : null;
    const percentageVsPrevious = hasCurrent && hasPrevious && previous !== 0 ? 
      ((evolutionVsPrevious / Math.abs(previous)) * 100) : null;

    // Comparaison N vs N-2
    const evolutionVsTwoYearsAgo = hasCurrent && hasTwoYearsAgo ? current - twoYearsAgo : null;
    const percentageVsTwoYearsAgo = hasCurrent && hasTwoYearsAgo && twoYearsAgo !== 0 ? 
      ((evolutionVsTwoYearsAgo / Math.abs(twoYearsAgo)) * 100) : null;

    // Tendance globale
    let trend = 'stable';
    if (evolutionVsPrevious > 0 && evolutionVsTwoYearsAgo > 0) trend = 'up';
    if (evolutionVsPrevious < 0 && evolutionVsTwoYearsAgo < 0) trend = 'down';

    return {
      evolutionVsPrevious,
      percentageVsPrevious: percentageVsPrevious ? Math.abs(percentageVsPrevious).toFixed(1) : null,
      evolutionVsTwoYearsAgo,
      percentageVsTwoYearsAgo: percentageVsTwoYearsAgo ? Math.abs(percentageVsTwoYearsAgo).toFixed(1) : null,
      trend,
      hasData: hasCurrent && (hasPrevious || hasTwoYearsAgo),
      currentValue: current,
      previousValue: previous,
      twoYearsAgoValue: twoYearsAgo
    };
  };

  // 📌 Computed pour les comparaisons sur 3 ans
  const comparisons = computed(() => {
    const current = threeYearsData.value.current;
    const previous = threeYearsData.value.previous;
    const twoYearsAgo = threeYearsData.value.twoYearsAgo;

    return {
      coutFonctionnement: getComparison(
        current?.cout_fonctionnement_par_eleve,
        previous?.cout_fonctionnement_par_eleve,
        twoYearsAgo?.cout_fonctionnement_par_eleve,
        'montant'
      ),
      chiffreAffaires: getComparison(
        current?.chiffre_affaires_par_eleve,
        previous?.chiffre_affaires_par_eleve,
        twoYearsAgo?.chiffre_affaires_par_eleve,
        'montant'
      ),
      partMasseSalariale: getComparison(
        current?.part_masse_salariale_enseignante,
        previous?.part_masse_salariale_enseignante,
        twoYearsAgo?.part_masse_salariale_enseignante,
        'pourcentage'
      ),
      margeParEleve: getComparison(
        current?.marge_par_eleve,
        previous?.marge_par_eleve,
        twoYearsAgo?.marge_par_eleve,
        'montant'
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
      
      const currentDate = new Date();
      exercicesList.value = response.data.filter(exercice => {
        const dateDebut = new Date(exercice.Date_debut);
        const isSelected = exercice.Id_Exercice_comptable === filters.value.idExercice;
        
        return dateDebut <= currentDate || isSelected;
      });
      
      exercicesList.value.sort((a, b) => b.Annee_fiscale - a.Annee_fiscale);
      
      console.log('Exercices pédagogiques:', exercicesList.value);
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

  // 📌 Récupérer les indicateurs individuels
  const getCoutFonctionnement = async () => {
    try {
    //   const effectifEleves = await getEffectifEleves(filters.value.dateStart, filters.value.dateEnd);
      const response = await axios.get(`${API_URL}/analyse/cout-fonctionnement-par-eleve`, {
        params:{date_debut: filters.value.dateStart,
        date_fin: filters.value.dateEnd,
        effectif_eleves: 100}
      });
      coutFonctionnement.value = response.data;
    } catch (error) {
      console.error("Erreur récupération coût fonctionnement:", error);
      throw error;
    }
  };

  const getChiffreAffaires = async () => {
    try {
    //   const effectifEleves = await getEffectifEleves(filters.value.dateStart, filters.value.dateEnd);
      const response = await axios.get(`${API_URL}/analyse/chiffre-affaires-par-eleve`, {
        params:{date_debut: filters.value.dateStart,
        date_fin: filters.value.dateEnd,
        effectif_eleves: 100}
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
        params:{date_debut: filters.value.dateStart,
        date_fin: filters.value.dateEnd}
      });
      partMasseSalariale.value = response.data;
    } catch (error) {
      console.error("Erreur récupération part masse salariale:", error);
      throw error;
    }
  };

  const getMargeParEleve = async () => {
    try {
    //   const effectifEleves = await getEffectifEleves(filters.value.dateStart, filters.value.dateEnd);
      const response = await axios.get(`${API_URL}/analyse/marge-par-eleve`, {
        params:{date_debut: filters.value.dateStart,
        date_fin: filters.value.dateEnd,
        effectif_eleves: 100}
      });
      margeParEleve.value = response.data;
    } catch (error) {
      console.error("Erreur récupération marge par élève:", error);
      throw error;
    }
  };

  // 📌 Fonction pour rafraîchir toutes les données
  const refreshAllData = async () => {
    try {
      loading.value = true;
      await Promise.all([
        getCoutFonctionnement(),
        getChiffreAffaires(),
        getPartMasseSalariale(),
        getMargeParEleve(),
        fetchThreeYearsData(formatDateForInput(filters.value.dateStart), formatDateForInput(filters.value.dateEnd))
      ]);
    } catch (error) {
      console.error("Erreur rafraîchissement données pédagogiques:", error);
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
      console.error("Erreur initializeData pédagogique:", error);
    } finally {
      loading.value = false;
    }
  };

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
    coutFonctionnement,
    chiffreAffaires,
    partMasseSalariale,
    margeParEleve,
    loading,
    threeYearsData,
    loadingTable,
    
    // Computed
    infoExercice,
    exercicesOptions,
    comparisons,
    
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
    getComparison,
    fetchThreeYearsData
  };
}