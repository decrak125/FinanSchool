<template>
  <div class="dashboard-container">
    <!-- Header -->
    <Header />

    <!-- Sidebar -->
    <Sidebar :current-route="$route.path" @navigation-change="handleNavigation" />


    <div class="main-content">
    <div class="p-6">
    <h1 class="text-2xl font-bold mb-4">Écriture Comptable</h1>

    <!-- FORMULAIRE MOUVEMENT -->
    <form @submit.prevent="createMouvement" class="card-form">
      <div class="input-group">
        <div>
          <label class="block font-semibold">Date du Mouvement</label>
          <input 
            v-model="mouvementForm.Date_mouvement" 
            type="date" 
            class="form-input" 
            required 
          />
        </div>
        <div>
          <label class="block font-semibold">Journal</label>
          <select v-model="mouvementForm.Id_Journal" class="form-input" required>
            <option value="">-- Sélectionner --</option>
            <option v-for="journal in journals" :key="journal.Id_Journal" :value="journal.Id_Journal">
              {{ journal.Code }} - {{ journal.Libelle }}
            </option>
          </select>
        </div>
      </div>
      <Button 
        type="submit" 
        :disabled="isCreatingMouvement"
        class="btn btn-primary"
      >
        {{ isCreatingMouvement ? 'Création...' : 'Créer Mouvement' }}
      </Button>
    </form>

    <!-- LOADER -->
    <div v-if="isLoading" class="text-center py-8">
      <div class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
      <p class="mt-2 text-gray-600">Chargement...</p>
    </div>

    <!-- MESSAGES D'ERREUR -->
    <div v-if="errorMessage" class="mb-4 bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded">
      {{ errorMessage }}
      <button @click="errorMessage = ''" class="float-right font-bold">&times;</button>
    </div>

    <!-- MESSAGES DE SUCCÈS -->
    <div v-if="successMessage" class="mb-4 bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded">
      {{ successMessage }}
      <button @click="successMessage = ''" class="float-right font-bold">&times;</button>
    </div>

    <!-- TABLEAU UNIQUE DES MOUVEMENTS ET LIGNES -->
    <div v-if="!isLoading && mouvements.length > 0" class="overflow-x-auto">
      <table class="w-full border-collapse border border-gray-300">
        <thead>
          <tr class="bg-gray-200">
            <th class="border border-gray-300 px-3 py-2 text-left w-20">N° Pièce</th>
            <th class="border border-gray-300 px-3 py-2 text-left w-48">Sous-compte</th>
            <th class="border border-gray-300 px-3 py-2 text-left">Libellé</th>
            <th class="border border-gray-300 px-3 py-2 text-right w-24">Débit</th>
            <th class="border border-gray-300 px-3 py-2 text-right w-24">Crédit</th>
            <th class="border border-gray-300 px-3 py-2 text-left w-32">Référence</th>
            <th class="border border-gray-300 px-3 py-2 text-center w-20">Qté</th>
            <th class="border border-gray-300 px-3 py-2 text-left w-32">Mode Paiement</th>
            <th class="border border-gray-300 px-3 py-2 text-center w-20">Actions</th>
          </tr>
        </thead>
        <tbody>
          <!-- Regroupement par numéro de pièce -->
          <template v-for="m in mouvements" :key="m.Id_Mouvement_ecriture">
            <!-- En-tête du mouvement -->
            <tr class="bg-gray-100 font-semibold">
              <td class="border border-gray-300 px-2 py-1" colspan="9">
                {{ m.Numero_piece || `#${m.Id_Mouvement_ecriture}` }} - {{ formatDate(m.Date_mouvement) }} - {{ getJournalLibelle(m.Id_Journal) }}
                <span v-if="isEquilibre(m)" class="ml-2 bg-green-100 text-green-700 px-2 py-1 rounded text-sm">
                  ✓ Équilibré
                </span>
                <span v-else class="ml-2 bg-red-100 text-red-700 px-2 py-1 rounded text-sm">
                  ⚠️ Non équilibré ({{ formatMontant(getDifference(m)) }})
                </span>
                <button 
                  v-if="isEquilibre(m) && !m.valide" 
                  @click="validerMouvement(m.Id_Mouvement_ecriture)"
                  :disabled="isValidating"
                  class="ml-2 bg-green-600 text-white px-2 py-1 rounded text-sm hover:bg-green-700 disabled:opacity-50"
                >
                  {{ isValidating ? 'Validation...' : 'Valider' }}
                </button>
                <span v-if="m.valide" class="ml-2 bg-blue-100 text-blue-700 px-2 py-1 rounded text-sm">
                  📋 Validé
                </span>
                <button 
                  @click="deleteMouvement(m.Id_Mouvement_ecriture)"
                  :disabled="m.valide || isDeletingMouvement"
                  class="ml-2 bg-red-600 text-white px-2 py-1 rounded text-sm hover:bg-red-700 disabled:opacity-50"
                >
                  🗑️
                </button>
              </td>
            </tr>
            <!-- Lignes d'écriture -->
            <tr v-for="(ligne, index) in m.lignes" :key="ligne.Id_Ligne_ecriture || `new-${index}`" 
                class="hover:bg-gray-50" :class="{'bg-yellow-50': !ligne.Id_Ligne_ecriture}">
              <td class="border border-gray-300 px-2 py-1 text-sm">
                {{ m.Numero_piece || `#${m.Id_Mouvement_ecriture}` }}
              </td>
              <!-- Sous-compte avec recherche dynamique -->
              <td class="border border-gray-300 px-2 py-1">
                <div class="relative">
                  <input 
                    v-model="ligne.sousCompteSearch"
                    @input="searchSousCompte(m.Id_Mouvement_ecriture, index, $event.target.value)"
                    @focus="onSousCompteFocus(m.Id_Mouvement_ecriture, index)"
                    @blur="validateSousCompte(m.Id_Mouvement_ecriture, index)"
                    @keydown.enter="selectFirstSuggestion(m.Id_Mouvement_ecriture, index)"
                    @keydown.escape="closeSuggestions(m.Id_Mouvement_ecriture, index)"
                    @keydown.arrow-down="navigateSuggestions(m.Id_Mouvement_ecriture, index, 'down')"
                    @keydown.arrow-up="navigateSuggestions(m.Id_Mouvement_ecriture, index, 'up')"
                    class="w-full px-2 py-1 border rounded text-xs focus:border-blue-500"
                    placeholder="Code ou libellé..."
                    :class="{'border-red-500': ligne.sousCompteError, 'border-green-500': ligne.Id_Sous_compte}"
                  />
                  <!-- Dropdown de suggestions -->
                  <div v-if="ligne.showSuggestions && ligne.suggestions?.length" 
                       class="absolute z-20 w-full bg-white border border-gray-300 rounded-b shadow-lg max-h-40 overflow-y-auto">
                    <div v-for="(suggestion, suggIndex) in ligne.suggestions" 
                         :key="suggestion.Id_Sous_compte"
                         @mousedown="selectSousCompte(m.Id_Mouvement_ecriture, index, suggestion)"
                         class="px-3 py-2 hover:bg-blue-50 cursor-pointer text-xs border-b last:border-b-0"
                         :class="{'bg-blue-100': suggIndex === ligne.selectedSuggestionIndex}">
                      <div class="font-semibold">{{ suggestion.Code_sous_compte }}</div>
                      <div class="text-gray-600">{{ suggestion.Libelle }}</div>
                    </div>
                  </div>
                  <div v-if="ligne.sousCompteError" class="text-red-500 text-xs mt-1">{{ ligne.sousCompteError }}</div>
                </div>
              </td>
              <!-- Libellé -->
              <td class="border border-gray-300 px-2 py-1">
                <input 
                  v-model="ligne.Libelle"
                  @blur="updateLigne(m.Id_Mouvement_ecriture, index)"
                  class="w-full px-2 py-1 border rounded text-xs focus:border-blue-500"
                  placeholder="Libellé de l'opération..."
                />
              </td>
              <!-- Débit -->
              <td class="border border-gray-300 px-2 py-1">
                <input 
                  v-model.number="ligne.Debit"
                  @input="onMontantChange(m.Id_Mouvement_ecriture, index, 'debit')"
                  @blur="updateLigne(m.Id_Mouvement_ecriture, index)"
                  type="number" 
                  step="0.01"
                  min="0"
                  class="w-full px-2 py-1 border rounded text-xs text-right focus:border-blue-500"
                  placeholder="0,00"
                />
              </td>
              <!-- Crédit -->
              <td class="border border-gray-300 px-2 py-1">
                <input 
                  v-model.number="ligne.Credit"
                  @input="onMontantChange(m.Id_Mouvement_ecriture, index, 'credit')"
                  @blur="updateLigne(m.Id_Mouvement_ecriture, index)"
                  type="number" 
                  step="0.01"
                  min="0"
                  class="w-full px-2 py-1 border rounded text-xs text-right focus:border-blue-500"
                  placeholder="0,00"
                />
              </td>
              <!-- Référence -->
              <td class="border border-gray-300 px-2 py-1">
                <input 
                  v-model="ligne.Reference"
                  @blur="updateLigne(m.Id_Mouvement_ecriture, index)"
                  class="w-full px-2 py-1 border rounded text-xs focus:border-blue-500"
                  placeholder="Réf..."
                />
              </td>
              <!-- Quantité -->
              <td class="border border-gray-300 px-2 py-1">
                <input 
                  v-model.number="ligne.Quantite"
                  @blur="updateLigne(m.Id_Mouvement_ecriture, index)"
                  type="number"
                  min="1"
                  class="w-full px-2 py-1 border rounded text-xs text-center focus:border-blue-500"
                />
              </td>
              <!-- Mode de paiement -->
              <td class="border border-gray-300 px-2 py-1">
                <select 
                  v-model="ligne.Id_Mode_paiement"
                  @change="updateLigne(m.Id_Mouvement_ecriture, index)"
                  class="w-full px-2 py-1 border rounded text-xs focus:border-blue-500"
                >
                  <option value="">-</option>
                  <option v-for="mode in modesPaiement" :key="mode.Id_Mode_paiement" :value="mode.Id_Mode_paiement">
                    {{ mode.Libelle }}
                  </option>
                </select>
              </td>
              <!-- Actions -->
              <td class="border border-gray-300 px-2 py-1 text-center">
                <button 
                  @click="deleteLigne(m.Id_Mouvement_ecriture, index)"
                  :disabled="m.valide"
                  class="text-red-600 hover:text-red-800 text-sm disabled:opacity-50 disabled:cursor-not-allowed"
                  title="Supprimer la ligne"
                >
                  🗑️
                </button>
              </td>
            </tr>
            <!-- Bouton pour ajouter une nouvelle ligne -->
            <tr v-if="!m.valide" class="bg-blue-50">
              <td class="border border-gray-300 px-2 py-1 text-sm">{{ m.Numero_piece || `#${m.Id_Mouvement_ecriture}` }}</td>
              <td class="border border-gray-300 px-2 py-1" colspan="7">
                <button 
                  @click="addNewLigne(m.Id_Mouvement_ecriture)"
                  class="w-full py-2 text-blue-600 hover:text-blue-800 font-semibold text-sm"
                >
                  + Ajouter une ligne d'écriture
                </button>
              </td>
              <td class="border border-gray-300 px-2 py-1"></td>
            </tr>
          </template>
        </tbody>
        <!-- Totaux globaux -->
        <tfoot>
          <tr class="bg-gray-100 font-bold text-sm">
            <td class="border border-gray-300 px-2 py-1" colspan="3">TOTAUX GÉNÉRAUX</td>
            <td class="border border-gray-300 px-2 py-1 text-right" 
                :class="{'text-red-600': getTotalGeneralDebit() !== getTotalGeneralCredit(), 'text-green-600': getTotalGeneralDebit() === getTotalGeneralCredit() && getTotalGeneralDebit() > 0}">
              {{ formatMontant(getTotalGeneralDebit()) }}
            </td>
            <td class="border border-gray-300 px-2 py-1 text-right" 
                :class="{'text-red-600': getTotalGeneralDebit() !== getTotalGeneralCredit(), 'text-green-600': getTotalGeneralDebit() === getTotalGeneralCredit() && getTotalGeneralCredit() > 0}">
              {{ formatMontant(getTotalGeneralCredit()) }}
            </td>
            <td class="border border-gray-300 px-2 py-1" colspan="4">
              <div class="flex items-center justify-between">
                <span v-if="getTotalGeneralDebit() !== getTotalGeneralCredit()" class="text-red-600 text-xs">
                  Différence: {{ formatMontant(Math.abs(getTotalGeneralDebit() - getTotalGeneralCredit())) }}
                </span>
                <span v-else-if="getTotalGeneralDebit() > 0" class="text-green-600 text-xs">✓ Équilibré</span>
                <span v-else class="text-gray-500 text-xs">Aucune écriture</span>
                <span class="text-gray-500 text-xs">{{ totalLignes }} ligne(s)</span>
              </div>
            </td>
          </tr>
        </tfoot>
      </table>
    </div>

    <!-- Message si aucun mouvement -->
    <div v-if="!isLoading && mouvements.length === 0" class="text-center py-12 text-gray-500">
      <div class="text-6xl mb-4">📊</div>
      <h3 class="text-lg font-semibold mb-2">Aucun mouvement d'écriture</h3>
      <p>Créez votre premier mouvement d'écriture en utilisant le formulaire ci-dessus.</p>
    </div>
  <AppFooter />
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
    
    mouvements.value = mouvementsData.sort((a, b) => new Date(b.Date_mouvement) - new Date(a.Date_mouvement));
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

// Valider un mouvement
const validerMouvement = async (mouvementId) => {
  if (isValidating.value) return;
  
  const mouvement = mouvements.value.find(m => m.Id_Mouvement_ecriture === mouvementId);
  if (!mouvement || !isEquilibre(mouvement)) {
    errorMessage.value = 'Le mouvement doit être équilibré pour être validé';
    return;
  }

  if (!confirm('Valider ce mouvement ? Cette action sera définitive.')) {
    return;
  }

  isValidating.value = true;

  try {
    let validationSuccess = false;
    try {
      await axios.post(`http://127.0.0.1:8000/api/mouvements/${mouvementId}/valider`);
      validationSuccess = true;
    } catch (error) {
      if (error.response?.status === 404) {
        await axios.put(`http://127.0.0.1:8000/api/mouvements/${mouvementId}`, { valide: true });
        validationSuccess = true;
      } else {
        throw error;
      }
    }

    if (validationSuccess) {
      showSuccess('Mouvement validé avec succès');
      await fetchMouvements();
    }
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