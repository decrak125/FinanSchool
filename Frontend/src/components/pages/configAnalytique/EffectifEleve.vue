<script setup>
import { ref, onMounted, computed } from 'vue';
import { useEffectifs } from '@/composables/useEffectifs';
import PageAnalyse from "@/components/template/Page-analyse.vue";
import Bouton from "@/components/atoms/Bouton.vue";
import Input from "@/components/atoms/Input.vue";
import Texte from "@/components/atoms/Texte.vue";
import PopUp from "@/components/molecules/Analyse/Pop-up.vue";
import Pagination from "@/components/molecules/Pagination.vue";
import { usePagination } from "@/composables/usePagination";
import Select from '@/components/atoms/Select.vue';
import BoutonIcon from "@/components/atoms/Bouton-icon.vue";
import FilterSelect from '@/components/atoms/Filter-select.vue';
import searchbar from '@/components/atoms/searchbar.vue';
import Counter from "@/components/atoms/counter.vue";
import LoadingText from '@/components/atoms/Loading-text.vue';
import Icon from '@/components/atoms/Icon.vue';

const openForm = ref(false);
const openDelete = ref(false);
const openCopyModal = ref(false);
const idToDelete = ref(null);
const copyMessage = ref("");
const copySuccess = ref(false);
const copyForm = ref({
  date_debut: "",
  date_fin: ""
});

const {
  effectifs,
  exercices,
  loading,
  nombreLignesLoader,
  form,
  isEditing,
  editingId,
  searchTerm,
  selectedExercice,
  filteredEffectifs,
  resetFilters,
  fetchEffectifs,
  fetchExercices,
  checkAndCopyEffectif,
  saveEffectif,
  editEffectif,
  cancelEdit,
  deleteEffectif,
  resetForm,
  getExerciceName,
  getExerciceDates,
  getExerciceStatut
} = useEffectifs();

// Utilisez filteredEffectifs pour la pagination
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
} = usePagination(filteredEffectifs)

const displayNumber = ref(0);

// Mettez à jour le compteur
onMounted(() => {
  const interval = setInterval(() => {
    displayNumber.value = Math.floor(Math.random() * (effectifs.value.length + 10));
  }, 150);

  setTimeout(() => {
    clearInterval(interval);
    displayNumber.value = effectifs.value.length;
  }, 1500);
});

// Computed pour le nombre de résultats filtrés
const filteredCount = computed(() => {
  return filteredEffectifs.value.length;
});

// Computed pour les statistiques
const statistiques = computed(() => {
  if (filteredEffectifs.value.length === 0) return null;

  const total = filteredEffectifs.value.reduce((sum, item) => sum + item.nombre_eleves, 0);
  const moyenne = total / filteredEffectifs.value.length;
  const max = Math.max(...filteredEffectifs.value.map(item => item.nombre_eleves));
  const min = Math.min(...filteredEffectifs.value.map(item => item.nombre_eleves));

  return {
    total,
    moyenne: moyenne.toFixed(2),
    max,
    min
  };
});

// Fonction pour ouvrir le formulaire avec l'exercice sélectionné
const openFormWithExercice = (exerciceId) => {
  form.value.Id_Exercice_comptable = exerciceId;
  openForm.value = true;
};

// Fonction pour vérifier et copier l'effectif
const handleCheckAndCopy = async () => {
  if (!copyForm.value.date_debut || !copyForm.value.date_fin) {
    copyMessage.value = "Veuillez sélectionner les dates de l'exercice.";
    copySuccess.value = false;
    return;
  }

  const result = await checkAndCopyEffectif(
    copyForm.value.date_debut,
    copyForm.value.date_fin
  );

  copyMessage.value = result.message;
  copySuccess.value = result.success;

  if (result.success) {
    fetchEffectifs();
    setTimeout(() => {
      openCopyModal.value = false;
      copyForm.value = { date_debut: "", date_fin: "" };
      copyMessage.value = "";
    }, 2000);
  }
};

// Formater la date pour l'input date
const formatDateForInput = (dateString) => {
  if (!dateString) return "";
  const date = new Date(dateString);
  return date.toISOString().split('T')[0];
};
</script>

<template>
  <PageAnalyse :menu="'Gestion pédagogique'" :sousmenu="'Effectif des élèves'">

    <!-- Modal de suppression -->
    <transition name="fade">
      <PopUp v-if="openDelete">
        <!-- <Icon :color="'primary'" :icon="'bi bi-exclamation-triangle'" /> -->
        <Texte :type="'bold-dark'" texte="Supprimer cet effectif ?" />
        <Texte :type="'dark'" texte="Une fois l'opération faite, la suppression sera irréversible" />
        <div class="PPbtn">
          <Bouton @click="deleteEffectif(idToDelete), openDelete = false" :type="'input'" :texte="'Confirmer'" />
          <Bouton @click="openDelete = false" :type="'cancel'" :texte="'Annuler'" />
        </div>
      </PopUp>
    </transition>

    <!-- Modal de formulaire -->
    <transition name="fade">
      <PopUp v-if="openForm">
        <form @submit.prevent="saveEffectif" class="mb-6 space-y-3 bg-gray-100 p-4 rounded">
          <Texte :texte="isEditing ? 'Modifier l\'effectif' : 'Créer un effectif'" :type="'dark'" />
          <div class="popupContent">
            <div class="form-row">
              <Select v-model="form.Id_Exercice_comptable" :placeholder="'Exercice comptable'" required>
                <option value="" disabled>Choisir un exercice</option>
                <option v-for="exercice in exercices" :key="exercice.Id_Exercice_comptable"
                  :value="exercice.Id_Exercice_comptable"
                  :disabled="effectifs.some(e => e.Id_Exercice_comptable === exercice.Id_Exercice_comptable && e.id !== editingId)">
                  {{ exercice.Annee_fiscale }}
                </option>
              </Select>
            </div>
            <div class="form-row">
              <Input v-model.number="form.nombre_eleves" placeholder="Nombre d'élèves" type="number" min="0" required />
            </div>
          </div>
          <div class="btn-form">
            <Bouton v-if="!isEditing" type="input" :texte="'Créer'" />
            <Bouton v-if="isEditing" type="input" :texte="'Modifier'" />
            <Bouton type="cancel" :texte="'Annuler'" @click="cancelEdit(), openForm = false" />
          </div>
        </form>
      </PopUp>
    </transition>

    <!-- Modal pour copier l'effectif -->
    <transition name="fade">
      <PopUp v-if="openCopyModal">
        <Icon :color="'primary'" :icon="'bi bi-copy'" />
        <Texte :type="'bold-dark'" texte="Copier l'effectif d'un exercice" />
        <Texte :type="'dark'"
          texte="Sélectionnez les dates de l'exercice cible. L'effectif de l'exercice précédent sera copié si aucun effectif n'existe." />

        <div class="popupContent">
          <div class="form-row">
            <Input v-model="copyForm.date_debut" placeholder="Date de début" type="date" required />
          </div>
          <div class="form-row">
            <Input v-model="copyForm.date_fin" placeholder="Date de fin" type="date" required />
          </div>
        </div>

        <div class="btn-form">
          <Bouton type="input" :texte="'Copier'" @click="handleCheckAndCopy" />
          <Bouton type="cancel" :texte="'Annuler'"
            @click="openCopyModal = false, copyForm = { date_debut: '', date_fin: '' }" />

          <p v-if="copyMessage" :class="copySuccess ? 'text-green' : 'text-red'">
            {{ copyMessage }}
          </p>
        </div>
      </PopUp>
    </transition>

    <div class="main">
      <!-- En-tête avec informations et boutons -->
      <div class="informations">
        <p class="Count-content">
          <Counter v-if="effectifs.length > 0" :number="filteredCount" />
          <Counter v-if="effectifs.length == 0" :number="0" />
          effectif{{ filteredCount !== 1 ? 's' : '' }} disponible{{ filteredCount !== 1 ? 's' : '' }}
        </p>
        <div class="btn">
          <!-- <Bouton type="primary" texte="Copier depuis exercice" redirection="" @click="openCopyModal = true" /> -->
          <Bouton type="primary" texte="Ajouter" redirection="" @click="openForm = true" />
        </div>
      </div>

      <!-- Statistiques -->
      <!-- <div v-if="statistiques" class="stats-container">
        <div class="stat-card">
          <Texte :type="'small-dark'" texte="Total élèves" />
          <Texte :type="'bold-dark'" :texte="statistiques.total.toString()" />
        </div>
        <div class="stat-card">
          <Texte :type="'small-dark'" texte="Moyenne" />
          <Texte :type="'bold-dark'" :texte="statistiques.moyenne" />
        </div>
        <div class="stat-card">
          <Texte :type="'small-dark'" texte="Max" />
          <Texte :type="'bold-dark'" :texte="statistiques.max.toString()" />
        </div>
        <div class="stat-card">
          <Texte :type="'small-dark'" texte="Min" />
          <Texte :type="'bold-dark'" :texte="statistiques.min.toString()" />
        </div>
      </div> -->

      <!-- Section Filtres -->
      <div class="filtres">
        <div class="ok">
          <searchbar v-model="searchTerm" type="text" placeholder="Rechercher par année ou nombre..." />

          <!-- Filtre par exercice -->
          <FilterSelect v-model="selectedExercice">
            <option value="">Tous les exercices</option>
            <option v-for="exercice in exercices" :key="exercice.Id_Exercice_comptable"
              :value="exercice.Id_Exercice_comptable">
              {{ exercice.Annee_fiscale }}
            </option>
          </FilterSelect>

          <BoutonIcon v-if="searchTerm || selectedExercice" @click="resetFilters" type="cancel" :icon-name="'x-lg'" />
        </div>
      </div>

      <!-- Tableau des effectifs -->
      <transition name="fade">
        <div class="content">
          <table class="table" id="effectifsTable">
            <thead>
              <tr>
                <th class="col">Exercice</th>
                <th class="col">Nombre d'élèves</th>

                <th class="col">Statut</th>
                <th class="col">Actions</th>
              </tr>
            </thead>
            <tbody>
              <!-- Données réelles -->
              <tr v-for="effectif in donneesPagination" :key="effectif.id" v-if="!loading">
                <td class="col">Exercice {{ effectif.exercice_comptable?.Annee_fiscale || 'N/A' }}</td>
                <td class="col">{{ effectif.nombre_eleves }}</td>

                <td class="col">
                  <span
                    :class="`status-badge status-${getExerciceStatut(effectif.Id_Exercice_comptable)?.toLowerCase()}`">
                    {{ getExerciceStatut(effectif.Id_Exercice_comptable) }}
                  </span>
                </td>
                <td class="col text-center">
                  <div class="action-content">
                    <BoutonIcon @click="editEffectif(effectif), openForm = true" icon-name="pen-fill" :type="'edit'" />
                    <BoutonIcon @click="idToDelete = effectif.id, openDelete = true" icon-name="trash-fill"
                      :type="'cancel'" />
                  </div>
                </td>
              </tr>

              <!-- Loaders pendant le chargement -->
              <tr v-if="loading" v-for="n in nombreLignesLoader" :key="'loader-' + n">
                <td class="col">
                  <LoadingText type="line-1" />
                </td>
                <td class="col">
                  <LoadingText type="line-2" />
                </td>
                <td class="col">
                  <LoadingText type="line-1" />
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
                <td class="col">
                  <LoadingText type="line-1" />
                </td>
              </tr>

              <!-- Message si aucun résultat -->
              <tr v-if="!loading && filteredCount === 0">
                <td colspan="7" class="text-center py-4 text-gray-500">
                  Aucun effectif trouvé.
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </transition>

      <!-- Pagination -->
      <Pagination :donnees="filteredEffectifs" :current-page="currentPage" :items-per-page="itemsPerPage"
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

#effectifsTable {
  @include table();

  .status-badge {
    padding: 4px 8px;
    border-radius: 12px;
    font-size: 12px;
    font-weight: 600;
    text-transform: uppercase;

    &.status-ouvert {
      background-color: #d4edda;
      color: #155724;
    }

    &.status-cloture {
      background-color: #f8d7da;
      color: #721c24;
    }

    &.status-provisoire {
      background-color: #fff3cd;
      color: #856404;
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

.fade-enter-to,
.fade-leave-from {
  opacity: 1;
  transform: scale(1);
}

.popupContent {
  @include position-contenus(flex, center, flex-start);
  flex-direction: column;
  gap: 10px;
  width: 100%;
}

.form-row {
  width: 100%;

  select,
  input {
    width: 100%;
  }
}

.filtres {
  @include position-contenus(flex, space-between, center);
  padding: 0 0;
  align-self: self-start;
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

.text-green {
  @include text-xs($stara-medium, $vert);
  text-align: center;
}

.text-red {
  @include text-xs($stara-medium, $rouge);
  text-align: center;
}

.stats-container {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 15px;
  width: 100%;
  margin-bottom: 15px;
}

.stat-card {
  @include glass();
  padding: 15px;
  border-radius: $radius-pm;
  text-align: center;

  &:first-child {
    border-left: 4px solid $vert;
  }

  &:nth-child(2) {
    border-left: 4px solid $secondary;
  }

  &:nth-child(3) {
    border-left: 4px solid $jaune;
  }

  &:last-child {
    border-left: 4px solid $rouge;
  }
}
</style>