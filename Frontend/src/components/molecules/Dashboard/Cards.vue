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
  // Indicateurs de liquidité
  TresorerieNette,
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

      <!-- Indicateurs de Liquidité -->
      <!-- <h3>Indicateurs de Liquidité</h3>
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
          :texte="'Marge d\'Exploitation'" 
          :chiffre="parseFloat(margeExploitation?.marge_exploitation?.valeur)"
          :format="'percentage'" 
          :icon="'bi bi-graph-up'" 
          :icon-color="'blue'"
          :variation="getTrendIcon(comparisons.margeExploitation) + ' ' + comparisons.margeExploitation.percentage"
          :colorVariation="getTrendClass(comparisons.margeExploitation)" />

        <Card 
          :texte="'Besoin en Fonds de Roulement (BFR)'" 
          :chiffre="parseInt(BFR?.bfr?.valeur)"
          :format="'money'" 
          :icon="'bi bi-arrow-left-right'" 
          :icon-color="'orange'"
          :variation="getTrendIcon(comparisons.fondRoulement) + ' ' + comparisons.fondRoulement.percentage"
          :colorVariation="getTrendClass(comparisons.fondRoulement)" />
      </div> -->

      <!-- Indicateurs de Rentabilité -->
      <!-- <h3>Indicateurs de Rentabilité</h3>
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
          :texte="'Return on Equity (ROE)'" 
          :chiffre="parseFloat(ROE?.roe?.valeur)"
          :format="'percentage'" 
          :icon="'bi bi-graph-up-arrow'" 
          :icon-color="'purple'"
          :variation="getTrendIcon(comparisons.ROE) + ' ' + comparisons.ROE.percentage"
          :colorVariation="getTrendClass(comparisons.ROE)" />

        <Card 
          :texte="'Return on Assets (ROA)'" 
          :chiffre="parseFloat(ROA?.roa?.valeur)"
          :format="'percentage'" 
          :icon="'bi bi-building'" 
          :icon-color="'teal'"
          :variation="getTrendIcon(comparisons.ROA) + ' ' + comparisons.ROA.percentage"
          :colorVariation="getTrendClass(comparisons.ROA)" />
      </div> -->

      <!-- Indicateurs de Solvabilité -->
      <!-- <h3>Indicateurs de Solvabilité</h3>
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
          :texte="'Capacité de Remboursement'" 
          :chiffre="parseFloat(CapaciteRemboursement?.capacite_remboursement?.valeur)"
          :format="'percentage'" 
          :icon="'bi bi-currency-exchange'" 
          :icon-color="'red'"
          :variation="getTrendIcon(comparisons.Remboursement) + ' ' + comparisons.Remboursement.percentage"
          :colorVariation="getTrendClass(comparisons.Remboursement)" />

        <Card 
          :texte="'Autonomie Financière'" 
          :chiffre="parseFloat(AutonomieFinanciere?.autonomie_financiere?.valeur)"
          :format="'percentage'" 
          :icon="'bi bi-shield-check'" 
          :icon-color="'green'"
          :variation="getTrendIcon(comparisons.Autonomie) + ' ' + comparisons.Autonomie.percentage"
          :colorVariation="getTrendClass(comparisons.Autonomie)" />
      </div>
 -->
      <!-- Indicateurs Pédagogiques (si disponibles) -->
      <!-- <h3>Indicateurs Pédagogiques</h3>
      <div class="cartes">
        <Card 
          :texte="'Coût de Fonctionnement par Élève'" 
          :chiffre="parseInt(coutFonctionnement?.cout_fonctionnement_par_eleve?.valeur)"
          :format="'money'" 
          :icon="'bi bi-person'" 
          :icon-color="'indigo'"
          :variation="getTrendIcon(comparisons.coutFonctionnement) + ' ' + comparisons.coutFonctionnement.percentage"
          :colorVariation="getTrendClass(comparisons.coutFonctionnement)" />
        
        <Card 
          :texte="'Chiffre d\'Affaires par Élève'" 
          :chiffre="parseInt(chiffreAffaires?.chiffre_affaires_par_eleve?.valeur)"
          :format="'money'" 
          :icon="'bi bi-currency-dollar'" 
          :icon-color="'success'"
          :variation="getTrendIcon(comparisons.chiffreAffaires) + ' ' + comparisons.chiffreAffaires.percentage"
          :colorVariation="getTrendClass(comparisons.chiffreAffaires)" />

        <Card 
          :texte="'Part Masse Salariale Enseignante'" 
          :chiffre="parseFloat(partMasseSalariale?.part_masse_salariale_enseignante?.valeur)"
          :format="'percentage'" 
          :icon="'bi bi-people'" 
          :icon-color="'warning'"
          :variation="getTrendIcon(comparisons.partMasseSalariale) + ' ' + comparisons.partMasseSalariale.percentage"
          :colorVariation="getTrendClass(comparisons.partMasseSalariale)" />

        <Card 
          :texte="'Marge par Élève'" 
          :chiffre="parseInt(margeParEleve?.marge_par_eleve?.valeur)"
          :format="'money'" 
          :icon="'bi bi-graph-up'" 
          :icon-color="'success'"
          :variation="getTrendIcon(comparisons.margeParEleve) + ' ' + comparisons.margeParEleve.percentage"
          :colorVariation="getTrendClass(comparisons.margeParEleve)" />
        </div> -->
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