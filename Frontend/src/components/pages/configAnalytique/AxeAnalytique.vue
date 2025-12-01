<script setup>
import { ref, onMounted } from "vue";
import { useAxes } from "@/composables/useAxes";
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
import BoutonIcon from "@/components/atoms/Bouton-icon.vue";
import Counter from "@/components/atoms/counter.vue";
import LoadingText from "@/components/atoms/Loading-text.vue";


const openForm = ref(false);
const openImport = ref(false);
const opendelete = ref(false);
const id_to_delete = ref(null);

const {
  axes,
  form,
  isEditing,
  editingId,
  loading,
  nombreLignesLoader,
  file,
  importMessage,
  importSuccess,
  fetchAxes,
  saveAxe,
  editAxe,
  cancelEdit,
  deleteAxe,
  onFileChange,
  uploadFile } = useAxes();
onMounted(fetchAxes);
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
} = usePagination(axes)

</script>

<template>
  <PageAnalyse :menu="'Saisie Analytique'" :sousmenu="'Axe Analytique'">
    <transition name="fade">
      <PopUp v-if="opendelete">
        <Icon :color="'primary'" :icon="'bi bi-envelope'" />
        <Texte :type="'bold-dark'" texte="Supprimer cet axe ?" />
        <Texte :type="'dark'"
          texte="Une fois l'opération faite, la suppression sera irréversible" />
        <div class="PPbtn">
          <Bouton @click="deleteAxe(id_to_delete), opendelete = false" :type="'input'" :texte="'Confirmer'" />
        <Bouton @click="opendelete = false" :type="'cancel'" :texte="'Annuler'" />
        </div>
      </PopUp>
    </transition>
    <transition name="fade">
      <PopUp v-if="openForm">
        <form @submit.prevent="saveAxe" class="mb-6 space-y-3 bg-gray-100 p-4 rounded">
          <Texte :texte="'Ajouter une axe analytique'" :type="'dark'" />
          <Input v-model="form.axe" placeholder="Nom de l'Axe" type="text" required />
          <Textarea v-model="form.description" placeholder="Description" required />
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
        <FileInput :reference="'file'" :file-name="file" :methode="onFileChange" />
        <div class="btn-form">
          <Bouton @click="uploadFile" type="input" :texte="'Importer'" redirection="" />
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
          <Counter v-if="axes.length > 0" :number="axes.length" />
          <Counter v-if="axes.length == 0" :number="0" />
          axes analytique disponibles.
        </p>
        <div class="btn">
          <!-- <div class="iconbtn">
                  <i class="bi bi-file-earmark-pdf-fill"></i>
          </div> -->
          <Bouton type="primary" texte="Importer" redirection="" @click="openImport = !openImport" />
          <Bouton type="primary" texte="Ajouter" redirection="" @click="openForm = !openForm" />
        </div>
      </div>
      <div class="filters">
      </div>
      <!-- Tableau des axes -->
      <transition name="fade">
        <div class="content">
          <table class="table" id="axesTable">
            <thead>
              <tr class="">
                <th class="col">#</th>
                <th class="col">Axe</th>
                <th class="col">Description</th>
                <th class="col">Actions</th>
              </tr>
            </thead>
            <tbody>

              <tr v-for="axe in donneesPagination" :key="axe.id_axe" v-if="!loading">
                <td class="col">{{ axe.id_axe }}</td>
                <td class="col">{{ axe.axe }}</td>
                <td class="col">{{ axe.description }}</td>
                <td class="col text-center">
                  <BoutonIcon @click="editAxe(axe), openForm = true" icon-name="pen-fill" :type="'edit'" />
                  <BoutonIcon @click="id_to_delete = axe.id_axe, opendelete = true" icon-name="trash-fill" :type="'cancel'" />
                </td>
              </tr>
              <tr v-if="loading" v-for="n in nombreLignesLoader" :key="'loader-' + n">
                <td class="col">
                  <LoadingText :type="'line-1'" />
                </td>
                <td class="col">
                  <LoadingText :type="'line-1'" />
                </td>
                <td class="col">
                  <LoadingText :type="'line-1'" />
                </td>
                <td class="col">
                  <LoadingText :type="'line-1'" />
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </transition>
      <Pagination :donnees="centres" :current-page="currentPage" :items-per-page="itemsPerPage"
        :total-pages="totalPages" :go-to-page="goToPage" :previous-page="previousPage" :next-page="nextPage" />
    </div>
  </PageAnalyse>
</template>
<style lang="scss" scoped>
.iconbtn{
  display: flex;
  align-items: center;
  justify-content: center;
  width: 42px;
  height: 42px;
  border-radius: 50%;
  @include glass();
  cursor: pointer;
  i{
    color: #e25252;
    font-size: 20px;
  }
}
.main {
  @include glass();
  min-height: 82vh;
  border-radius: $radius-pm;
  @include position-contenus(flex, baseline, center);
  padding: 0 24px 24px 24px;
  margin: 12px;
  // height: 100%;
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
  display: flex;
  background-color: transparent;
  color: #4A4A4A;
  font-family: Stara;
  font-size: 32px;
  font-style: normal;
  font-weight: 600;
  line-height: normal;
  gap: 5px;
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

.content {
  overflow-y: auto;
  /* Scroll vertical */
  // background-color: #fff;
  width: 100%;
  height: 60vh;
  /* Ajuste selon tes besoins */
  border-radius: $radius-pm;
}

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
.PPbtn{
  display: flex;
  flex-direction: column;
  gap: 10px;
}
</style>
