import { ref, computed, onMounted } from "vue";
import axios from "axios";

const API_URL = "http://127.0.0.1:8000/api";

export function useAffectations() {
  const affectations = ref([]);
  const centres = ref([]);
  const comptes = ref([]);
  const types = ref([]); // ← NOUVEAU : Liste des types
  const editingVentilation = ref(null);
  const showVentilationForm = ref(false);
  const nombreLignesLoader = ref(10);
  const loadingTable = ref(true);
  const form = ref({
    Id_Compte: null,
    ventilations: []
  });
  const isEditing = ref(false);
  const editingId = ref(null);

  // Variables pour recherche compte
  const searchTerm = ref("");
  const suggestions = ref([]);
  const showSuggestions = ref(false);

  // Variables pour les filtres
  const filterSearchTerm = ref("");
  const filterSelectedCentre = ref("");

  // Variables pour les détails
  const showDetails = ref(false);
  const selectedGroup = ref(null);
  const detailsMode = ref('view'); // 'view' ou 'edit'

  // Variables pour l'import
  const file = ref(null);
  const message = ref({ text: "", type: "" });

  // Fetch initial data
  const fetchData = async () => {
    loadingTable.value = true;
    const [resAffect, resCentres, resComptes, resTypes] = await Promise.all([ // ← AJOUT resTypes
      axios.get(`${API_URL}/affectations`),
      axios.get(`${API_URL}/centres`),
      axios.get(`${API_URL}/comptes`),
      axios.get(`${API_URL}/types`) // ← NOUVEAU : Récupérer les types
    ]);
    affectations.value = resAffect.data;
    centres.value = resCentres.data;
    comptes.value = resComptes.data;
    types.value = resTypes.data; // ← NOUVEAU : Stocker les types
    loadingTable.value = false;
  };

  // Computed property pour les affectations filtrées
  const filteredAffectations = computed(() => {
    return affectations.value.filter(affectation => {
      const matchesSearch = filterSearchTerm.value === "" || 
        (affectation.sous_compte?.Code_sous_compte?.toLowerCase().includes(filterSearchTerm.value.toLowerCase()) ||
         affectation.sous_compte?.Libelle?.toLowerCase().includes(filterSearchTerm.value.toLowerCase()));
      
      const matchesCentre = filterSelectedCentre.value === "" || 
        affectation.id_centre?.toString() === filterSelectedCentre.value;
      
      return matchesSearch && matchesCentre;
    });
  });

  // Computed properties pour la validation du formulaire
  const totalTaux = computed(() => {
    return form.value.ventilations?.reduce((sum, v) => sum + Number(v.taux || 0), 0) || 0;
  });

  const totalTauxClass = computed(() => {
    if (totalTaux.value === 100) return 'text-green-600';
    if (totalTaux.value > 100) return 'text-red-600';
    return 'text-amber-600';
  });

  const hasDuplicateCentres = computed(() => {
    if (!form.value.ventilations) return false;
    const centresIds = form.value.ventilations.map(v => v.id_centre).filter(Boolean);
    return new Set(centresIds).size !== centresIds.length;
  });

  const isFormValid = computed(() => {
    if (!form.value.ventilations || form.value.ventilations.length === 0) return false;
    if (Math.abs(totalTaux.value - 100) > 0.01) return false;
    if (hasDuplicateCentres.value) return false;
    
    return form.value.ventilations.every(vent => 
      vent.id_centre && vent.id_type && vent.taux !== null && vent.taux !== undefined // ← AJOUT vent.id_type
    );
  });

  // Sauvegarde des affectations
  const save = async () => {
    // Vérifier le total AVANT la sauvegarde
    const totalTauxCalculated = form.value.ventilations?.reduce((sum, v) => {
      return sum + Number(v.taux || 0);
    }, 0) || 0;
  
    if (Math.abs(totalTauxCalculated - 100) > 0.01) {
      alert(`Le total des taux doit être égal à 100% (actuellement: ${totalTauxCalculated.toFixed(2)}%)`);
      return false;
    }
  
    try {
      if (isEditing.value) {
        await updateMultipleVentilations();
      } else {
        if (!form.value.Id_Compte) {
          alert("Sélectionnez un compte");
          return false;
        }
        
        // Pour la création, envoyer chaque ventilation avec id_type
        await axios.post(`${API_URL}/affectations`, {
          Id_Compte: form.value.Id_Compte,
          ventilations: form.value.ventilations.map(vent => ({
            id_centre: vent.id_centre,
            id_type: vent.id_type, // ← NOUVEAU CHAMP
            taux: vent.taux,
            description: vent.description || ''
          }))
        });
      }
      
      resetForm();
      await fetchData();
      return true;
    } catch (error) {
      console.error('Erreur:', error);
      alert(error.response?.data?.message || 'Erreur lors de la sauvegarde');
      return false;
    }
  };

  // Mise à jour multiple des ventilations
  const updateMultipleVentilations = async () => {
    try {
      const response = await axios.put(`${API_URL}/affectations/multiple`, {
        Id_Sous_compte: editingId.value,
        ventilations: form.value.ventilations.map(vent => ({
          id_affectation: vent.id_affectation || null,
          id_centre: vent.id_centre,
          id_type: vent.id_type, // ← NOUVEAU CHAMP
          taux: vent.taux,
          description: vent.description
        }))
      });
      
      return response.data;
    } catch (error) {
      console.error('Erreur mise à jour multiple:', error);
      throw error;
    }
  };

  // Édition d'une affectation
  const edit = (aff) => {
    form.value = {
      Id_Compte: aff.sous_compte?.Id_Compte,
      ventilations: aff.ventilations?.map(v => ({
        id_affectation: v.id_affectation,
        id_centre: v.id_centre,
        id_type: v.id_type, // ← NOUVEAU CHAMP
        taux: v.taux,
        description: v.description
      })) || []
    };

    searchTerm.value = aff.sous_compte
      ? `${aff.sous_compte.Code_compte} - ${aff.sous_compte.Libelle}`
      : "";

    isEditing.value = true;
    editingId.value = aff.id_affectation;
  };

  // Suppression d'une affectation
  const remove = async (id) => {
    if (confirm("Supprimer cette affectation ?")) {
      await axios.delete(`${API_URL}/affectations/${id}`);
      await fetchData();
    }
  };

  // Édition d'une ventilation individuelle
  const editVentilation = (ventilation) => {
    editingVentilation.value = { ...ventilation };
    showVentilationForm.value = true;
  };

  // Affichage des détails d'un groupe
  const showVentilationDetails = (group) => {
    selectedGroup.value = group;
    detailsMode.value = 'view';
    showDetails.value = true;
  };

  // Édition d'un groupe
  const editGroup = (group) => {
    form.value = {
      Id_Compte: group.Id_Compte,
      ventilations: group.ventilations.map(v => ({
        id_affectation: v.id_affectation,
        id_centre: v.id_centre,
        id_type: v.id_type, // ← NOUVEAU CHAMP
        taux: v.taux,
        description: v.description || ""
      }))
    };
  
    searchTerm.value = `${group.Code_sous_compte} - ${group.Libelle}`;
    
    isEditing.value = true;
    editingId.value = group.Id_Sous_compte;
  };

  // Sauvegarde d'une ventilation individuelle
  const saveVentilation = async () => {
    if (!editingVentilation.value) return;
    
    try {
      await axios.put(`${API_URL}/affectations/${editingVentilation.value.id_affectation}`, {
        id_centre: editingVentilation.value.id_centre,
        id_type: editingVentilation.value.id_type, // ← NOUVEAU CHAMP
        taux: editingVentilation.value.taux,
        description: editingVentilation.value.description
      });
      
      const wasDetailsOpen = showDetails.value;
      const currentGroup = selectedGroup.value;
      
      showVentilationForm.value = false;
      showDetails.value = false;
      editingVentilation.value = null;
      
      await fetchData();
      
      if (wasDetailsOpen && currentGroup) {
        setTimeout(() => {
          const updatedGroup = affectationsGrouped.value.find(
            group => group.Id_Sous_compte === currentGroup.Id_Sous_compte
          );
          if (updatedGroup) {
            selectedGroup.value = updatedGroup;
            showDetails.value = true;
          }
        }, 100);
      }
      
    } catch (error) {
      console.error('Erreur:', error);
      alert(error.response?.data?.message || 'Erreur lors de la modification');
    }
  };

  // Réinitialisation du formulaire
  const resetForm = () => {
    form.value = { 
      Id_Compte: null, 
      ventilations: []
    };
    searchTerm.value = "";
    showSuggestions.value = false;
    isEditing.value = false;
    editingId.value = null;
  };

  // Recherche de comptes
  const searchCompte = () => {
    const term = searchTerm.value.trim().toLowerCase();
    if (!term || term.length < 2) {
      showSuggestions.value = false;
      suggestions.value = [];
      return;
    }

    const filtered = comptes.value.filter(c =>
      c.Code_compte.toLowerCase().includes(term) ||
      c.Libelle.toLowerCase().includes(term)
    ).slice(0, 10);

    suggestions.value = filtered;
    showSuggestions.value = filtered.length > 0;
  };

  // Sélection d'un compte
  const selectCompte = (compte) => {
    form.value.Id_Compte = compte.Id_Compte;
    searchTerm.value = `${compte.Code_compte} - ${compte.Libelle}`;
    showSuggestions.value = false;
  };

  // Gestion de l'import de fichiers
  const onFileChange = (e) => {
    file.value = e.target.files[0];
  };

  const uploadFile = async () => {
    if (!file.value) {
      message.value = { text: "Veuillez sélectionner un fichier.", type: "error" };
      return;
    }

    const formData = new FormData();
    formData.append("file", file.value);

    try {
      const res = await axios.post(`${API_URL}/import/affectations`, formData, {
        headers: {
          "Content-Type": "multipart/form-data",
        },
      });

      message.value = { text: res.data.message, type: "success" };
      file.value = null;
      await fetchData();
    } catch (error) {
      message.value = {
        text: error.response?.data?.message || "Erreur lors de l'import.",
        type: "error",
      };
    }
  };

  // Suppression d'une ventilation
  const removeVentilation = async (index) => {
    if (form.value.ventilations.length <= 1) {
      alert("Vous devez avoir au moins une ventilation !");
      return;
    }

    const ventilationToRemove = form.value.ventilations[index];
  
    // SUPPRIMER SANS REDISTRIBUER le taux
    form.value.ventilations.splice(index, 1);
    
    // Optionnel : redistribution automatique du taux
    const totalActuel = form.value.ventilations.reduce((sum, v) => sum + Number(v.taux || 0), 0);
    const tauxRestant = 100 - totalActuel;
    
    if (tauxRestant > 0 && form.value.ventilations.length > 0) {
      // Répartir le taux restant sur la dernière ventilation
      const derniereIndex = form.value.ventilations.length - 1;
      form.value.ventilations[derniereIndex].taux = Number(
        (Number(form.value.ventilations[derniereIndex].taux || 0) + tauxRestant).toFixed(2)
      );
    }
    
    if (ventilationToRemove.id_affectation) {
      await fetchData();
    }
  };

  // Suppression par sous-compte
  const removeBySousCompte = async (id_sous_compte) => {
    if (confirm("Voulez-vous supprimer toutes les affectations de ce sous-compte ?")) {
      try {
        await axios.delete(`${API_URL}/affectations/sous-compte/${id_sous_compte}`);
        await fetchData();
        return true;
      } catch (error) {
        console.error('Erreur suppression par sous-compte:', error);
        alert("Erreur lors de la suppression");
        return false;
      }
    }
    return false;
  };

  // Groupement des affectations
  const affectationsGrouped = computed(() => {
    const grouped = {};
    
    affectations.value.forEach(aff => {
      const key = aff.Id_Sous_compte;
      if (!grouped[key]) {
        grouped[key] = {
          Id_Sous_compte: aff.Id_Sous_compte,
          Id_Compte: aff.sous_compte?.Id_Compte,
          Code_sous_compte: aff.sous_compte?.Code_sous_compte,
          Libelle: aff.sous_compte?.Libelle,
          ventilations: []
        };
      }
      grouped[key].ventilations.push({
        id_affectation: aff.id_affectation,
        id_centre: aff.id_centre,
        id_type: aff.id_type, // ← NOUVEAU CHAMP
        centre_nom: aff.centre?.nom,
        type_nom: types.value.find(t => t.id_type === aff.id_type)?.code || 'N/A', // ← NOUVEAU : Nom du type
        taux: aff.taux,
        description: aff.description
      });
    });
    
    return Object.values(grouped);
  });

  // Fonction pour ajuster automatiquement le dernier taux si nécessaire
  const adjustTauxIfNeeded = () => {
    const total = totalTauxForm.value;
    if (Math.abs(total - 100) > 0.01 && form.value.ventilations.length > 0) {
      // Ajuster le dernier taux pour atteindre 100%
      const lastIndex = form.value.ventilations.length - 1;
      const autresTaux = form.value.ventilations.slice(0, -1).reduce((sum, v) => sum + Number(v.taux || 0), 0);
      form.value.ventilations[lastIndex].taux = Number((100 - autresTaux).toFixed(2));
    }
  };

  // Fonctions pour gérer l'édition dans le tableau
  const addVentilationToTable = () => {
    if (!form.value.ventilations) form.value.ventilations = [];
    
    const totalTaux = form.value.ventilations.reduce((sum, v) => {
      return sum + Number(Number(v.taux || 0).toFixed(2));
    }, 0);
    
    const remainingTaux = Number((100 - totalTaux).toFixed(2));
    
    if (remainingTaux <= 0) {
      alert("Le total des taux atteint déjà 100% !");
      return;
    }

    form.value.ventilations.push({
      id_centre: null,
      id_type: null, // ← NOUVEAU CHAMP
      taux: Number(remainingTaux.toFixed(2)),
      description: ""
    });
  };

  const removeVentilationFromTable = (index) => {
    if (form.value.ventilations.length <= 1) {
      alert("Vous devez avoir au moins une ventilation !");
      return;
    }

    const ventilationToRemove = form.value.ventilations[index];
    
    if (ventilationToRemove.id_affectation) {
      if (!confirm("Supprimer cette ventilation de la liste ? Elle sera supprimée de la base de données lors de la sauvegarde.")) {
        return;
      }
    }

    form.value.ventilations.splice(index, 1);
    
    // Redistribution automatique
    const totalActuel = form.value.ventilations.reduce((sum, v) => sum + Number(v.taux || 0), 0);
    const tauxRestant = 100 - totalActuel;
    
    if (tauxRestant > 0 && form.value.ventilations.length > 0) {
      const derniereIndex = form.value.ventilations.length - 1;
      form.value.ventilations[derniereIndex].taux = Number(
        (Number(form.value.ventilations[derniereIndex].taux || 0) + tauxRestant).toFixed(2)
      );
    }
  };

  const saveTableModifications = async () => {
    const success = await save();
    if (success) {
      switchToViewMode();
    }
  };

  const cancelTableModifications = () => {
    switchToViewMode();
  };

  // Computed pour le total dans le tableau
  const totalTauxForm = computed(() => {
    return form.value.ventilations?.reduce((sum, vent) => {
      return sum + Number(vent.taux || 0);
    }, 0) || 0;
  });

  const switchToEditMode = () => {
    if (selectedGroup.value) {
      editGroup(selectedGroup.value);
      detailsMode.value = 'edit';
    }
  };

  const switchToViewMode = () => {
    detailsMode.value = 'view';
    if (selectedGroup.value) {
      fetchData().then(() => {
        const updatedGroup = affectationsGrouped.value.find(
          group => group.Id_Sous_compte === selectedGroup.value.Id_Sous_compte
        );
        if (updatedGroup) {
          selectedGroup.value = updatedGroup;
        }
      });
    }
  };

  // NOUVEAU : Fonction pour obtenir le nom du type
  const getTypeName = (id_type) => {
    const type = types.value.find(t => t.id_type === id_type);
    return type ? type.code : 'N/A';
  };

  return {
    affectations, centres, comptes, types, file, showVentilationForm, switchToEditMode, switchToViewMode,
    showDetails, totalTauxClass, isFormValid, hasDuplicateCentres,
    selectedGroup,
    editingVentilation, cancelTableModifications, saveTableModifications, removeVentilationFromTable,
    form, isEditing, message, addVentilationToTable,
    fetchData, save, remove, resetForm, onFileChange, uploadFile,
    searchTerm, suggestions, showSuggestions,
    searchCompte, selectCompte,
    filterSearchTerm,
    filterSelectedCentre,
    filteredAffectations, detailsMode,
    editVentilation,
    saveVentilation,
    removeVentilation, adjustTauxIfNeeded,
    showVentilationDetails,
    updateMultipleVentilations,
    editGroup, removeBySousCompte,
    affectationsGrouped,
    getTypeName // ← NOUVEAU : Exposer la fonction
  };
}