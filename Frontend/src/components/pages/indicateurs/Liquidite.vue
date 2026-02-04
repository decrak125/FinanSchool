<script setup>
import { ref, onMounted, watch } from "vue";
import PageAnalyse from '@/components/template/Page-analyse.vue';
import { useIndicateurLiquidite } from "@/composables/useIndicateurLiquidite";
import Card from "@/components/atoms/Chart/Card.vue";
import Texte from "@/components/atoms/Texte.vue";
import FilterSelect from "@/components/atoms/Filter-select.vue";
import LoadingText from "@/components/atoms/Loading-text.vue";
import PopUp from "@/components/molecules/Analyse/Pop-up.vue";
import BoutonIcon from "@/components/atoms/Bouton-icon.vue";
import InterpretationCarousel from "@/components/molecules/Analyse/InterpretationCarousel.vue";
import { useExportPDF } from "@/composables/useExportPDF";

const nombreLignesLoader = 3;

const filters = ref({
  dateStart: "",
  dateEnd: "",
  idExercice: ""
});

const detailsLiquiditeGenerale = ref(false)
const detailsTresorerieNette = ref(false)
const detailsBFR = ref(false)

const {
  exercice,
  loadingTable,
    LiquiditeGenerale,
    TresorerieNette,
    BFR,
    loading,
    previousYearData,
    // Computed
    exercicesOptions,
    comparisons, // 📌 NOUVEAU : Comparaisons N vs N-1
    // Fonctions
    refreshAllData,
    initializeData,
    changeExercice,
} = useIndicateurLiquidite(filters);

// Initialisez le composable d'export PDF
const { exportLiquiditePDF } = useExportPDF();


// Formater les valeurs monétaires
const formatMoney = (value) => {
  if (value === null || value === undefined) return 'N/A';
  return new Intl.NumberFormat('mg-MG', {
    // style: 'currency',
    // currency: 'MGA',
    minimumFractionDigits: 0,
    maximumFractionDigits: 2
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

const interpretationCardsData = ref([]);

// Fonction sécurisée pour mettre à jour les données du carousel
const updateInterpretationCards = () => {
  console.log('Updating carousel data:', {
    TresorerieNette: TresorerieNette.value,
    BFR: BFR.value,
    LiquiditeGenerale: LiquiditeGenerale.value,
    comparisons: comparisons.value
  });

  interpretationCardsData.value = [
    {
      valeur: formatMoney(TresorerieNette.value?.tresorerie_nette?.valeur),
      texte: "Trésorerie nette",
      chiffre: formatMoney(comparisons.value.Tresorerie.evolution),
      icon: getTrendIcon(comparisons.value?.Tresorerie),
      variation: comparisons.value?.Tresorerie?.percentage || '0',
      colorVariation: getTrendClass(comparisons.value?.Tresorerie),
      interpretation: TresorerieNette.value?.tresorerie_nette?.interpretation || "Évolution des revenus totaux",
      format: 'money'
    },
    {
      valeur: formatMoney(BFR.value?.bfr?.valeur),
      texte: "BFR",
      chiffre: formatMoney(comparisons.value.fondRoulement.evolution),
      icon: getTrendIcon(comparisons.value?.fondRoulement),
      variation: comparisons.value?.fondRoulement?.percentage || '0',
      colorVariation: getTrendClass(comparisons.value?.fondRoulement),
      interpretation: BFR.value?.bfr?.interpretation || "Évolution des dépenses totales",
      format: 'percentage'
    },
    {
      valeur: formatPercentage(LiquiditeGenerale.value?.ratio_liquidite_generale?.valeur),
      texte: "Ratio de liquidité générale",
      chiffre: formatPercentage(comparisons.value.Liquidite.evolution),
      icon: getTrendIcon(comparisons.value?.Liquidite),
      variation: comparisons.value?.Liquidite?.percentage || '0',
      colorVariation: getTrendClass(comparisons.value?.Liquidite),
      interpretation: LiquiditeGenerale.value?.ratio_liquidite_generale?.interpretation || "Évolution du résultat net",
      format: 'percentage',
      negative: true
    }
    // ,
    // {
    //   texte: "ROA",
    //   chiffre: formatPercentage(comparisons.value.ROA.evolution),
    //   icon: getTrendIcon(comparisons.value?.ROA),
    //   variation: comparisons.value?.ROA?.percentage || '0',
    //   colorVariation: getTrendClass(comparisons.value?.ROA),
    //   interpretation: ROA.value?.roa?.interpretation || "Évolution de la marge d'exploitation",
    //   format: 'percentage'
    // }
  ].filter(card => card.chiffre !== undefined && card.chiffre !== null);
  
  console.log('Carousel data updated:', interpretationCardsData.value);
};

// Watcher pour mettre à jour automatiquement le carousel quand les données changent
watch([() => TresorerieNette.value, () => BFR.value, () => LiquiditeGenerale.value, () => comparisons.value], () => {
  if (!loading.value) {
    updateInterpretationCards();
  }
}, { deep: true, immediate: true });
// Chargement initial
onMounted(() => {
  initializeData().then(() => {
    console.log('Data initialized, updating carousel');
    updateInterpretationCards();
  });
});

// Gestion du changement d'exercice
const handleExerciceChange = async (event) => {
  const idExercice = event.target.value;
  await changeExercice(idExercice);
  updateInterpretationCards();
};

// Fonction pour rafraîchir les données manuellement
const handleRefresh = () => {
  refreshAllData();
  updateInterpretationCards();
};

const handleExportPDF = () => {
  const data = {
    exercice: exercice.value,
    TresorerieNette: TresorerieNette.value,
    BFR: BFR.value,
    LiquiditeGenerale: LiquiditeGenerale.value,
    previousYearData: previousYearData.value,
    comparisons: comparisons.value
  };
  
  exportLiquiditePDF(data, loading.value);
};

</script>

<template>
  <PageAnalyse :menu="'Indicateurs & ratios'" :sousmenu="'Indicateurs de liquidité'">
    <PopUp v-if="detailsTresorerieNette">
      <div class="details-popup">
        <div class="popuphead">
          <Texte :texte="TresorerieNette?.definition" :type="'dark'" />
          <BoutonIcon @click="detailsTresorerieNette = false" icon-name="x-lg" :type="'cancel'" title="Fermer" />
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
                <td id="detailTitle">Banque</td>
                <td id="detail">{{ formatMoney(TresorerieNette?.details_calcul?.comptes_tresorerie?.banque) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.TresorerieNette?.details_calcul?.comptes_tresorerie?.banque)
                }}
                </td>
              </tr>
              <tr>
                <td id="detailTitle">Découverts</td>
                <td id="detail">{{ formatMoney(TresorerieNette?.details_calcul?.comptes_tresorerie?.decouverts) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.TresorerieNette?.details_calcul?.comptes_tresorerie?.decouverts) }}
                </td>
              </tr>
            </tbody>
            <tfoot id="footable">
              <tr>
                <td id="detailTitle">Trésorerie nette</td>
                <td id="detail">{{ formatMoney(TresorerieNette?.tresorerie_nette?.valeur) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.TresorerieNette?.tresorerie_nette?.valeur) }}</td>
              </tr>
              <tr>
                <td id="detailTitle">Formule</td>
                <td id="detail" colspan="2">{{ TresorerieNette?.formule }}</td>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>
    </PopUp>
        <PopUp v-if="detailsBFR">
      <div class="details-popup">
        <div class="popuphead">
          <Texte :texte="BFR?.definition" :type="'dark'" />
          <BoutonIcon @click="detailsBFR = false" icon-name="x-lg" :type="'cancel'" title="Fermer" />
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
                <td id="detailTitle">stocks</td>
                <td id="detail">{{ formatMoney(BFR?.details_calcul?.stocks) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.BFR?.details_calcul?.stocks)
                }}
                </td>
              </tr>
              <tr>
                <td id="detailTitle">Créances clients</td>
                <td id="detail">{{ formatMoney(BFR?.details_calcul?.creances_clients) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.BFR?.details_calcul?.creances_clients) }}
                </td>
              </tr>
              <tr>
                <td id="detailTitle">Dettes fournisseurs</td>
                <td id="detail">{{ formatMoney(BFR?.details_calcul?.dettes_fournisseurs) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.BFR?.details_calcul?.dettes_fournisseurs) }}
                </td>
              </tr>
            </tbody>
            <tfoot id="footable">
              <tr>
                <td id="detailTitle">Besoin en fonds de roulement</td>
                <td id="detail">{{ formatMoney(BFR?.bfr?.valeur) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.BFR?.bfr?.valeur) }}</td>
              </tr>
              <tr>
                <td id="detailTitle">Formule</td>
                <td id="detail" colspan="2">{{ BFR?.formule }}</td>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>
    </PopUp>
        <PopUp v-if="detailsLiquiditeGenerale">
      <div class="details-popup">
        <div class="popuphead">
          <Texte :texte="LiquiditeGenerale?.definition" :type="'dark'" />
          <BoutonIcon @click="detailsLiquiditeGenerale = false" icon-name="x-lg" :type="'cancel'" title="Fermer" />
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
                <td id="detailTitle">Actif circulant</td>
                <td id="detail">{{ formatMoney(LiquiditeGenerale?.details_calcul?.actif_circulant) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.LiquiditeGenerale?.details_calcul?.actif_circulant)
                }}
                </td>
              </tr>
              <tr>
                <td id="detailTitle">Passif à court terme</td>
                <td id="detail">{{ formatMoney(LiquiditeGenerale?.details_calcul?.passif_court_terme) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.LiquiditeGenerale?.details_calcul?.passif_court_terme) }}
                </td>
              </tr>
            </tbody>
            <tfoot id="footable">
              <tr>
                <td id="detailTitle">Liquidité générale</td>
                <td id="detail">{{ formatPercentage(LiquiditeGenerale?.ratio_liquidite_generale?.valeur) }}</td>
                <td id="detail">{{ formatPercentage(previousYearData.LiquiditeGenerale?.ratio_liquidite_generale?.valeur) }}</td>
              </tr>
              <tr>
                <td id="detailTitle">Formule</td>
                <td id="detail" colspan="2">{{ LiquiditeGenerale?.formule }}</td>
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

      <!-- Indicateurs en cartes -->
      <div class="graphic">
        <div class="cartes">
          <div class="hauteur">
            <Card 
              :texte="'Trésorerie nette'"
              :chiffre="parseFloat(TresorerieNette?.tresorerie_nette?.valeur)" 
              :format="'money'" 
              :icon="'bi bi-wallet2'" 
              :icon-color="'brown'" 
              :variation="getTrendIcon(comparisons.Tresorerie) + ' ' + comparisons.Tresorerie.percentage"
              :colorVariation="getTrendClass(comparisons.Tresorerie)"
            />
            <Card 
              :texte="'Besoins de fond de roulement'"
              :chiffre="parseFloat(BFR?.bfr?.valeur)" 
              :format="'money'" 
              :icon="'bi bi-arrow-repeat'"
              :icon-color="'orange'" 
              :variation="getTrendIcon(comparisons.fondRoulement) + ' ' + comparisons.fondRoulement.percentage"
              :colorVariation="getTrendClass(comparisons.fondRoulement)"
            />
          </div>
          <div class="hauteur">
            
            <Card 
              :texte="'Ratio liquidité générale'"
              :chiffre="parseFloat(LiquiditeGenerale?.ratio_liquidite_generale?.valeur)" 
              :format="'percentage'" 
              :icon="'bi bi-water'" 
              :icon-color="'#499ef8'" 
              :negative="true" 
              :variation="getTrendIcon(comparisons.Liquidite) + ' ' + comparisons.Liquidite.percentage"
              :colorVariation="getTrendClass(comparisons.Liquidite)"
            />
            <!-- <Card 
              :texte="'No data'" 
              :chiffre="0"
              :format="'number'" 
              :icon="'bi bi-question-lg'" 
              :icon-color="'purple'" 
              :negative="true" 
            /> -->
          </div>
        </div>
        <InterpretationCarousel 
          :cards="interpretationCardsData"
          :autoPlay="true"
          :autoPlayInterval="5000"
          :showNavigation="true"
        />
      </div>

      <!-- Tableau de comparaison N vs N-1 -->
      <div class="comparison-section">
        <div class="section-header">
          <div class="infos">
            <Texte :type="'bold-dark'" :texte="'Vue et évolution des indicateurs'" />
          <Texte :type="'dark'" :texte="'Montants en Ariary (Ar).'" />
          </div>
          <div class="iconbtn" @click="handleExportPDF">
                  <i class="bi bi-file-earmark-pdf-fill"></i>
          </div>
        </div>
        
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
              <!-- Trésorerie nette -->
              <tr>
                <td class="col">
                  <i class="bi bi-wallet2 trend-icon brown"></i>
                  Trésorerie nette
                </td>
                <td class="col">
                  {{ formatMoney(TresorerieNette?.tresorerie_nette?.valeur) }}
                </td>
                <td class="col">
                  {{ formatMoney(previousYearData.TresorerieNette?.tresorerie_nette?.valeur) }}
                </td>
                <td :class="['evolution', getTrendClass(comparisons.Tresorerie)]">
                  <span class="trend-icon">{{ getTrendIcon(comparisons.Tresorerie) }}</span>
                  {{ comparisons.Tresorerie?.hasData ? formatMoney(comparisons.Tresorerie.evolution) : 'N/A' }}
                </td>
                <td :class="['percentage', getTrendClass(comparisons.Tresorerie)]">
                  {{ comparisons.Tresorerie?.hasData ? `${comparisons.Tresorerie.percentage}%` : 'N/A' }}
                </td>
                <td>
                  <BoutonIcon icon-name="eye-fill" type="edit" title="Voir les détails"
                    @click="detailsTresorerieNette = !detailsTresorerieNette" />
                </td>
              </tr>
              
              <!-- Besoins de fond de roulement -->
              <tr>
                <td class="col">
                  <i class="bi bi bi-arrow-repeat trend-icon orange"></i>
                  Besoins de fond de roulement
                </td>
                <td class="col">
                  {{ formatMoney(BFR?.bfr?.valeur) }}
                </td>
                <td class="col">
                  {{ formatMoney(previousYearData.BFR?.bfr?.valeur) }}
                </td>
                <td :class="['evolution', getTrendClass(comparisons.fondRoulement)]">
                  <span class="trend-icon">{{ getTrendIcon(comparisons.fondRoulement) }}</span>
                  {{ comparisons.fondRoulement?.hasData ? formatMoney(comparisons.fondRoulement.evolution) : 'N/A' }}
                </td>
                <td :class="['percentage', getTrendClass(comparisons.fondRoulement)]">
                  {{ comparisons.fondRoulement?.hasData ? `${comparisons.fondRoulement.percentage}%` : 'N/A' }}
                </td>
                <td>
                  <BoutonIcon icon-name="eye-fill" type="edit" title="Voir les détails"
                    @click="detailsBFR = !detailsBFR" />
                </td>
              </tr>
              
              <!-- Ratio liquidité générale -->
              <tr>
                <td class="col">
                  <i class="bi bi-water trend-icon blue"></i>
                  Ratio liquidité générale
                </td>
                <td class="col">
                  {{ formatPercentage(LiquiditeGenerale?.ratio_liquidite_generale?.valeur) }}
                </td>
                <td class="col">
                  {{ formatPercentage(previousYearData.LiquiditeGenerale?.ratio_liquidite_generale?.valeur) }}
                </td>
                <td :class="['evolution', getTrendClass(comparisons.Liquidite)]">
                  <span class="trend-icon">{{ getTrendIcon(comparisons.Liquidite) }}</span>
                  {{ comparisons.Liquidite?.hasData ? formatPercentage(comparisons.Liquidite.evolution) : 'N/A' }}
                </td>
                <td :class="['percentage', getTrendClass(comparisons.Liquidite)]">
                  {{ comparisons.Liquidite?.hasData ? `${comparisons.Liquidite.percentage}%` : 'N/A' }}
                </td>
                <td>
                  <BoutonIcon icon-name="eye-fill" type="edit" title="Voir les détails"
                    @click="detailsLiquiditeGenerale = !detailsLiquiditeGenerale" />
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
              </tr>
            </tbody>
          </table>
        </div>
      </div>
  </PageAnalyse>
</template>

<style lang="scss" scoped>
#axesTable {
  @include table();
  border-radius: $radius-pm;
  cursor: pointer;

  // @media (max-width: $mobile) {
  //   font-size: 0.875rem;
  // }
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
  gap: 24px;

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
  padding: 0 18px;
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
  @include position-contenus(flex, baseline, center);
  padding: 0;
  gap: 24px;

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
  gap: 24px;

  @media (max-width: $tablet) {
    gap: 18px;
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
  height: 100%;
  @include glass();
  border-radius: $radius-pm;
  padding: 18px;
  gap: 8px;
}

.section-header {
  @include position-contenus(flex, space-between, baseline);
  // margin-bottom: 16px;
  padding: 12px;
  h3 {
    margin: 0;
    color: #2c3e50;
    font-size: 18px;
    font-weight: 600;
  }
}
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