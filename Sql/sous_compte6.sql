-- =====================================
-- SOUS COMPTES POUR CLASSE 6 - RAITRA KIDZ
-- =====================================

-- Sous comptes pour 601 Achats de matieres premieres
INSERT INTO Sous_compte ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('601001', 'Achats de riz pour la cantine', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '601')),
('601002', 'Achats de legumes pour la cantine', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '601')),
('601003', 'Achats de viande et poisson pour la cantine', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '601')),
('601004', 'Achats de produits laitiers et oeufs', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '601'));

-- Sous comptes pour 602 Achats de fournitures scolaires
INSERT INTO Sous_compte ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('602001', 'Cahiers et papiers', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '602')),
('602002', 'Stylos crayons et gommes', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '602')),
('602003', 'Livres et manuels scolaires', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '602')),
('602004', 'Materiel pedagogique divers', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '602'));

-- Sous comptes pour 603 Achats de fournitures de bureau
INSERT INTO Sous_compte ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('603001', 'Papeterie administrative', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '603')),
('603002', 'Cartouches et toners', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '603')),
('603003', 'Classeurs dossiers et archives', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '603'));

-- Sous comptes pour 604 Petit materiel et equipements
INSERT INTO Sous_compte ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('604001', 'Tables et chaises scolaires', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '604')),
('604002', 'Tableaux et equipements pedagogiques', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '604')),
('604003', 'Materiel informatique de base', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '604'));

-- Sous comptes pour 605 Achats eau electricite gaz
INSERT INTO Sous_compte ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('605001', 'Factures electricite', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '605')),
('605002', 'Factures eau', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '605')),
('605003', 'Factures gaz pour cantine', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '605'));

-- Sous comptes pour 606 Produits entretien et nettoyage
INSERT INTO Sous_compte ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('606001', 'Produits de nettoyage classes', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '606')),
('606002', 'Produits hygiene toilettes', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '606')),
('606003', 'Materiel de nettoyage balais serpillieres', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '606'));

-- Sous comptes pour 607 Autres approvisionnements
INSERT INTO Sous_compte ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('607001', 'Uniformes et tenues scolaires', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '607')),
('607002', 'Equipements sportifs', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '607')),
('607003', 'Materiel pour activites culturelles', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '607'));

-- Sous comptes pour 611 Loyers et charges locatives
INSERT INTO Sous_compte ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('611001', 'Loyer des salles de classe', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '611')),
('611002', 'Loyer des bureaux administratifs', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '611')),
('611003', 'Charges eau et electricite batiments', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '611'));

-- Sous comptes pour 612 Entretien et reparations
INSERT INTO Sous_compte ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('612001', 'Reparation batiments scolaires', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '612')),
('612002', 'Reparation materiel scolaire', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '612')),
('612003', 'Reparation bus scolaire', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '612'));

-- Sous comptes pour 613 Assurance
INSERT INTO Sous_compte ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('613001', 'Assurance responsabilite civile', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '613')),
('613002', 'Assurance scolaire eleves', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '613')),
('613003', 'Assurance du personnel', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '613'));

-- Sous comptes pour 617 Surveillance et securite
INSERT INTO Sous_compte ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('617001', 'Salaires agents securite', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '617')),
('617002', 'Fournitures pour gardiennage', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '617')),
('617003', 'Contrat entreprise de securite', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '617'));

-- Sous comptes pour 621 Salaires enseignants
INSERT INTO Sous_compte ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('621001', 'Salaires enseignants primaire', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '621')),
('621002', 'Salaires enseignants secondaire', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '621'));

-- Sous comptes pour 622 Salaires administratifs
INSERT INTO Sous_compte ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('622001', 'Salaires personnel administratif', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '622')),
('622002', 'Indemnites personnel administratif', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '622'));

-- Sous comptes pour 625 Charges sociales
INSERT INTO Sous_compte ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('625001', 'Cotisations CNAPS', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '625')),
('625002', 'Cotisations OSTIE', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '625')),
('625003', 'Autres charges sociales obligatoires', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '625'));

-- Sous comptes pour 633 Cantine scolaire
INSERT INTO Sous_compte ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('633001', 'Achat riz cantine', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '633')),
('633002', 'Achat legumes cantine', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '633')),
('633003', 'Achat viande et poisson cantine', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '633')),
('633004', 'Gaz cuisine cantine', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '633'));

-- Sous comptes pour 635 Transport scolaire
INSERT INTO Sous_compte ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('635001', 'Carburant bus scolaire', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '635')),
('635002', 'Reparation bus scolaire', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '635')),
('635003', 'Assurance bus scolaire', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '635'));

-- Sous comptes pour 641 Amortissements mobilier scolaire
INSERT INTO Sous_compte ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('641001', 'Tables et chaises', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '641')),
('641002', 'Armoires et etageres', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '641'));

-- Sous comptes pour 642 Amortissements materiel informatique
INSERT INTO Sous_compte ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('642001', 'Ordinateurs', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '642')),
('642002', 'Projecteurs et TV', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '642'));

-- Sous comptes pour 643 Amortissements batiments
INSERT INTO Sous_compte ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('643001', 'Batiments scolaires', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '643')),
('643002', 'Bureaux administratifs', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '643'));

-- Sous comptes pour 644 Amortissements vehicules
INSERT INTO Sous_compte ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('644001', 'Bus scolaire', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '644')),
('644002', 'Vehicules utilitaires', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '644'));

-- Sous comptes pour 651 Interets sur emprunts
INSERT INTO Sous_compte ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('651001', 'Interets credit bancaire principal', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '651')),
('651002', 'Interets credit bus scolaire', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '651'));

-- Sous comptes pour 659 Autres charges financieres
INSERT INTO Sous_compte ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('659001', 'Frais bancaires courants', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '659')),
('659002', 'Frais de change et virements', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '659'));

-- Sous comptes pour 671 Penalites et amendes
INSERT INTO Sous_compte ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('671001', 'Amendes fiscales', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '671')),
('671002', 'Amendes administratives', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '671'));

-- Sous comptes pour 672 Charges exceptionnelles
INSERT INTO Sous_compte ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('672001', 'Travaux urgents non prevus', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '672')),
('672002', 'Depenses exceptionnelles diverses', (SELECT "Id_Compte" FROM Compte WHERE "Code_compte" = '672'));
