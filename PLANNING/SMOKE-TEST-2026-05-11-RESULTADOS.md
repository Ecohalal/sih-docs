# Smoke Test SIH — Resultados da Sessão 2026-05-11/12

**Duração:** sessão única estendida (~6+ horas)
**Executor:** Renato (PO) + Claude
**Backup:** `C:\Dump_Halal\dump-db_ecohalal_sih-202605111435.sql` (85 KB, Custom format)

---

## TL;DR

✅ **Reset prod executado com sucesso** — base limpa, admin renomeado para
`admin@sih.com`.

✅ **Sprint 1 + Sprint 2 validadas end-to-end em produção** — segmentação
IN/IND, duplo check (Assumir → Aprovar / Rejeitar com motivo → Reabrir →
Re-assinar) com histórico completo de transições funcionando.

❌ **Sprints 3, 4, 5 ainda não validadas** — fica pra próxima sessão.

🐛 **4 bugs corrigidos e deployados** durante o smoke test (todos
pré-existentes, descobertos pelo próprio fluxo de teste).

🐛 **6 pendências mapeadas** — não bloqueiam liberação, mas precisam ataque
em outras sessões.

---

## Fases concluídas

### FASE 1-4 — Reset prod ✅

| Fase | Status | Notas |
|---|---|---|
| 1. Backup pg_dump | ✅ | DBeaver Custom format, 85 KB |
| 2. Verificação pré-reset | ✅ | 11 users, 3 plants, 9 reports, 4 NCs, 5 collabs, 6 schedules |
| 3. Reset (rename admin + DELETEs) | ✅ | Bug GET DIAGNOSTICS no script corrigido in-flight |
| 4. Verificação pós-reset | ✅ | 1 admin, 0 de tudo o resto |

### FASE 5 — Setup smoke test ✅

| Recurso | Quantidade | Detalhe |
|---|---|---|
| Admin | 1 | `admin@sih.com` (era `r.rbeiro@ecotrace.info` com typo histórico) |
| Plantas | 3 | Planta IN Teste (SIF 0001, frigorifico, IN), Planta IND Teste (SIF 0002, processamento, IND), Planta TESTE Divisão 2 (SIF 0003, IN) |
| Usuários teste | 5 | senha `Teste@2026` em todos |

**Usuários teste:**

| Nome | Email | Role | Divisão | extraPlantAccess | isManager |
|---|---|---|---|---|---|
| sup-IN-teste | r.ribeiro@ecotrace.info | supervisor | — | — | false |
| sup-IND-teste | sup.ind@teste.com | supervisor | — | — | false |
| ctrl-IN-teste | ctrl.in@teste.com | controlador | IN | — | false |
| ctrl-IND-teste | ctrl.ind@teste.com | controlador | IND | [Planta IN Teste] | false |
| ctrl-gestor-teste | gestor@teste.com | controlador | IN | — | **true** |

### FASE 6 BLOCO 1 — Sprint 1 (TASK-02 + TASK-03) ✅

- **1.1** Controlador não vê botão "Novo Relatório" em Abate/Produção/Embarque ✅ (após fix do canCreate)
- **1.2** Sidebar mostra "Controladoria" pra controlador ✅
- **1.3** Segmentação IN/IND nas 3 dashboards:
  - ctrl-IN-teste vê só relatório IN ✅
  - ctrl-IND-teste vê IND + IN (via extraPlantAccess) ✅
  - ctrl-gestor-teste vê tudo ✅

### FASE 6 BLOCO 2 — Sprint 2 (TASK-01 + TASK-04) ✅

- **2.1** Fluxo Aprovação (Assumir → Aprovar) ✅
- **2.2** Fluxo Rejeição:
  - Motivo obrigatório (vazio bloqueia) ✅
  - Rejeição funciona, KPIs atualizam ✅
  - sup-IN vê banner "devolvido pela Controladoria" com motivo ✅
  - Botão [Reabrir para Edição] disponível ✅
  - Reabrir → editar → re-assinar funciona ✅
  - Volta pra Fila Pendente do controlador ✅
- **2.3** statusHistory completo com 7 transições + timestamps + motivo da rejeição visível ✅
- **2.4** Gestor reatribui — **não testado** (pulado nesta sessão)
- **2.5** Aging visual (cores < 24h / 24-48h / > 48h) — **não testado**
- **2.6** KPIs (Na fila / Em análise / Aprovados / Rejeitados) — visualmente validado ✅

---

## Bugs corrigidos e deployados nesta sessão

### Bug 1: Plant DTO sem campo `companyGroup`/`division`

- **Sintoma:** frontend enviava `companyGroup: "IN"`, banco salvava `NULL`
- **Causa:** `PlantBaseSchema` (Zod) não tinha o campo → ValidationPipe stripava
- **Fix:** parte do refactor maior (Bug 2)
- **Commit backend:** `1ef4426`

### Bug 2: Naming `companyGroup` semanticamente errado (refactor)

- **Sintoma:** o campo guardava `IN`/`IND` (categoria de produto), mas o nome
  `companyGroup` remetia a grupo corporativo (Minerva, BRF)
- **Decisão:** renomear pra `division` (alinha com vocabulário FAMBRAS: equipes
  IN e IND são divisões organizacionais distintas)
- **Why não `category`:** já é usado no HalalSphere pra `IndustrialCategory` (GSO/SMIIC)
- **Scope:** full stack (17 arquivos backend + 6 frontend)
- **Migration:** `20260511160000_rename_companygroup_to_division` (ALTER TABLE
  RENAME COLUMN, preserva dados)
- **AUTO_MIGRATE não rodou** (2ª vez) → aplicado manualmente via DBeaver,
  registrado em `_prisma_migrations` com checksum 'manual'
- **Commits:** sih-backend `1ef4426` + sih-frontend `48e4f0c`

### Bug 3: UserForm `limit=200` ultrapassa max do backend

- **Sintoma:** GET /plants?limit=200 → 400. Multiselect "Acesso Extra a Plantas"
  nunca aparecia no form do controlador
- **Causa:** todos QueryDtos do backend tem `max(100)`, frontend pedia 200
- **Fix:** `usePlants({ limit: 100 })`
- **Commit:** sih-frontend `6876546`

### Bug 4: `canCreate` incluía controlador

- **Sintoma:** botão "Novo Relatório" visível pra ctrl-IN/IND/gestor em
  Abate/Produção/Embarque
- **Causa:** `canCreate = user?.role !== 'coordenador'` (excluía só coordenador)
- **Fix:** allowlist explícita matchando `@Roles('admin','supervisor','operador')`
- **Commit:** sih-frontend `06f5c6d`

### Bug bonus: typo no script SQL de reset

- **Sintoma:** primeira tentativa de reset abortava com "UPDATE do admin afetou 0 linhas"
- **Causa:** GET DIAGNOSTICS em PL/pgSQL fora do mesmo DO $$ block do UPDATE
- **Fix:** mover UPDATE pra dentro do mesmo DO $$ block
- **Arquivo:** `SQL-RESET-BASE-PROD.md` (corrigido)
- **Memória:** `feedback_plpgsql_get_diagnostics.md`

---

## Pendências mapeadas (não-bloqueantes)

| # | Bug | Severidade | Onde fixar |
|---|---|---|---|
| 1 | PWA cache stale agressivo — dashboard só atualiza com Ctrl+Shift+R | 🟠 Alta UX | sih-frontend: vite-plugin-pwa workbox config + TanStack Query invalidateQueries |
| 2 | AUTO_MIGRATE ECS não rodou (2ª vez) | 🟠 Alta CI/CD | Investigar Task Definition prod + buildspec |
| 3 | Filtro "Todos os tipos" na Controladoria não retorna nada | 🟡 Média UX | sih-frontend ControladoriaDashboard ou backend query |
| 4 | Sem route guard em `/slaughter-reports/new` etc (controlador abre form vazio) | 🟡 Média UX | sih-frontend roteamento |
| 5 | Cold start ECS Fargate (~1s na primeira request) | 🟢 Baixa UX | ECS min-tasks > 0 ou skeleton loaders |
| 6 | PWA icon-192x192.png ausente no S3 | 🟢 Baixa | Publicar asset ou ajustar manifest |

---

## Estado atual do banco prod

- **Schema:** com migration `20260511160000_rename_companygroup_to_division` aplicada
- **Usuários:** 6 (1 admin + 5 teste, todos com senha `Teste@2026` exceto admin)
- **Plantas:** 3 (todas com `division` preenchido)
- **Relatórios em prod:**
  - `AB-SIF0001/2026/00001` — Abate Bovino, Planta IN Teste, status **aprovado**
  - `AB-SIF0001/2026/00002` — Abate Bovino, Planta IN Teste, status **aprovado** (após reabertura)
  - 1 relatório de Produção, Planta IND Teste, by sup-IND-teste, status **assinado** (não foi aprovado ainda — pode usar pra testar fluxo Aprovação na próxima sessão)
- **Inventário, NCs, anexos, notificações:** todos zerados

---

## Smoke test restante (próxima sessão)

| Bloco | Sprint | Tasks | Conteúdo |
|---|---|---|---|
| 2.4 | 2 | TASK-01 | Gestor reatribui (opcional) |
| 2.5-2.6 | 2 | — | Aging visual + KPIs detalhados |
| 3 | 3 | TASK-05, TASK-08 | Origem/destino em transferências + degolador condicional bovino vs ave |
| 4 | 4 | TASK-06, TASK-09 | Notificações in-app + SES email + anexos em embarque |
| 5 | 5 | TASK-07, TASK-11 | Desossa bovinos + plantas externas + integração SysHalal cert lookup |
| 6 | — | — | Pendências infra (PWA icon, AUTO_MIGRATE) |

Estimativa próxima sessão: ~90-120 min se nada quebrar.

---

## Commits gerados (no remote ecohalal/release)

| Repo | Commit | Descrição |
|---|---|---|
| sih-backend | `1ef4426` | refactor: companyGroup → division em Plant e SystemUser |
| sih-backend | `5135f42` | merge: refactor companyGroup → division (release) |
| sih-frontend | `48e4f0c` | refactor: companyGroup → division alinhado com backend |
| sih-frontend | `b348752` | merge: refactor companyGroup → division (release) |
| sih-frontend | `6876546` | fix: UserForm usa limit=100 em usePlants |
| sih-frontend | `06f5c6d` | fix: oculta botão Novo Relatório do controlador |
| sih-docs | (não commitado ainda) | SQL-RESET corrigido + playbook EXECUCAO + este doc + briefing |

---

## Lições aprendidas (registradas em memória)

- `project_sih_admin_prod.md` — admin atual em prod (admin@sih.com)
- `project_conceito_grupo_categoria.md` — modelo conceitual Grupo Empresarial × Empresa × Categoria
- `feedback_plpgsql_get_diagnostics.md` — GET DIAGNOSTICS só vê comandos no mesmo bloco DO $$
- `project_sih_cache_stale_bug.md` — PWA cache stale agressivo
