<script setup>
import { ref, onMounted, computed } from "vue";
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

// Fonction pour obtenir les initiales de l'utilisateur
const getUserInitials = computed(() => {
    if (!user.value?.name) return '?';
    
    const nameParts = user.value.name.trim().split(' ');
    if (nameParts.length === 1) {
        return nameParts[0].charAt(0).toUpperCase();
    } else {
        return (nameParts[0].charAt(0) + nameParts[nameParts.length - 1].charAt(0)).toUpperCase();
    }
});

// Fonction pour générer une couleur basée sur le nom de l'utilisateur
const getAvatarColor = computed(() => {
    if (!user.value?.name) return '#4f46e5'; // Couleur par défaut
    
    const colors = [
        '#4f46e5', '#0ea5e9', '#10b981', '#f59e0b', 
        '#ef4444', '#8b5cf6', '#ec4899', '#14b8a6'
    ];
    
    let hash = 0;
    for (let i = 0; i < user.value.name.length; i++) {
        hash = user.value.name.charCodeAt(i) + ((hash << 5) - hash);
    }
    
    return colors[Math.abs(hash) % colors.length];
});
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
        <!-- Avatar avec initiales -->
        <div class="avatar-initials" :style="{ backgroundColor: getAvatarColor }">
            {{ getUserInitials }}
        </div>
    </div>
    <transition name="fade">
        <div class="pop" v-if="cliqued">
        <div class="container">
            <!-- Avatar avec initiales dans le popup -->
            <div class="avatar-initials large" :style="{ backgroundColor: getAvatarColor }">
                {{ getUserInitials }}
            </div>
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
    top: 80px;
    right: 24px;
    @include glass();
    background-color: #fff;
    padding: 12px 32px;
    border-radius: $radius-pm;
    box-shadow: 0 10px 25px rgba(0, 0, 0, 0.15);
    z-index: 1000;
}

.containersolo {
    @include glass();
    cursor: pointer;
    display: inline-flex;
    padding: 0 12px;
    justify-content: flex-end;
    align-items: center;
    gap: 10px;
    flex-shrink: 0;
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
    cursor: pointer;
    display: flex;
    height: 100%;
    flex-direction: column;
    justify-content: center;
    align-items: flex-start;
    align-self: stretch;
}

// Avatar avec initiales (petit)
.avatar-initials {
    width: 32px;
    height: 32px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-family: Stara;
    font-size: 14px;
    font-weight: 600;
    text-transform: uppercase;
    
    &.large {
        width: 48px;
        height: 48px;
        font-size: 18px;
    }
}

.nomsolo {
    font-family: Stara;
    font-size: 14px;
    font-style: normal;
    font-weight: 600;
    line-height: normal;
    color: $primary;
}

.nom {
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
    color: #575757;
    font-family: Stara;
    font-size: 12px;
    font-style: normal;
    font-weight: 600;
    line-height: normal;
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