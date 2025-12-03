<script setup>
import { ref, onMounted, computed } from "vue";
import { useParametresAnalytique } from "@/composables/useParametresAnalytique";
import PageAnalyse from '@/components/template/Page-analyse.vue';
import Bouton from "@/components/atoms/Bouton.vue";
import Input from "@/components/atoms/Input.vue";
import Textarea from "@/components/atoms/Textarea.vue";
import Texte from "@/components/atoms/Texte.vue";
import PopUp from "@/components/molecules/Analyse/Pop-up.vue";
import BoutonIcon from "@/components/atoms/Bouton-icon.vue";
import searchbar from '@/components/atoms/searchbar.vue';
import Counter from "@/components/atoms/counter.vue";
import Pagination from "@/components/molecules/Pagination.vue";
import { usePagination } from "@/composables/usePagination";
import Select from '@/components/atoms/Select.vue';
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
const showInterpretationForm = ref(false);
const showDetails = ref(false);
const showDeleteConfirm = ref(false);
const editingIndicateur = ref(null);
const editingInterpretation = ref(null);
const itemToDelete = ref(null);
const deleteType = ref(''); // 'indicateur' ou 'interpretation'
const searchTerm = ref('');
const nombreLignesLoader = ref(10);

// Filtres
const filterSearchTerm = ref('');
const filterSelectedNiveau = ref('');

// Formulaires
const formIndicateur = ref({
  libelle: '',
  description: '',
  formule: ''
});

const formInterpretation = ref({
  valeur: '',
  interpretation: '',
  id_niveau_alerte: ''
});

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

// 📌 GESTION DES INTERPRÉTATIONS
const handleCreateInterpretation = async () => {
  try {
    const data = {
      ...formInterpretation.value,
      id_indicateur_analytique: currentIndicateur.value.id_indicateur_analytique
    };
    await createInterpretation(data);
    showInterpretationForm.value = false;
    resetFormInterpretation();
  } catch (error) {
    console.error("Erreur création interprétation:", error);
  }
};

const handleEditInterpretation = (interpretation) => {
  editingInterpretation.value = interpretation.id_interpretation_indicateur;
  formInterpretation.value = { 
    valeur: interpretation.valeur,
    interpretation: interpretation.interpretation,
    id_niveau_alerte: interpretation.id_niveau_alerte.toString()
  };
  showInterpretationForm.value = true;
};

const handleUpdateInterpretation = async () => {
  try {
    await updateInterpretation(editingInterpretation.value, formInterpretation.value);
    showInterpretationForm.value = false;
    resetFormInterpretation();
    editingInterpretation.value = null;
  } catch (error) {
    console.error("Erreur mise à jour interprétation:", error);
  }
};

const confirmDeleteInterpretation = (id) => {
  itemToDelete.value = id;
  deleteType.value = 'interpretation';
  showDeleteConfirm.value = true;
};

const handleDeleteInterpretation = async () => {
  try {
    await deleteInterpretation(itemToDelete.value);
    showDeleteConfirm.value = false;
    itemToDelete.value = null;
    deleteType.value = '';
  } catch (error) {
    console.error("Erreur suppression interprétation:", error);
  }
};

const resetFormInterpretation = () => {
  formInterpretation.value = {
    valeur: '',
    interpretation: '',
    id_niveau_alerte: ''
  };
  editingInterpretation.value = null;
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
  
  // Note: Pour les indicateurs, le filtre par niveau n'est pas applicable
  // car un indicateur peut avoir plusieurs interprétations avec différents niveaux
  
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
          <Bouton @click="deleteType === 'indicateur' ? handleDeleteIndicateur() : handleDeleteInterpretation()" 
                 :type="'input'" :texte="'Confirmer'" />
          <Bouton @click="showDeleteConfirm = false" :type="'cancel'" :texte="'Annuler'" />
        </div>
      </PopUp>
    </transition>

    <!-- POPUP Formulaire Indicateur -->
    <transition name="fade">
      <PopUp v-if="showIndicateurForm">
        <form @submit.prevent="editingIndicateur ? handleUpdateIndicateur() : handleCreateIndicateur()" 
              class="mb-6 space-y-3 bg-gray-100 p-4 rounded">
          <Texte :texte="editingIndicateur ? 'Modifier l\'indicateur' : 'Nouvel indicateur'" :type="'dark'" />
          <div class="popupContent">
              <Input v-model="formIndicateur.libelle" 
                     placeholder="Libellé de l'indicateur" 
                     type="text" 
                     required />
            
              <Textarea v-model="formIndicateur.description" 
                       placeholder="Description" 
                       required />
            
              <Textarea v-model="formIndicateur.formule" 
                     placeholder="Formule de calcul" 
                     required />
          </div>
          <div class="btn-form">
            <Bouton v-if="!editingIndicateur" type="input" :texte="'Créer'" />
            <Bouton v-if="editingIndicateur" type="input" :texte="'Modifier'" />
            <Bouton type="cancel" :texte="'Annuler'" 
                    @click="showIndicateurForm = false, resetFormIndicateur()" />
          </div>
        </form>
      </PopUp>
    </transition>

    <!-- POPUP Formulaire Interprétation -->
    <transition name="fade">
      <PopUp v-if="showInterpretationForm">
        <form @submit.prevent="editingInterpretation ? handleUpdateInterpretation() : handleCreateInterpretation()" 
              class="mb-6 space-y-3 bg-gray-100 p-4 rounded">
          <Texte :texte="editingInterpretation ? 'Modifier l\'interprétation' : 'Nouvelle interprétation'" 
                :type="'dark'" />
          <div class="popupContent">
            <div class="form-row">
              <Input v-model="formInterpretation.valeur" 
                     placeholder="Valeur seuil" 
                     type="number" 
                     step="0.01" 
                     required />
              <small class="form-help">Valeur à partir de laquelle cette interprétation s'applique</small>
            </div>
            
            <div class="form-row">
              <Textarea v-model="formInterpretation.interpretation" 
                       placeholder="Interprétation" 
                       required />
            </div>
            
            <div class="form-row">
              <Select v-model="formInterpretation.id_niveau_alerte" 
                      :placeholder="'Niveau d\'alerte'" 
                      required>
                <option value="" disabled>Sélectionner un niveau</option>
                <option v-for="niveau in niveaux" 
                        :key="niveau.id_niveau_alerte"
                        :value="niveau.id_niveau_alerte">
                  {{ niveau.libelle }}
                </option>
              </Select>
            </div>
          </div>
          <div class="btn-form">
            <Bouton v-if="!editingInterpretation" type="input" :texte="'Créer'" />
            <Bouton v-if="editingInterpretation" type="input" :texte="'Modifier'" />
            <Bouton type="cancel" :texte="'Annuler'" 
                    @click="showInterpretationForm = false, resetFormInterpretation()" />
          </div>
        </form>
      </PopUp>
    </transition>

    <!-- POPUP Détails Indicateur -->
    <transition name="fade">
      <PopUp v-if="showDetails && currentIndicateur">
        <div class="details-popup">
          <div class="popuphead">
            <Texte :type="'bold-dark'" 
                   :texte="'Détails: ' + currentIndicateur.libelle" />
            <div class="popup-actions">
              <BoutonIcon @click="handleEditIndicateur(currentIndicateur)" 
                         icon-name="pen-fill" :type="'edit'" />
              <BoutonIcon @click="confirmDeleteIndicateur(currentIndicateur.id_indicateur_analytique)" 
                         icon-name="trash-fill" :type="'cancel'" />
              <BoutonIcon @click="showDetails = false" 
                         icon-name="x-lg" :type="'cancel'" />
            </div>
          </div>
          
          <div class="details-content">
            <div class="detail-section">
              <Texte :type="'small-dark'" :texte="'Description'" />
              <p class="detail-text">{{ currentIndicateur.description }}</p>
            </div>
            
            <div class="detail-section">
              <Texte :type="'small-dark'" :texte="'Formule'" />
              <div class="formule-box">
                <code>{{ currentIndicateur.formule }}</code>
              </div>
            </div>
            
            <div class="interpretations-header">
              <Texte :type="'bold-dark'" :texte="'Interprétations'" />
              <BoutonIcon @click="resetFormInterpretation(), showInterpretationForm = true" 
                         icon-name="plus-lg" :type="'add'" />
            </div>
            
            <div class="interpretations-list">
              <div v-if="interpretations.length === 0" class="no-interpretations">
                <i class="bi bi-info-circle"></i>
                <Texte :type="'dark'" :texte="'Aucune interprétation définie'" />
              </div>
              
              <div v-for="interpretation in interpretations.sort((a, b) => b.valeur - a.valeur)" 
                   :key="interpretation.id_interpretation_indicateur" 
                   class="interpretation-item">
                <div class="interpretation-header">
                  <span class="seuil-badge">≥ {{ interpretation.valeur }}</span>
                  <span class="niveau-badge" 
                        :style="{ backgroundColor: getNiveauCouleur(interpretation.id_niveau_alerte) }">
                    {{ getNiveauLibelle(interpretation.id_niveau_alerte) }}
                  </span>
                </div>
                <div class="interpretation-body">
                  <p>{{ interpretation.interpretation }}</p>
                </div>
                <div class="interpretation-actions">
                  <BoutonIcon @click="handleEditInterpretation(interpretation)" 
                             icon-name="pen-fill" :type="'edit'" />
                  <BoutonIcon @click="confirmDeleteInterpretation(interpretation.id_interpretation_indicateur)" 
                             icon-name="trash-fill" :type="'cancel'" />
                </div>
              </div>
            </div>
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
      </div>

      <!-- Section Filtres -->
      <div class="filtres">
        <div class="ok">
          <searchbar v-model="filterSearchTerm" 
                     type="text" 
                     placeholder="Rechercher un indicateur..." />

          <!-- Filtre par niveau d'alerte (optionnel pour les indicateurs) -->
          <!-- <FilterSelect v-model="filterSelectedNiveau" :label="''">
            <option value="">Tous les niveaux</option>
            <option v-for="niveau in niveaux" 
                    :key="niveau.id_niveau_alerte" 
                    :value="niveau.id_niveau_alerte">
              {{ niveau.libelle }}
            </option>
          </FilterSelect>
 -->
          <BoutonIcon v-if="filterSearchTerm || filterSelectedNiveau" 
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
      <!-- <div class="loading" v-if="loading">
        <LoadingText :type="'line-1'" />
      </div> -->
      
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
                               icon-name="eye-fill" :type="'edit'" />
                    <BoutonIcon @click="handleEditIndicateur(indicateur)" 
                               icon-name="pen-fill" :type="'edit'" />
                    <BoutonIcon @click="confirmDeleteIndicateur(indicateur.id_indicateur_analytique)" 
                               icon-name="trash-fill" :type="'cancel'" />
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
                  :go-to-page="goToPage" 
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

#indicateursTable {
  @include table();
  
  th {
    font-weight: 600;
  }
  
  td {
    vertical-align: middle;
  }
  
  .indicateur-name {
    display: flex;
    align-items: center;
    gap: 8px;
    font-weight: 500;
    
    .bi-graph-up {
      color: $secondary;
    }
  }
  
  .formule-code {
    background: #f8f9fa;
    padding: 4px 8px;
    border-radius: $radius-pm;
    font-family: 'Courier New', monospace;
    color: $primary;
    font-size: 13px;
  }
  
  .no-data {
    text-align: center;
    padding: 40px 20px !important;
    
    .empty-state {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 16px;
      color: #adb5bd;
      
      .bi-graph-up {
        font-size: 48px;
        opacity: 0.5;
      }
    }
  }
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
  flex-direction: column;
  // gap: 10px;
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
  margin-bottom: 20px;
}

.popup-actions {
  display: flex;
  gap: 8px;
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

.details-popup {
  min-width: 600px;
  max-width: 800px;
  max-height: 80vh;
  overflow-y: auto;
  
  .details-content {
    .detail-section {
      margin-bottom: 20px;
      
      .detail-text {
        margin-top: 8px;
        color: #666;
        line-height: 1.6;
      }
      
      .formule-box {
        background: #f8f9fa;
        padding: 16px;
        border-radius: 8px;
        border-left: 4px solid $secondary;
        margin-top: 8px;
        
        code {
          font-family: 'Courier New', monospace;
          font-size: 15px;
          color: #2c3e50;
        }
      }
    }
    
    .interpretations-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin: 30px 0 20px 0;
      padding-top: 20px;
      border-top: 1px solid #f1f3f4;
    }
    
    .interpretations-list {
      .no-interpretations {
        text-align: center;
        padding: 40px 20px;
        color: #adb5bd;
        
        .bi-info-circle {
          font-size: 32px;
          margin-bottom: 16px;
          opacity: 0.5;
        }
      }
      
      .interpretation-item {
        background: #f8f9fa;
        border-radius: 8px;
        padding: 16px;
        margin-bottom: 12px;
        border-left: 4px solid $vert;
        
        .interpretation-header {
          display: flex;
          justify-content: space-between;
          align-items: center;
          margin-bottom: 12px;
          
          .seuil-badge {
            font-weight: 600;
            color: #2c3e50;
            background: white;
            padding: 4px 12px;
            border-radius: 4px;
            font-size: 13px;
          }
          
          .niveau-badge {
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
            color: white;
            text-transform: uppercase;
          }
        }
        
        .interpretation-body {
          p {
            color: #666;
            line-height: 1.6;
            margin: 0;
            font-size: 14px;
          }
        }
        
        .interpretation-actions {
          display: flex;
          justify-content: flex-end;
          gap: 8px;
          margin-top: 12px;
          padding-top: 12px;
          border-top: 1px solid #e9ecef;
        }
      }
    }
  }
}

.form-help {
  display: block;
  margin-top: 6px;
  color: #6c757d;
  font-size: 12px;
}

.form-row {
  width: 100%;
  
  input, textarea, select {
    width: 100%;
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