import { ref } from "vue";
import axios from "axios";

export function useNiveauxAlerte() {
  const API_URL = "http://127.0.0.1:8000/api";
  
  const niveaux = ref([]);
  const niveau = ref(null);
  const loading = ref(false);
  const error = ref(null);

  // 📌 Récupérer tous les niveaux
  const fetchNiveaux = async () => {
    try {
      loading.value = true;
      error.value = null;
      const response = await axios.get(`${API_URL}/niveaux-alerte`);
      niveaux.value = response.data.data;
      return response.data.data;
    } catch (err) {
      error.value = err.response?.data?.message || "Erreur lors de la récupération des niveaux d'alerte";
      console.error("Erreur fetchNiveaux:", err);
      return null;
    } finally {
      loading.value = false;
    }
  };

  // 📌 Récupérer un niveau par ID
  const fetchNiveauById = async (id) => {
    try {
      loading.value = true;
      error.value = null;
      const response = await axios.get(`${API_URL}/niveaux-alerte/${id}`);
      niveau.value = response.data.data;
      return response.data.data;
    } catch (err) {
      error.value = err.response?.data?.message || "Erreur lors de la récupération du niveau d'alerte";
      console.error("Erreur fetchNiveauById:", err);
      return null;
    } finally {
      loading.value = false;
    }
  };

  // 📌 Créer un nouveau niveau
  const createNiveau = async (data) => {
    try {
      loading.value = true;
      error.value = null;
      const response = await axios.post(`${API_URL}/niveaux-alerte`, data);
      niveaux.value.push(response.data.data);
      return response.data;
    } catch (err) {
      error.value = err.response?.data?.message || "Erreur lors de la création du niveau d'alerte";
      console.error("Erreur createNiveau:", err);
      throw err;
    } finally {
      loading.value = false;
    }
  };

  // 📌 Mettre à jour un niveau
  const updateNiveau = async (id, data) => {
    try {
      loading.value = true;
      error.value = null;
      const response = await axios.put(`${API_URL}/niveaux-alerte/${id}`, data);
      
      // Mettre à jour dans la liste
      const index = niveaux.value.findIndex(n => n.id_niveau_alerte == id);
      if (index !== -1) {
        niveaux.value[index] = response.data.data;
      }
      
      // Mettre à jour le niveau courant
      if (niveau.value?.id_niveau_alerte == id) {
        niveau.value = response.data.data;
      }
      
      return response.data;
    } catch (err) {
      error.value = err.response?.data?.message || "Erreur lors de la mise à jour du niveau d'alerte";
      console.error("Erreur updateNiveau:", err);
      throw err;
    } finally {
      loading.value = false;
    }
  };

  // 📌 Supprimer un niveau
  const deleteNiveau = async (id) => {
    try {
      loading.value = true;
      error.value = null;
      await axios.delete(`${API_URL}/niveaux-alerte/${id}`);
      
      // Retirer de la liste
      niveaux.value = niveaux.value.filter(n => n.id_niveau_alerte != id);
      
      // Réinitialiser le niveau courant si c'est celui-ci
      if (niveau.value?.id_niveau_alerte == id) {
        niveau.value = null;
      }
      
      return { success: true, message: "Niveau d'alerte supprimé avec succès" };
    } catch (err) {
      error.value = err.response?.data?.message || "Erreur lors de la suppression du niveau d'alerte";
      console.error("Erreur deleteNiveau:", err);
      throw err;
    } finally {
      loading.value = false;
    }
  };

  return {
    // Données
    niveaux,
    niveau,
    loading,
    error,
    
    // Méthodes
    fetchNiveaux,
    fetchNiveauById,
    createNiveau,
    updateNiveau,
    deleteNiveau
  };
}