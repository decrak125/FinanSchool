<template>
  <div class="dashboard-container w-full">
    <Header v-if="user" :user="user" />
    <Sidebar :current-route="$route.path" @navigation-change="handleNavigation" />
    
    <div class="main-content p-6">
      <div class="card card-form overflow-hidden">
        <!-- Header moderne (Bord à bord) -->
        <div class="card-header p-6" style="background-color: var(--gray-50); border-bottom: 2px solid var(--gray-100);">
          <h1 class="card-title text-3xl" style="font-family: 'Stara', sans-serif; margin: 0; color: var(--primary-color);">
            Gestion des Simulations
          </h1>
        </div>

        <div class="card-body p-6">
          <div class="d-flex justify-content-between align-items-center mb-6 gap-4">
            <div class="search-wrapper flex-grow-1" style="max-width: 500px;">
              <i class="bi bi-search search-icon"></i>
              <input 
                type="text" 
                v-model="searchQuery" 
                class="form-input search-input w-full" 
                placeholder="Rechercher un scénario..."
              >
            </div>
            <button @click="openCreateModal" class="btn btn-primary px-6 shadow-sm" style="height: 48px; margin: 0; font-size: 1rem;">
              <i class="bi bi-plus-lg me-2"></i>Nouvelle Simulation
            </button>
          </div>

          <br>

          <div v-if="loading" class="text-center py-5">
            <div class="spinner spinner-lg"></div>
            <p class="mt-2">Chargement des données...</p>
          </div>

          
          <!-- Tableau avec alignement vertical et horizontal strict -->
          
          <div v-else class="table-container mt-6">
            <table class="table table-bordered table-striped w-full">
              <thead>
                <tr class="bg-gray-800 text-white">
                  <th class="p-4 text-center" style="width: 140px">Date Simulation</th>
                  <th class="p-4 text-left">Intitulé du Scénario</th>
                  <th class="p-4 text-left">Description / Hypothèses</th>
                  <th class="p-4 text-right" style="width: 180px">Impact Budgétaire</th>
                  <th class="p-4 text-center" style="width: 140px">Gestion</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="sim in filteredSimulations" :key="sim.id_simulation">
                  <td class="p-4 align-middle text-center">{{ new Date(sim.date_simulation).toLocaleDateString() }}</td>
                  <td class="p-4 align-middle font-bold">{{ sim.nom_simulation }}</td>
                  <td class="p-4 align-middle text-muted">{{ sim.description || '-' }}</td>
                  <td :class="['p-4 align-middle text-right font-bold font-mono', getSimulationResult(sim) >= 0 ? 'text-success' : 'text-danger']">
                    <i :class="[getSimulationResult(sim) >= 0 ? 'bi-arrow-up-short' : 'bi-arrow-down-short', 'me-1']"></i>
                    {{ Math.abs(getSimulationResult(sim)).toLocaleString('fr-FR') }} Ar
                  </td>
                  <td class="p-4 text-center align-middle">
                    <div class="d-flex justify-content-center gap-2">
                      <button @click="viewSimulation(sim.id_simulation)" class="btn btn-sm btn-outline-primary" style="padding: 5px 15px;">
                        <i class="bi bi-eye"></i> Voir
                      </button>
                      <button @click="confirmDelete(sim.id_simulation)" class="btn btn-sm btn-outline-danger" style="padding: 5px 12px;">
                        <i class="bi bi-trash"></i>
                      </button>
                    </div>
                  </td>
                </tr>
                <tr v-if="filteredSimulations.length === 0">
                  <td colspan="4" class="p-8 text-center text-gray-400">Aucune simulation enregistrée pour le moment.</td>
                </tr>
              </tbody>
            </table>
          </div>
          
          <AppFooter />
        </div>
      </div>
    </div>

    <!-- MODALE DE CRÉATION PREMIUM -->
    <div v-if="showModal" class="modal-overlay">
      <div class="modal modal-xl premium-modal">
        <div class="modal-header premium-header">
          <div class="d-flex align-items-center">
            <div class="modal-header-icon mr-4">
              <i class="bi bi-sliders"></i>
            </div>
            <div>
              <h2 class="modal-title text-white mb-1" style="font-family: 'Stara', sans-serif;">
                Paramétrage du Scénario
              </h2>
              <p class="text-white-50 small mb-0 italic">Configurez vos hypothèses de croissance</p>
            </div>
          </div>
          <button @click="showModal = false" class="modal-close text-white">
            <i class="bi bi-x-lg"></i>
          </button>
        </div>
        
        <div class="modal-body p-6">
          <div class="row mb-5">
            <div class="col-md-6 mb-3">
              <label class="form-label required font-bold">Nom du scénario</label>
              <input v-model="newSim.nom_simulation" type="text" class="form-input" placeholder="Ex: Budget 2026..." required>
            </div>
            <br>
            <div class="col-md-6 mb-3">
              <label class="form-label font-bold">Description globale</label>
              <textarea v-model="newSim.description" class="form-input" rows="1"></textarea>
            </div>
          </div>

          <!-- Indicateurs Dashboard -->
          <div class="row mb-7">
            <div class="col-md-4 mb-3" v-for="(stat, idx) in stats" :key="idx">
              <div :class="['card border-0 shadow-sm', stat.bgClass]">
                <div class="card-body p-5 text-center">
                  <div :class="['text-xs font-bold text-uppercase mb-2', stat.textClass]">{{ stat.label }}</div>
                  <div class="h2 mb-0 font-bold d-flex align-items-center justify-content-center" :style="{ color: stat.color }">
                    <i :class="['bi', stat.icon, 'me-2']" style="font-size: 0.8em;"></i>
                    {{ stat.absVal }} <small class="ms-1">Ar</small>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Tableau de simulation -->
          <div class="table-container shadow-sm rounded overflow-hidden" style="max-height: 380px;">
            <table class="table table-bordered table-striped w-full mb-0">
              <thead class="bg-gray-800 text-white">
                <tr>
                  <th class="p-4 text-left">Libellé du compte</th>
                  <th class="p-4 text-center" style="width: 110px;">Type</th>
                  <th class="p-4 text-center" style="width: 110px;">Nature</th>
                  <th class="p-4 text-right">Moyenne Hist.</th>
                  <th class="p-4 text-center" style="width: 110px;">Coeff.</th>
                  <th class="p-4 text-right">Montant Simulé</th>
                </tr>
              </thead>
              <tbody class="bg-white">
                <tr v-for="(ligne, index) in newSim.lignes" :key="index">
                  <td class="p-4 align-middle">{{ ligne.libelle }}</td>
                  <td class="p-4 align-middle text-center">
                    <span :class="ligne.type === 'produit' ? 'badge badge-success' : 'badge badge-danger'">
                      {{ ligne.type === 'produit' ? 'PRODUIT' : 'CHARGE' }}
                    </span>
                  </td>
                  <td class="p-4 align-middle text-center">
                    <select v-model="ligne.nature_charge" class="form-select-sm" style="padding: 2px 4px;">
                      <option value="fixe">Fixe</option>
                      <option value="variable">Var.</option>
                    </select>
                  </td>
                  <td :class="['p-4 align-middle text-right font-mono', ligne.type === 'produit' ? 'text-success' : 'text-danger']">
                    {{ Math.abs(ligne.moyenne_historique).toLocaleString('fr-FR') }} Ar
                  </td>
                  <td class="p-4 align-middle text-center">
                    <input v-model.number="ligne.coefficient" @input="updateMontantLigne(index)" type="number" step="0.05" class="form-input-sm text-center" style="width: 70px;">
                  </td>
                  <td :class="['p-4 align-middle text-right font-bold font-mono', ligne.type === 'produit' ? 'text-success' : 'text-danger']">
                    {{ Math.abs(ligne.montant_simule).toLocaleString('fr-FR') }} Ar
                  </td>
                </tr>
                <tr v-if="newSim.lignes.length === 0">
                  <td colspan="6" class="p-6 text-center text-muted italic">
                    <i class="bi bi-info-circle me-2"></i>
                    Aucune donnée historique trouvée (Comptes de classes 6 et 7). 
                    Veuillez vérifier que vous avez des écritures comptables saisies.
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
        
        <div class="modal-footer p-4">
          <button @click="showModal = false" class="btn btn-ghost">Annuler</button>
          <button @click="saveSimulation" class="btn btn-primary px-6" :disabled="saving || !newSim.nom_simulation">
            {{ saving ? 'Action en cours...' : 'Enregistrer le Scénario' }}
          </button>
        </div>
      </div>
    </div>

    <!-- POPUPS DE NOTIFICATION -->
    <div v-if="showSuccessModal" class="modal-overlay">
      <div class="modal modal-sm p-6 text-center">
        <div class="h1 text-success mb-3"><i class="bi bi-check-circle-fill"></i></div>
        <h2 class="font-bold mb-4">Succès !</h2>
        <p class="mb-5 text-muted">{{ successModalMessage }}</p>
        <button class="btn btn-primary w-full" @click="showSuccessModal = false">Terminer</button>
      </div>
    </div>

    <!-- VIEW MODAL (PROFESSIONAL REPORT LAYOUT) -->
    <div v-if="showViewModal && selectedSimulation" class="modal-overlay">
      <div class="modal modal-xl document-modal">
        <div class="modal-header no-print border-bottom-0 pb-0">
          <h5 class="modal-title font-bold text-muted small uppercase tracking-widest">Aperçu du Scénario</h5>
          <button @click="showViewModal = false" class="modal-close">
            <i class="bi bi-x-lg"></i>
          </button>
        </div>
        
        <div class="modal-body p-10 document-body bg-white">
          <!-- DOCUMENT HEADER (Visible screen & print) -->
          <div class="mb-10 pb-6 border-bottom-2 d-flex justify-content-between align-items-end">
            <div class="report-header-left">
              <h1 class="font-bold mb-1 uppercase tracking-tighter" style="font-size: 2.2rem; color: #334155;">RAPPORT DE SIMULATION</h1>
              <p class="text-muted small uppercase tracking-widest font-bold mb-0">ANALYSE ET PROJECTIONS BUDGÉTAIRES</p>
            </div>
            <div class="report-meta text-right">
              <h2 class="h5 font-bold text-uppercase mb-1" style="color: var(--primary-color);">{{ selectedSimulation.nom_simulation }}</h2>
              <p class="text-muted small mb-0 font-mono">REF: #SIM-{{ selectedSimulation.id_simulation }}</p>
              <p class="text-muted small font-italic">Établi le {{ new Date().toLocaleDateString('fr-FR', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' }) }}</p>
            </div>
          </div>

          <!-- Notes / Description Section -->
          <div class="row mb-8" v-if="selectedSimulation.description">
            <div class="col-md-12">
              <div class="report-section-header mb-3">
                <h6 class="text-uppercase font-bold text-muted small tracking-widest border-left-4 border-primary pl-3">Contexte du Scénario</h6>
              </div>
              <div class="bg-light p-5 rounded-lg border">
                <p class="text-muted mb-0 leading-relaxed italic" style="font-size: 1.1rem;">" {{ selectedSimulation.description }} "</p>
              </div>
            </div>
          </div>

          <!-- Key Metrics / Recap -->
          <div class="report-section-header mb-4">
            <h6 class="text-uppercase font-bold text-muted small tracking-widest border-left-4 border-primary pl-3">Synthèse des Résultats</h6>
          </div>
          <div class="row mb-10 g-4">
            <div v-for="(stat, idx) in statsView" :key="idx" class="col-md-4">
              <div class="report-stat-card p-6 border rounded-xl h-100" :style="{ borderLeft: '6px solid ' + stat.color }">
                <div class="d-flex justify-content-between align-items-center mb-2">
                  <span class="text-xs font-bold uppercase tracking-wider text-muted">{{ stat.label }}</span>
                  <i :class="['bi', stat.icon]" :style="{ color: stat.color }"></i>
                </div>
                <div class="h3 font-bold mb-0 text-right" :style="{ color: stat.color }">
                  {{ stat.absVal }} <span class="small font-normal">Ar</span>
                </div>
              </div>
            </div>
          </div>

          <!-- Full Accounts Table -->
          <div class="report-section-header mb-4">
            <h6 class="text-uppercase font-bold text-muted small tracking-widest border-left-4 border-primary pl-3">Décomposition par Poste</h6>
          </div>
          <div class="table-responsive border rounded-xl overflow-hidden">
            <table class="table mb-0 table-hover table-striped">
              <thead class="bg-gray-100">
                <tr>
                  <th class="p-4 text-left font-bold" style="width: 40%;">Poste Budgétaire</th>
                  <th class="p-4 text-center font-bold" style="width: 15%;">Type</th>
                  <th class="p-4 text-center font-bold" style="width: 12%;">Nature</th>
                  <th class="p-4 text-right font-bold" style="width: 16.5%;">Réalisé (Hist.)</th>
                  <th class="p-4 text-right font-bold" style="width: 16.5%;">Projection Simulée</th>
                </tr>
              </thead>
              <tbody class="bg-white">
                <tr v-for="(ligne, index) in selectedSimulation.lignes" :key="index">
                  <td class="p-4 align-middle font-bold">{{ ligne.libelle }}</td>
                  <td class="p-4 align-middle text-center">
                    <span :class="ligne.type === 'produit' ? 'badge badge-success' : 'badge badge-danger'" style="font-size: 0.7rem;">
                      {{ ligne.type === 'produit' ? 'RECETTE' : 'DÉPENSE' }}
                    </span>
                  </td>
                  <td class="p-4 align-middle text-center">
                    <span class="text-muted small">{{ ligne.nature_charge === 'fixe' ? 'Fixe' : 'Var.' }}</span>
                  </td>
                  <td class="p-4 align-middle text-right font-mono text-muted">
                    {{ Math.abs(parseFloat(ligne.moyenne_historique)).toLocaleString('fr-FR') }} Ar
                  </td>
                  <td :class="['p-4 align-middle text-right font-bold font-mono', ligne.type === 'produit' ? 'text-success' : 'text-danger']">
                    {{ Math.abs(parseFloat(ligne.montant_simule)).toLocaleString('fr-FR') }} Ar
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- DOCUMENT FOOTER (Visible screen & print) -->
          <div class="mt-12 pt-8 border-top-2">
            <div class="row">
              <div class="col-7">
                <p class="small text-muted mb-4 italic leading-relaxed">
                  Ce document constitue une projection basée sur les données historiques fournies. 
                  Il est destiné à faciliter la prise de décision stratégique.
                </p>
              </div>
              <div class="col-5">
                <div class="signature-box border p-4 text-center rounded-lg" style="height: 140px;">
                  <p class="font-bold border-bottom pb-2 mb-6">Visa pour Approbation</p>
                  <p class="text-muted small">Signature et Cachet Officiel</p>
                </div>
              </div>
            </div>
          </div>
        </div>
        
        <div class="modal-footer p-4 no-print">
          <button @click="exportToPDF" class="btn btn-secondary px-6">
            <i class="bi bi-printer mr-2"></i> Imprimer / PDF
          </button>
          <button @click="showViewModal = false" class="btn btn-primary px-6">Fermer</button>
        </div>
      </div>
    </div>

    <div v-if="showErrorModal" class="modal-overlay">
      <div class="modal modal-sm p-6 text-center">
        <div class="h1 text-danger mb-3"><i class="bi bi-x-circle-fill"></i></div>
        <h2 class="font-bold mb-4">Erreur</h2>
        <p class="mb-5 text-muted">{{ errorModalMessage }}</p>
        <button class="btn btn-primary w-full" @click="showErrorModal = false">Fermer</button>
      </div>
    </div>

    <!-- CHATBOT -->
    <button class="chatbot-float-btn" @click="showChat = !showChat">
      <i v-if="!showChat" class="bi bi-chat-dots-fill" style="font-size: 1.4rem;"></i>
      <i v-else class="bi bi-x-lg" style="font-size: 1.4rem;"></i>
    </button>
    <transition name="chatbot-fade">
      <div v-if="showChat"><ChatBot /></div>
    </transition>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from "vue";
import { useRouter } from 'vue-router';
import axios from "axios";
import Sidebar from "../../components/molecules/Sidebar.vue";
import Header from "../../components/molecules/Header.vue";
import AppFooter from "../../components/molecules/Footer.vue";
import ChatBot from "../../components/molecules/ChatBot.vue";
import { getSimulations, getSimulation, createSimulation, deleteSimulation, getHistoricalData } from "@/services/SimulationService";
import { getUser } from "@/services/Auth";

const router = useRouter();
const user = ref(null);
const simulations = ref([]);
const loading = ref(true);
const saving = ref(false);
const showModal = ref(false);
const showChat = ref(false);
const searchQuery = ref("");

const showSuccessModal = ref(false);
const successModalMessage = ref('');
const showErrorModal = ref(false);
const errorModalMessage = ref('');

const showViewModal = ref(false);
const selectedSimulation = ref(null);

const newSim = ref({
  nom_simulation: '',
  description: '',
  id_exercice_comptable: 1,
  lignes: []
});

const handleNavigation = (item) => router.push(item.route);

const filteredSimulations = computed(() => {
  if (!searchQuery.value) return simulations.value;
  const q = searchQuery.value.toLowerCase();
  return simulations.value.filter(s => 
    s.nom_simulation.toLowerCase().includes(q) ||
    (s.description && s.description.toLowerCase().includes(q))
  );
});

const totalProduits = computed(() => newSim.value.lignes.filter(l => l.type === 'produit').reduce((sum, l) => sum + parseFloat(l.montant_simule), 0));
const totalCharges = computed(() => newSim.value.lignes.filter(l => l.type === 'charge').reduce((sum, l) => sum + parseFloat(l.montant_simule), 0));
const resultat = computed(() => totalProduits.value - totalCharges.value);

const totProdView = computed(() => selectedSimulation.value?.lignes?.filter(l => l.type === 'produit').reduce((sum, l) => sum + parseFloat(l.montant_simule), 0) || 0);
const totChgView = computed(() => selectedSimulation.value?.lignes?.filter(l => l.type === 'charge').reduce((sum, l) => sum + parseFloat(l.montant_simule), 0) || 0);
const resView = computed(() => totProdView.value - totChgView.value);

const statsView = computed(() => {
  const values = [
    { label: 'Total Recettes', val: totProdView.value },
    { label: 'Total Dépenses', val: -totChgView.value }, // Negative impact
    { label: 'Résultat Net', val: resView.value }
  ];
  return values.map(v => {
    const fmt = getFormattedValue(v.val);
    let bg = 'bg-primary-light';
    if (v.label === 'Total Recettes') bg = 'bg-success-light';
    if (v.label === 'Total Dépenses') bg = 'bg-danger-light';
    return { ...v, ...fmt, bgClass: bg };
  });
});

const stats = computed(() => {
  const values = [
    { label: 'Total Recettes', val: totalProduits.value },
    { label: 'Total Dépenses', val: -totalCharges.value }, // Negative impact
    { label: 'Résultat Net', val: resultat.value }
  ];
  return values.map(v => {
    const fmt = getFormattedValue(v.val);
    let bg = 'bg-primary-light';
    if (v.label === 'Total Recettes') bg = 'bg-success-light';
    if (v.label === 'Total Dépenses') bg = 'bg-danger-light';
    return { ...v, ...fmt, bgClass: bg };
  });
});

const getFormattedValue = (val) => {
  const isPos = val >= 0;
  return {
    absVal: Math.abs(val).toLocaleString('fr-FR'),
    textClass: isPos ? 'text-success' : 'text-danger',
    color: isPos ? 'var(--success-dark)' : 'var(--error-dark)',
    icon: isPos ? 'bi-arrow-up-circle-fill' : 'bi-arrow-down-circle-fill'
  };
};

const getSimulationResult = (sim) => {
  return (sim.lignes || []).reduce((sum, l) => sum + (l.type === 'produit' ? parseFloat(l.montant_simule) : -parseFloat(l.montant_simule)), 0);
};

const fetchSimulations = async () => {
  try {
    const res = await getSimulations();
    simulations.value = res.data;
  } catch (e) { console.error(e); }
  finally { loading.value = false; }
};

const openCreateModal = async () => {
  newSim.value = { nom_simulation: '', description: '', id_exercice_comptable: 1, lignes: [] };
  showModal.value = true;
  await fetchHistoricalDataList();
};

const fetchHistoricalDataList = async () => {
  try {
    const res = await getHistoricalData();
    newSim.value.lignes = res.data.map(h => ({
      libelle: h.libelle,
      type: h.type,
      nature_charge: 'fixe',
      moyenne_historique: h.moyenne_historique || h.moyenne_mensuelle || 0,
      coefficient: 1.00,
      montant_simule: h.moyenne_historique || h.moyenne_mensuelle || 0,
      id_sous_compte: h.id_sous_compte
    }));
  } catch (e) { console.error(e); }
};

const updateMontantLigne = (index) => {
  const ligne = newSim.value.lignes[index];
  ligne.montant_simule = parseFloat((ligne.moyenne_historique * ligne.coefficient).toFixed(2));
};

const saveSimulation = async () => {
  if (!newSim.value.nom_simulation) return;
  saving.value = true;
  try {
    await createSimulation(newSim.value);
    showModal.value = false;
    successModalMessage.value = 'Le scénario a été enregistré avec succès.';
    showSuccessModal.value = true;
    await fetchSimulations();
  } catch (e) {
    errorModalMessage.value = 'Erreur lors de l\'enregistrement.';
    showErrorModal.value = true;
  } finally { saving.value = false; }
};

const confirmDelete = async (id) => {
  if (confirm("Supprimer cette simulation ?")) {
    try {
      await deleteSimulation(id);
      successModalMessage.value = 'La simulation a été supprimée.';
      showSuccessModal.value = true;
      await fetchSimulations();
    } catch (e) {
      errorModalMessage.value = 'Impossible de supprimer cette simulation.';
      showErrorModal.value = true;
    }
  }
};

const viewSimulation = async (id) => {
  try {
    const res = await getSimulation(id);
    selectedSimulation.value = res.data;
    showViewModal.value = true;
  } catch (e) {
    errorModalMessage.value = 'Impossible de charger les détails du scénario.';
    showErrorModal.value = true;
  }
};

const exportToPDF = () => {
  window.print();
};

onMounted(async () => {
  const token = localStorage.getItem("token");
  if (!token) { router.push("/"); return; }
  axios.defaults.headers.common["Authorization"] = `Bearer ${token}`;
  try {
    const res = await getUser(token);
    user.value = res.data;
    await fetchSimulations();
  } catch (err) {
    localStorage.removeItem("token");
    router.push("/");
  }
});
</script>

<style scoped>
@font-face {
  font-family: 'Stara';
  src: url('../../../public/fonts/Stara-Black.woff') format('truetype');
}

.dashboard-container { display: flex; min-height: 100vh; flex-direction: column; }
.main-content { margin-left: 278px; padding: 32px; flex: 1; background: #f8fafc; min-height: calc(100vh - 80px); font-family: 'Stara', sans-serif; }

/* Thème bord-à-bord préféré par l'utilisateur */
.card-form { border: 1px solid var(--gray-200); box-shadow: var(--shadow-lg); }

.table th {
  background: linear-gradient(135deg, var(--primary-color) 0%, var(--primary-dark) 100%);
  color: white;
  font-weight: 600;
  border-bottom: none;
}

.modal-overlay {
  position: fixed; top: 0; left: 0; width: 100vw; height: 100vh;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex; justify-content: center; align-items: center;
  z-index: 10000;
  backdrop-filter: blur(4px);
  font-family: 'Manrope', sans-serif;
}

.modal {
  background: white; border-radius: var(--radius-lg); box-shadow: var(--shadow-xl);
  display: flex; flex-direction: column; max-height: 90vh; overflow: hidden;
}

.modal-xl { width: 95%; max-width: 1100px; }
.modal-sm { width: 90%; max-width: 400px; }
.modal-header { padding: 1.5rem; border-bottom: 1px solid var(--gray-200); display: flex; justify-content: space-between; align-items: center; }
.modal-body { padding: 1.5rem; overflow-y: auto; }
.modal-footer { background-color: var(--gray-50); border-top: 1px solid var(--gray-200); display: flex; justify-content: flex-end; gap: 1rem; }
.modal-close { background: none; border: none; font-size: 2.5rem; cursor: pointer; color: var(--gray-400); line-height: 0.8; }

.bg-success-light { background-color: var(--success-lighter) !important; }
.bg-danger-light { background-color: var(--error-lighter) !important; }
.bg-primary-light { background-color: var(--secondary-lighter) !important; }

.chatbot-float-btn {
  position: fixed; bottom: 55px; right: 45px; width: 54px; height: 54px;
  background: linear-gradient(135deg, var(--primary-color) 0%, var(--primary-dark) 100%);
  border-radius: 50%; color: #fff; font-size: 2em;
  display: flex; align-items: center; justify-content: center;
  z-index: 200; border: none; box-shadow: var(--shadow-lg);
}

/* --- DOCUMENT / REPORT STYLING --- */
.document-modal {
  border-radius: 12px;
  border: 1px solid #e2e8f0;
  overflow: hidden;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
}

.search-wrapper { position: relative; }
.search-icon {
  position: absolute;
  left: 15px;
  top: 50%;
  transform: translateY(-50%);
  color: #94a3b8;
}
.search-input {
  padding-left: 45px !important;
  height: 48px !important;
  border-radius: 12px;
  border: 1px solid #e2e8f0;
  background: white;
}

.document-body {
  font-family: 'Inter', system-ui, -apple-system, sans-serif;
  color: #1e293b;
}

.report-branding h1 { letter-spacing: -2px; }
.border-bottom-2 { border-bottom: 2px solid #e2e8f0; }
.border-top-2 { border-top: 2px solid #e2e8f0; }
.border-left-4 { border-left: 4px solid; }

.report-stat-card {
  background: #f8fafc;
  transition: all 0.2s ease;
}

.rounded-xl { border-radius: 1rem; }

.signature-box {
  background-color: #fdfdfd;
}

@media print {
  @page { margin: 1.5cm; size: A4; }
  
  .sidebar, .header, .chatbot-float-btn, .modal-footer, .btn, .search-toolbar, .no-print, .modal-close {
    display: none !important;
  }
  
  .print-only { display: block !important; }
  .main-content { margin: 0 !important; padding: 0 !important; }
  .modal-overlay { position: static !important; background: none !important; }

  .modal {
    box-shadow: none !important; border: none !important;
    width: 100% !important; max-width: 100% !important;
    margin: 0 !important;
  }

  .document-modal { border: none !important; }
  .document-body { padding: 0 !important; }

  .report-stat-card, .table-responsive, .signature-box, .bg-light {
    border: 1px solid #e2e8f0 !important;
    -webkit-print-color-adjust: exact !important;
    print-color-adjust: exact !important;
  }

  .table th { background: #f1f5f9 !important; color: #1e293b !important; }
  
  /* Financial Colors */
  .text-success { color: #16a34a !important; }
  .text-danger { color: #dc2626 !important; }
  .bg-success-light { background-color: #f0fdf4 !important; }
  .bg-danger-light { background-color: #fef2f2 !important; }
}
</style>
