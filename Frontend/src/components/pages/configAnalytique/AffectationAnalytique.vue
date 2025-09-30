<template>
  <div class="p-6">
    <h1 class="text-2xl font-bold mb-4">Gestion des Affectations Analytiques</h1>

    <!-- Formulaire -->
    <form @submit.prevent="saveAffectation" class="mb-6 space-y-3 bg-gray-100 p-4 rounded">
      <!-- Recherche compte -->
      <div class="relative">
        <label class="block font-semibold">Compte</label>
        <input
          v-model="compteSearch"
          @input="searchCompte"
          @keydown.down.prevent="moveSelection(1)"
          @keydown.up.prevent="moveSelection(-1)"
          @keydown.enter.prevent="selectSuggestion"
          type="text"
          class="w-full border rounded px-2 py-1"
          placeholder="Rechercher un compte..."
        />
        <!-- Suggestions -->
        <ul
          v-if="showSuggestions"
          class="absolute z-10 w-full bg-white border rounded shadow max-h-40 overflow-y-auto"
        >
          <li
            v-for="(compte, index) in suggestions"
            :key="compte.Id_Compte"
            :class="[
              'px-2 py-1 cursor-pointer hover:bg-blue-100',
              index === selectedSuggestionIndex ? 'bg-blue-200' : ''
            ]"
            @click="selectCompte(compte)"
          >
            {{ compte.Code_compte }} - {{ compte.Libelle }}
          </li>
        </ul>
      </div>

      <!-- Centre analytique -->
      <div>
        <label class="block font-semibold">Centre Analytique</label>
        <select v-model="form.id_centre" class="w-full border rounded px-2 py-1" required>
          <option value="" disabled>-- Sélectionner un centre --</option>
          <option v-for="centre in centres" :key="centre.id_centre" :value="centre.id_centre">
            {{ centre.nom }}
          </option>
        </select>
      </div>

      <!-- Description -->
      <div>
        <label class="block font-semibold">Description</label>
        <input v-model="form.description" type="text" class="w-full border rounded px-2 py-1" required />
      </div>

      <!-- Boutons -->
      <div>
        <button type="submit" class="bg-blue-600 text-white px-4 py-2 rounded">
          {{ isEditing ? "Mettre à jour" : "Ajouter" }}
        </button>
        <button v-if="isEditing" type="button" @click="cancelEdit" class="ml-2 bg-gray-500 text-white px-4 py-2 rounded">
          Annuler
        </button>
      </div>
    </form>

    <!-- Tableau des affectations -->
    <table class="w-full border-collapse border">
      <thead>
        <tr class="bg-gray-200">
          <th class="border px-3 py-2">#</th>
          <th class="border px-3 py-2">Sous-compte</th>
          <th class="border px-3 py-2">Centre</th>
          <th class="border px-3 py-2">Description</th>
          <th class="border px-3 py-2">Actions</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="affectation in affectations" :key="affectation.id_affectation">
          <td class="border px-3 py-2">{{ affectation.id_affectation }}</td>
          <td class="border px-3 py-2">
            {{ affectation.sous_compte?.Code_sous_compte }} - {{ affectation.sous_compte?.Libelle }}
          </td>
          <td class="border px-3 py-2">{{ affectation.centre?.nom }}</td>
          <td class="border px-3 py-2">{{ affectation.description }}</td>
          <td class="border px-3 py-2 text-center">
            <button @click="editAffectation(affectation)" class="bg-yellow-500 text-white px-2 py-1 rounded">✏️</button>
            <button @click="deleteAffectation(affectation.id_affectation)" class="ml-2 bg-red-600 text-white px-2 py-1 rounded">🗑️</button>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import axios from "axios";

const affectations = ref([]);
const centres = ref([]);
const comptes = ref([]); // Tous les comptes

const form = ref({ Id_Compte: null, id_centre: null, description: "" });
const isEditing = ref(false);
const editingId = ref(null);

// Recherche compte
const compteSearch = ref("");
const suggestions = ref([]);
const showSuggestions = ref(false);
const selectedSuggestionIndex = ref(-1);

// Auth
const token = localStorage.getItem("token");
if (!token) {
  window.location.href = "/";
} else {
  axios.defaults.headers.common["Authorization"] = `Bearer ${token}`;
}

// Charger données
const fetchData = async () => {
  const [resAffectations, resCentres, resComptes] = await Promise.all([
    axios.get("http://127.0.0.1:8000/api/affectations"),
    axios.get("http://127.0.0.1:8000/api/centres"),
    axios.get("http://127.0.0.1:8000/api/comptes"),
  ]);
  affectations.value = resAffectations.data;
  centres.value = resCentres.data;
  comptes.value = resComptes.data;
};

// 🔎 Recherche dans les comptes
const searchCompte = () => {
  if (!compteSearch.value || compteSearch.value.length < 2) {
    suggestions.value = [];
    showSuggestions.value = false;
    return;
  }

  const filtered = comptes.value.filter(compte =>
    compte.Code_compte.toLowerCase().includes(compteSearch.value.toLowerCase()) ||
    compte.Libelle.toLowerCase().includes(compteSearch.value.toLowerCase())
  ).slice(0, 10);

  suggestions.value = filtered;
  showSuggestions.value = filtered.length > 0;
  selectedSuggestionIndex.value = -1;
};

// Sélection avec clic
const selectCompte = (compte) => {
  form.value.Id_Compte = compte.Id_Compte;
  compteSearch.value = `${compte.Code_compte} - ${compte.Libelle}`;
  showSuggestions.value = false;
};

// Navigation clavier
const moveSelection = (direction) => {
  if (!showSuggestions.value) return;
  const maxIndex = suggestions.value.length - 1;
  selectedSuggestionIndex.value = Math.min(
    Math.max(selectedSuggestionIndex.value + direction, 0),
    maxIndex
  );
};

const selectSuggestion = () => {
  if (selectedSuggestionIndex.value >= 0 && selectedSuggestionIndex.value < suggestions.value.length) {
    selectCompte(suggestions.value[selectedSuggestionIndex.value]);
  }
};

// Ajouter / Mettre à jour
const saveAffectation = async () => {
  if (!form.value.Id_Compte) {
    alert("Veuillez sélectionner un compte valide !");
    return;
  }

  if (isEditing.value) {
    await axios.put(`http://127.0.0.1:8000/api/affectations/${editingId.value}`, form.value);
  } else {
    await axios.post("http://127.0.0.1:8000/api/affectations", form.value);
  }
  resetForm();
  fetchData();
};

// Modifier
const editAffectation = (affectation) => {
  form.value = { ...affectation };
  compteSearch.value = affectation.sous_compte?.Code_compte + " - " + affectation.sous_compte?.Libelle;
  isEditing.value = true;
  editingId.value = affectation.id_affectation;
};

// Annuler
const cancelEdit = () => resetForm();

// Supprimer
const deleteAffectation = async (id) => {
  if (confirm("Supprimer cette affectation ?")) {
    await axios.delete(`http://127.0.0.1:8000/api/affectations/${id}`);
    fetchData();
  }
};

// Reset form
const resetForm = () => {
  form.value = { Id_Compte: null, id_centre: null, description: "" };
  compteSearch.value = "";
  isEditing.value = false;
  editingId.value = null;
};

onMounted(fetchData);
</script>
