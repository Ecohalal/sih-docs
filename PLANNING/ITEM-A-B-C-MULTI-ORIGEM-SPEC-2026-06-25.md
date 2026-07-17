# Itens A/B/C — Multi-origem no Embarque (fontes vinculadas + faixas + rastreio) — SPEC

> **Data:** 2026-06-25
> **Origem:** reunião FAMBRAS 25/jun (Gabriel) + alinhamento de workflow com o PO (Renato)
> **Relação:** é a **Fase 2 (multi-origem)** do [Dossiê de Exportação](./DOSSIE-EXPORTACAO-IN-NATURA-ANALISE-2026-06-22.md). Converge 3 itens numa arquitetura só.
> **Repos:** `sih-backend` (NestJS 11 + Prisma 7) · `sih-frontend` (React 19 + Vite 7)

---

## 1. Os 3 itens (sintomas da mesma raiz)

- **Item A — Múltiplos SIF de origem no embarque (FM 7.1.7.1):** a carne de um embarque vem de vários frigoríficos/SIFs; hoje a tabela manual de produto tem 1 SIF.
- **Item B — Datas como faixa (início→fim):** abate/produção/validade são **período**, não data única; hoje o "Adicionar Produto" só aceita data única.
- **Item C — Vínculo embarque⇄produção visível na Controladoria:** o vínculo existe no dado, mas o controlador não consegue ver/abrir as produções vinculadas a partir do embarque.

**Raiz comum:** existem **2 representações** da composição do embarque:
1. `products` (JSON flat) — 1 SIF, data única → **é o que o PDF imprime**.
2. `productionSnapshot` (derivado das produções vinculadas) — **multi-SIF + faixas (start/end) + CSN + cert por origem** → **NÃO vai ao PDF**, e a Controladoria não lê.

Há até um botão `onApplyDerived` que **achata** (lossy) o rico no flat. A correção é **inverter**: o snapshot (rico) vira a fonte de verdade.

---

## 2. Workflow esperado pelo PO (2 modos)

**Cadeia:** Abate → Produção/Fabricação → Embarque. O embarque **reaproveita** dados dos relatórios anteriores.

- **Modo 1 — Vincular (caminho-rei):** ao preencher o embarque, o supervisor **vincula relatórios-fonte** já na base; período de abate, SIFs, séries Halal e pesos **derivam** desses vínculos. Não digita.
- **Modo 2 — Manual por range (exceção da implantação):** enquanto a base não tem os relatórios, permite **inserir os ranges manualmente** (abate, produção, validade — todos início→fim).
- **Coexistem:** um mesmo embarque pode ter parte vinculada + parte manual.

---

## 3. Decisões de desenho (confirmadas com o PO)

1. **Fontes vinculadas GENÉRICAS, tipadas** — não "abate ou produção", e sim N fontes `{ tipo: ABATE | PRODUCAO | … }`. Absorve variações futuras (controladoria de frigoríficos) sem nova tabela/migration. Trade-off aceito: referência **tipada por aplicação** (validar no backend que o relatório-fonte existe e é do tipo), não FK rígido por tipo.
2. **Elo abate→produção real** — adicionar `slaughterReportId` à matéria-prima da produção, para a cadeia **abate→produção→embarque** ficar navegável (vincular produção passa a "trazer" o abate, não só os dados).
3. **`productionSnapshot` = fonte de verdade** do PDF e da Controladoria; `products` flat vira **fallback** para embarque 100% manual.
4. **Campos deriváveis POR NATUREZA do produto** (não um conjunto fixo): in natura → período de abate + SIF; químico/industrializado (heparina, gelatina, couro) → lote-mãe + fabricação/validade, **sem abate**. Já apoiado por `ProductTable.visibleFields` (Fase 4) e pelos campos de abate nullable.
5. **Modo manual (range) preservado** como exceção de implantação.

---

## 4. Estado atual — o que JÁ existe (NÃO reconstruir)

| Já pronto | Onde |
|---|---|
| Vínculo embarque⇄produção (M:N) | `ShippingReportProduction` + `ShippingReport.linkedProductions` |
| Composição derivada **multi-SIF + faixas** | `deriveComposition()` → `productionSnapshot.products[].origins[]` (sanitaryCode/SIF, slaughterDateStart/End, csnNumber, halalCertNumber, quantityKg) |
| Painel derivado no form (multi-SIF + faixa) | `LinkedProductionsField.tsx` (tabela Origem/SIF, "01/03 – 15/03") |
| Snapshot congelado na assinatura | `ShippingReport.productionSnapshot` |
| Campos por tipo de expedição | `ProductTable.visibleFields` (Fase 4) |
| Cadeia química (lote-mãe) | `ProductionRawMaterial.sourceProductionReportId` |
| Anexos S3 (embarque + produção) | `ReportAttachment` (FK p/ ambos) |

**Gaps reais:** (a) vínculo só de PRODUÇÃO (falta ABATE + genérico); (b) sem `slaughterReportId` no rawMaterial (cadeia não navegável até abate); (c) `ProductTable` data única + 1 SIF; (d) PDF lê do flat; (e) Controladoria não inclui vínculos; (f) escopo de busca só por planta.

---

## 5. Implementação

### 5.1 Backend — Schema (1 migration aditiva)

**a) Elo abate→produção:**
```prisma
model ProductionRawMaterial {
  // …
  slaughterReportId String? @db.Uuid          // novo: vínculo ao abate (opcional)
  slaughterReport   SlaughterReport? @relation(fields: [slaughterReportId], references: [id])
}
```

**b) Fontes vinculadas genéricas no embarque** (substitui/eleva o `ShippingReportProduction`):
```prisma
enum ShippingSourceType { abate produção }   // extensível

model ShippingReportSource {
  shippingReportId String @db.Uuid
  sourceType       ShippingSourceType
  sourceReportId   String @db.Uuid            // ref. tipada por app (sem FK rígido)
  createdAt        DateTime @default(now())
  @@id([shippingReportId, sourceType, sourceReportId])
  @@index([sourceReportId])
  shippingReport   ShippingReport @relation(fields: [shippingReportId], references: [id], onDelete: Cascade)
}
```
> **Migração de compat:** backfill `ShippingReportProduction` → `ShippingReportSource` com `sourceType='produção'`. Manter a tabela antiga durante a transição (dual) ou migrar e dropar — decidir no detalhamento.

### 5.2 Backend — `deriveComposition` (union de fontes)

`deriveComposition(sources)` passa a **unir** origens de **todas** as fontes:
- **fonte PRODUÇÃO:** origens = `rawMaterials[]` (já multi-SIF + faixas) — como hoje.
- **fonte ABATE:** origem = SIF da planta do abate + `slaughterDate` (data única → contribui pro min/max do período) + cert.
- **período de abate derivado** = `min(slaughterDateStart) … max(slaughterDateEnd)` entre todas as origens.
- campos por natureza: se nenhuma origem tiver abate (químico), o período de abate sai null e o front/PDF não exibe.

### 5.3 Backend — Escopo da busca (`getDerivableProductions` → `getDerivableSources`)

Hoje filtra `plantId = report.plantId`. **Trocar por escopo confirmado** (ver §8): por **Empresa** (todas as plantas/SIFs da empresa) e/ou por **SIF de abate**. Generalizar para listar candidatos de ABATE e de PRODUÇÃO.

### 5.4 Backend — Controladoria (Item C)

Incluir as fontes vinculadas no endpoint de detalhe do embarque da Controladoria (`src/controladoria` hoje **não** inclui): retornar `[{ sourceType, serialNumber, plantName, sanitaryCode, formNumber, id }]` com dados p/ exibir + navegar.

### 5.5 Frontend

- **`ProductTable` (Item B):** campos de data viram **range** (`slaughterDateStart/End`, `productionDateStart/End`, `expiryDateStart/End`) no modo manual. SIF segue editável no manual. `visibleFields` esconde abate p/ natureza química.
- **`LinkedProductionsField` → `LinkedSourcesField` (Item A):** lista candidatos de **ABATE + PRODUÇÃO** (escopo §5.3); o painel derivado já mostra multi-SIF + faixas (reusar).
- **Controladoria (Item C):** detalhe do embarque renderiza as fontes vinculadas com link p/ `/slaughter-reports/:id` e `/production-reports/:id`.

### 5.6 PDF (Itens A + B)

`shipping-report-pdf.ts` passa a renderizar a partir do **`productionSnapshot`** quando presente (fallback `products`):
- cabeçalho "Frigorífico de abate" → **enumerar os N SIFs** das origens (não a planta única do embarque);
- tabela de produtos → SIF por origem + **faixas de data** (não data única);
- "período de abate" = min→max.

---

## 6. Mapa item → onde resolve

| Item | Resolve em |
|---|---|
| **A** multi-SIF | snapshot já agrega (5.2) + PDF lê do snapshot (5.6) + manual multi-linha (5.5) |
| **B** faixas | manual range no `ProductTable` (5.5) + derivação já tem start/end + PDF imprime range (5.6) |
| **C** rastreio | fontes no endpoint da Controladoria + UI navegável (5.4) + elo abate→produção (5.1a) |

---

## 7. Sequenciamento

1. **Item C primeiro** (independente, barato, alto valor): Controladoria expõe os vínculos existentes + UI navegável. Não depende de schema novo além do include.
2. **PDF lê do snapshot** (A-PDF + B-PDF juntos).
3. **Range manual no `ProductTable`** (B, modo exceção).
4. **Fontes genéricas + abate** (A completo, elo abate→produção, migração do `ShippingReportProduction`).
5. **Escopo de busca** (após §8).

---

## 8. Pergunta aberta (única que falta cravar)

**Escopo da busca de candidatos a vínculo:** restringir por **Empresa** (várias plantas/SIFs), por **Planta**, ou pelo **SIF de abate**? O PO indicou *"aquela empresa (ou o SIF de abate)"* — **recomendação:** filtrar por **Empresa** com refino opcional por **SIF de abate**; hoje é só por planta (estreito demais p/ empresa multi-planta). *(A confirmar com o Gabriel/PO.)*

---

## 9. Critérios de aceite

1. Criar embarque vinculando **≥2 fontes de SIF distintos** (abate e/ou produção) → SIFs e período aparecem no form, no snapshot e **no PDF**.
2. "Período de abate" do embarque = **min→max** das datas das fontes.
3. Modo manual: adicionar produto com **range** de abate/produção/validade → persiste e sai no PDF.
4. Produto **químico** (sem abate): vincula produção lote-mãe; campos de abate **não aparecem**; nada quebra.
5. **Controladoria:** abrir embarque com fonte vinculada → ver e **abrir** a produção/abate vinculados.
6. Vincular **produção** que tem abate vinculado → cadeia abate→produção→embarque navegável.
7. Backfill: vínculos antigos (`ShippingReportProduction`) migrados p/ fontes `tipo=produção`.

---

## 10. Fora de escopo

Reconciliação automática de pesos/lotes entre fontes e embarque (alertas de divergência) e a entidade Dossiê de 1ª classe — ficam para a evolução seguinte. A Fase 1 do Dossiê (NF-e estruturada, multi-CSI, anexos categorizados, painel `/dossier`) é trilha paralela.
