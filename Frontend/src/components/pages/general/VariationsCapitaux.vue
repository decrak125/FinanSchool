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
  annee_fiscale: "",
  statut: ""
});

const exercices = ref([]);
const selectedExercice = ref("");
const exerciceCourantId = ref("");

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
  if (!listeComplete.value.length) return alert("Aucune donnée à exporter !");
  const doc = new jsPDF('l', 'mm', 'a4');
  doc.setFontSize(14);
  doc.text("Tableau des Variations des Capitaux Propres", 14, 14);
  doc.setFontSize(10);
  doc.text(`Exercice : ${exerciceInfo.value.annee_fiscale}`, 14, 20);

  autoTable(doc, {
    head: [["CAPITAUX PROPRES", "Capital", "Primes & Réserves", "Écarts évaluation", "Écart équivalence", "Résultat", "Report à nouveau", "Total"]],
    body: listeComplete.value.map(l => [
      l.label,
      formatMontant(l.capital),
      formatMontant(l.prime),
      formatMontant(l.eval),
      formatMontant(l.equiv),
      formatMontant(l.result),
      formatMontant(l.autcpro),
      formatMontant(l.total)
    ]),
    theme: "grid",
    startY: 26,
    styles: { fontSize: 8 },
    headStyles: { fillColor: [51, 122, 183], textColor: [255, 255, 255], fontStyle: 'bold' },
  });
  doc.save("variations_capitaux_propres.pdf");
};

const exportToExcel = () => {
  if (!listeComplete.value.length) return alert("Aucune donnée à exporter !");
  const dataForExcel = listeComplete.value.map(l => ({
    'CAPITAUX PROPRES': l.label,
    'Capital': l.capital || "",
    'Primes & Réserves': l.prime || "",
    'Écarts évaluation': l.eval || "",
    'Écart équivalence': l.equiv || "",
    'Résultat': l.result || "",
    'Report à nouveau': l.autcpro || "",
    'Total': l.total || ""
  }));
  const dataSheet = XLSX.utils.json_to_sheet(dataForExcel);
  const wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, dataSheet, "VariationsCapitaux");
  XLSX.writeFile(wb, "variations_capitaux_propres.xlsx");
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

.font-bold { font-weight: 700;}
.table-container { overflow-x: auto; box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1); border-radius: 0.5rem; background: white;}
.table tbody tr { border-bottom: 1px solid #e5e7eb;}
.spinner { display: inline-block; width: 2rem; height: 2rem; border: 3px solid #f3f3f3; border-top: 3px solid #3498db; border-radius: 50%; animation: spin 1s linear infinite;}
@keyframes spin { from { transform: rotate(0deg); } to { transform: rotate(360deg); }}
@media (max-width: 768px) { .main-content { margin-left: 0; padding: 1rem;} .info-grid { grid-template-columns: 1fr;} .export-container { flex-direction: column !important;}}
</style>
