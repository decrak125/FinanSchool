<script setup>
import { ref, onMounted } from "vue";
import PageAnalyse from '@/components/template/Page-analyse.vue';
import { useIndicateurPedagogique } from "@/composables/useIndicateurPedagogique";
import Card from "@/components/atoms/Chart/Card.vue";
import ContentHeader from "@/components/molecules/Analyse/Content-header.vue";
import Texte from "@/components/atoms/Texte.vue";
import FilterSelect from "@/components/atoms/Filter-select.vue";
import LoadingText from "@/components/atoms/Loading-text.vue";
import PopUp from "@/components/molecules/Analyse/Pop-up.vue";
import BoutonIcon from "@/components/atoms/Bouton-icon.vue";

const nombreLignesLoader = 5;

const filters = ref({
  dateStart: "",
  dateEnd: "",
  idExercice: ""
});

const detailsCoutFonctionnement = ref(false);
const detailsChiffreAffaires = ref(false);
const detailsPartMasseSalariale = ref(false);
const detailsMargeParEleve = ref(false);

const {
  loadingTable,
  exercice,
  exercicesOptions,
  coutFonctionnement,
  chiffreAffaires,
  partMasseSalariale,
  margeParEleve,
  loading,
  comparisons,
  threeYearsData,
  refreshAllData,
  initializeData,
  changeExercice
} = useIndicateurPedagogique(filters);

// Chargement initial
onMounted(() => {
  initializeData();
});

// Gestion du changement d'exercice
const handleExerciceChange = async (event) => {
  const idExercice = event.target.value;
  await changeExercice(idExercice);
};

// Formater les valeurs monétaires
const formatMoney = (value) => {
  if (value === null || value === undefined) return 'N/A';
  return new Intl.NumberFormat('mg-MG', {
    style: 'currency',
    currency: 'MGA',
    minimumFractionDigits: 0,
    maximumFractionDigits: 0
  }).format(value);
};

// Formater les pourcentages
const formatPercentage = (value) => {
  if (value === null || value === undefined) return 'N/A';
  return `${parseFloat(value).toFixed(2)}%`;
};

// Obtenir la classe CSS pour la tendance
const getTrendClass = (comparison) => {
  if (!comparison?.hasData) return 'trend-neutral';
  return `trend-${comparison.trend}`;
};

// Obtenir l'icône de tendance
const getTrendIcon = (comparison) => {
  if (!comparison?.hasData) return '→';
  return comparison.trend === 'up' ? '↗' : 
         comparison.trend === 'down' ? '↘' : '→';
};

// Formater l'évolution avec les deux comparaisons
const formatEvolution = (comparison) => {
  if (!comparison?.hasData) return 'N/A';
  
  const vsPrevious = comparison.percentageVsPrevious ? 
    `N-1: ${comparison.percentageVsPrevious}%` : '';
  
  const vsTwoYearsAgo = comparison.percentageVsTwoYearsAgo ? 
    `N-2: ${comparison.percentageVsTwoYearsAgo}%` : '';
  
  return [vsPrevious, vsTwoYearsAgo].filter(Boolean).join(' | ');
};
</script>

<template>
  <PageAnalyse>
    <!-- POP UP pour Coût de Fonctionnement -->
    <PopUp v-if="detailsCoutFonctionnement">
      <div class="details-popup">
        <div class="popuphead">
          <Texte :texte="coutFonctionnement?.definition" :type="'dark'" />
          <BoutonIcon @click="detailsCoutFonctionnement = false" icon-name="x-lg" :type="'cancel'" title="Fermer" />
        </div>
        <div class="indicateur-detail">
          <table class="table" id="axesTable">
            <thead>
              <tr>
                <th class="col">Indicateur</th>
                <th class="col">{{ exercice?.Annee_fiscale - 2 }}</th>
                <th class="col">{{ exercice?.Annee_fiscale - 1 }}</th>
                <th class="col">{{ exercice?.Annee_fiscale }}</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td id="detailTitle">Charges d'exploitation</td>
                <td id="detail">{{ formatMoney(threeYearsData.twoYearsAgo?.details_calcul?.total_charges_exploitation) }}</td>
                <td id="detail">{{ formatMoney(threeYearsData.previous?.details_calcul?.total_charges_exploitation) }}</td>
                <td id="detail">{{ formatMoney(coutFonctionnement?.details_calcul?.total_charges_exploitation) }}</td>
              </tr>
              <tr>
                <td id="detailTitle">Effectif élèves</td>
                <td id="detail">{{ threeYearsData.twoYearsAgo?.details_calcul?.effectif_eleves || 'N/A' }}</td>
                <td id="detail">{{ threeYearsData.previous?.details_calcul?.effectif_eleves || 'N/A' }}</td>
                <td id="detail">{{ coutFonctionnement?.details_calcul?.effectif_eleves || 'N/A' }}</td>
              </tr>
            </tbody>
            <tfoot id="footable">
              <tr>
                <td id="detailTitle">Coût par élève</td>
                <td id="detail">{{ formatMoney(threeYearsData.twoYearsAgo?.cout_fonctionnement_par_eleve) }}</td>
                <td id="detail">{{ formatMoney(threeYearsData.previous?.cout_fonctionnement_par_eleve) }}</td>
                <td id="detail">{{ formatMoney(coutFonctionnement?.cout_fonctionnement_par_eleve?.valeur) }}</td>
              </tr>
              <tr>
                <td id="detailTitle">Formule</td>
                <td id="detail" colspan="3">{{ coutFonctionnement?.formule }}</td>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>
    </PopUp>

    <!-- POP UP pour Chiffre d'Affaires -->
    <PopUp v-if="detailsChiffreAffaires">
      <div class="details-popup">
        <div class="popuphead">
          <Texte :texte="chiffreAffaires?.definition" :type="'dark'" />
          <BoutonIcon @click="detailsChiffreAffaires = false" icon-name="x-lg" :type="'cancel'" title="Fermer" />
        </div>
        <div class="indicateur-detail">
          <table class="table" id="axesTable">
            <thead>
              <tr>
                <th class="col">Indicateur</th>
                <th class="col">{{ exercice?.Annee_fiscale - 2 }}</th>
                <th class="col">{{ exercice?.Annee_fiscale - 1 }}</th>
                <th class="col">{{ exercice?.Annee_fiscale }}</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td id="detailTitle">Produits d'exploitation</td>
                <td id="detail">{{ formatMoney(threeYearsData.twoYearsAgo?.details_calcul?.total_produits_exploitation) }}</td>
                <td id="detail">{{ formatMoney(threeYearsData.previous?.details_calcul?.total_produits_exploitation) }}</td>
                <td id="detail">{{ formatMoney(chiffreAffaires?.details_calcul?.total_produits_exploitation) }}</td>
              </tr>
              <tr>
                <td id="detailTitle">Effectif élèves</td>
                <td id="detail">{{ threeYearsData.twoYearsAgo?.details_calcul?.effectif_eleves || 'N/A' }}</td>
                <td id="detail">{{ threeYearsData.previous?.details_calcul?.effectif_eleves || 'N/A' }}</td>
                <td id="detail">{{ chiffreAffaires?.details_calcul?.effectif_eleves || 'N/A' }}</td>
              </tr>
            </tbody>
            <tfoot id="footable">
              <tr>
                <td id="detailTitle">CA par élève</td>
                <td id="detail">{{ formatMoney(threeYearsData.twoYearsAgo?.chiffre_affaires_par_eleve) }}</td>
                <td id="detail">{{ formatMoney(threeYearsData.previous?.chiffre_affaires_par_eleve) }}</td>
                <td id="detail">{{ formatMoney(chiffreAffaires?.chiffre_affaires_par_eleve?.valeur) }}</td>
              </tr>
              <tr>
                <td id="detailTitle">Formule</td>
                <td id="detail" colspan="3">{{ chiffreAffaires?.formule }}</td>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>
    </PopUp>

    <!-- POP UP pour Part Masse Salariale -->
    <PopUp v-if="detailsPartMasseSalariale">
      <div class="details-popup">
        <div class="popuphead">
          <Texte :texte="partMasseSalariale?.definition" :type="'dark'" />
          <BoutonIcon @click="detailsPartMasseSalariale = false" icon-name="x-lg" :type="'cancel'" title="Fermer" />
        </div>
        <div class="indicateur-detail">
          <table class="table" id="axesTable">
            <thead>
              <tr>
                <th class="col">Indicateur</th>
                <th class="col">{{ exercice?.Annee_fiscale - 2 }}</th>
                <th class="col">{{ exercice?.Annee_fiscale - 1 }}</th>
                <th class="col">{{ exercice?.Annee_fiscale }}</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td id="detailTitle">Masse salariale enseignante</td>
                <td id="detail">{{ formatMoney(threeYearsData.twoYearsAgo?.details_calcul?.masse_salariale_enseignante) }}</td>
                <td id="detail">{{ formatMoney(threeYearsData.previous?.details_calcul?.masse_salariale_enseignante) }}</td>
                <td id="detail">{{ formatMoney(partMasseSalariale?.details_calcul?.masse_salariale_enseignante) }}</td>
              </tr>
              <tr>
                <td id="detailTitle">Total charges</td>
                <td id="detail">{{ formatMoney(threeYearsData.twoYearsAgo?.details_calcul?.total_charges) }}</td>
                <td id="detail">{{ formatMoney(threeYearsData.previous?.details_calcul?.total_charges) }}</td>
                <td id="detail">{{ formatMoney(partMasseSalariale?.details_calcul?.total_charges) }}</td>
              </tr>
            </tbody>
            <tfoot id="footable">
              <tr>
                <td id="detailTitle">Part masse salariale</td>
                <td id="detail">{{ formatPercentage(threeYearsData.twoYearsAgo?.part_masse_salariale_enseignante) }}</td>
                <td id="detail">{{ formatPercentage(threeYearsData.previous?.part_masse_salariale_enseignante) }}</td>
                <td id="detail">{{ formatPercentage(partMasseSalariale?.part_masse_salariale_enseignante?.valeur) }}</td>
              </tr>
              <tr>
                <td id="detailTitle">Formule</td>
                <td id="detail" colspan="3">{{ partMasseSalariale?.formule }}</td>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>
    </PopUp>

    <!-- POP UP pour Marge par Élève -->
    <PopUp v-if="detailsMargeParEleve">
      <div class="details-popup">
        <div class="popuphead">
          <Texte :texte="margeParEleve?.definition" :type="'dark'" />
          <BoutonIcon @click="detailsMargeParEleve = false" icon-name="x-lg" :type="'cancel'" title="Fermer" />
        </div>
        <div class="indicateur-detail">
          <table class="table" id="axesTable">
            <thead>
              <tr>
                <th class="col">Indicateur</th>
                <th class="col">{{ exercice?.Annee_fiscale - 2 }}</th>
                <th class="col">{{ exercice?.Annee_fiscale - 1 }}</th>
                <th class="col">{{ exercice?.Annee_fiscale }}</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td id="detailTitle">Résultat net</td>
                <td id="detail">{{ formatMoney(threeYearsData.twoYearsAgo?.details_calcul?.resultat_net) }}</td>
                <td id="detail">{{ formatMoney(threeYearsData.previous?.details_calcul?.resultat_net) }}</td>
                <td id="detail">{{ formatMoney(margeParEleve?.details_calcul?.resultat_net) }}</td>
              </tr>
              <tr>
                <td id="detailTitle">Effectif élèves</td>
                <td id="detail">{{ threeYearsData.twoYearsAgo?.details_calcul?.effectif_eleves || 'N/A' }}</td>
                <td id="detail">{{ threeYearsData.previous?.details_calcul?.effectif_eleves || 'N/A' }}</td>
                <td id="detail">{{ margeParEleve?.details_calcul?.effectif_eleves || 'N/A' }}</td>
              </tr>
            </tbody>
            <tfoot id="footable">
              <tr>
                <td id="detailTitle">Marge par élève</td>
                <td id="detail">{{ formatMoney(threeYearsData.twoYearsAgo?.marge_par_eleve) }}</td>
                <td id="detail">{{ formatMoney(threeYearsData.previous?.marge_par_eleve) }}</td>
                <td id="detail">{{ formatMoney(margeParEleve?.marge_par_eleve?.valeur) }}</td>
              </tr>
              <tr>
                <td id="detailTitle">Formule</td>
                <td id="detail" colspan="3">{{ margeParEleve?.formule }}</td>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>
    </PopUp>

    <div class="main">
      <ContentHeader :menu="'Indicateurs & ratios'" :sousmenu="'Indicateurs pédagogiques'" />
      
      <!-- Filtres -->
      <div class="filtres">
        <Texte :type="'dark'" :texte="'Exercice comptable'" />
        <div>
          <FilterSelect 
            v-model="filters.idExercice"
            @change="handleExerciceChange"
            :disabled="loading"
          >
            <option value="">Exercice ouvert (actuel)</option>
            <option 
              v-for="exo in exercicesOptions" 
              :key="exo.value" 
              :value="exo.value"
            >
              {{ exo.label }}
            </option>
          </FilterSelect>
        </div>
      </div>

      <!-- Cartes indicateurs -->
      <div class="graphic">
        <div class="cartes">
          <div class="hauteur">
            <Card 
              :texte="'Coût par élève'"
              :chiffre="parseFloat(coutFonctionnement?.cout_fonctionnement_par_eleve?.valeur)"
              :format="'money'" 
              :icon="'bi bi-cash-coin'" 
              :icon-color="'orange'" 
              :negative="false"
              :variation="getTrendIcon(comparisons.coutFonctionnement) + ' ' + formatEvolution(comparisons.coutFonctionnement)"
              :colorVariation="getTrendClass(comparisons.coutFonctionnement)"
            />
            <Card 
              :texte="'CA par élève'"
              :chiffre="parseFloat(chiffreAffaires?.chiffre_affaires_par_eleve?.valeur)" 
              :format="'money'" 
              :icon="'bi bi-graph-up'"
              :icon-color="'green'" 
              :negative="false"
              :variation="getTrendIcon(comparisons.chiffreAffaires) + ' ' + formatEvolution(comparisons.chiffreAffaires)"
              :colorVariation="getTrendClass(comparisons.chiffreAffaires)"
            />
          </div>
          <div class="hauteur">
            <Card 
              :texte="'Part masse salariale'"
              :chiffre="parseFloat(partMasseSalariale?.part_masse_salariale_enseignante?.valeur)" 
              :format="'percentage'" 
              :icon="'bi bi-people-fill'" 
              :icon-color="'blue'" 
              :negative="false"
              :variation="getTrendIcon(comparisons.partMasseSalariale) + ' ' + formatEvolution(comparisons.partMasseSalariale)"
              :colorVariation="getTrendClass(comparisons.partMasseSalariale)"
            />
            <Card 
              :texte="'Marge par élève'" 
              :chiffre="parseFloat(margeParEleve?.marge_par_eleve?.valeur)"
              :format="'money'" 
              :icon="'bi bi-wallet2'" 
              :icon-color="'purple'" 
              :negative="true"
              :variation="getTrendIcon(comparisons.margeParEleve) + ' ' + formatEvolution(comparisons.margeParEleve)"
              :colorVariation="getTrendClass(comparisons.margeParEleve)"
            />
          </div>
        </div>
      </div>

      <!-- Tableau de comparaison sur 3 ans -->
      <div class="comparison-section">
        <div class="section-header">
          <Texte :type="'bold-dark'" :texte="'Évolution sur 3 ans des indicateurs pédagogiques'" />
        </div>
        
        <div class="comparison-table-container">
          <table class="table" id="axesTable">
            <thead>
              <tr>
                <th class="col">Indicateur</th>
                <th class="col">{{ exercice?.Annee_fiscale - 2 }}</th>
                <th class="col">{{ exercice?.Annee_fiscale - 1 }}</th>
                <th class="col">{{ exercice?.Annee_fiscale }}</th>
                <th class="col">Évolution N-1</th>
                <th class="col">Évolution N-2</th>
                <th class="col">Action</th>
              </tr>
            </thead>
            <tbody v-if="!loadingTable">
              <!-- Coût de fonctionnement -->
              <tr>
                <td class="col">
                  <i class="bi bi-cash-coin trend-icon orange"></i>
                  Coût par élève
                </td>
                <td class="col">
                  {{ formatMoney(threeYearsData.twoYearsAgo?.cout_fonctionnement_par_eleve) }}
                </td>
                <td class="col">
                  {{ formatMoney(threeYearsData.previous?.cout_fonctionnement_par_eleve) }}
                </td>
                <td class="col">
                  {{ formatMoney(coutFonctionnement?.cout_fonctionnement_par_eleve?.valeur) }}
                </td>
                <td :class="['evolution', getTrendClass(comparisons.coutFonctionnement)]">
                  <span class="trend-icon">{{ getTrendIcon(comparisons.coutFonctionnement) }}</span>
                  {{ comparisons.coutFonctionnement?.percentageVsPrevious ? `${comparisons.coutFonctionnement.percentageVsPrevious}%` : 'N/A' }}
                </td>
                <td :class="['evolution', getTrendClass(comparisons.coutFonctionnement)]">
                  {{ comparisons.coutFonctionnement?.percentageVsTwoYearsAgo ? `${comparisons.coutFonctionnement.percentageVsTwoYearsAgo}%` : 'N/A' }}
                </td>
                <td>
                  <BoutonIcon icon-name="eye" type="edit" title="Voir les détails"
                    @click="detailsCoutFonctionnement = !detailsCoutFonctionnement" />
                </td>
              </tr>
              
              <!-- Chiffre d'affaires -->
              <tr>
                <td class="col">
                  <i class="bi bi-graph-up trend-icon green"></i>
                  CA par élève
                </td>
                <td class="col">
                  {{ formatMoney(threeYearsData.twoYearsAgo?.chiffre_affaires_par_eleve) }}
                </td>
                <td class="col">
                  {{ formatMoney(threeYearsData.previous?.chiffre_affaires_par_eleve) }}
                </td>
                <td class="col">
                  {{ formatMoney(chiffreAffaires?.chiffre_affaires_par_eleve?.valeur) }}
                </td>
                <td :class="['evolution', getTrendClass(comparisons.chiffreAffaires)]">
                  <span class="trend-icon">{{ getTrendIcon(comparisons.chiffreAffaires) }}</span>
                  {{ comparisons.chiffreAffaires?.percentageVsPrevious ? `${comparisons.chiffreAffaires.percentageVsPrevious}%` : 'N/A' }}
                </td>
                <td :class="['evolution', getTrendClass(comparisons.chiffreAffaires)]">
                  {{ comparisons.chiffreAffaires?.percentageVsTwoYearsAgo ? `${comparisons.chiffreAffaires.percentageVsTwoYearsAgo}%` : 'N/A' }}
                </td>
                <td>
                  <BoutonIcon icon-name="eye" type="edit" title="Voir les détails"
                    @click="detailsChiffreAffaires = !detailsChiffreAffaires" />
                </td>
              </tr>
              
              <!-- Part masse salariale -->
              <tr>
                <td class="col">
                  <i class="bi bi-people-fill trend-icon blue"></i>
                  Part masse salariale
                </td>
                <td class="col">
                  {{ formatPercentage(threeYearsData.twoYearsAgo?.part_masse_salariale_enseignante) }}
                </td>
                <td class="col">
                  {{ formatPercentage(threeYearsData.previous?.part_masse_salariale_enseignante) }}
                </td>
                <td class="col">
                  {{ formatPercentage(partMasseSalariale?.part_masse_salariale_enseignante?.valeur) }}
                </td>
                <td :class="['evolution', getTrendClass(comparisons.partMasseSalariale)]">
                  <span class="trend-icon">{{ getTrendIcon(comparisons.partMasseSalariale) }}</span>
                  {{ comparisons.partMasseSalariale?.percentageVsPrevious ? `${comparisons.partMasseSalariale.percentageVsPrevious}%` : 'N/A' }}
                </td>
                <td :class="['evolution', getTrendClass(comparisons.partMasseSalariale)]">
                  {{ comparisons.partMasseSalariale?.percentageVsTwoYearsAgo ? `${comparisons.partMasseSalariale.percentageVsTwoYearsAgo}%` : 'N/A' }}
                </td>
                <td>
                  <BoutonIcon icon-name="eye" type="edit" title="Voir les détails"
                    @click="detailsPartMasseSalariale = !detailsPartMasseSalariale" />
                </td>
              </tr>
              
              <!-- Marge par élève -->
              <tr>
                <td class="col">
                  <i class="bi bi-wallet2 trend-icon purple"></i>
                  Marge par élève
                </td>
                <td class="col">
                  {{ formatMoney(threeYearsData.twoYearsAgo?.marge_par_eleve) }}
                </td>
                <td class="col">
                  {{ formatMoney(threeYearsData.previous?.marge_par_eleve) }}
                </td>
                <td class="col">
                  {{ formatMoney(margeParEleve?.marge_par_eleve?.valeur) }}
                </td>
                <td :class="['evolution', getTrendClass(comparisons.margeParEleve)]">
                  <span class="trend-icon">{{ getTrendIcon(comparisons.margeParEleve) }}</span>
                  {{ comparisons.margeParEleve?.percentageVsPrevious ? `${comparisons.margeParEleve.percentageVsPrevious}%` : 'N/A' }}
                </td>
                <td :class="['evolution', getTrendClass(comparisons.margeParEleve)]">
                  {{ comparisons.margeParEleve?.percentageVsTwoYearsAgo ? `${comparisons.margeParEleve.percentageVsTwoYearsAgo}%` : 'N/A' }}
                </td>
                <td>
                  <BoutonIcon icon-name="eye" type="edit" title="Voir les détails"
                    @click="detailsMargeParEleve = !detailsMargeParEleve" />
                </td>
              </tr>
            </tbody>
            <tbody v-if="loadingTable">
              <tr v-for="n in nombreLignesLoader" :key="'loader-' + n">
                <td><LoadingText :type="'line-1'" /></td>
                <td><LoadingText :type="'line-1'" /></td>
                <td><LoadingText :type="'line-1'" /></td>
                <td><LoadingText :type="'line-1'" /></td>
                <td><LoadingText :type="'line-1'" /></td>
                <td><LoadingText :type="'line-1'" /></td>
                <td><LoadingText :type="'line-1'" /></td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </PageAnalyse>
</template>

<style lang="scss" scoped>
// Vos styles SCSS existants restent les mêmes...

#axesTable {
  @include table(#f5f5f5);
  cursor: pointer;
  @media (max-width: $mobile) {
    font-size: 0.875rem;
  }
}

.details-popup{
  min-width: 75vh;
}

#footable {
  font-family: $stara-bold;
  background-color: $light;
}

#detail {
  color: $gris;
  cursor: default;
}

.popuphead {
  @include position-contenus();
  justify-content: space-between;
}

#detailTitle {
  color: $gris;
  padding-left: 24px;
  cursor: default;
}

.cartes {
  @include position-contenus(grid, center, center);
  padding: 0;
  gap: 32px;

  @media (max-width: $tablet) {
    gap: 24px;
    grid-template-columns: repeat(2, 1fr);
  }

  @media (max-width: $mobile) {
    gap: 16px;
    grid-template-columns: 1fr;
  }
}

.main {
  @include position-contenus(flex, center, center);
  padding: 0 32px;
  flex-direction: column;
  gap: 20px;
  flex: 1 0 0;
  align-self: stretch;
  animation: appear 0.6s ease-out forwards;

  @media (max-width: $tablet) {
    padding: 0 24px;
    gap: 16px;
  }

  @media (max-width: $mobile) {
    padding: 0 16px;
    gap: 12px;
  }
}

.hauteur {
  @include position-contenus(flex, center, center);
  padding: 0;
  gap: 32px;

  @media (max-width: $tablet) {
    gap: 24px;
    flex-direction: column;
  }

  @media (max-width: $mobile) {
    gap: 16px;
  }
}

.graphic {
  @include position-contenus(flex, flex-start, flex-start);
  padding: 10px 0;
  align-self: stretch;
  gap: 32px;

  @media (max-width: $tablet) {
    gap: 24px;
    flex-direction: column;
  }

  @media (max-width: $mobile) {
    gap: 16px;
    padding: 5px 0;
  }
}

.filtres {
  @include position-contenus(flex, flex-start, center);
  padding: 0 0;
  align-self: self-start;
  gap: 16px;
  flex-wrap: wrap;
  
  @media (max-width: $tablet) {
    align-self: stretch;
    justify-content: flex-start;
  }
  
  @media (max-width: $mobile) {
    gap: 12px;
    justify-content: center;
  }
}

/* Section de comparaison */
.comparison-section {
  width: 100%;
  margin-top: 20px;
}

.section-header {
  margin-bottom: 16px;
  
  h3 {
    margin: 0;
    color: #2c3e50;
    font-size: 18px;
    font-weight: 600;
  }
}

.comparison-table-container {
  background: white;
  border-radius: 8px;
}

.trend-icon {
  font-size: 16px;
  
  &.green { color: #28a745; }
  &.red { color: #dc3545; }
  &.orange { color: #fd7e14; }
  &.purple { color: #6f42c1; }
  &.blue { color: #007bff; }
  &.grey { color: #6c757d; }
}

.evolution {
  font-weight: 600;
  
  .trend-icon {
    margin-right: 4px;
    font-weight: bold;
  }
}

.trend-up {
  color: #28a745;
}

.trend-down {
  color: #dc3545;
}

.trend-stable, .trend-neutral {
  color: #6c757d;
}

/* Responsive */
@media (max-width: $tablet) {
  .comparison-table {
    font-size: 13px;
    
    th, td {
      padding: 10px 12px;
    }
  }
}

@media (max-width: $mobile) {
  .comparison-table-container {
    overflow-x: auto;
  }
  
  .comparison-table {
    min-width: 800px;
    font-size: 12px;
    
    th, td {
      padding: 8px 10px;
    }
  }
}
</style>