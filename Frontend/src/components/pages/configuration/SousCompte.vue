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
const showChat = ref(false);

const handleNavigation = (item) => {
  router.push(item.route);
};

const API_URL = 'http://localhost:8000/api'

const comptes = ref([])
const sousComptes = ref([])
const showModal = ref(false)
const isEditing = ref(false)
const currentPage = ref(1)
const itemsPerPage = 10

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

const token = localStorage.getItem("token");

if (!token) {
  window.location.href = "/";
} else {
  axios.defaults.headers.common["Authorization"] = `Bearer ${token}`;
}

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

const updateCode = () => {
  const compte = comptes.value.find(c => c.Id_Compte === form.value.Id_Compte)
  if (compte && compte.Code_compte) {
    form.value.Code_sous_compte = compte.Code_compte + form.value.suffixe.padStart(3, '0')
  } else {
    form.value.Code_sous_compte = form.value.suffixe
  }
}

const openCreateModal = () => {
  isEditing.value = false
  form.value = { id: null, Id_Compte: comptes.value[0]?.Id_Compte || '', suffixe: '', Code_sous_compte: '', Libelle: '' }
  showModal.value = true
}

const openEditModal = async (sousCompte) => {
  isEditing.value = true
  form.value.id = sousCompte.Id_Sous_compte
  form.value.Id_Compte = sousCompte.Id_Compte
  form.value.Libelle = sousCompte.Libelle
  form.value.suffixe = sousCompte.Code_sous_compte.slice(-3)
  updateCode()
  showModal.value = true
}

const saveSousCompte = async () => {
  try {
    if (isEditing.value) {
      await axios.put(`${API_URL}/sous-comptes/${form.value.id}`, form.value)
      alert('Sous-compte modifié avec succès')
    } else {
      await axios.post(`${API_URL}/sous-comptes`, form.value)
      alert('Sous-compte créé avec succès')

      // Appel API d’assignation automatique juste après la création
      await axios.post(`${API_URL}/assigner-toutes-automatiquement`);
    }
    showModal.value = false
    loadSousComptes()
    currentPage.value = 1
  } catch (error) {
    console.error('Erreur enregistrement sous-compte:', error.response?.data || error.message)
    alert('Erreur enregistrement sous-compte')
  }
}


const deleteSousCompte = async (id) => {
  if (confirm('Voulez-vous vraiment supprimer ce sous-compte ?')) {
    try {
      await axios.delete(`${API_URL}/sous-comptes/${id}`)
      alert('Sous-compte supprimé avec succès')
      loadSousComptes()
      if (filteredSousComptes.value.length <= (currentPage.value - 1) * itemsPerPage) {
        currentPage.value = Math.max(1, currentPage.value - 1)
      }
    } catch (error) {
      console.error('Erreur suppression sous-compte:', error.response?.data || error.message)
      alert('Erreur suppression sous-compte')
    }
  }
}

const loadSousComptes = async () => {
  try {
    const res = await axios.get(`${API_URL}/sous-comptes`)
    sousComptes.value = res.data.data || res.data
  } catch (err) {
    console.error(err)
  }
}

const debounceSearch = debounce((val) => {
  filters.value.search = val
  currentPage.value = 1
}, 300)

const filteredSousComptes = computed(() => {
  return sousComptes.value.filter(sc => {
    const matchCompte = !filters.value.compte_id || sc.Id_Compte == filters.value.compte_id
    const matchSearch = !filters.value.search ||
      sc.Code_sous_compte?.toLowerCase().includes(filters.value.search.toLowerCase()) ||
      sc.Libelle?.toLowerCase().includes(filters.value.search.toLowerCase())
    return matchCompte && matchSearch
  })
})

const paginatedSousComptes = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage
  const end = start + itemsPerPage
  return filteredSousComptes.value.slice(start, end)
})

const totalPages = computed(() => {
  return Math.ceil(filteredSousComptes.value.length / itemsPerPage)
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
    loadComptes();
    loadSousComptes();
  }
});

</script>

<template>
  <div class="dashboard-container">
    <Header v-if="user" :user="user" />
    <Sidebar :current-route="$route.path" @navigation-change="handleNavigation" />
    <div class="main-content p-4">
      <div class="card card-form">
        <div class="card-header">
          <h1 class="card-title text-2xl">Gestion des Sous-comptes</h1>
        </div>
        <div class="card-body">
          <div class="d-flex flex-column md:flex-row gap-3 mb-4">
            <div class="form-group w-full">
              <label for="compte" class="form-label">Compte</label>
              <select v-model="filters.compte_id" class="form-select w-full">
                <option value="">Tous les comptes</option>
                <option v-for="compte in comptes" :key="compte.Id_Compte" :value="compte.Id_Compte">
                  {{ compte.Code_compte }} - {{ compte.Libelle }}
                </option>
              </select>
            </div>
            <div class="form-group w-full">
              <label for="search" class="form-label">Recherche</label>
              <input
                type="text"
                placeholder="Code ou libellé..."
                :value="filters.search"
                @input="debounceSearch($event.target.value)"
                class="form-input w-full"
              />
            </div>
          </div>
          <button @click="openCreateModal" class="btn btn-primary mb-4">
            Nouveau sous-compte
          </button>
          <div class="table-container" style="margin-top: 20px;">
            <table class="table table-bordered table-striped">
              <thead>
                <tr>
                  <th class="text-sm">Code</th>
                  <th class="text-sm">Libellé</th>
                  <th class="text-sm">Compte</th>
                  <th class="text-sm">Actions</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="sc in paginatedSousComptes" :key="sc.Id_Sous_compte" class="fade-in">
                  <td>{{ sc.Code_sous_compte }}</td>
                  <td>{{ sc.Libelle }}</td>
                  <td>{{ sc.compte?.Code_compte }}</td>
                  <td class="d-flex gap-2">
                    <button @click="openEditModal(sc)" class="btn btn-primary text-base">
                      Modifier
                    </button>
                    <button @click="deleteSousCompte(sc.Id_Sous_compte)" class="btn btn-error text-base" style="height: 40px; margin-top: 10px;">
                      Supprimer
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
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
                  {{ isEditing ? 'Modifier le sous-compte' : 'Nouveau sous-compte' }}
                </h2>
                <button @click="showModal = false" class="modal-close">×</button>
              </div>
              <form @submit.prevent="saveSousCompte" class="modal-body">
                <div class="form-group">
                  <label for="compte" class="form-label required">Compte</label>
                  <select
                    v-model="form.Id_Compte"
                    @change="updateCode"
                    class="form-select w-full"
                    required
                  >
                    <option v-for="compte in comptes" :key="compte.Id_Compte" :value="compte.Id_Compte">
                      {{ compte.Code_compte }} - {{ compte.Libelle }}
                    </option>
                  </select>
                </div>
                <div class="form-group">
                  <label for="suffixe" class="form-label required">Suffixe</label>
                  <input
                    type="text"
                    v-model="form.suffixe"
                    @input="updateCode"
                    maxlength="3"
                    placeholder="001"
                    class="form-input w-full"
                    required
                  />
                </div>
                <div class="form-group">
                  <label for="code-sous-compte" class="form-label">Code complet</label>
                  <input
                    type="text"
                    v-model="form.Code_sous_compte"
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
     <button class="chatbot-float-btn" @click="showChat = !showChat">
  <span v-if="!showChat">💬</span>
  <span v-else>✖</span>
</button>

<!-- POPIN CHATBOT (fixe à droite, petite taille) -->
<transition name="chatbot-fade">
  <div v-if="showChat">
    <ChatBot />
  </div>
</transition>
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

.filter-container, .export-container {
  background: #fff;
  padding: 16px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.card-title,
.form-label,
.form-input,
.form-select,
.btn,
.table th,
.table td {
  font-family: var(--font-family); /* Use global Stara font from style.css */
}

.chatbot-float-btn {
  position: fixed;
  bottom: 55px;
  right: 45px;
  width: 54px;
  height: 54px;
  background: linear-gradient(135deg,#1c45bd 0%,#011244 100%);
  border-radius: 50%;
  color: #fff;
  font-size: 2em;
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 101;
  border: none;
  box-shadow: 0 6px 16px rgba(102,126,234,0.22);
  cursor: pointer;
  transition: box-shadow 0.2s;
}
.chatbot-float-btn:hover {
  box-shadow: 0 10px 22px rgba(102,126,234,0.32);
  background: linear-gradient(135deg,#011244 0%,#1c45bd 100%);
}

.dashboard-chatbot-chatbox {
  position: fixed;
  bottom: 100px;
  right: 40px;
  width: 380px;
  max-width: 99vw;
  height: 520px;
  max-height: 80vh;
  z-index: 100;
  background: #fff;
  border-radius: 15px;
  box-shadow: 0 8px 36px rgba(90,60,130,0.14);
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

/* Animation d'apparition */
.chatbot-fade-enter-active, .chatbot-fade-leave-active {
  transition: opacity 0.25s;
}
.chatbot-fade-enter, .chatbot-fade-leave-to {
  opacity: 0;
}

@media (max-width: 768px) {
  .main-content {
    margin-left: 0;
    padding: 16px;
  }

  .dashboard-chatbot-chatbox {
    right: 5vw;
    bottom: 80px;
    width: 98vw;
    height: 90vh;
    border-radius: 8px;
  }
  .chatbot-float-btn {
    right: 8vw;
    bottom: 18px;
    width: 44px;
    height: 44px;
    font-size: 1.3em;
  }
}
</style>