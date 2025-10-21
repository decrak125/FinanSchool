<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import axios from 'axios'
import { debounce } from 'lodash'
import { useRouter } from 'vue-router'
import Sidebar from "../../molecules/Sidebar.vue";
import Header from "../../molecules/Header.vue";
import AppFooter from "../../molecules/Footer.vue";
import { getUser } from "../../../services/Auth"; // Ajuste le chemin


const router = useRouter();
const user = ref(null);
const handleNavigation = (item) => {
  router.push(item.route);
};

const classes = ref([])
const rubriques = ref([])
const comptes = ref([])
const showModal = ref(false)
const isEditing = ref(false)
const currentPage = ref(1)
const itemsPerPage = 20

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

const token = localStorage.getItem("token");



const loadClasses = async () => {
  try {
    const response = await axios.get(`${API_URL}/classes`)
    classes.value = response.data.data || response.data
  } catch (error) {
    console.error('Erreur chargement classes:', error)
  }
}

const loadRubriques = async () => {
  try {
    const response = await axios.get(`${API_URL}/rubriques`)
    rubriques.value = response.data.data || response.data
  } catch (error) {
    console.error('Erreur chargement rubriques:', error)
  }
}

const loadComptes = async () => {
  try {
    const response = await axios.get(`${API_URL}/comptes`)
    comptes.value = response.data.data || response.data
  } catch (error) {
    console.error('Erreur chargement comptes:', error)
  }
}

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

const paginatedComptes = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage
  const end = start + itemsPerPage
  return filteredComptes.value.slice(start, end)
})

const totalPages = computed(() => {
  return Math.ceil(filteredComptes.value.length / itemsPerPage)
})

const prevPage = () => {
  if (currentPage.value > 1) {
    currentPage.value--
  }
}

const nextPage = () => {
  if (currentPage.value < totalPages.value) {
    currentPage.value++
  }
}

const goToPage = (page) => {
  currentPage.value = page
}

const debounceSearch = debounce((val) => {
  filters.value.search = val
  currentPage.value = 1
}, 300)

const openCreateModal = () => {
  isEditing.value = false
  form.value = { id: null, Code_compte: '', Libelle: '', Id_Rubrique: '', Id_Classe: '', suffixe: '' }
  showModal.value = true
}

const openEditModal = (compte) => {
  isEditing.value = true
  form.value = {
    id: compte.Id_Compte,
    Code_compte: compte.Code_compte,
    Libelle: compte.Libelle,
    Id_Rubrique: compte.Id_Rubrique,
    Id_Classe: compte.rubrique?.Id_Classe || '',
    suffixe: compte.Code_compte.slice(-1)
  }
  showModal.value = true
}

const updateCode = () => {
  const rubrique = rubriques.value.find(r => r.Id_Rubrique === form.value.Id_Rubrique)
  if (rubrique && form.value.suffixe) {
    form.value.Code_compte = `${rubrique.Code_rubrique}${form.value.suffixe.padStart(1, '0')}`
  } else {
    form.value.Code_compte = ''
  }
}

watch(
  () => [form.value.Id_Rubrique, form.value.suffixe],
  () => {
    updateCode()
  }
)

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
    currentPage.value = 1
  } catch (error) {
    console.error('Erreur enregistrement compte:', error.response?.data || error.message)
    alert(error.response?.data?.message || 'Erreur enregistrement compte')
  }
}

const deleteCompte = async (id) => {
  if (confirm('Voulez-vous vraiment supprimer ce compte ?')) {
    try {
      await axios.delete(`${API_URL}/comptes/${id}`)
      alert('Compte supprimé avec succès')
      loadComptes()
      if (filteredComptes.value.length <= (currentPage.value - 1) * itemsPerPage) {
        currentPage.value = Math.max(1, currentPage.value - 1)
      }
    } catch (error) {
      console.error('Erreur suppression compte:', error.response?.data || error.message)
      alert('Erreur suppression compte')
    }
  }
}

onMounted(async () => {
  console.log("Token récupéré :", token); // Vérifie si le token existe
  
  if (!token) {
    console.log("Pas de token → Redirection vers /");
    window.location.href = "/";
  } else {
    axios.defaults.headers.common["Authorization"] = `Bearer ${token}`;
    try {
      console.log("Appel getUser en cours...");
      const res = await getUser(token);
      user.value = res.data;
      console.log("User récupéré :", user.value);
    } catch (err) {
      console.error("Erreur lors de getUser :", err);
      localStorage.removeItem("token");
      window.location.href = "/";
      return; // Important : arrête l'exécution
    }
    loadClasses();
    loadRubriques();
    loadComptes();
  }
});
</script>

<template>
  <div class="dashboard-container">
    <Header v-if="user" :user="user" />
  <div v-else class="loading">Chargement...</div>
    <Sidebar :current-route="$route.path" @navigation-change="handleNavigation" />
    <div class="main-content p-4">
      <div class="card card-form">
        <div class="card-header">
          <h1 class="card-title text-2xl">Gestion des Comptes Comptables</h1>
        </div>
        <div class="card-body">
          <div class="d-flex flex-column md:flex-row gap-3 mb-4">
            <div class="form-group w-full">
              <label for="classe" class="form-label">Classe</label>
              <select v-model="filters.classe_id" class="form-select w-full">
                <option value="">Toutes les classes</option>
                <option v-for="classe in classes" :key="classe.id" :value="classe.Id_Classe">
                  {{ classe.Code }}
                </option>
              </select>
            </div>
            <div class="form-group w-full">
              <label for="rubrique" class="form-label">Rubrique</label>
              <select v-model="filters.rubrique_id" class="form-select w-full">
                <option value="">Toutes les rubriques</option>
                <option v-for="rubrique in rubriques" :key="rubrique.id" :value="rubrique.Id_Rubrique">
                  {{ rubrique.Code_rubrique }}
                </option>
              </select>
            </div>
            <div class="form-group w-full">
              <label for="compte" class="form-label">Compte</label>
              <select v-model="filters.compte_id" class="form-select w-full">
                <option value="">Tous les comptes</option>
                <option v-for="compte in comptes" :key="compte.id" :value="compte.Id_Compte">
                  {{ compte.Code_compte }}
                </option>
              </select>
            </div>
            <div class="form-group w-full">
              <label for="search" class="form-label">Recherche</label>
              <input
                :value="filters.search"
                @input="debounceSearch($event.target.value)"
                type="text"
                placeholder="Rechercher un compte..."
                class="form-input w-full"
              />
            </div>
          </div>
          <button @click="openCreateModal" class="btn btn-primary mb-4">
            Nouveau compte
          </button>
          
          <div class="table-container" style="margin-top: 20px;">
            <table class="table table-bordered table-striped">
              <thead>
                <tr>
                  <th class="text-sm">Numéro</th>
                  <th class="text-sm">Nom</th>
                  <th class="text-sm">Classe</th>
                  <th class="text-sm">Rubrique</th>
                  <th class="text-sm">Actions</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="compte in paginatedComptes" :key="compte.id" class="fade-in">
                  <td>{{ compte.Code_compte }}</td>
                  <td>{{ compte.Libelle }}</td>
                  <td>{{ compte.rubrique?.classe?.Code }}</td>
                  <td>{{ compte.rubrique?.Libelle }}</td>
                  <td class="d-flex gap-2">
                    <button @click="openEditModal(compte)" class="btn btn-primary text-base">
                      Modifier
                    </button>
                    <button @click="deleteCompte(compte.Id_Compte)" class="btn btn-error text-base" style="height: 40px; margin-top: 10px;">
                      Supprimer
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
          <br>
          <div v-if="totalPages > 1" class="d-flex justify-center mt-6 gap-2">
            <button
              @click="prevPage"
              :disabled="currentPage === 1"
              class="btn btn-ghost btn-sm text-base"
              aria-label="Page précédente"
            >
              <i class="bi bi-chevron-left"></i>
            </button>
            <button
              v-for="page in totalPages"
              :key="page"
              @click="goToPage(page)"
              class="btn"
              :class="{'btn-primary': currentPage === page, 'btn-ghost': currentPage !== page}"
              aria-label="Page {{ page }}"
            >
              {{ page }}
            </button>
            <button
              @click="nextPage"
              :disabled="currentPage === totalPages"
              class="btn btn-ghost btn-sm text-base"
              aria-label="Page suivante"
            >
              <i class="bi bi-chevron-right"></i>
            </button>
          </div>
          <div v-if="showModal" class="modal-overlay">
            <div class="modal">
              <div class="modal-header">
                <h2 class="modal-title">
                  {{ isEditing ? 'Modifier le compte' : 'Nouveau compte' }}
                </h2>
                <button @click="showModal = false" class="modal-close">×</button>
              </div>
              <form @submit.prevent="saveCompte" class="modal-body">
                <div class="form-group">
                  <label for="rubrique" class="form-label required">Rubrique</label>
                  <select
                    v-model="form.Id_Rubrique"
                    @change="updateCode"
                    class="form-select w-full"
                    required
                  >
                    <option value="">Sélectionner une rubrique</option>
                    <option
                      v-for="rubrique in rubriques"
                      :key="rubrique.Id_Rubrique"
                      :value="rubrique.Id_Rubrique"
                    >
                      {{ rubrique.Code_rubrique }} - {{ rubrique.Libelle }}
                    </option>
                  </select>
                </div>
                <div class="form-group">
                  <label for="suffixe" class="form-label required">Suffixe</label>
                  <input
                    type="text"
                    v-model="form.suffixe"
                    @input="updateCode"
                    maxlength="1"
                    placeholder="1"
                    class="form-input w-full"
                    required
                  />
                </div>
                <div class="form-group">
                  <label for="code-compte" class="form-label">Code complet</label>
                  <input
                    type="text"
                    v-model="form.Code_compte"
                    readonly
                    class="form-input w-full"
                  />
                </div>
                <div class="form-group">
                  <label for="libelle" class="form-label required">Libellé</label>
                  <input
                    type="text"
                    v-model="form.Libelle"
                    class="form-input w-full"
                    required
                  />
                </div>
                <div class="modal-footer">
                  <button type="button" @click="showModal = false" class="btn btn-ghost">
                    Annuler
                  </button>
                  <button type="submit" class="btn btn-primary">
                    {{ isEditing ? 'Modifier' : 'Enregistrer' }}
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
        <AppFooter />
      </div>
    </div>
  </div>
</template>

<style scoped>
.dashboard-container {
  display: flex;
  min-height: 100vh;
  flex-direction: column;
}

.main-content {
  margin-left: 278px;
  padding: 32px;
  flex: 1;
  background: #f8fafc;
  min-height: calc(100vh - 80px);
}

@media (max-width: 768px) {
  .main-content {
    margin-left: 0;
    padding: 16px;
  }
}
</style>