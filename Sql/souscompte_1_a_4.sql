-- =====================================
-- INSERTIONS SOUS-COMPTES CLASSE 1 à 5
-- =====================================

-- CLASSE 1 : Comptes de capitaux
INSERT INTO sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('101001', 'Capital verse par l Etat', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '101')),
('101002', 'Capital apporte par les fondateurs prives', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '101')),
('106001', 'Reserve legale', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '106')),
('106002', 'Autres reserves (fonds scolaires)', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '106')),
('108001', 'Compte du directeur detablissement', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '108'));

-- CLASSE 2 : Comptes d immobilisations
INSERT INTO sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('211001', 'Terrains du campus', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '211')),
('213001', 'Constructions - Batiments administratifs', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '213')),
('213002', 'Constructions - Salles de classe', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '213')),
('213003', 'Constructions - Bibliotheque et laboratoires', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '213')),
('215001', 'Materiel informatique', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '215')),
('215002', 'Materiel pedagogique', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '215')),
('218001', 'Mobilier scolaire', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '218')),
('218002', 'Vehicules de transport scolaire', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '218'));

-- =====================================
-- SOUS-COMPTES CLASSE 3 - Comptes de stocks et en-cours
-- =====================================

-- Pour 321 Matiere consommables
INSERT INTO sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('321001', 'Matiere consommables - produits chimiques labo', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '321')),
('321002', 'Matiere consommables - materiel pedagogique', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '321'));

-- Pour 322 Fournitures consommables
INSERT INTO sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('322001', 'Fournitures de bureau', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '322')),
('322002', 'Fournitures scolaires (cahiers, stylos)', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '322'));

-- Pour 326 Emballages
INSERT INTO sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('326001', 'Emballages de cantine', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '326')),
('326002', 'Emballages labo', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '326'));

-- Pour 331 Produits en-cours
INSERT INTO sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('331001', 'Travaux pratiques en-cours', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '331')),
('331002', 'Projets scolaires en-cours', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '331'));

-- Pour 335 Travaux en-cours
INSERT INTO sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('335001', 'Travaux de construction en-cours', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '335')),
('335002', 'Travaux de maintenance en-cours', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '335'));

-- Pour 341 Etudes en-cours
INSERT INTO sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('341001', 'Etudes administratives en-cours', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '341')),
('341002', 'Etudes scientifiques en-cours', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '341'));

-- Pour 345 Prestations de service en cours
INSERT INTO sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('345001', 'Services de formation en-cours', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '345')),
('345002', 'Services parascolaires en-cours', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '345'));

-- Pour 351 Produits intermediaires
INSERT INTO sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('351001', 'Produits pedagogiques intermediaires', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '351'));

-- Pour 355 Produits finis
INSERT INTO sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('355001', 'Manuels scolaires imprimes', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '355')),
('355002', 'Uniformes scolaires finis', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '355'));

-- Pour 358 Produits residuels
INSERT INTO sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('358001', 'Dechets recyclables', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '358')),
('358002', 'Materiel de recuperation', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '358'));

-- Pour 391 à 398 Pertes de valeur
INSERT INTO sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('391001', 'Perte valeur fournitures perimees', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '391')),
('392001', 'Perte valeur autres approvisionnements', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '392')),
('393001', 'Perte valeur en-cours biens', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '393')),
('394001', 'Perte valeur en-cours services', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '394')),
('395001', 'Perte valeur produits finis', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '395')),
('397001', 'Perte valeur stocks approvisionnements', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '397')),
('398001', 'Perte valeur stocks immobilisations', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '398'));

-- CLASSE 4 : Comptes de tiers
INSERT INTO sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('401001', 'Fournisseurs de fournitures scolaires', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '401')),
('401002', 'Fournisseurs de services (maintenance, securite)', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '401')),
('411001', 'Eleves - scolarite a encaisser', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '411')),
('411002', 'Parents - creances diverses', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '411')),
('416001', 'Eleves douteux - scolarite impayee', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '416')),
('421001', 'Personnel enseignant - salaires dus', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '421')),
('421002', 'Personnel administratif - salaires dus', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '421')),
('425001', 'Avances sur salaires', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '425')),
('431001', 'CNAPS', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '431')),
('445001', 'Etat - TVA a decaisser', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '445')),
('445002', 'Etat - Impot sur les salaires', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '445'));

-- CLASSE 5 : Comptes financiers
INSERT INTO sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('515001', 'Caisse centrale - Ariary', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '515')),
('515002', 'Caisse cantine', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '515')),
('512001', 'BNI - compte courant', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '512')),
('512002', 'BMOI - compte courant', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '512')),
('581001', 'Virement Banque vers Caisse', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '581'));
