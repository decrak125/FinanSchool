<script setup>
import { drop } from 'lodash';
import Texte from './Texte.vue';
defineProps({
    icon: String,
    texte: String,
    redirection: String,
    dropdown: Boolean,
});
</script>
<template>
    <a v-bind:href="redirection">
        <li>
            <i v-bind:class="icon"></i>
            <p>{{ texte }}</p>
            <i v-if="dropdown" class="bi bi-chevron-down"></i>
        </li>
    </a>
</template>
<style lang="scss" scoped>
li {
    border-radius: $radius-pm;
    width: 176px;
    background-color: #dbdbdb;
    @include position-contenus(flex, flex-start, center);
    padding: 0px 12px;
    gap: 8px;
    align-self: stretch;
}

i {
    font-size: 24px;
    aspect-ratio: 1/1;
    color: $primary;;
}
p{
    color: $primary;
    font-family: Stara;
    font-size: 16;
    font-style: normal;
    font-weight: 600;
    line-height: normal;
}
a {
    text-decoration: none;
}
</style>
