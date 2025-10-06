<script setup>
defineProps({
  type: String,
  texte : String,
  redirection : String,
});
</script>
<template>
    <button v-bind:class="`button-${type}`">
      <div class="loader">
          <span class="bar"></span>
          <span class="bar"></span>
          <span class="bar"></span>
      </div>
    </button>
</template>
  <style lang="scss" scoped>

  .button-primary {
    cursor: pointer;
      @include bouton($primary, $light, $radius-pm, $stara);
      transition: all 0.5s ease-in-out;
  }
  .button-primary:hover {
    @include bouton($secondary, $light, $radius-pm, $stara);
  }

  .button-input {
    cursor: pointer;
      @include bouton($primary, $light, $radius-pm, $stara, 270px);
      transition: all 0.5s ease-in-out;
  }
  .button-input:hover {
    @include bouton($secondary, $light, $radius-pm, $stara, 270px);
  }
  .button-transparent {
    cursor: pointer;
      @include bouton(transparent, $light, $radius-pm, $stara, 270px);
      transition: all 0.5s ease-in-out;
      .bar{
        background-color: rgb(37, 38, 73);
      }
  }

/* From Uiverse.io by aryamitra06 */ 
.loader {
  display: flex;
  align-items: center;
  align-self: center;
  justify-content: center;
}

.bar {
  display: inline-block;
  width: 3px;
  height: 12px;
  background-color: rgba(255, 255, 255, .5);
  border-radius: 10px;
  animation: scale-up4 1s linear infinite;
}

.bar:nth-child(2) {
  height: 23px;
  margin: 0 5px;
  animation-delay: .25s;
}

.bar:nth-child(3) {
  animation-delay: .5s;
}

@keyframes scale-up4 {
  20% {
    background-color: #ffff;
    transform: scaleY(1);
  }

  40% {
    transform: scaleY(0.5);
  }
}
  </style>
  