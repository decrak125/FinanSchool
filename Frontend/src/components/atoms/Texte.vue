<script setup>
defineProps({
  texte: String,
  type: String,
});
</script>

<template>
    <p v-bind:class="`text-${type}`">{{ texte }}</p>
</template>

<style lang="scss" scoped>
// Textes extra-small
.text-thin-dark{
    @include text-xs($stara-medium, $dark);
    
    @media (max-width: 768px) {
        font-size: 11px;
    }
}
.text-thin-error{
    @include text-xs($stara-medium, $rouge);
    
    @media (max-width: 768px) {
        font-size: 11px;
    }
}
.text-thin-success{
    @include text-xs($stara-medium, $vert);
    
    @media (max-width: 768px) {
        font-size: 11px;
    }
}
.text-thin-primary{
    @include text-xs($stara-medium, $primary);
    
    @media (max-width: 768px) {
        font-size: 11px;
    }
}
.text-thin-light{
    @include text-xs($stara-medium, $light);
    
    @media (max-width: 768px) {
        font-size: 11px;
    }
}
.text-thin-warning{
    @include text-xs($stara-medium, $jaune);
    
    @media (max-width: 768px) {
        font-size: 11px;
    }
}

// Textes principaux
.text-dark{
    @include text-pm($stara-medium, $dark);
    
    @media (max-width: 1024px) {
        font-size: 15px;
    }
    
    @media (max-width: 768px) {
        font-size: 14px;
    }
}
.text-error{
    @include text-pm($stara-medium, $rouge);
    
    @media (max-width: 1024px) {
        font-size: 15px;
    }
    
    @media (max-width: 768px) {
        font-size: 14px;
    }
}
.text-success{
    @include text-pm($stara-medium, $vert);
    
    @media (max-width: 1024px) {
        font-size: 15px;
    }
    
    @media (max-width: 768px) {
        font-size: 14px;
    }
}
.text-primary{
    @include text-pm($stara-medium, $primary);
    
    @media (max-width: 1024px) {
        font-size: 15px;
    }
    
    @media (max-width: 768px) {
        font-size: 14px;
    }
}
.text-light{
    @include text-pm($stara-medium, $light);
    
    @media (max-width: 1024px) {
        font-size: 15px;
    }
    
    @media (max-width: 768px) {
        font-size: 14px;
    }
}

// Textes grands
.text-bold-dark{
    @include text-gm($stara-medium, $dark);
    
    @media (max-width: 1024px) {
        font-size: 22px;
    }
    
    @media (max-width: 768px) {
        font-size: 20px;
    }
}
.text-bold-success{
    @include text-gm($stara-medium, $vert);
    
    @media (max-width: 1024px) {
        font-size: 22px;
    }
    
    @media (max-width: 768px) {
        font-size: 20px;
    }
}
.text-bold-primary{
    @include text-gm($stara-medium, $primary);
    
    @media (max-width: 1024px) {
        font-size: 22px;
    }
    
    @media (max-width: 768px) {
        font-size: 20px;
    }
}
.text-bold-light{
    @include text-gm($stara-medium, $light);
    
    @media (max-width: 1024px) {
        font-size: 22px;
    }
    
    @media (max-width: 768px) {
        font-size: 20px;
    }
}

// Textes extra-large
.text-black-error{
    @include text-xl($stara-medium, $rouge);
    
    @media (max-width: 1024px) {
        font-size: 22px;
    }
    
    @media (max-width: 768px) {
        font-size: 20px;
    }
}
.text-black-dark{
    @include text-xl($stara-medium, $dark);
    
    @media (max-width: 1024px) {
        font-size: 22px;
    }
    
    @media (max-width: 768px) {
        font-size: 20px;
    }
}
.text-black-success{
    @include text-xl($stara-medium, $vert);
    
    @media (max-width: 1024px) {
        font-size: 22px;
    }
    
    @media (max-width: 768px) {
        font-size: 20px;
    }
}
.text-black-primary{
    @include text-xl($stara-medium, $primary);
    
    @media (max-width: 1024px) {
        font-size: 22px;
    }
    
    @media (max-width: 768px) {
        font-size: 20px;
    }
}
.text-black-light{
    @include text-xl($stara-medium, $light);
    
    @media (max-width: 1024px) {
        font-size: 22px;
    }
    
    @media (max-width: 768px) {
        font-size: 20px;
    }
}

// Titres
.text-title-light{
    @include title-xl($stara-medium, $light);
    
    @media (max-width: 1024px) {
        font-size: 72px;
    }
    
    @media (max-width: 768px) {
        font-size: 48px;
    }
    
    @media (max-width: 480px) {
        font-size: 36px;
    }
}
.text-title-dark{
    @include title-xl($stara-medium, $dark);
    
    @media (max-width: 1024px) {
        font-size: 72px;
    }
    
    @media (max-width: 768px) {
        font-size: 48px;
    }
    
    @media (max-width: 480px) {
        font-size: 36px;
    }
}
.text-xl-dark{
    @include title($stara-medium, $dark);
    
    @media (max-width: 1024px) {
        font-size: 40px;
    }
    
    @media (max-width: 768px) {
        font-size: 32px;
    }
    
    @media (max-width: 480px) {
        font-size: 28px;
    }
}

// Règles générales pour tous les textes
@media (max-width: 768px) {
    p {
        line-height: 1.4;
        word-wrap: break-word;
    }
}

// Pour les très petits écrans
@media (max-width: 360px) {
    .text-title-light,
    .text-title-dark {
        font-size: 32px;
    }
    
    .text-xl-dark {
        font-size: 24px;
    }
}
</style>