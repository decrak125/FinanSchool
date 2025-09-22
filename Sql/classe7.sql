-- =====================================
-- INSERTIONS CLASSE 7 - Comptes de produits
-- =====================================

-- Classe 7
INSERT INTO classes ("Code", "Libelle") VALUES
('7', 'Comptes de produits');

-- 70 Ventes de produits fabriques, marchandises, prestations
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('70', 'Ventes de produits fabriques, marchandises, prestations', (SELECT "Id_Classe" FROM classes WHERE "Code" = '7'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('701', 'Ventes de produits finis', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '70')),
('702', 'Ventes de produits intermediaires', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '70')),
('703', 'Ventes de produits residuels', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '70')),
('704', 'Vente de travaux', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '70')),
('705', 'Vente detudes', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '70')),
('706', 'Vente de prestations de service', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '70')),
('707', 'Ventes de marchandises', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '70')),
('708', 'Produits des activites annexes', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '70')),
('709', 'Rabais, remises et ristournes accordes', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '70'));

-- 71 Production stockee (ou destockage)
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('71', 'Production stockee (ou destockage)', (SELECT "Id_Classe" FROM classes WHERE "Code" = '7'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('713', 'Variation de stocks den cours', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '71')),
('714', 'Variation de stocks de produits', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '71'));

-- 72 Production immobilisee
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('72', 'Production immobilisee', (SELECT "Id_Classe" FROM classes WHERE "Code" = '7'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('721', 'Production immobilisee d actif incorporel', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '72')),
('722', 'Production immobilisee d actif corporel', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '72'));

-- 74 Subventions dexploitation
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('74', 'Subventions dexploitation', (SELECT "Id_Classe" FROM classes WHERE "Code" = '7'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('741', 'Subvention dequilibre', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '74')),
('748', 'Autres subventions dexploitation', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '74'));

-- 75 Autres produits operationnels
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('75', 'Autres produits operationnels', (SELECT "Id_Classe" FROM classes WHERE "Code" = '7'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('751', 'Redevances pour concessions, brevets, licences, logiciels et valeurs similaires', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '75')),
('752', 'Plus values sur cessions d actifs non courants', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '75')),
('753', 'Jetons de presence et remunerations dadministrateurs ou de gerant', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '75')),
('754', 'Quotes parts de subventions dinvestissement virees au resultat', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '75')),
('755', 'Quote part de resultat sur operations faites en commun', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '75')),
('756', 'Liberalites percues, entrees sur creances amorties', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '75')),
('757', 'Produits exceptionnels sur operations de gestion', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '75')),
('758', 'Autres produits de gestion courante', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '75'));

-- 76 Produits financiers
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('76', 'Produits financiers', (SELECT "Id_Classe" FROM classes WHERE "Code" = '7'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('761', 'Produits de participations', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '76')),
('762', 'Produits des autres immobilisations financieres', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '76')),
('763', 'Revenus des autres creances', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '76')),
('764', 'Revenus et plus values des valeurs mobilieres de placement', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '76')),
('766', 'Gains de change', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '76')),
('767', 'Produits nets sur cessions de valeurs mobilieres de placement', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '76')),
('768', 'Autres produits financiers', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '76'));

-- 77 Elements extraordinaires (produits)
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('77', 'Elements extraordinaires (produits)', (SELECT "Id_Classe" FROM classes WHERE "Code" = '7'));

-- 78 Reprises sur provisions et pertes de valeur
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('78', 'Reprises sur provisions et pertes de valeur', (SELECT "Id_Classe" FROM classes WHERE "Code" = '7'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('781', 'Reprise dexploitation - actifs non courants', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '78')),
('785', 'Reprise dexploitation - actifs courants', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '78')),
('786', 'Reprises financieres', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '78'));
