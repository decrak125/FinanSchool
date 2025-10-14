<script setup>
import { ref, onMounted, computed } from "vue";
import PageAnalyse from '@/components/template/Page-analyse.vue';
import { useIndicateur } from "@/composables/useIndicateur";
import Card from "@/components/atoms/Chart/Card.vue";


const filters = new Date().getFullYear().toString();
const {
    general, getAnalyseRentabiliteParType, resultat
} = useIndicateur(filters);


// Génération des années
const availableYears = computed(() => {
  const currentYear = new Date().getFullYear();
  const years = [];
  for (let i = 0; i <= 5; i++) {
    years.push((currentYear - i).toString());
  }
  return years;
});

onMounted(() => {
    getAnalyseRentabiliteParType();
});

</script>
<template>
    <PageAnalyse>
        <div v-for="données in general" class="cartes">
            <Card
                v-if="données.id_type == 2"
                :texte="'Total Produits'"
                :chiffre="parseFloat(données.total_profits)"
                :format="'money'"
                :icon="'bi bi-arrow-right'"
                :icon-color="'green'"
            />
            <Card
                v-else
                :chiffre="parseFloat(données.total_couts)"
                :texte="'Total Charges'"
                :format="'money'"
                :icon="'bi bi-arrow-left'"
                :icon-color="'red'"
            />
        </div>
            <Card
                :chiffre="resultat"
                :texte="'Résultat net'"
                :format="'money'"
                :icon="'bi bi-arrow-left-right'"
                :icon-color="'orange'"
                :negative="true"
            />
    </PageAnalyse>
</template>
<style>
</style>