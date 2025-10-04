<script setup>
import sidebarMenu from '@/components/atoms/sidebar-menu.vue';
</script>
<template>
        <sidebarMenu :icon="'bi bi-house-fill'" :texte="'Accueil'" :redirection="'/home'" :dropdown="true" />
        <p>hi</p>
</template>
<style lang="scss" scoped>
</style>