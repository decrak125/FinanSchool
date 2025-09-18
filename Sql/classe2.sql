-- =====================================
-- INSERTIONS CLASSE 2 - Comptes dimmobilisations
-- =====================================

-- Classe 2
INSERT INTO classes ("Code", "Libelle") VALUES
('2', 'Comptes dimmobilisations');

-- 20 Immobilisations incorporelles
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('20', 'Immobilisations incorporelles', (SELECT "Id_Classe" FROM classes WHERE "Code" = '2'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('203', 'Frais de developpement immobilisables', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '20')),
('204', 'Logiciels informatiques et assimiles', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '20')),
('205', 'Concessions et droits similaires, brevets, licences, marques', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '20')),
('207', 'Fonds commercial', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '20')),
('208', 'Autres immobilisations incorporelles', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '20'));

-- 21 Immobilisations corporelles
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('21', 'Immobilisations corporelles', (SELECT "Id_Classe" FROM classes WHERE "Code" = '2'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('211', 'Terrains', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '21')),
('212', 'Agencements et amenagements de terrain', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '21')),
('213', 'Constructions', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '21')),
('215', 'Installations techniques', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '21')),
('218', 'Autres immobilisations corporelles', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '21'));

-- 22 Immobilisations mises en concession
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('22', 'Immobilisations mises en concession', (SELECT "Id_Classe" FROM classes WHERE "Code" = '2'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('221', 'Terrains en concession', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '22')),
('222', 'Agencements et amenagements de terrain en concession', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '22')),
('223', 'Constructions en concession', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '22')),
('225', 'Installations techniques en concession', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '22')),
('228', 'Autres immobilisations corporelles en concession', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '22')),
('229', 'Droits du concedant', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '22'));

-- 23 Immobilisations en cours
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('23', 'Immobilisations en cours', (SELECT "Id_Classe" FROM classes WHERE "Code" = '2'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('232', 'Immobilisations corporelles en cours', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '23')),
('237', 'Immobilisations incorporelles en cours', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '23')),
('238', 'Avances et acomptes verses sur commandes dimmobilisations', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '23'));

-- 24 Disponible
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('24', '(Disponible)', (SELECT "Id_Classe" FROM classes WHERE "Code" = '2'));

-- 25 Disponible
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('25', '(Disponible)', (SELECT "Id_Classe" FROM classes WHERE "Code" = '2'));

-- 26 Participations et creances rattachees a des participations
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('26', 'Participations et creances rattachees a des participations', (SELECT "Id_Classe" FROM classes WHERE "Code" = '2'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('261', 'Titres de participation', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '26')),
('262', 'Autres formes de participations', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '26')),
('265', 'Titres de participation evalues par equivalence', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '26')),
('266', 'Creances rattachees a des participations groupe', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '26')),
('267', 'Creances rattachees a des participations hors groupe', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '26')),
('268', 'Creances rattachees a des societes en participation', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '26')),
('269', 'Versements restant a effectuer sur titres de participation non liberes', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '26'));

-- 27 Autres immobilisations financieres
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('27', 'Autres immobilisations financieres', (SELECT "Id_Classe" FROM classes WHERE "Code" = '2'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('271', 'Titres immobilises autres que titres immobilises de lactivite de portefeuille', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '27')),
('272', 'Titres representatifs de droit de creance (obligations, bons)', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '27')),
('273', 'Titres immobilises de lactivite de portefeuille', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '27')),
('274', 'Prets', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '27')),
('275', 'Depots et cautionnements verses', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '27')),
('276', 'Autres creances immobilisees', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '27')),
('277', 'Actions propres (ou parts propres)', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '27')),
('279', 'Versements restant a effectuer sur titres immobilises non liberes', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '27'));

-- 28 Amortissements des immobilisations
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('28', 'Amortissements des immobilisations', (SELECT "Id_Classe" FROM classes WHERE "Code" = '2'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('280', 'Amortissement des immobilisations incorporelles', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '28')),
('281', 'Amortissement des immobilisations corporelles', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '28')),
('282', 'Amortissement des immobilisations mises en concession', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '28'));

-- 29 Pertes de valeur sur immobilisations
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('29', 'Pertes de valeur sur immobilisations', (SELECT "Id_Classe" FROM classes WHERE "Code" = '2'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('290', 'Perte de valeur sur immobilisations incorporelles', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '29')),
('291', 'Perte de valeur sur immobilisations corporelles', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '29')),
('292', 'Depreciation sur immobilisations mises en concession', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '29')),
('293', 'Perte de valeur sur immobilisations en cours', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '29')),
('296', 'Perte de valeur sur participations et creances rattachees a participations', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '29')),
('297', 'Perte de valeur sur autres immobilisations financieres', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '29'));
