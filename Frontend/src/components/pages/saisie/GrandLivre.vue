<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import axios from 'axios'
import { debounce } from 'lodash'
import { useRouter, useRoute } from 'vue-router'
import * as XLSX from 'xlsx-js-style';
import Sidebar from '../../molecules/Sidebar.vue'
import Header from '../../molecules/Header.vue'
import AppFooter from '../../molecules/Footer.vue'
import { getUser } from "../../../services/Auth";
import logoImg from '../../../assets/img/01300.png'
import html2pdf from 'html2pdf.js'

const router = useRouter()
const route = useRoute()
const user = ref(null);

const etablissement = {
  nom: "RAITRA KIDZ",
  adresse: "Antananarivo, Madagascar",
  tel: "+261 XX XX XXX XX",
  email: "contact@raitrakidz.mg"
}

const handleNavigation = (item) => { router.push(item.route) }

const grandLivres = ref([])
const loading = ref(false)
const filters = ref({
  search: '',
  date_debut: '',
  date_fin: ''
})
const currentPage = ref(1)
const itemsPerPage = 20
const API_URL = 'http://localhost:8000/api'
const token = localStorage.getItem('token')
if (!token) {
  window.location.href = '/'
} else {
  axios.defaults.headers.common['Authorization'] = `Bearer ${token}`
}

const isSingleCompte = computed(() => !!route.params.codeCompte)
const currentCompte = computed(() => route.params.codeCompte || '')

const loadGrandLivres = async () => {
  loading.value = true
  try {
    let url = `${API_URL}/grand-livre`
    let queryParams = new URLSearchParams()
    if (filters.value.date_debut) queryParams.append('date_debut', filters.value.date_debut)
    if (filters.value.date_fin) queryParams.append('date_fin', filters.value.date_fin)
    if (isSingleCompte.value) queryParams.append('code_compte', currentCompte.value)
    const queryString = queryParams.toString()
    const fullUrl = queryString ? `${url}?${queryString}` : url
    const response = await axios.get(fullUrl)
    grandLivres.value = response.data || []
  } catch (error) {
    console.error('Erreur chargement grand livres:', error)
    grandLivres.value = []
    alert('Erreur lors du chargement des données')
  } finally {
    loading.value = false
  }
}

const filteredGrandLivres = computed(() => {
  return grandLivres.value.filter(gl => {
    const matchSearch = !filters.value.search ||
      gl.code_compte?.toLowerCase().includes(filters.value.search.toLowerCase()) ||
      gl.libelle_compte?.toLowerCase().includes(filters.value.search.toLowerCase()) ||
      gl.code_sous_compte?.toLowerCase().includes(filters.value.search.toLowerCase()) ||
      gl.libelle_sous_compte?.toLowerCase().includes(filters.value.search.toLowerCase()) ||
      gl.numero_piece?.toLowerCase().includes(filters.value.search.toLowerCase()) ||
      gl.libelle_ecriture?.toLowerCase().includes(filters.value.search.toLowerCase())
    const matchDate = (!filters.value.date_debut || new Date(gl.date_mouvement) >= new Date(filters.value.date_debut)) &&
      (!filters.value.date_fin || new Date(gl.date_mouvement) <= new Date(filters.value.date_fin))
    const matchCompte = !isSingleCompte.value || gl.code_compte === currentCompte.value
    return matchSearch && matchDate && matchCompte
  })
})

const paginatedGrandLivres = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage
  const end = start + itemsPerPage
  return filteredGrandLivres.value.slice(start, end)
})

const totalPages = computed(() => Math.ceil(filteredGrandLivres.value.length / itemsPerPage))

const prevPage = () => { if (currentPage.value > 1) currentPage.value-- }
const nextPage = () => { if (currentPage.value < totalPages.value) currentPage.value++ }
const goToPage = (page) => { currentPage.value = page }

const summary = computed(() => {
  if (!isSingleCompte.value || filteredGrandLivres.value.length === 0) {
    return { total_debit: 0, total_credit: 0, solde: 0 }
  }
  const total_debit = filteredGrandLivres.value.reduce((sum, gl) => sum + (parseFloat(gl.Debit) || 0), 0)
  const total_credit = filteredGrandLivres.value.reduce((sum, gl) => sum + (parseFloat(gl.Credit) || 0), 0)
  const solde = total_debit - total_credit
  return { total_debit, total_credit, solde }
})

const paginatedSummary = computed(() => {
  const total_debit = paginatedGrandLivres.value.reduce((sum, gl) => sum + (parseFloat(gl.Debit) || 0), 0)
  const total_credit = paginatedGrandLivres.value.reduce((sum, gl) => sum + (parseFloat(gl.Credit) || 0), 0)
  return { total_debit, total_credit }
})

const calculateSoldeProgressif = (gl, entries) => {
  const index = entries.findIndex(e => e.numero_piece === gl.numero_piece && e.date_mouvement === gl.date_mouvement)
  let solde = 0
  for (let i = 0; i <= index; i++) {
    const debit = parseFloat(entries[i].Debit) || 0
    const credit = parseFloat(entries[i].Credit) || 0
    solde += debit - credit
  }
  return solde
}

const applyDateFilter = () => { currentPage.value = 1; loadGrandLivres() }
const resetDateFilter = () => { filters.value.date_debut = ''; filters.value.date_fin = ''; currentPage.value = 1; loadGrandLivres() }
const goBack = () => { router.push('/liste-grand-livre') }

const debounceSearch = debounce((val) => {
  filters.value.search = val
  currentPage.value = 1
}, 300)

const formatDate = (date) => new Date(date).toLocaleDateString('fr-FR')
const formatNumber = (value) => new Intl.NumberFormat('fr-FR', { minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(Math.abs(parseFloat(value) || 0))
const getNumberClass = (value) => ((parseFloat(value) || 0) < 0 ? 'text-red-600' : '')

onMounted(async () => {
  if (!token) {
    window.location.href = "/";
  } else {
    axios.defaults.headers.common["Authorization"] = `Bearer ${token}`;
    try {
      const res = await getUser(token)
      user.value = res.data
    } catch {
      localStorage.removeItem("token")
      window.location.href = "/"
      return
    }
    loadGrandLivres();
  }
})

watch(() => route.params.codeCompte, () => { currentPage.value = 1; loadGrandLivres() })

// Export PDF (décalé à gauche, avec logo et détails établissement)
function exportGrandLivre() {
  const now = new Date();
  const periodeText = `${filters.value.date_debut || 'Toutes'} à ${filters.value.date_fin || 'Toutes'}`;
  const firstEntry = filteredGrandLivres.value[0] || {};
  const libelleCompte = firstEntry.libelle_compte || '—';
  const logoBase64 = logoImg;

  const htmlContent = `
    <div style="font-family:'Helvetica',Arial,sans-serif;max-width:900px;padding:0;margin-left:0;">
      <div style="display:flex;align-items:flex-start;margin-bottom:18px;padding-bottom:10px;border-bottom:2px solid #2980b9;">
        <div style="flex:0 0 95px;">
          <img src="${logoBase64}" style="width:85px;" alt="Logo" />
        </div>
        <div style="flex:2;padding-left:12px;">
          <div style="font-size:13px;font-weight:700;color:#2c3e50;">${etablissement.nom}</div>
          <div style="font-size:10px;">${etablissement.adresse}</div>
          <div style="font-size:10px;">${etablissement.tel}</div>
          <div style="font-size:10px;">${etablissement.email}</div>
        </div>
        <div style="flex:3;text-align:center;">
          <h2 style="margin:0;margin-bottom:8px;font-size:19px;font-weight:bold;color:#1c45bd;">
            Grand Livre – Compte ${currentCompte.value}
          </h2>
          <div style="font-size:11px;">Libellé : ${libelleCompte}</div>
          <div style="font-size:10px;">Période : ${periodeText}</div>
          <div style="font-size:10px;">Date export : ${now.toLocaleDateString('fr-FR')} ${now.toLocaleTimeString('fr-FR', {hour:'2-digit',minute:'2-digit'})}</div>
        </div>
      </div>
      <table style="width:750px;border-collapse:collapse;margin-top:15px;">
        <thead>
          <tr style="background:#1c45bd;color:#fff;">
            <th style="padding:8px;border:1px solid #2980b9;font-size:10px;">Date</th>
            <th style="padding:8px;border:1px solid #2980b9;font-size:10px;">N° Pièce</th>
            <th style="padding:8px;border:1px solid #2980b9;font-size:10px;">Libellé</th>
            <th style="padding:8px;border:1px solid #2980b9;font-size:10px;text-align:right;">Débit</th>
            <th style="padding:8px;border:1px solid #2980b9;font-size:10px;text-align:right;">Crédit</th>
            <th style="padding:8px;border:1px solid #2980b9;font-size:10px;text-align:right;">Solde Progressif</th>
          </tr>
        </thead>
        <tbody>
          ${filteredGrandLivres.value
            .map(gl => `
            <tr>
              <td style="padding:7px;font-size:9px;border:1px solid #eee;">${formatDate(gl.date_mouvement)}</td>
              <td style="padding:7px;font-size:9px;border:1px solid #eee;">${gl.numero_piece}</td>
              <td style="padding:7px;font-size:9px;border:1px solid #eee;">${gl.libelle_ecriture}</td>
              <td style="padding:7px;font-size:9px;border:1px solid #eee;text-align:right;">${formatNumber(gl.Debit)}</td>
              <td style="padding:7px;font-size:9px;border:1px solid #eee;text-align:right;">${formatNumber(gl.Credit)}</td>
              <td style="padding:7px;font-size:9px;border:1px solid #eee;text-align:right;">${formatNumber(calculateSoldeProgressif(gl, filteredGrandLivres.value))}</td>
            </tr>`).join('')}
        </tbody>
        <tfoot>
          <tr style="background:#1c45bd;color:#fff;font-weight:bold;">
            <td colspan="3" style="padding:8px;border:1px solid #2980b9;text-align:right;">TOTAUX :</td>
            <td style="padding:8px;border:1px solid #2980b9;text-align:right;">${formatNumber(summary.value.total_debit)}</td>
            <td style="padding:8px;border:1px solid #2980b9;text-align:right;">${formatNumber(summary.value.total_credit)}</td>
            <td style="padding:8px;border:1px solid #2980b9;text-align:right;">${formatNumber(summary.value.solde)}</td>
          </tr>
        </tfoot>
      </table>
      <div style="margin-top:22px;text-align:center;font-size:10px;color:#888;">
        ${etablissement.nom} © ${now.getFullYear()} | Export PDF
      </div>
    </div>
  `
  const element = document.createElement('div');
  element.innerHTML = htmlContent;
  element.style.width = '210mm';
  element.style.marginLeft = '0';
  document.body.appendChild(element);
  html2pdf()
    .set({
      margin: [10, 5, 15, 5],
      filename: `Grand_Livre_${currentCompte.value}_${now.toISOString().split('T')[0]}.pdf`,
      image: { type: 'jpeg', quality: 0.98 },
      html2canvas: { scale: 2, useCORS: true },
      jsPDF: { unit: 'mm', format: 'a4', orientation: 'portrait' }
    })
    .from(element)
    .save()
    .then(() => document.body.removeChild(element));
}

// Export Excel avec header et détails PRO
const exportToExcel = async () => {
  if (!filteredGrandLivres.value || filteredGrandLivres.value.length === 0) {
    alert("Aucune donnée à exporter !");
    return;
  }

  const now = new Date();
  const libelleCompte = filteredGrandLivres.value[0]?.libelle_compte || '—';
  const titre = [[`GRAND LIVRE – Compte ${currentCompte.value}`]];
  const info = [
    [etablissement.nom],
    [etablissement.adresse],
    [etablissement.tel],
    [etablissement.email],
    [''],
    [`Compte : ${currentCompte.value}`],
    [`Libellé : ${libelleCompte}`],
    [`Période : ${filters.value.date_debut || 'Toutes'} à ${filters.value.date_fin || 'Toutes'}`],
    [`Date d’export : ${now.toLocaleDateString('fr-FR')} à ${now.toLocaleTimeString('fr-FR', {hour:'2-digit',minute:'2-digit'})}`],
    ['']
  ];

  // Styles
  const titleStyle = {
    font: { bold: true, sz: 19, color: { rgb: "1C45BD" } },
    alignment: { horizontal: "center", vertical: "center" }
  };
  const headerStyle = {
    font: { bold: true, color: { rgb: "FFFFFF" }, sz: 11 },
    fill: { fgColor: { rgb: "1C45BD" } },
    alignment: { horizontal: "center", vertical: "center" },
    border: { top: { style: "thin" }, bottom: { style: "thin" }, left: { style: "thin" }, right: { style: "thin" } }
  };
  const infoStyle = {
    font: { sz: 10, color: { rgb: "555555" } },
    alignment: { horizontal: "left", vertical: "center" }
  };
  const dataStyle = {
    font: { sz: 10 },
    alignment: { horizontal: "left", vertical: "center", wrapText: true },
    border: { top: { style: "thin" }, bottom: { style: "thin" }, left: { style: "thin" }, right: { style: "thin" } }
  };
  const numberStyle = {
    ...dataStyle,
    alignment: { horizontal: "right", vertical: "center" },
    numFmt: "#,##0.00"
  };
  const totalStyle = {
    font: { bold: true, sz: 11, color: { rgb: "FFFFFF" } },
    fill: { fgColor: { rgb: "1C45BD" } },
    alignment: { horizontal: "right", vertical: "center" },
    border: { top: { style: "medium" }, bottom: { style: "medium" }, left: { style: "medium" }, right: { style: "medium" } }
  };

  // Création de la feuille
  const ws = XLSX.utils.aoa_to_sheet([]);
  XLSX.utils.sheet_add_aoa(ws, titre, { origin: 'A1' });
  XLSX.utils.sheet_add_aoa(ws, info, { origin: 'A2' });

  // En-têtes du tableau
  const headers = [
    ['Date Mouvement', 'Numéro Pièce', 'Libellé Écriture', 'Débit', 'Crédit', 'Solde Progressif']
  ];
  XLSX.utils.sheet_add_aoa(ws, headers, { origin: 'A13' });

  // Données du Grand Livre
  const dataRows = filteredGrandLivres.value.map(gl => [
    formatDate(gl.date_mouvement),
    gl.numero_piece || '',
    gl.libelle_ecriture || '',
    parseFloat(gl.Debit) || 0,
    parseFloat(gl.Credit) || 0,
    calculateSoldeProgressif(gl, filteredGrandLivres.value)
  ]);
  XLSX.utils.sheet_add_aoa(ws, dataRows, { origin: 'A14' });

  // Ligne totaux
  const totalRowIdx = 14 + dataRows.length;
  XLSX.utils.sheet_add_aoa(ws, [
    ['', '', 'TOTAUX', summary.value.total_debit, summary.value.total_credit, summary.value.solde]
  ], { origin: `A${totalRowIdx}` });

  // Styles et fusion
  ws['A1'].s = titleStyle;
  ws['!merges'] = [{ s: { r: 0, c: 0 }, e: { r: 0, c: 5 } }];
  Object.keys(ws)
    .filter(cell => cell.match(/^A([2-9]|10|11)$/)) // infos établissement
    .forEach(cell => { ws[cell].s = infoStyle; });
  ['A13', 'B13', 'C13', 'D13', 'E13', 'F13'].forEach(cell => { ws[cell].s = headerStyle; });

  // Style lignes datas
  dataRows.forEach((_, i) => {
    const rowN = 14 + i;
    ['A', 'B', 'C'].forEach(col => { const ref = `${col}${rowN}`; if (ws[ref]) ws[ref].s = dataStyle; });
    ['D', 'E', 'F'].forEach(col => { const ref = `${col}${rowN}`; if (ws[ref]) ws[ref].s = numberStyle; });
  });
  // Style totaux
  ['A', 'B', 'C', 'D', 'E', 'F'].forEach(col => {
    const ref = `${col}${totalRowIdx}`;
    if (ws[ref]) ws[ref].s = totalStyle;
  });

  // Largeurs colonnes
  ws['!cols'] = [
    { wch: 15 }, // Date
    { wch: 15 }, // Numéro Pièce
    { wch: 40 }, // Libellé
    { wch: 15 }, // Débit
    { wch: 15 }, // Crédit
    { wch: 17 }  // Solde Progressif
  ];

  // Ajout au classeur et export
  const wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, ws, `GrandLivre_${currentCompte.value}`);
  const fileName = `Grand_Livre_${currentCompte.value}_${now.toISOString().split('T')[0]}.xlsx`;
  XLSX.writeFile(wb, fileName);
};
</script>


<template>
  <div class="dashboard-container">
    <Header v-if="user" :user="user" />
    <Sidebar :current-route="$route.path" @navigation-change="handleNavigation" />
    <div class="main-content p-4">
      <div class="card card-form">
        <div class="card-header">
          <div class="d-flex justify-between items-center">
            <h1 class="card-title text-2xl">
              {{ isSingleCompte ? `Grand Livre - Compte ${currentCompte}` : 'Liste des Grand Livres' }}
            </h1>
            <div class="d-flex gap-2">
              <button v-if="isSingleCompte && filteredGrandLivres.length > 0" @click="exportGrandLivre" class="btn btn-primary">
                <i class="bi bi-file-pdf"></i> Exporter PDF
              </button>
              <button v-if="isSingleCompte && filteredGrandLivres.length > 0" @click="exportToExcel" class="btn btn-success" style="height: 40px;margin-top: 10px;">
                <i class="bi bi-file-excel"></i> Exporter Excel
              </button>
              <button v-if="isSingleCompte" @click="goBack" class="btn btn-ghost" style="height: 40px;margin-top: 10px;">
                <i class="bi bi-arrow-left"></i> Retour à la liste
              </button>
            </div>
          </div>
        </div>
        <div class="card-body">
          <!-- Filtre par date -->
          <div class="filter-section mb-4">
            <div class="d-flex flex-column md:flex-row gap-3 align-items-end">
              <div class="form-group flex-1">
                <label class="form-label">Date de début</label>
                <input v-model="filters.date_debut" type="date" class="form-input w-full" />
              </div>
              <div class="form-group flex-1">
                <label class="form-label">Date de fin</label>
                <input v-model="filters.date_fin" type="date" class="form-input w-full" />
              </div>
              <div class="form-group">
                <button type="button" @click="applyDateFilter" class="btn btn-primary">
                  <i class="bi bi-funnel"></i> Appliquer
                </button>
              </div>
              <div class="form-group">
                <button type="button" @click="resetDateFilter" class="btn btn-ghost">
                  <i class="bi bi-x-circle"></i> Réinitialiser
                </button>
              </div>
            </div>
          </div>

          <!-- Recherche pour liste complète -->
          <div v-if="!isSingleCompte" class="mb-4">
            <div class="form-group">
              <label for="search" class="form-label">Recherche</label>
              <div class="search-input-wrapper">
                <i class="bi bi-search"></i>
                <input
                  :value="filters.search"
                  @input="debounceSearch($event.target.value)"
                  type="text"
                  placeholder="Rechercher dans le grand livre..."
                  class="form-input w-full pl-10"
                />
              </div>
            </div>
          </div>

          <!-- Affichage pour un compte unique -->
          <div v-if="isSingleCompte" class="table-container">
            <div class="table-responsive">
              <table class="table table-bordered table-striped table-hover">
                <thead>
                  <tr>
                    <th class="text-sm">Date Mouvement</th>
                    <th class="text-sm">Numéro Pièce</th>
                    <th class="text-sm">Libellé Écriture</th>
                    <th class="text-sm text-right">Débit</th>
                    <th class="text-sm text-right">Crédit</th>
                    <th class="text-sm text-right">Solde Progressif</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(gl, index) in paginatedGrandLivres" :key="gl.numero_piece + gl.date_mouvement + index" class="fade-in">
                    <td>{{ formatDate(gl.date_mouvement) }}</td>
                    <td>{{ gl.numero_piece }}</td>
                    <td>{{ gl.libelle_ecriture }}</td>
                    <td class="text-right" :class="getNumberClass(gl.Debit)">{{ formatNumber(gl.Debit) }}</td>
                    <td class="text-right" :class="getNumberClass(gl.Credit)">{{ formatNumber(gl.Credit) }}</td>
                    <td class="text-right font-semibold" :class="getNumberClass(calculateSoldeProgressif(gl, paginatedGrandLivres))">
                      {{ formatNumber(calculateSoldeProgressif(gl, paginatedGrandLivres)) }}
                    </td>
                  </tr>
                </tbody>
                <tfoot class="table-footer">
                  <tr>
                    <td colspan="3" class="text-right font-bold">TOTAUX :</td>
                    <td class="text-right font-bold" :class="getNumberClass(paginatedSummary.total_debit)">
                      {{ formatNumber(paginatedSummary.total_debit) }}
                    </td>
                    <td class="text-right font-bold" :class="getNumberClass(paginatedSummary.total_credit)">
                      {{ formatNumber(paginatedSummary.total_credit) }}
                    </td>
                    <td></td>
                  </tr>
                  <tr v-if="totalPages > 1">
                    <td colspan="3" class="text-right font-bold">TOTAUX GÉNÉRAUX:</td>
                    <td class="text-right font-bold" :class="getNumberClass(summary.total_debit)">
                      {{ formatNumber(summary.total_debit) }}
                    </td>
                    <td class="text-right font-bold" :class="getNumberClass(summary.total_credit)">
                      {{ formatNumber(summary.total_credit) }}
                    </td>
                    <td class="text-right font-bold" :class="getNumberClass(summary.solde)">
                      {{ formatNumber(summary.solde) }}
                    </td>
                  </tr>
                </tfoot>
              </table>
            </div>
          </div>

          <!-- Affichage pour tous les comptes -->
          <div v-else>
            <div v-for="(compteGroup, codeCompte) in groupedGrandLivres" :key="codeCompte" class="mb-8 compte-section">
              <div class="compte-header">
                <h2 class="compte-title">
                  <i class="bi bi-folder2-open"></i>
                  {{ codeCompte }} - {{ compteGroup.libelle_compte }}
                </h2>
              </div>
              <div v-for="(sousCompteGroup, codeSousCompte) in compteGroup.sousComptes" :key="codeSousCompte" class="mb-6 sous-compte-section">
                <h3 class="sous-compte-title">
                  <i class="bi bi-file-text"></i>
                  {{ codeSousCompte }} - {{ sousCompteGroup.libelle_sous_compte }}
                </h3>
                <div class="table-container">
                  <div class="table-responsive">
                    <table class="table table-bordered table-striped table-hover">
                      <thead>
                        <tr>
                          <th class="text-sm">Date Mouvement</th>
                          <th class="text-sm">Numéro Pièce</th>
                          <th class="text-sm">Libellé Écriture</th>
                          <th class="text-sm text-right">Débit</th>
                          <th class="text-sm text-right">Crédit</th>
                          <th class="text-sm text-right">Solde Progressif</th>
                        </tr>
                      </thead>
                      <tbody>
                        <tr v-for="(gl, index) in sousCompteGroup.entries" :key="gl.numero_piece + gl.date_mouvement + index" class="fade-in">
                          <td>{{ formatDate(gl.date_mouvement) }}</td>
                          <td>{{ gl.numero_piece }}</td>
                          <td>{{ gl.libelle_ecriture }}</td>
                          <td class="text-right" :class="getNumberClass(gl.Debit)">{{ formatNumber(gl.Debit) }}</td>
                          <td class="text-right" :class="getNumberClass(gl.Credit)">{{ formatNumber(gl.Credit) }}</td>
                          <td class="text-right font-semibold" :class="getNumberClass(calculateSoldeProgressif(gl, sousCompteGroup.entries))">
                            {{ formatNumber(calculateSoldeProgressif(gl, sousCompteGroup.entries)) }}
                          </td>
                        </tr>
                      </tbody>
                      <tfoot class="table-footer">
                        <tr>
                          <td colspan="3" class="text-right font-bold">TOTAL SOUS-COMPTE:</td>
                          <td class="text-right font-bold" :class="getNumberClass(getSousCompteTotal(sousCompteGroup.entries).total_debit)">
                            {{ formatNumber(getSousCompteTotal(sousCompteGroup.entries).total_debit) }}
                          </td>
                          <td class="text-right font-bold" :class="getNumberClass(getSousCompteTotal(sousCompteGroup.entries).total_credit)">
                            {{ formatNumber(getSousCompteTotal(sousCompteGroup.entries).total_credit) }}
                          </td>
                          <td class="text-right font-bold" :class="getNumberClass(getSousCompteTotal(sousCompteGroup.entries).solde)">
                            {{ formatNumber(getSousCompteTotal(sousCompteGroup.entries).solde) }}
                          </td>
                        </tr>
                      </tfoot>
                    </table>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Pagination -->
          <div v-if="totalPages > 1" class="pagination-container">
            <button
              @click="prevPage"
              :disabled="currentPage === 1"
              class="btn btn-ghost btn-sm"
              aria-label="Page précédente"
            >
              <i class="bi bi-chevron-left"></i> Précédent
            </button>
            <div class="pagination-pages">
              <button
                v-for="page in totalPages"
                :key="page"
                @click="goToPage(page)"
                class="btn btn-sm"
                :class="{ 'btn-primary': currentPage === page, 'btn-ghost': currentPage !== page }"
                aria-label="Page {{ page }}"
              >
                {{ page }}
              </button>
            </div>
            <button
              @click="nextPage"
              :disabled="currentPage === totalPages"
              class="btn btn-ghost btn-sm"
              aria-label="Page suivante"
            >
              Suivant <i class="bi bi-chevron-right"></i>
            </button>
          </div>

          <!-- Messages -->
          <div v-if="filteredGrandLivres.length === 0 && !loading" class="empty-state">
            <i class="bi bi-inbox"></i>
            <p>Aucune donnée disponible.</p>
          </div>
          <div v-if="loading" class="loading-state">
            <div class="spinner"></div>
            <p>Chargement des données...</p>
          </div>
        </div>
        <AppFooter />
      </div>
    </div>
  </div>
</template>


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

.table-container {
  margin-top: 20px;
}

.stat-card {
  background: #fff;
  padding: 16px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  text-align: center;
}

.stat-label {
  font-size: 1rem;
  color: #6b7280;
  margin-bottom: 8px;
}

.stat-value {
  font-size: 1.5rem;
  font-weight: bold;
}

@media (max-width: 768px) {
  .main-content {
    margin-left: 0;
    padding: 16px;
  }
}
</style>
