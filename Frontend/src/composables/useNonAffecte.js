import { ref, computed, onMounted } from "vue";
import axios from "axios";

const API_URL = "http://127.0.0.1:8000/api";

export function useNonAffecte() {
  const sousComptesNonAffectes = ref([]);
  const loading = ref(false);
  const searchTerm = ref("");
  const perPage = ref(null);
  const currentPage = ref(1);
  const total = ref(0);

  // Récupérer les sous-comptes non affectés
  const fetchSousComptesNonAffectes = async () => {
    loading.value = true;
    try {
      const response = await axios.get(`${API_URL}/affectations/non-affectes/pagines`, {
        // params: {
        //   per_page: perPage.value,
        //   page: currentPage.value
        // }
      });
      sousComptesNonAffectes.value = response.data.data;
      total.value = response.data.total;
    } catch (error) {
      console.error('Erreur:', error);
    } finally {
      loading.value = false;
    }
  };

  const affecterSousCompte = async (id) => {
    loading.value = true;
    try {
      const response = await axios.post(`${API_URL}/affectations/non-affectes/${id}`);
      sousComptesNonAffectes.value = response.data.data;
    } catch (error) {
      console.error('Erreur:', error);
    } finally {
      loading.value = false;
    }
  }

  // Filtrer les sous-comptes non affectés localement
  const filteredNonAffectes = computed(() => {
    if (!searchTerm.value) return sousComptesNonAffectes.value;
    
    return sousComptesNonAffectes.value.filter(sousCompte => 
      sousCompte.Code_sous_compte?.toLowerCase().includes(searchTerm.value.toLowerCase()) ||
      sousCompte.Libelle?.toLowerCase().includes(searchTerm.value.toLowerCase()) ||
      sousCompte.compte?.Code_compte?.toLowerCase().includes(searchTerm.value.toLowerCase()) ||
      sousCompte.compte?.Libelle?.toLowerCase().includes(searchTerm.value.toLowerCase())
    );
  });

  // Changer de page
  const changePage = (page) => {
    currentPage.value = page;
    fetchSousComptesNonAffectes();
  };

  onMounted(() => {
    fetchSousComptesNonAffectes();
  });

  return {
    sousComptesNonAffectes: filteredNonAffectes,
    loading,
    searchTerm,
    perPage,
    currentPage,
    total,
    fetchSousComptesNonAffectes,
    changePage
  };
}