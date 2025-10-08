import { ref, computed, onMounted } from "vue";
import axios from "axios";

const API_URL = "http://127.0.0.1:8000/api";

export function useAffectations() {
  const affectations = ref([]);
  const centres = ref([]);
  const comptes = ref([]);
  // Nouvelles variables pour l'édition par ventilation
  const editingVentilation = ref(null);
  const showVentilationForm = ref(false);
  const form = ref({
    Id_Compte: null,
    ventilations: []
  });
  const isEditing = ref(false);
  const editingId = ref(null);

  // ===== Pour recherche compte =====
  const searchTerm = ref("");
  const suggestions = ref([]);
  const showSuggestions = ref(false);

  // ===== Variables pour les filtres =====
  const filterSearchTerm = ref("");
  const filterSelectedCentre = ref("");

  // Fetch initial data
  const fetchData = async () => {
    const [resAffect, resCentres, resComptes] = await Promise.all([
      axios.get(`${API_URL}/affectations`),
      axios.get(`${API_URL}/centres`),
      axios.get(`${API_URL}/comptes`)
    ]);
    affectations.value = resAffect.data;
    centres.value = resCentres.data;
    comptes.value = resComptes.data;
    
  };

  // Computed property pour les affectations filtrées
  const filteredAffectations = computed(() => {
    return affectations.value.filter(affectation => {
      // Filtre par recherche (Code_sous_compte ou Libelle)
      const matchesSearch = filterSearchTerm.value === "" || 
        (affectation.sous_compte?.Code_sous_compte?.toLowerCase().includes(filterSearchTerm.value.toLowerCase()) ||
         affectation.sous_compte?.Libelle?.toLowerCase().includes(filterSearchTerm.value.toLowerCase()));
      
      // Filtre par centre
      const matchesCentre = filterSelectedCentre.value === "" || 
        affectation.id_centre?.toString() === filterSelectedCentre.value;
      
      return matchesSearch && matchesCentre;
    });
  });

  // Réinitialiser les filtres
  const resetFilters = () => {
    filterSearchTerm.value = "";
    filterSelectedCentre.value = "";
  };

  const save = async () => {
  
    // Convertir les taux en nombres et calculer le total
    const totalTaux = form.value.ventilations?.reduce((sum, v) => {
      const taux = Number(v.taux) || 0;
      return sum + taux;
    }, 0) || 0;
  
    if (Math.abs(totalTaux - 100) > 0.01) {
      return alert(`Le total des taux doit être égal à 100% (actuellement: ${totalTaux}%)`);
    }
  
    try {
      if (isEditing.value) {
        // 🔄 MODE ÉDITION - Utiliser saveVentilation pour chaque ventilation
        await updateVentilationsWithSaveVentilation();
      } else {
        // Validation de base
        if (!isEditing.value && !form.value.Id_Compte) {
          return alert("Sélectionnez un compte");
        }
        // ➕ MODE CRÉATION - Créer nouvelles affectations
        await axios.post(`${API_URL}/affectations`, form.value);
      }
      
      resetForm();
      fetchData();
      openForm.value = false;
    } catch (error) {
      console.error('Erreur:', error);
      alert(error.response?.data?.message || 'Erreur lors de la sauvegarde');
    }
  };
  
  // Nouvelle méthode qui utilise saveVentilation en boucle
  const updateVentilationsWithSaveVentilation = async () => {
    const wasDetailsOpen = showDetails.value;
    const currentGroup = selectedGroup.value;
    
    // Boucler sur chaque ventilation et utiliser la logique existante de saveVentilation
    for (const ventilation of form.value.ventilations) {
      if (ventilation.id_affectation) {
        // Pour les ventilations existantes, utiliser saveVentilation
        editingVentilation.value = { ...ventilation };
        await saveVentilationDirect(); // Version simplifiée de saveVentilation
      } else {
        // Pour les nouvelles ventilations, utiliser la création normale
        await axios.post(`${API_URL}/affectations`, {
          Id_Compte: form.value.Id_Compte,
          ventilations: [{
            id_centre: ventilation.id_centre,
            taux: ventilation.taux,
            description: ventilation.description
          }]
        });
      }
    }
    
    // Rafraîchir les données
    await fetchData();
    
    // Rouvrir les détails si c'était ouvert
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
  };
  
  // Version simplifiée de saveVentilation sans gestion UI
  const saveVentilationDirect = async () => {
    if (!editingVentilation.value) return;
    
    await axios.put(`${API_URL}/affectations/${editingVentilation.value.id_affectation}`, {
      id_centre: editingVentilation.value.id_centre,
      taux: editingVentilation.value.taux,
      description: editingVentilation.value.description
    });
    
    editingVentilation.value = null;
  };
  
  const updateMultipleVentilations = async () => {
    // Récupérer les affectations existantes pour ce compte
    const existingAffectations = affectations.value.filter(
      aff => aff.sous_compte?.Id_Compte === form.value.Id_Compte
    );
  
    const operations = [];
  
    // Séparer les ventilations à créer, update et supprimer
    const ventilationsToKeep = form.value.ventilations.filter(v => v.id_affectation);
    const ventilationsToCreate = form.value.ventilations.filter(v => !v.id_affectation);
    
    // 1. Supprimer les ventilations qui n'existent plus
    const ventilationsToDelete = existingAffectations.filter(
      existing => !ventilationsToKeep.some(v => v.id_affectation === existing.id_affectation)
    );
    
    ventilationsToDelete.forEach(aff => {
      operations.push(axios.delete(`${API_URL}/affectations/${aff.id_affectation}`));
    });
  
    // 2. Mettre à jour les ventilations existantes
    ventilationsToKeep.forEach(vent => {
      operations.push(
        axios.put(`${API_URL}/affectations/${vent.id_affectation}`, {
          id_centre: vent.id_centre,
          taux: vent.taux,
          description: vent.description
        })
      );
    });
  
    // 3. Créer les nouvelles ventilations
    if (ventilationsToCreate.length > 0) {
      operations.push(
        axios.post(`${API_URL}/affectations`, {
          Id_Compte: form.value.Id_Compte,
          ventilations: ventilationsToCreate
        })
      );
    }
  
    await Promise.all(operations);
  };
  

  const edit = (aff) => {
    form.value = {
      Id_Compte: aff.sous_compte?.Id_Compte,
      ventilations: aff.ventilations?.map(v => ({
        id_centre: v.id_centre,
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
  

  const remove = async (id) => {
    if (confirm("Supprimer cette affectation ?")) {
      await axios.delete(`${API_URL}/affectations/${id}`);
      fetchData();
    }
  };
// Pour éditer une ventilation individuelle
const editVentilation = (ventilation) => {
  editingVentilation.value = { ...ventilation };
  showVentilationForm.value = true;
};
// Nouvelles variables
const showDetails = ref(false);
const selectedGroup = ref(null);
// Méthodes pour gérer les détails
const showVentilationDetails = (group) => {
  selectedGroup.value = group;
  showDetails.value = true;
};
// Pour éditer tout un groupe (créer/modifier plusieurs ventilations)
const editGroup = (group) => {
  form.value = {
    Id_Compte: group.Id_Compte, // Stockez l'Id_Compte dans votre groupe
    ventilations: group.ventilations.map(v => ({
      id_affectation: v.id_affectation, // Important pour les updates
      id_centre: v.id_centre,
      taux: v.taux,
      description: v.description || ""
    }))
  };

  // Mettre à jour la recherche avec les informations du compte
  searchTerm.value = `${group.Code_sous_compte} - ${group.Libelle}`;
  
  isEditing.value = true;
  editingId.value = group.Id_Sous_compte;
};

  // Sauvegarder une ventilation individuelle
  const saveVentilation = async () => {
    if (!editingVentilation.value) return;
    
    try {
      await axios.put(`${API_URL}/affectations/${editingVentilation.value.id_affectation}`, {
        id_centre: editingVentilation.value.id_centre,
        taux: editingVentilation.value.taux,
        description: editingVentilation.value.description
      });
      
      // Fermer et rouvrir les popups pour forcer le rafraîchissement
      const wasDetailsOpen = showDetails.value;
      const currentGroup = selectedGroup.value;
      
      showVentilationForm.value = false;
      showDetails.value = false;
      editingVentilation.value = null;
      
      await fetchData();
      
      // Rouvrir les détails si c'était ouvert
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
  // Méthode pour mettre à jour plusieurs ventilations
  // const updateMultipleVentilations = async (ventilations) => {
  //   const promises = ventilations.map(vent => {
  //     if (vent.id_affectation) {
  //       // Mise à jour d'une ventilation existante
  //       return axios.put(`${API_URL}/affectations/${vent.id_affectation}`, {
  //         id_centre: vent.id_centre,
  //         taux: vent.taux,
  //         description: vent.description
  //       });
  //     } else {
  //       // Création d'une nouvelle ventilation
  //       return axios.post(`${API_URL}/affectations`, {
  //         Id_Compte: form.value.Id_Compte,
  //         ventilations: [vent]
  //       });
  //     }
  //   });
    
  //   await Promise.all(promises);
  // };

const resetForm = () => {
  form.value = { 
    Id_Compte: null, 
    ventilations: []  // ← Garder la structure avec ventilations
  };
  searchTerm.value = "";
  showSuggestions.value = false;
  isEditing.value = false;
  editingId.value = null;
};

  // Recherche dynamique des comptes
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

  const selectCompte = (compte) => {
    form.value.Id_Compte = compte.Id_Compte;
    searchTerm.value = `${compte.Code_compte} - ${compte.Libelle}`;
    showSuggestions.value = false;
  };

  // ----------------------------------

  const fileInput = ref(null);

  const message = ref({ text: "", type: "" }); // type = 'success' ou 'error'
  const importSuccess = ref(false);

  // Classe CSS dynamique pour le message
  const messageClass = computed(() => {
    return message.value.type === "success"
      ? "bg-green-100 text-green-800 border border-green-300"
      : "bg-red-100 text-red-800 border border-red-300";
  });

  // Gestion import CSV/Excel pour les affectations
  const file = ref(null);

  const onFileChange = (e) => {
    file.value = e.target.files[0];
  };

  const uploadFile = async () => {
    if (!file.value) {
      message.value = { text: "Veuillez sélectionner un fichier.", type: "error" };
      importSuccess.value = false;
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
      importSuccess.value = true;
      file.value = null;
      fetchData(); // rafraîchir les données après import
    } catch (error) {
      message.value = {
        text: error.response?.data?.message || "Erreur lors de l'import.",
        type: "error",
      };
      importSuccess.value = false;
    }
  };

// Dans useAffectations.js
const affectationsGrouped = computed(() => {
  const grouped = {};
  
  affectations.value.forEach(aff => {
    const key = aff.Id_Sous_compte;
    if (!grouped[key]) {
      grouped[key] = {
        Id_Sous_compte: aff.Id_Sous_compte,
        Code_sous_compte: aff.sous_compte?.Code_sous_compte,
        Libelle: aff.sous_compte?.Libelle,
        ventilations: []
      };
    }
    grouped[key].ventilations.push({
      id_affectation: aff.id_affectation,
      id_centre: aff.id_centre,
      centre_nom: aff.centre?.nom,
      taux: aff.taux,
      description: aff.description
    });
  });
  
  return Object.values(grouped);
});

// Ajouter une ventilation avec gestion intelligente du taux
const addVentilation = () => {
  if (!form.value.ventilations) form.value.ventilations = [];
  
  const totalTaux = form.value.ventilations.reduce((sum, v) => sum + Number(v.taux || 0), 0);
  const remainingTaux = 100 - totalTaux;
  
  if (remainingTaux <= 0) {
    alert("Le total des taux atteint déjà 100% !");
    return;
  }

  form.value.ventilations.push({
    id_centre: null,
    taux: Math.min(remainingTaux, 100), // Ne pas dépasser 100%
    description: ""
  });
};

// Supprimer une ventilation avec redistribution du taux
const removeVentilation = async (index) => {
  if (form.value.ventilations.length <= 1) {
    alert("Vous devez avoir au moins une ventilation !");
    return;
  }

  const ventilationToRemove = form.value.ventilations[index];
  
  // Si c'est une ventilation existante (avec id_affectation), supprimer de la BDD
  if (ventilationToRemove.id_affectation) {
    if (!confirm("Supprimer cette ventilation de la base de données ?")) {
      return; // Annuler si l'utilisateur refuse
    }
    
    try {
      await axios.delete(`${API_URL}/affectations/${ventilationToRemove.id_affectation}`);
    } catch (error) {
      console.error('Erreur suppression:', error);
      alert("Erreur lors de la suppression");
      return;
    }
  }

  // Redistribuer le taux avant de supprimer du formulaire
  const removedTaux = Number(ventilationToRemove.taux || 0);
  form.value.ventilations.splice(index, 1);

  // Redistribuer le taux supprimé sur les autres ventilations
  if (form.value.ventilations.length > 0 && removedTaux > 0) {
    const tauxParVentilation = removedTaux / form.value.ventilations.length;
    form.value.ventilations.forEach(vent => {
      vent.taux = Number((Number(vent.taux || 0) + tauxParVentilation).toFixed(2));
    });
  }
  
  // Rafraîchir les données si suppression BDD
  if (ventilationToRemove.id_affectation) {
    await fetchData();
  }
};

// Computed properties pour la validation
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
  const centres = form.value.ventilations.map(v => v.id_centre).filter(Boolean);
  return new Set(centres).size !== centres.length;
});

const isFormValid = computed(() => {
  if (!form.value.ventilations || form.value.ventilations.length === 0) return false;
  if (totalTaux.value !== 100) return false;
  if (hasDuplicateCentres.value) return false;
  
  // Vérifier que toutes les ventilations ont un centre et un taux
  return form.value.ventilations.every(vent => 
    vent.id_centre && vent.taux !== null && vent.taux !== undefined
  );
});

  return {
    affectations, centres, comptes, file, showVentilationForm,
    showDetails, totalTauxClass,isFormValid,hasDuplicateCentres,
    selectedGroup,
    editingVentilation,
    form, isEditing, fileInput, message, importSuccess,
    fetchData, save, edit, remove, resetForm, onFileChange, uploadFile,
    searchTerm, suggestions, showSuggestions,
    searchCompte, selectCompte,
    filterSearchTerm,
    filterSelectedCentre,
    filteredAffectations,
    resetFilters,
    editVentilation,
    saveVentilation,
    removeVentilation,
    showVentilationDetails,
    updateMultipleVentilations,
    editGroup,
    affectationsGrouped
  };
}