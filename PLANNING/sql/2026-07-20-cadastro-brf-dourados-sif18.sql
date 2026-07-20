-- =====================================================================
-- SIH · db_ecohalal_sih · CADASTRO DA PLANTA BRF DOURADOS (SIF 18)
-- =====================================================================
-- Origem: hands-on FAMBRAS 17/jul. O processo de aves escolhido pelo Vitor
-- era da BRF Dourados ("CIF 18"), mas a planta NAO existe no SIH — foi o
-- que impediu de refazer o fluxo abate -> transferencia -> embarque.
--
-- Dados conferidos em DUAS fontes independentes (20/jul):
--   - SysHalal (tela de cadastro, print do Renato)
--   - GC / db_ecohalal_halalsphere: plants.sanitary_code='18',
--     companies.tax_id='01838723006753', grupo 'GRUPO BRF'  -> BATEM
--
-- Idempotente: nao insere de novo se ja existir SIF 18 ou o CNPJ.
-- Rodar no DBeaver (conexao do SIH) e COLAR O OUTPUT das verificacoes.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1) ANTES: confirma que nao ha nada cadastrado (esperado: 0 linhas)
-- ---------------------------------------------------------------------
SELECT id, name, "sanitaryCode", cnpj, division
FROM plants
WHERE "sanitaryCode" = '18' OR cnpj = '01838723006753';

-- ---------------------------------------------------------------------
-- 2) INSERT
-- ---------------------------------------------------------------------
INSERT INTO plants (
  name, "sanitaryCode", "sanitaryCodeType", cnpj,
  type, capabilities, species, division,
  address, contact, "isActive", "isExternal",
  created_at, updated_at
)
SELECT
  'BRF Dourados/MS',
  '18',
  'SIF'::"SanitaryCodeType",
  '01838723006753',
  'frigorifico'::"PlantType",
  ARRAY[]::"PlantType"[],
  ARRAY['ave']::"Species"[],
  'IN',
  jsonb_build_object(
    'street',  'Rua Vereador Mario Ferreira de Aragão, 385',
    'city',    'Dourados',
    'state',   'MS',
    'zipCode', '79839-707'
  ),
  jsonb_build_object('email', '', 'phone', '', 'responsible', ''),
  true,
  false,
  now(),
  now()
WHERE NOT EXISTS (
  SELECT 1 FROM plants
  WHERE "sanitaryCode" = '18' OR cnpj = '01838723006753'
);

-- ---------------------------------------------------------------------
-- 3) DEPOIS: confere o registro criado (esperado: 1 linha)
-- ---------------------------------------------------------------------
SELECT id, name, "sanitaryCode", "sanitaryCodeType"::text AS tipo, cnpj,
       type::text AS type, species::text AS species,
       division, "isActive", address::text AS address
FROM plants
WHERE "sanitaryCode" = '18';

-- ---------------------------------------------------------------------
-- 4) DEPOIS: a carteira In Natura passa de 2 para 3 plantas ativas
-- ---------------------------------------------------------------------
SELECT division, count(*) FILTER (WHERE "isActive") AS ativas
FROM plants
WHERE division = 'IN'
GROUP BY division;


-- =====================================================================
-- OPCIONAL — so se o Renato confirmar (NAO roda junto)
-- =====================================================================
-- (a) A tela do SysHalal marca a BRF Dourados tambem como "Processador".
--     Se ela de fato faz industrializado, incluir a capability abaixo. Isso
--     a torna elegivel aos dropdowns de producao (fabricacao/fracionamento).
--     Deixei FORA do insert porque a irma BRF Nova Mutum esta sem nenhuma
--     capability — incluir aqui criaria divergencia entre as duas.
--
-- UPDATE plants SET capabilities = ARRAY['processamento']::"PlantType"[],
--        updated_at = now()
--  WHERE "sanitaryCode" = '18';
--
-- (b) Vinculo do supervisor: fazer pela UI (Usuarios > editar > Plantas).
--     O usuario Ziad Mansour ainda NAO existe e a criacao exige hash bcrypt
--     da senha — nao da para fazer em SQL puro sem gerar o hash fora.
-- =====================================================================


-- =====================================================================
-- DIVERGENCIA DE ENDERECO — decisao do Renato
-- =====================================================================
-- No SysHalal os dois campos discordam entre si:
--   Endereco (estruturado): "Rua Vereador Mario Ferreira de Aragão, 385,
--                            Distrito Industrial de Dourados" + CEP 79839-707
--   Observacoes (texto):    "BRF S.A., AVENIDA 04 S/N, QUADRA 13 PARQUE
--                            INDUSTRIAL"
-- Usei o campo ESTRUTURADO, que tem CEP e bairro coerentes. Se o certo for
-- o das observacoes, corrigir aqui E na fonte (SysHalal + GC).
-- =====================================================================
