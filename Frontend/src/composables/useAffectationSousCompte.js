import { ref, computed } from "vue";
import axios from "axios";

const API_URL = "http://127.0.0.1:8000/api";

export function useAffectationSousCompte() {
  const form = ref({
    Id_Sous_compte: null,
    ventilations: []
  });
  
  const loading = ref(false);
  const message = ref({ text: "", type: "" });

  // Computed properties pour la validation
  const totalTaux = computed(() => {
    return form.value.ventilations?.reduce((sum, v) => sum + Number(v.taux || 0), 0) || 0;
  });

  const totalTauxClass = computed(() => {
    if (totalTaux.value === 100) return 'text-green-600';
    if (totalTaux.value > 100) return 'text-red-600';
    return 'text-amber-600';
  });

  const hasDuplicateCentres = computed(() => {
    if (!form.value.ventilations) return false;
    const centresIds = form.value.ventilations.map(v => v.id_centre).filter(Boolean);
    return new Set(centresIds).size !== centresIds.length;
  });

  const isFormValid = computed(() => {
    if (!form.value.ventilations || form.value.ventilations.length === 0) return false;
    if (Math.abs(totalTaux.value - 100) > 0.01) return false;
    if (hasDuplicateCentres.value) return false;
    
    return form.value.ventilations.every(vent => 
      vent.id_centre && vent.id_type && vent.taux !== null && vent.taux !== undefined
    );
  });

  // Initialiser le formulaire pour un sous-compte
  const initForm = (sousCompte) => {
    form.value = {
      Id_Sous_compte: sousCompte.Id_Sous_compte,
      ventilations: [{
        id_centre: null,
        id_type: null,
        id_code: null, // ← NOUVEAU CHAMP
        taux: 100,
        description: ""
      }]
    };
  };

  // Ajouter une ventilation
  const addVentilation = () => {
    if (!form.value.ventilations) form.value.ventilations = [];
    
    const totalTauxCalculated = form.value.ventilations.reduce((sum, v) => {
      return sum + Number(Number(v.taux || 0).toFixed(2));
    }, 0);
    
    const remainingTaux = Number((100 - totalTauxCalculated).toFixed(2));
    
    if (remainingTaux <= 0) {
      alert("Le total des taux atteint déjà 100% !");
      return;
    }

    form.value.ventilations.push({
      id_centre: null,
      id_type: null,
      id_code: null, // ← NOUVEAU CHAMP
      taux: Number(remainingTaux.toFixed(2)),
      description: ""
    });
  };

  // Supprimer une ventilation
  const removeVentilation = (index) => {
    if (form.value.ventilations.length <= 1) {
      alert("Vous devez avoir au moins une ventilation !");
      return;
    }

    form.value.ventilations.splice(index, 1);
    
    // Redistribution automatique
    const totalActuel = form.value.ventilations.reduce((sum, v) => sum + Number(v.taux || 0), 0);
    const tauxRestant = 100 - totalActuel;
    
    if (tauxRestant > 0 && form.value.ventilations.length > 0) {
      const derniereIndex = form.value.ventilations.length - 1;
      form.value.ventilations[derniereIndex].taux = Number(
        (Number(form.value.ventilations[derniereIndex].taux || 0) + tauxRestant).toFixed(2)
      );
    }
  };

  // Sauvegarder l'affectation
  const save = async () => {
    // Vérifier le total AVANT la sauvegarde
    const totalTauxCalculated = form.value.ventilations?.reduce((sum, v) => {
      return sum + Number(v.taux || 0);
    }, 0) || 0;
  
    if (Math.abs(totalTauxCalculated - 100) > 0.01) {
      alert(`Le total des taux doit être égal à 100% (actuellement: ${totalTauxCalculated.toFixed(2)}%)`);
      return false;
    }

    if (!form.value.Id_Sous_compte) {
      alert("Sous-compte non spécifié");
      return false;
    }

    loading.value = true;
    
    try {
      const response = await axios.post(`${API_URL}/affectations/store-sous-compte`, {
        Id_Sous_compte: form.value.Id_Sous_compte,
        ventilations: form.value.ventilations.map(vent => ({
          id_centre: vent.id_centre,
          id_type: vent.id_type,
          id_code: vent.id_code, // ← NOUVEAU CHAMP
          taux: vent.taux,
          description: vent.description || ''
        }))
      });
      
      message.value = { text: response.data.message, type: "success" };
      return true;
    } catch (error) {
      console.error('Erreur:', error);
      message.value = {
        text: error.response?.data?.message || 'Erreur lors de la création des affectations',
        type: "error"
      };
      return false;
    } finally {
      loading.value = false;
    }
  };

  // Réinitialiser le formulaire
  const resetForm = () => {
    form.value = {
      Id_Sous_compte: null,
      ventilations: []
    };
    message.value = { text: "", type: "" };
  };

  return {
    form,
    loading,
    message,
    totalTaux,
    totalTauxClass,
    hasDuplicateCentres,
    isFormValid,
    initForm,
    addVentilation,
    removeVentilation,
    save,
    resetForm
  };
}