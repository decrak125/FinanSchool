<template>
  <div class="dashboard-container">
    <Header />
    <Sidebar :current-route="$route.path" @navigation-change="handleNavigation" />

    <div class="main-content">
      <div class="p-6">
        <h1 class="text-2xl font-bold mb-4">Gestion des Journaux</h1>

        <!-- ✅ Formulaire stylisé avec style.css -->
        <form @submit.prevent="saveJournal" class="card-form">
          <div class="form-group">
            <label class="form-label required">Code</label>
            <input v-model="form.Code" type="text" class="form-input" required />
          </div>

          <div class="form-group">
            <label class="form-label required">Libellé</label>
            <input v-model="form.Libelle" type="text" class="form-input" required />
          </div>

          <div class="form-group">
            <label class="form-label required">Type Journal</label>
            <select v-model="form.Id_Type_Journal" class="form-select" required>
              <option value="">-- Sélectionner --</option>
              <option v-for="type in typeJournals" :key="type.Id_Type_Journal" :value="type.Id_Type_Journal">
                {{ type.Type }}
              </option>
            </select>
          </div>

          <div class="form-group">
            <label class="form-label">Sous-compte (optionnel)</label>
            <select v-model="form.Id_Sous_compte" class="form-select">
              <option value="">-- Sélectionner --</option>
              <option v-for="compte in sousComptes" :key="compte.Id_Sous_compte" :value="compte.Id_Sous_compte">
                {{ compte.Code_sous_compte }} - {{ compte.Libelle }}
              </option>
            </select>
          </div>

          <div class="d-flex gap-2">
            <!-- ✅ Boutons avec tes classes -->
            <button type="submit" class="btn btn-primary">
              {{ isEditing ? "Mettre à jour" : "Ajouter" }}
            </button>
            <button v-if="isEditing" type="button" @click="cancelEdit" class="btn btn-outline">
              Annuler
            </button>
          </div>
        </form>

        <!-- ✅ Tableau stylisé -->
        <div class="table-container mt-4">
          <table class="table table-striped table-bordered">
            <thead>
              <tr>
                <th>#</th>
                <th>Code</th>
                <th>Libellé</th>
                <th>Type Journal</th>
                <th>Sous-compte</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="journal in journals" :key="journal.Id_Journal">
                <td>{{ journal.Id_Journal }}</td>
                <td>{{ journal.Code }}</td>
                <td>{{ journal.Libelle }}</td>
                <td>{{ journal.type_journal?.Type || '-' }}</td>
                <td>{{ journal.sous_compte?.Libelle || '-' }}</td>
                <td class="text-center">
                  <button @click="editJournal(journal)" class="btn btn-warning btn-sm">✏️</button>
                  <button @click="deleteJournal(journal.Id_Journal)" class="btn btn-error btn-sm">🗑️</button>
                </td>
              </tr>
            </tbody>
          </table>
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
import Sidebar from "../../molecules/Sidebar.vue"; // Adjust path if necessary
import Header from "../../molecules/Header.vue"; // Adjust path if necessary
import AppFooter from "../../molecules/Footer.vue";

const router = useRouter();

// Ajouter cette méthode pour gérer la navigation
const handleNavigation = (item) => {
  router.push(item.route);
};

const journals = ref([]);
const typeJournals = ref([]);
const sousComptes = ref([]);

const form = ref({
  Code: "",
  Libelle: "",
  Id_Type_Journal: "",
  Id_Sous_compte: "",
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

// Puis le reste de ton code fetch reste identique
const fetchJournals = async () => {
  const res = await axios.get("http://127.0.0.1:8000/api/journals");
  journals.value = res.data;
};

const fetchOptions = async () => {
  const types = await axios.get("http://127.0.0.1:8000/api/type-journals");
  typeJournals.value = types.data;

  const comptes = await axios.get("http://127.0.0.1:8000/api/sous-comptes");
  sousComptes.value = comptes.data;
};

  
  // Ajouter ou modifier un journal
  const saveJournal = async () => {
    if (isEditing.value) {
      await axios.put(`http://127.0.0.1:8000/api/journals/${editingId.value}`, form.value);
    } else {
      await axios.post("http://127.0.0.1:8000/api/journals", form.value);
    }
    resetForm();
    fetchJournals();
  };
  
  // Editer
  const editJournal = (journal) => {
    form.value = {
      Code: journal.Code,
      Libelle: journal.Libelle,
      Id_Type_Journal: journal.Id_Type_Journal,
      Id_Sous_compte: journal.Id_Sous_compte || "",
    };
    isEditing.value = true;
    editingId.value = journal.Id_Journal;
  };
  
  // Annuler
  const cancelEdit = () => {
    resetForm();
  };
  
  // Supprimer
  const deleteJournal = async (id) => {
    if (confirm("Supprimer ce journal ?")) {
      await axios.delete(`http://127.0.0.1:8000/api/journals/${id}`);
      fetchJournals();
    }
  };
  
  // Reset form
  const resetForm = () => {
    form.value = { Code: "", Libelle: "", Id_Type_Journal: "", Id_Sous_compte: "" };
    isEditing.value = false;
    editingId.value = null;
  };
  
  // Au montage
  onMounted(() => {
    fetchJournals();
    fetchOptions();
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
  