<script setup>
defineProps({
    label: {
        type: String,
        default: ''
    },
    name: {
        type: String,
        default: ''
    },
    placeholder: {
        type: String,
        default: ''
    },
    value: {
        type: String,
        default: ''
    }
});
</script>
<template>
    <textarea :name="name"  :placeholder="placeholder" :value="value"></textarea>
</template>
<style lang="scss" scoped>  

textarea{
    @include bouton-variant($primary, $light, $radius-pm, $stara);
    width: 250px;
    height: 135px;
    textarea::placeholder{
        color: $gris;
    }
}

</style>