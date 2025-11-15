<script setup>
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'
import { getUser } from "../../../services/Auth"
import { useRouter } from 'vue-router'
import Sidebar from "../../molecules/Sidebar.vue"
import Header from "../../molecules/Header.vue"
import AppFooter from "../../molecules/Footer.vue"
import ChatBot from "../../molecules/ChatBot.vue"

const router = useRouter()
const user = ref(null)
const handleNavigation = (item) => { router.push(item.route) }

const API_URL = 'http://localhost:8000/api'

const immobilisations = ref([])
const sousComptes = ref([])
const tauxAmortissement = ref([])
const showModal = ref(false)
const isEditing = ref(false)
const currentPage = ref(1)
const itemsPerPage = 10
const showChat = ref(false);

const filters = ref({ search: '' })
const form = ref({
  id: null,
  libelle: '',
  Id_Sous_compte: '',
  taux_amortissement_id: '',
  valeur_brute: '',
  date_acquisition: '',
  date_debut_utilisation: ''
})

const token = localStorage.getItem("token")
if (!token) {
  window.location.href = "/"
} else {
  axios.defaults.headers.common["Authorization"] = `Bearer ${token}`
}

const exerciceDate = ref("")

const formatDate = (dateStr) => {
  if (!dateStr) return ''
  const date = new Date(dateStr)
  let d = date.getDate().toString().padStart(2, '0')
  let m = (date.getMonth() + 1).toString().padStart(2, '0')
  let y = date.getFullYear()
  return `${d}/${m}/${y}`
}

const loadReferentiels = async () => {
  sousComptes.value = (await axios.get(`${API_URL}/sous-comptes`)).data
  tauxAmortissement.value = (await axios.get(`${API_URL}/taux-amortissement`)).data
}

const fetchExerciceCourant = async () => {
  const { data } = await axios.get(`${API_URL}/exercices/courant`)
  exerciceDate.value = data.exercice?.Date_fin ?? data.Date_fin ?? ""
}

const loadImmobilisations = async () => {
  // option : passer l'année ou la date si le backend attend l'un/l'autre
  immobilisations.value = (await axios.get(`${API_URL}/amortissement`)).data
}

const openCreateModal = () => {
  isEditing.value = false
  form.value = {
    id: null,
    libelle: '',
    Id_Sous_compte: sousComptes.value[0]?.Id_Sous_compte || '',
    taux_amortissement_id: tauxAmortissement.value[0]?.id || '',
    valeur_brute: '',
    date_acquisition: '',
    date_debut_utilisation: ''
  }
  showModal.value = true
}

const openEditModal = (immo) => {
  isEditing.value = true
  Object.assign(form.value, immo)
  showModal.value = true
}

const saveImmobilisation = async () => {
  try {
    if (isEditing.value && form.value.id) {
      await axios.put(`${API_URL}/amortissement/${form.value.id}`, form.value)
      alert('Immobilisation modifiée avec succès')
    } else {
      await axios.post(`${API_URL}/amortissement`, form.value)
      alert('Immobilisation créée avec succès')
    }
    showModal.value = false
    await loadImmobilisations()
    currentPage.value = 1
  } catch (error) {
    alert('Erreur enregistrement immobilisation')
  }
}

const deleteImmobilisation = async (id) => {
  if (confirm('Voulez-vous supprimer cette immobilisation ?')) {
    await axios.delete(`${API_URL}/amortissement/${id}`)
    await loadImmobilisations()
    if (filteredImmobilisations.value.length <= (currentPage.value - 1) * itemsPerPage) {
      currentPage.value = Math.max(1, currentPage.value - 1)
    }
  }
}

const filteredImmobilisations = computed(() => {
  return immobilisations.value.filter(immo =>
    !filters.value.search ||
      immo.compte?.toLowerCase().includes(filters.value.search.toLowerCase()) ||
      immo.libelle?.toLowerCase().includes(filters.value.search.toLowerCase())
  )
})

const paginatedImmobilisations = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage
  const end = start + itemsPerPage
  return filteredImmobilisations.value.slice(start, end)
})

const totalPages = computed(() => {
  return Math.ceil(filteredImmobilisations.value.length / itemsPerPage)
})

const prevPage = () => { if (currentPage.value > 1) currentPage.value-- }
const nextPage = () => { if (currentPage.value < totalPages.value) currentPage.value++ }
const goToPage = (page) => { currentPage.value = page }

onMounted(async () => {
  if (!token) {
    window.location.href = "/"
  } else {
    axios.defaults.headers.common["Authorization"] = `Bearer ${token}`
    try {
      const res = await getUser(token)
      user.value = res.data
    } catch (err) {
      localStorage.removeItem("token")
      window.location.href = "/"
      return
    }
    await fetchExerciceCourant()
    await loadReferentiels()
    await loadImmobilisations()
  }
})
</script>

<template>
  <div class="dashboard-container">
    <Header v-if="user" :user="user" />
    <Sidebar :current-route="$route.path" @navigation-change="handleNavigation" />
    <div class="main-content p-4">
      <div class="card card-form">
        <div class="card-header">
          <h1 class="card-title text-2xl">Gestion des Immobilisations & Amortissements</h1>
        </div>
        <div class="card-body">
          <div class="d-flex flex-column md:flex-row gap-3 mb-4">
            <div class="form-group w-full">
              <label for="search" class="form-label">Recherche</label>
              <input
                type="text"
                placeholder="Code, libellé ou compte..."
                v-model="filters.search"
                class="form-input w-full"
              />
            </div>
            <div style="font-weight:600;margin-left:20px;">
              Fin exercice : <span style="color: #0a608f;">{{ formatDate(exerciceDate) }}</span>
            </div>
          </div>
          <button @click="openCreateModal" class="btn btn-primary mb-4">
            Nouvelle immobilisation
          </button>
          <div class="table-container" style="margin-top: 20px;">
            <table class="table table-bordered table-striped">
              <thead>
                <tr>
                  <th>Compte</th>
                  <th>Libellé</th>
                  <th>Taux</th>
                  <th>Valeur d'acquisition</th>
                  <th>Date d'utilisation</th>
                  <th>Amortissement cumulé fin exercice</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="immo in paginatedImmobilisations" :key="immo.id" class="fade-in">
                  <td>{{ immo.compte }}</td>
                  <td>{{ immo.libelle }}</td>
                  <td>{{ immo.taux }}%</td>
                  <td>{{ immo.valeur_brute }}</td>
                  <td>{{ immo.date_debut_utilisation }}</td>
                  <td>{{ immo.cumul_amortissement }}</td>
                  <td class="d-flex gap-2">
                    <button @click="openEditModal(immo)" class="btn btn-primary text-base">
                      Modifier
                    </button>
                    <button @click="deleteImmobilisation(immo.id)" class="btn btn-error text-base" style="height: 40px; margin-top: 10px;">
                      Supprimer
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
          <div v-if="totalPages > 1" class="d-flex justify-center mt-6 gap-2">
            <button @click="prevPage" :disabled="currentPage === 1" class="btn btn-ghost btn-sm text-base"><i class="bi bi-chevron-left"></i></button>
            <button
              v-for="page in totalPages"
              :key="page"
              @click="goToPage(page)"
              class="btn"
              :class="{'btn-primary': currentPage === page, 'btn-ghost': currentPage !== page}"
              aria-label="Page {{ page }}"
            >{{ page }}</button>
            <button @click="nextPage" :disabled="currentPage === totalPages" class="btn btn-ghost btn-sm text-base"><i class="bi bi-chevron-right"></i></button>
          </div>
          <div v-if="showModal" class="modal-overlay">
            <div class="modal">
              <div class="modal-header">
                <h2 class="modal-title">{{ isEditing ? 'Modifier l\'immobilisation' : 'Nouvelle immobilisation' }}</h2>
                <button @click="showModal = false" class="modal-close">×</button>
              </div>
              <form @submit.prevent="saveImmobilisation" class="modal-body">
                <div class="form-group">
                  <label for="libelle" class="form-label required">Libellé</label>
                  <input type="text" v-model="form.libelle" required class="form-input w-full" />
                </div>
                <div class="form-group">
                  <label for="compte" class="form-label required">Compte</label>
                  <select v-model="form.Id_Sous_compte" class="form-select w-full" required>
                    <option v-for="sc in sousComptes" :key="sc.Id_Sous_compte" :value="sc.Id_Sous_compte">
                      {{ sc.Code_sous_compte }} - {{ sc.Libelle }}
                    </option>
                  </select>
                </div>
                <div class="form-group">
                  <label for="taux" class="form-label required">Taux d’amortissement</label>
                  <select v-model="form.taux_amortissement_id" class="form-select w-full" required>
                    <option v-for="taux in tauxAmortissement" :key="taux.id" :value="taux.id">
                      {{ taux.taux }}%
                    </option>
                  </select>
                </div>
                <div class="form-group">
                  <label for="valeur-brute" class="form-label required">Valeur d'acquisition</label>
                  <input type="number" v-model="form.valeur_brute" required class="form-input w-full" />
                </div>
                <div class="form-group">
                  <label for="date-acquisition" class="form-label required">Date d'acquisition</label>
                  <input type="date" v-model="form.date_acquisition" required class="form-input w-full" />
                </div>
                <div class="form-group">
                  <label for="date-debut-utilisation" class="form-label">Date début utilisation</label>
                  <input type="date" v-model="form.date_debut_utilisation" class="form-input w-full" />
                </div>
                <div class="modal-footer">
                  <button type="button" @click="showModal = false" class="btn btn-ghost">Annuler</button>
                  <button type="submit" class="btn btn-primary">{{ isEditing ? 'Modifier' : 'Enregistrer' }}</button>
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

.modal-overlay {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0,0,0,0.15);
  z-index: 100;
  display: flex;
  align-items: center;
  justify-content: center;
}
.modal {
  background: #fff;
  border-radius: 8px;
  padding: 28px 32px;
  min-width: 350px;
  max-width: 500px;
  box-shadow: 0 14px 32px rgba(0,0,0,0.07);
}
.modal-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.fade-in {
  animation: fadeIn .3s;
}
@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}
</style>
