<template>
  <div class="dashboard-container w-full">
    <Header v-if="user" :user="user" />
    <Sidebar :current-route="$route.path" @navigation-change="handleNavigation" />

    <div class="main-content">
      <div class="page-animate">
        <!-- Page Header -->
        <div class="page-header">
          <div class="page-header-content">
            <div class="page-header-icon">
              <i class="bi bi-graph-up-arrow"></i>
            </div>
            <div>
              <h1 class="page-title">Simulations Budgétaires</h1>
              <p class="page-subtitle">Créez et gérez vos scénarios de projections financières</p>
            </div>
          </div>
          <div class="page-header-stats" v-if="simulations.length > 0">
            <div class="header-stat">
              <span class="header-stat-value">{{ simulations.length }}</span>
              <span class="header-stat-label">Scénarios</span>
            </div>
          </div>
        </div>

        <!-- Toolbar -->
        <div class="toolbar">
          <div class="search-wrapper">
            <i class="bi bi-search search-icon"></i>
            <input
              type="text"
              v-model="searchQuery"
              class="form-input search-input"
              placeholder="Rechercher un scénario..."
            >
          </div>
          <button @click="openCreateModal" class="btn btn-primary btn-create">
            <i class="bi bi-plus-lg me-2"></i>Nouvelle Simulation
          </button>
        </div>

        <!-- Loading State -->
        <div v-if="loading" class="loading-state">
          <div class="spinner spinner-lg"></div>
          <p class="mt-3 text-muted">Chargement des simulations...</p>
        </div>

        <!-- Empty State -->
        <div v-else-if="filteredSimulations.length === 0 && !searchQuery" class="empty-state">
          <div class="empty-state-icon">
            <i class="bi bi-bar-chart-line"></i>
          </div>
          <h3>Aucune simulation</h3>
          <p>Commencez par créer votre premier scénario de simulation budgétaire.</p>
          <button @click="openCreateModal" class="btn btn-primary">
            <i class="bi bi-plus-lg me-2"></i>Créer un scénario
          </button>
        </div>

        <!-- Simulation Cards Grid -->
        <div v-else class="sim-grid">
          <div
            v-for="(sim, idx) in filteredSimulations"
            :key="sim.id_simulation"
            class="sim-card"
            :style="{ animationDelay: idx * 0.05 + 's' }"
          >
            <div class="sim-card-header">
              <div class="sim-card-date">
                <i class="bi bi-calendar3 me-1"></i>
                {{ new Date(sim.date_simulation).toLocaleDateString('fr-FR', { day: '2-digit', month: 'short', year: 'numeric' }) }}
              </div>
              <div class="sim-card-actions">
                <button @click="viewSimulation(sim.id_simulation)" class="sim-action-btn view" title="Voir le détail">
                  <i class="bi bi-eye"></i>
                </button>
                <button @click="confirmDelete(sim.id_simulation)" class="sim-action-btn delete" title="Supprimer">
                  <i class="bi bi-trash3"></i>
                </button>
              </div>
            </div>
            <div class="sim-card-body">
              <h3 class="sim-card-title">{{ sim.nom_simulation }}</h3>
              <p class="sim-card-desc" v-if="sim.description">{{ sim.description }}</p>
            </div>
            <div class="sim-card-footer">
              <div class="sim-card-metric">
                <span class="sim-metric-label">Impact budgétaire</span>
                <span :class="['sim-metric-value', getSimulationResult(sim) >= 0 ? 'positive' : 'negative']">
                  <i :class="['bi', getSimulationResult(sim) >= 0 ? 'bi-trending-up' : 'bi-trending-down']"></i>
                  {{ getSimulationResult(sim) >= 0 ? '+' : '-' }}{{ Math.abs(getSimulationResult(sim)).toLocaleString('fr-FR') }} Ar
                </span>
              </div>
              <div class="sim-card-lines-count">
                <i class="bi bi-layers me-1"></i>
                {{ (sim.lignes || []).length }} postes
              </div>
            </div>
          </div>

          <!-- No search results -->
          <div v-if="filteredSimulations.length === 0 && searchQuery" class="empty-search">
            <i class="bi bi-search me-2"></i>
            Aucun résultat pour "{{ searchQuery }}"
          </div>
        </div>

        <AppFooter />
      </div>
    </div>

    <!-- MODALE DE CRÉATION -->
    <transition name="modal-fade">
      <div v-if="showModal" class="modal-overlay" @click.self="showModal = false">
        <div class="modal modal-xl">
          <div class="modal-header premium-header">
            <div class="d-flex align-items-center gap-3">
              <div class="modal-header-icon">
                <i class="bi bi-sliders2"></i>
              </div>
              <div>
                <h2 class="modal-title" style="font-family: 'Stara', sans-serif;">
                  Paramétrage du Scénario
                </h2>
                <p class="modal-subtitle">Configurez vos hypothèses de croissance</p>
              </div>
            </div>
            <button @click="showModal = false" class="modal-close-btn">
              <i class="bi bi-x-lg"></i>
            </button>
          </div>

          <div class="modal-body p-6">
            <!-- Form fields -->
            <div class="form-row">
              <div class="form-col">
                <label class="form-label required font-bold">Nom du scénario</label>
                <input v-model="newSim.nom_simulation" type="text" class="form-input" placeholder="Ex: Budget 2026 — Croissance modérée">
              </div>
              <div class="form-col">
                <label class="form-label font-bold">Description</label>
                <input v-model="newSim.description" type="text" class="form-input" placeholder="Hypothèses et contexte du scénario...">
              </div>
            </div>

            <!-- KPI Cards -->
            <div class="kpi-row">
              <div v-for="(stat, idx) in stats" :key="idx" class="kpi-card" :class="stat.bgClass">
                <div class="kpi-icon-wrapper" :style="{ color: stat.color }">
                  <i :class="['bi', stat.icon]"></i>
                </div>
                <div class="kpi-content">
                  <span class="kpi-label">{{ stat.label }}</span>
                  <span class="kpi-value" :style="{ color: stat.color }">
                    {{ stat.absVal }} <small>Ar</small>
                  </span>
                </div>
              </div>
            </div>

            <!-- Simulation Table -->
            <div class="sim-table-wrapper">
              <table class="sim-table">
                <thead>
                  <tr>
                    <th class="text-left" style="width: 30%;">Libellé du compte</th>
                    <th class="text-center" style="width: 100px;">Type</th>
                    <th class="text-center" style="width: 100px;">Nature</th>
                    <th class="text-right" style="width: 160px;">Moyenne Hist.</th>
                    <th class="text-center" style="width: 100px;">Coeff.</th>
                    <th class="text-right" style="width: 160px;">Montant Simulé</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(ligne, index) in newSim.lignes" :key="index" class="sim-table-row">
                    <td class="align-middle font-bold">{{ ligne.libelle }}</td>
                    <td class="align-middle text-center">
                      <span :class="['type-badge', ligne.type === 'produit' ? 'type-produit' : 'type-charge']">
                        {{ ligne.type === 'produit' ? 'Produit' : 'Charge' }}
                      </span>
                    </td>
                    <td class="align-middle text-center">
                      <select v-model="ligne.nature_charge" class="nature-select">
                        <option value="fixe">Fixe</option>
                        <option value="variable">Variable</option>
                      </select>
                    </td>
                    <td :class="['align-middle text-right font-mono', ligne.type === 'produit' ? 'text-success' : 'text-danger']">
                      {{ Math.abs(ligne.moyenne_historique).toLocaleString('fr-FR') }} Ar
                    </td>
                    <td class="align-middle text-center">
                      <input
                        v-model.number="ligne.coefficient"
                        @input="updateMontantLigne(index)"
                        type="number"
                        step="0.05"
                        class="coeff-input"
                      >
                    </td>
                    <td :class="['align-middle text-right font-bold font-mono', ligne.type === 'produit' ? 'text-success' : 'text-danger']">
                      {{ Math.abs(ligne.montant_simule).toLocaleString('fr-FR') }} Ar
                    </td>
                  </tr>
                  <tr v-if="newSim.lignes.length === 0">
                    <td colspan="6" class="empty-table-msg">
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
              <i class="bi bi-check2-circle me-2" v-if="!saving"></i>
              <span v-if="saving" class="spinner spinner-sm me-2"></span>
              {{ saving ? 'Enregistrement...' : 'Enregistrer le Scénario' }}
            </button>
          </div>
        </div>
      </div>
    </transition>

    <!-- SUCCESS POPUP -->
    <transition name="modal-fade">
      <div v-if="showSuccessModal" class="modal-overlay" @click.self="showSuccessModal = false">
        <div class="modal modal-sm notification-modal">
          <div class="notif-icon success"><i class="bi bi-check-lg"></i></div>
          <h3 class="notif-title">Succès</h3>
          <p class="notif-message">{{ successModalMessage }}</p>
          <button class="btn btn-primary w-full" @click="showSuccessModal = false">Fermer</button>
        </div>
      </div>
    </transition>

    <!-- VIEW MODAL (PROFESSIONAL REPORT) -->
    <transition name="modal-fade">
      <div v-if="showViewModal && selectedSimulation" class="modal-overlay" @click.self="showViewModal = false">
        <div class="modal modal-xl document-modal">
          <!-- Sticky top bar -->
          <div class="doc-topbar no-print">
            <div class="doc-topbar-left">
              <div class="doc-topbar-badge">
                <i class="bi bi-file-earmark-bar-graph me-2"></i>Rapport de Simulation
              </div>
              <span class="doc-topbar-ref">REF: #SIM-{{ selectedSimulation.id_simulation }}</span>
            </div>
            <div class="doc-topbar-actions">
              <button @click="exportToPDF" class="doc-action-btn">
                <i class="bi bi-printer"></i> Imprimer
              </button>
              <button @click="showViewModal = false" class="doc-close-btn">
                <i class="bi bi-x-lg"></i>
              </button>
            </div>
          </div>

          <div class="modal-body document-body">
            <!-- Report Hero Banner -->
            <div class="report-hero">
              <div class="report-hero-bg"></div>
              <div class="report-hero-content">
                <div class="report-hero-left">
                  <div class="report-hero-badge">SIMULATION BUDGÉTAIRE</div>
                  <h1 class="report-hero-title">{{ selectedSimulation.nom_simulation }}</h1>
                  <p class="report-hero-date">
                    <i class="bi bi-calendar3 me-1"></i>
                    Établi le {{ new Date().toLocaleDateString('fr-FR', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' }) }}
                  </p>
                </div>
                <div class="report-hero-result">
                  <span class="report-hero-result-label">Résultat Net</span>
                  <span :class="['report-hero-result-value', resView >= 0 ? 'positive' : 'negative']">
                    {{ resView >= 0 ? '+' : '-' }}{{ Math.abs(resView).toLocaleString('fr-FR') }}
                    <small>Ar</small>
                  </span>
                </div>
              </div>
            </div>

            <!-- Description Card -->
            <div class="report-desc" v-if="selectedSimulation.description">
              <div class="report-desc-icon">
                <i class="bi bi-quote"></i>
              </div>
              <p class="report-desc-text">" {{ selectedSimulation.description }} "</p>
            </div>

            <!-- KPI Metrics Row -->
            <div class="report-section-label">
              <i class="bi bi-speedometer2 me-2"></i>Synthèse des Résultats
            </div>
            <div class="report-kpi-row">
              <!-- Recettes -->
              <div class="report-kpi-card-v2 kpi-recettes">
                <div class="kpi-v2-icon-circle">
                  <i class="bi bi-arrow-up-right"></i>
                </div>
                <div class="kpi-v2-body">
                  <span class="kpi-v2-label">Total Recettes</span>
                  <span class="kpi-v2-value">{{ totProdView.toLocaleString('fr-FR') }} <small>Ar</small></span>
                </div>
                <div class="kpi-v2-bar">
                  <div class="kpi-v2-bar-fill" :style="{ width: getKpiBarWidth({ val: totProdView }) + '%' }"></div>
                </div>
              </div>

              <!-- Dépenses -->
              <div class="report-kpi-card-v2 kpi-depenses">
                <div class="kpi-v2-icon-circle">
                  <i class="bi bi-arrow-down-right"></i>
                </div>
                <div class="kpi-v2-body">
                  <span class="kpi-v2-label">Total Dépenses</span>
                  <span class="kpi-v2-value">{{ totChgView.toLocaleString('fr-FR') }} <small>Ar</small></span>
                </div>
                <div class="kpi-v2-bar">
                  <div class="kpi-v2-bar-fill" :style="{ width: getKpiBarWidth({ val: -totChgView }) + '%' }"></div>
                </div>
              </div>

              <!-- Résultat Net -->
              <div :class="['report-kpi-card-v2', 'kpi-resultat', resView >= 0 ? 'kpi-resultat-pos' : 'kpi-resultat-neg']">
                <div class="kpi-v2-icon-circle">
                  <i :class="['bi', resView >= 0 ? 'bi-trophy' : 'bi-exclamation-triangle']"></i>
                </div>
                <div class="kpi-v2-body">
                  <span class="kpi-v2-label">Résultat Net</span>
                  <span class="kpi-v2-value">
                    {{ resView >= 0 ? '+' : '-' }}{{ Math.abs(resView).toLocaleString('fr-FR') }} <small>Ar</small>
                  </span>
                </div>
                <div class="kpi-v2-tag">
                  <i :class="['bi', resView >= 0 ? 'bi-check-circle-fill' : 'bi-x-circle-fill', 'me-1']"></i>
                  {{ resView >= 0 ? 'Excédentaire' : 'Déficitaire' }}
                </div>
              </div>
            </div>

            <!-- Accounts Table -->
            <div class="report-section-label">
              <i class="bi bi-list-columns-reverse me-2"></i>Décomposition par Poste
            </div>
            <div class="report-table-wrapper">
              <table class="report-table">
                <thead>
                  <tr>
                    <th class="text-left" style="width: 38%;">Poste Budgétaire</th>
                    <th class="text-center" style="width: 13%;">Type</th>
                    <th class="text-center" style="width: 11%;">Nature</th>
                    <th class="text-right" style="width: 19%;">Réalisé (Hist.)</th>
                    <th class="text-right" style="width: 19%;">Projection Simulée</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(ligne, index) in selectedSimulation.lignes" :key="index" class="report-table-row">
                    <td class="align-middle">
                      <div class="report-poste-name">{{ ligne.libelle }}</div>
                    </td>
                    <td class="align-middle text-center">
                      <span :class="['type-badge', ligne.type === 'produit' ? 'type-produit' : 'type-charge']">
                        {{ ligne.type === 'produit' ? 'Recette' : 'Dépense' }}
                      </span>
                    </td>
                    <td class="align-middle text-center">
                      <span class="nature-badge">{{ ligne.nature_charge === 'fixe' ? 'Fixe' : 'Variable' }}</span>
                    </td>
                    <td class="align-middle text-right font-mono text-muted">
                      {{ Math.abs(parseFloat(ligne.moyenne_historique)).toLocaleString('fr-FR') }} Ar
                    </td>
                    <td class="align-middle text-right">
                      <span :class="['report-montant', ligne.type === 'produit' ? 'positive' : 'negative']">
                        {{ Math.abs(parseFloat(ligne.montant_simule)).toLocaleString('fr-FR') }} Ar
                      </span>
                    </td>
                  </tr>
                </tbody>
                <tfoot>
                  <tr class="report-table-total">
                    <td colspan="3" class="text-right font-bold">TOTAL GÉNÉRAL</td>
                    <td class="text-right font-mono font-bold text-muted">
                      {{ Math.abs(selectedSimulation.lignes.reduce((s, l) => s + Math.abs(parseFloat(l.moyenne_historique)), 0)).toLocaleString('fr-FR') }} Ar
                    </td>
                    <td class="text-right font-mono font-bold">
                      <span :class="resView >= 0 ? 'text-success' : 'text-danger'">
                        {{ resView >= 0 ? '+' : '-' }}{{ Math.abs(resView).toLocaleString('fr-FR') }} Ar
                      </span>
                    </td>
                  </tr>
                </tfoot>
              </table>
            </div>

            <!-- Document Footer -->
            <div class="report-footer">
              <p class="report-footer-disclaimer">
                <i class="bi bi-info-circle me-1"></i>
                Ce document constitue une projection basée sur les données historiques fournies.
                Il est destiné à faciliter la prise de décision stratégique.
              </p>
              <p class="report-footer-gen">
                Document généré automatiquement par FinanSchool
              </p>
            </div>
          </div>
        </div>
      </div>
    </transition>

    <!-- ERROR POPUP -->
    <transition name="modal-fade">
      <div v-if="showErrorModal" class="modal-overlay" @click.self="showErrorModal = false">
        <div class="modal modal-sm notification-modal">
          <div class="notif-icon error"><i class="bi bi-x-lg"></i></div>
          <h3 class="notif-title">Erreur</h3>
          <p class="notif-message">{{ errorModalMessage }}</p>
          <button class="btn btn-primary w-full" @click="showErrorModal = false">Fermer</button>
        </div>
      </div>
    </transition>

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
import Sidebar from "../../molecules/Sidebar.vue";
import Header from "../../molecules/Header.vue";
import AppFooter from "../../molecules/Footer.vue";
import ChatBot from "../../molecules/ChatBot.vue";
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

const stats = computed(() => {
  const values = [
    { label: 'Total Recettes', val: totalProduits.value },
    { label: 'Total Dépenses', val: -totalCharges.value },
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

const getKpiBarWidth = (stat) => {
  const maxVal = Math.max(totProdView.value, totChgView.value, Math.abs(resView.value)) || 1;
  return Math.min((Math.abs(stat.val) / maxVal) * 100, 100);
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

/* ===== LAYOUT ===== */
.dashboard-container { display: flex; min-height: 100vh; flex-direction: column; }
.main-content {
  margin-left: 278px;
  padding: 32px;
  flex: 1;
  background: #f8fafc;
  min-height: calc(100vh - 80px);
  font-family: 'Stara', sans-serif;
}

.page-animate {
  animation: fadeInUp 0.5s ease-out;
}

/* ===== PAGE HEADER ===== */
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: white;
  border-radius: 16px;
  padding: 28px 32px;
  margin-bottom: 24px;
  border: 1px solid var(--gray-200);
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.04);
}

.page-header-content {
  display: flex;
  align-items: center;
  gap: 20px;
}

.page-header-icon {
  width: 56px;
  height: 56px;
  border-radius: 14px;
  background: linear-gradient(135deg, var(--primary-color) 0%, var(--primary-dark) 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 1.5rem;
  flex-shrink: 0;
}

.page-title {
  font-size: 1.75rem;
  font-weight: 700;
  color: var(--primary-color);
  margin: 0;
  line-height: 1.2;
}

.page-subtitle {
  font-size: 0.9rem;
  color: var(--gray-500);
  margin: 4px 0 0 0;
  font-weight: 400;
}

.page-header-stats {
  display: flex;
  gap: 24px;
}

.header-stat {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 8px 20px;
  background: var(--gray-50);
  border-radius: 12px;
}

.header-stat-value {
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--primary-color);
}

.header-stat-label {
  font-size: 0.75rem;
  color: var(--gray-500);
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

/* ===== TOOLBAR ===== */
.toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 16px;
  margin-bottom: 24px;
}

.search-wrapper {
  position: relative;
  flex: 1;
  max-width: 480px;
}

.search-icon {
  position: absolute;
  left: 16px;
  top: 50%;
  transform: translateY(-50%);
  color: var(--gray-400);
  font-size: 0.9rem;
}

.search-input {
  padding-left: 44px !important;
  height: 48px !important;
  border-radius: 12px;
  border: 1px solid var(--gray-200);
  background: white;
  width: 100%;
  transition: all 0.2s ease;
  font-size: 0.95rem;
}

.search-input:focus {
  border-color: var(--primary-lighter);
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.btn-create {
  height: 48px;
  padding: 0 28px;
  font-size: 0.95rem;
  border-radius: 12px;
  white-space: nowrap;
  font-weight: 600;
}

/* ===== LOADING STATE ===== */
.loading-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 80px 0;
}

/* ===== EMPTY STATE ===== */
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 80px 32px;
  background: white;
  border-radius: 16px;
  border: 2px dashed var(--gray-200);
  text-align: center;
}

.empty-state-icon {
  width: 80px;
  height: 80px;
  border-radius: 20px;
  background: linear-gradient(135deg, #eef2ff, #e0e7ff);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 2rem;
  color: var(--primary-color);
  margin-bottom: 20px;
}

.empty-state h3 {
  font-size: 1.25rem;
  font-weight: 700;
  color: var(--gray-700);
  margin: 0 0 8px;
}

.empty-state p {
  color: var(--gray-500);
  margin: 0 0 24px;
  max-width: 360px;
}

/* ===== SIMULATION CARDS GRID ===== */
.sim-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(360px, 1fr));
  gap: 20px;
}

.sim-card {
  background: white;
  border-radius: 14px;
  border: 1px solid var(--gray-200);
  overflow: hidden;
  transition: all 0.25s ease;
  animation: fadeInUp 0.4s ease-out both;
  display: flex;
  flex-direction: column;
}

.sim-card:hover {
  border-color: var(--primary-lighter);
  box-shadow: 0 8px 24px rgba(20, 44, 108, 0.08);
  transform: translateY(-2px);
}

.sim-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px 0;
}

.sim-card-date {
  font-size: 0.78rem;
  color: var(--gray-400);
  font-weight: 500;
  display: flex;
  align-items: center;
}

.sim-card-actions {
  display: flex;
  gap: 4px;
}

.sim-action-btn {
  width: 34px;
  height: 34px;
  border-radius: 8px;
  border: none;
  background: transparent;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.9rem;
  transition: all 0.15s ease;
}

.sim-action-btn.view {
  color: var(--primary-color);
}

.sim-action-btn.view:hover {
  background: #eef2ff;
  color: var(--primary-dark);
}

.sim-action-btn.delete {
  color: var(--gray-400);
}

.sim-action-btn.delete:hover {
  background: #fef2f2;
  color: var(--error-color);
}

.sim-card-body {
  padding: 12px 20px 16px;
  flex: 1;
}

.sim-card-title {
  font-size: 1.05rem;
  font-weight: 700;
  color: var(--gray-800);
  margin: 0 0 6px;
  line-height: 1.3;
}

.sim-card-desc {
  font-size: 0.85rem;
  color: var(--gray-500);
  margin: 0;
  line-height: 1.5;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.sim-card-footer {
  padding: 14px 20px;
  border-top: 1px solid var(--gray-100);
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  background: var(--gray-50);
}

.sim-card-metric {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.sim-metric-label {
  font-size: 0.7rem;
  color: var(--gray-400);
  text-transform: uppercase;
  letter-spacing: 0.5px;
  font-weight: 600;
}

.sim-metric-value {
  font-size: 1.1rem;
  font-weight: 700;
  font-family: 'SF Mono', 'Fira Code', monospace;
  display: flex;
  align-items: center;
  gap: 6px;
}

.sim-metric-value.positive { color: var(--success-color); }
.sim-metric-value.negative { color: var(--error-color); }

.sim-card-lines-count {
  font-size: 0.78rem;
  color: var(--gray-400);
  display: flex;
  align-items: center;
}

.empty-search {
  grid-column: 1 / -1;
  text-align: center;
  padding: 48px;
  color: var(--gray-400);
  font-size: 0.95rem;
}

/* ===== MODAL BASE ===== */
.modal-overlay {
  position: fixed; top: 0; left: 0; width: 100vw; height: 100vh;
  background-color: rgba(15, 23, 42, 0.5);
  display: flex; justify-content: center; align-items: center;
  z-index: 10000;
  backdrop-filter: blur(6px);
  font-family: 'Stara', sans-serif;
}

.modal {
  background: white;
  border-radius: 16px;
  box-shadow: 0 25px 60px -12px rgba(0, 0, 0, 0.25);
  display: flex;
  flex-direction: column;
  max-height: 92vh;
  overflow: hidden;
}

.modal-xl { width: 95%; max-width: 1100px; }
.modal-sm { width: 90%; max-width: 420px; }

.modal-header {
  padding: 1.5rem;
  border-bottom: 1px solid var(--gray-200);
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.modal-body { padding: 1.5rem; overflow-y: auto; }

.modal-footer {
  background-color: var(--gray-50);
  border-top: 1px solid var(--gray-200);
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
}

.modal-close {
  background: none;
  border: none;
  font-size: 1.5rem;
  cursor: pointer;
  color: var(--gray-400);
  line-height: 1;
  padding: 4px;
  border-radius: 8px;
  transition: all 0.15s;
}

.modal-close:hover {
  background: var(--gray-100);
  color: var(--gray-600);
}

/* Modal transition */
.modal-fade-enter-active { transition: all 0.25s ease-out; }
.modal-fade-leave-active { transition: all 0.2s ease-in; }
.modal-fade-enter-from { opacity: 0; }
.modal-fade-enter-from .modal { transform: scale(0.95) translateY(10px); }
.modal-fade-leave-to { opacity: 0; }
.modal-fade-leave-to .modal { transform: scale(0.97); }

/* ===== CREATION MODAL ===== */
.premium-header {
  background: linear-gradient(135deg, var(--primary-color) 0%, var(--primary-dark) 100%);
  padding: 24px 28px;
  border-bottom: none;
}

.modal-header-icon {
  width: 44px;
  height: 44px;
  border-radius: 12px;
  background: rgba(255, 255, 255, 0.15);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 1.2rem;
}

.premium-header .modal-title {
  color: white;
  font-size: 1.3rem;
  font-weight: 700;
  margin: 0;
}

.modal-subtitle {
  color: rgba(255, 255, 255, 0.6);
  font-size: 0.85rem;
  margin: 2px 0 0;
}

.modal-close-btn {
  background: rgba(255, 255, 255, 0.1);
  border: none;
  width: 36px;
  height: 36px;
  border-radius: 10px;
  color: rgba(255, 255, 255, 0.7);
  font-size: 1.1rem;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.15s;
}

.modal-close-btn:hover {
  background: rgba(255, 255, 255, 0.2);
  color: white;
}

/* Form layout inside modal */
.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
  margin-bottom: 28px;
}

/* ===== KPI CARDS ===== */
.kpi-row {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
  margin-bottom: 28px;
}

.kpi-card {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 20px;
  border-radius: 14px;
  transition: transform 0.2s ease;
}

.kpi-card:hover {
  transform: translateY(-1px);
}

.kpi-icon-wrapper {
  width: 44px;
  height: 44px;
  border-radius: 12px;
  background: rgba(255, 255, 255, 0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.3rem;
  flex-shrink: 0;
}

.kpi-content {
  display: flex;
  flex-direction: column;
  gap: 2px;
  min-width: 0;
}

.kpi-label {
  font-size: 0.72rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  color: var(--gray-500);
}

.kpi-value {
  font-size: 1.25rem;
  font-weight: 700;
  font-family: 'SF Mono', 'Fira Code', monospace;
  white-space: nowrap;
}

.kpi-value small {
  font-size: 0.75rem;
  font-weight: 500;
  opacity: 0.7;
}

.bg-success-light { background-color: #f0fdf4 !important; }
.bg-danger-light { background-color: #fef2f2 !important; }
.bg-primary-light { background-color: #eef2ff !important; }

/* ===== SIMULATION TABLE (Creation Modal) ===== */
.sim-table-wrapper {
  border: 1px solid var(--gray-200);
  border-radius: 12px;
  overflow: hidden;
  max-height: 380px;
  overflow-y: auto;
}

.sim-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.9rem;
}

.sim-table thead {
  position: sticky;
  top: 0;
  z-index: 1;
}

.sim-table th {
  background: linear-gradient(135deg, var(--primary-color) 0%, var(--primary-dark) 100%);
  color: white;
  font-weight: 600;
  font-size: 0.8rem;
  text-transform: uppercase;
  letter-spacing: 0.3px;
  padding: 14px 16px;
  border: none;
}

.sim-table td {
  padding: 12px 16px;
  border-bottom: 1px solid var(--gray-100);
}

.sim-table-row {
  transition: background-color 0.15s ease;
}

.sim-table-row:hover {
  background-color: #f8fafc;
}

.sim-table-row:last-child td {
  border-bottom: none;
}

.type-badge {
  display: inline-block;
  padding: 3px 10px;
  border-radius: 6px;
  font-size: 0.72rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.3px;
}

.type-produit {
  background: #ecfdf5;
  color: #059669;
}

.type-charge {
  background: #fef2f2;
  color: #dc2626;
}

.nature-select {
  padding: 4px 8px;
  border: 1px solid var(--gray-200);
  border-radius: 6px;
  font-size: 0.82rem;
  background: white;
  color: var(--gray-600);
  cursor: pointer;
  outline: none;
  transition: border-color 0.15s;
}

.nature-select:focus {
  border-color: var(--primary-lighter);
}

.coeff-input {
  width: 72px;
  padding: 5px 8px;
  border: 1px solid var(--gray-200);
  border-radius: 8px;
  text-align: center;
  font-size: 0.9rem;
  font-weight: 600;
  outline: none;
  transition: all 0.15s;
  background: white;
}

.coeff-input:focus {
  border-color: var(--primary-lighter);
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.empty-table-msg {
  padding: 40px 24px;
  text-align: center;
  color: var(--gray-400);
  font-style: italic;
}

/* ===== NOTIFICATION MODALS ===== */
.notification-modal {
  padding: 40px 32px 32px;
  text-align: center;
}

.notif-icon {
  width: 64px;
  height: 64px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 20px;
  font-size: 1.5rem;
}

.notif-icon.success {
  background: #ecfdf5;
  color: #059669;
}

.notif-icon.error {
  background: #fef2f2;
  color: #dc2626;
}

.notif-title {
  font-size: 1.25rem;
  font-weight: 700;
  color: var(--gray-800);
  margin: 0 0 8px;
}

.notif-message {
  color: var(--gray-500);
  margin: 0 0 24px;
  font-size: 0.95rem;
  line-height: 1.5;
}

/* ===== DOCUMENT / REPORT STYLING ===== */
.document-modal {
  border-radius: 16px;
  border: none;
  overflow: hidden;
  box-shadow: 0 25px 60px -12px rgba(0, 0, 0, 0.3);
  max-height: 95vh;
}

.doc-topbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 14px 24px;
  background: #f8fafc;
  border-bottom: 1px solid var(--gray-200);
}

.doc-topbar-left {
  display: flex;
  align-items: center;
  gap: 16px;
}

.doc-topbar-badge {
  font-size: 0.82rem;
  font-weight: 700;
  color: var(--primary-color);
  display: flex;
  align-items: center;
}

.doc-topbar-ref {
  font-size: 0.75rem;
  color: var(--gray-400);
  font-family: 'SF Mono', 'Fira Code', monospace;
}

.doc-topbar-actions {
  display: flex;
  align-items: center;
  gap: 8px;
}

.doc-action-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 16px;
  border: 1px solid var(--gray-200);
  border-radius: 8px;
  background: white;
  color: var(--gray-600);
  font-size: 0.82rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.15s;
}

.doc-action-btn:hover {
  background: var(--gray-50);
  border-color: var(--gray-300);
  color: var(--gray-800);
}

.doc-close-btn {
  width: 36px;
  height: 36px;
  border-radius: 8px;
  border: 1px solid var(--gray-200);
  background: white;
  color: var(--gray-400);
  font-size: 1rem;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.15s;
}

.doc-close-btn:hover {
  background: #fef2f2;
  border-color: #fca5a5;
  color: var(--error-color);
}

.document-body {
  padding: 0;
  overflow-y: auto;
  font-family: 'Inter', system-ui, -apple-system, sans-serif;
  color: #1e293b;
}

/* Report Hero Banner */
.report-hero {
  position: relative;
  padding: 40px 40px 36px;
  overflow: hidden;
}

.report-hero-bg {
  position: absolute;
  inset: 0;
  background: linear-gradient(135deg, var(--primary-color) 0%, var(--primary-dark) 100%);
  opacity: 0.04;
}

.report-hero-content {
  position: relative;
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  gap: 24px;
}

.report-hero-badge {
  display: inline-block;
  font-size: 0.68rem;
  font-weight: 800;
  letter-spacing: 2px;
  text-transform: uppercase;
  color: var(--primary-color);
  background: rgba(20, 44, 108, 0.08);
  padding: 5px 12px;
  border-radius: 6px;
  margin-bottom: 12px;
}

.report-hero-title {
  font-size: 1.85rem;
  font-weight: 800;
  color: #1e293b;
  margin: 0 0 8px;
  line-height: 1.2;
  letter-spacing: -0.5px;
}

.report-hero-date {
  font-size: 0.85rem;
  color: var(--gray-400);
  margin: 0;
  display: flex;
  align-items: center;
}

.report-hero-result {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 4px;
  flex-shrink: 0;
}

.report-hero-result-label {
  font-size: 0.72rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  color: var(--gray-400);
}

.report-hero-result-value {
  font-size: 1.75rem;
  font-weight: 800;
  font-family: 'SF Mono', 'Fira Code', monospace;
}

.report-hero-result-value.positive { color: var(--success-color); }
.report-hero-result-value.negative { color: var(--error-color); }
.report-hero-result-value small {
  font-size: 0.65em;
  font-weight: 500;
  opacity: 0.7;
}

/* Description Card */
.report-desc {
  display: flex;
  align-items: flex-start;
  gap: 16px;
  margin: 0 40px 32px;
  padding: 20px 24px;
  background: #f8fafc;
  border-radius: 12px;
  border: 1px solid var(--gray-200);
}

.report-desc-icon {
  width: 36px;
  height: 36px;
  border-radius: 8px;
  background: white;
  border: 1px solid var(--gray-200);
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--primary-color);
  font-size: 1rem;
  flex-shrink: 0;
}

.report-desc-text {
  font-size: 0.95rem;
  color: var(--gray-600);
  line-height: 1.6;
  margin: 0;
  font-style: italic;
}

/* Section Labels */
.report-section-label {
  display: flex;
  align-items: center;
  font-size: 0.78rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.8px;
  color: var(--gray-400);
  padding: 0 40px;
  margin-bottom: 16px;
}

.report-section-label i {
  font-size: 0.9rem;
}

/* Report KPI Cards V2 */
.report-kpi-row {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
  padding: 0 40px;
  margin-bottom: 36px;
}

.report-kpi-card-v2 {
  padding: 24px;
  border-radius: 16px;
  border: 1px solid transparent;
  display: flex;
  flex-direction: column;
  gap: 14px;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.report-kpi-card-v2:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.06);
}

/* Recettes card */
.kpi-recettes {
  background: linear-gradient(135deg, #f0fdf4 0%, #dcfce7 100%);
  border-color: #bbf7d0;
}

.kpi-recettes .kpi-v2-icon-circle {
  background: #16a34a;
  color: white;
}

.kpi-recettes .kpi-v2-value {
  color: #15803d;
}

.kpi-recettes .kpi-v2-bar-fill {
  background: #16a34a;
}

/* Dépenses card */
.kpi-depenses {
  background: linear-gradient(135deg, #fef2f2 0%, #fee2e2 100%);
  border-color: #fecaca;
}

.kpi-depenses .kpi-v2-icon-circle {
  background: #dc2626;
  color: white;
}

.kpi-depenses .kpi-v2-value {
  color: #b91c1c;
}

.kpi-depenses .kpi-v2-bar-fill {
  background: #dc2626;
}

/* Résultat card */
.kpi-resultat-pos {
  background: linear-gradient(135deg, #eef2ff 0%, #e0e7ff 100%);
  border-color: #c7d2fe;
}

.kpi-resultat-pos .kpi-v2-icon-circle {
  background: var(--primary-color);
  color: white;
}

.kpi-resultat-pos .kpi-v2-value {
  color: var(--primary-color);
}

.kpi-resultat-pos .kpi-v2-tag {
  color: #15803d;
  background: #dcfce7;
}

.kpi-resultat-neg {
  background: linear-gradient(135deg, #fff7ed 0%, #ffedd5 100%);
  border-color: #fed7aa;
}

.kpi-resultat-neg .kpi-v2-icon-circle {
  background: #ea580c;
  color: white;
}

.kpi-resultat-neg .kpi-v2-value {
  color: #c2410c;
}

.kpi-resultat-neg .kpi-v2-tag {
  color: #b91c1c;
  background: #fee2e2;
}

/* KPI V2 inner elements */
.kpi-v2-icon-circle {
  width: 40px;
  height: 40px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.1rem;
  flex-shrink: 0;
}

.kpi-v2-body {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.kpi-v2-label {
  font-size: 0.75rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  color: var(--gray-500);
}

.kpi-v2-value {
  font-size: 1.6rem;
  font-weight: 800;
  font-family: 'SF Mono', 'Fira Code', monospace;
  line-height: 1;
}

.kpi-v2-value small {
  font-size: 0.55em;
  font-weight: 500;
  opacity: 0.6;
  margin-left: 2px;
}

.kpi-v2-bar {
  height: 5px;
  background: rgba(0, 0, 0, 0.06);
  border-radius: 3px;
  overflow: hidden;
}

.kpi-v2-bar-fill {
  height: 100%;
  border-radius: 3px;
  transition: width 0.8s cubic-bezier(0.4, 0, 0.2, 1);
  opacity: 0.45;
}

.kpi-v2-tag {
  display: inline-flex;
  align-items: center;
  align-self: flex-start;
  font-size: 0.72rem;
  font-weight: 700;
  padding: 4px 10px;
  border-radius: 6px;
}

/* Report Table */
.report-table-wrapper {
  margin: 0 40px 36px;
  border: 1px solid var(--gray-200);
  border-radius: 12px;
  overflow: hidden;
}

.report-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.88rem;
}

.report-table thead th {
  background: #f1f5f9;
  color: #475569;
  font-weight: 700;
  font-size: 0.75rem;
  text-transform: uppercase;
  letter-spacing: 0.3px;
  padding: 14px 20px;
  border-bottom: 2px solid var(--gray-200);
}

.report-table td {
  padding: 14px 20px;
  border-bottom: 1px solid var(--gray-100);
}

.report-table-row {
  transition: background-color 0.12s ease;
}

.report-table-row:hover {
  background: #f8fafc;
}

.report-table-row:last-child td {
  border-bottom: none;
}

.report-poste-name {
  font-weight: 600;
  color: #334155;
}

.nature-badge {
  font-size: 0.78rem;
  color: var(--gray-500);
  background: var(--gray-50);
  padding: 2px 10px;
  border-radius: 4px;
}

.report-montant {
  font-weight: 700;
  font-family: 'SF Mono', 'Fira Code', monospace;
}

.report-montant.positive { color: var(--success-color); }
.report-montant.negative { color: var(--error-color); }

.report-table-total td {
  padding: 16px 20px;
  background: #f8fafc;
  border-top: 2px solid var(--gray-200);
  font-size: 0.9rem;
}

.report-table tfoot .report-table-total td:first-child {
  border-bottom-left-radius: 12px;
}

.report-table tfoot .report-table-total td:last-child {
  border-bottom-right-radius: 12px;
}

/* Report Footer */
.report-footer {
  padding: 28px 40px 36px;
  border-top: 2px solid var(--gray-100);
  margin-top: 8px;
  text-align: center;
}

.report-footer-disclaimer {
  font-size: 0.82rem;
  color: var(--gray-400);
  line-height: 1.6;
  margin: 0 0 6px;
}

.report-footer-gen {
  font-size: 0.72rem;
  color: var(--gray-300);
  margin: 0;
  font-style: italic;
}

.rounded-xl { border-radius: 1rem; }

/* ===== CHATBOT ===== */
.chatbot-float-btn {
  position: fixed; bottom: 55px; right: 45px; width: 54px; height: 54px;
  background: linear-gradient(135deg, var(--primary-color) 0%, var(--primary-dark) 100%);
  border-radius: 50%; color: #fff; font-size: 2em;
  display: flex; align-items: center; justify-content: center;
  z-index: 200; border: none; box-shadow: var(--shadow-lg);
  transition: transform 0.2s ease;
}

.chatbot-float-btn:hover {
  transform: scale(1.05);
}

/* ===== ANIMATIONS ===== */
@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(16px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* ===== PRINT STYLES ===== */
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
  .text-success { color: #16a34a !important; }
  .text-danger { color: #dc2626 !important; }
  .bg-success-light { background-color: #f0fdf4 !important; }
  .bg-danger-light { background-color: #fef2f2 !important; }
}
</style>
