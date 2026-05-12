# Playbook de Execução — Reset Base Prod + Smoke Test Sprints 1–5

> **STATUS 2026-05-12:** Fases 1-5 ✅ executadas + Sprint 1 e 2 do smoke test ✅
> validadas. Sprints 3, 4, 5 ainda pendentes. Ver
> [SMOKE-TEST-2026-05-11-RESULTADOS.md](SMOKE-TEST-2026-05-11-RESULTADOS.md) e
> [BRIEFING-PROXIMA-SESSAO-SMOKE-TEST.md](BRIEFING-PROXIMA-SESSAO-SMOKE-TEST.md)
> pra retomar.

**Objetivo:** liberar SIH para uso pleno do cliente após validar todas as 5
Sprints (TASK-01 a TASK-11) em produção, com base limpa.

**Executor:** Renato (PO)
**Tempo total:** ~2,5–3 h (reset + setup + smoke test)
**Pré-requisitos:** acesso prod, DevTools aberto, certificado FAMBRAS real, email funcional do supervisor de teste

---

## Fluxo macro

```
[ FASE 1 ] Backup prod                      ~15 min
[ FASE 2 ] Verificação pré-reset            ~5 min
[ FASE 3 ] Reset base                       ~10 min
[ FASE 4 ] Verificação pós-reset            ~5 min
[ FASE 5 ] Setup smoke test (Bloco 0)       ~10 min
[ FASE 6 ] Smoke test Sprints 1–5           ~90–120 min
[ FASE 7 ] Decisão de liberação             ~10 min
```

Cada fase é um **gate** — se falhar, pare e reporte antes da próxima.

---

## FASE 1 — Backup prod (obrigatório)

> Sem isso não rode reset. Backup é seguro de rollback.

### 1.1 — Snapshot manual no AWS RDS

- [ ] Console AWS → RDS → instância prod do SIH → Actions → Take snapshot
- [ ] Nome sugerido: `sih-prod-pre-reset-20260511`
- [ ] Aguardar status `available`
- [ ] **Esperado:** snapshot listado e disponível

### 1.2 — Alternativa: pg_dump local

```bash
pg_dump "$DATABASE_URL" \
  --no-owner --no-acl \
  -f "sih-prod-backup-$(date +%Y%m%d-%H%M).sql"
```

- [ ] Arquivo gerado com tamanho > 0 bytes
- [ ] Salvar fora do diretório do repo (não commitar)

**Gate 1:** ✅ Backup confirmado → seguir para Fase 2 / ❌ Falha → parar

---

## FASE 2 — Verificação pré-reset

> Confirmar que está apontando para o banco certo e que o admin existe.

### 2.1 — Confirmar conexão

```sql
SELECT current_database(), current_user, inet_server_addr();
```

- [ ] Database é o prod do SIH (confirmar nome)
- [ ] **Atenção:** se conectou no banco errado, pare

### 2.2 — Confirmar admin alvo

```sql
SELECT id, name, email, role, "isActive"
FROM system_users
WHERE email = 'r.rbeiro@ecotrace.info';
```

- [ ] Retorna **exatamente 1 linha**
- [ ] `role = 'admin'`
- [ ] `isActive = true`
- [ ] **Se retornar 0 linhas:** script vai abortar — pare e me avise

### 2.3 — Snapshot de counts (referência "antes")

Rodar o bloco inteiro de [SQL-RESET-BASE-PROD.md § Snapshot pré-reset](SQL-RESET-BASE-PROD.md#4-snapshot-pré-reset-referência-pra-conferir-o-antes).

- [ ] Anotar números de cada tabela (vai conferir depois)

**Gate 2:** ✅ Admin único + counts anotados → Fase 3 / ❌ Algo divergente → parar

---

## FASE 3 — Reset base

> Tudo numa transação. `RAISE EXCEPTION` interno faz rollback automático em qualquer falha.

### 3.1 — Executar script

- [ ] Abrir [SQL-RESET-BASE-PROD.md § Script Principal](SQL-RESET-BASE-PROD.md#script-principal--reset)
- [ ] Copiar tudo do `BEGIN;` até o `END $$;` final (passo 6)
- [ ] Colar no cliente SQL conectado em prod
- [ ] Executar

### 3.2 — Inspecionar NOTICEs

Esperar 4 NOTICEs:

- [ ] `OK: admin alvo encontrado, sera renomeado para admin@sih.com`
- [ ] `OK: admin renomeado para admin@sih.com`
- [ ] `OK: reset concluido. 1 admin, 0 plantas, 0 relatorios.`

**Se aparecer `ABORT:` em qualquer um:** a transação ainda NÃO foi commitada. Rode `ROLLBACK;` e me avise.

### 3.3 — Commit manual

- [ ] Confirmar visualmente os 3 NOTICEs `OK`
- [ ] Executar:
  ```sql
  COMMIT;
  ```
- [ ] **Esperado:** sem erro, transação fechada

**Gate 3:** ✅ COMMIT executado / ❌ ROLLBACK + parar

---

## FASE 4 — Verificação pós-reset

### 4.1 — Re-rodar snapshot de counts

Mesmo bloco da fase 2.3.

- [ ] `system_users = 1`
- [ ] **Todas** as outras tabelas = 0

### 4.2 — Confirmar admin renomeado

```sql
SELECT id, name, email, role, "isActive", "companyGroup", "isManager"
FROM system_users;
```

- [ ] 1 linha
- [ ] `email = 'admin@sih.com'`
- [ ] `name = 'Admin'`
- [ ] `role = 'admin'`
- [ ] `isActive = true`
- [ ] `companyGroup = NULL`
- [ ] `isManager = false`

**Gate 4:** ✅ Counts e admin batem → Fase 5 / ❌ Algo errado → restaurar do snapshot RDS

---

## FASE 5 — Setup smoke test (Bloco 0)

> Recriar plantas e usuários mínimos pra testar. Detalhes em [SMOKE-TEST-SPRINTS-1-5.md § BLOCO 0](SMOKE-TEST-SPRINTS-1-5.md#bloco-0--setup-criar-usuários-e-plantas).

### 5.1 — Login como admin

- [ ] Abrir URL do frontend prod
- [ ] Login: `admin@sih.com` + senha que você usava antes
- [ ] **Esperado:** dashboard admin abre sem erro
- [ ] **Opcional:** trocar senha pela UI

### 5.2 — Criar 2 plantas

- [ ] Planta 1 com `companyGroup = IN` (in natura — abate / frigorífico)
- [ ] Planta 2 com `companyGroup = IND` (industrializados — processamento)
- [ ] **Esperado:** campo "Grupo Empresarial" visível e persistido em ambas

### 5.3 — Criar 5 usuários de teste

| # | Nome | Role | companyGroup | extraPlantAccess | isManager |
|---|---|---|---|---|---|
| 1 | sup-IN-teste | supervisor | — | — | — |
| 2 | sup-IND-teste | supervisor | — | — | — |
| 3 | ctrl-IN-teste | controlador | IN | (vazio) | false |
| 4 | ctrl-IND-teste | controlador | IND | 1 planta IN | false |
| 5 | ctrl-gestor-teste | controlador | IN | (vazio) | **true** |

> ⚠ Use seu **email real** no usuário 1 (sup-IN-teste). Vai ser o destinatário do email SES no Bloco 4.3.

- [ ] 5 usuários criados, validações de UI passaram (ver SMOKE-TEST § 0.2)

**Gate 5:** ✅ Plantas + 5 usuários OK → Fase 6 / ❌ Falha em criação → reportar

---

## FASE 6 — Smoke test Sprints 1–5

Rodar **em ordem** os blocos de [SMOKE-TEST-SPRINTS-1-5.md](SMOKE-TEST-SPRINTS-1-5.md):

- [ ] **BLOCO 1** — Sprint 1 (TASK-02 + TASK-03) — controladoria + segmentação grupo
- [ ] **BLOCO 2** — Sprint 2 (TASK-01 + TASK-04) — duplo check + dashboard
- [ ] **BLOCO 3** — Sprint 3 (TASK-05 + TASK-08) — transferências + degolador
- [ ] **BLOCO 4** — Sprint 4 (TASK-06 + TASK-09) — notificações + anexos
- [ ] **BLOCO 5** — Sprint 5 (TASK-07 + TASK-11) — desossa + plantas externas + SysHalal
- [ ] **BLOCO 6** — Pendências de infra (ícone PWA + AUTO_MIGRATE)

**Regra de ouro:** em qualquer falha, parar o bloco em curso, anotar:
- URL exata
- Status HTTP (DevTools → Network)
- Mensagem de erro (UI + console)
- Body da request quando aplicável

E me reportar antes de seguir.

---

## FASE 7 — Decisão de liberação

Após os 6 blocos:

| Resultado | Decisão |
|---|---|
| Todos verdes | ✅ **Liberar para cliente** — anunciar Sprints 1–5 em produção |
| 1–2 falhas pontuais não-bloqueantes | 🟡 Liberar + abrir hotfix em `release` |
| Falha em fluxo crítico (login, assinatura, aprovação) | 🔴 **Não liberar** — hotfix prioritário ou rollback do commit |
| Falha em integração externa (SES, SysHalal) | 🟡 Liberar com aviso — fluxo manual de fallback |

### Template do retorno

```
Resumo: X/6 blocos verdes
Falhas:
  - BLOCO N.M — descrição curta
    URL: ...
    Status: 4xx/5xx
    Erro: "..."
    Body: { ... }

Decisão sugerida: [liberar / hotfix / rollback / aceitar bug]
```

---

## Rollback de emergência

Se algo der errado **após COMMIT** (Fase 3.3) e antes de gerar dados úteis no smoke test:

1. Console AWS → RDS → snapshots → escolher `sih-prod-pre-reset-20260511`
2. Actions → Restore snapshot → restaurar para nova instância
3. Cutover de DNS / Secrets Manager para apontar a aplicação ao restore
4. Me avisar — vou ajudar com o cutover

Se foi por pg_dump:

```bash
psql "$DATABASE_URL_RESTORE" < sih-prod-backup-AAAAMMDD-HHMM.sql
```

---

## Arquivos referenciados

| Arquivo | Uso |
|---|---|
| [SQL-RESET-BASE-PROD.md](SQL-RESET-BASE-PROD.md) | Script SQL completo do reset |
| [SMOKE-TEST-SPRINTS-1-5.md](SMOKE-TEST-SPRINTS-1-5.md) | Roteiro dos 6 blocos de smoke test |
| [SQL-VERIFICACAO-SPRINT1.md](SQL-VERIFICACAO-SPRINT1.md) | Verificações de migration Sprint 1 |
| [SQL-VERIFICACAO-SPRINT2.md](SQL-VERIFICACAO-SPRINT2.md) | Verificações de migration Sprint 2 |
| [SQL-VERIFICACAO-SPRINT4.md](SQL-VERIFICACAO-SPRINT4.md) | Verificações de migration Sprint 4 |
| [SQL-VERIFICACAO-SPRINT5.md](SQL-VERIFICACAO-SPRINT5.md) | Verificações de migration Sprint 5 |
| [SQL-VERIFICACAO-DESOSSA.md](SQL-VERIFICACAO-DESOSSA.md) | Verificações de migration TASK-07 |
