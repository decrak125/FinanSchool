
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