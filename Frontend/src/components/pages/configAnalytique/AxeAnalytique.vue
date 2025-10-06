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

const openForm = ref(false);
const openImport = ref(false);
const { axes,
  form,
  isEditing,
  editingId,
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
const displayNumber = ref(0);

onMounted(() => {
  const interval = setInterval(() => {
    displayNumber.value = Math.floor(Math.random() * (axes.value.length + 10));
  }, 150);

  setTimeout(() => {
    clearInterval(interval);
    displayNumber.value = axes.value.length;
  }, 1500);
});
</script>

<template>
  <PageAnalyse>
    <transition name="fade">
      <PopUp v-if="openForm">
        <form @submit.prevent="saveAxe" class="mb-6 space-y-3 bg-gray-100 p-4 rounded">
          <Texte :texte="'Créer une axe analytique'" :type="'dark'" />
          <Input v-model="form.axe" label="Nom de l'Axe" type="text" required />
          <Textarea v-model="form.description" label="Description" required />
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
      <ContentHeader :menu="'Saisie Analytique'" :sousmenu="'Axe Analytique'" />
      <div class="informations">
        <p class="Count-content">{{ displayNumber }} axes analytique disponibles.</p>
        <div class="btn">
          <Bouton type="primary" texte="Importer" redirection="" @click="openImport = !openImport" />
          <Bouton type="primary" texte="Ajouter un Axe" redirection="" @click="openForm = !openForm" />
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

            <tr v-for="axe in donneesPagination" :key="axe.id_axe">
              <td class="col">{{ axe.id_axe }}</td>
              <td class="col">{{ axe.axe }}</td>
              <td class="col">{{ axe.description }}</td>
              <td class="col text-center">
                <button @click="editAxe(axe), openForm = true"
                  class="bg-yellow-500 text-white px-2 py-1 rounded">✏️</button>
                <button @click="deleteAxe(axe.id_axe)" class="ml-2 bg-red-600 text-white px-2 py-1 rounded">🗑️</button>
              </td>
            </tr>
          </tbody>
        </table>
        </div>
      </transition>
      <Pagination 
      :donnees="centres" 
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
  @include position-contenus(flex, center, center);
  padding: 32px;
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
  @include text-xs($stara, $vert)
}

.text-red {
  @include text-xs($stara, $rouge)
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

.popupContent{
  @include position-contenus(flex,center, flex-start);
  gap: 10px;
}
</style>
