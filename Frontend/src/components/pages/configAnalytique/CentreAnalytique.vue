<script setup>
import { ref, onMounted, computed } from 'vue';
import { useCentres } from '@/composables/useCentres';
import PageAnalyse from "@/components/template/Page-analyse.vue";
import ContentHeader from "@/components/molecules/Analyse/Content-header.vue";
import Bouton from "@/components/atoms/Bouton.vue";
import Input from "@/components/atoms/Input.vue";
import Textarea from "@/components/atoms/Textarea.vue";
import Texte from "@/components/atoms/Texte.vue";
import PopUp from "@/components/molecules/Analyse/Pop-up.vue";
import FileInput from "@/components/atoms/File-input.vue";
import Pagination from "@/components/molecules/Pagination.vue";
import { usePagination } from "@/composables/usePagination";
import Select from '@/components/atoms/Select.vue';
import BoutonIcon from "@/components/atoms/Bouton-icon.vue";
import FilterSelect from '@/components/atoms/Filter-select.vue';
import searchbar from '@/components/atoms/searchbar.vue';
import Counter from "@/components/atoms/counter.vue";

const openForm = ref(false);
const openImport = ref(false);
const {
  API_URL,
  centres,
  axes,
  types,
  form,
  isEditing,
  editingId,
  file,
  importMessage,
  importSuccess,
  fetchCentres,
  fetchAxes,
  fetchTypes,
  saveCentre,
  onFileChange,
  editCentre,
  cancelEdit,
  deleteCentre,
  resetForm,
  getAxeName,
  getTypeName,
  uploadFile,
  // Nouvelles fonctions de filtre
  searchTerm,
  selectedAxe,
  selectedType,
  filteredCentres,
  resetFilters
} = useCentres();

// Utilisez filteredCentres pour la pagination au lieu de centres
const {
  currentPage,
  itemsPerPage,
  totalPages,
  startIndex,
  endIndex,
  donneesPagination,
  previousPage,
  nextPage,
  goToPage,
  resetPagination
} = usePagination(filteredCentres)

const displayNumber = ref(0);

// Mettez à jour le compteur pour utiliser filteredCentres
onMounted(() => {
  const interval = setInterval(() => {
    displayNumber.value = Math.floor(Math.random() * (centres.value.length + 10));
  }, 150);

  setTimeout(() => {
    clearInterval(interval);
    displayNumber.value = centres.value.length;
  }, 1500);
});

// Computed pour le nombre de résultats filtrés
const filteredCount = computed(() => {
  return filteredCentres.value.length;
});
</script>

<template>
  <PageAnalyse>
    <transition name="fade">
      <PopUp v-if="openForm">
        <form @submit.prevent="saveCentre" class="mb-6 space-y-3 bg-gray-100 p-4 rounded">
          <Texte :texte="'Créer un centre analytique'" :type="'dark'" />
          <div class="popupContent">
            <div class="gauche">
            <Input v-model="form.nom" label="Nom du centre" type="text" required />
            <Textarea v-model="form.description" label="Description" required />
          </div>
          <div class="droite">
            <div>
              <Select v-model="form.id_axe" :label="'Axe analytique'">
                <option value="" disabled>Choisir un axe</option>
                <option v-for="axe in axes" :key="axe.id_axe" :value="axe.id_axe">{{ axe.axe }}</option>
              </Select>
            </div>
            <div>
              <Select v-model="form.id_type" :label="'Type de centre'">
                <option value="" disabled>Choisir un type</option>
                <option v-for="type in types" :key="type.id_type" :value="type.id_type">{{ type.code }}</option>
              </Select>
            </div>
          </div>
          </div>
          <div class="btn-form">
            <Bouton v-if="!isEditing" type="input" :texte="'Créer'" redirection="" />
            <Bouton v-if="isEditing" type="input" :texte="'Modifier'" redirection="" />
            <Bouton type="cancel" :texte="'Annuler'" @click="cancelEdit, openForm = false" />
          </div>
        </form>
      </PopUp>
    </transition>
    <transition name="fade">
      <PopUp v-if="openImport">
        <FileInput :reference="'fileInput'" :file-name="file" :methode="onFileChange" />
        <div class="btn-form">
          <Bouton type="input" :texte="'Importer'" redirection="" @click="uploadFile" />
          <Bouton type="cancel" :texte="'Annuler'" @click="cancelEdit, openImport = false" />
          <p v-if="importMessage" :class="importSuccess ? 'text-green' : 'text-red'">
            {{ importMessage }}
          </p>
        </div>
      </PopUp>
    </transition>
    <div class="main">
      <ContentHeader :menu="'Saisie Analytique'" :sousmenu="'Centre Analytique'" />
      <div class="informations">
        <p class="Count-content">
          <Counter v-if="centres.length>0" :number="centres.length" />
            <Counter v-if="centres.length == 0" :number="0" /> centres analytique disponibles.</p>
        <div class="btn">
          <Bouton type="primary" texte="Importer" redirection="" @click="openImport = !openImport" />
          <Bouton type="primary" texte="Ajouter un centre" redirection="" @click="openForm = !openForm" />
        </div>
      </div>
      
      <!-- Section Filtres -->
      <div class="filtres">
            <searchbar
              v-model="searchTerm"
              type="text"
              placeholder="Nom du centre..."
            />
          <!-- Filtre par axe -->
            <FilterSelect
              v-model="selectedAxe"
            >
              <option value="">Axes</option>
              <option 
                v-for="axe in axes" 
                :key="axe.id_axe" 
                :value="axe.id_axe"
              >
                {{ axe.axe }}
              </option>
            </FilterSelect>

          <!-- Filtre par type -->
            <FilterSelect
              v-model="selectedType"
            >
              <option value="">Types</option>
              <option 
                v-for="type in types" 
                :key="type.id_type" 
                :value="type.id_type"
              >
                {{ type.code }}
              </option>
            </FilterSelect>
            <!-- <i @click="resetFilters" class="bi bi-x-circle-fill"></i> -->
      </div>
      <!-- Tableau des axes - utilise donneesPagination qui vient maintenant de filteredCentres -->
      <transition name="fade">
        <div class="content">
          <table class="table" id="axesTable">
          <thead>
            <tr class="">
              <th class="col">#</th>
              <th class="col">Nom</th>
              <th class="col">Description</th>
              <th class="col">Axe</th>
              <th class="col">Type</th>
              <th class="col">Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="centre in donneesPagination" :key="centre.id_centre">
              <td class="col">{{ centre.id_centre }}</td>
              <td class="col">{{ centre.nom }}</td>
              <td class="col">{{ centre.description }}</td>
              <td class="col">{{ getAxeName(centre.id_axe) }}</td>
              <td class="col">{{ getTypeName(centre.id_type) }}</td>
              <td class="col text-center">
                  <BoutonIcon @click="editCentre(centre), openForm = true" icon-name="pen" :type="'edit'" />
                <BoutonIcon @click="deleteCentre(centre.id_centre)" icon-name="trash" :type="'cancel'" />
              </td>
            </tr>
          </tbody>
        </table>
        </div>
      </transition>

      <!-- Message si aucun résultat -->
      <div v-if="filteredCount === 0" class="text-center py-8 text-gray-500">
        Aucun centre ne correspond aux critères de recherche.
      </div>

      <Pagination 
        :donnees="filteredCentres" 
        :current-page="currentPage" 
        :items-per-page="itemsPerPage"
        :total-pages="totalPages" 
        :go-to-page="goToPage" 
        :previous-page="previousPage" 
        :next-page="nextPage" 
      />
    </div>
  </PageAnalyse>
</template><style lang="scss" scoped>
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
  // flex-direction: column;
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
.content {
  overflow-y: auto;
  /* Scroll vertical */
  // background-color: #fff;
  width: 100%;
  max-height: 53vh;
  /* Ajuste selon tes besoins */
  border-radius: $radius-pm;
}

/* Personnalisation de la scrollbar */
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

.fade-enter-to,
.fade-leave-from {
  opacity: 1;
  transform: scale(1);
}
.popupContent{
  @include position-contenus(flex,center, flex-start);
  gap: 10px;
}
.filtres{
  @include position-contenus(flex, flex-start, center);
  padding: 0 0;
  align-self: self-start;
  // background-color: #fff;
  gap: 10px;
  width: 100%;
}
</style>