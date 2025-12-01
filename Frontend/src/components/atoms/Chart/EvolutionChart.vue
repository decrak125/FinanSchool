<template>
  <div>
    <div v-if="loading" class="loading">Chargement...</div>
    <div v-else-if="error" class="error">{{ error }}</div>
    <div v-else-if="series.length === 0" class="no-data">
      Aucune donnée disponible pour les filtres sélectionnés
    </div>
    <div v-else class="evolution-chart-wrapper">
      <div class="chart-with-separate-legend">
        <transition name="fade">
          <div class="chart-container">
            <div class="table-title">
              <Texte :type="'bold-dark'" :texte="'Évolution des Montants sur 12 Mois'" />
            </div>
            
            <div class="graphic-wrapper">
              <apexchart type="area" :height="height" :options="chartOptions" :series="series"></apexchart>
            </div>
          </div>
        </transition>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, watch, computed } from 'vue';
import Texte from '@/components/atoms/Texte.vue';
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
    default: 298
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
    // title: {
    //   text: 'Évolution des Montants sur 12 Mois',
    //   align: 'center',
    //   style: {
    //     fontFamily: 'stara',
    //     fontSize: '18px',
    //     fontWeight: 'bold',
    //     color: '#2c3e50'
    //   }
    // },
    xaxis: {
      type: 'datetime',
      labels: {
        style: {
          fontFamily: 'stara',
          colors: '#6b7280',
          fontSize: '11px'
        },
        formatter: function (value) {
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
        text: 'Montant (Ar)',
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
        formatter: function (value) {
          return new Intl.NumberFormat('mg-MG', {
            // style: 'currency',
            // currency: 'MGA',
            minimumFractionDigits: 0,
            maximumFractionDigits: 0
          }).format(value);
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
        formatter: function (value) {
          return new Date(value).toLocaleDateString('fr-FR', {
            month: 'long',
            year: 'numeric'
          });
        }
      },
      y: {
        formatter: function (value) {
          return new Intl.NumberFormat('mg-MG', {
            // style: 'currency',
            // currency: 'MGA',
            minimumFractionDigits: 0,
            maximumFractionDigits: 0
          }).format(value);
        }
      }
    },
    legend: {
      show: true,
      position: 'top',
      horizontalAlign: 'left',
      fontFamily: 'stara',
      markers: {
        width: 12,
        height: 12,
        radius: 6
      }
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
            formatter: function (value) {
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
  return new Intl.NumberFormat('mg-MG', {
    // style: 'currency',
    // currency: 'MGA',
    minimumFractionDigits: 0,
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

<style lang="scss" scoped>
.loading,
.error,
.no-data {
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
  @include glass();
  width: 100%;
  height: 100%;
  gap: 12px;
  // padding: 24px;
  border-radius: $radius-pm;
  animation: appear 0.6s ease-out forwards;
  transition: transform 0.3s ease, filter 0.3s ease-in-out;

  @media (max-width: 768px) {
    border-radius: $radius-sm;
  }
}

.evolution-chart-wrapper:hover {
  transform: scale(1.02);
  transition: transform 0.3s ease, filter 0.3s ease-in-out;
  box-shadow: 0 10px 10px rgba(0, 0, 0, 0.05);

  @media (max-width: 768px) {
    transform: none;
  }
}

// .chart-container {
//   @include position-contenus(flex, flex, center);
//     flex-direction: column;
//     position: relative;
//     overflow: hidden;
//     animation: appear 0.6s ease-out forwards;
// }

// Style pour la version séparée
.chart-with-separate-legend {
  // min-width: none;

  transition: transform 0.3s ease, filter 0.3s ease-in-out;
  @include position-contenus(flex, flex-start, flex-start);

  @media (max-width: 1024px) {
    gap: 10px;
  }

  @media (max-width: 768px) {
    flex-direction: column;
    gap: 5px;
  }

  .chart-container {
    flex: 1;
    min-width: 0;
    height: 100%;
    padding: 24px;

    @media (max-width: 768px) {
      width: 100%;
    }

    .graphic-wrapper {
      min-width: 600px;
      // padding: 12px;
      border-radius: 8px;

      @media (max-width: 768px) {
        padding: 8px;
      }
    }
  }

  .legend-container {
    width: auto;
    height: auto;

    // padding: 24px 0;      
    @media (max-width: 768px) {
      width: 100%;
    }

    .legend-wrapper {
      padding: 12px 0;
      border-radius: 8px;
      max-height: v-bind('legendHeight + "px"');
      overflow-y: auto;

      @media (max-width: 1024px) {
        padding: 1rem;
      }

      @media (max-width: 768px) {
        padding: 8px;
        max-height: 250px;
      }

      .legend-title {
        font-family: 'stara';

        font-size: 16px;
        font-weight: bold;
        margin-bottom: 1rem;
        color: #373d3f;
        border-bottom: 1px solid #e5e7eb;
        padding-bottom: 0.5rem;

        @media (max-width: 768px) {
          font-size: 14px;
          margin-bottom: 0.75rem;
        }
      }

      .legend-items {
        width: 100%;
        height: 100%;
        display: flex;
        // flex-direction: column;
        justify-content: flex-start;
      }

      .legend-item {
        display: flex;
        align-items: center;
        gap: 0.75rem;
        padding: 0 12px 0 0;
        transition: background-color 0.2s ease;

        @media (max-width: 480px) {
          gap: 0.5rem;
          padding: 0.375rem;
        }

        // &:hover {
        //     background-color: #f8f9fa;
        // }

        .legend-color {
          width: 12px;
          height: 12px;
          border-radius: $radius-pm;
          flex-shrink: 0;

          @media (max-width: 480px) {
            width: 12px;
            height: 12px;
          }
        }

        .legend-content {
          flex: 1;
          min-width: 0;


          .legend-label {
            font-family: 'stara';
            font-size: 12px;
            font-weight: 500;
            color: #374151;
            // margin-bottom: 0.25rem;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;

            @media (max-width: 480px) {
              font-size: 11px;
            }
          }

          .legend-values {
            display: flex;
            align-items: center;
            gap: 0.5rem;

            @media (max-width: 480px) {
              gap: 0.25rem;
              flex-direction: column;
              align-items: flex-start;
            }

            .legend-value {
              font-family: 'arial';
              font-size: 11px;
              font-weight: 600;
              color: #6b7280;

              @media (max-width: 480px) {
                font-size: 10px;
              }
            }

            .legend-percentage {
              font-family: 'arial';
              font-size: 11px;
              font-weight: 500;
              color: #9ca3af;

              @media (max-width: 480px) {
                font-size: 10px;
              }
            }
          }
        }
      }
    }
  }
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

// Responsive amélioré
@media (max-width: 1024px) {
  .chart-with-separate-legend {
    .legend-container {
      .legend-wrapper {
        max-height: 180px;
      }
    }
  }
}

/* Responsive */
@media (max-width: 768px) {
  .evolution-chart-wrapper {
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