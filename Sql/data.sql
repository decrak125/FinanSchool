INSERT INTO categorie_fonctionelles (code, libelle, calcul_auto, id_duree, id_fonction_economique, id_nature_comptable, id_type_categorie)
VALUES
('CA', 'Chiffre d’affaires', true, (SELECT id_duree FROM durees WHERE code='CT'), (SELECT id_fonction_economique FROM fonction_economiques WHERE code='EXPLOIT'), (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='PRODUIT'), (SELECT id_type_categorie FROM type_categories WHERE code_type='GESTION')),
('PRODSTOCK', 'Production stockée', true, (SELECT id_duree FROM durees WHERE code='CT'), (SELECT id_fonction_economique FROM fonction_economiques WHERE code='EXPLOIT'), (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='PRODUIT'), (SELECT id_type_categorie FROM type_categories WHERE code_type='GESTION')),
('PRODIMMO', 'Production immobilisée', true, (SELECT id_duree FROM durees WHERE code='LT'), (SELECT id_fonction_economique FROM fonction_economiques WHERE code='EXPLOIT'), (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='PRODUIT'), (SELECT id_type_categorie FROM type_categories WHERE code_type='GESTION')),
('ACHATCONSOM', 'Achats consommés', true, (SELECT id_duree FROM durees WHERE code='CT'), (SELECT id_fonction_economique FROM fonction_economiques WHERE code='EXPLOIT'), (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='CHARGE'), (SELECT id_type_categorie FROM type_categories WHERE code_type='GESTION')),
('SERVEXT', 'Services extérieurs et autres consommations', true, (SELECT id_duree FROM durees WHERE code='CT'), (SELECT id_fonction_economique FROM fonction_economiques WHERE code='EXPLOIT'), (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='CHARGE'), (SELECT id_type_categorie FROM type_categories WHERE code_type='GESTION')),
('SUBVENT', 'Subventions d’exploitation', true, (SELECT id_duree FROM durees WHERE code='CT'), (SELECT id_fonction_economique FROM fonction_economiques WHERE code='EXPLOIT'), (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='PRODUIT'), (SELECT id_type_categorie FROM type_categories WHERE code_type='GESTION')),
('CHPERS', 'Charges de personnel', true, (SELECT id_duree FROM durees WHERE code='CT'), (SELECT id_fonction_economique FROM fonction_economiques WHERE code='EXPLOIT'), (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='CHARGE'), (SELECT id_type_categorie FROM type_categories WHERE code_type='GESTION')),
('CHAREXPL', 'Charges exploitation spécifique', true, (SELECT id_duree FROM durees WHERE code='CT'), (SELECT id_fonction_economique FROM fonction_economiques WHERE code='EXPLOIT'), (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='CHARGE'), (SELECT id_type_categorie FROM type_categories WHERE code_type='GESTION')),
('IMPTAX', 'Impôts, taxes et versements assimilés', true, (SELECT id_duree FROM durees WHERE code='CT'), (SELECT id_fonction_economique FROM fonction_economiques WHERE code='EXPLOIT'), (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='CHARGE'), (SELECT id_type_categorie FROM type_categories WHERE code_type='GESTION')),
('AUTPRODOP', 'Autres produits opérationnels', true, (SELECT id_duree FROM durees WHERE code='CT'), (SELECT id_fonction_economique FROM fonction_economiques WHERE code='EXPLOIT'), (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='PRODUIT'), (SELECT id_type_categorie FROM type_categories WHERE code_type='GESTION')),
('AUTCHOP', 'Autres charges opérationnelles', true, (SELECT id_duree FROM durees WHERE code='CT'), (SELECT id_fonction_economique FROM fonction_economiques WHERE code='EXPLOIT'), (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='CHARGE'), (SELECT id_type_categorie FROM type_categories WHERE code_type='GESTION')),
('AMORTPROV', 'Dotations aux amortissements/provisions/pertes de valeur', true, (SELECT id_duree FROM durees WHERE code='LT'), (SELECT id_fonction_economique FROM fonction_economiques WHERE code='EXPLOIT'), (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='CHARGE'), (SELECT id_type_categorie FROM type_categories WHERE code_type='GESTION')),
('REPRISEPROV', 'Reprise sur provisions et pertes de valeur', true, (SELECT id_duree FROM durees WHERE code='LT'), (SELECT id_fonction_economique FROM fonction_economiques WHERE code='EXPLOIT'), (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='PRODUIT'), (SELECT id_type_categorie FROM type_categories WHERE code_type='GESTION')),
('PRODFIN', 'Produits financiers', true, (SELECT id_duree FROM durees WHERE code='CT'), (SELECT id_fonction_economique FROM fonction_economiques WHERE code='FINANCE'), (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='PRODUIT'), (SELECT id_type_categorie FROM type_categories WHERE code_type='GESTION')),
('CHARGEFIN', 'Charges financières', true, (SELECT id_duree FROM durees WHERE code='CT'), (SELECT id_fonction_economique FROM fonction_economiques WHERE code='FINANCE'), (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='CHARGE'), (SELECT id_type_categorie FROM type_categories WHERE code_type='GESTION')),
('IMPOT', 'Impôts exigibles sur resultat', true, (SELECT id_duree FROM durees WHERE code='CT'), (SELECT id_fonction_economique FROM fonction_economiques WHERE code='FINANCE'), (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='CHARGE'), (SELECT id_type_categorie FROM type_categories WHERE code_type='GESTION')),
('IMPOTDIFF', 'Impôts différés', true, (SELECT id_duree FROM durees WHERE code='CT'), (SELECT id_fonction_economique FROM fonction_economiques WHERE code='FINANCE'), (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='CHARGE'), (SELECT id_type_categorie FROM type_categories WHERE code_type='GESTION')),
('PRODEXCEPT', 'Produits extraordinaires', true, (SELECT id_duree FROM durees WHERE code='CT'), (SELECT id_fonction_economique FROM fonction_economiques WHERE code='EXCEPT'), (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='PRODUIT'), (SELECT id_type_categorie FROM type_categories WHERE code_type='GESTION')),
('CHAREXCEPT', 'Charges extraordinaires', true, (SELECT id_duree FROM durees WHERE code='CT'), (SELECT id_fonction_economique FROM fonction_economiques WHERE code='EXCEPT'), (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='CHARGE'), (SELECT id_type_categorie FROM type_categories WHERE code_type='GESTION'));

INSERT INTO categorie_fonctionelles (code, libelle, calcul_auto, id_duree, id_fonction_economique, id_nature_comptable, id_type_categorie)
VALUES
('VENTES', 'Produit des activités ordinaires', true, (SELECT id_duree FROM durees WHERE code='CT'), (SELECT id_fonction_economique FROM fonction_economiques WHERE code='EXPLOIT'), (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='PRODUIT'), (SELECT id_type_categorie FROM type_categories WHERE code_type='GESTION')),
('COUTVENTE', 'Coût des ventes', true, (SELECT id_duree FROM durees WHERE code='CT'), (SELECT id_fonction_economique FROM fonction_economiques WHERE code='EXPLOIT'), (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='CHARGE'), (SELECT id_type_categorie FROM type_categories WHERE code_type='GESTION')),
('CHARGECOMM', 'Coûts commerciaux', true, (SELECT id_duree FROM durees WHERE code='CT'), (SELECT id_fonction_economique FROM fonction_economiques WHERE code='EXPLOIT'), (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='CHARGE'), (SELECT id_type_categorie FROM type_categories WHERE code_type='GESTION')),
('CHARGEADM', 'Charges administratives', true, (SELECT id_duree FROM durees WHERE code='CT'), (SELECT id_fonction_economique FROM fonction_economiques WHERE code='EXPLOIT'), (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='CHARGE'), (SELECT id_type_categorie FROM type_categories WHERE code_type='GESTION'));


INSERT INTO categorie_fonctionelles (code, libelle, calcul_auto, id_duree, id_fonction_economique, id_nature_comptable, id_type_categorie)
VALUES
('GOODWILL', 'Ecart d’acquisition ou goodwill', true, (SELECT id_duree FROM durees WHERE code='LT'),
  (SELECT id_fonction_economique FROM fonction_economiques WHERE code='INVEST'),
  (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='ACTIF'),
  (SELECT id_type_categorie FROM type_categories WHERE code_type='BILAN')),

('IMMOINC', 'Immobilisations incorporelles', true, (SELECT id_duree FROM durees WHERE code='LT'),
  (SELECT id_fonction_economique FROM fonction_economiques WHERE code='INVEST'),
  (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='ACTIF'),
  (SELECT id_type_categorie FROM type_categories WHERE code_type='BILAN')),

('IMMOCO', 'Immobilisations corporelles', true, (SELECT id_duree FROM durees WHERE code='LT'),
  (SELECT id_fonction_economique FROM fonction_economiques WHERE code='INVEST'),
  (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='ACTIF'),
  (SELECT id_type_categorie FROM type_categories WHERE code_type='BILAN')),

('IMMOCOURS', 'Immobilisations en cours', true, (SELECT id_duree FROM durees WHERE code='LT'),
  (SELECT id_fonction_economique FROM fonction_economiques WHERE code='INVEST'),
  (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='ACTIF'),
  (SELECT id_type_categorie FROM type_categories WHERE code_type='BILAN')),

('AMORT_IMMOCO', 'Immobilisations en cours', true, (SELECT id_duree FROM durees WHERE code='LT'),
  (SELECT id_fonction_economique FROM fonction_economiques WHERE code='INVEST'),
  (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='ACTIF'),
  (SELECT id_type_categorie FROM type_categories WHERE code_type='BILAN')),

('AMORT_IMMOINC', 'Amortissement incorporelles', true, (SELECT id_duree FROM durees WHERE code='LT'),
  (SELECT id_fonction_economique FROM fonction_economiques WHERE code='INVEST'),
  (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='ACTIF'),
  (SELECT id_type_categorie FROM type_categories WHERE code_type='BILAN')),

('IMMOFIN', 'Immobilisations financières', true, (SELECT id_duree FROM durees WHERE code='LT'),
  (SELECT id_fonction_economique FROM fonction_economiques WHERE code='INVEST'),
  (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='ACTIF'),
  (SELECT id_type_categorie FROM type_categories WHERE code_type='BILAN')),

('TITRSEQ', 'Titres mis en équivalence', true, (SELECT id_duree FROM durees WHERE code='LT'),
  (SELECT id_fonction_economique FROM fonction_economiques WHERE code='INVEST'),
  (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='ACTIF'),
  (SELECT id_type_categorie FROM type_categories WHERE code_type='BILAN')),

('AUTPART', 'Autres participations et créances rattachées', true, (SELECT id_duree FROM durees WHERE code='LT'),
  (SELECT id_fonction_economique FROM fonction_economiques WHERE code='FINANCE'),
  (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='ACTIF'),
  (SELECT id_type_categorie FROM type_categories WHERE code_type='BILAN')),

('AUTIMMOFIN', 'Autres titres immobilisés', true, (SELECT id_duree FROM durees WHERE code='LT'),
  (SELECT id_fonction_economique FROM fonction_economiques WHERE code='INVEST'),
  (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='ACTIF'),
  (SELECT id_type_categorie FROM type_categories WHERE code_type='BILAN')),

('PRET', 'Prêts et autres immobilisations financières', true, (SELECT id_duree FROM durees WHERE code='LT'),
  (SELECT id_fonction_economique FROM fonction_economiques WHERE code='INVEST'),
  (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='ACTIF'),
  (SELECT id_type_categorie FROM type_categories WHERE code_type='BILAN')),

('STOCKS', 'Stocks et en-cours', true, (SELECT id_duree FROM durees WHERE code='CT'),
  (SELECT id_fonction_economique FROM fonction_economiques WHERE code='EXPLOIT'),
  (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='ACTIF'),
  (SELECT id_type_categorie FROM type_categories WHERE code_type='BILAN')),

('CREANCES', 'Créances et emplois assimilés', true, (SELECT id_duree FROM durees WHERE code='CT'),
  (SELECT id_fonction_economique FROM fonction_economiques WHERE code='EXPLOIT'),
  (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='ACTIF'),
  (SELECT id_type_categorie FROM type_categories WHERE code_type='BILAN')),

('CLIENTS', 'Clients et autres débiteurs', true, (SELECT id_duree FROM durees WHERE code='CT'),
  (SELECT id_fonction_economique FROM fonction_economiques WHERE code='EXPLOIT'),
  (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='ACTIF'),
  (SELECT id_type_categorie FROM type_categories WHERE code_type='BILAN')),

('IMPT', 'Impôts actifs', true, (SELECT id_duree FROM durees WHERE code='CT'),
  (SELECT id_fonction_economique FROM fonction_economiques WHERE code='EXPLOIT'),
  (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='ACTIF'),
  (SELECT id_type_categorie FROM type_categories WHERE code_type='BILAN')),

('AUTCREANCES', 'Autres créances et actifs assimilés', true, (SELECT id_duree FROM durees WHERE code='CT'),
  (SELECT id_fonction_economique FROM fonction_economiques WHERE code='EXPLOIT'),
  (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='ACTIF'),
  (SELECT id_type_categorie FROM type_categories WHERE code_type='BILAN')),

('TRESO', 'Trésorerie et équivalents de trésorerie', true, (SELECT id_duree FROM durees WHERE code='CT'),
  (SELECT id_fonction_economique FROM fonction_economiques WHERE code='TRESO'),
  (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='ACTIF'),
  (SELECT id_type_categorie FROM type_categories WHERE code_type='BILAN')),

('PLACEMENTS', 'Placements et autres équivalents de trésorerie', true, (SELECT id_duree FROM durees WHERE code='CT'),
  (SELECT id_fonction_economique FROM fonction_economiques WHERE code='TRESO'),
  (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='ACTIF'),
  (SELECT id_type_categorie FROM type_categories WHERE code_type='BILAN')),

('TRESOFONDS', 'Trésorerie fonds en caisse et dépôts à vue', true, (SELECT id_duree FROM durees WHERE code='CT'),
  (SELECT id_fonction_economique FROM fonction_economiques WHERE code='TRESO'),
  (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='ACTIF'),
  (SELECT id_type_categorie FROM type_categories WHERE code_type='BILAN')),

------------------
-- Capitaux propres
('CAPITAL', 'Capital émis', true, (SELECT id_duree FROM durees WHERE code='LT'),
  (SELECT id_fonction_economique FROM fonction_economiques WHERE code='FINANCE'),
  (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='CP'),
  (SELECT id_type_categorie FROM type_categories WHERE code_type='BILAN')),

('PRIME', 'Primes et réserves consolidées', true, (SELECT id_duree FROM durees WHERE code='LT'),
  (SELECT id_fonction_economique FROM fonction_economiques WHERE code='FINANCE'),
  (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='CP'),
  (SELECT id_type_categorie FROM type_categories WHERE code_type='BILAN')),

('EVAL', 'Ecarts d’évaluation', true, (SELECT id_duree FROM durees WHERE code='LT'),
  (SELECT id_fonction_economique FROM fonction_economiques WHERE code='FINANCE'),
  (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='CP'),
  (SELECT id_type_categorie FROM type_categories WHERE code_type='BILAN')),

('EQUIV', 'Ecart d’équivalence', true, (SELECT id_duree FROM durees WHERE code='LT'),
  (SELECT id_fonction_economique FROM fonction_economiques WHERE code='FINANCE'),
  (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='CP'),
  (SELECT id_type_categorie FROM type_categories WHERE code_type='BILAN')),

('RESULT', 'Résultat net (part du groupe)', true, (SELECT id_duree FROM durees WHERE code='LT'),
  (SELECT id_fonction_economique FROM fonction_economiques WHERE code='FINANCE'),
  (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='CP'),
  (SELECT id_type_categorie FROM type_categories WHERE code_type='BILAN')),

('AUTCPRO', 'Autres capitaux propres - Report à nouveau', true, (SELECT id_duree FROM durees WHERE code='LT'),
  (SELECT id_fonction_economique FROM fonction_economiques WHERE code='FINANCE'),
  (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='CP'),
  (SELECT id_type_categorie FROM type_categories WHERE code_type='BILAN')),

('FINPLACEMENT', 'Autres capitaux propres - Report à nouveau', true, (SELECT id_duree FROM durees WHERE code='LT'),
  (SELECT id_fonction_economique FROM fonction_economiques WHERE code='FINANCE'),
  (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='CP'),
  (SELECT id_type_categorie FROM type_categories WHERE code_type='BILAN')),
------------------
-- Passifs non courants
('SUBVINV', 'Subventions d’investissement', true, (SELECT id_duree FROM durees WHERE code='LT'),
  (SELECT id_fonction_economique FROM fonction_economiques WHERE code='INVEST'),
  (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='PASSIF'),
  (SELECT id_type_categorie FROM type_categories WHERE code_type='BILAN')),

('IMPTPASS', 'Impôts différés', true, (SELECT id_duree FROM durees WHERE code='LT'),
  (SELECT id_fonction_economique FROM fonction_economiques WHERE code='FINANCE'),
  (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='PASSIF'),
  (SELECT id_type_categorie FROM type_categories WHERE code_type='BILAN')),

('EMPRUNT', 'Emprunts et dettes financières', true, (SELECT id_duree FROM durees WHERE code='LT'),
  (SELECT id_fonction_economique FROM fonction_economiques WHERE code='FINANCE'),
  (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='PASSIF'),
  (SELECT id_type_categorie FROM type_categories WHERE code_type='BILAN')),

('PROVNCOUR', 'Provisions et produits constatés d’avance', true, (SELECT id_duree FROM durees WHERE code='LT'),
  (SELECT id_fonction_economique FROM fonction_economiques WHERE code='FINANCE'),
  (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='PASSIF'),
  (SELECT id_type_categorie FROM type_categories WHERE code_type='BILAN')),

------------------
-- Passifs courants
('DETTECT', 'Dettes court terme', true, (SELECT id_duree FROM durees WHERE code='CT'),
  (SELECT id_fonction_economique FROM fonction_economiques WHERE code='FINANCE'),
  (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='PASSIF'),
  (SELECT id_type_categorie FROM type_categories WHERE code_type='BILAN')),

('FOURN', 'Fournisseurs et comptes rattachés', true, (SELECT id_duree FROM durees WHERE code='CT'),
  (SELECT id_fonction_economique FROM fonction_economiques WHERE code='EXPLOIT'),
  (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='PASSIF'),
  (SELECT id_type_categorie FROM type_categories WHERE code_type='BILAN')),

('PROVC', 'Provisions et produits constatés d’avance passifs courants', true, (SELECT id_duree FROM durees WHERE code='CT'),
  (SELECT id_fonction_economique FROM fonction_economiques WHERE code='FINANCE'),
  (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='PASSIF'),
  (SELECT id_type_categorie FROM type_categories WHERE code_type='BILAN')),

('AUTDETTE', 'Autres dettes', true, (SELECT id_duree FROM durees WHERE code='CT'),
  (SELECT id_fonction_economique FROM fonction_economiques WHERE code='FINANCE'),
  (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='PASSIF'),
  (SELECT id_type_categorie FROM type_categories WHERE code_type='BILAN')),

('DECOUV', 'Comptes de trésorerie découverts bancaires', true, (SELECT id_duree FROM durees WHERE code='CT'),
  (SELECT id_fonction_economique FROM fonction_economiques WHERE code='TRESO'),
  (SELECT id_nature_comptable FROM nature_comptables WHERE code_nature='PASSIF'),
  (SELECT id_type_categorie FROM type_categories WHERE code_type='BILAN'));
