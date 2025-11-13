<script setup>
import { ref, onMounted, computed } from "vue";
import { useCout } from "@/composables/useCout";
import Leaderboard from "@/components/atoms/Chart/Leaderboard.vue";

const {
  exercice,
  exercicesList,
  filters,
  centresList,
  centres,
  affectations,
  sousComptesVentiles,
  verificationVentilations,
  selectedCentre,
  loading,
  classement,
  // Computed
  statsGlobales,
  infoExercice,
  centresFiltres,
  affectationsFiltrees,
  classementFiltrees,
  exercicesOptions,

  // API
  fetchCentresList,
  fetchCentres,
  fetchAffectations,
  fetchClassement,
  fetchSousComptesVentiles,
  fetchVerificationVentilations,

  // 🔥 NOUVELLES FONCTIONS
  initializeData,
  changeExercice,
  resetFilters,
  fetchExercicesList,
  formatDateForInput,
  formatDateForAPI,

  // Utils
  formatMontant,
  formatPourcentage,

} = useCout(1);
onMounted(async () => {
  await initializeData();
});
</script>
<template>
            <Leaderboard :depenses="classementFiltrees" :texte="'Top 5 des charges'" />
</template>


<style lang="scss" scoped>
</style>