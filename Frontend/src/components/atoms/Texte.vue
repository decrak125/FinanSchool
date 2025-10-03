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
    @include text-xs($stara, $dark);
}
.text-thin-error{
    @include text-xs($stara, $rouge);
}
.text-thin-success{
    @include text-xs($stara, $vert);
}
.text-thin-primary{
    @include text-xs($stara, $primary);
}
.text-thin-light{
    @include text-xs($stara, $light);
}

.text-dark{
    @include text-pm($stara, $dark);
}
.text-error{
    @include text-pm($stara, $rouge);
}
.text-success{
    @include text-pm($stara, $vert);
}
.text-primary{
    @include text-pm($stara, $primary);
}
.text-light{
    @include text-pm($stara, $light);
}

.text-bold-dark{
    @include text-gm($stara, $dark);
}
.text-bold-success{
    @include text-gm($stara, $vert);
}
.text-bold-primary{
    @include text-gm($stara, $primary);
}
.text-bold-light{
    @include text-gm($stara, $light);
}

.text-black-error{
    @include text-xl($stara, $rouge);
}
.text-black-dark{
    @include text-xl($stara, $dark);
}
.text-black-success{
    @include text-xl($stara, $vert);
}
.text-black-primary{
    @include text-xl($stara, $primary);
}
.text-black-light{
    @include text-xl($stara, $light);
}

.text-title-light{
    @include title-xl($stara, $light);
}
.text-title-dark{
    @include title-xl($stara, $dark);
}
.text-xl-dark{
    @include title($stara, $dark);
}




</style>