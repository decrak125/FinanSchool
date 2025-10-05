<script setup>
import searchbar from '@/components/atoms/searchbar.vue';
import profile from '@/components/atoms/profile.vue';
</script>
<template>
    <div class="header">
        <searchbar :placeholder="'Rechercher ou taper une commande...'" :name="'search'" />
        <profile :texte="'Jean Dupont'" :icon="'bi bi-person-circle'" />
    </div>
</template>
<style lang="scss" scoped>
.header {
    // background-color: #fff;
    display: flex;
    height: 48px;
    justify-content: space-between;
    align-items: center;
    align-self: stretch;
}
</style>