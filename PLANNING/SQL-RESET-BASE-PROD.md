# Reset Total da Base SIH — Produção

> **Operação destrutiva.** Apaga **todos** os relatórios, inventário, NCs,
> colaboradores, escalas, plantas, anexos, notificações e usuários.
> Mantém apenas **1 admin** com email `admin@sih.com`.

**Data alvo:** 2026-05-07
**Motivação:** zerar a base antes do smoke test das Sprints 1–5 com dados limpos.

---

## ⚠ Antes de rodar

### 1. Backup obrigatório

Antes de executar qualquer DELETE, gerar dump completo da base:

```bash
# Exemplo (substitua pela sua DATABASE_URL prod):
pg_dump "$DATABASE_URL" \
  --no-owner --no-acl \
  -f "sih-prod-backup-$(date +%Y%m%d-%H%M).sql"
```

Ou gerar **snapshot manual no AWS RDS** pelo console antes de rodar.

### 2. Confirmar conexão correta

```sql
SELECT current_database(), current_user, inet_server_addr();
-- Confirme que está apontando para o banco prod.
```

### 3. Conferir o admin que será preservado

```sql
SELECT id, name, email, role, "isActive"
FROM system_users
WHERE email = 'r.rbeiro@ecotrace.info';
-- Esperado: 1 linha, role = 'admin'.
-- Se vier 0 linhas: PARE — script vai abortar.
```

### 4. Snapshot pré-reset (referência pra conferir o "antes")

```sql
SELECT
  'system_users' AS tabela, COUNT(*) AS rows FROM system_users
UNION ALL SELECT 'plants', COUNT(*) FROM plants
UNION ALL SELECT 'slaughter_reports', COUNT(*) FROM slaughter_reports
UNION ALL SELECT 'production_reports', COUNT(*) FROM production_reports
UNION ALL SELECT 'shipping_reports', COUNT(*) FROM shipping_reports
UNION ALL SELECT 'non_conformities', COUNT(*) FROM non_conformities
UNION ALL SELECT 'collaborators', COUNT(*) FROM collaborators
UNION ALL SELECT 'collaborator_plants', COUNT(*) FROM collaborator_plants
UNION ALL SELECT 'report_staff', COUNT(*) FROM report_staff
UNION ALL SELECT 'user_schedules', COUNT(*) FROM user_schedules
UNION ALL SELECT 'meat_inventory_receipts', COUNT(*) FROM meat_inventory_receipts
UNION ALL SELECT 'meat_inventory_cuts', COUNT(*) FROM meat_inventory_cuts
UNION ALL SELECT 'meat_inventory_usages', COUNT(*) FROM meat_inventory_usages
UNION ALL SELECT 'batch_inventories', COUNT(*) FROM batch_inventories
UNION ALL SELECT 'batch_transfers', COUNT(*) FROM batch_transfers
UNION ALL SELECT 'labeling_inventories', COUNT(*) FROM labeling_inventories
UNION ALL SELECT 'notifications', COUNT(*) FROM notifications
UNION ALL SELECT 'report_attachments', COUNT(*) FROM report_attachments
ORDER BY tabela;
```

Anote os números. Após reset, todos devem ir a **0** exceto `system_users = 1`.

---

## Script Principal — Reset

> Tudo dentro de uma única transação. Se qualquer passo falhar, basta `ROLLBACK`.

```sql
BEGIN;

-- =======================================================================
-- PASSO 1: Verificar admin alvo existe (aborta se nao encontrar)
-- =======================================================================
DO $$
DECLARE
  admin_count int;
BEGIN
  SELECT COUNT(*) INTO admin_count
  FROM system_users
  WHERE email = 'r.rbeiro@ecotrace.info';

  IF admin_count = 0 THEN
    RAISE EXCEPTION 'ABORT: admin com email r.rbeiro@ecotrace.info nao encontrado. Nada apagado.';
  END IF;

  IF admin_count > 1 THEN
    RAISE EXCEPTION 'ABORT: % usuarios com mesmo email r.rbeiro@ecotrace.info. Inconsistencia.', admin_count;
  END IF;

  RAISE NOTICE 'OK: admin alvo encontrado, sera renomeado para admin@sih.com';
END $$;

-- =======================================================================
-- PASSO 2: Renomear admin atual para admin@sih.com
-- (mantem a senha que ja funciona — voce troca depois pela UI se quiser)
-- UPDATE + check juntos no mesmo DO $$ pra GET DIAGNOSTICS pegar o ROW_COUNT
-- do UPDATE (so funciona se rodar no mesmo bloco PL/pgSQL).
-- =======================================================================
DO $$
DECLARE
  updated int;
BEGIN
  UPDATE system_users
  SET
    email             = 'admin@sih.com',
    name              = 'Admin',
    role              = 'admin',
    "isActive"        = true,
    "companyGroup"    = NULL,
    "extraPlantAccess"= NULL,
    "isManager"       = false,
    registration      = NULL,
    qualifications    = NULL,
    preferences       = NULL,
    phone             = NULL,
    "updated_at"      = NOW()
  WHERE email = 'r.rbeiro@ecotrace.info';

  GET DIAGNOSTICS updated = ROW_COUNT;
  IF updated <> 1 THEN
    RAISE EXCEPTION 'ABORT: UPDATE do admin afetou % linhas (esperado 1)', updated;
  END IF;
  RAISE NOTICE 'OK: admin renomeado para admin@sih.com';
END $$;

-- =======================================================================
-- PASSO 3: Apagar dados operacionais (filhos antes dos pais)
-- =======================================================================

-- Anexos e notificacoes (Sprint 4)
DELETE FROM report_attachments;
DELETE FROM notifications;

-- Staff de relatorios (m2m colaborador <-> relatorio)
DELETE FROM report_staff;

-- Nao-conformidades (refs plants, supervisor, reports)
DELETE FROM non_conformities;

-- Inventario (CASCADE no schema cuida de cuts/usages/transfers, mas vou explicitar)
DELETE FROM meat_inventory_usages;
DELETE FROM meat_inventory_cuts;
DELETE FROM meat_inventory_receipts;

DELETE FROM batch_transfers;
DELETE FROM batch_inventories;

DELETE FROM labeling_inventories;

-- Colaboradores (m2m com plants antes)
DELETE FROM collaborator_plants;
DELETE FROM collaborators;

-- Escalas de supervisores
DELETE FROM user_schedules;

-- Relatorios (3 tipos — todos antes de plants/supervisors)
DELETE FROM shipping_reports;
DELETE FROM production_reports;
DELETE FROM slaughter_reports;

-- =======================================================================
-- PASSO 4: Apagar plantas (todas)
-- =======================================================================
DELETE FROM plants;

-- =======================================================================
-- PASSO 5: Apagar todos os usuarios EXCETO o admin renomeado
-- =======================================================================
DELETE FROM system_users
WHERE email <> 'admin@sih.com';

-- =======================================================================
-- PASSO 6: Verificacao final dos counts
-- =======================================================================
DO $$
DECLARE
  admin_check int;
  total_users int;
  total_plants int;
  total_reports int;
BEGIN
  SELECT COUNT(*) INTO admin_check
    FROM system_users WHERE email='admin@sih.com' AND role='admin';
  SELECT COUNT(*) INTO total_users FROM system_users;
  SELECT COUNT(*) INTO total_plants FROM plants;
  SELECT
    (SELECT COUNT(*) FROM slaughter_reports) +
    (SELECT COUNT(*) FROM production_reports) +
    (SELECT COUNT(*) FROM shipping_reports)
  INTO total_reports;

  IF admin_check <> 1 THEN
    RAISE EXCEPTION 'ABORT: admin@sih.com tem % registros (esperado 1)', admin_check;
  END IF;

  IF total_users <> 1 THEN
    RAISE EXCEPTION 'ABORT: system_users tem % registros (esperado 1)', total_users;
  END IF;

  IF total_plants <> 0 THEN
    RAISE EXCEPTION 'ABORT: plants tem % registros (esperado 0)', total_plants;
  END IF;

  IF total_reports <> 0 THEN
    RAISE EXCEPTION 'ABORT: relatorios totais = % (esperado 0)', total_reports;
  END IF;

  RAISE NOTICE 'OK: reset concluido. 1 admin, 0 plantas, 0 relatorios.';
END $$;

-- =======================================================================
-- PASSO 7: COMMIT manual
-- =======================================================================
-- INSPECIONE os NOTICEs acima. Se tudo OK, rode:
--    COMMIT;
-- Se algo errado, rode:
--    ROLLBACK;
```

---

## Verificação pós-reset

Após `COMMIT;`, rodar a mesma query do snapshot pra confirmar:

```sql
SELECT
  'system_users' AS tabela, COUNT(*) AS rows FROM system_users
UNION ALL SELECT 'plants', COUNT(*) FROM plants
UNION ALL SELECT 'slaughter_reports', COUNT(*) FROM slaughter_reports
UNION ALL SELECT 'production_reports', COUNT(*) FROM production_reports
UNION ALL SELECT 'shipping_reports', COUNT(*) FROM shipping_reports
UNION ALL SELECT 'non_conformities', COUNT(*) FROM non_conformities
UNION ALL SELECT 'collaborators', COUNT(*) FROM collaborators
UNION ALL SELECT 'collaborator_plants', COUNT(*) FROM collaborator_plants
UNION ALL SELECT 'report_staff', COUNT(*) FROM report_staff
UNION ALL SELECT 'user_schedules', COUNT(*) FROM user_schedules
UNION ALL SELECT 'meat_inventory_receipts', COUNT(*) FROM meat_inventory_receipts
UNION ALL SELECT 'meat_inventory_cuts', COUNT(*) FROM meat_inventory_cuts
UNION ALL SELECT 'meat_inventory_usages', COUNT(*) FROM meat_inventory_usages
UNION ALL SELECT 'batch_inventories', COUNT(*) FROM batch_inventories
UNION ALL SELECT 'batch_transfers', COUNT(*) FROM batch_transfers
UNION ALL SELECT 'labeling_inventories', COUNT(*) FROM labeling_inventories
UNION ALL SELECT 'notifications', COUNT(*) FROM notifications
UNION ALL SELECT 'report_attachments', COUNT(*) FROM report_attachments
ORDER BY tabela;
```

**Esperado:**
- `system_users = 1`
- Todos os outros = 0

E confirmar o admin:

```sql
SELECT id, name, email, role, "isActive", "companyGroup", "isManager"
FROM system_users;
-- Esperado: 1 linha
--   email = 'admin@sih.com'
--   name  = 'Admin'
--   role  = 'admin'
--   isActive = true
```

---

## O que NÃO é tocado

Estas estruturas permanecem intactas (não são dados, são esquema):

- Tabela `_prisma_migrations` (histórico de migrations aplicadas)
- Enums (`UserRole`, `ProductionType`, `ReportStatus`, etc.)
- Views (`meat_inventory_balance`, `batch_inventory_balance`, `labeling_inventory_balance`)
- Extensões (uuid-ossp, pgcrypto, pg_trgm)
- Índices, constraints, FKs

---

## Pós-reset — passos imediatos

1. **Logar como admin** com email `admin@sih.com` e a senha que você já usava antes.
2. **(Opcional) Trocar senha** pela UI do SIH se quiser zerar credenciais.
3. **Atualizar o nome** do admin pra algo mais descritivo se preferir.
4. Seguir para o [Bloco 0 do smoke test](SMOKE-TEST-SPRINTS-1-5.md#bloco-0--setup-criar-usuários-e-plantas) — criar plantas e usuários de teste.

---

## Rollback

Se em qualquer momento entre `BEGIN` e `COMMIT` algo der errado:

```sql
ROLLBACK;
```

Tudo volta ao estado anterior. Os `RAISE EXCEPTION` no script já fazem rollback
automático — então se você ver "ABORT:" em algum NOTICE, a transação **não foi
commitada** e o banco está intacto.

Se mesmo após `COMMIT;` algo deu errado, restaurar do backup gerado na etapa 1.
