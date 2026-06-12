# Planilha MP & Fornecedores FAMBRAS (FM 7.4.2.7 / FAM-0017) — Resumo Executivo

**Data:** 2026-05-25 (rev 2 — pós validação PO)
**Status:** 8 decisões-chave validadas pelo PO; pronto para sprint
**Fonte:** [PLANILHA MP E FORNECEDORES (REV 9)_PT_EN-FAM-0017-NOTE 15.04.2026.xlsm](../../fambras-references-2026-04/_emails-fonte/Industrial/Lina/Gestão%20de%20certificação%20EcoHalal%20-%20visita%201504/)
**Plano-mãe:** [FAMBRAS-VISITA-1504-ONDA-1+.md](FAMBRAS-VISITA-1504-ONDA-1+.md) — itens U7 (UI) + Onda 2 schema MP

## Companion docs

| Doc | Quando ler |
|---|---|
| [PLANILHA-MP-FORNECEDORES-FAM-0017-SCHEMA.md](PLANILHA-MP-FORNECEDORES-FAM-0017-SCHEMA.md) | Para implementar o schema Prisma (9 modelos novos, 13 migrations). |
| [PLANILHA-MP-FORNECEDORES-FAM-0017-UI.md](PLANILHA-MP-FORNECEDORES-FAM-0017-UI.md) | Para implementar a tela U7 (reforma `/homologacao-mp` + import wizard). |

---

## 1. O que a planilha é

Planilha mestre que **cada cliente industrial certificado FAMBRAS preenche** listando suas matérias-primas, fornecedores e certificados halal. É **insumo obrigatório** do escopo de toda Certification industrial — sem ela, FAMBRAS não consegue auditar a cadeia.

- Código: **FM 7.4.2.7** (formulário) / **FAM-0017** (id documental).
- Revisão atual: **REV 9 NOTE 15.04.2026**.
- Envio: cliente envia por e-mail no mínimo **15 dias antes da auditoria**.
- Atualização: cliente revisa quando troca fornecedor, MP, ou cert halal expira.

## 2. Estrutura física

| Aba | Linhas (exemplo real) | Cols | Propósito | Quem edita |
|---|---|---|---|---|
| `1. MP E INSUMOS_RAW MATERIAL` | 2.603 | 20 (A–T) | MP alimentar + cert halal + fornecedor + produtos finais que usam | Cliente |
| `2. OUTROS_OTHERS` | 82 | 7 (A–G) | Insumos não-alimentares que tocam linha (embalagem, lubrificante, limpeza, pragas, tintas) | Cliente |
| `3. CONSULTA` (oculta) | 100 | 16 | Form de busca interno da FAMBRAS — descartar | — |
| `3. INTERMEDIÁRIAS` | 231 | 4 (A–D) | Whitelist de MPs pré-aprovadas pela FAMBRAS — dispensa cert halal individual | FAMBRAS (qualidade) |

### Picklists oficiais

- **Origin**: ANIMAL, MICROBIAL/MICROBIANA, VEGETABLE/VEGETAL, MINERAL, SINTETIC/SINTÉTICA, CHEMICAL/QUIMÍCO, VEGETABLE AND MINERAL, OUTROS
- **Halal certified?**: YES/SIM, PENDING INFORMATION, N/A (em produção real, **77 valores distintos** porque os clientes preenchem o nome da certificadora ali — HCS, IFANCA, MUI, JAKIM, etc.)
- **Risk**: ALTO, MÉDIO, BAIXO (na prática **dado lixo** — só 42 preenchimentos em 2.603 itens, vários com "N/A" ou "YES/SIM")
- **Original packaging?**: YES/SIM, NO/NÃO, PENDING INFORMATION
- **Categorias OUTROS_OTHERS**: WATER TREATMENT, PACKAGING, CLEANING PRODUCTS, LUBRICANTS, CONTROLE DE PRAGAS, TINTAS/CARIMBOS/SOLVENTES

### Padrão "bloco multilinha"

Cada item ocupa um **bloco de N linhas**:
- **Linha-cabeçalho:** todos os campos preenchidos (código MP, fabricante, fornecedor, cert halal, etc.)
- **Linhas filhas:** apenas col N "In which final products is the raw material used" preenchida — lista os produtos finais que usam aquela MP
- Blocos separados por linha vazia

Mesma MP (mesmo código B) aparece em **vários itens** quando o cliente compra de fabricantes/fornecedores diferentes — cada combinação `(MP × Fabricante × Fornecedor × Cert Halal)` é um item único, identificado pela col A "Número do Item" introduzida na REV 15.04.

## 3. Diff REV 15.04 vs REVs anteriores

Comparação contra `FM 7.4.2.7 - PLANILHA MP E FORNECEDORES (REV 9)_PT_EN 09.04.2026.xlsm` e `(06-10-25).xlsm`:

| Mudança | Detalhe |
|---|---|
| **+ Col A "Número do Item"** | Sequencial humano-legível por linha-mestre |
| **+ Col O "código fornecedor"** | Código interno do cliente para o fornecedor |
| **+ Aba "3. INTERMEDIÁRIAS"** | 231 MPs pré-aprovadas FAMBRAS (whitelist global) |
| **+ Conteúdo** | 1.423 → 2.603 itens (cliente real expandiu base) |

## 4. O que já existe no halalsphere-backend (não duplicar)

| Modelo | Linha em `schema.prisma` | Relação com FM 7.4.2.7 |
|---|---|---|
| `ScopeSupplier` | 2291 | Já tem 9 campos halal embutidos (comentário errado diz FM 7.4.2.9) — denormalizado, sem catálogo |
| `SupplierHomologation` | 4373 | Workflow de aprovação MP×Fornecedor com docs. Flag `fm7427Updated` rastreia atualização da planilha |
| `CriticalRawMaterial` | 2085 | **Régua FAMBRAS** de criticidade por categoria — não é a planilha do cliente |
| `HomologationProfile` | 2126 | Docs/questionários exigidos por categoria |
| `Certification.hasMpSpreadsheet` | 4267 | Flag binário "FM 7.4.2.7 entregue" |

**Gap:** não existe nem catálogo mestre de MP, nem catálogo de Fabricante, nem catálogo de Certificadora Halal, nem junction MP→Product (col N), nem whitelist de intermediários pré-aprovados, nem modelo para Outros Insumos (não-alimentares).

## 5. O que está sendo proposto

### Schema (detalhe em [PLANILHA-MP-FORNECEDORES-FAM-0017-SCHEMA.md](PLANILHA-MP-FORNECEDORES-FAM-0017-SCHEMA.md))

**11 modelos novos em 3 camadas:**

Global FAMBRAS (curado pela qualidade via workflow `pending → approved`):
- `HalalCertifyingBody` (~40 bodies — HCS, IFANCA, JAKIM, MUI, FAMBRAS, etc.)
- `Manufacturer` (~6-8k fabricantes globais com aprovação)
- `RawMaterialMaster` (~2k MPs canônicas — dicionário)
- `PreApprovedIntermediateMaterial` (whitelist da aba INTERMEDIÁRIAS, 231 inicial)

Per-Company (cliente edita):
- `RawMaterialSupplierEntity` — fornecedor/revenda comercial
- `CompanyRawMaterial` — mapping do código interno do cliente → `RawMaterialMaster`
- `RawMaterialSupplier` — junction `(MP × Fabricante × Fornecedor)` = "Item Número" da planilha
- `RawMaterialHalalCertification` — evidência halal polimorfa
- `RawMaterialUseInFinalProduct` — junction MP → Product (col N)
- `NonFoodInput` — aba OUTROS_OTHERS

Audit trail (ISO 17065):
- `RevisionLog` particionada por mês — todas as mutações em 9 modelos rastreados

**6 enums novos:** `RawMaterialOrigin`, `RawMaterialHalalEvidenceType`, `NonFoodInputCategory`, `HalalCertifyingBodyRecognitionStatus`, `GlobalCatalogApprovalStatus`, `RevisionMutationType`.

**2 modelos modificados:** `ScopeSupplier` e `SupplierHomologation` ganham FK opcional para `RawMaterialSupplier` + comentários de deprecação suave nos campos achatados.

**15 migrations aditivas** (zero breaking). **2 seeds** (HalalCertifyingBody curado + 231 intermediárias). `RawMaterialMaster` e `Manufacturer` começam vazios — populados via imports + curadoria FAMBRAS.

### UI (detalhe em [PLANILHA-MP-FORNECEDORES-FAM-0017-UI.md](PLANILHA-MP-FORNECEDORES-FAM-0017-UI.md))

**Reforma da rota `/homologacao-mp`** (correção: o plano FAMBRAS-VISITA mencionava `/company/suppliers-homolog` que **não existe**; a rota real é `/homologacao-mp`).

3 abas espelhando a planilha física:
1. **MP & Insumos** — grid virtual com 2k+ linhas + drawer lateral para edição completa + inline edit dos 4 campos quentes + drawer **Histórico de Edições** consumindo `RevisionLog`
2. **Outros Insumos** — grid simpler 6 colunas + chips coloridos por categoria
3. **Intermediários Pré-aprovados FAMBRAS** — read-only para cliente, CRUD via hub admin separado

**Wizard de import Excel** em 4 passos: upload com detecção de REV → mapeamento de colunas → **reconciliação visual** (diff +/~/− com merge de conflitos) → confirmação. Reverter por sessão de import via `RevisionLog` (sem janela 24h — versionamento permanente).

**4 admin hubs novos em `/admin/catalogos/`** para qualidade FAMBRAS gerenciar os catálogos globais com workflow `pending → approved` + fusão de duplicatas.

**Suporte a "FABRICANTE OCULTO"/"FORNECEDOR OCULTO"** (descoberta da planilha real — 328 linhas com NDA): `approvalStatus = anonymous` + UI distinta para anonimato preservado.

## 6. Decisões consolidadas (validadas PO em 2026-05-25)

### Resoluções definitivas das 8 perguntas

| # | Pergunta | Decisão |
|---|---|---|
| 1 | Planilha pertence a `Certification` ou `Plant`? | **`Certification`** — vinculação ativa via `ScopeSupplier` |
| 2 | `RawMaterial` per-Company ou global? | **Global FAMBRAS** (`RawMaterialMaster`) + **mapping per-Company** (`CompanyRawMaterial`) |
| 3 | `Manufacturer` global ou per-Company? | **Global FAMBRAS** com workflow `pending → approved` |
| 4 | `SupplierHomologation` da grid ou wizard? | **Só via wizard** de Certification |
| 5 | Sync `ScopeSupplier` ↔ `RawMaterialSupplier`? | **One-way pull** (catálogo → escopo) |
| 6 | `PreApprovedIntermediateMaterial` — seed ou CRUD? | **CRUD desde o início** (todos os 4 catálogos globais ganham admin hub) |
| 7 | Reverter import — A/B/B+/C? | **Opção C — `RevisionLog` completo**. Justificativa permanente: FAMBRAS é body certificadora sob ISO/IEC 17065, auditada por acreditadores externos (GAC/JAKIM/MUIS/ESMA). Audit trail por linha é **requisito de acreditabilidade**, não nice-to-have |
| 8 | MVP focado ou 2 caminhos completos? | **2 caminhos completos** — MVP não é alternativa |

### Decisões técnicas dos agentes (mantidas)

| Decisão | Justificativa |
|---|---|
| `RawMaterialSupplierEntity` é **per-Company** com vínculo opcional a `SharedSupplier` | Nem toda Company quer compartilhar fornecedor com grupo; ponte opcional |
| `RiskLevel` **não vira enum** | Dado lixo na planilha real; criticidade canônica vive em `CriticalRawMaterial` + `RawMaterialMaster.criticalityHint` |
| Histórico de cert halal é mantido (não sobrescreve) | Reforçado por C: `RevisionLog` cobre tudo |
| UI usa **grid + drawer** (não cards, não grid puro) | Melhor compromisso para 2k+ linhas + multilinha + revisão FAMBRAS + mobile |
| Virtual scroll obrigatório (`@tanstack/react-virtual`) | 2.000+ linhas inviabilizam paginação |
| Parsing Excel canônico no **backend** (não cliente) | Diff browser vs node diverge em datas/floats — fonte da verdade no Nest |
| `revision_logs` particionada por `mutated_at` + arquivamento S3 Glacier após 24m | Volume linear; particionar desde o início evita rebuild gigante |
| **NÃO usar termos haram em seeds/mocks** | Memória `feedback_halal_no_haram_terms` |

## 7. Pendências residuais (não bloqueantes; resolver na implementação)

As 8 perguntas-chave foram **todas resolvidas pelo PO em 2026-05-25** (ver §6). Restam afinamentos operacionais:

1. **`itemNumber` (col A) — auto-incremento por Company?** Recomendação: sequence per-Company, persistir após reordenação no Excel exportado.
2. **Threshold do matching fuzzy no import** — 80% sugere, 95% pré-marca aceitar. Calibrar com primeiros imports reais.
3. **SLA para aprovação `Manufacturer pending` pela qualidade FAMBRAS** — proposta 2 dias úteis + notificação automática. Confirmar com a equipe Lina/Soha.
4. **Política de retenção `revision_logs`** — proposta: 24 meses Postgres ativo + S3 Glacier indefinido. Confirmar.
5. **Curadoria inicial das ~40 `HalalCertifyingBody`** — depende da Soha/Lina FAMBRAS enviar a lista normalizada com `recognitionStatus` por body.

## 8. Inserção no roadmap

Este trabalho **não está representado** explicitamente no plano FAMBRAS-VISITA-1504-ONDA-1+ como item completo. O que existe:

- **U7** (UI editor inline + import) — `✅ confirmed` mas **não iniciado**
- **Onda 2 schema** menciona genericamente `RawMaterialMaster + agente IA` (B.2 destravado), mas sem detalhe estrutural

**Recomendação de classificação no roadmap (revisada pós-PO):**

| Bloco | Pertence a | Tamanho |
|---|---|---|
| Schema (11 modelos + 15 migrations + 2 seeds + RevisionLog particionada) | **Onda 2** (expande "RawMaterialMaster") | 5-7 dias dev backend |
| Interceptor Nest do `RevisionLog` + endpoints revert | **Onda 2** | 2-3 dias backend |
| UI U7 (grid + drawer + 3 abas + drawer Histórico de Edições) | **Onda 1+** (já planejado U7) | 6-8 dias dev frontend |
| UI import wizard (4 passos com reconciliação) | **Onda 1+** (parte de U7) | 4-6 dias dev frontend |
| Agente IA criticidade (B.2) | **Onda 2** | 2-3 dias |
| 4 admin hubs `/admin/catalogos/*` com workflow `pending → approved` + fusão | **Onda 2** | 4-5 dias |

**Total estimado:** **~4 semanas dev consolidado** (era 3; +1 semana absorvendo `RevisionLog` + admin hubs + drawer Histórico de Edições).

## 9. Próximos passos imediatos

1. ✅ **8 perguntas PO validadas em 2026-05-25** — decisões consolidadas em §6.
2. **Atualizar `FAMBRAS-VISITA-1504-ONDA-1+.md`** marcando: (a) rota correta `/homologacao-mp` (não `/company/suppliers-homolog`); (b) schema MP detalhado fica nestes 3 docs; (c) link cruzado.
3. **Flatten da aba INTERMEDIÁRIAS para CSV** em `halalsphere-docs/FAMBRAS/FM-7.4.2.7-INTERMEDIARIAS.csv` para alimentar seed S2 (231 itens).
4. **Curar lista de Halal Certifying Bodies** — extrair os 76 valores distintos da col F, normalizar via aliases, classificar `recognitionStatus`. Tarefa de qualidade FAMBRAS (Soha/Lina).
5. **Spike técnico (1 dia)**: validar performance do virtual scroll com 2.500 linhas + filtros encadeados em browser real — antes de comprometer arquitetura.
6. **ADR formal sobre interceptor Nest + `RevisionLog`** — documentar design do middleware Prisma, política de async via EventEmitter, schema evolution (`schemaVersion`) e fluxo de revert.
7. **Abrir issues** no `halalsphere-backend` (schema) e `halalsphere-frontend` (UI) referenciando estes 3 docs.

## 10. Conexão com pendências mapeadas em outras análises

Esta análise **fecha** parcialmente os seguintes itens pendentes do plano FAMBRAS:

- ✓ U7 — agora tem spec detalhado (não só linha de tabela)
- ✓ Onda 2 schema `RawMaterialMaster` — agora detalhado em 9 modelos
- ✓ Aba INTERMEDIÁRIAS — descoberta nova (não estava no plano anterior)
- ✓ Catálogo de certificadoras halal — descoberta nova
- ⚠ Cruzamento `RawMaterial ↔ CriticalRawMaterial` — proposto via FK opcional, mas matching automático (pg_trgm) fica para sprint separado
- ⚠ Agente IA criticidade (B.2 da Onda 2) — modelo de dados aqui é compatível, mas service IA ainda não detalhado

E **destrava** o caminho para:
- ETL da pasta IFF-FAR (cliente real — Fuad enviou link OneDrive) — agora temos schema-alvo para mapear
- U6 (hub IT 7.12) — quando a U7 estiver pronta, o padrão de upload + versionamento se replica
- Hub admin de catálogos da qualidade (Intermediárias, Certifying Bodies, Critical Raw Materials) — surge naturalmente

## 11. Riscos

1. **FK circular em M11** entre `RawMaterialSupplier` e `RawMaterialHalalCertification` — Postgres aceita mas Prisma migrate pode reclamar. Mitigação: ALTER posterior (já planejado).
2. **Cache TanStack Query stale** repete bug conhecido (memória `project_sih_cache_stale_bug`). Mitigação: `staleTime: 30s` máx + invalidação explícita em mutate.
3. **Curadoria das Certifying Bodies depende de FAMBRAS** — atraso em receber lista normalizada bloqueia seed S1. Mitigação: começar com `recognitionStatus = unknown` em todas, evoluir depois.
4. **Volume JSON do endpoint** — 2.000 linhas × 20 campos ~ 500KB. Aceitável mas marginal em conexões 3G. Mitigação: gzip + paginação fallback configurável.
5. **Cliente espera que planilha continue sendo "fonte de verdade externa"** — se ele preferir continuar editando .xlsm e mandar por e-mail, o sistema vira só repositório (não consultoria automatizada). Mitigação: educação na onboarding + value-prop do dashboard de vencimentos.
6. **Write amplification do `RevisionLog`** — cada UPDATE vira UPDATE + INSERT. Em pico de import (~500 linhas em 30s) pode pressionar disco. Mitigação: interceptor async via `EventEmitter` (não bloqueia request); índices certos `(entity_type, entity_id, version)`; particionamento mensal evita scan da tabela inteira.
7. **Schema evolution do `dataSnapshot Jsonb`** — se um campo for renomeado no model, o snapshot mantém nome antigo. Mitigação: campo `schemaVersion: Int` no log + deserialização tolerante.
8. **Acreditador pede histórico anterior à implantação** — não temos data pré-Onda 2. Mitigação: relatório de transparência "Sistema de audit trail completo implementado em DD/MM/AAAA; auditoria anterior via planilhas Excel arquivadas" — documentar explicitamente para auditor externo.

---

**Última revisão:** 2026-05-25
**Próxima revisão:** após retorno do PO sobre as 8 perguntas da §7
