<script setup>
import { ref, onMounted } from "vue";
import PageAnalyse from '@/components/template/Page-analyse.vue';
import { useIndicateurRentabilite } from "@/composables/useIndicateurRentabilite";
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

const detailsMargebrute = ref(false)
const detailsMargenette = ref(false)
const detailsRoe= ref(false)
const detailsRoa = ref(false)

const {
  loadingTable,
  exercice,
  exercicesOptions,
  MargeBrute,
  MargeNette,
  ROE,
  ROA,
  loading,
  comparisons,
  previousYearData,
  refreshAllData,
  initializeData,
  changeExercice
} = useIndicateurRentabilite(filters);

// Chargement initial
onMounted(() => {
  initializeData();
});

// Gestion du changement d'exercice
const handleExerciceChange = async (event) => {
  const idExercice = event.target.value;
  await changeExercice(idExercice);
};

// Fonction pour rafraîchir les données manuellement
const handleRefresh = () => {
  refreshAllData();
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
</script>

<template>
  <PageAnalyse>
    <!-- POP UP  -->
    <PopUp v-if="detailsMargebrute">
      <div class="details-popup">
        <div class="popuphead">
          <Texte :texte="'Mesure la rentabilité opérationnelle de base.'" :type="'dark'" />
          <BoutonIcon @click="detailsMargebrute = false" icon-name="x-lg" :type="'cancel'" title="Fermer" />
        </div>
        <div class="indicateur-detail">
          <table class="table" id="axesTable">
            <thead>
              <tr>
                <th class="col">Indicateur</th>
                <th class="col">{{ exercice?.Annee_fiscale }}</th>
                <th class="col">{{ exercice?.Annee_fiscale - 1 }}</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td id="detailTitle">Chiffre d'affaires</td>
                <td id="detail">{{ formatMoney(MargeBrute?.details_calcul?.chiffre_affaires) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.MargeBrute?.details_calcul?.chiffre_affaires) }}
                </td>
              </tr>
              <tr>
                <td id="detailTitle">Cout des ventes</td>
                <td id="detail">{{ formatMoney(MargeBrute?.details_calcul?.cout_ventes) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.MargeBrute?.details_calcul?.cout_ventes)
                }}
                </td>
              </tr>
              <tr>
                <td id="detailTitle">Marge absolue</td>
                <td id="detail">{{ formatMoney(MargeBrute?.details_calcul?.marge_absolue) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.MargeBrute?.details_calcul?.marge_absolue) }}</td>
              </tr>
            </tbody>
            <tfoot id="footable">
              <tr>
                <td id="detailTitle">Marge Brute</td>
                <td id="detail">{{ formatPercentage(MargeBrute?.marge_brute?.valeur) }}</td>
                <td id="detail">{{ formatPercentage(previousYearData.MargeBrute?.marge_brute?.valeur) }}</td>
              </tr>
              <tr>
                <td id="detailTitle">Formule</td>
                <td id="detail" colspan="2">{{ MargeBrute?.formule }}</td>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>
    </PopUp>
    <PopUp v-if="detailsMargenette">
      <div class="details-popup">
        <div class="popuphead">
          <Texte :texte="'Montre le bénéfice final par Ar de ventes.'" :type="'dark'" />
          <BoutonIcon @click="detailsMargenette = false" icon-name="x-lg" :type="'cancel'" title="Fermer" />
        </div>
        <div class="indicateur-detail">
          <table class="table" id="axesTable">
            <thead>
              <tr>
                <th class="col">Indicateur</th>
                <th class="col">{{ exercice?.Annee_fiscale }}</th>
                <th class="col">{{ exercice?.Annee_fiscale - 1 }}</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td id="detailTitle">Resultat net</td>
                <td id="detail">{{ formatMoney(MargeNette?.details_calcul?.resultat_net) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.MargeNette?.details_calcul?.resultat_net)
                }}
                </td>
              </tr>
              <tr>
                <td id="detailTitle">Chiffre d'affaires</td>
                <td id="detail">{{ formatMoney(MargeNette?.details_calcul?.chiffre_affaires) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.MargeNette?.details_calcul?.chiffre_affaires) }}
                </td>
              </tr>
            </tbody>
            <tfoot id="footable">
              <tr>
                <td id="detailTitle">Marge Nette</td>
                <td id="detail">{{ formatPercentage(MargeNette?.marge_nette?.valeur) }}</td>
                <td id="detail">{{ formatPercentage(previousYearData.MargeNette?.marge_nette?.valeur) }}</td>
              </tr>
              <tr>
                <td id="detailTitle">Formule</td>
                <td id="detail" colspan="2">{{ MargeNette?.formule }}</td>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>
    </PopUp>
    <PopUp v-if="detailsRoe">
      <div class="details-popup">
        <div class="popuphead">
          <Texte :texte="ROE?.definition" :type="'dark'" />
          <BoutonIcon @click="detailsRoe = false" icon-name="x-lg" :type="'cancel'" title="Fermer" />
        </div>
        <div class="indicateur-detail">
          <table class="table" id="axesTable">
            <thead>
              <tr>
                <th class="col">Indicateur</th>
                <th class="col">{{ exercice?.Annee_fiscale }}</th>
                <th class="col">{{ exercice?.Annee_fiscale - 1 }}</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td id="detailTitle">Resultat net</td>
                <td id="detail">{{ formatMoney(ROE?.details_calcul?.resultat_net) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.ROE?.details_calcul?.resultat_net)
                }}
                </td>
              </tr>
              <tr>
                <td id="detailTitle">Capitaux propres</td>
                <td id="detail">{{ formatMoney(ROE?.details_calcul?.capitaux_propres) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.ROE?.details_calcul?.capitaux_propres) }}
                </td>
              </tr>
            </tbody>
            <tfoot id="footable">
              <tr>
                <td id="detailTitle">ROE</td>
                <td id="detail">{{ formatPercentage(ROE?.roe?.valeur) }}</td>
                <td id="detail">{{ formatPercentage(previousYearData.ROE?.roe?.valeur) }}</td>
              </tr>
              <tr>
                <td id="detailTitle">Formule</td>
                <td id="detail" colspan="2">{{ ROE?.formule }}</td>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>
    </PopUp>
    <PopUp v-if="detailsRoa">
      <div class="details-popup">
        <div class="popuphead">
          <Texte :texte="ROA?.definition" :type="'dark'" />
          <BoutonIcon @click="detailsRoa = false" icon-name="x-lg" :type="'cancel'" title="Fermer" />
        </div>
        <div class="indicateur-detail">
          <table class="table" id="axesTable">
            <thead>
              <tr>
                <th class="col">Indicateur</th>
                <th class="col">{{ exercice?.Annee_fiscale }}</th>
                <th class="col">{{ exercice?.Annee_fiscale - 1 }}</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td id="detailTitle">Resultat net</td>
                <td id="detail">{{ formatMoney(ROA?.details_calcul?.resultat_net) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.ROA?.details_calcul?.resultat_net)
                }}
                </td>
              </tr>
              <tr>
                <td id="detailTitle">Total actif</td>
                <td id="detail">{{ formatMoney(ROA?.details_calcul?.total_actif) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.ROA?.details_calcul?.total_actif) }}
                </td>
              </tr>
            </tbody>
            <tfoot id="footable">
              <tr>
                <td id="detailTitle">ROA</td>
                <td id="detail">{{ formatPercentage(ROA?.roa?.valeur) }}</td>
                <td id="detail">{{ formatPercentage(previousYearData.ROA?.roa?.valeur) }}</td>
              </tr>
              <tr>
                <td id="detailTitle">Formule</td>
                <td id="detail" colspan="2">{{ ROA?.formule }}</td>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>
    </PopUp>



    <div class="main">
      <ContentHeader :menu="'Indicateurs & ratios'" :sousmenu="'Indicateurs de rentabilité'" />
      
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

      <!-- MB -->
      <div class="graphic">
        <div class="cartes">
          <div class="hauteur">
            <Card 
              :texte="'Marge brute'"
              :chiffre="parseFloat(MargeBrute?.marge_brute?.valeur)"
              :format="'percentage'" 
              :icon="'bi bi-bar-chart-fill'" 
              :icon-color="'green'" 
              :negative="true"
              :variation="getTrendIcon(comparisons.brute) + ' ' + comparisons.brute.percentage"
              :colorVariation="getTrendClass(comparisons.brute)"
            />
            <Card 
              :texte="'Marge nette'"
              :chiffre="parseFloat(MargeNette?.marge_nette?.valeur)" 
              :format="'percentage'" 
              :icon="'bi bi-bar-chart-fill'"
              :icon-color="'blue'" 
              :negative="true"
              :variation="getTrendIcon(comparisons.nette) + ' ' + comparisons.nette.percentage"
              :colorVariation="getTrendClass(comparisons.nette)"
            />
          </div>
          <div class="hauteur">
            
            <Card 
              :texte="'ROE'"
              :chiffre="parseFloat(ROE?.roe?.valeur)" 
              :format="'percentage'" 
              :icon="'bi bi-people-fill'" 
              :icon-color="'purple'" 
              :negative="true" 
              :variation="getTrendIcon(comparisons.ROE) + ' ' + comparisons.ROE.percentage"
              :colorVariation="getTrendClass(comparisons.ROE)"
            />
            <Card 
              :texte="'ROA'" 
              :chiffre="parseFloat(ROA?.roa?.valeur)"
              :format="'percentage'" 
              :icon="'bi bi-building'" 
              :icon-color="'grey'" 
              :negative="true" 
              :variation="getTrendIcon(comparisons.ROA) + ' ' + comparisons.ROA.percentage"
              :colorVariation="getTrendClass(comparisons.ROA)"
            />
          </div>
        </div>
      </div>

      <!-- Tableau de comparaison N vs N-1 -->
      <div class="comparison-section">
        <div class="section-header">
          <Texte :type="'bold-dark'" :texte="'Vue et évolution des indicateurs'" />
        </div>
        
        <div class="comparison-table-container">
          <table class="table" id="axesTable">
            <thead>
              <tr>
                <th class="col">Indicateur</th>
                <th class="col">{{ exercice?.Annee_fiscale }}</th>
                <th class="col">{{ exercice?.Annee_fiscale-1 }}</th>
                <th class="col">Évolution</th>
                <th class="col">Variation</th>
                <th class="col">Action</th>
              </tr>
            </thead>
            <tbody v-if="!loadingTable">
              <!-- Marge brute -->
              <tr>
                <td class="col">
                  <i class="bi bi-bar-chart-fill trend-icon green"></i>
                  Marge brute
                </td>
                <td class="col">
                  {{ formatPercentage(MargeBrute?.marge_brute?.valeur) }}
                </td>
                <td class="col">
                  {{ formatPercentage(previousYearData.MargeBrute?.marge_brute?.valeur) }}
                </td>
                <td :class="['evolution', getTrendClass(comparisons.brute)]">
                  <span class="trend-icon">{{ getTrendIcon(comparisons.brute) }}</span>
                  {{ comparisons.brute?.hasData ? formatPercentage(comparisons.brute.evolution) : 'N/A' }}
                </td>
                <td :class="['percentage', getTrendClass(comparisons.brute)]">
                  {{ comparisons.brute?.hasData ? `${comparisons.brute.percentage}%` : 'N/A' }}
                </td>
                <td>
                  <BoutonIcon icon-name="eye" type="edit" title="Voir les détails"
                    @click="detailsMargebrute = !detailsMargebrute" />
                </td>
              </tr>
              
              <!-- Marge nette -->
              <tr>
                <td class="col">
                  <i class="bi bi-bar-chart-fill trend-icon blue"></i>
                  Marge nette
                </td>
                <td class="col">
                  {{ formatPercentage(MargeNette?.marge_nette?.valeur) }}
                </td>
                <td class="col">
                  {{ formatPercentage(previousYearData.MargeNette?.marge_nette?.valeur) }}
                </td>
                <td :class="['evolution', getTrendClass(comparisons.nette)]">
                  <span class="trend-icon">{{ getTrendIcon(comparisons.nette) }}</span>
                  {{ comparisons.nette?.hasData ? formatPercentage(comparisons.nette.evolution) : 'N/A' }}
                </td>
                <td :class="['percentage', getTrendClass(comparisons.nette)]">
                  {{ comparisons.nette?.hasData ? `${comparisons.nette.percentage}%` : 'N/A' }}
                </td>
                <td>
                  <BoutonIcon icon-name="eye" type="edit" title="Voir les détails"
                    @click="detailsMargenette = !detailsMargenette" />
                </td>
              </tr>
              
              <!-- ROE -->
              <tr>
                <td class="col">
                  <i class="bi bi-people-fill trend-icon purple"></i>
                  ROE
                </td>
                <td class="col">
                  {{ formatPercentage(ROE?.roe?.valeur) }}
                </td>
                <td class="col">
                  {{ formatPercentage(previousYearData.ROE?.roe?.valeur) }}
                </td>
                <td :class="['evolution', getTrendClass(comparisons.ROE)]">
                  <span class="trend-icon">{{ getTrendIcon(comparisons.ROE) }}</span>
                  {{ comparisons.ROE?.hasData ? formatPercentage(comparisons.ROE.evolution) : 'N/A' }}
                </td>
                <td :class="['percentage', getTrendClass(comparisons.ROE)]">
                  {{ comparisons.ROE?.hasData ? `${comparisons.ROE.percentage}%` : 'N/A' }}
                </td>
                <td>
                  <BoutonIcon icon-name="eye" type="edit" title="Voir les détails"
                    @click="detailsRoe = !detailsRoe" />
                </td>
              </tr>
              
              <!--ROA -->
              <tr>
                <td class="col">
                  <i class="bi bi-building trend-icon grey"></i>
                 ROA
                </td>
                <td class="col">
                  {{ formatPercentage(ROA?.roa?.valeur) }}
                </td>
                <td class="col">
                  {{ formatPercentage(previousYearData.ROA?.roa?.valeur) }}
                </td>
                <td :class="['evolution', getTrendClass(comparisons.ROA)]">
                  <span class="trend-icon">{{ getTrendIcon(comparisons.ROA) }}</span>
                  {{ comparisons.ROA?.hasData ? formatPercentage(comparisons.ROA.evolution) : 'N/A' }}
                </td>
                <td :class="['percentage', getTrendClass(comparisons.ROA)]">
                  {{ comparisons.ROA?.hasData ? `${comparisons.ROA.percentage}%` : 'N/A' }}
                </td>
                <td>
                  <BoutonIcon icon-name="eye" type="edit" title="Voir les détails"
                    @click="detailsRoa = !detailsRoa" />
                </td>
              </tr>
              
              <!-- Nombre d'élèves -->
              <!-- <tr>
                <td class="col">
                  <i class="bi bi-people trend-icon blue"></i>
                  Nombre d'élèves
                </td>
                <td class="col">
                  {{ nombreEleves?.count || 'N/A' }}
                </td>
                <td class="value-previous">
                  {{ previousYearData.nombreEleves?.count || 'N/A' }}
                </td>
                <td :class="['evolution', getTrendClass(comparisons.nombreEleves)]">
                  <span class="trend-icon">{{ getTrendIcon(comparisons.nombreEleves) }}</span>
                  {{ comparisons.nombreEleves?.hasData ? comparisons.nombreEleves.evolution : 'N/A' }}
                </td>
                <td :class="['percentage', getTrendClass(comparisons.nombreEleves)]">
                  {{ comparisons.nombreEleves?.hasData ? `${comparisons.nombreEleves.percentage}%` : 'N/A' }}
                </td>
              </tr> -->
            </tbody>
            <tbody v-if="loadingTable">
              <tr v-for="n in nombreLignesLoader" :key="'loader-' + n">
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
  // font-size: 16px;
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

// .exercice-header {
//   @include position-contenus(flex, space-between, center);
//   margin-bottom: 8px;
  
//   @media (max-width: $mobile) {
//     flex-direction: column;
//     align-items: flex-start;
//     gap: 8px;
//   }
// }

// .exercice-header h3 {
//   margin: 0;
//   color: #2c3e50;
//   font-size: 18px;
// }

// .statut-badge {
//   padding: 4px 12px;
//   border-radius: 20px;
//   font-size: 12px;
//   font-weight: 600;
//   text-transform: uppercase;
// }

// .statut-ouvert {
//   background-color: #d4edda;
//   color: #155724;
// }

// .statut-ferme {
//   background-color: #f8d7da;
//   color: #721c24;
// }

// .exercice-period {
//   margin: 0;
//   color: #555;
//   font-size: 14px;
// }

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
//   box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
//   overflow: hidden;
}

.comparison-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 14px;
  
  th, td {
    padding: 12px 16px;
    text-align: left;
    border-bottom: 1px solid #e9ecef;
  }
  
  th {
    background-color: #f8f9fa;
    font-weight: 600;
    color: #495057;
    border-bottom: 2px solid #dee2e6;
  }
  
  tbody tr:hover {
    background-color: #f8f9fa;
  }
}

.indicateur-col {
  width: 25%;
}

.value-col {
  width: 20%;
  text-align: right;
}

.evolution-col {
  width: 17.5%;
  text-align: right;
}

.percentage-col {
  width: 17.5%;
  text-align: right;
}

.indicateur-name {
  font-weight: 500;
  color: #2c3e50;
  display: flex;
  align-items: center;
  gap: 8px;
}

.trend-icon {
  font-size: 16px;
  
  &.green { color: #28a745; }
  &.red { color: #dc3545; }
  &.orange { color: #fd7e14; }
  &.purple { color: #6f42c1; }
  &.blue { color: #007bff; }
}

.value-current {
  font-weight: 600;
  color: #2c3e50;
}

.value-previous {
  color: #6c757d;
}

.evolution, .percentage {
  font-weight: 600;
  
  .trend-icon {
    margin-right: 4px;
    font-weight: bold;
  }
}

.trend-up {
  color: #28a745;
//   background-color: rgba(40, 167, 69, 0.1);
}

.trend-down {
  color: #dc3545;
//   background-color: rgba(220, 53, 69, 0.1);
}

.trend-stable, .trend-neutral {
  color: #6c757d;
  // background-color: rgba(108, 117, 125, 0.1);
}

/* Responsive */
@media (max-width: $tablet) {
  .comparison-table {
    font-size: 13px;
    
    th, td {
      padding: 10px 12px;
    }
  }
  
  .indicateur-col {
    width: 30%;
  }
  
  .value-col {
    width: 18%;
  }
  
  .evolution-col, .percentage-col {
    width: 17%;
  }
}

@media (max-width: $mobile) {
  .comparison-table-container {
    overflow-x: auto;
  }
  
  .comparison-table {
    min-width: 600px;
    font-size: 12px;
    
    th, td {
      padding: 8px 10px;
    }
  }
  
  .indicateur-name {
    flex-direction: column;
    align-items: flex-start;
    gap: 4px;
  }
}
</style>