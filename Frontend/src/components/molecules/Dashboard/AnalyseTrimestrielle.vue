<script setup>
import { ref, onMounted, defineProps } from 'vue';
import { useComparaison } from '@/composables/useComparaison';
import ColumnChart from '@/components/atoms/Chart/ColumnChart.vue';
import Texte from '@/components/atoms/Texte.vue';
import FilterSelect from '@/components/atoms/Filter-select.vue';

const props = defineProps({
  annee: {
    type: String,
    default: () => new Date().getFullYear().toString()
  }
});

const chartData = ref([]);
const loading = ref(false);
const error = ref('');
const typedata = ref([]);

const filters = ref({
  year: props.annee,
  id_centre: '',
  id_type: '1'
});

const fetchData = async () => {
  loading.value = true;
  error.value = '';
  
  try {
    console.log('Chargement des données trimestrielles pour', filters.value.year);
    const data = await useComparaison.getDonneesTrimestrielles(filters.value);
    chartData.value = data;
  } catch (err) {
    error.value = 'Erreur lors du chargement des données';
    console.error('Erreur détaillée:', err);
  } finally {
    loading.value = false;
  }
};

const fetchTypes = async () => {
  try {
    const type = await useComparaison.getType();
    typedata.value = type;
  } catch (err) {
    console.error('Erreur lors du chargement des types:', err);
  }
};

onMounted(() => {
  // Charger les données avec l'année du parent
  fetchData();
  fetchTypes();
});
</script>

<template>
  <div class="analyse-trimestrielle">    
    <div class="filters">
      <div class="filter-group">
        <FilterSelect v-model="filters.id_type" :label="''" @change="fetchData">
          <option v-for="type in typedata" :key="type.id_type" :value="type.id_type">
            {{ type.code }}
          </option>
        </FilterSelect>
      </div>
    </div>

    <div class="chart-container">
      <ColumnChart 
        :chartData="chartData"
        :loading="loading"
        :error="error"
        :tooltip="false"
      />
    </div>
  </div>
</template>
<style lang="scss" scoped>
  .filters{
    position: absolute;
    z-index: 1;
    right: 64px;
    padding-top: 28px;
    
  }

</style>