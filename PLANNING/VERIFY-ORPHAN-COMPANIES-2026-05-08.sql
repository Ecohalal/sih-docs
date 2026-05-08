-- Verificação: Companies sem Plant (órfãs após o refactor multi-país)
-- Sprint Fase 2 — Plant CRUD (2026-05-08)
--
-- Objetivo: detectar empresas que não têm nenhuma Plant cadastrada.
-- Sem Plant não é possível criar Certificação (FK obrigatória plantId).
--
-- Como rodar (psql / Aurora):
--   \i deploy/verify-orphan-companies.sql
--
-- Saída esperada:
--   - Bloco 1: contagem total de companies x companies com plants
--   - Bloco 2: lista das órfãs (até 50) com legalName + relationship
--   - Bloco 3: contagem de companies cliente FAMBRAS sem plant (caso urgente)

\echo '== Bloco 1: cobertura geral =='
SELECT
  (SELECT COUNT(*) FROM "Company") AS total_companies,
  (SELECT COUNT(DISTINCT "company_id") FROM "Plant") AS companies_with_plants,
  (SELECT COUNT(*) FROM "Company" c
    WHERE NOT EXISTS (SELECT 1 FROM "Plant" p WHERE p."company_id" = c.id)
  ) AS companies_without_plants;

\echo ''
\echo '== Bloco 2: lista de órfãs (até 50) =='
SELECT
  c.id,
  c."legal_name",
  c."tax_id",
  c."tax_id_type",
  c."country",
  c."relationship",
  c."is_active",
  c."created_at"
FROM "Company" c
WHERE NOT EXISTS (SELECT 1 FROM "Plant" p WHERE p."company_id" = c.id)
ORDER BY c."created_at" DESC
LIMIT 50;

\echo ''
\echo '== Bloco 3: clientes FAMBRAS sem planta (alta prioridade) =='
SELECT
  c.id,
  c."legal_name",
  c."tax_id",
  c."country",
  c."pending_validation",
  c."created_at"
FROM "Company" c
WHERE c."relationship" = 'client'
  AND c."is_active" = true
  AND NOT EXISTS (SELECT 1 FROM "Plant" p WHERE p."company_id" = c.id)
ORDER BY c."created_at" DESC;
