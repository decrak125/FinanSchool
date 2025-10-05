<script setup>
</script>
<template>
    <div class="container">
        <i class="bi bi-chevron-down"></i>
        <div class="info">
            <p class="nom">
                Jane Doe
            </p>
            <p class="role">
                Admin
            </p>
        </div>
        <img src="@/assets/img/pp.jpg" alt="" class="avatar" />
    </div>
</template>
<style lang="scss" scoped>
.container {
    display: inline-flex;
    height: 54px;
    justify-content: flex-end;
    align-items: center;
    gap: 10px;
    flex-shrink: 0;
}

.info {
    // background-color: #ce6d6d;
    display: flex;
    height: 100%;
    // padding: 9px 0;
    flex-direction: column;
    justify-content: center;
    align-items: flex-start;
    align-self: stretch;
}

.nom {
    // margin-top: 0;
    margin-bottom: 0;
    font-family: Stara;
    font-size: 14px;
    font-style: normal;
    font-weight: 600;
    line-height: normal;
    color: $primary;
}

.role {
    margin-top: 0;
    // margin-bottom: 100px;
    color: #575757;
    font-family: Stara;
    font-size: 12px;
    font-style: normal;
    font-weight: 600;
    line-height: normal;
}

.avatar {
    width: 48px;
    height: 48px;
    border-radius: 50%;
    background-color: #dbdbdb;
}
</style>