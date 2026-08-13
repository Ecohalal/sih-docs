# CTR-02 fase 2 — saldo por ITEM nas produções com produtos em Json

> **Status: SPEC. Nada implementado.** Escrita em 13/ago/2026 a pedido do Renato ("só spec, plano passo a passo").
> Repositórios: `sih-backend` + `sih-frontend` (Trilha D · SIH).
> Precede: **CTR-02 fase 1**, em produção desde 12/ago — back `5571e0f` · front `a8f0d23`.
> Origem: GAP-3 de 14/jun · achado CTR-02 do presencial (§5-C do `PRESENCIAL-FAMBRAS-2026-08-10-14`).

---

## 0. O enunciado do handoff está errado em dois pontos

O §7-Y descreve esta fase como *"saldo por item nos tipos com produtos em Json (raspa, tripas, gelatina)"*.
Lendo os 10 tipos de produção um a um, **a lista está errada nas duas pontas**:

- **`gelatina` NÃO é multi-produto.** Ela guarda `customFields.finalProduct` — um **objeto singular**, com um lote e
  um peso ([`GelatinaFields.tsx:9-21`](../../sih-frontend/src/components/production-types/GelatinaFields.tsx#L9-L21)).
  Um relatório de gelatina = um produto. Ela não precisa de granularidade nova; precisa apenas de **um leitor**,
  porque hoje ninguém lê aquele objeto.
- **`fracionamento` é multi-produto e ficou de fora.** `customFields.outputProducts[]` é um array
  ([`FracionamentoFields.tsx`](../../sih-frontend/src/components/production-types/FracionamentoFields.tsx)) — mesmo
  problema de raspa e tripas.

Isso muda o desenho: o eixo que importa **não é "Json × coluna"**, é **"quantos produtos finais o relatório tem"**.
Um tipo com um produto em Json (gelatina, heparina) resolve-se com um leitor; só os de **array** exigem chave por item.

---

## 1. Onde a fase 1 parou (fatos medidos no código)

| Peça | Onde | O que faz |
|---|---|---|
| `computeShipmentBalance` | [`shipment-balance.util.ts:33`](../../sih-backend/src/common/utils/shipment-balance.util.ts#L33) | `produzido − Σ consumido`, tolerância 1 g, nunca devolve negativo. `consumedKg == null` = consumo total |
| `consumedNetWeightKg` | [`schema.prisma:666`](../../sih-backend/prisma/schema.prisma#L666) | quantidade **por vínculo**, em `ShippingReportSource` |
| `GET /production-reports/pending-shipment` | [`production-report.service.ts:38`](../../sih-backend/src/production-report/production-report.service.ts#L38) | produções assinadas com saldo > 0 |
| `POST /shipping-reports/derive-composition` | [`shipping-report.controller.ts:70`](../../sih-backend/src/shipping-report/shipping-report.controller.ts#L70) | prévia da composição sem relatório salvo |
| Trava de sobre-consumo | `overConsumedKg`, na **assinatura** do embarque | recusa com o excedente em kg |

A premissa declarada da fase 1 está no comentário do helper: *"cada relatório de produção já é um produto com lote
próprio nos campos escalares, então o saldo por relatório **é** o saldo por produto/lote **nos tipos com produto em
coluna**"*. A ressalva final é exatamente o escopo desta fase 2.

---

## 2. O problema, medido — e por que ele é silencioso

### 2.1 O bloco de produção só existe para `fabricacao`

[`ProductionReportForm.tsx:973-974`](../../sih-frontend/src/pages/production/ProductionReportForm.tsx#L973-L974):

```tsx
{/* Produção — somente fabricacao */}
{isStandardForm && <Card>
```

Esse card contém `productBatch`, `totalProduced`, `packageType`, `packageCount`, **`netWeightKg`** e `grossWeightKg`.
Para os **9 outros tipos** ele nunca é renderizado ⇒ **`production_reports.net_weight_kg` fica NULL**. A única coluna
escalar que sobrevive é `productName`, e ainda assim preenchida por
[`getDefaultProductName`](../../sih-backend/src/common/utils/production-validation.util.ts#L120) com um **rótulo
genérico** ("Couro/Raspa/Apara", "Gelatina") quando o tipo está em `TYPES_WITHOUT_PRODUCT_NAME`.

### 2.2 `deriveComposition` nunca abre o `customFields`

[`shipping-report.service.ts:165-188`](../../sih-backend/src/shipping-report/shipping-report.service.ts#L165-L188)
monta **um produto por relatório**, lendo só escalares: `productName`, `productCode`, `productBatch`, `netWeightKg`,
`totalProduced`. A palavra `customFields` **não aparece uma vez** no módulo de embarque.

### 2.3 A cadeia de consequências

Com `netWeightKg = NULL`, tudo degrada — e nada reclama:

| # | Efeito | Onde |
|---|---|---|
| 1 | A linha da composição do embarque sai com **peso e lote nulos**, e nome genérico | `deriveComposition` |
| 2 | `totalWeightKg` da composição **soma 0** para esses relatórios | `shipping-report.service.ts:222` |
| 3 | `computeShipmentBalance(null, …)` ⇒ produzido 0, saldo 0, **`fullyShipped: true`** | helper |
| 4 | 🔴 **Basta 1 vínculo e a produção some da tela de pendências** — mesmo tendo embarcado 1 de 5 produtos | filtro `p.balanceKg > 0 \|\| (p.shipments.length === 0 && !p.netWeightKg)` ([linha 115](../../sih-backend/src/production-report/production-report.service.ts#L115)) |
| 5 | A trava de sobre-consumo **é pulada**: `if (production.netWeightKg === null) continue` | assinatura do embarque |

O item **4 é o mais grave**, e é o oposto do objetivo declarado da tela. A fase 1 já se defendeu do caso "nunca
embarcado" (por isso o `|| shipments.length === 0`), mas a partir do **primeiro** vínculo o relatório desaparece do
radar de quem cobra a entrega — sem aviso, sem badge, sem linha na tela.

O item **5 é degradação segura, não bug vivo**: pular a trava evita bloquear indevidamente uma assinatura. Não há,
hoje, falso positivo em produção — há **ausência de controle**.

---

## 3. Inventário dos 10 tipos — onde mora o produto final

| Tipo | Onde está o produto final | Qtd | Peso do item | Grupo |
|---|---|---|---|---|
| `fabricacao` | colunas escalares | 1 | `netWeightKg` | **A** |
| `raspa` | `customFields.finalProducts[]` | **N** | `netWeight` | **B** |
| `tripas` | `customFields.finalProducts[]` | **N** | `netWeight` | **B** |
| `fracionamento` | `customFields.outputProducts[]` | **N** | *(conferir colunas)* | **B** |
| `gelatina` | `customFields.finalProduct` (objeto) | 1 | `netWeight` | **C** |
| `heparina_bruta` | `customFields.finalProduct` (objeto) | 1 | `netWeight` | **C** |
| `heparina_purificacao` | `customFields.finalProduct` (objeto) | 1 | `netWeight` | **C** |
| `couro` | `customFields.netWeightKg` (escalar no Json) | 1 | `netWeightKg` | **C** ⚠️ |
| `mucosa` | `customFields.totalProduced` + `dailyLog[]` | 1 agregado | `totalProduced` | **D** |
| `desossa` | `customFields.origins[]` (carcaças de entrada) | — | — | **E** |

- **A** — já resolvido pela fase 1.
- **B** — **o alvo real desta spec**: exigem chave por item.
- **C** — um produto por relatório: resolvem-se **só com um leitor**, sem mudar granularidade. ⚠️ `couro` é
  **transferência** (tem `recipient`, `transferDate`, `sanitaryDocNumber`), não embarque de exportação — confirmar se
  entra no fluxo de embarque antes de incluí-lo.
- **D** — `mucosa` é **log diário sem lote**: tem quantidade total, não tem produto identificável. Saldo por
  relatório funciona; saldo por item não faz sentido.
- **E** — `desossa` registra **origens de entrada** (bandas/meia-carcaças), não produto final embarcável. **Fora do
  escopo**; se a sala quiser desossa embarcável, isso é modelagem nova, não fase 2.

---

## 4. As duas decisões de desenho

### 4.1 A chave primária não comporta dois itens do mesmo relatório

[`schema.prisma:672`](../../sih-backend/prisma/schema.prisma#L672):

```prisma
@@id([shippingReportId, sourceType, sourceReportId])
```

Um embarque **não consegue** ter duas linhas do mesmo relatório de produção. Saldo por item exige mudar isso.

| | Opção **A — estender a PK** | Opção **B — tabela filha** |
|---|---|---|
| Forma | `@@id([shippingReportId, sourceType, sourceReportId, sourceItemKey])`, com `''` = "o relatório inteiro" | `ShippingReportSourceItem` com FK para o vínculo + `itemKey` + `consumedNetWeightKg` |
| Migration | troca de PK (drop + add constraint) — **não é puramente aditiva** | `CREATE TABLE IF NOT EXISTS` — **aditiva** |
| Consumo mora em | **um lugar só** | **dois lugares** (pai e filho) |
| Compatibilidade | `sourceItemKey = ''` preserva **exatamente** a semântica dos vínculos atuais | preservada, mas com regra extra ("se há itens, ignore o pai") |
| Risco | proporcional ao nº de linhas da tabela | baixo |

**Recomendação: A**, condicionada ao tamanho da tabela. A opção B reintroduz **"duas fontes para o mesmo fato"** —
o padrão estrutural que este projeto já pagou em FRG-32, IND-04 e IND-14 (§7-Z). Trocar risco de migration por
ambiguidade permanente de modelo é mau negócio.

🔧 **Medir antes de decidir** (uma query, banco `db_ecohalal_sih`):

```sql
SELECT count(*) AS vinculos,
       count(*) FILTER (WHERE consumed_net_weight_kg IS NOT NULL) AS com_quantidade
  FROM shipping_report_sources;
```

A feature subiu em **12/ago**, e a M:N predecessora (`shipping_report_productions`) tinha **0 linhas** — a expectativa
é dezenas, não milhares. Se o número surpreender, **cair para B**.

### 4.2 O que identifica um item dentro do Json

**Boa notícia, já medida:** o editor **já carimba UUID em cada linha**.
[`EditableCardList.tsx:45`](../../sih-frontend/src/components/production-types/EditableCardList.tsx#L45):

```ts
const newRow: Record<string, unknown> = { id: crypto.randomUUID() };
```

E `updateRow`/`removeRow` operam **por `r.id`** — ou seja, uma linha sem `id` já estaria quebrada no próprio editor.
⇒ **`sourceItemKey` = `customFields.<coleção>[].id`.**

Por que **não** as alternativas:

- **Índice do array (`[0]`, `[1]`)** — o supervisor reordena ou remove uma linha e o vínculo passa a apontar para
  outro produto, **sem erro**. É o mesmo defeito do merge por UUID exportado stale: no-op silencioso, dado errado.
- **Lote + identificação** — chave natural legítima, mas **não é única** (dois lotes iguais em relatórios distintos são
  possíveis) e muda quando o supervisor corrige uma digitação, quebrando o vínculo.

🔧 **Verificar antes de F2.1**: se existem em produção linhas de `finalProducts`/`outputProducts` **sem `id`** (vindas
de seed, importação ou de antes desse comportamento). Se existirem, F2.1 precisa de um **backfill de `id`** no Json —
que é escrita em dado de produção e exige SQL revisado + OK explícito.

---

## 5. A peça central: um resolvedor de itens embarcáveis

Uma função pura, com um caso por tipo, que responde **"o que este relatório tem para embarcar?"**:

```ts
// sih-backend/src/common/utils/shippable-items.util.ts  (NOVO)
export interface ShippableItem {
  itemKey: string;        // '' para os tipos de 1 produto; UUID do Json para os de array
  label: string;          // o que o supervisor lê na tela
  batch: string | null;
  producedKg: number | null;
  packageType?: string | null;
  packageCount?: number | null;
}

export function resolveShippableItems(
  productionType: string,
  customFields: unknown,
  scalars: { productName: string | null; productBatch: string | null; netWeightKg: number | null; /* … */ },
): ShippableItem[];
```

Ela **subsome a fase 1** (`fabricacao` devolve 1 item com `itemKey: ''` a partir dos escalares) e é o único ponto do
sistema que precisa conhecer o formato de cada `customFields`. Três consumidores, hoje inconsistentes entre si,
passam a ler dela:

1. `deriveComposition` — **uma linha por item**, não por relatório
2. `findPendingShipment` — saldo por item
3. a trava de sobre-consumo da assinatura — por item

⚠️ **Sem esse resolvedor, os três lugares reimplementariam o mesmo `switch`** e divergiriam na primeira mudança de
formulário. Ele é o pré-requisito de tudo o que vem depois, e por isso é a primeira fatia.

---

## 6. Plano por fatias

> Cada fatia é commitável e verificável sozinha. **Nenhuma delas é autorizada a subir sem OK do Renato** —
> push em `release` é deploy.

### F2.1 · O resolvedor + testes *(sem efeito visível — é a fundação)*

**Faz:** `shippable-items.util.ts` com um caso por tipo do §3 e `shippable-items.spec.ts`.
**Arquivos:** `sih-backend/src/common/utils/shippable-items.util.{ts,spec.ts}` — **arquivos novos, zero colisão**.
**Pronto quando:** os casos de teste cobrirem (a) `fabricacao` a partir de escalares; (b) `raspa`/`tripas` com 3 itens;
(c) `gelatina`/`heparina` com objeto singular; (d) `customFields` **nulo, vazio ou malformado** ⇒ lista vazia, nunca
exceção — relatório antigo não pode derrubar a tela de embarque; (e) item **sem `id`** ⇒ decisão explícita e testada
(propor: excluir do saldo por item e sinalizar, jamais cair para índice).
**Risco:** nenhum. Nada consome ainda.

### F2.2 · Migration da granularidade

**Faz:** `sourceItemKey` na PK (opção A do §4.1), `DEFAULT ''`, idempotente, **nome mapeado** (`shipping_report_sources`).
**Antes:** rodar a query do §4.1 e registrar o resultado no commit.
**Pronto quando:** `migrate deploy` aplicar em base limpa **e** em cópia do prod; vínculos existentes continuarem com
`sourceItemKey = ''` e o saldo por relatório permanecer idêntico ao de hoje.
**Risco:** 🟡 troca de PK. Mitigação: medir antes, `BEGIN`/`COMMIT`, e um `SELECT` de conferência no mesmo commit.

### F2.3 · Back: saldo por item

**Faz:** `computeShipmentBalance` ganha variante por item; `findPendingShipment` devolve `items[]` com saldo próprio;
a trava da assinatura passa a comparar item a item (e o `continue` do `netWeightKg === null` sai — passa a valer
"sem peso **no item**").
**Arquivos:** `production-report.service.ts`, `shipping-report.service.ts`, `shipment-balance.util.ts`.
**Pronto quando:** um relatório de raspa com 3 produtos, com 1 deles embarcado, **continuar na lista de pendências**
com os outros 2 — que é exatamente o furo do §2.3 item 4.
⚠️ **Rota nova ⇒ regenerar swagger + os 3 JSONs do API Gateway no MESMO commit.** Se forem só campos novos em rotas
existentes, não há regen — **provar por `git diff`**, como a fase 1 fez, nunca por suposição.

### F2.4 · Back: composição item a item

**Faz:** `deriveComposition` emite uma linha por `ShippableItem`.
**Pronto quando:** a prévia de um embarque de tripas listar os N produtos com lote e peso próprios, e o
`totalWeightKg` deixar de ser 0.
⚠️ **Ponto de atenção:** `productionSnapshot` congela a composição na assinatura. Embarques **já assinados** guardam o
formato antigo — o leitor do snapshot precisa aceitar **os dois**, sob pena de quebrar a exibição de documento
histórico. Imutabilidade do documento assinado vale aqui como vale no certificado.

### F2.5 · Front: escolher e consumir por item

**Faz:** `LinkedSourcesField` passa a listar os itens dentro de cada fonte, com quantidade por item e o saldo ao lado
(o padrão que a fase 1 já criou por relatório); `PendingShipmentPage` mostra o detalhamento por produto/lote.
**Arquivos:** `sih-frontend/src/components/shipping-types/LinkedSourcesField.tsx`,
`sih-frontend/src/pages/production/PendingShipmentPage.tsx`.
**Pronto quando:** `tsc -b` limpo (**o script de build é `tsc -b && vite build`**) e o supervisor conseguir embarcar
2 dos 5 lotes de uma raspa, vendo o saldo dos 3 restantes.

### F2.6 · Validação de fora

Bundle servido contendo uma string nova e exclusiva; rota nova respondendo **404→401** (sonda que **distingue
versão** — a lição de 12/ago: `/production-reports/pending-shipment` dava 401 no código velho porque casava com
`:id`); migration com `finished_at` em `_prisma_migrations`.

---

## 7. Decisões que travam fatias

| # | Pergunta | Quem | Trava |
|---|---|---|---|
| 1 | **`couro` entra no fluxo de embarque?** Ele é transferência (`recipient`, `transferDate`) | Renato/FAMBRAS | o caso `couro` do resolvedor (F2.1) |
| 2 | **`mucosa` fica com saldo por relatório?** É log diário sem lote | Renato | idem |
| 3 | **`desossa` tem produto embarcável?** Hoje só registra origens de entrada | FAMBRAS | fora do escopo se "não" |
| 4 | **Item sem `id` no Json** (se existir em prod): backfill ou excluir do saldo por item? | Renato | F2.1(e) e possível carga de dados |
| 5 | **Opção A ou B** do §4.1 | decide a query do §4.1 | F2.2 |
| 6 | **`fracionamento`: quais colunas de `outputProducts`?** Não li o componente coluna a coluna | Claude (leitura) | o caso `fracionamento` (F2.1) |

---

## 8. O que esta fase **não** é

- **Não** é o cálculo do FM 7.1.9 (fase 2 daquele formulário) — assunto diferente, mesmo número de fase.
- **Não** mexe em `mucosa`/`desossa` sem as respostas 2 e 3.
- **Não** reescreve `productionSnapshot` de embarque assinado. Documento assinado é imutável; o leitor é que aceita
  os dois formatos.
- **Não** unifica os `customFields`. Padronizar os 10 formulários é reforma de modelo, com migração de dado real —
  não cabe na véspera do go-live, e o resolvedor do §5 existe justamente para **isolar** essa bagunça em um arquivo.

---

## 9. Nota de trilha (§2 do BACKLOG)

A **Trilha D · SIH** está declarada como `sih-backend/src/{auth,gc-integration}/` e
`sih-frontend/src/pages/{auth,gc-raw-materials}/`. **Nenhum** arquivo desta spec está nesse domínio — a declaração
ficou vencida. **Ampliar a Trilha D no §2 antes de abrir a primeira fatia**, senão duas sessões paralelas colidem
(já ocorreu em 16/jul). Domínio a declarar: `sih-backend/src/{production-report,shipping-report}/` +
`src/common/utils/{shipment-balance,shippable-items}.util.ts` · `sih-frontend/src/{components/shipping-types,pages/production}/`.
