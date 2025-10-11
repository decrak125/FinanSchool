-- 🔥 SUPPRESSION DES VUES EXISTANTES (si besoin de recommencer)
DROP MATERIALIZED VIEW IF EXISTS mv_analyse_mensuelle CASCADE;
DROP MATERIALIZED VIEW IF EXISTS mv_comparaison_annuelle CASCADE;
DROP MATERIALIZED VIEW IF EXISTS mv_evolution_12_mois CASCADE;
DROP MATERIALIZED VIEW IF EXISTS mv_analyse_trimestrielle CASCADE;
DROP MATERIALIZED VIEW IF EXISTS mv_stats_globales_temporelles CASCADE;

-- 🔥 VUE MATERIALISÉE POUR LA COMPARAISON MENSUELLE (CORRIGÉE)
CREATE MATERIALIZED VIEW mv_analyse_mensuelle AS
SELECT 
    EXTRACT(MONTH FROM me."Date_mouvement") as mois,
    TO_CHAR(me."Date_mouvement", 'Month') as nom_mois,
    EXTRACT(YEAR FROM me."Date_mouvement") as annee,
    ca.id_centre,
    ca.nom as centre,
    aa.id_type,
    ABS(SUM((le."Debit" - le."Credit") * (aa.taux / 100.0))) as montant_ventile,
    ABS(SUM(le."Debit" - le."Credit")) as montant_brut,
    COUNT(DISTINCT le."Id_Sous_compte") as nombre_sous_comptes,
    NOW() as date_mise_a_jour
FROM ligne_ecritures le
JOIN affectationanalytique aa ON le."Id_Sous_compte" = aa."Id_Sous_compte"
JOIN centreanalytique ca ON aa.id_centre = ca.id_centre
JOIN mouvement_ecritures me ON le."Id_Mouvement_ecriture" = me."Id_Mouvement_ecriture"
GROUP BY 
    EXTRACT(MONTH FROM me."Date_mouvement"), 
    TO_CHAR(me."Date_mouvement", 'Month'),
    EXTRACT(YEAR FROM me."Date_mouvement"),
    ca.id_centre, ca.nom, aa.id_type;

-- 🔥 INDEXES UNIQUES POUR LE RAFRAICHISSEMENT CONCURRENT
CREATE UNIQUE INDEX idx_mv_mensuelle_unique ON mv_analyse_mensuelle(annee, mois, id_centre, id_type);
CREATE INDEX idx_mv_mensuelle_annee_mois ON mv_analyse_mensuelle(annee, mois);
CREATE INDEX idx_mv_mensuelle_centre ON mv_analyse_mensuelle(id_centre);
CREATE INDEX idx_mv_mensuelle_type ON mv_analyse_mensuelle(id_type);

-- 🔥 VUE MATERIALISÉE POUR LA COMPARAISON ANNUELLE (CORRIGÉE)
CREATE MATERIALIZED VIEW mv_comparaison_annuelle AS
SELECT 
    EXTRACT(YEAR FROM me."Date_mouvement") as annee,
    ca.id_centre,
    ca.nom as centre,
    aa.id_type,
    ABS(SUM((le."Debit" - le."Credit") * (aa.taux / 100.0))) as montant_ventile,
    ABS(SUM(le."Debit" - le."Credit")) as montant_brut,
    COUNT(DISTINCT le."Id_Sous_compte") as nombre_sous_comptes,
    COUNT(DISTINCT EXTRACT(MONTH FROM me."Date_mouvement")) as mois_actifs,
    NOW() as date_mise_a_jour
FROM ligne_ecritures le
JOIN affectationanalytique aa ON le."Id_Sous_compte" = aa."Id_Sous_compte"
JOIN centreanalytique ca ON aa.id_centre = ca.id_centre
JOIN mouvement_ecritures me ON le."Id_Mouvement_ecriture" = me."Id_Mouvement_ecriture"
GROUP BY 
    EXTRACT(YEAR FROM me."Date_mouvement"),
    ca.id_centre, ca.nom, aa.id_type;

-- 🔥 INDEXES UNIQUES POUR LE RAFRAICHISSEMENT CONCURRENT
CREATE UNIQUE INDEX idx_mv_annuelle_unique ON mv_comparaison_annuelle(annee, id_centre, id_type);
CREATE INDEX idx_mv_annuelle_annee ON mv_comparaison_annuelle(annee);
CREATE INDEX idx_mv_annuelle_centre ON mv_comparaison_annuelle(id_centre);
CREATE INDEX idx_mv_annuelle_type ON mv_comparaison_annuelle(id_type);

-- 🔥 VUE MATERIALISÉE POUR L'ÉVOLUTION 12 MOIS GLISSANTS (CORRIGÉE)
CREATE MATERIALIZED VIEW mv_evolution_12_mois AS
SELECT 
    DATE_TRUNC('month', me."Date_mouvement") as mois,
    TO_CHAR(me."Date_mouvement", 'YYYY-MM') as periode,
    TO_CHAR(me."Date_mouvement", 'Month YYYY') as nom_periode,
    ca.id_centre,
    ca.nom as centre,
    aa.id_type,
    ABS(SUM((le."Debit" - le."Credit") * (aa.taux / 100.0))) as montant_ventile,
    ABS(SUM(le."Debit" - le."Credit")) as montant_brut,
    COUNT(DISTINCT le."Id_Sous_compte") as nombre_sous_comptes,
    NOW() as date_mise_a_jour
FROM ligne_ecritures le
JOIN affectationanalytique aa ON le."Id_Sous_compte" = aa."Id_Sous_compte"
JOIN centreanalytique ca ON aa.id_centre = ca.id_centre
JOIN mouvement_ecritures me ON le."Id_Mouvement_ecriture" = me."Id_Mouvement_ecriture"
WHERE me."Date_mouvement" >= CURRENT_DATE - INTERVAL '12 months'
GROUP BY 
    DATE_TRUNC('month', me."Date_mouvement"),
    TO_CHAR(me."Date_mouvement", 'YYYY-MM'),
    TO_CHAR(me."Date_mouvement", 'Month YYYY'),
    ca.id_centre, ca.nom, aa.id_type;

-- 🔥 INDEXES UNIQUES POUR LE RAFRAICHISSEMENT CONCURRENT
CREATE UNIQUE INDEX idx_mv_12mois_unique ON mv_evolution_12_mois(mois, id_centre, id_type);
CREATE INDEX idx_mv_12mois_mois ON mv_evolution_12_mois(mois);
CREATE INDEX idx_mv_12mois_centre ON mv_evolution_12_mois(id_centre);
CREATE INDEX idx_mv_12mois_type ON mv_evolution_12_mois(id_type);

-- 🔥 VUE MATERIALISÉE POUR L'ANALYSE TRIMESTRIELLE (CORRIGÉE)
CREATE MATERIALIZED VIEW mv_analyse_trimestrielle AS
SELECT 
    EXTRACT(QUARTER FROM me."Date_mouvement") as trimestre,
    CONCAT('T', EXTRACT(QUARTER FROM me."Date_mouvement")) as nom_trimestre,
    EXTRACT(YEAR FROM me."Date_mouvement") as annee,
    ca.id_centre,
    ca.nom as centre,
    aa.id_type,
    ABS(SUM((le."Debit" - le."Credit") * (aa.taux / 100.0))) as montant_ventile,
    ABS(SUM(le."Debit" - le."Credit")) as montant_brut,
    COUNT(DISTINCT le."Id_Sous_compte") as nombre_sous_comptes,
    COUNT(DISTINCT EXTRACT(MONTH FROM me."Date_mouvement")) as mois_actifs,
    NOW() as date_mise_a_jour
FROM ligne_ecritures le
JOIN affectationanalytique aa ON le."Id_Sous_compte" = aa."Id_Sous_compte"
JOIN centreanalytique ca ON aa.id_centre = ca.id_centre
JOIN mouvement_ecritures me ON le."Id_Mouvement_ecriture" = me."Id_Mouvement_ecriture"
GROUP BY 
    EXTRACT(QUARTER FROM me."Date_mouvement"),
    EXTRACT(YEAR FROM me."Date_mouvement"),
    ca.id_centre, ca.nom, aa.id_type;

-- 🔥 INDEXES UNIQUES POUR LE RAFRAICHISSEMENT CONCURRENT
CREATE UNIQUE INDEX idx_mv_trimestrielle_unique ON mv_analyse_trimestrielle(annee, trimestre, id_centre, id_type);
CREATE INDEX idx_mv_trimestrielle_annee_trimestre ON mv_analyse_trimestrielle(annee, trimestre);
CREATE INDEX idx_mv_trimestrielle_centre ON mv_analyse_trimestrielle(id_centre);
CREATE INDEX idx_mv_trimestrielle_type ON mv_analyse_trimestrielle(id_type);
CREATE INDEX idx_mv_trimestrielle_annee ON mv_analyse_trimestrielle(annee);

-- 🔥 VUE DES STATISTIQUES GLOBALES (CORRIGÉE)
CREATE MATERIALIZED VIEW mv_stats_globales_temporelles AS
SELECT 
    'mensuelle' as type_analyse,
    EXTRACT(YEAR FROM me."Date_mouvement") as annee,
    NULL as trimestre,
    NULL as annee_comparaison,
    COUNT(DISTINCT ca.id_centre) as nombre_centres,
    COUNT(DISTINCT EXTRACT(MONTH FROM me."Date_mouvement")) as nombre_periodes,
    SUM(ABS((le."Debit" - le."Credit") * (aa.taux / 100.0))) as total_ventile,
    SUM(ABS(le."Debit" - le."Credit")) as total_brut,
    NOW() as date_mise_a_jour
FROM ligne_ecritures le
JOIN affectationanalytique aa ON le."Id_Sous_compte" = aa."Id_Sous_compte"
JOIN centreanalytique ca ON aa.id_centre = ca.id_centre
JOIN mouvement_ecritures me ON le."Id_Mouvement_ecriture" = me."Id_Mouvement_ecriture"
WHERE aa.id_type = 1
GROUP BY EXTRACT(YEAR FROM me."Date_mouvement")

UNION ALL

SELECT 
    'trimestrielle' as type_analyse,
    EXTRACT(YEAR FROM me."Date_mouvement") as annee,
    EXTRACT(QUARTER FROM me."Date_mouvement") as trimestre,
    NULL as annee_comparaison,
    COUNT(DISTINCT ca.id_centre) as nombre_centres,
    COUNT(DISTINCT EXTRACT(QUARTER FROM me."Date_mouvement")) as nombre_periodes,
    SUM(ABS((le."Debit" - le."Credit") * (aa.taux / 100.0))) as total_ventile,
    SUM(ABS(le."Debit" - le."Credit")) as total_brut,
    NOW() as date_mise_a_jour
FROM ligne_ecritures le
JOIN affectationanalytique aa ON le."Id_Sous_compte" = aa."Id_Sous_compte"
JOIN centreanalytique ca ON aa.id_centre = ca.id_centre
JOIN mouvement_ecritures me ON le."Id_Mouvement_ecriture" = me."Id_Mouvement_ecriture"
WHERE aa.id_type = 1
GROUP BY EXTRACT(YEAR FROM me."Date_mouvement"), EXTRACT(QUARTER FROM me."Date_mouvement")

UNION ALL

SELECT 
    'annuelle' as type_analyse,
    EXTRACT(YEAR FROM me."Date_mouvement") as annee,
    NULL as trimestre,
    NULL as annee_comparaison,
    COUNT(DISTINCT ca.id_centre) as nombre_centres,
    1 as nombre_periodes,
    SUM(ABS((le."Debit" - le."Credit") * (aa.taux / 100.0))) as total_ventile,
    SUM(ABS(le."Debit" - le."Credit")) as total_brut,
    NOW() as date_mise_a_jour
FROM ligne_ecritures le
JOIN affectationanalytique aa ON le."Id_Sous_compte" = aa."Id_Sous_compte"
JOIN centreanalytique ca ON aa.id_centre = ca.id_centre
JOIN mouvement_ecritures me ON le."Id_Mouvement_ecriture" = me."Id_Mouvement_ecriture"
WHERE aa.id_type = 1
GROUP BY EXTRACT(YEAR FROM me."Date_mouvement");

-- 🔥 INDEX UNIQUE POUR LES STATISTIQUES
CREATE UNIQUE INDEX idx_mv_stats_unique ON mv_stats_globales_temporelles(type_analyse, annee, COALESCE(trimestre, 0));
CREATE INDEX idx_mv_stats_type_annee_trimestre ON mv_stats_globales_temporelles(type_analyse, annee, trimestre);

-- 🔥 MISE À JOUR DE LA FONCTION RAFRAICHIR
CREATE OR REPLACE FUNCTION rafraichir_vues_temporelles()
RETURNS void AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_analyse_mensuelle;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_analyse_trimestrielle;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_comparaison_annuelle;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_evolution_12_mois;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_stats_globales_temporelles;
END;
$$ LANGUAGE plpgsql;

-- 🔥 EXÉCUTION INITIALE (maintenant ça devrait fonctionner !)
SELECT rafraichir_vues_temporelles();