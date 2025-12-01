<template>
    <div>
      <div v-if="loading" class="loading">Chargement...</div>
      <div v-else-if="error" class="error">{{ error }}</div>
      <div v-else-if="series.length === 0" class="no-data">
        Aucune donnée disponible pour les filtres sélectionnés
      </div>
      <div v-else class="cout-profit-chart-wrapper">
            <div class="chart-with-separate-legend">
        <div class="chart-container">
          <div class="table-title">
              <Texte :type="'bold-dark'" :texte="'Évolution Coûts vs Profits'" />
        </div>
        <!-- <transition name="fade">
          <div class="legend-container" v-if="showDetails">
            <div class="legend-wrapper">
                <div class="legend-items">
                  <div class="legend-item">
                    <div class="legend-color" style="background-color: #00D4AA"></div>
                    <div class="legend-content">
                      <div class="legend-label">Profits</div>
                      <div class="legend-values">
                        <span class="legend-value">{{ formatMontant(summaryData.totalProfits) }}</span>
                      </div>
                    </div>
                  </div>
                  <div class="legend-item">
                    <div class="legend-color" style="background-color: #F34971"></div>
                    <div class="legend-content">
                      <div class="legend-label">Coûts</div>
                      <div class="legend-values">
                        <span class="legend-value">{{ formatMontant(summaryData.totalCosts) }}</span>
                      </div>
                    </div>
                  </div>
                  <div class="legend-item">
                    <div class="legend-color" style="background-color: #017AFF"></div>
                    <div class="legend-content">
                      <div class="legend-label">Solde Net</div>
                      <div class="legend-values">
                        <span class="legend-value" :class="summaryData.soldeNet >= 0 ? 'positive' : 'negative'">
                          {{ formatMontant(summaryData.soldeNet) }}
                        </span>
                      </div>
                    </div>
                  </div>
                </div>
                </div>
              </div>
        </transition> -->
          <div class="graphic-wrapper">
            <apexchart
              type="area"
              :height="height"
              :options="chartOptions"
              :series="series"
            ></apexchart>
          </div>
          <!-- <div class="voir" @click="showDetails = !showDetails">
            <i class="bi bi-eye"></i>
            <p v-if="!showDetails">Voir les détails</p>
            <p v-if="showDetails">Masquer les détails</p>
          </div> -->
        </div>
        
        <!-- <transition name="fade">
          <div class="legend-container" v-if="showDetails">
            <div class="legend-wrapper"> -->
              <!-- Statistiques globales -->
              <!-- <div class="stats-summary">
                <div class="stat-item">
                  <span class="stat-label">Période :</span>
                  <span class="stat-value">{{ periodRange }}</span>
                </div>
                <div class="stat-item">
                  <span class="stat-label">Types analysés :</span>
                  <span class="stat-value">{{ typesCount }}</span>
                </div>
                <div class="stat-item">
                  <span class="stat-label">Marge moyenne :</span>
                  <span class="stat-value" :class="getMargeClass(averageMarge)">
                    {{ formatPourcentage(averageMarge) }}
                  </span>
                </div>
              </div> -->
  
              <!-- Légende des séries -->
  
              <!-- Détails par type -->
              <!-- <div class="legend-year-group" v-if="detailedData.length > 0">
                <div class="legend-year-title">Analyse par Type</div>
                <div class="type-details">
                  <div v-for="item in detailedData" :key="'detail-' + item.id_type" class="type-detail-item">
                    <div class="type-header">
                      <span class="type-badge">Type {{ item.id_type }}</span>
                      <span class="marge-badge" :class="getMargeClass(item.marge_moyenne)">
                        {{ formatPourcentage(item.marge_moyenne) }}
                      </span>
                    </div>
                    <div class="type-stats">
                      <div class="stat-row">
                        <span>Coûts:</span>
                        <span>{{ formatMontant(item.total_couts) }}</span>
                      </div>
                      <div class="stat-row">
                        <span>Profits:</span>
                        <span>{{ formatMontant(item.total_profits) }}</span>
                      </div>
                      <div class="stat-row highlight">
                        <span>Solde net:</span>
                        <span :class="item.solde_net >= 0 ? 'positive' : 'negative'">
                          {{ formatMontant(item.solde_net) }}
                        </span>
                      </div>
                    </div>
                  </div>
                </div>
              </div> -->
            <!-- </div>
          </div>
        </transition> -->
      </div>
      </div>
    </div>
  </template>
  
  <script setup>
  import { ref, computed, watch } from 'vue';
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
  
  const typesCount = computed(() => {
    return new Set(props.chartData.map(item => item.id_type)).size;
  });
  
  // Données détaillées par type
  const detailedData = computed(() => {
    const types = [...new Set(props.chartData.map(item => item.id_type))];
    return types.map(type => {
      const typeData = props.chartData.filter(item => item.id_type === type);
      const totalCouts = typeData.reduce((sum, item) => sum + (parseFloat(item.total_couts_ventiles) || 0), 0);
      const totalProfits = typeData.reduce((sum, item) => sum + (parseFloat(item.total_profits_ventiles) || 0), 0);
      const soldeNet = totalProfits - totalCouts;
      const margeMoyenne = totalCouts > 0 ? (soldeNet / totalCouts) * 100 : 0;
  
      return {
        id_type: type,
        total_couts: totalCouts,
        total_profits: totalProfits,
        solde_net: soldeNet,
        marge_moyenne: margeMoyenne
      };
    }).sort((a, b) => b.solde_net - a.solde_net);
  });
  
  // Données résumées
  const summaryData = computed(() => {
    const totalCosts = props.chartData.reduce((sum, item) => sum + (parseFloat(item.total_couts_ventiles) || 0), 0);
    const totalProfits = props.chartData.reduce((sum, item) => sum + (parseFloat(item.total_profits_ventiles) || 0), 0);
    const soldeNet = totalProfits - totalCosts;
    
    return {
      totalCosts,
      totalProfits,
      soldeNet
    };
  });
  
  const averageMarge = computed(() => {
    if (detailedData.value.length === 0) return 0;
    const totalMarge = detailedData.value.reduce((sum, item) => sum + item.marge_moyenne, 0);
    return totalMarge / detailedData.value.length;
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
      colors: ['#00D4AA', '#F34971', '#017AFF'], // Vert pour profits, Rouge pour coûts, Bleu pour solde
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
      //   text: 'Évolution Coûts vs Profits',
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
          formatter: function(value) {
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
          formatter: function(value) {
            return new Date(value).toLocaleDateString('fr-FR', { 
              month: 'long',
              year: 'numeric'
            });
          }
        },
        y: {
          formatter: function(value) {
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
      },
      {
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
    console.log('🔹 Transformation des données coûts vs profits:', data);
    
    if (!data || data.length === 0) {
      series.value = [];
      return;
    }
  
    // Grouper les données par période
    const periodes = [...new Set(data.map(item => item.mois))].sort();
    
    // Calculer les totaux par période
    const profitsData = periodes.map(periode => {
      const items = data.filter(item => item.mois === periode);
      return {
        x: new Date(periode).getTime(),
        y: items.reduce((sum, item) => sum + (parseFloat(item.total_profits_ventiles) || 0), 0)
      };
    });
  
    const costsData = periodes.map(periode => {
      const items = data.filter(item => item.mois === periode);
      return {
        x: new Date(periode).getTime(),
        y: items.reduce((sum, item) => sum + (parseFloat(item.total_couts_ventiles) || 0), 0)
      };
    });
  
    const soldeData = periodes.map(periode => {
      const items = data.filter(item => item.mois === periode);
      const profits = items.reduce((sum, item) => sum + (parseFloat(item.total_profits_ventiles) || 0), 0);
      const costs = items.reduce((sum, item) => sum + (parseFloat(item.total_couts_ventiles) || 0), 0);
      return {
        x: new Date(periode).getTime(),
        y: profits - costs
      };
    });
  
    series.value = [
      {
        name: 'Profits',
        data: profitsData.sort((a, b) => a.x - b.x)
      },
      {
        name: 'Coûts',
        data: costsData.sort((a, b) => a.x - b.x)
      },
      {
        name: 'Solde Net',
        data: soldeData.sort((a, b) => a.x - b.x)
      }
    ];
  
    console.log('🔹 Séries area chart:', series.value);
  };
  
  // Méthodes utilitaires
  const formatMontant = (montant) => {
    return new Intl.NumberFormat('mg-MG', {
          // style: 'currency',
          // currency: 'MGA',
          minimumFractionDigits: 0,
          maximumFractionDigits: 0
        }).format(parseFloat(montant) || 0);
  };
  
  const formatPourcentage = (pourcentage) => {
    if (pourcentage === undefined || pourcentage === null || isNaN(pourcentage)) {
      return 'N/A';
    }
    const sign = pourcentage > 0 ? '+' : '';
    return `${sign}${pourcentage.toFixed(1)}%`;
  };
  
  const getMargeClass = (marge) => {
    if (marge === undefined || marge === null || isNaN(marge)) {
      return 'marge-stable';
    }
    if (marge > 20) return 'marge-excellente';
    if (marge > 10) return 'marge-bonne';
    if (marge > 0) return 'marge-faible';
    return 'marge-negative';
  };
  
  // Watchers
  watch(() => props.chartData, transformData, { immediate: true, deep: true });
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

.cout-profit-chart-wrapper {
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

.cout-profit-chart-wrapper:hover {
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
  .cout-profit-chart-wrapper {
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