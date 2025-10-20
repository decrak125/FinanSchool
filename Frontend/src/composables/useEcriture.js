import { ref, onMounted, nextTick, computed } from "vue";
import axios from "axios";
import { useRouter } from 'vue-router';
import { getUser } from "../services/Auth";

export function useEcriture() {
  const router = useRouter();
  const user = ref(null);

  // État de l'application
  const mouvements = ref([]);
  const journals = ref([]);
  const sousComptes = ref([]);
  const modesPaiement = ref([]);

  // États de chargement
  const isLoading = ref(true);
  const isCreatingMouvement = ref(false);
  const isValidating = ref(false);
  const isDeletingMouvement = ref(false);

  // Messages
  const errorMessage = ref('');
  const successMessage = ref('');

  const mouvementForm = ref({
    Date_mouvement: "",
    Id_Journal: "",
  });

  const token = localStorage.getItem("token");

  if (!token) {
    window.location.href = "/";
  } else {
    axios.defaults.headers.common["Authorization"] = `Bearer ${token}`;
  }

  const totalLignes = computed(() => {
    return mouvements.value.reduce((total, m) => total + m.lignes.length, 0);
  });

  const handleError = (error, defaultMessage = 'Une erreur est survenue') => {
    console.error('Erreur API:', error);
    if (error.response?.data?.message) {
      errorMessage.value = error.response.data.message;
    } else if (error.response?.data?.error) {
      errorMessage.value = error.response.data.error;
    } else {
      errorMessage.value = defaultMessage;
    }
    setTimeout(() => {
      errorMessage.value = '';
    }, 5000);
  };

  const showSuccess = (message) => {
    successMessage.value = message;
    setTimeout(() => {
      successMessage.value = '';
    }, 3000);
  };

  const fetchMouvements = async () => {
    try {
      const res = await axios.get("http://127.0.0.1:8000/api/mouvements");
      const mouvementsData = res.data;

      for (let m of mouvementsData) {
        try {
          const lignesRes = await axios.get(`http://127.0.0.1:8000/api/lignes?mouvement_id=${m.Id_Mouvement_ecriture}`);
          m.lignes = (lignesRes.data || [])
            .filter(l => l.Id_Mouvement_ecriture === m.Id_Mouvement_ecriture)
            .map(ligne => ({
              ...ligne,
              sousCompteSearch: ligne.sous_compte ? `${ligne.sous_compte.Code_sous_compte} - ${ligne.sous_compte.Libelle}` : '',
              showSuggestions: false,
              suggestions: [],
              selectedSuggestionIndex: -1,
              sousCompteError: '',
              enregistrementEnCours: false // ✅ AJOUTÉ ICI
            }));
        } catch (error) {
          console.error(`Erreur lors du chargement des lignes pour le mouvement ${m.Id_Mouvement_ecriture}:`, error);
          m.lignes = [];
        }
      }
      
      mouvements.value = mouvementsData
        .filter(m => !isMouvementValide(m))
        .sort((a, b) => new Date(b.Date_mouvement) - new Date(a.Date_mouvement));
    } catch (error) {
      handleError(error, 'Erreur lors du chargement des mouvements');
    }
  };

  const fetchOptions = async () => {
    try {
      const [journalsRes, sousComptesRes, modesRes] = await Promise.all([
        axios.get("http://127.0.0.1:8000/api/journals").catch(() => ({ data: [] })),
        axios.get("http://127.0.0.1:8000/api/sous-comptes").catch(() => ({ data: [] })),
        axios.get("http://127.0.0.1:8000/api/mode-paiements").catch(() => ({ data: [] }))
      ]);
      
      journals.value = journalsRes.data || [];
      sousComptes.value = sousComptesRes.data || [];
      modesPaiement.value = modesRes.data || [];
    } catch (error) {
      console.error('Erreur lors du chargement des options:', error);
    }
  };

  const createMouvement = async () => {
    if (isCreatingMouvement.value) return;
    
    isCreatingMouvement.value = true;
    errorMessage.value = '';
    
    try {
      await axios.post("http://127.0.0.1:8000/api/mouvements", mouvementForm.value);
      mouvementForm.value.Date_mouvement = "";
      mouvementForm.value.Id_Journal = "";
      showSuccess('Mouvement créé avec succès');
      await fetchMouvements();
    } catch (error) {
      handleError(error, 'Erreur lors de la création du mouvement');
    } finally {
      isCreatingMouvement.value = false;
    }
  };

  const deleteMouvement = async (mouvementId) => {
    if (!confirm('Êtes-vous sûr de vouloir supprimer ce mouvement et toutes ses lignes ?')) {
      return;
    }
    
    isDeletingMouvement.value = true;
    
    try {
      await axios.delete(`http://127.0.0.1:8000/api/mouvements/${mouvementId}`);
      showSuccess('Mouvement supprimé avec succès');
      await fetchMouvements();
    } catch (error) {
      handleError(error, 'Erreur lors de la suppression du mouvement');
    } finally {
      isDeletingMouvement.value = false;
    }
  };

  // ✅ MODIFIÉ : Ajout du flag enregistrementEnCours
  const addNewLigne = (mouvementId) => {
    const mouvement = mouvements.value.find(m => m.Id_Mouvement_ecriture === mouvementId);
    if (!mouvement) return;

    const nouvelleLigne = {
      Id_Ligne_ecriture: null,
      Libelle: "",
      Debit: 0,
      Credit: 0,
      Reference: "",
      Quantite: 1,
      Id_Mode_paiement: "",
      Id_Sous_compte: "",
      Id_Mouvement_ecriture: mouvementId,
      Id_Journal: mouvement.Id_Journal,
      sousCompteSearch: "",
      showSuggestions: false,
      suggestions: [],
      selectedSuggestionIndex: -1,
      sousCompteError: '',
      enregistrementEnCours: false // ✅ AJOUTÉ ICI
    };

    mouvement.lignes.push(nouvelleLigne);
    nextTick(() => {
      const inputs = document.querySelectorAll(`input[placeholder="Code ou libellé..."]`);
      const lastInput = inputs[inputs.length - 1];
      if (lastInput) lastInput.focus();
    });
  };

  const searchSousCompte = (mouvementId, ligneIndex, searchTerm) => {
    const mouvement = mouvements.value.find(m => m.Id_Mouvement_ecriture === mouvementId);
    if (!mouvement || !mouvement.lignes[ligneIndex]) return;

    const ligne = mouvement.lignes[ligneIndex];
    ligne.sousCompteError = '';
    
    if (!searchTerm || searchTerm.length < 2) {
      ligne.showSuggestions = false;
      ligne.suggestions = [];
      ligne.selectedSuggestionIndex = -1;
      return;
    }

    const filtered = sousComptes.value.filter(compte =>
      compte.Code_sous_compte.toLowerCase().includes(searchTerm.toLowerCase()) ||
      compte.Libelle.toLowerCase().includes(searchTerm.toLowerCase())
    ).slice(0, 10);

    ligne.suggestions = filtered;
    ligne.showSuggestions = filtered.length > 0;
    ligne.selectedSuggestionIndex = -1;
  };

  const onSousCompteFocus = (mouvementId, ligneIndex) => {
    const mouvement = mouvements.value.find(m => m.Id_Mouvement_ecriture === mouvementId);
    if (!mouvement || !mouvement.lignes[ligneIndex]) return;

    const ligne = mouvement.lignes[ligneIndex];
    if (ligne.sousCompteSearch && ligne.sousCompteSearch.length >= 2) {
      searchSousCompte(mouvementId, ligneIndex, ligne.sousCompteSearch);
    }
  };

  const navigateSuggestions = (mouvementId, ligneIndex, direction) => {
    const mouvement = mouvements.value.find(m => m.Id_Mouvement_ecriture === mouvementId);
    if (!mouvement || !mouvement.lignes[ligneIndex] || !mouvement.lignes[ligneIndex].showSuggestions) return;

    const ligne = mouvement.lignes[ligneIndex];
    const maxIndex = ligne.suggestions.length - 1;
    
    if (direction === 'down') {
      ligne.selectedSuggestionIndex = ligne.selectedSuggestionIndex < maxIndex ? ligne.selectedSuggestionIndex + 1 : 0;
    } else {
      ligne.selectedSuggestionIndex = ligne.selectedSuggestionIndex > 0 ? ligne.selectedSuggestionIndex - 1 : maxIndex;
    }
  };

  const selectFirstSuggestion = (mouvementId, ligneIndex) => {
    const mouvement = mouvements.value.find(m => m.Id_Mouvement_ecriture === mouvementId);
    if (!mouvement || !mouvement.lignes[ligneIndex]) return;

    const ligne = mouvement.lignes[ligneIndex];
    if (ligne.showSuggestions && ligne.suggestions.length > 0) {
      const selectedIndex = ligne.selectedSuggestionIndex >= 0 ? ligne.selectedSuggestionIndex : 0;
      selectSousCompte(mouvementId, ligneIndex, ligne.suggestions[selectedIndex]);
    }
  };

  const closeSuggestions = (mouvementId, ligneIndex) => {
    const mouvement = mouvements.value.find(m => m.Id_Mouvement_ecriture === mouvementId);
    if (!mouvement || !mouvement.lignes[ligneIndex]) return;

    const ligne = mouvement.lignes[ligneIndex];
    ligne.showSuggestions = false;
    ligne.selectedSuggestionIndex = -1;
  };

  const selectSousCompte = (mouvementId, ligneIndex, sousCompte) => {
    const mouvement = mouvements.value.find(m => m.Id_Mouvement_ecriture === mouvementId);
    if (!mouvement || !mouvement.lignes[ligneIndex]) return;

    const ligne = mouvement.lignes[ligneIndex];
    ligne.Id_Sous_compte = sousCompte.Id_Sous_compte;
    ligne.sousCompteSearch = `${sousCompte.Code_sous_compte} - ${sousCompte.Libelle}`;
    ligne.showSuggestions = false;
    ligne.selectedSuggestionIndex = -1;
    ligne.sousCompteError = '';
    
    if (!ligne.Libelle || ligne.Libelle.trim() === '') {
      ligne.Libelle = sousCompte.Libelle;
    }

    updateLigne(mouvementId, ligneIndex);
  };

  const validateSousCompte = (mouvementId, ligneIndex) => {
    setTimeout(() => {
      const mouvement = mouvements.value.find(m => m.Id_Mouvement_ecriture === mouvementId);
      if (!mouvement || !mouvement.lignes[ligneIndex]) return;

      const ligne = mouvement.lignes[ligneIndex];
      ligne.showSuggestions = false;
      ligne.selectedSuggestionIndex = -1;

      if (ligne.sousCompteSearch && !ligne.Id_Sous_compte) {
        const found = sousComptes.value.find(compte =>
          `${compte.Code_sous_compte} - ${compte.Libelle}` === ligne.sousCompteSearch ||
          compte.Code_sous_compte === ligne.sousCompteSearch.trim()
        );

        if (found) {
          ligne.Id_Sous_compte = found.Id_Sous_compte;
          ligne.sousCompteSearch = `${found.Code_sous_compte} - ${found.Libelle}`;
          ligne.sousCompteError = '';
          
          if (!ligne.Libelle || ligne.Libelle.trim() === '') {
            ligne.Libelle = found.Libelle;
          }
          
          updateLigne(mouvementId, ligneIndex);
        } else {
          ligne.sousCompteError = 'Sous-compte non trouvé';
          ligne.Id_Sous_compte = '';
        }
      }
    }, 150);
  };

  const onMontantChange = (mouvementId, ligneIndex, type) => {
    const mouvement = mouvements.value.find(m => m.Id_Mouvement_ecriture === mouvementId);
    if (!mouvement || !mouvement.lignes[ligneIndex]) return;

    const ligne = mouvement.lignes[ligneIndex];
    
    if (ligne.Debit < 0) ligne.Debit = 0;
    if (ligne.Credit < 0) ligne.Credit = 0;
    
    if (type === 'debit' && ligne.Debit > 0) {
      ligne.Credit = 0;
    } else if (type === 'credit' && ligne.Credit > 0) {
      ligne.Debit = 0;
    }
  };

  // ✅ FONCTION CORRIGÉE AVEC VERROU ANTI-DOUBLON
const updateLigne = async (mouvementId, ligneIndex) => {
  const mouvement = mouvements.value.find(m => m.Id_Mouvement_ecriture === mouvementId);
  if (!mouvement || !mouvement.lignes[ligneIndex]) return;

  const ligne = mouvement.lignes[ligneIndex];

  // ✅ VERROU : Si un enregistrement est déjà en cours, on stoppe
  if (ligne.enregistrementEnCours) {
    console.log('⚠️ Enregistrement déjà en cours, requête ignorée');
    return;
  }

  // Vérification des champs obligatoires
  if (!ligne.Id_Sous_compte || (!ligne.Debit && !ligne.Credit)) {
    console.log('⚠️ Champs obligatoires manquants');
    return;
  }

  // ✅ Active le verrou AVANT toute opération
  ligne.enregistrementEnCours = true;

  try {
    const ligneData = {
      Libelle: ligne.Libelle || '',
      Debit: parseFloat(ligne.Debit) || 0,
      Credit: parseFloat(ligne.Credit) || 0,
      Reference: ligne.Reference || '',
      Quantite: parseInt(ligne.Quantite) || 1,
      Id_Mode_paiement: ligne.Id_Mode_paiement || null,
      Id_Sous_compte: ligne.Id_Sous_compte,
      Id_Mouvement_ecriture: mouvementId,
      Id_Journal: mouvement.Id_Journal
    };

    if (ligne.Id_Ligne_ecriture) {
      // ✅ MISE À JOUR d'une ligne existante
      console.log('📝 Mise à jour ligne:', ligne.Id_Ligne_ecriture);
      const res = await axios.put(
        `http://127.0.0.1:8000/api/lignes/${ligne.Id_Ligne_ecriture}`, 
        ligneData
      );
      
      // Met à jour les données de la ligne
      Object.assign(ligne, res.data.data || res.data);
      console.log('✅ Ligne mise à jour avec succès');
      
    } else {
      // ✅ CRÉATION d'une nouvelle ligne
      console.log('➕ Création nouvelle ligne');
      const res = await axios.post("http://127.0.0.1:8000/api/lignes", ligneData);
      
      // ⚠️ CORRECTION : Récupère l'ID depuis différents formats de réponse
      const newId = res.data.data?.Id_Ligne_ecriture 
                 || res.data.Id_Ligne_ecriture 
                 || res.data.data?.id 
                 || res.data.id;
      
      if (newId) {
        ligne.Id_Ligne_ecriture = newId;
        console.log('✅ Ligne créée avec ID:', newId);
      } else {
        console.error('❌ Pas d\'ID retourné par le serveur:', res.data);
      }
      
      // Met à jour toutes les données de la ligne
      Object.assign(ligne, res.data.data || res.data);
    }
    
  } catch (error) {
    console.error('❌ Erreur dans updateLigne:', error);
    handleError(error, 'Erreur lors de la sauvegarde de la ligne');
  } finally {
    // ✅ Libère le verrou après succès ou erreur
    ligne.enregistrementEnCours = false;
    console.log('🔓 Verrou libéré');
  }
};


  const deleteLigne = async (mouvementId, ligneIndex) => {
    const mouvement = mouvements.value.find(m => m.Id_Mouvement_ecriture === mouvementId);
    if (!mouvement || !mouvement.lignes[ligneIndex]) return;

    const ligne = mouvement.lignes[ligneIndex];

    if (!confirm('Supprimer cette ligne d\'écriture ?')) {
      return;
    }

    try {
      if (ligne.Id_Ligne_ecriture) {
        await axios.delete(`http://127.0.0.1:8000/api/lignes/${ligne.Id_Ligne_ecriture}`);
        showSuccess('Ligne supprimée avec succès');
      }
      
      mouvement.lignes.splice(ligneIndex, 1);
    } catch (error) {
      handleError(error, 'Erreur lors de la suppression de la ligne');
    }
  };

  const getTotalDebit = (mouvement) => {
    return mouvement.lignes.reduce((total, ligne) => total + (parseFloat(ligne.Debit) || 0), 0);
  };

  const getTotalCredit = (mouvement) => {
    return mouvement.lignes.reduce((total, ligne) => total + (parseFloat(ligne.Credit) || 0), 0);
  };

  const getDifference = (mouvement) => {
    return Math.abs(getTotalDebit(mouvement) - getTotalCredit(mouvement));
  };

  const isEquilibre = (mouvement) => {
    const totalDebit = getTotalDebit(mouvement);
    const totalCredit = getTotalCredit(mouvement);
    return Math.abs(totalDebit - totalCredit) < 0.01 && totalDebit > 0;
  };

  const getTotalGeneralDebit = () => {
    return mouvements.value.reduce((total, m) => total + getTotalDebit(m), 0);
  };

  const getTotalGeneralCredit = () => {
    return mouvements.value.reduce((total, m) => total + getTotalCredit(m), 0);
  };

  const isMouvementValide = (mouvement) => {
    return mouvement.lignes.length > 0 && mouvement.lignes.every(ligne => ligne.statut === 'valide');
  };

  const validerMouvement = async (mouvementId) => {
    if (isValidating.value) return;
    
    const mouvement = mouvements.value.find(m => m.Id_Mouvement_ecriture === mouvementId);
    if (!mouvement || !isEquilibre(mouvement)) {
      errorMessage.value = 'Le mouvement doit être équilibré pour être validé';
      return;
    }

    if (isMouvementValide(mouvement)) {
      errorMessage.value = 'Le mouvement est déjà validé';
      return;
    }

    if (!confirm('Valider ce mouvement ? Cette action sera définitive.')) {
      return;
    }

    isValidating.value = true;

    try {
      await axios.post(`http://127.0.0.1:8000/api/mouvements/${mouvementId}/valider`);
      showSuccess('Mouvement validé avec succès');
      await fetchMouvements();
    } catch (error) {
      handleError(error, 'Erreur lors de la validation du mouvement');
    } finally {
      isValidating.value = false;
    }
  };

  const getJournalLibelle = (journalId) => {
    const journal = journals.value.find(j => j.Id_Journal === journalId);
    return journal ? `${journal.Code} - ${journal.Libelle}` : `Journal #${journalId}`;
  };

  const formatDate = (dateStr) => {
    if (!dateStr) return 'Date invalide';
    try {
      const date = new Date(dateStr);
      return date.toLocaleDateString('fr-FR', {
        weekday: 'short',
        year: 'numeric',
        month: 'short',
        day: 'numeric'
      });
    } catch (error) {
      return dateStr;
    }
  };

  const formatMontant = (montant) => {
    if (montant === null || montant === undefined || isNaN(montant)) {
      return '0,00';
    }
    return new Intl.NumberFormat('fr-FR', {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2
    }).format(montant);
  };

  onMounted(async () => {
    isLoading.value = true;
    try {
      await fetchOptions();
      await fetchMouvements();
    } catch (error) {
      handleError(error, 'Erreur lors de l\'initialisation');
    } finally {
      isLoading.value = false;
    }
    const today = new Date().toISOString().split('T')[0];
    mouvementForm.value.Date_mouvement = today;
  });

onMounted(async () => {
  // ========== 1. AUTHENTIFICATION (EN PREMIER) ==========
  console.log("Token récupéré :", token);
  
  if (!token) {
    console.log("Pas de token → Redirection vers /");
    window.location.href = "/";
    return; // Arrête l'exécution immédiatement
  }

  axios.defaults.headers.common["Authorization"] = `Bearer ${token}`;

  try {
    console.log("Appel getUser en cours...");
    const res = await getUser(token);
    user.value = res.data;
    console.log("User récupéré :", user.value);
  } catch (err) {
    console.error("Erreur lors de getUser :", err);
    localStorage.removeItem("token");
    window.location.href = "/";
    return; // Arrête l'exécution
  }

  // ========== 2. CHARGEMENT DES DONNÉES DE LA PAGE ==========
  isLoading.value = true;
  try {
    await fetchOptions();
    await fetchMouvements();
  } catch (error) {
    handleError(error, 'Erreur lors de l\'initialisation');
  } finally {
    isLoading.value = false;
  }

  // ========== 3. INITIALISATION DE LA DATE ==========
  const today = new Date().toISOString().split('T')[0];
  mouvementForm.value.Date_mouvement = today;
});


  const handleNavigation = (item) => {
    router.push(item.route);
  };

  return {
    mouvements,
    journals,
    sousComptes,
    modesPaiement,
    isLoading,
    isCreatingMouvement,
    isValidating,
    isDeletingMouvement,
    errorMessage,
    successMessage,
    mouvementForm,
    totalLignes,
    handleNavigation,
    createMouvement,
    deleteMouvement,
    addNewLigne,
    searchSousCompte,
    onSousCompteFocus,
    navigateSuggestions,
    selectFirstSuggestion,
    closeSuggestions,
    selectSousCompte,
    validateSousCompte,
    onMontantChange,
    updateLigne,
    deleteLigne,
    getTotalDebit,
    getTotalCredit,
    getDifference,
    isEquilibre,
    getTotalGeneralDebit,
    getTotalGeneralCredit,
    isMouvementValide,
    validerMouvement,
    getJournalLibelle,
    formatDate,
    formatMontant
  };
}
