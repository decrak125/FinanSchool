<template>
  <div class="dashboard-container">
    <Header />
    <Sidebar :current-route="$route.path" @navigation-change="handleNavigation" />
    
    <div class="main-content p-4">
      <div class="card card-form">
        <div class="card-header">
          <h2 class="card-title text-2xl">Gestion des Modes de Paiement</h2>
        </div>
        
        <div class="card-body">
          <!-- Formulaire -->
          <form @submit.prevent="isEditing ? updateModePaiement() : addModePaiement()" class="form-group">
            <div class="form-group">
              <label for="libelle" class="form-label required">Libellé</label>
              <input
                v-model="form.Libelle"
                id="libelle"
                type="text"
                placeholder="Libellé"
                class="form-input w-full"
                required
              />
            </div>
            <div class="form-group">
              <label for="abr" class="form-label required">Abréviation</label>
              <input
                v-model="form.Abr"
                id="abr"
                type="text"
                placeholder="Abréviation"
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
                  <th class="text-sm">Libellé</th>
                  <th class="text-sm">Abréviation</th>
                  <th class="text-sm">Actions</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="mode in modePaiements" :key="mode.Id_Mode_paiement" class="fade-in">
                  <td>{{ mode.Id_Mode_paiement }}</td>
                  <td>{{ mode.Libelle }}</td>
                  <td>{{ mode.Abr }}</td>
                  <td class="d-flex gap-2">
                    <button
                      @click="editModePaiement(mode)"
                      class="btn btn-primary text-base"
                    >
                      Modifier
                    </button>
                    <button
                      @click="deleteModePaiement(mode.Id_Mode_paiement)"
                      class="btn btn-error text-base" style="height: 40px; margin-top: 10px;"
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
import { useRouter } from 'vue-router'
import axios from "axios";
import Sidebar from "../../molecules/Sidebar.vue";
import Header from "../../molecules/Header.vue";
import AppFooter from "../../molecules/Footer.vue";

const router = useRouter();

const handleNavigation = (item) => {
  router.push(item.route);
};

const API_URL = "http://localhost:8000/api/mode-paiements";

const modePaiements = ref([]);
const isEditing = ref(false);
const editId = ref(null);

const form = ref({
  Libelle: "",
  Abr: "",
});

const token = localStorage.getItem("token"); // Récupérer le token

if (!token) {
  // Redirection vers login si pas de token
  window.location.href = "/";
} else {
  // Configurer Axios pour inclure le token dans toutes les requêtes
  axios.defaults.headers.common["Authorization"] = `Bearer ${token}`;
}

// Charger les modes de paiement
const fetchModePaiements = async () => {
  const response = await axios.get(API_URL);
  modePaiements.value = response.data;
};

// Ajouter
const addModePaiement = async () => {
  await axios.post(API_URL, form.value);
  fetchModePaiements();
  resetForm();
};

// Supprimer
const deleteModePaiement = async (id) => {
  if (confirm("Voulez-vous vraiment supprimer ce mode de paiement ?")) {
    await axios.delete(`${API_URL}/${id}`);
    fetchModePaiements();
  }
};

// Préparer édition
const editModePaiement = (mode) => {
  isEditing.value = true;
  editId.value = mode.Id_Mode_paiement;
  form.value = { ...mode };
};

// Mettre à jour
const updateModePaiement = async () => {
  await axios.put(`${API_URL}/${editId.value}`, form.value);
  fetchModePaiements();
  resetForm();
};

// Réinitialiser
const resetForm = () => {
  form.value = { Libelle: "", Abr: "" };
  isEditing.value = false;
  editId.value = null;
};

// Charger au montage
onMounted(fetchModePaiements);
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
