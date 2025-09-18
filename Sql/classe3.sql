-- =====================================
-- INSERTIONS CLASSE 3 - Comptes de stocks et en-cours
-- =====================================

-- Classe 3
INSERT INTO classes ("Code", "Libelle") VALUES
('3', 'Comptes de stocks et en-cours');

-- 30 Stocks de matieres premieres (et fournitures)
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('30', 'Stocks de matieres premieres et fournitures', (SELECT "Id_Classe" FROM classes WHERE "Code" = '3'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('301', 'Matiere (ou groupe) A', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '30')),
('302', 'Matiere (ou groupe) B', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '30')),
('303', 'Matiere (ou groupe) C', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '30')),
('308', 'Autres matieres premieres et fournitures', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '30'));

-- 31 Stocks d'autres approvisionnements
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('31', 'Stocks dautres approvisionnements', (SELECT "Id_Classe" FROM classes WHERE "Code" = '3'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('311', 'Matiere consommables', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '31')),
('312', 'Fournitures consommables', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '31')),
('316', 'Emballages', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '31'));

-- 32 En-cours de production de biens
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('32', 'En-cours de production de biens', (SELECT "Id_Classe" FROM classes WHERE "Code" = '3'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('321', 'Biens en-cours A', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '32')),
('322', 'Biens en-cours B', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '32')),
('328', 'Autres en-cours de production de biens', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '32'));

-- 33 En-cours de production de services
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('33', 'En-cours de production de services', (SELECT "Id_Classe" FROM classes WHERE "Code" = '3'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('331', 'Services en-cours A', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '33')),
('332', 'Services en-cours B', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '33')),
('338', 'Autres en-cours de production de services', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '33'));

-- 34 Produits intermediaires et finis
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('34', 'Produits intermediaires et finis', (SELECT "Id_Classe" FROM classes WHERE "Code" = '3'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('341', 'Produits intermediaires', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '34')),
('345', 'Produits finis', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '34'));

-- 35 Stocks de marchandises
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('35', 'Stocks de marchandises', (SELECT "Id_Classe" FROM classes WHERE "Code" = '3'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('351', 'Marchandises A', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '35')),
('352', 'Marchandises B', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '35')),
('358', 'Autres marchandises', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '35'));

-- 36 Disponible
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('36', '(Disponible)', (SELECT "Id_Classe" FROM classes WHERE "Code" = '3'));

-- 37 Stocks provenant d'approvisionnements
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('37', 'Stocks provenant dapprovisionnements', (SELECT "Id_Classe" FROM classes WHERE "Code" = '3'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('371', 'Matiere ou fournitures A', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '37')),
('372', 'Matiere ou fournitures B', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '37')),
('378', 'Autres stocks provenant dapprovisionnements', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '37'));

-- 38 Stocks provenant dimmobilisations
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('38', 'Stocks provenant dimmobilisations', (SELECT "Id_Classe" FROM classes WHERE "Code" = '3'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('381', 'Immobilisations destinees a la vente', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '38'));

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
