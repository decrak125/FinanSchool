<template>
  <div class="p-4 max-w-lg mx-auto">
    <h2 class="text-xl font-bold mb-4">Liste des Types de Journaux</h2>

    <!-- Tableau des types -->
    <table class="min-w-full border-collapse mb-4">
      <thead>
        <tr class="bg-gray-200">
          <th class="border px-4 py-2">#</th>
          <th class="border px-4 py-2">Type</th>
          <th class="border px-4 py-2">Actions</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="(type, index) in types" :key="type.id">
          <td class="border px-4 py-2 text-center">{{ index + 1 }}</td>

          <!-- Affichage ou édition inline -->
          <td class="border px-4 py-2">
            <div v-if="editingId !== type.id">{{ type.Type }}</div>
            <input
              v-else
              v-model="editingValue"
              type="text"
              class="border p-1 rounded w-full"
            />
          </td>

          <!-- Actions -->
          <td class="border px-4 py-2 text-center flex gap-2 justify-center">
            <button
              v-if="editingId !== type.id"
              @click="startEditing(type)"
              class="text-yellow-500 px-2 py-1 border rounded"
            >
              Modifier
            </button>
            <button
              v-else
              @click="updateType(type.id)"
              class="text-green-500 px-2 py-1 border rounded"
            >
              Sauvegarder
            </button>
            <button
              @click="deleteType(type.id)"
              class="text-red-500 px-2 py-1 border rounded"
            >
              Supprimer
            </button>
          </td>
        </tr>
      </tbody>
    </table>

    <!-- Formulaire ajout -->
    <form @submit.prevent="addType" class="flex gap-2">
      <input
        v-model="newType"
        type="text"
        placeholder="Ajouter un type"
        class="border p-2 flex-1 rounded"
      />
      <button type="submit" class="bg-blue-500 text-white px-4 rounded">
        Ajouter
      </button>
    </form>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'

const API_URL = 'http://localhost:8000/api/type-journals'

const types = ref([])
const newType = ref('')

// Pour édition inline
const editingId = ref(null)
const editingValue = ref('')

// Charger la liste
const loadTypes = async () => {
  try {
    const res = await axios.get(API_URL)
    types.value = res.data
  } catch (error) {
    console.error('Erreur chargement types :', error)
  }
}

// Ajouter un type
const addType = async () => {
  if (!newType.value.trim()) return
  try {
    const res = await axios.post(API_URL, { Type: newType.value })
    types.value.push(res.data)
    newType.value = ''
  } catch (error) {
    console.error('Erreur ajout type :', error)
  }
}

// Démarrer l'édition
const startEditing = (type) => {
  editingId.value = type.id
  editingValue.value = type.Type
}

// Sauvegarder la modification
const updateType = async (id) => {
  if (!editingValue.value.trim()) return
  try {
    const res = await axios.put(`${API_URL}/${id}`, { Type: editingValue.value })
    const index = types.value.findIndex(t => t.id === id)
    if (index !== -1) types.value[index] = res.data
    editingId.value = null
    editingValue.value = ''
  } catch (error) {
    console.error('Erreur modification type :', error)
  }
}

// Supprimer un type
const deleteType = async (id) => {
  try {
    await axios.delete(`${API_URL}/${id}`)
    types.value = types.value.filter(t => t.id !== id)
  } catch (error) {
    console.error('Erreur suppression :', error)
  }
}

onMounted(loadTypes)
</script>

<style scoped>
/* Style tableau simple */
table {
  border: 1px solid #ccc;
}
th, td {
  text-align: left;
}
button:hover {
  opacity: 0.8;
  cursor: pointer;
}
</style>
