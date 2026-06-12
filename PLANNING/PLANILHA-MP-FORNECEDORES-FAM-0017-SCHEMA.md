# Schema Prisma — Planilha MP & Fornecedores (FM 7.4.2.7 / FAM-0017)

**Data:** 2026-05-25 (rev 2 — pós validação PO)
**Status:** proposta validada nas decisões-chave (1, 2, 3, 4, 5, 6, 7=C, 8); pronto para sprint
**Alvo:** `c:\Projetos\Ecohalal\halalsphere-backend\prisma\schema.prisma`
**Fonte:** `FM 7.4.2.7 - PLANILHA MP E FORNECEDORES (REV 9) - NOTE 15.04.2026.xlsm`
**Companion docs:**
- [PLANILHA-MP-FORNECEDORES-FAM-0017.md](PLANILHA-MP-FORNECEDORES-FAM-0017.md) — resumo executivo
- [PLANILHA-MP-FORNECEDORES-FAM-0017-UI.md](PLANILHA-MP-FORNECEDORES-FAM-0017-UI.md) — spec de UI da tela U7

---

## 1. Diagnóstico do estado atual

| Modelo existente | Cobertura FM 7.4.2.7 | Gap |
|---|---|---|
| `ScopeSupplier` (linha 2291) | Campos halal embutidos por linha de escopo. Comentário diz "FM 7.4.2.9" (typo — é 7.4.2.7). | Sem catálogo mestre de MP, fabricante e certificadora. Duplica `materialName` e `manufacturerName` em toda Certification. Sem ligação com `Product` (col N da planilha). Sem rastreio de cert halal como entidade. |
| `SupplierHomologation` (linha 4373) | Workflow de aprovação MP×Fornecedor com URLs de doc e flag `fm7427Updated`. | Continua textual (`supplierName`, `materialName`, `manufacturerName` como strings). Não consome catálogo. |
| `CriticalRawMaterial` (linha 2085) | Catálogo curado FAMBRAS de MPs sensíveis por `IndustrialCategory`. | **NÃO** é a planilha do cliente — é a régua de criticidade que a FAMBRAS aplica. Coexistirá com `RawMaterial`. |
| `HomologationProfile` (linha 2126) | Define docs/questionários exigidos por categoria industrial. | OK, orquestra workflow; não muda. |
| `Product` (linha 1149) | Catálogo de produtos finais da Company. | Vai ser destino da junction "MP usada em qual produto" (col N). |
| `Certification.hasMpSpreadsheet` (linha 4267) | Flag binário "FM 7.4.2.7 entregue". | Útil como indicador de macro-status; mantém. |
| `SharedSupplier` (linha 2621) | Fornecedor compartilhado por grupo empresarial. | Boa referência de modelo: tem `companyId/plantId` opcionais (mesma semântica que vamos reusar em `Manufacturer`/`Supplier`). |

**Conclusão de diagnóstico:**
- A planilha não é uma extensão de `ScopeSupplier` — é um **catálogo mestre por Company** com workflow.
- A coluna A "Número do Item" da REV 15.04 é o conceito **`RawMaterialSupplier`** (tupla MP × Fabricante × Fornecedor × Cert Halal).
- A coluna B "Raw material/Input Code" é código do cliente — chave natural de `RawMaterial` dentro de uma Company.
- O bloco "linha mestre + N filhas só com coluna N" da planilha vira `RawMaterialUseInFinalProduct` (junction).

---

## 2. Modelos novos propostos

Notação: nomes pt-BR em comentários, `@@map` em snake_case (convenção do schema atual).

### 2.1 Enums novos

```prisma
enum RawMaterialOrigin {
  animal               // ANIMAL
  microbial            // MICROBIAL / MICROBIANA
  vegetable            // VEGETABLE / VEGETAL
  mineral              // MINERAL
  synthetic            // SINTETIC / SINTÉTICA
  chemical             // CHEMICAL / QUIMÍCO (sic na planilha)
  vegetable_mineral    // VEGETABLE AND MINERAL (combinação real)
  other                // OUTROS — sentinela quando nada se aplica
}

// Status de aprovação halal de uma cert/declaração específica da MP.
// NÃO confundir com SupplierHomologation.status (workflow de revisão FAMBRAS).
enum RawMaterialHalalEvidenceType {
  certificate          // Certificado halal emitido por body reconhecido
  declaration          // Declaração de não-uso de materiais haram (na ausência de cert)
  pre_approved         // MP intermediária pré-aprovada FAMBRAS (whitelist)
  none                 // Não há evidência (col F "NÃO" da planilha — 323 ocorrências)
}

// Categorias da aba "OUTROS_OTHERS" (insumos não-alimentares).
enum NonFoodInputCategory {
  water_treatment      // WATER TREATMENT
  packaging            // PACKAGING
  cleaning_products    // CLEANING PRODUCTS
  lubricants           // LUBRICANTS
  pest_control         // CONTROLE DE PRAGAS
  inks_stamps_solvents // TINTAS/CARIMBOS/SOLVENTES
  other                // sentinela
}

// Status de reconhecimento da certificadora pela FAMBRAS.
enum HalalCertifyingBodyRecognitionStatus {
  recognized           // Reconhecida (cross-reference IFANCA, JAKIM, MUI, MUIS, etc.)
  conditionally_recognized // Reconhecida com restrições de mercado
  not_recognized       // Não reconhecida — exige declaração ou troca
  fambras_internal     // É a própria FAMBRAS (sem cross-check externo)
  unknown              // Catálogo em construção — default seguro
}

// Workflow de aprovação dos catálogos globais FAMBRAS (Manufacturer, RawMaterialMaster).
// Cliente cadastra/importa entrada nova → entra `pending` → qualidade FAMBRAS avalia →
// aprova / rejeita / funde com entrada existente (`merged_into`).
enum GlobalCatalogApprovalStatus {
  pending              // Aguardando análise pela qualidade FAMBRAS
  approved             // Validada pela qualidade FAMBRAS
  rejected             // Rejeitada (entrada inválida — não usar)
  merged_into          // Marcada como duplicata; ver mergedIntoId
  anonymous            // Fabricante/MP confidencial por NDA do cliente (sem dados públicos)
}

// Tipo de mutação registrado no RevisionLog (audit trail ISO 17065).
enum RevisionMutationType {
  create
  update
  delete               // soft-delete (isActive=false)
  restore              // reverter de delete
  approve              // aprovação do workflow GlobalCatalogApprovalStatus
  reject
  merge                // merge de duplicata
}

**Decisão deliberada:** **não** criar enum `RawMaterialRiskLevel`. A coluna K "Risk" da planilha está poluída (clientes preenchem "N/A" / "SIM"), e a régua de criticidade real já vive em `CriticalRawMaterial.criticality` por categoria. Criar enum aqui validaria dados ruins e duplicaria fonte de verdade. Mantemos o atual `ScopeSupplier.riskLevel` como string livre **deprecada** e calculamos criticidade dinamicamente cruzando `RawMaterial.name × IndustrialCategory.code` contra `CriticalRawMaterial`.

### 2.2 `HalalCertifyingBody` — catálogo de certificadoras

```prisma
// CATÁLOGO DE CERTIFICADORAS HALAL (HCS, IFANCA, MUI, JAKIM, FAMBRAS, etc.)
// Alimenta autocomplete na UI cliente + valida cross-reference. Os 77 valores
// distintos da col F da planilha são normalizados aqui via seed.
// Mantido pela role qualidade FAMBRAS.
model HalalCertifyingBody {
  id                  String                              @id @default(dbgenerated("uuid_generate_v4()")) @db.Uuid
  code                String                              @unique @db.VarChar(50)  // "FAMBRAS", "IFANCA", "JAKIM", "MUI", "HCS"
  name                String                              @db.VarChar(255)         // "FAMBRAS Halal"
  fullLegalName       String?                             @map("full_legal_name") @db.VarChar(500)
  country             Country?                                                     // País-sede (nullable: alguns multinacionais)
  website             String?                             @db.VarChar(500)
  recognitionStatus   HalalCertifyingBodyRecognitionStatus @default(unknown) @map("recognition_status")
  recognitionNotes    String?                             @map("recognition_notes") @db.Text
  // Mercados onde a certificação dessa body é aceita (informativo; regra dura fica no FM 4.1.X).
  recognizedInMarkets Country[]                           @default([]) @map("recognized_in_markets")
  // Aliases livres usados na planilha que mapeiam pra essa body
  // (ex: "HCS - HALAL CERTIFICATION SERVICES", "HCS GmbH", "HCS-Halal Cert Svc").
  aliases             String[]                            @default([])
  isActive            Boolean                             @default(true) @map("is_active")
  createdAt           DateTime                            @default(now()) @map("created_at")
  updatedAt           DateTime                            @updatedAt @map("updated_at")

  // Reverse relations
  rawMaterialHalalCertifications RawMaterialHalalCertification[]

  @@index([code])
  @@index([recognitionStatus])
  @@index([isActive])
  @@map("halal_certifying_bodies")
}
```

### 2.3 `Manufacturer` — catálogo GLOBAL FAMBRAS (decisão #3 do PO)

**Decisão validada:** catálogo GLOBAL, mantido pela qualidade FAMBRAS via workflow `pending → approved`. Cliente nunca bloqueia: cadastra como `pending` e segue trabalhando; FAMBRAS aprova ou funde com duplicata.

**Calibração quantitativa:** 1 cliente real tem 450 fabricantes distintos. Extrapolação 30-50 clientes industriais ≈ ~5-8 mil fabricantes únicos após dedup (Cargill/BASF/etc. compartilhados). Catálogo grande mas finito.

```prisma
// CATÁLOGO GLOBAL DE FABRICANTES (planta que produz a MP).
// Mantido pela qualidade FAMBRAS via workflow approvalStatus.
// Distinto de RawMaterialSupplierEntity (relação comercial per-Company).
// Quando approvalStatus=anonymous, o cliente identifica internamente mas o nome
// público é redigido (suporta "FABRICANTE OCULTO" — 328 linhas reais no FAM-0017).
model Manufacturer {
  id String @id @default(dbgenerated("uuid_generate_v4()")) @db.Uuid

  // Identificação canônica (preenchida na aprovação pela qualidade FAMBRAS)
  canonicalName String   @map("canonical_name") @db.VarChar(255)  // Ex: "Cargill, Incorporated"
  displayName   String?  @map("display_name") @db.VarChar(255)    // Versão curta usada na UI (ex: "Cargill")
  aliases       String[] @default([])                              // Variantes na grafia das planilhas

  // Endereço / país-sede (opcionais; muitos clientes não preenchem)
  address String?  @db.Text
  country Country?

  // Tax ID livre (estrangeiros sem cadastro BR)
  taxId     String? @map("tax_id") @db.VarChar(50)
  taxIdType TaxIdType? @map("tax_id_type")
  website   String? @db.VarChar(500)

  // Vínculo opcional com Plant cadastrada no GC (quando fabricante é cliente FAMBRAS também)
  linkedPlantId String? @map("linked_plant_id") @db.Uuid

  // Workflow de curadoria
  approvalStatus  GlobalCatalogApprovalStatus @default(pending) @map("approval_status")
  approvedById    String?   @map("approved_by_id") @db.Uuid
  approvedAt      DateTime? @map("approved_at")
  rejectionReason String?   @map("rejection_reason") @db.Text
  mergedIntoId    String?   @map("merged_into_id") @db.Uuid  // Quando duplicata: aponta para a canônica
  // Quem propôs (Company que adicionou na planilha) — só auditoria, não usado em regras
  proposedByCompanyId String? @map("proposed_by_company_id") @db.Uuid

  notes    String? @db.Text
  isActive Boolean @default(true) @map("is_active")
  version  Int     @default(1)  // Optimistic concurrency + ref do RevisionLog

  createdAt DateTime @default(now()) @map("created_at")
  updatedAt DateTime @updatedAt @map("updated_at")

  // Relações
  linkedPlant         Plant?                @relation("ManufacturerLinkedPlant", fields: [linkedPlantId], references: [id], onDelete: SetNull)
  approvedBy          User?                 @relation("ManufacturerApprover", fields: [approvedById], references: [id])
  mergedInto          Manufacturer?         @relation("ManufacturerMerge", fields: [mergedIntoId], references: [id])
  duplicates          Manufacturer[]        @relation("ManufacturerMerge")
  proposedByCompany   Company?              @relation("ManufacturerProposer", fields: [proposedByCompanyId], references: [id])
  rawMaterialSuppliers RawMaterialSupplier[]
  nonFoodInputs       NonFoodInput[]

  @@index([canonicalName])
  @@index([country])
  @@index([approvalStatus])
  @@index([linkedPlantId])
  @@index([mergedIntoId])
  @@index([isActive])
  @@map("manufacturers")
}
```

### 2.4 `RawMaterialSupplierEntity` — fornecedor/revenda comercial

A planilha distingue Fabricante (col P) e Fornecedor (col R). Para evitar overload de "Supplier" com `ScopeSupplier`, e para não inflar `SharedSupplier`, criamos uma entidade dedicada:

```prisma
// FORNECEDOR COMERCIAL DE MATÉRIA-PRIMA (revenda, trading, importador, distribuidor).
// Distinto de Manufacturer: o mesmo Manufacturer pode chegar via N Suppliers.
// Distinto de ScopeSupplier (que é a vinculação no escopo de uma Certification específica).
// Distinto de SharedSupplier (que é o catálogo a nível de CompanyGroup).
//
// Convenção: este é o "catálogo de fornecedores que a Company usa para comprar MP".
// Sincroniza opcionalmente com SharedSupplier (mesmo CNPJ → mesma entidade lógica).
model RawMaterialSupplierEntity {
  id        String  @id @default(dbgenerated("uuid_generate_v4()")) @db.Uuid
  companyId String  @map("company_id") @db.Uuid   // Catálogo per-Company (cliente industrial)

  // Vínculo opcional com SharedSupplier (mesmo fornecedor que o grupo já cadastrou).
  sharedSupplierId String? @map("shared_supplier_id") @db.Uuid

  // Identificação
  externalCode String? @map("external_code") @db.VarChar(50)   // Col O "código fornecedor" (REV 15.04)
  name         String  @db.VarChar(255)                         // Col R "Raw material supplier name"
  taxId        String? @map("tax_id") @db.VarChar(50)
  taxIdType    TaxIdType? @map("tax_id_type")
  country      Country?
  address      String? @db.Text

  // Contato
  contactName  String? @map("contact_name") @db.VarChar(255)
  contactEmail String? @map("contact_email") @db.VarChar(255)
  contactPhone String? @map("contact_phone") @db.VarChar(50)

  notes     String?  @db.Text
  isActive  Boolean  @default(true) @map("is_active")
  createdAt DateTime @default(now()) @map("created_at")
  updatedAt DateTime @updatedAt @map("updated_at")

  company             Company              @relation(fields: [companyId], references: [id], onDelete: Cascade)
  sharedSupplier      SharedSupplier?      @relation(fields: [sharedSupplierId], references: [id], onDelete: SetNull)
  rawMaterialSuppliers RawMaterialSupplier[]
  nonFoodInputs       NonFoodInput[]       @relation("NonFoodInputSupplier")

  @@unique([companyId, externalCode])
  @@index([companyId])
  @@index([sharedSupplierId])
  @@index([taxId])
  @@index([name])
  @@map("raw_material_supplier_entities")
}
```

**Por que `RawMaterialSupplierEntity` e não reaproveitar `SharedSupplier`?**
- `SharedSupplier` é **per-Group** e tem workflow próprio de aprovação. Hoje só armazena "products: String[]". Forçar todo fornecedor de MP a virar `SharedSupplier` confunde: nem toda Company quer compartilhar fornecedor com outras do grupo.
- `SharedSupplier.products` é array de string → não modela `RawMaterialSupplier` com cert halal.
- Mantemos `sharedSupplierId` como **ponte opcional**: se o cliente promover esse fornecedor pra grupo, sincroniza.

### 2.5a `RawMaterialMaster` — catálogo GLOBAL FAMBRAS (decisão #2 do PO)

**Decisão validada:** dicionário canônico de MPs, mantido pela qualidade FAMBRAS. Mesmo workflow `pending → approved` do `Manufacturer`. Cliente cadastra MP nova como `pending`, FAMBRAS aprova / funde com canônica.

**Calibração quantitativa:** 1 cliente real tem 474 códigos MP / 773 nomes distintos (sinaliza variações grafadas para a mesma MP). Extrapolação 30-50 clientes ≈ ~1,5-3 mil MPs canônicas.

```prisma
// CATÁLOGO GLOBAL DE MATÉRIAS-PRIMAS CANÔNICAS (dicionário FAMBRAS).
// Ex: "Ácido Cítrico Anidro", "Lecitina de Soja Refinada", "Goma Xantana".
// Mantido pela qualidade FAMBRAS via workflow approvalStatus.
// O `internalCode` do cliente NÃO vive aqui — vive em CompanyRawMaterial.
model RawMaterialMaster {
  id String @id @default(dbgenerated("uuid_generate_v4()")) @db.Uuid

  canonicalName String   @map("canonical_name") @db.VarChar(500)
  aliases       String[] @default([])  // Variantes ("ÁCIDO CÍTRICO MONO", "AC CITRICO", etc.)
  casNumber     String?  @map("cas_number") @db.VarChar(20)  // ex: "77-92-9"

  // Origem canônica DEFAULT (cliente pode sobrescrever em CompanyRawMaterial.origin)
  defaultOrigin RawMaterialOrigin @map("default_origin")

  // Sinalização de criticidade (alimenta sugestão do agente IA da Onda 2)
  criticalityHint String? @map("criticality_hint") @db.VarChar(20) // baixo|medio|alto|critico

  // Vínculo opcional com a régua de criticidade por categoria FAMBRAS
  criticalRawMaterialId String? @map("critical_raw_material_id") @db.Uuid

  // Workflow de curadoria
  approvalStatus  GlobalCatalogApprovalStatus @default(pending) @map("approval_status")
  approvedById    String?   @map("approved_by_id") @db.Uuid
  approvedAt      DateTime? @map("approved_at")
  rejectionReason String?   @map("rejection_reason") @db.Text
  mergedIntoId    String?   @map("merged_into_id") @db.Uuid
  proposedByCompanyId String? @map("proposed_by_company_id") @db.Uuid

  notes    String? @db.Text
  isActive Boolean @default(true) @map("is_active")
  version  Int     @default(1)  // RevisionLog

  createdAt DateTime @default(now()) @map("created_at")
  updatedAt DateTime @updatedAt @map("updated_at")

  // Relações
  criticalRawMaterial CriticalRawMaterial? @relation(fields: [criticalRawMaterialId], references: [id], onDelete: SetNull)
  approvedBy          User?                @relation("RawMaterialMasterApprover", fields: [approvedById], references: [id])
  mergedInto          RawMaterialMaster?   @relation("RawMaterialMasterMerge", fields: [mergedIntoId], references: [id])
  duplicates          RawMaterialMaster[]  @relation("RawMaterialMasterMerge")
  proposedByCompany   Company?             @relation("RawMaterialMasterProposer", fields: [proposedByCompanyId], references: [id])
  companyRawMaterials CompanyRawMaterial[]

  @@index([canonicalName])
  @@index([casNumber])
  @@index([approvalStatus])
  @@index([criticalRawMaterialId])
  @@index([mergedIntoId])
  @@index([isActive])
  @@map("raw_material_masters")
}
```

### 2.5b `CompanyRawMaterial` — mapeamento per-Company (renomeado de `RawMaterial`)

```prisma
// MAPEAMENTO PER-COMPANY DO CÓDIGO INTERNO DO CLIENTE → RawMaterialMaster canônico.
// Equivalente lógico das colunas B (código), C (nome no cert), D (nome genérico).
// Mesmo Raw material code pode ter N CompanyRawMaterialSupplier (vários fabricantes).
//
// Distinto de CriticalRawMaterial: este é "o que a Company usa"; CriticalRawMaterial
// é "a régua FAMBRAS de criticidade por categoria". Cross-check via RawMaterialMaster.
model CompanyRawMaterial {
  id        String @id @default(dbgenerated("uuid_generate_v4()")) @db.Uuid
  companyId String @map("company_id") @db.Uuid

  // Col B — código interno do cliente (ex: "1000005"). Único por Company.
  internalCode String @map("internal_code") @db.VarChar(100)

  // Col C — nome como aparece no certificado halal (preserva grafia oficial do cliente)
  nameAsCertified String @map("name_as_certified") @db.VarChar(500)

  // Col D — nome genérico pt-BR (campo de busca interna)
  genericName String  @map("generic_name") @db.VarChar(500)

  // Col E — origem (PICKLIST; sobrescreve RawMaterialMaster.defaultOrigin se diferir)
  origin RawMaterialOrigin

  // FK para o canônico global FAMBRAS. NULL enquanto não houver matching:
  // - linha nova importada vai inicialmente com NULL + flag `awaitingMatching`
  // - serviço de matching (similarity pg_trgm + aliases) sugere; qualidade confirma
  rawMaterialMasterId String? @map("raw_material_master_id") @db.Uuid
  awaitingMatching    Boolean @default(true) @map("awaiting_matching")

  // Col L — produtos finais críticos que usam esta MP (texto livre legado;
  // a junção estruturada vive em RawMaterialUseInFinalProduct).
  criticalItemsNotes String? @map("critical_items_notes") @db.Text

  // Col M — ficha técnica disponível? PICKLIST YES/SIM/N/A → tri-state booleano.
  hasTechnicalSpec Boolean? @map("has_technical_spec")

  notes     String?  @db.Text          // Equivalente a Col T "Remarks" agregada
  isActive  Boolean  @default(true) @map("is_active")
  version   Int      @default(1)       // RevisionLog

  createdAt DateTime @default(now()) @map("created_at")
  updatedAt DateTime @updatedAt @map("updated_at")

  // Relações
  company           Company            @relation(fields: [companyId], references: [id], onDelete: Cascade)
  rawMaterialMaster RawMaterialMaster? @relation(fields: [rawMaterialMasterId], references: [id], onDelete: SetNull)
  suppliers         RawMaterialSupplier[]
  usesInFinalProducts RawMaterialUseInFinalProduct[]

  @@unique([companyId, internalCode])
  @@index([companyId])
  @@index([rawMaterialMasterId])
  @@index([origin])
  @@index([genericName])
  @@index([awaitingMatching])
  @@index([isActive])
  @@map("company_raw_materials")
}
```

**Decisão consolidada (PO #2):** RawMaterial **global** via `RawMaterialMaster` (FAMBRAS-curated) + mapeamento **per-Company** via `CompanyRawMaterial` (código interno do cliente). Resolve a tensão "código interno é per-ERP × substância é canônica".

### 2.6 `RawMaterialSupplier` — junction com cert halal (o "Item Número" da planilha)

```prisma
// LINHA-MESTRE DE ITEM DA PLANILHA FM 7.4.2.7.
// Equivalente lógico da Col A "Número do Item" (REV 15.04+).
// Cada instância = tupla única (CompanyRawMaterial × Manufacturer × Supplier).
// A cert halal vigente é a relação 1:1 com RawMaterialHalalCertification mais recente,
// mas mantemos histórico em RawMaterialHalalCertification (uma MP pode ter cert que vence
// e é renovada — auditoria precisa do histórico).
model RawMaterialSupplier {
  id             String @id @default(dbgenerated("uuid_generate_v4()")) @db.Uuid

  rawMaterialId  String @map("raw_material_id") @db.Uuid
  manufacturerId String @map("manufacturer_id") @db.Uuid
  supplierEntityId String @map("supplier_entity_id") @db.Uuid

  // Número sequencial humano-legível da planilha (Col A da REV 15.04).
  // Calculado/atribuído quando exporta a planilha. Não-único entre Companies.
  itemNumber Int? @map("item_number")

  // Col S — Embalagem original (sem re-embalagem). PICKLIST YES/NO/PENDING_INFO → tri-state.
  isOriginalPackaging Boolean? @map("is_original_packaging")

  // Col T — observações específicas dessa tupla (não da MP, não do fornecedor)
  remarks String? @db.Text

  // Cert halal vigente (denormalizado para consultas rápidas / export Excel).
  // currentHalalCertificationId NULL E hasDeclaration=true → vide Col H (declaração)
  // currentHalalCertificationId NULL E hasDeclaration=false → Col F "NÃO" (sem evidência)
  currentHalalCertificationId String? @map("current_halal_certification_id") @db.Uuid

  // Status de elegibilidade FAMBRAS para uso nessa Company
  // (calculado/sobrescrito pela qualidade; default 'pending' até primeira análise).
  fambrasReviewStatus String @default("pending") @map("fambras_review_status") @db.VarChar(20)
  fambrasReviewedAt   DateTime? @map("fambras_reviewed_at")
  fambrasReviewedBy   String?   @map("fambras_reviewed_by") @db.Uuid
  fambrasReviewNotes  String?   @map("fambras_review_notes") @db.Text

  isActive  Boolean  @default(true) @map("is_active")
  createdAt DateTime @default(now()) @map("created_at")
  updatedAt DateTime @updatedAt @map("updated_at")

  // Relações
  companyRawMaterial      CompanyRawMaterial              @relation(fields: [rawMaterialId], references: [id], onDelete: Cascade)
  manufacturer            Manufacturer                    @relation(fields: [manufacturerId], references: [id])
  supplierEntity          RawMaterialSupplierEntity       @relation(fields: [supplierEntityId], references: [id])
  currentHalalCertification RawMaterialHalalCertification? @relation("CurrentCert", fields: [currentHalalCertificationId], references: [id], onDelete: SetNull)
  halalCertificationHistory RawMaterialHalalCertification[] @relation("HistoryCert")
  usesInFinalProducts     RawMaterialUseInFinalProduct[]
  fambrasReviewer         User?                           @relation("RawMaterialSupplierReviewer", fields: [fambrasReviewedBy], references: [id])
  scopeSuppliers          ScopeSupplier[]

  @@unique([rawMaterialId, manufacturerId, supplierEntityId])
  @@index([rawMaterialId])
  @@index([manufacturerId])
  @@index([supplierEntityId])
  @@index([currentHalalCertificationId])
  @@index([fambrasReviewStatus])
  @@index([isActive])
  @@map("raw_material_suppliers")
}
```

**Por que histórico de cert halal e não só campo plano?**
- Auditoria FAMBRAS exige rastreio "qual cert estava válida em DD/MM/AAAA quando você usou essa MP no lote X?".
- A planilha do cliente sobrescreve (perde histórico) — o sistema corrige isso.

### 2.7 `RawMaterialHalalCertification` — evidência halal (cert ou declaração)

```prisma
// EVIDÊNCIA HALAL PARA UM RawMaterialSupplier.
// Polimorfa por evidenceType:
//   certificate  → certifyingBodyId + certificateNumber + issueDate + validityDate + fileUrl
//   declaration  → declarationText + fileUrl (sem body)
//   pre_approved → referencia PreApprovedIntermediateMaterial (FAMBRAS whitelist)
//   none         → registro vazio para tornar explícito "verificado: sem cert"
model RawMaterialHalalCertification {
  id                    String                        @id @default(dbgenerated("uuid_generate_v4()")) @db.Uuid
  rawMaterialSupplierId String                        @map("raw_material_supplier_id") @db.Uuid
  evidenceType          RawMaterialHalalEvidenceType  @map("evidence_type")

  // Quando evidenceType=certificate
  certifyingBodyId   String?   @map("certifying_body_id") @db.Uuid
  certificateNumber  String?   @map("certificate_number") @db.VarChar(255)  // Col G
  issueDate          DateTime? @map("issue_date")                            // Col I
  validityDate       DateTime? @map("validity_date")                         // Col J

  // Quando evidenceType=declaration
  declarationText String? @map("declaration_text") @db.Text                 // Col H

  // Quando evidenceType=pre_approved
  preApprovedIntermediateMaterialId String? @map("pre_approved_intermediate_material_id") @db.Uuid

  // Arquivo digitalizado da evidência (PDF/imagem)
  fileUrl  String? @map("file_url") @db.Text
  fileSize Int?    @map("file_size")
  mimeType String? @map("mime_type") @db.VarChar(100)

  // Auditoria
  uploadedBy String?  @map("uploaded_by") @db.Uuid
  uploadedAt DateTime @default(now()) @map("uploaded_at")
  // Marca a cert que está VIGENTE (espelha currentHalalCertificationId; permite query
  // direta "todas evidências vigentes" sem precisar fazer self-join via RawMaterialSupplier).
  isCurrent Boolean @default(true) @map("is_current")

  createdAt DateTime @default(now()) @map("created_at")
  updatedAt DateTime @updatedAt @map("updated_at")

  rawMaterialSupplierAsCurrent RawMaterialSupplier[] @relation("CurrentCert")
  rawMaterialSupplier          RawMaterialSupplier   @relation("HistoryCert", fields: [rawMaterialSupplierId], references: [id], onDelete: Cascade)
  certifyingBody               HalalCertifyingBody?  @relation(fields: [certifyingBodyId], references: [id])
  preApprovedIntermediateMaterial PreApprovedIntermediateMaterial? @relation(fields: [preApprovedIntermediateMaterialId], references: [id])
  uploader                     User?                 @relation("RawMaterialHalalCertUploader", fields: [uploadedBy], references: [id])

  @@index([rawMaterialSupplierId])
  @@index([certifyingBodyId])
  @@index([evidenceType])
  @@index([validityDate])
  @@index([isCurrent])
  @@map("raw_material_halal_certifications")
}
```

### 2.8 `RawMaterialUseInFinalProduct` — junction MP → Product (col N)

```prisma
// MAPEAMENTO "QUAL PRODUTO FINAL USA ESTA MP?"
// Equivale aos blocos "linha mestre + N filhas só com col N" da planilha.
// Pode ser preenchido em dois níveis de granularidade:
//   1) Genérico: liga CompanyRawMaterial -> Product (sem distinguir fabricante/fornecedor)
//   2) Específico: liga RawMaterialSupplier -> Product (rastrabilidade fina:
//      "produto X usa essa MP DESSE fabricante específico")
// rawMaterialSupplierId é opcional; quando NULL, é o vínculo genérico.
model RawMaterialUseInFinalProduct {
  id                    String  @id @default(dbgenerated("uuid_generate_v4()")) @db.Uuid
  rawMaterialId         String  @map("raw_material_id") @db.Uuid
  rawMaterialSupplierId String? @map("raw_material_supplier_id") @db.Uuid
  productId             String  @map("product_id") @db.Uuid

  // Texto livre que o cliente preencheu na col N quando o Product ainda não existe
  // como cadastro (cliente escreve nome verbatim mas só depois alguém cria o Product).
  // Permite ingestão sem bloqueio.
  rawProductLabel String? @map("raw_product_label") @db.VarChar(500)

  notes String? @db.Text

  createdAt DateTime @default(now()) @map("created_at")
  updatedAt DateTime @updatedAt @map("updated_at")

  companyRawMaterial  CompanyRawMaterial   @relation(fields: [rawMaterialId], references: [id], onDelete: Cascade)
  rawMaterialSupplier RawMaterialSupplier? @relation(fields: [rawMaterialSupplierId], references: [id], onDelete: SetNull)
  product             Product              @relation(fields: [productId], references: [id], onDelete: Cascade)

  @@unique([rawMaterialId, rawMaterialSupplierId, productId])
  @@index([rawMaterialId])
  @@index([rawMaterialSupplierId])
  @@index([productId])
  @@map("raw_material_uses_in_final_product")
}
```

### 2.9 `PreApprovedIntermediateMaterial` — whitelist da aba INTERMEDIÁRIAS

```prisma
// LISTA DE INTERMEDIÁRIOS PRÉ-APROVADOS PELA FAMBRAS (códigos começam com "9").
// Whitelist global (não per-Company): quando uma CompanyRawMaterial referencia um item
// dessa lista via RawMaterialHalalCertification(evidenceType=pre_approved), não
// é necessário anexar cert halal — a aprovação prévia FAMBRAS cobre.
// Mantido pela role qualidade FAMBRAS.
model PreApprovedIntermediateMaterial {
  id           String   @id @default(dbgenerated("uuid_generate_v4()")) @db.Uuid
  code         String   @unique @db.VarChar(50)         // Col A — "9xxxxxxx"
  name         String   @db.VarChar(500)                // Col B
  approvedAt   DateTime @map("approved_at")             // Col C
  approvedBy   String   @map("approved_by") @db.VarChar(255) @default("FAMBRAS") // Col D
  // Observações internas FAMBRAS (origem, restrições de uso, mercados onde NÃO vale, etc.)
  notes        String?  @db.Text
  // País onde o pre-approval é válido. Default array vazio = global.
  validInCountries Country[] @default([]) @map("valid_in_countries")
  isActive     Boolean  @default(true) @map("is_active")

  createdAt DateTime @default(now()) @map("created_at")
  updatedAt DateTime @updatedAt @map("updated_at")

  rawMaterialHalalCertifications RawMaterialHalalCertification[]

  @@index([code])
  @@index([isActive])
  @@map("pre_approved_intermediate_materials")
}
```

### 2.10 `NonFoodInput` — aba OUTROS_OTHERS

```prisma
// INSUMOS NÃO-ALIMENTARES que tocam a linha de produção (embalagem, lubrificante,
// produto de limpeza, controle de pragas, tinta de carimbo). Equivale à aba
// "2. OUTROS_OTHERS" da planilha (82 linhas, 7 colunas).
// Modelado separado de CompanyRawMaterial porque o fluxo de homologação é menor
// (geralmente sem cert halal — análise de risco da formulação).
model NonFoodInput {
  id        String @id @default(dbgenerated("uuid_generate_v4()")) @db.Uuid
  companyId String @map("company_id") @db.Uuid

  category       NonFoodInputCategory
  genericName    String  @map("generic_name") @db.VarChar(500)     // Col C
  commercialName String  @map("commercial_name") @db.VarChar(500)  // Col D

  // Fabricante e fornecedor seguem o MESMO catálogo de Manufacturer/SupplierEntity
  // que os CompanyRawMaterial (evita duplicar entidades).
  manufacturerId   String? @map("manufacturer_id") @db.Uuid
  supplierEntityId String? @map("supplier_entity_id") @db.Uuid

  // Quando o cliente ainda não normalizou pro cadastro:
  manufacturerNameRaw String? @map("manufacturer_name_raw") @db.VarChar(255) // Col E
  supplierNameRaw     String? @map("supplier_name_raw") @db.VarChar(255)     // Col F

  remarks  String? @db.Text                                                    // Col G
  isActive Boolean @default(true) @map("is_active")

  createdAt DateTime @default(now()) @map("created_at")
  updatedAt DateTime @updatedAt @map("updated_at")

  company        Company                    @relation(fields: [companyId], references: [id], onDelete: Cascade)
  manufacturer   Manufacturer?              @relation(fields: [manufacturerId], references: [id])
  supplierEntity RawMaterialSupplierEntity? @relation("NonFoodInputSupplier", fields: [supplierEntityId], references: [id])

  @@index([companyId])
  @@index([category])
  @@index([manufacturerId])
  @@index([supplierEntityId])
  @@map("non_food_inputs")
}
```

### 2.11 `RevisionLog` — audit trail completo (decisão #7 do PO: Opção C)

**Justificativa de negócio:** FAMBRAS é body certificadora sob ISO/IEC 17065, auditada por acreditadores externos (GAC, JAKIM, MUIS, ESMA…). Audit trail por linha **não é nice-to-have, é requisito de acreditabilidade**. Sem isso, o próprio sistema vira non-conformity em auditoria externa.

```prisma
// AUDIT TRAIL COMPLETO — uma linha por mutação em entidade rastreada.
// Auditável por acreditador externo: GAC/JAKIM/MUIS/ESMA podem solicitar
// "mostre o histórico de mudanças na cert halal do fornecedor X entre
// DD/MM/AAAA e DD/MM/AAAA". O export PDF do drawer "Histórico" responde.
//
// Particionado por mutated_at (mensal) via pg_partman. Política:
//   - 24 meses online em Postgres
//   - >24 meses arquivado em S3 Glacier (gigantescamente barato, recuperável)
model RevisionLog {
  id            String               @id @default(dbgenerated("uuid_generate_v4()")) @db.Uuid
  entityType    String               @map("entity_type") @db.VarChar(80)
  entityId      String               @map("entity_id") @db.Uuid
  version       Int                                                       // sequencial por (entityType, entityId)
  mutationType  RevisionMutationType @map("mutation_type")
  dataSnapshot  Json                 @map("data_snapshot")                 // estado completo APÓS a mutação
  diff          Json?                                                      // delta campo-a-campo (derivável; cache)
  schemaVersion Int                  @default(1) @map("schema_version")    // permite evolução do shape de dataSnapshot
  mutatedById   String?              @map("mutated_by_id") @db.Uuid
  mutatedAt     DateTime             @default(now()) @map("mutated_at")
  reason        String?              @db.Text                              // ex: "Import FAM-0017 session abc", "Aprovação qualidade"
  importSessionId String?            @map("import_session_id") @db.Uuid    // amarra mudanças do mesmo import
  ipAddress     String?              @map("ip_address") @db.VarChar(45)    // IPv4/IPv6 — exigência de alguns acreditadores
  userAgent     String?              @map("user_agent") @db.VarChar(500)

  // Relações
  mutatedBy User? @relation("RevisionLogMutator", fields: [mutatedById], references: [id])

  @@index([entityType, entityId, version])
  @@index([importSessionId])
  @@index([mutatedAt])
  @@index([mutatedById])
  // PostgreSQL: PARTITION BY RANGE (mutated_at) — ver §4.5 plano de particionamento
  @@map("revision_logs")
}
```

**Modelos que participam do C (ganham `version: Int @default(1)` + são gravados em `RevisionLog` via interceptor Nest):**

Camada global FAMBRAS (qualidade edita, acreditador audita decisões):
- `RawMaterialMaster`
- `Manufacturer`
- `HalalCertifyingBody`
- `PreApprovedIntermediateMaterial`

Camada per-Company (cliente edita, FAMBRAS audita evidências):
- `CompanyRawMaterial`
- `RawMaterialSupplier`
- `RawMaterialHalalCertification`
- `RawMaterialSupplierEntity`
- `NonFoodInput`

**NÃO entram (justificativa explícita):**
- `ScopeSupplier` — cache derivado; mudanças refletem do canônico.
- `SupplierHomologation` — já tem audit trail próprio via timeline de status.
- `RevisionLog` em si — é write-once por design.

**Mecânica de implementação (resumo, detalhe fica em ADR separado):**
- Interceptor Nest global escuta `prisma.$use(middleware)` → captura toda mutação em modelos rastreados → grava `RevisionLog` async via `EventEmitter` (não bloqueia request).
- Snapshot é o objeto após a mutação (cheio, não delta). `diff` é gerado em background como cache.
- `version` é incrementado atomicamente via `UPDATE … SET version = version + 1` (optimistic concurrency).
- Endpoint `POST /entities/:type/:id/revert` aceita `toVersion: Int` + `reason: String` (obrigatório).
- Endpoint `POST /imports/:sessionId/revert` itera `RevisionLog WHERE importSessionId = X` e reverte cada entidade — bloqueia se houver mutações posteriores em outras sessões (conflito) e oferece "revert + replay manual".

### 2.12 Reverse relations a adicionar em modelos existentes

```prisma
// Company
companyRawMaterials             CompanyRawMaterial[]
rawMaterialSupplierEntities     RawMaterialSupplierEntity[]
nonFoodInputs                   NonFoodInput[]
proposedManufacturers           Manufacturer[]                   @relation("ManufacturerProposer")
proposedRawMaterialMasters      RawMaterialMaster[]              @relation("RawMaterialMasterProposer")

// Plant
linkedAsManufacturer            Manufacturer[]                   @relation("ManufacturerLinkedPlant")

// Product
rawMaterialUses                 RawMaterialUseInFinalProduct[]

// CriticalRawMaterial
companyRawMaterials             CompanyRawMaterial[]
rawMaterialMasters              RawMaterialMaster[]

// User
approvedManufacturers           Manufacturer[]                   @relation("ManufacturerApprover")
approvedRawMaterialMasters      RawMaterialMaster[]              @relation("RawMaterialMasterApprover")
reviewedRawMaterialSuppliers    RawMaterialSupplier[]            @relation("RawMaterialSupplierReviewer")
uploadedRawMaterialCerts        RawMaterialHalalCertification[]  @relation("RawMaterialHalalCertUploader")
revisionLogsMutated             RevisionLog[]                    @relation("RevisionLogMutator")

// SharedSupplier
rawMaterialSupplierEntities     RawMaterialSupplierEntity[]
```

---

## 3. Como `ScopeSupplier` evolui

### Caminho recomendado: **(c) coexistência com sync explícito + deprecação suave**

**Justificativa:**
- (a) FK direto de `ScopeSupplier` para `RawMaterialSupplier.id` quebra o front atual que lê os campos achatados (`halalCertificateNumber`, `manufacturerName`, etc.). O front HalalSphere usa esses campos em telas legadas de escopo.
- (b) VIEW PostgreSQL ofusca a modelagem na introspecção do Prisma — o Prisma não modela views como first-class; teríamos que usar `@@ignore`/raw queries para escrita. Atrito grande contra ganho marginal.
- (c) Coexistir + sync = zero breaking. Adicionamos um FK opcional `rawMaterialSupplierId` em `ScopeSupplier` e marcamos os 9 campos achatados como **legado** (via comentário "DEPRECATED — sincronizado de RawMaterialSupplier; remover quando o front migrar"). Service-layer faz sync bidirecional enquanto coexistirem.

**Mudanças concretas em `ScopeSupplier`:**

```prisma
// FORNECEDORES no escopo
model ScopeSupplier {
  // ... campos existentes mantidos como estão ...

  // NOVO: ponteiro opcional para o catálogo mestre.
  // Quando preenchido, os 9 campos halal abaixo são CACHE espelhado do
  // RawMaterialSupplier vigente (escrita via service-layer, com sync).
  rawMaterialSupplierId String? @map("raw_material_supplier_id") @db.Uuid

  // DEPRECATED (manter até o front migrar — sprint pós lançamento de MP catálogo):
  // halalCertificateNumber, halalIssueDate, halalValidityDate, hasHalalDeclaration,
  // manufacturerName, manufacturerAddress, isOriginalPackaging, riskLevel
  // ...
  rawMaterialSupplier RawMaterialSupplier? @relation(fields: [rawMaterialSupplierId], references: [id], onDelete: SetNull)

  @@index([rawMaterialSupplierId])
}
```

**Regra do service-layer:**
- POST/PUT em `ScopeSupplier` com `rawMaterialSupplierId` preenchido → backend reescreve os 9 campos halal com base no `RawMaterialSupplier` referenciado (cache);
- POST/PUT em `ScopeSupplier` sem `rawMaterialSupplierId` → comportamento legado (campos achatados ficam canônicos);
- Cron/job semanal alerta `ScopeSupplier` com `halalValidityDate` próximo de vencer **e** sem `rawMaterialSupplierId` (encoraja migração).

Mesma estratégia para `SupplierHomologation` — adicionar `rawMaterialSupplierId String?` opcional + marcar os 3 campos textuais como legado.

---

## 4. Plano de migration

### 4.1 Ordem das migrations (todas aditivas, zero `DROP`)

| # | Migration | Conteúdo |
|---|---|---|
| M1 | `20260526_raw_material_catalog_enums` | Cria enums `RawMaterialOrigin`, `RawMaterialHalalEvidenceType`, `NonFoodInputCategory`, `HalalCertifyingBodyRecognitionStatus`, **`GlobalCatalogApprovalStatus`**, **`RevisionMutationType`**. |
| M2 | `20260526_revision_logs` | Cria `revision_logs` particionada por `mutated_at` (mensal, pg_partman). Pré-cria 24 partições. |
| M3 | `20260526_halal_certifying_bodies` | Cria `halal_certifying_bodies` (+ `version`). |
| M4 | `20260526_manufacturers_global` | Cria `manufacturers` **global FAMBRAS** com workflow `approvalStatus` (+ `version`). |
| M5 | `20260526_raw_material_masters` | Cria `raw_material_masters` **global FAMBRAS** (+ `version`). |
| M6 | `20260526_raw_material_supplier_entities` | Cria `raw_material_supplier_entities` per-Company (depende de `companies`, `shared_suppliers`) (+ `version`). |
| M7 | `20260526_pre_approved_intermediate_materials` | Cria `pre_approved_intermediate_materials` (+ `version`). |
| M8 | `20260526_company_raw_materials` | Cria `company_raw_materials` (depende M5 `raw_material_masters` + `companies` + `critical_raw_materials`) (+ `version`). |
| M9 | `20260526_raw_material_suppliers` | Cria `raw_material_suppliers` (depende M4, M6, M8) (+ `version`). |
| M10 | `20260526_raw_material_halal_certifications` | Cria `raw_material_halal_certifications` (depende M9, M3, M7) (+ `version`). |
| M11 | `20260526_raw_material_supplier_current_cert_fk` | Adiciona FK `raw_material_suppliers.current_halal_certification_id` (FK circular resolvida em segunda passada). |
| M12 | `20260526_raw_material_uses_in_final_product` | Cria `raw_material_uses_in_final_product` (depende M8, M9, `products`). |
| M13 | `20260526_non_food_inputs` | Cria `non_food_inputs` (+ `version`). |
| M14 | `20260526_scope_supplier_raw_material_supplier_fk` | Adiciona coluna opcional `scope_suppliers.raw_material_supplier_id` + FK + índice. |
| M15 | `20260526_supplier_homologation_raw_material_supplier_fk` | Idem em `supplier_homologations`. |

**Por que `revision_logs` é a M2 (logo após enums)?** Para que toda mutação em M3+ seja registrada desde a primeira inserção (seeds inclusos). Particionamento mensal pré-criado evita rebuild gigante depois.

**Por que a FK circular em M11 separada?** `RawMaterialSupplier.currentHalalCertificationId → RawMaterialHalalCertification` e `RawMaterialHalalCertification.rawMaterialSupplierId → RawMaterialSupplier` formam ciclo. Postgres aceita se a coluna for nullable, mas Prisma migrate pode reclamar se tentar criar tudo no mesmo CREATE TABLE — separar em ALTER posterior.

### 4.5 Particionamento e arquivamento de `revision_logs`

- Particionamento `PARTITION BY RANGE (mutated_at)` em janelas mensais; pg_partman gerencia roll-forward.
- Política: 24 meses online + retenção indefinida via S3 Glacier (`hs-revision-archive/{yyyy-mm}.parquet.gz`).
- Restore on-demand: endpoint `POST /admin/revision-logs/restore?from=2024-03` puxa partição do S3 para uma tabela temporária consultável por 7 dias.
- Custo real estimado: 50 clientes × 2k linhas × 20 edições/ano × ~2KB/linha = ~4GB/ano em Postgres ativo (~24 meses) + arquivamento Glacier negligível (~U$0,40/ano).

### 4.2 Seeds necessários (ordem)

| Seed | Arquivo proposto | Fonte | Volume |
|---|---|---|---|
| S1 | `seed-halal-certifying-bodies.ts` | Lista normalizada das 77 strings distintas da col F + aliases. Curadoria manual obrigatória. | ~40 bodies (após dedup por aliases) |
| S2 | `seed-pre-approved-intermediate-materials.ts` | Aba INTERMEDIÁRIAS (CSV flatten em halalsphere-docs). | 231 itens |
| — | (não-seed) `NonFoodInputCategory` | Já vive no enum, sem tabela. | — |

### 4.3 Risco de duplicação entre 3 catálogos de MP

**Esclarecimento obrigatório no comentário do schema:**

| | `CriticalRawMaterial` (já existe) | `RawMaterialMaster` (novo, global) | `CompanyRawMaterial` (novo, per-Company) |
|---|---|---|---|
| **Dono** | FAMBRAS (qualidade) | FAMBRAS (qualidade) | Cliente industrial |
| **Escopo** | Por `IndustrialCategory.code` | Global (cross-Company) | Por Company |
| **Cardinalidade** | ~100-300 itens curados por categoria | ~1.500-3.000 substâncias canônicas | Centenas a milhares por Company |
| **Propósito** | "Quais ingredientes a FAMBRAS exige rastreio reforçado nessa categoria?" | "Dicionário canônico de substâncias" | "Quais MPs essa Company usa, com qual código interno?" |
| **Atualização** | Baixa frequência | Média (cliente propõe via import, qualidade aprova) | Alta (cliente edita livremente) |
| **Cross-check** | `RawMaterialMaster.criticalRawMaterialId` aponta para `CriticalRawMaterial` (curadoria manual). `CompanyRawMaterial.rawMaterialMasterId` aponta para o dicionário (matching automático + revisão). |

**Não há duplicação se a regra for clara na UI:** cliente vê só seu catálogo (`CompanyRawMaterial`); qualidade FAMBRAS vê os 3.

### 4.4 Regra crítica: sem termos haram em seed

- **Proibido em seeds/exemplos:** suíno, álcool etílico bebível, gordura suína, derivados de porco.
- **Permitido:** carne bovina, frango halal, gelatina bovina, ácido acético, lecitina de soja, carragena, goma xantana, ácido cítrico, glicerina vegetal, etc.
- Os 2603 itens da planilha real **contêm** menções a álcool como veículo de aroma — isso é tema legítimo da FM 7.4.2.16, mas: (i) **não importamos a planilha como seed**, só como dados de cliente em ambiente cliente; (ii) **seed canônico** que vai ao repo usa só itens halal-seguros.

---

## 5. Decisões validadas pelo PO (Renato) — 2026-05-25

| # | Pergunta | Decisão |
|---|---|---|
| 1 | Planilha pertence a `Certification` ou `Plant`? | **`Certification`** — vinculação ativa via `ScopeSupplier`. Reuso entre certs faz cliente apontar mesmo `RawMaterialSupplier` em ambas. |
| 2 | `RawMaterial` per-Company ou global? | **Global FAMBRAS** via `RawMaterialMaster` + mapeamento per-Company via `CompanyRawMaterial`. |
| 3 | `Manufacturer` global ou per-Company? | **Global FAMBRAS** com workflow `pending → approved`. Cliente não bloqueia: cadastra `pending`, FAMBRAS aprova/funde. |
| 4 | `SupplierHomologation` disparado da grid ou só wizard? | **Só via wizard** de Certification. Grid U7 reflete status, não dispara. |
| 5 | Sync `ScopeSupplier` ↔ `RawMaterialSupplier`? | **One-way pull** (catálogo → escopo). |
| 6 | `PreApprovedIntermediateMaterial` — seed ou CRUD? | **CRUD desde o início**. Mesmo padrão para todos os catálogos globais (admin hub). Role responsável: `qualidade`. |
| 7 | Reverter import — A/B/B+/**C**? | **Opção C** — versionamento completo via `RevisionLog`. Acreditabilidade ISO 17065 exige audit trail por linha. |
| 8 | MVP focado ou 2 caminhos completos (inline + import)? | **2 caminhos completos**. MVP não é alternativa. |

### Pendências menores

- **`RawMaterialSupplier.itemNumber` (Col A) — geração:** recomendação atual: auto-incremento por Company via sequence. Não chega a ser bloqueante; pode resolver na implementação.
- **Mapping automático `CompanyRawMaterial.rawMaterialMasterId`:** propor matching por similaridade pg_trgm + aliases na fase de import, com revisão manual da qualidade quando confiança < 0.85.

---

## 6. Anti-padrões a evitar

1. **Não criar enum `RiskLevel`.** A col K da planilha está contaminada (clientes preenchem "N/A", "SIM"). Validar isso via enum legitima dado ruim. A criticidade canônica vive em `CriticalRawMaterial.criticality` por categoria. Mantemos `ScopeSupplier.riskLevel` como string livre **deprecada**.

2. **Não inflar `SharedSupplier` para virar `RawMaterialSupplierEntity`.** São conceitos distintos: `SharedSupplier` é catálogo per-Group com workflow próprio de aprovação inter-Company. `RawMaterialSupplierEntity` é catálogo per-Company de fornecedores de MP. Ligá-los via FK opcional (`sharedSupplierId`) é suficiente e respeita o modelo de domínio existente.

3. **Não acoplar `Product.composition`.** Tentação: criar `ProductIngredient` ligando `Product → RawMaterial[]` com percentuais. **Não fazer agora.** A FM 7.4.2.7 só pede "essa MP é usada em qual produto?" (relação binária). Recipe/BoM completo é outro fluxo (FM 7.4.2.6 — formulação), fora do escopo deste schema. `RawMaterialUseInFinalProduct` é binária por design.

4. **Não importar a planilha real do cliente como seed do repo.** A planilha contém menções a álcool como veículo em aromas (legítimo regulatório, mas viola convenção halal-only do repo). Importação fica em job de upload do cliente em produção, não em `prisma/seed.ts`.

5. **Não promover `currentHalalCertificationId` a NOT NULL.** A col F da planilha tem "NÃO" em 323 linhas (sem cert). Modelar essa ausência via `evidenceType=none` ou cert NULL é correto — forçar NOT NULL quebraria a ingestão dos 12% de itens sem cert que existem na planilha real.

6. **Não usar `String` puro para `country` em `Manufacturer.country`.** Tentação: muitos fabricantes estrangeiros não aparecem no enum `Country` (que cobre só países onde FAMBRAS opera). Solução pragmática: usar o enum mesmo assim — adicionar países à `Country` é migração trivial; manter consistência vale o esforço.

7. **Não modelar `Country` como obrigatório em `HalalCertifyingBody`.** Bodies como WHFC, AHF e outras operam multi-jurisdição. `country` deve ser nullable (país-sede), e `recognizedInMarkets: Country[]` carrega a aplicabilidade real.

---

## 7. Resumo executivo (rev 2 pós-PO)

**Novos modelos (11):**

Camada global FAMBRAS:
`HalalCertifyingBody`, `Manufacturer` (com approval workflow), `RawMaterialMaster`, `PreApprovedIntermediateMaterial`.

Camada per-Company:
`RawMaterialSupplierEntity`, `CompanyRawMaterial`, `RawMaterialSupplier`, `RawMaterialHalalCertification`, `RawMaterialUseInFinalProduct`, `NonFoodInput`.

Audit:
`RevisionLog` (particionada por mês).

**Novos enums (6):**
`RawMaterialOrigin`, `RawMaterialHalalEvidenceType`, `NonFoodInputCategory`, `HalalCertifyingBodyRecognitionStatus`, `GlobalCatalogApprovalStatus`, `RevisionMutationType`.

**Modelos modificados (2):**
`ScopeSupplier` (+1 FK opcional, 9 campos marcados como deprecated em comentário), `SupplierHomologation` (+1 FK opcional).

**Reverse relations adicionadas:**
`Company`, `Plant`, `Product`, `CriticalRawMaterial`, `User`, `SharedSupplier`.

**Migrations:** 15 aditivas, zero breaking. `revision_logs` particionada por `mutated_at` com pg_partman + 24 partições pré-criadas.

**Seeds:** 2 (HalalCertifyingBody curado com ~40 bodies + PreApprovedIntermediateMaterial com 231 itens). `RawMaterialMaster` e `Manufacturer` começam vazios — populados gradualmente via imports + curadoria FAMBRAS.

**Versionamento (`version: Int` + `RevisionLog` participante) em 9 modelos:**
`RawMaterialMaster`, `Manufacturer`, `HalalCertifyingBody`, `PreApprovedIntermediateMaterial`, `CompanyRawMaterial`, `RawMaterialSupplier`, `RawMaterialHalalCertification`, `RawMaterialSupplierEntity`, `NonFoodInput`.

**Resposta para a tensão MP-FAMBRAS × MP-Cliente:** 3 camadas claras — `CriticalRawMaterial` (régua de criticidade por categoria) + `RawMaterialMaster` (dicionário canônico global) + `CompanyRawMaterial` (mapping per-Company).
