-- =====================================
-- SOUS COMPTES POUR CLASSE 6 - RAITRA KIDZ
-- =====================================

-- 601 Matières premières
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('601001', 'Papier, cahiers et copies', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '601')),
('601002', 'Encres, craies et peintures', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '601')),
('601003', 'Matériel scientifique et technique', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '601')),
('601004', 'Fournitures artistiques', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '601')),
('601005', 'Achat de riz', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '601')),
('601006', 'Achat de légumes', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '601')),
('601007', 'Achat de fruits', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '601')),
('601008', 'Achat de viande et poisson', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '601')),
('601009', 'Achat de gouters', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '601'));

-- 602 Autres approvisionnements
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('602001', 'Fournitures de bureau', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '602')),
('602002', 'Cartouches et toners', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '602')),
('602003', 'Stylos, crayons et gommes', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '602')),
('602004', 'Classeurs, dossiers et archives', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '602')),
('602005', 'Livres et manuels scolaires', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '602')),
('602006', 'Matériel pédagogique divers', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '602'));

-- 603 Variations des stocks
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('603001', 'Papeterie administrative', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '603')),
('603002', 'Cartouches et toners', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '603')),
('603003', 'Classeurs dossiers et archives', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '603'));

-- 604 Achats d’études et prestations de service
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('604001', 'Conception pédagogique externe', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '604')),
('604002', 'Services de formation continue du personnel', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '604')),
('604003', 'Maintenance informatique', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '604')),
('604004', 'Achats études techniques', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '604'));

-- 605 Achats de matériels, équipements et travaux
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('605001', 'Tables et chaises scolaires', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '605')),
('605002', 'Tableaux et équipement pédagogiques', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '605')),
('605003', 'Matériel informatique de base', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '605')),
('605004', 'Factures électricité', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '605')),
('605005', 'Factures eau', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '605')),
('605006', 'Factures gaz', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '605'));

-- 606 Achats non stockés de matières et fournitures
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('606001', 'Produits de nettoyage classes', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '606')),
('606002', 'Produits hygiène toilettes', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '606')),
('606003', 'Matériel de nettoyage (balais, serpillières)', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '606'));

-- 607 Achats de marchandises
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('607001', 'Uniformes et tenues scolaires', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '607')),
('607002', 'Équipements sportifs', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '607')),
('607003', 'Matériel pour activités culturelles', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '607'));

-- 608 Frais accessoires d’achat
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('608001', 'Frais de transport des fournitures', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '608')),
('608002', 'Frais de douane', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '608'));

-- 609 Rabais, remises et ristournes obtenus sur achats
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('609001', 'Remises fournisseurs de papeterie', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '609'));

-- 611 Sous-traitance générale
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('611001', 'Loyer des salles de classe', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '611')),
('611002', 'Loyer des bureaux administratifs', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '611')),
('611003', 'Charges eau et électricité bâtiments', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '611'));

-- 613 Locations
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('613001', 'Assurance responsabilité civile', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '613')),
('613002', 'Assurance scolaire élèves', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '613')),
('613003', 'Assurance du personnel', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '613'));

-- 614 Charges locatives et de copropriété
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('614001', 'Charges copropriété écoles', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '614'));

-- 615 Entretien, réparations et maintenance
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('615001', 'Réparation bâtiments scolaires', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '615')),
('615002', 'Réparation matériel scolaire', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '615')),
('615003', 'Réparation bus scolaire', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '615'));

-- 616 Primes d’assurances
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('616001', 'Assurance bâtiments', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '616')),
('616002', 'Assurance véhicules scolaires', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '616'));

-- 617 Études et recherches
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('617001', 'Salaires agents sécurité', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '617')),
('617002', 'Fournitures pour gardiennage', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '617')),
('617003', 'Contrat entreprise de sécurité', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '617'));

-- 618 Documentation et divers
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('618001', 'Abonnement revues professionnelles', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '618'));

-- 619 Rabais, remises, ristournes sur services extérieurs
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('619001', 'Remises sur entretien et gardiennage', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '619'));


-- 622 Rémunérations d’intermédiaires et honoraires
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('622001', 'Salaires personnel administratif', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '622')),
('622002', 'Indemnités personnel administratif', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '622'));

-- 623 Publicité, publication, relations publiques
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('623001', 'Publicité institutionnelle', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '623'));

-- 624 Transports de biens et transport du personnel
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('624001', 'Transport élèves et enseignants', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '624')),
('624002', 'Transport matériel scolaire', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '624'));

-- 625 Déplacements, missions et réceptions
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('625001', 'Cotisations CNAPS', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '625')),
('625002', 'Cotisations OSTIE', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '625')),
('625003', 'Autres charges sociales obligatoires', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '625')),
('625004', 'Déplacements professionnels', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '625')),
('625005', 'Réceptions et événements', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '625'));

-- 626 Frais postaux et de télécommunications
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('626001', 'Frais envois postaux', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '626')),
('626002', 'Abonnement téléphonique et internet', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '626'));

-- 627 Services bancaires et assimilés
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('627001', 'Commissions bancaires', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '627'));

-- 628 Cotisations et divers
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('628001', 'Cotisation associations pédagogiques', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '628')),
('628002', 'Organisation de fetes', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '628'));

-- 629 Rabais, remises, ristournes sur autres services extérieurs
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('629001', 'Remises prestations services', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '629'));

-- 631 Impôts, taxes et versements assimilés sur rémunérations
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('631001', 'IRSA enseignants', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '631')),
('631002', 'IRSA personnel administratif', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '631'));

-- 635 Autres impôts et taxes
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('635001', 'Taxe foncière', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '635')),
('635002', 'Taxe professionnelle', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '635')),
('635003', 'TVA non déductible', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '635'));

-- 641 Rémunérations du personnel
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('641001', 'Vacations et contractuels', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '641'));
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('641002', 'Salaires enseignants primaire', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '641')),
('641003', 'Salaires enseignants secondaire', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '641'));

-- 644 Rémunérations des dirigeants
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('644001', 'Rémunération direction établissement', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '644'));

-- 645 Cotisations aux organismes sociaux
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('645001', 'Cotisations retraites', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '645'));

-- 646 Charges sociales sur rémunérations des dirigeants
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('646001', 'Cotisations sociales dirigeants', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '646'));

-- 647 Autres charges sociales
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('647001', 'Autres charges sociales', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '647'));

-- 648 Autres charges de personnel
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('648001', 'Primes et gratifications', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '648'));

-- 651 Redevances pour brevets, licences, logiciels et valeurs similaires
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('651001', 'Licences logiciels éducatifs', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '651')),
('651002', 'Abonnements plateformes pédagogiques', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '651'));

-- 652 Moins-values sur cessions d’actifs non courants
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('652001', 'Moins-value mobilier scolaire', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '652'));

-- 653 Jetons de présence
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('653001', 'Jetons de présence AG', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '653'));

-- 654 Pertes sur créances irrécouvrables
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('654001', 'Pertes sur créances parents', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '654'));

-- 655 Quote-part de résultat sur opérations faites en commun
-- Adapté si école en partenariat pédagogique
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('655001', 'Quote-part activités communes', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '655'));

-- 656 Amendes, pénalités, subventions accordées, dons et libéralités
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('656001', 'Amendes administratives', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '656')),
('656002', 'Subventions accordées', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '656')),
('656003', 'Dons', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '656'));

-- 657 Charges exceptionnelles de gestion courante
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('657001', 'Dépenses urgentes', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '657'));

-- 658 Autres charges de gestion courante
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('658001', 'Autres dépenses courantes', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '658'));

-- 661 Charges d’intérêts
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('661001', 'Intérêts prêt bancaire', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '661')),
('661002', 'Intérêts crédit bus scolaire', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '661'));

-- 664 Pertes sur créances liées à des participations
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('664001', 'Pertes sur partenariats', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '664'));

-- 665 Moins-values sur titres de placement
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('665001', 'Moins-value titres placements', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '665'));

-- 666 Pertes de change
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('666001', 'Pertes de change opération bancaire', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '666'));

-- 667 Moins-values sur instruments financiers et assimilés
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('667001', 'Moins-value financière', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '667'));

-- 668 Autres charges financières
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('668001', 'Frais bancaires divers', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '668'));

-- 681 Dotations - actifs non courants
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('681001', 'Amortissement mobilier scolaire', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '681')),
('681002', 'Amortissement matériel informatique', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '681')),
('681003', 'Amortissement bâtiments', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '681')),
('681004', 'Amortissement véhicules', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '681'));

-- 685 Dotations - actifs courants
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('685001', 'Provisions pour risques', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '685'));

-- 692 Imposition différée actif
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('692001', 'Impôts différés actifs', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '692'));

-- 693 Imposition différée passif
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('693001', 'Impôts différés passifs', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '693'));

-- 695 Impôts sur les bénéfices basés sur le résultat des activités ordinaires
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('695001', 'Impôts bénéfices courants', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '695'));

-- 698 Autres impôts sur les résultats
INSERT INTO Sous_comptes ("Code_sous_compte", "Libelle", "Id_Compte") VALUES
('698001', 'Autres impôts sur bénéfices', (SELECT "Id_Compte" FROM comptes WHERE "Code_compte" = '698'));
