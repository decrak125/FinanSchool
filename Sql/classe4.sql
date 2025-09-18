-- =====================================
-- INSERTIONS CLASSE 4 - Comptes de tiers
-- =====================================

-- Classe 4
INSERT INTO classe (code_classe, libelle) VALUES
('4', 'Comptes de tiers');

-- 40 Fournisseurs et comptes rattaches
INSERT INTO rubrique (code_rubrique, libelle, id_classe) VALUES
('40', 'Fournisseurs et comptes rattaches', (SELECT id_classe FROM classe WHERE code_classe = '4'));

INSERT INTO compte (code_compte, libelle, id_rubrique) VALUES
('401', 'Fournisseurs', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '40')),
('403', 'Fournisseurs - effets a payer', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '40')),
('408', 'Fournisseurs - factures non parvenues', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '40')),
('409', 'Fournisseurs debiteurs', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '40'));

-- 41 Clients et comptes rattaches
INSERT INTO rubrique (code_rubrique, libelle, id_classe) VALUES
('41', 'Clients et comptes rattaches', (SELECT id_classe FROM classe WHERE code_classe = '4'));

INSERT INTO compte (code_compte, libelle, id_rubrique) VALUES
('411', 'Clients', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '41')),
('413', 'Clients - effets a recevoir', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '41')),
('418', 'Clients - produits non encore factures', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '41')),
('419', 'Clients crediteurs', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '41'));

-- 42 Personnel et comptes rattaches
INSERT INTO rubrique (code_rubrique, libelle, id_classe) VALUES
('42', 'Personnel et comptes rattaches', (SELECT id_classe FROM classe WHERE code_classe = '4'));

INSERT INTO compte (code_compte, libelle, id_rubrique) VALUES
('421', 'Personnel - remunerations dues', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '42')),
('425', 'Personnel - avances et acomptes', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '42')),
('428', 'Personnel - charges a payer et produits a recevoir', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '42')),
('431', 'Securite sociale', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '42')),
('437', 'Autres organismes sociaux', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '42')),
('438', 'Organismes sociaux - charges a payer et produits a recevoir', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '42'));

-- 43 Etat et autres collectivites publiques
INSERT INTO rubrique (code_rubrique, libelle, id_classe) VALUES
('43', 'Etat et autres collectivites publiques', (SELECT id_classe FROM classe WHERE code_classe = '4'));

INSERT INTO compte (code_compte, libelle, id_rubrique) VALUES
('431', 'Etat - impots et taxes', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '43')),
('437', 'Etat - subventions a recevoir', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '43')),
('438', 'Etat - charges a payer et produits a recevoir', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '43'));

-- 44 Groupes et associes
INSERT INTO rubrique (code_rubrique, libelle, id_classe) VALUES
('44', 'Groupes et associes', (SELECT id_classe FROM classe WHERE code_classe = '4'));

INSERT INTO compte (code_compte, libelle, id_rubrique) VALUES
('441', 'Groupes', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '44')),
('445', 'Associes - comptes courants', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '44'));

-- 45 Debiteurs divers et crediteurs divers
INSERT INTO rubrique (code_rubrique, libelle, id_classe) VALUES
('45', 'Debiteurs divers et crediteurs divers', (SELECT id_classe FROM classe WHERE code_classe = '4'));

INSERT INTO compte (code_compte, libelle, id_rubrique) VALUES
('451', 'Debiteurs divers', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '45')),
('455', 'Crediteurs divers', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '45'));

-- 46 Comptes transitoires ou d'attente
INSERT INTO rubrique (code_rubrique, libelle, id_classe) VALUES
('46', 'Comptes transitoires ou dattente', (SELECT id_classe FROM classe WHERE code_classe = '4'));

INSERT INTO compte (code_compte, libelle, id_rubrique) VALUES
('461', 'Comptes de liaison interne', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '46')),
('462', 'Comptes dordre', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '46')),
('468', 'Autres comptes transitoires', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '46'));

-- 47 Comptes rattaches a des operations de financement
INSERT INTO rubrique (code_rubrique, libelle, id_classe) VALUES
('47', 'Comptes rattaches a des operations de financement', (SELECT id_classe FROM classe WHERE code_classe = '4'));

INSERT INTO compte (code_compte, libelle, id_rubrique) VALUES
('471', 'Dettes de financement a court terme', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '47')),
('472', 'Creances de financement a court terme', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '47'));

-- 48 Comptes de regularisation
INSERT INTO rubrique (code_rubrique, libelle, id_classe) VALUES
('48', 'Comptes de regularisation', (SELECT id_classe FROM classe WHERE code_classe = '4'));

INSERT INTO compte (code_compte, libelle, id_rubrique) VALUES
('481', 'Charges constatees davance', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '48')),
('482', 'Produits constates davance', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '48')),
('486', 'Charges a repartir', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '48')),
('487', 'Produits a repartir', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '48'));

-- 49 Pertes de valeur des comptes de tiers
INSERT INTO rubrique (code_rubrique, libelle, id_classe) VALUES
('49', 'Pertes de valeur des comptes de tiers', (SELECT id_classe FROM classe WHERE code_classe = '4'));

INSERT INTO compte (code_compte, libelle, id_rubrique) VALUES
('491', 'Perte de valeur sur clients', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '49')),
('495', 'Perte de valeur sur comptes rattaches', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '49')),
('498', 'Autres pertes de valeur sur comptes de tiers', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '49'));
