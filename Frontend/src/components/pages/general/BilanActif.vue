<template>
  <div class="dashboard-container w-full">
    <Header v-if="user" :user="user" />
    <Sidebar :current-route="$route.path" @navigation-change="handleNavigation" />
    <div class="main-content p-6">
      <div class="card card-form">
        <div class="p-6">
          <div class="card-header">
            <h1 class="text-3xl mb-4">
              <i class="bi bi-file-earmark-bar-graph me-2"></i> Bilan - Actif
            </h1>
          </div>
          <br>
          <div class="mb-4">
            <button @click="goBack" class="btn btn-outline">Retour</button>
          </div>
          <br>
          <div class="info-container mb-6" v-if="exerciceInfo.date_debut">
            <h2 class="text-xl mb-3 font-bold">Informations du bilan</h2>
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
                  <td colspan="6" class="p-4 text-center text-base">
                    <span class="spinner spinner-lg"></span> Chargement...
                  </td>
                </tr>
              </tbody>
            </table>
            <table v-else class="table table-bordered w-full bilan-table">
              <thead>
                <tr>
                  <th rowspan="2" class="vertical-middle">ACTIF</th>
                  <th rowspan="2" class="text-center vertical-middle">NOTE</th>
                  <th colspan="3" class="text-center">N</th>
                  <th rowspan="2" class="text-center vertical-middle">N-1<br>NET</th>
                </tr>
                <tr>
                  <th class="text-right">Brut</th>
                  <th class="text-right">Amort/Prov</th>
                  <th class="text-right">Net</th>
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
                    'subtotal-row': ligne.isSubtotal,
                    'detail-row': !ligne.isTitle && !ligne.isSubtitle && !ligne.isTotal && !ligne.isSubtotal
                  }"
                >
                  <td :class="{ 'font-bold': ligne.isTitle || ligne.isTotal, 'pl-4': ligne.isSubtitle, 'pl-8': ligne.isDetail }">
                    {{ ligne.label }}
                  </td>
                  <td class="text-center">{{ ligne.note || "" }}</td>
                  <td class="text-right" :class="{ 'font-bold': ligne.isTotal }">
                    {{ formatMontant(ligne.brutN) }}
                  </td>
                  <td class="text-right" :class="{ 'font-bold': ligne.isTotal }">
                    {{ formatMontant(ligne.amortN) }}
                  </td>
                  <td class="text-right" :class="{ 'font-bold': ligne.isTotal }">
                    {{ formatMontant(ligne.netN) }}
                  </td>
                  <td class="text-right" :class="{ 'font-bold': ligne.isTotal }">
                    {{ formatMontant(ligne.netN1) }}
                  </td>
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
import { ref, onMounted } from "vue";
import { useRouter } from "vue-router";
import axios from "axios";
import Header from "../../molecules/Header.vue";
import Sidebar from "../../molecules/Sidebar.vue";
import AppFooter from "../../molecules/Footer.vue";
import { jsPDF } from "jspdf";
import autoTable from "jspdf-autotable";
import * as XLSX from "xlsx";
import { getUser } from "../../../services/Auth";

const router = useRouter();
const user = ref(null);
const goBack = () => { router.push("/journal"); };
const handleNavigation = item => { router.push(item.route); };

const loading = ref(false);
const listeComplete = ref([]);
const exerciceInfo = ref({
  date_debut: "",
  date_fin: "",
  date_debut_n1: "",
  date_fin_n1: "",
  annee_fiscale: "",
  statut: ""
});

  const token = localStorage.getItem("token"); // Récupérer le token

if (!token) {
  // Redirection vers login si pas de token
  window.location.href = "/";
} else {
  // Configurer Axios pour inclure le token dans toutes les requêtes
  axios.defaults.headers.common["Authorization"] = `Bearer ${token}`;
}

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
    await loadExerciceOuvert();
    await fetchBilanActif();
  }
});

const loadExerciceOuvert = async () => {
  try {
    const { data: exercices } = await axios.get("http://localhost:8000/api/exercices");
    const exerciceN = exercices.find(ex => ex.Statut === 'OUVERT');
    if (exerciceN) {
      exerciceInfo.value.date_debut = exerciceN.Date_debut;
      exerciceInfo.value.date_fin = exerciceN.Date_fin;
      exerciceInfo.value.annee_fiscale = exerciceN.Annee_fiscale;
      exerciceInfo.value.statut = exerciceN.Statut;
      const indexN = exercices.findIndex(ex => ex.Statut === 'OUVERT');
      if (exercices[indexN + 1]) {
        const exerciceN1 = exercices[indexN + 1];
        exerciceInfo.value.date_debut_n1 = exerciceN1.Date_debut;
        exerciceInfo.value.date_fin_n1 = exerciceN1.Date_fin;
      }
    }
  } catch (error) {
    console.error("Erreur chargement exercice:", error);
    alert("Impossible de charger l'exercice ouvert");
  }
};

const fetchBilanActif = async () => {
  loading.value = true;
  let resN = [], resN1 = [];
  try {
    if (exerciceInfo.value.date_debut && exerciceInfo.value.date_fin) {
      const { data } = await axios.get("http://localhost:8000/api/bilan/actif", {
        params: { date_debut: exerciceInfo.value.date_debut, date_fin: exerciceInfo.value.date_fin }
      });
      resN = data;
    }
    if (exerciceInfo.value.date_debut_n1 && exerciceInfo.value.date_fin_n1) {
      const { data } = await axios.get("http://localhost:8000/api/bilan/actif", {
        params: { date_debut: exerciceInfo.value.date_debut_n1, date_fin: exerciceInfo.value.date_fin_n1 }
      });
      resN1 = data;
    }
    listeComplete.value = resN.map((ligneN, idx) => ({
      label: ligneN.label,
      note: ligneN.note || "",
      brutN: ligneN.brut,
      amortN: ligneN.amort,
      netN: ligneN.net,
      netN1: resN1[idx] ? resN1[idx].net : null,
      isTitle: ligneN.isTitle || false,
      isSubtitle: ligneN.isSubtitle || false,
      isTotal: ligneN.isTotal || false,
      isSubtotal: ligneN.isSubtotal || false,
      isDetail: !ligneN.isTitle && !ligneN.isSubtitle && !ligneN.isTotal && !ligneN.isSubtotal
    }));
  } catch (error) {
    console.error("Erreur chargement bilan actif:", error);
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
  if (!listeComplete.value.length) return alert("Aucune donnée à exporter !");
  const doc = new jsPDF('l', 'mm', 'a4');
  doc.setFontSize(16);
  doc.text("Bilan - Actif", 14, 14);
  doc.setFontSize(10);
  doc.text(`Exercice : ${exerciceInfo.value.annee_fiscale}`, 14, 22);
  doc.text(`Période : Du ${formatDate(exerciceInfo.value.date_debut)} au ${formatDate(exerciceInfo.value.date_fin)}`, 14, 28);
  
  autoTable(doc, {
    head: [
      [
        { content: 'ACTIF', rowSpan: 2 },
        { content: 'NOTE', rowSpan: 2 },
        { content: 'N', colSpan: 3 },
        { content: 'N-1 NET', rowSpan: 2 }
      ],
      ['Brut', 'Amort/Prov', 'Net']
    ],
    body: listeComplete.value.map(l => [
      l.label,
      l.note || "",
      formatMontant(l.brutN),
      formatMontant(l.amortN),
      formatMontant(l.netN),
      formatMontant(l.netN1)
    ]),
    theme: "grid",
    startY: 35,
    styles: { fontSize: 8 },
    headStyles: { fillColor: [51, 122, 183], textColor: [255, 255, 255], fontStyle: 'bold' },
  });
  doc.save("bilan_actif.pdf");
};

const exportToExcel = () => {
  if (!listeComplete.value.length) return alert("Aucune donnée à exporter !");
  const dataForExcel = listeComplete.value.map(l => ({
    'ACTIF': l.label,
    'NOTE': l.note || "",
    'Brut N': l.brutN || "",
    'Amort/Prov N': l.amortN || "",
    'Net N': l.netN || "",
    'Net N-1': l.netN1 || ""
  }));
  const dataSheet = XLSX.utils.json_to_sheet(dataForExcel);
  const wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, dataSheet, "BilanActif");
  XLSX.writeFile(wb, "bilan_actif.xlsx");
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

.bilan-table thead th { background-color: #1e40af; color: white; font-weight: 600; text-transform: uppercase; font-size: 0.875rem; padding: 0.75rem; border: 1px solid #ddd;}
.vertical-middle { vertical-align: middle !important;}

.title-row { background-color: #dbeafe !important; font-weight: bold; font-size: 1.05rem;}
.title-row td { padding: 0.75rem 1rem; color: #1e40af; font-weight: 700; border-top: 2px solid #3b82f6;}

.subtitle-row { background-color: #f0f9ff !important; font-weight: 600; font-style: italic;}
.subtitle-row td { padding: 0.6rem 1rem; color: #0369a1;}

.total-row { background-color: #e0e7ff !important; font-weight: bold; border-top: 2px solid #3b82f6; border-bottom: 2px solid #3b82f6;}
.total-row td { padding: 0.75rem 1rem; color: #1e40af; font-weight: 700;}

.subtotal-row { background-color: #ede9fe !important; font-weight: 600;}
.subtotal-row td { padding: 0.65rem 1rem; color: #5b21b6;}

.detail-row { background-color: #ffffff;}
.detail-row:hover { background-color: #f9fafb; transition: background-color 0.2s ease;}
.detail-row td { padding: 0.6rem 1rem; color: #374151;}

.pl-4 { padding-left: 1.5rem !important;}
.pl-8 { padding-left: 3rem !important;}
.font-bold { font-weight: 700;}
.table-container { overflow-x: auto; box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1); border-radius: 0.5rem; background: white;}
.table tbody tr { border-bottom: 1px solid #e5e7eb;}
.spinner { display: inline-block; width: 2rem; height: 2rem; border: 3px solid #f3f3f3; border-top: 3px solid #3498db; border-radius: 50%; animation: spin 1s linear infinite;}
@keyframes spin { from { transform: rotate(0deg); } to { transform: rotate(360deg); }}
@media (max-width: 768px) { .main-content { margin-left: 0; padding: 1rem;} .info-grid { grid-template-columns: 1fr;} .export-container { flex-direction: column !important;}}
</style>
