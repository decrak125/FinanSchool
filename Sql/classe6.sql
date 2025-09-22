-- =====================================
-- INSERTIONS CLASSE 6 - Comptes de charges (RAITRA KIDZ)
-- =====================================

-- Classe 6
INSERT INTO classes ("Code", "Libelle") VALUES
('6', 'Comptes de charges');

-- 60 Charges d’exploitation
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('60', 'Charges d’exploitation', (SELECT "Id_Classe" FROM classes WHERE "Code" = '6'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('601', 'Achats de matières premières (produits alimentaires pour la cantine)', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '60')),
('602', 'Achats de fournitures scolaires et pédagogiques', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '60')),
('603', 'Achats de fournitures de bureau et administratives', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '60')),
('604', 'Achats de petit matériel et équipements d’enseignement', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '60')),
('605', 'Achats d’eau, électricité, gaz', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '60')),
('606', 'Achats de produits d’entretien et de nettoyage', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '60')),
('607', 'Achats d’autres approvisionnements (tenues scolaires, etc.)', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '60'));

-- 61 Services extérieurs
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('61', 'Services extérieurs', (SELECT "Id_Classe" FROM classes WHERE "Code" = '6'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('611', 'Loyers et charges locatives (bâtiments scolaires)', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '61')),
('612', 'Entretien et réparations (bâtiments, matériel, véhicules scolaires)', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '61')),
('613', 'Assurance (responsabilité civile, assurance scolaire, assurance personnel)', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '61')),
('614', 'Publicité, communication, promotion', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '61')),
('615', 'Frais de scolarité versés aux instances / homologation', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '61')),
('616', 'Honoraires (comptable, avocat, consultant)', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '61')),
('617', 'Frais de surveillance, gardiennage et sécurité', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '61')),
('618', 'Frais bancaires et services financiers', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '61')),
('619', 'Autres services extérieurs', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '61'));

-- 62 Charges de personnel
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('62', 'Charges de personnel', (SELECT "Id_Classe" FROM classes WHERE "Code" = '6'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('621', 'Salaires et traitements des enseignants', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '62')),
('622', 'Salaires du personnel administratif', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '62')),
('623', 'Salaires du personnel technique et d’entretien', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '62')),
('624', 'Primes, indemnités et avantages divers', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '62')),
('625', 'Charges sociales obligatoires (CNAPS, OSTIE, etc.)', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '62')),
('626', 'Formation et perfectionnement du personnel', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '62'));

-- 63 Autres charges d’exploitation
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('63', 'Autres charges d’exploitation', (SELECT "Id_Classe" FROM classes WHERE "Code" = '6'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('631', 'Fournitures pédagogiques distribuées aux élèves', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '63')),
('632', 'Dépenses pour activités scolaires et parascolaires (sorties, sport, culture)', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '63')),
('633', 'Cantine : denrées alimentaires, gaz, entretien cuisine', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '63')),
('634', 'Frais de santé et hygiène scolaire', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '63')),
('635', 'Transport scolaire (carburant, entretien, assurance véhicules)', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '63')),
('636', 'Organisation d’événements (fêtes scolaires, remise de diplômes)', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '63'));

-- 64 Dotations aux amortissements et provisions
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('64', 'Dotations aux amortissements et provisions', (SELECT "Id_Classe" FROM classes WHERE "Code" = '6'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('641', 'Amortissements du mobilier scolaire', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '64')),
('642', 'Amortissements du matériel informatique et audiovisuel', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '64')),
('643', 'Amortissements des bâtiments scolaires', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '64')),
('644', 'Amortissements des véhicules (bus scolaires)', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '64')),
('645', 'Provisions pour créances douteuses (parents ne payant pas les frais)', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '64'));

-- 65 Charges financières
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('65', 'Charges financières', (SELECT "Id_Classe" FROM classes WHERE "Code" = '6'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('651', 'Intérêts sur emprunts bancaires', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '65')),
('659', 'Autres charges financières', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '65'));

-- 67 Charges exceptionnelles
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('67', 'Charges exceptionnelles', (SELECT "Id_Classe" FROM classes WHERE "Code" = '6'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('671', 'Pénalités et amendes', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '67')),
('672', 'Charges exceptionnelles diverses (travaux urgents non prévus)', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '67'));
