<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'
import Sidebar from "../../molecules/Sidebar.vue";
import Header from "../../molecules/Header.vue";
import AppFooter from "../../molecules/Footer.vue";
import ChatBot from "../../molecules/ChatBot.vue";
import { useRouter } from 'vue-router'
import { getUser } from "../../../services/Auth"; // Ajuste le chemin

const router = useRouter();
const user = ref(null);
const showChat = ref(false);

const showImportModal = ref(false)
const selectedFile = ref(null)
const preview = ref([])
const totalLignes = ref(0)
const formatValide = ref(false)
const isImporting = ref(false)
const importErrors = ref([])
const importSuccess = ref('')
const importFail = ref('')
const historique = ref([])

const token = localStorage.getItem("token");
const API_URL = 'http://localhost:8000/api'

const loadHistorique = async () => {
  try {
    const res = await axios.get(`${API_URL}/ecritures/imports/historique`)
    historique.value = res.data.data || res.data
  } catch (err) {
    historique.value = []
  }
}

// prévisualisation de l’import
const previewImport = async (file) => {
  try {
    let form = new FormData()
    form.append('file_ecritures', file)
    importFail.value = ''
    importErrors.value = []
    importSuccess.value = ''
    const res = await axios.post(`${API_URL}/ecritures/import/validate`, form)
    preview.value = res.data.preview || []
    totalLignes.value = res.data.total_lignes || 0
    formatValide.value = !!res.data.format_valide
  } catch (err) {
    preview.value = []
    formatValide.value = false
    importFail.value = err.response?.data?.message || "Erreur lors de la prévisualisation"
  }
}

// quand fichier glissé
const handleDrop = (e) => {
  e.preventDefault()
  if (e.dataTransfer.files.length) {
    selectedFile.value = e.dataTransfer.files[0]
    previewImport(selectedFile.value)
  }
}

// input file classique
const handleFileChange = (e) => {
  const files = e.target.files
  if (files.length) {
    selectedFile.value = files[0]
    previewImport(selectedFile.value)
  }
}

const clearFile = () => {
  selectedFile.value = null
  preview.value = []
  importFail.value = ''
  importSuccess.value = ''
  formatValide.value = false
}

// ENVOI DE L’IMPORT
const sendImport = async () => {
  if (!selectedFile.value || !formatValide.value) return
  isImporting.value = true
  let form = new FormData()
  form.append('file_ecritures', selectedFile.value)
  importErrors.value = []
  importFail.value = ''
  importSuccess.value = ''
  try {
    const res = await axios.post(`${API_URL}/ecritures/import`, form)
    if (res.data.errors?.length) importErrors.value = res.data.errors
    importSuccess.value = res.data.message || 'Importation réussie'
    loadHistorique()
    showImportModal.value = false
    clearFile()
  } catch (err) {
    importFail.value = err.response?.data?.message || "Echec de l'import."
    if (err.response?.data?.errors) importErrors.value = err.response.data.errors
  } finally {
    isImporting.value = false
  }
}

// Initialisation/auth
onMounted(async () => {
  if (!token) {
    window.location.href = "/";
  } else {
    axios.defaults.headers.common["Authorization"] = `Bearer ${token}`;
    try {
      const res = await getUser(token);
      user.value = res.data;
    } catch (err) {
      localStorage.removeItem("token"); window.location.href = "/";
      return;
    }
    loadHistorique()
  }
});
</script>

<template>
  <div class="dashboard-container">
    <Header v-if="user" :user="user" />
    <div v-else class="loading">Chargement...</div>
    <Sidebar :current-route="$route.path" @navigation-change="handleNavigation" />    <div class="main-content p-4">
      <div class="card card-form">
        <div class="card-header d-flex space-between align-items-center">
          <h1 class="card-title text-2xl" style="margin-top: 15px;">Import des Écritures Comptables</h1>
          <button class="btn btn-primary" @click="showImportModal = true" style="margin-left: 500px;">Importer un fichier</button>
        </div>
        <div class="card-body">
          <h3>Historique des imports</h3>
          <table class="table table-bordered table-striped">
            <thead>
              <tr>
                <th>Fichier</th>
                <th>Date</th>
                <th>Par</th>
                <th>Mouvements</th>
                <th>Lignes</th>
                <th>Statut</th>
                <th>Erreurs</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="imp in historique" :key="imp.id">
                <td>{{ imp.nom_fichier }}</td>
                <td>{{ new Date(imp.imported_at || imp.created_at).toLocaleString() }}</td>
                <td>{{ imp.user?.name || 'N/A' }}</td>
                <td>{{ imp.nombre_mouvements }}</td>
                <td>{{ imp.nombre_lignes }}</td>
                <td :class="imp.statut === 'réussi' ? 'text-success' : 'text-error'">
                  {{ imp.statut }}
                </td>
                <td><span v-if="imp.erreur" style="color:red">{{ imp.erreur }}</span></td>
              </tr>
              <tr v-if="!historique.length"><td colspan="7" class="text-center">Aucun import effectué</td></tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- MODAL IMPORT -->
      <div v-if="showImportModal" class="modal-overlay">
        <div class="modal">
          <div class="modal-header">
            <h2 class="modal-title">Importer un fichier d'écritures</h2>
            <button @click="showImportModal = false; clearFile()" class="modal-close">×</button>
          </div>
          <div class="modal-body">
            <div
              class="dropzone"
              @dragover.prevent
              @drop="handleDrop"
              @click="$refs.fileinput.click()"
              style="cursor:pointer;"
            >
              <input type="file" ref="fileinput" style="display:none"
                accept=".csv,application/vnd.ms-excel,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                @change="handleFileChange" />
              <div v-if="selectedFile">
                <strong>Fichier sélectionné:</strong> {{ selectedFile.name }}
                <button @click.stop="clearFile" class="btn btn-error btn-sm">Retirer</button>
              </div>
              <div v-else>
                Glissez-déposez un fichier CSV ou Excel ici, ou cliquez pour sélectionner.
              </div>
              <div v-if="importFail" class="text-error mt-2">{{ importFail }}</div>
            </div>
            <div v-if="preview.length" style="margin: 20px 0;">
              <h3>Aperçu du fichier ({{ totalLignes }} lignes)</h3>
              <table class="table table-bordered">
                <thead>
                  <tr>
                    <th v-for="key in Object.keys(preview[0])" :key="key">{{ key }}</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(row, idx) in preview" :key="idx">
                    <td v-for="v in row" :key="v">{{ v }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
            <div v-if="importErrors.length" class="text-error">
              <div v-for="err in importErrors" :key="err">{{ err }}</div>
            </div>
            <div class="modal-footer mt-3">
              <button class="btn btn-ghost" @click="showImportModal = false; clearFile()">Annuler</button>
              <button class="btn btn-primary" :disabled="!selectedFile || !formatValide || isImporting" @click="sendImport">
                Importer
              </button>
            </div>
            <div v-if="importSuccess" class="text-success mt-2">{{ importSuccess }}</div>
          </div>
        </div>
      </div>
      <!-- MODAL END -->

      <AppFooter />
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
.dropzone {
  border: 2px dashed #ddd;
  background: #fafbfc;
  min-height: 86px;
  display: flex; align-items: center;
  justify-content: center;
  color: #888;
  border-radius: 4px;
  padding: 20px;
  margin-bottom: 10px;
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
  .main-content { margin-left: 0; padding: 16px; }
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
