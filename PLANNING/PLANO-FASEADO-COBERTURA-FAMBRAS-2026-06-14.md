# Plano Faseado — Cobertura Completa SIH × Ecossistema FAMBRAS

> Base: [COBERTURA-SIH-PROCESSO-EMISSAO-JBS-EXPORTACAO-2026-06-14.md](./COBERTURA-SIH-PROCESSO-EMISSAO-JBS-EXPORTACAO-2026-06-14.md)
> Decisão do PO (14/jun): **vínculo** embarque ⇄ relatórios de produção da base.
> Autor: análise 2026-06-14. Estimativas em dias-dev (1 dev), ajustar conforme equipe.

---

## 0. Princípios gerais (valem para todas as fases)

1. **Aditivo e compatível.** Nada quebra o piloto em andamento. Campos `Json`
   atuais (`products`, `meatRawMaterials`) permanecem durante a transição;
   novos modelos relacionais convivem com eles via *dual-write/dual-read* até
   o backfill terminar.
2. **Migração de dados versionada.** Toda transição `Json → relacional` tem:
   (a) migration de schema aditiva; (b) script de backfill idempotente;
   (c) período de leitura híbrida; (d) migration de limpeza só depois de
   validado em prod.
3. **Feature flag por fase.** Cada fase entra atrás de flag (env ou campo de
   config) para rollout controlado e rollback sem redeploy.
4. **Cada fase é deployável isolada** e entrega valor sozinha.
5. **Workflow:** branch `release` → push dispara CI/CD; checklist pré-deploy
   obrigatório (migrations aplicadas, swagger API Gateway se houver rota nova,
   Zod v4, `tsc -b`, build).
6. **Enum migrations idempotentes** (`ADD VALUE IF NOT EXISTS`).
7. **Audit trail** (`version: Int` + RevisionLog) nos modelos de decisão/evidência
   conforme ISO 17065 — aplicar nos novos modelos de produção/vínculo.

---

## 1. Visão geral — fases e dependências

```
FASE 0  Fundação: código sanitário flexível (sanitaryCode + enum)
   │        └─ destrava: plantas sem SIF, origem não-SIF (curtume), import colaboradores
   ▼
FASE 1  Documento sanitário CSI/CSN/DCPOA + categorias de anexo     [independente, rápido]
   │
   ▼
FASE 2  Produção estruturada (MP relacional + origem flexível + vínculo entre produções)
   │        └─ pré-requisito do vínculo
   ▼
FASE 3  Vínculo Embarque ⇄ Produção (NÚCLEO — multi-origem)         [decisão do PO]
   │
   ▼
FASE 4  Variação da tabela de produtos por tipo de expedição        [refinamento]
   │
   ▼
FASE 5  Cadastros de base: catálogo de produtos + MP/fornecedores (FAM-0017)
```

- **Fase 1 pode correr em paralelo com a Fase 0** (não dependem entre si).
- **Fase 0 é pré-requisito da Fase 2** (origem não-SIF/curtume usa o enum).
- **Fase 2 é pré-requisito da Fase 3** (vínculo deriva da produção estruturada).
- **Fases 4 e 5 são incrementais**, podem vir depois do núcleo.

**Esforço total estimado: ~38–52 dias-dev** (≈ 8–11 semanas, 1 dev).

---

## FASE 0 — Fundação: código sanitário flexível

> **DECISÃO DO PO (14/jun): SIH é só BR a princípio → enum ENXUTO (opção A).**
> A troca `sifCode → sanitaryCode` **NÃO é sobre internacionalização** — resolve
> um problema BRASILEIRO: nem toda planta BR tem SIF (Kin Master = indústria
> química; curtume não-exportador; origem de curtume na gelatina). Por isso o
> enum carrega só os tipos BR; multi-país fica para depois (expandir é trivial
> via `ADD VALUE IF NOT EXISTS`). Integração futura com o GC mapeia `SIF↔SIF`
> sem conversão.

**Objetivo.** Trocar `Plant.sifCode` (obrigatório, único) por código sanitário
**nullable e tipado** — habilita plantas BR sem SIF (indústria química, curtume
não-exportador), origem não-SIF (curtume na gelatina) e o import de
colaboradores industriais.

**Dependências.** Nenhuma.

**Schema (Prisma) — enum enxuto BR.**
```prisma
enum SanitaryCodeType {
  SIF            // Serviço de Inspeção Federal (dominante)
  SIE            // Serviço de Inspeção Estadual
  SIM            // Serviço de Inspeção Municipal
  SISBI          // Sistema Brasileiro de Inspeção (equivalência federal)
  INTERNAL       // sem registro oficial (química, curtume interno, GTS)
  NAO_APLICAVEL  // origem sem fiscalização sanitária
  // multi-país (PY/AR/CO/USA/EU...) só quando/se o SIH sair do Brasil
}

model Plant {
  // sifCode  String  @unique         ← REMOVER (após backfill)
  sanitaryCode     String?            // NULL p/ planta sem fiscalização
  sanitaryCodeType SanitaryCodeType  @default(SIF)
  internalCode     String?            // identificador sintético opcional
  // ...
  @@unique([sanitaryCode, sanitaryCodeType])
}
```
> "GTS" do Curtume Jangadas: gravar como `INTERNAL` (código no `sanitaryCode`)
> ou `internalCode`, a confirmar com a FAMBRAS.

**Migração de dados.**
1. Migration aditiva: cria `sanitaryCode`, `sanitaryCodeType`, `internalCode`.
2. Backfill: `sanitaryCode = sifCode`, `sanitaryCodeType = 'SIF'` para todas as
   plantas existentes.
3. Período híbrido: serializa ambos; código novo lê `sanitaryCode`.
4. Migration de limpeza: dropa `sifCode` depois de validado.

**Backend.**
- `PlantService`/DTOs: aceitar `sanitaryCode` + `sanitaryCodeType`; manter alias
  `sifCode` de leitura durante a transição.
- Atualizar `serial-number.util` (hoje `SIF{code}/...`): generalizar para usar
  `sanitaryCode` (mantém formato visual quando tipo=SIF).
- Pontos que hoje exibem "SIF {sifCode}" (13 backend): camada de compat que
  formata `{tipo} {código}` (ex.: "SIF 451", "INVIMA 0567", "INTERNAL —").

**Frontend.**
- `PlantForm`: seletor de **tipo de código sanitário** + campo do código
  (nullable). Validação: se tipo ≠ NAO_APLICAVEL, código obrigatório.
- Dropdowns/labels (29 usos de "SIF"): helper `formatSanitaryCode(plant)` →
  "SIF 451" / "INVIMA 0567" / "Sem código".

**Validação.** Plantas existentes continuam exibindo "SIF XXX"; criar planta
curtume sem SIF (tipo INTERNAL/NAO_APLICAVEL) funciona; relatórios antigos
intactos.

**Riscos.** Alto alcance (42 arquivos tocam `sifCode`). Mitigação: fazer em
2 sub-passos — (0a) adicionar campos + backfill + helper de compat **mantendo
`sifCode`**; (0b) renomear usos e dropar `sifCode` depois. **Não dropar antes
de validar.**

**Esforço:** 6–8 dias.

**Entregável.** Plantas com código sanitário tipado e nullable; base pronta
para origem não-SIF e import de colaboradores.

---

## FASE 1 — Documento sanitário (CSI/CSN/DCPOA) + categorias de anexo

**Objetivo.** Modelar o documento sanitário obrigatório que varia por tipo de
expedição: **CSI** (exportação), **CSN** (mercado interno), **DCPOA**
(transferência/trânsito). Toda emissão de certificado exige o seu.

**Dependências.** Nenhuma. **Pode correr em paralelo com a Fase 0.**

**Schema (Prisma).**
```prisma
enum SanitaryDocType { CSI CSN DCPOA NENHUM }

model ShippingReport {
  // csiNumber String?   ← manter por compat; passa a ser derivado
  sanitaryDocType   SanitaryDocType @default(CSI)
  sanitaryDocNumber String?
  // ...
}
```
Anexos — estender whitelist (já tem CSI, CSN, INVOICE, BL, NOTA_FISCAL, ROMANEIO):
```
+ DCPOA   (Declaração de Conformidade de Produtos de Origem Animal)
+ CROQUI  (Croqui/Rótulo)
```

**Migração de dados.** Backfill: onde `csiNumber` preenchido →
`sanitaryDocType=CSI`, `sanitaryDocNumber=csiNumber`. Enum idempotente.

**Backend.**
- DTOs de embarque (Zod): `sanitaryDocType` + `sanitaryDocNumber`.
- `attachments.service`: adicionar `DCPOA`, `CROQUI` à whitelist (backend + front).
- Regra por `shippingType`: exportação→CSI, venda_interna/subprodutos→CSN/DCPOA,
  transferencia→DCPOA (validação leve, não bloqueante no piloto).

**Frontend.**
- `ShippingReportForm`: campo "Documento Sanitário" com **tipo derivado do
  shippingType** (default) e número. Editável.
- `attachments.service` + `FileUpload`: categorias DCPOA e Croqui no dropdown.

**Validação.** Criar embarque exportação → CSI; venda interna → CSN; transferência
→ DCPOA; anexar DCPOA e baixar (S3 já pronto).

**Riscos.** Baixo. Apenas garantir compat do `csiNumber` legado.

**Esforço:** 3–4 dias.

**Entregável.** Documento sanitário correto por tipo de expedição + anexos
DCPOA/Croqui. Conformidade documental fechada para mercado interno.

---

## FASE 2 — Produção estruturada (pré-requisito do vínculo)

**Objetivo.** Tirar a MP cárnea do `meatRawMaterials Json` e modelar
relacionalmente, com origem flexível (SIF de abate **ou** curtume/fornecedor) e
vínculo entre relatórios de produção (lote-mãe da heparina, entrada/saída do
fracionamento). É a base sobre a qual o embarque vai "puxar" os dados.

**Dependências.** Fase 0 (origem não-SIF usa `SanitaryCodeType`).

**Schema (Prisma).**
```prisma
model ProductionRawMaterial {            // linha de MP cárnea/animal do relatório
  id                 String   @id @default(uuid)
  productionReportId String   @db.Uuid
  proteinType        String?              // "Língua bovina", "Mucosa", "Fígado"...
  // origem flexível: SIF de abate OU curtume/fornecedor
  originPlantId      String?  @db.Uuid    // FK opcional p/ Plant (origem rastreável)
  originName         String?              // texto livre quando não há Plant
  sanitaryCode       String?              // SIF/registro da origem (snapshot)
  slaughterDateStart DateTime? @db.Date
  slaughterDateEnd   DateTime? @db.Date
  csnNumber          String?              // CSN da origem (FM 7.1.3.1/7.1.5.1)
  halalCertNumber    String?              // cert halal da origem ou nº pedido (transfer)
  quantityKg         Decimal  @db.Decimal(12,3)
  // vínculo lote-mãe (heparina bruta→purificação; fracionamento entrada→saída)
  sourceProductionReportId String? @db.Uuid

  productionReport       ProductionReport  @relation(...)
  originPlant            Plant?            @relation(...)
  sourceProductionReport ProductionReport? @relation("DerivedFrom", ...)
}

model ProductionReport {
  // meatRawMaterials Json   ← mantido durante transição
  rawMaterials  ProductionRawMaterial[]
  derivedInto   ProductionRawMaterial[] @relation("DerivedFrom")
  version       Int @default(1)          // audit ISO 17065
}
```

**Migração de dados.** Backfill: parsear `meatRawMaterials Json` de cada
relatório → linhas `ProductionRawMaterial`. Validar contagem/peso. Manter Json
como sombra até validação.

**Backend.**
- DTOs/service de produção: aceitar `rawMaterials[]` estruturado; dual-write
  (grava relacional + Json) na transição.
- Endpoint para consultar produção com MP estruturada (consumido pela Fase 3).
- Tratar origem: se `originPlantId` setado, snapshot de `sanitaryCode`; senão
  `originName` livre (curtume/fornecedor).

**Frontend.**
- Componentes por tipo de produção (já existem: Heparina/Gelatina/Raspa/...)
  passam a emitir o array estruturado `rawMaterials[]` em vez de Json solto.
  Mínima mudança visual; muda o shape persistido.
- Campo de **origem**: seletor de Plant (com busca) **ou** texto livre (curtume).
- Heparina/Fracionamento: seletor de **relatório de produção de origem**
  (lote-mãe / entrada).

**Validação.** Relatórios novos gravam MP relacional; backfill dos antigos
confere peso total; lote-mãe da heparina aparece vinculado.

**Riscos.** Médio — migração Json→relacional de dados de produção do piloto.
Mitigação: dual-write + período de leitura híbrida + reconciliação de pesos.

**Esforço:** 8–10 dias.

**Entregável.** Produção com MP rastreável (origem + datas de abate + CSN +
cert) e encadeamento entre produções. Pré-condição do vínculo satisfeita.

---

## FASE 3 — Vínculo Embarque ⇄ Produção (NÚCLEO)

**Objetivo.** Implementar a decisão do PO: o embarque referencia os relatórios
de produção já lançados e **deriva deles** a composição por produto (código,
lote, SIFs de origem com faixas de data de abate, pesos). Resolve o GAP-1
(multi-origem) e GAP-2 (múltiplos relatórios Halal) de exportação **e**
mercado interno de uma vez.

**Dependências.** Fase 2 (produção estruturada). Fase 1 (doc sanitário) desejável.

**Schema (Prisma).**
```prisma
model ShippingReportProduction {     // junção M:N embarque ⇄ produção
  shippingReportId   String @db.Uuid
  productionReportId String @db.Uuid
  @@id([shippingReportId, productionReportId])
}

model ShippingReport {
  // products Json   ← mantido; passa a poder ser DERIVADO das produções
  linkedProductions ShippingReportProduction[]
  // halalSerialNumber String?  ← derivado dos serialNumber das produções vinculadas
}
```

**Lógica de derivação (backend).**
- Ao vincular N `ProductionReport`, montar a tabela de produtos do embarque:
  - 1 linha de produto por produção (ou por productCode), com a sub-lista de
    **origens** vindas de `ProductionRawMaterial` (SIF + faixa de abate).
  - `halalSerialNumber` = lista dos `serialNumber` das produções vinculadas
    (ex.: 337/2026/0010–0013).
  - Pesos/volumes agregados das produções.
- Campos editáveis pelo supervisor (override) preservados; derivação é o default.

**Backend.**
- Endpoint: `GET /shipping-reports/:id/derivable-productions` (produções da
  mesma planta/período candidatas a vínculo).
- `POST/PATCH` aceita `linkedProductionIds[]`; service deriva `products` +
  `halalSerialNumber` e persiste snapshot (imutabilidade do documento emitido).
- Snapshot: ao assinar/emitir, congela a composição derivada (auditoria).

**Frontend.**
- `ShippingReportForm`: seção "Relatórios de produção vinculados" — multi-select
  com busca (planta, período, produto). Ao vincular, a **tabela de produtos é
  preenchida automaticamente** (com a composição multi-origem por produto) e os
  números de série Halal aparecem.
- `ProductTable` ganha sub-linhas de **origem por produto** (SIF + faixa de
  datas de abate) — visualização expansível.
- Permitir ajuste manual pontual sem perder o vínculo.

**Validação.** Reproduzir o embarque JBS real: vincular as 4 produções
(337/2026/0010–0013) → produtos e origens multi-SIF aparecem derivados; série
Halal lista os 4; pesos batem.

**Riscos.** Alto (núcleo, muda o fluxo de preenchimento do embarque). Mitigação:
flag para ativar derivação por planta-piloto; manter o modo manual (Json) como
fallback; snapshot na emissão evita divergência retroativa.

**Esforço:** 10–12 dias.

**Entregável.** Embarque fiel ao FM 7.1.7.1/7.1.7.4 real, com composição
multi-origem derivada da base e rastreabilidade até os relatórios de produção.

---

## FASE 4 — Variação da tabela de produtos por tipo de expedição

**Objetivo.** A tabela de produtos varia: **completa** (exportação),
**reduzida** (transferência: produto+lote+volumes+data fab+peso), **mínima**
(FM 7.1.7.9: produto+data abate+qtd, com CSN anexo fazendo o detalhe). Hoje o
`ProductTable` é fixo.

**Dependências.** Fase 3 (a derivação alimenta as variantes).

**Backend/Frontend.**
- Config declarativa por `shippingType`: quais colunas a tabela exibe/exige.
- `ProductTable` parametrizado por esse perfil de colunas (já refatorado para
  cards em 5916517 — estender com "perfil de campos").
- Validação condicional (campos obrigatórios por perfil).

**Validação.** Cada tipo de expedição mostra só as colunas pertinentes; FM
7.1.7.9 aceita tabela mínima.

**Riscos.** Baixo/médio (refino de UI + validação condicional).

**Esforço:** 4–5 dias.

**Entregável.** Tabela de produtos correta por tipo de operação.

---

## FASE 5 — Cadastros de base (catálogo de produtos + MP/fornecedores)

**Objetivo.** Criar os cadastros que hoje faltam, permitindo validar/autocompletar
em vez de digitar livre: **Catálogo de Produtos Halal** (Lista de Produtos v143)
e **Cadastro de MP/Fornecedores** (FAM-0017, já analisado em mai/2026).

**Dependências.** Fase 0 (SIF/origem). Independente das Fases 3–4 no schema.

**Schema (Prisma) — esboço.**
```prisma
model HalalProduct {           // catálogo (Lista de Produtos Halal)
  id            String @id @default(uuid)
  code          String @unique
  name          String
  brand         String?
  packageSpec   Json?          // dimensões/tipos de embalagem
  sealType      String?        // FAMBRAS / ESMA / ...
  approvedAt    DateTime? @db.Date
  isActive      Boolean @default(true)
}

model RawMaterialSupplier {    // FAM-0017 (ver análise mai/2026: 9 modelos propostos)
  // reaproveitar o desenho de PLANILHA-MP-FORNECEDORES-FAM-0017-SCHEMA.md
}
```

**Backend.** CRUD de catálogo + import da planilha (ETL idempotente, nos moldes
do pré-cadastro GC). Endpoints de busca para autocomplete.

**Frontend.** Telas de cadastro + autocomplete de produto (no embarque/produção)
e de MP (na produção), validando contra o catálogo.

**Validação.** Produto digitado no embarque casa com o catálogo; MP da produção
valida contra fornecedores aprovados.

**Riscos.** Médio (volume de dados — 519 produtos, ~640 MP). ETL reaproveita
padrão existente.

**Esforço:** 7–10 dias (catálogo 3–4; FAM-0017 4–6, já há análise/schema).

**Entregável.** Cadastros de base que sustentam validação e autocomplete em
todo o sistema.

---

## 10. Riscos transversais e mitigações

| Risco | Mitigação |
|-------|-----------|
| Migração Json→relacional perder/dobrar dados | Dual-write + reconciliação de peso/contagem + Json-sombra até validar |
| Quebrar piloto em andamento | Tudo aditivo + feature flags + fallback manual |
| Imutabilidade do documento emitido | Snapshot da composição na assinatura/emissão |
| Alcance do `sifCode` (42 arquivos) | Fase 0 em 2 sub-passos; dropar coluna só no fim |
| Divergência com o GC na integração futura | Enum enxuto BR mapeia `SIF↔SIF` direto; expandir multi-país é trivial (`ADD VALUE`) se/quando o SIH sair do Brasil |
| Checklist de deploy esquecido | Gate obrigatório (migrations, swagger, Zod v4, tsc -b) por fase |

---

## 11. Sequência de entrega recomendada

1. **Fase 1** (doc sanitário) — rápida, valor imediato, baixo risco. *Quick win.*
2. **Fase 0** (código sanitário) — fundação; pode sobrepor à Fase 1.
3. **Fase 2** (produção estruturada) — pré-requisito do núcleo.
4. **Fase 3** (vínculo) — núcleo; maior valor e risco.
5. **Fase 4** (variação de tabela) — refino pós-núcleo.
6. **Fase 5** (cadastros) — fundação de validação; pode iniciar em paralelo
   após a Fase 0 se houver banda.

**Marcos sugeridos:**
- **M1 (≈ 2 sem):** Fases 1 + 0 — conformidade documental + base sanitária.
- **M2 (≈ 5 sem):** Fase 2 — produção rastreável.
- **M3 (≈ 8 sem):** Fase 3 — vínculo (embarque fiel ao real). *Entrega-chave.*
- **M4 (≈ 11 sem):** Fases 4 + 5 — refino e cadastros.

---

## 12. Pendências de decisão do PO antes de iniciar

1. ~~Confirmar alinhamento `SanitaryCodeType` com o GC~~ **RESOLVIDO 14/jun:**
   SIH só BR → enum enxuto (opção A), sem multi-país. Ver Fase 0.
2. **Origem da carga no vínculo:** vincular por **relatório de produção**
   (decidido) — confirmar se também vincular ao **inventário de carne**
   (FM 7.1.5.1) quando a carne vem de estoque, não de produção direta.
3. **Imutabilidade:** confirmar que a composição derivada congela na
   assinatura (snapshot) — alinhado à regra de cert imutável já adotada.
4. **Catálogo de produtos:** a Lista v143 (519 itens) é a fonte; confirmar
   cadência de atualização (versão periódica vs contínua).
5. **Priorização:** validar a sequência M1–M4 e a alocação.
