<script setup>
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'
import Sidebar from "../../molecules/Sidebar.vue";
import Header from "../../molecules/Header.vue";
import AppFooter from "../../molecules/Footer.vue";
import { getUser } from "../../../services/Auth";
import { useRouter } from 'vue-router';

const API_URL = 'http://localhost:8000/api'

const router = useRouter();
const user = ref(null);

const amortissements = ref([])
const sousComptes = ref([])
const tauxAmortissement = ref([])

const showModal = ref(false)
const isEditing = ref(false)
const currentPage = ref(1)
const itemsPerPage = 20

const soldeBrut = ref(0)
const loadingSolde = ref(false)

const form = ref({
  id: null,
  Id_Sous_compte: '',
  taux_amortissement_id: '',
  date_amortissement: '',
  exercice: '',
  montant: '',
  cumul: '',
  is_exceptionnel: false,
  commentaire: ''
})

const token = localStorage.getItem("token");
if (!token) { window.location.href = "/" }
axios.defaults.headers.common["Authorization"] = `Bearer ${token}`

const loadReferentiels = async () => {
  sousComptes.value = (await axios.get(`${API_URL}/sous-comptes`)).data
  tauxAmortissement.value = (await axios.get(`${API_URL}/amortissements/taux`)).data
}

const loadAmortissements = async () => {
  amortissements.value = (await axios.get(`${API_URL}/amortissements`)).data
}

const openCreateModal = () => {
  isEditing.value = false
  soldeBrut.value = 0
  form.value = {
    id: null,
    Id_Sous_compte: sousComptes.value[0]?.Id_Sous_compte || '',
    taux_amortissement_id: tauxAmortissement.value[0]?.id || '',
    date_amortissement: '',
    exercice: '',
    montant: '',
    cumul: '',
    is_exceptionnel: false,
    commentaire: ''
  }
  showModal.value = true
}

const openEditModal = (item) => {
  isEditing.value = true
  soldeBrut.value = 0
  form.value = { ...item }
  showModal.value = true
}

const saveAmortissement = async () => {
  try {
    if (isEditing.value) {
      await axios.put(`${API_URL}/amortissements/${form.value.id}`, form.value)
      alert('Dotation modifiée avec succès')
    } else {
      await axios.post(`${API_URL}/amortissements`, form.value)
      alert('Dotation créée avec succès')
    }
    showModal.value = false
    await loadAmortissements()
    currentPage.value = 1
  } catch (error) {
    alert('Erreur enregistrement dotation')
  }
}

const deleteAmortissement = async id => {
  if (confirm('Voulez-vous supprimer la dotation ?')) {
    await axios.delete(`${API_URL}/amortissements/${id}`);
    await loadAmortissements()
  }
}

const paginatedAmortissements = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage
  const end = start + itemsPerPage
  return amortissements.value.slice(start, end)
})

const totalPages = computed(() => {
  return Math.ceil(amortissements.value.length / itemsPerPage)
})

const fetchSoldeBrut = async () => {
  if (!form.value.Id_Sous_compte || !form.value.date_amortissement) {
    alert("Sélectionnez un sous-compte et une date");
    return;
  }
  loadingSolde.value = true
  try {
    const finExercice = form.value.date_amortissement;
    const resp = await axios.get(`${API_URL}/amortissements/solde-brut/${form.value.Id_Sous_compte}/${finExercice}`);
    soldeBrut.value = resp.data.solde_brut || 0;
    const tauxObj = tauxAmortissement.value.find(t => t.id == form.value.taux_amortissement_id)
    if (tauxObj) {
      form.value.montant = ((soldeBrut.value * tauxObj.taux) / 100).toFixed(2)
    }
  } catch (e) {
    alert("Impossible de charger le solde brut !");
  }
  loadingSolde.value = false
}

onMounted(async () => {
  if (!token) {
    window.location.href = "/";
  } else {
    axios.defaults.headers.common["Authorization"] = `Bearer ${token}`;
    try {
      const res = await getUser(token);
      user.value = res.data;
    } catch (err) {
      localStorage.removeItem("token");
      window.location.href = "/";
      return;
    }
    await loadReferentiels()
    await loadAmortissements()
  }
})
</script>

<template>
  <div class="dashboard-container">
    <Header v-if="user" :user="user" />
    <Sidebar :current-route="$route.path" @navigation-change="handleNavigation" />
    <div class="main-content p-4">
      <h1 class="mb-4 text-xl font-bold">Gestion des Amortissements</h1>
      <button @click="openCreateModal" class="btn btn-primary mb-4">Nouvelle dotation</button>
      <table class="table table-bordered table-striped mb-8">
        <thead>
          <tr>
            <th>Sous-compte</th>
            <th>Taux</th>
            <th>Date</th>
            <th>Exercice</th>
            <th>Montant</th>
            <th>Commentaire</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="item in paginatedAmortissements" :key="item.id">
            <td>{{ item.sous_compte?.Code_sous_compte }} - {{ item.sous_compte?.Libelle }}</td>
            <td>{{ item.taux_amortissement?.intitule }} ({{ item.taux_amortissement?.taux }}%)</td>
            <td>{{ item.date_amortissement }}</td>
            <td>{{ item.exercice }}</td>
            <td>{{ item.montant }}</td>
            <td>{{ item.commentaire }}</td>
            <td>
              <button @click="openEditModal(item)" class="btn btn-primary btn-sm">Modifier</button>
              <button @click="deleteAmortissement(item.id)" class="btn btn-error btn-sm">Supprimer</button>
            </td>
          </tr>
        </tbody>
      </table>

      <div v-if="totalPages > 1" class="d-flex justify-center mt-6 gap-2">
        <button @click="currentPage = Math.max(1, currentPage - 1)" :disabled="currentPage === 1" class="btn btn-ghost btn-sm text-base">
          <i class="bi bi-chevron-left"></i>
        </button>
        <button
          v-for="page in totalPages"
          :key="page"
          @click="currentPage = page"
          :class="{'btn-primary': currentPage === page, 'btn-ghost': currentPage !== page}"
          class="btn"
        >
          {{ page }}
        </button>
        <button @click="currentPage = Math.min(totalPages, currentPage + 1)" :disabled="currentPage === totalPages" class="btn btn-ghost btn-sm text-base">
          <i class="bi bi-chevron-right"></i>
        </button>
      </div>

      <div v-if="showModal" class="modal-overlay">
        <div class="modal">
          <div class="modal-header">
            <h2>{{ isEditing ? 'Modifier la dotation' : 'Nouvelle dotation' }}</h2>
            <button @click="showModal = false">×</button>
          </div>
          <form @submit.prevent="saveAmortissement" class="modal-body">
            <div class="form-group">
              <label>Sous-compte</label>
              <select v-model="form.Id_Sous_compte" required class="form-select w-full">
                <option v-for="sc in sousComptes" :key="sc.Id_Sous_compte" :value="sc.Id_Sous_compte">
                  {{ sc.Code_sous_compte }} - {{ sc.Libelle }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label>Taux d’amortissement</label>
              <select v-model="form.taux_amortissement_id" required class="form-select w-full">
                <option v-for="taux in tauxAmortissement" :key="taux.id" :value="taux.id">
                  {{ taux.intitule }} ({{ taux.taux }}%, {{ taux.duree }} ans)
                </option>
              </select>
            </div>
            <div class="form-group">
              <label>Date d’amortissement</label>
              <input type="date" v-model="form.date_amortissement" required class="form-input w-full" />
            </div>
            <div class="form-group">
              <label>Exercice</label>
              <input type="number" v-model="form.exercice" required class="form-input w-full" />
            </div>
            <div class="form-group">
              <label>Montant</label>
              <div class="flex items-center gap-2">
                <input type="number" v-model="form.montant" required class="form-input w-full" />
                <button type="button" @click="fetchSoldeBrut" class="btn btn-ghost">
                  Calculer montant
                </button>
                <span v-if="soldeBrut !== 0" class="ml-2 text-gray-500">
                  <span v-if="loadingSolde">Chargement...</span>
                  <span v-else>Solde brut : {{ soldeBrut }}</span>
                </span>
              </div>
            </div>
            <div class="form-group">
              <label>Commentaire</label>
              <input type="text" v-model="form.commentaire" class="form-input w-full" />
            </div>
            <div class="form-group">
              <label>
                <input type="checkbox" v-model="form.is_exceptionnel" /> Exceptionnel
              </label>
            </div>
            <div class="modal-footer">
              <button type="button" @click="showModal = false" class="btn btn-ghost">Annuler</button>
              <button type="submit" class="btn btn-primary">Enregistrer</button>
            </div>
          </form>
        </div>
      </div>
    </div>
    <AppFooter />
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
.modal-overlay {
  position: fixed;
  top: 80px; left: 280px; right: 0; bottom: 0;
  background: rgba(0,0,0,0.15);
  z-index: 100;
  display: flex;
  align-items: center;
  justify-content: center;
  height: 700px;
}
.modal {
  background: #fff;
  border-radius: 8px;
  padding: 28px 32px;
  min-width: 350px;
  max-width: 500px;
}
.modal-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.modal-close {
  background: transparent;
  border: none;
  font-size: 22px;
  cursor: pointer;
}
.fade-in {
  animation: fadeIn .3s;
}
@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}
</style>
