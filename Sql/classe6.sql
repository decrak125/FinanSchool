-- =====================================
-- INSERTIONS CLASSE 6 - Comptes de charges (RAITRA KIDZ)
-- =====================================

-- Classe 6
INSERT INTO classes ("Code", "Libelle") VALUES
('6', 'Comptes de charges');

-- 60 Charges d exploitation
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('60', 'Charges d exploitation', (SELECT "Id_Classe" FROM classes WHERE "Code" = '6'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('601', 'Achats de matieres premieres produits alimentaires pour la cantine', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '60')),
('602', 'Achats de fournitures scolaires et pedagogiques', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '60')),
('603', 'Achats de fournitures de bureau et administratives', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '60')),
('604', 'Achats de petit materiel et equipements d enseignement', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '60')),
('605', 'Achats d eau electricite gaz', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '60')),
('606', 'Achats de produits d entretien et de nettoyage', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '60')),
('607', 'Achats d autres approvisionnements tenues scolaires etc', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '60'));

-- 61 Services exterieurs
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('61', 'Services exterieurs', (SELECT "Id_Classe" FROM classes WHERE "Code" = '6'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('611', 'Loyers et charges locatives batiments scolaires', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '61')),
('612', 'Entretien et reparations batiments materiel vehicules scolaires', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '61')),
('613', 'Assurance responsabilite civile assurance scolaire assurance personnel', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '61')),
('614', 'Publicite communication promotion', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '61')),
('615', 'Frais de scolarite verses aux instances homologation', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '61')),
('616', 'Honoraires comptable avocat consultant', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '61')),
('617', 'Frais de surveillance gardiennage et securite', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '61')),
('618', 'Frais bancaires et services financiers', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '61')),
('619', 'Autres services exterieurs', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '61'));

-- 62 Charges de personnel
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('62', 'Charges de personnel', (SELECT "Id_Classe" FROM classes WHERE "Code" = '6'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('621', 'Salaires et traitements des enseignants', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '62')),
('622', 'Salaires du personnel administratif', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '62')),
('623', 'Salaires du personnel technique et d entretien', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '62')),
('624', 'Primes indemnites et avantages divers', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '62')),
('625', 'Charges sociales obligatoires CNAPS OSTIE etc', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '62')),
('626', 'Formation et perfectionnement du personnel', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '62'));

-- 63 Autres charges d exploitation
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('63', 'Autres charges d exploitation', (SELECT "Id_Classe" FROM classes WHERE "Code" = '6'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('631', 'Fournitures pedagogiques distribuees aux eleves', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '63')),
('632', 'Depenses pour activites scolaires et parascolaires sorties sport culture', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '63')),
('633', 'Cantine denrees alimentaires gaz entretien cuisine', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '63')),
('634', 'Frais de sante et hygiene scolaire', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '63')),
('635', 'Transport scolaire carburant entretien assurance vehicules', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '63')),
('636', 'Organisation d evenements fetes scolaires remise de diplomes', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '63'));

-- 64 Dotations aux amortissements et provisions
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('64', 'Dotations aux amortissements et provisions', (SELECT "Id_Classe" FROM classes WHERE "Code" = '6'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('641', 'Amortissements du mobilier scolaire', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '64')),
('642', 'Amortissements du materiel informatique et audiovisuel', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '64')),
('643', 'Amortissements des batiments scolaires', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '64')),
('644', 'Amortissements des vehicules bus scolaires', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '64')),
('645', 'Provisions pour creances douteuses parents ne payant pas les frais', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '64'));

-- 65 Charges financieres
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('65', 'Charges financieres', (SELECT "Id_Classe" FROM classes WHERE "Code" = '6'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('651', 'Interets sur emprunts bancaires', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '65')),
('659', 'Autres charges financieres', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '65'));

-- 67 Charges exceptionnelles
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('67', 'Charges exceptionnelles', (SELECT "Id_Classe" FROM classes WHERE "Code" = '6'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('671', 'Penalites et amendes', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '67')),
('672', 'Charges exceptionnelles diverses travaux urgents non prevus', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '67'));
