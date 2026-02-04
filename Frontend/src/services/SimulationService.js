import axios from "axios";

const API_URL = "http://localhost:8000/api/simulations";

export const getSimulations = () => axios.get(API_URL);
export const getSimulation = (id) => axios.get(`${API_URL}/${id}`);
export const createSimulation = (data) => axios.post(API_URL, data);
export const deleteSimulation = (id) => axios.delete(`${API_URL}/${id}`);
export const getHistoricalData = (idExercice) =>
  axios.get(`${API_URL}/historical`, { params: { id_exercice: idExercice } });
