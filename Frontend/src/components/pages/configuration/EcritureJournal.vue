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
    <button class="chatbot-float-btn" @click="showChat = !showChat">
  <span v-if="!showChat">💬</span>
  <span v-else>✖</span>
</button>

<!-- POPIN CHATBOT (fixe à droite, petite taille) -->
<transition name="chatbot-fade">
  <div v-if="showChat">
    <ChatBot />
  </div>
</transition>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from "vue";
import { useRoute, useRouter } from "vue-router";
import axios from "axios";
import html2pdf from "html2pdf.js";
import * as XLSX from "xlsx-js-style";
import Header from "../../molecules/Header.vue";
import Sidebar from "../../molecules/Sidebar.vue";
import AppFooter from "../../molecules/Footer.vue";
import ChatBot from "../../molecules/ChatBot.vue";
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

const showChat = ref(false);

// Informations de l'établissement
const etablissement = {
  nom: "RAITRA KIDZ",
  adresse: "Antananarivo, Madagascar",
  tel: "+261 XX XX XXX XX",
  email: "contact@raitrakidz.mg"
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
  if (number === null || number === undefined || isNaN(number)) return '-';
  const num = Number(number);
  return num.toLocaleString('fr-FR', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  }).replace(/\s/g, ' ');
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
      defaultDevise.value = devises.value[0];
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

// Export vers PDF avec html2pdf.js (CORRIGÉ)
// Export vers PDF avec html2pdf.js (AVEC CONTENU DÉCALÉ À GAUCHE)
const exportToPDF = async () => {
  if (!ecritures.value || ecritures.value.length === 0) {
    alert("Aucune écriture à exporter !");
    return;
  }

  const now = new Date();
  const dateTirage = `${now.toLocaleDateString('fr-FR')} à ${now.toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' })}`;
  
  let period = '';
  if (dateFilter.value.date_debut) {
    const d = new Date(dateFilter.value.date_debut);
    period = d.toLocaleString('fr-FR', { month: 'long', year: 'numeric' });
  }

  const rows = ecritures.value.map(ecriture => {
    const dateMouvement = ecriture.mouvement ? ecriture.mouvement.Date_mouvement : null;
    let jour = '-';
    if (dateMouvement) {
      const d = new Date(dateMouvement);
      jour = `${d.getDate().toString().padStart(2, '0')}/${(d.getMonth() + 1).toString().padStart(2, '0')}/${d.getFullYear()}`;
    }
    return `
      <tr>
        <td>${jour}</td>
        <td>${ecriture.mouvement?.Numero_piece || '-'}</td>
        <td>${ecriture.sous_compte?.Code_sous_compte || '-'}</td>
        <td>${ecriture.Reference || '-'}</td>
        <td>${ecriture.Libelle || '-'}</td>
        <td style="text-align: right;">${ecriture.Debit ? formatNumber(ecriture.Debit) : '-'}</td>
        <td style="text-align: right;">${ecriture.Credit ? formatNumber(ecriture.Credit) : '-'}</td>
      </tr>
    `;
  }).join('');

  const htmlContent = `
    <div style="font-family: 'Helvetica', Arial, sans-serif; padding: 15px; max-width: 100%; margin: 0;">
      <!-- En-tête -->
      <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 25px; padding-bottom: 15px; border-bottom: 3px solid #2980b9;">
        <div style="flex: 1;">
          <img src="${logo}" alt="Logo" style="width: 100px; height: auto;" />
          <div style="margin-top: 8px; font-size: 11px; color: #555;">
            <div style="font-weight: bold; font-size: 13px; color: #2c3e50;">${etablissement.nom}</div>
            <div>${etablissement.adresse}</div>
            <div>${etablissement.tel}</div>
            <div>${etablissement.email}</div>
          </div>
        </div>
        <div style="flex: 2; text-align: center;">
          <h1 style="font-size: 22px; font-weight: bold; color: #2c3e50; margin: 0; text-transform: uppercase;">
            Journal ${journal.value ? journal.value.toUpperCase() : ''}
          </h1>
        </div>
        <div style="flex: 1; text-align: right; font-size: 10px; color: #555;">
          <div style="margin: 3px 0;"><strong>Devise:</strong> ${defaultDevise.value ? defaultDevise.value.Sigle : 'Ar'}</div>
          <div style="margin: 3px 0;"><strong>Période:</strong> ${period}</div>
          <div style="margin: 3px 0;"><strong>Journal N°:</strong> ${journalId.value}</div>
        </div>
      </div>
      
      <!-- Métadonnées -->
      <div style="display: flex; justify-content: space-between; margin-bottom: 20px; font-size: 10px; color: #666; padding: 10px; background: #f8f9fa; border-radius: 5px;">
        <div><strong>Date de tirage:</strong> ${dateTirage}</div>
        <div><strong>Plage:</strong> Du ${dateFilter.value.date_debut || '-'} au ${dateFilter.value.date_fin || '-'}</div>
      </div>

      <!-- Tableau -->
      <table style="width: 100%; border-collapse: collapse; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
        <thead>
          <tr style="background: linear-gradient(135deg, #2980b9 0%, #3498db 100%); color: white;">
            <th style="padding: 10px 8px; text-align: left; font-weight: 600; font-size: 10px; border: 1px solid #2980b9;">Jour</th>
            <th style="padding: 10px 8px; text-align: left; font-weight: 600; font-size: 10px; border: 1px solid #2980b9;">N° Pièce</th>
            <th style="padding: 10px 8px; text-align: left; font-weight: 600; font-size: 10px; border: 1px solid #2980b9;">N° Compte</th>
            <th style="padding: 10px 8px; text-align: left; font-weight: 600; font-size: 10px; border: 1px solid #2980b9;">Référence</th>
            <th style="padding: 10px 8px; text-align: left; font-weight: 600; font-size: 10px; border: 1px solid #2980b9;">Libellé</th>
            <th style="padding: 10px 8px; text-align: right; font-weight: 600; font-size: 10px; border: 1px solid #2980b9;">Débit</th>
            <th style="padding: 10px 8px; text-align: right; font-weight: 600; font-size: 10px; border: 1px solid #2980b9;">Crédit</th>
          </tr>
        </thead>
        <tbody>
          ${rows}
        </tbody>
        <tfoot>
          <tr style="background: linear-gradient(135deg, #2980b9 0%, #3498db 100%); color: white; font-weight: bold;">
            <td colspan="5" style="padding: 10px 8px; text-align: right; border: 1px solid #2980b9; font-size: 11px;">TOTAUX</td>
            <td style="padding: 10px 8px; text-align: right; border: 1px solid #2980b9; font-size: 11px;">${formatNumber(totalDebit.value)}</td>
            <td style="padding: 10px 8px; text-align: right; border: 1px solid #2980b9; font-size: 11px;">${formatNumber(totalCredit.value)}</td>
          </tr>
        </tfoot>
      </table>

      <!-- Pied de page -->
      <div style="margin-top: 25px; text-align: center; font-size: 9px; color: #999; border-top: 1px solid #ddd; padding-top: 10px;">
        <p style="margin: 0;">${etablissement.nom} © ${now.getFullYear()} | Document généré automatiquement | Impression provisoire</p>
      </div>
    </div>
  `;

  // Styles pour le tableau dans tbody
  const tbodyStyle = `
    <style>
      tbody tr { border: 1px solid #ddd; }
      tbody tr:nth-child(even) { background-color: #f8f9fa; }
      tbody td { padding: 8px; border: 1px solid #ddd; font-size: 9px; }
    </style>
  `;

  const fullHTML = tbodyStyle + htmlContent;

  // Créer un élément temporaire
  const element = document.createElement('div');
  element.innerHTML = fullHTML;
  element.style.width = '210mm';
  element.style.padding = '0'; // Suppression du padding
  element.style.margin = '0';   // Suppression du margin

  const opt = {
    margin: [10, 5, 15, 5], // [haut, droite, bas, gauche] - Marge gauche réduite de 10 à 5
    filename: `Journal_${journalId.value}_${now.toISOString().split('T')[0]}.pdf`,
    image: { type: 'jpeg', quality: 0.98 },
    html2canvas: { 
      scale: 2,
      useCORS: true,
      logging: false,
      letterRendering: true,
      allowTaint: true,
      x: 0,  // Commencer à gauche
      scrollX: 0,
      scrollY: 0
    },
    jsPDF: { 
      unit: 'mm', 
      format: 'a4', 
      orientation: 'portrait' 
    },
    pagebreak: { mode: ['avoid-all', 'css', 'legacy'] }
  };

  try {
    await html2pdf().set(opt).from(element).save();
    console.log('PDF généré avec succès');
  } catch (err) {
    console.error('Erreur lors de l\'export PDF:', err);
    alert('Erreur lors de la génération du PDF. Vérifiez la console.');
  }
};


// Export vers Excel avec logo et nom établissement (CORRIGÉ)
const exportToExcel = async () => {
  if (!ecritures.value || ecritures.value.length === 0) {
    alert("Aucune écriture à exporter !");
    return;
  }

  const wb = XLSX.utils.book_new();
  const ws = XLSX.utils.aoa_to_sheet([]);
  
  const now = new Date();
  let period = '';
  if (dateFilter.value.date_debut) {
    const d = new Date(dateFilter.value.date_debut);
    period = d.toLocaleString('fr-FR', { month: 'long', year: 'numeric' });
  }

  // Styles
  const titleStyle = {
    font: { bold: true, sz: 20, color: { rgb: "2C3E50" } },
    alignment: { horizontal: "center", vertical: "center" }
  };

  const headerStyle = {
    font: { bold: true, color: { rgb: "FFFFFF" }, sz: 11 },
    fill: { fgColor: { rgb: "2980B9" } },
    alignment: { horizontal: "center", vertical: "center" },
    border: {
      top: { style: "thin", color: { rgb: "000000" } },
      bottom: { style: "thin", color: { rgb: "000000" } },
      left: { style: "thin", color: { rgb: "000000" } },
      right: { style: "thin", color: { rgb: "000000" } }
    }
  };

  const etablissementStyle = {
    font: { bold: true, sz: 14, color: { rgb: "2980B9" } },
    alignment: { horizontal: "left", vertical: "center" }
  };

  const infoStyle = {
    font: { sz: 10, color: { rgb: "555555" } },
    alignment: { horizontal: "left", vertical: "center" }
  };

  const dataStyle = {
    font: { sz: 10 },
    alignment: { horizontal: "left", vertical: "center", wrapText: true },
    border: {
      top: { style: "thin", color: { rgb: "DDDDDD" } },
      bottom: { style: "thin", color: { rgb: "DDDDDD" } },
      left: { style: "thin", color: { rgb: "DDDDDD" } },
      right: { style: "thin", color: { rgb: "DDDDDD" } }
    }
  };

  const numberStyle = {
    ...dataStyle,
    alignment: { horizontal: "right", vertical: "center" },
    numFmt: "#,##0.00"
  };

  const totalStyle = {
    font: { bold: true, sz: 11, color: { rgb: "FFFFFF" } },
    fill: { fgColor: { rgb: "2980B9" } },
    alignment: { horizontal: "right", vertical: "center" },
    border: {
      top: { style: "medium", color: { rgb: "000000" } },
      bottom: { style: "medium", color: { rgb: "000000" } },
      left: { style: "medium", color: { rgb: "000000" } },
      right: { style: "medium", color: { rgb: "000000" } }
    }
  };

  // Logo et informations établissement (ligne 1-5)
  const logoInfo = [
    [etablissement.nom],
    [etablissement.adresse],
    [etablissement.tel],
    [etablissement.email],
    ['']
  ];
  
  XLSX.utils.sheet_add_aoa(ws, logoInfo, { origin: 'A1' });
  ws['A1'].s = etablissementStyle;
  ws['A2'].s = infoStyle;
  ws['A3'].s = infoStyle;
  ws['A4'].s = infoStyle;

  // Titre principal (ligne 6)
  const title = [[`JOURNAL ${journal.value ? journal.value.toUpperCase() : ''}`]];
  XLSX.utils.sheet_add_aoa(ws, title, { origin: 'A6' });
  ws['A6'].s = titleStyle;
  
  if (!ws['!merges']) ws['!merges'] = [];
  ws['!merges'].push({ s: { r: 5, c: 0 }, e: { r: 5, c: 6 } });

  // Informations du document (ligne 8-12)
  const info = [
    [''],
    [`Journal N°: ${journalId.value}`],
    [`Devise: ${defaultDevise.value ? `${defaultDevise.value.Libelle} (${defaultDevise.value.Sigle})` : 'Ariary'}`],
    [`Période: ${period}`],
    [`Date d'export: ${now.toLocaleDateString('fr-FR')} à ${now.toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' })}`],
    [`Plage: Du ${dateFilter.value.date_debut || '-'} au ${dateFilter.value.date_fin || '-'}`],
    ['']
  ];
  
  XLSX.utils.sheet_add_aoa(ws, info, { origin: 'A8' });
  for (let i = 9; i <= 13; i++) {
    if (ws[`A${i}`]) ws[`A${i}`].s = infoStyle;
  }

  // En-têtes du tableau (ligne 15)
  const headers = [
    ['Date Mouvement', 'N° Pièce', 'N° Compte', 'Référence', 'Libellé', 'Débit', 'Crédit']
  ];
  XLSX.utils.sheet_add_aoa(ws, headers, { origin: 'A15' });
  
  ['A15', 'B15', 'C15', 'D15', 'E15', 'F15', 'G15'].forEach(cell => {
    ws[cell].s = headerStyle;
  });

  // Données (à partir de ligne 16)
  const data = ecritures.value.map(ecriture => {
    const dateMouvement = ecriture.mouvement ? new Date(ecriture.mouvement.Date_mouvement).toLocaleDateString('fr-FR') : '-';
    return [
      dateMouvement,
      ecriture.mouvement?.Numero_piece || '-',
      ecriture.sous_compte?.Code_sous_compte || '-',
      ecriture.Reference || '-',
      ecriture.Libelle || '-',
      ecriture.Debit ? Number(ecriture.Debit) : 0,
      ecriture.Credit ? Number(ecriture.Credit) : 0
    ];
  });

  XLSX.utils.sheet_add_aoa(ws, data, { origin: 'A16' });

  // Application des styles aux données
  const startRow = 16;
  data.forEach((_, index) => {
    const rowNum = startRow + index;
    ['A', 'B', 'C', 'D', 'E'].forEach(col => {
      const cellRef = `${col}${rowNum}`;
      if (ws[cellRef]) ws[cellRef].s = dataStyle;
    });
    ['F', 'G'].forEach(col => {
      const cellRef = `${col}${rowNum}`;
      if (ws[cellRef]) ws[cellRef].s = numberStyle;
    });
  });

  // Ligne des totaux
  const totalRow = startRow + data.length;
  XLSX.utils.sheet_add_aoa(ws, [
    ['', '', '', '', 'TOTAUX', totalDebit.value, totalCredit.value]
  ], { origin: `A${totalRow}` });

  ['A', 'B', 'C', 'D', 'E', 'F', 'G'].forEach(col => {
    const cellRef = `${col}${totalRow}`;
    if (ws[cellRef]) ws[cellRef].s = totalStyle;
  });

  // Largeur des colonnes
  ws['!cols'] = [
    { wch: 15 },  // Date
    { wch: 15 },  // N° Pièce
    { wch: 15 },  // Compte
    { wch: 15 },  // Référence
    { wch: 40 },  // Libellé
    { wch: 15 },  // Débit
    { wch: 15 }   // Crédit
  ];

  // Hauteur des lignes
  ws['!rows'] = [
    { hpt: 25 },  // Nom établissement
    { hpt: 18 },  // Adresse
    { hpt: 18 },  // Tel
    { hpt: 18 },  // Email
    { hpt: 5 },   // Espace
    { hpt: 35 },  // Titre
    { hpt: 5 },   // Espace
    { hpt: 5 },   // Espace
    { hpt: 18 },  // Journal N°
    { hpt: 18 },  // Devise
    { hpt: 18 },  // Période
    { hpt: 18 },  // Date export
    { hpt: 18 },  // Plage
    { hpt: 5 },   // Espace
    { hpt: 25 }   // En-têtes
  ];

  // Ajout de la feuille au classeur
  XLSX.utils.book_append_sheet(wb, ws, `Journal ${journalId.value}`);

  // Sauvegarde
  const fileName = `Journal_${journalId.value}_${now.toISOString().split('T')[0]}.xlsx`;
  XLSX.writeFile(wb, fileName);
  
  console.log('Excel généré avec succès');
};

const goBack = () => {
  router.push('/journal');
};

onMounted(async () => {
  console.log("Token récupéré :", token);
  
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
      return;
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

@media (max-width: 768px) {
  .main-content {
    margin-left: 0;
    padding: 16px;
  }

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
  }
}
</style>