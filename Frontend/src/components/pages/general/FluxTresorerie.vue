<template>
  <div class="dashboard-container w-full">
    <Header v-if="user" :user="user" />
    <Sidebar :current-route="$route.path" @navigation-change="handleNavigation" />
    <div class="main-content p-6">
      <div class="card card-form">
        <div class="p-6">
          <div class="card-header">
            <h1 class="text-3xl mb-4">
              <i class="bi bi-cash-stack me-2"></i> Tableau des Flux de Trésorerie
              <span class="text-lg ml-2">(Méthode Indirecte)</span>
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
          <!-- Info Exercice -->
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
                  <td colspan="4" class="p-4 text-center text-base">
                    <span class="spinner spinner-lg"></span> Chargement...
                  </td>
                </tr>
              </tbody>
            </table>
            <table v-else class="table table-bordered w-full flux-table">
              <thead>
                <tr>
                  <th class="w-70">FLUX DE TRÉSORERIE</th>
                  <th class="text-center">NOTE</th>
                  <th class="text-right">N</th>
                  <th class="text-right">N-1</th>
                </tr>
              </thead>
              <tbody>
                <tr 
                  v-for="(ligne, idx) in listeComplete" 
                  :key="idx" 
                  :class="{
                    'title-row': ligne.isTitle,
                    'subtitle-row': ligne.isSubtitle,
                    'total-row': ligne.isTotal,
                    'detail-row': !ligne.isTitle && !ligne.isSubtitle && !ligne.isTotal
                  }"
                >
                  <td :class="{ 
                    'font-bold': ligne.isTitle || ligne.isTotal, 
                    'pl-4': ligne.isSubtitle, 
                    'pl-8': !ligne.isTitle && !ligne.isSubtitle && !ligne.isTotal 
                  }">
                    {{ ligne.label }}
                  </td>
                  <td class="text-center">{{ ligne.note || "" }}</td>
                  <td class="text-right" :class="{ 'font-bold': ligne.isTotal, 'text-red': ligne.montantN < 0 }">
                    {{ formatMontant(ligne.montantN) }}
                  </td>
                  <td class="text-right" :class="{ 'font-bold': ligne.isTotal, 'text-red': ligne.montantN1 < 0 }">
                    {{ formatMontant(ligne.montantN1) }}
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
import { jsPDF } from "jspdf";
import autoTable from "jspdf-autotable";
import * as XLSX from "xlsx";
import { getUser } from "../../../services/Auth";

const router = useRouter();
const user = ref(null);
const goBack = () => { router.push("/journal"); };
const handleNavigation = item => { router.push(item.route); };

const loading = ref(false);
const showChat = ref(false);
const listeComplete = ref([]);
const exerciceInfo = ref({
  date_debut: "",
  date_fin: "",
  date_debut_n1: "",
  date_fin_n1: "",
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
  const idx = exercices.value.findIndex(e => e.Id_Exercice_comptable == ex.Id_Exercice_comptable);
  const exN1 = exercices.value[idx + 1];
  if (exN1) {
    exerciceInfo.value.date_debut_n1 = exN1.Date_debut;
    exerciceInfo.value.date_fin_n1   = exN1.Date_fin;
  } else {
    exerciceInfo.value.date_debut_n1 = "";
    exerciceInfo.value.date_fin_n1   = "";
  }
  fetchFluxTresorerie();
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

const fetchFluxTresorerie = async () => {
  loading.value = true;
  let resN = [], resN1 = [];
  try {
    if (exerciceInfo.value.date_debut && exerciceInfo.value.date_fin) {
      const { data } = await axios.get("http://localhost:8000/api/flux-tresorerie", {
        params: { date_debut: exerciceInfo.value.date_debut, date_fin: exerciceInfo.value.date_fin }
      });
      resN = data;
    }
    if (exerciceInfo.value.date_debut_n1 && exerciceInfo.value.date_fin_n1) {
      const { data } = await axios.get("http://localhost:8000/api/flux-tresorerie", {
        params: { date_debut: exerciceInfo.value.date_debut_n1, date_fin: exerciceInfo.value.date_fin_n1 }
      });
      resN1 = data;
    }
    listeComplete.value = resN.map((ligneN, idx) => ({
      label: ligneN.label,
      note: ligneN.note || "",
      montantN: ligneN.montant,
      montantN1: resN1[idx] ? resN1[idx].montant : null,
      isTitle: ligneN.isTitle || false,
      isSubtitle: ligneN.isSubtitle || false,
      isTotal: ligneN.isTotal || false
    }));
  } catch (error) {
    console.error("Erreur chargement flux de trésorerie:", error);
    alert("Erreur lors du chargement des données");
  } finally {
    loading.value = false;
  }
};

const formatMontant = n => {
  if (n === null || n === undefined) return "";
  const absValue = Math.abs(Number(n));
  return absValue.toLocaleString("fr-FR", { minimumFractionDigits: 2 });
};

const formatDate = d => {
  if (!d) return "";
  const date = new Date(d);
  return date.toLocaleDateString("fr-FR", { day: "2-digit", month: "long", year: "numeric" });
};

const exportToPDF = () => {
  if (!listeComplete.value.length) return alert("Aucune donnée à exporter !");
  const doc = new jsPDF();
  if (logoBase64.value) {
    doc.addImage(logoBase64.value, 'PNG', 14, 4, 24, 16);
  }
  doc.setFontSize(16);
  doc.text("Tableau des Flux de Trésorerie", 44, 14);
  doc.setFontSize(10);
  doc.text("Méthode Indirecte", 14, 20);
  doc.text(`Exercice : ${exerciceInfo.value.annee_fiscale}`, 14, 26);
  doc.text(`Période : Du ${formatDate(exerciceInfo.value.date_debut)} au ${formatDate(exerciceInfo.value.date_fin)}`, 14, 32);

  autoTable(doc, {
    head: [["FLUX DE TRÉSORERIE", "NOTE", "N", "N-1"]],
    body: listeComplete.value.map(l => [
      l.label,
      l.note || "",
      formatMontant(l.montantN),
      formatMontant(l.montantN1)
    ]),
    theme: "grid",
    startY: 38,
    styles: { fontSize: 9 },
    headStyles: { fillColor: [51, 122, 183], textColor: [255, 255, 255], fontStyle: 'bold' },
  });
  doc.save("flux_tresorerie.pdf");
};

const exportToExcel = () => {
  if (!listeComplete.value.length) return alert("Aucune donnée à exporter !");
  const wsData = [
    ["TABLEAU DES FLUX DE TRÉSORERIE"],
    [""],
    ["Méthode : Indirecte"],
    [`Exercice : ${exerciceInfo.value.annee_fiscale}`],
    [`Période : Du ${formatDate(exerciceInfo.value.date_debut)} au ${formatDate(exerciceInfo.value.date_fin)}`],
    [""],
    ["FLUX DE TRÉSORERIE", "NOTE", "N", "N-1"],
    ...listeComplete.value.map(l => [
      l.label,
      l.note || "",
      formatMontant(l.montantN),
      formatMontant(l.montantN1)
    ])
  ];
  const ws = XLSX.utils.aoa_to_sheet(wsData);
  ws['!cols'] = [
    { wch: 40 }, { wch: 12 }, { wch: 20 }, { wch: 20 }
  ];
  ws['!merges'] = [{ s: { r: 0, c: 0 }, e: { r: 0, c: 3 } }];
  ["A7", "B7", "C7", "D7"].forEach(cell => {
    ws[cell].s = {
      font: { bold: true, sz: 13 },
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
  for (let r = 7; r < wsData.length; ++r) {
    for (let c = 0; c < 4; ++c) {
      const cellAddr = XLSX.utils.encode_cell({ r, c });
      if (ws[cellAddr]) {
        ws[cellAddr].s = {
          font: { sz: 12 },
          alignment: { horizontal: "center", vertical: "center" },
          border: {
            top:    { style: "thin", color: { rgb: "142c6c" } },
            left:   { style: "thin", color: { rgb: "142c6c" } },
            right:  { style: "thin", color: { rgb: "142c6c" } },
            bottom: { style: "thin", color: { rgb: "142c6c" } }
          }
        }
      }
    }
  }
  const wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, ws, "Flux_Tresorerie");
  XLSX.writeFile(wb, `flux_tresorerie_${new Date().toISOString().split("T")[0]}.xlsx`);
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

.flux-table thead th { background-color: #1e40af; color: white; font-weight: 600; text-transform: uppercase; font-size: 0.875rem; padding: 0.75rem; border: 1px solid #ddd;}
.w-70 { width: 60% !important;}

.title-row { background-color: #dbeafe !important; font-weight: bold; font-size: 1.05rem;}
.title-row td { padding: 0.75rem 1rem; color: #1e40af; font-weight: 700; border-top: 2px solid #3b82f6;}

.subtitle-row { background-color: #f0f9ff !important; font-weight: 600; font-style: italic;}
.subtitle-row td { padding: 0.6rem 1rem; color: #0369a1;}

.total-row { background-color: #e0e7ff !important; font-weight: bold; border-top: 2px solid #3b82f6; border-bottom: 2px solid #3b82f6;}
.total-row td { padding: 0.75rem 1rem; color: #1e40af; font-weight: 700;}

.detail-row { background-color: #ffffff;}
.detail-row:hover { background-color: #f9fafb; transition: background-color 0.2s ease;}
.detail-row td { padding: 0.6rem 1rem; color: #374151;}

.pl-4 { padding-left: 1.5rem !important;}
.pl-8 { padding-left: 3rem !important;}
.font-bold { font-weight: 700;}
.text-red { color: #dc2626 !important;}
.table-container { overflow-x: auto; box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1); border-radius: 0.5rem; background: white;}
.table tbody tr { border-bottom: 1px solid #e5e7eb;}
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
