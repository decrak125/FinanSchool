<template>
  <div class="dashboard-container">
    <Header v-if="user" :user="user" />
    <Sidebar :current-route="$route.path" @navigation-change="handleNavigation" />
    
    <div class="main-content p-4">
      <div class="card card-form">
        <div class="card-header">
          <h2 class="card-title text-2xl">Gestion des Types de Journal</h2>
        </div>
        
        <div class="card-body">
          <!-- Formulaire -->
          <form @submit.prevent="isEditing ? updateTypeJournal() : addTypeJournal()" class="form-group">
            <div class="form-group">
              <label for="journal-type" class="form-label required">Type de journal</label>
              <input
                v-model="form.Type"
                id="journal-type"
                type="text"
                placeholder="Type de journal"
                class="form-input w-full"
                required
              />
            </div>

            <div class="d-flex gap-2">
              <button type="submit" class="btn btn-primary">
                {{ isEditing ? "Mettre à jour" : "Ajouter" }}
              </button>
              <button
                v-if="isEditing"
                type="button"
                @click="resetForm"
                class="btn btn-ghost"
              >
                Annuler
              </button>
            </div>
          </form>

          <!-- Tableau -->
          <div class="table-container mt-4">
            <table class="table table-bordered table-striped">
              <thead>
                <tr>
                  <th class="text-sm">ID</th>
                  <th class="text-sm">Type</th>
                  <th class="text-sm">Actions</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="journal in typeJournals" :key="journal.id" class="fade-in">
                  <td>{{ journal.Id_Type_Journal }}</td>
                  <td>{{ journal.Type }}</td>
                  <td class="d-flex gap-2">
                    <button
                      @click="editTypeJournal(journal)"
                      class="btn btn-primary text-base"
                    >
                      Modifier
                    </button>
                    <button
                      @click="deleteTypeJournal(journal.Id_Type_Journal)"
                      class="btn btn-error text-base" style="height: 40px; margin-top: 10px;"
                    >
                      Supprimer
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
                    
        <AppFooter />
      </div>
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
import { useRouter } from 'vue-router'
import Sidebar from "../../molecules/Sidebar.vue";
import Header from "../../molecules/Header.vue";
import AppFooter from "../../molecules/Footer.vue";
import ChatBot from "../../molecules/ChatBot.vue";
import { getUser } from "../../../services/Auth";

const router = useRouter();
const user = ref(null);

const handleNavigation = (item) => {
  router.push(item.route);
};

const API_URL = "http://localhost:8000/api/type-journals";

const typeJournals = ref([]);
const isEditing = ref(false);
const editId = ref(null);

const form = ref({
  Type: "",
});

const showChat = ref(false);

const token = localStorage.getItem("token"); // Récupérer le token

if (!token) {
  // Redirection vers login si pas de token
  window.location.href = "/";
} else {
  // Configurer Axios pour inclure le token dans toutes les requêtes
  axios.defaults.headers.common["Authorization"] = `Bearer ${token}`;
}

// Charger les types de journal
const fetchTypeJournals = async () => {
  const response = await axios.get(API_URL);
  typeJournals.value = response.data;
};

// Ajouter
const addTypeJournal = async () => {
  await axios.post(API_URL, form.value);
  fetchTypeJournals();
  resetForm();
};

// Supprimer
const deleteTypeJournal = async (id) => {
  if (confirm("Voulez-vous vraiment supprimer ce type de journal ?")) {
    await axios.delete(`${API_URL}/${id}`);
    fetchTypeJournals();
  }
};

// Préparer édition
const editTypeJournal = (journal) => {
  isEditing.value = true;
  editId.value = journal.Id_Type_Journal;
  form.value = { ...journal };
};

// Mettre à jour
const updateTypeJournal = async () => {
  await axios.put(`${API_URL}/${editId.value}`, form.value);
  fetchTypeJournals();
  resetForm();
};

// Réinitialiser
const resetForm = () => {
  form.value = { Type: "" };
  isEditing.value = false;
  editId.value = null;
};


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
    fetchTypeJournals();
    
  }
});

</script>

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
  .main-content {
    margin-left: 0;
    padding: 16px;
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
