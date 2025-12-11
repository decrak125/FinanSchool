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
    backdrop-filter: blur(20px);
    -webkit-backdrop-filter: blur(20px);
    display: flex;
    // height: 48px;
    justify-content: space-between;
    align-items: center;
    align-self: stretch;
    // mask-image: 
    //     linear-gradient(to top, rgba(0,0,0,0) 0%, rgba(0,0,0,1) 10%),     /* bas */
    //     linear-gradient(to right, rgba(0,0,0,0) 0%, rgba(0,0,0,1) 1%);    /* droite */

    // -webkit-mask-image: 
    //     linear-gradient(to top, rgba(0,0,0,0) 0%, rgba(0,0,0,1) 10%),
    //     linear-gradient(to right, rgba(0,0,0,0) 0%, rgba(0,0,0,1) 1%);

    /* Combine les deux masques en mode "intersection" */
    mask-composite: intersect;
    -webkit-mask-composite: destination-in;
    
    
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