[file name]: view_analyse.sql
[file content begin]
-- 🔥 SUPPRESSION DES VUES EXISTANTES
DROP MATERIALIZED VIEW IF EXISTS mv_analyse_mensuelle CASCADE;
DROP MATERIALIZED VIEW IF EXISTS mv_comparaison_annuelle CASCADE;
DROP MATERIALIZED VIEW IF EXISTS mv_evolution_12_mois CASCADE;
DROP MATERIALIZED VIEW IF EXISTS mv_analyse_trimestrielle CASCADE;
DROP MATERIALIZED VIEW IF EXISTS mv_stats_globales_temporelles CASCADE;
DROP MATERIALIZED VIEW IF EXISTS mv_comparaison_cout_profit CASCADE;

-- 1. CRÉATION DES VUES SANS INDEXES
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
  AND me."Date_mouvement" <= CURRENT_DATE  -- ← CORRECTION IMPORTANTE
GROUP BY 
    DATE_TRUNC('month', me."Date_mouvement"),
    TO_CHAR(me."Date_mouvement", 'YYYY-MM'),
    TO_CHAR(me."Date_mouvement", 'Month YYYY'),
    ca.id_centre, ca.nom, aa.id_type;

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

-- Vue pour la comparaison coûts vs profits par type
CREATE MATERIALIZED VIEW mv_comparaison_cout_profit AS
SELECT 
    EXTRACT(YEAR FROM me."Date_mouvement") as annee,
    EXTRACT(MONTH FROM me."Date_mouvement") as mois,
    TO_CHAR(me."Date_mouvement", 'Month YYYY') as nom_periode,
    aa.id_type,
    -- Coûts (débits)
    SUM(CASE WHEN le."Debit" > 0 THEN (le."Debit" * (aa.taux / 100.0)) ELSE 0 END) as total_couts_ventiles,
    SUM(CASE WHEN le."Debit" > 0 THEN le."Debit" ELSE 0 END) as total_couts_bruts,
    -- Profits (crédits)
    SUM(CASE WHEN le."Credit" > 0 THEN (le."Credit" * (aa.taux / 100.0)) ELSE 0 END) as total_profits_ventiles,
    SUM(CASE WHEN le."Credit" > 0 THEN le."Credit" ELSE 0 END) as total_profits_bruts,
    -- Soldes et ratios
    SUM(CASE WHEN le."Credit" > 0 THEN (le."Credit" * (aa.taux / 100.0)) ELSE 0 END) - 
    SUM(CASE WHEN le."Debit" > 0 THEN (le."Debit" * (aa.taux / 100.0)) ELSE 0 END) as solde_net_ventile,
    SUM(CASE WHEN le."Credit" > 0 THEN le."Credit" ELSE 0 END) - 
    SUM(CASE WHEN le."Debit" > 0 THEN le."Debit" ELSE 0 END) as solde_net_brut,
    -- Ratios de profitabilité
    CASE 
        WHEN SUM(CASE WHEN le."Debit" > 0 THEN (le."Debit" * (aa.taux / 100.0)) ELSE 0 END) > 0 
        THEN (SUM(CASE WHEN le."Credit" > 0 THEN (le."Credit" * (aa.taux / 100.0)) ELSE 0 END) - 
              SUM(CASE WHEN le."Debit" > 0 THEN (le."Debit" * (aa.taux / 100.0)) ELSE 0 END)) / 
             SUM(CASE WHEN le."Debit" > 0 THEN (le."Debit" * (aa.taux / 100.0)) ELSE 0 END) * 100
        ELSE 0 
    END as marge_nette_percent,
    COUNT(DISTINCT le."Id_Sous_compte") as nombre_sous_comptes,
    COUNT(DISTINCT ca.id_centre) as nombre_centres,
    NOW() as date_mise_a_jour
FROM ligne_ecritures le
JOIN affectationanalytique aa ON le."Id_Sous_compte" = aa."Id_Sous_compte"
JOIN centreanalytique ca ON aa.id_centre = ca.id_centre
JOIN mouvement_ecritures me ON le."Id_Mouvement_ecriture" = me."Id_Mouvement_ecriture"
GROUP BY 
    EXTRACT(YEAR FROM me."Date_mouvement"),
    EXTRACT(MONTH FROM me."Date_mouvement"),
    TO_CHAR(me."Date_mouvement", 'Month YYYY'),
    aa.id_type;

-- Version simplifiée de la vue stats pour éviter les problèmes
CREATE MATERIALIZED VIEW mv_stats_globales_temporelles AS
SELECT 
    ROW_NUMBER() OVER () as id_unique, -- Clé unique artificielle
    type_analyse,
    annee,
    trimestre,
    annee_comparaison,
    nombre_centres,
    nombre_periodes,
    total_ventile,
    total_brut,
    date_mise_a_jour
FROM (
    SELECT 
        'mensuelle' as type_analyse,
        EXTRACT(YEAR FROM me."Date_mouvement") as annee,
        NULL::integer as trimestre,
        NULL::integer as annee_comparaison,
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
        NULL::integer as annee_comparaison,
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
        NULL::integer as trimestre,
        NULL::integer as annee_comparaison,
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
    GROUP BY EXTRACT(YEAR FROM me."Date_mouvement")
) as subquery;

-- 2. MAINTENANT CRÉER LES INDEXES UNIQUES
CREATE UNIQUE INDEX idx_mv_mensuelle_unique ON mv_analyse_mensuelle(annee, mois, id_centre, id_type);
CREATE UNIQUE INDEX idx_mv_annuelle_unique ON mv_comparaison_annuelle(annee, id_centre, id_type);
CREATE UNIQUE INDEX idx_mv_12mois_unique ON mv_evolution_12_mois(mois, id_centre, id_type);
CREATE UNIQUE INDEX idx_mv_trimestrielle_unique ON mv_analyse_trimestrielle(annee, trimestre, id_centre, id_type);
CREATE UNIQUE INDEX idx_mv_cout_profit_unique ON mv_comparaison_cout_profit(annee, mois, id_type);
CREATE UNIQUE INDEX idx_mv_stats_unique ON mv_stats_globales_temporelles(id_unique);

-- 3. INDEXES DE PERFORMANCE
CREATE INDEX idx_mv_mensuelle_annee_mois ON mv_analyse_mensuelle(annee, mois);
CREATE INDEX idx_mv_mensuelle_centre ON mv_analyse_mensuelle(id_centre);
CREATE INDEX idx_mv_mensuelle_type ON mv_analyse_mensuelle(id_type);

CREATE INDEX idx_mv_annuelle_annee ON mv_comparaison_annuelle(annee);
CREATE INDEX idx_mv_annuelle_centre ON mv_comparaison_annuelle(id_centre);
CREATE INDEX idx_mv_annuelle_type ON mv_comparaison_annuelle(id_type);

CREATE INDEX idx_mv_12mois_mois ON mv_evolution_12_mois(mois);
CREATE INDEX idx_mv_12mois_centre ON mv_evolution_12_mois(id_centre);
CREATE INDEX idx_mv_12mois_type ON mv_evolution_12_mois(id_type);

CREATE INDEX idx_mv_trimestrielle_annee_trimestre ON mv_analyse_trimestrielle(annee, trimestre);
CREATE INDEX idx_mv_trimestrielle_centre ON mv_analyse_trimestrielle(id_centre);
CREATE INDEX idx_mv_trimestrielle_type ON mv_analyse_trimestrielle(id_type);
CREATE INDEX idx_mv_trimestrielle_annee ON mv_analyse_trimestrielle(annee);

-- Indexes pour la vue coûts vs profits
CREATE INDEX idx_mv_cout_profit_annee_mois ON mv_comparaison_cout_profit(annee, mois);
CREATE INDEX idx_mv_cout_profit_type ON mv_comparaison_cout_profit(id_type);
CREATE INDEX idx_mv_cout_profit_periode ON mv_comparaison_cout_profit(nom_periode);

CREATE INDEX idx_mv_stats_type_annee_trimestre ON mv_stats_globales_temporelles(type_analyse, annee, trimestre);

-- 4. FONCTION DE RAFRAÎCHISSEMENT
CREATE OR REPLACE FUNCTION rafraichir_vues_temporelles()
RETURNS void AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_analyse_mensuelle;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_analyse_trimestrielle;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_comparaison_annuelle;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_evolution_12_mois;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_comparaison_cout_profit;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_stats_globales_temporelles;
END;
$$ LANGUAGE plpgsql;

-- Test du rafraîchissement
SELECT rafraichir_vues_temporelles();
[file content end]