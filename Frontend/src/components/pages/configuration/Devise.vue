<template>
  <div class="dashboard-container">
    <!-- Header -->
    <Header />

    <!-- Sidebar -->
    <Sidebar :current-route="$route.path" @navigation-change="handleNavigation" />

    <!-- Main content -->
    <div class="main-content p-4">
      <div class="card card-form">
        <div class="card-header">
          <h1 class="card-title text-2xl">Gestion des Devises</h1>
        </div>
        
        <div class="card-body">
          <!-- Formulaire -->
          <form @submit.prevent="saveDevise" class="form-group">
            <div class="form-group">
              <label for="libelle" class="form-label required">Libellé</label>
              <input
                v-model="form.Libelle"
                id="libelle"
                type="text"
                class="form-input w-full"
                required
              />
            </div>
            <div class="form-group">
              <label for="code" class="form-label required">Code</label>
              <input
                v-model="form.Code"
                id="code"
                type="text"
                class="form-input w-full"
                required
              />
            </div>
            <div class="form-group">
              <label for="sigle" class="form-label required">Sigle</label>
              <input
                v-model="form.Sigle"
                id="sigle"
                type="text"
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
                @click="cancelEdit"
                class="btn btn-ghost"
              >
                Annuler
              </button>
            </div>
          </form>

          <!-- Tableau des devises -->
          <div class="table-container mt-4">
            <table class="table table-bordered table-striped">
              <thead>
                <tr>
                  <th class="text-sm">#</th>
                  <th class="text-sm">Libellé</th>
                  <th class="text-sm">Code</th>
                  <th class="text-sm">Sigle</th>
                  <th class="text-sm">Actions</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="devise in devises" :key="devise.Id_Devise" class="fade-in">
                  <td>{{ devise.Id_Devise }}</td>
                  <td>{{ devise.Libelle }}</td>
                  <td>{{ devise.Code }}</td>
                  <td>{{ devise.Sigle }}</td>
                  <td class="d-flex gap-2 justify-center">
                    <button
                      @click="editDevise(devise)"
                      class="btn btn-primary text-base"
                    >
                      ✏️
                    </button>
                    <button
                      @click="deleteDevise(devise.Id_Devise)"
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
  import axios from "axios";
  import { useRouter } from 'vue-router'
import Sidebar from "../../molecules/Sidebar.vue";
import Header from "../../molecules/Header.vue";
import AppFooter from "../../molecules/Footer.vue";

const router = useRouter();

// Ajouter cette méthode pour gérer la navigation
const handleNavigation = (item) => {
  router.push(item.route);
};
  
  const devises = ref([]);
  const form = ref({
    Libelle: "",
    Code: "",
    Sigle: "",
  });
  const isEditing = ref(false);
  const editingId = ref(null);

  const token = localStorage.getItem("token"); // Récupérer le token

if (!token) {
  // Redirection vers login si pas de token
  window.location.href = "/";
} else {
  // Configurer Axios pour inclure le token dans toutes les requêtes
  axios.defaults.headers.common["Authorization"] = `Bearer ${token}`;
}
  
  // Charger les devises
  const fetchDevises = async () => {
    const res = await axios.get("http://127.0.0.1:8000/api/devises");
    devises.value = res.data;
  };
  
  // Sauvegarder (ajout ou update)
  const saveDevise = async () => {
    if (isEditing.value) {
      await axios.put(`http://127.0.0.1:8000/api/devises/${editingId.value}`, form.value);
    } else {
      await axios.post("http://127.0.0.1:8000/api/devises", form.value);
    }
    resetForm();
    fetchDevises();
  };
  
  // Modifier
  const editDevise = (devise) => {
    form.value = { ...devise };
    isEditing.value = true;
    editingId.value = devise.Id_Devise;
  };
  
  // Annuler modification
  const cancelEdit = () => {
    resetForm();
  };
  
  // Supprimer
  const deleteDevise = async (id) => {
    if (confirm("Supprimer cette devise ?")) {
      await axios.delete(`http://127.0.0.1:8000/api/devises/${id}`);
      fetchDevises();
    }
  };
  
  // Reset formulaire
  const resetForm = () => {
    form.value = { Libelle: "", Code: "", Sigle: "" };
    isEditing.value = false;
    editingId.value = null;
  };
  
  onMounted(() => {
    fetchDevises();
  });
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

/* Responsive design */
@media (max-width: 768px) {
  .main-content {
    margin-left: 0;
    padding: 16px;
  }
}
</style>
  