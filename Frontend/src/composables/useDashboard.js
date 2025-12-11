import axios from 'axios';

const API_BASE_URL = 'http://localhost:8000/api';

export const useDashboard = {
  async getDonneesMensuelles(filters = {}) {
    try {
      const params = new URLSearchParams();
      
      if (filters.year) params.append('year', filters.year);
      if (filters.id_centre) params.append('id_centre', filters.id_centre);
      if (filters.id_type) params.append('id_type', filters.id_type);
      
      const response = await axios.get(`${API_BASE_URL}/analyse/mensuelle-centre?${params}`);
      return response.data;
    } catch (error) {
      console.error('Erreur lors de la récupération des données:', error);
      throw error;
    }
  },

  async getDonneesTrimestrielles(filters = {}) {
    try {
      const params = new URLSearchParams();
      
      if (filters.year) params.append('year', filters.year);
      if (filters.id_centre) params.append('id_centre', filters.id_centre);
      if (filters.id_type) params.append('id_type', filters.id_type);
      
      const response = await axios.get(`${API_BASE_URL}/analyse/trimestrielle-centre?${params}`);
      return response.data;
    } catch (error) {
      console.error('Erreur lors de la récupération des données trimestrielles:', error);
      throw error;
    }
  },

  // 🔥 NOUVELLES FONCTIONS POUR COÛTS VS PROFITS
  async getComparaisonCoutProfit(filters = {}) {
    try {
      const params = new URLSearchParams();
      
      if (filters.annee) params.append('annee', filters.annee);
      if (filters.mois) params.append('mois', filters.mois);
      if (filters.id_type) params.append('id_type', filters.id_type);
      if (filters.limit) params.append('limit', filters.limit);
      if (filters.offset) params.append('offset', filters.offset);
      
      const response = await axios.get(`${API_BASE_URL}/analyse/cout-profit/comparaison?${params}`);
      return response.data;
    } catch (error) {
      console.error('Erreur lors de la récupération des données coûts vs profits:', error);
      throw error;
    }
  },

  async getResumeAnnuelCoutProfit(filters = {}) {
    try {
      const params = new URLSearchParams();
      
      if (filters.annee) params.append('annee', filters.annee);
      
      const response = await axios.get(`${API_BASE_URL}/analyse/cout-profit/resume-annuel?${params}`);
      return response.data;
    } catch (error) {
      console.error('Erreur lors de la récupération du résumé annuel coûts vs profits:', error);
      throw error;
    }
  },

  async getCentres() {
    try {
      const response = await axios.get(`${API_BASE_URL}/centres`);
      return response.data;
    } catch (error) {
      console.error('Erreur lors de la récupération des centres:', error);
      return [];
    }
  },
  
  async getType() {
    try {
      const response = await axios.get(`${API_BASE_URL}/types`);
      return response.data;
    } catch (error) {
      console.error('Erreur lors de la récupération des types:', error);
      return [];
    }
  }
};