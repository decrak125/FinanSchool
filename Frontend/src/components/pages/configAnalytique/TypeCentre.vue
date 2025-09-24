<template>
    <div class="p-6">
      <h1 class="text-2xl font-bold mb-4">Gestion des Types de Centres</h1>
  
      <!-- Formulaire -->
      <form @submit.prevent="saveType" class="mb-6 space-y-3 bg-gray-100 p-4 rounded">
        <div>
          <label class="block font-semibold">Code</label>
          <input v-model="form.code" type="text" class="w-full border rounded px-2 py-1" required />
        </div>
        <div>
          <label class="block font-semibold">Libellé</label>
          <input v-model="form.libelle" type="text" class="w-full border rounded px-2 py-1" required />
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
  
      <!-- Tableau des types -->
      <table class="w-full border-collapse border">
        <thead>
          <tr class="bg-gray-200">
            <th class="border px-3 py-2">#</th>
            <th class="border px-3 py-2">Code</th>
            <th class="border px-3 py-2">Libellé</th>
            <th class="border px-3 py-2">Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="type in types" :key="type.id_type">
            <td class="border px-3 py-2">{{ type.id_type }}</td>
            <td class="border px-3 py-2">{{ type.code }}</td>
            <td class="border px-3 py-2">{{ type.libelle }}</td>
            <td class="border px-3 py-2 text-center">
              <button @click="editType(type)" class="bg-yellow-500 text-white px-2 py-1 rounded">✏️</button>
              <button @click="deleteType(type.id_type)" class="ml-2 bg-red-600 text-white px-2 py-1 rounded">🗑️</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </template>
  
  <script setup>
  import { ref, onMounted } from "vue";
  import axios from "axios"; // ou axios direct
  
  const types = ref([]);
  const form = ref({ code: "", libelle: "" });
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
  
  // Charger les types
  const fetchTypes = async () => {
    const res = await axios.get("http://127.0.0.1:8000/api/types");
    types.value = res.data;
  };
  
  // Ajouter / Mettre à jour
  const saveType = async () => {
    if (isEditing.value) {
      await axios.put(`http://127.0.0.1:8000/api/types/${editingId.value}`, form.value);
    } else {
      await axios.post("http://127.0.0.1:8000/api/types", form.value);
    }
    resetForm();
    fetchTypes();
  };
  
  // Modifier
  const editType = (type) => {
    form.value = { ...type };
    isEditing.value = true;
    editingId.value = type.id_type;
  };
  
  // Annuler modification
  const cancelEdit = () => resetForm();
  
  // Supprimer
  const deleteType = async (id) => {
    if (confirm("Supprimer ce type ?")) {
      await axios.delete(`http://127.0.0.1:8000/api/types/${id}`);
      fetchTypes();
    }
  };
  
  // Reset formulaire
  const resetForm = () => {
    form.value = { code: "", libelle: "" };
    isEditing.value = false;
    editingId.value = null;
  };
  
  onMounted(fetchTypes);
  </script>
  