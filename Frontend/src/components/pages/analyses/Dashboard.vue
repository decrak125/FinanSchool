<script setup>
import PageAnalyse from '@/components/template/Page-analyse.vue';
import CoutsEtProfit from '@/components/molecules/Dashboard/CoutsEtProfit.vue';
import Cards from '@/components/molecules/Dashboard/Cards.vue';
import CoutsEtProfitcourbe from '@/components/molecules/Dashboard/CoutsEtProfitcourbe.vue';
import Classement from '@/components/molecules/Dashboard/Classement.vue';
import SwipingCard from '@/components/molecules/Dashboard/SwipingCard.vue';
</script>
<template>
  <PageAnalyse :menu="'Accueil'" :sousmenu="'Tableau de bord'">
    <div class="main">
      <div class="cards">
        <Cards />
      </div>
      <div class="coutProfit">
        <CoutsEtProfit />
        <SwipingCard />
      </div>
      <div class="coutProfit">
        <CoutsEtProfitcourbe />
        <Classement />
      </div>
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

.cards {
  width: 100%;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0;
}

.coutProfit {
  display: flex;
  justify-content: space-between;
  width: 100%;
  align-items: center;
  gap: 24px;
}
</style>