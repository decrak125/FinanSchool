<template>
  <div class="dashboard-container w-full">
    <Header />
    <Sidebar :current-route="$route.path" @navigation-change="handleNavigation" />

    <div class="main-content p-6">
      <div class="card card-form">
        <div class="p-6">
          <div class="card-header">
            <h1 class="card-title text-3xl">Gestion des Journaux</h1>
          </div>

          <!-- Formulaire stylisé -->
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
              <button type="submit" class="btn btn-primary">
                {{ isEditing ? "Mettre à jour" : "Ajouter" }}
              </button>
              <button v-if="isEditing" type="button" @click="cancelEdit" class="btn btn-outline">
                Annuler
              </button>
            </div>
          </form>

          <!-- Tableau stylisé -->
          <div class="table-container mt-6">
            <table class="table table-bordered table-striped w-full">
              <thead>
                <tr>
                  <th class="text-base p-4">#</th>
                  <th class="text-base p-4">Code</th>
                  <th class="text-base p-4">Libellé</th>
                  <th class="text-base p-4">Type Journal</th>
                  <th class="text-base p-4">Sous-compte</th>
                  <th class="text-base p-4">Actions</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="journals.length" v-for="journal in journals" :key="journal.Id_Journal">
                  <td class="p-4 text-base">{{ journal.Id_Journal }}</td>
                  <td class="p-4 text-base">{{ journal.Code }}</td>
                  <td class="p-4 text-base">{{ journal.Libelle }}</td>
                  <td class="p-4 text-base">{{ journal.type_journal?.Type || '-' }}</td>
                  <td class="p-4 text-base">{{ journal.sous_compte?.Libelle || '-' }}</td>
                  <td class="text-center">
                    <button @click="editJournal(journal)" class="btn btn-primary text-base">Modifier</button>
                    <button @click="deleteJournal(journal.Id_Journal)" class="btn btn-error text-base" style="height: 40px; margin-top: 10px; margin-left: 20px;">Supprimer</button>
                    <button @click="viewEcritures(journal.Id_Journal)" class="btn btn-primary text-base" style="height: 40px; margin-top: 10px; margin-left: 20px;">Voir Écritures</button>
                  </td>
                </tr>
                <tr v-else>
                  <td colspan="6" class="p-4 text-center text-base">Aucune donnée disponible</td>
                </tr>
              </tbody>
            </table>
          </div>

          <AppFooter />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import axios from "axios";
import { useRouter } from 'vue-router';
import Sidebar from "../../molecules/Sidebar.vue";
import Header from "../../molecules/Header.vue";
import AppFooter from "../../molecules/Footer.vue";

const router = useRouter();

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

const token = localStorage.getItem("token");

if (!token) {
  window.location.href = "/";
} else {
  axios.defaults.headers.common["Authorization"] = `Bearer ${token}`;
}

const fetchJournals = async () => {
  try {
    const res = await axios.get("http://127.0.0.1:8000/api/journals");
    journals.value = res.data;
    console.log("Journaux chargés:", journals.value);
  } catch (error) {
    console.error("Erreur lors du chargement des journaux:", error);
    journals.value = []; // Ensure journals is empty on error
  }
};

const fetchOptions = async () => {
  try {
    const types = await axios.get("http://127.0.0.1:8000/api/type-journals");
    typeJournals.value = types.data;
    const comptes = await axios.get("http://127.0.0.1:8000/api/sous-comptes");
    sousComptes.value = comptes.data;
  } catch (error) {
    console.error("Erreur lors du chargement des options:", error);
  }
};

const saveJournal = async () => {
  try {
    if (isEditing.value) {
      await axios.put(`http://127.0.0.1:8000/api/journals/${editingId.value}`, form.value);
    } else {
      await axios.post("http://127.0.0.1:8000/api/journals", form.value);
    }
    resetForm();
    fetchJournals();
  } catch (error) {
    console.error("Erreur lors de l'enregistrement du journal:", error);
  }
};

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

const cancelEdit = () => {
  resetForm();
};

const deleteJournal = async (id) => {
  if (confirm("Supprimer ce journal ?")) {
    try {
      await axios.delete(`http://127.0.0.1:8000/api/journals/${id}`);
      fetchJournals();
    } catch (error) {
      console.error("Erreur lors de la suppression du journal:", error);
    }
  }
};

const viewEcritures = (id) => {
  try {
    console.log("Navigating to /ecritures-journal/" + id);
    router.push(`/ecritures-journal/${id}`);
  } catch (error) {
    console.error("Erreur lors de la navigation:", error);
  }
};

const resetForm = () => {
  form.value = { Code: "", Libelle: "", Id_Type_Journal: "", Id_Sous_compte: "" };
  isEditing.value = false;
  editingId.value = null;
};

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

@media (max-width: 768px) {
  .main-content {
    margin-left: 0;
    padding: 16px;
  }
}
</style>