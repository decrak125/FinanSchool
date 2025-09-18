-- =====================================
-- INSERTIONS CLASSE 4 - Comptes de tiers
-- =====================================

-- Classe 4
INSERT INTO classes ("Code", "Libelle") VALUES
('4', 'Comptes de tiers');

-- 40 Fournisseurs et comptes rattaches
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('40', 'Fournisseurs et comptes rattaches', (SELECT "Id_Classe" FROM classes WHERE "Code" = '4'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('401', 'Fournisseurs', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '40')),
('403', 'Fournisseurs - effets a payer', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '40')),
('408', 'Fournisseurs - factures non parvenues', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '40')),
('409', 'Fournisseurs debiteurs', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '40'));

-- 41 Clients et comptes rattaches
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('41', 'Clients et comptes rattaches', (SELECT "Id_Classe" FROM classes WHERE "Code" = '4'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('411', 'Clients', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '41')),
('413', 'Clients - effets a recevoir', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '41')),
('418', 'Clients - produits non encore factures', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '41')),
('419', 'Clients crediteurs', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '41'));

-- 42 Personnel et comptes rattaches
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('42', 'Personnel et comptes rattaches', (SELECT "Id_Classe" FROM classes WHERE "Code" = '4'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('421', 'Personnel - remunerations dues', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '42')),
('425', 'Personnel - avances et acomptes', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '42')),
('428', 'Personnel - charges a payer et produits a recevoir', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '42')),
('431', 'Securite sociale', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '42')),
('437', 'Autres organismes sociaux', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '42')),
('438', 'Organismes sociaux - charges a payer et produits a recevoir', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '42'));

-- 43 Etat et autres collectivites publiques
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('43', 'Etat et autres collectivites publiques', (SELECT "Id_Classe" FROM classes WHERE "Code" = '4'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('431', 'Etat - impots et taxes', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '43')),
('437', 'Etat - subventions a recevoir', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '43')),
('438', 'Etat - charges a payer et produits a recevoir', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '43'));

-- 44 Groupes et associes
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('44', 'Groupes et associes', (SELECT "Id_Classe" FROM classes WHERE "Code" = '4'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('441', 'Groupes', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '44')),
('445', 'Associes - comptes courants', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '44'));

-- 45 Debiteurs divers et crediteurs divers
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('45', 'Debiteurs divers et crediteurs divers', (SELECT "Id_Classe" FROM classes WHERE "Code" = '4'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('451', 'Debiteurs divers', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '45')),
('455', 'Crediteurs divers', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '45'));

-- 46 Comptes transitoires ou d'attente
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('46', 'Comptes transitoires ou dattente', (SELECT "Id_Classe" FROM classes WHERE "Code" = '4'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('461', 'Comptes de liaison interne', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '46')),
('462', 'Comptes dordre', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '46')),
('468', 'Autres comptes transitoires', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '46'));

-- 47 Comptes rattaches a des operations de financement
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('47', 'Comptes rattaches a des operations de financement', (SELECT "Id_Classe" FROM classes WHERE "Code" = '4'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('471', 'Dettes de financement a court terme', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '47')),
('472', 'Creances de financement a court terme', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '47'));

-- 48 Comptes de regularisation
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('48', 'Comptes de regularisation', (SELECT "Id_Classe" FROM classes WHERE "Code" = '4'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('481', 'Charges constatees davance', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '48')),
('482', 'Produits constates davance', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '48')),
('486', 'Charges a repartir', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '48')),
('487', 'Produits a repartir', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '48'));

-- 49 Pertes de valeur des comptes de tiers
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('49', 'Pertes de valeur des comptes de tiers', (SELECT "Id_Classe" FROM classes WHERE "Code" = '4'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('491', 'Perte de valeur sur clients', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '49')),
('495', 'Perte de valeur sur comptes rattaches', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '49')),
('498', 'Autres pertes de valeur sur comptes de tiers', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '49'));
