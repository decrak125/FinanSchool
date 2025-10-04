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
            <h1 class="card-title text-3xl mb-4">Écriture Comptable</h1>
          </div>
          
          <!-- FORMULAIRE MOUVEMENT -->
          <form @submit.prevent="createMouvement" class="card-form">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
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
              class="btn btn-primary mt-4"
            >
              <i class="bi bi-plus-circle me-2"></i>
              {{ isCreatingMouvement ? 'Création...' : 'Créer Mouvement' }}
            </button>
          </form>

          <!-- LOADER -->
          <div v-if="isLoading" class="text-center py-8">
            <div class="spinner spinner-lg"></div>
            <p class="mt-2 text-gray-600">Chargement...</p>
          </div>

          <!-- MESSAGES D'ERREUR -->
          <div v-if="errorMessage" class="alert alert-error">
            <i class="bi bi-exclamation-triangle me-2"></i>
            <div class="alert-content">
              <p class="alert-message">{{ errorMessage }}</p>
            </div>
            <button @click="errorMessage = ''" class="alert-dismiss">&times;</button>
          </div>

          <!-- MESSAGES DE SUCCÈS -->
          <div v-if="successMessage" class="alert alert-success">
            <i class="bi bi-check-circle me-2"></i>
            <div class="alert-content">
              <p class="alert-message">{{ successMessage }}</p>
            </div>
            <button @click="successMessage = ''" class="alert-dismiss">&times;</button>
          </div>

          <!-- TABLEAU UNIQUE DES MOUVEMENTS ET LIGNES -->
          <div v-if="!isLoading && mouvements.length > 0" class="table-container mt-6">
            <table class="table table-bordered table-striped w-full">
              <thead>
                <tr>
                  <th class="w-20">N° Pièce</th>
                  <th class="text-left">Sous-compte</th>
                  <th>Libellé</th>
                  <th class="text-right w-24">Débit</th>
                  <th class="text-right w-24">Crédit</th>
                  <th class="w-28">Référence</th>
                  <th class="text-center w-20">Qté</th>
                  <th class="w-32">Mode Paiement</th>
                  <th class="text-center w-16" style="width: 20px;">Actions</th>
                </tr>
              </thead> 
              <tbody>
                <!-- Regroupement par numéro de pièce -->
                <template v-for="m in mouvements" :key="m.Id_Mouvement_ecriture">
                  <!-- En-tête du mouvement -->
                  <tr class="bg-gray-100 font-semibold">
                    <td colspan="9" class="p-3">
                      <div class="flex items-center flex-wrap gap-2">
                        <span>{{ m.Numero_piece || `#${m.Id_Mouvement_ecriture}` }} - {{ formatDate(m.Date_mouvement) }} - {{ getJournalLibelle(m.Id_Journal) }}</span>
                        
                        <span v-if="isEquilibre(m)" class="badge badge-success" style="margin-left: 10px; height: 28px;">
                          <i class="bi bi-check-circle me-1" style="margin-right: 5px;"></i> Équilibré
                        </span>
                        <span v-else class="badge badge-error" style="margin-left: 10px; height: 28px;">
                          <i class="bi bi-exclamation-triangle me-1" style="margin-right: 5px;"> </i> Non équilibré ({{ formatMontant(getDifference(m)) }})
                        </span>
                        
                        <button 
                          v-if="isEquilibre(m) && !isMouvementValide(m)" 
                          @click="validerMouvement(m.Id_Mouvement_ecriture)"
                          :disabled="isValidating"
                          class="btn btn-sm btn-success"
                          style="margin-left: 10px;"
                          >
                          <i class="bi bi-check-lg me-1"></i>
                          {{ isValidating ? 'Validation...' : 'Valider' }}
                        </button>
                        
                        <span v-if="isMouvementValide(m)" class="badge badge-primary">
                          <i class="bi bi-lock me-1"></i> Validé
                        </span>
                        
                        <button 
                          @click="deleteMouvement(m.Id_Mouvement_ecriture)"
                          :disabled="isMouvementValide(m) || isDeletingMouvement"
                          class="btn btn-sm btn-error"
                          style="margin-left: 10px;"
                        >
                          <i class="bi bi-trash"></i>
                        </button>
                      </div>
                    </td>
                  </tr>
                  
                  <!-- Lignes d'écriture -->
                  <tr v-for="(ligne, index) in m.lignes" 
                      :key="ligne.Id_Ligne_ecriture || `new-${index}`"
                      :class="!ligne.Id_Ligne_ecriture ? 'bg-warning-light' : ''">
                    <td>
                      <span class="text-sm" style="font-size: 10px;">{{ m.Numero_piece || `#${m.Id_Mouvement_ecriture}` }}</span>
                    </td>
                    
                    <!-- Sous-compte avec recherche dynamique -->
                    <td style="font-size: 12px;">
                      <div class="input-group relative text-left" >
                        <input
                          v-model="ligne.sousCompteSearch"
                          @input="searchSousCompte(m.Id_Mouvement_ecriture, index, $event.target.value)"
                          @focus="onSousCompteFocus(m.Id_Mouvement_ecriture, index)"
                          @blur="validateSousCompte(m.Id_Mouvement_ecriture, index)"
                          @keydown.enter.prevent="selectFirstSuggestion(m.Id_Mouvement_ecriture, index)"
                          @keydown.escape="closeSuggestions(m.Id_Mouvement_ecriture, index)"
                          @keydown.arrow-down.prevent="navigateSuggestions(m.Id_Mouvement_ecriture, index, 'down')"
                          @keydown.arrow-up.prevent="navigateSuggestions(m.Id_Mouvement_ecriture, index, 'up')"
                          class="form-input form-input-max"
                          :class="{ 'is-invalid': ligne.sousCompteError, 'is-valid': ligne.Id_Sous_compte }"
                          placeholder="Code ou libellé..."
                          style="padding-left: 10px; height: 20px; font-size: 12px; width: 68px;"
                        />
                        
                        <!-- Dropdown de suggestions -->
                        <div v-if="ligne.showSuggestions && ligne.suggestions?.length" 
                             class="absolute z-30 w-full bg-white border border-gray-300 rounded-md shadow-lg max-h-40 overflow-y-auto top-full mt-1 left-0" style="background-color: white;">
                          <div v-for="(suggestion, suggIndex) in ligne.suggestions" 
                               :key="suggestion.Id_Sous_compte"
                               @mousedown="selectSousCompte(m.Id_Mouvement_ecriture, index, suggestion)"
                               :class="{
                                 'bg-secondary-light': suggIndex === ligne.selectedSuggestionIndex
                               }"
                               class="p-2 cursor-pointer border-b border-gray-200 hover:bg-secondary-light"
                               @mouseover="ligne.selectedSuggestionIndex = suggIndex">
                            <div class="font-semibold text-xs">{{ suggestion.Code_sous_compte }}</div>
                            <div class="text-xs text-gray-600">{{ suggestion.Libelle }}</div>
                          </div>
                        </div>
                        
                        <div v-if="ligne.sousCompteError" class="form-error">{{ ligne.sousCompteError }}</div>
                      </div>
                    </td>
                    
                    <!-- Libellé -->
                    <td>
                      <input 
                        v-model="ligne.Libelle"
                        @blur="updateLigne(m.Id_Mouvement_ecriture, index)"
                        class="form-input form-input-sm"
                        placeholder="Libellé de l'opération..."
                        style="width: 150px; font-size: 12px;"
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
                        class="form-input form-input-sm text-right"
                        placeholder="0,00"
                        style="width: 120px; font-size: 12px;"
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
                        class="form-input form-input-sm text-right"
                        placeholder="0,00"
                        style="width: 120px; font-size: 12px;"
                      />
                    </td>
                    
                    <!-- Référence -->
                    <td>
                      <input 
                        v-model="ligne.Reference"
                        @blur="updateLigne(m.Id_Mouvement_ecriture, index)"
                        class="form-input form-input-sm"
                        placeholder="Réf..."
                        style="font-size: 12px;"
                      />
                    </td>
                    
                    <!-- Quantité -->
                    <td>
                      <input 
                        v-model.number="ligne.Quantite"
                        @blur="updateLigne(m.Id_Mouvement_ecriture, index)"
                        type="number"
                        min="1"
                        style="width: 40px; font-size: 12px;"
                        class="form-input form-input-sm text-center"
                      />
                    </td>
                    
                    <!-- Mode de paiement -->
                    <td>
                      <select 
                        v-model="ligne.Id_Mode_paiement"
                        @change="updateLigne(m.Id_Mouvement_ecriture, index)"
                        class="form-select form-input-sm"
                        style="width: 50px; font-size: 12px;"
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
                        :disabled="isMouvementValide(m)"
                        class="btn btn-xs btn-ghost text-error"
                        title="Supprimer la ligne"
                        style="width: 20px;"
                      >
                        <i class="bi bi-trash"></i>
                      </button>
                    </td>
                  </tr>
                  
                  <!-- Bouton pour ajouter une nouvelle ligne -->
                  <tr v-if="!isMouvementValide(m)" class="bg-secondary-light">
                    <td>
                      <span class="text-sm" style="font-size: 10px;">{{ m.Numero_piece || `#${m.Id_Mouvement_ecriture}` }}</span>
                    </td>
                    <td colspan="7">
                      <button 
                        @click="addNewLigne(m.Id_Mouvement_ecriture)"
                        class="btn btn-ghost w-full text-primary font-semibold"
                      >
                        <i class="bi bi-plus-circle me-2"></i>Ajouter une ligne d'écriture
                      </button>
                    </td>
                    <td></td>
                  </tr>
                </template>
              </tbody>
              
              <!-- Totaux globaux -->
              <tfoot>
                <tr class="bg-gray-100 font-bold">
                  <td colspan="3" class="p-3">TOTAUX GÉNÉRAUX</td>
                  <td class="text-right p-3" 
                      :class="{
                        'text-error': getTotalGeneralDebit() !== getTotalGeneralCredit(),
                        'text-success': getTotalGeneralDebit() === getTotalGeneralCredit() && getTotalGeneralDebit() > 0
                      }">
                    {{ formatMontant(getTotalGeneralDebit()) }}
                  </td>
                  <td class="text-right p-3"
                      :class="{
                        'text-error': getTotalGeneralDebit() !== getTotalGeneralCredit(),
                        'text-success': getTotalGeneralDebit() === getTotalGeneralCredit() && getTotalGeneralCredit() > 0
                      }">
                    {{ formatMontant(getTotalGeneralCredit()) }}
                  </td>
                  <td colspan="4" class="p-3">
                    <div class="flex items-center justify-between">
                      <span v-if="getTotalGeneralDebit() !== getTotalGeneralCredit()" class="text-xs text-error">
                        Différence: {{ formatMontant(Math.abs(getTotalGeneralDebit() - getTotalGeneralCredit())) }}
                      </span>
                      <span v-else-if="getTotalGeneralDebit() > 0" class="text-xs text-success">
                        <i class="bi bi-check-circle me-1" style="margin-right: 5px;"></i>Équilibré
                      </span>
                      <span v-else class="text-xs text-gray-500">Aucune écriture</span>
                      <span class="text-xs text-gray-500">{{ totalLignes }} ligne(s)</span>
                    </div>
                  </td>
                </tr>
              </tfoot>
            </table>
          </div>

          <!-- Message si aucun mouvement -->
          <div v-if="!isLoading && mouvements.length === 0" class="text-center py-8 text-gray-500">
            <i class="bi bi-journal-text display-4 mb-4"></i>
            <h3 class="text-lg font-semibold mb-2">Aucun mouvement d'écriture</h3>
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
import App from "@/App.vue";
import { useRouter } from 'vue-router'
import Sidebar from "../../molecules/Sidebar.vue";
import Header from "../../molecules/Header.vue";
import AppFooter from "../../molecules/Footer.vue";

const router = useRouter();

// Ajouter cette méthode pour gérer la navigation
const handleNavigation = (item) => {
  router.push(item.route);
};

// État de l'application
const mouvements = ref([]);
const journals = ref([]);
const sousComptes = ref([]);
const modesPaiement = ref([]);

// États de chargement
const isLoading = ref(true);
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

const token = localStorage.getItem("token"); // Récupérer le token

if (!token) {
  // Redirection vers login si pas de token
  window.location.href = "/";
} else {
  // Configurer Axios pour inclure le token dans toutes les requêtes
  axios.defaults.headers.common["Authorization"] = `Bearer ${token}`;
}

// Calcul du nombre total de lignes
const totalLignes = computed(() => {
  return mouvements.value.reduce((total, m) => total + m.lignes.length, 0);
});

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

// Charger tous les mouvements avec leurs lignes
const fetchMouvements = async () => {
  try {
    const res = await axios.get("http://127.0.0.1:8000/api/mouvements");
    const mouvementsData = res.data;

    for (let m of mouvementsData) {
      try {
        const lignesRes = await axios.get(`http://127.0.0.1:8000/api/lignes?mouvement_id=${m.Id_Mouvement_ecriture}`);
        m.lignes = (lignesRes.data || [])
          .filter(l => l.Id_Mouvement_ecriture === m.Id_Mouvement_ecriture)
          .map(ligne => ({
            ...ligne,
            sousCompteSearch: ligne.sous_compte ? `${ligne.sous_compte.Code_sous_compte} - ${ligne.sous_compte.Libelle}` : '',
            showSuggestions: false,
            suggestions: [],
            selectedSuggestionIndex: -1,
            sousCompteError: ''
          }));
      } catch (error) {
        console.error(`Erreur lors du chargement des lignes pour le mouvement ${m.Id_Mouvement_ecriture}:`, error);
        m.lignes = [];
      }
    }
    
    mouvements.value = mouvementsData
      .filter(m => !isMouvementValide(m)) // Filtrer pour n'afficher que les mouvements non validés (non clos)
      .sort((a, b) => new Date(b.Date_mouvement) - new Date(a.Date_mouvement));
  } catch (error) {
    handleError(error, 'Erreur lors du chargement des mouvements');
  }
};

// Charger options
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
  } catch (error) {
    console.error('Erreur lors du chargement des options:', error);
  }
};

// Créer un mouvement
const createMouvement = async () => {
  if (isCreatingMouvement.value) return;
  
  isCreatingMouvement.value = true;
  errorMessage.value = '';
  
  try {
    await axios.post("http://127.0.0.1:8000/api/mouvements", mouvementForm.value);
    mouvementForm.value.Date_mouvement = "";
    mouvementForm.value.Id_Journal = "";
    showSuccess('Mouvement créé avec succès');
    await fetchMouvements();
  } catch (error) {
    handleError(error, 'Erreur lors de la création du mouvement');
  } finally {
    isCreatingMouvement.value = false;
  }
};

// Supprimer un mouvement
const deleteMouvement = async (mouvementId) => {
  if (!confirm('Êtes-vous sûr de vouloir supprimer ce mouvement et toutes ses lignes ?')) {
    return;
  }
  
  isDeletingMouvement.value = true;
  
  try {
    await axios.delete(`http://127.0.0.1:8000/api/mouvements/${mouvementId}`);
    showSuccess('Mouvement supprimé avec succès');
    await fetchMouvements();
  } catch (error) {
    handleError(error, 'Erreur lors de la suppression du mouvement');
  } finally {
    isDeletingMouvement.value = false;
  }
};

// Ajouter une nouvelle ligne vide
const addNewLigne = (mouvementId) => {
  const mouvement = mouvements.value.find(m => m.Id_Mouvement_ecriture === mouvementId);
  if (!mouvement) return;

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
    sousCompteError: ''
  };

  mouvement.lignes.push(nouvelleLigne);
  nextTick(() => {
    const inputs = document.querySelectorAll(`input[placeholder="Code ou libellé..."]`);
    const lastInput = inputs[inputs.length - 1];
    if (lastInput) lastInput.focus();
  });
};

// Recherche dynamique de sous-comptes
const searchSousCompte = (mouvementId, ligneIndex, searchTerm) => {
  const mouvement = mouvements.value.find(m => m.Id_Mouvement_ecriture === mouvementId);
  if (!mouvement || !mouvement.lignes[ligneIndex]) return;

  const ligne = mouvement.lignes[ligneIndex];
  ligne.sousCompteError = '';
  
  if (!searchTerm || searchTerm.length < 2) {
    ligne.showSuggestions = false;
    ligne.suggestions = [];
    ligne.selectedSuggestionIndex = -1;
    return;
  }

  const filtered = sousComptes.value.filter(compte =>
    compte.Code_sous_compte.toLowerCase().includes(searchTerm.toLowerCase()) ||
    compte.Libelle.toLowerCase().includes(searchTerm.toLowerCase())
  ).slice(0, 10);

  ligne.suggestions = filtered;
  ligne.showSuggestions = filtered.length > 0;
  ligne.selectedSuggestionIndex = -1;
};

// Focus sur sous-compte
const onSousCompteFocus = (mouvementId, ligneIndex) => {
  const mouvement = mouvements.value.find(m => m.Id_Mouvement_ecriture === mouvementId);
  if (!mouvement || !mouvement.lignes[ligneIndex]) return;

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
  if (!mouvement || !mouvement.lignes[ligneIndex]) return;

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
    if (!mouvement || !mouvement.lignes[ligneIndex]) return;

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
  if (!mouvement || !mouvement.lignes[ligneIndex]) return;

  const ligne = mouvement.lignes[ligneIndex];
  
  if (ligne.Debit < 0) ligne.Debit = 0;
  if (ligne.Credit < 0) ligne.Credit = 0;
  
  if (type === 'debit' && ligne.Debit > 0) {
    ligne.Credit = 0;
  } else if (type === 'credit' && ligne.Credit > 0) {
    ligne.Debit = 0;
  }
};

// Mettre à jour ou créer une ligne
const updateLigne = async (mouvementId, ligneIndex) => {
  const mouvement = mouvements.value.find(m => m.Id_Mouvement_ecriture === mouvementId);
  if (!mouvement || !mouvement.lignes[ligneIndex]) return;

  const ligne = mouvement.lignes[ligneIndex];
  
  if (!ligne.Id_Sous_compte || (!ligne.Debit && !ligne.Credit)) {
    return;
  }

  try {
    const ligneData = {
      Libelle: ligne.Libelle || '',
      Debit: parseFloat(ligne.Debit) || 0,
      Credit: parseFloat(ligne.Credit) || 0,
      Reference: ligne.Reference || '',
      Quantite: parseInt(ligne.Quantite) || 1,
      Id_Mode_paiement: ligne.Id_Mode_paiement || null,
      Id_Sous_compte: ligne.Id_Sous_compte,
      Id_Mouvement_ecriture: mouvementId,
      Id_Journal: mouvement.Id_Journal
    };

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
};

// Supprimer une ligne
const deleteLigne = async (mouvementId, ligneIndex) => {
  const mouvement = mouvements.value.find(m => m.Id_Mouvement_ecriture === mouvementId);
  if (!mouvement || !mouvement.lignes[ligneIndex]) return;

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
  return mouvements.value.reduce((total, m) => total + getTotalDebit(m), 0);
};

const getTotalGeneralCredit = () => {
  return mouvements.value.reduce((total, m) => total + getTotalCredit(m), 0);
};

// Vérifier si un mouvement est validé (toutes les lignes ont statut 'valide')
const isMouvementValide = (mouvement) => {
  return mouvement.lignes.length > 0 && mouvement.lignes.every(ligne => ligne.statut === 'valide');
};

// Valider un mouvement
const validerMouvement = async (mouvementId) => {
  if (isValidating.value) return;
  
  const mouvement = mouvements.value.find(m => m.Id_Mouvement_ecriture === mouvementId);
  if (!mouvement || !isEquilibre(mouvement)) {
    errorMessage.value = 'Le mouvement doit être équilibré pour être validé';
    return;
  }

  if (isMouvementValide(mouvement)) {
    errorMessage.value = 'Le mouvement est déjà validé';
    return;
  }

  if (!confirm('Valider ce mouvement ? Cette action sera définitive.')) {
    return;
  }

  isValidating.value = true;

  try {
    // Valider le mouvement et toutes ses lignes via le nouvel endpoint
    await axios.post(`http://127.0.0.1:8000/api/mouvements/${mouvementId}/valider`);

    showSuccess('Mouvement validé avec succès');
    await fetchMouvements(); // Recharge les mouvements, en excluant les validés
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

// Initialisation
onMounted(async () => {
  isLoading.value = true;
  try {
    await fetchOptions();
    await fetchMouvements();
  } catch (error) {
    handleError(error, 'Erreur lors de l\'initialisation');
  } finally {
    isLoading.value = false;
  }
  const today = new Date().toISOString().split('T')[0];
  mouvementForm.value.Date_mouvement = today;
});

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
  };
});
</script>

<style scoped>
@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

.animate-spin {
  animation: spin 1s linear infinite;
}

input:focus,
select:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

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

button {
  transition: all 0.2s ease-in-out;
}

input, select {
  transition: border-color 0.2s ease-in-out, box-shadow 0.2s ease-in-out;
}

.disabled\:opacity-50:disabled {
  opacity: 0.5;
}

.disabled\:cursor-not-allowed:disabled {
  cursor: not-allowed;
}

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

@media print {
  .no-print {
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
}
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