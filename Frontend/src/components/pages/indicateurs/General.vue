<script setup>
import { ref, onMounted, watch } from "vue";
import PageAnalyse from '@/components/template/Page-analyse.vue';
import { useIndicateurGeneral } from "@/composables/useIndicateurGeneral";
import Card from "@/components/atoms/Chart/Card.vue";
import ContentHeader from "@/components/molecules/Analyse/Content-header.vue";
import Texte from "@/components/atoms/Texte.vue";
import FilterSelect from "@/components/atoms/Filter-select.vue";
import LoadingText from "@/components/atoms/Loading-text.vue";
import PopUp from "@/components/molecules/Analyse/Pop-up.vue";
import BoutonIcon from "@/components/atoms/Bouton-icon.vue";
// Correction du chemin d'importation
import InterpretationCarousel from "@/components/molecules/Analyse/InterpretationCarousel.vue";
import html2pdf from "html2pdf.js";

const filters = ref({
  dateStart: "",
  dateEnd: "",
  idExercice: ""
});
const nombreLignesLoader = ref(4)

const detailsProduits = ref(false)
const detailsCharges = ref(false)
const detailsResultat = ref(false)
const detailsMarge = ref(false)

const {
  exercice,
  loadingTable,
  exercicesList,
  exercicesOptions,
  totalProduits,
  totalCharges,
  nombreEleves,
  resultatNet,
  margeExploitation,
  infoExercice,
  loading,
  comparisons,
  previousYearData,
  refreshAllData,
  initializeData,
  changeExercice
} = useIndicateurGeneral(filters);
// Formater les valeurs monétaires
const formatMoney = (value) => {
  if (value === null || value === undefined) return '';
  return new Intl.NumberFormat('mg-MG', {
    minimumFractionDigits: 0,
    maximumFractionDigits: 0
  }).format(value);
};

// Formater les pourcentages
const formatPercentage = (value) => {
  if (value === null || value === undefined) return '';
  return `${parseFloat(value).toFixed(2)}%`;
};

// Obtenir la classe CSS pour la tendance
const getTrendClass = (comparison) => {
  if (!comparison?.hasData) return 'trend-neutral';
  return `trend-${comparison.trend}`;
};

// Obtenir l'icône de tendance
const getTrendIcon = (comparison) => {
  if (!comparison?.hasData) return '→';
  return comparison.trend === 'up' ? '↗' :
    comparison.trend === 'down' ? '↘' : '→';
};

// Préparer les données pour le carousel
const interpretationCardsData = ref([]);

// Fonction sécurisée pour mettre à jour les données du carousel
const updateInterpretationCards = () => {
  console.log('Updating carousel data:', {
    totalProduits: totalProduits.value,
    totalCharges: totalCharges.value,
    resultatNet: resultatNet.value,
    margeExploitation: margeExploitation.value,
    comparisons: comparisons.value
  });

  interpretationCardsData.value = [
    {
      valeur: formatMoney(totalProduits.value?.total_produits?.valeur),
      texte: "Revenus",
      chiffre: formatMoney(comparisons.value.produits.evolution),
      icon: getTrendIcon(comparisons.value?.produits),
      variation: comparisons.value?.produits?.percentage || '0',
      colorVariation: getTrendClass(comparisons.value?.produits),
      interpretation: totalProduits.value?.total_produits?.interpretation || "Évolution des revenus totaux",
      format: 'money',
      reverse: false
    },
    {
      valeur: formatMoney(totalCharges.value?.total_charges?.valeur),
      texte: "Dépenses",
      chiffre: formatMoney(comparisons.value.charges.evolution),
      icon: getTrendIcon(comparisons.value?.charges),
      variation: comparisons.value?.charges?.percentage || '0',
      colorVariation: getTrendClass(comparisons.value?.charges),
      interpretation: totalCharges.value?.total_charges?.interpretation || "Évolution des dépenses totales",
      format: 'money',
      reverse: true
    },
    {
      valeur: formatMoney(resultatNet.value?.resultat_net?.valeur),
      texte: "Bénéfices/Pertes",
      chiffre: formatMoney(comparisons.value.resultatNet.evolution),
      icon: getTrendIcon(comparisons.value?.resultatNet),
      variation: comparisons.value?.resultatNet?.percentage || '0',
      colorVariation: getTrendClass(comparisons.value?.resultatNet),
      interpretation: resultatNet.value?.resultat_net?.interpretation || "Évolution du résultat net",
      format: 'money',
      negative: true,
      reverse: false
    },
    {
      valeur: formatPercentage(margeExploitation.value?.marge_exploitation?.valeur),
      texte: "Marge d'exploitation",
      chiffre: comparisons.value?.margeExploitation?.hasData ? 
        formatPercentage(comparisons.value.margeExploitation.evolution) : 'N/A',
      icon: getTrendIcon(comparisons.value?.margeExploitation),
      variation: comparisons.value?.margeExploitation?.percentage || '0',
      colorVariation: getTrendClass(comparisons.value?.margeExploitation),
      interpretation: margeExploitation.value?.marge_exploitation?.interpretation || "Évolution de la marge d'exploitation",
      format: 'percentage',
      reverse: false
    }
  ].filter(card => card.chiffre !== undefined && card.chiffre !== null);
  
  console.log('Carousel data updated:', interpretationCardsData.value);
};

// Watcher pour mettre à jour automatiquement le carousel quand les données changent
watch([() => totalProduits.value, () => totalCharges.value, () => resultatNet.value, () => margeExploitation.value, () => comparisons.value], () => {
  if (!loading.value) {
    updateInterpretationCards();
  }
}, { deep: true, immediate: true });

// Chargement initial
onMounted(() => {
  initializeData().then(() => {
    console.log('Data initialized, updating carousel');
    updateInterpretationCards();
  });
});

// Gestion du changement d'exercice
const handleExerciceChange = async (event) => {
  const idExercice = event.target.value;
  await changeExercice(idExercice);
  updateInterpretationCards();
};

// Fonction pour rafraîchir les données manuellement
const handleRefresh = () => {
  refreshAllData();
  updateInterpretationCards();
};
// ---------------------------------------------
const generatePDFContent = () => {
  const currentYear = exercice.value?.Annee_fiscale || '';
  const previousYear = currentYear - 1;
  const dateGeneration = new Date().toLocaleDateString('fr-FR');
  
  return `
    <div style="font-family: Arial, sans-serif;">
      <!-- Page 1: Résumé général -->
      <div style="page-break-after: always; padding: 20px;">
        <div style="text-align: center; margin-bottom: 30px;">
          <h1 style="color: #2c3e50; margin-bottom: 5px;">Rapport des Indicateurs Généraux</h1>
          <h3 style="color: #6c757d;">Exercice ${currentYear}</h3>
          <p style="color: #888;">Généré le ${dateGeneration}</p>
        </div>
        <div style="margin-top: 40px; padding-top: 20px; border-top: 2px solid #e9ecef; color: #6c757d; font-size: 12px;">
          <p><strong>Note :</strong> Tous les montants sont exprimés en Ariary (Ar).</p>
        </div>
        <div style="margin-bottom: 30px;">
          <h2 style="color: #2c3e50; border-bottom: 2px solid #e9ecef; padding-bottom: 10px;">
            Comparaison ${previousYear} vs ${currentYear}
          </h2>
          
          <table style="width: 100%; border-collapse: collapse; margin-top: 20px;">
            <thead>
              <tr style="background-color: #f8f9fa;">
                <th style="padding: 12px; text-align: left; border: 1px solid #dee2e6;">Indicateur</th>
                <th style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">${currentYear}</th>
                <th style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">${previousYear}</th>
                <th style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">Évolution</th>
                <th style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">Variation</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td style="padding: 12px; border: 1px solid #dee2e6;">Total des revenus</td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${formatMoney(totalProduits.value?.total_produits?.valeur)}
                </td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${formatMoney(previousYearData.value.totalProduits?.total_produits?.valeur)}
                </td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${formatMoney(comparisons.value.produits.evolution)}
                </td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${comparisons.value.produits.percentage}%
                </td>
              </tr>
              
              <tr>
                <td style="padding: 12px; border: 1px solid #dee2e6;">Total des dépenses</td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${formatMoney(totalCharges.value?.total_charges?.valeur)}
                </td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${formatMoney(previousYearData.value.totalCharges?.total_charges?.valeur)}
                </td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${formatMoney(comparisons.value.charges.evolution)}
                </td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${comparisons.value.charges.percentage}%
                </td>
              </tr>
              
              <tr>
                <td style="padding: 12px; border: 1px solid #dee2e6;">Bénéfices/Pertes</td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${formatMoney(resultatNet.value?.resultat_net?.valeur)}
                </td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${formatMoney(previousYearData.value.resultatNet?.resultat_net?.valeur)}
                </td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${formatMoney(comparisons.value.resultatNet.evolution)}
                </td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${comparisons.value.resultatNet.percentage}%
                </td>
              </tr>
              
              <tr>
                <td style="padding: 12px; border: 1px solid #dee2e6;">Marge d'exploitation</td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${formatPercentage(margeExploitation.value?.marge_exploitation?.valeur)}
                </td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${formatPercentage(previousYearData.value.margeExploitation?.marge_exploitation?.valeur)}
                </td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${formatPercentage(comparisons.value.margeExploitation.evolution)}
                </td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${comparisons.value.margeExploitation.percentage}%
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      
      <!-- Page 2: Détails des produits -->
      <div style="page-break-after: always; padding: 20px;">
        <div style="text-align: center; margin-bottom: 30px;">
          <h2 style="color: #2c3e50; margin-bottom: 10px;">Détails des Revenus</h2>
          <p style="color: #6c757d;">Exercice ${currentYear}</p>
        </div>
        
        <div style="margin-bottom: 15px;">
          <p style="color: #495057; font-style: italic;">
            ${totalProduits.value?.total_produits?.definition || "Détail des revenus totaux"}
          </p>
        </div>
        
        <table style="width: 100%; border-collapse: collapse; margin-top: 20px;">
          <thead>
            <tr style="background-color: #f8f9fa;">
              <th style="padding: 12px; text-align: left; border: 1px solid #dee2e6;">Indicateur</th>
              <th style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">${currentYear}</th>
              <th style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">${previousYear}</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td style="padding: 12px; border: 1px solid #dee2e6;">Chiffres d'affaires</td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(totalProduits.value?.details_comptes?.chiffre_affaires)}
              </td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(previousYearData.value.totalProduits?.details_comptes?.chiffre_affaires)}
              </td>
            </tr>
            
            <tr>
              <td style="padding: 12px; border: 1px solid #dee2e6;">Produits d'exploitation</td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(totalProduits.value?.details_comptes?.produits_exploitation)}
              </td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(previousYearData.value.totalProduits?.details_comptes?.produits_exploitation)}
              </td>
            </tr>
            
            <tr>
              <td style="padding: 12px; border: 1px solid #dee2e6;">Produits financiers</td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(totalProduits.value?.details_comptes?.produits_financiers)}
              </td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(previousYearData.value.totalProduits?.details_comptes?.produits_financiers)}
              </td>
            </tr>
            
            <tr>
              <td style="padding: 12px; border: 1px solid #dee2e6;">Produits exceptionnels</td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(totalProduits.value?.details_comptes?.produits_exceptionnels)}
              </td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(previousYearData.value.totalProduits?.details_comptes?.produits_exceptionnels)}
              </td>
            </tr>
            
            <tr>
              <td style="padding: 12px; border: 1px solid #dee2e6;">Reprises/Provisions</td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(totalProduits.value?.details_comptes?.reprises_provisions)}
              </td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(previousYearData.value.totalProduits?.details_comptes?.reprises_provisions)}
              </td>
            </tr>
          </tbody>
          <tfoot>
            <tr style="background-color: #f1f3f4;">
              <td style="padding: 12px; border: 1px solid #dee2e6; font-weight: bold;">TOTAL</td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6; font-weight: bold;">
                ${formatMoney(totalProduits.value?.total_produits?.valeur)}
              </td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6; font-weight: bold;">
                ${formatMoney(previousYearData.value.totalProduits?.total_produits?.valeur)}
              </td>
            </tr>
          </tfoot>
        </table>
      </div>
      
      <!-- Page 3: Détails des charges -->
      <div style="page-break-after: always; padding: 20px;">
        <div style="text-align: center; margin-bottom: 30px;">
          <h2 style="color: #2c3e50; margin-bottom: 10px;">Détails des Dépenses</h2>
          <p style="color: #6c757d;">Exercice ${currentYear}</p>
        </div>
        
        <div style="margin-bottom: 15px;">
          <p style="color: #495057; font-style: italic;">
            ${totalCharges.value?.total_charges?.definition || "Détail des dépenses totales"}
          </p>
        </div>
        
        <table style="width: 100%; border-collapse: collapse; margin-top: 20px;">
          <thead>
            <tr style="background-color: #f8f9fa;">
              <th style="padding: 12px; text-align: left; border: 1px solid #dee2e6;">Indicateur</th>
              <th style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">${currentYear}</th>
              <th style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">${previousYear}</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td style="padding: 12px; border: 1px solid #dee2e6;">Achats et consommations</td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(totalCharges.value?.details_comptes?.achats_consommes)}
              </td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(previousYearData.value.totalCharges?.details_comptes?.achats_consommes)}
              </td>
            </tr>
            
            <tr>
              <td style="padding: 12px; border: 1px solid #dee2e6;">Services extérieurs</td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(totalCharges.value?.details_comptes?.services_exterieurs)}
              </td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(previousYearData.value.totalCharges?.details_comptes?.services_exterieurs)}
              </td>
            </tr>
            
            <tr>
              <td style="padding: 12px; border: 1px solid #dee2e6;">Charges personnelles</td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(totalCharges.value?.details_comptes?.charges_personnel)}
              </td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(previousYearData.value.totalCharges?.details_comptes?.charges_personnel)}
              </td>
            </tr>
            
            <tr>
              <td style="padding: 12px; border: 1px solid #dee2e6;">Autres charges d'exploitation</td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(totalCharges.value?.details_comptes?.autres_charges_exploitation)}
              </td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(previousYearData.value.totalCharges?.details_comptes?.autres_charges_exploitation)}
              </td>
            </tr>
            
            <tr>
              <td style="padding: 12px; border: 1px solid #dee2e6;">Dotations aux amortissements</td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(totalCharges.value?.details_comptes?.dotations_amortissements)}
              </td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(previousYearData.value.totalCharges?.details_comptes?.dotations_amortissements)}
              </td>
            </tr>
            
            <tr>
              <td style="padding: 12px; border: 1px solid #dee2e6;">Charges financières</td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(totalCharges.value?.details_comptes?.charges_financieres)}
              </td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(previousYearData.value.totalCharges?.details_comptes?.charges_financieres)}
              </td>
            </tr>
            
            <tr>
              <td style="padding: 12px; border: 1px solid #dee2e6;">Charges exceptionnelles</td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(totalCharges.value?.details_comptes?.charges_exceptionnelles)}
              </td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(previousYearData.value.totalCharges?.details_comptes?.charges_exceptionnelles)}
              </td>
            </tr>
          </tbody>
          <tfoot>
            <tr style="background-color: #f1f3f4;">
              <td style="padding: 12px; border: 1px solid #dee2e6; font-weight: bold;">TOTAL</td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6; font-weight: bold;">
                ${formatMoney(totalCharges.value?.total_charges?.valeur)}
              </td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6; font-weight: bold;">
                ${formatMoney(previousYearData.value.totalCharges?.total_charges?.valeur)}
              </td>
            </tr>
          </tfoot>
        </table>
      </div>
      
      <!-- Page 4: Détails du résultat net -->
      <div style="page-break-after: always; padding: 20px;">
        <div style="text-align: center; margin-bottom: 30px;">
          <h2 style="color: #2c3e50; margin-bottom: 10px;">Détails du Résultat Net</h2>
          <p style="color: #6c757d;">Exercice ${currentYear}</p>
        </div>
        
        <div style="margin-bottom: 15px;">
          <p style="color: #495057; font-style: italic;">
            ${resultatNet.value?.resultat_net?.definition || "Détail du résultat net"}
          </p>
        </div>
        
        <table style="width: 100%; border-collapse: collapse; margin-top: 20px;">
          <thead>
            <tr style="background-color: #f8f9fa;">
              <th style="padding: 12px; text-align: left; border: 1px solid #dee2e6;">Indicateur</th>
              <th style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">${currentYear}</th>
              <th style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">${previousYear}</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td style="padding: 12px; border: 1px solid #dee2e6;">Produits</td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(resultatNet.value?.details_calcul?.total_produits)}
              </td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(previousYearData.value.resultatNet?.details_calcul?.total_produits)}
              </td>
            </tr>
            
            <tr>
              <td style="padding: 12px; border: 1px solid #dee2e6;">Charges</td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(resultatNet.value?.details_calcul?.total_charges)}
              </td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(previousYearData.value.resultatNet?.details_calcul?.total_charges)}
              </td>
            </tr>
          </tbody>
          <tfoot>
            <tr style="background-color: #f1f3f4;">
              <td style="padding: 12px; border: 1px solid #dee2e6; font-weight: bold;">RESULTAT</td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6; font-weight: bold;">
                ${formatMoney(resultatNet.value?.resultat_net?.valeur)}
              </td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6; font-weight: bold;">
                ${formatMoney(previousYearData.value.resultatNet?.resultat_net?.valeur)}
              </td>
            </tr>
            <tr>
              <td colspan="3" style="padding: 12px; border: 1px solid #dee2e6; font-style: italic;">
                <strong>Formule :</strong> ${resultatNet.value?.formule || "Produits - Charges"}
              </td>
            </tr>
          </tfoot>
        </table>
      </div>
      
      <!-- Page 5: Détails de la marge d'exploitation -->
      <div style="padding: 20px;">
        <div style="text-align: center; margin-bottom: 30px;">
          <h2 style="color: #2c3e50; margin-bottom: 10px;">Détails de la Marge d'Exploitation</h2>
          <p style="color: #6c757d;">Exercice ${currentYear}</p>
        </div>
        
        <div style="margin-bottom: 15px;">
          <p style="color: #495057; font-style: italic;">
            ${margeExploitation.value?.description || "Détail de la marge d'exploitation"}
          </p>
        </div>
        
        <table style="width: 100%; border-collapse: collapse; margin-top: 20px;">
          <thead>
            <tr style="background-color: #f8f9fa;">
              <th style="padding: 12px; text-align: left; border: 1px solid #dee2e6;">Indicateur</th>
              <th style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">${currentYear}</th>
              <th style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">${previousYear}</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td style="padding: 12px; border: 1px solid #dee2e6;">Produits d'exploitation</td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(margeExploitation.value?.details_calcul?.produits_exploitation)}
              </td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(previousYearData.value.margeExploitation?.details_calcul?.produits_exploitation)}
              </td>
            </tr>
            
            <tr>
              <td style="padding: 12px; border: 1px solid #dee2e6;">Charges d'exploitation</td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(margeExploitation.value?.details_calcul?.charges_exploitation)}
              </td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(previousYearData.value.margeExploitation?.details_calcul?.charges_exploitation)}
              </td>
            </tr>
            
            <tr>
              <td style="padding: 12px; border: 1px solid #dee2e6;">Resultat d'exploitation</td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(margeExploitation.value?.details_calcul?.resultat_exploitation)}
              </td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(previousYearData.value.margeExploitation?.details_calcul?.resultat_exploitation)}
              </td>
            </tr>
          </tbody>
          <tfoot>
            <tr style="background-color: #f1f3f4;">
              <td style="padding: 12px; border: 1px solid #dee2e6; font-weight: bold;">Marge d'exploitation</td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6; font-weight: bold;">
                ${formatPercentage(margeExploitation.value?.marge_exploitation?.valeur)}
              </td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6; font-weight: bold;">
                ${formatPercentage(previousYearData.value.margeExploitation?.marge_exploitation?.valeur)}
              </td>
            </tr>
            <tr>
              <td colspan="3" style="padding: 12px; border: 1px solid #dee2e6; font-style: italic;">
                <strong>Formule :</strong> ${margeExploitation.value?.formule || "(Résultat d'exploitation / Produits d'exploitation) × 100"}
              </td>
            </tr>
          </tfoot>
        </table>
        
        <div style="margin-top: 40px; padding-top: 20px; border-top: 2px solid #e9ecef; color: #6c757d; font-size: 12px; text-align: center;">
          <p>--- Fin du rapport ---</p>
          <p>Document généré automatiquement par le système de gestion financière.</p>
        </div>
      </div>
    </div>
  `;
};

// Fonction pour générer et télécharger le PDF
const generatePDF = () => {
  if (loading.value) {
    alert('Veuillez attendre le chargement des données...');
    return;
  }

  const content = generatePDFContent();
  
  const element = document.createElement('div');
  element.innerHTML = content;
  document.body.appendChild(element);

  const options = {
    margin: [15, 15, 15, 15],
    filename: `rapport-indicateurs-generaux-${exercice.value?.Annee_fiscale || 'non-specifie'}.pdf`,
    image: { type: 'jpeg', quality: 0.98 },
    html2canvas: { 
      scale: 2,
      useCORS: true,
      letterRendering: true
    },
    jsPDF: { 
      unit: 'mm', 
      format: 'a4', 
      orientation: 'portrait' 
    }
  };

  html2pdf()
    .set(options)
    .from(element)
    .save()
    .finally(() => {
      document.body.removeChild(element);
    });
};

// Fonction pour gérer l'export PDF
const handleExport = () => {
  generatePDF();
};
</script>
<template>
  <PageAnalyse :menu="'Indicateurs & ratios'" :sousmenu="'Indicateurs généraux'">
    <PopUp v-if="detailsProduits">
      <div class="details-popup">
        <div class="popuphead">
          <Texte :texte="totalProduits?.total_produits?.definition" :type="'dark'" />
          <BoutonIcon @click="detailsProduits = false" icon-name="x-lg" :type="'cancel'" title="Fermer" />
        </div>
        <div class="indicateur-detail">
          <table class="table" id="axesTable">
            <thead>
              <tr>
                <th class="col">Indicateur</th>
                <th class="col">{{ exercice?.Annee_fiscale }}</th>
                <th class="col">{{ exercice?.Annee_fiscale - 1 }}</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td id="detailTitle">Chiffres d'affaires</td>
                <td id="detail">{{ formatMoney(totalProduits?.details_comptes?.chiffre_affaires) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.totalProduits?.details_comptes?.chiffre_affaires) }}
                </td>
              </tr>
              <tr>
                <td id="detailTitle">Produits d'exploitation</td>
                <td id="detail">{{ formatMoney(totalProduits?.details_comptes?.produits_exploitation) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.totalProduits?.details_comptes?.produits_exploitation)
                }}
                </td>
              </tr>
              <tr>
                <td id="detailTitle">Produits financiers</td>
                <td id="detail">{{ formatMoney(totalProduits?.details_comptes?.produits_financiers) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.totalProduits?.details_comptes?.produits_financiers) }}
                </td>
              </tr>
              <tr>
                <td id="detailTitle">Produits exceptionnels</td>
                <td id="detail">{{ formatMoney(totalProduits?.details_comptes?.produits_exceptionnels) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.totalProduits?.details_comptes?.produits_exceptionnels)
                }}
                </td>
              </tr>
              <tr>
                <td id="detailTitle">Reprises/Provisions</td>
                <td id="detail">{{ formatMoney(totalProduits?.details_comptes?.reprises_provisions) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.totalProduits?.details_comptes?.reprises_provisions) }}
                </td>
              </tr>
            </tbody>
            <tfoot id="footable">
              <tr>
                <td id="detailTitle">TOTAL</td>
                <td id="detail">{{ formatMoney(totalProduits?.total_produits?.valeur) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.totalProduits?.total_produits?.valeur) }}</td>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>
    </PopUp>
    <PopUp v-if="detailsCharges">
      <div class="details-popup">
        <div class="popuphead">
          <Texte :texte="totalCharges?.total_charges?.definition" :type="'dark'" />
          <BoutonIcon @click="detailsCharges = false" icon-name="x-lg" :type="'cancel'" title="Fermer" />
        </div>
        <div class="indicateur-detail">
          <table class="table" id="axesTable">
            <thead>
              <tr>
                <th class="col">Indicateur</th>
                <th class="col">{{ exercice?.Annee_fiscale }}</th>
                <th class="col">{{ exercice?.Annee_fiscale - 1 }}</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td id="detailTitle">Achats et consommations</td>
                <td id="detail">{{ formatMoney(totalCharges?.details_comptes?.achats_consommes) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.totalCharges?.details_comptes?.achats_consommes) }}
                </td>
              </tr>
              <tr>
                <td id="detailTitle">Services extérieurs</td>
                <td id="detail">{{ formatMoney(totalCharges?.details_comptes?.services_exterieurs) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.totalCharges?.details_comptes?.services_exterieurs)
                }}
                </td>
              </tr>
              <tr>
                <td id="detailTitle">Charges personnelles</td>
                <td id="detail">{{ formatMoney(totalCharges?.details_comptes?.charges_personnel) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.totalCharges?.details_comptes?.charges_personnel) }}
                </td>
              </tr>
              <tr>
                <td id="detailTitle">Autres charges d'exploitation</td>
                <td id="detail">{{ formatMoney(totalCharges?.details_comptes?.autres_charges_exploitation) }}</td>
                <td id="detail">{{
                  formatMoney(previousYearData.totalCharges?.details_comptes?.autres_charges_exploitation)
                }}
                </td>
              </tr>
              <tr>
                <td id="detailTitle">Dotations aux amortissements</td>
                <td id="detail">{{ formatMoney(totalCharges?.details_comptes?.dotations_amortissements) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.totalCharges?.details_comptes?.dotations_amortissements)
                }}
                </td>
              </tr>
              <tr>
                <td id="detailTitle">Charges financières</td>
                <td id="detail">{{ formatMoney(totalCharges?.details_comptes?.charges_financieres) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.totalCharges?.details_comptes?.charges_financieres) }}
                </td>
              </tr>
              <tr>
                <td id="detailTitle">Charges exceptionnelles</td>
                <td id="detail">{{ formatMoney(totalCharges?.details_comptes?.charges_exceptionnelles) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.totalCharges?.details_comptes?.charges_exceptionnelles)
                }}
                </td>
              </tr>
            </tbody>
            <tfoot id="footable">
              <tr>
                <td id="detailTitle">TOTAL</td>
                <td id="detail">{{ formatMoney(totalCharges?.total_charges?.valeur) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.totalCharges?.total_charges?.valeur) }}</td>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>
    </PopUp>
    <PopUp v-if="detailsResultat">
      <div class="details-popup">
        <div class="popuphead">
          <Texte :texte="resultatNet?.resultat_net?.definition" :type="'dark'" />
          <BoutonIcon @click="detailsResultat = false" icon-name="x-lg" :type="'cancel'" title="Fermer" />
        </div>
        <div class="indicateur-detail">
          <table class="table" id="axesTable">
            <thead>
              <tr>
                <th class="col">Indicateur</th>
                <th class="col">{{ exercice?.Annee_fiscale }}</th>
                <th class="col">{{ exercice?.Annee_fiscale - 1 }}</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td id="detailTitle">Produits</td>
                <td id="detail">{{ formatMoney(resultatNet?.details_calcul?.total_produits) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.resultatNet?.details_calcul?.total_produits) }}
                </td>
              </tr>
              <tr>
                <td id="detailTitle">Charges</td>
                <td id="detail">{{ formatMoney(resultatNet?.details_calcul?.total_charges) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.resultatNet?.details_calcul?.total_charges)
                }}
                </td>
              </tr>
            </tbody>
            <tfoot id="footable">
              <tr>
                <td id="detailTitle">RESULTAT</td>
                <td id="detail">{{ formatMoney(resultatNet?.resultat_net?.valeur) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.resultatNet?.resultat_net?.valeur) }}</td>
              </tr>
              <tr>
                <td id="detailTitle">Formule</td>
                <td id="detail" colspan="2">{{ resultatNet?.formule }}</td>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>
    </PopUp>
    <PopUp v-if="detailsMarge">
      <div class="details-popup">
        <div class="popuphead">
          <Texte :texte="margeExploitation?.description" :type="'dark'" />
          <BoutonIcon @click="detailsMarge = false" icon-name="x-lg" :type="'cancel'" title="Fermer" />
        </div>
        <div class="indicateur-detail">
          <table class="table" id="axesTable">
            <thead>
              <tr>
                <th class="col">Indicateur</th>
                <th class="col">{{ exercice?.Annee_fiscale }}</th>
                <th class="col">{{ exercice?.Annee_fiscale - 1 }}</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td id="detailTitle">Produits d'exploitation</td>
                <td id="detail">{{ formatMoney(margeExploitation?.details_calcul?.produits_exploitation) }}</td>
                <td id="detail">{{
                  formatMoney(previousYearData.margeExploitation?.details_calcul?.produits_exploitation) }}
                </td>
              </tr>
              <tr>
                <td id="detailTitle">Charges d'exploitation</td>
                <td id="detail">{{ formatMoney(margeExploitation?.details_calcul?.charges_exploitation) }}</td>
                <td id="detail">{{ formatMoney(previousYearData.margeExploitation?.details_calcul?.charges_exploitation)
                }}
                </td>
              </tr>
              <tr>
                <td id="detailTitle">Resultat d'exploitation</td>
                <td id="detail">{{ formatMoney(margeExploitation?.details_calcul?.resultat_exploitation) }}</td>
                <td id="detail">{{
                  formatMoney(previousYearData.margeExploitation?.details_calcul?.resultat_exploitation) }}</td>
              </tr>
            </tbody>
            <tfoot id="footable">
              <tr>
                <td id="detailTitle">Marge d'exploitation</td>
                <td id="detail">{{ formatPercentage(margeExploitation?.marge_exploitation?.valeur) }}</td>
                <td id="detail">{{ formatPercentage(previousYearData.margeExploitation?.marge_exploitation?.valeur) }}
                </td>
              </tr>
              <tr>
                <td id="detailTitle">Formule</td>
                <td id="detail" colspan="2">{{ margeExploitation?.formule }}</td>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>
    </PopUp>

    <div class="main">
      <!-- Filtres -->
      <div class="filtres">
        <Texte :type="'dark'" :texte="'Exercice comptable'" />
        <div>
          <FilterSelect v-model="filters.idExercice" @change="handleExerciceChange" :disabled="loading">
            <option value="">Exercice ouvert (actuel)</option>
            <option v-for="exo in exercicesOptions" :key="exo.value" :value="exo.value">
              {{ exo.label }}
            </option>
          </FilterSelect>
        </div>
      </div>

      <!-- Indicateurs en cartes -->
      <div class="graphic">

        <div class="cartes">
          <div class="hauteur">
            <Card :texte="'Total les revenus'" :chiffre="parseInt(totalProduits?.total_produits?.valeur)"
              :format="'money'" :icon="'bi bi-arrow-up-circle'" :icon-color="'green'"
              :variation="getTrendIcon(comparisons.produits) + ' ' + comparisons.produits.percentage"
              :colorVariation="getTrendClass(comparisons.produits)" />
            <Card :texte="'Total des dépenses'" :chiffre="parseInt(totalCharges?.total_charges?.valeur)"
              :format="'money'" :icon="'bi bi-arrow-down-circle'" :icon-color="'red'"
              :variation="getTrendIcon(comparisons.charges) + ' ' + comparisons.charges.percentage"
              :colorVariation="getTrendClass(comparisons.charges)" 
              :reverse = true
              />
              
          </div>
          <div class="hauteur">

            <Card :texte="'Bénéfices/Pertes'" :chiffre="parseInt(resultatNet?.resultat_net?.valeur)" :format="'money'"
              :icon="'bi bi-cash-stack'" :icon-color="'green'" :negative="true"
              :variation="getTrendIcon(comparisons.resultatNet) + ' ' + comparisons.resultatNet.percentage"
              :colorVariation="getTrendClass(comparisons.resultatNet)" />
            <Card :texte="'Marge d\'exploitation'" :chiffre="parseInt(margeExploitation?.marge_exploitation?.valeur)"
              :format="'percentage'" :icon="'bi bi-percent'" :icon-color="'purple'" :negative="true"
              :variation="getTrendIcon(comparisons.margeExploitation) + ' ' + comparisons.margeExploitation.percentage"
              :colorVariation="getTrendClass(comparisons.margeExploitation)" />
          </div>
        </div>
        <InterpretationCarousel 
          :cards="interpretationCardsData"
          :autoPlay="true"
          :autoPlayInterval="5000"
          :showNavigation="true"
        />
      </div>


      <!-- Tableau de comparaison N vs N-1 -->
      <div class="comparison-section">
        <div class="section-header">
          <div class="infos">
            <Texte :type="'bold-dark'" :texte="'Vue et évolution des indicateurs'" />
          <Texte :type="'dark'" :texte="'Montants en Ariary (Ar).'" />
          </div>
          <div class="iconbtn" @click="handleExport">
                  <i class="bi bi-file-earmark-pdf-fill"></i>
          </div>
        </div>

          <table class="table" id="axesTable">
            <thead>
              <tr>
                <th class="col">Indicateur</th>
                <th class="col">{{ exercice?.Annee_fiscale }}</th>
                <th class="col">{{ exercice?.Annee_fiscale - 1 }}</th>
                <th class="col">Évolution</th>
                <th class="col">Variation</th>
                <th class="col">Action</th>
              </tr>
            </thead>
            <tbody v-if="!loadingTable">
              <!-- Total Produits -->
              <tr>
                <td class="col">
                  <i class="bi bi-arrow-right trend-icon green"></i>
                  Total des revenus
                </td>
                <td class="col">
                  {{ formatMoney(totalProduits?.total_produits?.valeur) }}
                </td>
                <td class="col">
                  {{ formatMoney(previousYearData.totalProduits?.total_produits?.valeur) }}
                </td>
                <td :class="['evolution', getTrendClass(comparisons.produits)]">
                  <span class="trend-icon">{{ getTrendIcon(comparisons.produits) }}</span>
                  {{ comparisons.produits?.hasData ? formatMoney(comparisons.produits.evolution) : 'N/A' }}
                </td>
                <td :class="['percentage', getTrendClass(comparisons.produits)]">
                  {{ comparisons.produits?.hasData ? `${comparisons.produits.percentage}%` : 'N/A' }}
                </td>
                <td>
                  <BoutonIcon icon-name="eye-fill" type="edit" title="Voir les détails"
                    @click="detailsProduits = !detailsProduits" />
                </td>
              </tr>

              <!-- Total Charges -->
              <tr>
                <td class="col">
                  <i class="bi bi-arrow-left trend-icon red"></i>
                  Total des dépenses
                </td>
                <td class="col">
                  {{ formatMoney(totalCharges?.total_charges?.valeur) }}
                </td>
                <td class="col">
                  {{ formatMoney(previousYearData.totalCharges?.total_charges?.valeur) }}
                </td>
                <td :class="['evolution', getTrendClass(comparisons.charges)+'-reverse']">
                  <span class="trend-icon">{{ getTrendIcon(comparisons.charges) }}</span>
                  {{ comparisons.charges?.hasData ? formatMoney(comparisons.charges.evolution) : 'N/A' }}
                </td>
                <td :class="['percentage', getTrendClass(comparisons.charges)+'-reverse']">
                  {{ comparisons.charges?.hasData ? `${comparisons.charges.percentage}%` : 'N/A' }}
                </td>
                <td>
                  <BoutonIcon icon-name="eye-fill" type="edit" title="Voir les détails"
                    @click="detailsCharges = !detailsCharges" />
                </td>
              </tr>

              <!-- Résultat Net -->
              <tr>
                <td class="col">
                  <i class="bi bi-arrow-left-right trend-icon orange"></i>
                  Bénéfices/Pertes
                </td>
                <td class="col">
                  {{ formatMoney(resultatNet?.resultat_net?.valeur) }}
                </td>
                <td class="col">
                  {{ formatMoney(previousYearData.resultatNet?.resultat_net?.valeur) }}
                </td>
                <td :class="['evolution', getTrendClass(comparisons.resultatNet)]">
                  <span class="trend-icon">{{ getTrendIcon(comparisons.resultatNet) }}</span>
                  {{ comparisons.resultatNet?.hasData ? formatMoney(comparisons.resultatNet.evolution) : 'N/A' }}
                </td>
                <td :class="['percentage', getTrendClass(comparisons.resultatNet)]">
                  {{ comparisons.resultatNet?.hasData ? `${comparisons.resultatNet.percentage}%` : 'N/A' }}
                </td>
                <td>
                  <BoutonIcon icon-name="eye-fill" type="edit" title="Voir les détails"
                    @click="detailsResultat = !detailsResultat" />
                </td>
              </tr>

              <!-- Marge d'exploitation -->
              <tr>
                <td class="col">
                  <i class="bi bi-percent trend-icon purple"></i>
                  Marge d'exploitation
                </td>
                <td class="col">
                  {{ formatPercentage(margeExploitation?.marge_exploitation?.valeur) }}
                </td>
                <td class="col">
                  {{ formatPercentage(previousYearData.margeExploitation?.marge_exploitation?.valeur) }}
                </td>
                <td :class="['evolution', getTrendClass(comparisons.margeExploitation)]">
                  <span class="trend-icon">{{ getTrendIcon(comparisons.margeExploitation) }}</span>
                  {{ comparisons.margeExploitation?.hasData ? formatPercentage(comparisons.margeExploitation.evolution)
                    : 'N/A' }}
                </td>
                <td :class="['percentage', getTrendClass(comparisons.margeExploitation)]">
                  {{ comparisons.margeExploitation?.hasData ? `${comparisons.margeExploitation.percentage}%` : 'N/A' }}
                </td>
                <td>
                  <BoutonIcon icon-name="eye-fill" type="edit" title="Voir les détails"
                    @click="detailsMarge = !detailsMarge" />
                </td>
              </tr>

              <!-- Nombre d'élèves -->
              <!-- <tr>
                <td class="col">
                  <i class="bi bi-people trend-icon blue"></i>
                  Nombre d'élèves
                </td>
                <td class="col">
                  {{ nombreEleves?.count || 'N/A' }}
                </td>
                <td class="value-previous">
                  {{ previousYearData.nombreEleves?.count || 'N/A' }}
                </td>
                <td :class="['evolution', getTrendClass(comparisons.nombreEleves)]">
                  <span class="trend-icon">{{ getTrendIcon(comparisons.nombreEleves) }}</span>
                  {{ comparisons.nombreEleves?.hasData ? comparisons.nombreEleves.evolution : 'N/A' }}
                </td>
                <td :class="['percentage', getTrendClass(comparisons.nombreEleves)]">
                  {{ comparisons.nombreEleves?.hasData ? `${comparisons.nombreEleves.percentage}%` : 'N/A' }}
                </td>
              </tr> -->
            </tbody>
            <tbody v-if="loadingTable">
              <tr v-for="n in nombreLignesLoader" :key="'loader-' + n">
                <td>
                  <LoadingText :type="'line-1'" />
                </td>
                <td>
                  <LoadingText :type="'line-1'" />
                </td>
                <td>
                  <LoadingText :type="'line-1'" />
                </td>
                <td>
                  <LoadingText :type="'line-1'" />
                </td>
                <td>
                  <LoadingText :type="'line-1'" />
                </td>
              </tr>
            </tbody>
          </table>
      </div>
    </div>
  </PageAnalyse>
</template>

<style lang="scss" scoped>
#axesTable {
  @include table();
  border-radius: $radius-pm;
  cursor: pointer;

  // @media (max-width: $mobile) {
  //   font-size: 0.875rem;
  // }
}

.details-popup {
  min-width: 75vh;
}

#footable {
  font-family: $stara-bold;
  // font-size: 16px;
  // background-color: $light;
}

#detail {
  color: $gris;
  cursor: default;
}

.popuphead {
  @include position-contenus();
  justify-content: space-between;
}

#detailTitle {
  color: $gris;
  padding-left: 24px;
  cursor: default;
}

.cartes {
  @include position-contenus(grid, center, center);
  padding: 0;
  gap: 24px;

  @media (max-width: $tablet) {
    gap: 24px;
    grid-template-columns: repeat(2, 1fr);
  }

  @media (max-width: $mobile) {
    gap: 16px;
    grid-template-columns: 1fr;
  }
}

.main {
  @include position-contenus(flex, center, center);
  padding: 0 18px;
  flex-direction: column;
  gap: 20px;
  flex: 1 0 0;
  align-self: stretch;
  animation: appear 0.6s ease-out forwards;

  @media (max-width: $tablet) {
    padding: 0 24px;
    gap: 16px;
  }

  @media (max-width: $mobile) {
    padding: 0 16px;
    gap: 12px;
  }
}

.hauteur {
  @include position-contenus(flex, center, center);
  padding: 0;
  gap: 24px;

  @media (max-width: $tablet) {
    gap: 24px;
    flex-direction: column;
  }

  @media (max-width: $mobile) {
    gap: 16px;
  }
}

.graphic {
  @include position-contenus(flex, flex-start, flex-start);
  padding: 10px 0;
  align-self: stretch;
  gap: 24px;

  @media (max-width: $tablet) {
    gap: 18px;
    flex-direction: column;
  }

  @media (max-width: $mobile) {
    gap: 16px;
    padding: 5px 0;
  }
}

.filtres {
  @include position-contenus(flex, flex-start, center);
  padding: 0 0;
  align-self: self-start;
  gap: 16px;
  flex-wrap: wrap;

  @media (max-width: $tablet) {
    align-self: stretch;
    justify-content: flex-start;
  }

  @media (max-width: $mobile) {
    gap: 12px;
    justify-content: center;
  }
}

// .exercice-header {
//   @include position-contenus(flex, space-between, center);
//   margin-bottom: 8px;

//   @media (max-width: $mobile) {
//     flex-direction: column;
//     align-items: flex-start;
//     gap: 8px;
//   }
// }

// .exercice-header h3 {
//   margin: 0;
//   color: #2c3e50;
//   font-size: 18px;
// }

// .statut-badge {
//   padding: 4px 12px;
//   border-radius: 20px;
//   font-size: 12px;
//   font-weight: 600;
//   text-transform: uppercase;
// }

// .statut-ouvert {
//   background-color: #d4edda;
//   color: #155724;
// }

// .statut-ferme {
//   background-color: #f8d7da;
//   color: #721c24;
// }

// .exercice-period {
//   margin: 0;
//   color: #555;
//   font-size: 14px;
// }

/* Section de comparaison */
.comparison-section {
  width: 100%;
  height: 100%;
  @include glass();
  border-radius: $radius-pm;
  padding: 18px;
  gap: 8px;
}

.section-header {
  @include position-contenus(flex, space-between, baseline);
  // margin-bottom: 16px;
  padding: 12px;
  h3 {
    margin: 0;
    color: #2c3e50;
    font-size: 18px;
    font-weight: 600;
  }
}
.iconbtn{
  display: flex;
  align-items: center;
  justify-content: center;
  width: 42px;
  height: 42px;
  border-radius: 50%;
  @include glass();
  cursor: pointer;
  i{
    color: #e25252;
    font-size: 20px;
  }
}

.comparison-table-container {
  background: white;
  border-radius: 8px;
  //   box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  //   overflow: hidden;
}

.comparison-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 14px;

  th,
  td {
    padding: 12px 16px;
    text-align: left;
    border-bottom: 1px solid #e9ecef;
  }

  th {
    background-color: #f8f9fa;
    font-weight: 600;
    color: #495057;
    border-bottom: 2px solid #dee2e6;
  }

  tbody tr:hover {
    background-color: #f8f9fa;
  }
}

.indicateur-col {
  width: 25%;
}

.value-col {
  width: 20%;
  text-align: right;
}

.evolution-col {
  width: 17.5%;
  text-align: right;
}

.percentage-col {
  width: 17.5%;
  text-align: right;
}

.indicateur-name {
  font-weight: 500;
  color: #2c3e50;
  display: flex;
  align-items: center;
  gap: 8px;
}

.trend-icon {
  font-size: 16px;

  &.green {
    color: #28a745;
  }

  &.red {
    color: #dc3545;
  }

  &.orange {
    color: #fd7e14;
  }

  &.purple {
    color: #6f42c1;
  }

  &.blue {
    color: #007bff;
  }
}

.value-current {
  font-weight: 600;
  color: #2c3e50;
}

.value-previous {
  color: #6c757d;
}

.evolution,
.percentage {
  font-weight: 600;

  .trend-icon {
    margin-right: 4px;
    font-weight: bold;
  }
}

.trend-up {
  color: #28a745;
  //   background-color: rgba(40, 167, 69, 0.1);
}

.trend-down {
  color: #dc3545;
  //   background-color: rgba(220, 53, 69, 0.1);
}

.trend-down-reverse {
  color: #28a745;
  //   background-color: rgba(40, 167, 69, 0.1);
}

.trend-up-reverse {
  color: #dc3545;
  //   background-color: rgba(220, 53, 69, 0.1);
}

.trend-stable,
.trend-neutral {
  color: #6c757d;
  // background-color: rgba(108, 117, 125, 0.1);
}

/* Responsive */
@media (max-width: $tablet) {
  .comparison-table {
    font-size: 13px;

    th,
    td {
      padding: 10px 12px;
    }
  }

  .indicateur-col {
    width: 30%;
  }

  .value-col {
    width: 18%;
  }

  .evolution-col,
  .percentage-col {
    width: 17%;
  }
}

@media (max-width: $mobile) {
  .comparison-table-container {
    overflow-x: auto;
  }

  .comparison-table {
    min-width: 600px;
    font-size: 12px;

    th,
    td {
      padding: 8px 10px;
    }
  }

  .indicateur-name {
    flex-direction: column;
    align-items: flex-start;
    gap: 4px;
  }
}
</style>