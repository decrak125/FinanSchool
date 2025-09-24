<script setup>
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'
import { debounce } from 'lodash'

const API_URL = 'http://localhost:8000/api'
const rubriques = ref([])
const classes = ref([])
const showModal = ref(false)
const isEditing = ref(false)

const filters = ref({ search: '', classe: '' })
const form = ref({ id: null, Code_rubrique: '', Libelle: '', Id_Classe: '', suffixe: '' })

const token = localStorage.getItem("token"); // Récupérer le token

if (!token) {
  // Redirection vers login si pas de token
  window.location.href = "/";
} else {
  // Configurer Axios pour inclure le token dans toutes les requêtes
  axios.defaults.headers.common["Authorization"] = `Bearer ${token}`;
}

const loadClasses = async () => {
  const res = await axios.get(`${API_URL}/classes`)
  classes.value = res.data.data || res.data
}

const loadRubriques = async () => {
  const res = await axios.get(`${API_URL}/rubriques`)
  rubriques.value = res.data.data || res.data
}

const filteredRubriques = computed(() => {
  return rubriques.value.filter(r => {
    const matchSearch =
      !filters.value.search ||
      r.Code_rubrique.includes(filters.value.search) ||
      r.Libelle.toLowerCase().includes(filters.value.search.toLowerCase())

    const matchClasse =
      !filters.value.classe || r.Id_Classe === filters.value.classe

    return matchSearch && matchClasse
  })
})

const debounceSearch = debounce((val) => filters.value.search = val, 300)

const openCreateModal = () => {
  isEditing.value = false
  form.value = { id: null, Code_rubrique: '', Libelle: '', Id_Classe: '', suffixe: '' }
  showModal.value = true
}

const openEditModal = (rubrique) => {
  isEditing.value = true
  form.value = {
    id: rubrique.Id_Rubrique,
    Code_rubrique: rubrique.Code_rubrique,
    Libelle: rubrique.Libelle,
    Id_Classe: rubrique.Id_Classe,
    suffixe: rubrique.Code_rubrique.slice(1) // extraire le suffixe
  }
  showModal.value = true
}

const updateCode = () => {
  const classe = classes.value.find(c => c.Id_Classe === form.value.Id_Classe)
  if (classe && form.value.suffixe) {
    form.value.Code_rubrique = classe.Code + form.value.suffixe.padStart(1, "0")
  }
}

const saveRubrique = async () => {
  try {
    if (isEditing.value) {
      await axios.put(`${API_URL}/rubriques/${form.value.id}`, form.value)
    } else {
      await axios.post(`${API_URL}/rubriques`, form.value)
    }
    loadRubriques()
    showModal.value = false
  } catch (e) {
    alert(e.response?.data?.message || "Erreur")
  }
}

const deleteRubrique = async (id) => {
  if (confirm("Supprimer cette rubrique ?")) {
    await axios.delete(`${API_URL}/rubriques/${id}`)
    loadRubriques()
  }
}

onMounted(() => {
  loadClasses()
  loadRubriques()
})
</script>

<template>
  <div>
    <div class="flex justify-between mb-4 gap-2">
      <!-- Champ recherche -->
      <input type="text" placeholder="Rechercher..."
             @input="debounceSearch($event.target.value)"
             class="border px-2 py-1 rounded" />

      <!-- Filtre par classe -->
      <select v-model="filters.classe" class="border px-2 py-1 rounded">
        <option value="">Toutes les classes</option>
        <option v-for="classe in classes" :key="classe.Id_Classe" :value="classe.Id_Classe">
          {{ classe.Code }} - {{ classe.Libelle }}
        </option>
      </select>

      <button @click="openCreateModal"
              class="px-4 py-2 bg-green-500 text-white rounded hover:bg-green-600">
        + Nouvelle Rubrique
      </button>
    </div>

    <table class="w-full border">
      <thead class="bg-gray-100">
        <tr>
          <th class="border px-2 py-1">Code</th>
          <th class="border px-2 py-1">Libellé</th>
          <th class="border px-2 py-1">Classe</th>
          <th class="border px-2 py-1">Actions</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="rubrique in filteredRubriques" :key="rubrique.Id_Rubrique">
          <td class="border px-2 py-1">{{ rubrique.Code_rubrique }}</td>
          <td class="border px-2 py-1">{{ rubrique.Libelle }}</td>
          <td class="border px-2 py-1">{{ rubrique.classe?.Code }} - {{ rubrique.classe?.Libelle }}</td>
          <td class="border px-2 py-1">
            <button @click="openEditModal(rubrique)" class="px-2 py-1 bg-blue-500 text-white rounded">✏️</button>
            <button @click="deleteRubrique(rubrique.Id_Rubrique)" class="px-2 py-1 bg-red-500 text-white rounded">🗑️</button>
          </td>
        </tr>
      </tbody>
    </table>

    <!-- Modal -->
    <div v-if="showModal" class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50">
      <div class="bg-white p-6 rounded-lg w-96">
        <h2 class="text-lg font-bold mb-4">
          {{ isEditing ? 'Modifier Rubrique' : 'Nouvelle Rubrique' }}
        </h2>

        <form @submit.prevent="saveRubrique">
          <div class="mb-4">
            <label>Classe</label>
            <select v-if="!isEditing" v-model="form.Id_Classe" @change="updateCode" required
                    class="mt-1 block w-full border rounded-md">
              <option v-for="classe in classes" :key="classe.Id_Classe" :value="classe.Id_Classe">
                {{ classe.Code }} - {{ classe.Libelle }}
              </option>
            </select>
            <select v-if="isEditing" v-model="form.Id_Classe" @change="updateCode" hidden
                    class="mt-1 block w-full border rounded-md">
              <option v-for="classe in classes" :key="classe.Id_Classe" :value="classe.Id_Classe">
                {{ classe.Code }} - {{ classe.Libelle }}
              </option>
            </select>
          </div>

          <div class="mb-4">
            <label>Suffixe</label>
            <input type="text" v-model="form.suffixe" @input="updateCode"
                   maxlength="1" placeholder="01"
                   class="mt-1 block w-full border rounded-md" required />
          </div>

          <div class="mb-4">
            <label>Code complet</label>
            <input type="text" v-model="form.Code_rubrique" readonly
                   class="mt-1 block w-full border rounded-md" />
          </div>

          <div class="mb-4">
            <label>Libellé</label>
            <input type="text" v-model="form.Libelle"
                   class="mt-1 block w-full border rounded-md" required />
          </div>

          <div class="flex justify-end">
            <button type="button" @click="showModal = false" class="mr-2 px-4 py-2 border rounded">Annuler</button>
            <button type="submit"
                    class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600">
              {{ isEditing ? 'Modifier' : 'Enregistrer' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>
