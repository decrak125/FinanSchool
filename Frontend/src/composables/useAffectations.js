import { ref } from "vue";
import axios from "axios";

const API_URL = "http://127.0.0.1:8000/api";

export function useAffectations() {
  const affectations = ref([]);
  const centres = ref([]);
  const comptes = ref([]);

  const form = ref({ Id_Compte: null, id_centre: null, description: "" });
  const isEditing = ref(false);
  const editingId = ref(null);

  // ===== Pour recherche compte =====
  const searchTerm = ref("");
  const suggestions = ref([]);
  const showSuggestions = ref(false);

  // Fetch initial data
  const fetchData = async () => {
    const [resAffect, resCentres, resComptes] = await Promise.all([
      axios.get(`${API_URL}/affectations`),
      axios.get(`${API_URL}/centres`),
      axios.get(`${API_URL}/comptes`)
    ]);
    affectations.value = resAffect.data;
    centres.value = resCentres.data;
    comptes.value = resComptes.data;
  };

  const save = async () => {
    if (!form.value.Id_Compte) return alert("Sélectionnez un compte");
    if (isEditing.value) await axios.put(`${API_URL}/affectations/${editingId.value}`, form.value);
    else await axios.post(`${API_URL}/affectations`, form.value);

    resetForm();
    fetchData();
  };

  const edit = (aff) => {
    form.value = { ...aff, Id_Compte: aff.sous_compte?.Id_Compte };
    searchTerm.value = aff.sous_compte ? `${aff.sous_compte.Code_compte} - ${aff.sous_compte.Libelle}` : "";
    isEditing.value = true;
    editingId.value = aff.id_affectation;
  };

  const remove = async (id) => {
    if (confirm("Supprimer cette affectation ?")) {
      await axios.delete(`${API_URL}/affectations/${id}`);
      fetchData();
    }
  };

  const resetForm = () => {
    form.value = { Id_Compte: null, id_centre: null, description: "" };
    searchTerm.value = "";
    showSuggestions.value = false;
    isEditing.value = false;
    editingId.value = null;
  };

  // Recherche dynamique des comptes
  const searchCompte = () => {
    const term = searchTerm.value.trim().toLowerCase();
    if (!term || term.length < 2) {
      showSuggestions.value = false;
      suggestions.value = [];
      return;
    }

    const filtered = comptes.value.filter(c =>
      c.Code_compte.toLowerCase().includes(term) ||
      c.Libelle.toLowerCase().includes(term)
    ).slice(0, 10);

    suggestions.value = filtered;
    showSuggestions.value = filtered.length > 0;
  };

  const selectCompte = (compte) => {
    form.value.Id_Compte = compte.Id_Compte;
    searchTerm.value = `${compte.Code_compte} - ${compte.Libelle}`;
    showSuggestions.value = false;
  };

  return {
    affectations, centres, comptes,
    form, isEditing,
    fetchData, save, edit, remove, resetForm,
    searchTerm, suggestions, showSuggestions,
    searchCompte, selectCompte
  };
}
