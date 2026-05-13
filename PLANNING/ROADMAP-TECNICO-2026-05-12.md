# Roadmap Técnico — Ecossistema Halal Ecohalal

**Data publicação inicial:** 2026-05-12 (manhã)
**Última atualização:** 2026-05-13
**Audiência:** time técnico Ecohalal (uso interno; complementa
[ROADMAP-DIRETORIA-2026-05-12.md](ROADMAP-DIRETORIA-2026-05-12.md))
**Horizonte:** mai/2026 → mai/2027 com âncora em **jul/2026 (go-live FAMBRAS)**
**Premissa de capacidade:** 1 dev + IA generativa massiva. Velocidade real
recente: 17 PRs schema/dia, 2 sprints da Supervisão Industrial Halal validadas/dia. Gargalo é
decisão+UX+integração, não código.

---

## 0. Evolução desde a publicação inicial

> Esta seção registra tudo que foi modificado no roadmap após a publicação inicial. Seções 1-10 abaixo continuam válidas exceto onde explicitamente atualizadas.

### 2026-05-12 — Publicação do roadmap + sprint inicial em produção

| ID | Repo | Commit(s) | Data | Descrição |
|---|---|---|---|---|
| C3 | `halalsphere-backend` | `26665501` + merge `3e361b38` | 2026-05-12 | Schema `Certificate.issuanceMode = workflow \| manual` + migration `20260512100000_add_certificate_issuance_mode`. AUTO_MIGRATE rodou normalmente em prod (confirmado em 13/mai via 3 queries SQL: coluna, enum, `_prisma_migrations`). |
| C2 | `halalsphere-backend` | (mesmo commit) | 2026-05-12 | `POST /certificates/manual-emit` com `@Roles('qualidade', 'admin')`. Transação atômica cria Certification synthetic + Scope + Brands + Products + Certificate + History. Reusa `CertificatePdfService.generateAndStore()` para PDF + QR. |
| C1 | `halalsphere-frontend` | `9e1f7a20` + merge `c68cfcbb` | 2026-05-12 | Página `/qualidade/emissao-manual-certificado` em 7 seções. RHF + zod + TanStack mutation. Success view com link PDF/QR/verify. |
| C6 | — | (já existia) | — | `/verify/:certNumber` confirmado funcional (componente `VerifyCertificate.tsx`, endpoint `@Public` `GET /certificates/verify/:number`). |

### 2026-05-13 — Selos FAMBRAS + 4 hotfixes pós uso real

| ID | Repo | Commit | Data | Descrição |
|---|---|---|---|---|
| C5 | `halalsphere-backend` | `368dbe46` + merge `3ef7c684` | 2026-05-13 | 15 selos cortados de `halalsphere-docs/CERTIFICATES/logos.png` (1719×2675, 5×3 grid) via `scripts/crop-seals.ts` (sharp). Resolve TODOs históricos: enas, oic, kepkaban, muis, ms agora apontam para PNGs reais. **Descoberta**: o que parecia "Turkey/GIMDES" é na verdade o selo oficial *Halal Accreditation Agency* com texto "OIC/SMIIC 2:2019 ACCREDITED 2023-039". `ALL_SEALS_REGISTRY` exporta os 16 selos (FAMBRAS + 15). 9 novas variantes em `MARKET_VARIANT_CONFIGS`. |
| C5 | `halalsphere-frontend` | `70724120` + merge `b2134e2d` | 2026-05-13 | Tela manual passa de 7 para 17 templates no dropdown de acreditação. |

#### Hotfixes do dia 13/mai (descobertos pelo PO em uso real)

| ID | Repo | Commit | Data | Descrição |
|---|---|---|---|---|
| Hotfix-1 | `halalsphere-frontend` | `92050efa` | 2026-05-13 | Sidebar + MobileMenu ganham link "Emitir Certificado (manual)" com ícone `FilePlus`, role `qualidade` (após Dashboard Qualidade) e admin (seção Geral). Bug: rota existia mas não havia link de navegação. |
| Hotfix-2 | `halalsphere-backend` | `8437f6b0` | 2026-05-13 | **Bug S3 AccessDenied no PDF/QR**: bucket `repo-production-halalsphere-docs` é privado (correto) mas backend devolvia URL pública direta sem assinatura. Refactor: `uploadToS3` agora retorna `s3://bucket/key` (URI canônico, persistido no DB). Novo helper `presignS3Uri(stored, options)` gera presigned URL fresca (TTL 15min) a cada consumo. Aceita também URLs `https://bucket.s3.*.amazonaws.com/key` legadas (extrai bucket+key, regenera assinatura) — sem migration de dados. |
| Hotfix-3 | `halalsphere-backend` | `87865853` | 2026-05-13 | Endpoint dedicado **`GET /certificates/:id/download-url?asset=pdf\|qr`** retorna `{ url, expiresIn, filename }`. NÃO regenera o PDF — só o link. Idempotente; pode ser chamado infinitas vezes. Auth `@Roles('empresa', 'analista', 'gestor', 'admin', 'auditor', 'comercial', 'juridico', 'gestor_auditoria', 'qualidade')`. Resolve a dúvida do PO: "preciso poder baixar D+10, D+30, sem regerar o PDF". |
| Hotfix-3 | `halalsphere-frontend` | `1f45b716` | 2026-05-13 | `certificateService.getDownloadUrl(id, asset)` no service. Tela manual emission success view usa o novo endpoint. |
| Hotfix-4 | `halalsphere-frontend` | `19a08f3b` | 2026-05-13 | Telas legadas `CertificationDetails.tsx` (card "Certificados") e `Certificate.tsx` (img QR + handleDownload) migradas para o novo endpoint. **Causa raiz** do bug em prod do PO: essas telas usavam `cert.pdfUrl` / `cert.qrCodeUrl` direto do banco como `href` ou `src`, e após o hotfix do S3 esses campos contêm `s3://...` URI (não browser-friendly). |

#### Decisões arquiteturais novas

1. **Armazenamento canônico em S3**: `Certificate.pdfUrl` e `Certificate.qrCodeUrl` no banco devem armazenar **URI no formato `s3://bucket/key`**, NUNCA URLs HTTP públicas. URLs HTTP são geradas on-demand via `presignS3Uri()`.
2. **Backward compat sem migration**: `presignS3Uri()` aceita tanto `s3://...` quanto `https://bucket.s3.*.amazonaws.com/...` legadas. Registros antigos no banco (pré-hotfix) continuam funcionando sem necessidade de UPDATE em massa.
3. **PDF imutável, link presigned regenerado**: `generateAndStore()` tem cache forte por `certificationId + version`. Re-chamadas retornam o mesmo PDF S3 (cache hit) com link presigned novo. **Forçar regeneração requer `forceRegenerate: true` explícito** — nunca acontece por acidente.
4. **TTL 15min** (`expiresIn: 900`): suficiente para qualquer operação de download imediato. Re-uso posterior chama o endpoint dedicado.
5. **Role gating de download**: `GET /:id/download-url` está aberto a praticamente todas as roles internas. Decisão consciente: o certificado é documento oficial; quem tem login na Gestão de Certificações tem direito a baixá-lo. Acesso público continua via QR Code → `/verify/:certNumber` (não permite download do PDF, apenas validação dos metadados).

#### Migration confirmada em prod (DBeaver, 2026-05-12 18:13Z)

```sql
-- A) coluna issuance_mode existe (USER-DEFINED, default workflow, NOT NULL) ✅
-- B) enum CertificateIssuanceMode = {workflow, manual} ✅
-- C) _prisma_migrations: hash real, finished_at preenchido, applied_steps_count=1 ✅
```

**Diferença vs Supervisão Industrial Halal:** AUTO_MIGRATE no ECS funcionou na primeira tentativa para `halalsphere-backend`. A dívida técnica de AUTO_MIGRATE quebrado é específica do `sih-backend` (memória `feedback_migrations_deploy.md`).

#### Dívida técnica conhecida (nova)

| Item | Sistema | Severidade | Observação |
|---|---|---|---|
| `Contracts.pdfUrl` armazenado como URL HTTP direta em vez de `s3://` URI | `halalsphere-backend` + `halalsphere-frontend` (ContractList, ContractDetails, ContractManagement, CertificationDetails seção existingContract) | Média | Mesmo padrão de bug do certificate. Se contratos estão no mesmo bucket privado, links vão dar AccessDenied. Aplicar mesmo refactor: storage canônico s3:// + presignS3Uri. Backlog separado. |
| `manualEmit` response devolve `pdfUrl`/`qrCodeUrl` que expira em 15min (mesmo embedados na resposta) | `halalsphere-backend` | Baixa | Hoje funciona porque o frontend desbrocou para usar o endpoint dedicado. Limpeza opcional: remover esses campos da response para forçar uso do endpoint. |
| Sem botão "Imprimir comprovante de emissão" no success view da tela manual | `halalsphere-frontend` | Baixa UX | Operadora Qualidade pode querer imprimir um recibo do que foi emitido. Backlog. |

#### Memórias persistidas (Claude)

- `project_emissao_manual_certificado_18mai.md` — escopo C1-C8, baseline e ponte pós go-live.
- `feedback_pdf_certificado_aberto.md` — PDF sem senha em definitivo (GAP-28 cancelado).
- `feedback_no_presume_query_success.md` — não presumir resultado de queries pelo "deu resultado" informal do PO; pedir output literal.

#### Impacto no resto do roadmap

- **Seção 4.0 (Sprint imediata 12-18/mai)**: substancialmente entregue. Falta apenas validação visual com FAMBRAS (15-17/mai), smoke pessoal do PO e treinamento (18/mai) — tudo não-código.
- **Seção 4.2 (Gestão de Certificações — fechar Onda 1+)**: service layer (items 10, 18, 20) continua no plano para 3-4ª semana de maio, sem ajustes.
- **Seção 6 (Dívida técnica)**: adicionar entrada de Contracts (acima).

---

## 1. Arquitetura macro

```
┌─────────────────────────────────────────────────────────────────┐
│                       Gestão de Certificações (HalalSphere)                          │
│  Master de: CompanyGroup, Company, Plant, Certification,        │
│  CertificationScope, MarketScope, Contract, Audit, Certificate. │
│  Stack: NestJS 11 + Prisma 7 + Postgres + Redis + AWS           │
└──────────────┬──────────────────────────────┬───────────────────┘
               │                              │
               │ REST API (token-based)       │ REST API
               │                              │
       ┌───────▼──────────┐          ┌───────▼─────────────────┐
       │   Supervisão Industrial Halal (Operação) │          │   Sys Halal (Embarque)   │
       │  Lê Plant + Cert │          │  Lê Plant + Cert (s0)   │
       │  Próprio: relatos│          │  Próprio: BatchCert     │
       │  abate, prod,    │          │  emission SFDA          │
       │  emb, NCs, inv   │          │                         │
       │  Stack: NestJS+  │          │  Stack: NestJS legacy   │
       │  Prisma+Postgres │          │  + Postgres             │
       └────────┬─────────┘          └──────────┬──────────────┘
                │                               │
                │ /operational-evidence/:lot    │ /cross-validation
                └──────────────►(porta 4)◄──────┘
                          (out/2026)
```

**Decisões arquiteturais persistidas em memória:**
- `project_arquitetura_halal_ecosistema.md` — Gestão de Certificações é master, Supervisão Industrial Halal/Sys Halal
  consumem.
- `project_halalsphere_syshalal_coexistencia.md` — não fundir; coexistência
  com integração.
- `project_conceito_grupo_categoria.md` — Grupo (holding) × Empresa (CNPJ) ×
  Categoria (IN/IND).
- `feedback_pricing_no_formula.md` — preço manual por contrato, sem fórmula
  global.
- `feedback_no_supabase_no_poc.md` — toda feature é produção; sem mock.

---

## 2. Stack por repo

| Repo | Branch trabalho | Stack |
|---|---|---|
| `halalsphere-backend` | `release` | NestJS 11 + Prisma 7 + Postgres + Redis + Passport-JWT + Anthropic SDK + AWS (S3, SES, SNS, Secrets Manager) |
| `halalsphere-frontend` | `release` | Vite 7 + React 19 + Radix + Tailwind v4 + TanStack Query + react-hook-form + zod + Recharts + pdfjs-dist |
| `sih-backend` | `release` | NestJS 11 + Prisma 7 + Postgres + bcrypt + JWT HS256 self-contained + pdfkit |
| `sih-frontend` | `release` | Vite + React 19 + Tailwind + shadcn/ui + TanStack Query + Axios + PWA (vite-plugin-pwa) |
| `syshalal-api` | `release` | NestJS legacy + Prisma + Postgres + pdf-lib |
| `syshalal-web` | `release` | Next.js 14 + React 18 + Chart.js + next-auth |

**Convenções consolidadas (memória `feedback_*`):**
- pnpm v10+ com `onlyBuiltDependencies` no `package.json` para CodeBuild.
- TS strict via `tsc -b` (não `tsc --noEmit`) — rodar local antes de pushar
  `release`.
- Zod v4: separar `BaseSchema` + `RefinedSchema`; `.refine()` quebra `.partial()`
  em runtime.
- Migrations: gerar via Prisma, validar `_prisma_migrations` antes de cada
  push em `release`. Em prod, **AUTO_MIGRATE no ECS não está funcionando**
  consistentemente; aplicar manualmente via DBeaver e registrar com
  checksum 'manual' até resolver (ver Supervisão Industrial Halal bug #2 do smoke).
- Swagger: regenerar via `npm run generate:swagger` + `node scripts/generate-api-gateway.js`.
- Repos Ecohalal: usar **somente** remote organizacional; sem fork pessoal.

---

## 3. Estado atual técnico (release tip)

### 3.1 Gestão de Certificações — halalsphere-backend + halalsphere-frontend

**Schema (banco):**
- 76 modelos Prisma. Onda 1+ FAMBRAS — 17 schema PRs entregues em mai/2026 (E,
  G-V). Pendente: nenhum item de schema. Ver
  `project_onda1plus_schema_completo.md`.
- Convivência legado + novo no schema (marcadas com comentário
  "Legado — substituído por X"): `brandType` + `ownership`,
  `auditType` + `stage`, `templateType` + `certificateType`,
  `applicableStandards[]` + `MarketScope`, `hasSubcontracted` + `Subcontractor`.

**Backend (lógica/API):**
- 50 módulos NestJS, 754 testes verdes.
- Refactor Empresa+Planta entregue. `/auth/register` cria Plant default em
  transação atômica. PlantModule completo (CRUD + soft-delete + reactivate).

**Frontend (telas):**
- Multi-país completo em tipos (`Plant`, `SanitaryCodeType` 17 valores,
  `PlantType`, `Species`).
- `plant.service.ts` com 7 métodos; `PlantsManager` integrado em
  `GroupCompanyDetail`.
- Wizard step 4 persiste production data via `plantService.update`.

**Gaps conhecidos:**
- **TargetMarketsStep não persistia** (gap pré-U1 — wizard captura países mas
  submit não chama `bulkUpsertMarketScopes`). Memória:
  `project_targetmarkets_gap_pre_u1.md`.
- **Company.validationStatus** existe no front mas não no Prisma. Memória:
  `project_company_validationstatus_divergence.md`.
- **Service layer da Onda 1+**: hook re-emissão (item 10), Proposal.feeOverride
  (item 18), SLA reverso (item 20).
- **ETL B.1**: ingestão da pasta IFF-FAR (caso real). User baixa manualmente
  do SharePoint.
- **Encoding `�`** em legalName/address.city quando dados foram enviados via
  curl no Windows (smoke 05-08) — hipótese A: curl mal configurado; hipótese
  B: parser Nest sem charset. Validar antes de prod massiva.

### 3.2 Supervisão Industrial Halal — sih-backend + sih-frontend

**Reset prod 2026-05-11** com backup `dump-db_ecohalal_sih-202605111435.sql`.
Admin atual: `admin@sih.com` (era `r.rbeiro@ecotrace.info` com typo). Memória:
`project_sih_admin_prod.md`.

**Schema (banco):**
- Migration `20260511160000_rename_companygroup_to_division` aplicada
  manualmente (checksum 'manual' — segunda vez que AUTO_MIGRATE não rodou).
- 3 plantas + 6 usuários + 2 abates aprovados + 1 produção assinado em prod.

**Sprints validadas:**
- Sprint 1 (TASK-02 + TASK-03) — perfil Controladoria + segmentação IN/IND ✅
- Sprint 2 (TASK-01 + TASK-04) — duplo check + workflow rejeição/reabertura ✅
- Sprint 3 (TASK-05 + TASK-08) — transferências origem/destino + degolador
  condicional ✅
- Sprint 4 (TASK-06 + TASK-09) — notificações in-app ✅ / **email SES ❌** /
  **anexos ❌ (regressão crítica)**
- Sprint 5 (TASK-07 + TASK-11) — **não validada** (próxima sessão)

**Bugs críticos abertos (smoke 11/12-mai):**

| # | Bug | Onde |
|---|---|---|
| 11 | PDF some após aprovação (compliance halal exige PDF) | sih-frontend: condição render botão PDF |
| 13 | Sessão vaza entre logout/login (cache TanStack + route guards frouxos) | sih-frontend: useAuth/useLogout, middleware role |
| 14 | Email SES de rejeição não chega | sih-backend NotificationService + ECS env vars + console SES |
| 16 | AttachmentsSection não renderiza em nenhum form (regressão Sprint 4) | sih-frontend ShippingReportForm/ProductionReportForm + git log |

**Bugs altos/médios:** 10 pendências mapeadas em
[SMOKE-TEST-2026-05-11-RESULTADOS.md](SMOKE-TEST-2026-05-11-RESULTADOS.md).

**Dívida infra:**
- AUTO_MIGRATE ECS não roda (2ª vez) — investigar Task Definition + buildspec.
- Cache PWA stale (`project_sih_cache_stale_bug.md`) — workbox runtime cache +
  TanStack Query a investigar.
- Ícone PWA `icon-192x192.png` não publicado no S3.

### 3.3 Sys Halal — syshalal-api + syshalal-web

- Em produção desde ago/2025. **Sem alteração em curso.**
- Reference: `reference_syshalal_api.md` (endpoints, auth, ambientes).
- Supervisão Industrial Halal consome `/certified*` via proxy (TASK-11/Sprint 5) — funcional.

---

## 4. Backlog por sistema (até jul/2026)

### 4.0 Sprint imediata 12-18/mai — Emissão manual de certificados com QR Code (Gestão de Certificações)

**Compromisso externo:** entregar à FAMBRAS até **18/mai/2026** uma tela
que permita emitir novos certificados halal já com o **QR Code novo** e
todos os gabaritos finalizados — sem depender do fluxo completo de
certificação (que só fica pronto em julho).

**Baseline técnica (já entregue em sessão 2026-04-12, ver
[BRIEFING-BLOCO2-PROXIMOS-PASSOS.md](../../halalsphere-docs/PLANNING/BRIEFING-BLOCO2-PROXIMOS-PASSOS.md)):**
- 4 renderers em `halalsphere-backend/src/certificate/pdf/`:
  - `approval-renderer.ts` (FM 7.7.1 Standard landscape)
  - `certificate-renderer.ts` (FM 7.7.2 Standard portrait)
  - `approval-arabic-renderer.ts` (FM 7.7.1 Arabic bilingue)
  - `certificate-arabic-renderer.ts` (FM 7.7.2 Arabic bilingue)
- `qrcode-generator.ts` com logo FAMBRAS sobreposto + error correction H
- `country-config.ts` (BR/AR/CO/PY/EC) + `seal-config.ts` com combos
  GAC_ENAS, OIC_SMIIC
- Disclaimers granel/álcool no attachment
- Persistência S3 em `halalsphere-certificates/{companyId}/{certificationId}/v{version}/certificate.pdf`
- Endpoint `@Public()` para verificação via QR Code
- `generatePdf()` no front + botões "Download PDF" em `Certificate.tsx` e
  `CertificationDetails.tsx`
- Validado em prod com `TST.SOC.2602.0001.BRA` (v5 OK)

**Gap para o 18/mai — o que falta:**

| ID | Entregável | Janela | Risco |
|---|---|---|---|
| C1 | **Tela `/qualidade/emissao-manual-certificado`** — formulário standalone (não passa por `CertificationRequest`/`Proposal`/`Contract`). Acessível **apenas pela role `qualidade`** (RBAC enforcement no front + guard backend). Campos: Empresa (autocomplete em `companies`), Planta (autocomplete em `plants` da empresa), número do certificado (validado único), datas emissão+vencimento, escopo de produtos (tabela inline), mercados (multi-select), formCode (FM_7_7_1/FM_7_7_2), templateCode (Standard/GAC_ENAS/OIC_SMIIC), país, flags granel/álcool | 12-14/mai | Baixo (Vite+RHF+zod já no stack) |
| C2 | **Endpoint backend `POST /certificates/manual-emit`** — guard `@Roles('qualidade')`; cria `Certificate` mínimo no banco (apenas dados necessários para verify do QR), chama `certificate-pdf.service.generateAndStore()`, retorna URL S3 + ID para o QR. Validar unicidade do `certificateNumber` | 12-13/mai | Baixo |
| C3 | **Schema ajuste**: adicionar enum `Certificate.issuanceMode = 'MANUAL' \| 'WORKFLOW'` para auditoria pós go-live (saber quais foram emitidos pela ponte vs fluxo completo) | 12/mai | Baixo (migration aditiva) |
| C4 | **Validação visual fim-a-fim** dos 4 gabaritos com dados reais em prod (testar cada `templateCode` + variações `isGranel`/`isAlcool`) — usar checklist da prioridade 2 do briefing Bloco 2. **Janela de validação visual com FAMBRAS aberta a partir de 15/mai** (combinado com cliente) | 15-17/mai | Médio (pixel-perfect demora) |
| C5 | **Selos faltantes** (ENAS, OIC, BPJPH, MUIS, MS) — copiar PNGs reais para `src/certificate/assets/images/` e remover TODOs do `seal-config.ts`. **Dependência: solicitar a Elaine (depto. Qualidade FAMBRAS)** PNGs em transparente; enviar pedido formal até 14/mai | 14-17/mai | Alto (dependência externa) |
| C6 | **Página pública de verificação QR Code** (`/verify/:certNumber`) — confirmar que o endpoint `@Public` já implementado tem UI dedicada e renderiza dados do certificado + selo "verificado". Se ainda renderiza só JSON, criar página simples | 14-15/mai | Baixo |
| C7 | **Decisão de produto: PDF aberto sem senha.** GAP-28 (senha PDF) permanece desativado — não fazer nada nesta sprint nem no go-live de julho. Remover GAP-28 do backlog de pendências | — | — |
| C8 | **Roteiro de smoke + treinamento** — 1h de demonstração com operador da Qualidade FAMBRAS emitindo 1 certificado real de cada gabarito | 18/mai | Baixo |

**Mitigação para C5 (selos):** se FAMBRAS não entregar até 16/mai, emitir
com placeholders em cinza neutro (sem logo de acreditador) + sinalizar com
texto "Selo a ser substituído" no rodapé. QR Code continua funcionando.
Selos podem ser hot-swapados sem regerar o PDF (S3 storage por versão).

**Ponte pós-julho:** a tela `/admin/emissao-manual-certificado` permanece
disponível como **"emissão de exceção"** após o go-live, para casos onde
o fluxo completo não cabe (re-emissão urgente, cliente legado migrando, etc.).

### 4.1 Supervisão Industrial Halal — completar antes do go-live

**Bloco A — bugs críticos (3ª semana mai):**
- Fix #11: condição render PDF inclui `aprovado` (status final/assinado em geral).
- Fix #13: `queryClient.clear()` no logout + route guards por role + redirect
  default por role.
- Fix #14: investigar SES sandbox/env vars/handler engolido — CloudWatch + SES
  console.
- Fix #16: investigar git log `AttachmentsSection` + condição render — provável
  remoção acidental durante refactor companyGroup→division.

**Bloco B — UX e infra (4ª semana mai / 1ª semana jun):**
- AUTO_MIGRATE ECS — analisar Task Definition prod, env vars, comando de
  startup.
- PWA cache: configurar `NetworkFirst` em runtime caching API; auditar
  `invalidateQueries`; `refetchOnMount: 'always'` em queries de dashboard.
- Route guard em `/slaughter-reports/new` etc.
- Auto-popular Origem/Destino do form de embarque a partir de `plant`
  selecionada (#10 do smoke).
- Placeholders Insensibilização Aves com `Ex: 0,30` etc. (#7).
- Filtro "Todos os tipos" na Controladoria — debug (#3 do smoke).
- Notificações: badge sino consistente + página `/notifications` (#8, #9).

**Bloco C — Sprint 5 (1ª semana jun):**
- Desossa bovinos (TASK-07) — campos específicos no `ProductionReportForm` +
  PDF.
- Plantas externas com certificadora não-FAMBRAS + upload de cert externo.
- Cert Sys Halal lookup (TASK-11) — `HalalCertField` em
  `MeatReceiptForm`/`BatchInventoryForm`/`ShippingReportForm` com fallback
  manual.

**Bloco D — IA POC (4ª semana jul / set):**
- Extração de dados de documentos via Claude API (cert, CSI, BL, fatura).
- Avaliar API MAPA para validação cruzada de SIF/CNPJ.

### 4.2 Gestão de Certificações — fechar Onda 1+ + antecipar Onda 2

**Service layer Onda 1+ (3-4ª semana mai):**
- **Item 10** — Hook `ScopeAmendment.onApprove() → CertificateService.reissue()`
  para 5 dos 6 tipos. Trigger via Nest EventEmitter (não SQL).
- **Item 18** — `Proposal.feeOverride` aceito sem fórmula + cálculo
  automático vira **template sugerido** sobrescrevível.
- **Item 20** — SLA reverso 30d antes da auditoria + alertas D-30/D-15/D-7
  (BullMQ + Redis).
- Backfill `MarketDestination` aditivo com `GulfRestrictionConfig` (item 23) —
  enum `UNDETERMINED` transitório.

**Fix gaps pré-Onda 1+ (3ª semana mai):**
- Fix `TargetMarketsStep` chamando `bulkUpsertMarketScopes` no submit do
  wizard (`project_targetmarkets_gap_pre_u1.md`).
- Alinhar `Company.validationStatus` — adicionar ao Prisma ou remover do
  front (`project_company_validationstatus_divergence.md`).

**UI Onda 1+ (jun/jul):**

| ID | Tela | Janela | Notas técnicas |
|---|---|---|---|
| U1 | Wizard solicitação 5 passos ramificado | 1-2ª sem jun | JSON-driven, engine compartilhada com U3/U4 |
| U2 | Split-view analista FM 7.1.9 | 2ª sem jun | Cálculo paramétrico GSO/SMIIC/IAF MD 5 |
| U3 | Hub alteração de escopo (5 cards) | 2-3ª sem jun | 6 tipos de amendment; aviso de aditivo com custo |
| U4 | Engine wizard JSON-driven | 1-2ª sem jun | Componente compartilhado (U1/U3/U6) |
| U5 | FM 9.3 unificado mobile | 3-4ª sem jun | Seções colapsáveis carimbadas; offline-first opcional |
| U6 | Hub permanente IT 7.12 docs | 4ª sem jun | Nudges contextuais (não inundação inicial) |
| U7 | Editor planilha MP Airtable-like | 1-2ª sem jul | Import Excel + reconciliação visual |
| U8 | Inbox analista | 4ª sem jun | Fila FM 7.1.9 + HAS + MPs |
| U9 | Tela aditivo contratual + PDF preview | 2ª sem jul | pdfjs-dist + `<ContractPreview contractId>` |
| U10 | Template proposta/contrato em PDF | 3ª sem jun | pdfkit (já no stack) |
| U11 | Mercado interno × exportação dual-toggle | 2ª sem jun | Chip colorido na listagem |

**Operacional (mai-jul):**
- Catálogo de Laboratórios + role Qualidade + 7 labs seed FAMBRAS (Onda 2
  antecipada — 1ª sem jun).
- Templates de proposta/contrato em PDF (U10).
- Seed dos 17+ documentos IT 7.12 na `KnowledgeBase` versionada.
- HomologationProfile FAMBRAS (laticínio, armazém, frigorífico, industrial)
  como seed.
- ETL pasta IFF-FAR — dry-run em staging antes (1ª sem jul).
- Tela **Programa de Certificação 3 modos** (Onda 2 antecipada — 3-4ª sem
  jul). Critical path para "demo de governança" FAMBRAS.
- IA Matérias-primas básica (Onda 2 antecipada — 4ª sem jul). Saídas:
  `criticality`, `mayBeAnimalDerived`, `animalSpecies`. Sem fontes externas.

### 4.3 Sys Halal — congelado até ago/2026 **EXCETO API v2 (em paralelo)**

**TASK-API-v2 — nova API de integração externa (mai-ago/2026, em paralelo):**
- A API atualmente usada por parceiros (despachantes, sistemas de clientes) e
  pelo importador interno de arquivos TXT empurra dados estruturados — detalhes
  de produto, datas de abate, datas de processamento — para campos genéricos de
  "descrição" e "informações adicionais", herança da versão anterior do sistema.
- A base de dados **já tem colunas segregadas** para esses dados (refactor
  anterior). Falta a API e o importador de TXT evoluírem para popular as
  colunas corretas e devolver os campos estruturados no JSON de resposta.
- Escopo: rewrite do controller de import + ajuste no parser de TXT + nova
  versão do schema OpenAPI da API externa (`/v2/...`) preservando `/v1/...`
  como deprecated.
- Habilita certificados de embarque novos com rastreabilidade halal completa
  lote a lote, sem depender de regex/parsing de texto livre em "descrição".
- Pode rodar em paralelo com TASK-S0 (consumo da Gestão de Certificações)
  porque toca módulos distintos.

**TASK-S0 — alinhamento com Gestão de Certificações (ago):**
- Sys Halal deixa de ter cadastro próprio de Company/Plant; consome da Gestão de Certificações via
  API.
- Migração de dados: mapear `syshalal.empresa.cnpj` → `gc.Plant.taxId`.
- Backfill com pasta IFF-FAR (caso já mapeado pela ETL B.1 da Gestão de Certificações).
- Roll-back plan: dual-write até confiança total.

**Porta 4 — validação cruzada (ago):**
- Endpoint `GET /cross-validation/:lotId` na Supervisão Industrial Halal retornando:
  ```json
  {
    "plantSif": "...",
    "supervisorHalal": "...",
    "abateDates": [...],
    "ncsInPeriod": [...],
    "volumeMatch": true/false
  }
  ```
- Sys Halal chama antes de assinar cert de embarque; bloqueia emissão se
  evidência operacional inconsistente.

---

## 5. Pontos de integração

### 5.1 Hoje

- **Supervisão Industrial Halal → Sys Halal**: `GET /certified` proxy da Supervisão Industrial Halal para consultar cert halal
  por número (TASK-11). Auth via API key.
- **Supervisão Industrial Halal ↔ Gestão de Certificações**: nenhuma.
- **Sys Halal ↔ Gestão de Certificações**: nenhuma.

### 5.2 Jun-jul (antes do go-live)

- **Supervisão Industrial Halal ← Gestão de Certificações** (opcional, conforme tempo): Supervisão Industrial Halal consome `Plant` da Gestão de Certificações em vez
  de cadastrar próprio. Read-only inicial, com fallback ao local.

### 5.3 Ago-set (porta 4 ativa)

- **Sys Halal → Gestão de Certificações**: `/companies/:taxId`, `/plants/:id`,
  `/certifications/active`.
- **Sys Halal → Supervisão Industrial Halal**: `/operational-evidence/:lotId`.
- **Gestão de Certificações → Supervisão Industrial Halal** (eventual): re-emissão de cert dispara webhook que invalida
  cache Supervisão Industrial Halal.

### 5.4 Cross-cutting

- **Email**: AWS SES com domínio Ecohalal. Bug aberto: SES não chega na Supervisão Industrial Halal —
  validar verified senders e env vars antes do go-live.
- **Storage**: AWS S3 com presigned URLs. Padrão para upload de anexos
  (relatórios, certs, HAS, docs IT 7.12).
- **Notificações**: in-app via WebSocket/Polling; email via SES; **WhatsApp**
  pendente decisão de canal.
- **Auth**: cada sistema tem JWT próprio. Possível SSO no futuro (Onda 3).

---

## 6. Dívida técnica conhecida

| Item | Sistema | Severidade | Quando atacar |
|---|---|---|---|
| AUTO_MIGRATE ECS não roda | Supervisão Industrial Halal (e provavelmente Gestão de Certificações) | Alta | 4ª sem mai |
| Cache PWA stale agressivo | Supervisão Industrial Halal | Alta UX | 4ª sem mai |
| Encoding `�` em campos com acento via curl | Gestão de Certificações | Média (precisa repro) | 1ª sem jun |
| Schema legado coexistindo (5 lugares) | Gestão de Certificações | Baixa | Pós Onda 1+ UI migrada |
| `companyGroup` renomeado para `division` em Supervisão Industrial Halal; ainda há código antigo? | Supervisão Industrial Halal | Baixa | Auditoria pós-smoke |
| `Company.validationStatus` divergência front × prisma | Gestão de Certificações | Média | 3ª sem mai |
| 43 mocks de testes pendentes Fase 2 Supervisão Industrial Halal (project_fase2_em_andamento) | Supervisão Industrial Halal | Baixa | Backlog |
| `axios` direto em backend Nest (admin-geral, qrtracecode) | (não Ecohalal) | — | — |

---

## 7. Quality gates pré-deploy

Checklist obrigatório antes de qualquer push em `ecohalal/release` (memória
`feedback_checklist_predeploy_sih.md`):

1. **Migrations** — gerar, validar localmente, registrar em
   `prisma/migrations/`. Se AUTO_MIGRATE não rodar, aplicar manualmente.
2. **Swagger** — `npm run generate:swagger` + `node scripts/generate-api-gateway.js`.
   Commit dos dois arquivos.
3. **TS strict** — `tsc -b` verde (não só `tsc --noEmit`).
4. **Zod v4** — DTOs com Create/Update separados; `.refine()` no Refined, não
   no Base.
5. **Tests** — `pnpm test` verde; aceitar legacy se contado e justificado.
6. **Branch** — trabalhar em `release` direto (sem PR `release→main`); push
   dispara CI/CD.
7. **Reconciliação** — após hotfix em `release`, merge `release → develop`
   para não perder.

---

## 8. Riscos técnicos e mitigações

| Risco | Mitigação |
|---|---|
| **Elaine (Qualidade FAMBRAS) atrasar entrega dos selos reais para 18/mai** | Pedido formal a Elaine até 14/mai; fallback com placeholders cinza + texto "Selo a ser substituído"; selos hot-swapáveis sem regerar PDF (S3 versionado) |
| **Tela manual de emissão criar certificados sem rastreabilidade** ao fluxo completo pós julho | Campo `issuanceMode='MANUAL'` no Certificate + dashboard de auditoria separa manuais de workflow |
| **QR Code novo divergir do design aprovado pela FAMBRAS** | Validação visual com FAMBRAS a partir de **15/mai** (3 dias antes do go-live operacional); layout do QR é parametrizável em `qrcode-generator.ts` |
| Backfill `MarketDestination` com dados ambíguos | Enum `UNDETERMINED` transitório + dashboard analista resolve antes do `NOT NULL` |
| Materialização `DocumentRequest` via hook explode N | Cap por request (~50) + alertas + dry-run staging |
| Trigger duplo de re-emissão (SQL antigo + hook novo) | Desativar SQL no mesmo deploy |
| `CertificationScope` polimórfico por categoria | Core + `categoryDetailsJson` validado por Zod no boundary (não N tabelas-junção) |
| AUTO_MIGRATE silencioso vira deploy quebrado em prod | Investigar antes da próxima migration; aplicar manual com checksum 'manual' até resolver |
| Coexistência legado + novo no schema confunde o front | Telas migram gradualmente; só remover legado depois que TODAS as telas migrarem |
| Smoke test em prod descobre regressão pós-deploy | Reset prod autorizado pelo PO permite reset de estado quando necessário |
| `axios` direto vs `@nestjs/axios` em código novo | Code review enforce `@nestjs/axios` em backend Nest |

---

## 9. Capacidade e ritmo (calibração realista)

**Velocidade observada (maio/2026):**

| Tipo de trabalho | Velocidade real | Velocidade "típica de mercado" |
|---|---|---|
| Schema PR aditivo (migration + tipos + tests) | 30-60 min cada | 1-3 dias cada |
| Refactor cross-stack (companyGroup → division, 23 arquivos) | 1-2 horas | 1-2 sprints |
| Smoke test de sprint completo em prod | 2-4 horas | 1-2 dias |
| Tela nova com wizard + schema + tests | 4-8 horas | 1-2 semanas |
| ETL com dry-run staging | 1 dia | 1 sprint |

**Implicação:** o roadmap pode ser executado **com folga** se o gargalo não
for desenvolvimento. Os gargalos reais previstos:

1. **Decisões de UX** com FAMBRAS (Lina/Fuad) — agendar sessões quinzenais.
2. **Disponibilidade do cliente real** para amostra de dados (IFF-FAR) —
   user precisa baixar SharePoint manualmente.
3. **Email/integrações com terceiros** (SES sandbox, SFDA, SharePoint) —
   bloqueios externos não-determinísticos.
4. **Treinamento operacional FAMBRAS** — depende de agenda dos supervisores,
   não da equipe técnica.

**Buffer recomendado para go-live julho:** ~25% (i.e., terminar
desenvolvimento em jun-15 dá folga até jul-30 para integração+treinamento).

---

## 10. Anexos

- [ROADMAP-DIRETORIA-2026-05-12.md](ROADMAP-DIRETORIA-2026-05-12.md) — versão
  executiva (audiência: diretoria + FAMBRAS)
- [FAMBRAS-VISITA-1504-ONDA-1+.md](FAMBRAS-VISITA-1504-ONDA-1+.md) — Onda 1+
  detalhada
- [SMOKE-TEST-2026-05-11-RESULTADOS.md](SMOKE-TEST-2026-05-11-RESULTADOS.md) —
  status Supervisão Industrial Halal com bugs
- [BRIEFING-PROXIMA-SESSAO-SMOKE-TEST.md](BRIEFING-PROXIMA-SESSAO-SMOKE-TEST.md) —
  retomar smoke Supervisão Industrial Halal
- [DECISOES-LINA-2026-05-09.md](DECISOES-LINA-2026-05-09.md) — respostas FAMBRAS
- [CADASTRO-EMPRESA-PLANTA-NOVO-MODELO.md (halalsphere-docs)](../../halalsphere-docs/PLANNING/CADASTRO-EMPRESA-PLANTA-NOVO-MODELO.md) —
  design do refactor Gestão de Certificações
