-- =====================================================================
-- SIH · db_ecohalal_sih · IMPORTACAO FASE 1 — PLANTAS (planilha ALI CHAHINE)
-- =====================================================================
-- Origem: FRIGORIFICOS DIVERSOS FUNCIONARIOS ALI CHAHINE.xlsx (C:\SIH\).
-- Curadoria (22/jul): das 94 plantas com SIF, 1 ja existe (BRF Dourados),
-- 7 ficam FORA (marcador "verificar/campanha", dado incerto). Entram 86:
--   74 ativas + 12 inativas (marcador "sem producao/fechou/parado").
--
-- PREMISSAS (validar): type=frigorifico, division=IN, species={bovino} para
-- todas — sao frigorificos de abate bovino (parte In Natura, carteira do Andre).
-- Ajustar caso alguma seja aves/entreposto (ex.: VPJ Pirassununga Entreposto).
--
-- Nome = razao social do GC (Title Case) + cidade/UF do endereco do GC.
-- CNPJ = do GC (master). Idempotente por SIF (WHERE NOT EXISTS).
-- Supervisores e degoladores = Fase 2 (nao entram aqui).
-- =====================================================================

INSERT INTO plants (
  name, "sanitaryCode", "sanitaryCodeType", cnpj,
  type, capabilities, species, division,
  address, "isActive", "isExternal", created_at, updated_at
)
SELECT v.* FROM (VALUES
  ('Agra Agroindustrial de Alimentos S.A. - Rondonópolis/MT', '3941', 'SIF'::"SanitaryCodeType", '24746687000177', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Agroindustrial Iguatemi Ltda - Iguatemi/MS', '1440', 'SIF'::"SanitaryCodeType", '12593115000116', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Ativo Alimentos Exportadora e Importadora Ltda - Castanhal/PA', '2801', 'SIF'::"SanitaryCodeType", '06128996000100', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, false, false, now(), now()),
  ('Frigorífico Astra do Paraná Ltda - Cruzeiro do Oeste/PR', '1251', 'SIF'::"SanitaryCodeType", '07615913000242', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Balbinos Agroindustrial Eireli - Sidrolândia/MS', '89', 'SIF'::"SanitaryCodeType", '12052144000170', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, false, false, now(), now()),
  ('Barra Mansa Comércio de Carnes e Derivados Ltda - Sertãozinho/PB', '941', 'SIF'::"SanitaryCodeType", '03151790000447', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Boa Vista Alimentos Ltda - Goianira/GO', '3624', 'SIF'::"SanitaryCodeType", '37356854000115', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Beauvallet Goiás Alimentos Ltda - Inhumas/GO', '2872', 'SIF'::"SanitaryCodeType", '35156596000106', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Frigorifico Better Beef Ltda - Rancharia/SP', '1925', 'SIF'::"SanitaryCodeType", '05826986000258', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Bon - Mart Frigorífico Ltda - Presidente Prudente/SP', '2121', 'SIF'::"SanitaryCodeType", '04304360000219', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, false, false, now(), now()),
  ('Boibras Industria e Comercio de Carnes e Sub-Produtos Ltda - São Gabriel do Oeste/MS', '2782', 'SIF'::"SanitaryCodeType", '05492166000196', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Industria e Comercio de Carnes e Derivados Boi Brasil Ltda - Alvorada/TO', '1723', 'SIF'::"SanitaryCodeType", '04603630000373', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Indústria e Comércio de Carnes e Derivados Boi Brasil Ltda - Araguaína/TO', '2852', 'SIF'::"SanitaryCodeType", '04603630000888', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Indústria Frigorífica Boa Carne Ltda - Colíder/MT', '5125', 'SIF'::"SanitaryCodeType", '30251841000132', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Frigorifico Boi Mix Ltda - Jales/SP', '3386', 'SIF'::"SanitaryCodeType", '18715000000214', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, false, false, now(), now()),
  ('Comesul Beef Agro Industrial Ltda - Pantano Grande/RS', '2679', 'SIF'::"SanitaryCodeType", '15548956000108', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Falcao Industria de Alimentos Ltda - Boca do Acre/AM', '2803', 'SIF'::"SanitaryCodeType", '11958002000538', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Frigorifico Fortefrigo Ltda - Paragominas/PA', '372', 'SIF'::"SanitaryCodeType", '10748137000182', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, false, false, now(), now()),
  ('Frigorifico Regional Sudoeste Ltda. - Itapetinga/BA', '3576', 'SIF'::"SanitaryCodeType", '11516163000148', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Frigorifico Silva Industria e Comercio Ltda - Santa Maria/RS', '1733', 'SIF'::"SanitaryCodeType", '88728027000146', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, false, false, now(), now()),
  ('Fts - Frigorifico Tavares da Silva Ltda - Xinguara/PA', '4398', 'SIF'::"SanitaryCodeType", '25264597000374', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Frigoestrela S.A.. - Estrela D''oeste/SP', '2924', 'SIF'::"SanitaryCodeType", '52645009001206', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Irmãos Gonçalves Comércio e Indústria Ltda - Jaru/RO', '2443', 'SIF'::"SanitaryCodeType", '04082624001551', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Frigorifico Valencio Ltda - Xinguara/PA', '1891', 'SIF'::"SanitaryCodeType", '08915713000197', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Abatedouro de Bovinos Sampaio Ltda - Redenção/PA', '2258', 'SIF'::"SanitaryCodeType", '09248966000117', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Frigorífico Sul Ltda - Aparecida do Taboado/MS', '889', 'SIF'::"SanitaryCodeType", '02591772000170', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Pantaneira Industria e Comercio de Carnes e Derivados Ltda - Várzea Grande/MT', '1206', 'SIF'::"SanitaryCodeType", '05111062000194', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Frigosul - Frigorifico Sul Ltda - Vila Maria/RS', '3654', 'SIF'::"SanitaryCodeType", '02591772000766', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Frigorífico Verdi Ltda - Pouso Redondo/SC', '584', 'SIF'::"SanitaryCodeType", '85641066000113', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Frigorifico Vale do Sapucaí Ltda - Itajubá/MG', '1883', 'SIF'::"SanitaryCodeType", '01702122000192', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Frizelo Frigorificos Ltda - Terenos/MS', '1646', 'SIF'::"SanitaryCodeType", '13837014000106', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Rio Grande Comercio de Carnes Ltda - Imperatriz/MA', '2431', 'SIF'::"SanitaryCodeType", '07555950001012', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Grancarnes Industria e Comercio de Carnes S.A. - Nova Monte Verde/MT', '5018', 'SIF'::"SanitaryCodeType", '65978488000171', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Cooperativa dos Produtores de Carne e Derivados de Gurupi - Gurupi/TO', '93', 'SIF'::"SanitaryCodeType", '02964051000169', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Kadao S.A.. - Caçu/GO', '1914', 'SIF'::"SanitaryCodeType", '07164263000185', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, false, false, now(), now()),
  ('Lkj - Frigorifico Ltda - Araguaína/TO', '723', 'SIF'::"SanitaryCodeType", '21393000000179', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Supremo Carnes Ltda - Carlos Chagas/MG', '4293', 'SIF'::"SanitaryCodeType", '07540084000103', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Mult Beef Comercial Ltda - Brodowski/SP', '3314', 'SIF'::"SanitaryCodeType", '02886959000100', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Pro Boi Carnes Ltda - Cachoeira Alta/GO', '1616', 'SIF'::"SanitaryCodeType", '46075219000401', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Frigorífico Rio Maria Ltda - Rio Maria/PA', '112', 'SIF'::"SanitaryCodeType", '04749233000142', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Frigorifico Redentor S.A. - Guarantã do Norte/MT', '411', 'SIF'::"SanitaryCodeType", '02165984000196', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Vale Company Comercio e Servicos Ltda - Rondonópolis/MT', '4466', 'SIF'::"SanitaryCodeType", '76986850000253', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Santa Lucia Industria e Comercio de Carnes Ltda - Araguari/MG', '809', 'SIF'::"SanitaryCodeType", '22712053000178', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Prima Foods S.A.. - Araguari/MG', '177', 'SIF'::"SanitaryCodeType", '16820052000659', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Prima Foods S.A.. - Santa Fé de Goiás/GO', '4029', 'SIF'::"SanitaryCodeType", '16820052001540', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Prima Foods S.A.. - Cassilândia/MS', '3112', 'SIF'::"SanitaryCodeType", '16820052002600', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Zanchetta Indústria de Alimentos Ltda - Bauru/SP', '1758', 'SIF'::"SanitaryCodeType", '33920401000119', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Zanchetta Indústria de Alimentos Ltda - Batayporã/MS', '5164', 'SIF'::"SanitaryCodeType", '33920401000208', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Masterboi Ltda - São Geraldo do Araguaia/PA', '2437', 'SIF'::"SanitaryCodeType", '03721769000944', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Masterboi Ltda - Canhotinho/PE', '5317', 'SIF'::"SanitaryCodeType", '03721769001592', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Masterboi Ltda - Nova Olinda/TO', '860', 'SIF'::"SanitaryCodeType", '03721769000600', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Vale Grande Industria e Comercio de Alimentos S.A. - Matupá/MT', '4490', 'SIF'::"SanitaryCodeType", '06088741000403', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Vale Grande Industria e Comercio de Alimentos S.A. - Nova Canaã do Norte/MT', '2937', 'SIF'::"SanitaryCodeType", '06088741000829', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Vale Grande Industria e Comercio de Alimentos S.A. - Sinop/MT', '3348', 'SIF'::"SanitaryCodeType", '06088741000586', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Vale Grande Industria e Comercio de Alimentos S.A. - Ji-Paraná/RO', '3405', 'SIF'::"SanitaryCodeType", '06088741002520', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Naturafrig Alimentos Ltda - Rochedo/MS', '3974', 'SIF'::"SanitaryCodeType", '18626084000139', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Naturafrig Alimentos Ltda - Barra do Bugres/MT', '1811', 'SIF'::"SanitaryCodeType", '18626084000309', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Naturafrig Alimentos Ltda - Pirapozinho/SP', '1365', 'SIF'::"SanitaryCodeType", '18626084000481', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Naturafrig Alimentos Ltda - Nova Andradina/MS', '661', 'SIF'::"SanitaryCodeType", '18626084000210', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Distriboi-Industria Comércio e Transporte de Carne - Rolim de Moura/RO', '4334', 'SIF'::"SanitaryCodeType", '22882054000403', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Distriboi - Industria, Comercio e Transporte de Carne Bovina Ltda - Ji-Paraná/RO', '4695', 'SIF'::"SanitaryCodeType", '22882054000322', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Frigol S.A.. - Água Azul do Norte/PA', '2583', 'SIF'::"SanitaryCodeType", '68067446001068', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Frigol S.A.. - São Félix do Xingu/PA', '4150', 'SIF'::"SanitaryCodeType", '68067446001572', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Frigol S.A.. - Lençóis Paulista/SP', '2960', 'SIF'::"SanitaryCodeType", '68067446000410', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Mercurio Alimentos S.A. - Castanhal/PA', '4554', 'SIF'::"SanitaryCodeType", '11831785000241', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Mercurio Alimentos S.A. - Xinguara/PA', '4413', 'SIF'::"SanitaryCodeType", '11831785000322', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Frigomarca Ltda - Várzea Grande/MT', '3505', 'SIF'::"SanitaryCodeType", '11610856000367', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Frigomarca Ltda - Novo Progresso/PA', '4686', 'SIF'::"SanitaryCodeType", '11610856000286', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Frigomarca Ltda - Senador Guiomard/AC', '4086', 'SIF'::"SanitaryCodeType", '11610856000600', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Frigorifico Pantanal Ltda - Várzea Grande/MT', '585', 'SIF'::"SanitaryCodeType", '05408755000143', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Plena Alimentos S.A. - Porangatu/GO', '3920', 'SIF'::"SanitaryCodeType", '10198974000851', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Plena Alimentos S.A. - Paraíso do Tocantins/TO', '3215', 'SIF'::"SanitaryCodeType", '10198974000185', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Plena Alimentos S.A. - Contagem/MG', '4060', 'SIF'::"SanitaryCodeType", '10198974000347', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Plena Alimentos S.A. - Pará de Minas/MG', '2484', 'SIF'::"SanitaryCodeType", '10198974000690', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Frisa Frigorífico Rio Doce S.A. - Colatina/ES', '506', 'SIF'::"SanitaryCodeType", '27497684000135', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Frigorífico Nordeste Alimentos Ltda - Teixeira de Freitas/BA', '3448', 'SIF'::"SanitaryCodeType", '01066650000100', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Frisacre Frigorifico Santo Afonso do Acre Ltda - Jandira/SP', '5321', 'SIF'::"SanitaryCodeType", '14290696000576', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, false, false, now(), now()),
  ('Frisacre Frigorifico Santo Afonso do Acre Ltda - Rio Branco/AC', '3297', 'SIF'::"SanitaryCodeType", '14290696000142', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Frigorífico Rio Machado Indústria e Comércio de Carnes S.A. - Ji-Paraná/RO', '4267', 'SIF'::"SanitaryCodeType", '33129474000197', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Falcao Industria de Alimentos Ltda - Juruena/MT', '2620', 'SIF'::"SanitaryCodeType", '11958002001003', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Bmg Foods Importação e Exportação Ltda - Colorado/PR', '2153', 'SIF'::"SanitaryCodeType", '10989834001016', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Bmg Foods Importacao e Exportacao Ltda - Cacoal/RO', '5590', 'SIF'::"SanitaryCodeType", '10989834003736', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, true, false, now(), now()),
  ('Frigorifico Vila Bela Ltda - Vila Bela da Santíssima Trindade/MT', '5393', 'SIF'::"SanitaryCodeType", '24593984000120', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, false, false, now(), now()),
  ('Vpj Comercio de Produtos Alimenticios Ltda - Jundiai/SP', '3452', 'SIF'::"SanitaryCodeType", '07162028000840', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, false, false, now(), now()),
  ('Vpj Comercio de Produtos Limenticios Ltda - Pirassununga', '3537', 'SIF'::"SanitaryCodeType", NULL, 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, false, false, now(), now()),
  ('Vpj Comercio de Produtos Alimenticios Ltda - Pirassununga/SP', '5562', 'SIF'::"SanitaryCodeType", '07162028000174', 'frigorifico'::"PlantType", ARRAY[]::"PlantType"[], ARRAY['bovino']::"Species"[], 'IN', '{}'::jsonb, false, false, now(), now())
) AS v(name, "sanitaryCode", "sanitaryCodeType", cnpj, type, capabilities, species, division, address, "isActive", "isExternal", created_at, updated_at)
WHERE NOT EXISTS (
  SELECT 1 FROM plants p WHERE p."sanitaryCode" = v."sanitaryCode"
);

-- Conferencia: quantas passaram a existir da lista importada
SELECT "isActive", count(*) FROM plants
WHERE "sanitaryCode" = ANY(ARRAY['3941','1440','2801','1251','89','941','3624','2872','1925','2121','2782','1723','2852','5125','3386','2679','2803','372','3576','1733','4398','2924','2443','1891','2258','889','1206','3654','584','1883','1646','2431','5018','93','1914','723','4293','3314','1616','112','411','4466','809','177','4029','3112','1758','5164','2437','5317','860','4490','2937','3348','3405','3974','1811','1365','661','4334','4695','2583','4150','2960','4554','4413','3505','4686','4086','585','3920','3215','4060','2484','506','3448','5321','3297','4267','2620','2153','5590','5393','3452','3537','5562'])
GROUP BY "isActive" ORDER BY "isActive";
