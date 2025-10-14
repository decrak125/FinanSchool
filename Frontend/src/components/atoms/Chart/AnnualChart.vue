<template>
    <div>
      <div v-if="loading" class="loading">Chargement...</div>
      <div v-else-if="error" class="error">{{ error }}</div>
      <div v-else-if="series.length === 0" class="no-data">
        Aucune donnée disponible pour les filtres sélectionnés
      </div>
      <div v-else class="comparison-chart-wrapper">
        <div class="chart-container">
          <div class="graphic-wrapper">
            <apexchart
              type="bar"
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
              <!-- Légende pour l'année 1 -->
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
  
              <!-- Légende pour l'année 2 -->
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
  
              <!-- Section des évolutions -->
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
  
  const chartOptions = computed(() => {
    return {
      chart: {
        type: 'bar',
        height: props.height,
        stacked: false,
        toolbar: {
          show: false
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
        width: 1,
        colors: ['transparent']
      },
      title: {
        text: `Comparaison Annuelle ${props.annee1} vs ${props.annee2}`,
        align: 'center',
        style: {
          fontFamily: 'stara',
          fontSize: '16px',
          fontWeight: 'bold',
          color: '#373d3f'
        }
      },
      xaxis: {
        categories: chartCategories.value,
        title: {
          text: 'Centres',
          style: {
            fontFamily: 'stara',
            fontWeight: '500',
            color: '#373d3f'
          }
        },
        labels: {
          style: {
            fontFamily: 'stara',
            colors: '#6b7280',
            fontSize: '11px'
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
        show: true,
        position: 'top',
        horizontalAlign: 'center',
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
    
    if (!data || data.length === 0) {
      series.value = [];
      chartCategories.value = [];
      legendData.value = { annee1: [], annee2: [] };
      evolutionData.value = [];
      return;
    }
  
    // Obtenir les années uniques et les centres uniques
    const annees = [...new Set(data.map(item => item.annee))].sort();
    const centres = [...new Set(data.map(item => item.centre))];
    
    console.log('🔹 Années trouvées:', annees);
    console.log('🔹 Centres trouvés:', centres);
  
    // Préparer les séries pour le graphique (une série par année)
    const seriesData = annees.map(annee => {
      const dataForYear = centres.map(centre => {
        const item = data.find(d => d.centre === centre && d.annee === annee);
        const montant = parseFloat(item?.montant_brut) || parseFloat(item?.montant_ventile) || 0;
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
      annee1: data.filter(item => item.annee === props.annee1),
      annee2: data.filter(item => item.annee === props.annee2)
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
  };
  
  // Méthodes pour la légende
  const getColorForCentre = (centre) => {
    const centres = [...new Set(props.chartData.map(item => item.centre))];
    const index = centres.indexOf(centre);
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
  
  // Surveiller les changements de données
  watch(() => props.chartData, (newData) => {
    transformData(newData);
  }, { immediate: true, deep: true });
  
  // Surveiller les changements d'années
  watch(() => [props.annee1, props.annee2], () => {
    if (props.chartData.length > 0) {
      transformData(props.chartData);
    }
  });
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
  
  .comparison-chart-wrapper {
    width: 100%;
    background-color: #fff;
    border-radius: 8px;
    animation: appear 0.6s ease-out forwards;
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
  
  .legend-year-group {
    margin-bottom: 1.5rem;
  }
  
  .legend-year-group:last-child {
    margin-bottom: 0;
  }
  
  .legend-year-title {
    font-family: 'stara';
    font-size: 14px;
    font-weight: 600;
    color: #017AFF;
    margin-bottom: 0.75rem;
    padding-bottom: 0.5rem;
    border-bottom: 2px solid #e5e7eb;
  }
  
  .legend-items {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
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
  </style>