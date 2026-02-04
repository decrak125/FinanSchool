import html2pdf from 'html2pdf.js'
import * as XLSX from 'xlsx-js-style'
import axios from 'axios'

export const useExport = () => {
  // Formatage des montants
  const formatMontant = (montant) => {
    return new Intl.NumberFormat('fr-FR', {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2
    }).format(montant)
  }

  // Récupérer les données de l'API
  const getDonneesExport = async (annee) => {
    try {
      console.log(`Récupération données pour l'année: ${annee}`)
      const response = await axios.get(`http://localhost:8000/api/export/donnees/${annee}`)
      
      console.log('Réponse API:', response.data)
      
      if (!response.data.success) {
        throw new Error(response.data.message || 'Erreur API')
      }
      return response.data.data
    } catch (error) {
      console.error('Erreur récupération données:', error)
      throw new Error(error.response?.data?.message || error.message || 'Erreur de connexion au serveur')
    }
  }

  // Vérifier les données avant de générer le PDF
  const verifierDonnees = (data) => {
    console.log('Données reçues pour PDF:', data)
    
    if (!data) {
      throw new Error('Aucune donnée reçue')
    }
    
    if (!data.metadata) {
      throw new Error('Données metadata manquantes')
    }
    
    if (!data.tableau_couts_profits || !data.tableau_indicateurs) {
      throw new Error('Structure des données incorrecte')
    }
    
    console.log(`Tableau coûts-profits: ${data.tableau_couts_profits.lignes?.length || 0} lignes`)
    console.log(`Tableau indicateurs: ${data.tableau_indicateurs.lignes?.length || 0} lignes`)
    
    return true
  }

  // Fonction TEST: Prévisualiser le HTML dans le navigateur
  const previsualiserHTML = (htmlContent) => {
    const newWindow = window.open()
    newWindow.document.write(htmlContent)
    newWindow.document.close()
  }

  // Exporter en PDF - VERSION SIMPLIFIÉE POUR DÉBOGAGE
  const exporterPDF = async (annee, onMessage) => {
    console.log(`Début export PDF pour: ${annee}`)
    
    if (!annee) {
      onMessage('Veuillez sélectionner une année d\'exercice', 'error')
      return
    }

    try {
      onMessage('Récupération des données...', 'info')
      
      // 1. Récupérer les données
      const data = await getDonneesExport(annee)
      
      // 2. Vérifier les données
      verifierDonnees(data)
      
      onMessage('Génération du contenu...', 'info')
      
      // 3. Générer un HTML SIMPLE pour test
      const htmlContent = genererHTMLSimple(data)
      
      console.log('HTML généré (premiers 500 caractères):', htmlContent.substring(0, 500))
      
      // 4. TEST: Ouvrir le HTML dans un nouvel onglet pour voir s'il s'affiche
      // previsualiserHTML(htmlContent)
      // onMessage('HTML généré dans un nouvel onglet', 'info')
      // return
      
      // 5. Créer un élément temporaire VISIBLE pour test
      const element = document.createElement('div')
      element.style.position = 'fixed'
      element.style.top = '10px'
      element.style.left = '10px'
      element.style.width = '800px'
      element.style.height = '600px'
      element.style.backgroundColor = 'white'
      element.style.border = '2px solid red'
      element.style.zIndex = '9999'
      element.style.padding = '20px'
      element.style.overflow = 'auto'
      element.innerHTML = htmlContent
      document.body.appendChild(element)
      
      // Attendre un peu pour voir
      await new Promise(resolve => setTimeout(resolve, 1000))
      
      // 6. Options SIMPLES pour html2pdf
      const options = {
        margin: 10,
        filename: `diagnostic-${annee}.pdf`,
        image: { 
          type: 'jpeg', 
          quality: 0.98 
        },
        html2canvas: { 
          scale: 2,
          useCORS: true,
          logging: true, // Activer les logs
          letterRendering: true
        },
        jsPDF: { 
          unit: 'mm', 
          format: 'a4', 
          orientation: 'portrait' // TEST en portrait d'abord
        }
      }
      
      onMessage('Génération du PDF...', 'info')
      
      // 7. Générer le PDF
      console.log('Début génération PDF avec html2pdf')
      await html2pdf().set(options).from(element).save()
      
      console.log('PDF généré avec succès')
      onMessage(`PDF généré pour ${annee} !`, 'success')
      
      // 8. Supprimer l'élément temporaire après un délai
      setTimeout(() => {
        if (element.parentNode) {
          document.body.removeChild(element)
        }
      }, 2000)
      
    } catch (error) {
      console.error('Erreur complète export PDF:', error)
      onMessage(`Erreur: ${error.message}`, 'error')
    }
  }

  // Générer un HTML SIMPLE pour test
  const genererHTMLSimple = (data) => {
    const { metadata, tableau_couts_profits } = data
    
    return `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <title>Test PDF</title>
        <style>
          body { font-family: Arial; font-size: 12px; padding: 20px; }
          h1 { color: #2C3E50; }
          table { border-collapse: collapse; width: 100%; margin-top: 20px; }
          th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
          th { background-color: #f2f2f2; }
          .header { text-align: center; margin-bottom: 30px; }
        </style>
      </head>
      <body>
        <div class="header">
          <h1>DIAGNOSTIC FINANCIER - TEST</h1>
          <h2>Année: ${metadata?.annee_exercice || 'N/A'}</h2>
          <p>Date: ${new Date().toLocaleDateString()}</p>
        </div>
        
        <h3>Tableau des Centres (${tableau_couts_profits.lignes?.length || 0} centres)</h3>
        <table>
          <thead>
            <tr>
              <th>Centre</th>
              <th>Charges</th>
              <th>Produits</th>
              <th>Marge</th>
            </tr>
          </thead>
          <tbody>
            ${(tableau_couts_profits.lignes || []).slice(0, 5).map(centre => `
              <tr>
                <td>${centre.nom || 'N/A'}</td>
                <td>${formatMontant(centre.charges || 0)}</td>
                <td>${formatMontant(centre.produits || 0)}</td>
                <td>${formatMontant(centre.marge || 0)}</td>
              </tr>
            `).join('')}
          </tbody>
        </table>
        
        <div style="margin-top: 50px; font-size: 10px; color: #666;">
          <p>Ceci est un test de génération PDF</p>
          <p>Données valides: ${data ? 'OUI' : 'NON'}</p>
          <p>Nombre de centres: ${tableau_couts_profits.lignes?.length || 0}</p>
        </div>
      </body>
      </html>
    `
  }

  // Exporter en Excel (inchangé)
  const exporterExcel = async (annee, onMessage) => {
    console.log(`Début export Excel pour: ${annee}`)
    
    if (!annee) {
      onMessage('Veuillez sélectionner une année d\'exercice', 'error')
      return
    }

    try {
      onMessage('Génération du fichier Excel...', 'info')
      
      const data = await getDonneesExport(annee)
      verifierDonnees(data)
      
      // Créer un nouveau classeur
      const wb = XLSX.utils.book_new()
      
      // Feuille simple pour test
      const wsData = [
        ['DIAGNOSTIC FINANCIER', data.metadata.annee_exercice],
        [''],
        ['Centre', 'Charges', 'Produits', 'Marge']
      ]
      
      // Ajouter quelques lignes
      data.tableau_couts_profits.lignes.slice(0, 10).forEach(centre => {
        wsData.push([
          centre.nom,
          centre.charges,
          centre.produits,
          centre.marge
        ])
      })
      
      const ws = XLSX.utils.aoa_to_sheet(wsData)
      XLSX.utils.book_append_sheet(wb, ws, 'Diagnostic')
      
      // Générer le fichier
      const fileName = `diagnostic-${annee}.xlsx`
      XLSX.writeFile(wb, fileName)
      
      onMessage(`Excel généré pour ${annee} !`, 'success')
      
    } catch (error) {
      console.error('Erreur export Excel:', error)
      onMessage(`Erreur: ${error.message}`, 'error')
    }
  }

  return {
    getDonneesExport,
    exporterPDF,
    exporterExcel
  }
}