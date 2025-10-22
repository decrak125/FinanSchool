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
        <!-- Personalized message -->
        <h1 v-if="user">Bienvenue, {{ user.name }}</h1>
        <h1 v-else>Bienvenue sur le Dashboard</h1>

        <!-- Filtre exercice -->
        <div v-if="exerciceCourant" class="exercice-info">
          <p>
            <strong>Exercice en cours :</strong> 
            {{ formatDate(exerciceCourant.Date_debut) }} 
            - 
            {{ formatDate(exerciceCourant.Date_fin) }}
          </p>
        </div>
        
        <!-- Dashboard Charts -->
        <div class="charts-grid">
          <!-- 1. Évolution du CA -->
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

          <!-- 2. Évolution de la Trésorerie -->
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

          <!-- 3. Composition du Bilan -->
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

          <!-- 4. Décomposition du Résultat -->
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
    Line,
    Pie,
    Bar
  },
  data() {
    return {
      user: null,
      exerciceCourant: null,
      caData: { labels: [], series: [] },
      tresorerieData: { labels: [], series: [] },
      bilanData: { labels: [], series: [] },
      resultatData: { labels: [], series: [] },
      lineOptions: {
        responsive: true,
        maintainAspectRatio: true,
        aspectRatio: 3,
        plugins: {
          legend: {
            display: true,
            position: 'top'
          },
          tooltip: {
            mode: 'index',
            intersect: false,
          }
        },
        scales: {
          x: {
            display: true,
            grid: {
              display: false
            },
            ticks: {
              maxRotation: 45,
              minRotation: 0,
              autoSkip: false
            }
          },
          y: {
            beginAtZero: true,
            grid: {
              color: 'rgba(0, 0, 0, 0.05)'
            },
            ticks: {
              callback: function(value) {
                return value.toLocaleString('fr-FR');
              }
            }
          }
        }
      },
      pieOptions: {
        responsive: true,
        maintainAspectRatio: true,
        aspectRatio: 2,
        plugins: {
          legend: {
            display: true,
            position: 'right'
          },
          tooltip: {
            callbacks: {
              label: function(context) {
                let label = context.label || '';
                if (label) {
                  label += ': ';
                }
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
          legend: {
            display: true,
            position: 'top'
          },
          tooltip: {
            mode: 'index',
            intersect: false,
          }
        },
        scales: {
          x: {
            display: true,
            grid: {
              display: false
            },
            ticks: {
              maxRotation: 45,
              minRotation: 0,
              autoSkip: false
            }
          },
          y: {
            beginAtZero: true,
            grid: {
              color: 'rgba(0, 0, 0, 0.05)'
            },
            ticks: {
              callback: function(value) {
                return value.toLocaleString('fr-FR');
              }
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
    }
  },
  async mounted() {
    try {
      const token = localStorage.getItem("token");
      if (token) {
        const res = await getUser(token);
        this.user = res.data;
        await this.loadExerciceCourant();
        await this.loadDashboardData();
      } else {
        this.$router.push("/");
      }
    } catch (err) {
      console.error(err.response?.data);
      this.$router.push("/");
    }
  },
  methods: {
    async loadExerciceCourant() {
      try {
        const res = await axios.get('http://localhost:8000/api/exercices/courant');
        this.exerciceCourant = res.data.exercice;
        console.log('Exercice courant chargé:', this.exerciceCourant);
      } catch (error) {
        console.error('Erreur de chargement de l\'exercice courant:', error);
        this.exerciceCourant = {
          Date_debut: new Date().getFullYear() + '-01-01',
          Date_fin: new Date().getFullYear() + '-12-31'
        };
      }
    },
    async loadDashboardData() {
      if (!this.exerciceCourant) {
        console.error('Exercice courant non défini');
        return;
      }
      
      try {
        const year = new Date(this.exerciceCourant.Date_debut).getFullYear();
        console.log('Année extraite:', year);
        
        const resCA = await axios.get(
          'http://localhost:8000/api/dashboard/evolution-ca',
          { params: { year } }
        );
        console.log('Données CA reçues:', resCA.data);
        this.caData = this.extractLabelsAndSeries(
          resCA.data, 
          'mois', 
          'montant'
        );
        console.log('CA Data après extraction:', this.caData);

        const resTres = await axios.get(
          'http://localhost:8000/api/dashboard/evolution-tresorerie',
          { params: { year } }
        );
        console.log('Données Trésorerie reçues:', resTres.data);
        this.tresorerieData = this.extractLabelsAndSeries(
          resTres.data, 
          'mois', 
          'montant'
        );
        console.log('Trésorerie Data après extraction:', this.tresorerieData);

        const resBil = await axios.get(
          'http://localhost:8000/api/dashboard/composition-bilan',
          {
            params: { 
              date: this.exerciceCourant.Date_fin || new Date().toISOString().slice(0, 10)
            }
          }
        );
        this.bilanData = this.extractLabelsAndSeries(
          resBil.data, 
          'poste', 
          'montant'
        );

        const resRes = await axios.get(
          'http://localhost:8000/api/dashboard/decomposition-resultat',
          {
            params: { 
              date: this.exerciceCourant.Date_fin || new Date().toISOString().slice(0, 10)
            }
          }
        );
        this.resultatData = this.extractLabelsAndSeries(
          resRes.data, 
          'etape', 
          'montant'
        );
      } catch (error) {
        console.error('Erreur de chargement des données:', error);
      }
    },
    extractLabelsAndSeries(items, labelKey, valueKey) {
      const moisNoms = [
        'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
        'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
      ];
      
      // Pour les graphiques mensuels (CA et Trésorerie)
      if (labelKey === 'mois' && this.exerciceCourant && this.exerciceCourant.Date_debut) {
        const dateDebut = new Date(this.exerciceCourant.Date_debut);
        const dateFin = new Date(this.exerciceCourant.Date_fin);
        const moisDebut = dateDebut.getMonth() + 1;
        const moisFin = dateFin.getMonth() + 1;
        
        // Créer un map des données reçues
        const dataMap = {};
        items.forEach(item => {
          const mois = parseInt(item[labelKey]);
          dataMap[mois] = parseFloat(item[valueKey]) || 0;
        });
        
        const labels = [];
        const series = [];
        
        // Si l'exercice est sur l'année civile (janvier à décembre)
        if (moisDebut <= moisFin) {
          for (let m = moisDebut; m <= moisFin; m++) {
            labels.push(moisNoms[m - 1]);
            series.push(dataMap[m] || 0);
          }
        } 
        // Si l'exercice chevauche deux années (ex: juillet à juin)
        else {
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
      
      // Pour les autres graphiques (bilan, résultat)
      return {
        labels: items.map(i => {
          const key = i[labelKey] ?? i.etape ?? i.poste;
          return key;
        }),
        series: items.map(i => parseFloat(i[valueKey]) || 0)
      };
    },
    formatDate(dateString) {
      if (!dateString) return '';
      const date = new Date(dateString);
      return date.toLocaleDateString('fr-FR', { 
        year: 'numeric', 
        month: 'long', 
        day: 'numeric' 
      });
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
    },
  },
};
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

.exercice-info {
  background: white;
  padding: 16px 24px;
  border-radius: 8px;
  margin-bottom: 24px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
}

.exercice-info p {
  margin: 0;
  color: #475569;
  font-size: 15px;
}

.exercice-info strong {
  color: #1e293b;
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
}
</style>
