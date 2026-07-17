# Fase 1 — Empoderar o Relatório de Embarque (SPEC de implementação)

> **Data:** 2026-06-22
> **Contexto:** [DOSSIE-EXPORTACAO-IN-NATURA-ANALISE-2026-06-22.md](./DOSSIE-EXPORTACAO-IN-NATURA-ANALISE-2026-06-22.md) (seção 7-bis)
> **Repos:** `sih-backend` (NestJS 11 + Prisma 7 + PG) · `sih-frontend` (React 19 + Vite 7)
> **Objetivo:** transformar o **Relatório de Embarque (FM 7.1.7.1)** num **"mini-dossiê"** — agregando os documentos oficiais (CSN/CSI/NF-e) de forma estruturada + os relatórios já vinculados + o nº do certificado SysHalal. **Sem nova entidade**; tudo sobre o `ShippingReport` existente.
> **Pode começar JÁ** — não depende do retorno do especialista de frigoríficos (isso é Fase 2).

---

## 1. Escopo

**DENTRO da Fase 1:**
1. Capturar **NF-e** (Nº + chave de acesso) como campos estruturados.
2. Suportar **múltiplos documentos sanitários** (ex.: aves teve 2 CSI: `I0-00173944` + `I0-00173962`).
3. Padronizar **categorias de anexo** (CSN / CSI / NF-e / Certificado / Outro) na UI de upload.
4. **Painel do Dossiê (read-only)** na visualização do embarque: relatórios vinculados + nº cert SysHalal + anexos por categoria.

**FORA da Fase 1 (vai pra Fase 2):** reconciliação multi-origem (faixas de data, conferência de pesos/lotes), encadeamento transferência→embarque do entreposto, entidade Dossiê própria.

---

## 2. Estado atual — o que JÁ existe (NÃO reconstruir)

No `ShippingReport` ([schema.prisma:474](../../sih-backend/prisma/schema.prisma)):

| Já existe | Campo |
|---|---|
| Contêiner | `containerNumber` |
| Lacre | `sealNumber` |
| Pedido/Invoice | `orderNumber` |
| Série Halal | `halalSerialNumber` |
| Doc sanitário (1 só) | `sanitaryDocType` (CSI/CSN/DCPOA/NENHUM) + `sanitaryDocNumber` + `csiNumber` (legado) |
| Destino (inclui entreposto) | `destinationType` |
| **Dados do cert SysHalal** | `halalCertData` (Json) + `halalCertSource` |
| **Vínculo multi-origem (M:N)** | `linkedProductions` → `ShippingReportProduction` |
| Composição congelada | `productionSnapshot` (Json) |
| **Anexos S3** | `attachments` → `ReportAttachment` (tem `fileKey`, `mimeType`, **`category String?`**) |

➡️ **Conclusão:** lacre, contêiner, CSI/CSN, vínculo de produção, anexos S3 e o slot do cert SysHalal **já estão prontos**. O delta da Fase 1 é só o que está na seção 3.

---

## 3. Delta a implementar

### 3.1 Backend — Schema (1 migration aditiva)

Adicionar ao `model ShippingReport`:

```prisma
  // Fase 1 (dossiê): Nota Fiscal eletronica estruturada (DANFE).
  // orderNumber = pedido/invoice comercial; nfeNumber = Nº da NF-e (DANFE).
  nfeNumber     String?
  nfeAccessKey  String?  // chave de acesso 44 digitos (opcional, p/ validacao)

  // Fase 1 (dossiê): N documentos sanitarios por embarque (ex.: 2 CSI).
  // Shape: [{ type: 'CSI'|'CSN'|'DCPOA', number: string }]. Canonical;
  // sanitaryDocType/sanitaryDocNumber/csiNumber mantidos por compat (espelho do 1o).
  sanitaryDocuments Json?
```

**Migration (idempotente — ver gotcha em [feedback_migration_enum_idempotent]):**
- `ALTER TABLE shipping_reports ADD COLUMN IF NOT EXISTS nfe_number TEXT;`
- `ADD COLUMN IF NOT EXISTS nfe_access_key TEXT;`
- `ADD COLUMN IF NOT EXISTS sanitary_documents JSONB;`
- **Backfill:** popular `sanitary_documents` a partir do par `(sanitary_doc_type, sanitary_doc_number)` existente, quando `sanitary_doc_number IS NOT NULL` e `sanitary_doc_type <> 'NENHUM'`:
  ```sql
  UPDATE shipping_reports
  SET sanitary_documents = jsonb_build_array(
        jsonb_build_object('type', sanitary_doc_type::text, 'number', sanitary_doc_number))
  WHERE sanitary_doc_number IS NOT NULL
    AND sanitary_doc_type <> 'NENHUM'
    AND sanitary_documents IS NULL;
  ```

> `ReportAttachment.category` **já existe** (String?) — sem mudança de schema; só padronizar valores (3.4).

### 3.2 Backend — DTO

`create-shipping-report.dto.ts` — adicionar ao `CreateShippingReportSchema`:

```ts
export const SanitaryDocItemSchema = z.object({
  type: z.enum(['CSI', 'CSN', 'DCPOA']),
  number: z.string().min(1),
});

// dentro do CreateShippingReportSchema:
  nfeNumber: z.string().optional(),
  nfeAccessKey: z.string().regex(/^\d{44}$/,'Chave NF-e deve ter 44 dígitos').optional(),
  sanitaryDocuments: z.array(SanitaryDocItemSchema).optional(),
```

> **Zod v4 (ver [feedback_zod_v4_partial_refine]):** manter o padrão Base + `.partial()` no Update; não usar `.refine()` no schema base que vai sofrer `.partial()`. O Update DTO deriva do Base.

### 3.3 Backend — Service + endpoint agregador

**Persistência:** gravar os 3 campos novos; ao receber `sanitaryDocuments`, espelhar o 1º item em `sanitaryDocType`/`sanitaryDocNumber`/`csiNumber` (compat). Incluir os campos novos no allowlist de update do service ([shipping-report.service.ts:243](../../sih-backend/src/shipping-report/shipping-report.service.ts)).

**Endpoint agregador (read-only) — "Dossiê do embarque":**
`GET /shipping-reports/:id/dossier` → monta a partir do que já existe (sem nova tabela):

```jsonc
{
  "shipping": { /* campos core + container/lacre/orderNumber */ },
  "officialDocs": {
    "sanitary": [{ "type": "CSI", "number": "I0-00173944/3169/26" }, …],
    "nfe": { "number": "232275", "accessKey": "4326…" }
  },
  "halalCert": { "source": "syshalal", "number": "2603ME3DD", "data": { … } }, // de halalCertData/halalCertSource
  "linkedProductions": [   // expandido de linkedProductions / productionSnapshot
    { "id": "…", "formNumber": "FM 7.1.4.1", "plantSif": "3169",
      "slaughterDateRange": "23/03–26/03", "lot": "903", "product": "FRANGO…",
      "netWeight": 9184.0, "grossWeight": 9487.072 }
  ],
  "attachments": [ { "category": "CSI", "fileName": "…", "fileKey": "…" } ] // agrupavel por category
}
```

> A maior parte é **montagem de dado existente** (`include` de `linkedProductions` + leitura de `productionSnapshot` + `halalCertData` + `attachments`). Não há lógica de reconciliação nesta fase — é exibição.

### 3.4 Frontend

**a) Form do embarque — seção "Documentos oficiais"** (reorganiza `containerNumber`/`sealNumber` que já existem + novos):
- Contêiner, Lacre (já existem).
- **Documentos sanitários (lista):** botão "+ adicionar" → linha `{ tipo: CSI/CSN/DCPOA, número }`. Permite N.
- **NF-e:** Nº + Chave de acesso (44 díg., opcional, com máscara/validação).

**b) Visualização do embarque — "Painel do Dossiê" (read-only):** consome `GET /:id/dossier`:
- bloco **Relatórios vinculados** (lista os abate/produção com SIF, faixa de abate, produto, pesos);
- bloco **Certificado Halal** (nº do cert SysHalal + link de verificação se houver);
- bloco **Documentos oficiais** (sanitários + NF-e) e **Anexos** por categoria (com download via presigned URL — fluxo de anexos já existe).

**c) Upload de anexo — seletor de categoria:** ao anexar, exigir `category ∈ {CSN, CSI, NFE, HALAL_CERT, OUTRO}` (string já suportada no backend).

### 3.5 Categorias de anexo padronizadas (constante compartilhada)

```ts
export const ATTACHMENT_CATEGORIES = ['CSN','CSI','NFE','HALAL_CERT','OUTRO'] as const;
```
(Backend valida que `category`, se enviada, ∈ desse conjunto; frontend usa como dropdown.)

---

## 4. Gotchas / checklist pré-deploy (obrigatório — [feedback_checklist_predeploy_sih])

- [ ] Migration **idempotente** (`ADD COLUMN IF NOT EXISTS`) + backfill testado; confirmar aplicação no DB de prod (não só push).
- [ ] **Swagger → API Gateway** regenerado para o novo `GET /:id/dossier` (proxy+ / [feedback_apigw_routes]).
- [ ] `tsc -b` local antes de pushar `release` (sih-frontend CI é mais strict — [feedback_tsc_b_vs_noemit]).
- [ ] Zod v4: Update via Base + `.partial()` (sem `.refine()` no base).
- [ ] Trabalhar em `release`; push dispara CI/CD; reconciliar `release→development` depois ([feedback_hotfixes_em_release]).
- [ ] Sem termos haram em mocks/seeds/testes ([feedback_halal_no_haram_terms]).

---

## 5. Critérios de aceite

1. Supervisor consegue lançar **2+ CSI** num mesmo embarque e ambos persistem/exibem.
2. Campo **NF-e (Nº + chave)** salvo e exibido; distinto de `orderNumber` (invoice).
3. Anexos de CSN/CSI/NF-e/Cert sobem com **categoria** e aparecem agrupados.
4. `GET /:id/dossier` retorna embarque + docs oficiais + relatórios vinculados + nº cert SysHalal numa só resposta.
5. **Painel do Dossiê** read-only exibe tudo isso na tela do embarque.
6. Embarques antigos: backfill preencheu `sanitaryDocuments` a partir do doc sanitário único.

---

## 6. Estimativa grosseira

- Backend (schema+migration+backfill+DTO+service+endpoint): ~1 dia.
- Frontend (seção docs no form + painel read-only + categoria no upload): ~1,5–2 dias.
- Total Fase 1: **~3 dias**, sem dependência externa.

---

## 7. Fronteira com a Fase 2 (não fazer agora)

Reconciliação multi-origem (validar pesos/lotes/datas entre produções e embarque), encadeamento entreposto, e a entidade **Dossiê de Exportação** como processo de 1ª classe. Tudo que a Fase 1 grava no embarque é **lido** (não substituído) pela Fase 2.
