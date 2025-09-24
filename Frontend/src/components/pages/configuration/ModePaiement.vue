<template>
  <div class="p-6">
    <h2 class="text-2xl font-bold mb-4">Gestion des Modes de Paiement</h2>

    <!-- Formulaire -->
    <form @submit.prevent="isEditing ? updateModePaiement() : addModePaiement()" class="mb-6 space-y-4">
      <input
        v-model="form.Libelle"
        type="text"
        placeholder="Libellé"
        class="border rounded px-3 py-2 w-full"
        required
      />
      <input
        v-model="form.Abr"
        type="text"
        placeholder="Abréviation"
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
          <th class="border border-gray-300 px-4 py-2">Libellé</th>
          <th class="border border-gray-300 px-4 py-2">Abréviation</th>
          <th class="border border-gray-300 px-4 py-2">Actions</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="mode in modePaiements" :key="mode.Id_Mode_paiement">
          <td class="border border-gray-300 px-4 py-2">{{ mode.Id_Mode_paiement }}</td>
          <td class="border border-gray-300 px-4 py-2">{{ mode.Libelle }}</td>
          <td class="border border-gray-300 px-4 py-2">{{ mode.Abr }}</td>
          <td class="border border-gray-300 px-4 py-2">
            <button
              @click="editModePaiement(mode)"
              class="bg-yellow-500 text-white px-2 py-1 rounded mr-2"
            >
              Modifier
            </button>
            <button
              @click="deleteModePaiement(mode.Id_Mode_paiement)"
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

const API_URL = "http://localhost:8000/api/mode-paiements";

const modePaiements = ref([]);
const isEditing = ref(false);
const editId = ref(null);

const form = ref({
  Libelle: "",
  Abr: "",
});

const token = localStorage.getItem("token"); // Récupérer le token

if (!token) {
  // Redirection vers login si pas de token
  window.location.href = "/";
} else {
  // Configurer Axios pour inclure le token dans toutes les requêtes
  axios.defaults.headers.common["Authorization"] = `Bearer ${token}`;
}

// Charger les modes de paiement
const fetchModePaiements = async () => {
  const response = await axios.get(API_URL);
  modePaiements.value = response.data;
};

// Ajouter
const addModePaiement = async () => {
  await axios.post(API_URL, form.value);
  fetchModePaiements();
  resetForm();
};

// Supprimer
const deleteModePaiement = async (id) => {
  if (confirm("Voulez-vous vraiment supprimer ce mode de paiement ?")) {
    await axios.delete(`${API_URL}/${id}`);
    fetchModePaiements();
  }
};

// Préparer édition
const editModePaiement = (mode) => {
  isEditing.value = true;
  editId.value = mode.Id_Mode_paiement;
  form.value = { ...mode };
};

// Mettre à jour
const updateModePaiement = async () => {
  await axios.put(`${API_URL}/${editId.value}`, form.value);
  fetchModePaiements();
  resetForm();
};

// Réinitialiser
const resetForm = () => {
  form.value = { Libelle: "", Abr: "" };
  isEditing.value = false;
  editId.value = null;
};

// Charger au montage
onMounted(fetchModePaiements);
</script>

<style scoped>
table {
  margin-top: 20px;
}
</style>
