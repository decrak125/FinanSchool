// utils/pdfTemplates.js

export function exportEtatPDF({
  titre,
  periode,
  detailsDroite,
  colonnes,
  lignes,
  totaux,
  fileName,
  getLogoBase64
}) {
  const doc = new jsPDF({ orientation: 'portrait', unit: 'mm', format: 'a4' });

  // Ajout du logo
  const logoBase64 = getLogoBase64();
  doc.addImage(logoBase64, 'PNG', 10, 8, 30, 20);

  // Identité de la société à gauche
  doc.setFont('helvetica', 'bold');
  doc.setFontSize(14);
  doc.text('RAITRA KIDZ', 45, 16);
  doc.setFont('helvetica', 'normal');
  doc.setFontSize(10);
  doc.text('Adresse : Lot II M...', 45, 21);
  doc.text('Téléphone : +261 xx xx xx xx', 45, 26);
  doc.text('Email : contact@raitrakidz.mg', 45, 31);

  // Titre
  doc.setFont('helvetica', 'bold');
  doc.setFontSize(18);
  doc.text(titre, 105, 18, { align: 'center' });

  // Détails à droite (flexible)
  doc.setFont('helvetica', 'normal');
  doc.setFontSize(10);
  let rightY = 15;
  detailsDroite.forEach(line => {
    doc.text(line, 150, rightY);
    rightY += 6;
  });

  // Dates
  const now = new Date();
  doc.text(`Date de tirage : ${now.toLocaleDateString('fr-FR')} ${now.toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit', second: '2-digit' })}`, 10, 38);
  doc.text(`Période : ${periode}`, 10, 43);

  // Tableau
  autoTable(doc, {
    startY: 55,
    theme: 'grid',
    head: [colonnes],
    body: lignes,
    foot: [totaux],
    styles: {
      fontSize: 9,
      cellPadding: 2,
      textColor: [35, 35, 35],
      lineColor: [180, 180, 180],
      lineWidth: 0.1,
      fillColor: [250, 250, 250],
    },
    headStyles: {
      fillColor: [41, 128, 185],
      textColor: [255, 255, 255],
      fontStyle: 'bold',
      lineWidth: 0.3,
      lineColor: [41, 128, 185],
      halign: 'center',
    },
    alternateRowStyles: {
      fillColor: [245, 245, 255],
    },
    footStyles: {
      fillColor: [41, 128, 185],
      textColor: [255, 255, 255],
      fontStyle: 'bold',
      lineWidth: 0.3,
      lineColor: [41, 128, 185],
    },
    columnStyles: {
      3: { halign: 'right' },
      4: { halign: 'right' },
      5: { halign: 'right' }
    },
    margin: { top: 55, left: 10, right: 10, bottom: 25 },
    didDrawPage: (data) => {
      const pageCount = doc.internal.getNumberOfPages();
      for (let i = 1; i <= pageCount; i++) {
        doc.setPage(i);
        doc.setFontSize(10);
        doc.setTextColor(120, 120, 120);
        const pageStr = `Page : ${i}`;
        doc.text(pageStr, 190, 20);
        doc.setFontSize(9);
        doc.text(`RAITRA KIDZ © ${now.getFullYear()} | Impression provisoire`, 10, 290);
      }
    },
  });

  doc.save(`${fileName}_${now.toISOString().split('T')[0]}.pdf`);
}
