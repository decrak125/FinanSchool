<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import axios from 'axios'
import { debounce } from 'lodash'

const classes = ref([])
const rubriques = ref([])
const comptes = ref([])
const showModal = ref(false)
const isEditing = ref(false)

const API_URL = 'http://localhost:8000/api'

const filters = ref({
  classe_id: '',
  rubrique_id: '',
  compte_id: '',
  search: ''
})

const form = ref({
  id: null,
  Code_compte: '',
  Libelle: '',
  Id_Rubrique: '',
  Id_Classe: '',
  suffixe: ''
})

// Charger classes
const loadClasses = async () => {
  try {
    const response = await axios.get(`${API_URL}/classes`)
    classes.value = response.data.data || response.data
  } catch (error) {
    console.error('Erreur chargement classes:', error)
  }
}

// Charger rubriques
const loadRubriques = async () => {
  try {
    const response = await axios.get(`${API_URL}/rubriques`)
    rubriques.value = response.data.data || response.data
  } catch (error) {
    console.error('Erreur chargement rubriques:', error)
  }
}

// Charger comptes
const loadComptes = async () => {
  try {
    const response = await axios.get(`${API_URL}/comptes`)
    comptes.value = response.data.data || response.data
  } catch (error) {
    console.error('Erreur chargement comptes:', error)
  }
}

// Filtrage côté front
const filteredComptes = computed(() => {
  return comptes.value.filter(c => {
    const matchClasse = !filters.value.classe_id || c.rubrique?.Id_Classe == filters.value.classe_id
    const matchRubrique = !filters.value.rubrique_id || c.Id_Rubrique == filters.value.rubrique_id
    const matchCompte = !filters.value.compte_id || c.Id_Compte == filters.value.compte_id
    const matchSearch = !filters.value.search ||
      c.Code_compte?.toLowerCase().includes(filters.value.search.toLowerCase()) ||
      c.Libelle?.toLowerCase().includes(filters.value.search.toLowerCase())
    return matchClasse && matchRubrique && matchCompte && matchSearch
  })
})

// Debounce search
const debounceSearch = debounce((val) => {
  filters.value.search = val
}, 300)

// Modal création
const openCreateModal = () => {
  isEditing.value = false
  form.value = { id: null, Code_compte: '', Libelle: '', Id_Rubrique: '', Id_Classe: '', suffixe: '' }
  showModal.value = true
}

// Modal édition
const openEditModal = (compte) => {
  isEditing.value = true
  form.value = {
    id: compte.Id_Compte,
    Code_compte: compte.Code_compte,
    Libelle: compte.Libelle,
    Id_Rubrique: compte.Id_Rubrique,
    Id_Classe: compte.rubrique?.Id_Classe || '',
    suffixe: compte.Code_compte.slice(-1) // récupérer le dernier chiffre comme suffixe
  }
  showModal.value = true
}

// Génération automatique du Code_compte
const updateCode = () => {
  const rubrique = rubriques.value.find(r => r.Id_Rubrique === form.value.Id_Rubrique)
  if (rubrique && form.value.suffixe) {
    form.value.Code_compte = `${rubrique.Code_rubrique}${form.value.suffixe.padStart(1, '0')}`
  } else {
    form.value.Code_compte = ''
  }
}

// Watch pour mettre à jour Code_compte automatiquement
watch(
  () => [form.value.Id_Rubrique, form.value.suffixe],
  () => {
    updateCode()
  }
)

// Sauvegarde
const saveCompte = async () => {
  if (!form.value.Code_compte || !form.value.Libelle || !form.value.Id_Rubrique) {
    alert('Tous les champs sont obligatoires')
    return
  }

  try {
    if (isEditing.value) {
      await axios.put(`${API_URL}/comptes/${form.value.id}`, form.value)
      alert('Compte modifié avec succès')
    } else {
      await axios.post(`${API_URL}/comptes`, form.value)
      alert('Compte créé avec succès')
    }
    showModal.value = false
    loadComptes()
  } catch (error) {
    console.error('Erreur enregistrement compte:', error.response?.data || error.message)
    alert(error.response?.data?.message || 'Erreur enregistrement compte')
  }
}

// Suppression
const deleteCompte = async (id) => {
  if (confirm('Voulez-vous vraiment supprimer ce compte ?')) {
    try {
      await axios.delete(`${API_URL}/comptes/${id}`)
      alert('Compte supprimé avec succès')
      loadComptes()
    } catch (error) {
      console.error('Erreur suppression compte:', error.response?.data || error.message)
      alert('Erreur suppression compte')
    }
  }
}

onMounted(() => {
  loadClasses()
  loadRubriques()
  loadComptes()
})
</script>

<template>
  <div class="container mx-auto p-4">
    <h1 class="text-2xl font-bold mb-4">Gestion des comptes comptables</h1>
    
    <!-- Filtres -->
    <div class="mb-4 grid grid-cols-1 md:grid-cols-4 gap-4">
      <div>
        <label class="block text-sm font-medium text-gray-700">Classe</label>
        <select v-model="filters.classe_id" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm">
          <option value="">Toutes les classes</option>
          <option v-for="classe in classes" :key="classe.id" :value="classe.Id_Classe">{{ classe.Code }}</option>
        </select>
      </div>
      
      <div>
        <label class="block text-sm font-medium text-gray-700">Rubrique</label>
        <select v-model="filters.rubrique_id" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm">
          <option value="">Toutes les rubriques</option>
          <option v-for="rubrique in rubriques" :key="rubrique.id" :value="rubrique.Id_Rubrique">{{ rubrique.Code_rubrique }}</option>
        </select>
      </div>
      
      <div>
        <label class="block text-sm font-medium text-gray-700">Compte</label>
        <select v-model="filters.compte_id" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm">
          <option value="">Tous les comptes</option>
          <option v-for="compte in comptes" :key="compte.id" :value="compte.Id_Compte">{{ compte.Code_compte }}</option>
        </select>
      </div>
      
      <div>
        <label class="block text-sm font-medium text-gray-700">Recherche</label>
        <input :value="filters.search" @input="debounceSearch($event.target.value)" type="text" placeholder="Rechercher un compte..." 
               class="mt-1 block w-full rounded-md border-gray-300 shadow-sm">
      </div>
    </div>

    <!-- Bouton nouveau compte -->
    <button @click="openCreateModal" class="mb-4 bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600">
      Nouveau compte
    </button>

    <!-- Tableau des comptes -->
    <div class="overflow-x-auto">
      <table class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gray-50">
          <tr>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Numéro</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Nom</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Classe</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Rubrique</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-200">
          <tr v-for="compte in filteredComptes" :key="compte.id">
            <td class="px-6 py-3">{{ compte.Code_compte }}</td>
            <td class="px-6 py-3">{{ compte.Libelle }}</td>
            <td class="px-6 py-3">{{ compte.rubrique?.Id_Classe }}</td>
            <td class="px-6 py-3">{{ compte.rubrique?.Libelle }}</td>
            <td class="px-6 py-3">
              <button @click="openEditModal(compte)" class="text-blue-600 hover:text-blue-900 mr-2">Modifier</button>
              <button @click="deleteCompte(compte.Id_Compte)" class="text-red-600 hover:text-red-900">Supprimer</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Modal -->
    <div v-if="showModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center">
      <div class="bg-white p-6 rounded-lg w-full max-w-md">
        <h2 class="text-xl font-bold mb-4">{{ isEditing ? 'Modifier le compte' : 'Nouveau compte' }}</h2>
        <form @submit.prevent="saveCompte">
  <div class="mb-4">
    <label>Rubrique</label>
    <select v-model="form.Id_Rubrique" @change="updateCode" required class="mt-1 block w-full border rounded-md">
      <option value="">Sélectionner une rubrique</option>
      <option v-for="rubrique in rubriques" :key="rubrique.Id_Rubrique" :value="rubrique.Id_Rubrique">
        {{ rubrique.Code_rubrique }} - {{ rubrique.Libelle }}
      </option>
    </select>
  </div>

  <div class="mb-4">
    <label>Suffixe</label>
    <input type="text" v-model="form.suffixe" @input="updateCode" maxlength="1" placeholder="1"
           class="mt-1 block w-full border rounded-md" required />
  </div>

  <div class="mb-4">
    <label>Code complet</label>
    <input type="text" v-model="form.Code_compte" readonly class="mt-1 block w-full border rounded-md" />
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
