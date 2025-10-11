<script setup>
defineProps({
  type: String,
  texte: String,
  redirection: String,
});
</script>

<template>
    <button v-bind:class="`button-${type}`">{{ texte }}</button>
</template>

<style lang="scss" scoped>
.button-primary {
  cursor: pointer;
  @include bouton($primary, $light, $radius-pm, $stara-medium);
  transition: all 0.5s ease-in-out;
  
  @media (max-width: 768px) {
    width: 100%;
    max-width: 300px;
    padding: 12px 16px;
    font-size: 14px;
  }
  
  @media (max-width: 480px) {
    padding: 10px 14px;
    font-size: 13px;
  }
}

.button-primary:hover {
  @include bouton($secondary, $light, $radius-pm, $stara-medium);
}

.button-input {
  cursor: pointer;
  @include bouton($primary, $light, $radius-pm, $stara-medium, 250px);
  transition: all 0.5s ease-in-out;
  
  @media (max-width: 1024px) {
    width: 220px;
  }
  
  @media (max-width: 768px) {
    width: 100%;
    max-width: 300px;
    padding: 12px 16px;
    font-size: 14px;
  }
  
  @media (max-width: 480px) {
    padding: 10px 14px;
    font-size: 13px;
  }
}

.button-input:hover {
  @include bouton($secondary, $light, $radius-pm, $stara-medium, 250px);
  
  @media (max-width: 1024px) {
    width: 220px;
  }
  
  @media (max-width: 768px) {
    width: 100%;
    max-width: 300px;
  }
}

.button-loading {
  cursor: not-allowed;
  @include bouton($secondary, $light, $radius-pm, $stara-medium, 250px);
  transition: all 0.5s ease-in-out;
  
  @media (max-width: 1024px) {
    width: 220px;
  }
  
  @media (max-width: 768px) {
    width: 100%;
    max-width: 300px;
    padding: 12px 16px;
    font-size: 14px;
  }
  
  @media (max-width: 480px) {
    padding: 10px 14px;
    font-size: 13px;
  }
}

.button-cancel {
  cursor: pointer;
  @include input($primary, $primary, $radius-pm, $stara-medium);
  width: 250px;
  transition: all 0.5s ease-in-out;
  
  @media (max-width: 1024px) {
    width: 220px;
  }
  
  @media (max-width: 768px) {
    width: 100%;
    max-width: 300px;
    padding: 12px 16px;
    font-size: 14px;
  }
  
  @media (max-width: 480px) {
    padding: 10px 14px;
    font-size: 13px;
  }
}

.button-cancel:hover {
  @include input($rouge, $rouge, $radius-pm, $stara-medium);
  
  @media (max-width: 1024px) {
    width: 220px;
  }
  
  @media (max-width: 768px) {
    width: 100%;
    max-width: 300px;
  }
}

// Assurer que tous les boutons s'adaptent bien sur mobile
@media (max-width: 768px) {
  button {
    min-height: 44px; // Taille minimale pour le touch
    touch-action: manipulation; // Améliore l'expérience tactile
  }
}

// Pour les groupes de boutons
@media (max-width: 768px) {
  .button-group {
    display: flex;
    flex-direction: column;
    gap: 12px;
    width: 100%;
    
    button {
      width: 100%;
    }
  }
}
</style>