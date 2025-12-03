<script setup>
import Texte from '../Texte.vue';
import { computed } from 'vue';

const props = defineProps({
    dataMois: { 
        type: Object, 
        default: null 
    },
    
    loading: { 
        type: Boolean, 
        default: false 
    },
    
    // id_type: 1 = pire mois (coûts), 2 = meilleur mois (bénéfices)
    idType: {
        type: Number,
        default: 2
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

// Computed: Titre principal (change selon id_type)
const titrePrincipal = computed(() => {
    return props.idType === 1 ? 'Pire mois' : 'Meilleur mois';
});

// Computed: Sous-titre (le mois)
const sousTitre = computed(() => {
    if (!props.dataMois) return '';
    return props.dataMois.nomMois || '';
});

// Computed: Montant principal à afficher
const montantPrincipal = computed(() => {
    if (!props.dataMois) return 0;
    return props.dataMois.montant || 0;
});

// Computed: Évolution formatée
const evolutionFormatee = computed(() => {
    if (!props.dataMois) return '+0.0%';
    
    const evolution = props.dataMois.evolution || 0;
    return `${evolution >= 0 ? '+' : ''}${Math.abs(evolution).toFixed(1)}%`;
});

// Computed: Classe pour l'évolution (toujours positif pour meilleur mois, négatif pour pire mois)
const evolutionClass = computed(() => {
    return props.idType === 1 ? 'negative' : 'positive';
});

// Computed: Détails des données
const detailsDonnees = computed(() => {
    if (!props.dataMois) return null;
    
    return {
        label1: 'Mois:',
        valeur1: props.dataMois.nomMois || '',
        label2: 'Centre:',
        valeur2: props.dataMois.centre || 'Tous',
        labelDiff: 'Augmentation:',
        isPositive: props.idType === 2 // Positif pour idType=2, négatif pour idType=1
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
        <div v-if="dataMois" class="comparaison-content">
            <div class="variation-display">
                <Texte :texte="'+' + formatMontant(Math.abs(montantPrincipal))" :type="'title-dark'" />
                <Texte :texte="'Ar'" :type="'bold-dark'" />
            </div>
            
            <!-- Détails des données -->
            <div v-if="detailsDonnees" class="montants-comparaison">
                <div class="montant-ligne">
                    <span class="label">{{ detailsDonnees.label1 }}</span>
                    <span class="valeur">{{ detailsDonnees.valeur1 }}</span>
                </div>
                <div class="montant-ligne">
                    <span class="label">{{ detailsDonnees.label2 }}</span>
                    <span class="valeur">{{ detailsDonnees.valeur2 }}</span>
                </div>
                <div class="difference-ligne">
                    <span class="label">{{ detailsDonnees.labelDiff }}</span>
                    <span :class="['difference', detailsDonnees.isPositive ? 'positive' : 'negative']">
                        {{ evolutionFormatee }}
                    </span>
                </div>
            </div>
        </div>
        
        <!-- État de chargement -->
        <div v-else-if="loading" class="loading-state">
            <div class="loader"></div>
            <p>Chargement des données...</p>
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

/* Styles pour le mode comparaison */
.comparaison-content {
    width: 100%;
    display: flex;
    flex-direction: column;
    gap: 16px;
    margin-top: 8px;
}

.variation-display {
    display: flex;
    align-items: center;
    justify-content: baseline;
    gap: 4px;
}

.montants-comparaison {
    display: flex;
    flex-direction: column;
    gap: 8px;
    background: rgba(255, 255, 255, 0.5);
    padding: 16px;
    border-radius: $radius-pm;
    margin-top: 8px;
}

.montant-ligne, .difference-ligne {
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-size: 14px;
}

.label {
    font-family: $stara-medium;
    color: $gris;
}

.valeur {
    font-family: $stara-bold;
    color: $dark;
}

.difference {
    font-family: $stara-bold;
    padding: 4px 12px;
    border-radius: $radius-sm;
    
    &.positive {
        background-color: rgba($vert, 0.1);
        color: darken($vert, 10%);
    }
    
    &.negative {
        background-color: rgba($rouge, 0.1);
        color: darken($rouge, 10%);
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
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
}

/* Responsive */
@media (max-width: 768px) {
    .container {
        height: auto;
        padding: 20px;
        min-height: 350px;
    }
    
    .focus {
        font-size: 22px;
    }
}
</style>