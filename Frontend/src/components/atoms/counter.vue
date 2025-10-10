<template>
  <div class="multi-digit-counter">
    <!-- Affichage pour les pourcentages -->
    <div 
      v-if="isPercentage"
      class="percentage-counter"
    >
      <div class="digits-container">
        <template v-for="(char, index) in formattedChars" :key="index">
          <!-- Point décimal -->
          <span 
            v-if="char === '.'"
            class="decimal-point"
          >
            {{ char }}
          </span>
          <!-- Chiffre animé -->
          <AnimatedDigit
            v-else
            :number="parseInt(char)"
            :duration="duration"
            :delay="calculateDelay(index)"
          />
        </template>
      </div>
      <span class="percentage-symbol">%</span>
    </div>

    <!-- Affichage pour l'argent -->
    <div 
  v-else-if="isMoney"
  class="money-counter"
>
  <div class="digits-container">
    <template v-for="(char, index) in formattedChars" :key="index">
      <!-- Espace séparateur de milliers -->
      <span 
        v-if="char === ' '"
        class="thousands-separator"
      >
        &nbsp;
      </span>
      <!-- Point décimal -->
      <span 
        v-else-if="char === '.'"
        class="decimal-point"
      >
        {{ char }}
      </span>
      <!-- Chiffre animé -->
      <AnimatedDigit
        v-else
        :number="parseInt(char)"
        :duration="duration"
        :delay="calculateDelay(index)"
      />
    </template>
  </div>
  <span class="currency-symbol" v-if="showCurrency">Ar</span>

</div>

    <!-- Affichage normal pour les nombres -->
    <div 
      v-else
      class="normal-counter"
    >
      <template v-for="(char, index) in formattedChars" :key="index">
        <!-- Point décimal -->
        <span 
          v-if="char === '.'"
          class="decimal-point"
        >
          {{ char }}
        </span>
        <!-- Chiffre animé -->
        <AnimatedDigit
          v-else
          :number="parseInt(char)"
          :duration="duration"
          :delay="calculateDelay(index)"
        />
      </template>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import AnimatedDigit from './AnimatedDigit.vue'  

const props = defineProps({
  number: {
    type: [Number, String],
    required: true,
    validator: (value) => {
      const num = parseFloat(value);
      return !isNaN(num) && num >= 0;
    }
  },
  duration: {
    type: Number,
    default: 2000
  },
  format: {
    type: String,
    // default: 'number', // 'number', 'percentage', 'money'
    validator: (value) => ['number', 'percentage', 'money'].includes(value)
  },
  showCurrency: {
    type: Boolean,
    default: true
  },
  decimalPlaces: {
    type: Number,
    default: 2
  }
})

// Formater le nombre selon le type
// Formater le nombre selon le type
const formattedNumber = computed(() => {
  const num = parseFloat(props.number);
  
  if (isNaN(num)) return '0';
  
  switch (props.format) {
    case 'percentage':
      return Math.min(100, Math.max(0, num)).toFixed(props.decimalPlaces);
    case 'money':
      // Formater avec séparateurs de milliers
      return formatNumberWithSpaces(num, props.decimalPlaces);
    default:
      if (num % 1 === 0) {
        return formatNumberWithSpaces(Math.round(num), 0);
      }
      return formatNumberWithSpaces(num, props.decimalPlaces);
  }
})

// Fonction pour formater les nombres avec espaces séparateurs
const formatNumberWithSpaces = (number, decimalPlaces = 2) => {
  const num = parseFloat(number);
  if (isNaN(num)) return '0';
  
  // Séparer partie entière et partie décimale
  const [integerPart, decimalPart] = num.toFixed(decimalPlaces).split('.');
  
  // Ajouter des espaces tous les 3 chiffres dans la partie entière
  const formattedInteger = integerPart.replace(/\B(?=(\d{3})+(?!\d))/g, ' ');
  
  // Retourner avec ou sans décimales
  if (decimalPlaces > 0 && parseFloat(decimalPart) > 0) {
    return `${formattedInteger}.${decimalPart}`;
  } else {
    return formattedInteger;
  }
}

// Séparer les caractères (chiffres + points décimaux + espaces)
const formattedChars = computed(() => {
  return formattedNumber.value.toString().split('');
})


// Calculer le délai pour l'animation en cascade
const calculateDelay = (index) => {
  return index * 100; // 100ms entre chaque chiffre
}

// Computed pour déterminer le type d'affichage
const isPercentage = computed(() => props.format === 'percentage')
const isMoney = computed(() => props.format === 'money')


</script>

<style scoped>
.multi-digit-counter {
  display: flex;
  align-items: center;
}
.thousands-separator {
  display: inline-block;
  width: 1px; /* Largeur de l'espace */
  margin: 0 0.1em;
}
.percentage-counter {
  display: flex;
  align-items: center;
  gap: 2px;
}

.money-counter {
  display: flex;
  align-items: center;
  gap: 4px;
}

.normal-counter {
  display: flex;
  align-items: center;
}

.digits-container {
  display: flex;
  align-items: center;
}

.percentage-symbol {
  font-size: 0.8em;
  font-weight: bold;
  color: inherit;
  margin-left: 2px;
}

.currency-symbol {
  font-size: 12px;
  font-weight: bold;
  color: inherit;
  /* margin-right: 4px; */
}

.decimal-point {
  font-size: 1em;
  font-weight: bold;
  padding: 0 1px;
  display: inline-block;
  line-height: 1;
}
</style>