<template>
  <div class="stats-globales">
    <div class="stats-header">
      <h3>Statistiques Globales {{ anneeTitle }}</h3>
      <div class="stats-period" v-if="trimestre">
        {{ getTrimestreName(trimestre) }}
      </div>
    </div>
    
    <div class="stats-grid">
      <div class="stat-card global-stat">
        <div class="stat-icon">
          <i class="bi bi-graph-up"></i>
        </div>
        <div class="stat-content">
          <div class="stat-value">{{ formatMontant(stats.totalVentile) }}</div>
          <div class="stat-label">Total Ventilé</div>
        </div>
      </div>

      <div class="stat-card global-stat">
        <div class="stat-icon">
          <i class="bi bi-currency-euro"></i>
        </div>
        <div class="stat-content">
          <div class="stat-value">{{ formatMontant(stats.totalBrut) }}</div>
          <div class="stat-label">Total Brut</div>
        </div>
      </div>

      <div class="stat-card global-stat">
        <div class="stat-icon">
          <i class="bi bi-building"></i>
        </div>
        <div class="stat-content">
          <div class="stat-value">{{ stats.nombreCentres }}</div>
          <div class="stat-label">Centres Actifs</div>
        </div>
      </div>

      <div class="stat-card global-stat">
        <div class="stat-icon">
          <i class="bi bi-calendar-week"></i>
        </div>
        <div class="stat-content">
          <div class="stat-value">{{ stats.nombrePeriodes }}</div>
          <div class="stat-label">Périodes</div>
        </div>
      </div>
    </div>

    <!-- Indicateur de chargement -->
    <div v-if="loading" class="stats-loading">
      <div class="loading-spinner"></div>
      <span>Chargement des statistiques...</span>
    </div>

    <!-- Message d'erreur -->
    <div v-if="error" class="stats-error">
      <i class="bi bi-exclamation-triangle"></i>
      <span>{{ error }}</span>
    </div>
  </div>
</template>

<script setup>
import { ref, watch, computed } from 'vue';

const props = defineProps({
  year: {
    type: String,
    default: new Date().getFullYear().toString()
  },
  trimestre: {
    type: String,
    default: ''
  },
  loading: {
    type: Boolean,
    default: false
  },
  error: {
    type: String,
    default: ''
  },
  stats: {
    type: Object,
    default: () => ({
      totalVentile: 0,
      totalBrut: 0,
      nombreCentres: 0,
      nombrePeriodes: 0
    })
  }
});

const anneeTitle = computed(() => {
  return props.year ? `- ${props.year}` : '';
});

const formatMontant = (montant) => {
  return new Intl.NumberFormat('fr-FR', { 
    style: 'currency', 
    currency: 'EUR',
    maximumFractionDigits: 0
  }).format(parseFloat(montant) || 0);
};

const getTrimestreName = (trimestreNumber) => {
  const trimestres = [
    '1er Trimestre',
    '2ème Trimestre', 
    '3ème Trimestre',
    '4ème Trimestre'
  ];
  return trimestres[parseInt(trimestreNumber) - 1] || `Trimestre ${trimestreNumber}`;
};
</script>

<style scoped>
.stats-globales {
  background: white;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  margin-bottom: 24px;
  border: 1px solid #e9ecef;
}

.stats-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  padding-bottom: 16px;
  border-bottom: 2px solid #f8f9fa;
}

.stats-header h3 {
  margin: 0;
  font-family: 'stara', sans-serif;
  font-size: 18px;
  font-weight: 600;
  color: #2c3e50;
}

.stats-period {
  background: #017AFF;
  color: white;
  padding: 6px 12px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 500;
  font-family: 'stara', sans-serif;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 16px;
}

.global-stat {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 20px;
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
  border-radius: 8px;
  border-left: 4px solid #017AFF;
  transition: all 0.3s ease;
}

.global-stat:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.stat-icon {
  width: 48px;
  height: 48px;
  background: #017AFF;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 20px;
}

.stat-content {
  flex: 1;
}

.stat-value {
  font-size: 20px;
  font-weight: 700;
  color: #2c3e50;
  font-family: 'arial', sans-serif;
  margin-bottom: 4px;
}

.stat-label {
  font-size: 12px;
  color: #6c757d;
  font-weight: 500;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  font-family: 'stara', sans-serif;
}

.stats-loading {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  padding: 20px;
  background: #f8f9fa;
  border-radius: 8px;
  color: #6c757d;
  font-family: 'stara', sans-serif;
}

.loading-spinner {
  width: 20px;
  height: 20px;
  border: 2px solid #e9ecef;
  border-top: 2px solid #017AFF;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

.stats-error {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  padding: 20px;
  background: #ffe6e6;
  border-radius: 8px;
  color: #dc3545;
  font-family: 'stara', sans-serif;
  border: 1px solid #f5c6cb;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* Responsive */
@media (max-width: 768px) {
  .stats-globales {
    padding: 16px;
  }
  
  .stats-grid {
    grid-template-columns: 1fr;
    gap: 12px;
  }
  
  .global-stat {
    padding: 16px;
  }
  
  .stat-icon {
    width: 40px;
    height: 40px;
    font-size: 18px;
  }
  
  .stat-value {
    font-size: 18px;
  }
  
  .stats-header {
    flex-direction: column;
    gap: 12px;
    align-items: flex-start;
  }
}

@media (max-width: 480px) {
  .stats-globales {
    padding: 12px;
  }
  
  .global-stat {
    flex-direction: column;
    text-align: center;
    gap: 12px;
  }
  
  .stat-icon {
    width: 36px;
    height: 36px;
    font-size: 16px;
  }
}
</style>