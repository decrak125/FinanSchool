<script setup>
import { ref, computed } from 'vue';
import Texte from '../Texte.vue';
defineProps({
    texte: String,
    chiffre: { type: [Number, String] },
    icon: String,
    iconColor: String,
    format: String,
    negative: Boolean,
    loading: { type: Boolean, default: false },
    variation: String,
    colorVariation: String,
    interpretation: String
})
function unite(f) {
    if (f) {
      if (f === 'money') return ' Ar';
      if (f === 'percentage') return '';
      if (f === 'number') return ' année(s)';
    }
    return '';
}
</script>
<template>
    <div class="container">
        <div class="title">
            <p class="focus">{{ texte }}</p>
            <p class="indicator">Vue globale sur l'évolution de cet indicateur.</p>
        </div>
        <div class="data">
          <Texte v-if="parseFloat(chiffre) > 0" :texte="'+'" :type="'title-dark'"/>
          <Texte :texte="chiffre" :type="'title-dark'"/>
          <Texte v-if="format === 'money'" :texte="'Ar'" :type="'black-dark'"/>
            <p :class="colorVariation">{{ icon }}</p>
        </div>
        
        <Texte :texte="interpretation+
        '. Une évolution de ' +chiffre + unite(format) + ' et une variation de '+variation+'% '
        " :type="'dark'"/>
    </div>
</template>
<style lang="scss" scoped>
.focus{
    font-family: $stara-black;
    font-size: 32px;
    margin: 0px;
    padding: 0px;
}
.indicator{
    font-family: $stara-medium;
    font-size: 16px;
    color: $gris;
    margin: 0px;
    padding: 0px;
}
.title {
  display: flex;
  flex-direction: column;
  margin: 0px;
  padding: 0px;
}
.data {
  display: flex;
  align-items: center;
  margin-top: -10px;
  gap: 10px;

}
.container{
    width: 100%;
    height: 370px;
    align-items: flex-start;
    justify-content: space-between;
    align-content: flex-start;
    align-self: flex-start;
    display: flex;
    flex-direction: column;
    font-family: Stara;
    font-size: 32px;
    font-style: normal;
    line-height: normal;
    margin: 0;
    padding: 32px;
    gap: 5px;
    border-radius: $radius-pm;
    transition: transform 0.3s ease, filter 0.3s ease-in-out;
}


.trend-neutral {
  color: $gris;
  font-family: $stara-bold;
  font-size: 48px;
  font-style: normal;
  line-height: normal;
  margin: 5px 0px;
}

.trend-stable {
  color: $gris;
  font-family: $stara-bold;
  font-size: 48px;
  font-style: normal;
  line-height: normal;
  margin: 5px 0px;
}

.trend {
  color: $gris;
  font-family: $stara-bold;
  font-size: 48px;
  font-style: normal;
  line-height: normal;
  margin: 5px;
}

.trend-up {
  color: $vert;
  font-family: $stara-bold;
  font-size: 48px;
  font-style: normal;
  line-height: normal;
  margin: 5px 0px;
  padding: 0 5px ;
  border-radius: $radius-pm;
}

.trend-down {
  color: $rouge;
  font-family: $stara-bold;
  font-size: 48px;
  font-style: normal;
  line-height: normal;
  margin: 5px 0px;
}

</style>
