<script setup>
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
    width: 220px;
    @include position-contenus(flex, flex-start, center);
    padding: 0px 14px;
    gap: 8px;
    align-self: stretch;
    transition: all 0.5s ease-in-out;
    
    @media (max-width: 1024px) {
        width: 100%;
        max-width: 100%;
    }
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
    
    @media (max-width: 768px) {
        font-size: 20px;
    }
}
#dropdown {
    font-size: 18px;
    color: $primary;
    padding-top: 3px;
    
    @media (max-width: 768px) {
        font-size: 16px;
    }
}
p{
    color: $primary;
    font-family: Stara;
    font-size: 12px;
    font-style: normal;
    // font-weight: 600;
    line-height: normal;
    transition: all 0.5s ease-in-out;
    
    @media (max-width: 768px) {
        font-size: 11px;
    }
}
a {
    cursor: pointer;
    text-decoration: none;
    width: 100%;
}
li:hover {
    cursor: pointer;
    transition: all 0.5s ease-in-out;
    p{
        padding-left: 2px;
    }
}   

@media (max-width: 1024px) {
    .sidebar-item {
        width: 100%;
    }
}
</style>