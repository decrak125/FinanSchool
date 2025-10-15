
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

ALTER TABLE Ligne_ecriture
ADD COLUMN statut VARCHAR(20) DEFAULT 'brouillon' NOT NULL, -- brouillon | valide | annule
ADD COLUMN date_validation TIMESTAMP NULL,
ADD COLUMN valide_par INT NULL,
ADD CONSTRAINT fk_valide_par FOREIGN KEY (valide_par) REFERENCES Users(id);

CREATE OR REPLACE VIEW vue_grand_livre AS
WITH sous_compte_totals AS (
    SELECT
        sc."Id_Sous_compte",
        SUM(le."Debit") AS total_debit_sous_compte,
        SUM(le."Credit") AS total_credit_sous_compte,
        SUM(le."Debit") - SUM(le."Credit") AS solde_final_sous_compte
    FROM "ligne_ecritures" le
    JOIN "sous_comptes" sc ON le."Id_Sous_compte" = sc."Id_Sous_compte"
    GROUP BY sc."Id_Sous_compte"
),
compte_totals AS (
    SELECT
        c."Id_Compte",
        SUM(le."Debit") AS total_debit_compte,
        SUM(le."Credit") AS total_credit_compte,
        SUM(le."Debit") - SUM(le."Credit") AS solde_final_compte
    FROM "ligne_ecritures" le
    JOIN "sous_comptes" sc ON le."Id_Sous_compte" = sc."Id_Sous_compte"
    JOIN "comptes" c ON sc."Id_Compte" = c."Id_Compte"
    GROUP BY c."Id_Compte"
)
SELECT
    c."Code_compte"        AS code_compte,
    c."Libelle"            AS libelle_compte,
    sc."Code_sous_compte"  AS code_sous_compte,
    sc."Libelle"           AS libelle_sous_compte,
    me."Date_mouvement"    AS date_mouvement,
    me."Numero_piece"      AS numero_piece,
    le."Libelle"           AS libelle_ecriture,
    le."Debit",
    le."Credit",
    SUM(le."Debit" - le."Credit") OVER (
        PARTITION BY sc."Id_Sous_compte"
        ORDER BY me."Date_mouvement", le."Id_Ligne_ecriture"
    ) AS solde_progressif,
    sct.solde_final_sous_compte,
    ct.solde_final_compte
FROM "ligne_ecritures" le
JOIN "sous_comptes" sc ON le."Id_Sous_compte" = sc."Id_Sous_compte"
JOIN "comptes" c ON sc."Id_Compte" = c."Id_Compte"
JOIN "mouvement_ecritures" me ON le."Id_Mouvement_ecriture" = me."Id_Mouvement_ecriture"
JOIN sous_compte_totals sct ON sc."Id_Sous_compte" = sct."Id_Sous_compte"
JOIN compte_totals ct ON c."Id_Compte" = ct."Id_Compte"
WHERE me."Date_mouvement" BETWEEN '2025-01-01' AND '2025-12-31'
ORDER BY c."Code_compte" ASC,
         sc."Code_sous_compte" ASC,
         me."Date_mouvement",
         le."Id_Ligne_ecriture";


CREATE OR REPLACE VIEW vue_grand_livre AS
WITH sous_compte_totals AS (
    SELECT
        sc."Id_Sous_compte",
        SUM(le."Debit") AS total_debit_sous_compte,
        SUM(le."Credit") AS total_credit_sous_compte,
        SUM(le."Debit") - SUM(le."Credit") AS solde_final_sous_compte
    FROM "ligne_ecritures" le
    JOIN "sous_comptes" sc ON le."Id_Sous_compte" = sc."Id_Sous_compte"
    GROUP BY sc."Id_Sous_compte"
),
compte_totals AS (
    SELECT
        c."Id_Compte",
        SUM(le."Debit") AS total_debit_compte,
        SUM(le."Credit") AS total_credit_compte,
        SUM(le."Debit") - SUM(le."Credit") AS solde_final_compte
    FROM "ligne_ecritures" le
    JOIN "sous_comptes" sc ON le."Id_Sous_compte" = sc."Id_Sous_compte"
    JOIN "comptes" c ON sc."Id_Compte" = c."Id_Compte"
    GROUP BY c."Id_Compte"
)
SELECT
    c."Code_compte"        AS code_compte,
    c."Libelle"            AS libelle_compte,
    sc."Code_sous_compte"  AS code_sous_compte,
    sc."Libelle"           AS libelle_sous_compte,
    me."Date_mouvement"    AS date_mouvement,
    me."Numero_piece"      AS numero_piece,
    le."Libelle"           AS libelle_ecriture,
    le."Debit",
    le."Credit",
    SUM(le."Debit" - le."Credit") OVER (
        PARTITION BY sc."Id_Sous_compte"
        ORDER BY me."Date_mouvement", le."Id_Ligne_ecriture"
    ) AS solde_progressif,
    sct.solde_final_sous_compte,
    ct.solde_final_compte
FROM "ligne_ecritures" le
JOIN "sous_comptes" sc ON le."Id_Sous_compte" = sc."Id_Sous_compte"
JOIN "comptes" c ON sc."Id_Compte" = c."Id_Compte"
JOIN "mouvement_ecritures" me ON le."Id_Mouvement_ecriture" = me."Id_Mouvement_ecriture"
JOIN sous_compte_totals sct ON sc."Id_Sous_compte" = sct."Id_Sous_compte"
JOIN compte_totals ct ON c."Id_Compte" = ct."Id_Compte"
ORDER BY c."Code_compte" ASC,
         sc."Code_sous_compte" ASC,
         me."Date_mouvement",
         le."Id_Ligne_ecriture";



CREATE OR REPLACE VIEW vue_balance_generale AS
SELECT
    c."Code_compte"        AS code_compte,
    c."Libelle"            AS libelle_compte,
    sc."Code_sous_compte"  AS code_sous_compte,
    sc."Libelle"           AS libelle_sous_compte,
    COALESCE(SUM(le."Debit"), 0) AS total_debit,
    COALESCE(SUM(le."Credit"), 0) AS total_credit,
    COALESCE(SUM(le."Debit") - SUM(le."Credit"), 0) AS solde_final,
    me."Date_mouvement"    AS date_mouvement
FROM "ligne_ecritures" le
JOIN "sous_comptes" sc ON le."Id_Sous_compte" = sc."Id_Sous_compte"
JOIN "comptes" c ON sc."Id_Compte" = c."Id_Compte"
JOIN "mouvement_ecritures" me ON le."Id_Mouvement_ecriture" = me."Id_Mouvement_ecriture"
GROUP BY c."Code_compte", c."Libelle", sc."Code_sous_compte", sc."Libelle", me."Date_mouvement"
ORDER BY c."Code_compte", sc."Code_sous_compte";


-- Version avec contraintes supplémentaires
CREATE TABLE Exercice_comptable(
   Id_Exercice_comptable SERIAL PRIMARY KEY,
   Date_debut DATE NOT NULL UNIQUE,
   Date_fin DATE NOT NULL UNIQUE,
   Statut VARCHAR(50) NOT NULL CHECK (Statut IN ('OUVERT', 'CLOTURE', 'PROVISOIRE')),
   Annee_fiscale SMALLINT NOT NULL CHECK (Annee_fiscale BETWEEN 2000 AND 2100),
   CONSTRAINT chk_dates CHECK (Date_fin > Date_debut)
);

-- Création d'index pour les recherches par année
CREATE INDEX idx_exercice_annee ON Exercice_comptable(Annee_fiscale);



CREATE TABLE intervalle_comptes_categorie (
    id SERIAL PRIMARY KEY,
    compte_debut VARCHAR(10),
    compte_fin VARCHAR(10),
    id_categorie_fonctionelle INT,
    FOREIGN KEY (id_categorie_fonctionelle) REFERENCES categorie_fonctionelles(id_categorie_fonctionelle)
);

INSERT INTO intervalle_comptes_categorie (compte_debut, compte_fin, id_categorie_fonctionelle)
VALUES ('700', '710', (SELECT id_categorie_fonctionelle FROM categorie_fonctionelles WHERE code = 'CA'));

INSERT INTO compte_categories (id_sous_compte, id_categorie_fonctionelle, poids, date_debut, actif)
SELECT sc."Id_Sous_compte", icc."id_categorie_fonctionelle", 1, CURRENT_DATE, true
FROM sous_comptes sc
JOIN comptes c ON sc."Id_Compte" = c."Id_Compte"
JOIN intervalle_comptes_categorie icc 
  ON c."Code_compte"::bigint >= icc.compte_debut::bigint 
 AND c."Code_compte"::bigint <= icc.compte_fin::bigint;

SELECT 
    cf.code,
    cf.libelle,
    SUM(
        CASE 
            WHEN le."Debit" > 0 THEN le."Debit" 
            ELSE le."Credit" 
        END
    ) as montant_total
FROM ligne_ecritures le
JOIN sous_comptes sc ON le."Id_Sous_compte" = sc."Id_Sous_compte"
JOIN compte_categories cc ON sc."Id_Sous_compte" = cc."id_sous_compte"
JOIN categorie_fonctionelles cf ON cc.id_categorie_fonctionelle = cf.id_categorie_fonctionelle
WHERE cf.code = 'AUTCHOP'
    AND cc.actif = true
    AND le.statut = 'valide'
    AND le.date_validation BETWEEN '2024-01-01' AND '2024-12-31'
GROUP BY cf.id_categorie_fonctionelle, cf.code, cf.libelle;