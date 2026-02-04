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
import LoadingText from '@/components/atoms/Loading-text.vue';

const openForm = ref(false);
const openImport = ref(false);
const opendelete = ref(false);
const id_to_delete = ref(null);
const {
  API_URL,
  centres,
  axes,
  // types,
  loading,
  nombreLignesLoader,
  form,
  isEditing,
  editingId,
  file,
  importMessage,
  importSuccess,
  fetchCentres,
  fetchAxes,
  // fetchTypes,
  saveCentre,
  onFileChange,
  editCentre,
  cancelEdit,
  deleteCentre,
  resetForm,
  getAxeName,
  // getTypeName,
  uploadFile,
  // Nouvelles fonctions de filtre
  searchTerm,
  selectedAxe,
  // selectedType,
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
  <PageAnalyse :menu="'Saisie Analytique'" :sousmenu="'Centre de coûts'">
    <transition name="fade">
      <PopUp v-if="opendelete">
        <Icon :color="'primary'" :icon="'bi bi-envelope'" />
        <Texte :type="'bold-dark'" texte="Supprimer ce centre ?" />
        <Texte :type="'dark'" texte="Une fois l'opération faite, la suppression sera irréversible" />
        <div class="PPbtn">
          <Bouton @click="deleteCentre(id_to_delete), opendelete = false" :type="'input'" :texte="'Confirmer'" />
          <Bouton @click="opendelete = false" :type="'cancel'" :texte="'Annuler'" />
        </div>
      </PopUp>
    </transition>
    <transition name="fade">
      <PopUp v-if="openForm">
        <form @submit.prevent="saveCentre" class="mb-6 space-y-3 bg-gray-100 p-4 rounded">
          <Texte :texte="'Créer un centre de coûts'" :type="'dark'" />
          <div class="popupContent">
            <div class="gauche">
              <Input v-model="form.nom" placeholder="Nom du centre" type="text" required />
              <Textarea v-model="form.description" placeholder="Description" required />
            </div>
            <div class="droite">
              <div>
                <!-- <Select v-model="form.id_axe"  :placeholder="'Axe analytique'" hidden>
                  <option value="2" :key="2">Choisir un axe</option>
                  <option v-for="axe in axes" :key="axe.id_axe" :value="axe.id_axe">{{ axe.axe }}</option>
                </Select> -->
              </div>
              <!-- <div>
              <Select v-model="form.id_type" :label="'Type de centre'">
                <option value="" disabled>Choisir un type</option>
                <option v-for="type in types" :key="type.id_type" :value="type.id_type">{{ type.code }}</option>
              </Select>
            </div> -->
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
      <div class="informations">
        <p class="Count-content">
          <Counter v-if="centres.length > 0" :number="filteredCentres.length" />
          <Counter v-if="centres.length == 0" :number="0" /> centres de coûts disponibles.
        </p>
        <div class="btn">
          <Bouton type="primary" texte="Importer" redirection="" @click="openImport = !openImport" />
          <Bouton type="primary" texte="Ajouter" redirection="" @click="openForm = !openForm" />
        </div>
      </div>

      <!-- Section Filtres -->
      <div class="filtres">
        <div class="ok">
          <searchbar v-model="searchTerm" type="text" placeholder="Nom du centre..." />
          <!-- Filtre par axe -->
          <!-- <FilterSelect v-model="selectedAxe">
            <option value="">Axes</option>
            <option v-for="axe in axes" :key="axe.id_axe" :value="axe.id_axe">
              {{ axe.axe }}
            </option>
          </FilterSelect> -->
          <BoutonIcon v-if="searchTerm || selectedAxe" @click="resetFilters" type="cancel" :icon-name="'x-lg'" />
        </div>
        <div class="iconbtn">
          <i class="bi bi-file-earmark-pdf-fill"></i>
        </div>
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
                <!-- <th class="col">Axe</th> -->
                <!-- <th class="col">Type</th> -->
                <th class="col">Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="centre in donneesPagination" :key="centre.id_centre" v-if="loading == false">
                <td class="col">{{ centre.id_centre }}</td>
                <td class="col">{{ centre.nom }}</td>
                <td class="col">{{ centre.description }}</td>
                <!-- <td class="col">{{ getAxeName(centre.id_axe) }}</td> -->
                <!-- <td class="col">{{ getTypeName(centre.id_type) }}</td> -->
                <td class="col text-center">
                  <div class="action-content">
                    <BoutonIcon @click="editCentre(centre), openForm = true" icon-name="pen-fill" :type="'edit'" />
                    <BoutonIcon @click="id_to_delete = centre.id_centre, opendelete = true" icon-name="trash-fill"
                      :type="'cancel'" />
                  </div>

                </td>
              </tr>
              <tr v-if="loading" v-for="n in nombreLignesLoader" :key="'loader-' + n">
                <td class="col">
                  <LoadingText type="line-1" />
                </td>
                <td class="col">
                  <LoadingText type="line-2" />
                </td>
                <td class="col">
                  <LoadingText type="line-4" />
                </td>
                <td class="col">
                  <LoadingText type="line-1" />
                </td>
                <td class="col">
                  <LoadingText type="line-1" />
                </td>
              </tr>

            </tbody>
          </table>
        </div>
      </transition>

      <!-- Message si aucun résultat -->
      <!-- <div v-if="filteredCount === 0" class="text-center py-8 text-gray-500">
        Aucun centre ne correspond aux critères de recherche.
      </div> -->

      <Pagination :donnees="filteredCentres" :current-page="currentPage" :items-per-page="itemsPerPage"
        :total-pages="totalPages" :go-to-page="goToPage" :previous-page="previousPage" :next-page="nextPage" />
    </div>
  </PageAnalyse>
</template>
<style lang="scss" scoped>
.ok {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
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

.main {
  @include glass();
  height: 82vh;
  border-radius: $radius-pm;
  @include position-contenus(flex, baseline, center);
  padding: 0 24px 24px 24px;
  margin: 12px;
  height: 100%;
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
  flex-direction: column;
  gap: 10px;
  padding-top: 10px;
}

.Count-content {
  gap: 5px;
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
  height: 60vh;
  /* Ajuste selon tes besoins */
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


.fade-enter-to,
.fade-leave-from {
  opacity: 1;
  transform: scale(1);
}

.popupContent {
  @include position-contenus(flex, center, flex-start);
  flex-direction: column;
  gap: 10px;
}

.filtres {
  @include position-contenus(flex, space-between, center);
  padding: 0 0;
  align-self: self-start;
  // background-color: #fff;
  gap: 10px;
  width: 100%;
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
</style>