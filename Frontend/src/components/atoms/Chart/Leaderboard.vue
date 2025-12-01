<script setup>
import { computed } from "vue";
import LoadingText from "../Loading-text.vue";
import Texte from "../Texte.vue";

const props = defineProps({
  depenses: { type: Array, required: true },
  texte: { type: String, required: true },
  ready: { type: Boolean, default: true }
});




// Fonction pourcentage
const getPourcentage = (val) => {
  if (total.value === 0) return 0;
  return (val / total.value) * 100;
};

const topThree = computed(() => props.depenses.slice(0, 3));
const others = computed(() => props.depenses.slice(3, 5));
// Total de tous les montants

const total = computed(() => {
  const merged = [...topThree.value, ...others.value];
  return merged.reduce((acc, d) => acc + Number(d.montant_ventile || 0), 0);
});
// Formateur de montants
const formatMontant = (val) => {
  return new Intl.NumberFormat("mg-MG", {
    minimumFractionDigits: 0,
    maximumFractionDigits: 2,
  }).format(val);
};
</script>

<template>
  <div class="leaderboard-card" v-if="ready">

    <!-- Titre -->
    <div class="table-title">
      <Texte :type="'bold-dark'" :texte="texte" />
    </div>

    <ul class="ranking-list">

      <!-- TOP 3 -->
      <li v-for="(item, index) in topThree"
          :key="'top-' + index"
          class="ranking-item">

        <div class="ranking-left">
          <span class="rank-number">{{ index + 1 }}</span>
          <div>
            <div class="name">{{ item.libelle_sous_compte }}</div>
            <div class="amount">{{ formatMontant(item.montant_ventile) }}</div>

            <!-- JAUGE -->
            <div class="progress-bar">
              <div class="progress-fill"
                :style="{ width: getPourcentage(item.montant_ventile) + '%' }">
              </div>
            </div>
          </div>
        </div>

      </li>

      <!-- AUTRES -->
      <li v-for="(item, index) in others"
          :key="'other-' + index"
          class="ranking-item">

        <div class="ranking-left">
          <span class="rank-number">{{ index + 4 }}</span>
          <div>
            <div class="name">{{ item.libelle_sous_compte }}</div>
            <div class="amount">{{ formatMontant(item.montant_ventile) }}</div>

            <!-- JAUGE -->
            <div class="progress-bar">
              <div class="progress-fill"
                :style="{ width:getPourcentage(item.montant_ventile) + '%' }">
              </div>
            </div>
          </div>
        </div>

      </li>

    </ul>
  </div>

  <!-- LOADING -->
  <div class="leaderboard-card" v-else>
    <h2 class="leaderboard-title">
      <LoadingText type="line-1" />
      <LoadingText type="line-3" />
    </h2>

    <ul class="ranking-list">
      <li v-for="n in 5" :key="n" class="ranking-item">
        <div class="ranking-left">
          <span class="rank-number">{{ n }}</span>
          <div>
            <div class="name"><LoadingText type="line-3" /></div>
            <div class="amount"><LoadingText type="line-1" /></div>
          </div>
        </div>
      </li>
    </ul>
  </div>
</template>


<style lang="scss" scoped>
/* --- Layout global --- */
.progress-bar {
  width: 250px;
  height: 6px;
  background: $light;
  border-radius: 6px;
  margin-top: 6px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #1b6bff, #1cb7ff);
  border-radius: 6px;
  transition: width 0.4s ease;
}

.table-title {
  padding: 12px
}
.leaderboard-card {
  @include glass();
  border-radius: $radius-pm;
    padding: 18px;
  width:100%;
  // width: 100%;
  height: 100%;
  transition: transform 0.3s ease, filter 0.3s ease-in-out;
//   box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
}
.leaderboard-card:hover {
    transform: scale(1.02);
    transition: transform 0.3s ease, filter 0.3s ease-in-out;
        // box-shadow: 0 10px 10px rgba(0, 0, 0, 0.05);

}


/* --- Top 3 --- */
.top-three {
  display: flex;
  justify-content: space-around;
  align-items: flex-end;
  margin-bottom: 40px;
}

.top-item {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.bar {
  background: #c3e6cb;
  border-radius: 10px 10px 0 0;
  width: 50px;
  display: flex;
  justify-content: center;
  align-items: flex-end;
}

.rank-0 .bar {
  height: 120px;
  background-color: #ffca1b;
}
.rank-1 .bar {
  height: 100px;
    background-color: #dad9d7;

}
.rank-2 .bar {
  height: 80px;
    background-color: #f5b24e;
}

.rank-number {
  font-weight: bold;
  font-size: 1.2em;
  color: #333;
  margin-bottom: 5px;
  font-family: $stara-bold;
}

.info {
  text-align: center;
  margin-top: 10px;
  font-family: $stara-medium;
}
.info .icon {
  font-size: 1.5em;
}
.info .name {
  // font-weight: 600;
  font-size: 14px;
  color: #333;
  width: 100%;
}
.info .amount {
  font-size: 0.9em;
  color: #777;
}

/* --- Carte utilisateur --- */
.user-card {
  font-family: $stara-medium;
  background: $jaune;
  color: #fff;
  border-radius: 15px;
  padding: 15px 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 25px;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 10px;
}

.user-icon {
  background: #fff;
  color: #ff7849;
  border-radius: 50%;
  padding: 8px;
  font-size: 1.2em;
}

.user-name {
  font-weight: 600;
  font-family: $stara-medium;
  
}
.user-amount {
  font-size: 0.9em;
  font-family: $stara-medium;

}

/* --- Liste des autres classements --- */
.ranking-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.ranking-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px 0;
  width: 100%;
  height: 68px;
  border-bottom: 1px solid #eee;
}

.ranking-left {
  width: 100%;
  display: flex;
  align-items: center;
  gap: 24px;
}

.ranking-left .rank-number {
  font-weight: bold;
  // width: 5px;
  text-align: center;
}

.ranking-left .name {
  color: #222;
    font-family: $stara-bold;
    font-size: 14px;
    // width: 200px;

}

.ranking-left .amount {
  font-size: 0.85em;
  color: #666;
    font-family: $stara-medium;
}

.ranking-icon {
  font-size: 1.3em;
}
</style>
