<script setup>
import Texte from '../Texte.vue';
import { computed } from 'vue';

const props = defineProps({
    dataAnalyse: {
        type: Object,
        default: null
    },

    loading: {
        type: Boolean,
        default: false
    },

    // Année analysée
    annee: {
        type: String,
        default: new Date().getFullYear().toString()
    }
})

// Fonction pour formater les montants
const formatMontant = (value) => {
    if (value === null || value === undefined) return '0';
    return new Intl.NumberFormat('mg-MG', {
        minimumFractionDigits: 0,
        maximumFractionDigits: 0
    }).format(value);
};

// Fonction pour formater les pourcentages
const formatPourcentage = (value) => {
    if (value === null || value === undefined) return '0%';
    return `${value >= 0 ? '+' : ''}${value.toFixed(1)}%`;
};

// Computed: Titre principal
const titrePrincipal = computed(() => {
    if (!props.dataAnalyse) return 'Analyse Rentabilité';

    const moisRentables = props.dataAnalyse.moisRentables || 0;
    const totalMois = props.dataAnalyse.totalMois || 12;

    return `Rentabilité ${props.annee}`;
});

// Computed: Sous-titre (le message clé)
const sousTitre = computed(() => {
    if (!props.dataAnalyse) return '';

    const pointBascule = props.dataAnalyse.pointBascule;
    const moisRentables = props.dataAnalyse.moisRentables || 0;
    const totalMois = props.dataAnalyse.totalMois || 12;

    if (pointBascule) {
        return `Rentable à partir de ${pointBascule.nomMois}`;
    } else if (moisRentables === 0) {
        return 'Aucun mois rentable';
    } else if (moisRentables === totalMois) {
        return 'Rentable toute l\'année';
    } else {
        return `${moisRentables}/${totalMois} mois rentables`;
    }
});

// Computed: Message détaillé
const messageDetail = computed(() => {
    if (!props.dataAnalyse) return '';

    const pointBascule = props.dataAnalyse.pointBascule;
    const moisRentables = props.dataAnalyse.moisRentables || 0;
    const totalMois = props.dataAnalyse.totalMois || 12;
    const totalProfits = props.dataAnalyse.totalProfits || 0;
    const totalCosts = props.dataAnalyse.totalCosts || 0;
    const soldeAnnuel = totalProfits - totalCosts;

    let message = '';

    if (pointBascule) {
        message += `L'entreprise devient rentable en ${pointBascule.nomMois} `;
        message += `avec ${totalMois - moisRentables} mois de déficit. `;
    }

    if (moisRentables > 0) {
        const pourcentageRentable = ((moisRentables / totalMois) * 100).toFixed(0);
        message += `${pourcentageRentable}% des mois sont profitables. `;
    }

    return message;
});

// Computed: Détails pour le tableau
const detailsAnalyse = computed(() => {
    if (!props.dataAnalyse) return null;

    const pointBascule = props.dataAnalyse.pointBascule;
    const moisRentables = props.dataAnalyse.moisRentables || 0;
    const totalMois = props.dataAnalyse.totalMois || 12;
    const totalProfits = props.dataAnalyse.totalProfits || 0;
    const totalCosts = props.dataAnalyse.totalCosts || 0;
    const soldeAnnuel = totalProfits - totalCosts;
    const meilleurMois = props.dataAnalyse.meilleurMois;
    const pireMois = props.dataAnalyse.pireMois;

    return {
        pointBascule: pointBascule ? `${pointBascule.nomMois} (après ${pointBascule.moisAvantBascule} mois)` : 'Non atteint',
        moisRentables: `${moisRentables}/${totalMois} mois`,
        margeAnnuelle: totalCosts > 0 ? ((soldeAnnuel / totalCosts) * 100).toFixed(1) + '%' : 'N/A',
        meilleurMois: meilleurMois ? `${meilleurMois.nomMois}: +${formatMontant(meilleurMois.solde)}` : 'N/A',
        pireMois: pireMois ? `${pireMois.nomMois}: ${formatMontant(pireMois.solde)}` : 'N/A',
        totalProfits: formatMontant(totalProfits),
        totalCosts: formatMontant(totalCosts),
        soldeAnnuel: formatMontant(soldeAnnuel)
    };
});
</script>

<template>
    <div class="container" :class="{ loading: loading }">
        <div class="title">
            <p class="focus">{{ sousTitre }}</p>
            <p class="indicator">{{ titrePrincipal }}</p>
        </div>
        <!-- Section principale -->
        <div v-if="dataAnalyse" class="analyse-content">            <!-- Détails de l'analyse -->
            <div v-if="detailsAnalyse" class="details-comparaison">
                <div class="detail-ligne">
                    <span class="label">Point de bascule:</span>
                    <span class="valeur">{{ detailsAnalyse.pointBascule }}</span>
                </div>
                <div class="detail-ligne">
                    <span class="label">Mois rentables:</span>
                    <span class="valeur">{{ detailsAnalyse.moisRentables }}</span>
                </div>
                <div class="detail-ligne">
                    <span class="label">Meilleur mois:</span>
                    <span class="valeur positive">{{ detailsAnalyse.meilleurMois }} Ar</span>
                </div>
                <div class="detail-ligne">
                    <span class="label">Pire mois:</span>
                    <span class="valeur negative">{{ detailsAnalyse.pireMois }} Ar</span>
                </div>
            </div>
            <div class="message-detail">
                <p>{{ messageDetail }}</p>
            </div>

        </div>

        <!-- État de chargement -->
        <div v-else-if="loading" class="loading-state">
            <div class="loader"></div>
            <p>Analyse en cours...</p>
        </div>
    </div>
</template>

<style lang="scss" scoped>
.container {
    @include popupglass();
    width: 100%;
    height: 400px;
    align-items: flex-start;
    justify-content: space-between;
    display: flex;
    flex-direction: column;
    font-family: Stara;
    margin: 0;
    padding: 32px;
    gap: 16px;
    border-radius: $radius-pm;
    transition: transform 0.3s ease, filter 0.3s ease-in-out;

    &.loading {
        opacity: 0.7;
        pointer-events: none;
    }
}

.focus {
    font-family: $stara-black;
    font-size: 28px;
    margin: 0;
    padding: 0;
    line-height: 1.2;
}

.indicator {
    font-family: $stara-medium;
    font-size: 14px;
    color: $dark;
    margin: 0;
    padding: 0;
}

.title {
    display: flex;
    flex-direction: column;
    margin: 0;
    padding: 0;
    gap: 4px;
}

.analyse-content {
    width: 100%;
    display: flex;
    flex-direction: column;
    gap: 16px;
}

.valeur-display {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    gap: 4px;
}

.message-detail {
    // background: rgba(255, 255, 255, 0.5);
    // padding: 0px 16px;
    // border-radius: $radius-sm;
    // margin-top: 8px;

    p {
        font-family: $stara-medium;
        font-size: 13px;
        line-height: 1.4;
        color: $dark;
        margin: 0;
    }
}

.details-comparaison {
    display: flex;
    flex-direction: column;
    gap: 8px;
    background: rgba(255, 255, 255, 0.5);
    padding: 16px;
    border-radius: $radius-pm;
    margin-top: 8px;
}

.detail-ligne {
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-size: 13px;
    padding: 6px 0;
    border-bottom: 1px solid rgba($gris, 0.1);

    &:last-child {
        border-bottom: none;
    }
}

.label {
    font-family: $stara-medium;
    color: $gris;
}

.valeur {
    font-family: $stara-bold;
    color: $dark;

    &.positive {
        color: $vert;
    }

    &.negative {
        color: $rouge;
    }
}

.totals-section {
    margin-top: 12px;
    padding-top: 12px;
    border-top: 2px solid rgba($gris, 0.2);
}

.total-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-size: 13px;
    padding: 6px 0;

    &.highlight {
        background: rgba(255, 255, 255, 0.3);
        padding: 8px 12px;
        border-radius: $radius-sm;
        margin-top: 4px;
    }
}

.total-label {
    font-family: $stara-medium;
    color: $gris;
}

.total-value {
    font-family: $stara-bold;
    color: $dark;

    &.positive {
        color: $vert;
    }

    &.negative {
        color: $rouge;
    }
}

.loading-state {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    flex-grow: 1;
    width: 100%;

    .loader {
        border: 3px solid rgba($gris, 0.2);
        border-top: 3px solid $primary;
        border-radius: 50%;
        width: 40px;
        height: 40px;
        animation: spin 1s linear infinite;
        margin-bottom: 16px;
    }

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
    .container {
        height: auto;
        padding: 20px;
        min-height: 380px;
    }

    .focus {
        font-size: 22px;
    }

    .message-detail p {
        font-size: 12px;
    }

    .detail-ligne,
    .total-item {
        font-size: 12px;
    }
}
</style>