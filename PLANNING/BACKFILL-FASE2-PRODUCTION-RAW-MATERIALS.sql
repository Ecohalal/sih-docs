-- ════════════════════════════════════════════════════════════════════════
-- BACKFILL Fase 2 — meatRawMaterials (Json) → production_raw_materials
-- ────────────────────────────────────────────────────────────────────────
-- Rodar DEPOIS do deploy da migration 20260614170000_fase2_production_raw_materials.
-- Idempotente: so insere para relatorios que ainda NAO tem linhas relacionais.
-- O Json (meatRawMaterials) permanece como fonte da verdade (sombra) ate a
-- reconciliacao validar peso/contagem. So cobre tipos que usam meatRawMaterials
-- (padrao/fabricacao); tipos especializados (desossa, heparina, gelatina...)
-- guardam MP em customFields e serao migrados no estagio 2c.
-- ════════════════════════════════════════════════════════════════════════

BEGIN;

INSERT INTO production_raw_materials (
  "productionReportId", "proteinType", "originName", "sanitaryCode",
  "slaughterDateText", "csnNumber", "halalCertNumber", "quantityKg", "unit", "updated_at"
)
SELECT pr.id,
       NULLIF(COALESCE(elem->>'proteinType', elem->>'description'), ''),
       NULLIF(elem->>'slaughterhouse', ''),
       NULLIF(COALESCE(elem->>'sifNumber', elem->>'sifOrigin'), ''),
       NULLIF(elem->>'slaughterDateRange', ''),
       NULLIF(elem->>'csnNumber', ''),
       NULLIF(elem->>'halalCertNumber', ''),
       CASE WHEN replace(elem->>'quantity', ',', '.') ~ '^[0-9]+(\.[0-9]+)?$'
            THEN replace(elem->>'quantity', ',', '.')::decimal(12,3) END,
       NULLIF(elem->>'unit', ''),
       CURRENT_TIMESTAMP
FROM production_reports pr
CROSS JOIN LATERAL jsonb_array_elements(pr."meatRawMaterials") AS elem
WHERE jsonb_typeof(pr."meatRawMaterials") = 'array'
  AND NOT EXISTS (
    SELECT 1 FROM production_raw_materials prm WHERE prm."productionReportId" = pr.id
  );

-- ── RECONCILIAÇÃO (rodar dentro da MESMA transacao, antes do COMMIT) ──
-- PASS esperado:
--   linhas_json  = linhas_relacionais  (contagem casa)
--   reports_sem_match = 0              (nenhum relatorio com array ficou sem linhas)
SELECT
  (SELECT count(*)
     FROM production_reports pr
     CROSS JOIN LATERAL jsonb_array_elements(pr."meatRawMaterials") e
     WHERE jsonb_typeof(pr."meatRawMaterials") = 'array')                AS linhas_json,
  (SELECT count(*) FROM production_raw_materials)                        AS linhas_relacionais,
  (SELECT count(*)
     FROM production_reports pr
     WHERE jsonb_typeof(pr."meatRawMaterials") = 'array'
       AND jsonb_array_length(pr."meatRawMaterials") > 0
       AND NOT EXISTS (SELECT 1 FROM production_raw_materials prm
                       WHERE prm."productionReportId" = pr.id))          AS reports_sem_match;

-- Conferencia de PESO total (Json vs relacional). Diferenca esperada: ~0
-- (pode divergir em linhas cuja quantity nao era numerica — investigar essas).
SELECT
  COALESCE((SELECT sum(replace(e->>'quantity', ',', '.')::decimal)
     FROM production_reports pr
     CROSS JOIN LATERAL jsonb_array_elements(pr."meatRawMaterials") e
     WHERE jsonb_typeof(pr."meatRawMaterials") = 'array'
       AND replace(e->>'quantity', ',', '.') ~ '^[0-9]+(\.[0-9]+)?$'), 0) AS peso_json,
  COALESCE((SELECT sum("quantityKg") FROM production_raw_materials), 0)     AS peso_relacional;

-- Se os numeros baterem: COMMIT;  caso contrario: ROLLBACK;
-- COMMIT;
ROLLBACK;
