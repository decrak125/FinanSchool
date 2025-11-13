<script setup>
import PageAnalyse from '@/components/template/Page-analyse.vue';
import CoutsEtProfit from '@/components/molecules/Dashboard/CoutsEtProfit.vue';
import Cards from '@/components/molecules/Dashboard/Cards.vue';
import AnalyseMensuelle from '@/components/pages/analyses/AnalyseMensuelle.vue';
</script>
<template>
<PageAnalyse :menu="'Accueil'" :sousmenu="'Tableau de bord'">
    <div class="main">
        <div class="cards">
            <Cards />
        </div>
    <CoutsEtProfit />
    <AnalyseMensuelle />
    </div>
</PageAnalyse>
</template>
<style lang="scss" scoped>
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
.cards{
    display: flex;
}
</style>