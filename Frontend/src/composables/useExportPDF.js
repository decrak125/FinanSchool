import html2pdf from 'html2pdf.js';

export const useExportPDF = () => {
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

    const exportToPDF = (contentGenerator, data, filename, loading = false) => {
    if (loading) {
      alert('Veuillez attendre le chargement des données...');
      return false;
    }

    const content = contentGenerator(data);
    
    const element = document.createElement('div');
    element.innerHTML = content;
    document.body.appendChild(element);

    const options = {
      margin: [15, 15, 15, 15],
      filename: filename,
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

    return true;
  };

// Générer le contenu PDF pour les indicateurs de rentabilité
const generateRentabilitePDFContent = (data) => {
  const {
    exercice,
    MargeBrute,
    MargeNette,
    ROE,
    ROA,
    previousYearData,
    comparisons
  } = data;

  const currentYear = exercice?.Annee_fiscale || '';
  const previousYear = currentYear - 1;
  const dateGeneration = new Date().toLocaleDateString('fr-FR');
  
  return `
    <div style="font-family: Arial, sans-serif;">
      <!-- Page 1: Résumé général rentabilité -->
      <div style="page-break-after: always; padding: 20px;">
        <div style="text-align: center; margin-bottom: 30px;">
          <h1 style="color: #2c3e50; margin-bottom: 5px;">Rapport des Indicateurs de Rentabilité</h1>
          <h3 style="color: #6c757d;">Exercice ${currentYear}</h3>
          <p style="color: #888;">Généré le ${dateGeneration}</p>
        </div>
        
        <div style="margin-bottom: 30px;">
          <h2 style="color: #2c3e50; border-bottom: 2px solid #e9ecef; padding-bottom: 10px;">
            Comparaison ${previousYear} vs ${currentYear}
          </h2>
          <p><strong>Note :</strong> Tous les montants sont exprimés en Ariary (Ar).</p>
          
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
                <td style="padding: 12px; border: 1px solid #dee2e6;">Marge brute</td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${formatPercentage(MargeBrute?.marge_brute?.valeur)}
                </td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${formatPercentage(previousYearData?.MargeBrute?.marge_brute?.valeur)}
                </td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${formatPercentage(comparisons?.brute?.evolution)}
                </td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${comparisons?.brute?.percentage}%
                </td>
              </tr>
              
              <tr>
                <td style="padding: 12px; border: 1px solid #dee2e6;">Marge nette</td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${formatPercentage(MargeNette?.marge_nette?.valeur)}
                </td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${formatPercentage(previousYearData?.MargeNette?.marge_nette?.valeur)}
                </td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${formatPercentage(comparisons?.nette?.evolution)}
                </td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${comparisons?.nette?.percentage}%
                </td>
              </tr>
              
              <tr>
                <td style="padding: 12px; border: 1px solid #dee2e6;">ROE</td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${formatPercentage(ROE?.roe?.valeur)}
                </td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${formatPercentage(previousYearData?.ROE?.roe?.valeur)}
                </td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${formatPercentage(comparisons?.ROE?.evolution)}
                </td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${comparisons?.ROE?.percentage}%
                </td>
              </tr>
              
              <tr>
                <td style="padding: 12px; border: 1px solid #dee2e6;">ROA</td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${formatPercentage(ROA?.roa?.valeur)}
                </td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${formatPercentage(previousYearData?.ROA?.roa?.valeur)}
                </td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${formatPercentage(comparisons?.ROA?.evolution)}
                </td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${comparisons?.ROA?.percentage}%
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      
      <!-- Page 2: Détails de la marge brute -->
      <div style="page-break-after: always; padding: 20px;">
        <div style="text-align: center; margin-bottom: 30px;">
          <h2 style="color: #2c3e50; margin-bottom: 10px;">Détails de la Marge Brute</h2>
          <p style="color: #6c757d;">Exercice ${currentYear}</p>
        </div>
        
        <div style="margin-bottom: 15px;">
          <p style="color: #495057; font-style: italic;">
            ${MargeBrute?.marge_brute?.definition || "Mesure la rentabilité opérationnelle de base"}
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
              <td style="padding: 12px; border: 1px solid #dee2e6;">Chiffre d'affaires</td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(MargeBrute?.details_calcul?.chiffre_affaires)}
              </td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(previousYearData?.MargeBrute?.details_calcul?.chiffre_affaires)}
              </td>
            </tr>
            
            <tr>
              <td style="padding: 12px; border: 1px solid #dee2e6;">Coût des ventes</td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(MargeBrute?.details_calcul?.cout_ventes)}
              </td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(previousYearData?.MargeBrute?.details_calcul?.cout_ventes)}
              </td>
            </tr>
            
            <tr>
              <td style="padding: 12px; border: 1px solid #dee2e6;">Marge absolue</td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(MargeBrute?.details_calcul?.marge_absolue)}
              </td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(previousYearData?.MargeBrute?.details_calcul?.marge_absolue)}
              </td>
            </tr>
          </tbody>
          <tfoot>
            <tr style="background-color: #f1f3f4;">
              <td style="padding: 12px; border: 1px solid #dee2e6; font-weight: bold;">Marge brute</td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6; font-weight: bold;">
                ${formatPercentage(MargeBrute?.marge_brute?.valeur)}
              </td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6; font-weight: bold;">
                ${formatPercentage(previousYearData?.MargeBrute?.marge_brute?.valeur)}
              </td>
            </tr>
            <tr>
              <td colspan="3" style="padding: 12px; border: 1px solid #dee2e6; font-style: italic;">
                <strong>Formule :</strong> ${MargeBrute?.formule || "(Marge absolue / Chiffre d'affaires) × 100"}
              </td>
            </tr>
          </tfoot>
        </table>
      </div>
      
      <!-- Page 3: Détails de la marge nette -->
      <div style="page-break-after: always; padding: 20px;">
        <div style="text-align: center; margin-bottom: 30px;">
          <h2 style="color: #2c3e50; margin-bottom: 10px;">Détails de la Marge Nette</h2>
          <p style="color: #6c757d;">Exercice ${currentYear}</p>
        </div>
        
        <div style="margin-bottom: 15px;">
          <p style="color: #495057; font-style: italic;">
            ${MargeNette?.marge_nette?.definition || "Montre le bénéfice final par Ar de ventes"}
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
              <td style="padding: 12px; border: 1px solid #dee2e6;">Résultat net</td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(MargeNette?.details_calcul?.resultat_net)}
              </td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(previousYearData?.MargeNette?.details_calcul?.resultat_net)}
              </td>
            </tr>
            
            <tr>
              <td style="padding: 12px; border: 1px solid #dee2e6;">Chiffre d'affaires</td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(MargeNette?.details_calcul?.chiffre_affaires)}
              </td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(previousYearData?.MargeNette?.details_calcul?.chiffre_affaires)}
              </td>
            </tr>
          </tbody>
          <tfoot>
            <tr style="background-color: #f1f3f4;">
              <td style="padding: 12px; border: 1px solid #dee2e6; font-weight: bold;">Marge nette</td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6; font-weight: bold;">
                ${formatPercentage(MargeNette?.marge_nette?.valeur)}
              </td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6; font-weight: bold;">
                ${formatPercentage(previousYearData?.MargeNette?.marge_nette?.valeur)}
              </td>
            </tr>
            <tr>
              <td colspan="3" style="padding: 12px; border: 1px solid #dee2e6; font-style: italic;">
                <strong>Formule :</strong> ${MargeNette?.formule || "(Résultat net / Chiffre d'affaires) × 100"}
              </td>
            </tr>
          </tfoot>
        </table>
      </div>
      
      <!-- Page 4: Détails du ROE -->
      <div style="page-break-after: always; padding: 20px;">
        <div style="text-align: center; margin-bottom: 30px;">
          <h2 style="color: #2c3e50; margin-bottom: 10px;">Détails du ROE (Return on Equity)</h2>
          <p style="color: #6c757d;">Exercice ${currentYear}</p>
        </div>
        
        <div style="margin-bottom: 15px;">
          <p style="color: #495057; font-style: italic;">
            ${ROE?.roe?.definition || "Rentabilité des capitaux propres"}
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
              <td style="padding: 12px; border: 1px solid #dee2e6;">Résultat net</td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(ROE?.details_calcul?.resultat_net)}
              </td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(previousYearData?.ROE?.details_calcul?.resultat_net)}
              </td>
            </tr>
            
            <tr>
              <td style="padding: 12px; border: 1px solid #dee2e6;">Capitaux propres</td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(ROE?.details_calcul?.capitaux_propres)}
              </td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(previousYearData?.ROE?.details_calcul?.capitaux_propres)}
              </td>
            </tr>
          </tbody>
          <tfoot>
            <tr style="background-color: #f1f3f4;">
              <td style="padding: 12px; border: 1px solid #dee2e6; font-weight: bold;">ROE</td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6; font-weight: bold;">
                ${formatPercentage(ROE?.roe?.valeur)}
              </td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6; font-weight: bold;">
                ${formatPercentage(previousYearData?.ROE?.roe?.valeur)}
              </td>
            </tr>
            <tr>
              <td colspan="3" style="padding: 12px; border: 1px solid #dee2e6; font-style: italic;">
                <strong>Formule :</strong> ${ROE?.formule || "(Résultat net / Capitaux propres) × 100"}
              </td>
            </tr>
          </tfoot>
        </table>
      </div>
      
      <!-- Page 5: Détails du ROA -->
      <div style="padding: 20px;">
        <div style="text-align: center; margin-bottom: 30px;">
          <h2 style="color: #2c3e50; margin-bottom: 10px;">Détails du ROA (Return on Assets)</h2>
          <p style="color: #6c757d;">Exercice ${currentYear}</p>
        </div>
        
        <div style="margin-bottom: 15px;">
          <p style="color: #495057; font-style: italic;">
            ${ROA?.roa?.definition || "Rentabilité des actifs"}
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
              <td style="padding: 12px; border: 1px solid #dee2e6;">Résultat net</td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(ROA?.details_calcul?.resultat_net)}
              </td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(previousYearData?.ROA?.details_calcul?.resultat_net)}
              </td>
            </tr>
            
            <tr>
              <td style="padding: 12px; border: 1px solid #dee2e6;">Total actif</td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(ROA?.details_calcul?.total_actif)}
              </td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(previousYearData?.ROA?.details_calcul?.total_actif)}
              </td>
            </tr>
          </tbody>
          <tfoot>
            <tr style="background-color: #f1f3f4;">
              <td style="padding: 12px; border: 1px solid #dee2e6; font-weight: bold;">ROA</td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6; font-weight: bold;">
                ${formatPercentage(ROA?.roa?.valeur)}
              </td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6; font-weight: bold;">
                ${formatPercentage(previousYearData?.ROA?.roa?.valeur)}
              </td>
            </tr>
            <tr>
              <td colspan="3" style="padding: 12px; border: 1px solid #dee2e6; font-style: italic;">
                <strong>Formule :</strong> ${ROA?.formule || "(Résultat net / Total actif) × 100"}
              </td>
            </tr>
          </tfoot>
        </table>
        
        <div style="margin-top: 40px; padding-top: 20px; border-top: 2px solid #e9ecef; color: #6c757d; font-size: 12px; text-align: center;">
          <p>--- Fin du rapport de rentabilité ---</p>
          <p>Document généré automatiquement par le système de gestion financière.</p>
        </div>
      </div>
    </div>
  `;
};

// Générer le contenu PDF pour les indicateurs de liquidité
const generateLiquiditePDFContent = (data) => {
  const {
    exercice,
    TresorerieNette,
    BFR,
    LiquiditeGenerale,
    previousYearData,
    comparisons
  } = data;

  const currentYear = exercice?.Annee_fiscale || '';
  const previousYear = currentYear - 1;
  const dateGeneration = new Date().toLocaleDateString('fr-FR');
  
  return `
    <div style="font-family: Arial, sans-serif;">
      <!-- Page 1: Résumé général liquidité -->
      <div style="page-break-after: always; padding: 20px;">
        <div style="text-align: center; margin-bottom: 30px;">
          <h1 style="color: #2c3e50; margin-bottom: 5px;">Rapport des Indicateurs de Liquidité</h1>
          <h3 style="color: #6c757d;">Exercice ${currentYear}</h3>
          <p style="color: #888;">Généré le ${dateGeneration}</p>
        </div>
        
        <div style="margin-bottom: 30px;">
          <h2 style="color: #2c3e50; border-bottom: 2px solid #e9ecef; padding-bottom: 10px;">
            Comparaison ${previousYear} vs ${currentYear}
          </h2>
            <p><strong>Note :</strong> Tous les montants sont exprimés en Ariary (Ar).</p>
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
                <td style="padding: 12px; border: 1px solid #dee2e6;">Trésorerie nette</td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${formatMoney(TresorerieNette?.tresorerie_nette?.valeur)}
                </td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${formatMoney(previousYearData?.TresorerieNette?.tresorerie_nette?.valeur)}
                </td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${formatMoney(comparisons?.Tresorerie?.evolution)}
                </td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${comparisons?.Tresorerie?.percentage}%
                </td>
              </tr>
              
              <tr>
                <td style="padding: 12px; border: 1px solid #dee2e6;">Besoin en fonds de roulement</td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${formatMoney(BFR?.bfr?.valeur)}
                </td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${formatMoney(previousYearData?.BFR?.bfr?.valeur)}
                </td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${formatMoney(comparisons?.fondRoulement?.evolution)}
                </td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${comparisons?.fondRoulement?.percentage}%
                </td>
              </tr>
              
              <tr>
                <td style="padding: 12px; border: 1px solid #dee2e6;">Ratio liquidité générale</td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${formatPercentage(LiquiditeGenerale?.ratio_liquidite_generale?.valeur)}
                </td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${formatPercentage(previousYearData?.LiquiditeGenerale?.ratio_liquidite_generale?.valeur)}
                </td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${formatPercentage(comparisons?.Liquidite?.evolution)}
                </td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${comparisons?.Liquidite?.percentage}%
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      
      <!-- Page 2: Détails de la trésorerie nette -->
      <div style="page-break-after: always; padding: 20px;">
        <div style="text-align: center; margin-bottom: 30px;">
          <h2 style="color: #2c3e50; margin-bottom: 10px;">Détails de la Trésorerie Nette</h2>
          <p style="color: #6c757d;">Exercice ${currentYear}</p>
        </div>
        
        <div style="margin-bottom: 15px;">
          <p style="color: #495057; font-style: italic;">
            ${TresorerieNette?.tresorerie_nette?.definition || "Trésorerie disponible"}
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
              <td style="padding: 12px; border: 1px solid #dee2e6;">Banque</td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(TresorerieNette?.details_calcul?.comptes_tresorerie?.banque)}
              </td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(previousYearData?.TresorerieNette?.details_calcul?.comptes_tresorerie?.banque)}
              </td>
            </tr>
            
            <tr>
              <td style="padding: 12px; border: 1px solid #dee2e6;">Découverts</td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(TresorerieNette?.details_calcul?.comptes_tresorerie?.decouverts)}
              </td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(previousYearData?.TresorerieNette?.details_calcul?.comptes_tresorerie?.decouverts)}
              </td>
            </tr>
          </tbody>
          <tfoot>
            <tr style="background-color: #f1f3f4;">
              <td style="padding: 12px; border: 1px solid #dee2e6; font-weight: bold;">Trésorerie nette</td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6; font-weight: bold;">
                ${formatMoney(TresorerieNette?.tresorerie_nette?.valeur)}
              </td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6; font-weight: bold;">
                ${formatMoney(previousYearData?.TresorerieNette?.tresorerie_nette?.valeur)}
              </td>
            </tr>
            <tr>
              <td colspan="3" style="padding: 12px; border: 1px solid #dee2e6; font-style: italic;">
                <strong>Formule :</strong> ${TresorerieNette?.formule || "Banque - Découverts"}
              </td>
            </tr>
          </tfoot>
        </table>
      </div>
      
      <!-- Page 3: Détails du BFR -->
      <div style="page-break-after: always; padding: 20px;">
        <div style="text-align: center; margin-bottom: 30px;">
          <h2 style="color: #2c3e50; margin-bottom: 10px;">Détails du Besoin en Fonds de Roulement</h2>
          <p style="color: #6c757d;">Exercice ${currentYear}</p>
        </div>
        
        <div style="margin-bottom: 15px;">
          <p style="color: #495057; font-style: italic;">
            ${BFR?.bfr?.definition || "Besoin en fonds de roulement"}
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
              <td style="padding: 12px; border: 1px solid #dee2e6;">Stocks</td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(BFR?.details_calcul?.stocks)}
              </td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(previousYearData?.BFR?.details_calcul?.stocks)}
              </td>
            </tr>
            
            <tr>
              <td style="padding: 12px; border: 1px solid #dee2e6;">Créances clients</td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(BFR?.details_calcul?.creances_clients)}
              </td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(previousYearData?.BFR?.details_calcul?.creances_clients)}
              </td>
            </tr>
            
            <tr>
              <td style="padding: 12px; border: 1px solid #dee2e6;">Dettes fournisseurs</td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(BFR?.details_calcul?.dettes_fournisseurs)}
              </td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(previousYearData?.BFR?.details_calcul?.dettes_fournisseurs)}
              </td>
            </tr>
          </tbody>
          <tfoot>
            <tr style="background-color: #f1f3f4;">
              <td style="padding: 12px; border: 1px solid #dee2e6; font-weight: bold;">BFR</td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6; font-weight: bold;">
                ${formatMoney(BFR?.bfr?.valeur)}
              </td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6; font-weight: bold;">
                ${formatMoney(previousYearData?.BFR?.bfr?.valeur)}
              </td>
            </tr>
            <tr>
              <td colspan="3" style="padding: 12px; border: 1px solid #dee2e6; font-style: italic;">
                <strong>Formule :</strong> ${BFR?.formule || "Stocks + Créances clients - Dettes fournisseurs"}
              </td>
            </tr>
          </tfoot>
        </table>
      </div>
      
      <!-- Page 4: Détails du ratio de liquidité générale -->
      <div style="padding: 20px;">
        <div style="text-align: center; margin-bottom: 30px;">
          <h2 style="color: #2c3e50; margin-bottom: 10px;">Détails du Ratio de Liquidité Générale</h2>
          <p style="color: #6c757d;">Exercice ${currentYear}</p>
        </div>
        
        <div style="margin-bottom: 15px;">
          <p style="color: #495057; font-style: italic;">
            ${LiquiditeGenerale?.ratio_liquidite_generale?.definition || "Capacité à honorer les dettes à court terme"}
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
              <td style="padding: 12px; border: 1px solid #dee2e6;">Actif circulant</td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(LiquiditeGenerale?.details_calcul?.actif_circulant)}
              </td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(previousYearData?.LiquiditeGenerale?.details_calcul?.actif_circulant)}
              </td>
            </tr>
            
            <tr>
              <td style="padding: 12px; border: 1px solid #dee2e6;">Passif à court terme</td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(LiquiditeGenerale?.details_calcul?.passif_court_terme)}
              </td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                ${formatMoney(previousYearData?.LiquiditeGenerale?.details_calcul?.passif_court_terme)}
              </td>
            </tr>
          </tbody>
          <tfoot>
            <tr style="background-color: #f1f3f4;">
              <td style="padding: 12px; border: 1px solid #dee2e6; font-weight: bold;">Ratio liquidité générale</td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6; font-weight: bold;">
                ${formatPercentage(LiquiditeGenerale?.ratio_liquidite_generale?.valeur)}
              </td>
              <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6; font-weight: bold;">
                ${formatPercentage(previousYearData?.LiquiditeGenerale?.ratio_liquidite_generale?.valeur)}
              </td>
            </tr>
            <tr>
              <td colspan="3" style="padding: 12px; border: 1px solid #dee2e6; font-style: italic;">
                <strong>Formule :</strong> ${LiquiditeGenerale?.formule || "(Actif circulant / Passif à court terme) × 100"}
              </td>
            </tr>
          </tfoot>
        </table>
        
        <div style="margin-top: 40px; padding-top: 20px; border-top: 2px solid #e9ecef; color: #6c757d; font-size: 12px; text-align: center;">
          <p>--- Fin du rapport de liquidité ---</p>
          <p>Document généré automatiquement par le système de gestion financière.</p>
        </div>
      </div>
    </div>
  `;
};

// Fonction spécifique pour les indicateurs de rentabilité
const exportRentabilitePDF = (data, loading = false) => {
  const filename = `rapport-rentabilite-${data.exercice?.Annee_fiscale || 'non-specifie'}.pdf`;
  return exportToPDF(generateRentabilitePDFContent, data, filename, loading);
};

// Fonction spécifique pour les indicateurs de liquidité
const exportLiquiditePDF = (data, loading = false) => {
  const filename = `rapport-liquidite-${data.exercice?.Annee_fiscale || 'non-specifie'}.pdf`;
  return exportToPDF(generateLiquiditePDFContent, data, filename, loading);
};

return {
  formatMoney,
  formatPercentage,
  generateRentabilitePDFContent,
  generateLiquiditePDFContent,
  exportToPDF,
  exportRentabilitePDF,
  exportLiquiditePDF
};
};

