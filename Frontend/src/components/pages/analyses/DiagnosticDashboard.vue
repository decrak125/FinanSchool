<template>
    <div class="dashboard-container" :class="{ loading: loading }">
        <!-- En-tête du dashboard -->
        <div class="period-selector" hidden>
            <div class="detail-ligne">
                <div class="title">
                    <p class="focus">Dashboard Financier</p>
                    <p class="indicator">Analyse complète de la santé financière</p>
                </div>
                <div class="period-inputs">
                    <input type="date" :value="dateDebut" class="date-input"
                        @input="$emit('update:dateDebut', $event.target.value)" />
                    <span class="separator">→</span>
                    <input type="date" :value="dateFin" class="date-input"
                        @input="$emit('update:dateFin', $event.target.value)" />
                </div>
            </div>
        </div>

        <!-- Score global -->
        <div v-if="dashboard" class="score-global-section">
            <div class="score-card">
                <div class="score-display">
                    <span class="score-value">{{ dashboard.scoreGlobal }}</span>
                    <span class="score-label">/100</span>
                </div>
                <div class="score-details">
                    <span class="score-text">Santé Globale</span>
                    <div class="message-detail">
                        <p>{{ getInterpretationScore(dashboard.scoreGlobal) }}</p>
                    </div>
                </div>
                <div class="iconbtn">
                    <i class="bi bi-eye-fill" @click="voir = !voir" />
                </div>
            </div>
        </div>

        <!-- Grille des aspects -->
        <div v-if="dashboard && voir" class="aspects-grid">
            <div v-for="aspect in dashboard.aspects" :key="aspect.code" class="aspect-card">
                <div class="aspect-header">
                    <p class="aspect-title">{{ aspect.nom }}</p>
                    <div class="aspect-score" :style="{ color: getScoreColor(aspect.score) }">
                        {{ aspect.score }}
                    </div>
                </div>

                <!-- Détails de l'aspect -->
                <!-- <div class="details-comparaison">
                    <div v-if="aspect.kpis.length > 0">
                        <div v-for="kpi in aspect.kpis" :key="kpi.nom" class="detail-ligne">
                            <span class="label">{{ kpi.nom }}</span>
                            <span class="valeur" :class="getKpiClass(kpi)">
                                {{ formatValue(kpi.valeur) }}
                                <span v-if="kpi.unite">{{ kpi.unite }}</span>
                            </span>
                        </div>
                    </div>

                    

                    
                </div> -->
                <!-- <span class="total-label">Diagnostic</span> -->
                <span class="total-value" :class="getDiagnosticClass(aspect.score)">
                    {{ aspect.diagnostic }}
                </span>
            </div>

        </div>

        <!-- État de chargement -->
        <div v-else-if="loading" class="loading-state">
            <div class="loader">
                <span class="bar"></span>
                <span class="bar"></span>
                <span class="bar"></span>
            </div>
            <!-- <p>Calcul du diagnostic en cours...</p> -->
        </div>

        <!-- Sélecteur de période -->
    </div>
</template>

<script>
import { ref, watch, onMounted } from 'vue';

export default {
    name: 'DashboardFinancier',

    props: {
        dateDebut: {
            type: String,
            required: false,
            default: () => {
                const today = new Date();
                const firstDay = new Date(today.getFullYear(), 0, 1);
                return firstDay.toISOString().split('T')[0];
            }
        },
        dateFin: {
            type: String,
            required: false,
            default: () => {
                return new Date().toISOString().split('T')[0];
            }
        }
    },

    setup(props) {
        const voir = ref(false);
        const dashboard = ref(null);
        const loading = ref(false);
        const error = ref(null);

        // Fonction pour charger le dashboard
        const loadDashboard = async () => {
            loading.value = true;
            dashboard.value = null;
            error.value = null;

            try {
                // Importer dynamiquement le service
                const DiagnosticService = await import('@/composables/diagnosticService');
                dashboard.value = await DiagnosticService.default.getDashboardComplet(
                    props.dateDebut,
                    props.dateFin
                );
            } catch (err) {
                console.error('Erreur dashboard:', err);
                error.value = 'Impossible de charger les données financières';
            } finally {
                loading.value = false;
            }
        };

        // Formater une date au format fr-FR
        const formatDate = (dateStr) => {
            if (!dateStr) return '';
            try {
                const date = new Date(dateStr);
                return date.toLocaleDateString('fr-FR', {
                    day: '2-digit',
                    month: 'short',
                    year: 'numeric'
                });
            } catch {
                return dateStr;
            }
        };

        // Formater une heure
        const formatTime = (dateStr) => {
            if (!dateStr) return '';
            try {
                const date = new Date(dateStr);
                return date.toLocaleTimeString('fr-FR', {
                    hour: '2-digit',
                    minute: '2-digit'
                });
            } catch {
                return '';
            }
        };

        // Formater une valeur numérique
        const formatValue = (value) => {
            if (typeof value !== 'number') return value;
            return value.toFixed(2);
        };

        // Interprétation du score global
        const getInterpretationScore = (score) => {
            if (score >= 80) return 'Excellente santé financière';
            if (score >= 60) return 'Santé financière satisfaisante';
            if (score >= 40) return 'Santé financière à surveiller';
            if (score >= 20) return 'Situation financière fragile';
            return 'Situation financière critique';
        };

        // Couleur du score
        const getScoreColor = (score) => {
            if (score >= 80) return '#4CAF50';
            if (score >= 60) return '#01CC00';
            if (score >= 40) return '#F89400';
            if (score >= 20) return '#FF5722';
            return '#FE0000';
        };

        // Classe CSS pour un KPI
        const getKpiClass = (kpi) => {
            if (!kpi?.niveau) return '';
            if (kpi.niveau === 'mauvais' || kpi.niveau === 'critique') {
                return 'negative';
            }
            if (kpi.niveau === 'bon') {
                return 'moyen';
            }
            if (kpi.niveau === 'excellent') {
                return 'positive';
            }

            return '';
        };

        // Classe CSS pour le diagnostic
        const getDiagnosticClass = (score) => {
            if (score >= 60) return 'positive';
            if (score >= 40) return 'moyen';
            return 'negative';
        };

        // Formater une date pour input type="date"
        const formatDateForInput = (date) => {
            if (!date) return '';
            try {
                const d = new Date(date);
                return d.toISOString().split('T')[0];
            } catch {
                return '';
            }
        };

        // Observer les changements de props
        watch(
            () => [props.dateDebut, props.dateFin],
            () => {
                loadDashboard();
            }
        );

        // Chargement initial
        onMounted(() => {
            loadDashboard();
        });

        // Exposer les variables et méthodes au template
        return {
            voir,
            dashboard,
            loading,
            error,
            formatDate,
            formatTime,
            formatValue,
            getInterpretationScore,
            getScoreColor,
            getKpiClass,
            getDiagnosticClass,
            formatDateForInput,
            loadDashboard
        };
    }
};
</script>
<style lang="scss" scoped>
.loader {
  display: flex;
  align-items: center;
  align-self: center;
  justify-content: center;
}

.bar {
  display: inline-block;
  width: 3px;
  height: 12px;
  background-color: rgba(255, 255, 255, .5);
  border-radius: 10px;
  animation: scale-up4 1s linear infinite;
}

.bar:nth-child(2) {
  height: 20px;
  margin: 0 5px;
  animation-delay: .25s;
}

.bar:nth-child(3) {
  animation-delay: .5s;
}

@keyframes scale-up4 {
  20% {
    background-color: #ffff;
    transform: scaleY(1);
  }

  40% {
    transform: scaleY(0.5);
  }
}


.iconbtn {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 42px;
    height: 42px;
    border-radius: 50%;
    @include popupglass();
    cursor: pointer;

    i {
        color: $jaune;
        font-size: 20px;
    }
}

.dashboard-container {
    @include popupglass();
    width: 100%;
    align-items: flex-start;
    justify-content: space-between;
    display: flex;
    flex-direction: column;
    font-family: Stara;
    margin: 0;
    padding: 32px;
    gap: 24px;
    border-radius: $radius-pm;
    transition: transform 0.3s ease, filter 0.3s ease-in-out;

    &.loading {
        opacity: 0.7;
        pointer-events: none;
    }
}

.title {
    display: flex;
    flex-direction: column;
    margin: 0;
    padding: 0;
    gap: 4px;
    width: 100%;
}

.focus {
    font-family: $stara-black;
    font-size: 28px;
    margin: 0;
    padding: 0;
    line-height: 1.2;
    color: $dark;
}

.indicator {
    font-family: $stara-medium;
    font-size: 14px;
    color: $dark;
    margin: 0;
    padding: 0;
    opacity: 0.8;
}

/* Score global */
.score-global-section {
    display: flex;
    justify-content: space-between;
    width: 100%;
    // background: rgba(255, 255, 255, 0.5);
    // padding: 20px;
    border-radius: $radius-pm;
    // border: 1px solid rgba($gris, 0.1);
}

.score-card {
    display: flex;
    width: 100%;
    justify-content: space-between;
    align-items: center;
    gap: 20px;
    // margin-bottom: 16px;
}

.score-display {
    display: flex;
    align-items: baseline;
    gap: 4px;
}

.score-value {
    font-family: $stara-black;
    font-size: 48px;
    color: $dark;
    line-height: 1;
}

.score-label {
    font-family: $stara-medium;
    font-size: 20px;
    color: $gris;
}

.score-details {
    display: flex;
    flex-direction: column;
    gap: 4px;
}

.score-text {
    font-family: $stara-bold;
    font-size: 16px;
    color: $dark;
}

.score-period {
    font-family: $stara-medium;
    font-size: 13px;
    color: $gris;
}

/* Grille des aspects */
.aspects-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 20px;
    width: 100%;
}

.aspect-card {
    // @include glass();
    // background: rgba(255, 255, 255, 0.5);
    border-radius: $radius-pm;
    padding: 20px;
    display: flex;
    flex-direction: column;
    gap: 16px;
}

.aspect-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    // padding-bottom: 12px;
    border-bottom: 2px solid rgba($gris, 0.1);
}

.aspect-title {
    font-family: $stara-bold;
    font-size: 18px;
    color: $dark;
    margin: 0;
}

.aspect-score {
    font-family: $stara-black;
    font-size: 32px;
    font-weight: bold;
}

/* Détails (identique à votre exemple) */
.details-comparaison {
    display: flex;
    flex-direction: column;
    gap: 8px;
}

.detail-ligne {
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-size: 13px;
    padding: 8px 0;
    border-bottom: 1px solid rgba($gris, 0.1);

    &:last-child {
        border-bottom: none;
    }
}

.label {
    font-family: $stara-medium;
    color: $gris;
    flex: 1;
}

.valeur {
    font-family: $stara-bold;
    color: $dark;
    text-align: right;
    flex: 1;

    &.positive {
        color: $primary;
    }

    &.moyen {
        color: $jaune;
    }

    &.negative {
        color: $rouge;
    }
}

.no-data {
    opacity: 0.6;
}

.total-item {
    background: rgba(255, 255, 255, 0.3);
    padding: 10px 12px;
    border-radius: $radius-sm;
    margin-top: 8px;

    &.highlight {
        background: rgba(255, 255, 255, 0.5);
        border-left: 3px solid $primary;
    }
}

.total-label {
    font-family: $stara-medium;
    color: $gris;
}

.total-value {
    font-family: $stara-bold;
    font-size: 12px;
    color: $dark;

    // text-align: right;

    &.positive {
        color: $vert;
    }

    &.moyen {
        color: $jaune;
    }

    &.negative {
        color: $rouge;
    }
}

/* Message détail */
.message-detail {
    p {
        font-family: $stara-medium;
        font-size: 12px;
        line-height: 1.4;
        color: $gris;
        margin: 0;
        text-align: center;
    }
}

/* Sélecteur de période */
.period-selector {
    width: 100%;
    background: rgba(255, 255, 255, 0.5);
    padding: 16px;
    border-radius: $radius-pm;
    margin-top: 8px;
}

.period-inputs {
    display: flex;
    align-items: center;
    gap: 12px;
}

.date-input {
    font-family: $stara-medium;
    font-size: 13px;
    padding: 8px 12px;
    border: 1px solid rgba($gris, 0.3);
    border-radius: $radius-sm;
    background: white;
    color: $dark;

    &:focus {
        outline: none;
        border-color: $primary;
    }
}

.separator {
    font-family: $stara-medium;
    color: $gris;
    font-size: 14px;
}

/* État de chargement */
.loading-state {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    width: 100%;
    padding: 20px 0;

    // .loader {
    //     border: 3px solid rgba($gris, 0.2);
    //     border-top: 3px solid $primary;
    //     border-radius: 50%;
    //     width: 40px;
    //     height: 40px;
    //     animation: spin 1s linear infinite;
    //     // margin-bottom: 16px;
    // }

    p {
        font-family: $stara-medium;
        color: $gris;
        font-size: 14px;
    }
}

@keyframes spin {
    0% {
        transform: rotate(0deg);
    }

    100% {
        transform: rotate(360deg);
    }
}

/* Responsive */
@media (max-width: 768px) {
    .dashboard-container {
        padding: 20px;
        gap: 20px;
    }

    .focus {
        font-size: 22px;
    }

    .aspects-grid {
        grid-template-columns: 1fr;
        gap: 16px;
    }

    .aspect-card {
        padding: 16px;
    }

    .score-value {
        font-size: 36px;
    }

    .period-inputs {
        flex-direction: column;
        gap: 8px;
    }

    .separator {
        display: none;
    }
}
</style>