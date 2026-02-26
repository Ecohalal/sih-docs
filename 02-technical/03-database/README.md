# 3. Banco de Dados

---

## 3.1 Visao Geral

O SIH utiliza **PostgreSQL 16** como banco de dados relacional, gerenciado via **Prisma ORM** com migrações automaticas.

### Extensoes Habilitadas

| Extensao | Finalidade |
|----------|-----------|
| `uuid-ossp` | Geracao de UUID v4 para chaves primarias (`uuid_generate_v4()`) |
| `pgcrypto` | Funcoes criptograficas para hashing e encriptacao de dados sensiveis |
| `pg_trgm` | Busca por similaridade (trigram) para pesquisa textual aproximada |

### Resumo do Schema

| Item | Quantidade |
|------|-----------|
| Modelos (tabelas) | 10 (7 originais + Collaborator, CollaboratorPlant, ReportStaff) |
| Enums | 10 |
| Indices compostos | 18 |
| Constraints unique | 7 |

---

## 3.2 ERD (Diagrama Entidade-Relacionamento)

```
┌─────────────────────────┐
│   SupervisorProfile     │
│   (supervisor_profiles) │
│─────────────────────────│
│ PK id            UUID   │
│    externalUserId       │
│    name                 │
│    email         UNIQUE │
│    role          enum   │
│    phone                │
│    registration         │
│    qualifications JSON  │
│    preferences    JSON  │
│    isActive             │
│    lastLoginAt          │
│    created_at           │
│    updated_at           │
└────────┬────────────────┘
         │
         │ 1:N
         │
         ├──────────────────────────────────────────────────────────────────────┐
         │                                                                      │
         │          ┌──────────────────────────┐                                │
         │          │        Plant              │                                │
         │          │       (plants)            │                                │
         │          │──────────────────────────│                                │
         │          │ PK id             UUID   │                                │
         │          │    externalCompanyId     │                                │
         │          │    name                  │                                │
         │          │    sifCode       UNIQUE  │                                │
         │          │    type           enum   │                                │
         │          │    address         JSON  │                                │
         │          │    contact         JSON  │                                │
         │          │    species      enum[]   │                                │
         │          │    isActive              │                                │
         │          │    created_at            │                                │
         │          │    updated_at            │                                │
         │          └────────┬─────────────────┘                                │
         │                   │                                                  │
         │                   │ 1:N                                              │
         │                   │                                                  │
    ┌────┴───────────────────┴──────────────────────────────────────┐           │
    │                                                               │           │
    │  ┌──────────────────────────────┐  ┌────────────────────────────────┐     │
    │  │     SlaughterReport          │  │     ProductionReport           │     │
    │  │    (slaughter_reports)       │  │    (production_reports)        │     │
    │  │──────────────────────────────│  │────────────────────────────────│     │
    │  │ PK id              UUID     │  │ PK id              UUID       │     │
    │  │    serialNumber    UNIQUE   │  │    serialNumber    UNIQUE     │     │
    │  │    formNumber               │  │    formNumber                 │     │
    │  │ FK plantId         UUID ────│──│ FK plantId         UUID ──────│─┐   │
    │  │ FK supervisorId    UUID ────│──│ FK supervisorId    UUID ──────│─│───┘
    │  │    date            Date     │  │    productionStart            │ │
    │  │    shift           enum     │  │    productionEnd              │ │
    │  │    species          enum    │  │    shiftsCount                │ │
    │  │    totalAnimals             │  │    meatRawMaterials    JSON   │ │
    │  │    approvedAnimals          │  │    productName                │ │
    │  │    rejectedAnimals          │  │    totalProduced      Dec    │ │
    │  │    verificationItems JSON   │  │    verificationItems  JSON   │ │
    │  │    status           enum    │  │    status             enum   │ │
    │  │    created_at               │  │    created_at                │ │
    │  │    updated_at               │  │    updated_at                │ │
    │  └──────────┬──────────────────┘  └──────────┬───────────────────┘ │
    │             │ 1:N                            │ 1:N                 │
    │             │                                │                     │
    │             │    ┌───────────────────────┐    │                     │
    │             │    │    NonConformity      │    │                     │
    │             │    │  (non_conformities)   │    │                     │
    │             │    │───────────────────────│    │                     │
    │             │    │ PK id          UUID   │    │                     │
    │             ├───►│ FK plantId     UUID   │◄───┤                     │
    │             │    │ FK supervisorId UUID  │    │                     │
    │             └───►│ FK slaughterReportId? │    │                     │
    │                  │ FK productionReportId?│◄───┘                     │
    │                  │ FK shippingReportId?  │◄──────┐                  │
    │                  │    description        │       │                  │
    │                  │    severity    enum   │       │                  │
    │                  │    category           │       │                  │
    │                  │    evidence    JSON   │       │                  │
    │                  │    status      enum   │       │                  │
    │                  │    created_at         │       │                  │
    │                  │    updated_at         │       │                  │
    │                  └───────────────────────┘       │                  │
    │                                                  │                  │
    │  ┌──────────────────────────────┐                │                  │
    │  │     ShippingReport           │                │                  │
    │  │    (shipping_reports)        │                │                  │
    │  │──────────────────────────────│                │                  │
    │  │ PK id              UUID     │                │                  │
    │  │    serialNumber    UNIQUE   │                │                  │
    │  │    formNumber               │                │                  │
    │  │    shippingType    enum     │                │                  │
    │  │ FK plantId         UUID ────│────────────────│──────────────────┘
    │  │ FK supervisorId    UUID ────│────────────────┘
    │  │    loadingDate     Date     │
    │  │    transportType   enum     │
    │  │    products         JSON    │
    │  │    verificationItems JSON   │
    │  │    status           enum    │
    │  │    created_at               │
    │  │    updated_at               │
    │  └─────────────────────────────┘
    │
    │  ┌──────────────────────────────┐
    │  │   SupervisorSchedule         │
    │  │  (supervisor_schedules)      │
    │  │──────────────────────────────│
    │  │ PK id              UUID     │
    │  │ FK supervisorId    UUID ────│──► SupervisorProfile
    │  │ FK plantId         UUID ────│──► Plant
    │  │    date            Date     │
    │  │    shift           enum     │
    │  │    type            enum     │
    │  │    notes                    │
    │  │    created_at               │
    │  │    updated_at               │
    │  │                             │
    │  │  UNIQUE(supervisorId,       │
    │  │    plantId, date, shift)    │
    │  └─────────────────────────────┘
    │
    └──────────────────────────────────────────────────────────────────────
```

### Resumo dos Relacionamentos

| Relacao | Tipo | FK | Descricao |
|---------|------|-----|-----------|
| SupervisorProfile → SlaughterReport | 1:N | `supervisorId` | Supervisor autor do relatorio de abate |
| SupervisorProfile → ProductionReport | 1:N | `supervisorId` | Supervisor autor do relatorio de producao |
| SupervisorProfile → ShippingReport | 1:N | `supervisorId` | Supervisor autor do relatorio de embarque |
| SupervisorProfile → NonConformity | 1:N | `supervisorId` | Supervisor que registrou a NC |
| SupervisorProfile → SupervisorSchedule | 1:N | `supervisorId` | Escala do supervisor |
| Plant → SlaughterReport | 1:N | `plantId` | Relatorios de abate na planta |
| Plant → ProductionReport | 1:N | `plantId` | Relatorios de producao na planta |
| Plant → ShippingReport | 1:N | `plantId` | Relatorios de embarque na planta |
| Plant → NonConformity | 1:N | `plantId` | NCs registradas na planta |
| Plant → SupervisorSchedule | 1:N | `plantId` | Escalas na planta |
| SlaughterReport → NonConformity | 1:N | `slaughterReportId` | NCs vinculadas a abate (opcional) |
| ProductionReport → NonConformity | 1:N | `productionReportId` | NCs vinculadas a producao (opcional) |
| ShippingReport → NonConformity | 1:N | `shippingReportId` | NCs vinculadas a embarque (opcional) |
| Collaborator → CollaboratorPlant | 1:N | `collaboratorId` | Plantas onde o colaborador atua (planejado) |
| Plant → CollaboratorPlant | 1:N | `plantId` | Colaboradores vinculados a planta (planejado) |
| Collaborator → ReportStaff | 1:N | `collaboratorId` | Relatorios onde o colaborador atuou (planejado) |

---

## 3.3 Enums

### UserRole
Papeis de usuario no sistema.

| Valor | Descricao |
|-------|-----------|
| `admin` | Administrador do sistema com acesso total |
| `coordenador` | Coordenador de supervisores: gerencia escalas, cria/edita usuarios, visualiza relatorios (read-only), cancela relatorios, gerencia NCs. NAO assina relatorios |
| `supervisor` | Supervisor Halal que preenche e assina relatorios nas plantas |
| `operador` | Operador que preenche relatorios mas NAO pode assinar |
| `gestor` | (legado — NAO USADO na v1.0) |

### Species
Especies animais cobertas pela supervisao Halal na v1.0. Apenas bovino e ave possuem formularios FM implementados.

| Valor | Descricao | FM |
|-------|-----------|-----|
| `bovino` | Bovinos (gado) | FM 7.1.4.2 |
| `ave` | Aves (frango, peru) | FM 7.1.4.1 |

> **Nota**: As demais especies (ovino, caprino, bubalino, equino, peixe) foram suprimidas na v1.0 pois nao possuem FM especifico implementado. Poderao ser adicionadas em versoes futuras.

### Shift
Turnos de trabalho na planta industrial.

| Valor | Descricao |
|-------|-----------|
| `matutino` | Turno da manha |
| `vespertino` | Turno da tarde |
| `noturno` | Turno da noite |
| `integral` | Turno integral (dia completo) |

### PlantType
Tipo de planta industrial.

| Valor | Descricao |
|-------|-----------|
| `abatedouro` | Estabelecimento de abate |
| `frigorifico` | Frigorifico (abate + processamento) |
| `laticinio` | Laticinio |
| `processamento` | Unidade de processamento de alimentos |
| `armazenamento` | Unidade de armazenamento a frio |
| `outro` | Outros tipos de estabelecimento |

### ReportStatus
Status do ciclo de vida dos relatorios (Abate, Producao, Embarque). Workflow simplificado: rascunho → assinado (final). NAO ha etapa de aprovacao.

| Valor | Descricao |
|-------|-----------|
| `rascunho` | Relatorio em edicao, nao assinado |
| `assinado` | Assinado pelo supervisor (estado final — imutavel) |
| `cancelado` | Cancelado pelo coordenador/admin (com motivo obrigatorio) |

> **Nota**: Os valores `enviado`, `revisado`, `aprovado`, `rejeitado` existem no enum do Prisma por compatibilidade mas NAO sao usados no workflow v1.0. A assinatura e o unico passo de finalizacao.

### ShippingType
Tipo de movimentacao de embarque/venda.

| Valor | Descricao |
|-------|-----------|
| `exportacao` | Exportacao para mercado externo |
| `venda_interna` | Venda no mercado interno |
| `transferencia` | Transferencia entre unidades |

### TransportType
Tipo de transporte utilizado no embarque.

| Valor | Descricao |
|-------|-----------|
| `terrestre` | Transporte rodoviario/ferroviario |
| `aereo` | Transporte aereo |
| `maritimo` | Transporte maritimo |

### Severity
Grau de severidade de uma Nao-Conformidade.

| Valor | Descricao |
|-------|-----------|
| `critica` | Risco imediato a conformidade Halal; requer acao imediata |
| `maior` | Desvio significativo de processo; acao em 24h |
| `menor` | Desvio pontual sem impacto direto; acao em 7 dias |
| `observacao` | Ponto de atencao para melhoria continua |

### NCStatus
Status do ciclo de vida de uma Nao-Conformidade.

| Valor | Descricao |
|-------|-----------|
| `aberta` | NC registrada, aguardando tratamento |
| `em_tratamento` | Acao corretiva em andamento |
| `resolvida` | Acao corretiva implementada, aguardando verificacao |
| `verificada` | Verificado que a acao corretiva foi efetiva |
| `encerrada` | NC encerrada definitivamente |

### ScheduleType
Tipo de alocacao na escala de supervisores.

| Valor | Descricao |
|-------|-----------|
| `regular` | Escala regular/planejada |
| `substituicao` | Substituicao de outro supervisor |
| `extra` | Escala adicional/hora extra |
| `folga` | Dia de folga programada |

---

## 3.4 Dicionario de Dados

### 3.4.1 SupervisorProfile (`supervisor_profiles`)

Perfil do usuario no sistema. Na v1.0, a autenticacao e self-contained (bcrypt + JWT HS256). O campo `passwordHash` armazena o hash bcrypt da senha. O campo `externalUserId` esta preparado para integracao futura com HalalSphere.

| Campo | Tipo | Nullable | Default | Descricao |
|-------|------|----------|---------|-----------|
| `id` | UUID | Nao | `uuid_generate_v4()` | Chave primaria |
| `externalUserId` | String | Nao | - | ID externo (preparado para integracao com HalalSphere; na v1.0, igual ao `id`) |
| `name` | String | Nao | - | Nome completo do supervisor |
| `email` | String | Nao | - | Email do supervisor (usado para login) |
| `role` | UserRole | Nao | `supervisor` | Papel do usuario no sistema |
| `phone` | String | Sim | - | Telefone de contato |
| `registration` | String | Sim | - | Numero de registro profissional / matricula |
| `qualifications` | Json | Sim | - | Qualificacoes e certificacoes (formato livre JSON) |
| `preferences` | Json | Sim | - | Preferencias do usuario (tema, notificacoes, idioma, etc.) |
| `isActive` | Boolean | Nao | `true` | Se o supervisor esta ativo no sistema |
| `lastLoginAt` | DateTime | Sim | - | Data/hora do ultimo login |
| `created_at` | DateTime | Nao | `now()` | Data de criacao do registro |
| `updated_at` | DateTime | Nao | auto | Data da ultima atualizacao (gerenciado pelo Prisma) |

**Constraints:**
- `UNIQUE` em `externalUserId`
- `UNIQUE` em `email`

**Indices:** Nenhum indice composto adicional (indices unicos ja cobrem as buscas por `externalUserId` e `email`).

---

### 3.4.2 Plant (`plants`)

Planta industrial (abatedouro, frigorifico, etc.) onde a supervisao Halal e realizada.

| Campo | Tipo | Nullable | Default | Descricao |
|-------|------|----------|---------|-----------|
| `id` | UUID | Nao | `uuid_generate_v4()` | Chave primaria |
| `externalCompanyId` | String | Sim | - | ID da empresa no sistema externo (ERP/cadastro) |
| `name` | String | Nao | - | Nome da planta industrial |
| `sifCode` | String | Nao | - | Codigo SIF (Servico de Inspecao Federal) da planta |
| `type` | PlantType | Nao | - | Tipo de estabelecimento |
| `address` | Json | Sim | - | Endereco completo (logradouro, cidade, estado, CEP, coordenadas) |
| `contact` | Json | Sim | - | Dados de contato (telefone, email, responsavel) |
| `species` | Species[] | Nao | - | Lista de especies abatidas/processadas na planta |
| `isActive` | Boolean | Nao | `true` | Se a planta esta ativa no sistema |
| `created_at` | DateTime | Nao | `now()` | Data de criacao do registro |
| `updated_at` | DateTime | Nao | auto | Data da ultima atualizacao |

**Constraints:**
- `UNIQUE` em `sifCode`

**Indices:** Nenhum indice composto adicional (indice unico em `sifCode` cobre a busca principal).

---

### 3.4.3 SlaughterReport (`slaughter_reports`)

Relatorio de acompanhamento de abate Halal (FM 7.1.4.1 para aves, FM 7.1.4.2 para bovinos). Um unico modelo cobre todas as especies, diferenciado pelo campo `species`. Bovinos possuem secao adicional de insensibilizacao.

| Campo | Tipo | Nullable | Default | Descricao |
|-------|------|----------|---------|-----------|
| `id` | UUID | Nao | `uuid_generate_v4()` | Chave primaria |
| `serialNumber` | String | Nao | - | Numero serial unico (formato: SIF/ANO/SEQ) |
| `formNumber` | String | Nao | - | Numero do formulario FM (ex: "FM 7.1.4.1") |
| `plantId` | UUID | Nao | - | FK para Plant - planta onde ocorreu o abate |
| `supervisorId` | UUID | Nao | - | FK para SupervisorProfile - supervisor responsavel |
| `date` | Date | Nao | - | Data do abate |
| `shift` | Shift | Nao | - | Turno do abate |
| `species` | Species | Nao | - | Especie abatida |
| `slaughtererName` | String | Sim | - | Nome do degolador/abatedor |
| `slaughtererDoc` | String | Sim | - | Documento de identificacao do degolador |
| `totalAnimals` | Int | Nao | - | Total de animais abatidos |
| `approvedAnimals` | Int | Nao | - | Quantidade de animais aprovados |
| `rejectedAnimals` | Int | Nao | `0` | Quantidade de animais rejeitados |
| `rejectedSequence` | String | Sim | - | Sequencia numerica dos animais rejeitados |
| `stunningUsed` | Boolean | Sim | - | Se insensibilizacao foi utilizada (bovinos) |
| `stunningEvaluation` | String | Sim | - | Avaliacao da pressao de insensibilizacao |
| `stunningVerifications` | Json | Sim | - | Verificacoes de insensibilizacao (2 por turno) |
| `coolingCarcasses` | Int | Sim | - | Quantidade de carcacas em resfriamento |
| `coolingCameras` | String | Sim | - | Identificacao das camaras de resfriamento |
| `byproductsSold` | Boolean | Sim | - | Se houve venda de subprodutos |
| `byproductsDescription` | String | Sim | - | Descricao dos subprodutos vendidos |
| `verificationItems` | Json | Nao | - | 14 itens de verificacao C/NC (conformidade) |
| `observations` | String | Sim | - | Observacoes gerais |
| `status` | ReportStatus | Nao | `rascunho` | Status atual do relatorio |
| `cancelledReason` | String | Sim | - | Motivo do cancelamento (quando status=cancelado) |
| `replacedBy` | String | Sim | - | Serial do relatorio substituto |
| `reviewedBy` | UUID | Sim | - | ID do coordenador que revisou |
| `reviewedAt` | DateTime | Sim | - | Data/hora da revisao |
| `created_at` | DateTime | Nao | `now()` | Data de criacao do registro |
| `updated_at` | DateTime | Nao | auto | Data da ultima atualizacao |

**Constraints:**
- `UNIQUE` em `serialNumber`

**Indices:**
- `(plantId, date)` - Busca de relatorios por planta e data
- `(supervisorId, date)` - Busca de relatorios por supervisor e data
- `(status)` - Filtragem por status do relatorio

---

### 3.4.4 ProductionReport (`production_reports`)

Relatorio de acompanhamento de producao de industrializados Halal (FM 7.1.3.1) e producao especial (FM 7.1.8.x). Rastreia materias-primas, ingredientes e dados do produto final.

| Campo | Tipo | Nullable | Default | Descricao |
|-------|------|----------|---------|-----------|
| `id` | UUID | Nao | `uuid_generate_v4()` | Chave primaria |
| `serialNumber` | String | Nao | - | Numero serial unico (formato: SIF/ANO/SEQ) |
| `formNumber` | String | Nao | - | Numero do formulario FM (ex: "FM 7.1.3.1") |
| `plantId` | UUID | Nao | - | FK para Plant - planta onde ocorreu a producao |
| `supervisorId` | UUID | Nao | - | FK para SupervisorProfile - supervisor responsavel |
| `productionStart` | DateTime | Nao | - | Data/hora de inicio da producao |
| `productionEnd` | DateTime | Nao | - | Data/hora de fim da producao |
| `shiftsCount` | Int | Nao | - | Numero de turnos utilizados na producao |
| `meatRawMaterials` | Json | Nao | - | Tabela de materias-primas carneas (frigorifico, SIF, data abate, CSN, certificado Halal) |
| `approvedIngredients` | Json | Sim | - | Tabela de ingredientes aprovados nao-carneos (fornecedor, lote, validade) |
| `productName` | String | Nao | - | Nome do produto final |
| `productCode` | String | Sim | - | Codigo do produto |
| `productBatch` | String | Sim | - | Numero do lote do produto |
| `manufacturingDate` | Date | Sim | - | Data de fabricacao |
| `expiryDate` | Date | Sim | - | Data de validade |
| `totalProduced` | Decimal(12,3) | Sim | - | Quantidade total produzida (kg ou unidades) |
| `packageType` | String | Sim | - | Tipo de embalagem |
| `packageCount` | Int | Sim | - | Quantidade de embalagens |
| `netWeightKg` | Decimal(12,3) | Sim | - | Peso liquido total em kg |
| `grossWeightKg` | Decimal(12,3) | Sim | - | Peso bruto total em kg |
| `verificationItems` | Json | Nao | - | 5 itens de verificacao C/NC (conformidade) |
| `observations` | String | Sim | - | Observacoes gerais |
| `isSpecialProduction` | Boolean | Nao | `false` | Flag para producao especial (FM 7.1.8.x) |
| `status` | ReportStatus | Nao | `rascunho` | Status atual do relatorio |
| `cancelledReason` | String | Sim | - | Motivo do cancelamento |
| `replacedBy` | String | Sim | - | Serial do relatorio substituto |
| `reviewedBy` | UUID | Sim | - | ID do coordenador que revisou |
| `reviewedAt` | DateTime | Sim | - | Data/hora da revisao |
| `created_at` | DateTime | Nao | `now()` | Data de criacao do registro |
| `updated_at` | DateTime | Nao | auto | Data da ultima atualizacao |

**Constraints:**
- `UNIQUE` em `serialNumber`

**Indices:**
- `(plantId, productionStart)` - Busca de relatorios por planta e periodo de producao
- `(supervisorId, productionStart)` - Busca de relatorios por supervisor e periodo
- `(status)` - Filtragem por status do relatorio

---

### 3.4.5 ShippingReport (`shipping_reports`)

Relatorio de embarque, venda ou transferencia de produtos Halal. Unifica 3 tipos de movimentacao (FM 7.1.7.1 Exportacao, FM 7.1.7.4 Venda Interna, DCPOA Transferencia) em um unico modelo diferenciado por `shippingType`.

| Campo | Tipo | Nullable | Default | Descricao |
|-------|------|----------|---------|-----------|
| `id` | UUID | Nao | `uuid_generate_v4()` | Chave primaria |
| `serialNumber` | String | Nao | - | Numero serial unico (formato: SIF/ANO/SEQ) |
| `formNumber` | String | Nao | - | Numero do formulario FM |
| `shippingType` | ShippingType | Nao | - | Tipo de movimentacao (exportacao, venda_interna, transferencia) |
| `plantId` | UUID | Nao | - | FK para Plant - planta de origem |
| `supervisorId` | UUID | Nao | - | FK para SupervisorProfile - supervisor responsavel |
| `loadingDate` | Date | Nao | - | Data do carregamento |
| `exporter` | String | Sim | - | Razao social do exportador (exportacao) |
| `slaughterhouseInfo` | String | Sim | - | Informacoes do abatedouro de origem |
| `productionUnitInfo` | String | Sim | - | Informacoes da unidade de producao |
| `loadingAddress` | String | Sim | - | Endereco de carregamento |
| `importer` | String | Sim | - | Razao social do importador (exportacao) |
| `transportType` | TransportType | Sim | - | Tipo de transporte (terrestre, aereo, maritimo) |
| `embarkationPort` | String | Sim | - | Porto/ponto de embarque (exportacao) |
| `vehicleId` | String | Sim | - | Identificacao do veiculo (placa, numero voo, etc.) |
| `containerNumber` | String | Sim | - | Numero do container |
| `destinationPort` | String | Sim | - | Porto de destino (exportacao) |
| `destinationCountry` | String | Sim | - | Pais de destino (exportacao) |
| `orderNumber` | String | Sim | - | Numero do pedido/ordem de compra |
| `csiNumber` | String | Sim | - | Numero do CSI (Certificado Sanitario Internacional) |
| `sealNumber` | String | Sim | - | Numero do lacre |
| `products` | Json | Nao | - | Lista de produtos embarcados (produto, codigo, lote, datas, pesos, temperatura) |
| `verificationItems` | Json | Nao | - | 2 itens de verificacao C/NC (exclusividade Halal no container + selo) |
| `observations` | String | Sim | - | Observacoes gerais |
| `status` | ReportStatus | Nao | `rascunho` | Status atual do relatorio |
| `cancelledReason` | String | Sim | - | Motivo do cancelamento |
| `replacedBy` | String | Sim | - | Serial do relatorio substituto |
| `reviewedBy` | UUID | Sim | - | ID do coordenador que revisou |
| `reviewedAt` | DateTime | Sim | - | Data/hora da revisao |
| `created_at` | DateTime | Nao | `now()` | Data de criacao do registro |
| `updated_at` | DateTime | Nao | auto | Data da ultima atualizacao |

**Constraints:**
- `UNIQUE` em `serialNumber`

**Indices:**
- `(plantId, loadingDate)` - Busca de relatorios por planta e data de carregamento
- `(supervisorId, loadingDate)` - Busca de relatorios por supervisor e data
- `(shippingType, status)` - Filtragem por tipo de embarque e status

---

### 3.4.6 NonConformity (`non_conformities`)

Registro de nao-conformidade identificada durante a supervisao Halal (FM 7.1.6.1). Pode ser vinculada a qualquer tipo de relatorio (abate, producao, embarque) ou registrada de forma avulsa. Implementa o prazo de 7 dias corridos conforme PR 7.1.

| Campo | Tipo | Nullable | Default | Descricao |
|-------|------|----------|---------|-----------|
| `id` | UUID | Nao | `uuid_generate_v4()` | Chave primaria |
| `plantId` | UUID | Nao | - | FK para Plant - planta onde a NC foi identificada |
| `supervisorId` | UUID | Nao | - | FK para SupervisorProfile - supervisor que registrou |
| `slaughterReportId` | UUID | Sim | - | FK para SlaughterReport - vinculo opcional a relatorio de abate |
| `productionReportId` | UUID | Sim | - | FK para ProductionReport - vinculo opcional a relatorio de producao |
| `shippingReportId` | UUID | Sim | - | FK para ShippingReport - vinculo opcional a relatorio de embarque |
| `description` | String | Nao | - | Descricao detalhada da nao-conformidade |
| `severity` | Severity | Nao | - | Grau de severidade (critica, maior, menor, observacao) |
| `category` | String | Nao | - | Categoria da NC (higiene, processo, equipamento, materia-prima, rotulagem, etc.) |
| `evidence` | Json | Sim | - | Evidencias (fotos, descricoes, referencias documentais) |
| `correctiveAction` | String | Sim | - | Descricao da acao corretiva implementada |
| `preventiveAction` | String | Sim | - | Descricao da acao preventiva proposta |
| `deadline` | DateTime | Sim | - | Prazo para resolucao (padrao: 7 dias corridos) |
| `resolvedAt` | DateTime | Sim | - | Data/hora em que a NC foi resolvida |
| `resolvedBy` | UUID | Sim | - | ID de quem registrou a resolucao |
| `verifiedAt` | DateTime | Sim | - | Data/hora da verificacao da resolucao |
| `verifiedBy` | UUID | Sim | - | ID de quem verificou a resolucao |
| `status` | NCStatus | Nao | `aberta` | Status atual da NC |
| `created_at` | DateTime | Nao | `now()` | Data de criacao do registro |
| `updated_at` | DateTime | Nao | auto | Data da ultima atualizacao |

**Constraints:** Nenhuma constraint unique adicional.

**Indices:**
- `(plantId, status)` - Busca de NCs por planta e status
- `(severity, status)` - Busca de NCs por severidade e status
- `(supervisorId)` - Busca de NCs por supervisor

---

### 3.4.7 SupervisorSchedule (`supervisor_schedules`)

Escala de trabalho dos supervisores nas plantas industriais. Permite ao coordenador alocar supervisores por planta, turno e dia.

| Campo | Tipo | Nullable | Default | Descricao |
|-------|------|----------|---------|-----------|
| `id` | UUID | Nao | `uuid_generate_v4()` | Chave primaria |
| `supervisorId` | UUID | Nao | - | FK para SupervisorProfile - supervisor alocado |
| `plantId` | UUID | Nao | - | FK para Plant - planta de alocacao |
| `date` | Date | Nao | - | Data da escala |
| `shift` | Shift | Nao | - | Turno alocado |
| `type` | ScheduleType | Nao | `regular` | Tipo de alocacao (regular, substituicao, extra, folga) |
| `notes` | String | Sim | - | Observacoes sobre a alocacao |
| `created_at` | DateTime | Nao | `now()` | Data de criacao do registro |
| `updated_at` | DateTime | Nao | auto | Data da ultima atualizacao |

**Constraints:**
- `UNIQUE` composto em `(supervisorId, plantId, date, shift)` - Garante que um supervisor nao pode ter duplicidade de alocacao na mesma planta, data e turno

**Indices:**
- `(supervisorId, date)` - Busca de escala por supervisor e data
- `(plantId, date)` - Busca de escala por planta e data

---

### 3.4.8 Collaborator (`collaborators`) — Planejado

Cadastro de colaboradores operacionais que atuam nas plantas mas nao sao usuarios do sistema (degoladores, sheiks, auxiliares, veterinarios). Modelo planejado para implementacao futura com campo `externalId` para integracao com HalalSphere.

| Campo | Tipo | Nullable | Default | Descricao |
|-------|------|----------|---------|-----------|
| `id` | UUID | Nao | `uuid_generate_v4()` | Chave primaria |
| `externalId` | String | Sim | - | ID no sistema externo (HalalSphere) para integracao futura |
| `name` | String | Nao | - | Nome completo do colaborador |
| `document` | String | Nao | - | Documento de identificacao (RG, CPF ou passaporte) |
| `documentType` | String | Nao | `rg` | Tipo do documento: rg, cpf, passaporte |
| `role` | String | Nao | - | Funcao: degolador, sheik, auxiliar, supervisor_planta, veterinario |
| `photoUrl` | String | Sim | - | URL/path da foto do colaborador (S3 em producao, local em dev) |
| `phone` | String | Sim | - | Telefone de contato |
| `email` | String | Sim | - | Email de contato |
| `isActive` | Boolean | Nao | `true` | Se o colaborador esta ativo |
| `created_at` | DateTime | Nao | `now()` | Data de criacao do registro |
| `updated_at` | DateTime | Nao | auto | Data da ultima atualizacao |

**Constraints:**
- `UNIQUE` em `externalId` (quando presente)

**Foto do colaborador:**
- Upload via `POST /collaborators/:id/photo` (multipart/form-data)
- Formatos aceitos: JPEG, PNG (max 2MB)
- Armazenamento: `uploads/collaborators/` em dev, S3 em producao
- `photoUrl` armazena o path relativo ou URL S3

---

### 3.4.9 CollaboratorPlant (`collaborator_plants`) — Planejado

Tabela de ligacao N:N entre colaboradores e plantas onde atuam.

| Campo | Tipo | Nullable | Default | Descricao |
|-------|------|----------|---------|-----------|
| `collaboratorId` | UUID | Nao | - | FK para Collaborator |
| `plantId` | UUID | Nao | - | FK para Plant |

**Constraints:**
- `PRIMARY KEY` composta em `(collaboratorId, plantId)`

---

### 3.4.10 ReportStaff (`report_staff`) — Planejado

Vinculacao N:N entre colaboradores e relatorios, registrando a equipe que atuou em cada dia/relatorio especifico.

| Campo | Tipo | Nullable | Default | Descricao |
|-------|------|----------|---------|-----------|
| `id` | UUID | Nao | `uuid_generate_v4()` | Chave primaria |
| `collaboratorId` | UUID | Nao | - | FK para Collaborator |
| `reportId` | UUID | Nao | - | ID do relatorio (abate, producao ou embarque) |
| `reportType` | String | Nao | - | Tipo: slaughter, production, shipping |
| `roleInReport` | String | Nao | - | Funcao especifica naquele dia/relatorio |
| `date` | DateTime | Nao | - | Data do servico |

**Indices:**
- `(reportId, reportType)` — Busca de equipe por relatorio
- `(collaboratorId, date)` — Historico de atuacao do colaborador

---

## 3.5 Convencoes

### 3.5.1 Chaves Primarias

- Todas as tabelas utilizam **UUID v4** como chave primaria
- Gerado no banco via `uuid_generate_v4()` (extensao `uuid-ossp`)
- Tipo Postgres: `UUID`
- Motivo: evitar enumeracao sequencial, seguranca em APIs publicas, compatibilidade com sistemas distribuidos

### 3.5.2 Nomenclatura de Tabelas

- Prisma Models usam **PascalCase** (ex: `SlaughterReport`)
- Tabelas no Postgres usam **snake_case** via `@@map()` (ex: `slaughter_reports`)
- Mapeamento completo:

| Model (Prisma) | Tabela (Postgres) | Status |
|-----------------|-------------------|--------|
| SupervisorProfile | `supervisor_profiles` | Implementado |
| Plant | `plants` | Implementado |
| SlaughterReport | `slaughter_reports` | Implementado |
| ProductionReport | `production_reports` | Implementado |
| ShippingReport | `shipping_reports` | Implementado |
| NonConformity | `non_conformities` | Implementado |
| SupervisorSchedule | `supervisor_schedules` | Implementado |
| Collaborator | `collaborators` | Planejado |
| CollaboratorPlant | `collaborator_plants` | Planejado |
| ReportStaff | `report_staff` | Planejado |

### 3.5.3 Timestamps

- Todos os modelos possuem `created_at` e `updated_at`
- `created_at`: `DateTime @default(now())` - preenchido automaticamente na insercao
- `updated_at`: `DateTime @updatedAt` - atualizado automaticamente pelo Prisma em cada `UPDATE`
- Campos mapeados para snake_case no banco via `@map()`

### 3.5.4 Campos JSON

Campos JSON sao usados para dados com estrutura flexivel ou listas heterogeneas. Embora nao tenham validacao no banco, sao validados pela camada de aplicacao (DTOs + Zod).

| Campo | Modelo | Estrutura Esperada |
|-------|--------|--------------------|
| `qualifications` | SupervisorProfile | `{ certifications: string[], courses: string[], ... }` |
| `preferences` | SupervisorProfile | `{ theme: string, notifications: boolean, ... }` |
| `address` | Plant | `{ street: string, city: string, state: string, zip: string, lat?: number, lng?: number }` |
| `contact` | Plant | `{ phone: string, email: string, responsible: string }` |
| `verificationItems` | SlaughterReport | `[{ id: number, description: string, conformity: "C" \| "NC", observation?: string }]` |
| `stunningVerifications` | SlaughterReport | `[{ time: string, pressure: number, result: string }]` |
| `meatRawMaterials` | ProductionReport | `[{ slaughterhouse: string, sif: string, slaughterDate: string, csn: string, halalCert: string }]` |
| `approvedIngredients` | ProductionReport | `[{ name: string, supplier: string, batch: string, expiry: string }]` |
| `verificationItems` | ProductionReport | `[{ id: number, description: string, conformity: "C" \| "NC", observation?: string }]` |
| `products` | ShippingReport | `[{ name: string, code: string, batch: string, mfgDate: string, expDate: string, weight: number, temp: number }]` |
| `verificationItems` | ShippingReport | `[{ id: number, description: string, conformity: "C" \| "NC", observation?: string }]` |
| `evidence` | NonConformity | `{ photos: string[], description: string, references: string[] }` |

### 3.5.5 Indices e Performance

A estrategia de indexacao segue o padrao de acesso mais frequente:

- **Indices compostos por entidade + data**: Todas as tabelas de relatorio possuem indices `(plantId, date)` e `(supervisorId, date)` para queries de listagem paginada filtradas por planta ou supervisor em um periodo
- **Indices por status**: Permitem filtragem eficiente de relatorios pendentes, em revisao, etc.
- **Indices especificos**:
  - `ShippingReport(shippingType, status)` - Filtra por tipo de embarque + status
  - `NonConformity(severity, status)` - Prioriza NCs criticas abertas
  - `NonConformity(supervisorId)` - NCs por supervisor

### 3.5.6 Soft Delete vs. Hard Delete

O sistema utiliza **desativacao logica** (`isActive = false`) em vez de exclusao fisica para:
- `SupervisorProfile`: Supervisores desativados nao aparecem em listagens ativas, mas seus relatorios historicos permanecem
- `Plant`: Plantas desativadas preservam historico de relatorios e NCs

Relatorios e NCs **nao sao excluidos**; utilizam o workflow de status (`cancelado`/`encerrada`) para controle de ciclo de vida.
