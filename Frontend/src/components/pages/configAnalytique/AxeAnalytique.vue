<template>
    <div class="p-6">
      <h1 class="text-2xl font-bold mb-4">Gestion des Axes Analytiques</h1>
  
      <!-- Formulaire -->
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

  const token = localStorage.getItem("token"); // Récupérer le token

if (!token) {
  // Redirection vers login si pas de token
  window.location.href = "/";
} else {
  // Configurer Axios pour inclure le token dans toutes les requêtes
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
  
  onMounted(fetchAxes);
  </script>
  