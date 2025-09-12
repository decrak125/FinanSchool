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
    // @include position-container();
    @include position-contenus();
    flex-direction: column;
    text-align: center;
    background-color: $light;
    border-radius: $radius-pm;
    width: 566px;
    height: 100vh;
    // padding: 10px 64px; 
    display: flex;
    gap: 24px;
    flex-shrink: 0;
    border-radius: var(--border-radius, 32px) 0 0 var(--border-radius, 32px);
    /* Shadow Login */
    box-shadow: -32px 0 var(--border-radius, 32px) 0 rgba(0, 0, 0, 0.10);

}
</style>