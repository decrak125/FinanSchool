import { ref } from "vue";
import axios from "axios";

const API_URL = "http://127.0.0.1:8000/api";

export function useCoutEtProfit()
{

    const currentYear = new Date().getFullYear();

    const filters = ref({
    dateStart: `${currentYear}-01-01`,
    dateEnd: `${currentYear}-12-31`,
    idCentre: "",
    });

    const centresList = ref([]);
    const centres = ref([]);
    const affectations = ref([]);
    const selectedCentre = ref(null);

    const fetchCentresList = async () => {
        const [resCentres] = await Promise.all([
            axios.get(`${API_URL}/centres`)
          ]);
          centresList.value = resCentres.data;
    };
    
    const fetchCentres = async () => {
      try {
        fetchCentresList();
        const response = await axios.get(`${API_URL}/cout-et-profit`, {
          params: {
            date_start: filters.value.dateStart,
            date_end: filters.value.dateEnd,
            id_centre: filters.value.idCentre || null,
          },
        });
        centres.value = response.data;
        affectations.value = [];
        selectedCentre.value = null;
      } catch (error) {
        console.error(error);
      }
    };
    
    const fetchAffectations = async (centre) => {
      try {
        selectedCentre.value = centre.centre;
        const response = await axios.get(`${API_URL}/detail-affectation`, {
          params: {
            date_start: filters.value.dateStart,
            date_end: filters.value.dateEnd,
            id_centre: centre.id_centre,
          },
        });
        affectations.value = response.data;
      } catch (error) {
        console.error(error);
      }
    };
    
    const formatMontant = (val) => {
      return new Intl.NumberFormat("fr-FR", {
        style: "currency",
        currency: "EUR",
      }).format(val);
    };  

    return {
        centresList, filters, centres, affectations,
        fetchCentresList, fetchCentres, fetchAffectations,
        formatMontant
    };
}
