# SQLs de Verificação — TASK-07 (Desossa Bovinos)

> Migration: `20260504180000_add_desossa_and_external_plants`
>
> Adiciona o tipo de produção `desossa` ao enum `ProductionType` e
> seis campos de planta externa (cert não-FAMBRAS) à tabela `plants`,
> habilitando o relatório FM 7.1.4.15 com rastreabilidade de origens
> de carcaça (incluindo plantas certificadas por outras certificadoras).

---

## 1. Verificar migration aplicada

```sql
SELECT migration_name, finished_at
FROM _prisma_migrations
WHERE migration_name = '20260504180000_add_desossa_and_external_plants'
  AND finished_at IS NOT NULL;
-- Esperado: 1 row
```

## 2. Verificar valor `desossa` no enum ProductionType

```sql
SELECT unnest(enum_range(NULL::"ProductionType"))::text AS value
ORDER BY 1;
-- Esperado: contém 'desossa' junto com fabricacao, tripas, fracionamento,
-- couro, mucosa, heparina_bruta, heparina_purificacao, raspa, gelatina
```

## 3. Verificar campos novos em `plants`

```sql
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'plants'
  AND column_name IN (
    'isExternal',
    'certifierName',
    'externalCertNumber',
    'externalCertIssueDate',
    'externalCertExpiryDate',
    'externalCertS3Key'
  )
ORDER BY column_name;

-- Esperado (6 linhas):
-- certifierName            | text    | YES |
-- externalCertExpiryDate   | date    | YES |
-- externalCertIssueDate    | date    | YES |
-- externalCertNumber       | text    | YES |
-- externalCertS3Key        | text    | YES |
-- isExternal               | boolean | NO  | false
```

## 4. Verificar índices criados

```sql
SELECT indexname, tablename
FROM pg_indexes
WHERE tablename = 'plants'
  AND indexname IN ('plants_isExternal_idx', 'plants_certifierName_idx');
-- Esperado: 2 rows
```

## 5. Verificar dados existentes não foram afetados

```sql
SELECT count(*) AS plantas_total FROM plants;
SELECT count(*) AS plantas_externas FROM plants WHERE "isExternal" = true;
SELECT count(*) AS plantas_internas FROM plants WHERE "isExternal" = false;
-- Esperado:
-- plantas_total = igual ao total antes da migration
-- plantas_externas = 0 (campo novo, default false)
-- plantas_internas = plantas_total
```

## 6. Smoke test — criar uma planta externa via SQL

```sql
-- Inserir planta externa de teste (CDIAL)
INSERT INTO plants (
  id, name, "sifCode", type, species, "isActive",
  "isExternal", "certifierName", "externalCertNumber",
  "externalCertIssueDate", "externalCertExpiryDate",
  "createdAt", "updatedAt"
) VALUES (
  uuid_generate_v4(),
  'Frigorífico Teste CDIAL',
  'TEST-9999',
  'abatedouro',
  ARRAY['bovino']::"Species"[],
  true,
  true,
  'CDIAL Halal',
  'CDIAL-2026-001',
  '2026-01-15',
  '2027-01-15',
  now(),
  now()
);

-- Verificar
SELECT name, "sifCode", "isExternal", "certifierName", "externalCertNumber",
       "externalCertExpiryDate"
FROM plants
WHERE "sifCode" = 'TEST-9999';

-- Cleanup do smoke test (rodar após validação)
DELETE FROM plants WHERE "sifCode" = 'TEST-9999';
```

## 7. Listar plantas que aparecerão no dropdown de origem (DesossaFields)

```sql
-- Plantas ativas (interno + externo) que o supervisor pode escolher como origem
SELECT id, name, "sifCode", type, "isExternal",
       coalesce("certifierName", 'FAMBRAS') AS certificadora,
       "externalCertExpiryDate" AS validade_cert_externa
FROM plants
WHERE "isActive" = true
ORDER BY "isExternal", name;
```

## 8. Verificar fm-metadata expõe `desossa`

Endpoint backend: `GET /fm-metadata/production/desossa`

```bash
curl -X GET "https://supervisao-industrial-api.ecohalal.technology/fm-metadata/production/desossa" \
  -H "Authorization: Bearer <token>"
```

Esperado (resposta JSON):
```json
{
  "formNumber": "FM 7.1.4.15",
  "revision": "01",
  "revisionDate": "TBD",
  "titlePt": "RELATÓRIO DE DESOSSA",
  "titleEn": "DEBONING REPORT",
  "verifications": [
    { "pt": "Somente carcaças provenientes do abate Halal são desossadas.", "en": "Only carcasses from Halal slaughtered are deboned." },
    { "pt": "Todas as carcaças Halal estão identificadas.", "en": "All Halal carcasses are identified." },
    { "pt": "As condições da área de processamento estão satisfatórias...", "en": "The process place conditions are satisfactory..." },
    { "pt": "Todos os produtos finais Halal contêm a apropriada identificação na embalagem.", "en": "All Halal end products contain the appropriate identification on the packaging." }
  ]
}
```

## 9. Smoke test — criar relatório de produção tipo `desossa` via SQL

```sql
-- Apenas referência: produção via API é o caminho correto. Use este SQL
-- somente para inspecionar como o registro fica gravado.
SELECT id, "serialNumber", "productionType", "plantId", "customFields"
FROM production_reports
WHERE "productionType" = 'desossa'
ORDER BY "createdAt" DESC
LIMIT 5;
```

Estrutura esperada em `customFields`:
```json
{
  "shift": "1º turno",
  "observations": "...",
  "origins": [
    {
      "id": "uuid",
      "plantId": "uuid-da-planta-origem",
      "slaughterDate": "2026-05-03",
      "stunningUsed": false,
      "carcassQty": 42
    }
  ]
}
```

---

## Pendências pós-migration

- [ ] Confirmar `revisionDate` do FM 7.1.4.15 com Elaine (Qualidade FAMBRAS) e atualizar em `fm-metadata.ts` (placeholder `'TBD'` no momento)
- [ ] Cadastrar plantas externas reais (CDIAL, IFANCA, etc.) que aparecem como origem nas operações FAMBRAS
- [ ] Upload de PDF de certificado externo para S3 (UI ainda não implementada — campo `externalCertS3Key` aceita via PATCH manual)
- [ ] Smoke test em staging: criar relatório de desossa multi-origens, gerar PDF, validar com Elaine
