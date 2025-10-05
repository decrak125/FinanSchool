import { ref, onMounted } from "vue";
import axios from "axios";

export function useCentres() {
  const API_URL = "http://127.0.0.1:8000/api"; // variable pour l'API

  const centres = ref([]);
  const axes = ref([]);
  const types = ref([]);
  const form = ref({ nom: "", description: "", id_axe: "", id_type: "" });
  const isEditing = ref(false);
  const editingId = ref(null);
  const fileInput = ref(null);
  const importMessage = ref("");
  const importSuccess = ref(false);

  const token = localStorage.getItem("token"); // Récupérer le token

  if (!token) {
    window.location.href = "/";
  } else {
    axios.defaults.headers.common["Authorization"] = `Bearer ${token}`;
  }

  // Charger toutes les données nécessaires
  const fetchCentres = async () => {
    const res = await axios.get(`${API_URL}/centres`);
    centres.value = res.data;
  };

  const fetchAxes = async () => {
    const res = await axios.get(`${API_URL}/axes`);
    axes.value = res.data;
  };

  const fetchTypes = async () => {
    const res = await axios.get(`${API_URL}/types`);
    types.value = res.data;
  };

  // Ajouter / Mettre à jour
  const saveCentre = async () => {
    if (isEditing.value) {
      await axios.put(`${API_URL}/centres/${editingId.value}`, form.value);
    } else {
      await axios.post(`${API_URL}/centres`, form.value);
    }
    resetForm();
    fetchCentres();
  };

  // Modifier
  const editCentre = (centre) => {
    form.value = { ...centre };
    isEditing.value = true;
    editingId.value = centre.id_centre;
  };

  // Annuler modification
  const cancelEdit = () => resetForm();

  // Supprimer
  const deleteCentre = async (id) => {
    if (confirm("Supprimer ce centre ?")) {
      await axios.delete(`${API_URL}/centres/${id}`);
      fetchCentres();
    }
  };

  // Reset formulaire
  const resetForm = () => {
    form.value = { nom: "", description: "", id_axe: "", id_type: "" };
    isEditing.value = false;
    editingId.value = null;
  };

  // Fonctions pour afficher noms axe et type
  const getAxeName = (id) => axes.value.find((a) => a.id_axe === id)?.axe || "";
  const getTypeName = (id) => types.value.find((t) => t.id_type === id)?.code || "";

// Gestion import CSV/Excel
const file = ref(null);

const onFileChange = (e) => {
  file.value = e.target.files[0];
};

const uploadFile = async () => {
  if (!file.value) {
    importMessage.value = "Veuillez sélectionner un fichier.";
    importSuccess.value = false;
    return;
  }

  let formData = new FormData();
  formData.append("file", file.value);

  try {
    const res = await axios.post(`${API_URL}/import/centres`, formData, {
      headers: {
        "Content-Type": "multipart/form-data",
      },
    });
    importMessage.value = res.data.message;
    importSuccess.value = true;
    file.value = null;
    fetchCentres(); // rafraîchir après import
  } catch (err) {
    importMessage.value = err.response?.data?.message || "Erreur lors de l'import.";
    importSuccess.value = false;
  }
};


  // Charger les données au montage
  onMounted(() => {
    fetchCentres();
    fetchAxes();
    fetchTypes();
  });

  return {
    API_URL,
    centres,
    axes,
    types,
    form,
    isEditing,
    editingId,
    file,
    importMessage,
    importSuccess,
    fetchCentres,
    fetchAxes,
    onFileChange,
    fetchTypes,
    saveCentre,
    editCentre,
    cancelEdit,
    deleteCentre,
    resetForm,
    getAxeName,
    getTypeName,
    uploadFile,
  };
}
