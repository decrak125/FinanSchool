<template>
<PageAnalyse>
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
</PageAnalyse>
</template>

<script setup>
import { onMounted } from "vue";
import {useAxes} from "@/composables/useAxes";
import PageAnalyse from "@/components/template/Page-analyse.vue";
const { axes,
    form,
    isEditing,
    editingId,
    file,
    importMessage,
    importSuccess,
    fetchAxes,
    saveAxe,
    editAxe,
    cancelEdit,
    deleteAxe,
    onFileChange,
    uploadFile } = useAxes();
onMounted(fetchAxes);
</script>
