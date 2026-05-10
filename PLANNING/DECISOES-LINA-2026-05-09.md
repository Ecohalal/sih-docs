# Decisões Lina (FAMBRAS) — pós-perguntas residuais

**Data resposta:** 2026-05-09
**Origem:** Resposta em vermelho ao e-mail [EMAIL-LINA-PERGUNTAS-RESIDUAIS-2026-05-07.md](EMAIL-LINA-PERGUNTAS-RESIDUAIS-2026-05-07.md)
**Status:** 6 de 6 destravadas (B.1 destravado pelo link OneDrive enviado pelo Fuad em paralelo)

---

## TL;DR

- **HAS** tem 2 estágios de revisão (analista superficial + auditor in loco), não 1.
- **Mercados** continuam granulares; tendência futura é agregar em "interno × exportação". Modelar flexível desde já com campo `marketCategory` opcional.
- **Laboratórios** mantidos pela role Qualidade; cliente só lê e escolhe.
- **Caso de amostra (B.1)**: pasta IFF-FAR no SharePoint da FAMBRAS (link enviado pelo Fuad).
- **IA matérias-primas** tem escopo bem mais simples do que parecia: 3 outputs (criticidade / origem animal / espécie). Sem fontes específicas — só prompt nosso via Claude/OpenAI.
- **Item crítico** é por **produto**, não por (produto × país). Exceções pontuais (carmim de cochonilha em Turquia, ZA, países do Golfo) ficam em tabela auxiliar.

---

## A.1. HAS — confirmado + bonus

**Pergunta:** HAS é elaborado pelo cliente e a FAMBRAS atua como revisora?

**Resposta da Lina:**
> Sim, o cliente envia por e-mail. **O analista faz uma análise superficial** (se há todos os tópicos obrigatórios) **e o auditor faz uma verificação mais profunda in loco**.

**Decisão de modelagem:**

| Campo | Tipo | Quando |
|---|---|---|
| `analystReviewedAt` | `DateTime?` | Após análise documental (checklist DT 7.3) |
| `analystReviewedBy` | `String?` (userId) | idem |
| `analystChecklistOk` | `Boolean?` | Tópicos obrigatórios estão presentes? |
| `analystNotes` | `String?` | Observações administrativas |
| `auditorReviewedAt` | `DateTime?` | Após auditoria estágio 2 in loco |
| `auditorReviewedBy` | `String?` (userId) | idem |
| `auditorFieldNotes` | `String?` | Verificação profunda do conteúdo |

**Impacto na Onda 3:** "HAS guiado" deixa de ser feature ambiciosa e vira "Revisor de HAS em 2 níveis" — UI de upload + checklist analista + notes auditor. Escopo bem menor.

---

## A.2. Mercados — confirmado + tendência futura

**Pergunta:** Cliente seleciona um ou mais mercados? Divisão "Golfo / sem Golfo" era simplificação?

**Resposta da Lina:**
> Correto. **Sim. Em breve pensamos em mudar para mercado interno e exportação. Porque antes apenas a norma do Golfo era mais rígida. Atualmente, os demais países também possuem normas auditáveis.**

**Decisão de modelagem:**

Manter `MarketScope 1:N` granular como planejado, **mas adicionar campo derivado** `marketCategory` na `Country` ou no `MarketScope`:

```prisma
enum MarketCategory {
  internal   // Brasil
  export     // Qualquer outro país
}

model Country {
  code           String         @id  // ISO-2: BR, AR, SA, AE, ID, MY, ...
  name           String
  marketCategory MarketCategory      // computed: BR=internal, demais=export
  // ...
}
```

A vista agregada (interno × exportação) é apenas uma view UI sobre os dados granulares. Quando a Lina decidir migrar oficialmente, é só trocar a UI default sem mexer no schema.

**Impacto na Onda 1+:** Item B (CountryHabilitation) e item L (MarketScope no wizard) já estão alinhados — nenhum redesign.

---

## A.3. Lista de laboratórios — confirmado, role definido

**Pergunta:** Lista fechada mantida pela FAMBRAS? Quem aprova inclusões?

**Resposta da Lina:**
> É uma lista que pode ser atualizada **pela Qualidade** e é compartilhada com o cliente para que façam orçamento e escolham o laboratório que utilizarão.

**Decisão de modelagem:**

```prisma
model Laboratory {
  id                   String   @id @default(uuid())
  name                 String
  isFambrasApproved    Boolean  @default(false)
  allowedAnalysisTypes String[] // ['PCR_animal', 'etanol_residual', 'micotoxinas', ...]
  contactEmail         String?
  contactPhone         String?
  notes                String?  @db.Text
  isActive             Boolean  @default(true)
  createdAt            DateTime @default(now())
  updatedAt            DateTime @updatedAt
}
```

**Permissões:**
- `qualidade` (role nova ou subset de `analista`) → CRUD completo.
- `cliente` → READ-only no envio de FM 7.4.2.1 (catálogo filtrado por `isFambrasApproved=true` + `isActive=true`).
- Comitê **não envolvido**.

**Seed inicial (já mencionado no FM 7.4.2.1):** EUROFINS, FOODCHAIN, CQA, INTECSO, SENAI, UNIANÁLISES, FREITAG (com restrições por tipo de análise — ver doc original).

---

## B.1. Caso de amostra — destravado

**Pergunta:** Podem disponibilizar caso de amostra para calibrar ETL?

**Resposta:**
- Lina: delegou ao Fuad
- **Fuad enviou o link OneDrive (em paralelo):**
  ```
  https://fambras.sharepoint.com/:f:/r/sites/INDUSTRIAL/Documentos Compartilhados/1 CLIENTES/#INCLUSÃO DO GOLFO/IFF - FAR
  ```

**Cliente:** IFF (International Flavors & Fragrances). **Pasta:** "IFF - FAR" (FAR = pode ser código de processo/aditivo da Fambras — confirmar ao acessar).

**Próxima ação:** Renato baixa a pasta localmente, lista os anexos, e calibra o esquema ETL. Não atacar antes do schema multi-mercado/multi-país (A.2 + B.3) estar fechado, porque o ETL vai consumir esse schema.

**Risco:** o link é SharePoint privado — eu não consigo acessar daqui. Preciso que você baixe e ou (a) cole o índice de arquivos como referência, ou (b) compartilhe os anexos chave (proposta, contrato, plano auditoria, FM 9.3, NCs, FM 7.4.2.7, certificado emitido) localmente para análise.

---

## B.2. IA matérias-primas — escopo bem mais simples

**Pergunta:** O que a IA faz? Quais fontes? Prompts reais?

**Respostas da Lina:**
- **O quê:** "É uma busca por **criticidade**, **possibilidade de obtenção por fonte animal** e **qual espécie**."
- **Fontes:** "Não temos. São as ferramentas simples e gratuitas mesmo." (= Google + ChatGPT free, presumivelmente)
- **Prompts:** "N.A." (não documentaram)

**Decisão de modelagem:**

Output do agente IA por matéria-prima:

```ts
interface RawMaterialAiAnalysis {
  rawMaterialName: string;
  criticality: 'baixa' | 'media' | 'alta';
  mayBeAnimalDerived: boolean;
  animalSpecies: string | null; // "bovino", "suíno", "inseto", "caprino", null se vegetal/mineral/sintético
  reasoning: string; // Justificativa do agente para auditoria
  confidence: 'baixa' | 'media' | 'alta'; // Auto-avaliação do agente
}
```

**Implementação:**
- Claude API ou OpenAI direto, com prompt nosso baseado em conhecimento halal geral (não precisa indexar positive lists dos acreditadores).
- Input: nome da MP + categoria do produto + opcionalmente fornecedor + ficha técnica (se disponível).
- Cache por nome+categoria para reduzir custo (a maioria das MPs se repete entre clientes — "soro de leite", "lecitina de soja", etc.).
- UI: analista digita MP → agente responde em ~5s com 3 outputs + reasoning → analista revisa e aceita/edita.

**Cai de Onda 2 ambiciosa para Onda 2 viável.** Sem fontes externas pra integrar, escopo é só o agente + cache + UI de revisão.

---

## B.3. Item crítico × país — chave por produto

**Pergunta:** Itens críticos são fixos por categoria ou variam por país?

**Resposta da Lina:**
> A criticidade é **por produto, pela natureza e composição, não por país**. Há apenas algumas exceções, exemplo: o **carmim de cochonilha** (extraído de inseto), é proibido em **Turquia, África do Sul e todos os países do Golfo**.

**Decisão de modelagem:**

```prisma
model CriticalRawMaterial {
  id                  String   @id @default(uuid())
  categoryCode        String   // GSO/SMIIC: A, B, C, ...
  materialName        String   // "carmim de cochonilha", "coalho", "lecitina", ...
  criticality         Criticality
  naturalSourceMustBeChecked Boolean @default(true)
  notes               String?  @db.Text
  isActive            Boolean  @default(true)

  countryRestrictions CriticalRawMaterialCountryRestriction[]

  @@unique([categoryCode, materialName])
}

enum Criticality {
  baixa
  media
  alta
}

// Apenas para exceções por país (raras — ex: carmim de cochonilha)
model CriticalRawMaterialCountryRestriction {
  id                       String   @id @default(uuid())
  criticalRawMaterialId    String
  countryCode              String   // ISO-2
  restrictionType          RestrictionType
  notes                    String?

  criticalRawMaterial      CriticalRawMaterial @relation(fields: [criticalRawMaterialId], references: [id], onDelete: Cascade)

  @@unique([criticalRawMaterialId, countryCode])
}

enum RestrictionType {
  forbidden    // ex: carmim em Turquia/ZA/Golfo
  restricted   // permitido com condições especiais
}
```

**Seed inicial (extraído do FM 7.4.2.1 + e-mail Lina):**

| Categoria | Material | Criticidade | Restrições por país |
|---|---|---|---|
| Laticínio | coalho | alta | — |
| Laticínio | fermento | media | — |
| Laticínio | enzima | alta | — |
| Laticínio | cloreto de cálcio | baixa | — |
| Laticínio | ácido lático | media | — |
| Laticínio | vitaminas (encapsuladas) | media | — |
| Laticínio | corantes | media | — |
| Laticínio | detergente enzimático | baixa | — |
| Aditivo / corante | **carmim de cochonilha** | alta | **forbidden:** TR, ZA, SA, AE, KW, BH, OM, QA |
| ... | ... | ... | ... |

**Impacto na Onda 1+:** Item D (CriticalRawMaterial) sai de "key composta complexa" para "tabela simples + auxiliar de exceções". Reduz pela metade o esforço.

---

## Decisões NÃO perguntadas (mantidas como estavam)

- SysHalal × HalalSphere coexistem em paralelo (não migrar embarques)
- Política de preços fica fora do sistema (manual por contrato, sem fórmula)
- Tipos de alteração de escopo (6 fluxos), SLAs, fluxo de aditivo, reajuste IPCA, selo, auditoria não anunciada — todos claros nos documentos enviados.

---

## Próximos passos derivados

1. **Schema multi-mercado + multi-país (A.2 + B.3)** — primeiro alvo. Base para várias telas Onda 1+.
2. **Catálogo de Laboratórios (A.3)** — feature pequena e isolada, bom warm-up paralelo.
3. **Refactor HAS 2-estágios (A.1)** — fica para Onda 3 (não-crítico para Onda 1+).
4. **Agente IA matérias-primas (B.2)** — Onda 2, dependendo de quanto a Onda 1+ avançar.
5. **ETL de migração (B.1)** — depois do schema fechado, consumindo a pasta IFF-FAR como caso real.
