import axios from 'axios';

const API_URL = 'http://localhost:8000/api';

export default class ErrorService {
  // Récupère le message d'erreur par ID
  static async getMessage(id) {
    try {
      const res = await axios.get(`${API_URL}/errors/${id}`);
      return res.data.message;
    } catch (err) {
      return 'Erreur inconnue';
    }
  }
}
