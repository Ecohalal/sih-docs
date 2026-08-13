-- =====================================================================
-- FM 20.2 — rotas de e-mail (escopo `industrial-occurrence`)
-- Banco: db_ecohalal_sih (DBeaver)  ·  Rodar como o Renato
-- =====================================================================
--
-- Origem: cabeçalho do formulário enviado pela Carol em 12/ago —
--   "Unidades BRF: enviar diariamente para qualidade@ e adel@"
--   "Outras unidades: enviar diariamente para qualidade@, lina.ramadan@ e fuad@"
--
-- O roteamento é POR ESCOPO: o FM 20.1 (aves) já tem as rotas dele em produção
-- e não é tocado aqui. Sem estas linhas, o FM 20.2 assina normalmente mas NÃO
-- avisa ninguém por e-mail.
--
-- Idempotente: pode rodar de novo sem duplicar (apaga o escopo e recria).
-- =====================================================================

BEGIN;

-- 1) Confere o que existe hoje (deve vir vazio na primeira execução)
SELECT scope, "groupKey", "groupLabel", emails, "matchSifs", "isDefault"
  FROM notification_routes
 WHERE scope = 'industrial-occurrence';

-- 2) Limpa o escopo (só o do 20.2 — não toca no 'bird-occurrence')
DELETE FROM notification_routes WHERE scope = 'industrial-occurrence';

-- 3) BRF — casa pelos SIFs das unidades BRF cadastradas no SIH.
--    ⚠️ CONFERIR a lista antes de rodar: ela sai das plantas cujo nome contém
--    'BRF'. Se a FAMBRAS considerar "unidade BRF" por CNPJ, trocar matchSifs
--    por matchCnpjs.
INSERT INTO notification_routes
  (id, scope, "groupKey", "groupLabel", emails, "matchCnpjs", "matchSifs", "isDefault", "isActive", created_at, updated_at)
SELECT
  uuid_generate_v4(),
  'industrial-occurrence',
  'brf',
  'BRF',
  ARRAY['qualidade@fambrashalal.com.br', 'adel@fambrashalal.com.br'],
  ARRAY[]::text[],
  COALESCE(
    (SELECT array_agg(DISTINCT p."sanitaryCode")
       FROM plants p
      WHERE p."isActive"
        AND p."sanitaryCode" IS NOT NULL
        AND p.name ILIKE '%BRF%'),
    ARRAY[]::text[]
  ),
  false,
  true,
  now(), now();

-- 4) Demais unidades — rota DEFAULT (vale para quem não casar acima)
INSERT INTO notification_routes
  (id, scope, "groupKey", "groupLabel", emails, "matchCnpjs", "matchSifs", "isDefault", "isActive", created_at, updated_at)
VALUES (
  uuid_generate_v4(),
  'industrial-occurrence',
  'outras',
  'Demais unidades',
  ARRAY['qualidade@fambrashalal.com.br', 'lina.ramadan@fambrashalal.com.br', 'fuad@fambrashalal.com.br'],
  ARRAY[]::text[],
  ARRAY[]::text[],
  true,
  true,
  now(), now()
);

-- 5) Confere o resultado — COLAR A SAÍDA na sessão (nunca presumir que rodou)
SELECT scope, "groupKey", "groupLabel", emails, "matchSifs", "isDefault", "isActive"
  FROM notification_routes
 WHERE scope = 'industrial-occurrence'
 ORDER BY "isDefault", "groupKey";

COMMIT;

-- =====================================================================
-- Rollback, se precisar:
--   DELETE FROM notification_routes WHERE scope = 'industrial-occurrence';
-- Isso NÃO afeta o FM 20.1 — escopos são independentes.
-- =====================================================================
