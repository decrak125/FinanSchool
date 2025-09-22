-- =====================================
-- INSERTIONS CLASSE 5 - Comptes financiers
-- =====================================

-- Classe 5
INSERT INTO classes ("Code", "Libelle") VALUES
('5', 'Comptes financiers');

-- 50 Valeurs mobilieres de placement
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('50', 'Valeurs mobilieres de placement', (SELECT "Id_Classe" FROM classes WHERE "Code" = '5'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('501', 'Parts dans des entreprises liees', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '50')),
('503', 'Actions', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '50')),
('504', 'Autres titres conferant un droit de propriete', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '50')),
('505', 'Obligations et bons emis par la societe et rachetes par elle', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '50')),
('506', 'Obligations', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '50')),
('507', 'Bons du tresor et bons de caisse a court terme', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '50')),
('508', 'Autres valeurs mobilieres de placement et creances assimilees', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '50')),
('509', 'Versements restant a effectuer sur VMP non liberees', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '50'));

-- 51 Banques, etablissements financiers et assimiles
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('51', 'Banques, etablissements financiers et assimiles', (SELECT "Id_Classe" FROM classes WHERE "Code" = '5'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('511', 'Valeurs a l encaissement', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '51')),
('512', 'Banques comptes courants', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '51')),
('515', 'Caisse du Tresor Public et etablissements publics', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '51')),
('517', 'Autres organismes financiers', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '51')),
('518', 'Interets courus', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '51')),
('519', 'Concours bancaires courants', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '51'));

-- 52 Instruments de tresorerie
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('52', 'Instruments de tresorerie', (SELECT "Id_Classe" FROM classes WHERE "Code" = '5'));

-- 53 Caisse
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('53', 'Caisse', (SELECT "Id_Classe" FROM classes WHERE "Code" = '5'));

-- 54 Regies d avances et accredtitifs
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('54', 'Regies d avances et accredtitifs', (SELECT "Id_Classe" FROM classes WHERE "Code" = '5'));

-- 55 Disponible
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('55', '(Disponible)', (SELECT "Id_Classe" FROM classes WHERE "Code" = '5'));

-- 56 Disponible
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('56', '(Disponible)', (SELECT "Id_Classe" FROM classes WHERE "Code" = '5'));

-- 57 Disponible
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('57', '(Disponible)', (SELECT "Id_Classe" FROM classes WHERE "Code" = '5'));

-- 58 Virements internes
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('58', 'Virements internes', (SELECT "Id_Classe" FROM classes WHERE "Code" = '5'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('581', 'Virements de fonds', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '58')),
('588', 'Autres virements internes', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '58'));

-- 59 Pertes de valeur sur comptes financiers
INSERT INTO rubriques ("Code_rubrique", "Libelle", "Id_Classe") VALUES
('59', 'Pertes de valeur sur comptes financiers', (SELECT "Id_Classe" FROM classes WHERE "Code" = '5'));

INSERT INTO comptes ("Code_compte", "Libelle", "Id_Rubrique") VALUES
('591', 'Pertes de valeur sur valeurs en banque et etablissements financiers', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '59')),
('594', 'Pertes de valeur sur regies d avances et accredtitifs', (SELECT "Id_Rubrique" FROM rubriques WHERE "Code_rubrique" = '59'));
