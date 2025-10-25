<script setup>
import Texte from '../Texte.vue';
</script>
<template>
    <div class="container">
        <Texte :texte="'70%'" :type="'title-dark'"/>
    </div>
</template>
<style lang="scss" scoped>
.container{
    width: 100%;
    height: 422px;
    align-items: flex-start;
    justify-content: flex-start;
    align-content: flex-start;
    align-self: flex-start;
    display: flex;
    flex-direction: column;
    background-color: #ffff;
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
</style>
