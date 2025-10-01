<template>
  <div class="dashboard-container w-full">
    <!-- Header -->
    <Header />

    <!-- Sidebar -->
    <Sidebar :current-route="$route.path" @navigation-change="handleNavigation" />

    <div class="main-content p-6">
      <div class="p-4">
        <div class="card card-form">
          <div class="card-header">
            <h1 class="card-title text-3xl" style="margin-bottom: var(--spacing-lg);">Écriture Comptable</h1>
          </div>

          <!-- FORMULAIRE MOUVEMENT -->
          <form @submit.prevent="createMouvement" class="card-form">
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: var(--spacing-md);">
              <div class="form-group">
                <label class="form-label required">Date du Mouvement</label>
                <input 
                  v-model="mouvementForm.Date_mouvement" 
                  type="date" 
                  class="form-input" 
                  required 
                />
              </div>
              <div class="form-group">
                <label class="form-label required">Journal</label>
                <select v-model="mouvementForm.Id_Journal" class="form-select" required>
                  <option value="">-- Sélectionner --</option>
                  <option v-for="journal in journals" :key="journal.Id_Journal" :value="journal.Id_Journal">
                    {{ journal.Code }} - {{ journal.Libelle }}
                  </option>
                </select>
              </div>
            </div>
            <button 
              type="submit" 
              :disabled="isCreatingMouvement"
              class="btn btn-primary"
            >
              {{ isCreatingMouvement ? 'Création...' : 'Créer Mouvement' }}
            </button>
          </form>

          <!-- FILTRES -->
          <div class="filters-section" style="margin-top: var(--spacing-xl); padding: var(--spacing-lg); background: var(--gray-50); border-radius: var(--radius-md); border: 1px solid var(--gray-200);">
            <div style="display: flex; align-items: center; gap: var(--spacing-sm); margin-bottom: var(--spacing-md);">
              <span style="font-weight: 600; color: var(--gray-700);">🔍 Filtres</span>
              <button 
                v-if="hasActiveFilters"
                @click="resetFilters" 
                class="btn btn-xs btn-ghost"
                style="color: var(--primary-color);"
              >
                Réinitialiser
              </button>
            </div>
            
            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--spacing-md);">
              <!-- Filtre par période -->
              <div class="form-group">
                <label class="form-label">Période</label>
                <select v-model="filters.periode" @change="applyPeriodeFilter" class="form-select form-input-sm">
                  <option value="">Toutes les dates</option>
                  <option value="today">Aujourd'hui</option>
                  <option value="week">Cette semaine</option>
                  <option value="month">Ce mois</option>
                  <option value="quarter">Ce trimestre</option>
                  <option value="year">Cette année</option>
                  <option value="custom">Personnalisé</option>
                </select>
              </div>

              <!-- Date début -->
              <div class="form-group">
                <label class="form-label">Date début</label>
                <input 
                  v-model="filters.dateDebut" 
                  type="date" 
                  class="form-input form-input-sm"
                  :disabled="filters.periode && filters.periode !== 'custom'"
                />
              </div>

              <!-- Date fin -->
              <div class="form-group">
                <label class="form-label">Date fin</label>
                <input 
                  v-model="filters.dateFin" 
                  type="date" 
                  class="form-input form-input-sm"
                  :disabled="filters.periode && filters.periode !== 'custom'"
                />
              </div>

              <!-- Filtre par journal -->
              <div class="form-group">
                <label class="form-label">Journal</label>
                <select v-model="filters.journalId" class="form-select form-input-sm">
                  <option value="">Tous les journaux</option>
                  <option v-for="journal in journals" :key="journal.Id_Journal" :value="journal.Id_Journal">
                    {{ journal.Code }} - {{ journal.Libelle }}
                  </option>
                </select>
              </div>

              <!-- Filtre par statut -->
              <div class="form-group">
                <label class="form-label">Statut</label>
                <select v-model="filters.statut" class="form-select form-input-sm">
                  <option value="">Tous</option>
                  <option value="valide">Validés</option>
                  <option value="non_valide">Non validés</option>
                  <option value="equilibre">Équilibrés</option>
                  <option value="non_equilibre">Non équilibrés</option>
                </select>
              </div>

              <!-- Recherche par numéro -->
              <div class="form-group">
                <label class="form-label">N° Pièce / Référence</label>
                <input 
                  v-model="filters.searchText" 
                  type="text" 
                  class="form-input form-input-sm"
                  placeholder="Rechercher..."
                />
              </div>
            </div>

            <!-- Résultats du filtre -->
            <div v-if="hasActiveFilters" style="margin-top: var(--spacing-md); padding-top: var(--spacing-md); border-top: 1px solid var(--gray-200);">
              <span class="text-sm" style="color: var(--gray-600);">
                📊 {{ mouvementsFiltres.length }} mouvement(s) trouvé(s) sur {{ mouvements.length }}
              </span>
            </div>
          </div>

          <!-- LOADER -->
          <div v-if="isLoading" style="text-align: center; padding: var(--spacing-2xl) 0;">
            <div class="spinner spinner-lg"></div>
            <p style="margin-top: var(--spacing-md); color: var(--gray-600);">Chargement...</p>
          </div>

          <!-- MESSAGES D'ERREUR -->
          <div v-if="errorMessage" class="alert alert-error">
            <span class="alert-icon">⚠️</span>
            <div class="alert-content">
              <p class="alert-message">{{ errorMessage }}</p>
            </div>
            <button @click="errorMessage = ''" class="alert-dismiss">&times;</button>
          </div>

          <!-- MESSAGES DE SUCCÈS -->
          <div v-if="successMessage" class="alert alert-success">
            <span class="alert-icon">✓</span>
            <div class="alert-content">
              <p class="alert-message">{{ successMessage }}</p>
            </div>
            <button @click="successMessage = ''" class="alert-dismiss">&times;</button>
          </div>

          <!-- STATISTIQUES RAPIDES -->
          <div v-if="!isLoading && mouvementsFiltres.length > 0" class="stats-grid" style="margin-top: var(--spacing-xl); display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--spacing-md);">
            <div class="stat-card">
              <div class="stat-label">Total Débits</div>
              <div class="stat-value" style="color: var(--success-color);">{{ formatMontant(getTotalGeneralDebit()) }}</div>
            </div>
            <div class="stat-card">
              <div class="stat-label">Total Crédits</div>
              <div class="stat-value" style="color: var(--primary-color);">{{ formatMontant(getTotalGeneralCredit()) }}</div>
            </div>
            <div class="stat-card">
              <div class="stat-label">Mouvements validés</div>
              <div class="stat-value">{{ mouvementsValides }} / {{ mouvementsFiltres.length }}</div>
            </div>
            <div class="stat-card">
              <div class="stat-label">Total Lignes</div>
              <div class="stat-value">{{ totalLignes }}</div>
            </div>
          </div>

          <!-- TABLEAU UNIQUE DES MOUVEMENTS ET LIGNES -->
          <div v-if="!isLoading && mouvementsFiltres.length > 0" class="table-container" style="margin-top: var(--spacing-xl);">
            <table class="table table-bordered table-striped w-100">
  <thead class="table-light">
    <tr>
      <th style="width: 80px;">N° Pièce</th>
      <th style="width: 200px; text-align: left;">Sous-compte</th>
      <th>Libellé</th>
      <th style="width: 100px;" class="text-end">Débit</th>
      <th style="width: 100px;" class="text-end">Crédit</th>
      <th style="width: 120px;">Référence</th>
      <th style="width: 100px;" class="text-center">Qté</th>
      <th style="width: 100px;">Mode Paiement</th>
      <th style="width: 30px;" class="text-center">Actions</th>
    </tr>
  </thead>
  <tbody>
    <!-- Regroupement par numéro de pièce -->
    <template v-for="m in mouvementsFiltres" :key="m.Id_Mouvement_ecriture">
      <!-- En-tête du mouvement -->
      <tr class="table-secondary fw-bold">
        <td colspan="9" class="p-3">
          <div class="d-flex align-items-center flex-wrap gap-2">
            <span style="text-align: center; margin-top: 7px;">{{ m.Numero_piece || `#${m.Id_Mouvement_ecriture}` }} - {{ formatDate(m.Date_mouvement) }} - {{ getJournalLibelle(m.Id_Journal) }}</span>
            <span v-if="isEquilibre(m)" class="badge bg-success">
              <i class="bi bi-check-circle me-1"> </i> Équilibré
            </span>
            <span v-else class="badge bg-danger">
              <i class="bi bi-exclamation-circle me-1"></i> Non équilibré ({{ formatMontant(getDifference(m)) }})
            </span>
            <button
              v-if="isEquilibre(m) && !m.valide"
              @click="validerMouvement(m.Id_Mouvement_ecriture)"
              :disabled="isValidating"
              class="btn btn-sm btn-success"
            >
              <i class="bi bi-check-circle me-1"></i> {{ isValidating ? 'Validation...' : 'Valider' }}
            </button>
            <span v-if="m.valide" class="badge bg-primary">
              <i class="bi bi-file-earmark-check me-1"></i> Validé
            </span>
            <button
              @click="deleteMouvement(m.Id_Mouvement_ecriture)"
              :disabled="m.valide || isDeletingMouvement"
              class="btn btn-sm btn-danger"
            >
              <i class="bi bi-trash"></i>
            </button>
          </div>
        </td>
      </tr>
      <!-- Lignes d'écriture -->
      <tr
        v-for="(ligne, index) in m.lignes"
        :key="ligne.Id_Ligne_ecriture || `new-${index}`"
        :class="{ 'table-warning': !ligne.Id_Ligne_ecriture }"
      >
        <td>
          <span class="fs-6">{{ m.Numero_piece || `#${m.Id_Mouvement_ecriture}` }}</span>
        </td>
        <!-- Sous-compte avec recherche dynamique -->
        <td>
          <div class="position-relative">
            <input
              v-model="ligne.sousCompteSearch"
              @input="searchSousCompte(m.Id_Mouvement_ecriture, index, $event.target.value)"
              @focus="onSousCompteFocus(m.Id_Mouvement_ecriture, index)"
              @blur="validateSousCompte(m.Id_Mouvement_ecriture, index)"
              @keydown.enter.prevent="selectFirstSuggestion(m.Id_Mouvement_ecriture, index)"
              @keydown.escape="closeSuggestions(m.Id_Mouvement_ecriture, index)"
              @keydown.arrow-down.prevent="navigateSuggestions(m.Id_Mouvement_ecriture, index, 'down')"
              @keydown.arrow-up.prevent="navigateSuggestions(m.Id_Mouvement_ecriture, index, 'up')"
              class="form-control form-control-sm"
              :class="{ 'is-invalid': ligne.sousCompteError, 'is-valid': ligne.Id_Sous_compte }"
              placeholder="Code ou libellé..."
            />
            <!-- Dropdown de suggestions -->
            <div
              v-if="ligne.showSuggestions && ligne.suggestions?.length"
              class="position-absolute w-100 bg-white border rounded shadow-lg"
              style="max-height: 160px; overflow-y: auto; z-index: 1000; top: 100%; margin-top: 2px;"
            >
              <div
                v-for="(suggestion, suggIndex) in ligne.suggestions"
                :key="suggestion.Id_Sous_compte"
                @mousedown="selectSousCompte(m.Id_Mouvement_ecriture, index, suggestion)"
                class="p-2 border-bottom"
                :class="{ 'bg-light': suggIndex === ligne.selectedSuggestionIndex }"
                style="cursor: pointer;"
                @mouseover="ligne.selectedSuggestionIndex = suggIndex"
              >
                <div class="fw-semibold small">{{ suggestion.Code_sous_compte }}</div>
                <div class="text-muted small">{{ suggestion.Libelle }}</div>
              </div>
            </div>
            <div v-if="ligne.sousCompteError" class="invalid-feedback">{{ ligne.sousCompteError }}</div>
          </div>
        </td>
        <!-- Libellé -->
        <td>
          <input
            v-model="ligne.Libelle"
            @blur="updateLigne(m.Id_Mouvement_ecriture, index)"
            class="form-control form-control-sm"
            placeholder="Libellé de l'opération..."
          />
        </td>
        <!-- Débit -->
        <td>
          <input
            v-model.number="ligne.Debit"
            @input="onMontantChange(m.Id_Mouvement_ecriture, index, 'debit')"
            @blur="updateLigne(m.Id_Mouvement_ecriture, index)"
            type="number"
            step="0.01"
            min="0"
            class="form-control form-control-sm text-end"
            placeholder="0.00"
          />
        </td>
        <!-- Crédit -->
        <td>
          <input
            v-model.number="ligne.Credit"
            @input="onMontantChange(m.Id_Mouvement_ecriture, index, 'credit')"
            @blur="updateLigne(m.Id_Mouvement_ecriture, index)"
            type="number"
            step="0.01"
            min="0"
            class="form-control form-control-sm text-end"
            placeholder="0.00"
          />
        </td>
        <!-- Référence -->
        <td>
          <input
            v-model="ligne.Reference"
            @blur="updateLigne(m.Id_Mouvement_ecriture, index)"
            class="form-control form-control-sm"
            placeholder="Réf..."
          />
        </td>
        <!-- Quantité -->
        <td>
          <input
            v-model.number="ligne.Quantite"
            @blur="updateLigne(m.Id_Mouvement_ecriture, index)"
            type="number"
            min="1"
            class="form-control form-control-sm text-center"
          />
        </td>
        <!-- Mode de paiement -->
        <td>
          <select
            v-model="ligne.Id_Mode_paiement"
            @change="updateLigne(m.Id_Mouvement_ecriture, index)"
            class="form-select form-control-sm"
          >
            <option value="">-</option>
            <option v-for="mode in modesPaiement" :key="mode.Id_Mode_paiement" :value="mode.Id_Mode_paiement">
              {{ mode.Libelle }}
            </option>
          </select>
        </td>
        <!-- Actions -->
        <td class="text-center">
          <button
            @click="deleteLigne(m.Id_Mouvement_ecriture, index)"
            :disabled="m.valide"
            class="btn btn-sm btn-outline-danger"
            title="Supprimer la ligne"
          >
            <i class="bi bi-trash"></i>
          </button>
        </td>
      </tr>
      <!-- Bouton pour ajouter une nouvelle ligne -->
      <tr v-if="!m.valide" class="table-light">
        <td>
          <span class="fs-6">{{ m.Numero_piece || `#${m.Id_Mouvement_ecriture}` }}</span>
        </td>
        <td colspan="7">
          <button
            @click="addNewLigne(m.Id_Mouvement_ecriture)"
            class="btn btn-outline-primary w-100"
          >
            <i class="bi bi-plus-circle me-1"></i> Ajouter une ligne d'écriture
          </button>
        </td>
        <td></td>
      </tr>
    </template>
  </tbody>
  <!-- Totaux globaux -->
  <tfoot class="table-secondary fw-bold">
    <tr>
      <td colspan="3" class="p-3">TOTAUX GÉNÉRAUX</td>
      <td
        class="text-end p-3"
        :class="{
          'text-danger': getTotalGeneralDebit() !== getTotalGeneralCredit(),
          'text-success': getTotalGeneralDebit() === getTotalGeneralCredit() && getTotalGeneralDebit() > 0
        }"
      >
        {{ formatMontant(getTotalGeneralDebit()) }}
      </td>
      <td
        class="text-end p-3"
        :class="{
          'text-danger': getTotalGeneralDebit() !== getTotalGeneralCredit(),
          'text-success': getTotalGeneralDebit() === getTotalGeneralCredit() && getTotalGeneralCredit() > 0
        }"
      >
        {{ formatMontant(getTotalGeneralCredit()) }}
      </td>
      <td colspan="4" class="p-3">
        <div class="d-flex align-items-center justify-content-between">
          <span
            v-if="getTotalGeneralDebit() !== getTotalGeneralCredit()"
            class="small text-danger"
          >
            Différence: {{ formatMontant(Math.abs(getTotalGeneralDebit() - getTotalGeneralCredit())) }}
          </span>
          <span
            v-else-if="getTotalGeneralDebit() > 0"
            class="small text-success"
          >
            <i class="bi bi-check-circle me-1"></i> Équilibré
          </span>
          <span v-else class="small text-muted">Aucune écriture</span>
          <span class="small text-muted">{{ totalLignes }} ligne(s)</span>
        </div>
      </td>
    </tr>
  </tfoot>
</table>
          </div>

          <!-- Message si aucun mouvement -->
          <div v-if="!isLoading && mouvementsFiltres.length === 0 && mouvements.length > 0" style="text-align: center; padding: var(--spacing-2xl) 0; color: var(--gray-500);">
            <div style="font-size: 4rem; margin-bottom: var(--spacing-md);">🔍</div>
            <h3 class="text-lg font-semibold" style="margin-bottom: var(--spacing-sm);">Aucun résultat</h3>
            <p>Aucun mouvement ne correspond aux critères de recherche.</p>
            <button @click="resetFilters" class="btn btn-primary" style="margin-top: var(--spacing-md);">
              Réinitialiser les filtres
            </button>
          </div>

          <div v-if="!isLoading && mouvements.length === 0" style="text-align: center; padding: var(--spacing-2xl) 0; color: var(--gray-500);">
            <div style="font-size: 4rem; margin-bottom: var(--spacing-md);">📊</div>
            <h3 class="text-lg font-semibold" style="margin-bottom: var(--spacing-sm);">Aucun mouvement d'écriture</h3>
            <p>Créez votre premier mouvement d'écriture en utilisant le formulaire ci-dessus.</p>
          </div>
          
          <AppFooter />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, nextTick, computed } from "vue";
import axios from "axios";
import { useRouter } from 'vue-router'
import Sidebar from "../../molecules/Sidebar.vue";
import Header from "../../molecules/Header.vue";
import AppFooter from "../../molecules/Footer.vue";

const router = useRouter();

const handleNavigation = (item) => {
  router.push(item.route);
};

// État de l'application - MODIFIÉ : pas de chargement depuis la base
const mouvements = ref([]); // Liste des mouvements de la session uniquement
const journals = ref([]);
const sousComptes = ref([]);
const modesPaiement = ref([]);

// Filtres
const filters = ref({
  periode: '',
  dateDebut: '',
  dateFin: '',
  journalId: '',
  statut: '',
  searchText: ''
});

// États de chargement
const isLoading = ref(false); // Plus de chargement initial
const isCreatingMouvement = ref(false);
const isValidating = ref(false);
const isDeletingMouvement = ref(false);

// Messages
const errorMessage = ref('');
const successMessage = ref('');

const mouvementForm = ref({
  Date_mouvement: "",
  Id_Journal: "",
});

const token = localStorage.getItem("token");

if (!token) {
  window.location.href = "/";
} else {
  axios.defaults.headers.common["Authorization"] = `Bearer ${token}`;
}

// Computed: Mouvements filtrés
const mouvementsFiltres = computed(() => {
  let filtered = [...mouvements.value];

  // Filtre par date
  if (filters.value.dateDebut) {
    const dateDebut = new Date(filters.value.dateDebut);
    filtered = filtered.filter(m => new Date(m.Date_mouvement) >= dateDebut);
  }

  if (filters.value.dateFin) {
    const dateFin = new Date(filters.value.dateFin);
    dateFin.setHours(23, 59, 59, 999);
    filtered = filtered.filter(m => new Date(m.Date_mouvement) <= dateFin);
  }

  // Filtre par journal
  if (filters.value.journalId) {
    filtered = filtered.filter(m => m.Id_Journal === filters.value.journalId);
  }

  // Filtre par statut
  if (filters.value.statut) {
    switch (filters.value.statut) {
      case 'valide':
        filtered = filtered.filter(m => m.valide);
        break;
      case 'non_valide':
        filtered = filtered.filter(m => !m.valide);
        break;
      case 'equilibre':
        filtered = filtered.filter(m => isEquilibre(m));
        break;
      case 'non_equilibre':
        filtered = filtered.filter(m => !isEquilibre(m));
        break;
    }
  }

  // Filtre par texte de recherche
  if (filters.value.searchText) {
    const searchLower = filters.value.searchText.toLowerCase();
    filtered = filtered.filter(m => {
      const numeroPiece = (m.Numero_piece || '').toLowerCase();
      const hasMatchInLines = m.lignes.some(l => 
        (l.Reference || '').toLowerCase().includes(searchLower) ||
        (l.Libelle || '').toLowerCase().includes(searchLower)
      );
      return numeroPiece.includes(searchLower) || hasMatchInLines;
    });
  }

  return filtered;
});

// Vérifier si des filtres sont actifs
const hasActiveFilters = computed(() => {
  return filters.value.periode !== '' ||
         filters.value.dateDebut !== '' ||
         filters.value.dateFin !== '' ||
         filters.value.journalId !== '' ||
         filters.value.statut !== '' ||
         filters.value.searchText !== '';
});

// Nombre de mouvements validés
const mouvementsValides = computed(() => {
  return mouvementsFiltres.value.filter(m => m.valide).length;
});

// Calcul du nombre total de lignes
const totalLignes = computed(() => {
  return mouvementsFiltres.value.reduce((total, m) => total + m.lignes.length, 0);
});

// Appliquer un filtre de période prédéfini
const applyPeriodeFilter = () => {
  const today = new Date();
  const periode = filters.value.periode;

  if (periode === 'custom') {
    return;
  }

  switch (periode) {
    case 'today':
      filters.value.dateDebut = today.toISOString().split('T')[0];
      filters.value.dateFin = today.toISOString().split('T')[0];
      break;
    
    case 'week':
      const startOfWeek = new Date(today);
      startOfWeek.setDate(today.getDate() - today.getDay() + 1);
      filters.value.dateDebut = startOfWeek.toISOString().split('T')[0];
      filters.value.dateFin = today.toISOString().split('T')[0];
      break;
    
    case 'month':
      const startOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);
      filters.value.dateDebut = startOfMonth.toISOString().split('T')[0];
      filters.value.dateFin = today.toISOString().split('T')[0];
      break;
    
    case 'quarter':
      const quarter = Math.floor(today.getMonth() / 3);
      const startOfQuarter = new Date(today.getFullYear(), quarter * 3, 1);
      filters.value.dateDebut = startOfQuarter.toISOString().split('T')[0];
      filters.value.dateFin = today.toISOString().split('T')[0];
      break;
    
    case 'year':
      const startOfYear = new Date(today.getFullYear(), 0, 1);
      filters.value.dateDebut = startOfYear.toISOString().split('T')[0];
      filters.value.dateFin = today.toISOString().split('T')[0];
      break;
    
    default:
      filters.value.dateDebut = '';
      filters.value.dateFin = '';
  }
};

// Réinitialiser les filtres
const resetFilters = () => {
  filters.value = {
    periode: '',
    dateDebut: '',
    dateFin: '',
    journalId: '',
    statut: '',
    searchText: ''
  };
};

// Gestion des erreurs
const handleError = (error, defaultMessage = 'Une erreur est survenue') => {
  console.error('Erreur API:', error);
  if (error.response?.data?.message) {
    errorMessage.value = error.response.data.message;
  } else if (error.response?.data?.error) {
    errorMessage.value = error.response.data.error;
  } else {
    errorMessage.value = defaultMessage;
  }
  setTimeout(() => {
    errorMessage.value = '';
  }, 5000);
};

const showSuccess = (message) => {
  successMessage.value = message;
  setTimeout(() => {
    successMessage.value = '';
  }, 3000);
};

// Cache pour les sous-comptes
const sousComptesCache = ref(new Map());

// MODIFIÉ : Charger options uniquement (pas les mouvements)
const fetchOptions = async () => {
  try {
    const [journalsRes, sousComptesRes, modesRes] = await Promise.all([
      axios.get("http://127.0.0.1:8000/api/journals").catch(() => ({ data: [] })),
      axios.get("http://127.0.0.1:8000/api/sous-comptes").catch(() => ({ data: [] })),
      axios.get("http://127.0.0.1:8000/api/mode-paiements").catch(() => ({ data: [] }))
    ]);
    
    journals.value = journalsRes.data || [];
    sousComptes.value = sousComptesRes.data || [];
    modesPaiement.value = modesRes.data || [];

    // Créer un cache pour recherche rapide
    sousComptes.value.forEach(compte => {
      sousComptesCache.value.set(compte.Id_Sous_compte, compte);
    });
  } catch (error) {
    console.error('Erreur lors du chargement des options:', error);
  }
};

// MODIFIÉ : Créer un mouvement et l'ajouter à la session
const createMouvement = async () => {
  isCreatingMouvement.value = true;
  errorMessage.value = '';
  successMessage.value = '';

  try {
    // Envoi du mouvement au backend
    const res = await axios.post('http://127.0.0.1:8000/api/mouvements', mouvementForm.value);

    // Ajout du mouvement retourné (avec Numero_piece généré) à la liste locale
    mouvements.value.push(res.data);

    showSuccess("Mouvement créé !");
  } catch (error) {
    handleError(error, "Erreur lors de la création du mouvement");
  } finally {
    isCreatingMouvement.value = false;
  }
};

// Initialisation - MODIFIÉ : charger uniquement les options
onMounted(async () => {
  isLoading.value = true;
  try {
    await fetchOptions();
  } catch (error) {
    handleError(error, 'Erreur lors de l\'initialisation');
  } finally {
    isLoading.value = false;
  }
  const today = new Date().toISOString().split('T')[0];
  mouvementForm.value.Date_mouvement = today;
});

// Supprimer un mouvement
const deleteMouvement = async (mouvementId) => {
  if (!confirm('Êtes-vous sûr de vouloir supprimer ce mouvement et toutes ses lignes ?')) {
    return;
  }
  
  isDeletingMouvement.value = true;
  
  try {
    await axios.delete(`http://127.0.0.1:8000/api/mouvements/${mouvementId}`);
    showSuccess('Mouvement supprimé avec succès');
    
    // Retirer de la liste de session
    const index = mouvements.value.findIndex(m => m.Id_Mouvement_ecriture === mouvementId);
    if (index !== -1) {
      mouvements.value.splice(index, 1);
    }
  } catch (error) {
    handleError(error, 'Erreur lors de la suppression du mouvement');
  } finally {
    isDeletingMouvement.value = false;
  }
};

// Ajouter une nouvelle ligne vide
const addNewLigne = (mouvementId) => {
  const mouvement = mouvements.value.find(m => m.Id_Mouvement_ecriture === mouvementId);
  if (!mouvement || mouvement.valide) return; // MODIFIÉ : bloquer si validé

  const nouvelleLigne = {
    Id_Ligne_ecriture: null,
    Libelle: "",
    Debit: 0,
    Credit: 0,
    Reference: "",
    Quantite: 1,
    Id_Mode_paiement: "",
    Id_Sous_compte: "",
    Id_Mouvement_ecriture: mouvementId,
    Id_Journal: mouvement.Id_Journal,
    sousCompteSearch: "",
    showSuggestions: false,
    suggestions: [],
    selectedSuggestionIndex: -1,
    sousCompteError: '',
    statut: 'non_valide' // NOUVEAU : statut par défaut
  };

  mouvement.lignes.push(nouvelleLigne);
  nextTick(() => {
    const inputs = document.querySelectorAll(`input[placeholder="Code ou libellé..."]`);
    const lastInput = inputs[inputs.length - 1];
    if (lastInput) lastInput.focus();
  });
};

// Recherche dynamique de sous-comptes
let searchTimeout = null;
const searchSousCompte = (mouvementId, ligneIndex, searchTerm) => {
  const mouvement = mouvements.value.find(m => m.Id_Mouvement_ecriture === mouvementId);
  if (!mouvement || !mouvement.lignes[ligneIndex] || mouvement.valide) return; // MODIFIÉ : bloquer si validé

  const ligne = mouvement.lignes[ligneIndex];
  ligne.sousCompteError = '';
  
  if (!searchTerm || searchTerm.length < 2) {
    ligne.showSuggestions = false;
    ligne.suggestions = [];
    ligne.selectedSuggestionIndex = -1;
    return;
  }

  if (searchTimeout) clearTimeout(searchTimeout);
  
  searchTimeout = setTimeout(() => {
    const searchLower = searchTerm.toLowerCase();
    const filtered = sousComptes.value.filter(compte =>
      compte.Code_sous_compte.toLowerCase().includes(searchLower) ||
      compte.Libelle.toLowerCase().includes(searchLower)
    ).slice(0, 10);

    ligne.suggestions = filtered;
    ligne.showSuggestions = filtered.length > 0;
    ligne.selectedSuggestionIndex = -1;
  }, 150);
};

// Focus sur sous-compte
const onSousCompteFocus = (mouvementId, ligneIndex) => {
  const mouvement = mouvements.value.find(m => m.Id_Mouvement_ecriture === mouvementId);
  if (!mouvement || !mouvement.lignes[ligneIndex] || mouvement.valide) return; // MODIFIÉ

  const ligne = mouvement.lignes[ligneIndex];
  if (ligne.sousCompteSearch && ligne.sousCompteSearch.length >= 2) {
    searchSousCompte(mouvementId, ligneIndex, ligne.sousCompteSearch);
  }
};

// Navigation au clavier dans les suggestions
const navigateSuggestions = (mouvementId, ligneIndex, direction) => {
  const mouvement = mouvements.value.find(m => m.Id_Mouvement_ecriture === mouvementId);
  if (!mouvement || !mouvement.lignes[ligneIndex] || !mouvement.lignes[ligneIndex].showSuggestions) return;

  const ligne = mouvement.lignes[ligneIndex];
  const maxIndex = ligne.suggestions.length - 1;
  
  if (direction === 'down') {
    ligne.selectedSuggestionIndex = ligne.selectedSuggestionIndex < maxIndex ? ligne.selectedSuggestionIndex + 1 : 0;
  } else {
    ligne.selectedSuggestionIndex = ligne.selectedSuggestionIndex > 0 ? ligne.selectedSuggestionIndex - 1 : maxIndex;
  }
};

// Sélectionner la première suggestion
const selectFirstSuggestion = (mouvementId, ligneIndex) => {
  const mouvement = mouvements.value.find(m => m.Id_Mouvement_ecriture === mouvementId);
  if (!mouvement || !mouvement.lignes[ligneIndex]) return;

  const ligne = mouvement.lignes[ligneIndex];
  if (ligne.showSuggestions && ligne.suggestions.length > 0) {
    const selectedIndex = ligne.selectedSuggestionIndex >= 0 ? ligne.selectedSuggestionIndex : 0;
    selectSousCompte(mouvementId, ligneIndex, ligne.suggestions[selectedIndex]);
  }
};

// Fermer les suggestions
const closeSuggestions = (mouvementId, ligneIndex) => {
  const mouvement = mouvements.value.find(m => m.Id_Mouvement_ecriture === mouvementId);
  if (!mouvement || !mouvement.lignes[ligneIndex]) return;

  const ligne = mouvement.lignes[ligneIndex];
  ligne.showSuggestions = false;
  ligne.selectedSuggestionIndex = -1;
};

// Sélectionner un sous-compte
const selectSousCompte = (mouvementId, ligneIndex, sousCompte) => {
  const mouvement = mouvements.value.find(m => m.Id_Mouvement_ecriture === mouvementId);
  if (!mouvement || !mouvement.lignes[ligneIndex] || mouvement.valide) return; // MODIFIÉ

  const ligne = mouvement.lignes[ligneIndex];
  ligne.Id_Sous_compte = sousCompte.Id_Sous_compte;
  ligne.sousCompteSearch = `${sousCompte.Code_sous_compte} - ${sousCompte.Libelle}`;
  ligne.showSuggestions = false;
  ligne.selectedSuggestionIndex = -1;
  ligne.sousCompteError = '';
  
  if (!ligne.Libelle || ligne.Libelle.trim() === '') {
    ligne.Libelle = sousCompte.Libelle;
  }

  updateLigne(mouvementId, ligneIndex);
};

// Valider le sous-compte saisi
const validateSousCompte = (mouvementId, ligneIndex) => {
  setTimeout(() => {
    const mouvement = mouvements.value.find(m => m.Id_Mouvement_ecriture === mouvementId);
    if (!mouvement || !mouvement.lignes[ligneIndex] || mouvement.valide) return; // MODIFIÉ

    const ligne = mouvement.lignes[ligneIndex];
    ligne.showSuggestions = false;
    ligne.selectedSuggestionIndex = -1;

    if (ligne.sousCompteSearch && !ligne.Id_Sous_compte) {
      const found = sousComptes.value.find(compte =>
        `${compte.Code_sous_compte} - ${compte.Libelle}` === ligne.sousCompteSearch ||
        compte.Code_sous_compte === ligne.sousCompteSearch.trim()
      );

      if (found) {
        ligne.Id_Sous_compte = found.Id_Sous_compte;
        ligne.sousCompteSearch = `${found.Code_sous_compte} - ${found.Libelle}`;
        ligne.sousCompteError = '';
        
        if (!ligne.Libelle || ligne.Libelle.trim() === '') {
          ligne.Libelle = found.Libelle;
        }
        
        updateLigne(mouvementId, ligneIndex);
      } else {
        ligne.sousCompteError = 'Sous-compte non trouvé';
        ligne.Id_Sous_compte = '';
      }
    }
  }, 150);
};

// Gérer les changements de montant
const onMontantChange = (mouvementId, ligneIndex, type) => {
  const mouvement = mouvements.value.find(m => m.Id_Mouvement_ecriture === mouvementId);
  if (!mouvement || !mouvement.lignes[ligneIndex] || mouvement.valide) return; // MODIFIÉ

  const ligne = mouvement.lignes[ligneIndex];
  
  if (ligne.Debit < 0) ligne.Debit = 0;
  if (ligne.Credit < 0) ligne.Credit = 0;
  
  if (type === 'debit' && ligne.Debit > 0) {
    ligne.Credit = 0;
  } else if (type === 'credit' && ligne.Credit > 0) {
    ligne.Debit = 0;
  }
};

// Queue pour les mises à jour
const updateQueue = ref(new Map());
let updateTimeout = null;

// Mettre à jour ou créer une ligne
const updateLigne = async (mouvementId, ligneIndex) => {
  const mouvement = mouvements.value.find(m => m.Id_Mouvement_ecriture === mouvementId);
  if (!mouvement || !mouvement.lignes[ligneIndex] || mouvement.valide) return; // MODIFIÉ : bloquer si validé

  const ligne = mouvement.lignes[ligneIndex];
  
  if (!ligne.Id_Sous_compte || (!ligne.Debit && !ligne.Credit)) {
    return;
  }

  const ligneData = {
    Libelle: ligne.Libelle || '',
    Debit: parseFloat(ligne.Debit) || 0,
    Credit: parseFloat(ligne.Credit) || 0,
    Reference: ligne.Reference || '',
    Quantite: parseInt(ligne.Quantite) || 1,
    Id_Mode_paiement: ligne.Id_Mode_paiement || null,
    Id_Sous_compte: ligne.Id_Sous_compte,
    Id_Mouvement_ecriture: mouvementId,
    Id_Journal: mouvement.Id_Journal,
    statut: 'non_valide' // NOUVEAU
  };

  const key = `${mouvementId}-${ligneIndex}`;
  updateQueue.value.set(key, { ligne, ligneData, mouvementId, ligneIndex });

  if (updateTimeout) clearTimeout(updateTimeout);
  
  updateTimeout = setTimeout(async () => {
    const updates = Array.from(updateQueue.value.values());
    updateQueue.value.clear();

    for (const { ligne, ligneData } of updates) {
      try {
        if (ligne.Id_Ligne_ecriture) {
          const res = await axios.put(`http://127.0.0.1:8000/api/lignes/${ligne.Id_Ligne_ecriture}`, ligneData);
          Object.assign(ligne, res.data);
        } else {
          const res = await axios.post("http://127.0.0.1:8000/api/lignes", ligneData);
          ligne.Id_Ligne_ecriture = res.data.Id_Ligne_ecriture || res.data.id;
          Object.assign(ligne, res.data);
        }
      } catch (error) {
        handleError(error, 'Erreur lors de la sauvegarde de la ligne');
      }
    }
  }, 500);
};

// Supprimer une ligne
const deleteLigne = async (mouvementId, ligneIndex) => {
  const mouvement = mouvements.value.find(m => m.Id_Mouvement_ecriture === mouvementId);
  if (!mouvement || !mouvement.lignes[ligneIndex] || mouvement.valide) return; // MODIFIÉ : bloquer si validé

  const ligne = mouvement.lignes[ligneIndex];

  if (!confirm('Supprimer cette ligne d\'écriture ?')) {
    return;
  }

  try {
    if (ligne.Id_Ligne_ecriture) {
      await axios.delete(`http://127.0.0.1:8000/api/lignes/${ligne.Id_Ligne_ecriture}`);
      showSuccess('Ligne supprimée avec succès');
    }
    
    mouvement.lignes.splice(ligneIndex, 1);
  } catch (error) {
    handleError(error, 'Erreur lors de la suppression de la ligne');
  }
};

// Calculer les totaux par mouvement
const getTotalDebit = (mouvement) => {
  return mouvement.lignes.reduce((total, ligne) => total + (parseFloat(ligne.Debit) || 0), 0);
};

const getTotalCredit = (mouvement) => {
  return mouvement.lignes.reduce((total, ligne) => total + (parseFloat(ligne.Credit) || 0), 0);
};

const getDifference = (mouvement) => {
  return Math.abs(getTotalDebit(mouvement) - getTotalCredit(mouvement));
};

const isEquilibre = (mouvement) => {
  const totalDebit = getTotalDebit(mouvement);
  const totalCredit = getTotalCredit(mouvement);
  return Math.abs(totalDebit - totalCredit) < 0.01 && totalDebit > 0;
};

// Calculer les totaux généraux
const getTotalGeneralDebit = () => {
  return mouvementsFiltres.value.reduce((total, m) => total + getTotalDebit(m), 0);
};

const getTotalGeneralCredit = () => {
  return mouvementsFiltres.value.reduce((total, m) => total + getTotalCredit(m), 0);
};

// NOUVEAU : Valider un mouvement et toutes ses lignes
const validerMouvement = async (mouvementId) => {
  if (isValidating.value) return;
  
  const mouvement = mouvements.value.find(m => m.Id_Mouvement_ecriture === mouvementId);
  if (!mouvement || !isEquilibre(mouvement)) {
    errorMessage.value = 'Le mouvement doit être équilibré pour être validé';
    return;
  }

  if (mouvement.lignes.length === 0) {
    errorMessage.value = 'Le mouvement doit contenir au moins une ligne';
    return;
  }

  if (!confirm('Valider ce mouvement ? Cette action empêchera toute modification ultérieure.')) {
    return;
  }

  isValidating.value = true;

  try {
    // Valider le mouvement
    await axios.put(`http://127.0.0.1:8000/api/mouvements/${mouvementId}`, { 
      valide: true,
      date_validation: new Date().toISOString(),
      valide_par: token // ou l'ID utilisateur si disponible
    });

    // Valider toutes les lignes
    const validationPromises = mouvement.lignes.map(ligne => {
      if (ligne.Id_Ligne_ecriture) {
        return axios.post(`http://127.0.0.1:8000/api/lignes/${ligne.Id_Ligne_ecriture}/valider`);
      }
    });

    await Promise.all(validationPromises.filter(Boolean));

    // Mettre à jour localement
    mouvement.valide = true;
    mouvement.date_validation = new Date().toISOString();
    mouvement.lignes.forEach(ligne => {
      ligne.statut = 'valide';
    });

    showSuccess('Mouvement validé avec succès - Aucune modification ne sera plus possible');
  } catch (error) {
    handleError(error, 'Erreur lors de la validation du mouvement');
  } finally {
    isValidating.value = false;
  }
};

// Utilitaires
const getJournalLibelle = (journalId) => {
  const journal = journals.value.find(j => j.Id_Journal === journalId);
  return journal ? `${journal.Code} - ${journal.Libelle}` : `Journal #${journalId}`;
};

const formatDate = (dateStr) => {
  if (!dateStr) return 'Date invalide';
  try {
    const date = new Date(dateStr);
    return date.toLocaleDateString('fr-FR', {
      weekday: 'short',
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    });
  } catch (error) {
    return dateStr;
  }
};

const formatMontant = (montant) => {
  if (montant === null || montant === undefined || isNaN(montant)) {
    return '0,00';
  }
  return new Intl.NumberFormat('fr-FR', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  }).format(montant);
};

// Raccourcis clavier globaux
onMounted(() => {
  const handleKeydown = (event) => {
    if (event.ctrlKey && event.key === 'n') {
      event.preventDefault();
      document.querySelector('input[type="date"]')?.focus();
    }
    if (event.key === 'Escape') {
      errorMessage.value = '';
      successMessage.value = '';
    }
  };
  document.addEventListener('keydown', handleKeydown);
  
  return () => {
    document.removeEventListener('keydown', handleKeydown);
    if (searchTimeout) clearTimeout(searchTimeout);
    if (updateTimeout) clearTimeout(updateTimeout);
  };
});
</script>

<style scoped>
/* Statistiques */
.stat-card {
  background: white;
  padding: var(--spacing-lg);
  border-radius: var(--radius-md);
  border: 1px solid var(--gray-200);
  box-shadow: var(--shadow-sm);
}

.stat-label {
  font-size: 0.875rem;
  color: var(--gray-600);
  margin-bottom: var(--spacing-xs);
}

.stat-value {
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--gray-900);
}

/* Animations */
@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

.animate-spin {
  animation: spin 1s linear infinite;
}

/* Focus states */
input:focus,
select:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

/* Hover states */
.hover\:bg-gray-50:hover {
  background-color: #f9fafb;
}

.hover\:bg-blue-50:hover {
  background-color: #eff6ff;
}

.hover\:bg-blue-700:hover {
  background-color: #1d4ed8;
}

.hover\:bg-green-700:hover {
  background-color: #15803d;
}

.hover\:bg-red-700:hover {
  background-color: #b91c1c;
}

/* Transitions */
button {
  transition: all 0.2s ease-in-out;
}

input, select {
  transition: border-color 0.2s ease-in-out, box-shadow 0.2s ease-in-out;
}

/* Disabled states */
.disabled\:opacity-50:disabled {
  opacity: 0.5;
}

.disabled\:cursor-not-allowed:disabled {
  cursor: not-allowed;
}

/* Scrollbar */
.overflow-x-auto {
  scrollbar-width: thin;
  scrollbar-color: #cbd5e1 #f1f5f9;
}

.overflow-x-auto::-webkit-scrollbar {
  height: 6px;
}

.overflow-x-auto::-webkit-scrollbar-track {
  background: #f1f5f9;
}

.overflow-x-auto::-webkit-scrollbar-thumb {
  background: #cbd5e1;
  border-radius: 3px;
}

.z-20 {
  z-index: 20;
}

.z-30 {
  z-index: 30;
}

/* Print styles */
@media print {
  .no-print {
    display: none !important;
  }
  
  .filters-section {
    display: none !important;
  }
  
  table {
    page-break-inside: auto;
  }
  
  tr {
    page-break-inside: avoid;
    page-break-after: auto;
  }
}

/* Responsive */
@media (max-width: 768px) {
  .grid-cols-2 {
    grid-template-columns: 1fr;
  }
  
  .px-6 {
    padding-left: 1rem;
    padding-right: 1rem;
  }
  
  .text-xs {
    font-size: 0.75rem;
  }
  
  th, td {
    padding: 0.25rem !important;
  }
  
  .stat-card {
    padding: var(--spacing-md);
  }
  
  .stat-value {
    font-size: 1.25rem;
  }
}

/* Layout */
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