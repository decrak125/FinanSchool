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
('401', 'Fournisseurs de biens et services', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '40')),
('403', 'Fournisseurs - effets a payer', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '40')),
('404', 'Fournisseurs - immobilisations', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '40')),
('405', 'Fournisseurs - immobilisations effets a payer', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '40')),
('408', 'Fournisseurs - factures non parvenues', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '40')),
('409', 'Fournisseurs debiteurs  : avances et acomptes, RRR a obtenir, autres creances', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '40'));

-- 41 Clients et comptes rattaches
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('41', 'Clients et comptes rattaches', (SELECT "Id_Classe" FROM classes WHERE "Code" = '4'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('411', 'Clients', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '41')),
('413', 'Clients - effets a recevoir', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '41')),
('416', 'Clients douteux', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '41')),
('417', 'Creances sur travaux non encore facturables', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '41')),
('418', 'Clients - produits non encore factures', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '41')),
('419', 'Clients crediteurs', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '41'));

-- 42 Personnel et comptes rattaches
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('42', 'Personnel et comptes rattaches', (SELECT "Id_Classe" FROM classes WHERE "Code" = '4'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('421', 'Personnel - remunerations dues', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '42')),
('422', 'Fonds sociaux - oeuvres sociales', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '42')),
('425', 'Personnel - avances et acomptes', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '42')),
('426', 'Personnel - depot reçus', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '42')),
('427', 'Personnel oppositions', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '42')),
('428', 'Personnel - charges a payer et produits a recevoir', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '42'));

-- 43 Etat et autres collectivites publiques
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('43', 'Organismes sociaux et comptes rattaches', (SELECT "Id_Classe" FROM classes WHERE "Code" = '4'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('431', ' Organismes sociaux A', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '43')),
('432', ' Organismes sociaux B', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '43')),
('438', 'Organismes sociaux, charges a payer', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '43'));

-- 44 Groupes et associes
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('44', 'Etat, collectivites publiques, organismes internationaux', (SELECT "Id_Classe" FROM classes WHERE "Code" = '4'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('441', 'Etat, subventions a recevoir', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '44')),
('442', 'Etat, impots et taxes recouvrables sur des tiers', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '44')),
('443', 'Operations particulieres avec lEtat et autres organismes publiques', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '44')),
('444', 'Etat, impots sur les resultats', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '44')),
('445', 'Etat, taxes sur le chiffre d affaires', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '44')),
('447', 'Autres impots, taxes et versements assimiles', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '44')),
('448', 'Etat, charges a payer et produits a recevoir', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '44'));

-- 45 Debiteurs divers et crediteurs divers
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('45', 'Groupe et Associes', (SELECT "Id_Classe" FROM classes WHERE "Code" = '4'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('451', 'Operations Groupe', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '45')),
('455', 'Associes - comptes courants', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '45')),
('456', 'Associes, operations sur le capital', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '45')),
('457', 'Associes, dividendes a payer', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '45')),
('458', 'Associes, operations faites en commun ou en groupement', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '45'));

-- 46 Comptes transitoires ou d'attente
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('46', 'Debiteurs divers et crediteurs divers', (SELECT "Id_Classe" FROM classes WHERE "Code" = '4'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('462', 'Creances sur cessions d immobilisations', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '46')),
('464', 'Dettes sur acquisitions de valeurs mobilieres de placement', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '46')),
('465', 'Creances sur cessions de valeurs mobilieres de placement', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '46')),
('467', 'Autres comptes debiteurs ou crediteurs', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '46')),
('468', 'Divers charges a payer ou produits a recevoir', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '46'));

-- 47 Comptes rattaches a des operations de financement
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('47', 'Comptes transitoires ou d attente', (SELECT "Id_Classe" FROM classes WHERE "Code" = '4'));

-- 48 Comptes de regularisation
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('48', 'Charges ou produits constates d avance et provisions', (SELECT "Id_Classe" FROM classes WHERE "Code" = '4'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('481', 'Provisions - passifs courants', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '48')),
('486', 'Charges constatees d avance', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '48')),
('487', 'Produits constates d avance', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '48'));

-- 49 Pertes de valeur des comptes de tiers
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('49', 'Pertes de valeur sur comptes de tiers', (SELECT "Id_Classe" FROM classes WHERE "Code" = '4'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('491', 'Perte de valeur sur comptes de clients', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '49')),
('495', 'Perte de valeur sur comptes du groupe et des associes', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '49')),
('498', 'Pertes de valeur sur comptes de débiteurs divers', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '49'));
