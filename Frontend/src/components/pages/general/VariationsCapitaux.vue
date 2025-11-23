<template>
  <div class="dashboard-container w-full">
    <Header v-if="user" :user="user" />
    <Sidebar :current-route="$route.path" @navigation-change="handleNavigation" />
    <div class="main-content p-6">
      <div class="card card-form">
        <div class="p-6">
          <div class="card-header">
            <h1 class="text-3xl mb-4">
              <i class="bi bi-graph-up-arrow me-2"></i> Tableau des Variations des Capitaux Propres
            </h1>
          </div>
          <br>
          <div class="mb-4">
            <button @click="goBack" class="btn btn-outline">Retour</button>
          </div>
          <br>
          <!-- FILTRE EXERCICE -->
          <div class="filter-section mb-6" v-if="exercices.length">
            <label>
              <strong>Sélectionner un exercice :</strong>
              <select v-model="selectedExercice" @change="onExerciceChange" class="form-select">
                <option v-for="ex in exercices" :key="ex.Id_Exercice_comptable" :value="ex.Id_Exercice_comptable">
                  {{ ex.Annee_fiscale }} - Du {{ formatDate(ex.Date_debut) }} au {{ formatDate(ex.Date_fin) }}
                </option>
              </select>
            </label>
          </div>
          <br>
          <div class="info-container mb-6" v-if="exerciceInfo.date_debut">
            <h2 class="text-xl mb-3 font-bold">Informations du tableau</h2>
            <div class="info-grid">
              <div class="info-item">
                <span class="info-label">Exercice :</span>
                <span class="info-value">{{ exerciceInfo.annee_fiscale }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Période :</span>
                <span class="info-value">Du {{ formatDate(exerciceInfo.date_debut) }} au {{ formatDate(exerciceInfo.date_fin) }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Unité monétaire :</span>
                <span class="info-value">Ariary (Ar)</span>
              </div>
              <div class="info-item">
                <span class="info-label">Statut :</span>
                <span class="info-value badge" :class="exerciceInfo.statut === 'OUVERT' ? 'badge-success' : 'badge-secondary'">
                  {{ exerciceInfo.statut }}
                </span>
              </div>
            </div>
          </div>
          <br>
          <div class="export-container mb-6 d-flex gap-4">
            <button @click="exportToPDF" class="btn btn-primary">Exporter en PDF</button>
            <button @click="exportToExcel" class="btn btn-primary">Exporter en Excel</button>
          </div>
          <br>
          <div class="table-container mt-6">
            <table v-if="loading" class="table table-bordered table-striped w-full">
              <tbody>
                <tr>
                  <td colspan="8" class="p-4 text-center text-base">
                    <span class="spinner spinner-lg"></span> Chargement...
                  </td>
                </tr>
              </tbody>
            </table>
            <table v-else class="table table-bordered w-full variations-table">
              <thead>
                <tr>
                  <th class="w-30">CAPITAUX PROPRES</th>
                  <th class="text-right">Capital</th>
                  <th class="text-right">Primes & Réserves</th>
                  <th class="text-right">Écarts évaluation</th>
                  <th class="text-right">Écart équivalence</th>
                  <th class="text-right">Résultat</th>
                  <th class="text-right">Report à nouveau</th>
                  <th class="text-right">Total</th>
                </tr>
              </thead>
              <tbody>
                <tr 
                  v-for="(ligne, idx) in listeComplete" 
                  :key="idx" 
                  :class="{
                    'total-row': ligne.isTotal,
                    'detail-row': ligne.isDetail
                  }"
                >
                  <td :class="{ 'font-bold': ligne.isTotal }">{{ ligne.label }}</td>
                  <td class="text-right" :class="{ 'font-bold': ligne.isTotal }">
                    {{ formatMontant(ligne.capital) }}
                  </td>
                  <td class="text-right" :class="{ 'font-bold': ligne.isTotal }">
                    {{ formatMontant(ligne.prime) }}
                  </td>
                  <td class="text-right" :class="{ 'font-bold': ligne.isTotal }">
                    {{ formatMontant(ligne.eval) }}
                  </td>
                  <td class="text-right" :class="{ 'font-bold': ligne.isTotal }">
                    {{ formatMontant(ligne.equiv) }}
                  </td>
                  <td class="text-right" :class="{ 'font-bold': ligne.isTotal }">
                    {{ formatMontant(ligne.result) }}
                  </td>
                  <td class="text-right" :class="{ 'font-bold': ligne.isTotal }">
                    {{ formatMontant(ligne.autcpro) }}
                  </td>
                  <td class="text-right" :class="{ 'font-bold': ligne.isTotal }">
                    {{ formatMontant(ligne.total) }}
                  </td>
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
import { ref, onMounted } from "vue";
import { useRouter } from "vue-router";
import axios from "axios";
import Header from "../../molecules/Header.vue";
import Sidebar from "../../molecules/Sidebar.vue";
import AppFooter from "../../molecules/Footer.vue";
import ChatBot from "../../molecules/ChatBot.vue";
import html2pdf from 'html2pdf.js';
import * as XLSX from 'xlsx-js-style';
import { getUser } from "../../../services/Auth";

const router = useRouter();
const user = ref(null);
const showChat = ref(false);
const goBack = () => { router.push("/journal"); };
const handleNavigation = item => { router.push(item.route); };

const loading = ref(false);
const listeComplete = ref([]);
const exerciceInfo = ref({
  date_debut: "",
  date_fin: "",
  annee_fiscale: "",
  statut: ""
});

const exercices = ref([]);
const selectedExercice = ref("");
const exerciceCourantId = ref("");

// ------------ LOGO PDF ------------
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

const token = localStorage.getItem("token");
if (!token) {
  window.location.href = "/";
} else {
  axios.defaults.headers.common["Authorization"] = `Bearer ${token}`;
}

const fetchExerciceCourant = async () => {
  try {
    const { data } = await axios.get("http://localhost:8000/api/exercices/courant");
    exerciceCourantId.value = data.Id_Exercice_comptable ?? (data.exercice?.Id_Exercice_comptable) ?? "";
  } catch (e) {
    exerciceCourantId.value = "";
  }
};

const loadExercices = async () => {
  try {
    const { data } = await axios.get("http://localhost:8000/api/exercices");
    exercices.value = Array.isArray(data) ? data : (data.exercices || []);
  } catch (error) {
    exercices.value = [];
  }
};

const onExerciceChange = () => {
  const ex = exercices.value.find(e => e.Id_Exercice_comptable == selectedExercice.value);
  if (!ex) return;
  exerciceInfo.value.date_debut    = ex.Date_debut;
  exerciceInfo.value.date_fin      = ex.Date_fin;
  exerciceInfo.value.annee_fiscale = ex.Annee_fiscale;
  exerciceInfo.value.statut        = ex.Statut;
  fetchVariationsCapitaux();
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
    await fetchExerciceCourant();
    await loadExercices();
    if (exercices.value.length) {
      const courant = exercices.value.find(e => e.Id_Exercice_comptable == exerciceCourantId.value);
      selectedExercice.value = courant
        ? courant.Id_Exercice_comptable
        : exercices.value[0].Id_Exercice_comptable;
      onExerciceChange();
    }
  }
});

const fetchVariationsCapitaux = async () => {
  loading.value = true;
  try {
    if (exerciceInfo.value.date_debut && exerciceInfo.value.date_fin) {
      const { data } = await axios.get("http://localhost:8000/api/variations-capitaux", {
        params: { date_debut: exerciceInfo.value.date_debut, date_fin: exerciceInfo.value.date_fin }
      });
      listeComplete.value = data;
    }
  } catch (error) {
    console.error("Erreur chargement variations capitaux:", error);
    alert("Erreur lors du chargement des données");
  } finally {
    loading.value = false;
  }
};

const formatMontant = n => {
  if (n === null || n === undefined) return "";
  return Math.abs(Number(n)).toLocaleString("fr-FR", { minimumFractionDigits: 2 });
};

const formatDate = d => {
  if (!d) return "";
  const date = new Date(d);
  return date.toLocaleDateString("fr-FR", { day: "2-digit", month: "long", year: "numeric" });
};



const exportToPDF = () => {
  if (!listeComplete.value.length) {
    alert("Aucune donnée à exporter !");
    return;
  }
  const now = new Date();

  // Header (branding)
  const header = `
    <div style="display: flex; align-items: flex-start; border-bottom: 3px solid #2980b9; padding-bottom: 11px; margin-bottom: 8px;">
      <div style="flex: 0 0 70px;">
        <img src="${logoBase64.value || ''}" style="width:58px; height:auto;" />
      </div>
      <div style="flex:1; padding-left:10px;">
        <div style="font-size:10px; color:#555;">
          <div style="font-weight:bold; font-size:12px; color:#2c3e50;">RAITRA KIDZ</div>
          <div>Antananarivo, Madagascar</div>
          <div>+261 XX XX XXX XX</div>
        </div>
      </div>
      <div style="flex:2;text-align:center;">
        <h1 style="font-size:18px; font-weight:700; color:#1c45bd;margin:0 0 5px 0;">Tableau des Variations des Capitaux Propres</h1>
        <div style="font-size:10px; margin:2px 0;">Exercice : ${exerciceInfo.value.annee_fiscale || ''}</div>
        <div style="font-size:9px;">Période : Du ${formatDate(exerciceInfo.value.date_debut)} au ${formatDate(exerciceInfo.value.date_fin)}</div>
        <div style="font-size:9px;">Statut : ${exerciceInfo.value.statut || '-'}</div>
        <div style="font-size:9px;">Unité monétaire : Ariary (Ar)</div>
      </div>
      <div style="flex:0 0 90px;text-align:right;font-size:8px;color:#555;">
        <div><strong>Date édition:</strong></div>
        <div>${now.toLocaleDateString('fr-FR')} ${now.toLocaleTimeString('fr-FR', { hour:'2-digit', minute:'2-digit' })}</div>
      </div>
    </div>`;

  // Table rows
  const tableRows = listeComplete.value.map(l =>
    `<tr
      style="${l.isTotal ? 'background:#e0e7ff;font-weight:700;font-size:10px;color:#1e40af;' : 'font-size:9px;background:#f0f9ff;'}">
      <td style="padding:6px 4px;${l.isTotal?'font-weight:700;':''}border:1px solid #ddd;">
        ${l.label ?? ""}
      </td>
      <td style="padding:6px 3px;text-align:right;border:1px solid #ddd;">${formatMontant(l.capital)}</td>
      <td style="padding:6px 3px;text-align:right;border:1px solid #ddd;">${formatMontant(l.prime)}</td>
      <td style="padding:6px 3px;text-align:right;border:1px solid #ddd;">${formatMontant(l.eval)}</td>
      <td style="padding:6px 3px;text-align:right;border:1px solid #ddd;">${formatMontant(l.equiv)}</td>
      <td style="padding:6px 3px;text-align:right;border:1px solid #ddd;">${formatMontant(l.result)}</td>
      <td style="padding:6px 3px;text-align:right;border:1px solid #ddd;">${formatMontant(l.autcpro)}</td>
      <td style="padding:6px 3px;text-align:right;border:1px solid #ddd;${l.isTotal?'font-weight:700;':''}">${formatMontant(l.total)}</td>
    </tr>`
  ).join('');

  const htmlContent = `
    <div style="font-family:'Manrope',sans-serif;max-width:1100px;margin:auto;">
      ${header}
      <table style="width:1040px;max-width:100%;border-collapse:collapse;margin:10px auto 0 auto;">
        <thead>
          <tr style="background:linear-gradient(135deg,#2980b9 0%,#1e40af 100%);color:#fff;">
            <th style="padding:8px 4px;border:1px solid #1e40af;font-size:10px;">CAPITAUX PROPRES</th>
            <th style="padding:8px 4px;border:1px solid #1e40af;font-size:10px;text-align:right;">Capital</th>
            <th style="padding:8px 4px;border:1px solid #1e40af;font-size:10px;text-align:right;">Primes & Réserves</th>
            <th style="padding:8px 4px;border:1px solid #1e40af;font-size:10px;text-align:right;">Écarts évaluation</th>
            <th style="padding:8px 4px;border:1px solid #1e40af;font-size:10px;text-align:right;">Écart équivalence</th>
            <th style="padding:8px 4px;border:1px solid #1e40af;font-size:10px;text-align:right;">Résultat</th>
            <th style="padding:8px 4px;border:1px solid #1e40af;font-size:10px;text-align:right;">Report à nouveau</th>
            <th style="padding:8px 4px;border:1px solid #1e40af;font-size:10px;text-align:right;">Total</th>
          </tr>
        </thead>
        <tbody>
          ${tableRows}
        </tbody>
      </table>
      <div style="margin-top:13px;text-align:center;font-size:8.5px;color:#888;">
        RAITRA KIDZ © ${now.getFullYear()} | Tableau des Variations - Export PDF
      </div>
    </div>
  `;

  const element = document.createElement('div');
  element.innerHTML = htmlContent;
  element.style.width = '1040px';
  element.style.margin = '0 auto';
  document.body.appendChild(element);

  html2pdf()
    .set({
      margin: [8, 5, 14, 5],
      filename: `variations_capitaux_propres_${now.toISOString().split("T")[0]}.pdf`,
      image: { type: 'jpeg', quality: 0.98 },
      html2canvas: { scale: 2, useCORS: true },
      jsPDF: { unit: 'mm', format: 'a4', orientation: 'landscape' }
    })
    .from(element)
    .save()
    .then(() => document.body.removeChild(element))
    .catch(err => {
      document.body.removeChild(element);
      alert("Erreur lors de la génération du PDF.");
      console.error(err);
    });
};




const exportToExcel = () => {
  if (!listeComplete.value.length) return alert("Aucune donnée à exporter !");
  const now = new Date();
  const etablissement = {
    nom: "RAITRA KIDZ",
    adresse: "Antananarivo, Madagascar",
    tel: "+261 XX XX XXX XX",
    email: "contact@raitrakidz.mg"
  };

  const titre = [[`TABLEAU DES VARIATIONS DES CAPITAUX PROPRES – RAITRA KIDZ`]];
  const info = [
    [etablissement.nom],
    [etablissement.adresse],
    [etablissement.tel],
    [etablissement.email],
    [''],
    [`Exercice : ${exerciceInfo.value.annee_fiscale || ''}`],
    [`Période : Du ${formatDate(exerciceInfo.value.date_debut)} au ${formatDate(exerciceInfo.value.date_fin)}`],
    [`Statut : ${exerciceInfo.value.statut || "-"}`],
    [`Unité monétaire : Ariary (Ar)`],
    [`Date édition : ${now.toLocaleDateString('fr-FR')} à ${now.toLocaleTimeString('fr-FR', {hour:'2-digit',minute:'2-digit'})}`],
    ['']
  ];

  const headers = [
    ["CAPITAUX PROPRES", "Capital", "Primes & Réserves", "Écarts évaluation", "Écart équivalence", "Résultat", "Report à nouveau", "Total"]
  ];

  const dataRows = listeComplete.value.map(l => [
    l.label,
    l.capital !== null && l.capital !== undefined ? formatMontant(l.capital) : '',
    l.prime !== null && l.prime !== undefined ? formatMontant(l.prime) : '',
    l.eval !== null && l.eval !== undefined ? formatMontant(l.eval) : '',
    l.equiv !== null && l.equiv !== undefined ? formatMontant(l.equiv) : '',
    l.result !== null && l.result !== undefined ? formatMontant(l.result) : '',
    l.autcpro !== null && l.autcpro !== undefined ? formatMontant(l.autcpro) : '',
    l.total !== null && l.total !== undefined ? formatMontant(l.total) : ''
  ]);

  // Sheet création
  const ws = XLSX.utils.aoa_to_sheet([]);
  XLSX.utils.sheet_add_aoa(ws, titre, { origin: 'A1' });
  info.forEach((val, i) => XLSX.utils.sheet_add_aoa(ws, [val], { origin: `A${i+2}` }));
  XLSX.utils.sheet_add_aoa(ws, headers, { origin: 'A14' });
  XLSX.utils.sheet_add_aoa(ws, dataRows, { origin: 'A15' });

  ws['!cols'] = [
    { wch: 30 }, { wch: 18 }, { wch: 20 }, { wch: 18 }, { wch: 18 }, { wch: 18 }, { wch: 20 }, { wch: 22 }
  ];

  ws['!merges'] = [
    { s: { r: 0, c: 0 }, e: { r: 0, c: 7 } },
    ...[1,2,3,4,5,6,7,8,9,10,11,12,13].map(i => ({ s: { r: i, c: 0 }, e: { r: i, c: 7 } }))
  ];

  // Titre principal
  ws['A1'].s = {
    font: { bold: true, sz: 18, color: { rgb: "1C45BD" } },
    alignment: { horizontal: "center", vertical: "center" }
  };
  for (let i = 2; i <= 5; ++i) {
    const cell = `A${i}`;
    if (ws[cell]) ws[cell].s = {
      font: { sz: 11, bold: (i==2), color: { rgb: "222831" } },
      alignment: { horizontal: "left", vertical: "center" }
    };
  }
  for (let i = 6; i <= 13; ++i) {
    const cell = `A${i}`;
    if (ws[cell]) ws[cell].s = {
      font: { sz: 10, color: { rgb: "555555" } },
      alignment: { horizontal: "left", vertical: "center" }
    };
  }

  // En-tête du tableau
  ['A14','B14','C14','D14','E14','F14','G14','H14'].forEach(cell => {
    if (ws[cell]) ws[cell].s = {
      font: { bold: true, sz: 12, color: { rgb: "FFFFFF" } },
      fill: { fgColor: { rgb: "1C45BD" } },
      alignment: { horizontal: "center", vertical: "center" },
      border: {
        top:    { style: "thick", color: { rgb: "1C45BD" } },
        left:   { style: "thin", color: { rgb: "1C45BD" } },
        right:  { style: "thin", color: { rgb: "1C45BD" } },
        bottom: { style: "thick", color: { rgb: "1C45BD" } }
      }
    };
  });

  // Données tableau
  const firstDataRow = 15;
  for (let i = 0; i < dataRows.length; ++i) {
    const rowIdx = firstDataRow + i;
    const ligne = listeComplete.value[i];
    ['A','B','C','D','E','F','G','H'].forEach((col, j) => {
      const cell = `${col}${rowIdx}`;
      if (!ws[cell]) return;
      if (ligne.isTotal) {
        ws[cell].s = {
          font: { bold: true, sz: 12, color: { rgb: "1e40af" } },
          fill: { fgColor: { rgb: "e0e7ff" } },
          alignment: { horizontal: "center", vertical: "center" },
          border: {
            top:    { style: "medium", color: { rgb: "3b82f6" } },
            left:   { style: "thin", color: { rgb: "3b82f6" } },
            right:  { style: "thin", color: { rgb: "3b82f6" } },
            bottom: { style: "medium", color: { rgb: "3b82f6" } }
          }
        };
      } else {
        ws[cell].s = {
          font: { sz: 10 },
          alignment: { horizontal: "left", vertical: "center" },
          border: {
            top:    { style: "thin", color: { rgb: "e5e7eb" } },
            left:   { style: "thin", color: { rgb: "e5e7eb" } },
            right:  { style: "thin", color: { rgb: "e5e7eb" } },
            bottom: { style: "thin", color: { rgb: "e5e7eb" } }
          }
        };
        // Format nombre pour colonnes numériques
        if (j >= 1 && ws[cell].v !== '') {
          ws[cell].z = "#,##0.00";
        }
      }
    });
  }

  const wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, ws, "Variations_Capitaux");
  XLSX.writeFile(wb, `variations_capitaux_propres_${now.toISOString().split("T")[0]}.xlsx`);
};

</script>


<style scoped>
.dashboard-container { display: flex; min-height: 100vh; flex-direction: column; }
.main-content { margin-left: 278px; padding: 32px; flex: 1; background: #f8fafb; min-height: calc(100vh - 80px);}
.info-container, .export-container { background: white; padding: 1.5rem; border-radius: 0.75rem; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);}
.info-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 1rem;}
.info-item { display: flex; flex-direction: column; gap: 0.25rem;}
.info-label { font-size: 0.875rem; color: #6b7280; font-weight: 500;}
.info-value { font-size: 1rem; color: #1f2937; font-weight: 600;}
.badge { display: inline-block; width: fit-content; padding: 0.25rem 0.75rem; border-radius: 9999px; font-size: 0.875rem; font-weight: 600;}
.badge-success { background-color: #d1fae5; color: #065f46;}
.badge-secondary { background-color: #e5e7eb; color: #374151;}

.variations-table thead th { background-color: #1e40af; color: white; font-weight: 600; text-transform: uppercase; font-size: 0.75rem; padding: 0.75rem; border: 1px solid #ddd;}
.w-30 { width: 25% !important;}

.total-row { background-color: #e0e7ff !important; font-weight: bold; border-top: 2px solid #3b82f6; border-bottom: 2px solid #3b82f6;}
.total-row td { padding: 0.75rem 1rem; color: #1e40af; font-weight: 700;}

.detail-row { background-color: #f0f9ff;}
.detail-row td { padding: 0.6rem 1rem; color: #374151;}
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
.font-bold { font-weight: 700;}
.table-container { overflow-x: auto; box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1); border-radius: 0.5rem; background: white;}
.table tbody tr { border-bottom: 1px solid #e5e7eb;}
.spinner { display: inline-block; width: 2rem; height: 2rem; border: 3px solid #f3f3f3; border-top: 3px solid #3498db; border-radius: 50%; animation: spin 1s linear infinite;}
@keyframes spin { from { transform: rotate(0deg); } to { transform: rotate(360deg); }}
@media (max-width: 768px) { .main-content { margin-left: 0; padding: 1rem;} .info-grid { grid-template-columns: 1fr;} .export-container { flex-direction: column !important;}.dashboard-chatbot-chatbox {
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
  }}
</style>
