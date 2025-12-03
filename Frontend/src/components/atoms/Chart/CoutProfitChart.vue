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
          <div class="graphic-wrapper">
            <apexchart
              type="area"
              :height="height"
              :options="chartOptions"
              :series="series"
            ></apexchart>
          </div>
        </div>
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
  const xaxisCategories = ref([]); // Pour stocker les catégories de l'axe X
  const periodesOriginales = ref([]); // Pour stocker les périodes originales (année-mois)
  
  // Computed properties
  const periodRange = computed(() => {
    if (props.chartData.length === 0) return '';
    
    const annees = [...new Set(props.chartData.map(item => item.annee))].sort();
    if (annees.length === 0) return '';
    
    const minYear = Math.min(...annees.map(a => parseInt(a)));
    const maxYear = Math.max(...annees.map(a => parseInt(a)));
    
    if (minYear === maxYear) {
      return `Année ${minYear}`;
    }
    return `Période ${minYear}-${maxYear}`;
  });
  
  const typesCount = computed(() => {
    return new Set(props.chartData.map(item => item.id_type)).size;
  });
  
  // Transformer les données pour ApexCharts (version avec catégories)
  const transformData = (data) => {
    console.log('🔹 Transformation des données coûts vs profits:', data);
    
    if (!data || data.length === 0) {
      series.value = [];
      xaxisCategories.value = [];
      periodesOriginales.value = [];
      return;
    }

    // 1. Grouper les données par période (année-mois)
    const periodesSet = new Set();
    data.forEach(item => {
      if (item.annee && item.mois) {
        const moisFormate = item.mois.padStart(2, '0');
        periodesSet.add(`${item.annee}-${moisFormate}`);
      }
    });
    
    // 2. Trier les périodes chronologiquement
    const periodes = Array.from(periodesSet).sort((a, b) => {
      const [anneeA, moisA] = a.split('-').map(Number);
      const [anneeB, moisB] = b.split('-').map(Number);
      
      if (anneeA !== anneeB) return anneeA - anneeB;
      return moisA - moisB;
    });
    
    periodesOriginales.value = periodes;
    console.log('🔹 Périodes triées:', periodes);

    // 3. Créer les catégories pour l'axe X (noms des mois)
    xaxisCategories.value = periodes.map(periode => {
      const [annee, mois] = periode.split('-').map(Number);
      const date = new Date(annee, mois - 1, 1);
      
      // Si toutes les données sont de la même année, afficher seulement le mois
      const anneesUniques = new Set(data.map(item => item.annee));
      if (anneesUniques.size === 1) {
        return date.toLocaleDateString('fr-FR', { 
          month: 'short'
        });
      }
      
      // Sinon, afficher mois + année abrégée
      return date.toLocaleDateString('fr-FR', { 
        month: 'short',
        year: '2-digit'
      });
    });
    
    console.log('🔹 Catégories X:', xaxisCategories.value);

    // 4. Calculer les totaux pour chaque période
    const profitsData = periodes.map(periode => {
      const [annee, mois] = periode.split('-');
      const items = data.filter(item => 
        item.annee === annee && item.mois === mois.replace(/^0+/, '')
      );
      
      return items.reduce((sum, item) => sum + (parseFloat(item.total_profits_ventiles) || 0), 0);
    });

    const costsData = periodes.map(periode => {
      const [annee, mois] = periode.split('-');
      const items = data.filter(item => 
        item.annee === annee && item.mois === mois.replace(/^0+/, '')
      );
      
      return items.reduce((sum, item) => sum + (parseFloat(item.total_couts_ventiles) || 0), 0);
    });

    // 5. Calculer le solde cumulatif
    let soldeCumulatif = 0;
    const soldeData = profitsData.map((profit, index) => {
      const cost = costsData[index] || 0;
      soldeCumulatif += (profit - cost);
      return soldeCumulatif;
    });

    // 6. Préparer les séries pour ApexCharts
    series.value = [
      {
        name: 'Profits',
        data: profitsData
      },
      {
        name: 'Coûts',
        data: costsData
      },
      {
        name: 'Solde Net',
        data: soldeData
      }
    ];

    console.log('🔹 Séries préparées:', series.value);
    console.log('🔹 Profits:', profitsData);
    console.log('🔹 Coûts:', costsData);
    console.log('🔹 Solde:', soldeData);
  };
  
  // Options du graphique
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
      xaxis: {
        type: 'category', // Utiliser des catégories au lieu de datetime
        categories: xaxisCategories.value, // Les catégories générées
        labels: {
          style: {
            fontFamily: 'stara',
            colors: '#6b7280',
            fontSize: '11px'
          },
          rotate: -45, // Rotation pour mieux lire
          rotateAlways: false,
          hideOverlappingLabels: true
        },
        axisBorder: {
          show: false
        },
        axisTicks: {
          show: false
        },
        tickPlacement: 'on' // Placer les ticks sur les catégories
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
              minimumFractionDigits: 0,
              maximumFractionDigits: 0
            }).format(value);
          }
        }
      },
      tooltip: {
        enabled: true,
        shared: true, // Tooltip partagé pour toutes les séries
        intersect: false,
        theme: 'light',
        style: {
          fontFamily: 'stara',
          fontSize: '12px'
        },
        x: {
          formatter: function(value, { series, seriesIndex, dataPointIndex, w }) {
            // Afficher la période complète dans le tooltip
            if (periodesOriginales.value.length > dataPointIndex) {
              const periode = periodesOriginales.value[dataPointIndex];
              const [annee, mois] = periode.split('-').map(Number);
              const date = new Date(annee, mois - 1, 1);
              return date.toLocaleDateString('fr-FR', { 
                month: 'long',
                year: 'numeric'
              });
            }
            return value;
          }
        },
        y: {
          formatter: function(value, { series, seriesIndex, dataPointIndex, w }) {
            const seriesName = w.globals.seriesNames[seriesIndex];
            const formattedValue = new Intl.NumberFormat('mg-MG', {
              minimumFractionDigits: 0,
              maximumFractionDigits: 0
            }).format(value);
            
            return `<div style="display: flex; justify-content: space-between; min-width: 150px;">
                      <span style="font-weight: 600; margin-right: 10px;">${seriesName}:</span>
                      <span>${formattedValue} Ar</span>
                    </div>`;
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
          xaxis: {
            labels: {
              rotate: -45,
              style: {
                fontSize: '10px'
              }
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
          xaxis: {
            labels: {
              rotate: -45,
              style: {
                fontSize: '9px'
              },
              formatter: function(value) {
                // Sur très petit écran, réduire la longueur
                return value.length > 4 ? value.substring(0, 3) + '.' : value;
              }
            }
          },
          legend: {
            position: 'top',
            horizontalAlign: 'center'
          }
        }
      }]
    };
  });
  
  // Méthodes utilitaires
  const formatMontant = (montant) => {
    return new Intl.NumberFormat('mg-MG', {
      minimumFractionDigits: 0,
      maximumFractionDigits: 0
    }).format(parseFloat(montant) || 0);
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

.chart-with-separate-legend {
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
            border-radius: 8px;
            
            @media (max-width: 768px) {
                padding: 8px;
            }
        }
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