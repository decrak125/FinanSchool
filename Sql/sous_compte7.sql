-- =====================================
-- SOUS COMPTES POUR CLASSE 7 - RAITRA KIDZ
-- =====================================

-- Sous comptes pour 701 Ventes de produits finis
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('701001', 'Ventes de manuels scolaires produits en interne', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '701')),
('701002', 'Ventes de cahiers personnalises ecole', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '701')),
('701003', 'Ventes de uniformes scolaires fabriques', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '701'));

-- Sous comptes pour 702 Ventes de produits intermediaires
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('702001', 'Vente de polycopies', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '702')),
('702002', 'Vente de fascicules de cours', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '702'));

-- Sous comptes pour 703 Ventes de produits residuels
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('703001', 'Vente de materiels scolaires usagers', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '703')),
('703002', 'Vente de livres anciens ou surplus', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '703'));

-- Sous comptes pour 704 Ventes de travaux
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('704001', 'Travaux realises par eleves (expos, projets)', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '704')),
('704002', 'Travaux pratiques vendus', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '704'));

-- Sous comptes pour 705 Vente etudes
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('705001', 'Etudes ou recherches pedagogiques', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '705'));

-- Sous comptes pour 706 Prestations de service
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('706001', 'Frais de scolarite', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '706')),
('706002', 'Frais dinscription', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '706')),
('706003', 'Frais de transport scolaire', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '706')),
('706004', 'Frais de cantine', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '706')),
('706005', 'Frais de garderie', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '706'));

-- Sous comptes pour 707 Ventes de marchandises
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('707001', 'Vente de fournitures scolaires', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '707')),
('707002', 'Vente de uniformes scolaires', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '707')),
('707003', 'Vente de articles divers (snack, boissons)', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '707'));

-- Sous comptes pour 708 Produits annexes
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('708001', 'Location salles ou materiels', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '708')),
('708002', 'Organisation fetes et evenements', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '708')),
('708003', 'Club parascolaire (sport musique art)', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '708'));

-- Sous comptes pour 709 Rabais remises ristournes
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('709001', 'Remises frais de scolarite', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '709')),
('709002', 'Rabais sur ventes de fournitures', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '709'));

-- Sous comptes pour 713 Variation de stocks en cours
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('713001', 'Variation stock fournitures', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '713')),
('713002', 'Variation stock uniformes', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '713'));

-- Sous comptes pour 714 Variation de stocks produits
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('714001', 'Variation stock livres', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '714')),
('714002', 'Variation stock marchandises annexes', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '714'));

-- Sous comptes pour 721 Production immobilisee incorporelle
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('721001', 'Developpement logiciel pedagogique', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '721'));

-- Sous comptes pour 722 Production immobilisee corporelle
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('722001', 'Amenagements classes ou laboratoires', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '722'));

-- Sous comptes pour 741 Subvention dequilibre
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('741001', 'Subvention de lEtat', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '741')),
('741002', 'Subvention dautorites locales', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '741'));

-- Sous comptes pour 748 Autres subventions dexploitation
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('748001', 'Subvention ONG et associations', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '748')),
('748002', 'Subvention entreprises privees', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '748'));

-- Sous comptes pour 751 Redevances concessions licences
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('751001', 'Location logiciels pedagogiques', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '751')),
('751002', 'Utilisation brevets pedagogiques', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '751'));

-- Sous comptes pour 752 Plus values sur cessions
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('752001', 'Cession anciens ordinateurs', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '752')),
('752002', 'Cession anciens vehicules scolaires', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '752'));

-- Sous comptes pour 753 Jetons de presence
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('753001', 'Remuneration conseil administration', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '753'));

-- Sous comptes pour 754 Quotes parts subventions investissement
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('754001', 'Subventions constructions batiments', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '754'));

-- Sous comptes pour 756 Liberalites percues
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('756001', 'Dons de materiels scolaires', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '756')),
('756002', 'Dons financiers', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '756'));

-- Sous comptes pour 757 Produits exceptionnels
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('757001', 'Produits exceptionnels sur gestion', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '757'));

-- Sous comptes pour 758 Autres produits courants
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('758001', 'Revenus divers non specifies', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '758'));

-- Sous comptes pour 761 Produits de participations
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('761001', 'Revenus participation associations scolaires', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '761'));

-- Sous comptes pour 763 Revenus autres creances
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('763001', 'Revenus creances sur parents', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '763'));

-- Sous comptes pour 764 Revenus valeurs mobilieres
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('764001', 'Revenus placement court terme', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '764'));

-- Sous comptes pour 766 Gains de change
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('766001', 'Gains sur operations devises', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '766'));

-- Sous comptes pour 768 Autres produits financiers
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('768001', 'Produits financiers divers', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '768'));

-- Sous comptes pour 781 Reprise exploitation actifs non courants
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('781001', 'Reprise sur batiments', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '781')),
('781002', 'Reprise sur materiels', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '781'));

-- Sous comptes pour 785 Reprise exploitation actifs courants
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('785001', 'Reprise sur stocks', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '785'));

-- Sous comptes pour 786 Reprises financieres
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('786001', 'Reprise sur emprunts', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '786')),
('786002', 'Reprise sur creances douteuses', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '786'));
