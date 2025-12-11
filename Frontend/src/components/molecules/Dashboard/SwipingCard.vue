<script setup>
import { ref, onMounted, defineProps } from "vue";
import { useIndicateurPedagogique } from "@/composables/useIndicateurPedagogique";
import InterpretationCarousel from "@/components/molecules/Analyse/InterpretationCarousel.vue";
import Texte from "@/components/atoms/Texte.vue";
import FilterSelect from "@/components/atoms/Filter-select.vue";

// Définir la prop annee
const props = defineProps({
  annee: {
    type: String,
    default: () => new Date().getFullYear().toString()
  }
});

// Initialiser les filtres avec l'année du parent
const filters = ref({
  dateStart: `${props.annee}-01-01`,
  dateEnd: `${props.annee}-12-31`,
  idExercice: ""
});

const {
  exercice,
  loadingTable,
  exercicesOptions,
  coutFonctionnement,
  chiffreAffaires,
  partMasseSalariale,
  margeParEleve,
  loading,
  comparisons,
  refreshAllData,
  initializeData,
  changeExercice
} = useIndicateurPedagogique(filters);

// Formater les valeurs monétaires
const formatMoney = (value) => {
  if (value === null || value === undefined) return '';
  return new Intl.NumberFormat('mg-MG', {
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

// Préparer les données pour le carousel
const interpretationCardsData = ref([]);

// Fonction pour mettre à jour les données du carousel
const updateInterpretationCards = () => {
  console.log('Updating carousel data pédagogique pour l\'année:', props.annee);

  interpretationCardsData.value = [
    {
      texte: "Coût par élève",
      chiffre: comparisons.value.coutFonctionnement?.hasData ? 
               formatMoney(comparisons.value.coutFonctionnement.evolution) : 'N/A',
      icon: getTrendIcon(comparisons.value?.coutFonctionnement),
      variation: comparisons.value?.coutFonctionnement?.percentage || '0',
      colorVariation: getTrendClass(comparisons.value?.coutFonctionnement),
      interpretation: coutFonctionnement.value?.cout_fonctionnement_par_eleve?.interpretation || 
                     "Évolution du coût de fonctionnement par élève",
      format: 'money'
    },
    {
      texte: "CA par élève",
      chiffre: comparisons.value.chiffreAffaires?.hasData ? 
               formatMoney(comparisons.value.chiffreAffaires.evolution) : 'N/A',
      icon: getTrendIcon(comparisons.value?.chiffreAffaires),
      variation: comparisons.value?.chiffreAffaires?.percentage || '0',
      colorVariation: getTrendClass(comparisons.value?.chiffreAffaires),
      interpretation: chiffreAffaires.value?.chiffre_affaires_par_eleve?.interpretation || 
                     "Évolution du chiffre d'affaires par élève",
      format: 'money'
    },
    {
      texte: "Part masse salariale",
      chiffre: comparisons.value.partMasseSalariale?.hasData ? 
               formatPercentage(comparisons.value.partMasseSalariale.evolution) : 'N/A',
      icon: getTrendIcon(comparisons.value?.partMasseSalariale),
      variation: comparisons.value?.partMasseSalariale?.percentage || '0',
      colorVariation: getTrendClass(comparisons.value?.partMasseSalariale),
      interpretation: partMasseSalariale.value?.part_masse_salariale_enseignante?.interpretation || 
                     "Évolution de la part de la masse salariale enseignante",
      format: 'percentage'
    },
    {
      texte: "Marge par élève",
      chiffre: comparisons.value.margeParEleve?.hasData ? 
               formatMoney(comparisons.value.margeParEleve.evolution) : 'N/A',
      icon: getTrendIcon(comparisons.value?.margeParEleve),
      variation: comparisons.value?.margeParEleve?.percentage || '0',
      colorVariation: getTrendClass(comparisons.value?.margeParEleve),
      interpretation: margeParEleve.value?.marge_par_eleve?.interpretation || 
                     "Évolution de la marge par élève",
      format: 'money',
      negative: true
    }
  ].filter(card => card.chiffre !== undefined && card.chiffre !== null);
  
  console.log('Carousel data pédagogique updated:', interpretationCardsData.value);
};

// Fonction pour trouver l'exercice correspondant à l'année
const findAndSetExerciseForYear = async () => {
  try {
    // Si nous avons des options d'exercice, chercher celui qui correspond à l'année
    if (exercicesOptions.value && exercicesOptions.value.length > 0) {
      const exerciseForYear = exercicesOptions.value.find(exo => 
        exo.label === props.annee || 
        exo.annee === parseInt(props.annee)
      );
      
      if (exerciseForYear) {
        filters.value.idExercice = exerciseForYear.value;
        console.log('Exercice trouvé pour l\'année', props.annee, ':', exerciseForYear.value);
      } else {
        // Si aucun exercice trouvé, utiliser l'exercice ouvert
        const openExercise = exercicesOptions.value.find(exo => exo.statut === 'ouvert');
        if (openExercise) {
          filters.value.idExercice = openExercise.value;
          console.log('Utilisation de l\'exercice ouvert pour l\'année', props.annee);
        }
      }
    }
  } catch (error) {
    console.error('Erreur lors de la recherche de l\'exercice:', error);
  }
};

// Chargement initial
onMounted(async () => {
  try {
    console.log('Initialisation SwipingCard avec l\'année:', props.annee);
    
    // Initialiser les données
    await initializeData();
    
    // Trouver et définir l'exercice correspondant à l'année
    await findAndSetExerciseForYear();
    
    // Rafraîchir les données avec l'exercice approprié
    if (filters.value.idExercice) {
      await changeExercice(filters.value.idExercice);
    }
    
    // Mettre à jour le carousel
    updateInterpretationCards();
    
    console.log('SwipingCard initialisé pour l\'année:', props.annee);
  } catch (error) {
    console.error('Erreur lors de l\'initialisation:', error);
  }
});

// Gestion du changement d'exercice via le select (optionnel)
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
</script>

<template>
    <!-- Option 1: Masquer complètement le filtre d'exercice -->
    <!-- 
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
    -->

    <!-- Option 2: Afficher l'année en cours sans filtre modifiable -->
    <!-- Cartes indicateurs -->
    <div class="graphic">
      <InterpretationCarousel 
        :cards="interpretationCardsData"
        :autoPlay="true"
        :autoPlayInterval="5000"
        :showNavigation="true"
      />
    </div>
</template>

<style lang="scss" scoped>

.graphic {
  width: 530px;
}
</style>