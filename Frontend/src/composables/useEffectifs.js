import { ref, onMounted, computed } from "vue";
import axios from "axios";

export function useEffectifs() {
  const API_URL = "http://127.0.0.1:8000/api"; // variable pour l'API

  const effectifs = ref([]);
  const exercices = ref([]);
  const exercicesPrecedents = ref([]); // Nouveau tableau pour les exercices précédents
  const currentExercice = ref(null); // Pour stocker l'exercice actuellement ouvert
  const form = ref({ Id_Exercice_comptable: "", nombre_eleves: 0 });
  const isEditing = ref(false);
  const editingId = ref(null);
  const loading = ref(true);
  const nombreLignesLoader = ref(10);

  // Variables pour les filtres
  const searchTerm = ref("");
  const selectedExercice = ref("");

  const token = localStorage.getItem("token"); // Récupérer le token

  if (!token) {
    window.location.href = "/";
  } else {
    axios.defaults.headers.common["Authorization"] = `Bearer ${token}`;
  }

  // Charger toutes les données nécessaires
  const fetchEffectifs = async () => {
    loading.value = true;
    const res = await axios.get(`${API_URL}/effectifs-eleves`);
    effectifs.value = res.data.data;
    loading.value = false;
    nombreLignesLoader.value = effectifs.value.length || 10;
  };

  const fetchExercices = async () => {
    try {
      const res = await axios.get(`${API_URL}/exercices`);
      exercices.value = res.data.data || res.data;
      
      // Trouver l'exercice actuellement ouvert (statut = OUVERT)
      currentExercice.value = exercices.value.find(exo => exo.Statut === 'OUVERT');
      
      // Filtrer pour n'avoir que les exercices précédents (clôturés ou provisoires avant l'exercice ouvert)
      exercicesPrecedents.value = exercices.value.filter(exo => {
        // Si on a un exercice ouvert, on prend tous les exercices dont la date de fin est avant la date de début de l'exercice ouvert
        if (currentExercice.value) {
          return new Date(exo.Date_fin) <= new Date(currentExercice.value.Date_fin);
        }
        // Si pas d'exercice ouvert, on prend tous les exercices clôturés
        return exo.Statut === 'CLOTURE';
      });
      
      // Trier par date de fin décroissante (du plus récent au plus ancien)
      exercicesPrecedents.value.sort((a, b) => new Date(b.Date_fin) - new Date(a.Date_fin));
      
    } catch (error) {
      console.error("Erreur lors du chargement des exercices:", error);
    }
  };

  // Fonction pour vérifier et copier l'effectif de l'exercice précédent
  const checkAndCopyEffectif = async (dateDebut, dateFin) => {
    try {
      const res = await axios.post(`${API_URL}/effectifs-eleves/check-copy`, {
        date_debut: dateDebut,
        date_fin: dateFin
      });
      return res.data;
    } catch (error) {
      console.error("Erreur lors de la copie d'effectif:", error);
      return { success: false, message: error.response?.data?.message || "Erreur lors de la copie" };
    }
  };

  // Computed property pour les effectifs filtrés
  const filteredEffectifs = computed(() => {
    return effectifs.value.filter(effectif => {
      // Filtre par recherche (nombre d'élèves ou année)
      const matchesSearch = searchTerm.value === "" || 
        effectif.nombre_eleves.toString().includes(searchTerm.value) ||
        (effectif.exercice_comptable && 
         effectif.exercice_comptable.Annee_fiscale.toString().includes(searchTerm.value));
      
      // Filtre par exercice (parmi les exercices précédents)
      const matchesExercice = selectedExercice.value === "" || 
        effectif.Id_Exercice_comptable.toString() === selectedExercice.value;
      
      return matchesSearch && matchesExercice;
    });
  });

  // Réinitialiser les filtres
  const resetFilters = () => {
    searchTerm.value = "";
    selectedExercice.value = "";
  };

  // Ajouter / Mettre à jour
  const saveEffectif = async () => {
    try {
      if (isEditing.value) {
        await axios.put(`${API_URL}/effectifs-eleves/${editingId.value}`, form.value);
      } else {
        // Pour la création, on ne permet que les exercices précédents (pas l'exercice ouvert)
        const selectedExo = exercices.value.find(e => e.Id_Exercice_comptable == form.value.Id_Exercice_comptable);
        if (selectedExo && selectedExo.Statut === 'OUVERT') {
          return { 
            success: false, 
            message: "Impossible de créer un effectif pour un exercice ouvert. Utilisez la fonction 'Copier depuis exercice'." 
          };
        }
        
        await axios.post(`${API_URL}/effectifs-eleves`, form.value);
      }
      resetForm();
      fetchEffectifs();
      return { success: true };
    } catch (error) {
      console.error("Erreur lors de la sauvegarde:", error);
      return { 
        success: false, 
        message: error.response?.data?.message || "Erreur lors de la sauvegarde" 
      };
    }
  };

  // Modifier
  const editEffectif = (effectif) => {
    form.value = { 
      Id_Exercice_comptable: effectif.Id_Exercice_comptable, 
      nombre_eleves: effectif.nombre_eleves 
    };
    isEditing.value = true;
    editingId.value = effectif.id;
  };

  // Annuler modification
  const cancelEdit = () => resetForm();

  // Supprimer
  const deleteEffectif = async (id) => {
    try {
      await axios.delete(`${API_URL}/effectifs-eleves/${id}`);
      fetchEffectifs();
      return { success: true };
    } catch (error) {
      console.error("Erreur lors de la suppression:", error);
      return { 
        success: false, 
        message: error.response?.data?.message || "Erreur lors de la suppression" 
      };
    }
  };

  // Reset formulaire
  const resetForm = () => {
    form.value = { Id_Exercice_comptable: "", nombre_eleves: 0 };
    isEditing.value = false;
    editingId.value = null;
  };

  // Fonction pour afficher le nom de l'exercice
  const getExerciceName = (id) => {
    const exercice = exercices.value.find((e) => e.Id_Exercice_comptable === id);
    return exercice ? `Exercice ${exercice.Annee_fiscale}` : "";
  };

  // Fonction pour afficher les dates de l'exercice
  const getExerciceDates = (id) => {
    const exercice = exercices.value.find((e) => e.Id_Exercice_comptable === id);
    return exercice ? `${exercice.Date_debut} - ${exercice.Date_fin}` : "";
  };

  // Fonction pour obtenir l'état de l'exercice
  const getExerciceStatut = (id) => {
    const exercice = exercices.value.find((e) => e.Id_Exercice_comptable === id);
    return exercice ? exercice.Statut : "";
  };

  // Fonction pour vérifier si un exercice est l'exercice actuel ouvert
  const isCurrentExercice = (id) => {
    return currentExercice.value && currentExercice.value.Id_Exercice_comptable === id;
  };

  // Fonction pour obtenir l'exercice précédent le plus récent
  const getMostRecentPreviousExercice = () => {
    if (exercicesPrecedents.value.length > 0) {
      return exercicesPrecedents.value[0]; // Le premier car déjà trié par date décroissante
    }
    return null;
  };

  // Charger les données au montage
  onMounted(() => {
    fetchEffectifs();
    fetchExercices();
  });

  return {
    API_URL,
    effectifs,
    exercices: exercicesPrecedents, // On expose uniquement les exercices précédents
    exercicesAll: exercices, // On garde tous les exercices pour référence
    currentExercice,
    loading,
    nombreLignesLoader,
    form,
    isEditing,
    editingId,
    // Variables et fonctions pour les filtres
    searchTerm,
    selectedExercice,
    filteredEffectifs,
    resetFilters,
    // Fonctions principales
    fetchEffectifs,
    fetchExercices,
    checkAndCopyEffectif,
    saveEffectif,
    editEffectif,
    cancelEdit,
    deleteEffectif,
    resetForm,
    getExerciceName,
    getExerciceDates,
    getExerciceStatut,
    isCurrentExercice,
    getMostRecentPreviousExercice
  };
}