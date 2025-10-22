import { ref } from "vue";
import axios from "axios";

export function useAxes() {
    const axes = ref([]);
    const form = ref({ axe: "", description: "" });
    const isEditing = ref(false);
    const editingId = ref(null);
    const loading = ref(true);
    const nombreLignesLoader = ref(5);

    
    const file = ref(null);
    const importMessage = ref("");
    const importSuccess = ref(false);
    
    const token = localStorage.getItem("token");
    
    if (!token) {
      window.location.href = "/";
    } else {
      axios.defaults.headers.common["Authorization"] = `Bearer ${token}`;
    }
    
    // Charger les axes
    const fetchAxes = async () => {
      loading.value = true;
      const res = await axios.get("http://127.0.0.1:8000/api/axes");
      nombreLignesLoader.value = res.data.length || 10;
      axes.value = res.data;
      loading.value = false;
    };
    
    // Ajouter / Mettre à jour
    const saveAxe = async () => {
      if (isEditing.value) {
        loading.value = true;
        await axios.put(`http://127.0.0.1:8000/api/axes/${editingId.value}`, form.value);
        loading.value = false;
        nombreLignesLoader.value = axes.value.length || 10;
      } else {
        loading.value = true;
        await axios.post("http://127.0.0.1:8000/api/axes", form.value);
        loading.value = false;
        nombreLignesLoader.value = axes.value.length || 10;
      }
      resetForm();
      fetchAxes();
    };
    
    // Modifier
    const editAxe = (axe) => {
      form.value = { ...axe };
      isEditing.value = true;
      editingId.value = axe.id_axe;
    };
    
    // Annuler modification
    const cancelEdit = () => resetForm();
    
    // Supprimer
    const deleteAxe = async (id) => {
      if (confirm("Supprimer cet axe ?")) {
        loading.value = true;
        await axios.delete(`http://127.0.0.1:8000/api/axes/${id}`);
        loading.value = false;
        nombreLignesLoader.value = axes.value.length || 10;
        fetchAxes();
      }
    };
    
    // Reset formulaire
    const resetForm = () => {
      loading.value = true;
      form.value = { axe: "", description: "" };
      isEditing.value = false;
      editingId.value = null;
      loading.value = false;
    };
    
    // Gestion import CSV/Excel
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
        const res = await axios.post("http://127.0.0.1:8000/api/import/axes", formData, {
          headers: {
            "Content-Type": "multipart/form-data",
          },
        });
        importMessage.value = res.data.message;
        importSuccess.value = true;
        fetchAxes(); // rafraîchir le tableau après import
      } catch (err) {
        importMessage.value = err.response?.data?.message || "Erreur lors de l'import.";
        importSuccess.value = false;
      }
    };
    
    return {
        axes,
        form,
        isEditing,
        editingId,
        file,
        loading,
        nombreLignesLoader,
        importMessage,
        importSuccess,
        fetchAxes,
        saveAxe,
        editAxe,
        cancelEdit,
        deleteAxe,
        onFileChange,
        uploadFile
    };
}