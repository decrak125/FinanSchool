
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
