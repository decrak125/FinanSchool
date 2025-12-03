<script setup>
import Texte from '../Texte.vue';
import { computed } from 'vue';

const props = defineProps({
    dataComparaison: { 
        type: Object, 
        default: null 
    },
    
    loading: { 
        type: Boolean, 
        default: false 
    },
    
    // Type: 'ecart-annuel', 'centre-augmentation', 'centre-diminution'
    type: {
        type: String,
        default: 'ecart-annuel',
        validator: (value) => ['ecart-annuel', 'centre-augmentation', 'centre-diminution'].includes(value)
    },
    
    // Nouveau prop pour le type d'indicateur
    idType: {
        type: Number,
        default: 2 // Par défaut, on considère que l'augmentation est positive
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

// Computed: Titre principal
const titrePrincipal = computed(() => {
    if (!props.dataComparaison) return 'Comparaison annuelle';
    
    switch (props.type) {
        case 'ecart-annuel':
            return `Écart ${props.dataComparaison.annee1}-${props.dataComparaison.annee2}`;
        case 'centre-augmentation':
            return 'Centre avec la plus forte augmentation';
        case 'centre-diminution':
            return 'Centre avec la plus forte diminution';
        default:
            return 'Analyse annuelle';
    }
});

// Computed: Sous-titre
const sousTitre = computed(() => {
    if (!props.dataComparaison) return '';
    
    switch (props.type) {
        case 'ecart-annuel':
            return `Évolution annuelle`;
        case 'centre-augmentation':
            return props.dataComparaison.centre || '';
        case 'centre-diminution':
            return props.dataComparaison.centre || '';
        default:
            return '';
    }
});

// Computed: Pourcentage formaté
const pourcentageFormate = computed(() => {
    if (!props.dataComparaison) return '+0.0%';
    
    const pourcentage = props.dataComparaison.pourcentage || 0;
    return `${pourcentage >= 0 ? '+' : ''}${Math.abs(pourcentage).toFixed(1)}%`;
});

// Computed: Classe pour le pourcentage
const pourcentageClass = computed(() => {
    if (!props.dataComparaison) return 'trend-neutral';
    
    const pourcentage = props.dataComparaison.pourcentage || 0;
    if (pourcentage > 0) return 'trend-up';
    if (pourcentage < 0) return 'trend-down';
    return 'trend-neutral';
});

// Computed: Détermine si la différence est positive selon le type d'indicateur
const isDifferencePositive = computed(() => {
    if (!props.dataComparaison) return true;
    
    // Logique selon le type
    switch (props.type) {
        case 'ecart-annuel':
            // Pour 'ecart-annuel', utilise la valeur existante ou recalcule
            if (props.dataComparaison.isPositive !== undefined) {
                return props.dataComparaison.isPositive;
            }
            return props.dataComparaison.difference >= 0;
            
        case 'centre-augmentation':
        case 'centre-diminution':
            // Pour les autres types, utilise le pourcentage
            const pourcentage = props.dataComparaison.pourcentage || 0;
            
            // Applique la logique selon id_type
            if (props.idType === 1) {
                // id_type = 1 : l'augmentation est négative (ex: pertes, coûts)
                return pourcentage <= 0;
            } else {
                // id_type = 2 : l'augmentation est positive (ex: bénéfices, ventes)
                return pourcentage >= 0;
            }
            
        default:
            return true;
    }
});

// Computed: Détails des montants avec logique inversée selon id_type
const detailsMontants = computed(() => {
    if (!props.dataComparaison) return null;
    
    switch (props.type) {
        case 'ecart-annuel':
            return {
                annee1: props.dataComparaison.annee1,
                annee2: props.dataComparaison.annee2,
                montant1: props.dataComparaison.totalAnnee1 || 0,
                montant2: props.dataComparaison.totalAnnee2 || 0,
                difference: props.dataComparaison.difference || 0,
                isPositive: isDifferencePositive.value
            };
        case 'centre-augmentation':
        case 'centre-diminution':
            return {
                annee1: props.dataComparaison.annee1,
                annee2: props.dataComparaison.annee2,
                montant1: props.dataComparaison.montantAnnee1 || 0,
                montant2: props.dataComparaison.montantAnnee2 || 0,
                difference: props.dataComparaison.difference || 0,
                isPositive: isDifferencePositive.value
            };
        default:
            return null;
    }
});
</script>

<template>
    <div class="container" :class="{ loading: loading }">
        <div class="title">
            <p class="focus">{{ sousTitre }}</p>
            <p class="indicator">{{ titrePrincipal }}</p>
        </div>
        
        <!-- Section pourcentage -->
        <div v-if="dataComparaison" class="comparaison-content">
            <div class="variation-display">
                <Texte :texte="(detailsMontants.isPositive ? '+' : '-') + formatMontant(Math.abs(detailsMontants.difference))" :type="'title-dark'" />
                <Texte :texte="'Ar'" :type="'bold-dark'" />
            </div>
            
            <!-- Détails des montants -->
            <div v-if="detailsMontants" class="montants-comparaison">
                <div class="montant-ligne">
                    <span class="label">Année {{ detailsMontants.annee1 }}:</span>
                    <span class="valeur">{{ formatMontant(detailsMontants.montant1) }} Ar</span>
                </div>
                <div class="montant-ligne">
                    <span class="label">Année {{ detailsMontants.annee2 }}:</span>
                    <span class="valeur">{{ formatMontant(detailsMontants.montant2) }} Ar</span>
                </div>
                <div class="difference-ligne">
                    <span class="label">Différence:</span>
                    
                    <span v-if="idType === 2" :class="['difference', detailsMontants.isPositive ? 'positive' : 'negative']">
                        {{ pourcentageFormate }}
                    </span>
                    <span v-else :class="['difference', detailsMontants.isPositive ? 'negative' : 'positive']">
                        {{ pourcentageFormate }}
                    </span>
                </div>
            </div>
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
    // flex-direction: column;
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

/* Classes de variation */
.trend-up {
    color: $vert;
    font-family: $stara-bold;
    font-size: 48px;
    font-style: normal;
    line-height: normal;
    margin: 0;
}

.trend-down {
    color: $rouge;
    font-family: $stara-bold;
    font-size: 48px;
    font-style: normal;
    line-height: normal;
    margin: 0;
}

.trend-neutral {
    color: $gris;
    font-family: $stara-bold;
    font-size: 48px;
    font-style: normal;
    line-height: normal;
    margin: 0;
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