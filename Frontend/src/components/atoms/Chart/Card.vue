<script setup>
import Counter from '../counter.vue';
    defineProps({
        texte: String,
        chiffre: Number,
        icon: String,
        iconColor: String,
        format: String,
    })
</script>
<template>
    <div class="Count-content">
        <i v-bind:class="icon" v-bind:style="`color:${iconColor};`"></i>
            <p class="texte">{{texte}}</p>
          <Counter v-if="chiffre = null" :number="0" :format="format" />
          <Counter v-if="chiffre !=null" :number="chiffre" :format="format" />
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
    width: 300px;
    height: max-content;
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