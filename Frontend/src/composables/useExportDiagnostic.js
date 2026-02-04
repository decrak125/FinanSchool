import { ref } from 'vue'
import axios from 'axios'
import html2pdf from 'html2pdf.js'
import * as XLSX from 'xlsx-js-style'

export const useExportDiagnostic = () => {
  const API_URL = "http://127.0.0.1:8000/api"
  const loading = ref(false)
  const message = ref('')

  // Récupérer les données
  const getDonneesExport = async (anneeExercice) => {
    try {
      console.log(`Récupération données export pour: ${anneeExercice}`)
      
      const response = await axios.get(`${API_URL}/export/donnees/${anneeExercice}`)
      
      console.log('Réponse export API:', response.data)
      
      if (!response.data.success) {
        throw new Error(response.data.message || 'Erreur API export')
      }
      
      return response.data.data
      
    } catch (error) {
      console.error('Erreur récupération données export:', error)
      throw new Error(error.response?.data?.message || error.message || 'Erreur de connexion')
    }
  }

  // Formatage monétaire (comme dans useExportPedagogie)
  const formatMontant = (montant) => {
    if (montant === null || montant === undefined) return '';
    return new Intl.NumberFormat('fr-FR', {
      minimumFractionDigits: 0,
      maximumFractionDigits: 0
    }).format(montant);
  }

  // Formater les pourcentages (comme dans useExportPedagogie)
  const formatPourcentage = (valeur) => {
    if (valeur === null || valeur === undefined) return '';
    return `${parseFloat(valeur).toFixed(2)}%`;
  }

  // Générer le contenu PDF dans le style de useExportPedagogie
  const genererHTMLPDF = (data) => {
    const { metadata, tableau_couts_profits, tableau_indicateurs } = data
    const currentYear = metadata.annee_exercice || '';
    const dateGeneration = new Date().toLocaleDateString('fr-FR');

    // Fonction pour obtenir la classe CSS du niveau (simplifiée)
    const getClasseNiveau = (niveau) => {
      if (!niveau) return '';
      const niveauStr = (niveau.libelle || niveau).toString().toLowerCase();
      
      if (niveauStr.includes('faible') || niveauStr.includes('mauvais') || niveauStr.includes('dangereux')) {
        return 'color: #dc3545; font-weight: bold;';
      } else if (niveauStr.includes('moyen') || niveauStr.includes('attention') || niveauStr.includes('alerte')) {
        return 'color: #ffc107; font-weight: bold;';
      } else if (niveauStr.includes('bon') || niveauStr.includes('satisfaisant') || niveauStr.includes('optimal')) {
        return 'color: #28a745; font-weight: bold;';
      } else if (niveauStr.includes('très bon') || niveauStr.includes('excellent')) {
        return 'color: #007bff; font-weight: bold;';
      }
      return 'color: #6c757d; font-weight: bold;';
    }

    return `
      <div style="font-family: Arial, sans-serif;">
        <!-- Page 1: Entête et tableau coûts-profits -->
        <div style="page-break-after: always; padding: 20px;">
          <div style="text-align: center; margin-bottom: 30px;">
            <h1 style="color: #2c3e50; margin-bottom: 5px;">DIAGNOSTIC FINANCIER</h1>
            <h3 style="color: #6c757d;">Année d'exercice : ${currentYear}</h3>
            <p style="color: #888;">Généré le ${dateGeneration} | Période : ${metadata.date_periode}</p>
          </div>
          
          <div style="margin-bottom: 30px;">
            <h2 style="color: #2c3e50; border-bottom: 2px solid #e9ecef; padding-bottom: 10px;">
              TABLEAU 1 : COÛTS ET PROFITS PAR CENTRE ANALYTIQUE
            </h2>
            
            <table style="width: 100%; border-collapse: collapse; margin-top: 20px;">
              <thead>
                <tr style="background-color: #f8f9fa;">
                  <th style="padding: 12px; text-align: left; border: 1px solid #dee2e6;">Centre Analytique</th>
                  <th style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">Charges (Ar)</th>
                  <th style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">Produits (Ar)</th>
                  <th style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">Marge (Ar)</th>
                  <th style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">Marge %</th>
                </tr>
              </thead>
              <tbody>
                ${tableau_couts_profits.lignes.map(centre => `
                  <tr>
                    <td style="padding: 12px; border: 1px solid #dee2e6;">${centre.nom || 'Non spécifié'}</td>
                    <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                      ${formatMontant(centre.charges)}
                    </td>
                    <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6;">
                      ${formatMontant(centre.produits)}
                    </td>
                    <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6; ${centre.marge >= 0 ? 'color: #28a745; font-weight: bold;' : 'color: #dc3545; font-weight: bold;'}">
                      ${formatMontant(centre.marge)}
                    </td>
                    <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6; ${centre.pourcentage_marge >= 0 ? 'color: #28a745; font-weight: bold;' : 'color: #dc3545; font-weight: bold;'}">
                      ${Math.abs(centre.pourcentage_marge).toFixed(2)}%
                    </td>
                  </tr>
                `).join('')}
              </tbody>
              <tfoot>
                <tr style="background-color: #f1f3f4;">
                  <td style="padding: 12px; border: 1px solid #dee2e6; font-weight: bold;">TOTAL GÉNÉRAL</td>
                  <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6; font-weight: bold;">
                    ${formatMontant(tableau_couts_profits.totaux.charges)}
                  </td>
                  <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6; font-weight: bold;">
                    ${formatMontant(tableau_couts_profits.totaux.produits)}
                  </td>
                  <td style="padding: 12px; text-align: right; border: 1px solid #dee2e6; font-weight: bold; ${tableau_couts_profits.totaux.marge >= 0 ? 'color: #28a745;' : 'color: #dc3545;'}">
                    ${formatMontant(tableau_couts_profits.totaux.marge)}
                  </td>
                  <td style="padding: 12px; border: 1px solid #dee2e6;"></td>
                </tr>
              </tfoot>
            </table>
          </div>
          
          <div style="margin-top: 40px; padding-top: 20px; border-top: 2px solid #e9ecef; color: #6c757d; font-size: 12px; text-align: center;">
            <p>--- Page 1 sur 2 ---</p>
            <p>Document généré automatiquement par le système de diagnostic financier.</p>
          </div>
        </div>
        
        <!-- Page 2: Tableau indicateurs -->
        <div style="padding: 20px;">
          <div style="text-align: center; margin-bottom: 30px;">
            <h1 style="color: #2c3e50; margin-bottom: 5px;">DIAGNOSTIC FINANCIER</h1>
            <h3 style="color: #6c757d;">Année d'exercice : ${currentYear}</h3>
            <p style="color: #888;">Indicateurs financiers par aspect</p>
          </div>
          
          <div style="margin-bottom: 30px;">
            <h2 style="color: #2c3e50; border-bottom: 2px solid #e9ecef; padding-bottom: 10px;">
              TABLEAU 2 : INDICATEURS FINANCIERS PAR ASPECT
            </h2>
            
            ${Object.entries(tableau_indicateurs.groupes || {}).map(([aspect, indicateurs]) => {
              if (!indicateurs || indicateurs.length === 0) return '';
              
              return `
                <div style="margin-top: 25px; margin-bottom: 20px;">
                  <h3 style="color: #495057; background-color: #e9ecef; padding: 10px 15px; border-radius: 4px;">
                    ${aspect.toUpperCase()}
                  </h3>
                  
                  <table style="width: 100%; border-collapse: collapse; margin-top: 15px;">
                    <thead>
                      <tr style="background-color: #f8f9fa;">
                        <th style="padding: 10px; text-align: left; border: 1px solid #dee2e6;">Indicateur</th>
                        <th style="padding: 10px; text-align: right; border: 1px solid #dee2e6;">Valeur</th>
                        <th style="padding: 10px; text-align: left; border: 1px solid #dee2e6;">Interprétation</th>
                        <th style="padding: 10px; text-align: center; border: 1px solid #dee2e6;">Niveau</th>
                      </tr>
                    </thead>
                    <tbody>
                      ${indicateurs.map(indic => {
                        const valeurFormat = indic.unite === '%' 
                          ? formatPourcentage(indic.valeur)
                          : indic.unite === 'Ar'
                            ? formatMontant(indic.valeur) + ' Ar'
                            : indic.unite === 'années'
                              ? indic.valeur.toFixed(2) + ' années'
                              : formatMontant(indic.valeur);
                        
                        const niveauLibelle = indic.niveau_alerte?.libelle || indic.niveau_alerte || '';
                        
                        return `
                          <tr>
                            <td style="padding: 10px; border: 1px solid #dee2e6;">${indic.nom}</td>
                            <td style="padding: 10px; text-align: right; border: 1px solid #dee2e6; font-weight: bold;">
                              ${valeurFormat}
                            </td>
                            <td style="padding: 10px; border: 1px solid #dee2e6;">
                              ${indic.interpretation || ''}
                            </td>
                            <td style="padding: 10px; text-align: center; border: 1px solid #dee2e6;">
                              ${niveauLibelle ? `<span style="${getClasseNiveau(indic.niveau_alerte)}">${niveauLibelle}</span>` : ''}
                            </td>
                          </tr>
                        `;
                      }).join('')}
                    </tbody>
                  </table>
                </div>
              `;
            }).join('')}
          </div>
          
          <div style="margin-top: 40px; padding-top: 20px; border-top: 2px solid #e9ecef; color: #6c757d; font-size: 12px; text-align: center;">
            <p>--- Page 2 sur 2 ---</p>
            <p>Document généré automatiquement par le système de diagnostic financier.</p>
            <p style="font-size: 11px; margin-top: 10px;">
              Exercice : ${metadata.exercice.annee_fiscale} | 
              ID : ${metadata.exercice.id} | 
              Version : 1.0
            </p>
          </div>
        </div>
      </div>
    `
  }

  // Exporter en PDF (simplifié comme dans useExportPedagogie)
  const exporterPDF = async (anneeExercice, onMessage) => {
    if (!anneeExercice) {
      onMessage('Veuillez sélectionner une année d\'exercice', 'error')
      return
    }

    loading.value = true
    onMessage('Préparation des données...', 'info')

    try {
      // 1. Récupérer les données
      const data = await getDonneesExport(anneeExercice)
      onMessage('Génération du PDF...', 'info')
      
      // 2. Générer le HTML
      const htmlContent = genererHTMLPDF(data)
      
      // 3. Créer un élément DIV (comme dans useExportPedagogie)
      const element = document.createElement('div')
      element.innerHTML = htmlContent
      
      // 4. Configuration html2pdf optimisée
      const options = {
        margin: [15, 15, 15, 15],
        filename: `diagnostic-financier-${anneeExercice}.pdf`,
        image: { 
          type: 'jpeg', 
          quality: 0.98 
        },
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
      }
      
      // 5. Générer le PDF
      console.log('Début génération PDF...')
      
      // Ajouter temporairement au DOM
      document.body.appendChild(element)
      
      await html2pdf()
        .set(options)
        .from(element)
        .save()
        .then(() => {
          console.log('PDF généré avec succès!')
          onMessage(`PDF généré pour ${anneeExercice} !`, 'success')
        })
        .catch(err => {
          console.error('Erreur html2pdf:', err)
          throw new Error('Échec de la génération PDF: ' + err.message)
        })
      
      // Nettoyer
      document.body.removeChild(element)
      
    } catch (error) {
      console.error('Erreur export PDF:', error)
      onMessage(`Erreur: ${error.message}`, 'error')
    } finally {
      loading.value = false
    }
  }

  // Exporter en Excel (inchangée mais adaptée au nouveau format)
  const exporterExcel = async (anneeExercice, onMessage) => {
    if (!anneeExercice) {
      onMessage('Veuillez sélectionner une année d\'exercice', 'error')
      return
    }

    loading.value = true
    onMessage('Génération du fichier Excel...', 'info')

    try {
      const data = await getDonneesExport(anneeExercice)
      
      const wb = XLSX.utils.book_new()
      
      // Feuille 1: Coûts et Profits
      const ws1Data = [
        [`DIAGNOSTIC FINANCIER - ${data.metadata.annee_exercice}`],
        [`Période: ${data.metadata.date_periode}`],
        [`Généré le: ${data.metadata.date_generation}`],
        [''],
        ['TABLEAU 1 : COÛTS ET PROFITS PAR CENTRE ANALYTIQUE'],
        ['']
      ]
      
      ws1Data.push(['Centre', 'Charges (Ar)', 'Produits (Ar)', 'Marge (Ar)', 'Marge (%)'])
      
      data.tableau_couts_profits.lignes.forEach(centre => {
        ws1Data.push([
          centre.nom,
          centre.charges,
          centre.produits,
          centre.marge,
          centre.pourcentage_marge / 100
        ])
      })
      
      ws1Data.push([''])
      ws1Data.push([
        'TOTAL',
        data.tableau_couts_profits.totaux.charges,
        data.tableau_couts_profits.totaux.produits,
        data.tableau_couts_profits.totaux.marge,
        ''
      ])
      
      const ws1 = XLSX.utils.aoa_to_sheet(ws1Data)
      
      // Feuille 2: Indicateurs
      const ws2Data = [
        [`INDICATEURS FINANCIERS - ${data.metadata.annee_exercice}`],
        ['']
      ]
      
      ws2Data.push(['Aspect', 'Indicateur', 'Valeur', 'Unité', 'Interprétation', 'Niveau'])
      
      const groupes = ['Rentabilité', 'Solvabilité', 'Liquidité', 'Pédagogique']
      groupes.forEach(aspect => {
        const indicateurs = data.tableau_indicateurs.groupes[aspect] || []
        if (indicateurs.length > 0) {
          ws2Data.push([aspect, '', '', '', '', ''])
          indicateurs.forEach(indic => {
            ws2Data.push([
              '',
              indic.nom,
              indic.valeur,
              indic.unite,
              indic.interpretation,
              indic.niveau_alerte?.libelle || ''
            ])
          })
          ws2Data.push([''])
        }
      })
      
      const ws2 = XLSX.utils.aoa_to_sheet(ws2Data)
      
      // Styles
      const applyStyles = (ws) => {
        if (!ws['!ref']) return
        
        const range = XLSX.utils.decode_range(ws['!ref'])
        
        for (let R = range.s.r; R <= range.e.r; R++) {
          for (let C = range.s.c; C <= range.e.c; C++) {
            const cell = XLSX.utils.encode_cell({ r: R, c: C })
            
            if (!ws[cell]) continue
            
            ws[cell].s = {
              font: { sz: 11 },
              alignment: { vertical: 'center' }
            }
            
            // Titres
            if (R === 0 || (ws[cell].v && typeof ws[cell].v === 'string' && ws[cell].v.includes('TABLEAU'))) {
              ws[cell].s = {
                ...ws[cell].s,
                font: { bold: true, sz: 14, color: { rgb: "2C3E50" } },
                alignment: { horizontal: 'center' }
              }
            }
          }
        }
        
        ws['!cols'] = [
          { wch: 30 },
          { wch: 25 },
          { wch: 15 },
          { wch: 10 },
          { wch: 40 },
          { wch: 15 }
        ]
      }
      
      applyStyles(ws1)
      applyStyles(ws2)
      
      XLSX.utils.book_append_sheet(wb, ws1, 'Coûts-Profits')
      XLSX.utils.book_append_sheet(wb, ws2, 'Indicateurs')
      
      const fileName = `diagnostic-financier-${anneeExercice}.xlsx`
      XLSX.writeFile(wb, fileName)
      
      onMessage(`Excel généré pour ${anneeExercice} !`, 'success')
      
    } catch (error) {
      console.error('Erreur export Excel:', error)
      onMessage(`Erreur: ${error.message}`, 'error')
    } finally {
      loading.value = false
    }
  }

  return {
    loading,
    message,
    exporterPDF,
    exporterExcel,
    getDonneesExport,
    formatMontant,
    formatPourcentage
  }
}
