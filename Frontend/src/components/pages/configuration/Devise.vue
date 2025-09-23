<template>
    <div class="p-6">
      <h1 class="text-2xl font-bold mb-4">Gestion des Devises</h1>
  
      <!-- Formulaire -->
      <form @submit.prevent="saveDevise" class="mb-6 space-y-3 bg-gray-100 p-4 rounded">
        <div>
          <label class="block font-semibold">Libellé</label>
          <input v-model="form.Libelle" type="text" class="w-full border rounded px-2 py-1" required />
        </div>
        <div>
          <label class="block font-semibold">Code</label>
          <input v-model="form.Code" type="text" class="w-full border rounded px-2 py-1" required />
        </div>
        <div>
          <label class="block font-semibold">Sigle</label>
          <input v-model="form.Sigle" type="text" class="w-full border rounded px-2 py-1" required />
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
  
      <!-- Tableau des devises -->
      <table class="w-full border-collapse border">
        <thead>
          <tr class="bg-gray-200">
            <th class="border px-3 py-2">#</th>
            <th class="border px-3 py-2">Libellé</th>
            <th class="border px-3 py-2">Code</th>
            <th class="border px-3 py-2">Sigle</th>
            <th class="border px-3 py-2">Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="devise in devises" :key="devise.Id_Devise">
            <td class="border px-3 py-2">{{ devise.Id_Devise }}</td>
            <td class="border px-3 py-2">{{ devise.Libelle }}</td>
            <td class="border px-3 py-2">{{ devise.Code }}</td>
            <td class="border px-3 py-2">{{ devise.Sigle }}</td>
            <td class="border px-3 py-2 text-center">
              <button @click="editDevise(devise)" class="bg-yellow-500 text-white px-2 py-1 rounded">✏️</button>
              <button @click="deleteDevise(devise.Id_Devise)" class="ml-2 bg-red-600 text-white px-2 py-1 rounded">🗑️</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </template>
  
  <script setup>
  import { ref, onMounted } from "vue";
  import axios from "axios";
  
  const devises = ref([]);
  const form = ref({
    Libelle: "",
    Code: "",
    Sigle: "",
  });
  const isEditing = ref(false);
  const editingId = ref(null);
  
  // Charger les devises
  const fetchDevises = async () => {
    const res = await axios.get("http://127.0.0.1:8000/api/devises");
    devises.value = res.data;
  };
  
  // Sauvegarder (ajout ou update)
  const saveDevise = async () => {
    if (isEditing.value) {
      await axios.put(`http://127.0.0.1:8000/api/devises/${editingId.value}`, form.value);
    } else {
      await axios.post("http://127.0.0.1:8000/api/devises", form.value);
    }
    resetForm();
    fetchDevises();
  };
  
  // Modifier
  const editDevise = (devise) => {
    form.value = { ...devise };
    isEditing.value = true;
    editingId.value = devise.Id_Devise;
  };
  
  // Annuler modification
  const cancelEdit = () => {
    resetForm();
  };
  
  // Supprimer
  const deleteDevise = async (id) => {
    if (confirm("Supprimer cette devise ?")) {
      await axios.delete(`http://127.0.0.1:8000/api/devises/${id}`);
      fetchDevises();
    }
  };
  
  // Reset formulaire
  const resetForm = () => {
    form.value = { Libelle: "", Code: "", Sigle: "" };
    isEditing.value = false;
    editingId.value = null;
  };
  
  onMounted(() => {
    fetchDevises();
  });
  </script>
  
  <style scoped>
  table {
    margin-top: 1rem;
  }
  </style>
  