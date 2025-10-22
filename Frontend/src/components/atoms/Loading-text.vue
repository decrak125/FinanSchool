<script setup>
defineProps({
  type: String,
});
</script>
<template>
<!-- From Uiverse.io by Nawsome --> 
<div class="loader">
  <div class="wrapper">
    <div v-bind:class="type"></div>
  </div>
</div>
</template>
<style lang="scss" scoped>
.loader {
  position: relative;
//   width: 240px;
//   height: 130px;
//   margin-bottom: 10px;
//   border: 1px solid #d3d3d3;
//   padding: 15px;
  background-color: #ececec;
  overflow: hidden;
}

.wrapper:after {
  content: "";
  position: absolute;
  width: 100%;
  height: 100%;
  top: 0;
  left: 0;
  background: linear-gradient(110deg, rgba(227, 227, 227, 0) 0%, rgba(227, 227, 227, 0) 40%, rgba(255, 255, 255, 0.5) 50%, rgba(227, 227, 227, 0) 60%, rgba(227, 227, 227, 0) 100%);
  animation: gradient-animation_2 1.2s linear infinite;
}

.loader .wrapper {
//   width: 100%;
//   height: 100%;
  position: relative;
}

// .loader .wrapper > div {
// //   background-color: #ebebeb;
// }

.loader .circle {
  width: 50px;
  height: 50px;
  border-radius: 50%;
}

.loader .button {
  display: inline-block;
  height: 32px;
  width: 75px;
}

.loader .line-1 {
//   position: absolute;
  top: 11px;
//   left: 58px;
  height: 16px;
  width: 10%;
}

.loader .line-2 {
//   position: absolute;
//   top: 34px;
//   left: 58px;
  height: 16px;
  width: 30%;
}

.loader .line-3 {
//   position: absolute;
//   top: 57px;
  left: 0px;
  height: 16px;
  width: 50%;
}

.loader .line-4 {
//   position: absolute;
//   top: 80px;
  left: 0px;
  height: 16px;
  width: 70%;
}

@keyframes gradient-animation_2 {
  0% {
    transform: translateX(-100%);
  }

  100% {
    transform: translateX(100%);
  }
}</style>