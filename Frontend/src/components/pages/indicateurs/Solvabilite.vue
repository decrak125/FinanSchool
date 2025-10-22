<script setup>
import { ref, onMounted } from "vue";
import PageAnalyse from '@/components/template/Page-analyse.vue';
import { useIndicateurSolvabilite } from "@/composables/useIndicateurSolvabilite";
import Card from "@/components/atoms/Chart/Card.vue";
import ContentHeader from "@/components/molecules/Analyse/Content-header.vue";
import Texte from "@/components/atoms/Texte.vue";
import FilterSelect from "@/components/atoms/Filter-select.vue";
import LoadingText from "@/components/atoms/Loading-text.vue";

const nombreLignesLoader = ref(3);
const filters = ref({
  dateStart: "",
  dateEnd: "",
  idExercice: ""
});

const {
  exercice,
  loadingTable,
    RatioEndettement,
    CapaciteRemboursement,
    AutonomieFinanciere,
    loading,
    previousYearData,
    // Computed
    exercicesOptions,
    comparisons, // 📌 NOUVEAU : Comparaisons N vs N-1
    // Fonctions
    refreshAllData,
    initializeData,
    changeExercice,
} = useIndicateurSolvabilite(filters);

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
    <div class="main">
      <ContentHeader :menu="'Indicateurs & ratios'" :sousmenu="'Indicateurs de solvabilité'" />
      
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
              :texte="'Autonomie financière'"
              :chiffre="parseFloat(AutonomieFinanciere?.autonomie_financiere?.valeur)" 
              :format="'percentage'"
              :negative="true" 
              :icon="'bi bi-shield-check'" 
              :icon-color="'green'" 
            />
            <Card 
              :texte="'Capacité de remboursement'"
              :chiffre="parseFloat(CapaciteRemboursement?.capacite_remboursement?.valeur)" 
              :format="'number'" 
              :icon="'bi bi-credit-card-2-front-fill'"
              :icon-color="'orange'" 
            />
          </div>
          <div class="hauteur">
            
            <Card 
              :texte="'Ratio d\'endettement'"
              :chiffre="parseFloat(RatioEndettement?.ratio_endettement?.valeur)" 
              :format="'percentage'" 
              :icon="'bi bi-bank'" 
              :icon-color="'grey'" 
              :negative="true" 
            />
            <Card 
              :texte="'No data'" 
              :chiffre="0"
              :format="'number'" 
              :icon="'bi bi-question-lg'" 
              :icon-color="'purple'" 
              :negative="true" 
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
              </tr>
            </thead>
            <tbody v-if="!loadingTable">
              <!-- Autonomie financière -->
              <tr>
                <td class="col">
                  <i class="bi bi-shield-check trend-icon green"></i>
                  Autonomie financière
                </td>
                <td class="col">
                  {{ formatPercentage(AutonomieFinanciere?.autonomie_financiere?.valeur) }}
                </td>
                <td class="col">
                  {{ formatPercentage(previousYearData.AutonomieFinanciere?.autonomie_financiere?.valeur) }}
                </td>
                <td :class="['evolution', getTrendClass(comparisons.Autonomie)]">
                  <span class="trend-icon">{{ getTrendIcon(comparisons.Autonomie) }}</span>
                  {{ comparisons.Autonomie?.hasData ? formatPercentage(comparisons.Autonomie.evolution) : 'N/A' }}
                </td>
                <td :class="['percentage', getTrendClass(comparisons.Autonomie)]">
                  {{ comparisons.Autonomie?.hasData ? `${comparisons.Autonomie.percentage}%` : 'N/A' }}
                </td>
              </tr>
              
              <!-- Capacité de remboursement -->
              <tr>
                <td class="col">
                  <i class="bi bi-credit-card-2-front-fill trend-icon orange"></i>
                  Capacité de remboursement
                </td>
                <td class="col">
                  {{ CapaciteRemboursement?.capacite_remboursement?.valeur }} ans
                </td>
                <td class="col">
                  {{ previousYearData.CapaciteRemboursement?.capacite_remboursement?.valeur }} ans
                </td>
                <td :class="['evolution', getTrendClass(comparisons.Remboursement)]">
                  <span class="trend-icon">{{ getTrendIcon(comparisons.Remboursement) }}</span>
                  {{ comparisons.Remboursement?.hasData ? comparisons.Remboursement.evolution + 'an' : 'N/A' }}
                </td>
                <td :class="['percentage', getTrendClass(comparisons.Remboursement)]">
                  {{ comparisons.Remboursement?.hasData ? `${comparisons.Remboursement.percentage}%` : 'N/A' }}
                </td>
              </tr>
              
              <!-- Ratio d'endettement -->
              <tr>
                <td class="col">
                  <i class="bi bi-bank trend-icon grey"></i>
                  Ratio d'endettement
                </td>
                <td class="col">
                  {{ formatPercentage(RatioEndettement?.ratio_endettement?.valeur) }}
                </td>
                <td class="col">
                  {{ formatPercentage(previousYearData.RatioEndettement?.ratio_endettement?.valeur) }}
                </td>
                <td :class="['evolution', getTrendClass(comparisons.Endettement)]">
                  <span class="trend-icon">{{ getTrendIcon(comparisons.Endettement) }}</span>
                  {{ comparisons.Endettement?.hasData ? formatPercentage(comparisons.Endettement.evolution) : 'N/A' }}
                </td>
                <td :class="['percentage', getTrendClass(comparisons.Endettement)]">
                  {{ comparisons.Endettement?.hasData ? `${comparisons.Endettement.percentage}%` : 'N/A' }}
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
    </div>
  </PageAnalyse>
</template>

<style lang="scss" scoped>
#axesTable {
  @include table(#f5f5f5);
  
  @media (max-width: $mobile) {
    font-size: 0.875rem;
  }
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