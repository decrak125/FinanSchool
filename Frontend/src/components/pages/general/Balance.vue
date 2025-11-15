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
    <button class="chatbot-float-btn" @click="showChat = !showChat">
    <span v-if="!showChat">💬</span>
    <span v-else>✖</span>
  </button>
  <transition name="chatbot-fade">
    <div v-if="showChat">
      <ChatBot />
    </div>
  </transition>
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
import ChatBot from "../../molecules/ChatBot.vue";
import { getUser } from "../../../services/Auth";

const router = useRouter();
const user = ref(null);
const comptes = ref([]);
const showChat = ref(false);
const loading = ref(false);
const expandedAccounts = ref(new Set());
const exercices = ref([]);
const selectedExercice = ref("");
const filters = ref({
  date_debut: "",
  date_fin: "",
  classe_compte: "",
  exercice_comptable: "",
});

// LOGO EN BASE64
const logoBase64 = ref(null);
async function fetchImageAsBase64(url) {
  const response = await fetch(url);
  const blob = await response.blob();
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onloadend = () => resolve(reader.result);
    reader.onerror = reject;
    reader.readAsDataURL(blob);
  });
}

const getClasseLibelle = (classe) => ({
  '1': 'Capitaux',
  '2': 'Immobilisations',
  '3': 'Stocks',
  '4': 'Tiers',
  '5': 'Finances',
  '6': 'Charges',
  '7': 'Produits'
})[classe] || 'Classe inconnue';

const groupedComptes = computed(() => {
  const grouped = {};
  comptes.value.forEach((compte) => {
    const mainCode = compte.code_compte.substring(0, 1);
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

const totalDebit = computed(() =>
  Object.values(groupedComptes.value).reduce((sum, acc) => sum + (acc.total_debit || 0), 0)
);

const totalCredit = computed(() =>
  Object.values(groupedComptes.value).reduce((sum, acc) => sum + (acc.total_credit || 0), 0)
);

const toggleAccount = (accountCode) => {
  if (expandedAccounts.value.has(accountCode)) {
    expandedAccounts.value.delete(accountCode);
  } else {
    expandedAccounts.value.add(accountCode);
  }
};
const handleNavigation = (item) => { router.push(item.route); };
const goBack = () => { router.push("/journal"); };

const token = localStorage.getItem("token");
if (!token) {
  window.location.href = "/";
} else {
  axios.defaults.headers.common["Authorization"] = `Bearer ${token}`;
}

const formatNumber = (number) =>
  Number(number).toLocaleString('fr-FR', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
    useGrouping: true
  });

const fetchBalanceGenerale = async () => {
  try {
    loading.value = true;
    const queryParams = new URLSearchParams({
      ...(filters.value.date_debut && { date_debut: filters.value.date_debut.slice(0, 10) }),
      ...(filters.value.date_fin && { date_fin: filters.value.date_fin.slice(0, 10) }),
      ...(filters.value.classe_compte && { classe_compte: filters.value.classe_compte }),
      ...(filters.value.exercice_comptable && { exercice_comptable: filters.value.exercice_comptable }),
    }).toString();
    const res = await axios.get(`http://127.0.0.1:8000/api/balance-generale?${queryParams}`);
    comptes.value = res.data;
  } catch (error) {
    comptes.value = [];
  } finally {
    loading.value = false;
  }
};

const fetchExercices = async () => {
  try {
    const res = await axios.get('http://127.0.0.1:8000/api/exercices');
    exercices.value = res.data.map(e => ({
      id: e.Id_Exercice_comptable,
      nom: `${e.Annee_fiscale} | Du ${e.Date_debut.slice(0, 10)} au ${e.Date_fin.slice(0, 10)} | ${e.Statut}`,
      Statut: e.Statut,
      Date_debut: e.Date_debut,
      Date_fin: e.Date_fin,
      ...e
    }));
    // Sélectionne exercice courant (statut OUVERT), sinon le premier
    const courant = exercices.value.find(ex => ex.Statut === 'OUVERT') || exercices.value[0];
    if (courant) {
      selectedExercice.value = courant.id;
      onExerciceChange();
    }
  } catch (e) {
    exercices.value = [];
  }
};

const onExerciceChange = () => {
  const exercice = exercices.value.find(ex => ex.id == selectedExercice.value);
  if (exercice) {
    filters.value.exercice_comptable = exercice.id;
    filters.value.date_debut = exercice.Date_debut.slice(0, 10);
    filters.value.date_fin = exercice.Date_fin.slice(0, 10);
    fetchBalanceGenerale();
  }
};

const applyFilters = () => { fetchBalanceGenerale(); };
const resetFilters = () => {
  if (exercices.value.length) {
    const courant = exercices.value.find(ex => ex.Statut === 'OUVERT') || exercices.value[0];
    selectedExercice.value = courant.id;
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

const exportToExcel = () => {
  if (!Object.keys(groupedComptes.value).length) {
    alert("Aucune donnée à exporter");
    return;
  }
  const today = new Date().toLocaleDateString('fr-FR');
  const titleRow = ["💼 RAITRA KIDZ"];
  const infoRow = [`Date édition : ${today}`];
  const periodRow = [`Période : ${filters.value.date_debut || "N/A"} à ${filters.value.date_fin || "N/A"}`];
  const exerciceRow = [`Exercice : ${filters.value.exercice_comptable || "Tous"}`];
  const classeRow = [`Classe de compte : ${filters.value.classe_compte || "Toutes"}`];
  const emptyRow = [""];
  const headerRow = ["Compte", "Libellé", "Débit", "Crédit"];

  const dataRows = [];
  Object.entries(groupedComptes.value).forEach(([mainCode, mainAccount]) => {
    dataRows.push([
      `${mainCode} - ${mainAccount.libelle}`,
      "",
      formatNumber(mainAccount.total_debit),
      formatNumber(mainAccount.total_credit),
    ]);
    mainAccount.subAccounts.forEach(subAccount => {
      dataRows.push([
        subAccount.code_sous_compte,
        subAccount.libelle_sous_compte,
        subAccount.solde_final >= 0 ? formatNumber(subAccount.solde_final) : "",
        subAccount.solde_final < 0 ? formatNumber(Math.abs(subAccount.solde_final)) : ""
      ]);
    });
  });
  dataRows.push([
    "TOTAUX", "", formatNumber(totalDebit.value), formatNumber(totalCredit.value)
  ]);
  const wsData = [
    titleRow, infoRow, periodRow, exerciceRow, classeRow, emptyRow, headerRow, ...dataRows
  ];
  const ws = XLSX.utils.aoa_to_sheet(wsData);
  ws['!cols'] = [
    { wch: 25 }, { wch: 40 }, { wch: 18 }, { wch: 18 }
  ];
  ws['!merges'] = [
    { s: { r: 0, c: 0 }, e: { r: 0, c: 3 } },
    { s: { r: 1, c: 0 }, e: { r: 1, c: 3 } },
    { s: { r: 2, c: 0 }, e: { r: 2, c: 3 } },
    { s: { r: 3, c: 0 }, e: { r: 3, c: 3 } },
    { s: { r: 4, c: 0 }, e: { r: 4, c: 3 } },
  ];
  ["A7", "B7", "C7", "D7"].forEach(cell => {
    ws[cell].s = {
      font: { bold: true, sz: 13, color: { rgb: "222831" } },
      alignment: { horizontal: "center", vertical: "center" },
      fill: { fgColor: { rgb: "e3edfc" } },
      border: {
        top:    { style: "medium", color: { rgb: "1976d2" } },
        left:   { style: "medium", color: { rgb: "1976d2" } },
        right:  { style: "medium", color: { rgb: "1976d2" } },
        bottom: { style: "medium", color: { rgb: "1976d2" } }
      }
    }
  });
  const startRow = 7;
  for (let r = startRow; r < wsData.length; ++r) {
    for (let c = 0; c < 4; ++c) {
      const cellAddr = XLSX.utils.encode_cell({ r, c });
      if (!ws[cellAddr]) continue;
      ws[cellAddr].s = {
        font: { sz: 12 },
        alignment: { horizontal: "center", vertical: "center" },
        border: {
          top:    { style: "thin", color: { rgb: "142c6c" } },
          left:   { style: "thin", color: { rgb: "142c6c" } },
          right:  { style: "thin", color: { rgb: "142c6c" } },
          bottom: { style: "thin", color: { rgb: "142c6c" } }
        }
      };
      if (
        wsData[r][0] &&
        (
          wsData[r][0].startsWith("TOTAUX") ||
          wsData[r][0].match(/^\d - /)
        )
      ) {
        ws[cellAddr].s.font.bold = true;
        ws[cellAddr].s.fill = { fgColor: { rgb: "dbeafe" } };
      }
    }
  }
  const wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, ws, "Balance_Generale");
  XLSX.writeFile(wb, `balance_generale_${new Date().toISOString().split("T")[0]}.xlsx`);
};

const exportToPDF = () => {
  if (!Object.keys(groupedComptes.value).length) {
    alert("Aucune donnée à exporter");
    return;
  }
  const doc = new jsPDF();
  // --- Ajout du logo ---
  if (logoBase64.value) {
    doc.addImage(logoBase64.value, "PNG", 14, 4, 24, 16);
  }
  doc.setFontSize(12);
  doc.setTextColor(44, 62, 80);
  doc.setFont("helvetica", "bold");
  doc.text("RAITRA KIDZ", 44, 14);

  doc.setFontSize(10);
  doc.setFont("helvetica", "normal");
  doc.text(`Date édition : ${new Date().toLocaleDateString("fr-FR")}`, 14, 20);

  doc.setFontSize(16);
  doc.setFont("helvetica", "bold");
  doc.setTextColor(51, 122, 183);
  doc.text("BALANCE GÉNÉRALE", doc.internal.pageSize.getWidth() / 2, 32, {align:"center"});

  doc.setFontSize(10);
  doc.setFont("helvetica", "normal");
  doc.setTextColor(44, 62, 80);
  doc.text(`Période : ${filters.value.date_debut || "N/A"} à ${filters.value.date_fin || "N/A"}`, 14, 40);
  doc.text(`Exercice : ${filters.value.exercice_comptable || "Tous"}`, 120, 40);
  doc.text(`Classe de compte : ${filters.value.classe_compte || "Toutes"}`, 14, 46);

  const tableData = [];
  Object.entries(groupedComptes.value).forEach(([mainCode, mainAccount]) => {
    tableData.push([
      `${mainCode} - ${mainAccount.libelle}`,
      formatNumber(mainAccount.total_debit),
      formatNumber(mainAccount.total_credit),
    ]);
    mainAccount.subAccounts.forEach(subAccount => {
      tableData.push([
        `${subAccount.code_sous_compte} - ${subAccount.libelle_sous_compte}`,
        subAccount.solde_final >= 0 ? formatNumber(subAccount.solde_final) : "",
        subAccount.solde_final < 0 ? formatNumber(Math.abs(subAccount.solde_final)) : ""
      ]);
    });
  });
  tableData.push([
    'TOTAUX',
    formatNumber(totalDebit.value),
    formatNumber(totalCredit.value),
  ]);

  autoTable(doc, {
    startY: 52,
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
    margin: { top: 52 }
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

onMounted(async () => {
  logoBase64.value = await fetchImageAsBase64("/01Raitra kidz 300px.png");
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
    // La balance sur exercice courant sera affichée par défaut automatiquement
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
.chatbot-float-btn {
  position: fixed;
  bottom: 55px;
  right: 45px;
  width: 54px;
  height: 54px;
  background: linear-gradient(135deg,#1c45bd 0%,#011244 100%);
  border-radius: 50%;
  color: #fff;
  font-size: 2em;
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 101;
  border: none;
  box-shadow: 0 6px 16px rgba(102,126,234,0.22);
  cursor: pointer;
  transition: box-shadow 0.2s;
}
.chatbot-float-btn:hover {
  box-shadow: 0 10px 22px rgba(102,126,234,0.32);
  background: linear-gradient(135deg,#011244 0%,#1c45bd 100%);
}

.dashboard-chatbot-chatbox {
  position: fixed;
  bottom: 100px;
  right: 40px;
  width: 380px;
  max-width: 99vw;
  height: 520px;
  max-height: 80vh;
  z-index: 100;
  background: #fff;
  border-radius: 15px;
  box-shadow: 0 8px 36px rgba(90,60,130,0.14);
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

/* Animation d'apparition */
.chatbot-fade-enter-active, .chatbot-fade-leave-active {
  transition: opacity 0.25s;
}
.chatbot-fade-enter, .chatbot-fade-leave-to {
  opacity: 0;
}
@media (max-width: 768px) { .main-content { margin-left: 0; padding: 1rem; }
  .dashboard-chatbot-chatbox {
    right: 5vw;
    bottom: 80px;
    width: 98vw;
    height: 90vh;
    border-radius: 8px;
  }
  .chatbot-float-btn {
    right: 8vw;
    bottom: 18px;
    width: 44px;
    height: 44px;
    font-size: 1.3em;
  } }
.table-container { overflow-x: auto; }
.spinner { display: inline-block; width: 2rem; height: 2rem; border: 3px solid #f3f3f3; border-top: 3px solid #3498db; border-radius: 50%; animation: spin 1s linear infinite; }

@keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
</style>
