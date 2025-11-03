<script setup>
import { ref, onMounted, computed } from "vue";
import { useNonAffecte } from "@/composables/useNonAffecte";
import { useAffectationSousCompte } from "@/composables/useAffectationSousCompte";
import PageAnalyse from "@/components/template/Page-analyse.vue";
import ContentHeader from "@/components/molecules/Analyse/Content-header.vue";
import Bouton from "@/components/atoms/Bouton.vue";
import Input from "@/components/atoms/Input.vue";
import Texte from "@/components/atoms/Texte.vue";
import PopUp from "@/components/molecules/Analyse/Pop-up.vue";
import BoutonIcon from "@/components/atoms/Bouton-icon.vue";
import Pagination from "@/components/molecules/Pagination.vue";
import { usePagination } from "@/composables/usePagination";
import searchbar from '@/components/atoms/searchbar.vue';
import Counter from "@/components/atoms/counter.vue";
import LoadingText from "@/components/atoms/Loading-text.vue";
import Select from '@/components/atoms/Select.vue';
import Textarea from "@/components/atoms/Textarea.vue";
import { useAffectations } from "@/composables/useAffectations";
import InputTable from "@/components/atoms/Input-table.vue";
import TextareaTable from "@/components/atoms/Textarea-table.vue";
import SelectTable from "@/components/atoms/select-table.vue";


// Composable pour les sous-comptes non affectés
const {
  sousComptesNonAffectes,
  loading,
  searchTerm,
  currentPage,
  total,
  fetchSousComptesNonAffectes,
  changePage
} = useNonAffecte();

// Composable pour l'affectation d'un sous-compte
const {
  form,
  loading: loadingAffectation,
  message,
  totalTaux,
  totalTauxClass,
  hasDuplicateCentres,
  isFormValid,
  initForm,
  addVentilation,
  removeVentilation,
  save,
  resetForm
} = useAffectationSousCompte();

// Composable pour les données communes (centres, types)
const { codesAnalytiques, centres, types, fetchData } = useAffectations();

// Variables pour le formulaire d'affectation
const openForm = ref(false);
const selectedSousCompte = ref(null);

// Pagination
const {
  currentPage: currentPagePagination,
  itemsPerPage,
  totalPages,
  donneesPagination,
  previousPage,
  nextPage,
  goToPage
} = usePagination(sousComptesNonAffectes);

// Computed pour le compteur
const filteredNonAffectes = computed(() => {
  if (!searchTerm.value) return sousComptesNonAffectes.value;

  return sousComptesNonAffectes.value.filter(sousCompte =>
    sousCompte.Code_sous_compte?.toLowerCase().includes(searchTerm.value.toLowerCase()) ||
    sousCompte.Libelle?.toLowerCase().includes(searchTerm.value.toLowerCase()) ||
    sousCompte.compte?.Code_compte?.toLowerCase().includes(searchTerm.value.toLowerCase()) ||
    sousCompte.compte?.Libelle?.toLowerCase().includes(searchTerm.value.toLowerCase())
  );
});

// Ouvrir le formulaire d'affectation
const ouvrirFormulaireAffectation = (sousCompte) => {
  selectedSousCompte.value = sousCompte;
  initForm(sousCompte);
  openForm.value = true;
};

// Fermer le formulaire
const fermerFormulaire = () => {
  openForm.value = false;
  selectedSousCompte.value = null;
  resetForm();
};

// Sauvegarder et fermer
const handleSave = async () => {
  const success = await save();
  if (success) {
    await fetchSousComptesNonAffectes(); // Rafraîchir la liste
    fermerFormulaire();
  }
};

// Chargement initial
onMounted(() => {
  fetchSousComptesNonAffectes();
  fetchData(); // Charger centres et types
});
</script>

<template>
  <PageAnalyse>
    <!-- Popup pour affecter un sous-compte -->
    <transition name="fade">
      <PopUp v-if="openForm">
        <div class="creation-popup">
          <!-- En-tête -->
          <div class="popuphead">
            <Texte
              :texte="'Affecter le sous-compte: ' + selectedSousCompte?.Code_sous_compte + ' - ' + selectedSousCompte?.Libelle"
              :type="'dark'" />
            <BoutonIcon @click="fermerFormulaire" icon-name="x-lg" :type="'cancel'" title="Annuler les modifications" />
          </div>

          <!-- Informations du sous-compte -->
          <!-- <div class="sous-compte-info mb-4">
            <div class="info-grid">
              <div>
                <Texte :texte="'Code Compte:'" :type="'label'" />
                <Texte :texte="selectedSousCompte?.compte?.Code_compte" :type="'dark'" />
              </div>
              <div>
                <Texte :texte="'Libellé Compte:'" :type="'label'" />
                <Texte :texte="selectedSousCompte?.compte?.Libelle" :type="'dark'" />
              </div>
            </div>
          </div> -->

          <!-- Formulaire de ventilation -->
          <div class="ventilation-form">
            <table class="table" id="axesTable">
              <thead>
                <tr>
                  <th class="col">Centre</th>
                  <th class="col">Type</th>
                  <th class="col">Code Analytique</th> <!-- ← NOUVELLE COLONNE -->
                  <th class="col">Description</th>
                  <th class="col">Taux</th>
                  <th class="col">Actions</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(vent, index) in form.ventilations" :key="index">
                  <td class="col">
                    <SelectTable v-model="vent.id_centre" :label="''" required>
                      <option value="" disabled>Sélectionner un centre</option>
                      <option v-for="centre in centres" :key="centre.id_centre" :value="centre.id_centre">
                        {{ centre.nom }}
                      </option>
                    </SelectTable>
                  </td>
                  <td class="col">
                    <SelectTable v-model="vent.id_type" :label="''" required>
                      <option value="" disabled>Sélectionner un type</option>
                      <option v-for="type in types" :key="type.id_type" :value="type.id_type">
                        {{ type.code }} - {{ type.libelle }}
                      </option>
                    </SelectTable>
                  </td>
                  <td class="col"> <!-- ← NOUVELLE COLONNE -->
                <SelectTable 
                  v-model="vent.id_code" 
                  :label="''"
                  class="compact-select"
                >
                  <option value="">Aucun code</option>
                  <option 
                    v-for="code in codesAnalytiques" 
                    :key="code.id_code" 
                    :value="code.id_code"
                  >
                    {{ code.code }} - {{ code.libelle }}
                  </option>
                </SelectTable>
              </td>
                  <td class="col">
                    <TextareaTable v-model="vent.description" :label="''" placeholder="Description..." />
                  </td>
                  <td class="col">
                    <InputTable type="number" v-model.number="vent.taux" :label="''" min="0" max="100" step="0.01"
                      required class="taux-input" />%
                    <!-- <span class="percent-symbol">%</span> -->
                  </td>
                  <td class="col">
                    <BoutonIcon @click="removeVentilation(index)" icon-name="trash" :type="'cancel'"
                      title="Supprimer cette ventilation" :disabled="form.ventilations.length <= 1" />
                  </td>
                </tr>
              </tbody>
              <tfoot id="footable">
                <tr>
                  <td class="col">Total</td>
                  <td></td>
                  <td></td>
                  
                  <td class="col">
                    <span class="total-value" :class="totalTauxClass">
                      {{ totalTaux.toFixed(2) }}%
                    </span>
                  </td>
                  <td></td>
                </tr>
              </tfoot>
            </table>

            <!-- Messages d'information -->
            <div class="msg">
              <div v-if="totalTaux !== 100" class="taux-warning mt-3">
              <Texte :texte="'Le total des taux doit être exactement 100%'" :type="'thin-warning'" />
            </div>

            <div v-if="hasDuplicateCentres" class="duplicate-warning mt-3">
              <Texte :texte="'Vous ne pouvez pas avoir plusieurs ventilations pour le même centre'"
                :type="'thin-error'" />
            </div>

            <!-- Message de retour d'API -->
            <div v-if="message.text" :class="message.type === 'success' ? 'text-green' : 'text-red'">
              {{ message.text }}
            </div>
            </div>
          </div>

          <div class="action-content">
            <BoutonIcon :icon-name="'plus-lg'" :type="totalTaux >= 100 ? 'primary-disabled' : 'primary'"
              @click="addVentilation" :disabled="totalTaux >= 100" title="Ajouter une ventilation" />
            <Bouton @click="handleSave" type="input" :texte="loadingAffectation ? 'Création...' : `Créer l'affectation`"
              :disabled="!isFormValid || loadingAffectation" />
          </div>
        </div>
      </PopUp>
    </transition>

    <div class="main">
      <ContentHeader :menu="'Saisie Analytique'" :sousmenu="'Sous-comptes non affectés'" />

      <div class="informations">
        <p class="Count-content">
          <Counter v-if="filteredNonAffectes.length > 0" :number="filteredNonAffectes.length" :format="'number'" />
          <Counter v-if="filteredNonAffectes.length == 0" :number="0" />
          sous-compte(s) non affecté(s)
        </p>
        <div class="btn">
          <Bouton type="primary" texte="Rafraîchir" @click="fetchSousComptesNonAffectes" />
        </div>
      </div>

      <!-- Barre de recherche -->
      <div class="filtres">
        <searchbar v-model="searchTerm" type="text" placeholder="Rechercher par code ou libellé..." />
      </div>

      <!-- Tableau des sous-comptes non affectés -->
      <div class="loading" v-if="loading">
        <BoutonLoading :type="'transparent'" />
      </div>

      <transition name="fade">
        <div class="content">
          <table class="table" id="axesTable">
            <thead>
              <tr>
                <th class="col">Code Sous-compte</th>
                <th class="col">Libellé</th>
                <th class="col">Code Compte</th>
                <th class="col">Libellé Compte</th>
                <th class="col">Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="sousCompte in donneesPagination" :key="sousCompte.Id_Sous_compte">
                <td class="col">{{ sousCompte.Code_sous_compte }}</td>
                <td class="col">{{ sousCompte.Libelle }}</td>
                <td class="col">{{ sousCompte.compte?.Code_compte }}</td>
                <td class="col">{{ sousCompte.compte?.Libelle }}</td>
                <td class="col">
                  <div class="action-content">
                    <BoutonIcon @click="ouvrirFormulaireAffectation(sousCompte)" icon-name="plus-lg" :type="'primary'"
                      title="Affecter ce sous-compte" />
                  </div>
                </td>
              </tr>
              <tr v-if="loading" v-for="n in 10" :key="'loader-' + n">
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
                <td class="col">
                  <LoadingText :type="'line-1'" />
                </td>
              </tr>
              <tr v-if="donneesPagination.length === 0 && !loading">
                <td colspan="5" class="col text-center">
                  Aucun sous-compte non affecté trouvé
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </transition>

      <!-- Pagination -->
      <Pagination :donnees="filteredNonAffectes" :current-page="currentPagePagination" :items-per-page="itemsPerPage"
        :total-pages="totalPages" :go-to-page="goToPage" :previous-page="previousPage" :next-page="nextPage" />
    </div>
  </PageAnalyse>
</template>

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
.msg{
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
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

.filtres {
  @include position-contenus(flex, flex-start, center);
  padding: 0 0;
  align-self: self-start;
  gap: 10px;
}

.popuphead {
  @include position-contenus();
  justify-content: space-between;
}

.action-content {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 10px;
  padding: 10px;
}

.text-center {
  text-align: center;
}

.sous-compte-info {
  background-color: #f8f9fa;
  padding: 15px;
  border-radius: 8px;
  border: 1px solid #e9ecef;
}

#footable {
  font-family: $stara-bold;
  font-size: 16px;
  background-color: #f3f3f3;
}
.info-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 15px;
}

.info-grid div {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.ventilation-form {
  margin-top: 20px;
}

.taux-input {
  position: relative;
}

.percent-symbol {
  position: absolute;
  right: 10px;
  top: 50%;
  transform: translateY(-50%);
  color: #666;
}

.total-cell {
  display: flex;
  align-items: center;
  gap: 10px;
}

.total-label {
  font-weight: bold;
}

.total-value {
  font-weight: bold;
}

.text-green {
  @include text-xs($stara-medium, $vert)
}

.text-red {
  @include text-xs($stara-medium, $rouge)
}

.taux-warning, .duplicate-warning {
  margin-top: 10px;
}
</style>