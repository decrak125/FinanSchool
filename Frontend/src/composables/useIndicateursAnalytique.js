import { ref } from "vue";
import axios from "axios";

export function useIndicateursAnalytique() {
  const API_URL = "http://127.0.0.1:8000/api";
  
  const indicateurs = ref([]);
  const indicateur = ref(null);
  const loading = ref(false);
  const error = ref(null);

  // 📌 Récupérer tous les indicateurs
  const fetchIndicateurs = async () => {
    try {
      loading.value = true;
      error.value = null;
      const response = await axios.get(`${API_URL}/indicateurs-analytique`);
      indicateurs.value = response.data.data;
      return response.data.data;
    } catch (err) {
      error.value = err.response?.data?.message || "Erreur lors de la récupération des indicateurs";
      console.error("Erreur fetchIndicateurs:", err);
      return null;
    } finally {
      loading.value = false;
    }
  };

  // 📌 Récupérer un indicateur par ID
  const fetchIndicateurById = async (id) => {
    try {
      loading.value = true;
      error.value = null;
      const response = await axios.get(`${API_URL}/indicateurs-analytique/${id}`);
      indicateur.value = response.data.data;
      return response.data.data;
    } catch (err) {
      error.value = err.response?.data?.message || "Erreur lors de la récupération de l'indicateur";
      console.error("Erreur fetchIndicateurById:", err);
      return null;
    } finally {
      loading.value = false;
    }
  };

  // 📌 Créer un nouvel indicateur
  const createIndicateur = async (data) => {
    try {
      loading.value = true;
      error.value = null;
      const response = await axios.post(`${API_URL}/indicateurs-analytique`, data);
      indicateurs.value.push(response.data.data);
      return response.data;
    } catch (err) {
      error.value = err.response?.data?.message || "Erreur lors de la création de l'indicateur";
      console.error("Erreur createIndicateur:", err);
      throw err;
    } finally {
      loading.value = false;
    }
  };

  // 📌 Mettre à jour un indicateur
  const updateIndicateur = async (id, data) => {
    try {
      loading.value = true;
      error.value = null;
      const response = await axios.put(`${API_URL}/indicateurs-analytique/${id}`, data);
      
      // Mettre à jour dans la liste
      const index = indicateurs.value.findIndex(i => i.id_indicateur_analytique == id);
      if (index !== -1) {
        indicateurs.value[index] = response.data.data;
      }
      
      // Mettre à jour l'indicateur courant
      if (indicateur.value?.id_indicateur_analytique == id) {
        indicateur.value = response.data.data;
      }
      
      return response.data;
    } catch (err) {
      error.value = err.response?.data?.message || "Erreur lors de la mise à jour de l'indicateur";
      console.error("Erreur updateIndicateur:", err);
      throw err;
    } finally {
      loading.value = false;
    }
  };

  // 📌 Supprimer un indicateur
  const deleteIndicateur = async (id) => {
    try {
      loading.value = true;
      error.value = null;
      await axios.delete(`${API_URL}/indicateurs-analytique/${id}`);
      
      // Retirer de la liste
      indicateurs.value = indicateurs.value.filter(i => i.id_indicateur_analytique != id);
      
      // Réinitialiser l'indicateur courant si c'est celui-ci
      if (indicateur.value?.id_indicateur_analytique == id) {
        indicateur.value = null;
      }
      
      return { success: true, message: "Indicateur supprimé avec succès" };
    } catch (err) {
      error.value = err.response?.data?.message || "Erreur lors de la suppression de l'indicateur";
      console.error("Erreur deleteIndicateur:", err);
      throw err;
    } finally {
      loading.value = false;
    }
  };

  // 📌 Rechercher par catégorie
  const searchByCategorie = async (categorie) => {
    try {
      loading.value = true;
      error.value = null;
      const response = await axios.get(`${API_URL}/indicateurs-analytique/categorie/${categorie}`);
      return response.data.data;
    } catch (err) {
      error.value = err.response?.data?.message || "Erreur lors de la recherche";
      console.error("Erreur searchByCategorie:", err);
      return null;
    } finally {
      loading.value = false;
    }
  };

  return {
    // Données
    indicateurs,
    indicateur,
    loading,
    error,
    
    // Méthodes
    fetchIndicateurs,
    fetchIndicateurById,
    createIndicateur,
    updateIndicateur,
    deleteIndicateur,
    searchByCategorie
  };
}