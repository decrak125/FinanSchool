<template>
    <aside class="sidebar">
      <div class="logo">
        <img src="" alt="Logo" />
      </div>
      <nav>
        <ul>
          <!-- Accueil -->
          <SidebarMenu :icon="'bi bi-house-fill'" :texte="'Accueil'" :redirection="'/home'" :dropdown="true" />
  
          <!-- Analyse des coûts -->
          <li>
            <button @click="toggleMenu('analyse')" class="dropdown-btn">
              <i class="fas fa-chart-pie"></i> Analyse des coûts
              <span :class="{'rotate': openMenu === 'analyse'}">▼</span>
            </button>
            <ul v-show="openMenu === 'analyse'" class="submenu">
              <li><a href="#">Répartition des charges</a></li>
              <li><a href="#">Répartition des profits</a></li>
              <li><a href="#">Graphiques de ventilation</a></li>
            </ul>
          </li>
  
          <!-- Indicateurs & Ratios -->
          <li>
            <button @click="toggleMenu('indicateurs')" class="dropdown-btn">
              <i class="fas fa-chart-line"></i> Indicateurs & Ratios
              <span :class="{'rotate': openMenu === 'indicateurs'}">▼</span>
            </button>
            <ul v-show="openMenu === 'indicateurs'" class="submenu">
              <li><a href="#">Ratio de rentabilité</a></li>
              <li><a href="#">Ratio de solvabilité</a></li>
            </ul>
          </li>
  
          <!-- Conseils -->
          <li>
            <a href="#">
              <i class="fas fa-lightbulb"></i> Conseils
            </a>
          </li>
        </ul>
      </nav>
  
      <div class="settings">
        <a href="#">
          <i class="fas fa-cog"></i> Paramètres
        </a>
      </div>
    </aside>
  </template>
  
  <script setup>
  import { ref } from "vue";
  import SidebarMenu from '@/components/atoms/sidebar-menu.vue';
  
  const openMenu = ref(null);
  
  function toggleMenu(menu) {
    openMenu.value = openMenu.value === menu ? null : menu;
  }
  </script>
  
  <style scoped>
  .sidebar {
    display: flex;
    width: 248px;
    height: 100vh;
    padding: 32px 24px;
    flex-direction: column;
    justify-content: space-between;
    align-items: center;
    /* flex-shrink: 0; */
    /* align-self: stretch; */
  }
  .logo {
    padding: 20px;
    text-align: center;
  }
  nav ul {
    list-style: none;
    padding: 0;
  }
  nav ul li {
    margin: 5px 0;
  }
  a, button {
    display: flex;
    align-items: center;
    padding: 10px 20px;
    color: #002b5c;
    text-decoration: none;
    font-weight: 500;
    width: 100%;
  }
  button {
    background: none;
    border: none;
    cursor: pointer;
    justify-content: space-between;
  }
  .submenu {
    background: #f9f9f9;
    padding-left: 20px;
  }
  .submenu li a {
    font-size: 14px;
    padding: 8px 20px;
  }
  .rotate {
    transform: rotate(180deg);
  }
  .settings {
    padding: 20px;
    border-top: 1px solid #eee;
  }
  </style>
  