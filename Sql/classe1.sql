-- =====================================
-- INSERTIONS CLASSE 1 - Comptes de capitaux (sans accents ni cedilles)
-- =====================================

-- Classe 1
INSERT INTO classes ("Code", "Libelle") VALUES
('1', 'Comptes de capitaux');

-- Rubriques et comptes
-- 10 Capital, reserves et assimiles
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('10', 'Capital, reserves et assimiles', 1);

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('101', 'Capital', 1),
('104', 'Primes liees au capital social', 1),
('105', 'Ecart de evaluation', 1),
('106', 'Reserves', 1),
('107', 'Ecart de equivalence', 1),
('108', 'Compte de lexploitant', 1),
('109', 'Actionnaires, capital souscrit non appele', 1);

-- 11 Report a nouveau
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('11', 'Report a nouveau', 1);

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('110', 'Report a nouveau solde crediteur', 2),
('119', 'Report a nouveau solde debiteur', 2);

-- 12 Resultat de lexercice
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('12', 'Resultat de lexercice', 1);

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('120', 'Resultat de lexercice (benefice)', 3),
('129', 'Resultat de lexercice (perte)', 3);

-- 13 Produits et charges differes - hors cycle dexploitation
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('13', 'Produits et charges differes - hors cycle dexploitation', 1);

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('131', 'Subventions dequipement', 4),
('132', 'Autres subventions dinvestissement', 4),
('133', 'Impots differes actif', 4),
('134', 'Impots differes passif', 4),
('138', 'Autres produits et charges differes', 4);

-- 14 Disponible
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('14', '(Disponible)', 1);

-- 15 Provisions pour charges - passifs non courants
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('15', 'Provisions pour charges - passifs non courants', 1);

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('153', 'Provisions pour pensions et obligations similaires', 6),
('155', 'Provisions pour impots', 6),
('156', 'Provisions pour renouvellement des immobilisations (concession)', 6),
('158', 'Autres provisions pour charges - passifs non courants', 6);

-- 16 Emprunts et dettes assimiles
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('16', 'Emprunts et dettes assimiles', 1);

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('161', 'Emprunts obligataires convertibles', 7),
('163', 'Autres emprunts obligataires', 7),
('164', 'Emprunts aupres des etablissements de credit', 7),
('165', 'Depots et cautionnements recus', 7),
('167', 'Dettes sur contrat de location-financement', 7),
('168', 'Autres emprunts et dettes assimiles', 7),
('169', 'Primes de remboursement des obligations', 7);

-- 17 Dettes rattachees a des participations
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('17', 'Dettes rattachees a des participations', 1);

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('171', 'Dettes rattachees a des participations groupe', 8),
('172', 'Dettes rattachees a des participations hors groupe', 8),
('173', 'Dettes rattachees a des societes en participation', 8),
('178', 'Autres dettes rattachees a des participations', 8);

-- 18 Comptes de liaison des etablissements et societes en participation
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('18', 'Comptes de liaison des etablissements et societes en participation', 1);

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('181', 'Comptes de liaison entre etablissements', 9),
('188', 'Comptes de liaison entre societes en participation', 9);

-- 19 Disponible
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('19', '(Disponible)', 1);
