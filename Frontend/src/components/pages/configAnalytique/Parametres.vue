<script setup>
import { ref, onMounted, computed } from "vue";
import { useParametresAnalytique } from "@/composables/useParametresAnalytique";
import PageAnalyse from '@/components/template/Page-analyse.vue';
import Bouton from "@/components/atoms/Bouton.vue";
import Input from "@/components/atoms/Input.vue";
import InputTable from "@/components/atoms/Input-table.vue";
import Textarea from "@/components/atoms/Textarea.vue";
import TextareaTable from "@/components/atoms/Textarea-table.vue";
import Texte from "@/components/atoms/Texte.vue";
import PopUp from "@/components/molecules/Analyse/Pop-up.vue";
import BoutonIcon from "@/components/atoms/Bouton-icon.vue";
import searchbar from '@/components/atoms/searchbar.vue';
import Counter from "@/components/atoms/counter.vue";
import Pagination from "@/components/molecules/Pagination.vue";
import { usePagination } from "@/composables/usePagination";
import Select from '@/components/atoms/Select.vue';
import SelectTable from "@/components/atoms/select-table.vue";
import FilterSelect from '@/components/atoms/Filter-select.vue';
import LoadingText from '@/components/atoms/Loading-text.vue';
import Icon from '@/components/atoms/Icon.vue';

// Service
const {
  indicateurs,
  currentIndicateur,
  interpretations,
  niveaux,
  loading,
  fetchIndicateursComplets,
  fetchIndicateurDetails,
  createIndicateur,
  updateIndicateur,
  deleteIndicateur,
  createInterpretation,
  updateInterpretation,
  deleteInterpretation,
  fetchNiveauxAlerte
} = useParametresAnalytique();

// États UI
const showIndicateurForm = ref(false);
const showDetails = ref(false);
const showDeleteConfirm = ref(false);
const editingIndicateur = ref(null);
const editingInterpretation = ref(null);
const itemToDelete = ref(null);
const deleteType = ref(''); // 'indicateur' ou 'interpretation'
const searchTerm = ref('');
const nombreLignesLoader = ref(10);

// États pour le mode d'affichage (similaire à AffectationAnalytique)
const detailsMode = ref('view'); // 'view' ou 'edit'

// Filtres
const filterSearchTerm = ref('');
const filterSelectedNiveau = ref('');

// Formulaires
const formIndicateur = ref({
  libelle: '',
  description: '',
  formule: ''
});

const formInterpretations = ref([]); // Pour stocker les interprétations en édition

// Chargement initial
onMounted(async () => {
  await Promise.all([
    fetchIndicateursComplets(),
    fetchNiveauxAlerte()
  ]);
  nombreLignesLoader.value = indicateurs.value.length || 10;
});

// 📌 Ouvrir les détails d'un indicateur
const openIndicateurDetails = async (indicateur) => {
  await fetchIndicateurDetails(indicateur.id_indicateur_analytique);
  detailsMode.value = 'view';
  showDetails.value = true;
};

// 📌 GESTION DES INDICATEURS
const handleCreateIndicateur = async () => {
  try {
    await createIndicateur(formIndicateur.value);
    showIndicateurForm.value = false;
    resetFormIndicateur();
  } catch (error) {
    console.error("Erreur création indicateur:", error);
  }
};

const handleEditIndicateur = (indicateur) => {
  editingIndicateur.value = indicateur.id_indicateur_analytique;
  formIndicateur.value = { ...indicateur };
  showIndicateurForm.value = true;
};

const handleUpdateIndicateur = async () => {
  try {
    await updateIndicateur(editingIndicateur.value, formIndicateur.value);
    showIndicateurForm.value = false;
    resetFormIndicateur();
    editingIndicateur.value = null;
  } catch (error) {
    console.error("Erreur mise à jour indicateur:", error);
  }
};

const confirmDeleteIndicateur = (id) => {
  itemToDelete.value = id;
  deleteType.value = 'indicateur';
  showDeleteConfirm.value = true;
};

const handleDeleteIndicateur = async () => {
  try {
    await deleteIndicateur(itemToDelete.value);
    showDeleteConfirm.value = false;
    showDetails.value = false;
    itemToDelete.value = null;
    deleteType.value = '';
  } catch (error) {
    console.error("Erreur suppression indicateur:", error);
  }
};

const resetFormIndicateur = () => {
  formIndicateur.value = {
    libelle: '',
    description: '',
    formule: ''
  };
  editingIndicateur.value = null;
};

// 📌 GESTION DES INTERPRÉTATIONS (similaire à AffectationAnalytique)
const switchToEditMode = () => {
  detailsMode.value = 'edit';
  // Initialiser formInterpretations avec les interprétations actuelles
  formInterpretations.value = interpretations.value.map(interp => ({
    id_interpretation_indicateur: interp.id_interpretation_indicateur,
    valeur: interp.valeur.toString(),
    interpretation: interp.interpretation,
    id_niveau_alerte: interp.id_niveau_alerte.toString()
  }));
};

const switchToViewMode = () => {
  detailsMode.value = 'view';
  formInterpretations.value = [];
};

const cancelTableModifications = () => {
  switchToViewMode();
};

const addInterpretationToTable = () => {
  formInterpretations.value.push({
    id_interpretation_indicateur: null,
    valeur: '',
    interpretation: '',
    id_niveau_alerte: ''
  });
};

const removeInterpretationFromTable = (index) => {
  if (formInterpretations.value.length > 1) {
    formInterpretations.value.splice(index, 1);
  }
};

const saveTableModifications = async () => {
  try {
    // Identifier les nouvelles, modifiées et supprimées
    const currentIds = interpretations.value.map(i => i.id_interpretation_indicateur);
    const newIds = formInterpretations.value
      .filter(i => !i.id_interpretation_indicateur)
      .map(i => ({ 
        valeur: parseFloat(i.valeur), 
        interpretation: i.interpretation, 
        id_niveau_alerte: parseInt(i.id_niveau_alerte),
        id_indicateur_analytique: currentIndicateur.value.id_indicateur_analytique
      }));

    const updated = formInterpretations.value
      .filter(i => i.id_interpretation_indicateur)
      .map(i => ({
        id_interpretation_indicateur: i.id_interpretation_indicateur,
        valeur: parseFloat(i.valeur),
        interpretation: i.interpretation,
        id_niveau_alerte: parseInt(i.id_niveau_alerte)
      }));

    const deleted = currentIds.filter(id => 
      !formInterpretations.value.some(i => i.id_interpretation_indicateur === id)
    );

    // Exécuter les opérations
    for (const newInterp of newIds) {
      await createInterpretation(newInterp);
    }

    for (const updateInterp of updated) {
      await updateInterpretation(updateInterp.id_interpretation_indicateur, updateInterp);
    }

    for (const deleteId of deleted) {
      await deleteInterpretation(deleteId);
    }

    // Recharger les données
    await fetchIndicateurDetails(currentIndicateur.value.id_indicateur_analytique);
    switchToViewMode();
  } catch (error) {
    console.error("Erreur sauvegarde interprétations:", error);
  }
};

// 📌 FILTRES
const filteredIndicateurs = computed(() => {
  let filtered = indicateurs.value;
  
  if (filterSearchTerm.value) {
    const term = filterSearchTerm.value.toLowerCase();
    filtered = filtered.filter(indicateur =>
      indicateur.libelle.toLowerCase().includes(term) ||
      indicateur.description.toLowerCase().includes(term) ||
      indicateur.formule.toLowerCase().includes(term)
    );
  }
  
  return filtered;
});

// 📌 UTILITAIRES
const getNiveauLibelle = (id) => {
  const niveau = niveaux.value.find(n => n.id_niveau_alerte == id);
  return niveau ? niveau.libelle : 'N/A';
};

const getNiveauCouleur = (id) => {
  const niveau = niveaux.value.find(n => n.id_niveau_alerte == id);
  return niveau ? niveau.couleur : '#6c757d';
};

const getDeleteMessage = computed(() => {
  if (deleteType.value === 'indicateur') {
    return "Êtes-vous sûr de vouloir supprimer cet indicateur ? Toutes ses interprétations seront également supprimées.";
  } else if (deleteType.value === 'interpretation') {
    return "Êtes-vous sûr de vouloir supprimer cette interprétation ?";
  }
  return "";
});

// Réinitialiser les filtres
const resetFilters = () => {
  filterSearchTerm.value = '';
  filterSelectedNiveau.value = '';
};

// Pagination
const {
  currentPage,
  itemsPerPage,
  totalPages,
  donneesPagination,
  previousPage,
  nextPage,
  goToPage
} = usePagination(filteredIndicateurs);
</script>

<template>
  <PageAnalyse :menu="'Paramètres'" :sousmenu="'Indicateurs analytiques'">
    
    <!-- POPUP Confirmation suppression -->
    <transition name="fade">
      <PopUp v-if="showDeleteConfirm">
        <Icon :color="'primary'" :icon="'bi bi-exclamation-triangle'" />
        <Texte :type="'bold-dark'" texte="Confirmation de suppression" />
        <Texte :type="'dark'" :texte="getDeleteMessage" />
        <div class="PPbtn">
          <Bouton @click="deleteType === 'indicateur' ? handleDeleteIndicateur() : deleteInterpretation(itemToDelete)" 
                 :type="'input'" :texte="'Confirmer'" />
          <Bouton @click="showDeleteConfirm = false" :type="'cancel'" :texte="'Annuler'" />
        </div>
      </PopUp>
    </transition>

    <!-- POPUP Formulaire Indicateur -->
    <transition name="fade">
      <PopUp v-if="showIndicateurForm">
        <div class="creation-popup">
          <div class="popuphead">
            <Texte :texte="editingIndicateur ? 'Modifier l\'indicateur' : 'Nouvel indicateur'" :type="'dark'" />
          </div>

          <div class="form-content">
            <div class="form-row">
              <Input v-model="formIndicateur.libelle" 
                     placeholder="Libellé de l'indicateur" 
                     type="text" 
                     required />
            </div>
            
            <div class="form-row">
              <Textarea v-model="formIndicateur.description" 
                       placeholder="Description" 
                       required />
            </div>
            
            <div class="form-row">
              <Textarea v-model="formIndicateur.formule" 
                       placeholder="Formule de calcul" 
                       required />
            </div>
          </div>

          <div class="btn-form">
            <Bouton @click="editingIndicateur ? handleUpdateIndicateur() : handleCreateIndicateur()" 
                   type="input" 
                   :texte="editingIndicateur ? 'Modifier' : 'Créer'" />
            <Bouton @click="showIndicateurForm = false, resetFormIndicateur()" 
                   type="cancel" 
                   :texte="'Annuler'" />
          </div>
        </div>
      </PopUp>
    </transition>

    <!-- POPUP Détails Indicateur (similaire à AffectationAnalytique) -->
    <transition name="fade">
      <PopUp v-if="showDetails && currentIndicateur">
        <div class="details-popup">
          <!-- En-tête avec bouton d'édition -->
          <div class="popuphead">
            <Texte
              :texte="(detailsMode === 'edit' ? 'Édition des interprétations: ' : 'Détails de l\'indicateur: ') + currentIndicateur.libelle"
              :type="'dark'" />

            <!-- Bouton Modifier/Annuler selon le mode -->
            <div v-if="detailsMode === 'view'">
              <BoutonIcon @click="showDetails = false" 
                         icon-name="x-lg" 
                         :type="'cancel'"
                         title="Modifier les interprétations" />
              <!-- <BoutonIcon @click="confirmDeleteIndicateur(currentIndicateur.id_indicateur_analytique)" 
                         icon-name="trash-fill" 
                         :type="'cancel'"
                         title="Supprimer l'indicateur" /> -->
            </div>
            <div v-else>
              <BoutonIcon @click="cancelTableModifications()" 
                         icon-name="x-lg" 
                         :type="'cancel'"
                         title="Annuler les modifications" />
            </div>
          </div>

          <!-- Informations de l'indicateur -->
          <div class="indicateur-info mb-4">
            <div class="info-section">
              <Texte :type="'bold-dark'" :texte="'Description'" />
              <Texte :type="'dark'" :texte="currentIndicateur.description" />
            </div>
            
            <div class="info-section">
              <Texte :type="'bold-dark'" :texte="'Formule'" />
              <Texte :type="'dark'" :texte="currentIndicateur.formule" />
            </div>
          </div>

          <!-- Tableau des interprétations -->
          <div class="interpretations-table">
            <Texte :type="'bold-dark'" :texte="'Interprétations'" />
            
            <table class="table" id="interpretationsTable">
              <thead>
                <tr>
                  <th class="col">Valeur seuil</th>
                  <th class="col">Interprétation</th>
                  <th class="col">Niveau d'alerte</th>
                  <th class="col" v-if="detailsMode === 'edit'">Actions</th>
                </tr>
              </thead>
              <tbody>
                <!-- MODE VISUALISATION -->
                <template v-if="detailsMode === 'view'">
                  <tr v-for="interpretation in interpretations.sort((a, b) => b.valeur - a.valeur)" 
                      :key="interpretation.id_interpretation_indicateur">
                    <td class="col"> {{ (interpretation.valeur >= 0 ? '≥ ' : '≤ ') + interpretation.valeur }}</td>
                    <td class="col">{{ interpretation.interpretation }}</td>
                    <td class="col">
                      <span class="niveau-badge" 
                            :style="{ color: getNiveauCouleur(interpretation.id_niveau_alerte) }">
                        {{ getNiveauLibelle(interpretation.id_niveau_alerte) }}
                      </span>
                    </td>
                  </tr>
                </template>

                <!-- MODE ÉDITION -->
                <template v-else>
                  <tr v-for="(interpretation, index) in formInterpretations" 
                      :key="index">
                    <td class="col">
                      <InputTable type="number" 
                                 v-model="interpretation.valeur" 
                                 :label="''" 
                                 step="0.01" 
                                 required 
                                 class="compact-input" />
                    </td>
                    <td class="col">
                      <TextareaTable v-model="interpretation.interpretation" 
                                    :label="''" 
                                    placeholder="Interprétation..." 
                                    class="compact-input" />
                    </td>
                    <td class="col">
                      <SelectTable v-model="interpretation.id_niveau_alerte" 
                                  :label="''" 
                                  class="compact-select" 
                                  required>
                        <option value="" disabled>Sélectionner un niveau</option>
                        <option v-for="niveau in niveaux" 
                                :key="niveau.id_niveau_alerte"
                                :value="niveau.id_niveau_alerte">
                          {{ niveau.libelle }}
                        </option>
                      </SelectTable>
                    </td>
                    <td class="col">
                      <BoutonIcon @click="removeInterpretationFromTable(index)" 
                                 icon-name="trash" 
                                 :type="'cancel'"
                                 title="Supprimer cette interprétation" 
                                 :disabled="formInterpretations.length <= 1" />
                    </td>
                  </tr>
                </template>
              </tbody>
              <tfoot v-if="detailsMode === 'edit'">
                <tr>
                  <td class="col">
                    <BoutonIcon :icon-name="'plus-lg'" 
                               :type="'primary'" 
                               @click="addInterpretationToTable" />
                  </td>
                  <td></td>
                  <td></td>
                  <td></td>
                </tr>
              </tfoot>
            </table>
          </div>

          <!-- Boutons selon le mode -->
          <div class="btn-form mt-4">
            <!-- MODE VISUALISATION -->
            <template v-if="detailsMode === 'view'">
              <Bouton @click="switchToEditMode()" 
                     type="input" 
                     :texte="'Modifier'" />
            </template>

            <!-- MODE ÉDITION -->
            <template v-else>
              <div class="action-content">
                <Bouton @click="saveTableModifications" 
                       type="input" 
                       :texte="'Valider'" />
              </div>
            </template>
          </div>
        </div>
      </PopUp>
    </transition>

    <div class="main">
      <div class="informations">
        <p class="Count-content">
          <Counter v-if="filteredIndicateurs.length > 0" :number="filteredIndicateurs.length" />
          <Counter v-if="filteredIndicateurs.length == 0" :number="0" /> 
          indicateur{{ filteredIndicateurs.length !== 1 ? 's' : '' }} analytique{{ filteredIndicateurs.length !== 1 ? 's' : '' }}
        </p>
        <div class="btn">
          <Bouton type="primary" 
                 texte="Ajouter" 
                 redirection="" 
                 @click="resetFormIndicateur(), showIndicateurForm = true" />
        </div>
      </div>

      <!-- Section Filtres -->
      <div class="filtres">
        <div class="ok">
          <searchbar v-model="filterSearchTerm" 
                     type="text" 
                     placeholder="Rechercher un indicateur..." />

          <BoutonIcon v-if="filterSearchTerm" 
                     @click="resetFilters" 
                     type="cancel" 
                     :icon-name="'x-lg'" 
                     class="reset-filter-btn" />
        </div>
        <div class="iconbtn">
          <i class="bi bi-file-earmark-pdf-fill"></i>
        </div>
      </div>

      <!-- Tableau des indicateurs -->
      <transition name="fade">
        <div class="content">
          <table class="table" id="indicateursTable">
            <thead>
              <tr>
                <th class="col">#</th>
                <th class="col">Indicateur</th>
                <th class="col">Description</th>
                <th class="col">Formule</th>
                <th class="col">Actions</th>
              </tr>
            </thead>
            <tbody>
              <!-- Données réelles -->
              <tr v-for="indicateur in donneesPagination" 
                  :key="indicateur.id_indicateur_analytique" 
                  v-if="!loading">
                <td class="col">{{ indicateur.id_indicateur_analytique }}</td>
                <td class="col">
                  {{ indicateur.libelle }}
                </td>
                <td class="col">{{ indicateur.description }}</td>
                <td class="col">
                  {{ indicateur.formule }}
                </td>
                <td class="col">
                  <div class="action-content">
                    <BoutonIcon @click="openIndicateurDetails(indicateur)" 
                               icon-name="eye-fill" 
                               :type="'edit'" />
                    <BoutonIcon @click="handleEditIndicateur(indicateur)" 
                               icon-name="pen-fill" 
                               :type="'edit'" />
                  </div>
                </td>
              </tr>

              <!-- Loaders -->
              <tr v-if="loading" v-for="n in nombreLignesLoader" :key="'loader-' + n">
                <td class="col"><LoadingText type="line-1" /></td>
                <td class="col"><LoadingText type="line-2" /></td>
                <td class="col"><LoadingText type="line-4" /></td>
                <td class="col"><LoadingText type="line-1" /></td>
                <td class="col"><LoadingText type="line-1" /></td>
              </tr>

              <!-- Message si aucun résultat -->
              <tr v-if="!loading && filteredIndicateurs.length === 0">
                <td colspan="5" class="no-data">
                  <div class="empty-state">
                    <i class="bi bi-graph-up"></i>
                    <Texte :type="'dark'" :texte="'Aucun indicateur trouvé'" />
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </transition>

      <!-- Pagination -->
      <Pagination :donnees="filteredIndicateurs" 
                  :current-page="currentPage" 
                  :items-per-page="itemsPerPage"
                  :total-pages="totalPages" 
                  :go-to-page="goTo-page" 
                  :previous-page="previousPage" 
                  :next-page="nextPage" />
    </div>
  </PageAnalyse>
</template>

<style lang="scss" scoped>
.main {
  @include glass();
  border-radius: $radius-pm;
  @include position-contenus(flex, baseline, center);
  padding: 0 24px 24px 24px;
  margin: 12px;
  height: 82vh;
  flex-direction: column;
  gap: 10px;
  flex: 1 0 0;
  align-self: stretch;
  animation: appear 0.6s ease-out forwards;
}

.iconbtn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 49px;
  height: 49px;
  border-radius: 50%;
  @include glass();
  cursor: pointer;

  i {
    color: #e25252;
    font-size: 20px;
  }
}

.ok {
  display: flex;
  align-items: center;
  justify-content: flex-start;
  gap: 10px;
}

#indicateursTable, #interpretationsTable {
  @include table();
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
  height: 60vh;
  border-radius: $radius-pm;
}

/* Personnalisation de la scrollbar */
.content::-webkit-scrollbar {
  width: 10px;
}

.content::-webkit-scrollbar-track {
  background: transparent;
  border-radius: 10px;
}

.content::-webkit-scrollbar-thumb {
  background: #C5C5C5;
  border-radius: 10px;
}

.popupContent {
  @include position-contenus(flex, center, flex-start);
  gap: 10px;
}

.filtres {
  @include position-contenus(flex, space-between, center);
  padding: 0 0;
  align-self: self-start;
  gap: 10px;
  width: 100%;
}

.reset-filter-btn {
  margin-left: auto;
}

.popuphead {
  @include position-contenus(flex, space-between, center);
  width: 100%;
  // margin-bottom: 20px;
}

.action-content {
  display: flex;
  justify-content: center;
  gap: 10px;
}

.PPbtn {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

/* Styles pour le popup de détails (similaire à AffectationAnalytique) */
.details-popup {
  min-width: 700px;
  max-width: 900px;
  max-height: 80vh;
  overflow-y: auto;
  
  .indicateur-info {
    .info-section {
      margin-bottom: 16px;
      
      .info-text {
        margin-top: 8px;
        color: #666;
        line-height: 1.6;
        background: #f8f9fa;
        padding: 12px;
        border-radius: 8px;
      }
      
      .formule-box {
        background: #f8f9fa;
        padding: 12px;
        border-radius: 8px;
        border-left: 4px solid $secondary;
        margin-top: 8px;
        
        code {
          font-family: 'Courier New', monospace;
          font-size: 14px;
          color: #2c3e50;
        }
      }
    }
  }
  
  .interpretations-table {
    margin-top: 24px;
    
    .niveau-badge {
      padding: 4px 12px;
      border-radius: 12px;
      font-size: 12px;
      font-weight: 600;
      color: white;
      text-transform: uppercase;
      display: inline-block;
    }
  }
}

.form-content {
  display: flex;
  flex-direction: column;
  gap: 16px;
  margin-bottom: 20px;
  
  .form-row {
    width: 100%;
  }
}

.compact-input {
  width: 100%;
  padding: 8px 12px;
  font-size: 14px;
}

.compact-select {
  width: 100%;
  padding: 8px 12px;
  font-size: 14px;
  height: 40px;
}

/* Styles pour le tableau dans le popup */
#interpretationsTable {
  margin-top: 16px;
  
  .col {
    padding: 12px 8px;
    vertical-align: middle;
  }
  
  tfoot {
    background: #f8f9fa;
    
    .col {
      padding: 12px 8px;
    }
  }
}

@media (max-width: 768px) {
  .main {
    padding: 16px;
  }
  
  .informations {
    flex-direction: column;
    gap: 16px;
    align-items: flex-start;
  }
  
  .btn {
    width: 100%;
    justify-content: flex-start;
  }
  
  .details-popup {
    min-width: unset;
    width: 95vw;
    padding: 20px;
  }
  
  .action-content {
    flex-direction: column;
  }
  
  .ok {
    flex-wrap: wrap;
  }
}
</style>