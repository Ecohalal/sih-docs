-- =====================================================================
-- SIH · db_ecohalal_sih · FASE 2a — DEGOLADORES (planilha ALI CHAHINE)
-- =====================================================================
-- 57 degoladores -> Collaborator(type=degolador) + vinculo por SIF.
-- Idempotente: Collaborator por (lower(name), type); vinculo pela unique
-- (collaboratorId, plantId). Reproduz a carga executada via Node em 22/jul.
-- Documento nao vem na planilha (fica NULL); telefone quando valido.
-- =====================================================================

WITH origem(name, phone, sif) AS (VALUES
  ('ZAKARIAE KARROUM', '11-98955-5642', '3941'),
  ('MOHAMED ARAFET MEJRI', '12 -9 88350677', '1251'),
  ('HAMADU BALDE', '11979609640', '3624'),
  ('OMAR BELDI', '216 26 642 435', '2872'),
  ('SALIF DIAW', '11953382555', '2782'),
  ('KARIM AYARI', '63-98126-6420', '1723'),
  ('KHALIDOU SOW', '11 96120-2246', '2852'),
  ('MODOU KHARY DIOP', NULL, '5125'),
  ('HAMZA LEMGHAOUAL', NULL, '147'),
  ('MEISSA BIRAME SECK', '11 9 5176-8194', '2679'),
  ('ALSHANE BARY', '+224 622 73 18 21', '2803'),
  ('KHALED GUESMI', '33 99979-4358', '3576'),
  ('CHEIK DJILI', '11 94928-6636', '4398'),
  ('AMR ANTAR MOHAMED ATTIA MOHAMED', '17 9 9778-2276', '2924'),
  ('AHMED CHARLON', '69 9259-3564', '2443'),
  ('HESHAM SOBHY AHMED HUSSEIN GHORAB', '69 99228-9262', '2443'),
  ('MAHFOUD CHALOU', '11 9 7800-5383', '2443'),
  ('OUSMANE ANNE', '11 97018-6935', '1891'),
  ('ALLASANY ALLAY AFFO', '43988677319', '2258'),
  ('AHMED IBRAHIM ABDALLA ELHASSAN', '11 9 6296-7478', '1646'),
  ('MOUSTAFA A.A.HAMID.GHOUNEIM', NULL, '93'),
  ('ABDELOUAHID MARZOUK', '(11)967119270', '723'),
  ('RAMZI GARRAOUI', '12 9 8144-9681', '1616'),
  ('MOHAMED ALI OURABI', '12 99744-2678', '411'),
  ('ZARIFOU ALASSANI', '11977379773', '4466'),
  ('MOHAMMED LAROUSSI', '11914970909', '809'),
  ('SIDOW MOHAMED IBRAHIM', '11 96137-7792', '177'),
  ('HARUNA MUHAMMED SAFARI', '11 97033-8567', '177'),
  ('NABIL NABIL HASSAN ABDELKADER', '11933826087', '4029'),
  ('BOUBACAR BALDE', '67999526592', '3112'),
  ('ALI KHALIL', '11 9 9414-4779', '1758'),
  ('DIALLO MAMADUO MOUSTAPHA', '11 98293-5032', '5164'),
  ('WAIL S.ABDELRAMANDIM', '46 9 9919-5627', '2437'),
  ('MOUTAWAKILOU TCHASSAMS', NULL, '5317'),
  ('FEDI MLOUKI', '12 9 8881-2329', '4490'),
  ('HAMZA GASMI', '12 98881-3187', '2937'),
  ('HAMZA ZAIDI', '12 9 8868-4005', '3348'),
  ('MARWAN IBRAHIM ADAM DAWOD', '212 643 966 927', '3405'),
  ('AYOUB AIT FARES', '011 9 3497-3022', '3974'),
  ('ABDIFTAAX HIRAD', '065 9 9624-9635', '3974'),
  ('OSSAMA AZZI', '065 9939-4190', '1811'),
  ('WASSIM FRAYAH', '011 99456-3119', '1811'),
  ('ADIL FARTHATI', '011 9 2091-6220', '1365'),
  ('ALI HANI ALMAJDOUBAH', '053 9 9935-3099', '1365'),
  ('AYOUB BAAZIZ', '011 9 4610-4032', '661'),
  ('ZOUHIR RABAAI', '94 8116-3155', '2583'),
  ('MOHAMEDALI MAWIA MOHAMEDALI GASSMELSYED', '66- 9 9624-2877', '2960'),
  ('FOUED AOIADI', '12 996467616', '4554'),
  ('CHEIK KHOUNA GASSAMA-PESSOAL CHAMA ELE DE BABA', '+221 78 180 90 49', '4413'),
  ('ABDOULAY SOW', '11 9 4609-5322', '3920'),
  ('BADR', '33 98452-9679', '3215'),
  ('BADR', '33 98452-9679', '2051'),
  ('SAIDOU SOW', '11 98550 7352', '3215'),
  ('ABDOUL MALICK BARRY', NULL, '3297'),
  ('MOHAMED GALAL ABDALLA BARAKAT', '69 9 9 280-0000', '4267'),
  ('PAROU', NULL, '2620'),
  ('JAMAL HUSSEIN', NULL, '2153'),
  ('MOHAMMED LAGRAID', '69-99359-4957', '5590')
),
-- 1) cria os colaboradores ausentes (um por nome distinto)
novos AS (
  INSERT INTO collaborators (name, type, phone, "isActive", created_at, updated_at)
  SELECT DISTINCT ON (lower(o.name)) o.name, 'degolador', o.phone, true, now(), now()
    FROM origem o
   WHERE NOT EXISTS (
     SELECT 1 FROM collaborators c WHERE lower(c.name)=lower(o.name) AND c.type='degolador'
   )
  RETURNING id, lower(name) AS lname
)
-- 2) vincula cada degolador as suas plantas (por SIF)
INSERT INTO collaborator_plants ("collaboratorId", "plantId", "assignedAt")
SELECT c.id, p.id, now()
  FROM origem o
  JOIN collaborators c ON lower(c.name)=lower(o.name) AND c.type='degolador'
  JOIN plants p ON p."sanitaryCode"=o.sif
ON CONFLICT ("collaboratorId", "plantId") DO NOTHING;

-- Conferencia
SELECT count(*) FILTER (WHERE type='degolador') AS degoladores FROM collaborators;
SELECT count(*) AS vinculos FROM collaborator_plants cp
  JOIN collaborators c ON c.id=cp."collaboratorId" WHERE c.type='degolador';
