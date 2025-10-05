<script setup>
</script>
<template>
    <div class="container">
        <div class="main">
            <slot />
        </div>
    </div>
</template>
<style lang="scss" scoped>
.main {
    @include position-container();
    @include position-contenus();
    padding: var(--border-radius, 32px) 64px;
    flex-direction: column;
    background-color: $light;
    border-radius: $radius-pm;
    width: 500px;
    display: flex;
    gap: 16px;
    text-align: center;
    
}

.container {
    position: fixed;
    top: 0;
    left: 0;
    @include position-contenus(flex, center, center);
    width: 100%;
    height: 100vh;
    box-shadow: 0px 4px 75px 1000px rgba(0, 0, 0, 0.75) inset;
    backdrop-filter: blur(2px);
    z-index: 9998;

}
</style>