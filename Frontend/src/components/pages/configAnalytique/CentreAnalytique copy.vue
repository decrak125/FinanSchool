<script setup>
import { onMounted } from 'vue';
import { useCentres } from '@/composables/useCentres';
import PageAnalyse from '@/components/template/Page-analyse.vue';

const {
  API_URL,
  centres,
  axes,
  types,
  form,
  isEditing,
  editingId,
  fileInput,
  importMessage,
  importSuccess,
  fetchCentres,
  fetchAxes,
  fetchTypes,
  saveCentre,
  editCentre,
  cancelEdit,
  deleteCentre,
  resetForm,
  getAxeName,
  getTypeName,
  importCSV,
} = useCentres();
</script>

<template>
  <PageAnalyse>
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
      <!-- Formulaire import CSV -->
    <form @submit.prevent="importCSV" class="mb-6 space-y-3 bg-gray-100 p-4 rounded">
      <div>
        <label class="block font-semibold">Importer un CSV</label>
        <input type="file"  ref="fileInput" class="w-full" />
      </div>
      <div>
        <button type="submit" class="bg-blue-600 text-white px-4 py-2 rounded">
          Importer
        </button>
      </div>
      <p v-if="importMessage" :class="importSuccess ? 'text-green-600' : 'text-red-600'">
        {{ importMessage }}
      </p>
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

  </PageAnalyse>
</template>
  
 
  