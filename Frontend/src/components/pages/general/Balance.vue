<template>
  <div class="dashboard-container w-full">
    <Header v-if="user" :user="user" />
    <Sidebar :current-route="$route.path" @navigation-change="handleNavigation" />

    <div class="main-content p-6">
      <div class="card card-form">
        <div class="p-6">
          <div class="card-header">
            <h1 class="text-3xl">
              <i class="bi bi-table me-2"></i> Balance Générale
            </h1>
          </div>
          <br>

          <div class="mb-4">
            <button @click="goBack" class="btn btn-outline">Retour aux Journaux</button>
          </div>
          <br>

          <div class="filter-container mb-6">
            <h2 class="text-xl mb-4">Filtrer la balance</h2>
            <form @submit.prevent="applyFilters" class="d-flex gap-4 flex-column flex-md-row">
              <div class="form-group" style="display: flex;">
                <label class="form-label">Exercice comptable</label>
                <select v-model="selectedExercice" class="form-select" @change="onExerciceChange">
                  <option v-for="ex in exercices" :key="ex.id" :value="ex.id">{{ ex.nom }}</option>
                </select>
              </div>
              <div class="form-group">
                <label class="form-label">Classe de compte</label>
                <select v-model="filters.classe_compte" class="form-select">
                  <option value="">Toutes</option>
                  <option value="1">Classe 1 - Capitaux</option>
                  <option value="2">Classe 2 - Immobilisations</option>
                  <option value="3">Classe 3 - Stocks</option>
                  <option value="4">Classe 4 - Tiers</option>
                  <option value="5">Classe 5 - Finances</option>
                  <option value="6">Classe 6 - Charges</option>
                  <option value="7">Classe 7 - Produits</option>
                </select>
              </div>
              <div class="form-group">
                <label class="form-label">Date début</label>
                <input type="date" v-model="filters.date_debut" class="form-input" readonly />
              </div>
              <div class="form-group">
                <label class="form-label">Date fin</label>
                <input type="date" v-model="filters.date_fin" class="form-input" readonly />
              </div>
              <div class="d-flex gap-2 align-center">
                <button type="submit" class="btn btn-primary" style="height: 40px;">Appliquer</button>
                <button type="button" @click="resetFilters" class="btn btn-outline" style="height: 40px; margin-top: 10px;">Réinitialiser</button>
              </div>
            </form>
          </div>

          <div class="export-container mb-6 d-flex gap-4">
            <button @click="exportToPDF" class="btn btn-primary">Exporter en PDF</button>
            <button @click="exportToExcel" class="btn btn-primary">Exporter en Excel</button>
          </div>

          <div class="table-container mt-6">
            <table v-if="loading" class="table table-bordered table-striped w-full">
              <tbody>
                <tr>
                  <td colspan="3" class="p-4 text-center text-base">
                    <span class="spinner spinner-lg"></span> Chargement...
                  </td>
                </tr>
              </tbody>
            </table>
            <table v-else class="table table-bordered w-full">
              <thead>
                <tr>
                  <th class="text-base p-4">Compte</th>
                  <th class="text-base p-4">Débit</th>
                  <th class="text-base p-4">Crédit</th>
                </tr>
              </thead>
              <tbody>
                <template v-for="(mainAccount, mainCode) in groupedComptes" :key="mainCode">
                  <tr class="main-account-row">
                    <td class="p-4 text-base font-bold cursor-pointer" @click="toggleAccount(mainCode)">
                      <i :class="mainAccount.expanded ? 'bi bi-chevron-down' : 'bi bi-chevron-right'" class="me-2"></i>
                      {{ mainCode }} - {{ mainAccount.libelle }}
                    </td>
                    <td class="p-4 text-base font-bold">{{ formatNumber(Math.abs(mainAccount.total_debit)) }}</td>
                    <td class="p-4 text-base font-bold">{{ formatNumber(Math.abs(mainAccount.total_credit)) }}</td>
                  </tr>
                  <template v-if="mainAccount.expanded">
                    <tr v-for="(subAccount, index) in mainAccount.subAccounts" :key="`${mainCode}-${index}`" class="sub-account-row">
                      <td class="p-4 text-base pl-8">{{ subAccount.code_sous_compte }} - {{ subAccount.libelle_sous_compte }}</td>
                      <td class="p-4 text-base">
                        {{ subAccount.solde_final >= 0 ? formatNumber(subAccount.solde_final) : '' }}
                      </td>
                      <td class="p-4 text-base">
                        {{ subAccount.solde_final < 0 ? formatNumber(Math.abs(subAccount.solde_final)) : '' }}
                      </td>
                    </tr>
                  </template>
                </template>
                <tr v-if="!Object.keys(groupedComptes).length">
                  <td colspan="3" class="p-4 text-center text-base">Aucune donnée disponible</td>
                </tr>
                <tr v-if="Object.keys(groupedComptes).length" class="total-row">
                  <td class="p-4 text-base font-bold">Totaux</td>
                  <td class="p-4 text-base font-bold">{{ formatNumber(totalDebit) }}</td>
                  <td class="p-4 text-base font-bold">{{ formatNumber(totalCredit) }}</td>
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
import { ref, computed, onMounted } from "vue";
import { useRouter } from "vue-router";
import axios from "axios";
import { jsPDF } from "jspdf";
import autoTable from "jspdf-autotable";
import * as XLSX from "xlsx";
import Header from "../../molecules/Header.vue";
import Sidebar from "../../molecules/Sidebar.vue";
import AppFooter from "../../molecules/Footer.vue";
import { getUser } from "../../../services/Auth";

const router = useRouter();
const user = ref(null);
const comptes = ref([]);
const loading = ref(false);
const expandedAccounts = ref(new Set());
const exercices = ref([]);
const selectedExercice = ref(""); // Ajout clé
const filters = ref({
  date_debut: "",
  date_fin: "",
  classe_compte: "",
  exercice_comptable: "",
});

// Groupement des comptes (inchangé)
const groupedComptes = computed(() => {
  const grouped = {};
  comptes.value.forEach((compte) => {
    const mainCode = compte.code_compte.substring(0, 1); // Classe
    if (!grouped[mainCode]) {
      grouped[mainCode] = {
        libelle: getClasseLibelle(mainCode),
        total_debit: 0,
        total_credit: 0,
        expanded: expandedAccounts.value.has(mainCode),
        subAccounts: []
      };
    }
    grouped[mainCode].subAccounts.push({
      code_sous_compte: compte.code_sous_compte,
      libelle_sous_compte: compte.libelle_sous_compte,
      solde_final: parseFloat(compte.solde_final) || 0
    });
    if ((parseFloat(compte.solde_final) || 0) >= 0) {
      grouped[mainCode].total_debit += parseFloat(compte.solde_final) || 0;
    } else {
      grouped[mainCode].total_credit += Math.abs(parseFloat(compte.solde_final)) || 0;
    }
  });
  return grouped;
});
const getClasseLibelle = (classe) => {
  const classes = {
    '1': 'Capitaux',
    '2': 'Immobilisations',
    '3': 'Stocks',
    '4': 'Tiers',
    '5': 'Finances',
    '6': 'Charges',
    '7': 'Produits'
  };
  return classes[classe] || 'Classe inconnue';
};
const totalDebit = computed(() => {
  return Object.values(groupedComptes.value).reduce((sum, acc) => sum + (acc.total_debit || 0), 0);
});
const totalCredit = computed(() => {
  return Object.values(groupedComptes.value).reduce((sum, acc) => sum + (acc.total_credit || 0), 0);
});
const toggleAccount = (accountCode) => {
  if (expandedAccounts.value.has(accountCode)) {
    expandedAccounts.value.delete(accountCode);
  } else {
    expandedAccounts.value.add(accountCode);
  }
};
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
  return Number(number).toLocaleString('fr-FR', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
    useGrouping: true
  });
};
// FETCH Balance
const fetchBalanceGenerale = async () => {
  try {
    loading.value = true;
    const queryParams = new URLSearchParams({
      ...(filters.value.date_debut && { date_debut: filters.value.date_debut.slice(0, 10) }),
      ...(filters.value.date_fin && { date_fin: filters.value.date_fin.slice(0, 10) }),
      ...(filters.value.classe_compte && { classe_compte: filters.value.classe_compte }),
      ...(filters.value.exercice_comptable && { exercice_comptable: filters.value.exercice_comptable }),
    }).toString();
    // DEBUG
    console.log("Filtres à l'API:", filters.value);
    console.log("URL API:", `http://127.0.0.1:8000/api/balance-generale?${queryParams}`);
    const res = await axios.get(`http://127.0.0.1:8000/api/balance-generale?${queryParams}`);
    comptes.value = res.data;
  } catch (error) {
    console.error("Erreur lors du chargement de la balance générale:", error);
    comptes.value = [];
  } finally {
    loading.value = false;
  }
};
// FETCH Exercices
const fetchExercices = async () => {
  try {
    const res = await axios.get('http://127.0.0.1:8000/api/exercices');
    exercices.value = res.data.map(e => ({
      id: e.Id_Exercice_comptable,
      nom: `${e.Annee_fiscale} | Du ${e.Date_debut.slice(0, 10)} au ${e.Date_fin.slice(0, 10)} | ${e.Statut}`,
      ...e
    }));
    // Init sélection sur le 1e exercice dans la liste
    if (exercices.value.length) {
      selectedExercice.value = exercices.value[0].id;
      onExerciceChange();
    }
  } catch (e) {
    exercices.value = [];
  }
};
// Exercice / période synchronisée
const onExerciceChange = () => {
  const exercice = exercices.value.find(ex => ex.id == selectedExercice.value);
  if (exercice) {
    filters.value.exercice_comptable = exercice.id;
    filters.value.date_debut = exercice.Date_debut.slice(0, 10);
    filters.value.date_fin = exercice.Date_fin.slice(0, 10);
    fetchBalanceGenerale();
  }
};
// Appliquer les filtres (garde la logique d’export…)
const applyFilters = () => { fetchBalanceGenerale(); };
const resetFilters = () => {
  if (exercices.value.length) {
    selectedExercice.value = exercices.value[0].id;
    onExerciceChange();
  } else {
    filters.value = {
      date_debut: "",
      date_fin: "",
      classe_compte: "",
      exercice_comptable: "",
    };
    fetchBalanceGenerale();
  }
};


const societeNom = "RAITRA KIDZ";

const formatNumberSage = (number) => {
  if (isNaN(number)) return '0,00';
  let parts = Number(number).toFixed(2).split('.');
  parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, '.');
  return parts.join(',');
};

const exportToPDF = () => {
  if (!Object.keys(groupedComptes.value).length) {
    alert("Aucune donnée à exporter");
    return;
  }
  const doc = new jsPDF();

  doc.setFontSize(12);
  doc.setTextColor(44, 62, 80);
  doc.setFont("helvetica", "bold");
  doc.text(societeNom, 14, 14);

  doc.setFontSize(10);
  doc.setFont("helvetica", "normal");
  doc.text(`Date édition : ${new Date().toLocaleDateString("fr-FR")}`, 14, 20);

  doc.setFontSize(16);
  doc.setFont("helvetica", "bold");
  doc.setTextColor(51, 122, 183);
  doc.text("BALANCE GÉNÉRALE", doc.internal.pageSize.getWidth() / 2, 30, {align:"center"});

  doc.setFontSize(10);
  doc.setFont("helvetica", "normal");
  doc.setTextColor(44, 62, 80);
  doc.text(`Période : ${filters.value.date_debut || "N/A"} à ${filters.value.date_fin || "N/A"}`, 14, 38);
  doc.text(`Exercice : ${filters.value.exercice_comptable || "Tous"}`, 120, 38);
  doc.text(`Classe de compte : ${filters.value.classe_compte || "Toutes"}`, 14, 44);

  const tableData = [];
  Object.entries(groupedComptes.value).forEach(([mainCode, mainAccount]) => {
    tableData.push([
      `${mainCode} - ${mainAccount.libelle}`,
      formatNumberSage(mainAccount.total_debit),
      formatNumberSage(mainAccount.total_credit),
    ]);
    mainAccount.subAccounts.forEach(subAccount => {
      tableData.push([
        `  ${subAccount.code_sous_compte} - ${subAccount.libelle_sous_compte}`,
        subAccount.solde_final >= 0 ? formatNumberSage(subAccount.solde_final) : "",
        subAccount.solde_final < 0 ? formatNumberSage(Math.abs(subAccount.solde_final)) : ""
      ]);
    });
  });
  tableData.push([
    'TOTAUX',
    formatNumberSage(totalDebit.value),
    formatNumberSage(totalCredit.value),
  ]);

  autoTable(doc, {
    startY: 48,
    head: [['Compte', 'Débit', 'Crédit']],
    body: tableData,
    theme: 'grid',
    styles: {
      fontSize: 10,
      font: "helvetica",
      textColor: [44, 62, 80],
      halign: 'right',
      cellPadding: 4,
      lineColor: [180, 180, 180],
      lineWidth: 0.1,
    },
    headStyles: {
      fillColor: [51, 122, 183],
      textColor: [255, 255, 255],
      fontStyle: 'bold',
      halign: 'center',
      fontSize: 11,
    },
    alternateRowStyles: {
      fillColor: [245, 245, 245],
    },
    columnStyles: {
      0: { halign: 'left', fontStyle: 'bold' },
      1: { halign: 'right' },
      2: { halign: 'right' }
    },
    margin: { top: 48 }
  });

  doc.setFontSize(8);
  doc.setTextColor(180, 180, 180);
  doc.text(
    "Document édité automatiquement - Sage 100 style",
    14,
    doc.internal.pageSize.getHeight() - 10
  );
  doc.save(`Balance_Generale_${new Date().toISOString().split("T")[0]}.pdf`);
};

const exportToExcel = () => {
  if (!Object.keys(groupedComptes.value).length) {
    alert("Aucune donnée à exporter");
    return;
  }
  const data = [];
  Object.entries(groupedComptes.value).forEach(([mainCode, mainAccount]) => {
    mainAccount.subAccounts.forEach(subAccount => {
      data.push({
        'Compte': subAccount.code_sous_compte,
        'Libellé': subAccount.libelle_sous_compte,
        'Débit': subAccount.solde_final >= 0 ? formatNumber(subAccount.solde_final) : "",
        'Crédit': subAccount.solde_final < 0 ? formatNumber(Math.abs(subAccount.solde_final)) : "",
      });
    });
  });
  const today = new Date().toLocaleDateString('fr-FR');
  const title = [["💼 BALANCE GÉNÉRALE"]];
  const details = [
    [`Date d'export : ${today}`],[]
  ];
  const ws = XLSX.utils.aoa_to_sheet([...title, ...details]);
  XLSX.utils.sheet_add_json(ws, data, { origin: -1, skipHeader: false });
  ws['!cols'] = [ { wch: 15 }, { wch: 35 }, { wch: 15 }, { wch: 15 } ];
  ws['!merges'] = [ { s: { r: 0, c: 0 }, e: { r: 0, c: 3 } } ];
  const wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, ws, "Balance_Generale");
  XLSX.writeFile(wb, `balance_generale_${new Date().toISOString().split("T")[0]}.xlsx`);
};

const goBack = () => { router.push("/journal"); };

onMounted(async () => {
  // DEBUG
  console.log("Token récupéré :", token);
  if (!token) {
    window.location.href = "/";
  } else {
    axios.defaults.headers.common["Authorization"] = `Bearer ${token}`;
    try {
      const res = await getUser(token);
      user.value = res.data;
    } catch (err) {
      localStorage.removeItem("token");
      window.location.href = "/";
      return;
    }
    await fetchExercices();
    await fetchExerciceCourant();
    await fetchBalanceGenerale();
  }
});
</script>

<!-- Style identique à l'original, tu peux garder tel quel -->
<style scoped>
.dashboard-container { display: flex; min-height: 100vh; flex-direction: column; }
.main-content { margin-left: 278px; padding: 32px; flex: 1; background: #f9fafb; min-height: calc(100vh - 80px); }
.filter-container, .export-container { background: white; padding: 1rem; border-radius: 0.75rem; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06); }
.bi-table { font-size: 1.125rem; color: #142c6c; vertical-align: middle; }
.main-account-row { background-color: #f0f4f8; cursor: pointer; }
.main-account-row:hover { background-color: #e1e8f0; }
.sub-account-row { background-color: #fafafa; }
.total-row { background-color: #e6e6e6; font-weight: bold; }
@media (max-width: 768px) { .main-content { margin-left: 0; padding: 1rem; } }
.table-container { overflow-x: auto; }
.spinner { display: inline-block; width: 2rem; height: 2rem; border: 3px solid #f3f3f3; border-top: 3px solid #3498db; border-radius: 50%; animation: spin 1s linear infinite; }
@keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
</style>
