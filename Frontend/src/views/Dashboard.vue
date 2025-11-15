<template>
  <div class="dashboard-container">
    <!-- Header -->
    <Header v-if="user" :user="user" />

    <!-- Sidebar -->
    <Sidebar 
      :current-route="$route.path" 
      @navigation-change="handleNavigation" 
    />

    <!-- Main content -->
    <div class="main-content">
      <div class="dashboard">
        <!-- Welcome message -->
        <h1 v-if="user">Bienvenue, {{ user.name }}</h1>
        <h1 v-else>Bienvenue sur le Dashboard</h1>

        <!-- Info exercice courant -->
        <div v-if="exerciceCourant" class="exercice-info">
          <p>
            <strong>Exercice en cours :</strong> 
            {{ formatDate(exerciceCourant.Date_debut) }} 
            - 
            {{ formatDate(exerciceCourant.Date_fin) }}
          </p>
        </div>

        <!-- Filtre exercice -->
        <div class="filter-section" v-if="exercicesFiltrés.length">
          <label for="form-select"><strong>Sélectionner un exercice :</strong></label>
          <select id="form-select" v-model="selectedExercice" @change="changeExercice">
            <option 
              v-for="ex in exercicesFiltrés" 
              :key="ex.Id_Exercice_comptable" 
              :value="ex.Id_Exercice_comptable"
            >
              {{ formatDate(ex.Date_debut) }} - {{ formatDate(ex.Date_fin) }}
            </option>
          </select>
        </div>

        <!-- Cartes résumé -->
        <div class="resume-cards" v-if="resumeData">
          <div class="card simple-card">
            <div class="card-title">Solde actuel CA</div>
            <div class="card-value">{{ resumeData.solde_ca !== null ? resumeData.solde_ca.toLocaleString('fr-FR') : '–' }}</div>
          </div>
          <div class="card simple-card">
            <div class="card-title">Solde Charges</div>
            <div class="card-value">{{ resumeData.solde_charges !== null ? resumeData.solde_charges.toLocaleString('fr-FR') : '–' }}</div>
          </div>
          <div class="card simple-card">
            <div class="card-title">Écritures non validées</div>
            <div class="card-value">{{ resumeData.nb_ecritures_non_validees ?? '–' }}</div>
          </div>
        </div>

        <!-- Dashboard Charts -->
        <div class="charts-grid">
          <div class="chart-card">
            <h2>Évolution du Chiffre d'Affaires</h2>
            <div class="chart-wrapper">
              <Line 
                v-if="caData.labels.length" 
                :data="caChartData" 
                :options="lineOptions" 
              />
              <p v-else class="loading">Chargement...</p>
            </div>
          </div>

          <div class="chart-card">
            <h2>Évolution de la Trésorerie</h2>
            <div class="chart-wrapper">
              <Line 
                v-if="tresorerieData.labels.length" 
                :data="tresorerieChartData" 
                :options="lineOptions" 
              />
              <p v-else class="loading">Chargement...</p>
            </div>
          </div>

          <div class="chart-card">
            <h2>Composition du Bilan</h2>
            <div class="chart-wrapper chart-wrapper-pie">
              <Pie 
                v-if="bilanData.labels.length" 
                :data="bilanChartData" 
                :options="pieOptions" 
              />
              <p v-else class="loading">Chargement...</p>
            </div>
          </div>

          <div class="chart-card">
            <h2>Décomposition du Résultat</h2>
            <div class="chart-wrapper">
              <Bar 
                v-if="resultatData.labels.length" 
                :data="resultatChartData" 
                :options="barOptions" 
              />
              <p v-else class="loading">Chargement...</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Bouton flottant pour ouvrir/fermer le Chatbot -->
      <!-- BOUTON ROND FLOTTANT (FIXE EN BAS À DROITE) -->
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

      
      <!-- Footer -->
      <AppFooter />
    </div>
  </div>
</template>

<script>
import { getUser } from "../services/Auth";
import Sidebar from "../components/molecules/Sidebar.vue";
import Header from "../components/molecules/Header.vue";
import AppFooter from "../components/molecules/Footer.vue";
import ChatBot from "../components/molecules/ChatBot.vue";
import axios from 'axios';
import { Line, Pie, Bar } from 'vue-chartjs';
import {
  Chart as ChartJS,
  LineElement,
  BarElement,
  ArcElement,
  CategoryScale,
  LinearScale,
  PointElement,
  Tooltip,
  Legend
} from 'chart.js';

ChartJS.register(
  LineElement, 
  BarElement, 
  ArcElement, 
  CategoryScale, 
  LinearScale, 
  PointElement, 
  Tooltip, 
  Legend
);

export default {
  components: {
    Sidebar,
    Header,
    AppFooter,
    ChatBot,
    Line,
    Pie,
    Bar
  },
  data() {
    return {
      user: null,
      showChat: false,
      exercices: [],
      selectedExercice: null,
      exerciceCourant: null,
      caData: { labels: [], series: [] },
      tresorerieData: { labels: [], series: [] },
      bilanData: { labels: [], series: [] },
      resultatData: { labels: [], series: [] },
      resumeData: null,
      lineOptions: {
        responsive: true,
        maintainAspectRatio: true,
        aspectRatio: 3,
        plugins: {
          legend: { display: true, position: 'top' },
          tooltip: { mode: 'index', intersect: false }
        },
        scales: {
          x: {
            display: true,
            grid: { display: false },
            ticks: { maxRotation: 45, minRotation: 0, autoSkip: false }
          },
          y: {
            beginAtZero: true,
            grid: { color: 'rgba(0, 0, 0, 0.05)' },
            ticks: {
              callback: function(value) { return value.toLocaleString('fr-FR'); }
            }
          }
        }
      },
      pieOptions: {
        responsive: true,
        maintainAspectRatio: true,
        aspectRatio: 2,
        plugins: {
          legend: { display: true, position: 'right' },
          tooltip: {
            callbacks: {
              label: function(context) {
                let label = context.label || '';
                if (label) label += ': ';
                label += context.parsed.toLocaleString('fr-FR');
                return label;
              }
            }
          }
        }
      },
      barOptions: {
        responsive: true,
        maintainAspectRatio: true,
        aspectRatio: 3,
        plugins: {
          legend: { display: true, position: 'top' },
          tooltip: { mode: 'index', intersect: false }
        },
        scales: {
          x: {
            display: true,
            grid: { display: false },
            ticks: { maxRotation: 45, minRotation: 0, autoSkip: false }
          },
          y: {
            beginAtZero: true,
            grid: { color: 'rgba(0, 0, 0, 0.05)' },
            ticks: {
              callback: function(value) { return value.toLocaleString('fr-FR'); }
            }
          }
        }
      }
    };
  },
  computed: {
    caChartData() {
      return {
        labels: this.caData.labels,
        datasets: [{
          label: 'Chiffre d\'affaires',
          data: this.caData.series,
          borderColor: '#1976d2',
          backgroundColor: 'rgba(25, 118, 210, 0.1)',
          tension: 0.3,
          fill: true,
          pointRadius: 4,
          pointHoverRadius: 6
        }]
      };
    },
    tresorerieChartData() {
      return {
        labels: this.tresorerieData.labels,
        datasets: [{
          label: 'Trésorerie',
          data: this.tresorerieData.series,
          borderColor: '#4caf50',
          backgroundColor: 'rgba(76, 175, 80, 0.1)',
          tension: 0.3,
          fill: true,
          pointRadius: 4,
          pointHoverRadius: 6
        }]
      };
    },
    bilanChartData() {
      return {
        labels: this.bilanData.labels,
        datasets: [{
          data: this.bilanData.series,
          backgroundColor: [
            '#42a5f5', 
            '#66bb6a', 
            '#ffa726', 
            '#ef5350', 
            '#26c6da', 
            '#ab47bc', 
            '#8d6e63', 
            '#ffca28'
          ],
          borderWidth: 1
        }]
      };
    },
    resultatChartData() {
      return {
        labels: this.resultatData.labels,
        datasets: [{
          label: 'Montant',
          data: this.resultatData.series,
          backgroundColor: '#ff9800',
          borderColor: '#f57c00',
          borderWidth: 1
        }]
      };
    },
    exercicesFiltrés() {
      if (!Array.isArray(this.exercices) || !this.exercices.length || !this.exerciceCourant) return [];
      const index = this.exercices.findIndex(
        e => e.Id_Exercice_comptable === this.exerciceCourant.Id_Exercice_comptable
      );
      if (index === -1) return this.exercices.slice(0, 7);
      const debut = Math.max(0, index - 3);
      const fin = Math.min(this.exercices.length, index + 4); // +4 car slice exclut la fin
      return this.exercices.slice(debut, fin);
    }
  },
  async mounted() {
    try {
      const token = localStorage.getItem("token");
      if (token) {
        const res = await getUser(token);
        this.user = res.data;

        await this.loadExercices();
        await this.loadExerciceCourant();

        if (this.exerciceCourant && Array.isArray(this.exercices) && this.exercices.length) {
          this.selectedExercice = this.exerciceCourant.Id_Exercice_comptable;
          await this.changeExercice();
        }
      } else {
        this.$router.push("/");
      }
    } catch (err) {
      console.error(err.response?.data);
      this.$router.push("/");
    }
  },
  methods: {
    async loadExercices() {
      try {
        const res = await axios.get('http://localhost:8000/api/exercices');
        this.exercices = Array.isArray(res.data.exercices) 
          ? res.data.exercices 
          : Array.isArray(res.data) ? res.data : [];
        if (this.exercices.length) {
          this.selectedExercice = this.exercices[0].Id_Exercice_comptable;
        }
      } catch (error) {
        console.error('Erreur chargement exercices:', error);
        this.exercices = [];
      }
    },
    async changeExercice() {
      const selected = this.exercices.find(e => e.Id_Exercice_comptable === this.selectedExercice);
      this.exerciceCourant = selected || null;
      if (this.exerciceCourant) {
        await this.loadDashboardData();
      }
    },
    async loadExerciceCourant() {
      try {
        const res = await axios.get('http://localhost:8000/api/exercices/courant');
        this.exerciceCourant = res.data.exercice;
      } catch (error) {
        console.error('Erreur de chargement de l\'exercice courant:', error);
        this.exerciceCourant = null;
      }
    },
    async loadDashboardData() {
      if (!this.exerciceCourant) {
        console.error('Exercice courant non défini');
        return;
      }
      try {
        const date_debut = this.exerciceCourant.Date_debut.slice(0, 10);
        const date_fin = this.exerciceCourant.Date_fin.slice(0, 10);

        // Résumé
        const resResume = await axios.get(
          'http://localhost:8000/api/dashboard/resume',
          { params: { date_debut, date_fin } }
        );
        this.resumeData = resResume.data;

        // CA
        const resCA = await axios.get(
          'http://localhost:8000/api/dashboard/evolution-ca',
          { params: { date_debut, date_fin } }
        );
        this.caData = this.extractLabelsAndSeries(resCA.data, 'mois', 'montant');

        // Trésorerie
        const resTres = await axios.get(
          'http://localhost:8000/api/dashboard/evolution-tresorerie',
          { params: { date_debut, date_fin } }
        );
        this.tresorerieData = this.extractLabelsAndSeries(resTres.data, 'mois', 'montant');

        // Bilan
        const resBil = await axios.get(
          'http://localhost:8000/api/dashboard/composition-bilan',
          { params: { date_fin } }
        );
        this.bilanData = this.extractLabelsAndSeries(resBil.data, 'poste', 'montant');

        // Résultat
        const resRes = await axios.get(
          'http://localhost:8000/api/dashboard/decomposition-resultat',
          { params: { date_fin } }
        );
        this.resultatData = this.extractLabelsAndSeries(resRes.data, 'etape', 'montant');
      } catch (error) {
        console.error('Erreur de chargement des données:', error);
      }
    },
    extractLabelsAndSeries(items, labelKey, valueKey) {
      const moisNoms = [
        'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
        'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
      ];
      if (labelKey === 'mois' && this.exerciceCourant && this.exerciceCourant.Date_debut) {
        const dateDebut = new Date(this.exerciceCourant.Date_debut);
        const dateFin = new Date(this.exerciceCourant.Date_fin);
        const moisDebut = dateDebut.getMonth() + 1;
        const moisFin = dateFin.getMonth() + 1;
        const dataMap = {};
        items.forEach(item => {
          const mois = parseInt(item[labelKey]);
          dataMap[mois] = parseFloat(item[valueKey]) || 0;
        });
        const labels = [];
        const series = [];
        if (moisDebut <= moisFin) {
          for (let m = moisDebut; m <= moisFin; m++) {
            labels.push(moisNoms[m - 1]);
            series.push(dataMap[m] || 0);
          }
        } else {
          for (let m = moisDebut; m <= 12; m++) {
            labels.push(moisNoms[m - 1]);
            series.push(dataMap[m] || 0);
          }
          for (let m = 1; m <= moisFin; m++) {
            labels.push(moisNoms[m - 1]);
            series.push(dataMap[m] || 0);
          }
        }
        return { labels, series };
      }
      return {
        labels: items.map(i => i[labelKey] ?? i.etape ?? i.poste),
        series: items.map(i => parseFloat(i[valueKey]) || 0)
      };
    },
    formatDate(dateString) {
      if (!dateString) return '';
      const date = new Date(dateString);
      return date.toLocaleDateString('fr-FR', { year: 'numeric', month: 'long', day: 'numeric' });
    },
    logout() {
      localStorage.removeItem("token");
      this.$router.push("/");
    },
    journal() {
      this.$router.push("/journal");
    },
    ecriture() {
      this.$router.push("/ecriture");
    },
    handleNavigation(item) {
      this.$router.push(item.route);
    }
  }
}
</script>

<style scoped>
@font-face {
  font-family: 'Stara';
  src: url('../../public/fonts/Stara-Bold.woff') format('truetype');
  font-weight: normal;
  font-style: normal;
}
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
  background: #f8fafc;
  min-height: calc(100vh - 80px);
  font-family: 'Stara', sans-serif;
}
.dashboard {
  max-width: 1400px;
  margin: 0 auto;
}
.filter-section {
  background: white;
  padding: 12px 20px;
  border-radius: 8px;
  margin-bottom: 16px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
}
.filter-section select {
  margin-left: 12px;
  padding: 6px 10px;
  font-size: 14px;
  border-radius: 4px;
  border: 1px solid #cbd5e1;
}
.exercice-info {
  background: white;
  padding: 16px 24px;
  border-radius: 8px;
  margin-bottom: 24px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
}
.exercice-info p {
  margin: 0;
  color: #25ae39;
  font-size: 15px;
}
.exercice-info strong {
  color: #1e293b;
}
.resume-cards {
  display: flex;
  gap: 28px;
  margin-bottom: 32px;
}
.simple-card {
  background: #fff;
  border-radius: 10px;
  box-shadow: 0 1px 4px rgba(0,0,0,0.08);
  padding: 18px 30px 12px 24px;
  min-width: 220px;
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: flex-start;
}
.card-title {
  font-size: 15px;
  color: #4f4f4f;
  margin-bottom: 10px;
}
.card-value {
  font-size: 2.1em;
  font-weight: 700;
  color: #1976d2;
  margin-bottom: 5px;
}
button {
  background: red;
  color: white;
  border: none;
  padding: 10px 15px;
  border-radius: 5px;
  cursor: pointer;
  margin-right: 10px;
  margin-bottom: 20px;
  font-family: 'Stara', sans-serif;
}
button:hover {
  background: darkred;
}
.charts-grid {
  display: flex;
  flex-direction: column;
  gap: 24px;
  margin-top: 24px;
}
.chart-card {
  background: white;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  width: 100%;
}
.chart-card h2 {
  font-size: 18px;
  font-weight: 600;
  margin-bottom: 16px;
  color: #1e293b;
}
.chart-wrapper {
  position: relative;
  width: 100%;
  max-height: 400px;
}
.chart-wrapper-pie {
  max-height: 500px;
  display: flex;
  justify-content: center;
}
.loading {
  text-align: center;
  color: #64748b;
  padding: 40px;
}

.chatbot-float-btn {
  position: fixed;
  bottom: 35px;
  right: 32px;
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
  .main-content {
    margin-left: 0;
    padding: 16px;
  }
  .chart-wrapper {
    max-height: 300px;
  }
  .chart-wrapper-pie {
    max-height: 400px;
  }
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
