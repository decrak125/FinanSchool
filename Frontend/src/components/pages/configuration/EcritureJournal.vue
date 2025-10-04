<template>
  <div class="dashboard-container w-full">
    <Header />
    <Sidebar :current-route="$route.path" @navigation-change="handleNavigation" />

    <div class="main-content p-6">
      <div class="card card-form">
        <div class="p-6">
          <div class="card-header">
            <h1 class="card-title text-3xl">Écritures du Journal {{ journal }}</h1>
          </div>
          <br>

          <!-- Bouton Retour -->
          <div class="mb-4">
            <button @click="goBack" class="btn btn-outline">Retour aux Journaux</button>
          </div>
          <br>

          <!-- Filtre par date -->
          <div class="filter-container mb-6">
            <h2 class="text-xl mb-4">Filtrer les écritures</h2>
            <form @submit.prevent="applyDateFilter" class="d-flex gap-4">
              <div class="form-group">
                <label class="form-label">Date de début</label>
                <input v-model="dateFilter.date_debut" type="date" class="form-input" />
              </div>
              <div class="form-group">
                <label class="form-label">Date de fin</label>
                <input v-model="dateFilter.date_fin" type="date" class="form-input" />
              </div>
              <button type="submit" class="btn btn-primary" style="height: 40px; margin-top: 20px;">Appliquer</button>
              <button type="button" @click="resetDateFilter" class="btn btn-outline" style="height: 40px; margin-top: 20px;">Réinitialiser</button>
            </form>
          </div>

          <!-- Boutons d'exportation -->
          <div class="export-container mb-6 d-flex gap-4">
            <button @click="exportToPDF" class="btn btn-primary">Exporter en PDF</button>
            <button @click="exportToExcel" class="btn btn-primary">Exporter en Excel</button>
          </div>

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
                  <td class="p-4 text-base" style="font-size:12px;">{{ ecriture.mouvement ? new Date(ecriture.mouvement.Date_mouvement).toLocaleDateString('fr-FR') : '-' }}</td>
                  <td class="p-4 text-base" style="font-size:10px; width: 110px;">{{ ecriture.mouvement ? ecriture.mouvement.Numero_piece : '-' }}</td>
                  <td class="p-4 text-base" style="font-size:12px;">{{ ecriture.sous_compte ? `${ecriture.sous_compte.Code_sous_compte}` : '-' }}</td>
                  <td class="p-4 text-base" style="font-size:12px;">{{ ecriture.Libelle || '-' }}</td>
                  <td class="p-4 text-base" style="font-size:12px;">{{ ecriture.Reference || '-' }}</td>
                  <td class="p-4 text-base" style="font-size:12px;">{{ ecriture.mode_paiement ? ecriture.mode_paiement.Libelle : '-' }}</td>
                  <td class="p-4 text-base" style="font-size:12px;">{{ ecriture.Debit ? formatNumber(ecriture.Debit) : '-' }}</td>
                  <td class="p-4 text-base" style="font-size:12px;">{{ ecriture.Credit ? formatNumber(ecriture.Credit) : '-' }}</td>
                </tr>
                <tr v-if="ecritures.length">
                  <td colspan="6" class="p-4 text-base font-bold text-right">Totaux :</td>
                  <td class="p-4 text-base font-bold">{{ formatNumber(totalDebit) }}</td>
                  <td class="p-4 text-base font-bold">{{ formatNumber(totalCredit) }}</td>
                </tr>
                <tr v-if="!ecritures.length">
                  <td colspan="8" class="p-4 text-center text-base">Aucune écriture trouvée</td>
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
import { jsPDF } from "jspdf";
import autoTable from "jspdf-autotable";
import * as XLSX from "xlsx";
import Header from "../../molecules/Header.vue";
import Sidebar from "../../molecules/Sidebar.vue";
import AppFooter from "../../molecules/Footer.vue";

const route = useRoute();
const router = useRouter();
const journalId = ref(route.params.id);
const journal = ref (route.params.journal || route.params.journalLibelle); // Récupérer le libellé du journal si disponible
const ecritures = ref([]);
const dateFilter = ref({
  date_debut: "",
  date_fin: "",
});

const handleNavigation = (item) => {
  router.push(item.route);
};

const token = localStorage.getItem("token");

if (!token) {
  window.location.href = "/";
} else {
  axios.defaults.headers.common["Authorization"] = `Bearer ${token}`;
}

const formatNumber = (number) => {
  return Number(number).toLocaleString('fr-FR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
};

const fetchEcritures = async () => {
  try {
    const queryParams = new URLSearchParams({
      status: "valide",
      ...(dateFilter.value.date_debut && { date_debut: dateFilter.value.date_debut }),
      ...(dateFilter.value.date_fin && { date_fin: dateFilter.value.date_fin }),
    }).toString();
    const res = await axios.get(`http://127.0.0.1:8000/api/journals/${journalId.value}/ecritures?${queryParams}`);
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

const applyDateFilter = () => {
  fetchEcritures();
};

const resetDateFilter = () => {
  dateFilter.value = { date_debut: "", date_fin: "" };
  fetchEcritures();
};

const exportToPDF = () => {
  const doc = new jsPDF();
  
  // En-tête
  doc.setFontSize(18);
  doc.setTextColor(0, 51, 102); // Bleu foncé
  doc.text("RAITRA KIDZ - Écritures du Journal", 14, 20);
  
  doc.setFontSize(10);
  doc.setTextColor(0, 0, 0); // Noir
  doc.text(`Journal ID: ${journalId.value}`, 14, 30);
  doc.text(`Période: ${dateFilter.value.date_debut || 'N/A'} à ${dateFilter.value.date_fin || 'N/A'}`, 14, 38);
  doc.text(`Nombre d'écritures: ${ecritures.value.length}`, 14, 46);
  doc.text(`Exporté le: ${new Date().toLocaleDateString('fr-FR')}`, 14, 54);

  // Tableau
  autoTable(doc, {
    startY: 60,
    head: [['Date Mouvement', 'N° Pièce', 'Compte', 'Libellé', 'Référence', 'Mode Paiement', 'Débit', 'Crédit']],
    body: ecritures.value.map(ecriture => [
      ecriture.mouvement ? new Date(ecriture.mouvement.Date_mouvement).toLocaleDateString('fr-FR') : '-',
      ecriture.mouvement ? ecriture.mouvement.Numero_piece : '-',
      ecriture.sous_compte ? ecriture.sous_compte.Code_sous_compte : '-',
      ecriture.Libelle || '-',
      ecriture.Reference || '-',
      ecriture.mode_paiement ? ecriture.mode_paiement.Libelle : '-',
      ecriture.Debit ? formatNumber(ecriture.Debit) : '-',
      ecriture.Credit ? formatNumber(ecriture.Credit) : '-',
    ]),
    foot: [['', '', '', '', '', 'Totaux :', formatNumber(totalDebit.value), formatNumber(totalCredit.value)]],
    styles: {
      fontSize: 10,
      cellPadding: 3,
      textColor: [0, 0, 0], // Noir pour le texte
    },
    headStyles: {
      fillColor: [0, 51, 102], // Bleu foncé pour l'en-tête
      textColor: [255, 255, 255], // Blanc pour le texte de l'en-tête
      fontStyle: 'bold',
    },
    alternateRowStyles: {
      fillColor: [240, 240, 240], // Gris clair pour les lignes alternées
    },
    footStyles: {
      fillColor: [200, 200, 200], // Gris pour le pied de tableau
      textColor: [0, 0, 0],
      fontStyle: 'bold',
    },
    margin: { top: 60, bottom: 20 },
    didDrawPage: (data) => {
      // Pied de page
      const pageCount = doc.internal.getNumberOfPages();
      for (let i = 1; i <= pageCount; i++) {
        doc.setPage(i);
        doc.setFontSize(10);
        doc.setTextColor(100);
        doc.text(`Page ${i} de ${pageCount}`, 14, doc.internal.pageSize.height - 10);
        doc.text(`RAITRA KIDZ © ${new Date().getFullYear()}`, doc.internal.pageSize.width - 50, doc.internal.pageSize.height - 10);
      }
    },
  });

  doc.save(`Ecriture_Journal_${journalId.value}_${new Date().toISOString().split('T')[0]}.pdf`);
};

const exportToExcel = () => {
  const data = ecritures.value.map(ecriture => ({
    'Date Mouvement': ecriture.mouvement ? new Date(ecriture.mouvement.Date_mouvement).toLocaleDateString('fr-FR') : '-',
    'N° Pièce': ecriture.mouvement ? ecriture.mouvement.Numero_piece : '-',
    'Compte': ecriture.sous_compte ? ecriture.sous_compte.Code_sous_compte : '-',
    'Libellé': ecriture.Libelle || '-',
    'Référence': ecriture.Reference || '-',
    'Mode Paiement': ecriture.mode_paiement ? ecriture.mode_paiement.Libelle : '-',
    'Débit': ecriture.Debit ? formatNumber(ecriture.Debit) : '-',
    'Crédit': ecriture.Credit ? formatNumber(ecriture.Credit) : '-',
  }));
  data.push({
    'Date Mouvement': '', 'N° Pièce': '', 'Compte': '', 'Libellé': '', 'Référence': '', 'Mode Paiement': 'Totaux :',
    'Débit': formatNumber(totalDebit.value), 'Crédit': formatNumber(totalCredit.value)
  });
  const ws = XLSX.utils.json_to_sheet(data);
  const wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, ws, `Journal_${journalId.value}`);
  XLSX.writeFile(wb, `ecritures_journal_${journalId.value}_${new Date().toISOString().split('T')[0]}.xlsx`);
};

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

.filter-container, .export-container {
  background: #fff;
  padding: 16px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.card-title,
.form-label,
.form-input,
.form-select,
.btn,
.table th,
.table td {
  font-family: var(--font-family); /* Use global Stara font from style.css */
}

@media (max-width: 768px) {
  .main-content {
    margin-left: 0;
    padding: 16px;
  }
}
</style>