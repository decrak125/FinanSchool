import html2pdf from 'html2pdf.js';

export const useExportPedagogie = () => {
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

  // Générer le contenu PDF pour les indicateurs pédagogiques
  const generatePedagogiquePDFContent = (data) => {
    const {
      exercice,
      coutFonctionnement,
      chiffreAffaires,
      partMasseSalariale,
      margeParEleve,
      previousYearData,
      comparisons
    } = data;

    const currentYear = exercice?.Annee_fiscale || '';
    const previousYear = currentYear - 1;
    const dateGeneration = new Date().toLocaleDateString('fr-FR');
    
    return `
      <div style="font-family: Arial, sans-serif;">
        <!-- Page 1: Résumé général pédagogique -->
        <div style="page-break-after: always; padding: 20px;">
          <div style="text-align: center; margin-bottom: 30px;">
            <h1 style="color: #2c3e50; margin-bottom: 5px;">Rapport des Indicateurs Pédagogiques</h1>
            <h3 style="color: #6c757d;">Exercice ${currentYear}</h3>
            <p style="color: #888;">Généré le ${dateGeneration}</p>
          </div>
          <div style="margin-bottom: 30px;">
            <h2 style="color: #2c3e50; border-bottom: 2px solid #e9ecef; padding-bottom: 10px;">
              Comparaison ${previousYear} vs ${currentYear}
            </h2>
            <p><strong></strong> Tous les montants sont exprimés en Ariary (Ar).</p>
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
                  <td style="padding: 12px; border: 1px solid #dee2e6;">Coût par élève</td>
                  <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                    ${formatMoney(coutFonctionnement?.cout_fonctionnement_par_eleve?.valeur)}
                  </td>
                  <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                    ${formatMoney(previousYearData?.coutFonctionnement?.cout_fonctionnement_par_eleve?.valeur)}
                  </td>
                  <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                    ${formatMoney(comparisons?.coutFonctionnement?.evolution)}
                  </td>
                  <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                    ${comparisons?.coutFonctionnement?.percentage}%
                  </td>
                </tr>
                
                <tr>
                  <td style="padding: 12px; border: 1px solid #dee2e6;">CA par élève</td>
                  <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                    ${formatMoney(chiffreAffaires?.chiffre_affaires_par_eleve?.valeur)}
                  </td>
                  <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                    ${formatMoney(previousYearData?.chiffreAffaires?.chiffre_affaires_par_eleve?.valeur)}
                  </td>
                  <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                    ${formatMoney(comparisons?.chiffreAffaires?.evolution)}
                  </td>
                  <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                    ${comparisons?.chiffreAffaires?.percentage}%
                  </td>
                </tr>
                
                <tr>
                  <td style="padding: 12px; border: 1px solid #dee2e6;">Part masse salariale</td>
                  <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                    ${formatPercentage(partMasseSalariale?.part_masse_salariale_enseignante?.valeur)}
                  </td>
                  <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                    ${formatPercentage(previousYearData?.partMasseSalariale?.part_masse_salariale_enseignante?.valeur)}
                  </td>
                  <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                    ${formatPercentage(comparisons?.partMasseSalariale?.evolution)}
                  </td>
                  <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                    ${comparisons?.partMasseSalariale?.percentage}%
                  </td>
                </tr>
                
                <tr>
                  <td style="padding: 12px; border: 1px solid #dee2e6;">Marge par élève</td>
                  <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                    ${formatMoney(margeParEleve?.marge_par_eleve?.valeur)}
                  </td>
                  <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                    ${formatMoney(previousYearData?.margeParEleve?.marge_par_eleve?.valeur)}
                  </td>
                  <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                    ${formatMoney(comparisons?.margeParEleve?.evolution)}
                  </td>
                  <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                    ${comparisons?.margeParEleve?.percentage}%
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
          
        </div>
        
        <!-- Page 2: Détails du coût par élève -->
        <div style="page-break-after: always; padding: 20px;">
          <div style="text-align: center; margin-bottom: 30px;">
            <h2 style="color: #2c3e50; margin-bottom: 10px;">Détails du Coût par Élève</h2>
            <p style="color: #6c757d;">Exercice ${currentYear}</p>
          </div>
          
          <div style="margin-bottom: 15px;">
            <p style="color: #495057; font-style: italic;">
              ${coutFonctionnement?.cout_fonctionnement_par_eleve?.definition || "Détail du coût de fonctionnement par élève"}
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
                <td style="padding: 12px; border: 1px solid #dee2e6;">Charges d'exploitation</td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${formatMoney(coutFonctionnement?.details_calcul?.total_charges_exploitation)}
                </td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${formatMoney(previousYearData?.coutFonctionnement?.details_calcul?.total_charges_exploitation)}
                </td>
              </tr>
              
              <tr>
                <td style="padding: 12px; border: 1px solid #dee2e6;">Effectif élèves</td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${coutFonctionnement?.details_calcul?.effectif_eleves || 'N/A'}
                </td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${previousYearData?.coutFonctionnement?.details_calcul?.effectif_eleves || 'N/A'}
                </td>
              </tr>
            </tbody>
            <tfoot>
              <tr style="background-color: #f1f3f4;">
                <td style="padding: 12px; border: 1px solid #dee2e6; font-weight: bold;">Coût par élève</td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6; font-weight: bold;">
                  ${formatMoney(coutFonctionnement?.cout_fonctionnement_par_eleve?.valeur)}
                </td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6; font-weight: bold;">
                  ${formatMoney(previousYearData?.coutFonctionnement?.cout_fonctionnement_par_eleve?.valeur)}
                </td>
              </tr>
              <tr>
                <td colspan="3" style="padding: 12px; border: 1px solid #dee2e6; font-style: italic;">
                  <strong>Formule :</strong> ${coutFonctionnement?.formule || "Charges d'exploitation / Effectif élèves"}
                </td>
              </tr>
            </tfoot>
          </table>
        </div>
        
        <!-- Page 3: Détails du CA par élève -->
        <div style="page-break-after: always; padding: 20px;">
          <div style="text-align: center; margin-bottom: 30px;">
            <h2 style="color: #2c3e50; margin-bottom: 10px;">Détails du Chiffre d'Affaires par Élève</h2>
            <p style="color: #6c757d;">Exercice ${currentYear}</p>
          </div>
          
          <div style="margin-bottom: 15px;">
            <p style="color: #495057; font-style: italic;">
              ${chiffreAffaires?.chiffre_affaires_par_eleve?.definition || "Détail du chiffre d'affaires par élève"}
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
                  ${formatMoney(chiffreAffaires?.details_calcul?.total_produits_exploitation)}
                </td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${formatMoney(previousYearData?.chiffreAffaires?.details_calcul?.total_produits_exploitation)}
                </td>
              </tr>
              
              <tr>
                <td style="padding: 12px; border: 1px solid #dee2e6;">Effectif élèves</td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${chiffreAffaires?.details_calcul?.effectif_eleves || 'N/A'}
                </td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${previousYearData?.chiffreAffaires?.details_calcul?.effectif_eleves || 'N/A'}
                </td>
              </tr>
            </tbody>
            <tfoot>
              <tr style="background-color: #f1f3f4;">
                <td style="padding: 12px; border: 1px solid #dee2e6; font-weight: bold;">CA par élève</td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6; font-weight: bold;">
                  ${formatMoney(chiffreAffaires?.chiffre_affaires_par_eleve?.valeur)}
                </td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6; font-weight: bold;">
                  ${formatMoney(previousYearData?.chiffreAffaires?.chiffre_affaires_par_eleve?.valeur)}
                </td>
              </tr>
              <tr>
                <td colspan="3" style="padding: 12px; border: 1px solid #dee2e6; font-style: italic;">
                  <strong>Formule :</strong> ${chiffreAffaires?.formule || "Produits d'exploitation / Effectif élèves"}
                </td>
              </tr>
            </tfoot>
          </table>
        </div>
        
        <!-- Page 4: Détails de la part masse salariale -->
        <div style="page-break-after: always; padding: 20px;">
          <div style="text-align: center; margin-bottom: 30px;">
            <h2 style="color: #2c3e50; margin-bottom: 10px;">Détails de la Part Masse Salariale</h2>
            <p style="color: #6c757d;">Exercice ${currentYear}</p>
          </div>
          
          <div style="margin-bottom: 15px;">
            <p style="color: #495057; font-style: italic;">
              ${partMasseSalariale?.part_masse_salariale_enseignante?.definition || "Détail de la part de la masse salariale enseignante"}
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
                <td style="padding: 12px; border: 1px solid #dee2e6;">Masse salariale enseignante</td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${formatMoney(partMasseSalariale?.details_calcul?.masse_salariale_enseignante)}
                </td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${formatMoney(previousYearData?.partMasseSalariale?.details_calcul?.masse_salariale_enseignante)}
                </td>
              </tr>
              
              <tr>
                <td style="padding: 12px; border: 1px solid #dee2e6;">Total charges</td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${formatMoney(partMasseSalariale?.details_calcul?.total_charges)}
                </td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${formatMoney(previousYearData?.partMasseSalariale?.details_calcul?.total_charges)}
                </td>
              </tr>
            </tbody>
            <tfoot>
              <tr style="background-color: #f1f3f4;">
                <td style="padding: 12px; border: 1px solid #dee2e6; font-weight: bold;">Part masse salariale</td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6; font-weight: bold;">
                  ${formatPercentage(partMasseSalariale?.part_masse_salariale_enseignante?.valeur)}
                </td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6; font-weight: bold;">
                  ${formatPercentage(previousYearData?.partMasseSalariale?.part_masse_salariale_enseignante?.valeur)}
                </td>
              </tr>
              <tr>
                <td colspan="3" style="padding: 12px; border: 1px solid #dee2e6; font-style: italic;">
                  <strong>Formule :</strong> ${partMasseSalariale?.formule || "(Masse salariale enseignante / Total charges) × 100"}
                </td>
              </tr>
            </tfoot>
          </table>
        </div>
        
        <!-- Page 5: Détails de la marge par élève -->
        <div style="padding: 20px;">
          <div style="text-align: center; margin-bottom: 30px;">
            <h2 style="color: #2c3e50; margin-bottom: 10px;">Détails de la Marge par Élève</h2>
            <p style="color: #6c757d;">Exercice ${currentYear}</p>
          </div>
          
          <div style="margin-bottom: 15px;">
            <p style="color: #495057; font-style: italic;">
              ${margeParEleve?.marge_par_eleve?.definition || "Détail de la marge par élève"}
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
                  ${formatMoney(margeParEleve?.details_calcul?.resultat_net)}
                </td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${formatMoney(previousYearData?.margeParEleve?.details_calcul?.resultat_net)}
                </td>
              </tr>
              
              <tr>
                <td style="padding: 12px; border: 1px solid #dee2e6;">Effectif élèves</td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${margeParEleve?.details_calcul?.effectif_eleves || 'N/A'}
                </td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                  ${previousYearData?.margeParEleve?.details_calcul?.effectif_eleves || 'N/A'}
                </td>
              </tr>
            </tbody>
            <tfoot>
              <tr style="background-color: #f1f3f4;">
                <td style="padding: 12px; border: 1px solid #dee2e6; font-weight: bold;">Marge par élève</td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6; font-weight: bold;">
                  ${formatMoney(margeParEleve?.marge_par_eleve?.valeur)}
                </td>
                <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6; font-weight: bold;">
                  ${formatMoney(previousYearData?.margeParEleve?.marge_par_eleve?.valeur)}
                </td>
              </tr>
              <tr>
                <td colspan="3" style="padding: 12px; border: 1px solid #dee2e6; font-style: italic;">
                  <strong>Formule :</strong> ${margeParEleve?.formule || "Résultat net / Effectif élèves"}
                </td>
              </tr>
            </tfoot>
          </table>
          
          <div style="margin-top: 40px; padding-top: 20px; border-top: 2px solid #e9ecef; color: #6c757d; font-size: 12px; text-align: center;">
            <p>--- Fin du rapport pédagogique ---</p>
            <p>Document généré automatiquement par le système de gestion pédagogique.</p>
          </div>
        </div>
      </div>
    `;
  };

  // Générer le contenu PDF pour les indicateurs généraux
  const generateGeneralPDFContent = (data) => {
    // Implémentation similaire pour les indicateurs généraux
    // (vous pouvez l'ajouter ici)
    return '';
  };

  // Fonction principale pour exporter en PDF
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

  // Fonction spécifique pour les indicateurs pédagogiques
  const exportPedagogiquePDF = (data, loading = false) => {
    const filename = `rapport-pedagogique-${data.exercice?.Annee_fiscale || 'non-specifie'}.pdf`;
    return exportToPDF(generatePedagogiquePDFContent, data, filename, loading);
  };

  // Fonction spécifique pour les indicateurs généraux
  const exportGeneralPDF = (data, loading = false) => {
    const filename = `rapport-generaux-${data.exercice?.Annee_fiscale || 'non-specifie'}.pdf`;
    return exportToPDF(generateGeneralPDFContent, data, filename, loading);
  };

  return {
    formatMoney,
    formatPercentage,
    generatePedagogiquePDFContent,
    generateGeneralPDFContent,
    exportToPDF,
    exportPedagogiquePDF,
    exportGeneralPDF
  };
};
