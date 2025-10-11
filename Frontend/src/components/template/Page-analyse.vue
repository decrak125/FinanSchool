<script setup>
import sidebar from '@/components/molecules/Analyse/Sidebar.vue';
import Header from '@/components/molecules/Analyse/Header.vue';

const token = localStorage.getItem("token");

if (!token) {
  window.location.href = "/";
}
</script>

<template>
  <div class="all">
    <div class="container" v-if="token">
      <sidebar class="sidebar-desktop" />
      <div class="main">
        <Header />
        <!-- <sidebar class="sidebar-mobile" /> -->
        <div class="content">
          <slot />
        </div>
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

<style lang="scss" scoped>
.container {
  @include position-contenus(flex, flex-start, center);
  width: 100%;
  height: 100%;
  
  @media (max-width: 1024px) {
    flex-direction: column;
  }
}

.main {
  display: flex;
  padding: 32px 24px 24px 0;
  flex-direction: column;
  align-items: center;
  gap: 24px;
  flex: 1 0 0;
  align-self: stretch;
  
  @media (max-width: 1024px) {
    padding: 16px;
    gap: 16px;
  }
  
  @media (max-width: 768px) {
    padding: 12px;
    gap: 12px;
  }
}

.content {
  background-color: $light;
  @include position-contenus(block, center, center);
  flex: 1 0 0;
  align-self: stretch;
  border-radius: $radius-pm;
  
  @media (max-width: 1024px) {
    border-radius: $radius-pm;
  }
}

.sidebar-desktop {
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
</style>