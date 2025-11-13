<script setup>
import { ref, onMounted, watch } from "vue";
import { useIndicateurRentabilite } from "@/composables/useIndicateurRentabilite";
import InterpretationCarousel from "@/components/molecules/Analyse/InterpretationCarousel.vue";


const nombreLignesLoader = 5;

const filters = ref({
  dateStart: "",
  dateEnd: "",
  idExercice: ""
});

const {
  MargeBrute,
  MargeNette,
  ROE,
  ROA,
  loading,
  comparisons,
  refreshAllData,
  initializeData,
  changeExercice
} = useIndicateurRentabilite(filters);



// Formater les valeurs monétaires
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

// Préparer les données pour le carousel
const interpretationCardsData = ref([]);

// Fonction sécurisée pour mettre à jour les données du carousel
const updateInterpretationCards = () => {
  console.log('Updating carousel data:', {
    MargeBrute: MargeBrute.value,
    MargeNette: MargeNette.value,
    ROE: ROE.value,
    ROA: ROA.value,
    comparisons: comparisons.value
  });

  interpretationCardsData.value = [
    {
      texte: "Marge brute",
      chiffre: formatPercentage(comparisons.value.brute.evolution),
      icon: getTrendIcon(comparisons.value?.brute),
      variation: comparisons.value?.brute?.percentage || '0',
      colorVariation: getTrendClass(comparisons.value?.brute),
      interpretation: MargeBrute.value?.marge_brute?.interpretation || "Évolution des revenus totaux",
      format: 'percentage'
    },
    {
      texte: "Marge nette",
      chiffre: formatPercentage(comparisons.value.nette.evolution),
      icon: getTrendIcon(comparisons.value?.nette),
      variation: comparisons.value?.nette?.percentage || '0',
      colorVariation: getTrendClass(comparisons.value?.nette),
      interpretation: MargeNette.value?.marge_nette?.interpretation || "Évolution des dépenses totales",
      format: 'percentage'
    },
    {
      texte: "ROE",
      chiffre: formatPercentage(comparisons.value.ROE.evolution),
      icon: getTrendIcon(comparisons.value?.ROE),
      variation: comparisons.value?.ROE?.percentage || '0',
      colorVariation: getTrendClass(comparisons.value?.ROE),
      interpretation: ROE.value?.roe?.interpretation || "Évolution du résultat net",
      format: 'percentage',
      negative: true
    },
    {
      texte: "ROA",
      chiffre: formatPercentage(comparisons.value.ROA.evolution),
      icon: getTrendIcon(comparisons.value?.ROA),
      variation: comparisons.value?.ROA?.percentage || '0',
      colorVariation: getTrendClass(comparisons.value?.ROA),
      interpretation: ROA.value?.roa?.interpretation || "Évolution de la marge d'exploitation",
      format: 'percentage'
    }
  ].filter(card => card.chiffre !== undefined && card.chiffre !== null);
  
  console.log('Carousel data updated:', interpretationCardsData.value);
};

// Watcher pour mettre à jour automatiquement le carousel quand les données changent
watch([() => MargeBrute.value, () => MargeNette.value, () => ROE.value, () => ROA.value, () => comparisons.value], () => {
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
</script>

<template>
      
      <!-- Filtres -->
      <!-- <div class="filtres">
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
      </div> -->

      <!-- MB -->
        <InterpretationCarousel 
          :cards="interpretationCardsData"
          :autoPlay="true"
          :autoPlayInterval="5000"
          :showNavigation="true"
        />
</template>

<style lang="scss" scoped>
</style>