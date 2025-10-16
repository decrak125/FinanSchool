<!-- components/Sidebar.vue -->
<template>
  <div class="sidebar">
    <!-- Header avec logo -->
    <div class="sidebar-header">
      <div class="logo">
        <div class="logo-icon">R</div>
        <div class="logo-text">
          <span class="logo-main">RAITRA</span>
          <span class="logo-sub">Kidz</span>
        </div>
      </div>
    </div>

    <!-- Navigation principale -->
    <nav class="sidebar-nav">
      <!-- Section Tableau de bord -->
      <div class="nav-group">
        <div class="nav-group-title">Vue d'ensemble</div>
        <div 
          class="nav-item"
          :class="{ active: currentRoute === '/dashboard' }"
          @click="navigateTo({ route: '/dashboard', name: 'Tableau de bord' })"
        >
          <i class="bi bi-columns-gap"></i>
          <span>Tableau de bord</span>
        </div>
      </div>

      <!-- Section Saisie -->
      <div class="nav-group">
        <div class="nav-group-title">Saisie</div>
        
        <!-- Journaux -->
        <div class="nav-item has-children" :class="{ 
          active: isItemActive(getNavigationItem('journaux')),
          'children-open': getNavigationItem('journaux').isOpen 
        }">
          <div class="nav-main" @click="toggleSubMenu(getNavigationItem('journaux'))">
            <i class="bi bi-journal-text"></i>
            <span>Journaux</span>
            <i class="chevron" :class="getNavigationItem('journaux').isOpen ? 'bi bi-chevron-up' : 'bi bi-chevron-down'"></i>
          </div>
          
          <transition name="submenu">
            <div v-show="getNavigationItem('journaux').isOpen" class="submenu">
              <div 
                class="submenu-item"
                :class="{ active: currentRoute === '/journal' }"
                @click="navigateTo({ route: '/journal', name: 'Tous les journaux' })"
              >
                <i class="bi bi-list-ul"></i>
                <span>Tous les journaux</span>
              </div>
              <div 
                class="submenu-item"
                :class="{ active: currentRoute === '/type-journal' }"
                @click="navigateTo({ route: '/type-journal', name: 'Types de journaux' })"
              >
                <i class="bi bi-tags"></i>
                <span>Types de journaux</span>
              </div>
              <div 
                class="submenu-item"
                :class="{ active: currentRoute === '/nouveau-journal' }"
                @click="navigateTo({ route: '/nouveau-journal', name: 'Nouveau journal' })"
              >
                <i class="bi bi-plus-circle"></i>
                <span>Nouveau journal</span>
              </div>
            </div>
          </transition>
        </div>

        <!-- Écritures -->
        <div class="nav-item has-children" :class="{ 
          active: isItemActive(getNavigationItem('ecritures')),
          'children-open': getNavigationItem('ecritures').isOpen 
        }">
          <div class="nav-main" @click="toggleSubMenu(getNavigationItem('ecritures'))">
            <i class="bi bi-pencil-square"></i>
            <span>Écritures</span>
            <i class="chevron" :class="getNavigationItem('ecritures').isOpen ? 'bi bi-chevron-up' : 'bi bi-chevron-down'"></i>
          </div>
          
          <transition name="submenu">
            <div v-show="getNavigationItem('ecritures').isOpen" class="submenu">
              <div 
                class="submenu-item"
                :class="{ active: currentRoute === '/ecritures' }"
                @click="navigateTo({ route: '/ecritures', name: 'Toutes les écritures' })"
              >
                <i class="bi bi-list-check"></i>
                <span>Toutes les écritures</span>
              </div>
              <div 
                class="submenu-item"
                :class="{ active: currentRoute === '/ecriture' }"
                @click="navigateTo({ route: '/ecriture', name: 'Saisie écriture' })"
              >
                <i class="bi bi-pencil"></i>
                <span>Saisie écriture</span>
              </div>
              <div 
                class="submenu-item"
                :class="{ active: currentRoute === '/validation-ecritures' }"
                @click="navigateTo({ route: '/validation-ecritures', name: 'Validation' })"
              >
                <i class="bi bi-check-circle"></i>
                <span>Validation</span>
              </div>
            </div>
          </transition>
        </div>

        <div class="nav-item has-children" :class="{ 
          active: isItemActive(getNavigationItem('grand-livre')),
          'children-open': getNavigationItem('grand-livre').isOpen 
        }">
          <div class="nav-main" @click="toggleSubMenu(getNavigationItem('grand-livre'))">
            <i class="bi bi-journals"></i>
            <span>Liste des Grand Livres</span>
            <i class="chevron" :class="getNavigationItem('grand-livre').isOpen ? 'bi bi-chevron-up' : 'bi bi-chevron-down'"></i>
          </div>
          
          <transition name="submenu">
            <div v-show="getNavigationItem('grand-livre').isOpen" class="submenu">
              <div 
                class="submenu-item"
                :class="{ active: currentRoute === '/liste-grand-livre' }"
                @click="navigateTo({ route: '/liste-grand-livre', name: 'Tous les grand livres' })"
              >
                <i class="bi bi-list-check"></i>
                <span>Grand livre</span>
              </div>
            </div>
          </transition>
        </div>
      </div>

      <!-- Section Structure -->
      <div class="nav-group">
        <div class="nav-group-title">Structure</div>
        
        <!-- Plan Comptable -->
        <div class="nav-item has-children" :class="{ 
          active: isItemActive(getNavigationItem('plan-comptable')),
          'children-open': getNavigationItem('plan-comptable').isOpen 
        }">
          <div class="nav-main" @click="toggleSubMenu(getNavigationItem('plan-comptable'))">
            <i class="bi bi-diagram-3"></i>
            <span>Plan Comptable</span>
            <i class="chevron" :class="getNavigationItem('plan-comptable').isOpen ? 'bi bi-chevron-up' : 'bi bi-chevron-down'"></i>
          </div>
          
          <transition name="submenu">
            <div v-show="getNavigationItem('plan-comptable').isOpen" class="submenu">
              <div 
                class="submenu-item"
                :class="{ active: currentRoute === '/classe' }"
                @click="navigateTo({ route: '/classe', name: 'Classes' })"
              >
                <i class="bi bi-1-circle"></i>
                <span>Classes</span>
              </div>
              <div 
                class="submenu-item"
                :class="{ active: currentRoute === '/rubrique' }"
                @click="navigateTo({ route: '/rubrique', name: 'Rubriques' })"
              >
                <i class="bi bi-2-circle"></i>
                <span>Rubriques</span>
              </div>
              <div 
                class="submenu-item"
                :class="{ active: currentRoute === '/compte' }"
                @click="navigateTo({ route: '/compte', name: 'Comptes' })"
              >
                <i class="bi bi-3-circle"></i>
                <span>Comptes</span>
              </div>
              <div 
                class="submenu-item"
                :class="{ active: currentRoute === '/souscompte' }"
                @click="navigateTo({ route: '/souscompte', name: 'Sous-comptes' })"
              >
                <i class="bi bi-4-circle"></i>
                <span>Sous-comptes</span>
              </div>
            </div>
          </transition>
        </div>

        <!-- Référentiels -->
        <div class="nav-item has-children" :class="{ 
          active: isItemActive(getNavigationItem('referentiels')),
          'children-open': getNavigationItem('referentiels').isOpen 
        }">
          <div class="nav-main" @click="toggleSubMenu(getNavigationItem('referentiels'))">
            <i class="bi bi-book"></i>
            <span>Référentiels</span>
            <i class="chevron" :class="getNavigationItem('referentiels').isOpen ? 'bi bi-chevron-up' : 'bi bi-chevron-down'"></i>
          </div>
          
          <transition name="submenu">
            <div v-show="getNavigationItem('referentiels').isOpen" class="submenu">
              <div 
                class="submenu-item"
                :class="{ active: currentRoute === '/devise' }"
                @click="navigateTo({ route: '/devise', name: 'Devises' })"
              >
                <i class="bi bi-currency-exchange"></i>
                <span>Devises</span>
              </div>
              <div 
                class="submenu-item"
                :class="{ active: currentRoute === '/paiement-mode' }"
                @click="navigateTo({ route: '/paiement-mode', name: 'Modes de paiement' })"
              >
                <i class="bi bi-credit-card"></i>
                <span>Modes de paiement</span>
              </div>
              <div 
                class="submenu-item"
                :class="{ active: currentRoute === '/tiers' }"
                @click="navigateTo({ route: '/tiers', name: 'Tiers' })"
              >
                <i class="bi bi-people"></i>
                <span>Tiers</span>
              </div>
            </div>
          </transition>
        </div>
      </div>

      <!-- Section Reporting -->
      <div class="nav-group">
        <div class="nav-group-title">Rapport</div>
        

         <!-- Balance général -->
        <div class="nav-item has-children" :class="{ 
          active: isItemActive(getNavigationItem('balance')),
          'children-open': getNavigationItem('balance').isOpen 
        }">
          <div class="nav-main" @click="toggleSubMenu(getNavigationItem('balance'))">
            <i class="bi bi-clipboard-data"></i>
            <span>Balance</span>
            <i class="chevron" :class="getNavigationItem('balance').isOpen ? 'bi bi-chevron-up' : 'bi bi-chevron-down'"></i>
          </div>
          
          <transition name="submenu">
            <div v-show="getNavigationItem('balance').isOpen" class="submenu">
              <div 
                class="submenu-item"
                :class="{ active: currentRoute === '/balance' }"
                @click="navigateTo({ route: '/balance', name: 'Balance' })"
              >
                <i class="bi bi-arrow-left-right"></i>
                <span>Balance géneral</span>
              </div>
            </div>
          </transition>
        </div>
        
        <div class="nav-item has-children" :class="{ 
          active: isItemActive(getNavigationItem('compte_resultat')),
          'children-open': getNavigationItem('compte_resultat').isOpen 
        }">
          <div class="nav-main" @click="toggleSubMenu(getNavigationItem('compte_resultat'))">
            <i class="bi bi-bar-chart-line"></i>
            <span>Compte de resultat</span>
            <i class="chevron" :class="getNavigationItem('compte_resultat').isOpen ? 'bi bi-chevron-up' : 'bi bi-chevron-down'"></i>
          </div>
          
          <transition name="submenu">
            <div v-show="getNavigationItem('compte_resultat').isOpen" class="submenu">
              <div 
                class="submenu-item"
                :class="{ active: currentRoute === '/compte_resultat' }"
                @click="navigateTo({ route: '/CR-Nature', name: 'CR-Nature' })"
              >
                <i class="bi bi-receipt"></i>
                <span>Par nature</span>
              </div>
              <div 
                class="submenu-item"
                :class="{ active: currentRoute === '/compte_resultat' }"
                @click="navigateTo({ route: '/CR-Fonction', name: 'CR-Fonction' })"
              >
                <i class="bi bi-diagram-3"></i>
                <span>Par fonction</span>
              </div>
            </div>
          </transition>
        </div>

        <!-- Trésorerie -->
        <div class="nav-item has-children" :class="{ 
          active: isItemActive(getNavigationItem('bilan')),
          'children-open': getNavigationItem('bilan').isOpen 
        }">
          <div class="nav-main" @click="toggleSubMenu(getNavigationItem('bilan'))">
            <i class="bi bi-table"></i>
            <span>Bilan</span>
            <i class="chevron" :class="getNavigationItem('bilan').isOpen ? 'bi bi-chevron-up' : 'bi bi-chevron-down'"></i>
          </div>
          
          <transition name="submenu">
            <div v-show="getNavigationItem('bilan').isOpen" class="submenu">
              <div 
                class="submenu-item"
                :class="{ active: currentRoute === '/balance' }"
                @click="navigateTo({ route: '/balance', name: 'Bilan' })"
              >
                <i class="bi bi-building"></i>
                <span>Actif</span>
              </div>
               <div 
                class="submenu-item"
                :class="{ active: currentRoute === '/balance' }"
                @click="navigateTo({ route: '/balance', name: 'Bilan' })"
              >
                <i class="bi bi-bank"></i>
                <span>Passif</span>
              </div>
            </div>
          </transition>
        </div>     
      </div>

      <!-- Section Utilitaires -->
      <div class="nav-group">
        <div class="nav-group-title">Utilitaires</div>
        
        <div 
          class="nav-item"
          :class="{ active: currentRoute === '/import' }"
          @click="navigateTo({ route: '/import', name: 'Import des données' })"
        >
          <i class="bi bi-folder2-open"></i>
          <span>Import des données</span>
        </div>
      </div>
    </nav>

    <!-- Footer avec configuration -->
    <div class="sidebar-footer">
      <div class="nav-separator"></div>
      <div 
        class="nav-item" 
        :class="{ active: currentRoute === '/configuration' }"
        @click="navigateTo({ route: '/configuration', name: 'Configuration' })"
      >
        <i class="bi bi-gear"></i>
        <span>Paramètres</span>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Sidebar',
  props: {
    currentRoute: {
      type: String,
      default: ''
    }
  },
  data() {
    return {
      navigationItems: {
        journaux: {
          name: 'Journal',
          route: '/journal',
          icon: 'bi bi-journal-text',
          children: [
            { name: 'Tous les journaux', route: '/journal', icon: 'bi bi-list-ul' },
            { name: 'Types de journaux', route: '/type-journal', icon: 'bi bi-tags' },
            { name: 'Nouveau journal', route: '/nouveau-journal', icon: 'bi bi-plus-circle' }
          ],
          isOpen: false
        },
        ecritures: {
          name: 'Écriture',
          route: '/ecriture',
          icon: 'bi bi-pencil-square',
          children: [
            { name: 'Toutes les écritures', route: '/ecriture', icon: 'bi bi-list-check' },
            { name: 'Saisie écriture', route: '/ecriture', icon: 'bi bi-pencil' },
            { name: 'Validation', route: '/validation-ecritures', icon: 'bi bi-check-circle' }
          ],
          isOpen: false
        },
        'grand-livre': {
          name : 'Grand Livres',
          route : '/grand-livre',
          icon : 'bi bi-journal-text',
          children: [
            {name: 'Tous les grand livres', route: '/liste-grand-livre', icon: 'bi bi-list-ul' }
          ],
          isOpen: false
        },
        'plan-comptable': {
          name: 'Plan Comptable',
          route: '/plan-comptable',
          icon: 'bi bi-diagram-3',
          children: [
            { name: 'Classes', route: '/classe', icon: 'bi bi-1-circle' },
            { name: 'Rubriques', route: '/rubrique', icon: 'bi bi-2-circle' },
            { name: 'Comptes', route: '/compte', icon: 'bi bi-3-circle' },
            { name: 'Sous-comptes', route: '/souscompte', icon: 'bi bi-4-circle' }
          ],
          isOpen: false
        },
        'balance': {
          name: 'Balance',
          route: '/balance',
          icon: 'bi bi-wallet2',
          children: [
            { name: 'Balance', route: '/balance', icon: 'bi bi-arrow-left-right' }
          ],
          isOpen: false
        },
        'compte_resultat': {
          name: 'Compte de resultat',
          route: '/compte_resultat',
          icon: 'bi bi-wallet2',
          children: [
            { name: 'CR-Nature', route: '/CRNature', icon: 'bi bi-arrow-left-right' },
            { name: 'CR-Fonction', route: '/CR-Fonction', icon: 'bi bi-arrow-left-right' }
          ],
          isOpen: false
        },
        'bilan': {
          name: 'Bilan',
          route: '/balance',
          icon: 'bi bi-wallet2',
          children: [
            { name: 'Bilan', route: '/balance', icon: 'bi bi-arrow-left-right' }
          ],
          isOpen: false
        },
        analytique: {
          name: 'Analytique',
          route: '/analytique',
          icon: 'bi bi-graph-up',
          children: [
            { name: 'Centres de coût', route: '/centres-cout', icon: 'bi bi-pie-chart' },
            { name: 'Répartition', route: '/repartition-analytique', icon: 'bi bi-arrow-repeat' }
          ],
          isOpen: false
        },
        referentiels: {
          name: 'Référentiels',
          route: '/referentiels',
          icon: 'bi bi-book',
          children: [
            { name: 'Devises', route: '/devise', icon: 'bi bi-currency-exchange' },
            { name: 'Modes de paiement', route: '/paiement-mode', icon: 'bi bi-credit-card' },
            { name: 'Tiers', route: '/tiers', icon: 'bi bi-people' }
          ],
          isOpen: false
        }
      }
    }
  },
  watch: {
    currentRoute(newRoute) {
      // Ouvrir automatiquement le sous-menu si la route actuelle correspond à un enfant
      Object.values(this.navigationItems).forEach(item => {
        if (item.children) {
          const hasActiveChild = item.children.some(child => child.route === newRoute);
          if (hasActiveChild) {
            item.isOpen = true;
          }
        }
      });
    }
  },
  mounted() {
    // Ouvrir les sous-menus au chargement si la route actuelle correspond
    Object.values(this.navigationItems).forEach(item => {
      if (item.children) {
        item.isOpen = item.children.some(child => child.route === this.currentRoute);
      }
    });
  },
  methods: {
    navigateTo(item) {
      this.$emit('navigation-change', item);
      this.$router.push(item.route);
    },
    
    toggleSubMenu(item) {
      item.isOpen = !item.isOpen;
    },
    
    getNavigationItem(key) {
      return this.navigationItems[key];
    },
    
    isItemActive(item) {
      if (item.route === this.currentRoute) return true;
      if (item.children) {
        return item.children.some(child => child.route === this.currentRoute);
      }
      return false;
    }
  }
}
</script>

<style scoped>
.sidebar {
  display: flex;
  width: 280px;
  height: 100vh;
  padding: 24px 0;
  flex-direction: column;
  background: linear-gradient(180deg, #142c6c 0%, #051442 100%);
  color: white;
  font-family: 'Stara', sans-serif;
  font-size: 12px;
  position: fixed;
  left: 0;
  top: 0;
  bottom: 50px;
  z-index: 1000;
  overflow-y: auto;
  box-shadow: 4px 0 20px rgba(0, 0, 0, 0.1);
  
}

.sidebar-header {
  padding: 0 24px 24px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  margin-bottom: 24px;
}

.logo {
  display: flex;
  align-items: center;
  gap: 12px;
}

.logo-icon {
  width: 48px;
  height: 48px;
  background: white;
  color: #1e40af;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  font-weight: bold;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.logo-text {
  display: flex;
  flex-direction: column;
}

.logo-main {
  font-size: 20px;
  font-weight: bold;
  color: white;
  line-height: 1;
}

.logo-sub {
  font-size: 14px;
  color: rgba(255, 255, 255, 0.7);
  line-height: 1;
  margin-top: 2px;
}

.sidebar-nav {
  flex: 1;
  padding: 0 16px;
  display: flex;
  flex-direction: column;
  gap: 32px;
}

.nav-group {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.nav-group-title {
  font-size: 11px;
  font-weight: 600;
  color: rgba(255, 255, 255, 0.5);
  text-transform: uppercase;
  letter-spacing: 1px;
  padding: 0 12px 8px;
  margin-bottom: 8px;
}

.nav-item {
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-size: 14px;
  font-weight: 500;
  overflow: hidden;
  margin-bottom: 2px;
}

.nav-item:not(.has-children) {
  padding: 14px 16px;
  display: flex;
  align-items: center;
  gap: 12px;
}

.nav-item:not(.has-children):hover {
  background: rgba(255, 255, 255, 0.08);
  transform: translateX(4px);
}

.nav-item:not(.has-children).active {
  background: rgba(255, 255, 255, 0.15);
  border-left: 3px solid #60a5fa;
  box-shadow: 0 2px 8px rgba(96, 165, 250, 0.2);
}

.nav-item.has-children {
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(255, 255, 255, 0.05);
}

.nav-item.has-children.children-open {
  background: rgba(255, 255, 255, 0.06);
  border-color: rgba(255, 255, 255, 0.1);
}

.nav-main {
  display: flex;
  align-items: center;
  padding: 14px 16px;
  gap: 12px;
  transition: all 0.3s ease;
}

.nav-item.has-children:hover .nav-main {
  background: rgba(255, 255, 255, 0.08);
}

.nav-item.has-children.active .nav-main {
  background: rgba(255, 255, 255, 0.12);
  border-left: 3px solid #60a5fa;
}

.chevron {
  margin-left: auto;
  font-size: 12px;
  transition: transform 0.3s ease;
  opacity: 0.6;
}

.nav-item.children-open .chevron {
  transform: rotate(180deg);
}

/* Sous-menu */
.submenu {
  background: rgba(0, 0, 0, 0.15);
  backdrop-filter: blur(10px);
  border-radius: 0 0 8px 8px;
  overflow: hidden;
  margin-top: 2px;
}

.submenu-item {
  display: flex;
  align-items: center;
  padding: 12px 16px 12px 48px;
  gap: 12px;
  font-size: 13px;
  transition: all 0.3s ease;
  color: rgba(255, 255, 255, 0.85);
  position: relative;
}

.submenu-item::before {
  content: '';
  position: absolute;
  left: 24px;
  width: 6px;
  height: 1px;
  background: rgba(255, 255, 255, 0.3);
}

.submenu-item:hover {
  background: rgba(255, 255, 255, 0.08);
  color: white;
  transform: translateX(4px);
}

.submenu-item.active {
  background: rgba(96, 165, 250, 0.15);
  color: #93c5fd;
  border-left: 2px solid #60a5fa;
}

.submenu-item.active::before {
  background: #60a5fa;
  width: 8px;
}

.submenu-item i {
  font-size: 12px;
  opacity: 0.8;
  width: 16px;
  display: flex;
  justify-content: center;
}

.submenu-item.active i {
  opacity: 1;
  color: #93c5fd;
}

/* Animations pour le sous-menu */
.submenu-enter-active,
.submenu-leave-active {
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
  max-height: 300px;
}

.submenu-enter-from,
.submenu-leave-to {
  opacity: 0;
  max-height: 0;
  transform: translateY(-8px);
}

.submenu-enter-to,
.submenu-leave-from {
  opacity: 1;
  max-height: 300px;
  transform: translateY(0);
}

/* Icônes */
.nav-item i {
  width: 18px;
  height: 18px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 16px;
  opacity: 0.9;
}

.nav-item.active i,
.nav-item:hover i {
  opacity: 1;
}

.sidebar-footer {
  padding: 20px 16px;
  border-top: 1px solid rgba(255, 255, 255, 0.1);
}

.nav-separator {
  height: 1px;
  background: rgba(255, 255, 255, 0.1);
  margin-bottom: 16px;
}

/* Responsive */
@media (max-width: 768px) {
  .sidebar {
    width: 260px;
    transform: translateX(-100%);
    transition: transform 0.3s ease;
  }
  
  .sidebar.open {
    transform: translateX(0);
  }
  
  .nav-group {
    gap: 24px;
  }
  
  .submenu-item {
    padding: 10px 16px 10px 44px;
    font-size: 12px;
  }
}

/* Scrollbar personnalisée */
.sidebar::-webkit-scrollbar {
  width: 6px;
}

.sidebar::-webkit-scrollbar-track {
  background: rgba(255, 255, 255, 0.05);
  border-radius: 3px;
}

.sidebar::-webkit-scrollbar-thumb {
  background: rgba(255, 255, 255, 0.2);
  border-radius: 3px;
}

.sidebar::-webkit-scrollbar-thumb:hover {
  background: rgba(255, 255, 255, 0.3);
}

/* États de focus pour l'accessibilité */
.nav-item:focus-visible,
.submenu-item:focus-visible {
  outline: 2px solid #60a5fa;
  outline-offset: 2px;
}
</style>