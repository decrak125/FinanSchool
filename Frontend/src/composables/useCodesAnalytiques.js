import { ref } from "vue";
import axios from "axios";

export function useCodesAnalytiques() {
    const codes = ref([]);
    const form = ref({ 
        code: "", 
        libelle: "", 
        plage_de_extension: "" 
    });
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
    
    // Charger les codes analytiques
    const fetchCodes = async () => {
      loading.value = true;
      const res = await axios.get("http://127.0.0.1:8000/api/codes");
      nombreLignesLoader.value = res.data.length || 10;
      codes.value = res.data;
      loading.value = false;
    };
    
    // Ajouter / Mettre à jour
    const saveCode = async () => {
      if (isEditing.value) {
        loading.value = true;
        await axios.put(`http://127.0.0.1:8000/api/codes/${editingId.value}`, form.value);
        loading.value = false;
        nombreLignesLoader.value = codes.value.length || 10;
      } else {
        loading.value = true;
        await axios.post("http://127.0.0.1:8000/api/codes", form.value);
        loading.value = false;
        nombreLignesLoader.value = codes.value.length || 10;
      }
      resetForm();
      fetchCodes();
    };
    
    // Modifier
    const editCode = (code) => {
      form.value = { ...code };
      isEditing.value = true;
      editingId.value = code.id_code;
    };
    
    // Annuler modification
    const cancelEdit = () => resetForm();
    
    // Supprimer
    const deleteCode = async (id) => {
        loading.value = true;
        await axios.delete(`http://127.0.0.1:8000/api/codes/${id}`);
        loading.value = false;
        nombreLignesLoader.value = codes.value.length || 10;
        fetchCodes();
    };
    
    // Reset formulaire
    const resetForm = () => {
      loading.value = true;
      form.value = { 
        code: "", 
        libelle: "", 
        plage_de_extension: "" 
      };
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
        const res = await axios.post("http://127.0.0.1:8000/api/import/codes", formData, {
          headers: {
            "Content-Type": "multipart/form-data",
          },
        });
        importMessage.value = res.data.message;
        importSuccess.value = true;
        fetchCodes(); // rafraîchir le tableau après import
      } catch (err) {
        importMessage.value = err.response?.data?.message || "Erreur lors de l'import.";
        importSuccess.value = false;
      }
    };
    
    return {
        codes,
        form,
        isEditing,
        editingId,
        file,
        loading,
        nombreLignesLoader,
        importMessage,
        importSuccess,
        fetchCodes,
        saveCode,
        editCode,
        cancelEdit,
        deleteCode,
        onFileChange,
        uploadFile
    };
}