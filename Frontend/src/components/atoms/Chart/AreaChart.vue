<template>
  <div v-if="loading" class="loading">Chargement...</div>
  <div v-else-if="error" class="error">{{ error }}</div>
  <div v-else-if="series.length === 0" class="no-data">
    Aucune donnée disponible pour les filtres sélectionnés
  </div>
  <div v-else class="area-chart-wrapper">
    <!-- Mode légende séparée comme dans areaChart -->
    <div class="chart-with-separate-legend">
      <transition name="fade">
        <div class="chart-container">
          <div class="table-title">
            <Texte :type="'bold-dark'" :texte="'Analyse Mensuelle par Centre'" />
          </div>
          <!-- <transition name="fade">
            <div class="legend-container">
              <div class="legend-wrapper">
                <div class="legend-items">
                  <div v-for="(serie, index) in series" :key="index" class="legend-item">
                    <div class="legend-color" :style="{ backgroundColor: getColor(index) }"></div>
                    <div class="legend-content">
                      <div class="legend-label">{{ serie.name }}</div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </transition> -->
          <div class="graphic-wrapper">
            <apexchart type="line" :height="height" :options="chartOptions" :series="series"></apexchart>
          </div>
          <!-- <div class="voir" @click="showDetails = !showDetails">
              <i class="bi bi-eye"></i>
              <p v-if="!showDetails">Voir les détails</p>
              <p v-if="showDetails">Masquer les détails</p>
            </div> -->
        </div>
      </transition>
    </div>
  </div>
</template>

<script setup>
import { ref, watch, computed } from 'vue';
import Texte from '../Texte.vue';

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
        show: true
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
      width: 2
    },
    title: {
      show: false // On retire le titre intégré car on utilise le composant Texte
    },
    xaxis: {
      categories: ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun', 'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'],
      title: {
        text: 'Mois',
        style: {
          fontFamily: 'ninetea',
          fontWeight: '500',
          color: '#373d3f'
        }
      },
      labels: {
        style: {
          fontFamily: 'ninetea',
          colors: '#6b7280'
        }
      }
    },
    yaxis: {
      title: {
        text: 'Montant (Ar)',
        style: {
          fontFamily: 'ninetea',
          fontWeight: '500',
          color: '#373d3f'
        }
      },
      labels: {
        formatter: function (value) {
          return new Intl.NumberFormat('mg-MG', {
            minimumFractionDigits: 0,
            maximumFractionDigits: 0
          }).format(value);
        },
        style: {
          fontFamily: 'ninetea',
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
        formatter: function (value) {
          return new Intl.NumberFormat('mg-MG', {
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
    grid: {
      borderColor: '#e5e7eb',
      strokeDashArray: 4
    },
    markers: {
      size: 0,
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
  return new Intl.NumberFormat('mg-MG', {
    minimumFractionDigits: 0,
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

<style lang="scss" scoped>
.voir {
  @include position-contenus(flex, center, center);
  gap: 0.5rem;
  cursor: pointer;

  p {
    @include text-pm($stara-medium, $primary);

    @media (max-width: 768px) {
      font-size: 14px;
    }

    @media (max-width: 480px) {
      font-size: 12px;
    }
  }

  i {
    color: $primary;
    font-size: 18px;

    @media (max-width: 480px) {
      font-size: 16px;
    }
  }

  transition: transform 0.3s ease,
  filter 0.3s ease-in-out;

  @media (max-width: 768px) {
    padding: 12px 0;
    justify-content: flex-start;
  }
}

.voir:hover {
  transform: scale(1.02);
  transition: transform 0.3s ease, filter 0.3s ease-in-out;
}

.area-chart-wrapper:hover {
  transform: scale(1.02);
  transition: transform 0.3s ease, filter 0.3s ease-in-out;
  box-shadow: 0 10px 10px rgba(0, 0, 0, 0.05);

  @media (max-width: 768px) {
    transform: none; // Désactiver le scale sur mobile pour éviter les problèmes de layout
  }
}

.area-chart-wrapper {
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

// .area-chart-container {
//     @include position-contenus(flex, flex, center);
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

@media (max-width: 768px) {
  .area-chart-wrapper {
    margin: 0 auto;
  }

  .chart-with-separate-legend {
    .chart-container {
      .graphic-wrapper {
        :deep(.apexcharts-canvas) {
          margin: 0 auto;
        }
      }
    }

    .legend-container {
      margin-top: 0;
    }
  }
}

@media (max-width: 480px) {
  .area-chart-wrapper {
    padding: 8px;
  }

  .voir {
    flex-direction: column;
    gap: 0.25rem;
    text-align: center;
  }
}

// Pour les très petits écrans
@media (max-width: 360px) {
  .chart-with-separate-legend {
    .legend-container {
      .legend-wrapper {
        padding: 0.5rem;

        .legend-item {
          padding: 0.25rem;
        }
      }
    }
  }
}
</style>