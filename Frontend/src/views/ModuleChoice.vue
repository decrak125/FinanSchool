<script setup>
import Page from "@/components/template/Page.vue";
import Texte from "@/components/atoms/Texte.vue";
import { getUser } from "@/services/Auth"; // Adjust the path if necessary
import { onMounted, ref } from "vue";
const user = ref({});
const token = localStorage.getItem("token");
if (!token) {
  window.location.href = "/";
  {
    onMounted(async () => {
      try {
        const res = await getUser(token); // attendre la promesse
        user.value = res.data;           // axios renvoie { data: ... }
      } catch (err) {
        console.error("Erreur lors de la récupération de l'utilisateur :", err);
        window.location.href = "/";
      }
    });
  }
}
const etatfinancier = () => {
  window.location.href = "/dashboard";
};
const analysefinanciere = () => {
  window.location.href = "/analyse";
};
</script>
<template>
  <Page :type="'light'">
    <div class="container">
      <div class="title">
        <Texte type="xl-dark" texte="Bienvenu(e)" />
        <Texte type="bold-dark" texte="Que souhaiteriez-vous consulter aujourd’hui?" />
      </div>
      <div class="card-container">
        <div class="card" @click="etatfinancier">
          <Texte type="xl-dark" texte="Etat Financier" />
          <Texte type="dark" texte="l'Etat Financier présente de manière synthétique la situation financière et les performances d’une entreprise à un moment donné." />
        </div>
        <div class="card" @click="analysefinanciere">
          <Texte type="xl-dark" texte="Analyse Financière" />
          <Texte type="dark" texte="Contrairement à l’etat financier, l’analyse financière sert à comprendre où vont les ressources et comment elles sont utilisées." />
        </div>
      </div>
    </div>
  </Page>
</template>
<style lang="scss" scoped>
.title {
  @include position-contenus(block, center, center);
  text-align: center;
}

.card-container {
  @include position-contenus(flex, center, center);
  gap: 32px;
  flex-wrap: wrap;
}

.card {
  cursor: pointer;
  background-color: $light;
  width: 519px;
  height: 519px;
  border-radius: $radius-pm;
  padding: 32px;
  @include position-contenus(flex, center, flex-start);
  display: flex;
  width: 519px;
  height: 519px;
  padding: 32px;
  flex-direction: column;
  justify-content: flex-end;

}

.container {
  background-color: #fff;
  @include position-contenus(flex, center, center);
  width: 100%;
  padding: 32px 64px;
  flex-direction: column;
  align-items: center;
  gap: 32px;
}
</style>