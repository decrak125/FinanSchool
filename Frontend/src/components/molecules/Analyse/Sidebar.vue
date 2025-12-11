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
    type: 'simple',
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
        texte: 'Répartition des produits',
        redirection: '/profits'
      },
      {
        id: 'comparatif',
        texte: 'Comparatif',
        redirection: '/comparatif'
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
        id: 'indicateurs_generaux',
        texte: 'Indicateurs généraux',
        redirection: '/indicateur-general'
      },
      {
        id: 'indicateurs_pedagogique',
        texte: 'Indicateurs pedagogiques',
        redirection: '/indicateur-pedagogique'
      },
      {
        id: 'indicateurs_rentabilite',
        texte: 'Indicateurs de rentabilité',
        redirection: '/indicateur-rentabilite'
      },
      {
        id: 'ratios_liquidite',
        texte: 'Indicateurs de liquidité',
        redirection: '/indicateur-liquidite'
      },
      {
        id: 'ratios_solvabilite',
        texte: 'Indicateurs de solvabilité',
        redirection: '/indicateur-solvabilite'
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
      // {
      //   id: 'Axes',
      //   texte: 'Axes analytiques',
      //   redirection: '/axe-analytique'
      // },
      {
        id: 'Centres',
        texte: 'Centres analytiques',
        redirection: '/centre-analytique'
      },
      {
        id: 'Codes',
        texte: 'Codes analytiques',
        redirection: '/code-analytique'
      },
      {
        id: 'Affectations',
        texte: 'Affectations aux centres',
        redirection: '/affectation-analytique'
      },
      {
        id: 'non-affected',
        texte: 'Sous-comptes non affectés',
        redirection: '/non-affected'
      },
      {
        id: 'parametres',
        texte: 'Saisie des indicateurs',
        redirection: '/parametres'
      }
    ]
  }
];

// Menu du bas (séparé)
const bottomMenuConfig = [
  {
    id: 'parametres',
    icon: 'bi bi-gear-fill',
    texte: 'Paramètres',
    redirection: '/parametres',
    type: 'simple'
  }
];

// État réactif
const openMenu = ref(null);
const activeMenu = ref('accueil');
const isMobileMenuOpen = ref(false);

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
    closeMobileMenu();
  } else if (menu.type === 'dropdown') {
    // Basculer l'état d'ouverture
    openMenu.value = openMenu.value === menu.id ? null : menu.id;
    
    // Si c'est un menu dropdown sans enfant actif, le marquer comme actif
    // if (!menu.children.some(child => child.id === activeMenu.value)) {
    //   activeMenu.value = menu.id;
    // }
  }
}

// Gérer le clic sur un sous-menu
function handleSubmenuClick(submenu) {
  activeMenu.value = submenu.id;
  closeMobileMenu();
}

const logout = () => {
  localStorage.removeItem("token");
  router.push("/");
}

// Fermer le menu mobile
const closeMobileMenu = () => {
  isMobileMenuOpen.value = false;
}

// Toggle menu mobile
const toggleMobileMenu = () => {
  isMobileMenuOpen.value = !isMobileMenuOpen.value;
}

// Initialiser
onMounted(() => {
  setActiveFromRoute();
});
</script>

<template>
  <!-- Version Desktop -->
  <aside class="sidebar-desktop">
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
          <div :class="activeMenu === menu.id ? 'actif' : ''" v-if="menu.type == 'simple'">
            <SidebarMenu         
            :icon="menu.icon"
            :texte="menu.texte"
            :redirection="menu.redirection"
            @click="handleMenuClick(menu)"
          />
          </div>

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
    </div>
  </aside>

  <!-- Version Mobile/Tablette -->
  <aside class="sidebar-mobile">
    <div class="mobile-header">
      <div class="logo"></div>
      <button class="mobile-menu-toggle" @click="toggleMobileMenu">
        <i class="bi" :class="isMobileMenuOpen ? 'bi-x-lg' : 'bi-list'"></i>
      </button>
    </div>

    <transition name="mobile-slide">
      <div v-show="isMobileMenuOpen" class="mobile-menu-content">
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

        <!-- Bas du menu mobile -->
        <div class="bottom-menu">
          <hr />
          <SidebarMenu
            v-for="menu in bottomMenuConfig"
            :key="menu.id"
            :icon="menu.icon"
            :texte="menu.texte"
            :redirection="menu.redirection"
            :class="{ active: isMenuActive(menu) }"
            @click="handleMenuClick(menu)"
          />
          <SidebarMenu
            :texte="'Déconnexion'"
            :icon="'bi bi-door-closed-fill'"
            :redirection="'/'"
            @click="logout"
          />
        </div>
      </div>
    </transition>
  </aside>
</template>

<style lang="scss" scoped>
.sidebar-desktop {
  @include glass();
  // -----------------------
  // background-color: #fff;
  display: flex;
  width: 245px;
  height: 100%;
  padding: 32px 24px;
  // margin: 8px;
  border-radius: $radius-pm;
  flex-direction: column;
  gap: 24px;
  align-items: center;
  justify-content: space-between;

  @media (max-width: 1024px) {
    display: none;
  }
}

.sidebar-mobile {
  display: none;
  width: 100%;
  
  @media (max-width: 1024px) {
    display: block;
    background: white;
    border-radius: $radius-pm;
    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
  }
  
  @media (max-width: 768px) {
    border-radius: $radius-pm;
  }
}

.mobile-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px;
  width: 100%;
}

.mobile-menu-toggle {
  background: none;
  border: none;
  font-size: 24px;
  color: $primary;
  cursor: pointer;
  padding: 8px;
}

.mobile-menu-content {
  max-height: 70vh;
  overflow-y: auto;
  padding: 0 16px 16px;
}

.sb-menu {
  display: flex;
  flex-direction: column;
  padding: 32px 24px;
  gap: 24px;
  align-items: center;
  justify-content: center;
  margin: 0 auto;
  width: 80%;
  
  @media (max-width: 1024px) {
    padding: 16px 0;
    gap: 16px;
  }
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
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  gap: 10px;
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

/* Transition menu mobile */
.mobile-slide-enter-active,
.mobile-slide-leave-active {
  transition: all 0.3s ease-in-out;
  overflow: hidden;
}

.mobile-slide-enter-from,
.mobile-slide-leave-to {
  max-height: 0;
  opacity: 0;
}

.mobile-slide-enter-to,
.mobile-slide-leave-from {
  max-height: 70vh;
  opacity: 1;
}

/* Ajout d'un léger rebond */
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
  
  @media (max-width: 768px) {
    width: 150px;
    height: 36px;
  }
}

.top {
  align-self: stretch;
}

/* Style du menu actif */
.active {
  background: rgba(255, 255, 255, 0.25);
  -webkit-backdrop-filter: blur(20px);
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1),
  inset 0 1px 0 rgba(255, 255, 255, 0.2);
  border-radius: $radius-pm;
  color: $secondary !important;
  transition: all 0.3s ease;
}

.actif {
  @include glass();
  border-radius: $radius-pm;
  color: $secondary !important;
  transition: all 0.3s ease;
}

.active .bi {
  color: $secondary !important;
}

/* Responsive pour les éléments de menu */
@media (max-width: 1024px) {
  .menu-item {
    width: 100%;
  }
  
  .bottom-menu {
    position: fixed;
    padding-top: 26px;
  }
}
</style>