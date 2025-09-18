-- =====================================
-- INSERTIONS CLASSE 3 - Comptes de stocks et en-cours
-- =====================================

-- Classe 3
INSERT INTO classe (code_classe, libelle) VALUES
('3', 'Comptes de stocks et en-cours');

-- 30 Stocks de matieres premieres (et fournitures)
INSERT INTO rubrique (code_rubrique, libelle, id_classe) VALUES
('30', 'Stocks de matieres premieres et fournitures', (SELECT id_classe FROM classe WHERE code_classe = '3'));

INSERT INTO compte (code_compte, libelle, id_rubrique) VALUES
('301', 'Matiere (ou groupe) A', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '30')),
('302', 'Matiere (ou groupe) B', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '30')),
('303', 'Matiere (ou groupe) C', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '30')),
('308', 'Autres matieres premieres et fournitures', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '30'));

-- 31 Stocks dautres approvisionnements
INSERT INTO rubrique (code_rubrique, libelle, id_classe) VALUES
('31', 'Stocks dautres approvisionnements', (SELECT id_classe FROM classe WHERE code_classe = '3'));

INSERT INTO compte (code_compte, libelle, id_rubrique) VALUES
('311', 'Matiere consommables', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '31')),
('312', 'Fournitures consommables', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '31')),
('316', 'Emballages', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '31'));

-- 32 En-cours de production de biens
INSERT INTO rubrique (code_rubrique, libelle, id_classe) VALUES
('32', 'En-cours de production de biens', (SELECT id_classe FROM classe WHERE code_classe = '3'));

INSERT INTO compte (code_compte, libelle, id_rubrique) VALUES
('321', 'Biens en-cours A', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '32')),
('322', 'Biens en-cours B', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '32')),
('328', 'Autres en-cours de production de biens', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '32'));

-- 33 En-cours de production de services
INSERT INTO rubrique (code_rubrique, libelle, id_classe) VALUES
('33', 'En-cours de production de services', (SELECT id_classe FROM classe WHERE code_classe = '3'));

INSERT INTO compte (code_compte, libelle, id_rubrique) VALUES
('331', 'Services en-cours A', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '33')),
('332', 'Services en-cours B', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '33')),
('338', 'Autres en-cours de production de services', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '33'));

-- 34 Produits intermediaires et finis
INSERT INTO rubrique (code_rubrique, libelle, id_classe) VALUES
('34', 'Produits intermediaires et finis', (SELECT id_classe FROM classe WHERE code_classe = '3'));

INSERT INTO compte (code_compte, libelle, id_rubrique) VALUES
('341', 'Produits intermediaires', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '34')),
('345', 'Produits finis', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '34'));

-- 35 Stocks de marchandises
INSERT INTO rubrique (code_rubrique, libelle, id_classe) VALUES
('35', 'Stocks de marchandises', (SELECT id_classe FROM classe WHERE code_classe = '3'));

INSERT INTO compte (code_compte, libelle, id_rubrique) VALUES
('351', 'Marchandises A', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '35')),
('352', 'Marchandises B', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '35')),
('358', 'Autres marchandises', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '35'));

-- 36 Disponible
INSERT INTO rubrique (code_rubrique, libelle, id_classe) VALUES
('36', '(Disponible)', (SELECT id_classe FROM classe WHERE code_classe = '3'));

-- 37 Stocks provenant dapprovisionnements
INSERT INTO rubrique (code_rubrique, libelle, id_classe) VALUES
('37', 'Stocks provenant dapprovisionnements', (SELECT id_classe FROM classe WHERE code_classe = '3'));

INSERT INTO compte (code_compte, libelle, id_rubrique) VALUES
('371', 'Matiere ou fournitures A', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '37')),
('372', 'Matiere ou fournitures B', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '37')),
('378', 'Autres stocks provenant dapprovisionnements', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '37'));

-- 38 Stocks provenant dimmobilisations
INSERT INTO rubrique (code_rubrique, libelle, id_classe) VALUES
('38', 'Stocks provenant dimmobilisations', (SELECT id_classe FROM classe WHERE code_classe = '3'));

INSERT INTO compte (code_compte, libelle, id_rubrique) VALUES
('381', 'Immobilisations destinees a la vente', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '38'));

-- 39 Pertes de valeur sur stocks et en-cours
INSERT INTO rubrique (code_rubrique, libelle, id_classe) VALUES
('39', 'Pertes de valeur sur stocks et en-cours', (SELECT id_classe FROM classe WHERE code_classe = '3'));

INSERT INTO compte (code_compte, libelle, id_rubrique) VALUES
('391', 'Perte de valeur sur matieres premieres et fournitures', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '39')),
('392', 'Perte de valeur sur autres approvisionnements', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '39')),
('393', 'Perte de valeur sur en-cours de production de biens', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '39')),
('394', 'Perte de valeur sur en-cours de production de services', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '39')),
('395', 'Perte de valeur sur produits', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '39')),
('397', 'Perte de valeur sur stocks provenant dapprovisionnements', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '39')),
('398', 'Perte de valeur sur stocks provenant dimmobilisations', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '39'));
