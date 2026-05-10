# Plano consolidado — visita técnica FAMBRAS 2026-04-15

**Status:** **destravado** — 6 de 6 perguntas residuais respondidas em 2026-05-09 (ver [DECISOES-LINA-2026-05-09.md](DECISOES-LINA-2026-05-09.md))
**Origem:** 4 rodadas de análise sobre material da Lina Ramadan (FAMBRAS Halal) + agentes especialistas (Negócio, Infra, UI/UX) + e-mail de respostas (2026-05-09) + link OneDrive da pasta IFF-FAR (Fuad Arisheh)

> ⚠️ **Dependência crítica (decisão 2026-05-07):** este plano **aguarda a Fase 4 do Refactor de Empresa+Planta** concluída antes de iniciar os 20 itens pendentes. O refactor (12-17 dias úteis em 5 fases) toca modelos centrais (`Company`, `Plant`, `Certification.companyId → plantId`); executar Onda 1+ antes obriga retrabalho. D8 original mantida — reset da base autorizado pelo PO. Doc de refactor: [`halalsphere-docs/PLANNING/CADASTRO-EMPRESA-PLANTA-NOVO-MODELO.md`](../../../halalsphere-docs/PLANNING/CADASTRO-EMPRESA-PLANTA-NOVO-MODELO.md). Itens 4, 5 e 6 (CertificationScope APPCC + Subcontractor + ScopeBrand.ownership) já foram implementados antes do refactor e serão preservados no schema fresh.

> Este documento consolida tudo que foi decidido nas 4 rodadas de análise. Itens marcados com `🟡 pending_lina` dependem de confirmação da FAMBRAS antes da implementação. Itens marcados com `✅ confirmed` podem entrar em desenvolvimento imediato.

---

## 1. Sumário executivo

A visita técnica de 15/04/2026 à FAMBRAS expôs **8 áreas operacionais** e **8 issues funcionais** no HalalSphere. As rodadas subsequentes adicionaram regras de alteração de escopo, formulários de captura de escopo por categoria, procedimento mestre PR 7.1 (65 páginas) e exemplos reais de proposta/contrato/diretrizes.

**Diagnóstico final:** o HalalSphere atual cobre ~60% do que a FAMBRAS precisa para operar com ISO 17065, GSO 2055-2 e SMIIC 02. Os 40% restantes envolvem:
1. **Modelagem de mercado** — multi-select de destinos com acreditadores específicos por país.
2. **Reforma da solicitação** — wizard ramificado por categoria + FM 7.1.9 (revisão + cálculo de tempo de auditoria).
3. **Alterações de escopo** — entidade de primeira classe com 6 tipos discriminantes, integrada a contrato e comitê.
4. **Documentação obrigatória** — biblioteca versionada (IT 7.12) + templates parametrizados (FM 7.4.2.x).
5. **Telas operacionais** — Programa de Certificação (controladoria), Inbox do analista, FM 9.3 unificado, Hub de alteração de escopo.

**Escopo:** a Onda 1+ tem ~25 entregáveis; entrega parcial em 30-45 dias destrava a próxima auditoria FAMBRAS sem regressão.

---

## 2. Contexto

### 2.1 Material analisado

| # | Origem | Documentos-chave |
|---|---|---|
| 1 | Pasta visita 15/04 | Corpo e-mail Lina, IT 7.12, DT 7.3 (HAS), exemplo HAS IFF, FM 7.4.2.1, FM 7.2.1.3, mais 30+ anexos |
| 2 | Pasta "Regras alteração de escopo" | Corpo e-mail Lina, FM 7.4.2.15 (Questionário Armazém), Termo Compromisso Halal, planilha MP laticínio |
| 3 | Pasta "Escopos e solicitação documental" | FM 7.2.1.2 a 7.2.1.11 (escopos por categoria), FM 7.4.2.1, FM 7.4.2.2 |
| 4 | Anexos diretos | FM 7.2.1.1 (formulário solicitação), PR 7.1 (procedimento mestre 65 pg) |
| 5 | Pasta Ayat (cliente real) | FM 7.2.3 (proposta ATA), FM 4.1.1.1 (anexo II diretrizes), FM 4.1.1 (contrato ATA) |

### 2.2 Stack envolvida

- **Backend:** halalsphere-backend — NestJS 11 + Prisma 7 + Postgres + Redis + AWS (S3, SES, SNS, Secrets Manager)
- **Frontend:** halalsphere-frontend — Vite 7 + React 19 + Radix + Tailwind v4 + TanStack Query + react-hook-form + Recharts
- **AI:** `@anthropic-ai/sdk` (já em uso para `AiAnalysis + KnowledgeBase + ChatMessage`)
- **Coexistência:** integração com SysHalal (sistema legado para certificados de embarque, não absorção — ver memória `project_halalsphere_syshalal_coexistencia`)

---

## 3. Decisões consolidadas (não rediscutir)

### 3.1 Confirmações com alta confiança (a confirmar formalmente com Lina)

| Decisão | Fonte |
|---|---|
| HAS é elaborado pelo cliente; FAMBRAS revisa | FM 7.4.2.1 + DT 7.3 (item 6) |
| Mercado é multi-select de 9-10 destinos | FM 7.2.1.1 seção "Abrangência" |
| Lista fechada de 7 labs aprovados (EUROFINS, FOODCHAIN, CQA, INTECSO, SENAI, UNIANÁLISES, FREITAG) | FM 7.4.2.1 + PR 7.1 item 10.8 |
| Cálculo de tempo de auditoria via FM 7.1.9 (paramétrico, IAF MD 5:2015, redução até 30%) | PR 7.1 item 10.7.2 |
| Comitê: 3 membros mínimo (2 sheikhs + 1 técnico), unanimidade | PR 7.1 item 5.17 + 10.9.1 |
| Especialista islâmico participa OBRIGATORIAMENTE de toda auditoria | PR 7.1 item 10.7.4 |
| Não repetir auditor por mais de 3 anos consecutivos | PR 7.1 item 10.7.4 |
| Ciclo de 3 anos (estágio 1+2 → manutenção 1 → manutenção 2 → recertificação) | PR 7.1 item 10.4 |
| 6 tipos de alteração de escopo com fluxos discriminantes | E-mail Lina "Regras alteração de escopo" |
| Aditivo contratual com taxa anual em 3 dos 6 tipos (marca cliente, razão social, CNPJ) | E-mail Lina + contrato ATA |
| Selo obrigatório em exportação + B2B; facultativo em varejo interno | Anexo II item 25 |

### 3.2 Decisões internas (não perguntar à Lina)

- **SysHalal × HalalSphere coexistem em paralelo, integrados.** Propósitos diferentes; não migrar funcionalidades de embarque para HalalSphere. Despachantes ficam no SysHalal.
- **Política de preços fica fora do sistema (sem fórmulas).** `PricingTable` parametrizável por contrato com valores manuais. O cálculo automático que existe hoje no `Proposal` (multiplicadores) deve virar template sugerido sobrescrevível.
- **FM 9.3 não será splitado em modelo.** Consenso Negócio+UX: manter `PreparatoryForm` único, separar visualmente em **seções colapsáveis com avatar+timestamp** do autor (analista pré × auditor em campo).
- **Estágio 1 e 2 como `enum stage` em `Audit`** + `parentAuditId` (não criar `AuditStage` filho).
- **Wizard parametrizado JSON-driven** compartilhado entre Solicitação Inicial, Alteração de Escopo e Homologação (engine reutilizável, 1 código N jornadas).
- **Trigger de re-emissão de Certificate via Nest EventEmitter**, não trigger SQL (5 dos 6 tipos de amendment re-emitem).
- **Categoria UAE.S GSO (A-K) e OIC/SMIIC (A-L) como enums** + tabela `CategoryAccreditationMatrix` (categoria × acreditador).
- **HAS guiado vira Revisor de HAS** na Onda 3 (não gerador IA — risco regulatório).

### 3.3 Respostas residuais da Lina (recebidas 2026-05-09)

Detalhe completo em [DECISOES-LINA-2026-05-09.md](DECISOES-LINA-2026-05-09.md). Resumo:

| ID | Pergunta | Status | Decisão |
|---|---|---|---|
| **A.1** | HAS elaborado pelo cliente | ✅ confirmado **+ bonus** | HAS tem **2 estágios** de revisão (analista superficial + auditor in loco). `HasReview` ganha `analystReviewedAt/By`, `analystChecklistOk`, `auditorReviewedAt/By`, `auditorFieldNotes` |
| **A.2** | Mercado multi-select | ✅ confirmado **+ tendência** | Manter `MarketScope` 1:N granular; adicionar `marketCategory: internal\|export` em `Country` (vista futura agregada) |
| **A.3** | Lista de labs fixa? | ✅ confirmado | Mantida pela role **Qualidade** (sem comitê). Cliente READ-only no envio FM 7.4.2.1. Modelo `Laboratory.allowedAnalysisTypes[]` |
| **B.1** | Amostra de cliente | ✅ entregue (Fuad) | Pasta SharePoint **IFF-FAR** (cliente IFF, alteração FAR). User precisa baixar manualmente — link privado |
| **B.2** | IA matérias-primas | ✅ confirmado **+ escopo menor** | 3 outputs: `criticality`, `mayBeAnimalDerived`, `animalSpecies`. Sem fontes externas — Claude/OpenAI direto com prompt nosso. Cai pra Onda 2 viável |
| **B.3** | Item crítico × país | ✅ confirmado | Chave **por produto**. Tabela auxiliar `CriticalRawMaterialCountryRestriction` para exceções (ex: carmim de cochonilha em TR/ZA/Golfo) |

**Onda 1+ pode avançar.** Onda 2 (RawMaterialMaster, Laboratory, CriticalRawMaterial) destravada. ETL de migração depende de baixar manualmente a pasta IFF-FAR.

---

## 4. Onda 1+ — próximos 30-45 dias

**Objetivo:** destravar a próxima auditoria FAMBRAS sem regressão funcional. ~25 entregáveis entre schema, UI e operacional.

### 4.1 Schema / Backend

| # | Entregável | Dependências | Status |
|---|---|---|---|
| 1 | `MarketScope` 1:N com `Certification` (multi-select de destinos) + `Country` enum estendido | — | ✅ **DELIVERED 2026-05-09** PR-A `CountryConfig` + PR-B `MarketScope` (release `cefb2d2d`) |
| 2 | `CategoryAccreditationMatrix` — categoria × acreditador (UAE.S GSO A-K + OIC/SMIIC A-L) | — | ⏭️ **PULADO** — `IndustrialGroup`/`IndustrialCategory` já cobrem (`gsoCode`, `smiicCode`, `applicableGso`, `applicableSmiic`); reusar em vez de criar tabela paralela |
| 3 | `RequestReviewReport` (FM 7.1.9) com cálculo paramétrico GSO+SMIIC+IAF MD 5; novo estado `REQUEST_REVIEW` no Workflow | (1), (2) | ✅ confirmed |
| 4 | Reforma `CertificationRequest` + `CertificationScope`: `hasAPPCC`, `appccPlanRef`, `numAPPCCStudies`, `numShifts`, `numEmployees`, `consultancyReceived` (FM 7.2.1.1) | — | ✅ confirmed |
| 5 | `Subcontractor` + `ProductSubcontracting` (atividades subcontratadas FM 7.2.1.1) | (4) | ✅ confirmed |
| 6 | `ScopeBrand.ownership` enum (`OWN`, `CLIENT_PRIVATE_LABEL`, `LICENSED`) + `clientCompanyId` | — | ✅ confirmed |
| 7 | `RequiredDocumentTemplate { categoryCode, standardId, cycleType, department, isMandatory, triggerPhase, version, supersedesId }` + materialização via hook | (2) | ✅ confirmed |
| 8 | `ScopeAmendment` (6 tipos: HOMOLOG_MP, NEW_PRODUCT_NEW_LINE, NEW_PRODUCT_EXISTING_LINE, ADD_CLIENT_BRAND, CHANGE_LEGAL_NAME, CHANGE_CNPJ) + `requiresNewLine: Boolean` + `ScopeAmendmentDelta` polimórfico | — | ✅ confirmed |
| 9 | `ContractAmendment { contractId, scopeAmendmentId, type, annualFeeDelta, newAnnualFee, signatureDocumentId, pricingSnapshotJson }` — valor manual, sem fórmula | (8) | ✅ confirmed |
| 10 | Hook `ScopeAmendment.onApprove() → CertificateService.reissue()` para 5 dos 6 tipos | (8) | ✅ confirmed |
| 11 | `HomologationProfile { categoryCode, requiredDocumentTypes[], questionnaireTemplateIds[], skipRulesJson }` + `CriticalRawMaterial { categoryCode, materialName, certificationRequired }` | — | ✅ **DELIVERED 2026-05-09** PR-C `HomologationProfile` (release `f282d69b`) + PR-D `CriticalRawMaterial` + restrições por país (release `474dde16`) |
| 12 | `QuestionnaireTemplate { code, version, applicableContexts[], schemaJson }` + `QuestionnaireResponse` (renderizado com react-hook-form + zod) | — | ✅ confirmed |
| 13 | `QualityDocument` versionado + `QualityDocumentVersion` + `ClientDocumentDelivery { sentAt, sentVia, emailId, acknowledgedAt }` (IT 7.12) | — | ✅ confirmed |
| 14 | 4 modelos de `Certificate`: `UNIQUE`, `HABILITATION`, `BATCH_EXPORT`, `BATCH_INTERNAL` + preço por contrato (sem fórmula global) | — | ✅ confirmed |
| 15 | `Audit.stage` enum (`STAGE_1`, `STAGE_2`, `MAINTENANCE`, `RECERTIFICATION`, `UNANNOUNCED`, `SPECIAL`, `EXTRAORDINARY`) + `parentAuditId` | — | ✅ confirmed |
| 16 | Validação `Audit.requiresMuslimSpecialist = true` sempre + equipe SMIIC = 3 (2 técnicos + 1 islâmico) | (15) | ✅ confirmed |
| 17 | `AuditorSupervisorAgreement` (modalidades: `FIXED`, `CAMPAIGN`, `NONE`) + `cctAdjustmentMonth` para reajuste anual | — | ✅ confirmed |
| 18 | Revisar `Proposal.feeOverride` aceito sem fórmula + transformar cálculo automático em **template sugerido** | — | ✅ confirmed |
| 19 | `ComplianceDeclaration` por contrato (LGPD + Anticorrupção + OIT + ambiental) | — | ✅ confirmed |
| 20 | SLA reverso de 30 dias para envio de docs antes da auditoria + alertas em D-30, D-15, D-7 | — | ✅ confirmed |
| 21 | `EmailRouting` por contexto (cobranca, qualidade, jurídico, frigorífico, industrializado, renovação) com cópia oculta automática para jurídico | — | ✅ confirmed |
| 22 | `ProductRecall` + email automático para `qualidade@fambrashalal.com.br` em ≤48h | — | ✅ confirmed |
| 23 | Backfill `MarketDestination` aditivo: `GulfRestrictionConfig` ativa → mapeamento para destinos do Golfo; sem config → `INTERNAL`; ambíguos → `UNDETERMINED` | (1) | ✅ confirmed |

**Migrações:** todos os itens acima são **aditivos** (sem breaking change). `MarketScope` é new table; `Audit.stage` é nullable inicialmente com default `STAGE_2`; `RequestReviewReport` é new table que entra entre Request e Proposal sem invalidar registros existentes.

### 4.2 UI / Frontend

| # | Entregável | Telas afetadas | Status |
|---|---|---|---|
| U1 | Wizard 5 passos solicitação (ramificado por categoria desde o passo 1) com APPCC, subcontratada, marca própria, escopo produtos | `/certification/new` | ✅ confirmed |
| U2 | Tela split-view do analista (esquerda solicitação cliente, direita formulário FM 7.1.9) | nova `/analysis/request-review/:id` | ✅ confirmed |
| U3 | Hub de alteração de escopo (5 cards em linguagem do cliente) + wizard parametrizado JSON | nova `/empresa/escopo/alterar` | ✅ confirmed |
| U4 | Engine de wizard JSON-driven (componente compartilhado entre Solicitação, Alteração de Escopo e Homologação) | componente compartilhado | ✅ confirmed |
| U5 | FM 9.3 unificado com seções colapsáveis carimbadas (avatar + timestamp do autor) | `/audits/execution` reformada | ✅ confirmed |
| U6 | Hub permanente de docs IT 7.12 do cliente + nudges contextuais (não inundação inicial) | nova `/empresa/biblioteca` | ✅ confirmed |
| U7 | Editor inline planilha MP/fornecedores (Airtable-like) + import Excel com reconciliação visual | reforma `/company/suppliers-homolog` | ✅ confirmed |
| U8 | Inbox do analista (fila de FM 7.1.9 pendentes + HAS para revisar + MPs para classificar) | reforma `/dashboard` analista | ✅ confirmed |
| U9 | Tela de aditivo contratual com PDF preview embutido (pdfjs-dist) e `<ContractPreview contractId>` reaproveitado | reforma `/juridico/contracts/:id` | ✅ confirmed |
| U10 | Template real de proposta/contrato em PDF via `pdfkit` (já no stack) | módulo PDF service | ✅ confirmed |
| U11 | Mercado interno × exportação como dual-toggle no passo 1 do wizard + chip colorido na listagem | `/certifications`, `/certification/new` | ✅ confirmed |

**Princípios mantidos:** mobile-first, dark mode, OKLCH tokens, sem inline styles, shadcn/ui (Radix), pt-BR.

### 4.3 Operacional

- Inserir os 17+ documentos da IT 7.12 (DTs, PRs, ITs) na `KnowledgeBase` versionada como seed inicial.
- Cadastrar os 7 laboratórios aprovados em seed com `approvedAnalysisTypes`.
- Cadastrar `HomologationProfile` para laticínio, armazém e unidade adicional como seed inicial (categorias confirmadas em campo).

---

## 5. Onda 2 — próximos 60 dias

**Objetivo:** estabilização operacional após primeiro ciclo de uso real pela FAMBRAS.

### 5.1 Schema / Backend

- Cálculo dinâmico FM 7.1.9 com algoritmo completo de horas (anexo B do GSO 2055-2 + anexo B do SMIIC 02) — atualmente paramétrico básico.
- **`RawMaterialMaster` + agente IA** (B.2 destravado): output `criticality / mayBeAnimalDerived / animalSpecies` via Claude/OpenAI direto (sem indexação de fontes externas). Cache por `(materialName, categoryCode)`. UI de revisão pelo analista.
- View materializada `mv_certification_program_kpi` refrescada via `pg_cron` 15min (complexidade ponderada por analista).
- Modelos para Treinamentos, Ocorrências, Comunicados estruturados.
- `UnannouncedAudit` workflow (notificação 90d antes + janela 15d + 5d blackout do cliente).
- `AuditorImpartialityCheck` — alerta após 3 anos consecutivos com mesmo auditor.
- `ExternalRegistrationTask` (HAKSIS, SiHalal, MOIAT, halal.gov.sa) com status PENDING/SUBMITTED/CONFIRMED/EXPIRED — placeholder, sem integração API ainda.
- **`Laboratory`** (A.3 destravado): `name, isFambrasApproved, allowedAnalysisTypes[]`. Mantida por role `qualidade` (sem comitê). Cliente READ-only no envio de FM 7.4.2.1. Seed: 7 labs (EUROFINS, FOODCHAIN, CQA, INTECSO, SENAI, UNIANÁLISES, FREITAG).
- **`CriticalRawMaterial`** (B.3 destravado): chave `(categoryCode, materialName)` + tabela auxiliar `CriticalRawMaterialCountryRestriction` para exceções (carmim de cochonilha em TR/ZA/Golfo).
- **ETL de migração** (B.1 destravado): consumir pasta SharePoint IFF-FAR (caso real, cliente IFF, alteração FAR). Usuário baixa manualmente; rodar análise local antes de definir scripts.

### 5.2 UI / Frontend

- **Programa de Certificação** (tela-mãe da gestão) com 3 modos via toggle:
  - Executivo (gestor): KPIs, charts Recharts (barras empilhadas por fase, donut por mercado interno × exportação, linha de receita projetada).
  - Operacional (controladoria): tabela densa com filtros (status, complexidade, responsável, mercado, vencimento). Default: ordenado por "pendência desc".
  - Por colaborador: agrupado por analista/auditor com contagem ponderada por complexidade.
- Mapa de calor mensal de balanceamento de auditores (gestor de auditoria).
- Timeline de certificação ativa para cliente (substitui dashboard genérico).
- Página dedicada de questionários (rota `/empresa/questionarios/:id`) com autosave a cada blur.
- Tela de certificados com selector de versão (v1 original, v2 aditivo CNPJ, etc.).

---

## 6. Onda 3 — pós-implantação

- **Revisor de HAS em 2 estágios** (A.1 destravado): UI de upload + checklist do analista (presença dos tópicos obrigatórios DT 7.3) + notes do auditor (verificação profunda in loco). Não é "gerador IA" (risco regulatório).
- Scraping/integração efetiva com acreditadores (GAC, JAKIM, BPJPH, MUIS) com filas Redis e backoff — opcional, só se a base de positive lists virar relevante.
- Calendário/balanceamento avançado de auditores.
- Reconhecimento automático de certificado Halal de MP via links dos acreditadores.
- Tradução formal de documentos (`TranslationRequest`).

---

## 7. Telas a criar — top 5 priorizadas

| Ordem | Tela | Usuário primário | Onda |
|---|---|---|---|
| 1 | **Programa de Certificação** (3 modos) | Controladoria / Gestor | 2 |
| 2 | **Editor de planilha MP** (inline + import) | Cliente | 1+ |
| 3 | **FM 9.3 unificado** (offline-first, mobile) | Auditor | 1+ |
| 4 | **Inbox do analista** (fila inteligente) | Analista | 1+ |
| 5 | **Hub de alteração de escopo** (5 cards) | Cliente | 1+ |

---

## 8. Riscos e armadilhas

### 8.1 Técnicos

1. **Backfill de `MarketDestination` com dados ambíguos** — usar enum `UNDETERMINED` transitório + dashboard para analista resolver antes do `NOT NULL`.
2. **Materialização de `DocumentRequest` a partir de templates versionados** pode explodir N — cap por request (~50) + alertas + dry-run em staging.
3. **Trigger duplo de re-emissão** (SQL antigo + hook novo) — desativar SQL no mesmo deploy.
4. **CertificationScope polimórfico por categoria** — recomendado: core + `categoryDetailsJson` validado por Zod no boundary (não N tabelas-junção).

### 8.2 De negócio

1. **Replicar literalmente os 30 relatórios da FAMBRAS atual** vira tela morta — cada relatório vira filtro/visão da tela operacional, não tela própria.
2. **Cliente confunde "excluir produto" com "cancelar certificação"** — confirmação dupla diferenciada com wording explícito.
3. **Aditivo + taxa anual surpreende cliente** — exibir aviso de custo já no card do hub: "Esta alteração gera aditivo contratual com custo".
4. **Triagem diferida tipo 2 vs 3 cria expectativa de SLA frustrada** — adicionar SLA interno de classificação (1 dia útil) e mostrar ao cliente.
5. **IA como muleta regulatória** — no HAS revisor, IA é só rascunho assistivo com revisão obrigatória + log de "editado pelo humano".

### 8.3 Operacionais

1. **Implantação dos dados FAMBRAS** sem amostra de cliente real é especulação de prazo — bloqueador da Onda 2.
2. **Aditivo contratual recorrente** sem cobrança automatizada — taxa anual pós-aditivo é fácil de esquecer; precisa job/notificação D-90, D-30, D-7.
3. **HAS compartilhável entre certificações da mesma cadeia** (cenário "unidade que envasa reaproveita HAS do fabricante") — não modelar HAS como propriedade só de Certification.

---

## 9. Anexos / referências

### 9.1 Documentos da FAMBRAS analisados

| Código | Nome | Origem |
|---|---|---|
| FM 7.2.1.1 | Formulário de Solicitação (REV 19) | Pasta Lina |
| FM 7.2.1.2-11 | Controle de Escopo (Aves, Bovino, Entreposto, Fazenda, Hotel, Catering, etc.) | Pasta "Escopos" |
| FM 7.4.2.1 | Solicitação Documentação Inicial Industrial (REV 34) | Pasta visita 15/04 + "Escopos" |
| FM 7.4.2.2 | Solicitação Documentação Inicial Frigorífico (REV 20) | Pasta "Escopos" |
| FM 7.4.2.7 | Planilha MP e Fornecedores (REV 9) | Pasta visita 15/04 |
| FM 7.4.2.15 | Questionário Halal Armazém (REV 1) | Pasta "Regras alteração" |
| FM 7.1.9 | Relatório Revisão Solicitação + Cálculo Tempo Auditoria (REV 13) | Pasta visita 15/04 |
| FM 7.2.3 | Proposta Comercial (REV 17) | Pasta Ayat (exemplo ATA) |
| FM 4.1.1 | Contrato Prestação Serviços (REV 29) | Pasta Ayat |
| FM 4.1.1.1 | Anexo II Diretrizes Qualidade (REV 28) | Pasta Ayat |
| PR 7.1 | Condições Concessão/Manutenção/Extensão/Redução/Suspensão/Cancelamento (REV 22) | Pasta Lina |
| IT 7.12 | Guia Documentos Enviados Clientes (REV 4) | Pasta visita 15/04 |
| DT 7.3 | Requisitos HAS (REV 10) + Anexo 1 (matriz PCCH) | Pasta visita 15/04 |

### 9.2 Memórias persistentes relacionadas

- [project_arquitetura_halal_ecosistema](../../../../Users/ecotrace/.claude/projects/c--Projetos-Ecohalal-sih-docs/memory/project_arquitetura_halal_ecosistema.md) — GC master, SIH operação, SysHalal exportação
- [project_halalsphere_syshalal_coexistencia](../../../../Users/ecotrace/.claude/projects/c--Projetos-Ecohalal-sih-docs/memory/project_halalsphere_syshalal_coexistencia.md) — sistemas em paralelo, propósitos distintos
- [feedback_pricing_no_formula](../../../../Users/ecotrace/.claude/projects/c--Projetos-Ecohalal-sih-docs/memory/feedback_pricing_no_formula.md) — preços manuais por contrato, sem fórmulas
- [project_geolocalizacao_assinatura](../../../../Users/ecotrace/.claude/projects/c--Projetos-Ecohalal-sih-docs/memory/project_geolocalizacao_assinatura.md) — pedido FAMBRAS adiado para pós-implantação
- [reference_syshalal_api](../../../../Users/ecotrace/.claude/projects/c--Projetos-Ecohalal-sih-docs/memory/reference_syshalal_api.md) — endpoints da API SysHalal

### 9.3 Histórico desta análise

- **Rodada 1** (2026-05-07): leitura inicial do corpo do e-mail Lina + IT 7.12 + DT 7.3 + HAS exemplo. Mapeamento do estado atual do HalalSphere (76 modelos Prisma + 50 módulos NestJS).
- **Rodada 2**: e-mail "Regras para alteração de escopo" — descoberta dos 6 tipos de amendment.
- **Rodada 3**: pasta "Escopos e solicitação documental" — taxonomia oficial de categorias FM 7.2.1.x.
- **Rodada 4**: FM 7.2.1.1 + PR 7.1 (65 pg) + pasta Ayat — fechamento das principais ambiguidades + 7 das 11 perguntas pendentes respondidas.

---

## 10. Próximos passos imediatos

Atualizado em 2026-05-09 após respostas da Lina e link do Fuad.

1. **Schema multi-mercado + multi-país (itens 1, 2, 11 da Onda 1+)** — primeiro alvo. Base para várias telas. Inclui `MarketScope`, `CategoryAccreditationMatrix`, `Country` com `marketCategory`, `CriticalRawMaterial` + restrições por país.
2. **Catálogo de Laboratórios** (movido de Onda 2 → Onda 1+ como warm-up paralelo): tabela `Laboratory` + role `qualidade` + UI READ-only no cliente. Seed dos 7 labs.
3. **Refactor HAS 2-estágios** (A.1 destravado): pequeno ajuste no schema do `HasReview` + UI minimal (upload + checklist + notes). Pode entrar com Onda 1+ ou Onda 3.
4. **ETL análise da pasta IFF-FAR**: usuário baixa manualmente da SharePoint, lista anexos, e calibra esquema antes de codar scripts ETL.
5. **Smoke test em staging** após primeiros 5-7 entregáveis da Onda 1+ — validar com Lina antes de seguir.
6. **Onda 2** (RawMaterialMaster + agente IA): pode arrancar em paralelo após o schema multi-mercado fechar, porque IA é independente.
