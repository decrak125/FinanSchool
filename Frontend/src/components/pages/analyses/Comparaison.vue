<script setup>
import { ref, onMounted, computed, onUnmounted } from "vue";
import { useComparaison } from "@/composables/useComparaison";
import PageAnalyse from '@/components/template/Page-analyse.vue';
import ContentHeader from "@/components/molecules/Analyse/Content-header.vue";
import AnalyseMensuelle from "./AnalyseMensuelle.vue";
import AnalyseTrimestrielle from "./AnalyseTrimestrielle.vue";
import ComparaisonAnnuelle from "./ComparaisonAnnuelle.vue";
import Evolution12mois from "./Evolution12Mois.vue";
import ComparaisonCoutProfit from "./ComparaisonCoutProfit.vue";
import Texte from "@/components/atoms/Texte.vue";

// État du composant sélectionné (au lieu d'un objet avec plusieurs booléens)
const selectedComponent = ref('coutProfit'); // Valeur par défaut

// État du menu déroulant
const isDropdownOpen = ref(false);

// Options disponibles
const componentOptions = [
  { id: 'coutProfit', label: 'Coûts vs Profits', icon: '' },
  { id: 'mensuelle', label: 'Analyse Mensuelle', icon: '' },
  { id: 'trimestrielle', label: 'Analyse Trimestrielle', icon: '' },
  { id: 'annuelle', label: 'Comparaison Annuelle', icon: '' }
];

// Sélectionner un composant (remplace toggleComponent)
const selectComponent = (componentId) => {
  selectedComponent.value = componentId;
  isDropdownOpen.value = false; // Fermer le dropdown après sélection
};

// Ouvrir/fermer le dropdown
const toggleDropdown = () => {
  isDropdownOpen.value = !isDropdownOpen.value;
};

// Fermer le dropdown en cliquant à l'extérieur
const closeDropdown = (event) => {
  if (!event.target.closest('.dropdown-container')) {
    isDropdownOpen.value = false;
  }
};

// Gestion des clics en dehors du dropdown
onMounted(() => {
  document.addEventListener('click', closeDropdown);
});

onUnmounted(() => {
  document.removeEventListener('click', closeDropdown);
});
</script>

<template>
  <PageAnalyse :menu="'Analyse Comparative'" :sousmenu="componentOptions.find(opt => opt.id === selectedComponent)?.label">
    <div class="main">
      <!-- Sélecteur de composant avec menu déroulant -->
      <div class="components-selector">
        <div class="selector-header">
          <Texte :type="'thin-dark'" :texte="'Section à afficher'" />
          <!-- Menu déroulant -->
          <div class="dropdown-container">
            <button class="dropdown-toggle" @click="toggleDropdown">
              <span class="selected-label">
                {{ componentOptions.find(opt => opt.id === selectedComponent)?.label || 'Sélectionner' }}
              </span>
              <i class="bi bi-chevron-down" :class="{ 'open': isDropdownOpen }"></i>
            </button>
            <transition name="dropdown">
              <div v-if="isDropdownOpen" class="dropdown-menu">
                <div class="dropdown-options">
                  <div v-for="option in componentOptions" :key="option.id" 
                       class="dropdown-option"
                       :class="{ selected: selectedComponent === option.id }" 
                       @click="selectComponent(option.id)">
                    <div class="option-radio">
                      <input type="radio" 
                             :checked="selectedComponent === option.id"
                             @click.stop="selectComponent(option.id)" />
                    </div>
                    <div class="option-icon">{{ option.icon }}</div>
                    <div class="option-label">{{ option.label }}</div>
                  </div>
                </div>
              </div>
            </transition>
          </div>
        </div>
      </div>

      <!-- Composants conditionnels -->
      <div class="components-container">
        <ComparaisonCoutProfit v-if="selectedComponent === 'coutProfit'" />
        <AnalyseMensuelle v-if="selectedComponent === 'mensuelle'" />
        <AnalyseTrimestrielle v-if="selectedComponent === 'trimestrielle'" />
        <ComparaisonAnnuelle v-if="selectedComponent === 'annuelle'" />
      </div>
    </div>
  </PageAnalyse>
</template>

<style lang="scss" scoped>
.main {
  @include position-contenus(flex, center, center);
  padding: 0 18px;
  flex-direction: column;
  gap: 10px;
  flex: 1 0 0;
  align-self: stretch;
  animation: appear 0.6s ease-out forwards;
}

.components-selector {
  width: 100%;
  border-radius: $radius-pm;
}

.selector-header {
  display: flex;
  align-items: baseline;
  margin-bottom: 1.5rem;
  flex-wrap: wrap;
  gap: 1rem;
}

/* Styles du menu déroulant */
.dropdown-container {
  position: relative;
  display: inline-block;
}

.dropdown-toggle {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  padding: 12px 16px;
  border: 1px solid #ddd;
  border-radius: $radius-pm;
  cursor: pointer;
  transition: all 0.3s ease;
  min-width: 200px;
  @include glass();
  font-family: 'stara';
}

.selected-label {
  font-size: 14px;
  color: $dark;
  font-weight: 500;
}

.dropdown-arrow {
  font-size: 10px;
  transition: transform 0.3s ease;
  color: $dark;
}

.dropdown-arrow.open {
  transform: rotate(180deg);
}

.dropdown-menu {
  position: absolute;
  top: 100%;
  right: 0;
  background: white;
  border: 1px solid #ddd;
  border-radius: $radius-pm;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  z-index: 1000;
  margin-top: 5px;
  @include glass();
}

.dropdown-options {
  background: #ffffff;
  border-radius: $radius-pm;
  max-height: 300px;
  overflow-y: auto;
  padding: 8px 0;
}

.dropdown-option {
  background-color: transparent;
  font-family: $stara-medium;
  display: flex;
  align-items: center;
  padding: 10px 16px;
  cursor: pointer;
}

.dropdown-option:hover {
  background: #f8f9fa;
}

.option-radio {
  display: flex;
  align-items: center;
}

.option-radio input[type="radio"] {
  width: 16px;
  height: 16px;
  cursor: pointer;
  accent-color: $primary;
}

.option-icon {
  font-size: 12px;
  width: 20px;
  text-align: center;
}

.option-label {
  flex: 1;
  font-size: 12px;
  color: #333;
  font-weight: 500;
  margin-left: 8px;
}

/* Animation pour la sélection */
.dropdown-option.selected {
  background-color: rgba($primary, 0.1);
}

.dropdown-option.selected .option-label {
  color: $primary;
  font-weight: 600;
}

/* Animations */
.dropdown-enter-active,
.dropdown-leave-active {
  transition: all 0.3s ease;
}

.dropdown-enter-from,
.dropdown-leave-to {
  opacity: 0;
  transform: translateY(-10px);
}

.components-container {
  width: 100%;
  display: flex;
  flex-direction: column;
  gap: 2rem;
}

/* Responsive */
@media (max-width: 768px) {
  .selector-header {
    flex-direction: column;
    align-items: stretch;
    gap: 1rem;
  }

  .dropdown-container {
    width: 100%;
  }

  .dropdown-toggle {
    width: 100%;
    justify-content: space-between;
  }

  .dropdown-menu {
    width: 100%;
    right: 0;
    left: 0;
  }
}

@media (max-width: 480px) {
  .main {
    padding: 0 12px;
  }

  .components-selector {
    padding: 1rem;
  }
}
</style>