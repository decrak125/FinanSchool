<script setup>
import { ref, computed } from 'vue'
import PageAnalyse from '@/components/template/Page-analyse.vue'
import CoutsEtProfit from '@/components/molecules/Dashboard/CoutsEtProfit.vue'
import Cards from '@/components/molecules/Dashboard/Cards.vue'
import SwipingCard from '@/components/molecules/Dashboard/SwipingCard.vue'
import Texte from '@/components/atoms/Texte.vue'
import FilterSelect from '@/components/atoms/Filter-select.vue'
import AnalyseTrimestrielle from '@/components/molecules/Dashboard/AnalyseTrimestrielle.vue'
import DiagnosticDashboard from './DiagnosticDashboard.vue'
import { useExportDiagnostic } from '@/composables/useExportDiagnostic'

const { loading, message, exporterPDF, exporterExcel } = useExportDiagnostic()

const filters = ref({
  annee: new Date().getFullYear().toString()
})

const availableYears = computed(() => {
  const currentYear = new Date().getFullYear()
  const years = []
  for (let i = 0; i <= 7; i++) {
    years.push((currentYear - i).toString())
  }
  return years
})

const setMessage = (msg, type = 'info') => {
  message.value = msg
  console.log(`Message export: ${msg} (${type})`)
  
  if (type !== 'info') {
    setTimeout(() => {
      message.value = ''
    }, 5000)
  }
}

const handleExportPDF = async () => {
  console.log('Export PDF demandé pour:', filters.value.annee)
  
  if (!filters.value.annee) {
    setMessage('Veuillez sélectionner une année d\'exercice', 'error')
    return
  }
  
  await exporterPDF(filters.value.annee, setMessage)
}

const handleExportExcel = async () => {
  console.log('Export Excel demandé pour:', filters.value.annee)
  
  if (!filters.value.annee) {
    setMessage('Veuillez sélectionner une année d\'exercice', 'error')
    return
  }
  
  await exporterExcel(filters.value.annee, setMessage)
}
</script>

<template>
  <PageAnalyse :menu="'Accueil'" :sousmenu="'Tableau de bord'">
    <div class="main">
      <div class="filters-container">
        <div class="filters">
          <Texte :type="'dark'" :texte="'Année d\'exercice'" />
          <FilterSelect v-model="filters.annee" :label="''">
            <option v-for="year in availableYears" :key="year" :value="year">
              {{ year }}
            </option>
          </FilterSelect>
        </div> 
        <div class="iconbtn"
          @click="handleExportPDF" 
            :disabled="loading"
          >
            <i class="bi bi-file-earmark-pdf-fill"></i>
          </div>
      </div>
      
      <DiagnosticDashboard
        :date-debut="filters.annee + '-01-01'"
        :date-fin="filters.annee + '-12-31'"
      />
      
      <div class="cards">
        <Cards :key="filters.annee" :annee="filters.annee" />
      </div>
      <div class="coutProfit">
        <CoutsEtProfit :key="filters.annee" :annee="filters.annee" />
      </div>
      <div class="coutProfit">
        <SwipingCard :key="filters.annee" :annee="filters.annee"/>
        <AnalyseTrimestrielle :key="filters.annee" :annee="filters.annee" />
      </div>
    </div>
  </PageAnalyse>
</template>

<style lang="scss" scoped>
.filters-container {
  display: flex;
  width: 100%;
  align-items: baseline;
  justify-content: space-between;
  gap: 10px;
  margin-bottom: 15px;
}

.filters {
  display: flex;
  gap: 12px;
  align-items: center;
  justify-content: flex-start;
  flex-wrap: wrap;
}

.export-btn {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 8px 16px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  font-weight: 500;
  transition: all 0.2s ease;
  
  &:hover:not(:disabled) {
    opacity: 0.9;
    transform: translateY(-1px);
  }
  
  &:active:not(:disabled) {
    transform: translateY(0);
  }
  
  &:disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }
}

.pdf-btn {
  background-color: #dc3545;
  color: white;
  
  &:hover:not(:disabled) {
    background-color: #c82333;
  }
}

.excel-btn {
  background-color: #198754;
  color: white;
  
  &:hover:not(:disabled) {
    background-color: #157347;
  }
}

.icon {
  width: 16px;
  height: 16px;
  fill: currentColor;
}

.spinner {
  display: inline-block;
  width: 12px;
  height: 12px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-radius: 50%;
  border-top-color: white;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.message {
  padding: 8px 12px;
  border-radius: 4px;
  font-size: 13px;
  animation: fadeIn 0.3s ease;
}

.message-info {
  background-color: #d1ecf1;
  color: #0c5460;
  border: 1px solid #bee5eb;
}

.message-success {
  background-color: #d4edda;
  color: #155724;
  border: 1px solid #c3e6cb;
}

.message-error {
  background-color: #f8d7da;
  color: #721c24;
  border: 1px solid #f5c6cb;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(-5px); }
  to { opacity: 1; transform: translateY(0); }
}

.main {
  @include position-contenus(flex, center, center);
  padding: 0 18px;
  flex-direction: column;
  gap: 20px;
  flex: 1 0 0;
  align-self: stretch;
  animation: appear 0.6s ease-out forwards;

  @media (max-width: $tablet) {
    padding: 0 24px;
    gap: 16px;
  }

  @media (max-width: $mobile) {
    padding: 0 16px;
    gap: 12px;
  }
}

.cards {
  width: 100%;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0;
}

.coutProfit {
  display: flex;
  width: 100%;
  align-items: center;
  gap: 24px;
  
  @media (max-width: $tablet) {
    flex-direction: column;
    gap: 16px;
  }
}

.iconbtn{
  display: flex;
  align-items: center;
  justify-content: center;
  width: 42px;
  height: 42px;
  border-radius: 50%;
  @include glass();
  cursor: pointer;
  i{
    color: #e25252;
    font-size: 20px;
  }
}
</style>