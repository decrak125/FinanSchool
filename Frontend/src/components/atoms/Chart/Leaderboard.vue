<script setup>
import { computed } from "vue";
import LoadingText from "../Loading-text.vue";

const props = defineProps({
  depenses: {
    type: Array,
    required: true
  },
  texte: {
    type: String,
    required: true
  },
  ready: {
    type: Boolean,
    default: true
  }
});
const first = computed(() => props.depenses[0]);
const topThree = computed(() => props.depenses.slice(0, 3));
const others = computed(() => props.depenses.slice(3));
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
      <h2 class="leaderboard-title">{{ texte }}</h2>
      <!-- Top 3 -->
      <div class="top-three">
        <div
          v-for="(item, index) in topThree"
          :key="index"
          class="top-item"
          :class="'rank-' + index"
        >
          <div class="bar">
            <span class="rank-number">{{ index +1 }}</span>
          </div>
          <div class="info">
            <!-- <div class="icon">💰</div> -->
            <div class="name">{{ item.libelle_sous_compte }}</div>
            <div class="amount">{{ formatMontant(item.montant_ventile) }}</div>
          </div>
        </div>
      </div>
      <!-- Autres classements -->
      <ul class="ranking-list">
        <li v-for="(item, index) in others" :key="index" class="ranking-item">
          <div class="ranking-left">
            <span class="rank-number">{{ index + 4 }}</span>
            <div>
              <div class="name">{{ item.libelle_sous_compte }}</div>
              <div class="amount">{{ formatMontant(item.montant_ventile) }}</div>
            </div>
          </div>
          <div class="ranking-icon">
          </div>
        </li>
      </ul>
    </div>
        <div class="leaderboard-card" v-if="!ready">
      <!-- Titre -->
      <h2 class="leaderboard-title">
        <LoadingText :type="'line-1'" />
        <LoadingText :type="'line-3'" />
      </h2>

      <!-- Top 3 -->
      <div class="top-three">
        <div
          v-for="(item, index) in topThree"
          :key="index"
          class="top-item"
          :class="'rank-' + index"
        >
          <div class="bar">
            <span class="rank-number">{{ index +1 }}</span>
          </div>
          <div class="info">
            <!-- <div class="icon">💰</div> -->
            <div class="name"><LoadingText :type="'line-1'" /></div>
            <div class="amount"><LoadingText :type="'line-3'" /></div>
          </div>
        </div>
      </div>
      <!-- Autres classements -->
      <ul class="ranking-list">
        <li v-for="(item, index) in others" :key="index" class="ranking-item">
          <div class="ranking-left">
            <span class="rank-number">{{ index + 4 }}</span>
            <div>
              <div class="name"><LoadingText :type="'line-3'" /></div>
              <div class="amount"><LoadingText :type="'line-1'" /></div>
            </div>
          </div>
          <div class="ranking-icon">
          </div>
        </li>
      </ul>
    </div>

</template>


<style lang="scss" scoped>
/* --- Layout global --- */


.leaderboard-card {
  background: #fff;
  border-radius: $radius-pm;
  padding: 0px 30px;
  width: 320px;
  // width: 100%;
  height: 100%;
  transition: transform 0.3s ease, filter 0.3s ease-in-out;
//   box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
}
.leaderboard-card:hover {
    transform: scale(1.02);
    transition: transform 0.3s ease, filter 0.3s ease-in-out;
}

/* --- Titre --- */
.leaderboard-title {
  text-align: left;
  font-size: 1.5em;
  font-weight: 600;
  font-family: $stara-bold;
  color: #222;
  margin-bottom: 25px;
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
  font-weight: 600;
  font-size: 14px;
  color: #333;
  width: 80px;
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
  border-bottom: 1px solid #eee;
}

.ranking-left {
  display: flex;
  align-items: center;
  gap: 10px;
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
    width: 200px;

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
