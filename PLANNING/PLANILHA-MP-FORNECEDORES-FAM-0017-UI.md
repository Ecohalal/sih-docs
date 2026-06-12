# Spec UI U7 — Editor Inline Planilha MP/Fornecedores (FAM-0017 / FM 7.4.2.7) + Import Excel

**Data:** 2026-05-25 (rev 2 — pós validação PO)
**Status:** decisões PO consolidadas (1,4,6,7,8); pronto para sprint UI
**Alvo:** `c:\Projetos\Ecohalal\halalsphere-frontend\src\` — reformar rota `/homologacao-mp`
**Plano-mãe:** [FAMBRAS-VISITA-1504-ONDA-1+.md](FAMBRAS-VISITA-1504-ONDA-1+.md) — item U7
**Companion docs:**
- [PLANILHA-MP-FORNECEDORES-FAM-0017.md](PLANILHA-MP-FORNECEDORES-FAM-0017.md) — resumo executivo
- [PLANILHA-MP-FORNECEDORES-FAM-0017-SCHEMA.md](PLANILHA-MP-FORNECEDORES-FAM-0017-SCHEMA.md) — schema Prisma

---

## 0. Premissas e nomenclatura

- **Linguagem da UI**: pt-BR (com tooltips bilíngue PT/EN onde a planilha original tem cabeçalho duplo).
- **Stack**: shadcn/ui + Tailwind v4 + Radix + TanStack Query v5 + react-hook-form + zod + react-dropzone (todos já no `package.json`).
- **Novas libs a adicionar**:
  - `@tanstack/react-virtual` (virtual scroll) — obrigatório, clientes têm >2.000 linhas.
  - `xlsx` (SheetJS) **client-side só para preview/parsing leve**; o parsing canônico é no backend (ver §3.1).
  - `@tanstack/react-table` v8 (headless table) — opcional mas recomendado; substitui matrix manual.
- **Sem MUI, sem inline `style={}`**, sem `<select>` HTML nativo (sempre usar `<Select>` shadcn). Em modo read-only: **`<div>` plano**, não `<Select disabled>` (memória `feedback_select_disabled_em_view_only`).
- **Cache TanStack Query**: usar `staleTime: 30s` máx. para a planilha; invalidar agressivamente após mutate. Memória `project_sih_cache_stale_bug` lembra do bug de listas estagnadas.
- **Mocks e exemplos**: jamais usar termos haram (porco, álcool etc.). Use sempre exemplos halal: gelatina bovina, lecitina de soja, ácido cítrico, açafrão, palma, cacau, leite em pó (memória `feedback_halal_no_haram_terms`).

> **Correção ao briefing original:** o plano FAMBRAS-VISITA menciona `/company/suppliers-homolog` que **NÃO existe** como rota. A rota real do projeto é `/homologacao-mp` (App.tsx:768). Esta spec mantém `/homologacao-mp`.

---

## 1. Estrutura de telas e navegação

### 1.1 Layout geral da rota `/homologacao-mp`

```
┌─ AppLayout (sidebar + topbar) ────────────────────────────────────────────────┐
│ Breadcrumb: Empresa › Certificação X › Planilha MP & Fornecedores             │
│                                                                                │
│ ┌─ PageHeader ───────────────────────────────────────────────────────────────┐ │
│ │ H1 "Planilha de MP & Fornecedores"   [Cert: BR-FAM-2025-0123 ▾] [⬇ Export]│ │
│ │ Sub: "FM 7.4.2.7 REV 9 — atualizada há 3 min por Ana C."   [⬆ Importar]   │ │
│ └────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                │
│ ┌─ AlertBanner (cond.) ──────────────────────────────────────────────────────┐ │
│ │ ⚠ 12 certificados halal vencem nos próximos 30 dias.  [Filtrar]           │ │
│ └────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                │
│ ┌─ Tabs ─────────────────────────────────────────────────────────────────────┐ │
│ │ [ MP & Insumos (2.317) ] [ Outros Insumos (84) ] [ Intermediários (231) ] │ │
│ │ ─────────────────────────────────────────────────────────────────────────── │
│ │  (conteúdo da aba selecionada — ver §2, §4, §5)                            │ │
│ └────────────────────────────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────────────────────────────┘
```

**Seletor de Certificação no topo**: a planilha pertence sempre a *uma* Certification (mais precisamente, à Plant da Certification). Se o usuário tem mais de uma Cert ativa, abrir Combobox shadcn no header — pré-selecionar a última editada.

**Persistência por aba na URL**: `/homologacao-mp/:certificationId?tab=mp` (default `mp`) para deep-link e voltar do drawer manter contexto.

### 1.2 Decisão sobre as 3 abas

A planilha FAM-0017 nasce com 4 abas físicas (MP, Outros, Consulta oculta, Intermediárias). **A aba "Consulta" é descartada** — é utilitário interno de planilha, não conteúdo do domínio. Logo a navegação fica **3 abas**:

1. **MP & Insumos** (aba primária, ~95% do uso)
2. **Outros Insumos** (não-alimentares)
3. **Intermediários Pré-aprovados FAMBRAS** (read-only para o cliente)

**Crítica à própria escolha**: considerei colapsar MP+Outros em uma única aba com filtro de tipo, mas o usuário FAMBRAS mentalmente trata isto como planilhas separadas (a planilha física tem abas distintas). Manter espelhamento reduz fricção cognitiva. A integração visual virá pelo banner de vencimento que somariza as duas.

### 1.3 Integração com cards de homologação existente

A rota atual hospeda dois fluxos diferentes confundidos:
- **Catálogo de MP/fornecedores** (esta U7, novo) — fonte de verdade do escopo.
- **`SupplierHomologation`** (existente) — workflow de aprovação documental por item.

Proposta: a tabela U7 traz coluna **Status FAMBRAS** que reflete o último `SupplierHomologation` daquela linha. Clicando no badge abre **drawer lateral "Histórico de Homologação"** mostrando timeline + docs anexados. Botão "Solicitar Homologação" dispara create de `SupplierHomologation` (já existente, reaproveitar `supplier-homologation.service.ts`).

O `SupplierHomologationList` atual (`pages/company/SupplierHomologationList.tsx`) é mantido como tela secundária acessível por **link "Ver todas as homologações em andamento"** no header da U7 — útil para o auditor FAMBRAS ver fila plana cross-cliente.

---

## 2. Editor inline da aba "MP & Insumos"

### 2.1 Decisão arquitetural: 3 alternativas avaliadas

| Critério | (A) Grid editável puro | (B) Cards + modal | (C) Grid + drawer lateral |
|---|---|---|---|
| 2.000+ linhas | ✓ ótimo (virtual scroll) | ✗ paginação obrigatória, lento | ✓ ótimo |
| Multilinha por item (col N) | ✗ complexo (sub-row dentro de virtual row) | ✓ natural (lista no card) | ✓ excelente (drawer mostra lista filha) |
| Revisão por auditor FAMBRAS | ✓ visão densa, comparativa | ✗ scrolling chato | ✓ ✓ (linha contextual + form completo) |
| Edição rápida (lote) | ✓ ✓ ✓ | ✗ | ✓ (bulk via checkbox + barra) |
| Mobile | ✗ ruim, scroll horizontal | ✓ excelente | ✓ aceitável (drawer ocupa 100%) |
| Performance render | ✓ se virtualizado bem | ✓ | ✓ |
| Curva de implementação | Alta (validação por célula, dirty tracking, etc.) | Baixa | Média |
| Risco de bugs sutis (focus, race) | Alto | Baixo | Médio |

**Recomendação: (C) Grid + drawer lateral**, com edição inline *opcional só nos 4 campos mais frequentes* (Risk, Halal cert, Validity date, Status). Para alterações complexas (mudar fabricante, adicionar produtos finais, anexar cert), drawer.

**Por quê (C)**:
- Resolve o problema multilinha (col N) de forma elegante — produtos finais viram chips/lista no drawer, não poluem grid.
- Auditor FAMBRAS pode revisar dezenas de linhas em sequência via teclado (J/K para próximo/anterior dentro do drawer).
- Mobile-friendly: drawer vira sheet bottom em <md.
- Inline edit pontual cobre o caso "preciso só atualizar o vencimento" sem abrir drawer.

### 2.2 Colunas visíveis

**Default (8 colunas):**
1. ☑ checkbox bulk
2. **Nº** (col A — número sequencial, sticky left)
3. **Código MP** (sticky left, monospace, com badge se intermediário FAMBRAS)
4. **Nome do Produto** (com tooltip mostrando nome em EN se diferente)
5. **Fabricante** › **Fornecedor** (duas linhas dentro da célula; chip `pending FAMBRAS` quando fabricante novo aguardando aprovação)
6. **Cert Halal** (chip status: SIM/PENDENTE/N-A) — **editável inline (Select)**
7. **Validade** (DateTime, vermelho se ≤30d, amarelo ≤60d) — **editável inline (popover calendar)**
8. **Status FAMBRAS** (Aprovado / Pendente / Reprovado / Rascunho) — readonly
9. Action menu (kebab — Editar, Anexar doc, **Histórico de edições**, Duplicar, Inativar)

> **Decisão PO #4:** kebab e barra de bulk **não** disparam `SupplierHomologation` direto. Esse fluxo continua exclusivamente no wizard de Certification. A grid U7 é catálogo + visualização de status, não orquestrador.

**Ocultas por padrão (acessíveis via "Colunas" popover — Checkbox list)**:
- Código Fornecedor (col O, novo REV 15.04)
- Origem (ANIMAL/MICROBIANA/VEGETAL/...)
- Risco (ALTO/MÉDIO/BAIXO)
- Embalagem original (S/N/PEND)
- Órgão emissor (HCS, IFANCA, JAKIM, ...)
- Nº cert halal
- Emissão da cert
- Endereço fabricante
- Produtos finais que usam essa MP (chips, count + popover lista)
- Categoria industrial
- Observações (Remarks)
- Quem editou + quando

**Configuração de colunas persistida em localStorage por user** (`hs:planilha-mp:cols:v1`), com botão "Resetar ao padrão".

### 2.3 Representação de blocos (item-pai + produtos finais filhos)

A planilha física repete o cabeçalho do item por linha-filha (uma por produto final que usa aquela MP). **Na UI, NÃO duplicamos**: cada linha = 1 item canônico (`{códigoMP, fabricante, fornecedor, certHalal}`). O multivalor "produtos finais" vira:

- **Na grid**: chip compacto `"Salgadinho de queijo +4"` (popover ao hover mostra lista completa).
- **No drawer**: seção dedicada "Produtos finais que usam esta MP" com TagsInput (combobox multi-select com criação livre + autocomplete dos produtos já cadastrados no escopo).

Quando o **mesmo Código MP** é usado com fabricantes diferentes (cenário real da planilha — códigos repetidos), aparece **agrupador colapsável**:
```
▼ MP-00231  Lecitina de soja                          [3 fornecedores]
  │ Solae Brasil  · Solae do Brasil Ltda · SIM · 12/2026
  │ Cargill       · Cargill Agríc.       · SIM · 03/2027
  │ DowDuPont     · DuPont Nutrition     · PENDENTE · —
```
Agrupador é **opcional** — toggle "Agrupar por Código MP" no header da grid (default ON quando >50 linhas).

### 2.4 Validação em tempo real

Validações com **zod schema por linha** (rodadas no `onBlur` da célula e no save do drawer):

- `codigoMP`: regex `^[0-9A-Z]{3,12}$`, único por (manufacturer + supplier).
- `productName`: required, max 200.
- `manufacturerName`: required.
- `supplierName`: required.
- `halalCertified`: enum YES|PENDING|N_A. Se YES, exige `halalCertBody`, `halalCertNumber`, `halalIssueDate`, `halalValidityDate`.
- `halalValidityDate > halalIssueDate`.
- `halalValidityDate >= hoje` (warning amarelo, não bloqueante — auditor pode estar registrando histórico).
- `origin`: enum dos 7 valores. Se ANIMAL, exige `halalCertified == YES` (regra de negócio FAMBRAS — animal sem cert é bloqueio).
- `risk`: enum ALTO|MEDIO|BAIXO (opcional mas se ANIMAL e risk vazio → autopreencher ALTO + warning).
- `originalPackaging`: enum YES|NO|PENDING.

**UX dos erros**:
- Célula com erro: borda `border-destructive` + ícone `AlertCircle` no canto direito da célula.
- Tooltip no ícone mostra mensagem (pt-BR).
- Linha com qualquer erro: tag vermelha pulsando "1 erro" no início.
- **Drawer aberto com erros**: salvar fica disabled, contador no rodapé "3 campos pendentes — Cert Halal vencida, Origem em branco, ...".
- Erros bloqueantes (regra ANIMAL+Halal) impedem submit ao backend; erros de warning (validade próxima) só sinalizam.

### 2.5 Estados das células

| Estado | Visual | Quando |
|---|---|---|
| Limpo (sincronizado) | sem indicador | linha salva e validada |
| Dirty (rascunho local) | ponto laranja no início da linha | usuário alterou, autosave pendente |
| Salvando | spinner pequeno + opacidade .7 | request em voo |
| Salvo agora | check verde fade-out 2s | confirmado |
| Erro de save | banner inline na linha "Falha ao salvar — Tentar de novo" | 4xx/5xx |
| Erro de validação | borda vermelha + ícone | zod fail |
| Aprovado FAMBRAS | borda esquerda verde 3px | último `SupplierHomologation.status = aprovado` |
| Pendente FAMBRAS | borda esquerda amarela | status documentacao_enviada / em_analise |
| Reprovado FAMBRAS | borda esquerda vermelha + fundo `bg-destructive/5` | status reprovado |
| Rascunho do cliente (nunca submetido) | borda tracejada cinza | item criado mas sem homologação solicitada |

### 2.6 Filtros e busca

Barra de filtros logo abaixo das tabs, com chips Radix:

- **Busca global** (Input com debounce 300ms): casa código, nome, fabricante, fornecedor, nº cert.
- **Categoria industrial** (multi-select chips).
- **Status FAMBRAS** (multi-select: aprovado / pendente / reprovado / rascunho).
- **Origem** (multi-select).
- **Cert halal** (toggle group: SIM/PENDENTE/N-A/Vencida/Vence em 30d/60d).
- **Criticidade** (ALTO/MÉDIO/BAIXO).
- **Linhas com erro** (toggle "Apenas com pendências").

Filtros refletidos na URL (`?q=lecitina&status=pendente,reprovado`). Botão "Limpar filtros" quando >0 ativo. Contador "Mostrando 47 de 2.317" sticky abaixo da barra.

### 2.7 Bulk actions

Quando ≥1 checkbox marcado, barra **`ActionBar` flutuante** aparece no rodapé (motion fade-up, animação 150ms):

```
┌─ 12 linhas selecionadas ─────────────────────────────────────────────────────┐
│ [Reaplicar fornecedor ▾] [Marcar inativo] [Exportar selecionados (.xlsx)]    │
│ [Anexar mesmo doc] [✕ Limpar seleção]                                        │
└──────────────────────────────────────────────────────────────────────────────┘
```

> **PO #4:** removido botão "Solicitar homologação" das bulk actions (fluxo só via wizard de Certification).

Bulk endpoints PATCH `/raw-materials/bulk` (criar no back) com array de IDs + delta. Dialog de confirmação antes de operação destrutiva (inativar). Toast de sucesso com botão **"Desfazer"** que reenvia delta reverso por 10s (sonner action).

> **Importante (PO #7):** com `RevisionLog` ativo, "Desfazer" não é só UX — é um revert formal que cria nova versão. Toda mutação fica registrada, o "desfazer" gera entrada `mutationType=update reason="Bulk undo via toast"`.

### 2.8 Autosave por linha + indicador visual

- **Trigger**: `onBlur` de célula inline, ou `onSubmit` do drawer.
- **Debounce**: 800ms para o caso de o usuário editar várias células sem perder foco fora da linha (saída de linha confirma).
- **Indicador global no header**: "Salvo há 3 segundos" / "Salvando..." / "Alterações não salvas (5)".
- **Optimistic update** com `useMutation` + `onMutate`/`onError` rollback. Em erro, manter dirty + toast.
- **Single-flight por linha**: se nova edição chega antes da anterior responder, cancelar request anterior (AbortController) e enviar nova com merge.

### 2.9 Comentário/observação por linha (col T Remarks)

**Não** colocar como célula expandida — polui grid. Opções:

- **Coluna oculta por default**, mostra ícone `MessageSquare` (com contador se >0) na coluna actions.
- **Popover ao clicar**: mostra histórico de observações (timestamp + autor) + textarea para nova.
- No drawer: seção dedicada "Observações" com timeline.

Modelo de dados: `RawMaterial.remarks` (string longa) + opcional `RawMaterialNote[]` para histórico. Decisão: começar simples (string mutável + ícone na grid), evoluir para notes histórico só se PO pedir auditoria.

### 2.10 Paginação OU virtual scrolling

**Virtual scrolling**, sem dúvida (`@tanstack/react-virtual` com `useVirtualizer`). Justificativa:

- Cliente FAMBRAS real tem 2.317 linhas. Paginação quebra `Ctrl+F`, filtros perdem contexto, scroll horizontal já é problema sem somar quebra vertical.
- Backend retorna TUDO via 1 endpoint `/raw-materials?certificationId=X` (esperar ~500KB JSON pra 2.000 linhas — aceitável).
- Cache TanStack Query com `staleTime: 30_000`, `gcTime: 5_min`. Invalidar em mutate.
- Virtualizer com `estimateSize: 56`, `overscan: 10`.
- Render row condicional: skeleton 4-line shimmer enquanto a query carrega (mostrar 20 skeleton rows na altura visível).

**Fallback** se a planilha vier com >5.000 linhas (improvável, mas possível): degradar para paginação server-side com warning amarelo "Planilha muito grande — modo paginado ativado para performance". Configurável por env `VITE_PLANILHA_VIRTUAL_LIMIT`.

---

## 3. Import Excel com reconciliação visual

### 3.1 Arquitetura: parse onde?

**Backend canônico**: o parsing real (validação de schema FAM-0017, detecção de REV, mapeamento) acontece no backend Nest (já existe `xlsx` provavelmente; senão, adicionar `exceljs`). Endpoint: `POST /raw-materials/import/preview` (multipart) → retorna `ImportSession { id, sheets, diffs, warnings }`. `POST /raw-materials/import/:sessionId/commit` aplica.

Cliente faz parse leve apenas para mostrar **preview de header** antes do upload (UX feel responsivo): tira primeiras 20 linhas, lê cabeçalho via `xlsx.read({type:'binary'})`. Se header bate com REV conhecida, mostra ✓ verde antes mesmo de enviar.

Justificativa: planilhas FAMBRAS contêm fórmulas, células mescladas, sub-linhas — fácil parsing inconsistente entre node-xlsx e xlsx browser. Backend manda no schema. Cliente é só UI.

### 3.2 Wizard (Dialog shadcn em fullscreen, 4 passos)

#### Passo 1 — Upload

```
┌─ Importar planilha FAM-0017 ───────────────────────── Passo 1 de 4 ─[ × ]─┐
│                                                                            │
│  ┌──────────────────────────────────────────────────────────────────────┐ │
│  │            📊  Arraste o arquivo .xlsx ou .xlsm aqui                 │ │
│  │                          ou clique para escolher                     │ │
│  │                                                                      │ │
│  │            Template oficial: FM 7.4.2.7 REV 9 (15.04.2026)           │ │
│  │            [⬇ Baixar template em branco]                             │ │
│  └──────────────────────────────────────────────────────────────────────┘ │
│                                                                            │
│  Aceitamos: REV 9 (atual) · REV 9 (09.04.2026 legado, com aviso)          │
│                                                                            │
│                                            [ Cancelar ]  [ Continuar → ]   │
└────────────────────────────────────────────────────────────────────────────┘
```

Comportamento:
- `react-dropzone`, accept `.xlsx,.xlsm`, max 25MB.
- Após drop: spinner "Analisando estrutura...".
- Detectar template:
  - Hash de cabeçalho da linha 1+2 + nome de aba.
  - **REV 9 v15.04** → badge verde "Template oficial detectado".
  - **REV 9 v09.04 (legado)** → badge amarelo "Template antigo — mapearemos automaticamente, revise no passo 2".
  - **Outro/desconhecido** → badge vermelho "Template não reconhecido — abriremos mapeamento manual no passo 2".
- Botão Continuar disabled enquanto análise não conclui.

#### Passo 2 — Preview + mapeamento de colunas

Tabela 2 colunas: **Coluna na planilha** | **Mapeada para campo do sistema** (Select por linha).

```
Coluna no Excel                       →   Campo no sistema
─────────────────────────────────────────────────────────────────
A — "ITEM"                            →   [Nº sequencial ▾]            ✓ auto
B — "CÓDIGO MP"                       →   [Código MP ▾]                ✓ auto
C — "PRODUTO"                         →   [Nome do produto ▾]          ✓ auto
D — "FABRICANTE/MANUFACTURER"         →   [Fabricante ▾]               ✓ auto
E — "ENDEREÇO FAB."                   →   [Endereço fabricante ▾]      ✓ auto
F — "FORNECEDOR/SUPPLIER"             →   [Fornecedor ▾]               ✓ auto
G — "ORIGEM/ORIGIN"                   →   [Origem ▾]                   ⚠ revisar
H — "RISCO"                           →   [— Ignorar coluna ▾]         ⚠ revisar
...
T — "REMARKS"                         →   [Observações ▾]              ✓ auto
```

Heurística de auto-mapeamento por similaridade (Levenshtein normalizado >0.8). Mapeamento manual fica em Select com todos os campos do sistema + opção "— Ignorar esta coluna".

Botão "Salvar este mapeamento como preset" (útil pra cliente que tem template fora-do-padrão e importa toda semana).

#### Passo 3 — Reconciliação (TELA MAIS IMPORTANTE DO WIZARD)

Diff visual em formato grid. Filtros no topo: `Todas (1.847) · Novas (+312) · Alteradas (~127) · Removidas (-43) · Conflitos (8)`.

```
┌─ Reconciliação ─────────────────────────────────── Passo 3 de 4 ─[ × ]─┐
│                                                                         │
│ [Todas (1.847)] [+ Novas 312] [~ Alteradas 127] [− Removidas 43]       │
│ [⚠ Conflitos 8]                          [Buscar...] [⚙ Aplicar a tudo]│
│                                                                         │
│ Sel Cód MP   Produto              Fabric.     Mudança          Ação    │
│ ─────────────────────────────────────────────────────────────────────── │
│ [✓] +MP-1042 Açafrão em pó       Casa Sabor  NOVA              [Aceitar▾]│
│ [✓] ~MP-0231 Lecitina de soja    Solae       Validade:                  │
│                                              03/26 → 12/27     [Aceitar▾]│
│ [ ] −MP-0098 Cacau alcalino      Barry C.    REMOVIDA          [Manter▾]│
│              ⚠ Em uso por Cert BR-FAM-2025-0123 (ativa)                 │
│ [✓] ⚠MP-0314 Goma xantana        Jungbun.    Conflito:                  │
│              Origem: MICROBIANA → MICROBIAL                             │
│              [✓ Aceitar valor importado] [Manter atual] [Resolver →]    │
│                                                                         │
│ Mostrando 1-25 de 482 itens com mudança             ◀ 1 2 3 ... 20 ▶  │
│                                                                         │
│ Resumo: 312 aceitar · 127 atualizar · 8 conflitos · 43 remover (1 bloq.)│
│                                                                         │
│                    [← Voltar]  [Aplicar a todos: Aceitar ▾]  [Continuar →]
└─────────────────────────────────────────────────────────────────────────┘
```

Códigos visuais:
- `+` verde — linha nova (não existe no sistema).
- `~` amarelo — linha alterada (mostrar "antes → depois" só dos campos que mudaram).
- `−` vermelho — existe no sistema, ausente no arquivo importado.
- `⚠` laranja — conflito (valor importado viola validação, ex.: origem fora do enum).

Por linha, dropdown de ação:
- **Nova**: Aceitar (default) / Pular.
- **Alterada**: Aceitar nova / Manter atual / Mesclar campo a campo (abre popover detalhado).
- **Removida**: Manter no sistema (default — segurança) / Marcar inativa / Excluir (só se não estiver em uso por Cert ativa).
- **Conflito**: dialog "Resolver" com 3 colunas (Atual / Importado / Resolução) — tipo merge resolver.

**Regra de segurança**: linha com `inUseByActiveCertification = true` NUNCA fica pré-marcada para exclusão. Banner vermelho na linha.

#### Passo 4 — Confirmação

```
┌─ Confirmação ─────────────────────────────────── Passo 4 de 4 ─[ × ]─┐
│                                                                       │
│ Resumo da importação:                                                 │
│   + 312 novos itens serão criados                                     │
│   ~ 124 itens serão atualizados                                       │
│   −  41 itens serão marcados como inativos                            │
│      6 conflitos resolvidos manualmente                               │
│      2 conflitos pulados                                              │
│                                                                       │
│ ⚠ A importação ficará registrada no histórico (passa a ser           │
│   revertível por 24h).                                                │
│                                                                       │
│ [ ] Notificar auditor FAMBRAS após commit (Maria Q. - maria@...)     │
│                                                                       │
│                          [← Voltar]  [Cancelar]  [Confirmar import ✓]│
└───────────────────────────────────────────────────────────────────────┘
```

Commit → progress bar (operação pode levar 10-30s para 2k linhas) → toast + redirect para grid já filtrada por "Recém-importados".

### 3.3 Tratamentos especiais

#### Blocos multilinha (col N) na importação

Backend agrupa linhas por (`códigoMP`, `manufacturer`, `supplier`, `halalCert#`). Linhas com chave igual e apenas col N preenchida = produtos finais filhos. Resultado: 1 RawMaterial canônica com array `appliesToFinalProducts: string[]`.

UI no passo 3: chip "+3 produtos finais" na coluna Produto, expansível.

#### Mesmo MP, novo fornecedor

Não duplicar — criar segundo RawMaterialSupplier com mesmo `códigoMP` mas chave composta diferente. UI sinaliza no passo 3: `+MP-0231 (3º fornecedor)`.

#### Violação de picklist (Origin com typo "VEGETBLE/VEGETAL")

- Backend tenta fuzzy match contra enum. Confiança ≥0.85 → auto-mapeia + flag `wasFuzzyMatched`.
- Confiança <0.85 → entra em "Conflitos" no passo 3 com dropdown "Você quis dizer: VEGETABLE/VEGETAL? [Sim] [Outro: ▾]".

#### Fuzzy match contra Manufacturer/Supplier existentes

Quando importar `"Solae Brasil"` e sistema tem `"Solae do Brasil Ltda"`:
- Mostrar inline no passo 3: `Fabricante: "Solae Brasil" ≈ "Solae do Brasil Ltda" (94%) [✓ Vincular] [Criar novo]`.
- Threshold ≥80% mostra sugestão, ≥95% pré-marca como aceitar.
- Permitir override individual ou bulk ("aplicar todas sugestões >90%").

#### Match com Intermediárias FAMBRAS

Se `códigoMP` começa com `9` E está no catálogo `PreApprovedIntermediateMaterial`: badge `🏷 Pré-aprovada FAMBRAS — dispensa anexo de cert`. Linha entra como nova mas com `halalCertified = N/A (aprovado por catálogo)` automaticamente.

#### Histórico de imports

No header da página (ao lado de "Importar"), botão `Histórico ▾` abre popover com últimas 10 importações: data, autor, arquivo, +/~/-, status (committed/reverted/failed), ação "Ver detalhes" (abre dialog read-only do diff) ou "Reverter" (se ≤24h e não foi sobrescrita).

---

## 4. Aba "Intermediários Pré-aprovados FAMBRAS"

### 4.1 Modo cliente (read-only)

```
┌─ Intermediários Pré-aprovados pela FAMBRAS ──────────────────────────────┐
│                                                                           │
│ ℹ Estas 231 matérias-primas são pré-aprovadas pela FAMBRAS.              │
│   Se você usa qualquer uma destas, basta selecioná-la na sua planilha    │
│   — não é necessário anexar certificado halal individual.                │
│                                                                           │
│ [Buscar por código ou nome...]                          [⬇ Exportar PDF] │
│                                                                           │
│ Código    Nome                                Categoria      Validade FAM│
│ ──────────────────────────────────────────────────────────────────────── │
│ 9-0001    Açúcar cristal                      Açúcares       12/2027    │
│ 9-0014    Bicarbonato de sódio                Aditivos       12/2027    │
│ 9-0042    Lecitina de soja (refinada)         Emulsificantes 06/2027    │
│ ...                                                                       │
│                                                                           │
│ Mostrando 1-50 de 231                                ◀ 1 2 3 4 5 ▶      │
└───────────────────────────────────────────────────────────────────────────┘
```

- Tabela 100% read-only (não shadcn `<Select disabled>` — apenas células de texto).
- Busca client-side (lista de 231 é pequena).
- Paginação client-side 50/pg (não vale virtual scroll aqui).
- Botão "Adicionar à minha planilha" por linha → abre drawer pré-populado, salva como novo RawMaterial na aba MP.
- **Sem edição** para role `empresa`. Tooltip educativo no hover do header: "Apenas a equipe FAMBRAS pode editar este catálogo".

### 4.2 Modo gestor FAMBRAS (CRUD)

Acesso por rota separada `/admin/catalogos/intermediarias` (hub de catálogos administrativos, fora desta U7). A aba aqui na U7 mostra um link discreto no header: `🛠 Gerenciar catálogo (FAMBRAS)` visível apenas para roles `auditor|analista|gestor|admin`.

---

## 5. Aba "Outros Insumos"

Grid simpler — sem multilinha, sem cert halal, 6 colunas:

| Categoria (chip) | Nome genérico | Nome comercial | Fabricante | Fornecedor | Obs |
|---|---|---|---|---|---|

Chips coloridos por categoria (paleta OKLCH consistente com tokens do projeto):
- **WATER TREATMENT** — azul claro
- **PACKAGING** — âmbar
- **CLEANING** — verde
- **LUBRICANTS** — laranja
- **PEST CONTROL** — rosa (atenção: cor diferente de erro!)
- **INKS/STAMPS/SOLVENTS** — roxo

Mesmas mecânicas:
- Virtual scroll (raramente >500 linhas, mas mantém consistência).
- Inline edit em todas as células (são strings simples + categoria Select).
- Bulk: mudar categoria, exportar, inativar.
- Import via mesmo wizard, escolhendo "Outros Insumos" no passo 1 antes do upload (radio: MP & Insumos / Outros / Detectar automaticamente).

Sem coluna Halal — mas com regra: se a categoria for `CLEANING` ou `LUBRICANTS`, mostrar ícone ⚠ na linha lembrando "Verificar se há contato com produto final — pode exigir laudo halal".

---

## 6. Notificações e gates

### 6.1 Banner vencimento (topo, antes das tabs)

Aparece se `count(certHalal expirando em ≤30d) > 0`:

```
⚠  12 certificados halal vencem nos próximos 30 dias.  [Ver lista filtrada →]
```

Cor: `bg-amber-50 dark:bg-amber-950 border-amber-300`. Botão filtra grid + ativa o chip "Vence em 30d".

Variante crítica (≥1 cert já vencida):
```
🔴  3 certificados halal estão VENCIDOS. Ação imediata necessária.  [Ver →]
```

### 6.2 Gate no wizard de Certification

Quando usuário tenta avançar passo "Documentação" do wizard NewCertificationRequest **sem** ter ≥10 linhas preenchidas na planilha MP (heurística simples):

- Modal de aviso: "Sua planilha de MP tem apenas 4 itens — recomendamos preencher antes de submeter. Continuar mesmo assim?"
- Botão `[Voltar e preencher planilha]` (default) | `[Continuar mesmo assim]`.
- **Não bloqueia hard** — algumas certs C3/C4 têm escopo pequeno legítimo. Apenas aviso.

Hard block apenas quando: 0 linhas preenchidas E tipo certificação ∈ {C1, C2} (abate/processamento — não faz sentido sem MP).

### 6.3 Empty state inicial

Primeira vez que entra na rota e a planilha está vazia:

```
┌──────────────────────────────────────────────────────────────────────────┐
│                                                                          │
│                         📋  Nenhuma MP cadastrada ainda                  │
│                                                                          │
│              Comece importando sua planilha FAM-0017 existente,          │
│              ou crie itens manualmente um por um.                        │
│                                                                          │
│              ┌─────────────────────┐  ┌─────────────────────┐           │
│              │ ⬆  Importar Excel   │  │ ＋ Criar manualmente │           │
│              │   (recomendado)     │  │                      │           │
│              └─────────────────────┘  └─────────────────────┘           │
│                                                                          │
│              ⬇ Baixar template em branco FM 7.4.2.7 REV 9               │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘
```

Após import, manter "dica do dia" (dismissible) na primeira sessão: "Você pode editar qualquer célula clicando duas vezes. Use ☑ para ações em lote."

---

## 7. Integração com SupplierHomologation existente

> **Decisão PO #4:** `SupplierHomologation` é disparado **exclusivamente pelo wizard de Certification**. A grid U7 reflete status e dá visibilidade do histórico, mas não inicia novos pedidos.

### 7.1 Status refletido na grid

Coluna **Status FAMBRAS** mostra badge do último `SupplierHomologation.status` daquela linha (matching por `certificationId + supplierName + materialName`). Clique no badge abre **drawer "Histórico de Homologação"** lateral com:

- Timeline de eventos (solicitado → docs enviados → em análise → aprovado/reprovado).
- Lista de docs anexados (links para download).
- Notas do auditor.
- Botão "Reabrir caso" (se reprovado, permite nova rodada com novos docs).

### 7.2 Fluxo aprovação do auditor (fora desta U7)

Auditor FAMBRAS continua aprovando via `/homologacao-mp/fila` (renomeação da tela atual). Quando aprova, status volta refletido no badge da grid U7 — usar `queryClient.invalidateQueries({ queryKey: ['raw-materials'] })` no callback de aprovação.

---

## 7-bis. Histórico de Edições (drawer ISO 17065) — decisão PO #7 / Opção C

Toda mutação em modelo participante do `RevisionLog` é auditável. Pela ótica de UX:

### 7-bis.1 Acesso

- **Por linha:** kebab `⋮` → "Histórico de edições" → abre drawer lateral com timeline.
- **Bulk:** se múltiplas linhas selecionadas, oferece "Exportar histórico (.pdf)" no menu de bulk (responde pedido de auditor externo sem fricção).
- **Por sessão de import:** popover "Histórico de Imports" no header já lista cada commit; clique em qualquer item navega para drawer agregado mostrando todas as linhas afetadas naquele import.

### 7-bis.2 Layout do drawer

```
┌─ Histórico de Edições — MP-0231 Lecitina de soja ────────────[ × ]─┐
│ [Apenas mudanças críticas ☐]  [Exportar PDF]      v12 atual         │
│ ─────────────────────────────────────────────────────────────────── │
│                                                                      │
│ ● v12  2026-05-24 14:32  Ana Costa (cliente)                        │
│   ⤷ atualizou Validade da cert halal: 03/2026 → 12/2027            │
│   ⤷ Razão: "renovação anual do certificado HCS"                    │
│   [Ver snapshot] [Reverter para esta versão]                        │
│                                                                      │
│ ● v11  2026-05-20 09:14  Sistema (import FAM-0017 sessão #4821)     │
│   ⤷ atualizou 3 campos: Cert nº, Fabricante endereço, Embalagem    │
│   [Ver diff completo]                                                │
│                                                                      │
│ ● v10  2026-05-15 16:08  Maria Q. (FAMBRAS qualidade)               │
│   ⤷ aprovou: Status FAMBRAS = aprovado                              │
│   ⤷ "Cert HCS validada cross-reference IFANCA"                      │
│                                                                      │
│ ● v1   2026-03-12 11:00  Ana Costa (cliente)                        │
│   ⤷ criou linha                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### 7-bis.3 Mecânica de Reverter

- Clica **"Reverter para esta versão"** → dialog obrigatório pedindo `reason: String` (campo `RevisionLog.reason`).
- Validação anti-conflito: se houve mutações posteriores em **outras linhas relacionadas** (ex.: a cert vinculada foi sobrescrita), exibe warning "Esta reverso pode quebrar consistência: a cert halal v3 foi referenciada por X outros itens."
- Confirma → backend `POST /entities/CompanyRawMaterial/:id/revert?toVersion=N` → cria nova versão (v13) idêntica à v10 com `mutationType=restore reason="<texto>"`.
- **Não destrói versões intermediárias** — auditor sempre vê o histórico completo, inclusive os "errôneos revertidos".

### 7-bis.4 Reverter import inteiro

Acessível via **Histórico de Imports** (popover do header):

```
┌─ Histórico de Imports ───────────────────────────────────────[ × ]─┐
│                                                                      │
│ #4821  2026-05-20 09:14  planilha_FAM-0017_v15-04.xlsx              │
│        Ana Costa  ·  +312 ~127 −43  ·  ✓ committed                 │
│        [Ver diff] [Reverter] [Exportar PDF]                          │
│                                                                      │
│ #4798  2026-05-18 14:30  planilha_emergencia.xlsx                   │
│        Ana Costa  ·  +4 ~12 −0  ·  ⏮ revertido por Maria Q.        │
│        [Ver diff] [— revertido —]                                    │
│                                                                      │
│ #4801  2026-05-19 10:02  planilha_emergencia_v2.xlsx                │
│        Maria Q.   ·  +4 ~12 −0  ·  ✓ committed                     │
│        [Ver diff] [Reverter] [Exportar PDF]                          │
└─────────────────────────────────────────────────────────────────────┘
```

Botão **Reverter** dispara `POST /imports/:sessionId/revert` com confirmação. Backend valida conflitos (mutações posteriores nas mesmas linhas) e exibe lista do que precisa "revert + replay manual" antes de seguir.

### 7-bis.5 Suporte a "FABRICANTE OCULTO" / NDA (descoberta da planilha real)

A planilha real do cliente tem **328 linhas com "FABRICANTE OCULTO" / "FORNECEDOR OCULTO"** (NDA com cliente final). Suporte:

- Linha pode marcar fabricante como **`approvalStatus=anonymous`** — UI mostra chip cinza "🔒 Anônimo (NDA)".
- Cliente preenche metadados internos (notes privadas) que só ele vê; FAMBRAS vê estatística mas não detalhes.
- Auditor externo recebe relatório anonimizado por default; sob solicitação formal + autorização do cliente, FAMBRAS pode desbloquear caso a caso.

---

## 7-ter. Admin hubs — catálogos globais FAMBRAS (decisão PO #6)

Rota base `/admin/catalogos/` — visível só para roles `qualidade | admin`.

| Sub-rota | Catálogo | Volume esperado | Workflow |
|---|---|---|---|
| `/admin/catalogos/raw-material-masters` | `RawMaterialMaster` (~2k MPs canônicas) | Cresce com imports | `pending → approved`, fusão de duplicatas |
| `/admin/catalogos/manufacturers` | `Manufacturer` global (~6-8k) | Cresce com imports | `pending → approved`, fusão, suporte a `anonymous` |
| `/admin/catalogos/halal-certifying-bodies` | `HalalCertifyingBody` (~40-100) | Estável | Curadoria manual de aliases e `recognitionStatus` |
| `/admin/catalogos/intermediarias` | `PreApprovedIntermediateMaterial` (~231 inicial, cresce) | Cresce manualmente | CRUD direto |

**Padrão de UI dos 4 hubs:**
- Grid com filtro por `approvalStatus`, busca por nome/alias, ordenação por `createdAt desc` (novos primeiro).
- Linha em `pending` → destaque amarelo + botão de ação "Aprovar / Rejeitar / Fundir com…" inline.
- Fusão de duplicatas: drawer com lista de candidatos (similarity > 80%) + radio "manter A / manter B / fundir em nova canônica" + campo razão.
- Mesmo drawer de **Histórico de Edições** (§7-bis) reutilizado.
- Export CSV/PDF do catálogo inteiro para envio a acreditadores externos.

---

## 8. Mockups ASCII

### 8.1 Grid principal MP & Insumos com filtros e bulk action bar

```
┌─ Empresa › Indústria Halal Sabor › Planilha MP & Fornecedores ────────────────────────────────────────────────────────┐
│  Cert: [BR-FAM-2025-0123  Indústria Halal Sabor SA ▾]            Salvo há 4s     [⬇ Exportar] [📜 Histórico] [⬆ Import]│
│                                                                                                                          │
│  ⚠ 12 certificados halal vencem nos próximos 30 dias.  [Ver lista filtrada →]                                          │
│                                                                                                                          │
│  [ MP & Insumos (2.317) ]  [ Outros Insumos (84) ]  [ Intermediários Pré-aprovados (231) ]                              │
│  ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────  │
│  [Buscar código, produto, fornecedor...] [Categoria ▾] [Status ▾] [Origem ▾] [Cert ▾] [⚠ Só pendências] [Colunas ⚙]   │
│                                                                                                                          │
│  Mostrando 47 de 2.317                                                                          [+ Nova MP]            │
│                                                                                                                          │
│  ┌─────┬──────┬─────────┬──────────────────────┬───────────────────────┬──────────┬───────────┬──────────────┬───┐    │
│  │ ☐   │ Nº   │ Cód MP  │ Produto              │ Fab. / Fornecedor     │ Cert Hal │ Validade  │ Status FAMBR │   │    │
│  ├─────┼──────┼─────────┼──────────────────────┼───────────────────────┼──────────┼───────────┼──────────────┼───┤    │
│  │ ☑   │  012 │ MP-0042 │ Lecitina de soja  +3 │ Solae do Brasil Ltda  │ ● SIM    │ 12/2027   │ ✓ Aprovado   │ ⋮ │    │
│  │     │      │         │                      │ Solae Brasil          │          │           │              │   │    │
│  │ ☑   │  013 │ MP-0098 │ Açafrão em pó        │ Casa do Sabor Ltda    │ ◐ PEND.  │     —     │ ⏳ Em análise│ ⋮ │    │
│  │     │      │         │                      │ Distrib. Spice Co     │          │           │              │   │    │
│  │ ☐   │  014 │ MP-0231 │ Goma xantana      +1 │ Jungbunzlauer Suisse  │ ● SIM    │ 03/2026⚠  │ ✓ Aprovado   │ ⋮ │    │
│  │     │      │         │                      │ Importadora Multi BR  │          │ (em 28d)  │              │   │    │
│  │ ☐   │  015 │ MP-0314 │ Cacau alcalino       │ Barry Callebaut       │ ● SIM    │ 08/2028   │ ⚪ Rascunho  │ ⋮ │    │
│  │     │      │         │                      │ Callebaut Brasil      │          │           │              │   │    │
│  │ ☐   │  016 │ 9-0042  │ Lecitina (interm)🏷  │ —                     │ N/A      │     —     │ ✓ Pré-aprov. │ ⋮ │    │
│  │ ⚠   │  017 │ MP-0418 │ Gelatina bovina      │ Gelita do Brasil      │ ● SIM    │ 11/2025❌ │ ✗ Reprovado  │ ⋮ │    │
│  │     │      │         │ ⚠ Cert vencida — atualizar urgente              VENCIDA  │              │   │    │
│  └─────┴──────┴─────────┴──────────────────────┴───────────────────────┴──────────┴───────────┴──────────────┴───┘    │
│                                                                                                                          │
│  ┌─ 2 linhas selecionadas ────────────────────────────────────────────────────────────────────────────────────┐         │
│  │ [Solicitar homologação] [Reaplicar fornecedor ▾] [Marcar inativo] [Exportar ⬇] [Anexar mesmo doc] [✕]    │         │
│  └────────────────────────────────────────────────────────────────────────────────────────────────────────────┘         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

### 8.2 Passo 3 do import — Reconciliação visual

```
┌─ Importar planilha FAM-0017 ──────────────────────────────────────────── Passo 3 de 4 ─────[ × ]─┐
│                                                                                                    │
│  Arquivo: planilha_FAM-0017_halal_sabor_v15-04.xlsx  (487 KB)              ✓ REV 9 v15.04.2026   │
│                                                                                                    │
│  [Todas (1.847)]  [+ Novas (312)]  [~ Alteradas (127)]  [− Removidas (43)]  [⚠ Conflitos (8)]   │
│  ────────────────────────────────────────────────────────────────────────────────────────────────  │
│  [Buscar...]                          [⚙ Aplicar em lote: Aceitar todas as alterações ▾]         │
│                                                                                                    │
│  Sel  Cód MP    Produto             Mudança                                        Decisão        │
│  ──── ────────  ──────────────────  ──────────────────────────────────────────────  ──────────────│
│  [✓] +MP-1042   Açafrão em pó       NOVA                                          [Aceitar ▾]   │
│       Fab: Casa do Sabor · Fornec: Distrib. Spice · Cert: SIM (12/2027)                          │
│                                                                                                    │
│  [✓] ~MP-0231   Lecitina de soja    Validade:  03/2026  →  12/2027                [Aceitar ▾]   │
│                                      Cert nº:   HCS-2024 → HCS-2025-449                          │
│                                                                                                    │
│  [✓] ~MP-0418   Gelatina bovina     Fornec:    Gelita BR → Gelita do Brasil S/A   [Mesclar ▾]   │
│                                      ≈ 92% similar com fornecedor existente                       │
│                                                                                                    │
│  [ ] −MP-0098   Cacau alcalino      REMOVIDA da planilha                          [Manter ▾]    │
│       🔴 EM USO por Cert BR-FAM-2025-0123 (ativa) — não pode ser excluída                         │
│       Opção sugerida: marcar como inativa após renovação                                          │
│                                                                                                    │
│  [✓] ⚠MP-0314   Goma xantana        CONFLITO: Origem                              [Resolver →]  │
│                  Atual: MICROBIANA                                                                │
│                  Importado: MICROBIAL  (≈ 96% match com MICROBIAL/MICROBIANA)                    │
│                  [ ✓ Aceitar valor importado mapeado ]  [ Manter atual ]                         │
│                                                                                                    │
│  [✓] +MP-1208   Óleo de palma RBD   NOVA  🏷 Pré-aprovada FAMBRAS (9-0078)                       │
│                  ℹ Será criada com Cert Halal = N/A (intermediária pré-aprovada)                 │
│                                                                                                    │
│  Mostrando 1-25 de 482 com mudança                                       ◀  1  2  3 ... 20  ▶   │
│                                                                                                    │
│  Resumo:  312 novas (aceitar) · 124 atualizar · 8 conflitos · 41 inativar · 2 bloqueadas         │
│                                                                                                    │
│                                          [← Voltar]  [Aplicar a tudo: Aceitar ▾]  [Continuar →]  │
└────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 9. Decisões PO já tomadas + perguntas residuais

**Resolvidas (2026-05-25):** 1 (Certification), 4 (só wizard), 6 (CRUD admin desde início), 7 (Opção C — RevisionLog), 8 (2 caminhos completos sem MVP). Detalhe no doc resumo executivo.

**Perguntas residuais (não bloqueantes; resolver na implementação):**

1. **`itemNumber` (col A) — auto-incremento por Company?** Recomendação: sim, sequence per-Company. Persistir mesmo após reordenação no Excel exportado.
2. **Threshold do matching de import (fuzzy):** 80% sugere, 95% pré-marca aceitar. Calibrar com base nos primeiros imports reais.
3. **Quem aprova `Manufacturer pending`?** Role `qualidade`. SLA: 2 dias úteis? Notificação automática?
4. **Política de retenção de partições `revision_logs`:** 24 meses online — confirma? E arquivamento em S3 Glacier (custo trivial)?

---

## 10. Anti-padrões a evitar

1. **Cada célula = 1 request HTTP**: matar autosave síncrono por keystroke. Sempre debounce 800ms + single-flight por linha com AbortController. Senão a planilha vira DDoS no backend a cada digitação.

2. **`<Select disabled>` em modo view-only**: memória `feedback_select_disabled_em_view_only` — race do Radix entre disabled e portal montagem provoca flicker e onValueChange fantasma. Em qualquer célula read-only (intermediárias FAMBRAS, status aprovado pelo auditor), renderizar **`<div>` plano com classes de Badge/Chip**, nunca `<Select disabled>`.

3. **Cache TanStack Query agressivo**: memória `project_sih_cache_stale_bug` lembra do bug em listas onde edições não apareciam por `staleTime: Infinity`. Para esta planilha usar `staleTime: 30_000` no máximo + `invalidateQueries(['raw-materials', certId])` no `onSuccess` de toda mutação. E o drawer fechar deve dar refetch garantido (`refetchOnWindowFocus: true`).

4. **Termos haram em mocks/exemplos**: memória `feedback_halal_no_haram_terms`. Toda a UI (placeholders, exemplos, dados de teste, screenshots de documentação) usa apenas: gelatina bovina, lecitina de soja, ácido cítrico, açafrão, palma, cacau, leite em pó, goma xantana, bicarbonato, glucose. Nunca porco, presunto, vinho, álcool etc. — mesmo "como exemplo do que NÃO entra".

5. **Virtualizar e perder accessibility**: virtual scroll naive quebra `Ctrl+F`, screen reader e tab order. Implementar com `aria-rowcount`/`aria-rowindex` corretos, manter focus dentro do row mesmo se ele sai da viewport (não destruir DOM enquanto está focado — usar `overscan` + foco rastreado), e oferecer fallback "Modo lista plana (acessível)" no menu de Colunas.

6. **Excel parsing client-side como source of truth**: navegador resolve floats e datas Excel diferente do backend. Sempre que o cliente fizer parse leve para preview, deixar claro "preview aproximado — backend valida". Commit só após backend devolver `ImportSession` validada. Senão diff visual diverge do que realmente vai ser salvo → desastre de confiança.

7. **Bulk operations sem confirmação "undo"**: "Marcar 47 itens como inativos" sem undo gera ticket de suporte garantido. Toast sonner com action "Desfazer" por 10s + endpoint reverso são obrigatórios.

---

## 11. Roteiro de implementação sugerido (sequência)

Apenas indicativo para PO/Tech Lead — não é parte do spec UX:

1. Backend: migrations `revision_logs` particionada + interceptor Nest + 11 modelos novos (ver [-SCHEMA.md](PLANILHA-MP-FORNECEDORES-FAM-0017-SCHEMA.md)).
2. Seeds: `HalalCertifyingBody` curado + `PreApprovedIntermediateMaterial` (231 itens).
3. Frontend: scaffold rota `/homologacao-mp` reformada + 3 abas + breadcrumb + seletor de certificação.
4. Aba MP&Insumos: grid virtual + filtros + busca (read-only primeira passada).
5. Inline edit dos 4 campos quick-win (Cert Halal, Validade, Risco, Status).
6. Drawer de edição completa + validação zod + autosave + **drawer "Histórico de Edições"** consumindo `RevisionLog`.
7. Aba Intermediárias (read-only para cliente).
8. Aba Outros Insumos.
9. Wizard de import — passos 1, 2, 4 (sem reconciliação).
10. Wizard passo 3 — reconciliação visual (a parte mais complexa).
11. Bulk actions, banner vencimento, gate no wizard de Cert.
12. Integração com `SupplierHomologation` (drawer histórico read-only — sem disparo).
13. Histórico de imports + reverter por sessão (`POST /imports/:id/revert`).
14. Admin hubs `/admin/catalogos/*` (4 telas: RawMaterialMaster, Manufacturer, HalalCertifyingBody, Intermediárias) com workflow `pending → approved` + fusão de duplicatas.

**Estimativa revisada:** ~4 semanas dev consolidado (era 3, +1 por causa de RevisionLog + admin hubs + drawer Histórico).

---

## 12. Métricas de sucesso (post-launch)

- Tempo médio para preencher 100 MPs (importadas vs. manuais).
- % de imports que precisam de >1 tentativa.
- % de conflitos resolvidos vs. pulados.
- % de homologações disparadas da grid (vs. via wizard de Cert).
- Bugs reportados de "minha edição sumiu" (alvo: 0 — sinal direto de bug de cache).
