<script setup>
import { ref, computed, onMounted } from "vue";
import { useRoute } from "vue-router";
import SidebarMenu from '@/components/atoms/sidebar-menu.vue';

const route = useRoute();

// Configuration centralisée des menus
const menuConfig = [
  {
    id: 'accueil',
    icon: 'bi bi-house-fill',
    texte: 'Accueil',
    redirection: '/analyse',
    type: 'simple'
  },
  {
    id: 'analyse',
    icon: 'bi bi-pie-chart-fill',
    texte: 'Analyse des coûts',
    redirection: '#',
    type: 'dropdown',
    children: [
      {
        id: 'repartition_charges',
        texte: 'Répartition des charges',
        redirection: '/couts'
      },
      {
        id: 'repartition_profits',
        texte: 'Répartition des profits',
        redirection: '/profits'
      },
      {
        id: 'comparatif',
        texte: 'Comparatif',
        redirection: '#'
      }
    ]
  },
  {
    id: 'ratios',
    icon: 'bi bi-graph-up',
    texte: 'Indicateurs & Ratios',
    redirection: '#',
    type: 'dropdown',
    children: [
      {
        id: 'ratios_liquidite',
        texte: 'Ratios de liquidité',
        redirection: '#'
      },
      {
        id: 'ratios_solvabilite',
        texte: 'Ratios de solvabilité',
        redirection: '#'
      },
      {
        id: 'ratios_rentabilite',
        texte: 'Ratios de rentabilité',
        redirection: '#'
      }
    ]
  },
  {
    id: 'saisieAnalytique',
    icon: 'bi bi-sliders',
    texte: 'Saisie analytique',
    redirection: '#',
    type: 'dropdown',
    children: [
      {
        id: 'Axes',
        texte: 'Axes analytiques',
        redirection: '/axe-analytique'
      },
      {
        id: 'Centres',
        texte: 'Centres analytiques',
        redirection: '/centre-analytique'
      },
      {
        id: 'Affectations',
        texte: 'Affectations aux centres',
        redirection: '/affectation-analytique'
      }
    ]
  },
  {
    id: 'conseils',
    icon: 'bi bi-lightbulb-fill',
    texte: 'Conseils',
    redirection: '#',
    type: 'simple'
  }
];

// Menu du bas (séparé)
const bottomMenuConfig = [
  {
    id: 'parametres',
    icon: 'bi bi-gear-fill',
    texte: 'Paramètres',
    redirection: '#',
    type: 'simple'
  }
];

// État réactif
const openMenu = ref(null);
const activeMenu = ref('accueil');

// Créer un mapping automatique route -> menuId
const routeToMenuMap = computed(() => {
  const map = {};
  
  const processMenu = (menu) => {
    if (menu.redirection && menu.redirection !== '#') {
      map[menu.redirection] = menu.id;
    }
    
    if (menu.children) {
      menu.children.forEach(child => {
        if (child.redirection && child.redirection !== '#') {
          map[child.redirection] = child.id;
        }
      });
    }
  };
  
  menuConfig.forEach(processMenu);
  bottomMenuConfig.forEach(processMenu);
  
  return map;
});

// Trouver le menu parent d'un sous-menu
function findParentMenu(menuId) {
  return menuConfig.find(menu => 
    menu.children && menu.children.some(child => child.id === menuId)
  )?.id || null;
}

// Déterminer l'état actif basé sur la route
function setActiveFromRoute() {
  const currentPath = route.path;
  
  // Chercher la correspondance exacte
  let activeMenuId = routeToMenuMap.value[currentPath];
  
  // Si pas trouvé, chercher une correspondance partielle
  if (!activeMenuId) {
    for (const [routePath, menuId] of Object.entries(routeToMenuMap.value)) {
      if (currentPath.startsWith(routePath)) {
        activeMenuId = menuId;
        break;
      }
    }
  }
  
  if (activeMenuId) {
    activeMenu.value = activeMenuId;
    
    // Ouvrir le menu parent si c'est un sous-menu
    const parentMenu = findParentMenu(activeMenuId);
    if (parentMenu) {
      openMenu.value = parentMenu;
    } else {
      openMenu.value = null;
    }
  }
}

// Vérifier si un menu est actif (inclut les enfants)
function isMenuActive(menu) {
  if (menu.id === activeMenu.value) return true;
  
  if (menu.children) {
    return menu.children.some(child => child.id === activeMenu.value);
  }
  
  return false;
}

// Gérer le clic sur un menu
function handleMenuClick(menu) {
  if (menu.type === 'simple') {
    activeMenu.value = menu.id;
    openMenu.value = null;
  } else if (menu.type === 'dropdown') {
    // Basculer l'état d'ouverture
    openMenu.value = openMenu.value === menu.id ? null : menu.id;
    
    // Si c'est un menu dropdown sans enfant actif, le marquer comme actif
    if (!menu.children.some(child => child.id === activeMenu.value)) {
      activeMenu.value = menu.id;
    }
  }
}

// Gérer le clic sur un sous-menu
function handleSubmenuClick(submenu) {
  activeMenu.value = submenu.id;
}
const logout = () => {
  localStorage.removeItem("token");
  router.push("/");
}
// Initialiser
onMounted(() => {
  setActiveFromRoute();
});
</script>

<template>
  <aside>
    <div class="top">
      <div class="logo"></div>
      <div class="sb-menu">
        <!-- Menus principaux -->
        <div 
          v-for="menu in menuConfig" 
          :key="menu.id"
          class="menu-item"
          :class="{ 'has-dropdown': menu.type === 'dropdown' }"
        >
          <!-- Menu simple -->
          <SidebarMenu
            v-if="menu.type === 'simple'"
            :icon="menu.icon"
            :texte="menu.texte"
            :redirection="menu.redirection"
            :class="{ active: isMenuActive(menu) }"
            @click="handleMenuClick(menu)"
          />

          <!-- Menu avec dropdown -->
          <div v-else-if="menu.type === 'dropdown'" class="dropdown-menu">
            <div class="main-menu">
              <SidebarMenu
                @click="handleMenuClick(menu)"
                :icon="menu.icon"
                :texte="menu.texte"
                :redirection="menu.redirection"
                :dropdown="true"
                :class="{ active: isMenuActive(menu) }"
              />
            </div>

            <transition name="smooth-slide">
              <div
                v-show="openMenu === menu.id"
                class="submenu"
              >
                <SidebarMenu
                  v-for="child in menu.children"
                  :key="child.id"
                  :texte="child.texte"
                  :redirection="child.redirection"
                  :class="{ active: activeMenu === child.id }"
                  @click="handleSubmenuClick(child)"
                />
              </div>
            </transition>
          </div>
        </div>
      </div>
    </div>

    <!-- Bas du menu -->
    <div class="bottom-menu">
      <hr />
      <!-- Menus du bas -->
      <SidebarMenu
        v-for="menu in bottomMenuConfig"
        :key="menu.id"
        :icon="menu.icon"
        :texte="menu.texte"
        :redirection="menu.redirection"
        :class="{ active: isMenuActive(menu) }"
        @click="handleMenuClick(menu)"
      />
      <!-- LOG OUT -->
      <SidebarMenu
        :texte="'Déconnexion'"
        :icon="'bi bi-door-closed-fill'"
        :redirection="'/'"
        @click="logout"
      />
    </div>
  </aside>
</template>

<style lang="scss" scoped>
aside {
  display: flex;
  width: 280px;
  height: 100vh;
  padding: 32px 24px;
  flex-direction: column;
  gap: 24px;
  align-items: center;
  justify-content: space-between;
}

.sb-menu {
  display: flex;
  flex-direction: column;
  padding: 32px 24px;
  gap: 24px;
  align-items: center;
  width: 100%;
}

.analyse {
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 100%;
  gap: 8px;
}

/* Sous-menu */
.submenu {
  // background-color: #6d5e5e;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  gap: 10px;
  // padding: 0 12px;
  width: 100%;
}

/* Transition fluide + mouvement du reste */
.smooth-slide-enter-active,
.smooth-slide-leave-active {
  transition: all 0.6s cubic-bezier(0.25, 1, 0.5, 1.2);
  overflow: hidden;
}

.smooth-slide-enter-from,
.smooth-slide-leave-to {
  max-height: 0;
  opacity: 0;
  transform: translateY(-8px);
}

.smooth-slide-enter-to{
  max-height: 600px;
  opacity: 1;
  transform: translateY(0);
}
.smooth-slide-leave-from {
  max-height: 1000px;
  opacity: 1;
  transform: translateY(0);
}

/* Ajout d’un léger rebond */
.smooth-slide-enter-active {
  transition: all 0.55s cubic-bezier(0.23, 1, 0.32, 1.4);
}

/* Ligne de séparation */
hr {
  border: 0.2px solid #ccc;
  width: 100%;
}

/* Logo */
.logo {
  width: 200px;
  height: 48px;
  background: url("@/assets/img/01Raitra kidz 300px.png") 50% / contain no-repeat;
}

.top {
  align-self: stretch;
}

/* Style du menu actif */
.active {
  background-color: #e0e7ff !important;
  border-radius: $radius-pm;
  color: #1e40af !important;
  transition: all 0.3s ease;
}

.active .bi {
  color: #1e40af !important;
}
</style>