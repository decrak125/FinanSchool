<template>
    <div class="p-6">
      <h1 class="text-2xl font-bold mb-4">Gestion des Journaux</h1>
  
      <!-- Formulaire -->
      <form @submit.prevent="saveJournal" class="mb-6 space-y-3 bg-gray-100 p-4 rounded">
        <div>
          <label class="block font-semibold">Code</label>
          <input v-model="form.Code" type="text" class="w-full border rounded px-2 py-1" required />
        </div>
  
        <div>
          <label class="block font-semibold">Libellé</label>
          <input v-model="form.Libelle" type="text" class="w-full border rounded px-2 py-1" required />
        </div>
  
        <div>
          <label class="block font-semibold">Type Journal</label>
          <select v-model="form.Id_Type_Journal" class="w-full border rounded px-2 py-1" required>
            <option value="">-- Sélectionner --</option>
            <option v-for="type in typeJournals" :key="type.Id_Type_Journal" :value="type.Id_Type_Journal">
              {{ type.Type }}
            </option>
          </select>
        </div>
  
        <div>
          <label class="block font-semibold">Sous-compte (optionnel)</label>
          <select v-model="form.Id_Sous_compte" class="w-full border rounded px-2 py-1">
            <option value="">-- Sélectionner --</option>
            <option v-for="compte in sousComptes" :key="compte.Id_Sous_compte" :value="compte.Id_Sous_compte">
              {{ compte.Code_sous_compte }} - {{ compte.Libelle }}
            </option>
          </select>
        </div>
  
        <div>
          <button type="submit" class="bg-blue-600 text-white px-4 py-2 rounded">
            {{ isEditing ? "Mettre à jour" : "Ajouter" }}
          </button>
          <button v-if="isEditing" type="button" @click="cancelEdit" class="ml-2 bg-gray-500 text-white px-4 py-2 rounded">
            Annuler
          </button>
        </div>
      </form>
  
      <!-- Tableau des journaux -->
      <table class="w-full border-collapse border">
        <thead>
          <tr class="bg-gray-200">
            <th class="border px-3 py-2">#</th>
            <th class="border px-3 py-2">Code</th>
            <th class="border px-3 py-2">Libellé</th>
            <th class="border px-3 py-2">Type Journal</th>
            <th class="border px-3 py-2">Sous-compte</th>
            <th class="border px-3 py-2">Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="journal in journals" :key="journal.Id_Journal">
            <td class="border px-3 py-2">{{ journal.Id_Journal }}</td>
            <td class="border px-3 py-2">{{ journal.Code }}</td>
            <td class="border px-3 py-2">{{ journal.Libelle }}</td>
            <td class="border px-3 py-2">{{ journal.type_journal?.Type || '-' }}</td>
            <td class="border px-3 py-2">{{ journal.sous_compte?.Libelle || '-' }}</td>
            <td class="border px-3 py-2 text-center">
              <button @click="editJournal(journal)" class="bg-yellow-500 text-white px-2 py-1 rounded">✏️</button>
              <button @click="deleteJournal(journal.Id_Journal)" class="ml-2 bg-red-600 text-white px-2 py-1 rounded">🗑️</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </template>
  
  <script setup>
import { ref, onMounted } from "vue";
import axios from "axios";

const journals = ref([]);
const typeJournals = ref([]);
const sousComptes = ref([]);

const form = ref({
  Code: "",
  Libelle: "",
  Id_Type_Journal: "",
  Id_Sous_compte: "",
});

const isEditing = ref(false);
const editingId = ref(null);

const token = localStorage.getItem("token"); // Récupérer le token

if (!token) {
  // Redirection vers login si pas de token
  window.location.href = "/";
} else {
  // Configurer Axios pour inclure le token dans toutes les requêtes
  axios.defaults.headers.common["Authorization"] = `Bearer ${token}`;
}

// Puis le reste de ton code fetch reste identique
const fetchJournals = async () => {
  const res = await axios.get("http://127.0.0.1:8000/api/journals");
  journals.value = res.data;
};

const fetchOptions = async () => {
  const types = await axios.get("http://127.0.0.1:8000/api/type-journals");
  typeJournals.value = types.data;

  const comptes = await axios.get("http://127.0.0.1:8000/api/sous-comptes");
  sousComptes.value = comptes.data;
};

  
  // Ajouter ou modifier un journal
  const saveJournal = async () => {
    if (isEditing.value) {
      await axios.put(`http://127.0.0.1:8000/api/journals/${editingId.value}`, form.value);
    } else {
      await axios.post("http://127.0.0.1:8000/api/journals", form.value);
    }
    resetForm();
    fetchJournals();
  };
  
  // Editer
  const editJournal = (journal) => {
    form.value = {
      Code: journal.Code,
      Libelle: journal.Libelle,
      Id_Type_Journal: journal.Id_Type_Journal,
      Id_Sous_compte: journal.Id_Sous_compte || "",
    };
    isEditing.value = true;
    editingId.value = journal.Id_Journal;
  };
  
  // Annuler
  const cancelEdit = () => {
    resetForm();
  };
  
  // Supprimer
  const deleteJournal = async (id) => {
    if (confirm("Supprimer ce journal ?")) {
      await axios.delete(`http://127.0.0.1:8000/api/journals/${id}`);
      fetchJournals();
    }
  };
  
  // Reset form
  const resetForm = () => {
    form.value = { Code: "", Libelle: "", Id_Type_Journal: "", Id_Sous_compte: "" };
    isEditing.value = false;
    editingId.value = null;
  };
  
  // Au montage
  onMounted(() => {
    fetchJournals();
    fetchOptions();
  });
  </script>
  
  <style scoped>
  table {
    margin-top: 1rem;
  }
  </style>
  