<script setup>
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'
import { debounce } from 'lodash'
import { useRouter } from 'vue-router'
import Sidebar from "../../molecules/Sidebar.vue";
import Header from "../../molecules/Header.vue";
import AppFooter from "../../molecules/Footer.vue";
import { getUser } from "../../../services/Auth"; 
const router = useRouter();
const user = ref(null);

const handleNavigation = (item) => {
  router.push(item.route);
};

const API_URL = 'http://localhost:8000/api'
const rubriques = ref([])
const classes = ref([])
const showModal = ref(false)
const isEditing = ref(false)
const currentPage = ref(1)
const itemsPerPage = 10

const filters = ref({ search: '', classe: '' })
const form = ref({ id: null, Code_rubrique: '', Libelle: '', Id_Classe: '', suffixe: '' })

const token = localStorage.getItem("token");

if (!token) {
  window.location.href = "/";
} else {
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

const paginatedRubriques = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage
  const end = start + itemsPerPage
  return filteredRubriques.value.slice(start, end)
})

const totalPages = computed(() => {
  return Math.ceil(filteredRubriques.value.length / itemsPerPage)
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
    suffixe: rubrique.Code_rubrique.slice(1)
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
    currentPage.value = 1
  } catch (e) {
    alert(e.response?.data?.message || "Erreur")
  }
}

const deleteRubrique = async (id) => {
  if (confirm("Supprimer cette rubrique ?")) {
    await axios.delete(`${API_URL}/rubriques/${id}`)
    loadRubriques()
    if (filteredRubriques.value.length <= (currentPage.value - 1) * itemsPerPage) {
      currentPage.value = Math.max(1, currentPage.value - 1)
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
  }
});


</script>

<template>
  <div class="dashboard-container w-full">
    <Header v-if="user" :user="user" />
    <Sidebar :current-route="$route.path" @navigation-change="handleNavigation" />
    
    <div class="main-content p-6">
      <div class="card card-form">
        <div class="card-header">
          <h2 class="card-title text-3xl">Gestion des Rubriques</h2>
        </div>
        
        <div class="card-body">
          <div class="d-flex justify-between mb-6 gap-4 flex-column md:flex-row">
            <div class="form-group w-full">
              <input
                type="text"
                placeholder="Rechercher..."
                @input="debounceSearch($event.target.value)"
                class="form-input w-full text-base rounded-md"
              />
            </div>

            <div class="form-group w-full">
              <select v-model="filters.classe" class="form-select w-full text-base rounded-md">
                <option value="">Toutes les classes</option>
                <option v-for="classe in classes" :key="classe.Id_Classe" :value="classe.Id_Classe">
                  {{ classe.Code }} - {{ classe.Libelle }}
                </option>
              </select>
            </div>

            <button @click="openCreateModal" class="btn btn-success text-base">
              <i class="bi bi-plus-circle mr-1"></i> Nouvelle Rubrique
            </button>
          </div>
          <br>
          
          <div class="table-container mt-6">
            <table class="table table-bordered table-striped w-full">
              <thead>
                <tr>
                  <th class="text-base p-4">Code</th>
                  <th class="text-base p-4">Libellé</th>
                  <th class="text-base p-4">Classe</th>
                  <th class="text-base p-4">Actions</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="rubrique in paginatedRubriques" :key="rubrique.Id_Rubrique" class="fade-in">
                  <td class="p-4 text-base">{{ rubrique.Code_rubrique }}</td>
                  <td class="p-4 text-base">{{ rubrique.Libelle }}</td>
                  <td class="p-4 text-base">{{ rubrique.classe?.Code }} - {{ rubrique.classe?.Libelle }}</td>
                  <td class="d-flex gap-2 p-4">
                    <button @click="openEditModal(rubrique)" class="btn btn-primary text-base">
                      <i class="bi bi-pencil mr-1"></i> Modifier
                    </button>
                    <button @click="deleteRubrique(rubrique.Id_Rubrique)" class="btn btn-error text-base" style="height: 40px; margin-top: 10px;">
                      <i class="bi bi-trash mr-1"></i> Supprimer
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
                <h2 class="modal-title text-2xl">
                  {{ isEditing ? 'Modifier Rubrique' : 'Nouvelle Rubrique' }}
                </h2>
                <button @click="showModal = false" class="modal-close text-base">&times;</button>
              </div>

              <form @submit.prevent="saveRubrique" class="modal-body space-y-4">
                <div class="form-group">
                  <label for="classe" class="form-label required text-base">Classe</label>
                  <select
                    v-if="!isEditing"
                    v-model="form.Id_Classe"
                    @change="updateCode"
                    class="form-select w-full text-base rounded-md"
                    required
                  >
                    <option v-for="classe in classes" :key="classe.Id_Classe" :value="classe.Id_Classe">
                      {{ classe.Code }} - {{ classe.Libelle }}
                    </option>
                  </select>
                  <select
                    v-if="isEditing"
                    v-model="form.Id_Classe"
                    @change="updateCode"
                    class="form-select w-full text-base rounded-md d-none"
                  >
                    <option v-for="classe in classes" :key="classe.Id_Classe" :value="classe.Id_Classe">
                      {{ classe.Code }} - {{ classe.Libelle }}
                    </option>
                  </select>
                </div>

                <div class="form-group">
                  <label for="suffixe" class="form-label required text-base">Suffixe</label>
                  <input
                    type="text"
                    v-model="form.suffixe"
                    @input="updateCode"
                    maxlength="1"
                    placeholder="01"
                    class="form-input w-full text-base rounded-md"
                    required
                  />
                </div>

                <div class="form-group">
                  <label for="code-rubrique" class="form-label text-base">Code complet</label>
                  <input
                    type="text"
                    v-model="form.Code_rubrique"
                    readonly
                    class="form-input w-full text-base rounded-md"
                  />
                </div>

                <div class="form-group">
                  <label for="libelle" class="form-label required text-base">Libellé</label>
                  <input
                    type="text"
                    v-model="form.Libelle"
                    class="form-input w-full text-base rounded-md"
                    required
                  />
                </div>

                <div class="modal-footer d-flex justify-end gap-2">
                  <button type="button" @click="showModal = false" class="btn btn-ghost text-base">
                    Annuler
                  </button>
                  <button type="submit" class="btn btn-primary text-base">
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