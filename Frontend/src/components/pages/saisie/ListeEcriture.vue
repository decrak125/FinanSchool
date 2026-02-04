<template>
  <div class="dashboard-container w-full">
    <Header v-if="user" :user="user" />
    <Sidebar :current-route="$route.path" @navigation-change="handleNavigation" />

    <!-- J'ai retiré la classe 'blurred-overlay' pour éviter les conflits de positionnement -->
    <div class="main-content p-6">
      
      <!-- CARTE FILTRES : Design Horizontal & Propre -->
      <div class="card card-form mb-6">
        <div class="card-header border-b border-gray-100 pb-4 mb-4">
          <h1 class="card-title text-2xl font-semibold text-gray-800">Consultation des Écritures</h1>
        </div>
        
        <form @submit.prevent="fetchEcritures">
          <br>
          <!-- Ligne 1 : Recherche et Dates -->
          <div class="flex flex-wrap gap-4 mb-4 items-end">
            <div class="flex-1 min-w-[200px]">
              <label class="text-xs font-bold text-gray-500 uppercase mb-1 block">Recherche</label>
              <input v-model="filters.q" class="form-input w-full" placeholder="Libellé, référence..." />
            </div>
            <br>
            <div class="w-40">
              <label class="text-xs font-bold text-gray-500 uppercase mb-1 block">Date début</label>
              <input v-model="filters.date_debut" type="date" class="form-input w-full" />
            </div>
            <br>
            <div class="w-40">
              <label class="text-xs font-bold text-gray-500 uppercase mb-1 block">Date fin</label>
              <input v-model="filters.date_fin" type="date" class="form-input w-full" />
            </div>
          </div>
          <br>

          <!-- Ligne 2 : Listes déroulantes (Optimisées) -->
          <div class="flex flex-wrap gap-4 items-end">
            <div class="flex-1 min-w-[150px]">
              <label class="text-xs font-bold text-gray-500 uppercase mb-1 block">Classe</label>
              <select v-model="filters.Id_Classe" class="form-input w-full" :disabled="loadingLists">
                <option value="">{{ loadingLists ? 'Chargement...' : 'Toutes les classes' }}</option>
                <option v-for="cl in classes" :value="cl.Id_Classe" :key="cl.Id_Classe">
                  {{ cl.Code }} - {{ cl.Libelle }}
                </option>
              </select>
            </div>
            <br>
            <div class="flex-1 min-w-[150px]">
              <label class="text-xs font-bold text-gray-500 uppercase mb-1 block">Journal</label>
              <select v-model="filters.Id_Journal" class="form-input w-full" :disabled="loadingLists">
                <option value="">{{ loadingLists ? 'Chargement...' : 'Tous les journaux' }}</option>
                <option v-for="j in journaux" :value="j.Id_Journal" :key="j.Id_Journal">
                  {{ j.Code }} - {{ j.Libelle }}
                </option>
              </select>
            </div>
            <br>
            <div class="flex-1 min-w-[150px]">
              <label class="text-xs font-bold text-gray-500 uppercase mb-1 block">Compte</label>
              <select v-model="filters.Id_Compte" class="form-input w-full" :disabled="loadingLists">
                <option value="">{{ loadingLists ? 'Chargement...' : 'Tous les comptes' }}</option>
                <option v-for="cp in comptes" :value="cp.Id_Compte" :key="cp.Id_Compte">
                  {{ cp.Code_compte }} - {{ cp.Libelle }}
                </option>
              </select>
            </div>
            
            <div class="flex gap-2 ml-auto">
              <button @click="resetFilters" type="button" class="btn btn-ghost">Réinitialiser</button>
              <button type="submit" class="btn btn-primary" :disabled="isLoading">
                 {{ isLoading ? '...' : 'Filtrer' }}
              </button>
            </div>
          </div>
        </form>
      </div>

      <!-- Bouton Modif Groupée -->
      <div class="flex justify-end mb-4 items-center h-10">
        <button v-if="selectedRows.length > 0" @click="editGroup" class="btn btn-success flex items-center gap-2 shadow-sm">
          <span>✏️</span> Modifier sélection ({{ selectedRows.length }})
        </button>
      </div>

      <!-- Tableau avec Skeleton Loader -->
      <div class="card p-0 overflow-hidden mb-4">
        <div class="overflow-x-auto">
          <table class="table table-bordered w-full">
            <thead class="bg-gray-50 text-gray-600 font-semibold">
              <tr>
                <th class="w-10 text-center"><input type="checkbox" v-model="allChecked" @change="toggleAllRows" :disabled="isLoading" /></th>
                <th>Date</th>
                <th>Numero de pièce</th>
                <th>Sous-compte</th>
                <th>Libellé</th>
                <th class="text-right">Débit</th>
                <th class="text-right">Crédit</th>
                <th>Réf.</th>
                <th class="text-center">Statut</th>
                <th class="text-right">Actions</th>
              </tr>
            </thead>
            <tbody>
               <!-- Squelette de chargement -->
               <tr v-if="isLoading" v-for="n in 5" :key="'skel-'+n" class="animate-pulse bg-white">
                  <td class="p-4"><div class="h-4 bg-gray-200 rounded w-4 mx-auto"></div></td>
                  <td class="p-4"><div class="h-4 bg-gray-200 rounded w-20"></div></td>
                  <td class="p-4"><div class="h-4 bg-gray-200 rounded w-16"></div></td>
                  <td class="p-4"><div class="h-4 bg-gray-200 rounded w-full"></div></td>
                  <td class="p-4"><div class="h-4 bg-gray-200 rounded w-16 ml-auto"></div></td>
                  <td class="p-4"><div class="h-4 bg-gray-200 rounded w-16 ml-auto"></div></td>
                  <td class="p-4"><div class="h-4 bg-gray-200 rounded w-12"></div></td>
                  <td class="p-4"><div class="h-6 bg-gray-200 rounded w-16 mx-auto"></div></td>
                  <td class="p-4"><div class="h-6 bg-gray-200 rounded w-12 ml-auto"></div></td>
               </tr>

               <!-- Données réelles -->
               <template v-else>
                <tr v-for="ligne in filteredEcritures" :key="ligne.Id_Ligne_ecriture" class="hover:bg-gray-50 transition-colors border-b border-gray-100">
                  <td class="text-center">
                    <input v-if="ligne.statut !== 'valide'" type="checkbox" :value="ligne.Id_Ligne_ecriture" v-model="selectedRows" />
                  </td>
                  <td>{{ formatDate(ligne.mouvement?.Date_mouvement) }}</td>
                  <td class="font-mono text-sm">{{ ligne.mouvement?.Numero_piece }}</td>
                  <td class="font-mono text-sm">{{ ligne.sous_compte?.Code_sous_compte }}</td>
                  <td class="max-w-[200px] truncate" :title="ligne.Libelle">{{ ligne.Libelle }}</td>
                  <td class="text-right">{{ formatMontant(ligne.Debit) }}</td>
                  <td class="text-right">{{ formatMontant(ligne.Credit) }}</td>
                  <td class="text-sm text-gray-500">{{ ligne.Reference }}</td>
                  <td class="text-center">
                    <span v-if="ligne.statut === 'valide'" class="badge badge-success" style="font-size: 12px;">Validé</span>
                    <span v-else class="badge badge-warning" style="font-size: 12px;">Brouillon</span>
                  </td>
                  <td class="text-right">
                    <button v-if="ligne.statut !== 'valide'" @click="editLigne(ligne)" class="btn btn-xs btn-primary" style="margin-right: 20px;">Modifier</button>
                    <span v-else class="text-xs text-gray-400 italic">Verrouillé</span>
                  </td>
                </tr>
                 <tr v-if="filteredEcritures.length === 0">
                   <td colspan="9" class="p-8 text-center text-gray-400">Aucune écriture trouvée.</td>
                </tr>
               </template>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Pagination -->
      <div v-if="!isLoading && ecritures.data && ecritures.last_page > 1" class="mt-4 flex justify-center items-center gap-2" style="margin-left:500px;">
        <button @click="changePage(ecritures.current_page-1)" :disabled="ecritures.current_page === 1" class="btn btn-sm btn-ghost">Précédent</button>
        <span class="mx-2 text-sm font-medium">Page {{ ecritures.current_page }} / {{ ecritures.last_page }}</span>
        <button @click="changePage(ecritures.current_page+1)" :disabled="ecritures.current_page === ecritures.last_page" class="btn btn-sm btn-ghost">Suivant</button>
      </div>

      <AppFooter />
    </div>

    <!-- MODALES (Placées ici pour sortir du contexte main-content) -->
    
    <!-- MODAL MODIF INDIVIDUELLE (ERGONOMIQUE) -->
    <div v-if="showEditModal" class="modal-wrapper">
      <div class="modal-backdrop" @click="showEditModal=false"></div>
      <div class="modal-card">
        <div class="flex justify-between items-center mb-6">
           <h2 class="text-xl font-semibold">Modifier l'écriture</h2>
           <button @click="showEditModal=false" class="text-gray-400 hover:text-gray-600 text-xl">&times;</button>
        </div>
        
        <form @submit.prevent="updateLigneEdit">
          <div class="mb-4">
            <label class="block text-sm font-medium text-gray-700 mb-1">Sous-compte d'imputation</label>
            <select v-model="ligneEdit.Id_Sous_compte" class="form-input w-full bg-blue-50 border-blue-200" :disabled="loadingLists">
              <option value="">{{ loadingLists ? 'Chargement des comptes...' : 'Sélectionner un sous-compte...' }}</option>
              <option v-for="sc in sousComptes" :value="sc.Id_Sous_compte" :key="sc.Id_Sous_compte">
                {{ sc.Code_sous_compte }} - {{ sc.Libelle }}
              </option>
            </select>
          </div>

          <div class="grid grid-cols-3 gap-4 mb-4">
              <div class="col-span-2">
                  <label class="block text-sm font-medium text-gray-700 mb-1">Libellé</label>
                  <input v-model="ligneEdit.Libelle" class="form-input w-full" />
              </div>
              <div>
                  <label class="block text-sm font-medium text-gray-700 mb-1">Référence</label>
                  <input v-model="ligneEdit.Reference" class="form-input w-full" />
              </div>
          </div>

          <!-- Bloc Montants Intelligent -->
          <div class="grid grid-cols-2 gap-4 mb-6 p-4 bg-gray-50 rounded border border-gray-100">
              <div>
                  <label class="block text-sm font-medium text-gray-700 mb-1">Débit</label>
                  <input v-model.number="ligneEdit.Debit" type="number" step="0.01" 
                         @input="onDebitInput('ligne')"
                         class="form-input w-full text-right" placeholder="0.00" />
              </div>
              <div>
                  <label class="block text-sm font-medium text-gray-700 mb-1">Crédit</label>
                  <input v-model.number="ligneEdit.Credit" type="number" step="0.01" 
                         @input="onCreditInput('ligne')"
                         class="form-input w-full text-right" placeholder="0.00" />
              </div>
          </div>

          <div class="flex justify-end gap-3 pt-2 border-t border-gray-100">
            <button @click="showEditModal=false" type="button" class="btn btn-ghost">Annuler</button>
            <button class="btn btn-success px-6" :disabled="loadingLists">Enregistrer</button>
          </div>
        </form>
      </div>
    </div>

    <!-- MODAL MODIF GROUPÉE (Même logique) -->
    <div v-if="showGroupModal" class="modal-wrapper">
      <div class="modal-backdrop" @click="showGroupModal=false"></div>
      <div class="modal-card border-t-4 border-blue-600">
        <div class="flex justify-between items-center mb-6">
           <h2 class="text-xl font-semibold text-blue-800">Modification groupée ({{ selectedRows.length }})</h2>
           <button @click="showGroupModal=false" class="text-gray-400 hover:text-gray-600 text-xl">&times;</button>
        </div>

        <div class="bg-yellow-50 p-3 text-sm text-yellow-800 rounded mb-4">
          Les champs laissés vides ne seront pas modifiés.
        </div>

        <form @submit.prevent="updateGroup">
          <div class="mb-4">
            <label class="block text-sm font-medium text-gray-700 mb-1">Nouveau Sous-compte</label>
            <select v-model="groupEdit.Id_Sous_compte" class="form-input w-full" :disabled="loadingLists">
              <option value="">-- Ne pas modifier --</option>
              <option v-for="sc in sousComptes" :value="sc.Id_Sous_compte" :key="sc.Id_Sous_compte">
                {{ sc.Code_sous_compte }} - {{ sc.Libelle }}
              </option>
            </select>
          </div>

          <div class="grid grid-cols-3 gap-4 mb-4">
              <div class="col-span-2">
                  <label class="block text-sm font-medium text-gray-700 mb-1">Nouveau Libellé</label>
                  <input v-model="groupEdit.Libelle" class="form-input w-full" placeholder="Laisser vide..." />
              </div>
              <div>
                  <label class="block text-sm font-medium text-gray-700 mb-1">Nouvelle Réf.</label>
                  <input v-model="groupEdit.Reference" class="form-input w-full" placeholder="Optionnel" />
              </div>
          </div>

          <div class="grid grid-cols-2 gap-4 mb-6">
              <div>
                  <label class="block text-sm font-medium text-gray-700 mb-1">Forcer Débit</label>
                  <input v-model.number="groupEdit.Debit" type="number" step="0.01" 
                         @input="onDebitInput('group')"
                         class="form-input w-full text-right" placeholder="Inchangé" />
              </div>
              <div>
                  <label class="block text-sm font-medium text-gray-700 mb-1">Forcer Crédit</label>
                  <input v-model.number="groupEdit.Credit" type="number" step="0.01" 
                         @input="onCreditInput('group')"
                         class="form-input w-full text-right" placeholder="Inchangé" />
              </div>
          </div>

          <div class="flex justify-end gap-3 pt-2 border-t border-gray-100">
            <button @click="showGroupModal=false" type="button" class="btn btn-ghost">Annuler</button>
            <button class="btn btn-success px-6">Appliquer</button>
          </div>
        </form>
      </div>
    </div>

    <!-- Chatbot -->
    <button class="chatbot-float-btn" @click="showChat = !showChat">
      <span v-if="!showChat">💬</span><span v-else>✖</span>
    </button>
    <transition name="chatbot-fade">
      <div v-if="showChat"><ChatBot /></div>
    </transition>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from "vue";
import axios from "axios";
import Header from "../../molecules/Header.vue";
import Sidebar from "../../molecules/Sidebar.vue";
import AppFooter from "../../molecules/Footer.vue";
import ChatBot from "../../molecules/ChatBot.vue";

const user = ref(null);
const showChat = ref(false);
const token = localStorage.getItem("token");
if (!token) window.location.href = "/";
axios.defaults.headers.common["Authorization"] = `Bearer ${token}`;

const handleNavigation = (item) => { window.location.href = item.route; };

// Etats
const filters = ref({ q: "", date_debut: "", date_fin: "", Id_Classe: "", Id_Journal: "", Id_Compte: "", page: 1 });
const classes = ref([]); 
const comptes = ref([]); 
const journaux = ref([]); 
const sousComptes = ref([]);

const ecritures = ref({ data: [], current_page: 1, last_page: 1 });
const isLoading = ref(true); // Pour le tableau
const loadingLists = ref(true); // Pour les selects

const selectedRows = ref([]);
const allChecked = ref(false);

const showEditModal = ref(false);
const ligneEdit = ref({});
const showGroupModal = ref(false);
const groupEdit = ref({ Libelle: "", Debit: null, Credit: null, Reference: "", Id_Sous_compte: "" });

// --- LOGIQUE METIER ---

// Gestion auto Débit/Crédit (si l'un est rempli, l'autre se vide)
function onDebitInput(context) {
    const target = context === 'ligne' ? ligneEdit.value : groupEdit.value;
    if (target.Debit > 0) target.Credit = 0;
}
function onCreditInput(context) {
    const target = context === 'ligne' ? ligneEdit.value : groupEdit.value;
    if (target.Credit > 0) target.Debit = 0;
}

function formatDate(d) { return d ? new Date(d).toLocaleDateString("fr-FR") : ""; }
function formatMontant(m) { if (!m || m === 0) return "-"; return Number(m).toLocaleString('fr-FR', { minimumFractionDigits: 2 }); }

async function fetchEcritures() {
  isLoading.value = true;
  try {
    let params = { ...filters.value, page: filters.value.page || 1 };
    const res = await axios.get("http://localhost:8000/api/ecritures", { params });
    ecritures.value = res.data;
    
    // Recalculer les checkbox
    const idsEditable = ecritures.value.data.filter(l => l.statut !== 'valide').map(l => l.Id_Ligne_ecriture);
    allChecked.value = idsEditable.length > 0 && idsEditable.every(id => selectedRows.value.includes(id));
  } catch { ecritures.value = { data: [] }; }
  isLoading.value = false;
}

const filteredEcritures = computed(() => {
  let result = ecritures.value.data || [];
  if(filters.value.Id_Classe) result = result.filter(l => l.sous_compte?.compte?.rubrique?.classe?.Id_Classe == filters.value.Id_Classe);
  if(filters.value.Id_Compte) result = result.filter(l => l.sous_compte?.compte?.Id_Compte == filters.value.Id_Compte);
  if(filters.value.Id_Journal) result = result.filter(l => l.Id_Journal == filters.value.Id_Journal);
  return result;
});

function resetFilters() {
  filters.value = { q: "", date_debut: "", date_fin: "", Id_Classe: "", Id_Journal: "", Id_Compte: "", page: 1 };
  fetchEcritures();
  selectedRows.value = [];
  allChecked.value = false;
}
function changePage(p) { filters.value.page = p; fetchEcritures(); }
function toggleAllRows() {
  const editableRows = ecritures.value.data.filter(l => l.statut !== 'valide');
  if (allChecked.value) selectedRows.value = editableRows.map(l => l.Id_Ligne_ecriture);
  else selectedRows.value = [];
}

function editLigne(ligne) {
  ligneEdit.value = JSON.parse(JSON.stringify(ligne));
  ligneEdit.value.Id_Sous_compte = ligne.sous_compte?.Id_Sous_compte || "";
  showEditModal.value = true;
}
async function updateLigneEdit() {
  try {
    await axios.put(`http://localhost:8000/api/lignes/${ligneEdit.value.Id_Ligne_ecriture}`, ligneEdit.value);
    showEditModal.value = false;
    fetchEcritures();
  } catch(e) { alert("Erreur lors de la sauvegarde"); }
}

function editGroup() {
  groupEdit.value = { Libelle: "", Debit: null, Credit: null, Reference: "", Id_Sous_compte: "" };
  showGroupModal.value = true;
}
async function updateGroup() {
  if(!confirm("Confirmer la modification ?")) return;
  try {
    await axios.put('http://localhost:8000/api/lignes/batch-update', { ids: selectedRows.value, data: groupEdit.value });
    showGroupModal.value = false;
    fetchEcritures();
    selectedRows.value = [];
    allChecked.value = false;
  } catch(e) { alert("Erreur lors de la modification groupée"); }
}

onMounted(() => {
  // 1. Charger l'utilisateur rapidement
  axios.get("http://localhost:8000/api/user").then(res => user.value = res.data);

  // 2. Charger le tableau IMMÉDIATEMENT
  fetchEcritures();

  // 3. Charger les listes en ARRIÈRE-PLAN (Non-bloquant)
  loadingLists.value = true;
  Promise.all([
      axios.get("http://localhost:8000/api/classes"),
      axios.get("http://localhost:8000/api/comptes"),
      axios.get("http://localhost:8000/api/journals"),
      axios.get("http://localhost:8000/api/sous-comptes")
  ]).then(([clRes, cpRes, jRes, scRes]) => {
      classes.value = clRes.data;
      comptes.value = cpRes.data;
      journaux.value = jRes.data;
      sousComptes.value = scRes.data;
  }).finally(() => {
      loadingLists.value = false;
  });
});
</script>

<style scoped>
/* Structure générale */
.dashboard-container { display: flex; min-height: 100vh; flex-direction: column; font-family: 'Manrope', sans-serif; }
.main-content { margin-left: 278px; padding: 32px; flex: 1; background: #f8fafc; }

/* Styles Cartes et Inputs */
.card { background-color: #fff; border-radius: 12px; box-shadow: 0 2px 10px rgba(0,0,0,0.02); border: 1px solid #f1f5f9; }
.card-form { padding: 24px; }
.form-input { padding: 10px 12px; border: 1px solid #e2e8f0; border-radius: 6px; font-size: 0.9rem; outline: none; transition: border-color 0.2s; }
.form-input:focus { border-color: #3b82f6; }
.form-input:disabled { background-color: #f1f5f9; cursor: not-allowed; color: #94a3b8; }
.badge-warning { background: #ffe3bd; color: #995c0c; border-color: #995c0c; border-width: 1px;}
.badge-success { background: #d1fae5; color: #047857; }
/* Boutons */
.btn { padding: 8px 16px; border-radius: 6px; font-weight: 500; font-size: 0.9rem; transition: 0.2s; }

.btn-success { background: #10b981; color: white; } .btn-success:hover { background: #059669; }
.btn-ghost { background: transparent; color: #64748b; } .btn-ghost:hover { background: #f1f5f9; }
.btn-xs { padding: 4px 8px; font-size: 0.75rem; }

/* Squelette de chargement */
.animate-pulse { animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite; }
@keyframes pulse { 0%, 100% { opacity: 1; } 50% { opacity: .5; } }

/* MODALE - Correction Positionnement */
.modal-wrapper {
  position: fixed; top: 0; left: 0; width: 100%; height: 100%; 
  z-index: 9999; /* Au-dessus de tout */
  display: flex; align-items: center; justify-content: center;
}
.modal-backdrop {
  position: absolute; top: 0; left: 0; width: 100%; height: 100%;
  background: rgba(0, 0, 0, 0.5); backdrop-filter: blur(4px);
}
.modal-card {
  position: relative; z-index: 10000;
  background: white; padding: 30px;
  border-radius: 12px; box-shadow: 0 20px 50px rgba(0,0,0,0.2);
  width: 600px; max-width: 90vw; max-height: 90vh;
  overflow-y: auto;
  animation: modalFadeIn 0.2s ease-out;
}
@keyframes modalFadeIn {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

/* Chatbot */
.chatbot-float-btn {
  position: fixed; bottom: 55px; right: 45px; width: 54px; height: 54px;
  background: linear-gradient(135deg,#1c45bd 0%,#011244 100%);
  border-radius: 50%; color: #fff; font-size: 2em;
  display: flex; align-items: center; justify-content: center;
  z-index: 101; cursor: pointer;
}
.chatbot-fade-enter-active, .chatbot-fade-leave-active { transition: opacity 0.25s; }
.chatbot-fade-enter, .chatbot-fade-leave-to { opacity: 0; }
</style>
