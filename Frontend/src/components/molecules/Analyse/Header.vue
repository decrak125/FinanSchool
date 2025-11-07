<script setup>
import { ref, computed, onMounted } from "vue";
import profile from '@/components/atoms/profile.vue';
import Notifications from '@/components/molecules/Analyse/Notifications.vue';
import ContentHeader from "./Content-header.vue";
defineProps({
  menu: String,
  sousmenu : String,
});
</script>
<template>
    <div class="header">
        <div class="gauche">
            <ContentHeader :menu="menu" :sousmenu="sousmenu"/>
        </div>
        <div class="droite">
        <Notifications/>
        <profile/>
        </div>
    </div>
</template>

<style lang="scss" scoped>
.header {
    display: flex;
    // height: 48px;
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
.droite {
    display: flex;
    gap: 10px;
    align-items: center;
}
.gauche {
    display: flex;
    gap: 10px;
    align-items: center;
}
</style>