# Epic 07: Inventario (FASE FUTURA)

**FM 7.1.5.1 (Carne) + FM 7.1.5.6 (Lotes) + FM 7.1.3.6 (Rotulagem)**
**6 User Stories | Story Points TBD | Prioridade P2 (FUTURO)**

---

> **NOTA**: Este epico esta **documentado mas NAO sera implementado na v1.0**. O modelo de dados foi desenhado e validado com dados reais (6 planilhas Excel, 25 abas, 23.000+ linhas) para evitar retrabalho quando for implementado. A implementacao sera via migration separada adicionando as tabelas ao banco existente.

---

## Contexto

O inventario Halal opera no conceito de **conta corrente** (running balance): saldo = entrada - saida. Existem 3 tipos distintos de inventario, cada um rastreando um elo diferente da cadeia produtiva.

### Cadeia de Rastreabilidade

```
Relatorio de Abate (FM 7.1.4.x)
    ↓ Certificado Halal + CSN + SIF
Inventario de Carne (FM 7.1.5.1)  ←  recebido vs. usado em producao
    ↓ Codigo produto + data producao
Relatorio de Producao (FM 7.1.3.x)
    ↓ Lote gerado + peso
Inventario de Lotes (FM 7.1.5.6)  ←  gerado vs. transferido
    ↓ Lote transferido + doc sanitario
Inventario de Rotulagem (FM 7.1.3.6)  ←  sem rotulo → rotulado → embarcado
    ↓ Numero do pedido
Relatorio de Embarque (FM 7.1.7.x)
```

### Modelos de Dados (6 tabelas)

**FM 7.1.5.1 - Conta Corrente de Carne:**
- `MeatInventoryReceipt` → `MeatInventoryCut` → `MeatInventoryUsage`
- Hierarquico: recebimento pai → cortes filhos → usos em producao

**FM 7.1.5.6 - Inventario de Lotes:**
- `BatchInventory` → `BatchTransfer`
- Lote gerado → transferencias para outras unidades

**FM 7.1.3.6 - Inventario de Rotulagem:**
- `LabelingInventory`
- Fluxo: recebido sem rotulo → rotulado → embarcado/descartado

### Codigo Futuro

- Backend: `src/inventory/meat/`, `src/inventory/batch/`, `src/inventory/labeling/`
- Frontend: `src/pages/inventory/`

---

## User Stories

### Feature 7.1: Inventario de Carne Halal (FM 7.1.5.1)

#### SIH-034: Registrar Recebimento de Carne Halal

```
Como supervisor muculmano,
Eu quero registrar o recebimento de carne Halal na planta,
Para que o inventario de conta corrente seja atualizado com a entrada.
```

**Prioridade**: P2 - Nice to Have (Futuro)
**Estimativa**: TBD

**Criterios de Aceitacao**:

- [ ] **Dados do recebimento**:
  - Data de recebimento
  - Especie (bovino, ave)
  - Nome do frigorifico fornecedor
  - SIF do fornecedor (obrigatorio)
  - Numero do certificado Halal
  - Periodo de abate (data inicio - data fim)
  - Numero CSN (Certificado Sanitario Nacional)
  - Peso total recebido (kg)

- [ ] **Detalhamento por tipo de corte** (sub-linhas):
  - Tipo de corte: C. DURO, C. MOLE, LAGARTO, ACEN, PATINHO, etc.
  - Peso recebido por corte (kg)
  - Soma dos cortes = peso total recebido

- [ ] **Saldo automatico**: Saldo inicial = peso total recebido

---

#### SIH-035: Registrar Uso de Carne em Producao

```
Como supervisor muculmano,
Eu quero registrar o uso de carne do inventario em producao,
Para que o saldo de conta corrente seja atualizado com a saida.
```

**Prioridade**: P2 - Nice to Have (Futuro)
**Estimativa**: TBD

**Criterios de Aceitacao**:

- [ ] **Dados do uso**:
  - Data de producao
  - Tipo de corte utilizado (select do inventario disponivel)
  - Codigos dos produtos fabricados
  - Peso utilizado (kg)
  - Link opcional ao relatorio de producao (ProductionReport)

- [ ] **Validacoes**:
  - Peso utilizado <= saldo disponivel do corte
  - Saldo atualizado automaticamente: `currentBalanceKg = totalRecebido - somaUtilizado`

- [ ] **Visao de saldo**:
  - Tabela com: recebimento, cortes, peso recebido, peso utilizado, saldo atual
  - Destaque para itens com saldo zerado
  - Separacao por especie (bovino, ave)

---

### Feature 7.2: Inventario de Lotes (FM 7.1.5.6)

#### SIH-036: Registrar Lote Produzido

```
Como supervisor muculmano,
Eu quero registrar um lote produzido no inventario,
Para que o rastreamento de lotes gerados seja mantido.
```

**Prioridade**: P2 - Nice to Have (Futuro)
**Estimativa**: TBD

**Criterios de Aceitacao**:

- [ ] **Dados do lote**:
  - Data de producao
  - Numero do documento sanitario
  - Codigo do lote gerado (obrigatorio)
  - Peso liquido gerado (kg)

- [ ] **Saldo inicial**: `currentStockKg = weightGeneratedKg`

---

#### SIH-037: Registrar Transferencia de Lote

```
Como supervisor muculmano,
Eu quero registrar a transferencia de um lote para outra unidade,
Para que o saldo do inventario de lotes seja atualizado.
```

**Prioridade**: P2 - Nice to Have (Futuro)
**Estimativa**: TBD

**Criterios de Aceitacao**:

- [ ] **Dados da transferencia**:
  - Lote de origem (select do inventario)
  - Data de transferencia
  - Numero do documento sanitario da transferencia
  - Codigo do lote na transferencia
  - Peso transferido (kg)
  - Unidade industrial destino (texto)
  - Link opcional ao relatorio de embarque (ShippingReport type=transferencia)

- [ ] **Validacoes**:
  - Peso transferido <= saldo do lote
  - Saldo atualizado: `currentStockKg = gerado - somaTransferido`
  - Historico de transferencias por lote

---

### Feature 7.3: Inventario de Rotulagem (FM 7.1.3.6)

#### SIH-038: Registrar Movimentacao de Rotulagem

```
Como supervisor muculmano,
Eu quero registrar entradas e saidas do inventario de rotulagem,
Para que o rastreamento de produtos rotulados seja mantido.
```

**Prioridade**: P2 - Nice to Have (Futuro)
**Estimativa**: TBD

**Criterios de Aceitacao**:

- [ ] **Dados por registro**:
  - Data
  - Categoria do produto (E 340, POUCH, EXTRATO, HAMBURGUER, etc.)
  - Codigo interno (sem rotulo)
  - Codigo do produto rotulado
  - Nome do produto

- [ ] **Entradas**:
  - Quantidade recebida sem rotulo
  - Quantidade rotulada

- [ ] **Saidas**:
  - Quantidade embarcada
  - Numero do pedido
  - Quantidade descartada (com rotulo)
  - Quantidade descartada (sem rotulo)

- [ ] **Saldos calculados**:
  - Estoque com rotulagem = acumulado(rotulados) - acumulado(embarcados + descarte rotulado)
  - Estoque sem rotulagem = acumulado(recebidos) - acumulado(rotulados + descarte sem rotulo)

---

#### SIH-039: Dashboard de Inventario

```
Como coordenador ou gestor,
Eu quero um dashboard consolidado de inventario,
Para que eu tenha visibilidade dos estoques Halal em cada planta.
```

**Prioridade**: P2 - Nice to Have (Futuro)
**Estimativa**: TBD

**Criterios de Aceitacao**:

- [ ] **Visao consolidada por planta**:
  - Inventario de carne: saldo atual por tipo de corte e especie
  - Inventario de lotes: lotes em estoque, lotes transferidos
  - Inventario de rotulagem: estoque com/sem rotulo por categoria

- [ ] **Alertas**:
  - Saldos negativos (inconsistencia)
  - Lotes com muito tempo em estoque
  - Saldos zerados (sem material disponivel)

---

## Decisoes de Design para Implementacao Futura

| Decisao | Detalhe |
|---------|---------|
| **Saldos** | Calculados via triggers/views no banco (nao em codigo aplicacao) |
| **Particionamento** | Possivel particionamento mensal para tabelas de alto volume (FM 7.1.5.6: ~1000 linhas/mes) |
| **Migracao** | Importacao em massa de planilhas Excel existentes (dados historicos) |
| **Migration** | Tabelas criadas via migration separada (nao inclusa na init) |
| **Modulos backend** | 3 modulos separados: `inventory/meat/`, `inventory/batch/`, `inventory/labeling/` |

## Dados de Referencia (Planilhas Analisadas)

| Planilha | Tipo | Abas | Linhas | Observacao |
|----------|------|:----:|:------:|------------|
| FM 7.1.5.1 - INVENTARIO MSP.xlsx | Carne | 2 | 1.702 | Bovinos (1530) + Aves (172) |
| FM 7.1.5.6 - INVENTARIO GELNEX.xlsx | Lotes | 11 | ~11.000 | Mensal (mar/25 - jan/26) |
| FM 7.1.3.6 - ODERICH.xlsx | Rotulagem | 3 | ~2.000 | 3 categorias |
| PLANILHA INVENTARIO PAMPEANO.xlsx | Rotulagem | 11 | ~15.000 | 11 categorias (E 340: 8068 linhas) |
| PLANILHA INVENTARIO CARAPRETA.xlsx | Produto | 2 | ~500 | Hamburguer + File Mignon |
| inventario kin master.xlsx | Produto | 1 | ~200 | Tracking individual |
