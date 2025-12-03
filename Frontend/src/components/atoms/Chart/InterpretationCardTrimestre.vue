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

// Computed: Nom du trimestre
const trimestreNom = computed(() => {
    if (!props.dataComparaison) return '';
    
    // Convertir le numéro de trimestre en nom
    const trimNum = props.dataComparaison.trimestre || props.dataComparaison.mois;
    if (!trimNum) return '';
    
    const trimestres = ['1er Trimestre', '2ème Trimestre', '3ème Trimestre', '4ème Trimestre'];
    const index = parseInt(trimNum) - 1;
    return index >= 0 && index < 4 ? trimestres[index] : `Trimestre ${trimNum}`;
});

// Computed: Texte du titre
const titreTexte = computed(() => {
    if (!props.dataComparaison) return 'Plus forte variation trimestrielle';
    
    const pourcentage = props.dataComparaison.pourcentage || 0;
    return pourcentage >= 0 ? 'Trimestre avec la plus forte augmentation' : 'Trimestre avec la plus forte diminution';
});

// Computed: Pourcentage formaté
const pourcentageFormate = computed(() => {
    if (!props.dataComparaison) return '+0.0%';
    
    const pourcentage = props.dataComparaison.pourcentage || 0;
    return `${pourcentage >= 0 ? '+' : ''}${pourcentage.toFixed(1)}%`;
});

// Computed: Classe pour le pourcentage
const pourcentageClass = computed(() => {
    if (!props.dataComparaison) return 'trend-neutral';
    
    const pourcentage = props.dataComparaison.pourcentage || 0;
    if (pourcentage > 0) return 'trend-up';
    if (pourcentage < 0) return 'trend-down';
    return 'trend-neutral';
});

// Computed: Détails des montants
const detailsMontants = computed(() => {
    if (!props.dataComparaison) return null;
    
    const trimPrecedent = props.dataComparaison.trimestrePrecedent || '';
    const valeurPrecedente = props.dataComparaison.valeurTrimestrePrecedent || 0;
    const valeurActuelle = props.dataComparaison.valeurTrimestreActuel || 0;
    const difference = props.dataComparaison.difference || 0;
    const pourcentage = props.dataComparaison.pourcentage || 0;
    
    return {
        trimPrecedent: trimPrecedent ? `T${trimPrecedent}` : 'trimestre précédent',
        valeurPrecedente,
        valeurActuelle,
        difference,
        isPositive: pourcentage >= 0
    };
});
</script>

<template>
    <div class="container" :class="{ loading: loading }">
        <div class="title">
            <p class="focus">{{ trimestreNom }}</p>
            <p class="indicator">{{ titreTexte }}</p>
        </div>
        
        <!-- Section pourcentage -->
        <div v-if="dataComparaison" class="comparaison-content">
            <div class="variation-display">
                <Texte :texte="pourcentageFormate" :type="'title-dark'" />
            </div>
            
            <!-- Détails des montants -->
            <div v-if="detailsMontants" class="montants-comparaison">
                <div class="montant-ligne">
                    <span class="label">Trimestre précédent:</span>
                    <span class="valeur">{{ formatMontant(detailsMontants.valeurPrecedente) }} Ar</span>
                </div>
                <div class="montant-ligne">
                    <span class="label">{{ trimestreNom }}:</span>
                    <span class="valeur">{{ formatMontant(detailsMontants.valeurActuelle) }} Ar</span>
                </div>
                <div class="difference-ligne">
                    <span class="label">Différence:</span>
                    <span v-if="idType == 2" :class="['difference', detailsMontants.isPositive ? 'positive' : 'negative']">
                        {{ detailsMontants.isPositive ? '+' : '-' }}{{ formatMontant(Math.abs(detailsMontants.difference)) }} Ar
                    </span>
                    <span v-else :class="['difference', detailsMontants.isPositive ? 'negative' : 'positive']">
                        {{ detailsMontants.isPositive ? '+' : '-' }}{{ formatMontant(Math.abs(detailsMontants.difference)) }} Ar
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
    flex-direction: column;
    align-items: flex-start;
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