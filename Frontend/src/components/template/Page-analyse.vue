<script setup>
import sidebar from '@/components/molecules/Analyse/Sidebar.vue';
import Header from '@/components/molecules/Analyse/Header.vue';
import Footer from '../molecules/Analyse/Footer.vue';
import { useNotificationStore } from '@/stores/notificationStore'; // ← IMPORTANT
import ChatBot from '@/components/template/ChatBot.vue';
import Card from '../atoms/Chart/Card.vue';

defineProps({
  menu: String,
  sousmenu : String,
});
const token = localStorage.getItem("token");
const store = useNotificationStore(); // ← INITIALISATION DU STORE

if (!token) {
  window.location.href = "/";
}

// Charger les notifications une seule fois quand la page s'affiche
import { onMounted } from 'vue';
onMounted(() => {
  if (token) {
    store.loadNotifications();
    
    // Écouter les nouvelles notifications en temps réel
    window.Echo.channel('notifications')
      .listen('NotificationCreee', (e) => {
        console.log('Nouvelle notification reçue!', e);
        store.addNotification(e.notification);
      });
  }
});
</script>

<template>
  <div class="all">
    <div class="container" v-if="token">
          <div class="bc"></div>

      <div class="sidebar">
        <sidebar />
      </div>
      <div class="main">
        <div class="header">
          <Header :menu="menu" :sousmenu="sousmenu"/>
        </div>
        <div class="content">
          <slot />
          <ChatBot />
        </div>
        <!-- <Footer/> -->
      </div>
    </div>
    <div class="redirection" v-else>
      <div class="loader">
        <span class="bar"></span>
        <span class="bar"></span>
        <span class="bar"></span>
      </div>
    </div>
  </div>
</template>

<!-- Le reste de votre style reste inchangé -->
<style lang="scss" scoped>
// html, body {
//   background-color: $light;
//   height: 100%;
//   margin: 0;
// }

.container {
  
  // background-color: $light;
  display: flex;
  width: 100%;
  height: 100vh; // toute la hauteur visible de l’écran
  // overflow: hidden;
  @media (max-width: 1024px) {
    flex-direction: column;
    height: auto;
    
  }
}

.main {
  left: 0;
  top: 0;
  margin-left: 265px; // espace égal à la largeur de la sidebar
  display: flex;
  flex-direction: column;
  padding: 32px 12px 12px 0;
  flex: 1;
  width:100vh;
  height: fit-content;
  // background-color: $light;
  // overflow-y: auto; // permet de scroller uniquement dans le contenu
  scrollbar-width: thin;
  gap: 24px;

  @media (max-width: 1024px) {
    margin-left: 0;
    height: auto;
    overflow: visible;
    padding: 16px;
    gap: 16px;
  }
}
.header {
  position: fixed;
  padding: 8px;
  top: 0;
  left: 260px; // démarre après la sidebar
  right: 0;
  // height: 100px;
  // background-color: $light; // ou ta couleur de fond du header
  z-index: 999;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 24px;
  // border-bottom: 1px solid rgba(0, 0, 0, 0.1);

  @media (max-width: 1024px) {
    left: 0;
    position: relative;
    height: auto;
    border-bottom: none;
  }
}
.content {
  margin-top: 80px;
  flex: 1;
  width: 100%;
  // background-color: $light;
  // border-radius: $radius-pm;
  @include position-contenus(block, center, center);
}

#sb {
  @media (max-width: 1024px) {
    display: none;
  }
}

.sidebar-mobile {
  display: none;
  width: 100%;

  @media (max-width: 1024px) {
    display: block;
  }
}
/* From Uiverse.io by aryamitra06 */
.loader {
  width: 100vh;
  height: 100vh;
  display: flex;
  background-color: $light;
  @include position-contenus(flex, center, center);
  @include position-container();
}

.bar {
  display: inline-block;
  width: 3px;
  height: 12px;
  background-color: rgba(69, 66, 194, 0.5);
  border-radius: 10px;
  animation: scale-up4 1s linear infinite;
}

.bar:nth-child(2) {
  height: 23px;
  margin: 0 5px;
  animation-delay: .25s;
}

.bar:nth-child(3) {
  animation-delay: .5s;
}

@keyframes scale-up4 {
  20% {
    background-color: #7254e0;
    transform: scaleY(1);
  }

  40% {
    transform: scaleY(0.5);
  }
}
.sidebar {
  position: fixed; // position fixe sur l’écran
  top: 0;
  left: 0;
  align-items: center;
  justify-content: center;
  display: flex;
  padding: 12px;
  // width: 260px; // largeur fixe
  height: 100vh;
  // background-color: $light;
  // z-index: 1000;
  // background-color: $light; // à adapter selon ta couleur
  // border-right: 1px solid rgba(0, 0, 0, 0.1);
  
  @media (max-width: 1024px) {
    position: relative;
    width: 100%;
    height: auto;
  }
}
.all{
  height: 100vh;
}
.bc{
  position: fixed;
  width: 100%;
  height: 100vh;
  // background: linear-gradient(
  //   -45deg,
  //   #f2c6b8, 
  //   #ffffff, 
  //   #ffe0e0, 
  //   #ffffff);
  background: url('@/assets/img/télécharger1.jpg') center no-repeat;
  background-color: $light;
  background-size:cover;
  // animation: gradient 15s ease infinite;
  
}

@keyframes gradient {
  0% { background-position: 0% 50%; }
  50% { background-position: 100% 50%; }
  100% { background-position: 0% 50%; }
}
</style>