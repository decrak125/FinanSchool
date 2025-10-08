<script setup>
</script>
<template>
    <div class="popup">
      <div class="popup-content">
        <slot/>
      </div>
    </div>

</template>
<style lang="scss" scoped>
    .popup {
    position: absolute;
    // top: 0;
    // left: 0;
    @include position-contenus(flex, center, center);
    margin-top: 11%;
    width: 82%;
    height: 65%;
    // box-shadow: 0px 4px 75px 1000px rgba(0, 0, 0, 0.75) inset;
    backdrop-filter: blur(5px);
    z-index: 9999;
    }

    .popup-content {
    display: flex;
    padding: 24px;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    // gap: 10px;
    border-radius: $radius-pm;
    background-color: #fff;
    }
</style>