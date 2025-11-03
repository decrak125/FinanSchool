<template>
  <div class="dashboard-container w-full">
    <Header v-if="user" :user="user" />
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
                  <th class="text-base p-4" style="width: 120px;">Débit</th>
                  <th class="text-base p-4" style="width: 120px;">Crédit</th>
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
                  <td class="p-4 text-base" style="font-size:12px; text-align: end;">{{ ecriture.Debit ? formatNumber(ecriture.Debit) : '-' }}</td>
                  <td class="p-4 text-base" style="font-size:12px; text-align: end;">{{ ecriture.Credit ? formatNumber(ecriture.Credit) : '-' }}</td>
                </tr>
                <tr v-if="ecritures.length">
                  <td colspan="6" class="p-4 text-base font-bold text-right">Totaux :</td>
                  <td class="p-4 text-base font-bold" style="font-size: 14px; text-align: right;">{{ formatNumber(totalDebit) }}</td>
                  <td class="p-4 text-base font-bold" style="font-size: 14px; text-align: right;">{{ formatNumber(totalCredit) }}</td>
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
import { getUser } from "../../../services/Auth";
import logo from '@/assets/img/01Raitra kidz 300px.png';

const route = useRoute();
const user = ref(null);
const router = useRouter();
const journalId = ref(route.params.id);
const journal = ref(route.params.journal || route.params.journalLibelle);
const ecritures = ref([]);
const devises = ref([]);
const defaultDevise = ref(null);
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
  if (number === null || number === undefined || isNaN(number)) return '-';
  const num = Number(number);
  return num.toLocaleString('fr-FR', {
    minimumFractionDigits: 2, // Always show 2 decimal places
    maximumFractionDigits: 2, // Limit to 2 decimal places
  }).replace(/\s/g, ' '); // Ensure space as thousand separator is consistent
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

const fetchDevises = async () => {
  try {
    const res = await axios.get(`http://127.0.0.1:8000/api/devises`);
    devises.value = res.data;
    if (devises.value.length > 0) {
      defaultDevise.value = devises.value[0]; // Utiliser la première devise comme devise par défaut
    }
    console.log("Devises chargées:", devises.value);
  } catch (error) {
    console.error("Erreur lors du chargement des devises:", error);
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

const getLogoBase64 = () => {
  return logo; // Le logo est déjà en base64 grâce à l'import
};

const exportToPDF = () => {
  const doc = new jsPDF({ orientation: 'portrait', unit: 'mm', format: 'a4' });

  // Ajout du logo
  const logoBase64 = getLogoBase64();
  doc.addImage(logoBase64, 'PNG', 10, 8, 30, 20); // X=10, Y=6, largeur=20mm, hauteur=20mm

  // Identité de la société
  doc.setFont('helvetica', 'bold');
  doc.setFontSize(14);
  

  doc.setFont('helvetica', 'normal');
  doc.setFontSize(10);

  // Titre du document
  doc.setFont('helvetica', 'bold');
  doc.setFontSize(18);
  doc.text(`Journal ${(journal.value ? journal.value.toUpperCase() : '')}`, 105, 15, { align: 'center' });

  // Détails à droite
  doc.setFont('helvetica', 'normal');
  doc.setFontSize(10);
  const deviseText = `Tenue de compte : ${defaultDevise.value ? defaultDevise.value.Sigle : 'Ar'}`;
  doc.text(deviseText, 150, 15);

  // Période (mois et année)
  let period = '';
  if (dateFilter.value.date_debut) {
    const d = new Date(dateFilter.value.date_debut);
    period = d.toLocaleString('fr-FR', { month: 'long', year: 'numeric' });
  }
  doc.text(`Période : ${period}`, 150, 20);

  // Date de tirage et page
  const now = new Date();
  const dateTirage = `Date de tirage : ${now.toLocaleDateString('fr-FR')} ${now.toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit', second: '2-digit' })}`;
  doc.text(dateTirage, 10, 38);

  // Plage de dates
  doc.text(`Du ${dateFilter.value.date_debut || '-'} au ${dateFilter.value.date_fin || '-'}`, 10, 43);

  // Tableau des écritures
  autoTable(doc, {
    startY: 55,
    theme: 'grid',
    head: [[
      'Jour', 'N° Pièce', 'N° Compte', 'Référence',
      'Libellé Écriture', 'Débit', 'Crédit'
    ]],
    body: ecritures.value.map(ecriture => {
      const dateMouvement = ecriture.mouvement ? ecriture.mouvement.Date_mouvement : null;
      let jour = '-';
      if (dateMouvement) {
        const d = new Date(dateMouvement);
        jour = `${d.getDate().toString().padStart(2, '0')}${(d.getMonth() + 1).toString().padStart(2, '0')}${d.getFullYear().toString().slice(2)}`;
      }
      return [
        jour,
        ecriture.mouvement?.Numero_piece || '-',
        ecriture.sous_compte?.Code_sous_compte || '-',
        ecriture.Reference || '-',
        ecriture.Libelle || '-',
        ecriture.Debit ? formatNumber(ecriture.Debit) : '-',
        ecriture.Credit ? formatNumber(ecriture.Credit) : '-',
      ];
    }),
    foot: [[
      '', '', '', '', 'Totaux', formatNumber(totalDebit.value), formatNumber(totalCredit.value),
    ]],
    styles: {
      fontSize: 9,
      cellPadding: 2,
      textColor: [35, 35, 35],
      lineColor: [180, 180, 180],
      lineWidth: 0.1,
      fillColor: [250, 250, 250],
    },
    headStyles: {
      fillColor: [41, 128, 185],
      textColor: [255, 255, 255],
      fontStyle: 'bold',
      lineWidth: 0.3,
      lineColor: [41, 128, 185],
      halign: 'center',
    },
    alternateRowStyles: {
      fillColor: [245, 245, 255],
    },
    footStyles: {
      fillColor: [41, 128, 185],
      textColor: [255, 255, 255],
      fontStyle: 'bold',
      lineWidth: 0.3,
      lineColor: [41, 128, 185],
    },
    columnStyles: {
      5: { halign: 'right' },
      6: { halign: 'right' },
    },
    margin: { top: 55, left: 10, right: 10, bottom: 25 },
    didDrawPage: (data) => {
      const pageCount = doc.internal.getNumberOfPages();
      for (let i = 1; i <= pageCount; i++) {
        doc.setPage(i);
        doc.setFontSize(10);
        doc.setTextColor(120, 120, 120);
        const pageStr = `Page : ${i}`;
        doc.text(pageStr, 190, 20);

        // Pied de page personnalisé
        doc.setFontSize(9);
        doc.text(`RAITRA KIDZ © ${now.getFullYear()} | Impression provisoire`, 10, 290);
      }
    },
  });

  // Sauvegarde du PDF
  doc.save(`Journal_${journalId.value}_${now.toISOString().split('T')[0]}.pdf`);
};

const exportToExcel = () => {
  if (!ecritures.value || ecritures.value.length === 0) {
    alert("Aucune écriture à exporter !");
    return;
  }

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
    'Date Mouvement': '',
    'N° Pièce': '',
    'Compte': '',
    'Libellé': '',
    'Référence': '',
    'Mode Paiement': 'TOTAUX',
    'Débit': formatNumber(totalDebit.value),
    'Crédit': formatNumber(totalCredit.value)
  });

  const ws = XLSX.utils.aoa_to_sheet([]);

  const titre = [`JOURNAL DES ÉCRITURES N° ${journalId.value}`];
  const details = [
    [`Journal ID : ${journalId.value}`],
    [`Unité monétaire : ${defaultDevise.value ? `${defaultDevise.value.Libelle} (${defaultDevise.value.Sigle})` : 'N/A'}`],
    [`Date d’export : ${new Date().toLocaleDateString('fr-FR')}`],
    [''],
  ];

  XLSX.utils.sheet_add_aoa(ws, [titre], { origin: 'A1' });
  XLSX.utils.sheet_add_aoa(ws, details, { origin: 'A3' });

  XLSX.utils.sheet_add_json(ws, data, { origin: 'A8', skipHeader: false });

  const colWidths = Object.keys(data[0]).map((key) => ({
    wch: Math.max(key.length + 5, 15)
  }));
  ws['!cols'] = colWidths;

  const wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, ws, `Journal_${journalId.value}`);

  const fileName = `Journal_${journalId.value}_${new Date()
    .toISOString()
    .split('T')[0]}.xlsx`;

  XLSX.writeFile(wb, fileName);
};

const goBack = () => {
  router.push('/journal');
};

onMounted(async () => {
  console.log("Token récupéré :", token); // Vérifie si le token existe
  
  if (!token) {
    console.log("Pas de token → Redirection vers /");
    window.location.href = "/";
  } else {
    axios.defaults.headers.common["Authorization"] = `Bearer ${token}`;
    try {
      console.log("Appel getUser en cours...");
      const res = await getUser(token);
      user.value = res.data;
      console.log("User récupéré :", user.value);
    } catch (err) {
      console.error("Erreur lors de getUser :", err);
      localStorage.removeItem("token");
      window.location.href = "/";
      return; // Important : arrête l'exécution
    }
  fetchDevises();
  fetchEcritures();
  }
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