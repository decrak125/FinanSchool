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
// État des composants sélectionnés
const selectedComponents = ref({
  mensuelle: true,
  trimestrielle: true,
  annuelle: true,
  evolution12mois: true,
  coutProfit: true
});

// État du menu déroulant
const isDropdownOpen = ref(false);

// Options disponibles
const componentOptions = [
  { id: 'mensuelle', label: 'Analyse Mensuelle', icon: '' },
  { id: 'trimestrielle', label: 'Analyse Trimestrielle', icon: '' },
  { id: 'annuelle', label: 'Comparaison Annuelle', icon: '' },
  { id: 'evolution12mois', label: 'Évolution 12 Mois', icon: '' },
  { id: 'coutProfit', label: 'Coûts vs Profits', icon: '' }
];

// Basculer la sélection d'un composant
const toggleComponent = (componentId) => {
  selectedComponents.value[componentId] = !selectedComponents.value[componentId];
};

// Sélectionner/désélectionner tous
const toggleAllComponents = (selectAll) => {
  Object.keys(selectedComponents.value).forEach(key => {
    selectedComponents.value[key] = selectAll;
  });
};

// Ouvrir/fermer le dropdown
const toggleDropdown = () => {
  isDropdownOpen.value = !isDropdownOpen.value;
};

// Appliquer la sélection et fermer le dropdown
const applySelection = () => {
  isDropdownOpen.value = false;
};

// Fermer le dropdown en cliquant à l'extérieur
const closeDropdown = (event) => {
  if (!event.target.closest('.dropdown-container')) {
    isDropdownOpen.value = false;
  }
};

// Nombre de composants sélectionnés
const selectedCount = computed(() => {
  return Object.values(selectedComponents.value).filter(Boolean).length;
});

// Gestion des clics en dehors du dropdown
onMounted(() => {
  document.addEventListener('click', closeDropdown);
});

onUnmounted(() => {
  document.removeEventListener('click', closeDropdown);
});
</script>

<template>
  <PageAnalyse :menu="'Analyse Comparative'" :sousmenu="'Données temporelles'">
    <div class="main">
      <!-- Sélecteur de composants avec menu déroulant -->
      <div class="components-selector">
        <div class="selector-header">
          <Texte :type="'thin-dark'" :texte="'Sections à afficher'" />
          <!-- Menu déroulant -->
          <div class="dropdown-container">
            <button 
              class="dropdown-toggle"
              @click="toggleDropdown"
            >
              <span class="selected-count">{{ selectedCount }}/{{ componentOptions.length }} sélectionnés</span>
              <i class="bi bi-chevron-down" :class="{ 'open': isDropdownOpen }"></i>
            </button>
            
            <transition name="dropdown">
              <div v-if="isDropdownOpen" class="dropdown-menu">
                <!-- <div class="dropdown-header">
                  <Texte :type="'thin-dark'" :texte="'Sélectionner les sections'" />
                  
                </div> -->
                
                <div class="dropdown-options">
                  <div 
                    v-for="option in componentOptions" 
                    :key="option.id"
                    class="dropdown-option"
                    :class="{ selected: selectedComponents[option.id] }"
                    @click="toggleComponent(option.id)"
                  >
                    <div class="option-checkbox">
                      <input 
                        type="checkbox" 
                        :checked="selectedComponents[option.id]"
                        @click.stop="toggleComponent(option.id)"
                      />
                    </div>
                    <div class="option-icon">{{ option.icon }}</div>
                    <div class="option-label">{{ option.label }}</div>
                  </div>
                </div>
                
                <!-- <div class="dropdown-footer">
                  <div class="dropdown-actions">
                    <button @click="toggleAllComponents(true)" class="btn-select-all">
                      Tout
                    </button>
                    <button @click="toggleAllComponents(false)" class="btn-deselect-all">
                      Aucun
                    </button>
                  </div>
                </div> -->
              </div>
            </transition>
          </div>
        </div>
      </div>

      <!-- Composants conditionnels -->
      <div class="components-container">
        <AnalyseMensuelle v-if="selectedComponents.mensuelle" />
        <AnalyseTrimestrielle v-if="selectedComponents.trimestrielle" />
        <ComparaisonAnnuelle v-if="selectedComponents.annuelle" />
        <Evolution12mois v-if="selectedComponents.evolution12mois" />
        <ComparaisonCoutProfit v-if="selectedComponents.coutProfit" />
      </div>

      <!-- Message si aucun composant sélectionné -->
      <div v-if="selectedCount === 0" class="no-components-selected">
        <div class="empty-state">
          <span class="empty-icon">📊</span>
          <h3>Aucune section sélectionnée</h3>
          <p>Veuillez sélectionner au moins une section à afficher dans le menu déroulant ci-dessus.</p>
          <button @click="toggleAllComponents(true)" class="btn-primary">
            Afficher toutes les sections
          </button>
        </div>
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
  // padding: 1.5rem;
  margin-bottom: 2rem;
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
  align-items: space-between;
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


.selected-count {
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

.dropdown-header {
  background-color: #ffffff;
  display: flex;
  justify-content: center;
  align-items: center;
  // padding: 8px 16px;
  border-bottom: 1px solid #eee;
}

.dropdown-title {
  font-weight: 600;
  font-size: 14px;
  color: #333;
}

.dropdown-actions {
  display: flex;
  gap: 8px;
}

.btn-select-all,
.btn-deselect-all {
  padding: 4px 8px;
  font-size: 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  background: white;
  cursor: pointer;
  transition: all 0.2s ease;
}

.btn-select-all:hover {
  background: $primary;
  color: white;
  border-color: $primary;
}

.btn-deselect-all:hover {
  background: #dc3545;
  color: white;
  border-color: #dc3545;
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
  // gap: 12px;
  padding: 10px 16px;
  cursor: pointer;
  // transition: background-color 0.2s ease;
}

.dropdown-option:hover {
  background: #f8f9fa;
}


.option-checkbox {
  display: flex;
  align-items: center;
}

.option-checkbox input[type="checkbox"] {
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
}

.dropdown-footer {
  padding: 12px 16px;
  border-top: 1px solid #eee;
  text-align: right;
}

.btn-apply {
  padding: 8px 16px;
  background: $primary;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  transition: background-color 0.2s ease;
}

.btn-apply:hover {
  background: #0163cc;
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

.no-components-selected {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 400px;
  background: white;
  border-radius: 12px;
  border: 2px dashed #e5e7eb;
  @include glass();
}

.empty-state {
  text-align: center;
  padding: 3rem;
}

.empty-icon {
  font-size: 4rem;
  display: block;
  margin-bottom: 1rem;
}

.empty-state h3 {
  color: #374151;
  margin-bottom: 0.5rem;
  font-size: 1.5rem;
}

.empty-state p {
  color: #6b7280;
  margin-bottom: 1.5rem;
}

.btn-primary {
  padding: 0.75rem 1.5rem;
  background: $primary;
  color: white;
  border: none;
  border-radius: 6px;
  font-weight: 500;
  cursor: pointer;
  transition: background 0.2s ease;
}

.btn-primary:hover {
  background: #0163cc;
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
  
  .empty-state {
    padding: 2rem 1rem;
  }
  
  .empty-icon {
    font-size: 3rem;
  }
}

@media (max-width: 480px) {
  .main {
    padding: 0 12px;
  }
  
  .components-selector {
    padding: 1rem;
  }
  
  .dropdown-header {
    flex-direction: column;
    gap: 10px;
    align-items: flex-start;
  }
  
  .dropdown-actions {
    align-self: flex-end;
  }
}
</style>