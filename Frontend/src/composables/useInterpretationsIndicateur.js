import { ref } from "vue";
import axios from "axios";

export function useInterpretationsIndicateur() {
  const API_URL = "http://127.0.0.1:8000/api";
  
  const interpretations = ref([]);
  const interpretation = ref(null);
  const loading = ref(false);
  const error = ref(null);

  // 📌 Récupérer toutes les interprétations
  const fetchInterpretations = async () => {
    try {
      loading.value = true;
      error.value = null;
      const response = await axios.get(`${API_URL}/interpretations-indicateur`);
      interpretations.value = response.data.data;
      return response.data.data;
    } catch (err) {
      error.value = err.response?.data?.message || "Erreur lors de la récupération des interprétations";
      console.error("Erreur fetchInterpretations:", err);
      return null;
    } finally {
      loading.value = false;
    }
  };

  // 📌 Récupérer les interprétations d'un indicateur
  const fetchInterpretationsByIndicateur = async (idIndicateur) => {
    try {
      loading.value = true;
      error.value = null;
      const response = await axios.get(`${API_URL}/interpretations-indicateur/indicateur/${idIndicateur}`);
      return response.data.data;
    } catch (err) {
      error.value = err.response?.data?.message || "Erreur lors de la récupération des interprétations";
      console.error("Erreur fetchInterpretationsByIndicateur:", err);
      return null;
    } finally {
      loading.value = false;
    }
  };

  // 📌 Récupérer une interprétation par ID
  const fetchInterpretationById = async (id) => {
    try {
      loading.value = true;
      error.value = null;
      const response = await axios.get(`${API_URL}/interpretations-indicateur/${id}`);
      interpretation.value = response.data.data;
      return response.data.data;
    } catch (err) {
      error.value = err.response?.data?.message || "Erreur lors de la récupération de l'interprétation";
      console.error("Erreur fetchInterpretationById:", err);
      return null;
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
      
      // Mettre à jour l'interprétation courante
      if (interpretation.value?.id_interpretation_indicateur == id) {
        interpretation.value = response.data.data;
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
      
      // Réinitialiser l'interprétation courante si c'est celle-ci
      if (interpretation.value?.id_interpretation_indicateur == id) {
        interpretation.value = null;
      }
      
      return { success: true, message: "Interprétation supprimée avec succès" };
    } catch (err) {
      error.value = err.response?.data?.message || "Erreur lors de la suppression de l'interprétation";
      console.error("Erreur deleteInterpretation:", err);
      throw err;
    } finally {
      loading.value = false;
    }
  };

  // 📌 Obtenir l'interprétation pour une valeur donnée
  const getInterpretationForValue = async (idIndicateur, valeur) => {
    try {
      loading.value = true;
      error.value = null;
      const response = await axios.post(`${API_URL}/interpretations-indicateur/indicateur/${idIndicateur}/valeur`, {
        valeur: valeur
      });
      return response.data.data;
    } catch (err) {
      error.value = err.response?.data?.message || "Aucune interprétation trouvée pour cette valeur";
      console.error("Erreur getInterpretationForValue:", err);
      return null;
    } finally {
      loading.value = false;
    }
  };

  return {
    // Données
    interpretations,
    interpretation,
    loading,
    error,
    
    // Méthodes
    fetchInterpretations,
    fetchInterpretationsByIndicateur,
    fetchInterpretationById,
    createInterpretation,
    updateInterpretation,
    deleteInterpretation,
    getInterpretationForValue
  };
}