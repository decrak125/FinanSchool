<template>
  <div class="dashboard-container w-full">
    <Header />
    <Sidebar :current-route="$route.path" @navigation-change="handleNavigation" />

    <div class="main-content p-6">
      <div class="card card-form">
        <div class="p-6">
          <div class="card-header">
            <h1 class="card-title text-3xl">Écritures du Journal {{ journalId }}</h1>
          </div>
          <br>

          <!-- Bouton Retour -->
          <div class="mb-4">
            <button @click="goBack" class="btn btn-outline">Retour aux Journaux</button>
          </div>
          <br>
          <!-- Tableau des écritures -->
          <div class="table-container mt-6">
            <table class="table table-bordered table-striped w-full">
              <thead>
                <tr>
                  <th class="text-base p-4">Date Mouvement</th>
                  <th class="text-base p-4">N° Pièce</th>
                  <th class="text-base p-4">Compte</th>
                  <th class="text-base p-4">Libellé</th>
                  <th class="text-base p-4">Référence</th>
                  <th class="text-base p-4">Mode Paiement</th>
                  <th class="text-base p-4">Débit</th>
                  <th class="text-base p-4">Crédit</th>
                  
                  
                </tr>
              </thead>
              <tbody>
                <tr v-for="ecriture in ecritures" :key="ecriture.Id_Ligne_ecriture">
                    <td class="p-4 text-base">{{ ecriture.mouvement ? new Date(ecriture.mouvement.Date_mouvement).toLocaleDateString('fr-FR') : '-' }}</td>
                  <td class="p-4 text-base">{{ ecriture.mouvement ? ecriture.mouvement.Numero_piece : '-' }}</td>
                  <td class="p-4 text-base">{{ ecriture.sous_compte ? `${ecriture.sous_compte.Code_sous_compte}` : '-' }}</td>
                  <td class="p-4 text-base">{{ ecriture.Libelle || '-' }}</td>
                  <td class="p-4 text-base">{{ ecriture.Reference || '-' }}</td>
                  <td class="p-4 text-base">{{ ecriture.mode_paiement ? ecriture.mode_paiement.Libelle : '-' }}</td>
                  <td class="p-4 text-base">{{ ecriture.Debit ? Number(ecriture.Debit).toFixed(2) : '-' }}</td>
                  <td class="p-4 text-base">{{ ecriture.Credit ? Number(ecriture.Credit).toFixed(2) : '-' }}</td>
                  
                                  </tr>
                <tr v-if="ecritures.length">
                  <td colspan="6" class="p-4 text-base font-bold text-right">Totaux :</td>
        
                  <td class="p-4 text-base font-bold">{{ totalDebit.toFixed(2) }}</td>
                  <td class="p-4 text-base font-bold">{{ totalCredit.toFixed(2) }}</td>
                  
                </tr>
                <tr v-if="!ecritures.length">
                  <td colspan="9" class="p-4 text-center text-base">Aucune écriture trouvée</td>
                </tr>
              </tbody>
            </table>
          </div>

          <AppFooter />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from "vue";
import { useRoute, useRouter } from "vue-router";
import axios from "axios";
import Header from "../../molecules/Header.vue";
import Sidebar from "../../molecules/Sidebar.vue";
import AppFooter from "../../molecules/Footer.vue";

const route = useRoute();
const router = useRouter();
const journalId = ref(route.params.id);
const ecritures = ref([]);

const handleNavigation = (item) => {
  router.push(item.route);
};

const token = localStorage.getItem("token");

if (!token) {
  window.location.href = "/";
} else {
  axios.defaults.headers.common["Authorization"] = `Bearer ${token}`;
}

const fetchEcritures = async () => {
  try {
    const res = await axios.get(`http://127.0.0.1:8000/api/journals/${journalId.value}/ecritures`);
    ecritures.value = res.data;
    console.log("Écritures chargées:", ecritures.value);
  } catch (error) {
    console.error("Erreur lors du chargement des écritures:", error);
    ecritures.value = [];
  }
};

const totalDebit = computed(() => {
  return ecritures.value.reduce((sum, ecriture) => sum + (Number(ecriture.Debit) || 0), 0);
});

const totalCredit = computed(() => {
  return ecritures.value.reduce((sum, ecriture) => sum + (Number(ecriture.Credit) || 0), 0);
});

const goBack = () => {
  router.push('/journal');
};

onMounted(() => {
  fetchEcritures();
});
</script>

<style scoped>
.dashboard-container {
  display: flex;
  min-height: 100vh;
  flex-direction: column;
}

.main-content {
  margin-left: 278px;
  padding: 32px;
  flex: 1;
  background: #f8fafc;
  min-height: calc(100vh - 80px);
}

@media (max-width: 768px) {
  .main-content {
    margin-left: 0;
    padding: 16px;
  }
}
</style>