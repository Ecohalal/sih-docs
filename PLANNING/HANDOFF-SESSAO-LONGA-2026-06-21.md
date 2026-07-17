# Handoff de sessão longa — 2026-06-21

> **Status:** sessão Claude Code aberta desde 2026-05-10, encerrada em 2026-06-21
> próxima da compactação automática. Documento consolidado por pedido do PO.

## 0. Linha do tempo da sessão

| Período | Atividade |
|---|---|
| **2026-05-10** (manhã→noite) | 17 PRs schema-only (PR-E a PR-V) fechando 100% do schema da Onda 1+ FAMBRAS |
| **2026-05-11** | 4 PRs adicionais (PR-W, PR-X, PR-Y, PR-Z, PR-AA): service layer Lotes A/B/C + seeds operacionais + SLA reverso pré-auditoria + ativação SchedulerModule |
| **2026-05-11 → 2026-06-21** | **GAP de 6 semanas**: muito trabalho rodou em sessões paralelas (memória registra entregas SIH+GC entre 14/jun e 21/jun). Esta sessão não tem visibilidade desse intervalo |
| **2026-06-21** | Pickup pelo PO + auditoria cross-repo + reconciliação com memória → este handoff |

> Migration timestamps usados nas PRs (`20260510xxxxxx`, `20260511xxxxxx`) seguem
> a data lógica das sessões de trabalho, não 2026-06-21. Confirmado em prod via
> `_prisma_migrations`.

## 1. Entregue por esta sessão (em prod)

### 1.1 Schema Onda 1+ (17 PRs em 2026-05-10) — `halalsphere-backend`

Aditivos puros, todos com `prisma migrate deploy` no boot do container.

| PR | Item plano | Entrega |
|---|---|---|
| PR-E | seed countries fix-up | 58 países em `country_config` via migration idempotente |
| PR-G | Item 6 | `ScopeBrand.ownership` enum + `clientCompanyId` FK |
| PR-H | A.1 | `HasReview` 2-estágios (analista + auditor in loco) |
| PR-I | Item 15 | `Audit.stage` + `parentAuditId` self-relation |
| PR-J | Item 16 | `Audit.requiresMuslimSpecialist` + comentário PR 7.1 10.7.4 |
| PR-K | Item 22 | `ProductRecall` + 3 enums + restrições por país |
| PR-L | Item 17 | `AuditorSupervisorAgreement` + modalidades + reajuste CCT |
| PR-M | Item 19 | `ComplianceDeclaration` (LGPD/anticorrupção/OIT/ambiental) |
| PR-N | Item 4 | `CertificationScope` campos APPCC + consultancy (en) |
| PR-O | Item 5 | `Subcontractor` + `ProductSubcontracting` |
| PR-P | Item 21 | `EmailRouting` + 6 contextos |
| PR-Q | Item 7 | `RequiredDocumentTemplate` + materialização |
| PR-R | Item 12 | `QuestionnaireTemplate` + `QuestionnaireResponse` |
| PR-S | Item 3 | `RequestReviewReport` (FM 7.1.9) |
| PR-T | Itens 8+9 | `ScopeAmendment` + `Delta` + `ContractAmendment` |
| PR-U | Item 14 | `CertificateType` enum (4 tipos) |
| PR-V | Item 13 | `QualityDocument` + `Version` + `ClientDocumentDelivery` |

### 1.2 Service layer (4 PRs em 2026-05-11)

| PR | Lote | Entrega |
|---|---|---|
| PR-W | A | DTOs (Audit/Certificate/CertificationScope/ScopeBrand) + módulo `email-routing/` + módulo `product-recall/` (com hook automático email qualidade@ em ≤48h) + validação SMIIC em `AuditPlanService.signPlan` |
| PR-X | B | Módulos `has-review/`, `subcontractor/`, `request-review-report/`, `compliance-declaration/`, `scope-amendment/` (com hook crítico `Certificate.reissue()` para 5 dos 6 tipos de amendment) |
| PR-Y | C | Módulos `quality-document/` (catálogo+versionamento+delivery), `required-document-template/` (com materialização em `DocumentRequest`), `questionnaire/` (templates JSON-driven + responses com workflow) |
| PR-AA | D | SLA reverso D-30/D-15/D-7 pré-auditoria em `CertificationSchedulerService` + **ativação do `SchedulerModule`** (estava inerte em prod — bug de configuração) |

### 1.3 Seeds operacionais (1 PR em 2026-05-11)

| PR | Entrega |
|---|---|
| PR-Z | 7 laboratórios aprovados, ~16 MP críticas (C+K), 16 restrições por país (carmim/E120 em TR/ZA/Golfo), 16 entradas catálogo IT 7.12, 6 EmailRouting com BCC automático para jurídico |

**Decisão de modelagem:** item 18 (Proposal.feeOverride → template sugerido) já está
coberto pelo schema existente (`Proposal.totalValue` = calculado, `manualAdjustment` +
`adjustmentReason` = override manual, `finalValue` = efetivo). Sem mudança necessária.

### 1.4 Memórias salvas nesta sessão

- `feedback_halalsphere_seed_dev_only.md` — `seed.ts` é dev-only; ref-data via migration
- `project_targetmarkets_gap_pre_u1.md` — wizard captura países mas submit não persiste; aguarda U1
- `project_onda1plus_schema_completo.md` — registro do dia "17 PRs em 1 sessão"

## 2. O que aconteceu DEPOIS (lacuna 2026-05-11 → 2026-06-21)

Auditoria cross-repo via agente Explore em 2026-06-21 detectou entregas que
não passaram por esta sessão. Detalhes nas memórias de cada item:

### 2.1 GC / HalalSphere
- **Reset GC prod EXECUTADO 28/mai** — 33 users / 564 companies / 577 plants / 1042 certs zerados → base limpa pra go-live
- **Ingestão pré-cadastro EXECUTADA 28/mai** — 150 grupos / 299 empresas / 268 plantas a partir do SysHalal
- **Ingestão suppliers FM EXECUTADA 21/jun** — +498 Companies/Plants NAO_APLICAVEL
- **Emissão Manual Certificado (FM 7.7.2 Rev 05)** — bridge GC pré-go-live com 4 gabaritos + QR Code novo
- **Hands-on emissão manual** com Lina/Fuad/Nilsa em 13-20/mai + bugs PDF corrigidos
- **Roadmap público auto-update obrigatório** — regra registrada em `feedback_roadmap_publico_auto_update.md`
- **Domínio QR verify RESOLVIDO 18/jun** — Caminho B (regra ALB)
- Último commit `release` no momento da auditoria: `5cd5a96d` (docs roadmap)

### 2.2 SIH
- **Reset SIH prod EXECUTADO 28/mai** (substitui o `admin@sih.com` antigo)
- **Fases 0-4 do plano faseado ENTREGUES 14/jun** — código sanitário, doc sanitário CSI/CSN/DCPOA, produção estruturada, vínculo embarque⇄produção, tabela produtos por tipo
- **Demo SIH In Natura FAMBRAS 15/jun ENTREGUE** — FM 7.1.6.1 (NC), FM 20.1 (Ocorrência Aves), roteamento notificação por grupo
- **Fase 5A catálogo de produtos** — 5A-1+5A-3+5A-4 entregues (frontend admin `/halal-products` em commit `369dced`)
- **Histórico de acessos SIH** (espelha GC) deployado 16/jun
- Enums planta + import IND, ajuste relatório transferência (cnpj.ws), vínculo supervisor↔plantas
- **SIH cache stale RESOLVIDO 12/jun** (commit `3d75972` Cache-Control + PWA removido)

### 2.3 Cross-system / FAMBRAS
- Docs do ecossistema entregues 18/jun (pedido Cintia/Flav em `halalsphere-docs/ECOSSISTEMA/`)
- Reunião FAMBRAS 13/mai/2026 — ata + action items
- Planilha MP FAM-0017 / FM 7.4.2.7 analisada 25/mai
- QA Nilsa 19/mai + 21/mai com resultados consolidados

## 3. TODO REAL — pendências ativas em 2026-06-21

### 3.1 Blocker — aguardando input externo

| # | Item | Aguardando |
|---|---|---|
| 1 | Ingestão das 3122 certs FAMBRAS (PARKED 21/jun) | CSVs atualizados FAMBRAS + resolver 3 SIFs duplicados (585/4699/2620) |
| 2 | 5A-2 ETL em massa catálogo produtos | `.xlsx` FAMBRAS |
| 3 | 8 perguntas PO sobre FAM-0017 / FM 7.4.2.7 | Lina |
| 4 | 7 decisões PO import colaboradores industrial (SIF 451 dup, SIF ausente, GTS, campanha, emails) | PO |
| 5 | Fase 2 SIH: exceção JBS NF, versionamento embarque, travas doc prévio, "outros" cód. sanitários, modelos cert IA desossa | PO |
| 6 | Embarque exportação vínculo aos relatórios da base (FM 7.1.7.1 multi-origem) | Análises pré-implementação |

### 3.2 High — implementável agora

| # | Item | Repo | Esforço |
|---|---|---|---|
| 7 | **Frontend Onda 1+ integração** — wizard não consome MarketScope, ScopeAmendment, ProductRecall, EmailRouting, HasReview etc. dos schemas/services entregues | halalsphere-frontend | grande |
| 8 | **U1: refactor wizard 11→5 passos** (destrava U11 toggle + bulkUpsertMarketScopes — gap pré-existente em `project_targetmarkets_gap_pre_u1`) | halalsphere-frontend | grande |
| 9 | Autocomplete de produto nos forms de embarque/produção SIH | sih-frontend | médio |
| 10 | Cert multi-categoria flex: schema M:N já existe; falta wire DTO + service + renderer + verify | halalsphere-backend | médio |
| 11 | 6 gaps cert IT 7.10 + IT 4.2 (numeração SEQQ global por depto, EN+AR mandatório, datas, GAC ou nada, etc.) | halalsphere-backend | médio |
| 12 | Item 23 Onda 1+ — backfill `MarketDestination` com regras GulfRestrictions | halalsphere-backend | pequeno-médio |

### 3.3 Medium — qualidade / dívida

| # | Item | Repo |
|---|---|---|
| 13 | `Company.validationStatus` divergente — campo no front sem par no Prisma; bloqueia feature nova em `/admin/validacao-empresas` | halalsphere |
| 14 | TargetMarketsStep não persistia — gap aguarda U1 (item 8 acima) | halalsphere-frontend |
| 15 | Bug planta em edição SIH (M3.3/M4.12 ainda falham apesar do fix `3da18a3`) | sih-frontend |
| 16 | Enforcement supervisor↔planta no create | sih-backend |
| 17 | Refino `dt-code-map`: K → drugs/cosmetics via context |

### 3.4 Low — cosmético

| # | Item |
|---|---|
| 18 | FM 4.1.X — normas por (DT × mercado): REV 03 entregue, falta `CertificationStandardByMarket` tabela mestre |

## 4. Atenção pós-deploy (riscos ativos das PRs desta sessão)

1. **SchedulerModule ativado (PR-AA)** — primeiro run pós-deploy pode disparar backlog de notificações para certs expirando, NCs em atraso, etc. Monitorar logs ECS 1h após deploy.
2. **Reissue automático de Certificate em 5 dos 6 tipos de ScopeAmendment.approve** — comportamento intencional; se algum amendment for marcado approved e o cert ativo não puder ser re-emitido (sem PDF service rodando?), log de erro aparece mas amendment fica approved sem cert novo.
3. **Email automático ProductRecall** — depende de `EmailRouting` context=`qualidade` estar configurado e `EmailService` SES estar com FROM autorizado. Se falhar, gravamos warning mas o recall é criado mesmo assim (intencional).

## 5. Prompt de retomada (cold start)

Cole isso no início da próxima sessão se quiser pickup limpo:

> Voltando depois de pausa. Última sessão Claude Code (encerrada 21/jun) foi
> a "maratona Onda 1+ FAMBRAS" — 22 PRs no `halalsphere-backend` em 2 dias
> (10-11/mai), todos em prod via `release`. Backend GC está 100% pronto pra
> Onda 1+; **frontend não consome nada disso ainda**. Memória atual em
> `c--Projetos-Ecohalal-sih-docs/memory/MEMORY.md` e detalhes em
> `sih-docs/PLANNING/HANDOFF-SESSAO-LONGA-2026-06-21.md`. Pendência #1 hoje
> seria U1 (refactor wizard 11→5 passos) + integração schemas Onda 1+ no
> frontend — ver itens 7+8 do TODO real. Mas antes, **confirma com PO se há
> prioridade comercial diferente vinda da FAMBRAS** nas reuniões recentes
> (Lina/Fuad/Nilsa em 13-20/mai + ata 13/mai/2026).

## 6. Referências

- `sih-docs/PLANNING/FAMBRAS-VISITA-1504-ONDA-1+.md` — plano canônico da Onda 1+
- `sih-docs/PLANNING/DECISOES-LINA-2026-05-09.md` — respostas residuais Lina
- `sih-docs/PLANNING/HANDOFF-FASES-0-4-2026-06-14.md` — handoff SIH Fases 0-4
- `sih-docs/PLANNING/HANDOFF-SESSAO-2026-06-17.md` — handoff sessão 17/jun
- `sih-docs/PLANNING/INGESTAO-CERTIFICATIONS-FM-PENDENTE-2026-06-21.md` — retomada cold ingestão certs FM
- `c--Projetos-Ecohalal-sih-docs/memory/MEMORY.md` — índice de memória persistente
