import { ref } from "vue";
import axios from "axios";

export function useParametresAnalytique() {
  const API_URL = "http://127.0.0.1:8000/api";
  
  const indicateurs = ref([]);
  const currentIndicateur = ref(null);
  const interpretations = ref([]);
  const niveaux = ref([]);
  const loading = ref(false);
  const error = ref(null);

  // 📌 Récupérer tous les indicateurs avec leurs interprétations
  const fetchIndicateursComplets = async () => {
    try {
      loading.value = true;
      error.value = null;
      
      const [indicateursRes, niveauxRes] = await Promise.all([
        axios.get(`${API_URL}/indicateurs-analytique`),
        axios.get(`${API_URL}/niveaux-alerte`)
      ]);
      
      indicateurs.value = indicateursRes.data.data;
      niveaux.value = niveauxRes.data.data;
      
      return indicateurs.value;
    } catch (err) {
      error.value = err.response?.data?.message || "Erreur lors de la récupération des données";
      console.error("Erreur fetchIndicateursComplets:", err);
      return null;
    } finally {
      loading.value = false;
    }
  };

  // 📌 Récupérer les détails d'un indicateur avec ses interprétations
  const fetchIndicateurDetails = async (id) => {
    try {
      loading.value = true;
      error.value = null;
      
      const [indicateurRes, interpretationsRes] = await Promise.all([
        axios.get(`${API_URL}/indicateurs-analytique/${id}`),
        axios.get(`${API_URL}/interpretations-indicateur/indicateur/${id}`)
      ]);
      
      currentIndicateur.value = indicateurRes.data.data;
      interpretations.value = interpretationsRes.data.data;
      
      return {
        indicateur: currentIndicateur.value,
        interpretations: interpretations.value
      };
    } catch (err) {
      error.value = err.response?.data?.message || "Erreur lors de la récupération des détails";
      console.error("Erreur fetchIndicateurDetails:", err);
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
      if (currentIndicateur.value?.id_indicateur_analytique == id) {
        currentIndicateur.value = response.data.data;
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
      if (currentIndicateur.value?.id_indicateur_analytique == id) {
        currentIndicateur.value = null;
        interpretations.value = [];
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

  // 📌 Créer une nouvelle interprétation
  const createInterpretation = async (data) => {
    try {
      loading.value = true;
      error.value = null;
      const response = await axios.post(`${API_URL}/interpretations-indicateur`, data);
      interpretations.value.push(response.data.data);
      return response.data;
    } catch (err) {
      error.value = err.response?.data?.message || "Erreur lors de la création de l'interprétation";
      console.error("Erreur createInterpretation:", err);
      throw err;
    } finally {
      loading.value = false;
    }
  };

  // 📌 Mettre à jour une interprétation
  const updateInterpretation = async (id, data) => {
    try {
      loading.value = true;
      error.value = null;
      const response = await axios.put(`${API_URL}/interpretations-indicateur/${id}`, data);
      
      // Mettre à jour dans la liste
      const index = interpretations.value.findIndex(i => i.id_interpretation_indicateur == id);
      if (index !== -1) {
        interpretations.value[index] = response.data.data;
      }
      
      return response.data;
    } catch (err) {
      error.value = err.response?.data?.message || "Erreur lors de la mise à jour de l'interprétation";
      console.error("Erreur updateInterpretation:", err);
      throw err;
    } finally {
      loading.value = false;
    }
  };

  // 📌 Supprimer une interprétation
  const deleteInterpretation = async (id) => {
    try {
      loading.value = true;
      error.value = null;
      await axios.delete(`${API_URL}/interpretations-indicateur/${id}`);
      
      // Retirer de la liste
      interpretations.value = interpretations.value.filter(i => i.id_interpretation_indicateur != id);
      
      return { success: true, message: "Interprétation supprimée avec succès" };
    } catch (err) {
      error.value = err.response?.data?.message || "Erreur lors de la suppression de l'interprétation";
      console.error("Erreur deleteInterpretation:", err);
      throw err;
    } finally {
      loading.value = false;
    }
  };

  // 📌 Récupérer les niveaux d'alerte
  const fetchNiveauxAlerte = async () => {
    try {
      const response = await axios.get(`${API_URL}/niveaux-alerte`);
      niveaux.value = response.data.data;
      return niveaux.value;
    } catch (err) {
      console.error("Erreur fetchNiveauxAlerte:", err);
      return [];
    }
  };

  return {
    // Données
    indicateurs,
    currentIndicateur,
    interpretations,
    niveaux,
    loading,
    error,
    
    // Méthodes
    fetchIndicateursComplets,
    fetchIndicateurDetails,
    createIndicateur,
    updateIndicateur,
    deleteIndicateur,
    createInterpretation,
    updateInterpretation,
    deleteInterpretation,
    fetchNiveauxAlerte
  };
}