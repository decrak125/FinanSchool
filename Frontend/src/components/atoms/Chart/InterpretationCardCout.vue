<script setup>
import Texte from '../Texte.vue';
import { computed } from 'vue';

const props = defineProps({
    texte: String,
    chiffre: { type: [Number, String] },
    icon: String,
    iconColor: String,
    format: String,
    negative: Boolean,
    loading: { type: Boolean, default: false },
    variation: { type: [Number, String], default: null },
    colorVariation: String,
    interpretation: String,
    type: { type: String, default: 'simple' }, // 'simple' ou 'comparaison-mois'
    dataComparaison: { type: Object, default: null }, // Nouvelle prop pour les données de comparaison
    idType: {
        type: Number,
        default: 2 // Par défaut, on considère que l'augmentation est positive
    }
})

// Computed pour formater le chiffre selon le format
const formattedChiffre = computed(() => {
    if (props.chiffre === null || props.chiffre === undefined) return '0';
    
    if (props.format === 'currency') {
        return new Intl.NumberFormat('mg-MG', {
            minimumFractionDigits: 0,
            maximumFractionDigits: 0
        }).format(Number(props.chiffre));
    } else if (props.format === 'percent') {
        return `${Number(props.chiffre).toFixed(1)}%`;
    } else {
        return props.chiffre.toString();
    }
});

// Computed pour déterminer la classe de variation
const variationClass = computed(() => {
    if (props.colorVariation) return props.colorVariation;
    
    if (props.variation) {
        const variationNum = Number(props.variation);
        if (variationNum > 0) return 'trend-up';
        if (variationNum < 0) return 'trend-down';
        return 'trend-neutral';
    }
    
    return 'trend-neutral';
});

// Computed pour formater la variation
const formattedVariation = computed(() => {
    if (props.variation === null || props.variation === undefined) return '';
    
    const variationNum = Number(props.variation);
    if (props.format === 'currency') {
        const sign = variationNum >= 0 ? '+' : '';
        return `${sign}${new Intl.NumberFormat('mg-MG', {
            minimumFractionDigits: 0,
            maximumFractionDigits: 0
        }).format(variationNum)}`;
    } else if (props.format === 'percent') {
        return `${variationNum >= 0 ? '+' : ''}${variationNum.toFixed(1)}%`;
    } else {
        return `${variationNum >= 0 ? '+' : ''}${variationNum}`;
    }
});

// Computed pour l'interprétation selon le type
const computedInterpretation = computed(() => {
    if (props.type === 'comparaison-mois' && props.dataComparaison) {
        const data = props.dataComparaison;
        const isIncrease = data.pourcentage >= 0;
        const variationText = isIncrease ? 'augmenté' : 'diminué';
        
        return `${data.moisNom} a ${variationText} de ${Math.abs(data.pourcentage).toFixed(1)}% 
                par rapport au mois précédent (${formatMontant(data.valeurMoisPrecedent)} → ${formatMontant(data.valeurMoisActuel)})`;
    }
    
    // Retourner l'interprétation par défaut si fournie
    if (props.interpretation) return props.interpretation;
    
    // Générer une interprétation automatique si non fournie
    if (props.variation !== null && props.variation !== undefined) {
        const variationNum = Number(props.variation);
        if (variationNum > 0) {
            return `Augmentation de ${formattedVariation.value} par rapport à la période précédente`;
        } else if (variationNum < 0) {
            return `Diminution de ${formattedVariation.value.replace('+', '').replace('-', '')} par rapport à la période précédente`;
        } else {
            return `Stabilité par rapport à la période précédente`;
        }
    }
    
    return 'Vue globale sur l\'évolution de cet indicateur.';
});

// Fonction pour formater les montants (utilisée dans dataComparaison)
const formatMontant = (value) => {
    if (value === null || value === undefined) return '0';
    return new Intl.NumberFormat('mg-MG', {
        minimumFractionDigits: 0,
        maximumFractionDigits: 0
    }).format(value);
};

// Computed pour le texte du titre si en mode comparaison
const computedTexte = computed(() => {
    if (props.type === 'comparaison-mois' && props.dataComparaison) {
        const data = props.dataComparaison;
        if (data.pourcentage >= 0) {
            return 'Mois avec la plus forte augmentation';
        } else {
            return 'Mois avec la plus forte diminution';
        }
    }
    return props.texte || 'Indicateur';
});
</script>
<template>
    <div class="container" :class="{ loading: loading }">
        <div class="title">
            <p class="focus">{{ dataComparaison.moisNom }}</p>
            <p class="indicator">{{ computedTexte }}</p>
        </div>
        
        <!-- Mode comparaison mois -->
        <div v-if="type === 'comparaison-mois' && dataComparaison" class="comparaison-content">
            
            <div class="variation-display">
                <Texte :texte="'+' + dataComparaison.pourcentage.toFixed(1) + '%'" :type="'title-dark'" />
                <!-- <span class="vs-text">vs mois précédent</span> -->
            </div>
            
            <div class="montants-comparaison">
                <div class="montant-ligne">
                    <span class="label">Mois précédent:</span>
                    <span class="valeur">{{ formatMontant(dataComparaison.valeurMoisPrecedent) }} Ar</span>
                </div>
                <div class="montant-ligne">
                    <span class="label">{{ dataComparaison.moisNom }}:</span>
                    <span class="valeur">{{ formatMontant(dataComparaison.valeurMoisActuel) }} Ar</span>
                </div>
                <div class="difference-ligne">
                    <span class="label">Différence:</span>
                    <span v-if="idType == 2" :class="['difference', dataComparaison.pourcentage >= 0 ? 'positive' : 'negative']">
                        {{ dataComparaison.pourcentage >= 0 ? '+' : '-' }}{{ formatMontant(Math.abs(dataComparaison.augmentation || dataComparaison.baisse || 0)) }} Ar
                    </span>
                    <span v-else :class="['difference', dataComparaison.pourcentage >= 0 ? 'negative' : 'positive']">
                        {{ dataComparaison.pourcentage >= 0 ? '+' : '-' }}{{ formatMontant(Math.abs(dataComparaison.augmentation || dataComparaison.baisse || 0)) }} Ar
                    </span>
                </div>
            </div>
        </div>
        
        <!-- Mode simple (original) -->
        <!-- <div v-else class="data">
            <Texte v-if="!negative && parseFloat(chiffre) > 0 && format !== 'percent'" 
                   :texte="'+'" 
                   :type="'title-dark'"/>
            <Texte :texte="formattedChiffre" :type="'title-dark'"/>
            <p v-if="icon" :class="variationClass">{{ icon }}</p>
        </div> -->
        
        <!-- Section interprétation -->
        <!-- <div class="interpretation-section">
            <Texte :texte="computedInterpretation" :type="'dark'"/>
            
            <div v-if="type === 'simple' && variation !== null" class="variation-info">
                <span :class="variationClass">
                    Variation: {{ formattedVariation }}
                </span>
            </div>
        </div> -->
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

.data {
    display: flex;
    align-items: baseline;
    gap: 8px;
    margin-top: 8px;
}

/* Styles pour le mode comparaison */
.comparaison-content {
    width: 100%;
    display: flex;
    flex-direction: column;
    gap: 16px;
    margin-top: 8px;
}

.mois-nom {
    font-family: $stara-black;
    font-size: 32px;
    color: $dark;
    text-align: center;
}

.variation-display {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    gap: 4px;
}

.variation-display span:first-child {
    font-family: $stara-bold;
    font-size: 48px;
    padding: 8px 16px;
    border-radius: $radius-pm;
}

.vs-text {
    font-family: $stara-medium;
    font-size: 14px;
    color: $dark;
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

/* Section interprétation */
.interpretation-section {
    margin-top: auto;
    display: flex;
    flex-direction: column;
    gap: 8px;
}

.variation-info {
    font-family: $stara-medium;
    font-size: 14px;
    margin-top: 4px;
}

/* Classes de variation */
.trend-neutral {
    color: $gris;
    font-family: $stara-bold;
    font-size: 48px;
    font-style: normal;
    line-height: normal;
    margin: 0;
}

.trend-stable {
    color: $gris;
    font-family: $stara-bold;
    font-size: 48px;
    font-style: normal;
    line-height: normal;
    margin: 0;
}

.trend {
    color: $gris;
    font-family: $stara-bold;
    font-size: 48px;
    font-style: normal;
    line-height: normal;
    margin: 0;
}

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
    
    .mois-nom {
        font-size: 26px;
    }
    
    .variation-display span:first-child {
        font-size: 36px;
    }
}
</style>