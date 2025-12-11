<script setup>
import { ref, onMounted, defineProps, watch } from "vue";
import { useIndicateursUnifies } from "@/composables/useIndicateursUnifies";
import Card from "@/components/atoms/Chart/Card.vue";

// Définir la prop annee
const props = defineProps({
  annee: {
    type: String,
    default: () => new Date().getFullYear().toString()
  }
});

const filters = ref({
  dateStart: "",
  dateEnd: "",
  idExercice: ""
});

const {
  totalProduits,
  totalCharges,
  resultatNet,
  TresorerieNette,
  comparisons,
  refreshAllData,
  initializeData,
  changeExercice,
  fetchExercice // Ajouter cette fonction
} = useIndicateursUnifies(filters);

// Fonction pour convertir l'année en dates d'exercice
const convertYearToExerciseDates = async (year) => {
  try {
    // Créer les dates pour l'année sélectionnée
    const dateStart = `${year}-01-01`;
    const dateEnd = `${year}-12-31`;
    
    // Mettre à jour les filtres
    filters.value.dateStart = dateStart;
    filters.value.dateEnd = dateEnd;
    filters.value.idExercice = ""; // Réinitialiser l'exercice
    
    console.log('Dates mises à jour pour l\'année:', year, dateStart, dateEnd);
    
    // Rafraîchir les données avec les nouvelles dates
    await refreshAllData();
    
  } catch (error) {
    console.error('Erreur lors de la conversion de l\'année:', error);
  }
};

// Chargement initial avec l'année
onMounted(() => {
  convertYearToExerciseDates(props.annee).then(() => {
    console.log('Données initialisées pour l\'année:', props.annee);
  });
});

// Fonction pour rafraîchir quand l'année change
const refreshForYear = async (year) => {
  console.log('Rafraîchissement pour l\'année:', year);
  await convertYearToExerciseDates(year);
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
  <div class="cartes">
    <Card 
      :texte="'Total les revenus'" 
      :chiffre="parseInt(totalProduits?.total_produits?.valeur)"
      :format="'money'" 
      :icon="'bi bi-arrow-up-circle'" 
      :icon-color="'green'"
      :variation="getTrendIcon(comparisons.produits) + ' ' + comparisons.produits.percentage"
      :colorVariation="getTrendClass(comparisons.produits)" />
    
    <Card 
      :texte="'Total des dépenses'" 
      :chiffre="parseInt(totalCharges?.total_charges?.valeur)"
      :format="'money'" 
      :icon="'bi bi-arrow-down-circle'" 
      :icon-color="'red'"
      :variation="getTrendIcon(comparisons.charges) + ' ' + comparisons.charges.percentage"
      :colorVariation="getTrendClass(comparisons.charges)" />

    <Card 
      :texte="'Bénéfices/Pertes'" 
      :chiffre="parseInt(resultatNet?.resultat_net?.valeur)" 
      :format="'money'"
      :icon="'bi bi-cash-stack'" 
      :icon-color="'green'" 
      :negative="true"
      :variation="getTrendIcon(comparisons.resultatNet) + ' ' + comparisons.resultatNet.percentage"
      :colorVariation="getTrendClass(comparisons.resultatNet)" />
    
    <Card 
      :texte="'Trésorerie Nette'" 
      :chiffre="parseInt(TresorerieNette?.tresorerie_nette?.valeur)"
      :format="'money'" 
      :icon="'bi bi-cash-coin'" 
      :icon-color="'green'"
      :variation="getTrendIcon(comparisons.Tresorerie) + ' ' + comparisons.Tresorerie.percentage"
      :colorVariation="getTrendClass(comparisons.Tresorerie)" />    
  </div>
</template>

<style lang="scss" scoped>
// Vos styles existants restent les mêmes
.cartes {
  @include position-contenus(flex, space-between, flex-start);
  padding: 0;
  width: 100%;
  gap: 24px;
  flex-wrap: wrap;

  @media (max-width: $tablet) {
    gap: 24px;
    grid-template-columns: repeat(2, 1fr);
  }

  @media (max-width: $mobile) {
    gap: 16px;
    grid-template-columns: 1fr;
  }
}


h3 {
  color: #2c3e50;
  margin-bottom: 16px;
  font-size: 1.5rem;
  border-bottom: 2px solid #e9ecef;
  padding-bottom: 8px;
}
</style>