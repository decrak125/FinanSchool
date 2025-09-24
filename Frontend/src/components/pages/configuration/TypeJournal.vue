<template>
  <div class="p-6">
    <h2 class="text-2xl font-bold mb-4">Gestion des Types de Journal</h2>

    <!-- Formulaire -->
    <form @submit.prevent="isEditing ? updateTypeJournal() : addTypeJournal()" class="mb-6 space-y-4">
      <input
        v-model="form.Type"
        type="text"
        placeholder="Type de journal"
        class="border rounded px-3 py-2 w-full"
        required
      />

      <button type="submit" class="bg-blue-500 text-white px-4 py-2 rounded">
        {{ isEditing ? "Mettre à jour" : "Ajouter" }}
      </button>
      <button
        v-if="isEditing"
        type="button"
        @click="resetForm"
        class="bg-gray-500 text-white px-4 py-2 rounded ml-2"
      >
        Annuler
      </button>
    </form>

    <!-- Tableau -->
    <table class="min-w-full border-collapse border border-gray-300">
      <thead>
        <tr class="bg-gray-200">
          <th class="border border-gray-300 px-4 py-2">ID</th>
          <th class="border border-gray-300 px-4 py-2">Type</th>
          <th class="border border-gray-300 px-4 py-2">Actions</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="journal in typeJournals" :key="journal.id">
          <td class="border border-gray-300 px-4 py-2">{{ journal.Id_Type_Journal }}</td>
          <td class="border border-gray-300 px-4 py-2">{{ journal.Type }}</td>
          <td class="border border-gray-300 px-4 py-2">
            <button
              @click="editTypeJournal(journal)"
              class="bg-yellow-500 text-white px-2 py-1 rounded mr-2"
            >
              Modifier
            </button>
            <button
              @click="deleteTypeJournal(journal.Id_Type_Journal)"
              class="bg-red-500 text-white px-2 py-1 rounded"
            >
              Supprimer
            </button>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import axios from "axios";

const API_URL = "http://localhost:8000/api/type-journals";

const typeJournals = ref([]);
const isEditing = ref(false);
const editId = ref(null);

const form = ref({
  Type: "",
});

const token = localStorage.getItem("token"); // Récupérer le token

if (!token) {
  // Redirection vers login si pas de token
  window.location.href = "/";
} else {
  // Configurer Axios pour inclure le token dans toutes les requêtes
  axios.defaults.headers.common["Authorization"] = `Bearer ${token}`;
}

// Charger les types de journal
const fetchTypeJournals = async () => {
  const response = await axios.get(API_URL);
  typeJournals.value = response.data;
};

// Ajouter
const addTypeJournal = async () => {
  await axios.post(API_URL, form.value);
  fetchTypeJournals();
  resetForm();
};

// Supprimer
const deleteTypeJournal = async (id) => {
  if (confirm("Voulez-vous vraiment supprimer ce type de journal ?")) {
    await axios.delete(`${API_URL}/${id}`);
    fetchTypeJournals();
  }
};

// Préparer édition
const editTypeJournal = (journal) => {
  isEditing.value = true;
  editId.value = journal.Id_Type_Journal;
  form.value = { ...journal };
};

// Mettre à jour
const updateTypeJournal = async () => {
  await axios.put(`${API_URL}/${editId.value}`, form.value);
  fetchTypeJournals();
  resetForm();
};

// Réinitialiser
const resetForm = () => {
  form.value = { Type: "" };
  isEditing.value = false;
  editId.value = null;
};

// Charger au montage
onMounted(fetchTypeJournals);
</script>

<style scoped>
table {
  margin-top: 20px;
}
</style>
