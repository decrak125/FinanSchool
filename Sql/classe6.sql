-- =====================================
-- INSERTIONS CLASSE 6 - Comptes de charges (PCG 2005)
-- =====================================

-- Classe 6
INSERT INTO classes ("Code", "Libelle") VALUES
('6', 'Comptes de charges');

-- 60 Achats consommés
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('60', 'Achats consommés', (SELECT "Id_Classe" FROM classes WHERE "Code" = '6'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('601', 'Matières premières', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '60')),
('602', 'Autres approvisionnements', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '60')),
('603', 'Variations des stocks', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '60')),
('604', 'Achats d’études et de prestations de service', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '60')),
('605', 'Achats de matériels, équipements et travaux', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '60')),
('606', 'Achats non stockés de matières et fournitures', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '60')),
('607', 'Achats de marchandises', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '60')),
('608', 'Frais accessoires d’achat', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '60')),
('609', 'Rabais, remises et ristournes obtenus sur achats', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '60'));

-- 61 Services extérieurs
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('61', 'Services extérieurs', (SELECT "Id_Classe" FROM classes WHERE "Code" = '6'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('611', 'Sous-traitance générale', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '61')),
('613', 'Locations', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '61')),
('614', 'Charges locatives et de copropriété', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '61')),
('615', 'Entretien, réparations et maintenance', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '61')),
('616', 'Primes d’assurances', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '61')),
('617', 'Études et recherches', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '61')),
('618', 'Documentation et divers', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '61')),
('619', 'Rabais, remises, ristournes sur services extérieurs', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '61'));

-- 62 Autres services extérieurs
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('62', 'Autres services extérieurs', (SELECT "Id_Classe" FROM classes WHERE "Code" = '6'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('621', 'Personnel extérieur à l’entreprise', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '62')),
('622', 'Rémunérations d’intermédiaires et honoraires', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '62')),
('623', 'Publicité, publication, relations publiques', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '62')),
('624', 'Transports de biens et transport collectif du personnel', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '62')),
('625', 'Déplacements, missions et réceptions', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '62')),
('626', 'Frais postaux et de télécommunications', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '62')),
('627', 'Services bancaires et assimilés', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '62')),
('628', 'Cotisations et divers', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '62')),
('629', 'Rabais, remises, ristournes sur autres services extérieurs', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '62'));

-- 63 Impôts, taxes et versements assimilés
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('63', 'Impôts, taxes et versements assimilés', (SELECT "Id_Classe" FROM classes WHERE "Code" = '6'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('631', 'Impôts, taxes et versements assimilés sur rémunérations', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '63')),
('635', 'Autres impôts et taxes', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '63'));

-- 64 Charges de personnel
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('64', 'Charges de personnel', (SELECT "Id_Classe" FROM classes WHERE "Code" = '6'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('641', 'Rémunérations du personnel', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '64')),
('644', 'Rémunérations des dirigeants', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '64')),
('645', 'Cotisations aux organismes sociaux', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '64')),
('646', 'Charges sociales sur rémunérations des dirigeants', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '64')),
('647', 'Autres charges sociales', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '64')),
('648', 'Autres charges de personnel', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '64'));

-- 65 Autres charges des activités ordinaires
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('65', 'Autres charges des activités ordinaires', (SELECT "Id_Classe" FROM classes WHERE "Code" = '6'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('651', 'Redevances pour concessions, brevets, licences, logiciels et valeurs similaires', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '65')),
('652', 'Moins-values sur cessions d’actifs non courants', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '65')),
('653', 'Jetons de présence', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '65')),
('654', 'Pertes sur créances irrécouvrables', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '65')),
('655', 'Quote-part de résultat sur opérations faites en commun', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '65')),
('656', 'Amendes, pénalités, subventions accordées, dons et libéralités', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '65')),
('657', 'Charges exceptionnelles de gestion courante', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '65')),
('658', 'Autres charges de gestion courante', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '65'));

-- 66 Charges financières
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('66', 'Charges financières', (SELECT "Id_Classe" FROM classes WHERE "Code" = '6'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('661', 'Charges d’intérêts', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '66')),
('664', 'Pertes sur créances liées à des participations', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '66')),
('665', 'Moins-values sur titres de placement', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '66')),
('666', 'Pertes de change', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '66')),
('667', 'Moins-values sur instruments financiers et assimilés', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '66')),
('668', 'Autres charges financières', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '66'));

-- 67 Éléments extraordinaires (charges)
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('67', 'Éléments extraordinaires (charges)', (SELECT "Id_Classe" FROM classes WHERE "Code" = '6'));

-- 68 Dotations aux amortissements, provisions, pertes de valeur
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('68', 'Dotations aux amortissements, provisions et pertes de valeur', (SELECT "Id_Classe" FROM classes WHERE "Code" = '6'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('681', 'Dotations - actifs non courants', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '68')),
('685', 'Dotations - actifs courants', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '68'));

-- 69 Impôts sur les bénéfices
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('69', 'Impôts sur les bénéfices', (SELECT "Id_Classe" FROM classes WHERE "Code" = '6'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('692', 'Imposition différée actif', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '69')),
('693', 'Imposition différée passif', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '69')),
('695', 'Impôts sur les bénéfices basés sur le résultat des activités ordinaires', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '69')),
('698', 'Autres impôts sur les résultats', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '69'));
