# Plano — Fase 5: Cadastros de Base (Catálogo de Produtos + MP/Fornecedores)

> Parte do [PLANO-FASEADO-COBERTURA-FAMBRAS-2026-06-14.md](./PLANO-FASEADO-COBERTURA-FAMBRAS-2026-06-14.md).
> Pré-requisito já satisfeito: Fase 0 (código sanitário). Independente das Fases 3–4 no schema.
> **Objetivo:** sair do "digita livre" para **validar/autocompletar** contra catálogos —
> Catálogo de Produtos Halal (Lista v143) e Cadastro de MP/Fornecedores (FAM-0017).

A Fase 5 tem duas metades independentes, entregáveis em separado:

- **5A — Catálogo de Produtos Halal** (menor, ~3–4 dias)
- **5B — Cadastro de MP/Fornecedores (FAM-0017)** (maior, ~4–6 dias; schema já desenhado)

Mesmo ritmo das fases anteriores: **aditivo → migration → ETL/seed idempotente → CRUD/endpoints → autocomplete no front → validar a cada estágio**.

---

## FASE 5A — Catálogo de Produtos Halal

**Fonte:** Lista de Produtos Halal v143 (~519 itens). Decisão de PO pendente:
cadência de atualização (versão periódica vs contínua).

**Schema (Prisma) — esboço.**
```prisma
model HalalProduct {
  id          String   @id @default(dbgenerated("uuid_generate_v4()")) @db.Uuid
  code        String   @unique          // código do produto (Lista v143)
  name        String
  brand       String?
  packageSpec Json?                      // dimensões/tipos de embalagem
  sealType    String?                    // FAMBRAS / ESMA / ...
  category    String?                    // família do produto
  approvedAt  DateTime? @db.Date
  isActive    Boolean  @default(true)
  version     Int      @default(1)       // audit
  createdAt   DateTime @default(now()) @map("created_at")
  updatedAt   DateTime @updatedAt @map("updated_at")
  @@map("halal_products")
}
```

**Estágios:**
1. **5A-1 (aditivo):** schema + migration (`create table halal_products`). Nada lê ainda.
2. **5A-2 (ETL):** script idempotente importando a Lista v143 (nos moldes do
   pré-cadastro GC / backfill Fase 2). Reconciliação de contagem. Mantido fora
   da migration automática (revisável).
3. **5A-3 (backend):** módulo `HalalProduct` — CRUD (admin) + `GET /halal-products?search=`
   para autocomplete. Rota nova de **módulo de topo** → regenerar API Gateway
   (`generate:swagger` + `generate-api-gateway.js` + CI). *(diferente das sub-rotas das fases 3/4)*
4. **5A-4 (frontend):** tela de catálogo (lista/CRUD) + componente de **autocomplete de produto**
   plugado no embarque (`ProductTable.name/code`) e na produção (`productName`/`productCode`),
   validando contra o catálogo (com opção "produto fora do catálogo" para não travar o piloto).

**Validação:** produto digitado no embarque casa com o catálogo; busca retorna itens; ETL reconciliado.

**Esforço:** 3–4 dias.

---

## FASE 5B — Cadastro de MP/Fornecedores (FAM-0017)

**Schema JÁ DESENHADO** em [PLANILHA-MP-FORNECEDORES-FAM-0017-SCHEMA.md](./PLANILHA-MP-FORNECEDORES-FAM-0017-SCHEMA.md)
(11 modelos: `HalalCertifyingBody`, `Manufacturer`, `RawMaterialSupplierEntity`,
`RawMaterialMaster`, `CompanyRawMaterial`, `RawMaterialSupplier`,
`RawMaterialHalalCertification`, `RawMaterialUseInFinalProduct`,
`PreApprovedIntermediateMaterial`, `NonFoodInput`, `RevisionLog`) + 6 enums.
UI esboçada em [PLANILHA-MP-FORNECEDORES-FAM-0017-UI.md](./PLANILHA-MP-FORNECEDORES-FAM-0017-UI.md).

> **Reaproveitar `RevisionLog` aqui também resolve a pendência de audit ISO 17065**
> das Fases 2/3 (hoje só `version: Int`). Considerar `RevisionLog` genérico.

**⚠️ Bloqueio: 8 decisões de PO pendentes** (ver [project_planilha_mp_fam0017_analisada] na memória).
Confirmadas: #2 (RawMaterialMaster global), #3 (Manufacturer global), #7 (RevisionLog Opção C).
Faltam confirmar as demais antes de implementar.

**Estágios (após decisões do PO):**
1. **5B-1 (aditivo):** schema + migration dos 11 modelos + 6 enums (enum idempotente `ADD VALUE IF NOT EXISTS`).
2. **5B-2 (ETL):** import da planilha FM 7.4.2.7 REV (≈640 MP) — parser já prototipado
   (`_fm_parser_consolidado.py`, `_fm_gc_cross_reference.py` em PLANNING). Idempotente + reconciliação.
3. **5B-3 (backend):** CRUD dos catálogos (Manufacturer, RawMaterialMaster, fornecedores,
   certificadoras) + endpoints de busca/autocomplete. Rotas novas de topo → regenerar API Gateway.
4. **5B-4 (frontend):** telas de cadastro + **autocomplete de MP** na produção
   (valida contra fornecedores/MP aprovados), com `RevisionLog` na UI de decisões.

**Validação:** MP da produção valida contra fornecedores aprovados; evidências halal vigentes; ETL reconciliado.

**Esforço:** 4–6 dias (schema/análise já prontos).

---

## Sequência recomendada

1. **5A** primeiro (menor, destrava autocomplete de produto no embarque/produção, baixo risco).
2. **5B** depois das 8 decisões do PO (maior, mas com schema/ETL já desenhados).

## Riscos / mitigações
- Volume de dados (519 produtos, ~640 MP) → ETL idempotente + reconciliação (padrão já usado).
- Rotas novas de **módulo de topo** → **lembrar de regenerar o API Gateway** (≠ sub-rotas das fases 3/4).
- Não travar o piloto → autocomplete com fallback "fora do catálogo".

## Pendências de decisão do PO antes de iniciar
- **5A:** cadência de atualização da Lista v143 (periódica vs contínua); a Lista v143 é a fonte única?
- **5B:** as 8 decisões da análise FAM-0017 (5 ainda em aberto).
