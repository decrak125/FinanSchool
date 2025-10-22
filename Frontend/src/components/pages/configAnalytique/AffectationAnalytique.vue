<script setup>
import { ref, onMounted, computed } from "vue";
import { useAffectations } from "@/composables/useAffectations";
import PageAnalyse from "@/components/template/Page-analyse.vue";
import ContentHeader from "@/components/molecules/Analyse/Content-header.vue";
import Bouton from "@/components/atoms/Bouton.vue";
import Input from "@/components/atoms/Input.vue";
import Textarea from "@/components/atoms/Textarea.vue";
import Texte from "@/components/atoms/Texte.vue";
import PopUp from "@/components/molecules/Analyse/Pop-up.vue";
import FileInput from "@/components/atoms/File-input.vue";
import BoutonLoading from "@/components/atoms/Bouton-loading.vue";
import Pagination from "@/components/molecules/Pagination.vue";
import { usePagination } from "@/composables/usePagination";
import Select from '@/components/atoms/Select.vue';
import BoutonIcon from "@/components/atoms/Bouton-icon.vue";
import FilterSelect from '@/components/atoms/Filter-select.vue';
import searchbar from '@/components/atoms/searchbar.vue';
import Counter from "@/components/atoms/counter.vue";
import selectTable from "@/components/atoms/select-table.vue";
import InputTable from "@/components/atoms/Input-table.vue";
import TextareaTable from "@/components/atoms/Textarea-table.vue";
import SelectTable from "@/components/atoms/select-table.vue";
import LoadingText from "@/components/atoms/Loading-text.vue";

const openForm = ref(false);
const openImport = ref(false);
const loading = ref(true);

const {
  affectations, centres, comptes, types, file, showVentilationForm, // ← AJOUT types
  showDetails, totalTauxClass, isFormValid, hasDuplicateCentres,
  selectedGroup, loadingTable, nombreLignesLoader,
  editingVentilation, cancelTableModifications, saveTableModifications, removeVentilationFromTable,
  form, isEditing, message, addVentilationToTable,
  fetchData, save, remove, resetForm, onFileChange, uploadFile,
  searchTerm, suggestions, showSuggestions,
  searchCompte, selectCompte,
  filterSearchTerm,
  filterSelectedCentre,
  filteredAffectations,
  editVentilation,
  saveVentilation,
  removeVentilation, adjustTauxIfNeeded,
  showVentilationDetails,
  updateMultipleVentilations,
  editGroup, removeBySousCompte,
  switchToEditMode, switchToViewMode,detailsMode,
  affectationsGrouped,
  getTypeName // ← NOUVEAU : Fonction pour obtenir le nom du type
} = useAffectations();

// Computed pour les données groupées ET filtrées (uniquement pour l'affichage du tableau)
const filteredAffectationsGrouped = computed(() => {
  if (filteredAffectations && filteredAffectations.value) {
    const grouped = {};
    
    filteredAffectations.value.forEach(aff => {
      const key = aff.Id_Sous_compte;
      if (!grouped[key]) {
        grouped[key] = {
          Id_Sous_compte: aff.Id_Sous_compte,
          Id_Compte: aff.sous_compte?.Id_Compte,
          Code_sous_compte: aff.sous_compte?.Code_sous_compte,
          Libelle: aff.sous_compte?.Libelle,
          ventilations: []
        };
      }
      grouped[key].ventilations.push({
        id_affectation: aff.id_affectation,
        id_centre: aff.id_centre,
        id_type: aff.id_type, // ← AJOUT id_type
        centre_nom: aff.centre?.nom,
        type_nom: getTypeName(aff.id_type), // ← AJOUT type_nom
        taux: aff.taux,
        description: aff.description
      });
    });
    
    return Object.values(grouped);
  }
  
  return affectationsGrouped.value || [];
});

// Computed pour TOUTES les données groupées (sans filtre)
const allAffectationsGrouped = computed(() => {
  return affectationsGrouped.value || [];
});

// Pagination avec les données groupées filtrées
const {
  currentPage,
  itemsPerPage,
  totalPages,
  donneesPagination,
  previousPage,
  nextPage,
  goToPage
} = usePagination(filteredAffectationsGrouped)

// Computed pour le total des taux dans le formulaire
const totalTauxForm = computed(() => {
  return form.value.ventilations?.reduce((sum, v) => sum + Number(v.taux || 0), 0) || 0;
});

onMounted(
  async () => {
    try {
      fetchData();
    } finally {
      loading.value = false;
    }
  }
);

// Annuler l'édition
const cancelEdit = () => {
  resetForm();
  openForm.value = false;
};

// S'assurer que addVentilation fonctionne avec le nouveau design
const addVentilation = () => {
  if (!form.value.ventilations) form.value.ventilations = [];
  
  const totalTaux = form.value.ventilations.reduce((sum, v) => {
    return sum + Number(Number(v.taux || 0).toFixed(2));
  }, 0);
  
  const remainingTaux = Number((100 - totalTaux).toFixed(2));
  
  if (remainingTaux <= 0) {
    alert("Le total des taux atteint déjà 100% !");
    return;
  }

  form.value.ventilations.push({
    id_centre: null,
    id_type: null, // ← AJOUT id_type
    taux: Number(remainingTaux.toFixed(2)),
    description: ""
  });
};

// Sauvegarder et fermer le popup
const handleSave = async () => {
  const success = await save();
  if (success) {
    openForm.value = false;
  }
};

const openFormPopup = () => {
  resetForm();
  openForm.value = true;
};

// Réinitialiser les filtres
const resetFilters = () => {
  filterSearchTerm.value = '';
  filterSelectedCentre.value = '';
};

// Fonction pour afficher les détails avec TOUTES les ventilations
const showAllVentilations = (group) => {
  // Trouver le groupe complet dans toutes les données (sans filtre)
  const completeGroup = allAffectationsGrouped.value.find(
    g => g.Id_Sous_compte === group.Id_Sous_compte
  );
  
  if (completeGroup) {
    showVentilationDetails(completeGroup);
  } else {
    // Fallback: utiliser le groupe filtré si pas trouvé
    showVentilationDetails(group);
  }
};
</script>

<template>
  <PageAnalyse>
    <transition name="fade">
  <PopUp v-if="openForm">
    <div class="creation-popup">
      <!-- En-tête -->
      <div class="popuphead">
        <Texte 
          :texte="isEditing ? 'Modifier les ventilations de ' + searchTerm : 'Nouvelle affectation'" 
          :type="'dark'" 
        />
      </div>

      <!-- Recherche de compte (uniquement en création) -->
      <div v-if="!isEditing" class="compte-search mb-4">
        <Input 
          type="text" 
          v-model="searchTerm" 
          @input="searchCompte" 
          label="Libellé du compte" 
          required 
        />

        <ul v-if="showSuggestions" class="suggestion">
          <li 
            v-for="compte in suggestions" 
            :key="compte.Id_Compte" 
            @click="selectCompte(compte)" 
            class="sugg-list"
          >
            {{ compte.Code_compte }} - {{ compte.Libelle }}
          </li>
        </ul>
      </div>

      <!-- Affichage du compte sélectionné -->
      <div v-if="form.Id_Compte && !isEditing" class="selected-compte mb-4">
       <Texte
        :texte="searchTerm"
        :type="'dark'"
       />
      </div>

      <!-- Tableau des ventilations -->
      <div class="ventilation-table">
        <table class="table" id="axesTable" v-if="form.Id_Compte && !isEditing">
          <thead>
            <tr>
              <th class="col">Centre</th>
              <th class="col">Type</th> <!-- ← NOUVELLE COLONNE -->
              <th class="col">Description</th>
              <th class="col">Taux</th>
              <th class="col">Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(vent, index) in form.ventilations" :key="index">
              <td class="col">
                <SelectTable 
                  v-model="vent.id_centre" 
                  :label="''"
                  class="compact-select"
                  required
                >
                  <option value="" disabled>Sélectionner un centre</option>
                  <option 
                    v-for="centre in centres" 
                    :key="centre.id_centre" 
                    :value="centre.id_centre"
                  >
                    {{ centre.nom }}
                  </option>
                </SelectTable>
              </td>
              <td class="col"> <!-- ← NOUVELLE COLONNE -->
                <SelectTable 
                  v-model="vent.id_type" 
                  :label="''"
                  class="compact-select"
                  required
                >
                  <option value="" disabled>Sélectionner un type</option>
                  <option 
                    v-for="type in types" 
                    :key="type.id_type" 
                    :value="type.id_type"
                  >
                    {{ type.code }} - {{ type.libelle }}
                  </option>
                </SelectTable>
              </td>
              <td class="col">
                <TextareaTable 
                  v-model="vent.description" 
                  :label="''"
                  placeholder="Description..."
                  class="compact-input"
                />
              </td>
              <td class="col">
                <InputTable 
                  type="number" 
                  v-model.number="vent.taux" 
                  :label="''"
                  min="0" 
                  max="100" 
                  step="0.01"
                  required 
                  class="compact-input taux-input"
                />
                <span class="percent-symbol">%</span>
              </td>
              <td class="col">
                <BoutonIcon 
                  @click="removeVentilation(index)" 
                  icon-name="trash" 
                  :type="'cancel'" 
                  title="Supprimer cette ventilation"
                  :disabled="form.ventilations.length <= 1"
                />
              </td>
            </tr>
          </tbody>
          <tfoot id="footable">
            <tr>
              <td class="col">
              <button 
                type="button" 
                @click="addVentilation"
                class="add-ventilation-btn"
                :disabled="totalTauxForm >= 100 || !form.Id_Compte"
                :class="{ 
                  'opacity-50 cursor-not-allowed': totalTauxForm >= 100 || !form.Id_Compte 
                }"
              >
                + Ajouter un centre
              </button>
            </td>
            <td></td>
            <td></td>
            <td class="col total-cell">
              <span class="total-label">Total:</span>
              <span class="total-value" :class="totalTauxClass">
                {{ totalTauxForm.toFixed(2) }}%
              </span>
            </td>
            <td></td>
            </tr>
          </tfoot>
        </table>

        <!-- Messages d'information -->
        <div v-if="totalTauxForm !== 100 && form.Id_Compte" class="taux-warning mt-3">
          <Texte
            :texte="'Le total des taux doit être exactement 100%'"
            :type="'thin-warning'"
          />
        </div>

        <div v-if="hasDuplicateCentres" class="duplicate-warning mt-3">
          <Texte
            :texte="'Vous ne pouvez pas avoir plusieurs ventilations pour le même centre'"
            :type="'thin-error'"
          />
        </div>

        <div v-if="!form.Id_Compte && !isEditing" class="compte-warning mt-3">
          <Texte
            :texte="`Veuillez d'abord sélectionner un compte`"
            :type="'thin-warning'"
          />

        </div>
      </div>

      <!-- Boutons d'action -->
      <div class="btn-form mt-4">
        <Bouton 
          @click="handleSave" 
          type="input" 
          :texte="isEditing ? 'Valider' : 'Créer'" 
          :disabled="!isFormValid"
        />
        <Bouton 
          @click="cancelEdit" 
          type="cancel" 
          :texte="'Annuler'" 
        />
      </div>
    </div>
  </PopUp>
</transition>
    <!-- Popup pour l'import -->
    <transition name="fade">
      <PopUp v-if="openImport">
        <FileInput :reference="'file'" :file-name="file" :methode="onFileChange" />
        <div class="btn-form">
          <Bouton @click="uploadFile" type="input" :texte="'Importer'" redirection="" />
          <Bouton type="cancel" :texte="'Annuler'" @click="openImport = false" />
          <div v-if="message.text" :class="message.type === 'success' ? 'text-green' : 'text-red'">
            {{ message.text }}
          </div>
        </div>
      </PopUp>
    </transition>
    <transition name="fade">
  <PopUp v-if="showDetails">
    <div class="details-popup">
      <!-- En-tête avec bouton d'édition -->
      <div class="popuphead">
        <Texte
          :texte="(detailsMode === 'edit' ? 'Édition des ventilations: ' : 'Détails des ventilations: ') + selectedGroup?.Code_sous_compte + ' - ' + selectedGroup?.Libelle"
          :type="'dark'" />
        
        <!-- Bouton Modifier/Annuler selon le mode -->
        <div v-if="detailsMode === 'view'">
          <BoutonIcon 
            @click="switchToEditMode()" 
            icon-name="pen" 
            :type="'edit'" 
            title="Modifier les ventilations"
          />
        </div>
        <div v-else>
          
          <BoutonIcon 
            @click="cancelTableModifications()" 
            icon-name="x-lg" 
            :type="'cancel'" 
            title="Annuler les modifications"
          />
        </div>
      </div>

      <!-- Contenu selon le mode -->
      <div class="ventilation-details">
        <table class="table" id="axesTable">
          <thead>
            <tr>
              <th class="col">Centre</th>
              <th class="col">Type</th> <!-- ← NOUVELLE COLONNE -->
              <th class="col">Description</th>
              <th class="col">Taux</th>
              <th class="col">Actions</th>
            </tr>
          </thead>
          <tbody>
            <!-- MODE VISUALISATION -->
            <template v-if="detailsMode === 'view'">
              <!-- Afficher TOUTES les ventilations du sous-compte -->
              <tr v-for="vent in selectedGroup?.ventilations || []" :key="vent.id_affectation">
                <td class="col">{{ vent.centre_nom }}</td>
                <td class="col">{{ vent.type_nom }}</td> <!-- ← AJOUT colonne type -->
                <td class="col">{{ vent.description }}</td>
                <td class="col">{{ Number(vent.taux || 0).toFixed(2) }}%</td>
                <td class="col">
                  <BoutonIcon 
                    @click="remove(vent.id_affectation); showDetails=false" 
                    icon-name="trash" 
                    :type="'cancel'" 
                  />
                </td>
              </tr>
            </template>

            <!-- MODE ÉDITION -->
            <template v-else>
              <!-- Éditer TOUTES les ventilations du sous-compte -->
              <tr v-for="(vent, index) in form.ventilations" :key="index">
                <td class="col">
                  <selectTable 
                    v-model="vent.id_centre" 
                    :label="''"
                    class="compact-select"
                  >
                    <option value="" disabled>Sélectionner un centre</option>
                    <option 
                      v-for="centre in centres" 
                      :key="centre.id_centre" 
                      :value="centre.id_centre"
                    >
                      {{ centre.nom }}
                    </option>
                  </selectTable>
                </td>
                <td class="col"> <!-- ← NOUVELLE COLONNE -->
                  <selectTable 
                    v-model="vent.id_type" 
                    :label="''"
                    class="compact-select"
                  >
                    <option value="" disabled>Sélectionner un type</option>
                    <option 
                      v-for="type in types" 
                      :key="type.id_type" 
                      :value="type.id_type"
                    >
                      {{ type.code }} - {{ type.libelle }}
                    </option>
                  </selectTable>
                </td>
                <td class="col">
                  <TextareaTable 
                    v-model="vent.description" 
                    :label="''"
                    placeholder="Description..."
                    class="compact-input"
                  />
                </td>
                <td class="col">
                  <InputTable 
                    type="number" 
                    v-model.number="vent.taux" 
                    :label="''"
                    min="0" 
                    max="100" 
                    step="0.01"
                    class="compact-input taux-input"
                  />
                  <span class="percent-symbol">%</span>
                </td>
                <td class="col">
                  <BoutonIcon 
                    @click="removeVentilationFromTable(index)" 
                    icon-name="trash" 
                    :type="'cancel'" 
                    title="Supprimer cette ventilation"
                    :disabled="form.ventilations.length <= 1"
                  />
                </td>
              </tr>
            </template>
          </tbody>
          <tfoot id="footable">
            <!-- MODE VISUALISATION -->
            <template v-if="detailsMode === 'view'">
              <td class="col">Total</td>
              <td></td>
              <td></td>
              <td class="col">{{selectedGroup?.ventilations?.reduce((sum, v) => sum + Number(v.taux || 0), 0).toFixed(2)}}%</td>
              <td></td>
            </template>

            <!-- MODE ÉDITION -->
            <template v-else>
              <td class="col">
                Total
              </td>
              <td></td>
              <td></td>
              <td class="col">
                <span class="total-value" :class="totalTauxClass">
                  {{ totalTauxForm.toFixed(2) }}%
                </span>
              </td>
              <td class="col">
                 
              </td>
            </template>
          </tfoot>
        </table>

        <!-- Messages d'information (uniquement en mode édition) -->
        <!-- <div v-if="detailsMode === 'edit'">
          <div v-if="totalTauxForm !== 100" class="taux-warning mt-3">
            <p class="text-amber-600 text-sm">
              ⚠️ Le total des taux doit être exactement 100% (actuellement : {{ totalTauxForm.toFixed(2) }}%)
            </p>
          </div>

          <div v-if="hasDuplicateCentres" class="duplicate-warning mt-3">
            <p class="text-red-600 text-sm">
              ❌ Vous ne pouvez pas avoir plusieurs ventilations pour le même centre
            </p>
          </div>
        </div> -->
      </div>

      <!-- Boutons selon le mode -->
      <div class="btn-form mt-4">
        <!-- MODE VISUALISATION -->
        <template v-if="detailsMode === 'view'">
          <Bouton @click="showDetails = false" type="cancel" :texte="'Fermer'" />
        </template>

        <!-- MODE ÉDITION -->
        <template v-else>
          <div class="action-content">
            <BoutonIcon
                    :icon-name="'plus-lg'"
                    :type="totalTauxForm >= 100 ? 'primary-disabled' : 'primary' "
                     @click="addVentilationToTable"
                     :disabled="totalTauxForm >= 100"
                  />
            <Bouton 
            @click="saveTableModifications" 
            type="input" 
            :texte="'Valider'" 
            :disabled="!isFormValid"
          />
          <!-- <Bouton 
            @click="cancelTableModifications" 
            type="cancel" 
            :texte="'Annuler'" 
          /> -->
        </div>
        </template>
      </div>
    </div>
  </PopUp>
</transition>

    <div class="main">
      <ContentHeader :menu="'Saisie Analytique'" :sousmenu="'Affectation Analytique'" />
      <div class="informations">
        <p class="Count-content">
          <Counter v-if="filteredAffectationsGrouped.length > 0" :number="filteredAffectationsGrouped.length" :format="'number'" />
          <Counter v-if="filteredAffectationsGrouped.length == 0" :number="0" />
          affectations analytique faite(s).
        </p>
        <div class="btn">
          <Bouton type="primary" texte="Importer" redirection="" @click="openImport = !openImport" />
          <Bouton type="primary" texte="Ajouter" redirection="" @click="openFormPopup" />
        </div>
      </div>

      <!-- Section Filtres -->
      <div class="filtres">
        <searchbar v-model="filterSearchTerm" type="text" placeholder="Code ou libellé du compte..." />
        
        <FilterSelect v-model="filterSelectedCentre" :label="''">
          <option value="">Tous les centres</option>
          <option v-for="centre in centres" :key="centre.id_centre" :value="centre.id_centre">
            {{ centre.nom }}
          </option>
        </FilterSelect>
        
        <BoutonIcon 
        v-if="filterSearchTerm || filterSelectedCentre"
          @click="resetFilters" 
          type="cancel" 
          :icon-name="'x-lg'"
          class="reset-filter-btn"
        />
      </div>

      <!-- Tableau des affectations -->
      <div class="loading" v-if="loading">
        <BoutonLoading :type="'transparent'" />
      </div>
      <transition name="fade">
        <div class="content">
          <table class="table" id="axesTable">
            <thead>
              <tr>
                <th class="col">Code</th>
                <th class="col">Libellé</th>
                <th class="col">Nombre de ventilations</th>
                <th class="col">Total taux</th>
                <th class="col">Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="group in donneesPagination" :key="group.Id_Sous_compte" v-if="donneesPagination.length > 0">
                <td class="col">{{ group.Code_sous_compte }}</td>
                <td class="col">{{ group.Libelle }}</td>
                <td class="col">{{ group.ventilations.length }}</td>
                <td class="col">{{group.ventilations.reduce((sum, v) => sum + Number(v.taux || 0), 0).toFixed(2)}}%</td>
                <td class="col">
                  <div class="action-content">
                    <!-- Utiliser showAllVentilations au lieu de showVentilationDetails -->
                    <BoutonIcon @click="showAllVentilations(group)" icon-name="eye" :type="'edit'" />
                  <BoutonIcon
                    @click="removeBySousCompte(group.Id_Sous_compte), showDetails=false" icon-name="trash" :type="'cancel'"
                  />
                  </div>
                </td>
              </tr>
              <tr v-if="loadingTable" v-for="n in nombreLignesLoader" :key="'loader-' + n">
                <td class="col"><LoadingText :type="'line-1'"/></td>
                <td class="col"><LoadingText :type="'line-1'"/></td>
                <td class="col"><LoadingText :type="'line-1'"/></td>
                <td class="col"><LoadingText :type="'line-1'"/></td>
                <td class="col"><LoadingText :type="'line-1'"/></td>
              </tr>
              <!-- <tr v-if="donneesPagination.length === 0 && !loading">
                <td colspan="5" class="col text-center">
                  Aucune affectation trouvée
                </td>
              </tr> -->
            </tbody>
          </table>
        </div>
      </transition>

      <!-- Popup pour voir les détails des ventilations -->

      <Pagination 
        :donnees="filteredAffectationsGrouped" 
        :current-page="currentPage" 
        :items-per-page="itemsPerPage"
        :total-pages="totalPages" 
        :go-to-page="goToPage" 
        :previous-page="previousPage" 
        :next-page="nextPage" 
      />
    </div>
  </PageAnalyse>
</template>

<!-- Le CSS reste identique -->
<style lang="scss" scoped>
.main {
  @include position-contenus(flex, center, center);
  padding: 0 32px;
  flex-direction: column;
  gap: 10px;
  flex: 1 0 0;
  align-self: stretch;
  animation: appear 0.6s ease-out forwards;
}

#axesTable {
  @include table(#f5f5f5);
}

.informations {
  @include position-contenus(flex, space-between, center);
  padding: 10px 0;
  align-self: stretch;
  border-bottom: 1px solid #C5C5C5;
}

.btn {
  @include position-contenus(flex, flex-end, center);
  gap: 10px;
}

.btn-form {
  @include position-contenus(flex, center, center);
  flex-direction: column;
  gap: 10px;
  padding-top: 10px;
}

.Count-content {
  display: flex;
  background-color: transparent;
  color: #4A4A4A;
  font-family: Stara;
  font-size: 32px;
  font-style: normal;
  font-weight: 600;
  line-height: normal;
  margin: 0;
  gap: 5px;
}

.file {
  display: flex;
  height: 189px;
  padding: 10px;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  gap: 10px;
  align-self: stretch;
  border-radius: $radius-pm;
  border: 1px dashed #515151;
}

.text-green {
  @include text-xs($stara-medium, $vert)
}

.text-red {
  @include text-xs($stara-medium, $rouge)
}

.fade-enter-active,
.fade-leave-active {
  transition: all 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
  transform: scale(0.9);
}

.fade-enter-to,
.fade-leave-from {
  opacity: 1;
  transform: scale(1);
}

.loading {
  @include position-contenus(flex, center, center);
  height: 400px;
}

.content {
  overflow-y: auto;
  width: 100%;
  max-height: 53vh;
  border-radius: $radius-pm;
}

.content::-webkit-scrollbar {
  width: 10px;
}

.content::-webkit-scrollbar-track {
  background: #ffffff;
  border-radius: 10px;
}

.content::-webkit-scrollbar-thumb {
  background: $light;
  border-radius: 10px;
}

.content::-webkit-scrollbar-thumb:hover {
  background: #a8a8a8;
}

.popupContent {
  @include position-contenus(flex, center, flex-start);
  gap: 10px;
}

.suggestion {
  @include position-contenus(flex, flex-start, flex-start);
  flex-direction: column;
  width: 250px;
  gap: 10px;
  list-style: none;
  padding-left: 0;
  background-color: #F5F5F5;
  position: fixed;
  padding: 12px;
  max-height: 250px;
  border: 1px #4A4A4A solid;
  overflow-y: auto;
  z-index: 1000;
}

.sugg-list {
  cursor: pointer;
  border-bottom: 1px solid #C5C5C5;
  font-family: $stara-medium;
  font-size: 12px;
  list-style: none;
  padding-left: 0;
  width: 100%;
  padding: 8px 4px;
}

.sugg-list:hover {
  background-color: #e5e5e5;
}

.suggestion::-webkit-scrollbar {
  width: 5px;
}

.suggestion::-webkit-scrollbar-track {
  background: #ffffff;
  border-radius: 5px;
}

.suggestion::-webkit-scrollbar-thumb {
  background: $light;
  border-radius: 5px;
}

.suggestion::-webkit-scrollbar-thumb:hover {
  background: #a8a8a8;
}

.filtres {
  @include position-contenus(flex, flex-start, center);
  padding: 0 0;
  align-self: self-start;
  gap: 10px;
  // width: 100%;
}

.reset-filter-btn {
  margin-left: auto;
}

.ventilations {
  display: flex;
  background-color: #fff;
  padding: 0%;
  margin: 0%;
}

#footable {
  font-family: $stara-bold;
  font-size: 16px;
  background-color: #f3f3f3;
}

.popuphead{
  @include position-contenus();
  justify-content: space-between;
}

.action-content{
  display: flex;
  justify-content: center;
  gap: 10px;
}

.ventilation-item{
  background-color: $light;
  padding: 0px;
  gap: 0px;
  margin: 0px;
}

.ventilation-nb{
  background-color: #5a4949;
  margin: 0;
  padding: 0;
}

.text-center {
  text-align: center;
}
</style>