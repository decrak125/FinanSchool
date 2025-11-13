<script setup>
import { ref, onMounted } from "vue";
import { useIndicateursUnifies } from "@/composables/useIndicateursUnifies";
import Card from "@/components/atoms/Chart/Card.vue";

const filters = ref({
  dateStart: "",
  dateEnd: "",
  idExercice: ""
});

const {
  // Indicateurs généraux
  totalProduits,
  totalCharges,
  resultatNet,
  margeExploitation,
  
  // Indicateurs de liquidité
  LiquiditeGenerale,
  TresorerieNette,
  BFR,
  
  // Indicateurs de rentabilité
  MargeBrute,
  MargeNette,
  ROE,
  ROA,
  
  // Indicateurs de solvabilité
  RatioEndettement,
  CapaciteRemboursement,
  AutonomieFinanciere,
  
  loading,
  comparisons,
  refreshAllData,
  initializeData,
  changeExercice
} = useIndicateursUnifies(filters);

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

// Chargement initial
onMounted(() => {
  initializeData().then(() => {
    console.log('Toutes les données initialisées');
  });
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
</script>

<template>
  <div class="main">
    <!-- Indicateurs en cartes -->
    <div class="graphic">
      <!-- Indicateurs Généraux -->
      <h3>Indicateurs Généraux</h3>
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
      </div>

      <!-- Indicateurs de Liquidité -->
      <h3>Indicateurs de Liquidité</h3>
      <div class="cartes">
        <Card 
          :texte="'Liquidité Générale'" 
          :chiffre="parseFloat(LiquiditeGenerale?.ratio_liquidite_generale?.valeur)"
          :format="'percentage'" 
          :icon="'bi bi-graph-up'" 
          :icon-color="'blue'"
          :variation="getTrendIcon(comparisons.Liquidite) + ' ' + comparisons.Liquidite.percentage"
          :colorVariation="getTrendClass(comparisons.Liquidite)" />
        
        <Card 
          :texte="'Trésorerie Nette'" 
          :chiffre="parseInt(TresorerieNette?.tresorerie_nette?.valeur)"
          :format="'money'" 
          :icon="'bi bi-cash-coin'" 
          :icon-color="'green'"
          :variation="getTrendIcon(comparisons.Tresorerie) + ' ' + comparisons.Tresorerie.percentage"
          :colorVariation="getTrendClass(comparisons.Tresorerie)" />
      </div>

      <!-- Indicateurs de Rentabilité -->
      <h3>Indicateurs de Rentabilité</h3>
      <div class="cartes">
        <Card 
          :texte="'Marge Brute'" 
          :chiffre="parseFloat(MargeBrute?.marge_brute?.valeur)"
          :format="'percentage'" 
          :icon="'bi bi-percent'" 
          :icon-color="'green'"
          :variation="getTrendIcon(comparisons.brute) + ' ' + comparisons.brute.percentage"
          :colorVariation="getTrendClass(comparisons.brute)" />
        
        <Card 
          :texte="'Marge Nette'" 
          :chiffre="parseFloat(MargeNette?.marge_nette?.valeur)"
          :format="'percentage'" 
          :icon="'bi bi-percent'" 
          :icon-color="'blue'"
          :variation="getTrendIcon(comparisons.nette) + ' ' + comparisons.nette.percentage"
          :colorVariation="getTrendClass(comparisons.nette)" />
        
        <Card 
          :texte="'ROE'" 
          :chiffre="parseFloat(ROE?.roe?.valeur)"
          :format="'percentage'" 
          :icon="'bi bi-graph-up-arrow'" 
          :icon-color="'purple'"
          :variation="getTrendIcon(comparisons.ROE) + ' ' + comparisons.ROE.percentage"
          :colorVariation="getTrendClass(comparisons.ROE)" />
      </div>

      <!-- Indicateurs de Solvabilité -->
      <h3>Indicateurs de Solvabilité</h3>
      <div class="cartes">
        <Card 
          :texte="'Ratio d\'Endettement'" 
          :chiffre="parseFloat(RatioEndettement?.ratio_endettement?.valeur)"
          :format="'percentage'" 
          :icon="'bi bi-bank'" 
          :icon-color="'orange'"
          :variation="getTrendIcon(comparisons.Endettement) + ' ' + comparisons.Endettement.percentage"
          :colorVariation="getTrendClass(comparisons.Endettement)" />
        
        <Card 
          :texte="'Autonomie Financière'" 
          :chiffre="parseFloat(AutonomieFinanciere?.autonomie_financiere?.valeur)"
          :format="'percentage'" 
          :icon="'bi bi-shield-check'" 
          :icon-color="'green'"
          :variation="getTrendIcon(comparisons.Autonomie) + ' ' + comparisons.Autonomie.percentage"
          :colorVariation="getTrendClass(comparisons.Autonomie)" />
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
// Vos styles existants restent les mêmes
.cartes {
  @include position-contenus(flex, center, center);
  padding: 0;
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

.graphic {
  @include position-contenus(flex, flex-start, flex-start);
  padding: 10px 0;
  align-self: stretch;
  gap: 24px;
  flex-direction: column;

  @media (max-width: $tablet) {
    gap: 18px;
  }

  @media (max-width: $mobile) {
    gap: 16px;
    padding: 5px 0;
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