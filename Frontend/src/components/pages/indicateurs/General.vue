<script setup>
import { ref, onMounted } from "vue";
import PageAnalyse from '@/components/template/Page-analyse.vue';
import { useIndicateurGeneral } from "@/composables/useIndicateurGeneral";
import Card from "@/components/atoms/Chart/Card.vue";
import ContentHeader from "@/components/molecules/Analyse/Content-header.vue";
import Texte from "@/components/atoms/Texte.vue";
import FilterSelect from "@/components/atoms/Filter-select.vue";
import LoadingText from "@/components/atoms/Loading-text.vue";
import PopUp from "@/components/molecules/Analyse/Pop-up.vue";
import BoutonIcon from "@/components/atoms/Bouton-icon.vue";
import InterpretationCard from "@/components/atoms/Chart/InterpretationCard.vue";


const filters = ref({
  dateStart: "",
  dateEnd: "",
  idExercice: ""
});
const nombreLignesLoader = ref(4)

const detailsProduits = ref(false)
const detailsCharges = ref(false)
const detailsResultat = ref(false)
const detailsMarge = ref(false)

const {
  exercice,
  loadingTable,
  exercicesList,
  exercicesOptions,
  totalProduits,
  totalCharges,
  nombreEleves,
  resultatNet,
  margeExploitation,
  infoExercice,
  loading,
  comparisons,
  previousYearData,
  refreshAllData,
  initializeData,
  changeExercice
} = useIndicateurGeneral(filters);

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
  if (value === null || value === undefined) return '';
  return new Intl.NumberFormat('mg-MG', {
    // style: 'currency',
    // currency: 'MGA',
    minimumFractionDigits: 0,
    maximumFractionDigits: 0
  }).format(value);
};

// Formater les pourcentages
const formatPercentage = (value) => {
  if (value === null || value === undefined) return '';
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
  <PageAnalyse :menu="'Indicateurs & ratios'" :sousmenu="'Indicateurs généraux'">
    <PopUp v-if="detailsProduits">
      <div class="details-popup">
        <div class="popuphead">
          <Texte :texte="totalProduits?.total_produits?.definition" :type="'dark'" />
          <BoutonIcon @click="detailsProduits = false" icon-name="x-lg" :type="'cancel'" title="Fermer" />
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
                <td id="detailTitle">Chiffres d'affaires</td>
                <td id="detail">{{ formatMoney(totalProduits?.details_comptes?.chiffre_affaires) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.totalProduits?.details_comptes?.chiffre_affaires) }}
                </td>
              </tr>
              <tr>
                <td id="detailTitle">Produits d'exploitation</td>
                <td id="detail">{{ formatMoney(totalProduits?.details_comptes?.produits_exploitation) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.totalProduits?.details_comptes?.produits_exploitation)
                }}
                </td>
              </tr>
              <tr>
                <td id="detailTitle">Produits financiers</td>
                <td id="detail">{{ formatMoney(totalProduits?.details_comptes?.produits_financiers) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.totalProduits?.details_comptes?.produits_financiers) }}
                </td>
              </tr>
              <tr>
                <td id="detailTitle">Produits exceptionnels</td>
                <td id="detail">{{ formatMoney(totalProduits?.details_comptes?.produits_exceptionnels) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.totalProduits?.details_comptes?.produits_exceptionnels)
                }}
                </td>
              </tr>
              <tr>
                <td id="detailTitle">Reprises/Provisions</td>
                <td id="detail">{{ formatMoney(totalProduits?.details_comptes?.reprises_provisions) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.totalProduits?.details_comptes?.reprises_provisions) }}
                </td>
              </tr>
            </tbody>
            <tfoot id="footable">
              <tr>
                <td id="detailTitle">TOTAL</td>
                <td id="detail">{{ formatMoney(totalProduits?.total_produits?.valeur) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.totalProduits?.total_produits?.valeur) }}</td>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>
    </PopUp>
    <PopUp v-if="detailsCharges">
      <div class="details-popup">
        <div class="popuphead">
          <Texte :texte="totalCharges?.total_charges?.definition" :type="'dark'" />
          <BoutonIcon @click="detailsCharges = false" icon-name="x-lg" :type="'cancel'" title="Fermer" />
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
                <td id="detailTitle">Achats et consommations</td>
                <td id="detail">{{ formatMoney(totalCharges?.details_comptes?.achats_consommes) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.totalCharges?.details_comptes?.achats_consommes) }}
                </td>
              </tr>
              <tr>
                <td id="detailTitle">Services extérieurs</td>
                <td id="detail">{{ formatMoney(totalCharges?.details_comptes?.services_exterieurs) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.totalCharges?.details_comptes?.services_exterieurs)
                }}
                </td>
              </tr>
              <tr>
                <td id="detailTitle">Charges personnelles</td>
                <td id="detail">{{ formatMoney(totalCharges?.details_comptes?.charges_personnel) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.totalCharges?.details_comptes?.charges_personnel) }}
                </td>
              </tr>
              <tr>
                <td id="detailTitle">Autres charges d'exploitation</td>
                <td id="detail">{{ formatMoney(totalCharges?.details_comptes?.autres_charges_exploitation) }}</td>
                <td id="detail">{{
                  formatMoney(previousYearData.totalCharges?.details_comptes?.autres_charges_exploitation)
                }}
                </td>
              </tr>
              <tr>
                <td id="detailTitle">Dotations aux amortissements</td>
                <td id="detail">{{ formatMoney(totalCharges?.details_comptes?.dotations_amortissements) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.totalCharges?.details_comptes?.dotations_amortissements)
                }}
                </td>
              </tr>
              <tr>
                <td id="detailTitle">Charges financières</td>
                <td id="detail">{{ formatMoney(totalCharges?.details_comptes?.charges_financieres) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.totalCharges?.details_comptes?.charges_financieres) }}
                </td>
              </tr>
              <tr>
                <td id="detailTitle">Charges exceptionnelles</td>
                <td id="detail">{{ formatMoney(totalCharges?.details_comptes?.charges_exceptionnelles) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.totalCharges?.details_comptes?.charges_exceptionnelles)
                }}
                </td>
              </tr>
            </tbody>
            <tfoot id="footable">
              <tr>
                <td id="detailTitle">TOTAL</td>
                <td id="detail">{{ formatMoney(totalCharges?.total_charges?.valeur) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.totalCharges?.total_charges?.valeur) }}</td>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>
    </PopUp>
    <PopUp v-if="detailsResultat">
      <div class="details-popup">
        <div class="popuphead">
          <Texte :texte="resultatNet?.resultat_net?.definition" :type="'dark'" />
          <BoutonIcon @click="detailsResultat = false" icon-name="x-lg" :type="'cancel'" title="Fermer" />
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
                <td id="detailTitle">Produits</td>
                <td id="detail">{{ formatMoney(resultatNet?.details_calcul?.total_produits) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.resultatNet?.details_calcul?.total_produits) }}
                </td>
              </tr>
              <tr>
                <td id="detailTitle">Charges</td>
                <td id="detail">{{ formatMoney(resultatNet?.details_calcul?.total_charges) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.resultatNet?.details_calcul?.total_charges)
                }}
                </td>
              </tr>
            </tbody>
            <tfoot id="footable">
              <tr>
                <td id="detailTitle">RESULTAT</td>
                <td id="detail">{{ formatMoney(resultatNet?.resultat_net?.valeur) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.resultatNet?.resultat_net?.valeur) }}</td>
              </tr>
              <tr>
                <td id="detailTitle">Formule</td>
                <td id="detail" colspan="2">{{ resultatNet?.formule }}</td>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>
    </PopUp>
    <PopUp v-if="detailsMarge">
      <div class="details-popup">
        <div class="popuphead">
          <Texte :texte="margeExploitation?.description" :type="'dark'" />
          <BoutonIcon @click="detailsMarge = false" icon-name="x-lg" :type="'cancel'" title="Fermer" />
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
                <td id="detailTitle">Produits d'exploitation</td>
                <td id="detail">{{ formatMoney(margeExploitation?.details_calcul?.produits_exploitation) }}</td>
                <td id="detail">{{
                  formatMoney(previousYearData.margeExploitation?.details_calcul?.produits_exploitation) }}
                </td>
              </tr>
              <tr>
                <td id="detailTitle">Charges d'exploitation</td>
                <td id="detail">{{ formatMoney(margeExploitation?.details_calcul?.charges_exploitation) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.margeExploitation?.details_calcul?.charges_exploitation)
                }}
                </td>
              </tr>
              <tr>
                <td id="detailTitle">Resultat d'exploitation</td>
                <td id="detail">{{ formatMoney(margeExploitation?.details_calcul?.resultat_exploitation) }}</td>
                <td id="detail">{{
                  formatMoney(previousYearData.margeExploitation?.details_calcul?.resultat_exploitation) }}</td>
              </tr>
            </tbody>
            <tfoot id="footable">
              <tr>
                <td id="detailTitle">Marge d'exploitation</td>
                <td id="detail">{{ formatPercentage(margeExploitation?.marge_exploitation?.valeur) }}</td>
                <td id="detail">{{ formatPercentage(previousYearData.margeExploitation?.marge_exploitation?.valeur) }}
                </td>
              </tr>
              <tr>
                <td id="detailTitle">Formule</td>
                <td id="detail" colspan="2">{{ margeExploitation?.formule }}</td>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>
    </PopUp>

    <div class="main">
      <!-- Filtres -->
      <div class="filtres">
        <Texte :type="'dark'" :texte="'Exercice comptable'" />
        <div>
          <FilterSelect v-model="filters.idExercice" @change="handleExerciceChange" :disabled="loading">
            <option value="">Exercice ouvert (actuel)</option>
            <option v-for="exo in exercicesOptions" :key="exo.value" :value="exo.value">
              {{ exo.label }}
            </option>
          </FilterSelect>
        </div>
      </div>

      <!-- Indicateurs en cartes -->
      <div class="graphic">

        <div class="cartes">
          <div class="hauteur">
            <Card :texte="'Total les revenus'" :chiffre="parseInt(totalProduits?.total_produits?.valeur)"
              :format="'money'" :icon="'bi bi-arrow-up-circle'" :icon-color="'green'"
              :variation="getTrendIcon(comparisons.produits) + ' ' + comparisons.produits.percentage"
              :colorVariation="getTrendClass(comparisons.produits)" />
            <Card :texte="'Total des dépenses'" :chiffre="parseInt(totalCharges?.total_charges?.valeur)"
              :format="'money'" :icon="'bi bi-arrow-down-circle'" :icon-color="'red'"
              :variation="getTrendIcon(comparisons.charges) + ' ' + comparisons.charges.percentage"
              :colorVariation="getTrendClass(comparisons.charges)" />
          </div>
          <div class="hauteur">

            <Card :texte="'Bénéfices/Pertes'" :chiffre="parseInt(resultatNet?.resultat_net?.valeur)" :format="'money'"
              :icon="'bi bi-cash-stack'" :icon-color="'green'" :negative="true"
              :variation="getTrendIcon(comparisons.resultatNet) + ' ' + comparisons.resultatNet.percentage"
              :colorVariation="getTrendClass(comparisons.resultatNet)" />
            <Card :texte="'Marge d\'exploitation'" :chiffre="parseInt(margeExploitation?.marge_exploitation?.valeur)"
              :format="'percentage'" :icon="'bi bi-percent'" :icon-color="'purple'" :negative="true"
              :variation="getTrendIcon(comparisons.margeExploitation) + ' ' + comparisons.margeExploitation.percentage"
              :colorVariation="getTrendClass(comparisons.margeExploitation)" />
          </div>
        </div>
        <InterpretationCard 
        :chiffre="comparisons.margeExploitation?.hasData ? formatPercentage(comparisons.margeExploitation.evolution) : 'N/A'" 
        :texte="'Marge d\'exploitation'"
        :interpretation="margeExploitation?.marge_exploitation?.interpretation" 
        :icon="getTrendIcon(comparisons.margeExploitation)"
        :variation="comparisons.margeExploitation.percentage"
        :colorVariation="getTrendClass(comparisons.margeExploitation)"
        />
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
                <th class="col">{{ exercice?.Annee_fiscale - 1 }}</th>
                <th class="col">Évolution</th>
                <th class="col">Variation</th>
                <th class="col">Action</th>
              </tr>
            </thead>
            <tbody v-if="!loadingTable">
              <!-- Total Produits -->
              <tr>
                <td class="col">
                  <i class="bi bi-arrow-right trend-icon green"></i>
                  Total des revenus
                </td>
                <td class="col">
                  {{ formatMoney(totalProduits?.total_produits?.valeur) }}
                </td>
                <td class="col">
                  {{ formatMoney(previousYearData.totalProduits?.total_produits?.valeur) }}
                </td>
                <td :class="['evolution', getTrendClass(comparisons.produits)]">
                  <span class="trend-icon">{{ getTrendIcon(comparisons.produits) }}</span>
                  {{ comparisons.produits?.hasData ? formatMoney(comparisons.produits.evolution) : 'N/A' }}
                </td>
                <td :class="['percentage', getTrendClass(comparisons.produits)]">
                  {{ comparisons.produits?.hasData ? `${comparisons.produits.percentage}%` : 'N/A' }}
                </td>
                <td>
                  <BoutonIcon icon-name="eye" type="edit" title="Voir les détails"
                    @click="detailsProduits = !detailsProduits" />
                </td>
              </tr>

              <!-- Total Charges -->
              <tr>
                <td class="col">
                  <i class="bi bi-arrow-left trend-icon red"></i>
                  Total des dépenses
                </td>
                <td class="col">
                  {{ formatMoney(totalCharges?.total_charges?.valeur) }}
                </td>
                <td class="col">
                  {{ formatMoney(previousYearData.totalCharges?.total_charges?.valeur) }}
                </td>
                <td :class="['evolution', getTrendClass(comparisons.charges)]">
                  <span class="trend-icon">{{ getTrendIcon(comparisons.charges) }}</span>
                  {{ comparisons.charges?.hasData ? formatMoney(comparisons.charges.evolution) : 'N/A' }}
                </td>
                <td :class="['percentage', getTrendClass(comparisons.charges)]">
                  {{ comparisons.charges?.hasData ? `${comparisons.charges.percentage}%` : 'N/A' }}
                </td>
                <td>
                  <BoutonIcon icon-name="eye" type="edit" title="Voir les détails"
                    @click="detailsCharges = !detailsCharges" />
                </td>
              </tr>

              <!-- Résultat Net -->
              <tr>
                <td class="col">
                  <i class="bi bi-arrow-left-right trend-icon orange"></i>
                  Bénéfices/Pertes
                </td>
                <td class="col">
                  {{ formatMoney(resultatNet?.resultat_net?.valeur) }}
                </td>
                <td class="col">
                  {{ formatMoney(previousYearData.resultatNet?.resultat_net?.valeur) }}
                </td>
                <td :class="['evolution', getTrendClass(comparisons.resultatNet)]">
                  <span class="trend-icon">{{ getTrendIcon(comparisons.resultatNet) }}</span>
                  {{ comparisons.resultatNet?.hasData ? formatMoney(comparisons.resultatNet.evolution) : 'N/A' }}
                </td>
                <td :class="['percentage', getTrendClass(comparisons.resultatNet)]">
                  {{ comparisons.resultatNet?.hasData ? `${comparisons.resultatNet.percentage}%` : 'N/A' }}
                </td>
                <td>
                  <BoutonIcon icon-name="eye" type="edit" title="Voir les détails"
                    @click="detailsResultat = !detailsResultat" />
                </td>
              </tr>

              <!-- Marge d'exploitation -->
              <tr>
                <td class="col">
                  <i class="bi bi-percent trend-icon purple"></i>
                  Marge d'exploitation
                </td>
                <td class="col">
                  {{ formatPercentage(margeExploitation?.marge_exploitation?.valeur) }}
                </td>
                <td class="col">
                  {{ formatPercentage(previousYearData.margeExploitation?.marge_exploitation?.valeur) }}
                </td>
                <td :class="['evolution', getTrendClass(comparisons.margeExploitation)]">
                  <span class="trend-icon">{{ getTrendIcon(comparisons.margeExploitation) }}</span>
                  {{ comparisons.margeExploitation?.hasData ? formatPercentage(comparisons.margeExploitation.evolution)
                    : 'N/A' }}
                </td>
                <td :class="['percentage', getTrendClass(comparisons.margeExploitation)]">
                  {{ comparisons.margeExploitation?.hasData ? `${comparisons.margeExploitation.percentage}%` : 'N/A' }}
                </td>
                <td>
                  <BoutonIcon icon-name="eye" type="edit" title="Voir les détails"
                    @click="detailsMarge = !detailsMarge" />
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
                <td>
                  <LoadingText :type="'line-1'" />
                </td>
                <td>
                  <LoadingText :type="'line-1'" />
                </td>
                <td>
                  <LoadingText :type="'line-1'" />
                </td>
                <td>
                  <LoadingText :type="'line-1'" />
                </td>
                <td>
                  <LoadingText :type="'line-1'" />
                </td>
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

.details-popup {
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

  th,
  td {
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

  &.green {
    color: #28a745;
  }

  &.red {
    color: #dc3545;
  }

  &.orange {
    color: #fd7e14;
  }

  &.purple {
    color: #6f42c1;
  }

  &.blue {
    color: #007bff;
  }
}

.value-current {
  font-weight: 600;
  color: #2c3e50;
}

.value-previous {
  color: #6c757d;
}

.evolution,
.percentage {
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

.trend-stable,
.trend-neutral {
  color: #6c757d;
  // background-color: rgba(108, 117, 125, 0.1);
}

/* Responsive */
@media (max-width: $tablet) {
  .comparison-table {
    font-size: 13px;

    th,
    td {
      padding: 10px 12px;
    }
  }

  .indicateur-col {
    width: 30%;
  }

  .value-col {
    width: 18%;
  }

  .evolution-col,
  .percentage-col {
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

    th,
    td {
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