# Item A2 — Fontes vinculadas genéricas no embarque — SPEC

> **Data:** 2026-06-26
> **Contexto:** [ITEM-A-B-C-MULTI-ORIGEM-SPEC](./ITEM-A-B-C-MULTI-ORIGEM-SPEC-2026-06-25.md) (A2 é a fatia estrutural restante). A1 (elo abate→produção) já entregue e deployado.
> **Repos:** `sih-backend` (NestJS 11 + Prisma 7) · `sih-frontend` (React 19 + Vite 7)
> **Decisões do PO (Renato, 26/jun):** (1) migração aditiva; (2) frontend opção (b) seção separada; (3) DTO troca limpa.

---

## 1. O que entrega (e relação com o A1)

Hoje o embarque só vincula **produção** (`ShippingReportProduction`). Com o **A1**, a produção já carrega o abate (`ProductionRawMaterial.slaughterReportId`) → a cadeia **abate→produção→embarque** já funciona *quando há produção intermediária*.

O **A2 adiciona o "também"** que o PO pediu: o embarque poder vincular **abate diretamente** (sem produção no meio — carcaça congelada, ou implantação sem relatório de produção), e generaliza o vínculo para **fontes tipadas** (`abate | produção | …futuro`), absorvendo variações futuras sem nova tabela.

---

## 2. Estado atual (NÃO reconstruir)

| Já existe | Onde |
|---|---|
| Vínculo embarque⇄produção (M:N) | `ShippingReportProduction` + `ShippingReport.linkedProductions` |
| Composição derivada (multi-SIF + faixas) | `deriveComposition(productionIds)` → `productionSnapshot` |
| Sync | `syncLinkedProductions(shippingReportId, ids)` |
| Candidatos | `getDerivableProductions(id)` (filtro `plantId`) |
| Snapshot congelado na assinatura | `productionSnapshot` |
| DTO | `linkedProductionIds: string[]` |
| Frontend | `LinkedProductionsField` + `useDerivableProductions` + `onApplyDerived` |
| A1: elo abate→produção | `ProductionRawMaterial.slaughterReportId` + filtro `sif` em `/slaughter-reports` |

---

## 3. Schema (migration DDL aditiva — decisão 1)

```prisma
enum ShippingSourceType { abate producao }   // extensível

model ShippingReportSource {
  shippingReportId String @db.Uuid
  sourceType       ShippingSourceType
  sourceReportId   String @db.Uuid           // ref. tipada por app (validada no backend)
  createdAt        DateTime @default(now()) @map("created_at")
  @@id([shippingReportId, sourceType, sourceReportId])
  @@index([sourceReportId])
  shippingReport   ShippingReport @relation(fields: [shippingReportId], references: [id], onDelete: Cascade)
  @@map("shipping_report_sources")
}
```
- Adicionar relação inversa em `ShippingReport`: `sources ShippingReportSource[]`.
- **`ShippingReportProduction` fica como está** (não dropar — risco). Vira dead após o backfill; cleanup em migration futura.
- Migration = só DDL (enum + tabela). Idempotente (`CREATE TABLE IF NOT EXISTS` / guards). **Sem data move na migration.**

---

## 4. Backend (raio: módulo `shipping-report`)

### 4.1 `deriveComposition(sources)` — union de fontes
- `sourceType=producao` → origens dos `rawMaterials` (como hoje).
- `sourceType=abate` → 1 origem `{ sanitaryCode: plant.sanitaryCode, originName: plant.name, slaughterDateStart/End: abate.date, proteinType: abate.species }`.
- Período de abate = `min..max` de todas as origens (já é assim no PDF/derivação).
- Mantém shape do `productionSnapshot` (products[].origins[]) — PDF e front não mudam de contrato.

### 4.2 `syncSources(shippingReportId, sources)` (substitui `syncLinkedProductions`)
- `deleteMany` + `createMany` das N `{sourceType, sourceReportId}`.
- **Validação:** cada `sourceReportId` existe e é do tipo declarado (abate→slaughterReport, producao→productionReport). Retorna 400 se não.

### 4.3 `getDerivableSources(id, { sif })` — candidatos por SIF (escopo decidido)
- **abate:** `slaughterReport where plant.sanitaryCode contains sif`, status ≠ cancelado.
- **producao:** produções cujas `rawMaterials.sanitaryCode = sif` (ou plant.sanitaryCode), status ≠ cancelado.
- Retorna lista tipada `[{ sourceType, id, serialNumber, label, plantName, sif, date }]`.

### 4.4 `findOne`
- `include: { sources: true }` + expandir resumo de cada fonte (serial, tipo, planta) p/ navegação (Item C estende até abate).
- Derivar composição das `sources` (snapshot congelado se assinado).

### 4.5 DTO (decisão 3 — troca limpa)
- `linkedProductionIds` **removido**; entra `linkedSources: z.array(z.object({ sourceType: z.enum(['abate','producao']), sourceReportId: z.string().uuid() })).optional()`.
- `create`/`update` chamam `syncSources`.

---

## 5. Frontend (decisão 2 — opção b, aditivo)

- **Manter** o `LinkedProductionsField` (produções) funcionando.
- **Adicionar** uma seção de **abates** no embarque (estilo `LinkedSlaughtersField` do A1: busca por SIF, lista, vincula). Ambas as seções escrevem no **mesmo** estado `linkedSources` (cada item com seu `sourceType`).
- Form: `linkedProductionIds` → `linkedSources` no estado, load, submit, `onApplyDerived`.
- `shipping-reports.service`: `useDerivableProductions` → `useDerivableSources` (aceita `sif`); tipo `DerivedComposition` inalterado (snapshot mantém shape).
- **Sem refatorar** o `LinkedProductionsField` internamente (risco menor) — só troca a fonte de IDs.

---

## 6. Backfill (DBeaver — dados, decisão 1)

Após a migration DDL aplicar, migrar os vínculos existentes:
```sql
INSERT INTO shipping_report_sources ("shippingReportId", "sourceType", "sourceReportId")
SELECT "shippingReportId", 'producao'::"ShippingSourceType", "productionReportId"
FROM shipping_report_productions
ON CONFLICT DO NOTHING;
```
Provável poucos/zero registros (pré-go-live). `ShippingReportProduction` fica intacto (rollback fácil).

---

## 7. Sequência

1. Schema + migration DDL (`shipping_report_sources` + enum `ShippingSourceType`).
2. Backend: `deriveComposition` union + `syncSources` + `getDerivableSources(sif)` + `findOne` + DTO (`linkedSources`).
3. Frontend: seção de abates no embarque + troca `linkedProductionIds`→`linkedSources` (estado/load/submit/onApplyDerived) + hook `useDerivableSources`.
4. Backfill DBeaver.
5. Typecheck (front `tsc -b` + back) + commit + push `release` + reconciliar.

---

## 8. Riscos / atenção

- **DTO muda** (`linkedProductionIds`→`linkedSources`) — ponto mais sensível: toca form, snapshot, `onApplyDerived`, `findOne`. Troca limpa (pré-go-live) evita manter 2 contratos.
- `ShippingReportProduction` fica **órfão** até cleanup futuro (aceitável; não dropar agora).
- Migration usa **nome mapeado** da tabela (`shipping_report_sources`, `shipping_reports`) — ver lição P3009 (`feedback_migration_use_mapped_table_name`).
- Checklist pré-deploy: migration idempotente + swagger→API GW (novo `getDerivableSources`/rota) + `tsc -b` + Zod v4 (Base+`.partial()`).

---

## 9. Critérios de aceite

1. Criar embarque vinculando **≥1 abate diretamente** (sem produção) → SIF + data aparecem no snapshot e no PDF (cabeçalho multi-SIF + período).
2. Vincular **produção + abate** no mesmo embarque (misto) → ambas as origens compõem.
3. Candidatos filtrados **por SIF** (abate + produção).
4. Backfill: vínculos antigos viram `sources(tipo=producao)`; comportamento idêntico ao anterior.
5. Controladoria (Item C) navega até o abate quando a fonte é abate.

---

## 10. Fora de escopo

- Reconciliação automática de pesos/lotes entre fontes e embarque (alertas de divergência).
- Drop do `ShippingReportProduction` (cleanup futuro).
- Entidade Dossiê de 1ª classe (evolução do Dossiê de Exportação).
