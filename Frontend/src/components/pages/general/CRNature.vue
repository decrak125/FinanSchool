<template>
  <div class="dashboard-container w-full">
    <Header />
    <Sidebar :current-route="$route.path" @navigation-change="handleNavigation" />
    <div class="main-content p-6">
      <div class="card card-form">
        <div class="p-6">
          <div class="card-header">
            <h1 class="text-3xl mb-4">
              <i class="bi bi-table me-2"></i> Compte de Résultat par Nature
            </h1>
          </div>
          <div class="mb-4">
            <button @click="goBack" class="btn btn-outline">Retour</button>
          </div>
          <div class="info-container mb-6" v-if="exerciceInfo.date_debut">
            <h2 class="text-xl mb-3 font-bold">Informations du compte de résultat</h2>
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
          <div class="export-container mb-6 d-flex gap-4">
            <button @click="exportToPDF" class="btn btn-primary">Exporter en PDF</button>
            <button @click="exportToExcel" class="btn btn-primary">Exporter en Excel</button>
          </div>
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
            <table v-else class="table table-bordered w-full">
              <thead>
                <tr>
                  <th>POSTE</th>
                  <th>NOTE</th>
                  <th class="text-right">N</th>
                  <th class="text-right">N-1</th>
                </tr>
              </thead>
              <tbody>
                <tr 
                  v-for="(ligne, idx) in listeComplete" 
                  :key="idx" 
                  :class="{ 'total-row': ligne.isTotal, 'detail-row': !ligne.isTotal }"
                >
                  <td :class="{ 'font-bold': ligne.isTotal, 'pl-6': !ligne.isTotal }">
                    {{ ligne.label }}
                  </td>
                  <td class="text-center">{{ ligne.note || "" }}</td>
                  <td class="text-right" :class="{ 'font-bold': ligne.isTotal, 'text-red': ligne.montantN < 0 }">
                    {{ formatMontantAbsolu(ligne.montantN) }}
                  </td>
                  <td class="text-right" :class="{ 'font-bold': ligne.isTotal, 'text-red': ligne.montantN1 < 0 }">
                    {{ formatMontantAbsolu(ligne.montantN1) }}
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

const router = useRouter();
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

onMounted(async () => {
  await loadExerciceOuvert();
  await fetchResultats();
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

const fetchResultats = async () => {
  loading.value = true;
  let resN = [], resN1 = [];
  try {
    if (exerciceInfo.value.date_debut && exerciceInfo.value.date_fin) {
      const { data } = await axios.get("http://localhost:8000/api/compte-resultat/nature", {
        params: { date_debut: exerciceInfo.value.date_debut, date_fin: exerciceInfo.value.date_fin }
      });
      resN = data;
    }
    if (exerciceInfo.value.date_debut_n1 && exerciceInfo.value.date_fin_n1) {
      const { data } = await axios.get("http://localhost:8000/api/compte-resultat/nature", {
        params: { date_debut: exerciceInfo.value.date_debut_n1, date_fin: exerciceInfo.value.date_fin_n1 }
      });
      resN1 = data;
    }
    listeComplete.value = resN.map((ligneN, idx) => ({
      label: ligneN.label,
      note: ligneN.note || "",
      montantN: ligneN.montant,
      montantN1: resN1[idx] ? resN1[idx].montant : "",
      isTotal: ligneN.isTotal || false
    }));
  } catch (error) {
    console.error("Erreur chargement compte de résultat:", error);
    alert("Erreur lors du chargement des données");
  } finally {
    loading.value = false;
  }
};

const formatMontantAbsolu = n => {
  if (!n && n !== 0) return "";
  return Math.abs(Number(n)).toLocaleString("fr-FR", { minimumFractionDigits: 2 });
};

const formatDate = d => {
  if (!d) return "";
  const date = new Date(d);
  return date.toLocaleDateString("fr-FR", { day: "2-digit", month: "long", year: "numeric" });
};

const exportToPDF = () => {
  if (!listeComplete.value.length) return alert("Aucune donnée à exporter !");
  const doc = new jsPDF();
  doc.setFontSize(16);
  doc.text("Compte de Résultat par Nature", 14, 14);
  doc.setFontSize(10);
  doc.text(`Exercice : ${exerciceInfo.value.annee_fiscale}`, 14, 22);
  doc.text(`Période : Du ${formatDate(exerciceInfo.value.date_debut)} au ${formatDate(exerciceInfo.value.date_fin)}`, 14, 28);
  doc.text(`Unité monétaire : Ariary (Ar)`, 14, 34);
  autoTable(doc, {
    head: [["POSTE", "NOTE", "N", "N-1"]],
    body: listeComplete.value.map(l => [l.label, l.note || "", formatMontantAbsolu(l.montantN), formatMontantAbsolu(l.montantN1)]),
    theme: "grid",
    startY: 40,
    styles: { fontSize: 9 },
    headStyles: { fillColor: [51, 122, 183], textColor: [255, 255, 255], fontStyle: 'bold' },
  });
  doc.save("compte_resultat_nature.pdf");
};

const exportToExcel = () => {
  if (!listeComplete.value.length) return alert("Aucune donnée à exporter !");
  const dataForExcel = listeComplete.value.map(l => ({
    'POSTE': l.label,
    'NOTE': l.note || "",
    'N': Math.abs(l.montantN),
    'N-1': Math.abs(l.montantN1)
  }));
  const dataSheet = XLSX.utils.json_to_sheet(dataForExcel);
  const wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, dataSheet, "RésultatNature");
  XLSX.writeFile(wb, "compte_resultat_nature.xlsx");
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
.total-row { background-color: #e0e7ff !important; font-weight: bold; border-top: 2px solid #3b82f6; border-bottom: 2px solid #3b82f6;}
.total-row td { padding: 0.75rem 1rem; color: #1e40af; font-weight: 700;}
.detail-row { background-color: #ffffff;}
.detail-row:hover { background-color: #f9fafb; transition: background-color 0.2s ease;}
.detail-row td { padding: 0.6rem 1rem; color: #374151;}
.pl-6 { padding-left: 2.5rem !important;}
.font-bold { font-weight: 700;}
.text-red { color: #dc2626 !important; font-weight: 600;}
.table-container { overflow-x: auto; box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1); border-radius: 0.5rem; background: white;}
.table thead th { background-color: #1e40af; color: white; font-weight: 600; text-transform: uppercase; font-size: 0.875rem; padding: 1rem; border: none;}
.table tbody tr { border-bottom: 1px solid #e5e7eb;}
.table tbody tr:last-child { border-bottom: none;}
.spinner { display: inline-block; width: 2rem; height: 2rem; border: 3px solid #f3f3f3; border-top: 3px solid #3498db; border-radius: 50%; animation: spin 1s linear infinite;}
@keyframes spin { from { transform: rotate(0deg); } to { transform: rotate(360deg); }}
@media (max-width: 768px) { .main-content { margin-left: 0; padding: 1rem;} .info-grid { grid-template-columns: 1fr;} .export-container { flex-direction: column !important;}}
</style>
