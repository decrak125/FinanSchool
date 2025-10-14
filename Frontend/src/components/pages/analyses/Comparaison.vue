<script setup>
import { ref, onMounted, computed } from "vue";
import { useComparaison } from "@/composables/useComparaison";
import PageAnalyse from '@/components/template/Page-analyse.vue';
import ContentHeader from "@/components/molecules/Analyse/Content-header.vue";
import AnalyseMensuelle from "./AnalyseMensuelle.vue";
import AnalyseTrimestrielle from "./AnalyseTrimestrielle.vue";
import ComparaisonAnnuelle from "./ComparaisonAnnuelle.vue";
import Evolution12mois from "./Evolution12Mois.vue";
import ComparaisonCoutProfit from "./ComparaisonCoutProfit.vue";

// État des composants sélectionnés
const selectedComponents = ref({
  mensuelle: true,
  trimestrielle: true,
  annuelle: true,
  evolution12mois: true,
  coutProfit: true
});

// Options disponibles
const componentOptions = [
  { id: 'mensuelle', label: 'Analyse Mensuelle', icon: '📅' },
  { id: 'trimestrielle', label: 'Analyse Trimestrielle', icon: '📊' },
  { id: 'annuelle', label: 'Comparaison Annuelle', icon: '📈' },
  { id: 'evolution12mois', label: 'Évolution 12 Mois', icon: '🔄' },
  { id: 'coutProfit', label: 'Coûts vs Profits', icon: '💰' }
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

// Nombre de composants sélectionnés
const selectedCount = computed(() => {
  return Object.values(selectedComponents.value).filter(Boolean).length;
});
</script>

<template>
  <PageAnalyse>
    <div class="main">
      <ContentHeader :menu="'Analyse Comparative'" :sousmenu="'Données temporelles'" />
      
      <!-- Sélecteur de composants -->
      <div class="components-selector">
        <div class="selector-header">
          <h3>📋 Sections à afficher</h3>
          <div class="selector-actions">
            <span class="selected-count">{{ selectedCount }}/{{ componentOptions.length }} sélectionnés</span>
            <button @click="toggleAllComponents(true)" class="btn-select-all">
              Tout sélectionner
            </button>
            <button @click="toggleAllComponents(false)" class="btn-deselect-all">
              Tout désélectionner
            </button>
          </div>
        </div>
        
        <div class="components-grid">
          <div 
            v-for="option in componentOptions" 
            :key="option.id"
            class="component-option"
            :class="{ selected: selectedComponents[option.id] }"
            @click="toggleComponent(option.id)"
          >
            <div class="option-icon">{{ option.icon }}</div>
            <div class="option-label">{{ option.label }}</div>
            <div class="option-checkbox">
              <input 
                type="checkbox" 
                :checked="selectedComponents[option.id]"
                @click.stop="toggleComponent(option.id)"
              />
            </div>
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
          <p>Veuillez sélectionner au moins une section à afficher ci-dessus.</p>
          <button @click="toggleAllComponents(true)" class="btn-primary">
            Afficher toutes les sections
          </button>
        </div>
      </div>
    </div>
  </PageAnalyse>
</template>

<style scoped>
.components-selector {
  background: white;
  border-radius: 12px;
  padding: 1.5rem;
  margin-bottom: 2rem;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  border: 1px solid #e5e7eb;
}

.selector-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
  flex-wrap: wrap;
  gap: 1rem;
}

.selector-header h3 {
  margin: 0;
  color: #1f2937;
  font-size: 1.25rem;
  font-weight: 600;
}

.selector-actions {
  display: flex;
  align-items: center;
  gap: 1rem;
  flex-wrap: wrap;
}

.selected-count {
  color: #6b7280;
  font-size: 0.875rem;
  font-weight: 500;
}

.btn-select-all,
.btn-deselect-all {
  padding: 0.5rem 1rem;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  background: white;
  color: #374151;
  font-size: 0.875rem;
  cursor: pointer;
  transition: all 0.2s ease;
}

.btn-select-all:hover {
  background: #f3f4f6;
  border-color: #9ca3af;
}

.btn-deselect-all:hover {
  background: #fef2f2;
  border-color: #fca5a5;
  color: #dc2626;
}

.components-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
}

.component-option {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 1rem;
  border: 2px solid #e5e7eb;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
  background: white;
}

.component-option:hover {
  border-color: #9ca3af;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.component-option.selected {
  border-color: #017AFF;
  background: #f0f7ff;
  box-shadow: 0 4px 12px rgba(1, 122, 255, 0.15);
}

.option-icon {
  font-size: 1.5rem;
  flex-shrink: 0;
}

.option-label {
  flex: 1;
  font-weight: 500;
  color: #374151;
  font-size: 0.9rem;
}

.option-checkbox input[type="checkbox"] {
  width: 18px;
  height: 18px;
  border-radius: 4px;
  border: 2px solid #d1d5db;
  cursor: pointer;
  accent-color: #017AFF;
}

.component-option.selected .option-checkbox input[type="checkbox"] {
  background-color: #017AFF;
  border-color: #017AFF;
}

.components-container {
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
  background: #017AFF;
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
  }
  
  .selector-actions {
    justify-content: space-between;
  }
  
  .components-grid {
    grid-template-columns: 1fr;
  }
  
  .component-option {
    padding: 0.75rem;
  }
  
  .empty-state {
    padding: 2rem 1rem;
  }
  
  .empty-icon {
    font-size: 3rem;
  }
}
</style>