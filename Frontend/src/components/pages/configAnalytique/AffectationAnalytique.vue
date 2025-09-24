<template>
    <div class="p-6">
      <h1 class="text-2xl font-bold mb-4">Gestion des Affectations Analytiques</h1>
  
      <!-- Formulaire -->
      <form @submit.prevent="saveAffectation" class="mb-6 space-y-3 bg-gray-100 p-4 rounded">
        <div>
          <label class="block font-semibold">Sous-compte</label>
          <select v-model="form.Id_Sous_compte" class="w-full border rounded px-2 py-1" required>
            <option value="" disabled>-- Sélectionner un sous-compte --</option>
            <option v-for="sous in sousComptes" :key="sous.Id_Sous_compte" :value="sous.Id_Sous_compte">
              {{ sous.Code_sous_compte }} - {{ sous.Libelle }}
            </option>
          </select>
        </div>
        <div>
          <label class="block font-semibold">Centre Analytique</label>
          <select v-model="form.id_centre" class="w-full border rounded px-2 py-1" required>
            <option value="" disabled>-- Sélectionner un centre --</option>
            <option v-for="centre in centres" :key="centre.id_centre" :value="centre.id_centre">
              {{ centre.nom }}
            </option>
          </select>
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
            <td class="border px-3 py-2">{{ affectation.sous_compte?.Code_sous_compte }} - {{ affectation.sous_compte?.Libelle }}</td>
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
  const sousComptes = ref([]);
  
  const form = ref({ Id_Sous_compte: null, id_centre: null, description: "" });
  const isEditing = ref(false);
  const editingId = ref(null);
  
  // Charger toutes les données nécessaires
  const fetchData = async () => {
    const [resAffectations, resCentres, resSousComptes] = await Promise.all([
      axios.get("http://127.0.0.1:8000/api/affectations"),
      axios.get("http://127.0.0.1:8000/api/centres"),
      axios.get("http://127.0.0.1:8000/api/sous-comptes")
    ]);
    affectations.value = resAffectations.data;
    centres.value = resCentres.data;
    sousComptes.value = resSousComptes.data;
  };
  
  // Ajouter / Mettre à jour
  const saveAffectation = async () => {
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
    isEditing.value = true;
    editingId.value = affectation.id_affectation;
  };
  
  // Annuler modification
  const cancelEdit = () => resetForm();
  
  // Supprimer
  const deleteAffectation = async (id) => {
    if (confirm("Supprimer cette affectation ?")) {
      await axios.delete(`http://127.0.0.1:8000/api/affectations/${id}`);
      fetchData();
    }
  };
  
  // Reset formulaire
  const resetForm = () => {
    form.value = { Id_Sous_compte: null, id_centre: null, description: "" };
    isEditing.value = false;
    editingId.value = null;
  };
  
  onMounted(fetchData);
  </script>
  