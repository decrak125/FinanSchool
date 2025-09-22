<script setup>
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'
import { debounce } from 'lodash'

const API_URL = 'http://localhost:8000/api'

const comptes = ref([])
const sousComptes = ref([])
const showModal = ref(false)
const isEditing = ref(false)

const filters = ref({
  compte_id: '',
  search: ''
})

const form = ref({
  id: null,
  Id_Compte: '',
  suffixe: '',
  Code_sous_compte: '',
  Libelle: ''
})

// Charger comptes depuis l'API
const loadComptes = async () => {
  try {
    const response = await axios.get(`${API_URL}/comptes`)
    comptes.value = response.data.data || response.data
    if (comptes.value.length && !form.value.Id_Compte) {
      form.value.Id_Compte = comptes.value[0].Id_Compte
      updateCode()
    }
  } catch (error) {
    console.error('Erreur chargement comptes:', error)
  }
}

// Met à jour le code complet automatiquement
const updateCode = () => {
  const compte = comptes.value.find(c => c.Id_Compte === form.value.Id_Compte)
  if (compte && compte.Code_compte) {
    form.value.Code_sous_compte = compte.Code_compte + form.value.suffixe.padStart(3, '0')
  } else {
    form.value.Code_sous_compte = form.value.suffixe
  }
}

// Ouvrir modal création
const openCreateModal = () => {
  isEditing.value = false
  form.value = { id: null, Id_Compte: comptes.value[0]?.Id_Compte || '', suffixe: '', Code_sous_compte: '', Libelle: '' }
  showModal.value = true
}

// Ouvrir modal édition
const openEditModal = async (sousCompte) => {
  isEditing.value = true
  form.value.id = sousCompte.Id_Sous_compte
  form.value.Id_Compte = sousCompte.Id_Compte
  form.value.Libelle = sousCompte.Libelle
  form.value.suffixe = sousCompte.Code_sous_compte.slice(-3)
  updateCode()
  showModal.value = true
}

// Sauvegarder (création / modification)
const saveSousCompte = async () => {
  try {
    if (isEditing.value) {
      await axios.put(`${API_URL}/sous-comptes/${form.value.id}`, form.value)
      alert('Sous-compte modifié avec succès')
    } else {
      await axios.post(`${API_URL}/sous-comptes`, form.value)
      alert('Sous-compte créé avec succès')
    }
    showModal.value = false
    loadSousComptes()
  } catch (error) {
    console.error('Erreur enregistrement sous-compte:', error.response?.data || error.message)
    alert('Erreur enregistrement sous-compte')
  }
}

// Supprimer
const deleteSousCompte = async (id) => {
  if (confirm('Voulez-vous vraiment supprimer ce sous-compte ?')) {
    try {
      await axios.delete(`${API_URL}/sous-comptes/${id}`)
      alert('Sous-compte supprimé avec succès')
      loadSousComptes()
    } catch (error) {
      console.error('Erreur suppression sous-compte:', error.response?.data || error.message)
      alert('Erreur suppression sous-compte')
    }
  }
}

// Liste des sous-comptes
const loadSousComptes = async () => {
  try {
    const res = await axios.get(`${API_URL}/sous-comptes`)
    sousComptes.value = res.data.data || res.data
  } catch (err) {
    console.error(err)
  }
}

// Recherche avec debounce
const debounceSearch = debounce((val) => {
  filters.value.search = val
}, 300)

// Sous-comptes filtrés
const filteredSousComptes = computed(() => {
  return sousComptes.value.filter(sc => {
    const matchCompte = !filters.value.compte_id || sc.Id_Compte == filters.value.compte_id
    const matchSearch = !filters.value.search ||
      sc.Code_sous_compte?.toLowerCase().includes(filters.value.search.toLowerCase()) ||
      sc.Libelle?.toLowerCase().includes(filters.value.search.toLowerCase())
    return matchCompte && matchSearch
  })
})

onMounted(() => {
  loadComptes()
  loadSousComptes()
})
</script>

<template>
  <div class="container mx-auto p-4">
    <h1 class="text-2xl font-bold mb-4">Gestion des sous-comptes</h1>

    <!-- Filtres -->
    <div class="mb-4 grid grid-cols-1 md:grid-cols-2 gap-4">
      <div>
        <label>Compte</label>
        <select v-model="filters.compte_id" class="mt-1 block w-full border rounded-md">
          <option value="">Tous les comptes</option>
          <option v-for="compte in comptes" :key="compte.Id_Compte" :value="compte.Id_Compte">
            {{ compte.Code_compte }}
          </option>
        </select>
      </div>
      <div>
        <label>Recherche</label>
        <input type="text" placeholder="Code ou libellé..." class="mt-1 block w-full border rounded-md"
               :value="filters.search" @input="debounceSearch($event.target.value)" />
      </div>
    </div>

    <button @click="openCreateModal" class="mb-4 bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600">
      Nouveau sous-compte
    </button>

    <table class="min-w-full divide-y divide-gray-200">
      <thead class="bg-gray-50">
        <tr>
          <th class="px-6 py-3 text-left">Code</th>
          <th class="px-6 py-3 text-left">Libellé</th>
          <th class="px-6 py-3 text-left">Compte</th>
          <th class="px-6 py-3 text-left">Actions</th>
        </tr>
      </thead>
      <tbody class="bg-white divide-y divide-gray-200">
        <tr v-for="sc in filteredSousComptes" :key="sc.Id_Sous_compte">
          <td class="px-6 py-3">{{ sc.Code_sous_compte }}</td>
          <td class="px-6 py-3">{{ sc.Libelle }}</td>
          <td class="px-6 py-3">{{ sc.compte?.Code_compte }}</td>
          <td class="px-6 py-3">
            <button @click="openEditModal(sc)" class="text-blue-600 hover:text-blue-900 mr-2">Modifier</button>
            <button @click="deleteSousCompte(sc.Id_Sous_compte)" class="text-red-600 hover:text-red-900">Supprimer</button>
          </td>
        </tr>
      </tbody>
    </table>

    <!-- Modal -->
    <div v-if="showModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center">
      <div class="bg-white p-6 rounded-lg w-full max-w-md">
        <h2 class="text-xl font-bold mb-4">{{ isEditing ? 'Modifier le sous-compte' : 'Nouveau sous-compte' }}</h2>
        <form @submit.prevent="saveSousCompte">
          <div class="mb-4">
            <label>Compte</label>
            <select v-model="form.Id_Compte" @change="updateCode" required class="mt-1 block w-full border rounded-md">
              <option v-for="compte in comptes" :key="compte.Id_Compte" :value="compte.Id_Compte">
                {{ compte.Code_compte }}
              </option>
            </select>
          </div>
          <div class="mb-4">
            <label>Suffixe</label>
            <input type="text" v-model="form.suffixe" @input="updateCode" maxlength="3" placeholder="001"
                   class="mt-1 block w-full border rounded-md" required />
          </div>
          <div class="mb-4">
            <label>Code complet</label>
            <input type="text" v-model="form.Code_sous_compte" readonly class="mt-1 block w-full border rounded-md" />
          </div>
          <div class="mb-4">
            <label>Libellé</label>
            <input type="text" v-model="form.Libelle" class="mt-1 block w-full border rounded-md" required />
          </div>
          <div class="flex justify-end">
            <button type="button" @click="showModal = false" class="mr-2 px-4 py-2 border rounded">Annuler</button>
            <button type="submit" class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600">
              {{ isEditing ? 'Modifier' : 'Enregistrer' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>
