import { ref, onMounted, computed } from "vue";
import { useRouter } from 'vue-router';
import axios from "axios";

// État global partagé entre tous les composants
const user = ref(null);
const isAuthenticated = ref(false);
const API_URL = 'http://localhost:8000/api';
export function useAuth() {
  const router = useRouter();
  
  const getUser = async (token) => {
    return axios.get(`${API_URL}/user`, {
        headers: { Authorization: `Bearer ${token}` 
    }
    })
  };
  // Récupérer l'utilisateur depuis le token
  const fetchUser = async () => {
    try {
      const token = localStorage.getItem("token");
      if (token) {
        const res = await getUser(token);
        user.value = res.data;
        isAuthenticated.value = true;
        console.log("Utilisateur récupéré:", user.value);
        return user.value;
      } else {
        router.push("/");
      }
    } catch (err) {
      console.error("Erreur récupération user:", err);
      logout();
    }
  };

  // Déconnexion
  const logout = () => {
    localStorage.removeItem("token");
    user.value = null;
    isAuthenticated.value = false;
    router.push("/");
  };
  onMounted(() => {
    fetchUser();
  });

  return {
    user,
    isAuthenticated,
    fetchUser,
    logout
  };
}
