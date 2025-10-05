<script setup>
defineProps({
  menu: String,
  sousmenu : String,
});
</script>
<template>
<div class="content-header">
      <h1 class="">{{menu}}</h1>
      <div class="rubrique">
        <p class="menu">{{menu}} /</p>
        <p class="sous-menu"> {{sousmenu}}</p>
      </div>
</div>
</template>
<style lang="scss" scoped>
.rubrique{
  display: flex;
}
.content-header{
  display: flex;
  height: 82px;
  flex-direction: column;
  align-items: flex-start;
  align-self: stretch;
  h1{
    margin-bottom: 0;
    color: $dark;
    font-family: Stara;
    font-size: 32px;
    font-style: normal;
    font-weight: 600;
    line-height: normal;
  }
  .menu{
    margin-top: 0;
    color: $dark;
    font-family: sans-serif;
    font-weight: normal;
    font-size: 14px;
    font-style: normal;
    line-height: normal;
  }
  .sous-menu{
    margin-top: 0;
    color: $primary;
    font-family: sans-serif;
    font-weight: normal;
    font-size: 14px;
    font-style: normal;
    line-height: normal;
  }
}

</style>