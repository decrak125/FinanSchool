<template>
  <div class="dashboard-container w-full">
    <Header />
    <Sidebar :current-route="$route.path" @navigation-change="handleNavigation" />
    <div class="main-content p-6">
      <div class="card card-form">
        <div class="p-6">
          <!-- Titre -->
          <div class="card-header" style="font-family: 'Stara', sans-serif;">
            <h1 class="text-3xl mb-4">
              <i class="bi bi-file-earmark-bar-graph me-2"></i> Compte de Résultat par Nature
            </h1>
          </div>
          <br>
          <!-- Bouton Retour -->
          <div class="mb-4">
            <button @click="goBack" class="btn btn-outline">Retour</button>
          </div>
          <br>
          <!-- Informations de l'exercice -->
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
          <br>
          <!-- Export -->
          <div class="export-container mb-6 d-flex gap-4">
            <button @click="exportToPDF" class="btn btn-primary">Exporter en PDF</button>
            <button @click="exportToExcel" class="btn btn-primary">Exporter en Excel</button>
          </div>
          <br>
          <!-- Tableau -->
          <div class="table-container mt-6" style="font-family: 'Stara', sans-serif; ">
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
                  :class="{
                    'section-title': ligne.isSection,
                    'total-row': ligne.isTotal,
                    'subtotal-row': ligne.isSubtotal,
                    'detail-row': !ligne.isTotal && !ligne.isSubtotal && !ligne.isSection
                  }"
                >
                  <td :class="{ 
                    'font-bold text-lg': ligne.isSection, 
                    'font-bold': ligne.isTotal || ligne.isSubtotal, 
                    'pl-4': !ligne.isTotal && !ligne.isSubtotal && !ligne.isSection 
                  }">
                    {{ ligne.label }}
                  </td>
                  <td class="text-center">{{ ligne.note || "" }}</td>
                  <td 
                    class="text-right" 
                    :class="{ 
                      'font-bold': ligne.isTotal || ligne.isSubtotal || ligne.isSection, 
                      'text-red': ligne.montantN < 0 
                    }"
                  >
                    {{ formatMontantAbsolu(ligne.montantN) }}
                  </td>
                  <td 
                    class="text-right" 
                    :class="{ 
                      'font-bold': ligne.isTotal || ligne.isSubtotal || ligne.isSection, 
                      'text-red': ligne.montantN1 < 0 
                    }"
                  >
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

// Chargement automatique au montage
onMounted(async () => {
  await loadExerciceOuvert();
  await fetchResultats();
});

// Récupérer l'exercice courant et N-1
const loadExerciceOuvert = async () => {
  try {
    // Récupérer l'exercice courant basé sur la date actuelle
    const { data: exerciceCourant } = await axios.get("http://localhost:8000/api/exercices/courant");
    const exerciceN = exerciceCourant.exercice;
    
    if (exerciceN) {
      exerciceInfo.value.date_debut = exerciceN.Date_debut;
      exerciceInfo.value.date_fin = exerciceN.Date_fin;
      exerciceInfo.value.annee_fiscale = exerciceN.Annee_fiscale;
      exerciceInfo.value.statut = exerciceN.Statut;

      // Récupérer tous les exercices pour trouver N-1
      const { data: exercices } = await axios.get("http://localhost:8000/api/exercices");
      const indexN = exercices.findIndex(ex => ex.Id_Exercice_comptable === exerciceN.Id_Exercice_comptable);
      
      if (exercices[indexN + 1]) {
        const exerciceN1 = exercices[indexN + 1];
        exerciceInfo.value.date_debut_n1 = exerciceN1.Date_debut;
        exerciceInfo.value.date_fin_n1 = exerciceN1.Date_fin;
      }
    }
  } catch (error) {
    console.error("Erreur chargement exercice:", error);
    alert("Impossible de charger l'exercice courant");
  }
};

const fetchResultats = async () => {
  loading.value = true;
  let resN = [], resN1 = [];

  try {
    if (exerciceInfo.value.date_debut && exerciceInfo.value.date_fin) {
      const { data } = await axios.get("http://localhost:8000/api/compte-resultat/nature", {
        params: {
          date_debut: exerciceInfo.value.date_debut,
          date_fin: exerciceInfo.value.date_fin
        }
      });
      resN = data;
    }
    
    if (exerciceInfo.value.date_debut_n1 && exerciceInfo.value.date_fin_n1) {
      const { data } = await axios.get("http://localhost:8000/api/compte-resultat/nature", {
        params: {
          date_debut: exerciceInfo.value.date_debut_n1,
          date_fin: exerciceInfo.value.date_fin_n1
        }
      });
      resN1 = data;
    }

    listeComplete.value = resN.map((ligneN, idx) => ({
      label: ligneN.label,
      note: "",
      montantN: ligneN.montant,
      montantN1: resN1[idx] ? resN1[idx].montant : 0,
      isTotal: isLigneTotal(ligneN.label),
      isSubtotal: isLigneSubtotal(ligneN.label),
      isSection: isLigneSection(ligneN.label)
    }));
  } catch (error) {
    console.error("Erreur chargement compte de résultat:", error);
    alert("Erreur lors du chargement des données");
  } finally {
    loading.value = false;
  }
};

// Identification des lignes totaux et sous-totaux selon la structure PCG
const isLigneTotal = (label) => {
  const totauxPrincipaux = [
    'X – Résultat net de l\'exercice',
    'Résultat net de l\'exercice'
  ];
  return totauxPrincipaux.some(t => label.includes(t));
};

const isLigneSubtotal = (label) => {
  const sousTotaux = [
    'I – Production de l\'exercice',
    'II – Consommation de l\'exercice',
    'III – Valeur ajoutée',
    'IV – Excédent brut d\'exploitation',
    'V – Résultat opérationnel',
    'VI – Résultat financier',
    'VII – Résultat avant impôts',
    'VIII – Résultat net des activités ordinaires',
    'IX – Résultat extraordinaire',
    'Total des produits',
    'Total des charges'
  ];
  return sousTotaux.some(st => label.includes(st));
};

const isLigneSection = (label) => {
  // Sections principales (non utilisé dans ce contexte, mais peut être utile)
  return false;
};

// Formatage avec valeur absolue
const formatMontantAbsolu = n => {
  if (!n && n !== 0) return "";
  return Math.abs(Number(n)).toLocaleString("fr-FR", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
};

const formatDate = d => {
  if (!d) return "";
  const date = new Date(d);
  return date.toLocaleDateString("fr-FR", { day: "2-digit", month: "long", year: "numeric" });
};

// Export PDF
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
    body: listeComplete.value.map(l =>
      [l.label, l.note || "", formatMontantAbsolu(l.montantN), formatMontantAbsolu(l.montantN1)]
    ),
    theme: "grid",
    startY: 40,
    styles: { fontSize: 8, cellPadding: 2 },
    headStyles: { fillColor: [30, 64, 175], textColor: [255, 255, 255], fontStyle: 'bold' },
    bodyStyles: { 
      fontSize: 8,
      cellPadding: 2
    },
    didParseCell: function(data) {
      const ligne = listeComplete.value[data.row.index];
      if (ligne) {
        if (ligne.isTotal) {
          data.cell.styles.fillColor = [30, 64, 175];
          data.cell.styles.textColor = [255, 255, 255];
          data.cell.styles.fontStyle = 'bold';
        } else if (ligne.isSubtotal) {
          data.cell.styles.fillColor = [224, 231, 255];
          data.cell.styles.fontStyle = 'bold';
        }
      }
    }
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
.dashboard-container { 
  display: flex; 
  min-height: 100vh; 
  flex-direction: column;
  font-family: 'Stara', sans-serif; 
}

.main-content { 
  margin-left: 278px; 
  padding: 32px; 
  flex: 1; 
  background: #f8fafb; 
  min-height: calc(100vh - 80px);
  font-family: 'Stara', sans-serif; 
}

.info-container, .export-container { 
  background: white; 
  padding: 1.5rem; 
  border-radius: 0.75rem; 
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
  font-family: 'Stara', sans-serif; 
}

.info-grid { 
  display: grid; 
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); 
  gap: 1rem;
  font-family: 'Stara', sans-serif; 
}

.info-item { 
  display: flex; 
  flex-direction: column; 
  gap: 0.25rem;
}

.info-label { 
  font-size: 0.875rem; 
  color: #6b7280; 
  font-weight: 500;
  font-family: 'Stara', sans-serif; 
}

.info-value { 
  font-size: 1rem; 
  color: #1f2937; 
  font-weight: 600;
}

.badge { 
  display: inline-block; 
  width: fit-content; 
  padding: 0.25rem 0.75rem; 
  border-radius: 9999px; 
  font-size: 0.875rem; 
  font-weight: 600;
}

.badge-success { 
  background-color: #d1fae5; 
  color: #065f46;
}

.badge-secondary { 
  background-color: #e5e7eb; 
  color: #374151;
}

/* Styles pour les sections et totaux */
.section-title { 
  background-color: #1e40af !important; 
  color: white !important;
  font-weight: 700;
  border-top: 3px solid #1e3a8a;
  border-bottom: 3px solid #1e3a8a;
}

.section-title td {
  color: white !important;
  padding: 0.9rem 1rem;
  font-size: 1.05rem;
}

.total-row { 
  background-color: #1e40af !important; 
  color: white !important;
  font-weight: bold; 
  border-top: 2px solid #1e3a8a; 
  border-bottom: 2px solid #1e3a8a;
}

.total-row td { 
  padding: 0.85rem 1rem; 
  color: white !important; 
  font-weight: 700;
}

.subtotal-row { 
  background-color: #e0e7ff !important; 
  font-weight: bold; 
  border-top: 1px solid #6366f1; 
  border-bottom: 1px solid #6366f1;
}

.subtotal-row td { 
  padding: 0.75rem 1rem; 
  color: #1e40af; 
  font-weight: 600;
}

.detail-row { 
  background-color: #ffffff;
}

.detail-row:hover { 
  background-color: #f9fafb; 
  transition: background-color 0.2s ease;
}

.detail-row td { 
  padding: 0.6rem 1rem; 
  color: #374151;
}

.pl-4 { 
  padding-left: 1.5rem !important;
}

.font-bold { 
  font-weight: 700;
}

.text-red { 
  color: #dc2626 !important; 
  font-weight: 600;
}

.text-lg {
  font-size: 1.05rem;
}

.table-container { 
  overflow-x: auto; 
  box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1); 
  border-radius: 0.5rem; 
  background: white;
}

.table thead th { 
  background-color: #1e40af; 
  color: white; 
  font-weight: 600; 
  text-transform: uppercase; 
  font-size: 0.875rem; 
  padding: 1rem; 
  border: none;
}

.table tbody tr { 
  border-bottom: 1px solid #e5e7eb;
}

.table tbody tr:last-child { 
  border-bottom: none;
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
  from { transform: rotate(0deg); } 
  to { transform: rotate(360deg); }
}

@media (max-width: 768px) { 
  .main-content { 
    margin-left: 0; 
    padding: 1rem;
  } 
  .info-grid { 
    grid-template-columns: 1fr;
  } 
  .export-container { 
    flex-direction: column !important;
  }
}
</style>
