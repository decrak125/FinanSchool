<script setup>
import { ref, computed, onMounted } from "vue";
import searchbar from '@/components/atoms/searchbar.vue';
import profile from '@/components/atoms/profile.vue';




</script>
<template>
    <div class="header">
        <searchbar :placeholder="'Rechercher ou taper une commande...'" :name="'search'" />
        <profile/>
    </div>
</template>

<style lang="scss" scoped>
.header {
    display: flex;
    height: 48px;
    justify-content: space-between;
    align-items: center;
    align-self: stretch;
    
    @media (max-width: 768px) {
        flex-direction: column;
        height: auto;
        gap: 12px;
        align-items: stretch;
    }
}
</style>