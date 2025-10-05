<script setup>
import { drop } from 'lodash';
import Texte from './Texte.vue';
defineProps({
    icon: String,
    texte: String,
    redirection: String,
    dropdown: Boolean,
    isActive: Boolean
});
</script>
<template>
    <router-link
    :to="redirection"
    class="sidebar-item"
    :class="{ active: isActive }"
    >
        <li>
            <div class="menu">
                <i v-bind:class="icon"></i>
                <p>{{ texte }}</p>
            </div>
            <i v-if="dropdown" class="bi bi-chevron-down" id="dropdown"></i>
        </li>
    </router-link>
</template>
<style lang="scss" scoped>
li {
    border-radius: $radius-pm;
    width: 232px;
    // background-color: #dbdbdb;
    @include position-contenus(flex, flex-start, center);
    padding: 0px 12px;
    gap: 8px;
    align-self: stretch;
    transition: all 0.5s ease-in-out;
}
.menu {
    @include position-contenus(flex, flex-start, center);
    gap: 12px;
    flex-grow: 1;
}

i {
    font-size: 24px;
    aspect-ratio: 1/1;
    color: $primary;
}
#dropdown {
    font-size: 18px;
    color: $primary;
    padding-top: 3px;
}
p{
    color: $primary;
    font-family: Stara;
    font-size: 12px;
    font-style: normal;
    font-weight: 600;
    line-height: normal;
    transition: all 0.5s ease-in-out;
}
a {
    cursor: pointer;
    text-decoration: none;
    // background-color: #fff;
}
li:hover {
    background-color: $light;
    cursor: pointer;
    transition: all 0.5s ease-in-out;
    p{

        padding-left: 2px;
    }
}   

</style>
