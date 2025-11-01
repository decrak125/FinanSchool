<script setup>
import { ref, onMounted } from "vue";
import SidebarMenu from '@/components/atoms/sidebar-menu.vue';
import {useAuth} from "@/composables/useAuth.js";

const {
    user,
    isAuthenticated,
    fetchUser,
    logout
} = useAuth();

defineProps({
    texte: Object,
    type: String,
});
const cliqued = ref(false);

</script>
<template>
    <div class="containersolo" @click="cliqued = !cliqued">
        <transition v-if="!cliqued">
            <i class="bi bi-chevron-down" ></i>
        </transition>
        <transition name="fade" v-else>
            <i class="bi bi-chevron-up" ></i>
        </transition>
        <div class="info">
            <p class="nomsolo">
                {{ user?.name }}
            </p>
        </div>
        <img src="@/assets/img/pp.jpg" alt="" class="avatarsolo" />
    </div>
    <transition name="fade">
        <div class="pop" v-if="cliqued">
        <div class="container">
            <img src="@/assets/img/pp.jpg" alt="" class="avatar" />
            <div class="info">
                <p class="nom">
                    {{ user?.name }}
                </p>
                <p class="role">
                    {{ user?.email }}
                </p>
            </div>
            
        </div>
        <hr>
            <div class="log">
                <SidebarMenu :texte="'Se déconnecter'" :icon="'bi bi-door-closed-fill'" :redirection="'/'"
                    @click="logout" />
            </div>
    </div>
    </transition>
</template>
<style lang="scss" scoped>
.pop {
    position: absolute;
    display: block;
    flex-direction: column;
    top: 100px;
    right: 24px;
    background: $light;
    padding: 12px 32px;
    border: 1px solid #dbdbdb;
    border-radius: $radius-pm;
    box-shadow: 0 10px 25px rgba(0, 0, 0, 0.15);
    z-index: 1000;
}

.containersolo {
    cursor: pointer;
    display: inline-flex;
    // height: 54px;
    padding: 0 12px;
    background-color: $light;
    justify-content: flex-end;
    align-items: center;
    gap: 10px;
    flex-shrink: 0;
    border: 1px solid #dbdbdb;
    border-radius: $radius-pm;

}

.container {
    display: inline-flex;
    height: 54px;
    justify-content: flex-end;
    align-items: center;
    gap: 10px;
    flex-shrink: 0;

}

.info {
    // background-color: #ce6d6d;
    display: flex;
    height: 100%;
    // padding: 9px 0;
    flex-direction: column;
    justify-content: center;
    align-items: flex-start;
    align-self: stretch;
}

.avatarsolo {
    width: 32px;
    height: 32px;
    border-radius: 50%;
    background-color: #dbdbdb;
}

.nomsolo {
    // margin-top: 0;
    font-family: Stara;
    font-size: 14px;
    font-style: normal;
    font-weight: 600;
    line-height: normal;
    color: $primary;
}

.nom {
    // margin-top: 0;
    margin-bottom: 0;
    font-family: Stara;
    font-size: 14px;
    font-style: normal;
    font-weight: 600;
    line-height: normal;
    color: $primary;
}

.role {
    margin-top: 0;
    // margin-bottom: 100px;
    color: #575757;
    font-family: Stara;
    font-size: 12px;
    font-style: normal;
    font-weight: 600;
    line-height: normal;
}

.avatar {
    width: 48px;
    height: 48px;
    border-radius: 50%;
    background-color: #dbdbdb;
}

.fade-enter-active,
.fade-leave-active {
  transition: all 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
  transform: scale(0.9);
}

.fade-enter-to,
.fade-leave-from {
  opacity: 1;
  transform: scale(1);
}
</style>