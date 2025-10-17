import { ref } from 'vue';
import { getUser } from '../services/Auth.js';
import { useRouter } from 'vue-router';

// État global partagé entre tous les composants
const user = ref(null);
const isAuthenticated = ref(false);

export function useAuth() {
  const router = useRouter();

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

  return {
    user,
    isAuthenticated,
    fetchUser,
    logout
  };
}
