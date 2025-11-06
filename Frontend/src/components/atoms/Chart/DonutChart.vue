<!-- components/charts/DonutChart.vue -->
<script setup>
import { ref, watch, computed } from 'vue';
import BoutonIcon from '../Bouton-icon.vue';

const showDetails = ref(true);
const props = defineProps({
    data: {
        type: Array,
        required: true,
        default: () => []
    },
    labels: {
        type: Array,
        required: true,
        default: () => []
    },
    title: {
        type: String,
        default: 'Répartition'
    },
    chartId: {
        type: String,
        default: 'donut-chart'
    },
    height: {
        type: Number,
        default: 400
    },
    colors: {
        type: Array,
        default: () => ['#017AFF', '#F34971', '#FF9382', '#F5C900', '#6C47FF', '#39C0C8', '#00D4AA', '#FF6B8B', '#9C27B0', '#3F51B5']
    },
    type: {
        type: String,
        default: 'donut',
        validator: (value) => ['donut', 'pie'].includes(value)
    },
    donutSize: {
        type: String,
        default: '60%'
    },
    showTotal: {
        type: Boolean,
        default: true
    },
    formatter: {
        type: Function,
        default: (value) => value
    },
    separateLegend: {
        type: Boolean,
        default: false
    },
    legendHeight: {
        type: Number,
        default: 200
    }
});

// Options pour le graphique SANS légende
const chartOptions = computed(() => {
    const baseOptions = {
        chart: {
            type: props.type,
            width: '100%',
            height: props.height,
            id: props.chartId,
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
            }
        },
        colors: props.colors,
        labels: props.labels,
        // ⭐⭐ IMPORTANT : Désactiver la légende dans le chart
        legend: {
            show: !props.separateLegend,
            position: 'bottom'
        },
        dataLabels: {
            enabled: true,
            style: {
                fontSize: '14px',
                fontFamily: 'stara',
                colors: ['#ffffff'],
                fontWeight: 'bold'
            },
            dropShadow: {
                enabled: false
            },
        },
        stroke: {
            width: 0,
            colors: ['#fff']
        },
        fill: {
            opacity: 1
        },
        tooltip: {
            enabled: true,
            theme: 'dark',
            style: {
                fontSize: '12px',
            },
            y: {
                formatter: props.formatter
            },
            marker: {
                show: true,
                fillColors: '#1F2937'
            },
            background: '#1F2937'
        },
        responsive: [{
            breakpoint: 768,
            options: {
                chart: {
                    height: 350,
                    width: '100%'
                },
                dataLabels: {
                    style: {
                        fontSize: '12px'
                    }
                }
            }
        }, {
            breakpoint: 480,
            options: {
                chart: {
                    height: 300,
                    width: '100%'
                },
                dataLabels: {
                    style: {
                        fontSize: '10px'
                    },
                    offset: 5
                },
                plotOptions: {
                    pie: {
                        donut: {
                            size: '50%'
                        }
                    }
                }
            }
        }],
        title: {
            text: props.title,
            align: 'center',
            style: {
                fontFamily: 'stara',
                fontSize: '16px',
                fontWeight: 'bold',
                color: '#373d3f'
            }
        }
    };

    if (props.type === 'donut') {
        baseOptions.plotOptions = {
            pie: {
                donut: {
                    size: props.donutSize,
                    labels: {
                        show: props.showTotal,
                        name: {
                            show: true,
                            fontFamily: 'stara',
                            fontSize: '12px',
                            fontWeight: 500,
                            color: '#373d3f'
                        },
                        value: {
                            show: true,
                            fontFamily: 'sans-serif',
                            fontSize: '18px',
                            fontWeight: 'bold',
                            color: '#373d3f',
                            formatter: props.formatter
                        },
                        total: {
                            show: props.showTotal,
                            label: 'Total',
                            color: '#373d3f',
                            fontFamily: 'stara',
                            fontSize: '12px',
                            fontWeight: 600,
                            formatter: function (w) {
                                const total = w.globals.seriesTotals.reduce((a, b) => a + b, 0);
                                return props.formatter(total);
                            }
                        }
                    }
                },
                expandOnClick: true,
                customScale: 1,
                offsetX: 0,
                offsetY: 0,
                dataLabels: {
                    offset: 0,
                    minAngleToShowLabel: 10
                }
            }
        };
    } else {
        baseOptions.plotOptions = {
            pie: {
                customScale: 1,
                expandOnClick: true,
                offsetX: 0,
                offsetY: 0,
                dataLabels: {
                    offset: 0,
                    minAngleToShowLabel: 10
                }
            }
        };
    }

    return baseOptions;
});

const series = ref([]);

// Mettre à jour les séries
watch(() => props.data, (newData) => {
    series.value = newData.map(item => parseFloat(item) || 0);
}, { immediate: true, deep: true });

// Calculer les pourcentages pour la légende personnalisée
const legendItems = computed(() => {
    const total = props.data.reduce((sum, value) => sum + parseFloat(value || 0), 0);

    return props.labels.map((label, index) => {
        const value = parseFloat(props.data[index] || 0);
        const percentage = total > 0 ? ((value / total) * 100).toFixed(1) : 0;

        return {
            label,
            value,
            percentage,
            color: props.colors[index % props.colors.length],
            formattedValue: props.formatter(value)
        };
    });
});
</script>

<template>
    <transition name="fade">

        <div class="donut-chart-wrapper">
            <!-- Mode légende séparée -->
            <div v-if="separateLegend" class="chart-with-separate-legend">
                <transition name="fade">
                    <div class="chart-container">
                        <div class="graphic-wrapper">
                            <apexchart :type="type" :height="height" :options="chartOptions" :series="series"
                                :id="chartId" />
                        </div>
                        <div class="voir" @click="showDetails = !showDetails">
                            <i class="bi bi-eye"></i>
                            <p v-if="!showDetails">Voir les details</p>
                            <p v-if="showDetails">Masquer les details</p>
                        </div>
                    </div>
                </transition>
                <transition name="fade">
                    <div class="legend-container" v-if="showDetails">
                        <div class="legend-wrapper">
                            <!-- <div class="legend-title">Détails</div> -->
                            <div class="legend-items">
                                <div v-for="(item, index) in legendItems" :key="index" class="legend-item">
                                    <div class="legend-color" :style="{ backgroundColor: item.color }"></div>
                                    <div class="legend-content">
                                        <div class="legend-label">{{ item.label }}</div>
                                        <div class="legend-values">
                                            <span class="legend-value">{{ item.formattedValue }}</span>
                                            <span class="legend-percentage">({{ item.percentage }}%)</span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </transition>
            </div>

            <!-- Mode normal (légende intégrée) -->
            <div v-else class="donut-chart-container">
                <apexchart :type="type" :height="height" :options="chartOptions" :series="series" :id="chartId" />
            </div>
        </div>
    </transition>

</template>

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

    transition: transform 0.3s ease, filter 0.3s ease-in-out;
    
    @media (max-width: 768px) {
        padding: 12px 0;
        justify-content: flex-start;
    }
}

.voir:hover {
    transform: scale(1.02);
    transition: transform 0.3s ease, filter 0.3s ease-in-out;
}

.donut-chart-wrapper:hover {
    transform: scale(1.02);
    transition: transform 0.3s ease, filter 0.3s ease-in-out;
    
    @media (max-width: 768px) {
        transform: none; // Désactiver le scale sur mobile pour éviter les problèmes de layout
    }
}

.donut-chart-wrapper {
    width: 100%;
    background-color: #fff;
    border-radius: $radius-pm;
    animation: appear 0.6s ease-out forwards;
    transition: transform 0.3s ease, filter 0.3s ease-in-out;
    
    @media (max-width: 768px) {
        border-radius: $radius-sm;
    }
}

.donut-chart-container {
    @include position-contenus(flex, flex, center);
    position: relative;
    overflow: hidden;
    animation: appear 0.6s ease-out forwards;
}


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
        
        @media (max-width: 768px) {
            width: 100%;
        }

        .graphic-wrapper {
            padding: 12px;
            border-radius: 8px;
            
            @media (max-width: 768px) {
                padding: 8px;
            }
        }
    }

    .legend-container {
        width: auto;
        height: auto;
        
        @media (max-width: 768px) {
            width: 100%;
        }
        
        .legend-wrapper {
            padding: 12px;
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
                width: 150px;
                display: flex;
                flex-direction: column;
            }

            .legend-item {
                display: flex;
                align-items: center;
                gap: 0.75rem;
                padding: 0.5rem;
                border-radius: 6px;
                transition: background-color 0.2s ease;
                
                @media (max-width: 480px) {
                    gap: 0.5rem;
                    padding: 0.375rem;
                }

                &:hover {
                    background-color: #f8f9fa;
                }

                .legend-color {
                    width: 16px;
                    height: 16px;
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
                        margin-bottom: 0.25rem;
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
    .donut-chart-wrapper {
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
    .donut-chart-wrapper {
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