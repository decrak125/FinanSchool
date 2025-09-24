
CREATE TABLE Classe (
    Id_Classe SERIAL PRIMARY KEY,
    Code VARCHAR(1) NOT NULL UNIQUE,
    Libelle VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE Rubrique (
    Id_Rubrique SERIAL PRIMARY KEY,
    Code_rubrique VARCHAR(2) NOT NULL UNIQUE,
    Libelle VARCHAR(255) NOT NULL UNIQUE,
    Id_Classe INT NOT NULL,
    FOREIGN KEY (Id_Classe) REFERENCES Classe(Id_Classe)
);

CREATE TABLE Compte (
    Id_Compte SERIAL PRIMARY KEY,
    Code_compte VARCHAR(3) NOT NULL UNIQUE,
    Libelle VARCHAR(255) NOT NULL UNIQUE,
    Id_Rubrique INT NOT NULL,
    FOREIGN KEY (Id_Rubrique) REFERENCES Rubrique(Id_Rubrique)
);

CREATE TABLE Sous_compte (
    Id_Sous_compte SERIAL PRIMARY KEY,
    Code_sous_compte VARCHAR(6) NOT NULL UNIQUE,
    Libelle VARCHAR(255) NOT NULL UNIQUE,
    Id_Compte INT NOT NULL,
    FOREIGN KEY (Id_Compte) REFERENCES Compte(Id_Compte)
);

-- =====================================
-- Table Type_Journal
-- =====================================
CREATE TABLE Type_Journal (
    Id_Type_Journal SERIAL PRIMARY KEY,
    Type VARCHAR(50) NOT NULL UNIQUE
);

-- =====================================
-- Table Mode_paiement
-- =====================================
CREATE TABLE Mode_paiement (
    Id_Mode_paiement SERIAL PRIMARY KEY,
    Libelle VARCHAR(50) NOT NULL UNIQUE,
    Abr VARCHAR(50) NOT NULL UNIQUE
);

-- =====================================
-- Table Journal
-- =====================================
CREATE TABLE Journal (
    Id_Journal SERIAL PRIMARY KEY,
    Code VARCHAR(50) NOT NULL UNIQUE,
    Libelle VARCHAR(50) NOT NULL,
    Id_Type_Journal INT NOT NULL,
    Id_Sous_compte INT,
    FOREIGN KEY (Id_Type_Journal) REFERENCES Type_Journal(Id_Type_Journal),
    FOREIGN KEY (Id_Sous_compte) REFERENCES Sous_comptes("Id_Sous_compte")
);

-- =====================================
-- Table Mouvement_ecriture
-- =====================================
CREATE TABLE Mouvement_ecriture (
    Id_Mouvement_ecriture SERIAL PRIMARY KEY,
    Date_mouvement DATE NOT NULL,
    Numero_piece VARCHAR(50),
    Id_Journal INT NOT NULL,
    FOREIGN KEY (Id_Journal) REFERENCES Journal(Id_Journal)
);

-- =====================================
-- Table Ligne_ecriture
-- =====================================
CREATE TABLE Ligne_ecriture (
    Id_Ligne_ecriture SERIAL PRIMARY KEY,
    Libelle VARCHAR(255) NOT NULL,
    Debit NUMERIC(15,2) NOT NULL,
    Credit NUMERIC(15,2) NOT NULL,
    Reference VARCHAR(50),
    Quantite INT,
    Id_Mode_paiement INT,
    Id_Mouvement_ecriture INT NOT NULL,
    Id_Journal INT NOT NULL,
    Id_Sous_compte INT NOT NULL,
    FOREIGN KEY (Id_Mode_paiement) REFERENCES Mode_paiement(Id_Mode_paiement),
    FOREIGN KEY (Id_Mouvement_ecriture) REFERENCES Mouvement_ecriture(Id_Mouvement_ecriture),
    FOREIGN KEY (Id_Journal) REFERENCES Journal(Id_Journal),
    FOREIGN KEY (Id_Sous_compte) REFERENCES Sous_comptes("Id_Sous_compte")
);

-- ANALATYQUE LELENTY E 


-- Table des axes analytiques (cycle, nature, etc.)
CREATE TABLE AxesAnalytique (
    id_axe SERIAL PRIMARY KEY,
    axe VARCHAR(100) NOT NULL,
    description VARCHAR(100) NOT NULL
);

-- Table des types de centre (coût, profit, etc.)
CREATE TABLE TypeCentre (
    id_type SERIAL PRIMARY KEY,
    code VARCHAR(20) NOT NULL,
    libelle VARCHAR(100) NOT NULL
);

-- Table des centres analytiques
CREATE TABLE CentreAnalytique (
    id_centre SERIAL PRIMARY KEY,
    nom VARCHAR(150) NOT NULL,
    description VARCHAR(100) NOT NULL,
    id_axe INT NOT NULL REFERENCES AxesAnalytique(id_axe),
    id_type INT NOT NULL REFERENCES TypeCentre(id_type)
);

-- Table des affectations analytiques
CREATE TABLE AffectationAnalytique (
    id_affectation SERIAL PRIMARY KEY,
    Id_Sous_compte INT NOT NULL REFERENCES Sous_comptes("Id_Sous_compte"), -- à relier à ta table SousCompte plus tard
    id_centre INT NOT NULL REFERENCES CentreAnalytique(id_centre),
    description VARCHAR(100) NOT NULL
);
