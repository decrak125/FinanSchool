<template>
  <div class="p-6">
    <h1 class="text-2xl font-bold mb-4">Gestion des Axes Analytiques</h1>

    <!-- Formulaire manuel -->
    <form @submit.prevent="saveAxe" class="mb-6 space-y-3 bg-gray-100 p-4 rounded">
      <div>
        <label class="block font-semibold">Nom de l'Axe</label>
        <input v-model="form.axe" type="text" class="w-full border rounded px-2 py-1" required />
      </div>
      <div>
        <label class="block font-semibold">Description</label>
        <input v-model="form.description" type="text" class="w-full border rounded px-2 py-1" required />
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

    <!-- Import CSV / Excel -->
    <div class="mb-6 bg-gray-100 p-4 rounded">
      <h2 class="font-semibold mb-2">Importer un fichier CSV/Excel</h2>
      <input type="file" @change="onFileChange" class="mb-2" />
      <button @click="uploadFile" class="bg-green-600 text-white px-4 py-2 rounded">
        Importer
      </button>
      <p v-if="importMessage" :class="importSuccess ? 'text-green-600' : 'text-red-600'">
        {{ importMessage }}
      </p>
    </div>

    <!-- Tableau des axes -->
    <table class="w-full border-collapse border">
      <thead>
        <tr class="bg-gray-200">
          <th class="border px-3 py-2">#</th>
          <th class="border px-3 py-2">Axe</th>
          <th class="border px-3 py-2">Description</th>
          <th class="border px-3 py-2">Actions</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="axe in axes" :key="axe.id_axe">
          <td class="border px-3 py-2">{{ axe.id_axe }}</td>
          <td class="border px-3 py-2">{{ axe.axe }}</td>
          <td class="border px-3 py-2">{{ axe.description }}</td>
          <td class="border px-3 py-2 text-center">
            <button @click="editAxe(axe)" class="bg-yellow-500 text-white px-2 py-1 rounded">✏️</button>
            <button @click="deleteAxe(axe.id_axe)" class="ml-2 bg-red-600 text-white px-2 py-1 rounded">🗑️</button>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import axios from "axios";

const axes = ref([]);
const form = ref({ axe: "", description: "" });
const isEditing = ref(false);
const editingId = ref(null);

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
  const res = await axios.get("http://127.0.0.1:8000/api/axes");
  axes.value = res.data;
};

// Ajouter / Mettre à jour
const saveAxe = async () => {
  if (isEditing.value) {
    await axios.put(`http://127.0.0.1:8000/api/axes/${editingId.value}`, form.value);
  } else {
    await axios.post("http://127.0.0.1:8000/api/axes", form.value);
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
    await axios.delete(`http://127.0.0.1:8000/api/axes/${id}`);
    fetchAxes();
  }
};

// Reset formulaire
const resetForm = () => {
  form.value = { axe: "", description: "" };
  isEditing.value = false;
  editingId.value = null;
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

onMounted(fetchAxes);
</script>
