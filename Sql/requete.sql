-- affichage des couts centre

SELECT ca.nom AS centre,
       SUM(le."Debit" - le."Credit") AS montant,
       ROUND(
    SUM(le."Debit" - le."Credit") * 100.0
    / NULLIF(SUM(SUM(le."Debit" - le."Credit")) OVER (), 0),
    2
  )                                       AS pourcentage
FROM Ligne_ecritures le
JOIN AffectationAnalytique aa ON le."Id_Sous_compte" = aa."Id_Sous_compte"
JOIN CentreAnalytique ca ON aa.id_centre = ca.id_centre
GROUP BY ca.nom;

-- affichage des pourcentages et repartitions de couts en details

SELECT
  aa.description                                 AS centre,
  SUM(le."Debit" - le."Credit")               AS montant,
  ROUND(
    SUM(le."Debit" - le."Credit") * 100.0
    / NULLIF(SUM(SUM(le."Debit" - le."Credit")) OVER (), 0),
    2
  )                                       AS pourcentage
FROM ligne_ecritures le
JOIN affectationanalytique aa
  ON le."Id_Sous_compte" = aa."Id_Sous_compte"
JOIN centreanalytique ca
  ON aa.id_centre = ca.id_centre
JOIN mouvement_ecritures me
  ON le."Id_Mouvement_ecriture" = me."Id_Mouvement_ecriture"
WHERE me."Date_mouvement" BETWEEN DATE '2025-01-01' AND DATE '2025-12-31'
GROUP BY aa.description
ORDER BY montant DESC;