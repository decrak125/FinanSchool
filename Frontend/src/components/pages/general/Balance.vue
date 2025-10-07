<template>
  <div class="dashboard-container w-full">
    <Header />
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

          <!-- Bouton Retour -->
          <div class="mb-4">
            <button @click="goBack" class="btn btn-outline">Retour aux Journaux</button>
          </div>
          <br>

          <!-- Filtre par période et classe de compte -->
          <div class="filter-container mb-6">
            <h2 class="text-xl mb-4">Filtrer la balance</h2>
            <form @submit.prevent="applyFilters" class="d-flex gap-4 flex-column flex-md-row">
              <div class="form-group">
                <label class="form-label">Date de début</label>
                <input v-model="filters.date_debut" type="date" class="form-input" />
              </div>
              <div class="form-group">
                <label class="form-label">Date de fin</label>
                <input v-model="filters.date_fin" type="date" class="form-input" />
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
              <div class="d-flex gap-2 align-center">
                <button type="submit" class="btn btn-primary" style="height: 40px;">Appliquer</button>
                <button type="button" @click="resetFilters" class="btn btn-outline" style="height: 40px; margin-top: 10px;">Réinitialiser</button>
              </div>
            </form>
          </div>

          <!-- Boutons d'exportation -->
          <div class="export-container mb-6 d-flex gap-4">
            <button @click="exportToPDF" class="btn btn-primary">Exporter en PDF</button>
            <button @click="exportToExcel" class="btn btn-primary">Exporter en Excel</button>
          </div>

          <!-- Tableau de la balance générale -->
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
                  <!-- Compte principal -->
                  <tr class="main-account-row">
                    <td class="p-4 text-base font-bold cursor-pointer" @click="toggleAccount(mainCode)">
                      <i :class="mainAccount.expanded ? 'bi bi-chevron-down' : 'bi bi-chevron-right'" class="me-2"></i>
                      {{ mainCode }} - {{ mainAccount.libelle }}
                    </td>
                    <td class="p-4 text-base font-bold">{{ formatNumber(Math.abs(mainAccount.total_debit)) }}</td>
                    <td class="p-4 text-base font-bold">{{ formatNumber(Math.abs(mainAccount.total_credit)) }}</td>
                  </tr>
                  <!-- Sous-comptes (affichés si expanded) -->
                  <template v-if="mainAccount.expanded">
                    <tr v-for="(subAccount, index) in mainAccount.subAccounts" :key="`${mainCode}-${index}`" class="sub-account-row">
                      <td class="p-4 text-base pl-8">{{ subAccount.code_sous_compte }} - {{ subAccount.libelle_sous_compte }}</td>
                      <td class="p-4 text-base">{{ formatNumber(Math.abs(subAccount.total_debit)) }}</td>
                      <td class="p-4 text-base">{{ formatNumber(Math.abs(subAccount.total_credit)) }}</td>
                    </tr>
                  </template>
                </template>
                <tr v-if="!Object.keys(groupedComptes).length">
                  <td colspan="3" class="p-4 text-center text-base">Aucune donnée disponible</td>
                </tr>
                <!-- Ligne des totaux -->
                <tr v-if="Object.keys(groupedComptes).length" class="total-row">
                  <td class="p-4 text-base font-bold">Totaux</td>
                  <td class="p-4 text-base font-bold">{{ formatNumber(Math.abs(totalDebit)) }}</td>
                  <td class="p-4 text-base font-bold">{{ formatNumber(Math.abs(totalCredit)) }}</td>
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

const router = useRouter();
const comptes = ref([]);
const loading = ref(false);
const expandedAccounts = ref(new Set());

const filters = ref({
  date_debut: "",
  date_fin: "",
  classe_compte: "",
});

// Grouper les comptes par code principal
const groupedComptes = computed(() => {
  const grouped = {};
  
  comptes.value.forEach((compte) => {
    const mainCode = compte.code_compte.substring(0, 1); // Premier caractère pour la classe
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
      total_debit: parseFloat(compte.total_debit) || 0,
      total_credit: parseFloat(compte.total_credit) || 0,
    });
    
    grouped[mainCode].total_debit += parseFloat(compte.total_debit) || 0;
    grouped[mainCode].total_credit += parseFloat(compte.total_credit) || 0;
  });
  
  return grouped;
});

// Obtenir le libellé de la classe
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

// Calcul des totaux
const totalDebit = computed(() => {
  return Object.values(groupedComptes.value).reduce((sum, account) => sum + account.total_debit, 0);
});

const totalCredit = computed(() => {
  return Object.values(groupedComptes.value).reduce((sum, account) => sum + account.total_credit, 0);
});

// Toggle l'expansion d'un compte
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
  return Number(number).toLocaleString("fr-FR", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
};

const fetchBalanceGenerale = async () => {
  try {
    loading.value = true;
    const queryParams = new URLSearchParams({
      ...(filters.value.date_debut && { date_debut: filters.value.date_debut }),
      ...(filters.value.date_fin && { date_fin: filters.value.date_fin }),
      ...(filters.value.classe_compte && { classe_compte: filters.value.classe_compte }),
    }).toString();
    
    const res = await axios.get(`http://127.0.0.1:8000/api/balance-generale?${queryParams}`);
    comptes.value = res.data;
  } catch (error) {
    console.error("Erreur lors du chargement de la balance générale:", error);
    comptes.value = [];
  } finally {
    loading.value = false;
  }
};

const applyFilters = () => {
  fetchBalanceGenerale();
};

const resetFilters = () => {
  filters.value = {
    date_debut: "",
    date_fin: "",
    classe_compte: "",
  };
  fetchBalanceGenerale();
};

const exportToPDF = () => {
  if (!Object.keys(groupedComptes.value).length) {
    alert("Aucune donnée à exporter");
    return;
  }

  const doc = new jsPDF();
  
  doc.setFontSize(18);
  doc.setTextColor(0, 51, 102);
  doc.text("RAITRA KIDZ - Balance Générale", 14, 20);
  
  doc.setFontSize(10);
  doc.setTextColor(0, 0, 0);
  doc.text(`Période: ${filters.value.date_debut || "N/A"} à ${filters.value.date_fin || "N/A"}`, 14, 30);
  doc.text(`Classe de compte: ${filters.value.classe_compte || "Toutes"}`, 14, 38);
  doc.text(`Exporté le: ${new Date().toLocaleDateString("fr-FR")}`, 14, 46);

  const tableData = [];
  Object.entries(groupedComptes.value).forEach(([mainCode, mainAccount]) => {
    tableData.push([
      `${mainCode} - ${mainAccount.libelle}`,
      formatNumber(Math.abs(mainAccount.total_debit)),
      formatNumber(Math.abs(mainAccount.total_credit)),
    ]);
    mainAccount.subAccounts.forEach(subAccount => {
      tableData.push([
        `  ${subAccount.code_sous_compte} - ${subAccount.libelle_sous_compte}`,
        formatNumber(Math.abs(subAccount.total_debit)),
        formatNumber(Math.abs(subAccount.total_credit)),
      ]);
    });
  });
  
  tableData.push([
    'TOTAUX',
    formatNumber(Math.abs(totalDebit.value)),
    formatNumber(Math.abs(totalCredit.value)),
  ]);

  autoTable(doc, {
    startY: 50,
    head: [['Compte', 'Débit', 'Crédit']],
    body: tableData,
    styles: {
      fontSize: 9,
      cellPadding: 3,
    },
    headStyles: {
      fillColor: [0, 51, 102],
      textColor: [255, 255, 255],
      fontStyle: "bold",
    },
    alternateRowStyles: {
      fillColor: [240, 240, 240],
    },
    margin: { top: 50, bottom: 20 },
  });

  doc.save(`Balance_Generale_${new Date().toISOString().split("T")[0]}.pdf`);
};

const exportToExcel = () => {
  if (!Object.keys(groupedComptes.value).length) {
    alert("Aucune donnée à exporter");
    return;
  }

  // 1️⃣ Récupération des données
  const data = [];
  Object.entries(groupedComptes.value).forEach(([mainCode, mainAccount]) => {
    mainAccount.subAccounts.forEach(subAccount => {
      data.push({
        'Compte': subAccount.code_sous_compte,
        'Libellé': subAccount.libelle_sous_compte,
        'Débit': formatNumber(Math.abs(subAccount.total_debit)),
        'Crédit': formatNumber(Math.abs(subAccount.total_credit)),
      });
    });
  });

  // 2️⃣ Création d’un tableau pour le titre et les détails
  const today = new Date().toLocaleDateString('fr-FR');
  const title = [["💼 BALANCE GÉNÉRALE"]];
  const details = [
    [`Date d'export : ${today}`],
    [""]
  ];

  // 3️⃣ Convertir le tableau principal en sheet
  const dataSheet = XLSX.utils.json_to_sheet(data, { origin: -1 });

  // 4️⃣ Fusion des éléments dans un seul tableau
  const ws = XLSX.utils.aoa_to_sheet([...title, ...details]);
  XLSX.utils.sheet_add_json(ws, data, { origin: -1, skipHeader: false });

  // 5️⃣ Ajustement de la largeur des colonnes
  const colWidths = [
    { wch: 15 }, // Compte
    { wch: 35 }, // Libellé
    { wch: 15 }, // Débit
    { wch: 15 }, // Crédit
  ];
  ws['!cols'] = colWidths;

  // 6️⃣ Ajout d’un peu de style (fusion + alignement)
  ws['!merges'] = [
    { s: { r: 0, c: 0 }, e: { r: 0, c: 3 } } // Fusion du titre sur 4 colonnes
  ];

  // 7️⃣ Création du classeur et écriture du fichier
  const wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, ws, "Balance_Generale");
  XLSX.writeFile(
    wb,
    `balance_generale_${new Date().toISOString().split("T")[0]}.xlsx`
  );
};


const goBack = () => {
  router.push("/journal");
};

onMounted(() => {
  fetchBalanceGenerale();
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
  background: #f9fafb;
  min-height: calc(100vh - 80px);
}

.filter-container,
.export-container {
  background: white;
  padding: 1rem;
  border-radius: 0.75rem;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
}

.bi-table {
  font-size: 1.125rem;
  color: #142c6c;
  vertical-align: middle;
}

.main-account-row {
  background-color: #f0f4f8;
  cursor: pointer;
}

.main-account-row:hover {
  background-color: #e1e8f0;
}

.sub-account-row {
  background-color: #fafafa;
}

.total-row {
  background-color: #e6e6e6;
  font-weight: bold;
}

@media (max-width: 768px) {
  .main-content {
    margin-left: 0;
    padding: 1rem;
  }
}

.table-container {
  overflow-x: auto;
}

.spinner {
  display: inline-block;
  width: 2rem;
  height: 2rem;
  border: 3px solid #f3f3f3;
  border-top: 3px solid #3498db;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
</style>