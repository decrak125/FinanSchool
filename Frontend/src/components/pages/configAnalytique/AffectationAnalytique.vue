<script setup>
import { ref, onMounted } from "vue";
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

const openForm = ref(false);
const openImport = ref(false);
const displayNumber = ref(0);
const loading = ref(true);

const {
  affectations, centres, comptes, file,
  form, isEditing, fileInput, message, importSuccess,
  fetchData, save, edit, remove, resetForm, onFileChange, uploadFile,
  searchTerm, suggestions, showSuggestions,
  searchCompte, selectCompte
} = useAffectations();

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
} = usePagination(affectations)

onMounted(() => {
  const interval = setInterval(() => {
    displayNumber.value = Math.floor(Math.random() * (affectations.value.length + 10));
  }, 150);

  setTimeout(() => {
    clearInterval(interval);
    displayNumber.value = affectations.value.length;
  }, 1500);
});


// const token = localStorage.getItem("token"); 

// if (!token) {
//   window.location.href = "/";
// } else {
//   axios.defaults.headers.common["Authorization"] = `Bearer ${token}`;
// }

onMounted(
  async () => {
    try {
      fetchData();
    } finally {
      loading.value = false;
    }
  }
);


</script>

<template>
  <PageAnalyse>
    <transition name="fade">
      <PopUp v-if="openForm">
        <form @submit.prevent="save" class="mb-6 space-y-3 bg-gray-100 p-4 rounded">
          <Texte :texte="'Nouvelle affectation.'" :type="'dark'" />
          <Input type="text" v-model="searchTerm" @input="searchCompte" label="Libellé du compte" required />
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
          <div>
            <Select v-model="form.id_centre" :label="'Centre Analytique'">
              <option value="" disabled>Sélectionner un centre</option>
              <option v-for="centre in centres" :key="centre.id_centre" :value="centre.id_centre">
                {{ centre.nom }}
              </option>
            </Select>
          </div>
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
          <div v-if="message.text" :class="'text-green'">
            {{ message.text }}
          </div>
        </div>
      </PopUp>
    </transition>
    <div class="main">
      <ContentHeader :menu="'Saisie Analytique'" :sousmenu="'Affectation Analytique'" />
      <div class="informations">
        <p class="Count-content">{{ displayNumber }} affectations analytique faite(s).</p>
        <div class="btn">
          <Bouton type="primary" texte="Importer" redirection="" @click="openImport = !openImport" />
          <Bouton type="primary" texte="Ajouter une Affectation" redirection="" @click="openForm = !openForm" />
        </div>
      </div>
      <div class="filters">
      </div>
      <!-- Tableau des axes -->
      <div class="loading" v-if="loading">
        <BoutonLoading :type="'transparent'" />
      </div>
      <transition name="fade">
        <div class="content">
          <table class="table" id="axesTable" v-if="!loading">
            <thead>
              <tr class="">
                <th class="col">#</th>
                <th class="col">Compte</th>
                <th class="col">Centre</th>
                <th class="col">Description</th>
                <th class="col">Actions</th>
              </tr>
            </thead>
            <tbody>

              <tr v-for="aff in donneesPagination" :key="aff.id_affectation">
                <td class="col">{{ aff.id_affectation }}</td>
                <td class="col">{{ aff.sous_compte?.Code_sous_compte }} - {{ aff.sous_compte?.Libelle }}</td>
                <td class="col">{{ aff.centre?.nom }}</td>
                <td class="col">{{ aff.description }}</td>
                <td class="col">
                  <button @click="edit(aff)" class="bg-yellow-500 text-white px-2 py-1 rounded">✏️</button>
                  <button @click="remove(aff.id_affectation)"
                    class="ml-2 bg-red-600 text-white px-2 py-1 rounded">🗑️</button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </transition>
      <Pagination :donnees="affectations" :current-page="currentPage" :items-per-page="itemsPerPage"
        :total-pages="totalPages" :go-to-page="goToPage" :previous-page="previousPage" :next-page="nextPage" />
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

.loading {
  // background-color: #704545;
  @include position-contenus(flex, center, center);
  height: 400px;
  // flex: 1 0 0;
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
  // border-radius: $radius-pm;
  overflow-y: scroll;
  /* Scroll vertical */
  // background-color: #fff;
  max-height: 250px;
  border: 1px #4A4A4A solid;
}
.sugg-list {
  cursor: pointer;
  border-bottom: 1px solid #C5C5C5;
  font-family: $stara;
  font-size: 12px;
  list-style: none;
  padding-left: 0;
}

/* Personnalisation de la scrollbar */
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
</style>
