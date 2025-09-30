import axios from "axios";

const API_URL = "http://127.0.0.1:8000/api";

export const getAffectations = () => axios.get(`${API_URL}/affectations`);
export const getCentres = () => axios.get(`${API_URL}/centres`);
export const getComptes = () => axios.get(`${API_URL}/comptes`);

export const createAffectation = (data) => axios.post(`${API_URL}/affectations`, data);
export const updateAffectation = (id, data) => axios.put(`${API_URL}/affectations/${id}`, data);
export const deleteAffectation = (id) => axios.delete(`${API_URL}/affectations/${id}`);
