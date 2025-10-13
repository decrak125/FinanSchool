<template>
  <div>
    <div v-if="loading" class="loading">Chargement...</div>
    <div v-else-if="error" class="error">{{ error }}</div>
    <div v-else-if="series.length === 0" class="no-data">
      Aucune donnée disponible pour les filtres sélectionnés
    </div>
    <div v-else class="area-chart-wrapper">
      <div class="chart-container">
        <div class="graphic-wrapper">
          <apexchart
            type="line"
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
            <div class="legend-items">
              <div v-for="(serie, index) in series" :key="index" class="legend-item">
                <div class="legend-color" :style="{ backgroundColor: getColor(index) }"></div>
                <div class="legend-content">
                  <div class="legend-label">{{ serie.name }}</div>
                  <div class="legend-values">
                    <span class="legend-value">{{ formatTotal(serie.data) }}</span>
                    <span class="legend-percentage">({{ calculatePercentage(serie.data) }}%)</span>
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
    default: () => ['#017AFF', '#F34971', '#FF9382', '#F5C900', '#6C47FF', '#39C0C8', '#00D4AA', '#FF6B8B', '#9C27B0', '#3F51B5']
  }
});

const showDetails = ref(true);
const series = ref([]);

const chartOptions = computed(() => {
  return {
    chart: {
      type: 'line',
      height: props.height,
      animations: {
        enabled: true,
        easing: 'easeout',
        speed: 800,
        animateGradually: {
          enabled: true,
          delay: 200
        }
      },
      toolbar: {
        show: false
      },
      zoom: {
        enabled: false
      }
    },
    colors: props.colors,
    dataLabels: {
      enabled: false
    },
    stroke: {
      curve: 'smooth',
      width: 3
    },
    title: {
      text: 'Analyse Mensuelle par Centre',
      align: 'center',
      style: {
        fontFamily: 'stara',
        fontSize: '16px',
        fontWeight: 'bold',
        color: '#373d3f'
      }
    },
    xaxis: {
      categories: ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun', 'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'],
      title: {
        text: 'Mois',
        style: {
          fontFamily: 'stara',
          fontWeight: '500',
          color: '#373d3f'
        }
      },
      labels: {
        style: {
          fontFamily: 'stara',
          colors: '#6b7280'
        }
      }
    },
    yaxis: {
      title: {
        text: 'Montant (€)',
        style: {
          fontFamily: 'stara',
          fontWeight: '500',
          color: '#373d3f'
        }
      },
      labels: {
        formatter: function(value) {
          return new Intl.NumberFormat('fr-FR', { 
            style: 'currency', 
            currency: 'EUR',
            maximumFractionDigits: 0 
          }).format(value);
        },
        style: {
          fontFamily: 'stara',
          colors: '#6b7280'
        }
      }
    },
    tooltip: {
      enabled: true,
      theme: 'dark',
      style: {
        fontSize: '12px',
        fontFamily: 'stara'
      },
      y: {
        formatter: function(value) {
          return new Intl.NumberFormat('fr-FR', { 
            style: 'currency', 
            currency: 'EUR' 
          }).format(value);
        }
      }
    },
    legend: {
      show: false
    },
    grid: {
      borderColor: '#e5e7eb',
      strokeDashArray: 4
    },
    // ⭐⭐ IMPORTANT : Configuration pour éviter les cassures
    markers: {
      size: 0, // Pas de points sur la ligne
      hover: {
        size: 5
      }
    },
    noData: {
      text: "Aucune donnée disponible",
      style: {
        fontFamily: 'stara'
      }
    },
    responsive: [{
      breakpoint: 768,
      options: {
        chart: {
          height: 350
        }
      }
    }, {
      breakpoint: 480,
      options: {
        chart: {
          height: 300
        },
        xaxis: {
          labels: {
            style: {
              fontSize: '10px'
            }
          }
        },
        yaxis: {
          labels: {
            style: {
              fontSize: '10px'
            }
          }
        }
      }
    }]
  };
});

// Transformer les données pour ApexCharts - SANS les valeurs null
const transformData = (data) => {
  if (!data || data.length === 0) {
    series.value = [];
    return;
  }

  // Grouper les données par centre
  const centres = {};
  
  data.forEach(item => {
    const centreName = item.centre;
    const moisIndex = parseInt(item.mois) - 1;
    const montant = parseFloat(item.montant_ventile) || parseFloat(item.montant_brut) || 0;
    
    if (!centres[centreName]) {
      // ⭐⭐ IMPORTANT : Initialiser avec 0 au lieu de null pour éviter les cassures
      centres[centreName] = new Array(12).fill(0);
    }
    
    if (moisIndex >= 0 && moisIndex < 12) {
      centres[centreName][moisIndex] = montant;
    }
  });

  // Convertir en format ApexCharts
  series.value = Object.keys(centres).map(centre => ({
    name: centre,
    data: centres[centre]
  }));
};

// Méthodes pour la légende
const getColor = (index) => {
  return props.colors[index % props.colors.length];
};

const formatTotal = (data) => {
  const total = data.reduce((sum, value) => sum + (value || 0), 0);
  return new Intl.NumberFormat('fr-FR', { 
    style: 'currency', 
    currency: 'EUR',
    maximumFractionDigits: 0 
  }).format(total);
};

const calculatePercentage = (data) => {
  const total = data.reduce((sum, value) => sum + (value || 0), 0);
  const allTotals = series.value.map(serie => 
    serie.data.reduce((sum, value) => sum + (value || 0), 0)
  );
  const grandTotal = allTotals.reduce((sum, value) => sum + value, 0);
  
  return grandTotal > 0 ? ((total / grandTotal) * 100).toFixed(1) : 0;
};

// Surveiller les changements de données
watch(() => props.chartData, (newData) => {
  transformData(newData);
}, { immediate: true, deep: true });
</script>

<style scoped>
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

.area-chart-wrapper {
/* display: flex; */
  width: 100%;
  background-color: #fff;
  border-radius: 8px;
  animation: appear 0.6s ease-out forwards;
  transition: transform 0.3s ease, filter 0.3s ease-in-out;
}

.area-chart-wrapper:hover {
  transform: scale(1.02);
  transition: transform 0.3s ease, filter 0.3s ease-in-out;
}

.chart-container {
  flex: 1;
  min-width: 0;
}

.graphic-wrapper {
  padding: 1rem;
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
  transition: transform 0.3s ease, filter 0.3s ease-in-out;
}

.voir:hover {
  transform: scale(1.02);
}

.voir p {
  margin: 0;
  font-weight: 500;
}

.voir i {
  font-size: 18px;
}

.legend-container {
  width: auto;
  height: auto;
}

.legend-wrapper {
  padding: 1.5rem;
  border-radius: 8px;
  /* max-height: 200px; */
  overflow-y: auto;
}

.legend-items {
  display: flex;
  justify-content: center;
  /* flex-direction: column; */
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.5rem;
  border-radius: 6px;
  transition: background-color 0.2s ease;
}

.legend-item:hover {
  background-color: #f8f9fa;
}

.legend-color {
  width: 16px;
  height: 16px;
  border-radius: 4px;
  flex-shrink: 0;
}

.legend-content {
  flex: 1;
  min-width: 0;
}

.legend-label {
  font-family: 'stara';
  font-size: 12px;
  font-weight: 500;
  color: #374151;
  margin-bottom: 0.25rem;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.legend-values {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.legend-value {
  font-family: 'arial';
  font-size: 11px;
  font-weight: 600;
  color: #6b7280;
}

.legend-percentage {
  font-family: 'arial';
  font-size: 11px;
  font-weight: 500;
  color: #9ca3af;
}

.fade-enter-active,
.fade-leave-active {
  transition: all 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
  transform: scale(0.9);
}

.fade-enter-to,
.fade-leave-from {
  opacity: 1;
  transform: scale(1);
}

/* Responsive */
@media (max-width: 768px) {
  .area-chart-wrapper {
    flex-direction: column;
  }
  
  .graphic-wrapper {
    padding: 0.5rem;
  }
  
  .legend-wrapper {
    padding: 1rem;
    max-height: 150px;
  }
  
  .voir {
    padding: 0.75rem;
  }
}

@media (max-width: 480px) {
  .legend-item {
    gap: 0.5rem;
    padding: 0.375rem;
  }
  
  .legend-color {
    width: 12px;
    height: 12px;
  }
  
  .legend-label {
    font-size: 11px;
  }
  
  .legend-value,
  .legend-percentage {
    font-size: 10px;
  }
}

@keyframes appear {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>