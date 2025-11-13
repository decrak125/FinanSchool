import { ref, onMounted, computed } from "vue";
import axios from "axios";

export function useIndicateursUnifies(filters) {
  const API_URL = "http://127.0.0.1:8000/api";
  
  // États communs
  const exercice = ref(null);
  const exercicesList = ref([]);
  const loading = ref(false);
  const loadingTable = ref(false);

  // 📊 INDICATEURS GÉNÉRAUX
  const totalProduits = ref(null);
  const totalCharges = ref(null);
  const resultatNet = ref(null);
  const margeExploitation = ref(null);

  // 💰 INDICATEURS DE LIQUIDITÉ
  const LiquiditeGenerale = ref(null);
  const TresorerieNette = ref(null);
  const BFR = ref(null);

  // 🎓 INDICATEURS PÉDAGOGIQUES
  const coutFonctionnement = ref(null);
  const chiffreAffaires = ref(null);
  const partMasseSalariale = ref(null);
  const margeParEleve = ref(null);

  // 📈 INDICATEURS DE RENTABILITÉ
  const MargeBrute = ref(null);
  const MargeNette = ref(null);
  const ROE = ref(null);
  const ROA = ref(null);

  // 🏦 INDICATEURS DE SOLVABILITÉ
  const RatioEndettement = ref(null);
  const CapaciteRemboursement = ref(null);
  const AutonomieFinanciere = ref(null);

  // 📌 Données de l'année N-1 pour tous les indicateurs
  const previousYearData = ref({
    // Général
    totalProduits: null,
    totalCharges: null,
    resultatNet: null,
    margeExploitation: null,
    
    // Liquidité
    LiquiditeGenerale: null,
    TresorerieNette: null,
    BFR: null,
    
    // Rentabilité
    MargeBrute: null,
    MargeNette: null,
    ROE: null,
    ROA: null,
    
    // Solvabilité
    RatioEndettement: null,
    CapaciteRemboursement: null,
    AutonomieFinanciere: null
  });

  // 📌 Fonction pour obtenir les dates de l'année précédente
  const getPreviousYearDates = (currentDateStart, currentDateEnd) => {
    const start = new Date(currentDateStart);
    const end = new Date(currentDateEnd);

    start.setHours(0, 0, 0, 0);
    end.setHours(0, 0, 0, 0);

    const previousStart = new Date(start);
    previousStart.setFullYear(previousStart.getFullYear() - 1);

    const previousEnd = new Date(end);
    previousEnd.setFullYear(previousEnd.getFullYear() - 1);

    const formatDate = (d) => d.toLocaleDateString('fr-CA');

    return {
      dateStart: formatDate(previousStart),
      dateEnd: formatDate(previousEnd)
    };
  };

  // 📌 Récupérer TOUTES les données de l'année N-1
  const fetchPreviousYearData = async (currentDateStart, currentDateEnd) => {
    try {
      loadingTable.value = true;
      const previousDates = getPreviousYearDates(currentDateStart, currentDateEnd);
      
      // Récupération de TOUS les indicateurs pour N-1
      const [
        produits, charges, resultat, margeExploit,
        liquidite, tresorerie, bfr,
        margeBrute, margeNette, roe, roa,
        endettement, remboursement, autonomie
      ] = await Promise.all([
        // Indicateurs Généraux
        axios.get(`${API_URL}/analyse/total-produits`, {
          params: { date_debut: previousDates.dateStart, date_fin: previousDates.dateEnd }
        }).catch(() => ({ data: null })),
        
        axios.get(`${API_URL}/analyse/total-charges`, {
          params: { date_debut: previousDates.dateStart, date_fin: previousDates.dateEnd }
        }).catch(() => ({ data: null })),
        
        axios.get(`${API_URL}/analyse/resultat-net`, {
          params: { date_debut: previousDates.dateStart, date_fin: previousDates.dateEnd }
        }).catch(() => ({ data: null })),
        
        axios.get(`${API_URL}/analyse/marge-exploitation`, {
          params: { date_debut: previousDates.dateStart, date_fin: previousDates.dateEnd }
        }).catch(() => ({ data: null })),

        // Indicateurs de Liquidité
        axios.get(`${API_URL}/analyse/ratio-liquidite-generale`, {
          params: { date_debut: previousDates.dateStart, date_fin: previousDates.dateEnd }
        }).catch(() => ({ data: null })),
        
        axios.get(`${API_URL}/analyse/tresorerie-nette`, {
          params: { date_debut: previousDates.dateStart, date_fin: previousDates.dateEnd }
        }).catch(() => ({ data: null })),
        
        axios.get(`${API_URL}/analyse/bfr`, {
          params: { date_debut: previousDates.dateStart, date_fin: previousDates.dateEnd }
        }).catch(() => ({ data: null })),

        // Indicateurs de Rentabilité
        axios.get(`${API_URL}/analyse/marge-brute`, {
          params: { date_debut: previousDates.dateStart, date_fin: previousDates.dateEnd }
        }).catch(() => ({ data: null })),
        
        axios.get(`${API_URL}/analyse/marge-nette`, {
          params: { date_debut: previousDates.dateStart, date_fin: previousDates.dateEnd }
        }).catch(() => ({ data: null })),
        
        axios.get(`${API_URL}/analyse/roe`, {
          params: { date_debut: previousDates.dateStart, date_fin: previousDates.dateEnd }
        }).catch(() => ({ data: null })),
        
        axios.get(`${API_URL}/analyse/roa`, {
          params: { date_debut: previousDates.dateStart, date_fin: previousDates.dateEnd }
        }).catch(() => ({ data: null })),

        // Indicateurs de Solvabilité
        axios.get(`${API_URL}/analyse/ratio-endettement`, {
          params: { date_debut: previousDates.dateStart, date_fin: previousDates.dateEnd }
        }).catch(() => ({ data: null })),
        
        axios.get(`${API_URL}/analyse/capacite-remboursement`, {
          params: { date_debut: previousDates.dateStart, date_fin: previousDates.dateEnd }
        }).catch(() => ({ data: null })),
        
        axios.get(`${API_URL}/analyse/autonomie-financiere`, {
          params: { date_debut: previousDates.dateStart, date_fin: previousDates.dateEnd }
        }).catch(() => ({ data: null }))
      ]);

      previousYearData.value = {
        // Général
        totalProduits: produits.data,
        totalCharges: charges.data,
        resultatNet: resultat.data,
        margeExploitation: margeExploit.data,
        
        // Liquidité
        LiquiditeGenerale: liquidite.data,
        TresorerieNette: tresorerie.data,
        BFR: bfr.data,
        
        // Rentabilité
        MargeBrute: margeBrute.data,
        MargeNette: margeNette.data,
        ROE: roe.data,
        ROA: roa.data,
        
        // Solvabilité
        RatioEndettement: endettement.data,
        CapaciteRemboursement: remboursement.data,
        AutonomieFinanciere: autonomie.data
      };

      console.log('Données N-1 unifiées:', previousYearData.value);
      loadingTable.value = false;
      return previousYearData.value;
    } catch (error) {
      console.error("Erreur lors de la récupération des données N-1 unifiées:", error);
      return null;
    }
  };

  // 📌 Fonction de comparaison entre N et N-1
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
      percentage: Math.abs(percentage).toFixed(type === 'pourcentage' ? 1 : 2),
      trend,
      hasData: true,
      currentValue: current,
      previousValue: previous
    };
  };

  // 📌 Computed pour TOUTES les comparaisons
  const comparisons = computed(() => {
    return {
      // Indicateurs Généraux
      produits: getComparison(
        totalProduits.value?.total_produits, 
        previousYearData.value.totalProduits?.total_produits
      ),
      charges: getComparison(
        totalCharges.value?.total_charges, 
        previousYearData.value.totalCharges?.total_charges
      ),
      resultatNet: getComparison(
        resultatNet.value?.resultat_net, 
        previousYearData.value.resultatNet?.resultat_net
      ),
      margeExploitation: getComparison(
        margeExploitation.value?.marge_exploitation?.valeur, 
        previousYearData.value.margeExploitation?.marge_exploitation?.valeur,
        'pourcentage'
      ),

      // Indicateurs de Liquidité
      Liquidite: getComparison(
        LiquiditeGenerale.value?.ratio_liquidite_generale?.valeur, 
        previousYearData.value.LiquiditeGenerale?.ratio_liquidite_generale?.valeur,
        'pourcentage'
      ),
      Tresorerie: getComparison(
        TresorerieNette.value?.tresorerie_nette, 
        previousYearData.value.TresorerieNette?.tresorerie_nette
      ),
      fondRoulement: getComparison(
        BFR.value?.bfr, 
        previousYearData.value.BFR?.bfr
      ),

      // Indicateurs de Rentabilité
      brute: getComparison(
        MargeBrute.value?.marge_brute?.valeur, 
        previousYearData.value.MargeBrute?.marge_brute?.valeur,
        'pourcentage'
      ),
      nette: getComparison(
        MargeNette.value?.marge_nette?.valeur, 
        previousYearData.value.MargeNette?.marge_nette?.valeur,
        'pourcentage'
      ),
      ROE: getComparison(
        ROE.value?.roe?.valeur, 
        previousYearData.value.ROE?.roe?.valeur,
        'pourcentage'
      ),
      ROA: getComparison(
        ROA.value?.roa?.valeur, 
        previousYearData.value.ROA?.roa?.valeur,
        'pourcentage'
      ),

      // Indicateurs de Solvabilité
      Endettement: getComparison(
        RatioEndettement.value?.ratio_endettement?.valeur, 
        previousYearData.value.RatioEndettement?.ratio_endettement?.valeur,
        'pourcentage'
      ),
      Remboursement: getComparison(
        CapaciteRemboursement.value?.capacite_remboursement, 
        previousYearData.value.CapaciteRemboursement?.capacite_remboursement
      ),
      Autonomie: getComparison(
        AutonomieFinanciere.value?.autonomie_financiere?.valeur, 
        previousYearData.value.AutonomieFinanciere?.autonomie_financiere?.valeur,
        'pourcentage'
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
      
      console.log('Exercices filtrés:', exercicesList.value);
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

  // 📌 Fonctions pour récupérer TOUS les indicateurs
  const getAllIndicateurs = async () => {
    try {
      const [
        // Général
        produits, charges, resultat, margeExploit,
        // Liquidité
        liquidite, tresorerie, bfr,
        // Rentabilité
        margeBrute, margeNette, roe, roa,
        // Solvabilité
        endettement, remboursement, autonomie
      ] = await Promise.all([
        // Indicateurs Généraux
        axios.get(`${API_URL}/analyse/total-produits`, {
          params: { date_debut: filters.value.dateStart, date_fin: filters.value.dateEnd }
        }),
        axios.get(`${API_URL}/analyse/total-charges`, {
          params: { date_debut: filters.value.dateStart, date_fin: filters.value.dateEnd }
        }),
        axios.get(`${API_URL}/analyse/resultat-net`, {
          params: { date_debut: filters.value.dateStart, date_fin: filters.value.dateEnd }
        }),
        axios.get(`${API_URL}/analyse/marge-exploitation`, {
          params: { date_debut: filters.value.dateStart, date_fin: filters.value.dateEnd }
        }),

        // Indicateurs de Liquidité
        axios.get(`${API_URL}/analyse/ratio-liquidite-generale`, {
          params: { date_debut: filters.value.dateStart, date_fin: filters.value.dateEnd }
        }),
        axios.get(`${API_URL}/analyse/tresorerie-nette`, {
          params: { date_debut: filters.value.dateStart, date_fin: filters.value.dateEnd }
        }),
        axios.get(`${API_URL}/analyse/bfr`, {
          params: { date_debut: filters.value.dateStart, date_fin: filters.value.dateEnd }
        }),

        // Indicateurs de Rentabilité
        axios.get(`${API_URL}/analyse/marge-brute`, {
          params: { date_debut: filters.value.dateStart, date_fin: filters.value.dateEnd }
        }),
        axios.get(`${API_URL}/analyse/marge-nette`, {
          params: { date_debut: filters.value.dateStart, date_fin: filters.value.dateEnd }
        }),
        axios.get(`${API_URL}/analyse/roe`, {
          params: { date_debut: filters.value.dateStart, date_fin: filters.value.dateEnd }
        }),
        axios.get(`${API_URL}/analyse/roa`, {
          params: { date_debut: filters.value.dateStart, date_fin: filters.value.dateEnd }
        }),

        // Indicateurs de Solvabilité
        axios.get(`${API_URL}/analyse/ratio-endettement`, {
          params: { date_debut: filters.value.dateStart, date_fin: filters.value.dateEnd }
        }),
        axios.get(`${API_URL}/analyse/capacite-remboursement`, {
          params: { date_debut: filters.value.dateStart, date_fin: filters.value.dateEnd }
        }),
        axios.get(`${API_URL}/analyse/autonomie-financiere`, {
          params: { date_debut: filters.value.dateStart, date_fin: filters.value.dateEnd }
        })
      ]);

      // Assignation des valeurs
      // Général
      totalProduits.value = produits.data;
      totalCharges.value = charges.data;
      resultatNet.value = resultat.data;
      margeExploitation.value = margeExploit.data;

      // Liquidité
      LiquiditeGenerale.value = liquidite.data;
      TresorerieNette.value = tresorerie.data;
      BFR.value = bfr.data;

      // Rentabilité
      MargeBrute.value = margeBrute.data;
      MargeNette.value = margeNette.data;
      ROE.value = roe.data;
      ROA.value = roa.data;

      // Solvabilité
      RatioEndettement.value = endettement.data;
      CapaciteRemboursement.value = remboursement.data;
      AutonomieFinanciere.value = autonomie.data;

    } catch (error) {
      console.error("Erreur lors de la récupération de tous les indicateurs:", error);
      throw error;
    }
  };

  // 📌 Fonction pour rafraîchir TOUTES les données
  const refreshAllData = async () => {
    try {
      loading.value = true;
      await Promise.all([
        getAllIndicateurs(),
        fetchPreviousYearData(formatDateForInput(filters.value.dateStart), formatDateForInput(filters.value.dateEnd))
      ]);
    } catch (error) {
      console.error("Erreur lors du rafraîchissement de toutes les données:", error);
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
      console.error("Erreur initializeData unifié:", error);
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
    // États de chargement
    loading,
    loadingTable,

    // Données des exercices
    exercice,
    exercicesList,
    infoExercice,
    exercicesOptions,

    // 📊 TOUS LES INDICATEURS
    // Général
    totalProduits,
    totalCharges,
    resultatNet,
    margeExploitation,
    
    // Liquidité
    LiquiditeGenerale,
    TresorerieNette,
    BFR,
    
    // Rentabilité
    MargeBrute,
    MargeNette,
    ROE,
    ROA,
    
    // Solvabilité
    RatioEndettement,
    CapaciteRemboursement,
    AutonomieFinanciere,

    // Données de comparaison
    previousYearData,
    comparisons,

    // Fonctions principales
    refreshAllData,
    initializeData,
    changeExercice,
    fetchExercicesList,
    formatDateForInput,
    getComparison,
    fetchPreviousYearData
  };
}