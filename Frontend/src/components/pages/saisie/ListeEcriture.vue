<template>
  <div class="dashboard-container w-full">
    <Header v-if="user" :user="user" />
    <Sidebar :current-route="$route.path" @navigation-change="handleNavigation" />

    <div class="main-content p-6">
      <!-- Carte Filtres -->
      <div class="card card-form mb-6">
        <div class="card-header">
          <h1 class="card-title text-2xl mb-6">Consultation des Écritures comptables</h1>
        </div>
        <form @submit.prevent="fetchEcritures" class="grid grid-cols-1 md:grid-cols-7 gap-4 items-end">
          <input v-model="filters.q" class="form-input md:col-span-2" placeholder="Recherche..." />
          <select v-model="filters.Id_Classe" class="form-input">
            <option value="">Classe</option>
            <option v-for="cl in classes" :value="cl.Id_Classe" :key="cl.Id_Classe">
              {{ cl.Code }} - {{ cl.Libelle }}
            </option>
          </select>
          <select v-model="filters.Id_Journal" class="form-input">
            <option value="">Journal</option>
            <option v-for="j in journaux" :value="j.Id_Journal" :key="j.Id_Journal">
              {{ j.Code }} - {{ j.Libelle }}
            </option>
          </select>
          <select v-model="filters.Id_Compte" class="form-input">
            <option value="">Compte</option>
            <option v-for="cp in comptes" :value="cp.Id_Compte" :key="cp.Id_Compte">
              {{ cp.Code_compte }} - {{ cp.Libelle }}
            </option>
          </select>
          <input v-model="filters.date_debut" type="date" class="form-input" placeholder="Date début" />
          <input v-model="filters.date_fin" type="date" class="form-input" placeholder="Date fin" />
          <div class="flex gap-2">
            <button type="submit" class="btn btn-primary">Filtrer</button>
            <button @click="resetFilters" type="button" class="btn btn-ghost">Réinitialiser</button>
          </div>
        </form>
      </div>

      <!-- Bouton Modif Groupée -->
      <div class="flex justify-end mb-4">
        <button :disabled="selectedRows.length === 0" @click="editGroup" class="btn btn-success">
          Modifier sélection ({{ selectedRows.length }})
        </button>
      </div>

      <!-- Tableau -->
      <div v-if="isLoading" class="py-10 text-center text-gray-600">Chargement...</div>
      <div v-else class="table-container overflow-x-auto mb-4">
        <table class="table table-bordered w-full">
          <thead>
            <tr>
              <th><input type="checkbox" v-model="allChecked" @change="toggleAllRows" /></th>
              <th>Date</th>
              <th>Sous-compte</th>
              <th>Libellé</th>
              <th>Débit</th>
              <th>Crédit</th>
              <th>Référence</th>
              <th>Statut</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="ligne in ecritures.data" :key="ligne.Id_Ligne_ecriture">
              <td>
                <input v-if="ligne.statut !== 'valide'" type="checkbox" :value="ligne.Id_Ligne_ecriture" v-model="selectedRows" />
              </td>
              <td>{{ formatDate(ligne.mouvement?.Date_mouvement) }}</td>
              <td>{{ ligne.sous_compte?.Code_sous_compte }}</td>
              <td>{{ ligne.Libelle }}</td>
              <td class="text-right">{{ formatMontant(ligne.Debit) }}</td>
              <td class="text-right">{{ formatMontant(ligne.Credit) }}</td>
              <td>{{ ligne.Reference }}</td>
              <td>
                <span :class="ligne.statut === 'valide' ? 'badge badge-success' : 'badge badge-warning'">
                  {{ ligne.statut === 'valide' ? 'Validé' : 'Brouillon' }}
                </span>
              </td>
              <td>
                <button v-if="ligne.statut !== 'valide'" @click="editLigne(ligne)" class="btn btn-xs btn-primary">Modifier</button>
                <span v-else class="text-xs text-gray-400">Non modifiable</span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Pagination -->
      <div v-if="ecritures.data && ecritures.last_page > 1" class="mt-4 flex justify-center items-center gap-2">
        <button @click="changePage(ecritures.current_page-1)" :disabled="ecritures.current_page === 1" class="btn btn-xs btn-ghost">Précédent</button>
        <span class="mx-2">Page {{ ecritures.current_page }} / {{ ecritures.last_page }}</span>
        <button @click="changePage(ecritures.current_page+1)" :disabled="ecritures.current_page === ecritures.last_page" class="btn btn-xs btn-ghost">Suivant</button>
      </div>

      <!-- Modal modif individuelle -->
      <div v-if="showEditModal" class="modal">
        <div class="modal-content">
          <h2>Modifier écriture #{{ ligneEdit.Id_Ligne_ecriture }}</h2>
          <form @submit.prevent="updateLigneEdit">
            <input v-model="ligneEdit.Libelle" class="form-input mb-2" placeholder="Libellé" />
            <input v-model.number="ligneEdit.Debit" type="number" class="form-input mb-2" placeholder="Débit" />
            <input v-model.number="ligneEdit.Credit" type="number" class="form-input mb-2" placeholder="Crédit" />
            <input v-model="ligneEdit.Reference" class="form-input mb-2" placeholder="Référence" />
            <select v-model="ligneEdit.Id_Compte" class="form-input mb-2">
              <option value="">Compte...</option>
              <option v-for="cp in comptes" :value="cp.Id_Compte" :key="cp.Id_Compte">
                {{ cp.Code_compte }} - {{ cp.Libelle }}
              </option>
            </select>
            <button class="btn btn-success">Enregistrer</button>
            <button @click="showEditModal=false" type="button" class="btn btn-ghost ml-2">Annuler</button>
          </form>
        </div>
      </div>
      <!-- Modal modif groupée -->
      <div v-if="showGroupModal" class="modal">
        <div class="modal-content">
          <h2>Modification groupée</h2>
          <form @submit.prevent="updateGroup">
            <input v-model="groupEdit.Libelle" class="form-input mb-2" placeholder="Libellé (optionnel)" />
            <input v-model.number="groupEdit.Debit" type="number" class="form-input mb-2" placeholder="Débit (optionnel)" />
            <input v-model.number="groupEdit.Credit" type="number" class="form-input mb-2" placeholder="Crédit (optionnel)" />
            <input v-model="groupEdit.Reference" class="form-input mb-2" placeholder="Référence (optionnel)" />
            <button class="btn btn-success">Modifier {{ selectedRows.length }} écritures</button>
            <button @click="showGroupModal=false" type="button" class="btn btn-ghost ml-2">Annuler</button>
          </form>
        </div>
      </div>
      <AppFooter />
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import axios from "axios";
import Header from "../../molecules/Header.vue";
import Sidebar from "../../molecules/Sidebar.vue";
import AppFooter from "../../molecules/Footer.vue";

// Auth
const user = ref(null);
const token = localStorage.getItem("token");
if (!token) window.location.href = "/";
axios.defaults.headers.common["Authorization"] = `Bearer ${token}`;

// Routing
const handleNavigation = (item) => { window.location.href = item.route; };

// Filtres et listes de référence
const filters = ref({
  q: "",
  date_debut: "",
  date_fin: "",
  Id_Classe: "",
  Id_Journal: "",
  Id_Compte: "",
  page: 1
});
const classes = ref([]);
const comptes = ref([]);
const journaux = ref([]);

// Table, sélection et états
const ecritures = ref({ data: [], current_page: 1, last_page: 1 });
const isLoading = ref(false);
const selectedRows = ref([]);
const allChecked = ref(false);

// Modals
const showEditModal = ref(false);
const ligneEdit = ref({});
const showGroupModal = ref(false);
const groupEdit = ref({ Libelle: "", Debit: null, Credit: null, Reference: "" });

// Format helpers
function formatDate(d) {
  return d ? new Date(d).toLocaleDateString("fr-FR") : "";
}
function formatMontant(m) {
  return Number(m || 0).toLocaleString('fr-FR', { minimumFractionDigits: 2 });
}

// API: chargement et filtres
async function fetchEcritures() {
  isLoading.value = true;
  try {
    let params = { ...filters.value, page: filters.value.page || 1 };
    const res = await axios.get("http://localhost:8000/api/ecritures", { params });
    ecritures.value = res.data;
    const ids = ecritures.value.data.filter(l => l.statut !== 'valide').map(l => l.Id_Ligne_ecriture);
    allChecked.value = ids.length > 0 && selectedRows.value.length === ids.length;
  } catch {
    ecritures.value = { data: [] };
  }
  isLoading.value = false;
}

function resetFilters() {
  filters.value = {
    q: "",
    date_debut: "",
    date_fin: "",
    Id_Classe: "",
    Id_Journal: "",
    Id_Compte: "",
    page: 1
  };
  fetchEcritures();
  selectedRows.value = [];
  allChecked.value = false;
}
function changePage(p) {
  filters.value.page = p;
  fetchEcritures();
}
function toggleAllRows() {
  if (allChecked.value) {
    selectedRows.value = ecritures.value.data.filter(l => l.statut !== 'valide').map(l => l.Id_Ligne_ecriture);
  } else {
    selectedRows.value = [];
  }
}

// Edition individuelle
function editLigne(ligne) {
  ligneEdit.value = { ...ligne };
  showEditModal.value = true;
}
async function updateLigneEdit() {
  await axios.put(`http://localhost:8000/api/lignes/${ligneEdit.value.Id_Ligne_ecriture}`, ligneEdit.value);
  showEditModal.value = false;
  fetchEcritures();
}

// Edition groupée
function editGroup() {
  groupEdit.value = { Libelle: "", Debit: null, Credit: null, Reference: "" };
  showGroupModal.value = true;
}
async function updateGroup() {
  await axios.put('http://localhost:8000/api/lignes/batch-update', { ids: selectedRows.value, data: groupEdit.value });
  showGroupModal.value = false;
  fetchEcritures();
  selectedRows.value = [];
  allChecked.value = false;
}

// Initialisation: chargement user, classes, comptes, journaux, écritures
onMounted(async () => {
  try {
    const resUser = await axios.get("http://localhost:8000/api/user");
    user.value = resUser.data;
    const resClasses = await axios.get("http://localhost:8000/api/classes");
    classes.value = resClasses.data;
    const resComptes = await axios.get("http://localhost:8000/api/comptes");
    comptes.value = resComptes.data;
    const resJournaux = await axios.get("http://localhost:8000/api/journals");
    journaux.value = resJournaux.data;
  } catch {}
  await fetchEcritures();
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
/* Style les .card, .modal, .badge selon ton framework/utilisation */
</style>
