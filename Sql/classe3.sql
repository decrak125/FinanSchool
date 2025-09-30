-- =====================================
-- INSERTIONS CLASSE 3 - Comptes de stocks et en-cours
-- =====================================

-- Classe 3
INSERT INTO classes ("Code", "Libelle") VALUES
('3', 'Comptes de stocks et en-cours');

-- 30 Stocks de matieres premieres (et fournitures)
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('31', 'Stocks de matieres premieres et fournitures', (SELECT "Id_Classe" FROM classes WHERE "Code" = '3'));

-- 31 Stocks d'autres approvisionnements
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('32', 'Stocks dautres approvisionnements', (SELECT "Id_Classe" FROM classes WHERE "Code" = '3'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('321', 'Matiere consommables', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '32')),
('322', 'Fournitures consommables', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '32')),
('326', 'Emballages', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '32'));

-- 32 En-cours de production de biens
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('33', 'En-cours de production de biens', (SELECT "Id_Classe" FROM classes WHERE "Code" = '3'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('331', 'Produit en-cours', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '33')),
('335', 'Travaux en-cours ', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '33'));

-- 33 En-cours de production de services
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('34', 'En-cours de production de services', (SELECT "Id_Classe" FROM classes WHERE "Code" = '3'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('341', 'Etudes en-cours', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '34')),
('345', 'Prestations de service en cours', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '34'));

-- 34 Produits intermediaires et finis
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('35', 'Produits intermediaires et finis', (SELECT "Id_Classe" FROM classes WHERE "Code" = '3'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('351', 'Produits intermediaires', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '35')),
('355', 'Produits finis', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '35')),
('358', 'Produits residuels ou matieres de recuperation (dechets,rebuts)', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '35'));

-- 36 Disponible
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('36', '(Disponible)', (SELECT "Id_Classe" FROM classes WHERE "Code" = '3'));

-- 37 Stocks provenant d'approvisionnements
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('37', 'Stocks de marchandises', (SELECT "Id_Classe" FROM classes WHERE "Code" = '3'));

-- 38 Stocks provenant dimmobilisations
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('38', 'Stocks à lextérieur (en cours de route, en dépôt ou en
consignation)', (SELECT "Id_Classe" FROM classes WHERE "Code" = '3'));

-- 39 Pertes de valeur sur stocks et en-cours
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('39', 'Pertes de valeur sur stocks et en-cours', (SELECT "Id_Classe" FROM classes WHERE "Code" = '3'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('391', 'Perte de valeur sur matieres premieres et fournitures', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '39')),
('392', 'Perte de valeur sur autres approvisionnements', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '39')),
('393', 'Perte de valeur sur en-cours de production de biens', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '39')),
('394', 'Perte de valeur sur en-cours de production de services', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '39')),
('395', 'Perte de valeur sur produits', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '39')),
('397', 'Perte de valeur sur stocks provenant dapprovisionnements', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '39')),
('398', 'Perte de valeur sur stocks provenant dimmobilisations', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '39'));
