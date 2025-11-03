<script setup>
defineProps({
  menu: String,
  sousmenu : String,
});
</script>

<template>
<div class="content-header">
      <h1 class="">{{sousmenu}}</h1>
      <div class="rubrique">
        <p class="menu">{{menu}} /</p>
        <p class="sous-menu"> {{sousmenu}}</p>
      </div>
</div>
</template>

<style lang="scss" scoped>
.rubrique{
  display: flex;
  
  @media (max-width: 768px) {
    flex-direction: column;
    gap: 4px;
  }
}
.content-header{
  display: flex;
  height: 82px;
  flex-direction: column;
  align-items: flex-start;
  align-self: stretch;
  
  @media (max-width: 768px) {
    height: auto;
    gap: 8px;
  }
  
  h1{
    margin-bottom: 0;
    color: $dark;
    font-family: $stara-black;
    font-size: 32px;
    font-style: normal;
    font-weight: 600;
    line-height: normal;
    
    @media (max-width: 1024px) {
      font-size: 28px;
    }
    
    @media (max-width: 768px) {
      font-size: 24px;
    }
  }
  .menu{
    margin-top: 0;
    color: $dark;
    font-family: $stara-medium;
    font-weight: normal;
    font-size: 14px;
    font-style: normal;
    line-height: normal;
    
    @media (max-width: 768px) {
      font-size: 12px;
    }
  }
  .sous-menu{
    margin-top: 0;
    color: $primary;
    font-family: $stara-medium;
    font-weight: normal;
    font-size: 14px;
    font-style: normal;
    line-height: normal;
    
    @media (max-width: 768px) {
      font-size: 12px;
    }
  }
}
</style>