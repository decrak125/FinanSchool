<template>
  <div>
    <div v-if="loading" class="loading">Chargement...</div>
    <div v-else-if="error" class="error">{{ error }}</div>
    <div v-else-if="series.length === 0" class="no-data">
      Aucune donnée disponible pour les filtres sélectionnés
    </div>
    <div v-else class="evolution-chart-wrapper">
      <div class="chart-container">
        <div class="graphic-wrapper">
          <apexchart
            type="area"
            :height="height"
            :options="chartOptions"
            :series="series"
          ></apexchart>
        </div>
        <div class="voir" @click="showDetails = !showDetails">
          <i class="bi bi-eye"></i>
          <p v-if="!showDetails">Voir les détails</p>
          <p v-if="showDetails">Masquer les détails</p>
        </div>
      </div>
      
      <transition name="fade">
        <div class="legend-container" v-if="showDetails">
          <div class="legend-wrapper">
            <!-- Statistiques globales -->
            <div class="stats-summary">
              <div class="stat-item">
                <span class="stat-label">Période :</span>
                <span class="stat-value">{{ periodRange }}</span>
              </div>
              <div class="stat-item">
                <span class="stat-label">Centres :</span>
                <span class="stat-value">{{ centresCount }}</span>
              </div>
              <div class="stat-item">
                <span class="stat-label">Évolution moyenne :</span>
                <span class="stat-value" :class="getEvolutionClass(averageEvolution)">
                  {{ formatEvolution(averageEvolution) }}
                </span>
              </div>
            </div>

            <!-- Légende des centres -->
            <div class="legend-year-group">
              <div class="legend-year-title">Performance des Centres</div>
              <div class="legend-items">
                <div v-for="(centre, index) in centresList" :key="index" class="legend-item">
                  <div class="legend-color" :style="{ backgroundColor: getColor(index) }"></div>
                  <div class="legend-content">
                    <div class="legend-label">{{ centre.name }}</div>
                    <div class="legend-values">
                      <span class="legend-value">{{ formatMontant(centre.total) }}</span>
                      <span class="legend-percentage" :class="getEvolutionClass(centre.evolution)">
                        {{ formatEvolution(centre.evolution) }}
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </transition>
    </div>
  </div>
</template>

<script setup>
import { ref, watch, computed } from 'vue';

const props = defineProps({
  chartData: {
    type: Array,
    default: () => []
  },
  loading: {
    type: Boolean,
    default: false
  },
  error: {
    type: String,
    default: ''
  },
  height: {
    type: Number,
    default: 400
  },
  colors: {
    type: Array,
    default: () => [
      '#017AFF', '#F34971', '#00D4AA', '#F5C900', 
      '#6C47FF', '#39C0C8', '#FF6B8B', '#9C27B0'
    ]
  }
});

const showDetails = ref(true);
const series = ref([]);

// Computed properties
const periodRange = computed(() => {
  if (props.chartData.length === 0) return '';
  
  const dates = props.chartData.map(item => new Date(item.mois));
  const minDate = new Date(Math.min(...dates));
  const maxDate = new Date(Math.max(...dates));
  
  return `${minDate.toLocaleDateString('fr-FR', { month: 'short', year: 'numeric' })} - ${maxDate.toLocaleDateString('fr-FR', { month: 'short', year: 'numeric' })}`;
});

const centresList = computed(() => {
  const centres = {};
  
  props.chartData.forEach(item => {
    if (!centres[item.centre]) {
      centres[item.centre] = {
        name: item.centre,
        data: [],
        total: 0,
        evolution: 0,
        premierPoint: null,
        dernierPoint: null
      };
    }
    
    const montant = parseFloat(item.montant_brut) || parseFloat(item.montant_ventile) || 0;
    const date = new Date(item.mois);
    const pointData = { date, montant };
    
    centres[item.centre].data.push({
      x: date.getTime(),
      y: montant,
      ...pointData
    });
    centres[item.centre].total += montant;
    
    // Premier point (le plus ancien)
    if (!centres[item.centre].premierPoint || date < centres[item.centre].premierPoint.date) {
      centres[item.centre].premierPoint = pointData;
    }
    
    // Dernier point (le plus récent)
    if (!centres[item.centre].dernierPoint || date > centres[item.centre].dernierPoint.date) {
      centres[item.centre].dernierPoint = pointData;
    }
  });

  // Calculer l'évolution entre premier et dernier point
  Object.values(centres).forEach(centre => {
    centre.data.sort((a, b) => a.x - b.x);
    
    if (centre.premierPoint && centre.dernierPoint && centre.premierPoint.montant > 0) {
      centre.evolution = ((centre.dernierPoint.montant - centre.premierPoint.montant) / centre.premierPoint.montant) * 100;
      
      console.log(`📈 ${centre.name}: ` +
        `${centre.premierPoint.date.toLocaleDateString('fr-FR')} = ${centre.premierPoint.montant.toLocaleString()}€ → ` +
        `${centre.dernierPoint.date.toLocaleDateString('fr-FR')} = ${centre.dernierPoint.montant.toLocaleString()}€ → ` +
        `${centre.evolution.toFixed(1)}%`);
    } else {
      centre.evolution = null;
    }
  });

  return Object.values(centres).sort((a, b) => b.total - a.total);
});
const centresCount = computed(() => {
  return centresList.value.length;
});

const averageEvolution = computed(() => {
  const evolutions = centresList.value
    .filter(centre => !isNaN(centre.evolution) && Math.abs(centre.evolution) < 1000) // Filtrer les valeurs aberrantes
    .map(centre => centre.evolution);
  
  if (evolutions.length === 0) return 0;
  
  const totalEvolution = evolutions.reduce((sum, evolution) => sum + evolution, 0);
  return totalEvolution / evolutions.length;
});

const chartOptions = computed(() => {
  return {
    chart: {
      type: 'area',
      height: props.height,
      toolbar: {
        show: true,
        tools: {
          download: true,
          selection: false,
          zoom: false,
          zoomin: false,
          zoomout: false,
          pan: false,
          reset: true
        }
      },
      animations: {
        enabled: true,
        easing: 'easeinout',
        speed: 800
      },
      zoom: {
        enabled: false
      },
      fontFamily: 'stara'
    },
    colors: props.colors,
    stroke: {
      curve: 'smooth',
      width: 2,
      lineCap: 'round'
    },
    fill: {
      type: 'gradient',
      gradient: {
        shadeIntensity: 0.3,
        opacityFrom: 0.6,
        opacityTo: 0.1,
        stops: [0, 90, 100]
      }
    },
    title: {
      text: 'Évolution des Montants sur 12 Mois',
      align: 'center',
      style: {
        fontFamily: 'stara',
        fontSize: '18px',
        fontWeight: 'bold',
        color: '#2c3e50'
      }
    },
    xaxis: {
      type: 'datetime',
      labels: {
        style: {
          fontFamily: 'stara',
          colors: '#6b7280',
          fontSize: '11px'
        },
        formatter: function(value) {
          return new Date(value).toLocaleDateString('fr-FR', { 
            month: 'short',
            year: '2-digit'
          });
        }
      },
      axisBorder: {
        show: false
      },
      axisTicks: {
        show: false
      }
    },
    yaxis: {
      title: {
        text: 'Montant (€)',
        style: {
          fontFamily: 'stara',
          fontWeight: '600',
          color: '#2c3e50',
          fontSize: '12px'
        }
      },
      labels: {
        style: {
          fontFamily: 'stara',
          colors: '#6b7280',
          fontSize: '11px'
        },
        formatter: function(value) {
          if (value >= 1000000) {
            return '€' + (value / 1000000).toFixed(1) + 'M';
          } else if (value >= 1000) {
            return '€' + (value / 1000).toFixed(0) + 'K';
          }
          return '€' + value;
        }
      }
    },
    tooltip: {
      enabled: true,
      theme: 'light',
      style: {
        fontFamily: 'stara',
        fontSize: '12px'
      },
      x: {
        formatter: function(value) {
          return new Date(value).toLocaleDateString('fr-FR', { 
            month: 'long',
            year: 'numeric'
          });
        }
      },
      y: {
        formatter: function(value) {
          return new Intl.NumberFormat('fr-FR', { 
            style: 'currency', 
            currency: 'EUR',
            maximumFractionDigits: 0
          }).format(value);
        }
      }
    },
    legend: {
      show: false
    },
    markers: {
      size: 0,
      hover: {
        size: 5
      }
    },
    grid: {
      borderColor: '#f1f3f4',
      strokeDashArray: 3,
      padding: {
        top: 0,
        right: 0,
        bottom: 0,
        left: 0
      }
    },
    dataLabels: {
      enabled: false
    },
    responsive: [{
      breakpoint: 768,
      options: {
        chart: {
          height: 350
        },
        title: {
          style: {
            fontSize: '16px'
          }
        }
      }
    }, {
      breakpoint: 480,
      options: {
        chart: {
          height: 300
        },
        title: {
          style: {
            fontSize: '14px'
          }
        },
        xaxis: {
          labels: {
            formatter: function(value) {
              return new Date(value).toLocaleDateString('fr-FR', { 
                month: 'short'
              });
            }
          }
        }
      }
    }]
  };
});

// Transformer les données pour ApexCharts
const transformData = (data) => {
  console.log('🔹 Transformation des données pour area chart:', data);
  
  if (!data || data.length === 0) {
    series.value = [];
    return;
  }

  // Grouper les données par centre
  const centres = {};
  
  data.forEach(item => {
    const centreName = item.centre;
    const date = new Date(item.mois);
    const montant = parseFloat(item.montant_brut) || parseFloat(item.montant_ventile) || 0;
    
    if (!centres[centreName]) {
      centres[centreName] = [];
    }
    
    centres[centreName].push({
      x: date.getTime(),
      y: montant
    });
  });

  // Convertir en format ApexCharts et trier par date
  series.value = Object.keys(centres).map(centre => ({
    name: centre,
    data: centres[centre].sort((a, b) => a.x - b.x)
  }));

  console.log('🔹 Séries area chart:', series.value);
};

// Méthodes utilitaires
const getColor = (index) => {
  return props.colors[index % props.colors.length];
};

const formatMontant = (montant) => {
  return new Intl.NumberFormat('fr-FR', { 
    style: 'currency', 
    currency: 'EUR',
    maximumFractionDigits: 0 
  }).format(parseFloat(montant) || 0);
};

const formatEvolution = (evolution) => {
  if (evolution === undefined || evolution === null || isNaN(evolution)) {
    return 'N/A';
  }
  if (Math.abs(evolution) < 0.1) return '→ Stable';
  const sign = evolution > 0 ? '↗' : '↘';
  return `${sign} ${Math.abs(evolution).toFixed(1)}%`;
};

const getEvolutionClass = (evolution) => {
  if (evolution === undefined || evolution === null || isNaN(evolution)) {
    return 'evolution-stable';
  }
  if (evolution > 5) return 'evolution-positive';
  if (evolution < -5) return 'evolution-negative';
  return 'evolution-stable';
};

// Surveiller les changements de données
watch(() => props.chartData, (newData) => {
  transformData(newData);
}, { immediate: true, deep: true });
</script>

<style scoped>
/* Le style reste identique à la version précédente */
.loading, .error, .no-data {
  text-align: center;
  padding: 40px;
  font-size: 16px;
  background: #f9f9f9;
  border-radius: 8px;
  margin: 20px 0;
  font-family: 'stara';
}

.error {
  color: #ff0000;
  background: #ffe6e6;
}

.no-data {
  color: #666;
  background: #f0f0f0;
}

.evolution-chart-wrapper {
  width: 100%;
  background-color: #fff;
  border-radius: 12px;
  animation: appear 0.6s ease-out forwards;
  box-shadow: 0 2px 10px rgba(0,0,0,0.08);
}

.chart-container {
  flex: 1;
  min-width: 0;
}

.graphic-wrapper {
  padding: 1.5rem;
  border-radius: 8px;
}

.voir {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 0.5rem;
  cursor: pointer;
  padding: 1rem;
  font-family: 'stara';
  color: #017AFF;
  border-top: 1px solid #f1f3f4;
  transition: all 0.3s ease;
}

.voir:hover {
  background-color: #f8f9fa;
}

.legend-container {
  width: auto;
  height: auto;
}

.legend-wrapper {
  padding: 1.5rem;
  border-radius: 8px;
  max-height: 400px;
  overflow-y: auto;
}

.stats-summary {
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
  padding: 1.25rem;
  border-radius: 10px;
  margin-bottom: 1.5rem;
  border-left: 4px solid #017AFF;
}

.stat-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.75rem;
  padding: 0.5rem 0;
}

.stat-item:last-child {
  margin-bottom: 0;
  border-top: 1px solid #e9ecef;
  padding-top: 0.75rem;
  margin-top: 0.5rem;
}

.stat-label {
  font-family: 'stara';
  font-size: 13px;
  color: #6b7280;
  font-weight: 500;
}

.stat-value {
  font-family: 'arial';
  font-size: 13px;
  font-weight: 600;
  color: #374151;
}

.legend-year-group {
  margin-bottom: 1.5rem;
}

.legend-year-title {
  font-family: 'stara';
  font-size: 15px;
  font-weight: 600;
  color: #2c3e50;
  margin-bottom: 1rem;
  padding-bottom: 0.75rem;
  border-bottom: 2px solid #e9ecef;
}

.legend-items {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.75rem;
  border-radius: 8px;
  transition: all 0.3s ease;
  border: 1px solid transparent;
}

.legend-item:hover {
  background-color: #f8f9fa;
  border-color: #e9ecef;
  transform: translateX(4px);
}

.legend-color {
  width: 16px;
  height: 16px;
  border-radius: 4px;
  flex-shrink: 0;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.legend-content {
  flex: 1;
  min-width: 0;
}

.legend-label {
  font-family: 'stara';
  font-size: 13px;
  font-weight: 600;
  color: #374151;
  margin-bottom: 0.25rem;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.legend-values {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.legend-value {
  font-family: 'arial';
  font-size: 12px;
  font-weight: 600;
  color: #6b7280;
  background: #f8f9fa;
  padding: 2px 8px;
  border-radius: 6px;
}

.legend-percentage {
  font-family: 'arial';
  font-size: 11px;
  font-weight: 600;
  padding: 4px 10px;
  border-radius: 12px;
  min-width: 70px;
  text-align: center;
  letter-spacing: 0.3px;
}

.evolution-positive {
  background: linear-gradient(135deg, #d1fae5 0%, #a7f3d0 100%);
  color: #065f46;
  border: 1px solid #10b981;
}

.evolution-negative {
  background: linear-gradient(135deg, #fee2e2 0%, #fecaca 100%);
  color: #991b1b;
  border: 1px solid #ef4444;
}

.evolution-stable {
  background: linear-gradient(135deg, #f3f4f6 0%, #e5e7eb 100%);
  color: #374151;
  border: 1px solid #d1d5db;
}

.fade-enter-active,
.fade-leave-active {
  transition: all 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
  transform: translateY(-10px);
}

.fade-enter-to,
.fade-leave-from {
  opacity: 1;
  transform: translateY(0);
}

/* Responsive */
@media (max-width: 768px) {
  .evolution-chart-wrapper {
    flex-direction: column;
  }
  
  .graphic-wrapper {
    padding: 1rem;
  }
  
  .legend-wrapper {
    padding: 1rem;
    max-height: 350px;
  }
  
  .stats-summary {
    padding: 1rem;
  }
  
  .legend-item {
    padding: 0.5rem;
  }
}

@keyframes appear {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>