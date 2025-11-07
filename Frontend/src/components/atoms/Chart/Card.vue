<script setup>
import Texte from '../Texte.vue';
import Counter from '../counter.vue';
import LoadingText from '../Loading-text.vue';
defineProps({
  texte: String,
  chiffre: { type: [Number, String] },
  icon: String,
  iconColor: String,
  format: String,
  negative: Boolean,
  loading: { type: Boolean, default: false },
  variation: String,
  colorVariation: String
})
</script>
<template>
  <div class="Count-content" v-if="!loading">
    <div class="info">
      <i v-bind:class="icon" v-bind:style="`color:${iconColor};`"></i>
      <p class="texte">{{ texte }}</p>
    </div>
    <div class="datas">
      <Counter v-if="chiffre === null || chiffre === undefined" :number="0" :format="format"
        :allowNegative="negative" />
      <Counter v-else :number="chiffre" :format="format" :allowNegative="negative" />
      <div class="variation" v-if="variation">
        <p :class="colorVariation">{{  variation ? variation : 'N/A' }}%</p>
        <p class="texte-info">VS l'année précédente</p>
      </div>
    </div>


  </div>

  <div v-if="loading" class="Count-content-loading">
    <i>
      <LoadingText :type="'circle'" />
    </i>
    <p class="texte">
      <LoadingText :type="'line-4'" />
    </p>
    <LoadingText :type="'line-1'" />
    <LoadingText :type="'line-1'" />
  </div>
</template>
<style lang="scss" scoped>
.head {
  @include position-contenus();
  gap: 10px;
}

.variation {
  display: flex;
  align-items: center;
  margin-top: -10px;

}

.datas {
  display: flex;
  flex-direction: column;
  padding: 0px;
  margin: 0px;
}

// .info{
//   display: flex;
//   // flex-direction: column;
//   gap: 10px;
//   align-items: center;

//   // margin: -5px 0;
//   padding: 0px;
// }
i {
  border-style: none;
  //   color: $gris;
  margin: 0;
  text-decoration: none;
  width: 38px;
  height: 38px;
  justify-content: center;
  align-items: center;
  flex-shrink: 0;
}

.Count-content-loading {
  width: 275px;
  height: 194px;
  align-items: center;
  justify-content: center;
  display: block;
  background-color: #ffff;
  font-family: $stara-black;
  font-size: 32px;
  // font-style: normal;
  line-height: normal;
  margin: 0;
  gap: 10px;
  padding: 32px;
  border-radius: $radius-pm;
  transition: transform 0.3s ease, filter 0.3s ease-in-out;
}

.Count-content {
  width: 275px;
  height: 194px;
  align-items: flex-start;
  justify-content: center;
  align-content: flex-start;
  align-self: flex-start;
  display: flex;
  flex-direction: column;
  background-color: #ffff;
  font-family: $stara-black;
  font-size: 32px;
  // font-style: normal;
  line-height: normal;
  margin: 0;
  padding: 32px;
  gap: 5px;
  border-radius: $radius-pm;
  transition: transform 0.3s ease-in-out, filter 0.3s ease-in-out;

}

.Count-content:hover {
  box-shadow: 0 10px 10px rgba(0, 0, 0, 0.05);
  transform: scale(1.02);
  transition: transform 0.3s ease-in-out, filter 0.3s ease-in-out;

}

.texte {
  color: $gris;
  font-family: $stara-medium;
  font-size: 16px;
  font-style: normal;
  line-height: normal;
  margin: 5px;
}

.texte-info {
  color: $gris;
  font-family: $stara-medium;
  font-size: 12px;
  font-style: normal;
  line-height: normal;
  margin: 5px;
}

.trend-neutral {
  color: $gris;
  font-family: $stara-bold;
  font-size: 12px;
  font-style: normal;
  line-height: normal;
  margin: 5px 0px;
}

.trend-stable {
  color: $gris;
  font-family: $stara-bold;
  font-size: 12px;
  font-style: normal;
  line-height: normal;
  margin: 5px 0px;
}

.trend {
  color: $gris;
  font-family: $stara-bold;
  font-size: 12px;
  font-style: normal;
  line-height: normal;
  margin: 5px;
}

.trend-up {
  color: $vert;
  font-family: $stara-bold;
  font-size: 12px;
  font-style: normal;
  line-height: normal;
  margin: 5px 0px;
  padding: 0 5px ;
  background-color: #e2ffe3;
  border-radius: $radius-pm;
}

.trend-down {
  color: $rouge;
  font-family: $stara-bold;
  font-size: 12px;
  font-style: normal;
  line-height: normal;
  margin: 5px 0px;
  padding: 0 5px ;
  background-color: #ffe2e2;
  border-radius: $radius-pm;
}
</style>