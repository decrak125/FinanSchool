<script setup>
import { ref, computed, watch } from 'vue';
import PageAnalyse from '@/components/template/Page-analyse.vue';
import CoutsEtProfit from '@/components/molecules/Dashboard/CoutsEtProfit.vue';
import Cards from '@/components/molecules/Dashboard/Cards.vue';
import CoutsEtProfitcourbe from '@/components/molecules/Dashboard/CoutsEtProfitcourbe.vue';
import Classement from '@/components/molecules/Dashboard/Classement.vue';
import SwipingCard from '@/components/molecules/Dashboard/SwipingCard.vue';
import Texte from '@/components/atoms/Texte.vue';
import FilterSelect from '@/components/atoms/Filter-select.vue';
import ClassementCopy from '@/components/molecules/Dashboard/Classement copy.vue';
import AnalyseTrimestrielle from '@/components/molecules/Dashboard/AnalyseTrimestrielle.vue';
import DiagnosticDashboard from './DiagnosticDashboard.vue';

const filters = ref({
  annee: new Date().getFullYear().toString()
});

const availableYears = computed(() => {
  const currentYear = new Date().getFullYear();
  const years = [];
  for (let i = 0; i <= 7; i++) {
    years.push((currentYear - i).toString());
  }
  return years;
});

// CORRECTION: Utiliser filters.value.annee au lieu de filters.annee
// watch(() => filters.value.annee, (newYear) => {
//   console.log('Nouvelle année sélectionnée:', newYear)
// });

</script>
<template>
  <PageAnalyse :menu="'Accueil'" :sousmenu="'Tableau de bord'">

    <div class="main">
      <div class="filters-container">
        <div class="filters">
          <Texte :type="'dark'" :texte="'Année d\'exercice'" />
          <FilterSelect v-model="filters.annee" :label="''">
            <option v-for="year in availableYears" :key="year" :value="year">
              {{ year }}
            </option>
          </FilterSelect>
        </div>
      </div>
            <DiagnosticDashboard
              :date-debut="filters.annee + '-01-01'"
              :date-fin="filters.annee + '-12-31'"
            />

      <div class="cards">
        <Cards :key="filters.annee" :annee="filters.annee" />
      </div>
      <div class="coutProfit">
        <CoutsEtProfit :key="filters.annee" :annee="filters.annee" />
      </div>
      <div class="coutProfit">
        <SwipingCard :key="filters.annee" :annee="filters.annee"/>
        <AnalyseTrimestrielle :key="filters.annee" :annee="filters.annee" />
      </div>
    </div>
  </PageAnalyse>
</template>
<style lang="scss" scoped>
.filters-container {
  display: flex;
  width: 100%;
  align-items: baseline;
  flex-direction: column;
  gap: 20px;
  // margin-bottom: 30px;
}

.filters {
  display: flex;
  gap: 8px;
  align-items: center;
  justify-content: baseline;
  flex-wrap: wrap;
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

.cards {
  width: 100%;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0;
}

.coutProfit {
  display: flex;
  // justify-content: space-between;
  width: 100%;
  align-items: center;
  gap: 24px;
}
</style>