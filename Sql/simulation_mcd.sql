-- MCD Simulation FinanSchool

-- Table Simulation (En-tête)
CREATE TABLE simulations (
    id_simulation BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nom_simulation VARCHAR(255) NOT NULL,
    date_simulation DATETIME DEFAULT CURRENT_TIMESTAMP,
    description TEXT NULL,
    id_exercice_comptable BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    CONSTRAINT fk_simulation_exercice FOREIGN KEY (id_exercice_comptable) 
        REFERENCES exercice_comptable(Id_Exercice_comptable) ON DELETE CASCADE
);

-- Table Simulation Ligne (Produits et Charges)
CREATE TABLE simulation_lignes (
    id_simulation_ligne BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_simulation BIGINT UNSIGNED NOT NULL,
    libelle VARCHAR(255) NOT NULL,
    type ENUM('produit', 'charge') NOT NULL,
    nature_charge ENUM('fixe', 'variable') DEFAULT 'fixe',
    moyenne_historique DECIMAL(15, 2) DEFAULT 0.00,
    coefficient DECIMAL(5, 2) DEFAULT 1.00,
    montant_simule DECIMAL(15, 2) NOT NULL,
    id_sous_compte BIGINT UNSIGNED NULL, -- Optionnel, pour lier à un compte existant
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    CONSTRAINT fk_ligne_simulation FOREIGN KEY (id_simulation) 
        REFERENCES simulations(id_simulation) ON DELETE CASCADE,
    CONSTRAINT fk_ligne_sous_compte FOREIGN KEY (id_sous_compte) 
        REFERENCES sous_comptes(Id_Sous_compte) ON DELETE SET NULL
);
