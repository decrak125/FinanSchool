<script setup>

import Counter from '../counter.vue';
import LoadingText from '../Loading-text.vue';
    defineProps({
        texte: String,
        chiffre: {type:[Number, String]},
        icon: String,
        iconColor: String,
        format: String,
        negative: Boolean,
        loading: {type: Boolean, default: false}
    })
</script>
<template>
    <div class="Count-content" v-if="!loading">
        <i v-bind:class="icon" v-bind:style="`color:${iconColor};`"></i>
            <p class="texte">{{texte}}</p>
          <Counter v-if="chiffre === null || chiffre === undefined" :number="0" :format="format" :allowNegative="negative" />
          <Counter v-else :number="chiffre" :format="format" :allowNegative="negative" />
    </div>

    <div v-if="loading" class="Count-content">
        <i><LoadingText :type="'circle'" /></i>
            <p class="texte"><LoadingText :type="'line-4'" /></p>
          <LoadingText :type="'line-1'" />
          <LoadingText :type="'line-1'" />
    </div>
</template>
<style lang="scss" scoped>
.head {
    @include position-contenus();
    gap: 10px;
}
i{
  border-style: none;
//   color: $gris;
  text-decoration: none;
  width: 38px;
  height: 38px;
  justify-content: center;
  align-items: center;
  flex-shrink: 0;
}
.Count-content {
    width: 275px;
    height: 194px;
    align-items: center;
    justify-content: center;
  display: block;
  background-color: #ffff;
  font-family: Stara;
  font-size: 32px;
  font-style: normal;
  line-height: normal;
  margin: 0;
  padding: 32px;
  border-radius: $radius-pm;
  transition: transform 0.3s ease, filter 0.3s ease-in-out;
}
.Count-content:hover {
    transform: scale(1.02);
    transition: transform 0.3s ease, filter 0.3s ease-in-out;
}
.texte{
    color: $gris;
font-family: $stara-medium;
  font-size: 12px;
  font-style: normal;
  line-height: normal;

}
</style>