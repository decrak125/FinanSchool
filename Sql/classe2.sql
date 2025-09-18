-- =====================================
-- INSERTIONS CLASSE 2 - Comptes dimmobilisations
-- =====================================

-- Classe 2
INSERT INTO classe (code_classe, libelle) VALUES
('2', 'Comptes dimmobilisations');

-- 20 Immobilisations incorporelles
INSERT INTO rubrique (code_rubrique, libelle, id_classe) VALUES
('20', 'Immobilisations incorporelles', (SELECT id_classe FROM classe WHERE code_classe = '2'));

INSERT INTO compte (code_compte, libelle, id_rubrique) VALUES
('203', 'Frais de developpement immobilisables', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '20')),
('204', 'Logiciels informatiques et assimiles', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '20')),
('205', 'Concessions et droits similaires, brevets, licences, marques', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '20')),
('207', 'Fonds commercial', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '20')),
('208', 'Autres immobilisations incorporelles', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '20'));

-- 21 Immobilisations corporelles
INSERT INTO rubrique (code_rubrique, libelle, id_classe) VALUES
('21', 'Immobilisations corporelles', (SELECT id_classe FROM classe WHERE code_classe = '2'));

INSERT INTO compte (code_compte, libelle, id_rubrique) VALUES
('211', 'Terrains', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '21')),
('212', 'Agencements et amenagements de terrain', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '21')),
('213', 'Constructions', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '21')),
('215', 'Installations techniques', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '21')),
('218', 'Autres immobilisations corporelles', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '21'));

-- 22 Immobilisations mises en concession
INSERT INTO rubrique (code_rubrique, libelle, id_classe) VALUES
('22', 'Immobilisations mises en concession', (SELECT id_classe FROM classe WHERE code_classe = '2'));

INSERT INTO compte (code_compte, libelle, id_rubrique) VALUES
('221', 'Terrains en concession', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '22')),
('222', 'Agencements et amenagements de terrain en concession', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '22')),
('223', 'Constructions en concession', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '22')),
('225', 'Installations techniques en concession', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '22')),
('228', 'Autres immobilisations corporelles en concession', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '22')),
('229', 'Droits du concedant', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '22'));

-- 23 Immobilisations en cours
INSERT INTO rubrique (code_rubrique, libelle, id_classe) VALUES
('23', 'Immobilisations en cours', (SELECT id_classe FROM classe WHERE code_classe = '2'));

INSERT INTO compte (code_compte, libelle, id_rubrique) VALUES
('232', 'Immobilisations corporelles en cours', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '23')),
('237', 'Immobilisations incorporelles en cours', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '23')),
('238', 'Avances et acomptes verses sur commandes dimmobilisations', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '23'));

-- 24 Disponible
INSERT INTO rubrique (code_rubrique, libelle, id_classe) VALUES
('24', '(Disponible)', (SELECT id_classe FROM classe WHERE code_classe = '2'));

-- 25 Disponible
INSERT INTO rubrique (code_rubrique, libelle, id_classe) VALUES
('25', '(Disponible)', (SELECT id_classe FROM classe WHERE code_classe = '2'));

-- 26 Participations et creances rattachees a des participations
INSERT INTO rubrique (code_rubrique, libelle, id_classe) VALUES
('26', 'Participations et creances rattachees a des participations', (SELECT id_classe FROM classe WHERE code_classe = '2'));

INSERT INTO compte (code_compte, libelle, id_rubrique) VALUES
('261', 'Titres de participation', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '26')),
('262', 'Autres formes de participations', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '26')),
('265', 'Titres de participation evalues par equivalence', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '26')),
('266', 'Creances rattachees a des participations groupe', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '26')),
('267', 'Creances rattachees a des participations hors groupe', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '26')),
('268', 'Creances rattachees a des societes en participation', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '26')),
('269', 'Versements restant a effectuer sur titres de participation non liberes', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '26'));

-- 27 Autres immobilisations financieres
INSERT INTO rubrique (code_rubrique, libelle, id_classe) VALUES
('27', 'Autres immobilisations financieres', (SELECT id_classe FROM classe WHERE code_classe = '2'));

INSERT INTO compte (code_compte, libelle, id_rubrique) VALUES
('271', 'Titres immobilises autres que titres immobilises de lactivite de portefeuille', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '27')),
('272', 'Titres representatifs de droit de creance (obligations, bons)', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '27')),
('273', 'Titres immobilises de lactivite de portefeuille', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '27')),
('274', 'Prets', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '27')),
('275', 'Depots et cautionnements verses', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '27')),
('276', 'Autres creances immobilisees', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '27')),
('277', 'Actions propres (ou parts propres)', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '27')),
('279', 'Versements restant a effectuer sur titres immobilises non liberes', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '27'));

-- 28 Amortissements des immobilisations
INSERT INTO rubrique (code_rubrique, libelle, id_classe) VALUES
('28', 'Amortissements des immobilisations', (SELECT id_classe FROM classe WHERE code_classe = '2'));

INSERT INTO compte (code_compte, libelle, id_rubrique) VALUES
('280', 'Amortissement des immobilisations incorporelles', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '28')),
('281', 'Amortissement des immobilisations corporelles', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '28')),
('282', 'Amortissement des immobilisations mises en concession', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '28'));

-- 29 Pertes de valeur sur immobilisations
INSERT INTO rubrique (code_rubrique, libelle, id_classe) VALUES
('29', 'Pertes de valeur sur immobilisations', (SELECT id_classe FROM classe WHERE code_classe = '2'));

INSERT INTO compte (code_compte, libelle, id_rubrique) VALUES
('290', 'Perte de valeur sur immobilisations incorporelles', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '29')),
('291', 'Perte de valeur sur immobilisations corporelles', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '29')),
('292', 'Depreciation sur immobilisations mises en concession', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '29')),
('293', 'Perte de valeur sur immobilisations en cours', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '29')),
('296', 'Perte de valeur sur participations et creances rattachees a participations', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '29')),
('297', 'Perte de valeur sur autres immobilisations financieres', (SELECT id_rubrique FROM rubrique WHERE code_rubrique = '29'));
