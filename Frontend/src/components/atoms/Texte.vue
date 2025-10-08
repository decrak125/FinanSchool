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

.text-thin-dark{
    @include text-xs($stara-medium, $dark);
}
.text-thin-error{
    @include text-xs($stara-medium, $rouge);
}
.text-thin-success{
    @include text-xs($stara-medium, $vert);
}
.text-thin-primary{
    @include text-xs($stara-medium, $primary);
}
.text-thin-light{
    @include text-xs($stara-medium, $light);
}
.text-thin-warning{
    @include text-xs($stara-medium, $jaune);
}

.text-dark{
    @include text-pm($stara-medium, $dark);
}
.text-error{
    @include text-pm($stara-medium, $rouge);
}
.text-success{
    @include text-pm($stara-medium, $vert);
}
.text-primary{
    @include text-pm($stara-medium, $primary);
}
.text-light{
    @include text-pm($stara-medium, $light);
}

.text-bold-dark{
    @include text-gm($stara-medium, $dark);
}
.text-bold-success{
    @include text-gm($stara-medium, $vert);
}
.text-bold-primary{
    @include text-gm($stara-medium, $primary);
}
.text-bold-light{
    @include text-gm($stara-medium, $light);
}

.text-black-error{
    @include text-xl($stara-medium, $rouge);
}
.text-black-dark{
    @include text-xl($stara-medium, $dark);
}
.text-black-success{
    @include text-xl($stara-medium, $vert);
}
.text-black-primary{
    @include text-xl($stara-medium, $primary);
}
.text-black-light{
    @include text-xl($stara-medium, $light);
}

.text-title-light{
    @include title-xl($stara-medium, $light);
}
.text-title-dark{
    @include title-xl($stara-medium, $dark);
}
.text-xl-dark{
    @include title($stara-medium, $dark);
}




</style>