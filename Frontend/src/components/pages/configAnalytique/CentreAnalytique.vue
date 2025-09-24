<template>
    <div class="p-6">
      <h1 class="text-2xl font-bold mb-4">Gestion des Centres Analytiques</h1>
  
      <!-- Formulaire -->
      <form @submit.prevent="saveCentre" class="mb-6 space-y-3 bg-gray-100 p-4 rounded">
        <div>
          <label class="block font-semibold">Nom</label>
          <input v-model="form.nom" type="text" class="w-full border rounded px-2 py-1" required />
        </div>
        <div>
          <label class="block font-semibold">Description</label>
          <input v-model="form.description" type="text" class="w-full border rounded px-2 py-1" required />
        </div>
        <div>
          <label class="block font-semibold">Axe</label>
          <select v-model="form.id_axe" class="w-full border rounded px-2 py-1" required>
            <option value="" disabled>Choisir un axe</option>
            <option v-for="axe in axes" :key="axe.id_axe" :value="axe.id_axe">{{ axe.axe }}</option>
          </select>
        </div>
        <div>
          <label class="block font-semibold">Type</label>
          <select v-model="form.id_type" class="w-full border rounded px-2 py-1" required>
            <option value="" disabled>Choisir un type</option>
            <option v-for="type in types" :key="type.id_type" :value="type.id_type">{{ type.code }}</option>
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
  
      <!-- Tableau des centres -->
      <table class="w-full border-collapse border">
        <thead>
          <tr class="bg-gray-200">
            <th class="border px-3 py-2">#</th>
            <th class="border px-3 py-2">Nom</th>
            <th class="border px-3 py-2">Description</th>
            <th class="border px-3 py-2">Axe</th>
            <th class="border px-3 py-2">Type</th>
            <th class="border px-3 py-2">Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="centre in centres" :key="centre.id_centre">
            <td class="border px-3 py-2">{{ centre.id_centre }}</td>
            <td class="border px-3 py-2">{{ centre.nom }}</td>
            <td class="border px-3 py-2">{{ centre.description }}</td>
            <td class="border px-3 py-2">{{ getAxeName(centre.id_axe) }}</td>
            <td class="border px-3 py-2">{{ getTypeName(centre.id_type) }}</td>
            <td class="border px-3 py-2 text-center">
              <button @click="editCentre(centre)" class="bg-yellow-500 text-white px-2 py-1 rounded">✏️</button>
              <button @click="deleteCentre(centre.id_centre)" class="ml-2 bg-red-600 text-white px-2 py-1 rounded">🗑️</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </template>
  
  <script setup>
  import { ref, onMounted } from "vue";
  import axios from "axios";
  
  const centres = ref([]);
  const axes = ref([]);
  const types = ref([]);
  const form = ref({ nom: "", description: "", id_axe: "", id_type: "" });
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

  // Charger toutes les données nécessaires
  const fetchCentres = async () => {
    const res = await axios.get("http://127.0.0.1:8000/api/centres");
    centres.value = res.data;
  };
  
  const fetchAxes = async () => {
    const res = await axios.get("http://127.0.0.1:8000/api/axes");
    axes.value = res.data;
  };
  
  const fetchTypes = async () => {
    const res = await axios.get("http://127.0.0.1:8000/api/types");
    types.value = res.data;
  };
  
  // Ajouter / Mettre à jour
  const saveCentre = async () => {
    if (isEditing.value) {
      await axios.put(`http://127.0.0.1:8000/api/centres/${editingId.value}`, form.value);
    } else {
      await axios.post("http://127.0.0.1:8000/api/centres", form.value);
    }
    resetForm();
    fetchCentres();
  };
  
  // Modifier
  const editCentre = (centre) => {
    form.value = { ...centre };
    isEditing.value = true;
    editingId.value = centre.id_centre;
  };
  
  // Annuler modification
  const cancelEdit = () => resetForm();
  
  // Supprimer
  const deleteCentre = async (id) => {
    if (confirm("Supprimer ce centre ?")) {
      await axios.delete(`http://127.0.0.1:8000/api/centres/${id}`);
      fetchCentres();
    }
  };
  
  // Reset formulaire
  const resetForm = () => {
    form.value = { nom: "", description: "", id_axe: "", id_type: "" };
    isEditing.value = false;
    editingId.value = null;
  };
  
  // Fonctions pour afficher noms axe et type
  const getAxeName = (id) => axes.value.find(a => a.id_axe === id)?.axe || "";
  const getTypeName = (id) => types.value.find(t => t.id_type === id)?.code || "";
  
  onMounted(() => {
    fetchCentres();
    fetchAxes();
    fetchTypes();
  });
  </script>
  