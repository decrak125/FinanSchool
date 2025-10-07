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
import Header from "../../molecules/Header.vue";
import Sidebar from "../../molecules/Sidebar.vue";
import AppFooter from "../../molecules/Footer.vue";
import { useEcriture } from '@/composables/useEcriture';

// Import and use the composable
const {
  mouvements,
  journals,
  sousComptes,
  modesPaiement,
  isLoading,
  isCreatingMouvement,
  isValidating,
  isDeletingMouvement,
  errorMessage,
  successMessage,
  mouvementForm,
  totalLignes,
  handleNavigation,
  createMouvement,
  deleteMouvement,
  addNewLigne,
  searchSousCompte,
  onSousCompteFocus,
  navigateSuggestions,
  selectFirstSuggestion,
  closeSuggestions,
  selectSousCompte,
  validateSousCompte,
  onMontantChange,
  updateLigne,
  deleteLigne,
  getTotalDebit,
  getTotalCredit,
  getDifference,
  isEquilibre,
  getTotalGeneralDebit,
  getTotalGeneralCredit,
  isMouvementValide,
  validerMouvement,
  getJournalLibelle,
  formatDate,
  formatMontant
} = useEcriture();
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