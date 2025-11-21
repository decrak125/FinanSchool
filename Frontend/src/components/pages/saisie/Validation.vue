<template>
  <div class="dashboard-container w-full">
    <Header v-if="user" :user="user" />
    <Sidebar :current-route="$route.path" @navigation-change="handleNavigation" />
    <div class="main-content p-6">
      <div class="card card-form mb-8">
        <h1 class="text-2xl mb-4"><i class="bi bi-shield-check me-2"></i> Validation des écritures comptables</h1>
        <div v-if="rapport" class="stat-row mb-4">
          <div class="stat-block">
            <span class="stat-label">Écritures à valider</span>
            <span class="stat-value badge badge-warning">{{ rapport.total_non_validees }}</span>
          </div>
          <div class="stat-block">
            <span class="stat-label">Validées</span>
            <span class="stat-value badge badge-success">{{ rapport.valides }}</span>
          </div>
          <div class="stat-block">
            <span class="stat-label">Non valides</span>
            <span class="stat-value badge badge-danger">{{ rapport.invalides }}</span>
          </div>
          <div class="stat-block">
            <span class="stat-label">Valides (restants)</span>
            <span class="stat-value badge badge-primary">{{ rapport.validables }}</span>
          </div>
          <div class="stat-block">
            <span class="stat-label">Mouvements non équilibrés</span>
            <span class="stat-value badge badge-info">{{ rapport.mouvements_non_equilibres }}</span>
          </div>
        </div>
        <button class="btn btn-success mt-2" :disabled="validating" @click="validerToutes">
          <i v-if="validating" class="spinner spinner-sm me-2"></i>
          Valider toutes les écritures non validées
        </button>
      </div>
      <!-- ... reste inchangé ... -->
      <div class="card mb-8">
        <div class="card-header">
          <h2 class="text-lg font-bold mb-3">Écritures non validées (exercice courant)</h2>
        </div>
        <div v-if="isLoading" class="text-center py-6 text-gray-600">Chargement...</div>
        <div v-else>
          <table v-if="ecritures.data.length" class="table table-bordered w-full">
            <thead>
              <tr>
                <th>Date</th>
                <th>Sous-compte</th>
                <th>Libellé</th>
                <th>Débit</th>
                <th>Crédit</th>
                <th>Référence</th>
                <th>Statut</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="ligne in ecritures.data" :key="ligne.Id_Ligne_ecriture">
                <td>{{ formatDate(ligne.mouvement?.Date_mouvement) }}</td>
                <td>{{ ligne.sous_compte?.Code_sous_compte }}</td>
                <td>{{ ligne.Libelle }}</td>
                <td class="text-right">{{ formatMontant(ligne.Debit) }}</td>
                <td class="text-right">{{ formatMontant(ligne.Credit) }}</td>
                <td>{{ ligne.Reference }}</td>
                <td>
                  <span class="badge badge-warning">À valider</span>
                </td>
              </tr>
            </tbody>
          </table>
          <div v-else class="text-center text-gray-500 py-4">Aucune écriture non validée à afficher</div>

          <div v-if="ecritures.last_page > 1" class="mt-4 flex justify-center items-center gap-2">
            <button @click="changePage(ecritures.current_page-1)" :disabled="ecritures.current_page === 1" class="btn btn-xs btn-ghost">Précédent</button>
            <span class="mx-2">Page {{ ecritures.current_page }} / {{ ecritures.last_page }}</span>
            <button @click="changePage(ecritures.current_page+1)" :disabled="ecritures.current_page === ecritures.last_page" class="btn btn-xs btn-ghost">Suivant</button>
          </div>
        </div>
      </div>
      <AppFooter />
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
import { ref, onMounted } from "vue";
import axios from "axios";
import Header from "../../molecules/Header.vue";
import Sidebar from "../../molecules/Sidebar.vue";
import AppFooter from "../../molecules/Footer.vue";
import ChatBot from "../../molecules/ChatBot.vue";
import { getUser } from "../../../services/Auth"; // ou ton chemin exact
const token = localStorage.getItem("token");
if (!token) window.location.href = "/";
axios.defaults.headers.common["Authorization"] = `Bearer ${token}`;

const user = ref(null);
const rapport = ref(null);
const ecritures = ref({ data: [], current_page: 1, last_page: 1 });
const isLoading = ref(false);
const validating = ref(false);
const showChat = ref(false);

const exerciceCourant = ref({});

function formatDate(d) {
  return d ? new Date(d).toLocaleDateString("fr-FR") : "";
}
function formatMontant(m) {
  return Number(m || 0).toLocaleString('fr-FR', { minimumFractionDigits: 2 });
}

async function fetchExerciceCourant() {
  const { data } = await axios.get("http://localhost:8000/api/exercices/courant");
  exerciceCourant.value = data.exercice || data;
}

async function fetchRapport() {
  const { data } = await axios.get("http://localhost:8000/api/lignes/rapport-validation");
  rapport.value = data;
}

async function fetchEcrituresNonValidees(page = 1) {
  isLoading.value = true;
  try {
    const params = {
      page,
      statut: '!=valide',
      date_debut: exerciceCourant.value.Date_debut,
      date_fin: exerciceCourant.value.Date_fin
    };
    const res = await axios.get("http://localhost:8000/api/ecritures", { params });
    // Filtrer côté front au cas où le backend ne gère pas le 'statut!=valide'
    ecritures.value = {
      ...res.data,
      data: res.data.data
        .filter(l => l.statut !== 'valide')
        .filter(l => (
          new Date(l.mouvement?.Date_mouvement) >= new Date(exerciceCourant.value.Date_debut) &&
          new Date(l.mouvement?.Date_mouvement) <= new Date(exerciceCourant.value.Date_fin)
        ))
    };
  } catch {
    ecritures.value = { data: [] };
  }
  isLoading.value = false;
}

function changePage(page) {
  fetchEcrituresNonValidees(page);
}

async function validerToutes() {
  validating.value = true;
  try {
    await axios.post("http://localhost:8000/api/lignes/valider-toutes");
    await fetchRapport();
    await fetchEcrituresNonValidees();
  } finally {
    validating.value = false;
  }
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
    await fetchExerciceCourant();
  await fetchRapport();
  await fetchEcrituresNonValidees();
  }
});



</script>

<style scoped>
.dashboard-container {
  display: flex;
  min-height: 100vh;
  flex-direction: column;
  font-family: 'Manrope', sans-serif;
}
.main-content {
  margin-left: 278px;
  padding: 32px;
  flex: 1;
  background: #f8fafc;
  min-height: calc(100vh - 80px);
  font-family: 'Manrope', sans-serif;
}
.stat-row {
  display: flex;
  flex-direction: row;
  gap: 2rem;
  flex-wrap: nowrap;
  overflow-x: auto;
  padding-bottom: 0.5rem;
  margin-bottom: 1.2rem;
}
.stat-block {
  display: flex;
  flex-direction: column;
  align-items: center;
  background: #fff;
  border-radius: 0.75rem;
  padding: 1rem 1.7rem;
  min-width: 180px;
  min-height: 90px;
  box-shadow: 0 1px 6px 0 rgba(30,64,175,.07);
}
.stat-label {
  font-size: 0.95rem;
  font-weight: 500;
  color: #334155;
  margin-bottom: 0.4rem;
  text-align: center;
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
.stat-value {
  font-size: 1.44rem;
  font-weight: bold;
  text-align: center;
}
.badge-warning { background: #fcd34d; color: #8a5705; }
.badge-success { background: #d1fae5; color: #047857; }
.badge-danger { background: #fca5a5; color: #991b1b; }
.badge-primary { background: #c7d2fe; color: #1e40af; }
.badge-info { background: #bae6fd; color: #0369a1; }
.spinner { display: inline-block; width: 1.5em; height: 1.5em; border: 2.5px solid #e0e7ef; border-top: 2.5px solid #2563eb; border-radius: 50%; animation: spin 1s linear infinite; vertical-align: middle;}
@keyframes spin { 0% { transform: rotate(0deg);} 100% { transform: rotate(360deg);}}
@media (max-width: 1024px) {
  .stat-row { gap: 1rem; }
  .stat-block { padding: 0.8rem 0.9rem; min-width: 120px;}
}
@media (max-width: 768px) {
  .main-content { margin-left: 0; padding: 1rem; }
  .stat-row { gap: 0.5rem; }
  .stat-block { padding: 0.7rem 0.5rem; min-width: 95px;}
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
