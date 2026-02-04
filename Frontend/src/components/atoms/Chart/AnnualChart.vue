<template>
  <div>
    <div v-if="loading" class="loading">Chargement...</div>
    <div v-else-if="error" class="error">{{ error }}</div>
    <div v-else-if="!chartData || chartData.length === 0" class="no-data">
      Aucune donnée disponible pour les filtres sélectionnés
    </div>
    <div v-else class="comparison-chart-wrapper">
      <div class="chart-with-separate-legend">
        <div class="chart-container">
          <div class="table-title">
              <Texte :type="'bold-dark'" :texte="'Comparaison Annuelle ' + annee1 + ' vs ' + annee2" />
          </div>
          <div class="graphic-wrapper">
            <apexchart type="bar" :height="height" :options="chartOptions" :series="series"></apexchart>
          </div>
          <!-- <div class="voir" @click="showDetails = !showDetails">
            <i class="bi bi-eye"></i>
            <p v-if="!showDetails">Voir les détails</p>
            <p v-if="showDetails">Masquer les détails</p>
          </div> -->
        </div>

        <!-- <transition name="fade">
          <div class="legend-container" v-if="showDetails">
            <div class="legend-wrapper">
              <div class="legend-year-group" v-if="legendData.annee1.length > 0">
                <div class="legend-year-title">Année {{ annee1 }}</div>
                <div class="legend-items">
                  <div v-for="(item, index) in legendData.annee1" :key="`a1-${index}`" class="legend-item">
                    <div class="legend-color" :style="{ backgroundColor: getColorForCentre(item.centre) }"></div>
                    <div class="legend-content">
                      <div class="legend-label">{{ item.centre }}</div>
                      <div class="legend-values">
                        <span class="legend-value">{{ formatMontant(item.montant_brut) }}</span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <div class="legend-year-group" v-if="legendData.annee2.length > 0">
                <div class="legend-year-title">Année {{ annee2 }}</div>
                <div class="legend-items">
                  <div v-for="(item, index) in legendData.annee2" :key="`a2-${index}`" class="legend-item">
                    <div class="legend-color" :style="{ backgroundColor: getColorForCentre(item.centre) }"></div>
                    <div class="legend-content">
                      <div class="legend-label">{{ item.centre }}</div>
                      <div class="legend-values">
                        <span class="legend-value">{{ formatMontant(item.montant_brut) }}</span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <div class="legend-year-group" v-if="evolutionData.length > 0">
                <div class="legend-year-title">Évolutions par centre</div>
                <div class="legend-items">
                  <div v-for="(item, index) in evolutionData" :key="`evo-${index}`" class="legend-item">
                    <div class="legend-color" :style="{ backgroundColor: getColorForCentre(item.centre) }"></div>
                    <div class="legend-content">
                      <div class="legend-label">{{ item.centre }}</div>
                      <div class="legend-values">
                        <span class="legend-percentage" :class="getEvolutionClass(item.evolution)">
                          {{ formatEvolution(item.evolution) }}
                        </span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </transition> -->
      </div>
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
    default: () => ['#017AFF', '#F34971', '#00D4AA', '#F5C900', '#6C47FF', '#39C0C8']
  },
  annee1: {
    type: String,
    default: ''
  },
  annee2: {
    type: String,
    default: ''
  }
});

const showDetails = ref(true);
const series = ref([]);
const chartCategories = ref([]);

// Données séparées pour les légendes
const legendData = ref({
  annee1: [],
  annee2: []
});
const evolutionData = ref([]);

// CORRECTION : Définir les polices comme des constantes
const fontFamily = "'ninetea', sans-serif";

const chartOptions = computed(() => {
  return {
    chart: {
      type: 'bar',
      height: props.height,
      stacked: false,
      toolbar: {
        show: true
      },
      animations: {
        enabled: true,
        easing: 'easeout',
        speed: 800
      }
    },
    colors: props.colors,
    plotOptions: {
      bar: {
        horizontal: false,
        columnWidth: '60%',
        borderRadius: 6,
        borderRadiusApplication: 'end',
      }
    },
    dataLabels: {
      enabled: false
    },
    stroke: {
      show: true,
      width: 2,
      colors: ['transparent']
    },
    // title: {
    //   text: `Comparaison Annuelle ${props.annee1} vs ${props.annee2}`,
    //   align: 'center',
    //   style: {
    //     fontFamily: fontFamily,
    //     fontSize: '16px',
    //     fontWeight: 'bold',
    //     color: '#373d3f'
    //   }
    // },
    xaxis: {
      categories: chartCategories.value,
      title: {
        text: 'Centres',
        style: {
          fontFamily: fontFamily,
          fontWeight: '500',
          color: '#373d3f'
        }
      },
      labels: {
        style: {
          fontFamily: fontFamily,
          colors: '#6b7280',
          fontSize: '11px'
        }
      }
    },
    yaxis: {
      title: {
        text: 'Montant (Ar)',
        style: {
          fontFamily: fontFamily,
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
          fontFamily: fontFamily,
          colors: '#6b7280'
        }
      }
    },
    tooltip: {
      enabled: true,
      theme: 'dark',
      style: {
        fontSize: '12px',
        fontFamily: fontFamily
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
      fontFamily: 'ninetea',
      fontWeight: '800',
      
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
    responsive: [{
      breakpoint: 768,
      options: {
        chart: {
          height: 350
        },
        plotOptions: {
          bar: {
            columnWidth: '70%'
          }
        }
      }
    }]
  };
});

// Transformer les données pour ApexCharts
const transformData = (data) => {
  console.log('🔹 Transformation des données:', data);

  // CORRECTION : Validation plus robuste des données
  if (!data || !Array.isArray(data) || data.length === 0) {
    console.log('🔹 Aucune donnée à transformer');
    series.value = [];
    chartCategories.value = [];
    legendData.value = { annee1: [], annee2: [] };
    evolutionData.value = [];
    return;
  }

  try {
    // Obtenir les années uniques et les centres uniques
    const annees = [...new Set(data.map(item => item.annee))].sort();
    const centres = [...new Set(data.map(item => item.centre))].filter(centre => centre); // Filtrer les centres vides

    console.log('🔹 Années trouvées:', annees);
    console.log('🔹 Centres trouvés:', centres);

    // CORRECTION : Validation des centres
    if (centres.length === 0) {
      throw new Error('Aucun centre valide trouvé dans les données');
    }

    // Préparer les séries pour le graphique (une série par année)
    const seriesData = annees.map(annee => {
      const dataForYear = centres.map(centre => {
        const item = data.find(d => d.centre === centre && d.annee === annee);
        // CORRECTION : Gestion des valeurs null/undefined
        const montant = item ? (parseFloat(item.montant_brut) || parseFloat(item.montant_ventile) || 0) : 0;
        return montant;
      });

      return {
        name: `Année ${annee}`,
        data: dataForYear
      };
    });

    // Mettre à jour les catégories (centres)
    chartCategories.value = centres;

    // Séparer les données par année pour les légendes
    legendData.value = {
      annee1: data.filter(item => item.annee === props.annee1 && item.centre), // Filtrer les items sans centre
      annee2: data.filter(item => item.annee === props.annee2 && item.centre)
    };

    // Calculer les évolutions par centre
    evolutionData.value = centres.map(centre => {
      const itemAnnee1 = data.find(d => d.centre === centre && d.annee === props.annee1);
      const itemAnnee2 = data.find(d => d.centre === centre && d.annee === props.annee2);

      let evolution = 0;
      if (itemAnnee1 && itemAnnee2) {
        const montant1 = parseFloat(itemAnnee1.montant_brut) || parseFloat(itemAnnee1.montant_ventile) || 0;
        const montant2 = parseFloat(itemAnnee2.montant_brut) || parseFloat(itemAnnee2.montant_ventile) || 0;

        if (montant1 > 0) {
          evolution = ((montant2 - montant1) / montant1) * 100;
        }
      }

      return {
        centre: centre,
        evolution: evolution
      };
    });

    series.value = seriesData;
    console.log('🔹 Transformation terminée avec succès');

  } catch (error) {
    console.error('❌ Erreur lors de la transformation des données:', error);
    series.value = [];
    chartCategories.value = [];
    legendData.value = { annee1: [], annee2: [] };
    evolutionData.value = [];
  }
};

// Méthodes pour la légende
const getColorForCentre = (centre) => {
  if (!centre) return '#CCCCCC'; // Couleur par défaut pour les centres vides

  const centres = [...new Set(props.chartData.map(item => item.centre).filter(c => c))];
  const index = centres.indexOf(centre);
  return props.colors[index % props.colors.length] || '#CCCCCC';
};

const formatMontant = (montant) => {
  return new Intl.NumberFormat('mg-MG', {
    minimumFractionDigits: 0,
    maximumFractionDigits: 0
  }).format(parseFloat(montant) || 0);
};

const formatEvolution = (evolution) => {
  if (evolution === undefined || evolution === null || isNaN(evolution)) {
    return 'N/A';
  }
  if (evolution === 0) return '→ Stable';
  const sign = evolution > 0 ? '↗' : '↘';
  return `${sign} ${Math.abs(evolution).toFixed(1)}%`;
};

const getEvolutionClass = (evolution) => {
  if (evolution === undefined || evolution === null || isNaN(evolution)) {
    return 'evolution-stable';
  }
  if (evolution > 0) return 'evolution-positive';
  if (evolution < 0) return 'evolution-negative';
  return 'evolution-stable';
};

// CORRECTION : Surveiller les changements de données avec gestion d'erreur
watch(() => props.chartData, (newData) => {
  console.log('🔹 Données changées, transformation en cours...');
  transformData(newData);
}, { immediate: true, deep: true });

// Surveiller les changements d'années
watch(() => [props.annee1, props.annee2], () => {
  console.log('🔹 Années changées, mise à jour du graphique');
  if (props.chartData && props.chartData.length > 0) {
    transformData(props.chartData);
  }
});
</script>

<style lang="scss" scoped>
// CORRECTION : Définir les variables CSS ou utiliser des valeurs fixes
$stara-medium: 'Arial', 'Helvetica', sans-serif;

.loading,
.error,
.no-data {
  text-align: center;
  padding: 40px;
  font-size: 16px;
  background: #f9f9f9;
  border-radius: 8px;
  margin: 20px 0;
  font-family: $stara-medium;
}

.error {
  color: #ff0000;
  background: #ffe6e6;
}

.no-data {
  color: #666;
  background: #f0f0f0;
}


.comparison-chart-wrapper:hover {
  transform: scale(1.02);
  transition: transform 0.3s ease, filter 0.3s ease-in-out;
  box-shadow: 0 10px 10px rgba(0, 0, 0, 0.05);

  @media (max-width: 768px) {
    transform: none; // Désactiver le scale sur mobile pour éviter les problèmes de layout
  }
}

.comparison-chart-wrapper {
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

.legend-percentage {
  font-family: 'Arial', sans-serif;
  font-size: 11px;
  font-weight: 500;
  padding: 4px 8px;
  border-radius: 12px;
  min-width: 60px;
  text-align: center;
}

.evolution-positive {
  background-color: #d1fae5;
  color: #065f46;
  border: 1px solid #a7f3d0;
}

.evolution-negative {
  background-color: #fee2e2;
  color: #991b1b;
  border: 1px solid #fecaca;
}

.evolution-stable {
  background-color: #f3f4f6;
  color: #374151;
  border: 1px solid #e5e7eb;
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
  .comparison-chart-wrapper {
    flex-direction: column;
  }

  .graphic-wrapper {
    padding: 0.5rem;
  }

  .legend-wrapper {
    padding: 1rem;
    max-height: 300px;
  }

  .legend-year-title {
    font-size: 13px;
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