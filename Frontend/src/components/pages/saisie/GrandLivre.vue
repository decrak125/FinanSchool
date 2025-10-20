<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import axios from 'axios'
import { debounce } from 'lodash'
import { useRouter, useRoute } from 'vue-router'
import { jsPDF } from 'jspdf'
import autoTable from 'jspdf-autotable'
import * as XLSX from 'xlsx'
import Sidebar from '../../molecules/Sidebar.vue'
import Header from '../../molecules/Header.vue'
import AppFooter from '../../molecules/Footer.vue'
import { getUser } from "../../../services/Auth";

const router = useRouter()
const route = useRoute()
const user = ref(null);

const handleNavigation = (item) => {
  router.push(item.route)
}

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

// Computed properties
const isSingleCompte = computed(() => !!route.params.codeCompte)
const currentCompte = computed(() => route.params.codeCompte || '')

const loadGrandLivres = async () => {
  loading.value = true
  try {
    let url = `${API_URL}/grand-livre`
    let queryParams = new URLSearchParams()

    if (filters.value.date_debut) {
      queryParams.append('date_debut', filters.value.date_debut)
    }
    if (filters.value.date_fin) {
      queryParams.append('date_fin', filters.value.date_fin)
    }

    if (isSingleCompte.value) {
      queryParams.append('code_compte', currentCompte.value)
    }

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

const totalPages = computed(() => {
  return Math.ceil(filteredGrandLivres.value.length / itemsPerPage)
})

const prevPage = () => {
  if (currentPage.value > 1) currentPage.value--
}

const nextPage = () => {
  if (currentPage.value < totalPages.value) currentPage.value++
}

const goToPage = (page) => {
  currentPage.value = page
}

const groupedGrandLivres = computed(() => {
  if (isSingleCompte.value) return {}

  const groups = {}
  filteredGrandLivres.value.forEach(gl => {
    const compteKey = gl.code_compte || 'Unknown'
    const sousCompteKey = gl.code_sous_compte || 'N/A'
    if (!groups[compteKey]) {
      groups[compteKey] = {
        libelle_compte: gl.libelle_compte || 'Compte Inconnu',
        sousComptes: {}
      }
    }
    if (!groups[compteKey].sousComptes[sousCompteKey]) {
      groups[compteKey].sousComptes[sousCompteKey] = {
        libelle_sous_compte: gl.libelle_sous_compte || 'Sous-Compte Inconnu',
        entries: []
      }
    }
    groups[compteKey].sousComptes[sousCompteKey].entries.push(gl)
  })
  return groups
})

const summary = computed(() => {
  if (!isSingleCompte.value || filteredGrandLivres.value.length === 0) {
    return { total_debit: 0, total_credit: 0, solde: 0 }
  }

  const total_debit = filteredGrandLivres.value.reduce((sum, gl) => {
    return sum + (parseFloat(gl.Debit) || 0)
  }, 0)

  const total_credit = filteredGrandLivres.value.reduce((sum, gl) => {
    return sum + (parseFloat(gl.Credit) || 0)
  }, 0)

  const solde = total_debit - total_credit

  return {
    total_debit,
    total_credit,
    solde
  }
})

const paginatedSummary = computed(() => {
  const total_debit = paginatedGrandLivres.value.reduce((sum, gl) => {
    return sum + (parseFloat(gl.Debit) || 0)
  }, 0)

  const total_credit = paginatedGrandLivres.value.reduce((sum, gl) => {
    return sum + (parseFloat(gl.Credit) || 0)
  }, 0)

  return { total_debit, total_credit }
})

const getSousCompteTotal = (entries) => {
  const total_debit = entries.reduce((sum, gl) => sum + (parseFloat(gl.Debit) || 0), 0)
  const total_credit = entries.reduce((sum, gl) => sum + (parseFloat(gl.Credit) || 0), 0)
  return { total_debit, total_credit, solde: total_debit - total_credit }
}

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

const applyDateFilter = () => {
  currentPage.value = 1
  loadGrandLivres()
}

const resetDateFilter = () => {
  filters.value.date_debut = ''
  filters.value.date_fin = ''
  currentPage.value = 1
  loadGrandLivres()
}

const goBack = () => {
  router.push('/liste-grand-livre')
}

const exportToPDF = () => {
  const doc = new jsPDF()
  doc.setFontSize(18)
  doc.setTextColor(0, 51, 102)
  doc.text(`Grand Livre - Compte ${currentCompte.value}`, 14, 20)
  doc.setFontSize(10)
  doc.setTextColor(0, 0, 0)
  doc.text(`Période: ${filters.value.date_debut || 'Toutes'} à ${filters.value.date_fin || 'Toutes'}`, 14, 30)
  doc.text(`Nombre d'écritures: ${filteredGrandLivres.value.length}`, 14, 38)
  doc.text(`Exporté le: ${new Date().toLocaleDateString('fr-FR')}`, 14, 46)

  autoTable(doc, {
    startY: 50,
    head: [['Date', 'N° Pièce', 'Libellé', 'Débit', 'Crédit', 'Solde Progressif']],
    body: filteredGrandLivres.value.map((gl) => [
      formatDate(gl.date_mouvement),
      gl.numero_piece,
      gl.libelle_ecriture,
      formatNumber(gl.Debit),
      formatNumber(gl.Credit),
      formatNumber(calculateSoldeProgressif(gl, filteredGrandLivres.value))
    ]),
    foot: [['', '', 'TOTAUX:', formatNumber(summary.value.total_debit), formatNumber(summary.value.total_credit), formatNumber(summary.value.solde)]],
    styles: {
      fontSize: 8,
      cellPadding: 2
    },
    headStyles: {
      fillColor: [0, 51, 102],
      textColor: [255, 255, 255],
      fontStyle: 'bold'
    },
    footStyles: {
      fillColor: [200, 200, 200],
      textColor: [0, 0, 0],
      fontStyle: 'bold'
    }
  })

  doc.save(`Grand_Livre_${currentCompte.value}_${new Date().toISOString().split('T')[0]}.pdf`)
}

const exportToExcel = () => {
  if (!filteredGrandLivres.value || filteredGrandLivres.value.length === 0) {
    alert("Aucune donnée à exporter !");
    return;
  }

  // Récupération du libellé depuis les données si non défini
  const firstEntry = filteredGrandLivres.value[0] || {};
  const libelleCompte = firstEntry.libelle_compte || '—';

  // 1️⃣ Données principales
  const data = filteredGrandLivres.value.map((gl) => ({
    'Date Mouvement': formatDate(gl.date_mouvement),
    'Numéro Pièce': gl.numero_piece,
    'Libellé Écriture': gl.libelle_ecriture,
    'Débit': parseFloat(gl.Debit) || 0,
    'Crédit': parseFloat(gl.Credit) || 0,
    'Solde Progressif': calculateSoldeProgressif(gl, filteredGrandLivres.value)
  }));

  // 2️⃣ Ligne Totaux
  data.push({
    'Date Mouvement': '',
    'Numéro Pièce': '',
    'Libellé Écriture': 'TOTAUX',
    'Débit': summary.value.total_debit,
    'Crédit': summary.value.total_credit,
    'Solde Progressif': summary.value.solde
  });

  // 3️⃣ Feuille Excel
  const ws = XLSX.utils.aoa_to_sheet([]);

  // ✅ Titre et détails
  const titre = [`GRAND LIVRE DU COMPTE ${currentCompte.value}`];
  const details = [
    [`Compte : ${currentCompte.value}`],
    [`Libellé : ${libelleCompte}`],
    [`Date d’export : ${new Date().toLocaleDateString('fr-FR')}`],
    [''] // ligne vide
  ];

  // Ajout du titre et des détails dans la feuille
  XLSX.utils.sheet_add_aoa(ws, [titre], { origin: 'A1' });
  XLSX.utils.sheet_add_aoa(ws, details, { origin: 'A3' });

  // ✅ Données comptables à partir de la ligne 8
  XLSX.utils.sheet_add_json(ws, data, { origin: 'A8', skipHeader: false });

  // ✅ Ajustement automatique des colonnes
  const colWidths = Object.keys(data[0]).map((key) => ({
    wch: Math.max(key.length + 5, 15)
  }));
  ws['!cols'] = colWidths;

  // ✅ Création du classeur
  const wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, ws, `Compte_${currentCompte.value}`);

  // ✅ Téléchargement
  const fileName = `Grand_Livre_${currentCompte.value}_${new Date()
    .toISOString()
    .split('T')[0]}.xlsx`;

  XLSX.writeFile(wb, fileName);
};


const debounceSearch = debounce((val) => {
  filters.value.search = val
  currentPage.value = 1
}, 300)

const formatDate = (date) => {
  return new Date(date).toLocaleDateString('fr-FR')
}

const formatNumber = (value) => {
  const num = parseFloat(value) || 0
  return new Intl.NumberFormat('fr-FR', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  }).format(Math.abs(num))
}

const getNumberClass = (value) => {
  const num = parseFloat(value) || 0
  return num < 0 ? 'text-red-600' : ''
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
    loadGrandLivres();
  }
});

watch(() => route.params.codeCompte, () => {
  currentPage.value = 1
  loadGrandLivres()
})
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
              <button v-if="isSingleCompte && filteredGrandLivres.length > 0" @click="exportToPDF" class="btn btn-primary">
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
