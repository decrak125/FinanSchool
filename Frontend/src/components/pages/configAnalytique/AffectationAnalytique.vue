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

const openForm = ref(false);
const openImport = ref(false);
const loading = ref(true);

const {
    affectations, centres, comptes, file, showVentilationForm,
    showDetails, totalTauxClass, isFormValid, hasDuplicateCentres,
    selectedGroup,
    editingVentilation,
    form, isEditing, message,
    fetchData, save, remove, resetForm, onFileChange, uploadFile,
    searchTerm, suggestions, showSuggestions,
    searchCompte, selectCompte,
    filterSearchTerm,
    filterSelectedCentre,
    filteredAffectations,
    editVentilation,adjustTauxIfNeeded,
    saveVentilation,
    removeVentilation,
    showVentilationDetails,
    editGroup, removeBySousCompte,
    affectationsGrouped
} = useAffectations();

// Pagination avec les données groupées
const {
  currentPage,
  itemsPerPage,
  totalPages,
  donneesPagination,
  previousPage,
  nextPage,
  goToPage
} = usePagination(affectationsGrouped)


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

// Ajouter une ventilation - CORRIGÉE
const addVentilation = () => {
  if (!form.value.ventilations) form.value.ventilations = [];
  
  // Calculer le total actuel
  const totalTaux = form.value.ventilations.reduce((sum, v) => {
    return sum + Number(Number(v.taux || 0).toFixed(2));
  }, 0);
  
  const remainingTaux = Number((100 - totalTaux).toFixed(2));
  
  if (remainingTaux <= 0) {
    alert("Le total des taux atteint déjà 100% !");
    return;
  }

  // Ajouter la nouvelle ventilation avec le taux restant
  form.value.ventilations.push({
    id_centre: null,
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
  if (!isEditing.value) {
    resetForm();
  }
  openForm.value = true;
};
</script>

<template>
  <PageAnalyse>
    <!-- Popup principal pour créer/modifier les affectations -->
    <transition name="fade">
      <PopUp v-if="openForm">
        <form @submit.prevent="handleSave" class="mb-6 space-y-3 bg-gray-100 p-4 rounded">
          <Texte 
            :texte="isEditing ? 'Modifier les ventilations' : 'Nouvelle affectation'" 
            :type="'dark'" 
          />

          <!-- Sélection du compte (seulement en création) -->
          <div v-if="!isEditing">
            <Input 
              type="text" 
              v-model="searchTerm" 
              @input="searchCompte" 
              label="Libellé du compte" 
              required 
            />

            <!-- Suggestions -->
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

          <!-- Affichage du compte en mode édition -->
          <div v-else class="selected-compte">
            <p class="text-sm font-semibold text-gray-700">Compte sélectionné :</p>
            <p class="text-lg">{{ searchTerm }}</p>
          </div>

          <!-- Liste des ventilations -->
          <div class="ventilations-list space-y-4">
            <div 
              v-for="(vent, index) in form.ventilations" 
              :key="index" 
              class="ventilation-item bg-white p-4 rounded border border-gray-200"
            >
              <div class="ventilation-header flex items-center justify-between mb-3">
                <h3 class="font-semibold text-gray-800">Ventilation {{ index + 1 }}</h3>
                <button 
                  type="button" 
                  @click="removeVentilation(index)" 
                  class="text-red-500 hover:text-red-700 font-bold text-lg"
                  :disabled="form.ventilations.length <= 1"
                  :class="{ 'opacity-50 cursor-not-allowed': form.ventilations.length <= 1 }"
                >
                  ✕
                </button>
              </div>

              <div class="ventilations">
                <Select 
                  v-model="vent.id_centre" 
                  :label="'Centre Analytique'"
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
                </Select>

                <Input 
                  type="number" 
                  v-model.number="vent.taux" 
                  label="Taux (%)" 
                  min="0" 
                  max="100" 
                  step="0.01"
                  required 
                  class="w-full"
                  @blur="adjustTauxIfNeeded"
                />
                <Textarea 
                  v-model="vent.description" 
                  label="Description" 
                  class="mt-3" 
                  placeholder="Description de la ventilation..."
                />
              </div>
            </div>
          </div>

          <!-- Bouton pour ajouter une ventilation -->
          <div class="flex justify-between items-center">
            <div class="total-taux">
              <p class="text-sm font-semibold" :class="totalTauxClass">
                Total des taux : {{ totalTauxForm.toFixed(2) }}%
              </p>
            </div>
            <button 
              type="button" 
              @click="addVentilation"
              class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600 transition flex items-center gap-2"
              :disabled="totalTauxForm >= 100"
              :class="{ 'opacity-50 cursor-not-allowed': totalTauxForm >= 100 }"
            >
              <span>+</span>
              <span>Ajouter un centre</span>
            </button>
          </div>

          <!-- Messages d'information -->
          <div v-if="totalTauxForm !== 100" class="taux-warning">
            <p class="text-amber-600 text-sm">
              ⚠️ Le total des taux doit être exactement 100% (actuellement : {{ totalTauxForm.toFixed(2) }}%)
            </p>
          </div>

          <div v-if="hasDuplicateCentres" class="duplicate-warning">
            <p class="text-red-600 text-sm">
              ❌ Vous ne pouvez pas avoir plusieurs ventilations pour le même centre
            </p>
          </div>

          <!-- Boutons d'action -->
          <div class="btn-form">
            <Bouton 
              type="submit"
              :texte="isEditing ? 'Mettre à jour' : 'Créer'" 
              redirection=""
              :disabled="!isFormValid"
            />
            <Bouton 
              @click="cancelEdit" 
              type="cancel" 
              :texte="'Annuler'" 
            />
          </div>
        </form>
      </PopUp>
    </transition>

    <!-- Popup pour éditer une ventilation individuelle -->
    <transition name="fade">
      <PopUp v-if="showVentilationForm">
        <form @submit.prevent="saveVentilation">
          <Texte :texte="'Modifier la ventilation'" :type="'dark'" />

          <!-- Centre Analytique -->
          <Select v-model="editingVentilation.id_centre" :label="'Centre Analytique'" required>
            <option value="" disabled>Sélectionner un centre</option>
            <option v-for="centre in centres" :key="centre.id_centre" :value="centre.id_centre">
              {{ centre.nom }}
            </option>
          </Select>

          <!-- Taux -->
          <Input type="number" v-model="editingVentilation.taux" label="Taux (%)" min="0" max="100" required />

          <!-- Description -->
          <Textarea v-model="editingVentilation.description" label="Description" />

          <!-- Boutons -->
          <div class="btn-form">
            <Bouton type="submit" :texte="'Modifier'" redirection="" />
            <Bouton @click="showVentilationForm = false; editingVentilation = null; showDetails=true" type="cancel" :texte="'Annuler'" />
          </div>
        </form>
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

    <div class="main">
      <ContentHeader :menu="'Saisie Analytique'" :sousmenu="'Affectation Analytique'" />
      <div class="informations">
        <p class="Count-content">
          <Counter v-if="affectationsGrouped.length > 0" :number="affectationsGrouped.length" />
          <Counter v-if="affectationsGrouped.length == 0" :number="0" />
          affectations analytique faite(s).
        </p>
        <div class="btn">
          <Bouton type="primary" texte="Importer" redirection="" @click="openImport = !openImport" />
          <Bouton type="primary" texte="Ajouter une Affectation" redirection="" @click="openFormPopup" />
        </div>
      </div>

      <!-- Section Filtres -->
      <div class="filtres">
        <searchbar v-model="filterSearchTerm" type="text" placeholder="Code ou libellé du compte..." />

        <FilterSelect v-model="filterSelectedCentre" :label="''">
          <option value="">Centres</option>
          <option v-for="centre in centres" :key="centre.id_centre" :value="centre.id_centre">
            {{ centre.nom }}
          </option>
        </FilterSelect>
      </div>

      <!-- Tableau des affectations -->
      <div class="loading" v-if="loading">
        <BoutonLoading :type="'transparent'" />
      </div>
      <transition name="fade">
        <div class="content">
          <table class="table" id="axesTable" v-if="!loading">
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
              <tr v-for="group in donneesPagination" :key="group.Id_Sous_compte">
                <td class="col">{{ group.Code_sous_compte }}</td>
                <td class="col">{{ group.Libelle }}</td>
                <td class="col">{{ group.ventilations.length }}</td>
                <td class="col">{{group.ventilations.reduce((sum, v) => sum + Number(v.taux || 0), 0).toFixed(2)}}%</td>
                <td class="col">
                  <BoutonIcon @click="showVentilationDetails(group)" icon-name="eye" :type="'edit'" />
                  <BoutonIcon @click="editGroup(group); openForm = true" icon-name="pen" :type="'edit'" />
                  <BoutonIcon
                    @click="removeBySousCompte(group.Id_Sous_compte), showDetails=false" icon-name="trash" :type="'cancel'"
                  />
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </transition>

      <!-- Popup pour voir les détails des ventilations -->
      <transition name="fade">
        <PopUp v-if="showDetails">
          <div class="details-popup">
            <Texte
              :texte="'Détails des ventilations: ' + selectedGroup?.Code_sous_compte + ' - ' + selectedGroup?.Libelle"
              :type="'dark'" />
            <div class="ventilation-details">
              <table class="table" id="axesTable">
                <thead>
                  <tr>
                    <th class="col">Centre</th>
                    <th class="col">Description</th>
                    <th class="col">Taux</th>
                    <th class="col">Actions</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="vent in selectedGroup?.ventilations || []" :key="vent.id_affectation">
                    <td class="col">{{ vent.centre_nom }}</td>
                    <td class="col">{{ vent.description }}</td>
                    <td class="col">{{ Number(vent.taux || 0).toFixed(2) }}%</td>
                    <td class="col">
                      <BoutonIcon @click="editVentilation(vent), showDetails=false" icon-name="pen" :type="'edit'" class="mr-2" />
                      <BoutonIcon @click="remove(vent.id_affectation), showDetails=false" icon-name="trash" :type="'cancel'" />
                    </td>
                  </tr>
                </tbody>
                <tfoot id="footable">
                  <td class="col">Total</td>
                  <td></td>
                  <td class="col">{{selectedGroup?.ventilations?.reduce((sum, v) => sum + Number(v.taux || 0), 0).toFixed(2)}}%</td>
                  <td></td>
                </tfoot>
              </table>
            </div>

            <div class="btn-form">
              <Bouton @click="showDetails = false" type="cancel" :texte="'Fermer'" />
            </div>
          </div>
        </PopUp>
      </transition>

      <Pagination :donnees="filteredAffectations" :current-page="currentPage" :items-per-page="itemsPerPage"
        :total-pages="totalPages" :go-to-page="goToPage" :previous-page="previousPage" :next-page="nextPage" />
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
  @include position-contenus(flex, center, flex-start);
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
}

.sugg-list {
  cursor: pointer;
  border-bottom: 1px solid #C5C5C5;
  font-family: $stara-medium;
  font-size: 12px;
  list-style: none;
  padding-left: 0;
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
  width: 100%;
}

.ventilations {
  display: flex;
}

#footable {
  font-family: $stara-bold;
  font-size: 16px;
  background-color: #f3f3f3;
}
</style>