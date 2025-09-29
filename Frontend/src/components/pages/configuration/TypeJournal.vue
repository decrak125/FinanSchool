<template>
  <div class="dashboard-container">
    <Header />
    <Sidebar :current-route="$route.path" @navigation-change="handleNavigation" />
    
    <div class="main-content p-4">
      <div class="card card-form">
        <div class="card-header">
          <h2 class="card-title text-2xl">Gestion des Types de Journal</h2>
        </div>
        
        <div class="card-body">
          <!-- Formulaire -->
          <form @submit.prevent="isEditing ? updateTypeJournal() : addTypeJournal()" class="form-group">
            <div class="form-group">
              <label for="journal-type" class="form-label required">Type de journal</label>
              <input
                v-model="form.Type"
                id="journal-type"
                type="text"
                placeholder="Type de journal"
                class="form-input w-full"
                required
              />
            </div>

            <div class="d-flex gap-2">
              <button type="submit" class="btn btn-primary">
                {{ isEditing ? "Mettre à jour" : "Ajouter" }}
              </button>
              <button
                v-if="isEditing"
                type="button"
                @click="resetForm"
                class="btn btn-ghost"
              >
                Annuler
              </button>
            </div>
          </form>

          <!-- Tableau -->
          <div class="table-container mt-4">
            <table class="table table-bordered table-striped">
              <thead>
                <tr>
                  <th class="text-sm">ID</th>
                  <th class="text-sm">Type</th>
                  <th class="text-sm">Actions</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="journal in typeJournals" :key="journal.id" class="fade-in">
                  <td>{{ journal.Id_Type_Journal }}</td>
                  <td>{{ journal.Type }}</td>
                  <td class="d-flex gap-2">
                    <button
                      @click="editTypeJournal(journal)"
                      class="btn btn-warning btn-sm"
                    >
                      Modifier
                    </button>
                    <button
                      @click="deleteTypeJournal(journal.Id_Type_Journal)"
                      class="btn btn-error btn-sm"
                    >
                      Supprimer
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
        
        <AppFooter />
      </div>
    </div>
  </div>  
</template>

<script setup>
import { ref, onMounted } from "vue";
import axios from "axios";
import { useRouter } from 'vue-router'
import Sidebar from "../../molecules/Sidebar.vue";
import Header from "../../molecules/Header.vue";
import AppFooter from "../../molecules/Footer.vue";

const router = useRouter();

const handleNavigation = (item) => {
  router.push(item.route);
};

const API_URL = "http://localhost:8000/api/type-journals";

const typeJournals = ref([]);
const isEditing = ref(false);
const editId = ref(null);

const form = ref({
  Type: "",
});

const token = localStorage.getItem("token"); // Récupérer le token

if (!token) {
  // Redirection vers login si pas de token
  window.location.href = "/";
} else {
  // Configurer Axios pour inclure le token dans toutes les requêtes
  axios.defaults.headers.common["Authorization"] = `Bearer ${token}`;
}

// Charger les types de journal
const fetchTypeJournals = async () => {
  const response = await axios.get(API_URL);
  typeJournals.value = response.data;
};

// Ajouter
const addTypeJournal = async () => {
  await axios.post(API_URL, form.value);
  fetchTypeJournals();
  resetForm();
};

// Supprimer
const deleteTypeJournal = async (id) => {
  if (confirm("Voulez-vous vraiment supprimer ce type de journal ?")) {
    await axios.delete(`${API_URL}/${id}`);
    fetchTypeJournals();
  }
};

// Préparer édition
const editTypeJournal = (journal) => {
  isEditing.value = true;
  editId.value = journal.Id_Type_Journal;
  form.value = { ...journal };
};

// Mettre à jour
const updateTypeJournal = async () => {
  await axios.put(`${API_URL}/${editId.value}`, form.value);
  fetchTypeJournals();
  resetForm();
};

// Réinitialiser
const resetForm = () => {
  form.value = { Type: "" };
  isEditing.value = false;
  editId.value = null;
};

// Charger au montage
onMounted(fetchTypeJournals);
</script>

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
