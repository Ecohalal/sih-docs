# 4. Arquitetura de Features

---

## 4.1 Visao Geral dos Epicos

O SIH esta organizado em **7 epicos**, sendo 6 para implementacao na v1.0 e 1 documentado para implementacao futura.

```
SIH v1.0
├── Epic 01: Relatorios de Abate (FM 7.1.4.x)
├── Epic 02: Relatorios de Producao (FM 7.1.3.x / FM 7.1.8.x)
├── Epic 03: Relatorios de Embarque (FM 7.1.7.x / DCPOA)
├── Epic 04: Nao-Conformidades (FM 7.1.6.1)
├── Epic 05: Escala de Supervisores
├── Epic 06: Dashboard e Relatorios
│
SIH Futuro
└── Epic 07: Inventario (FM 7.1.5.x / FM 7.1.3.6) [DOCUMENTADO]
```

---

## 4.2 Mapeamento FM → Epico → Modulo

| FM | Epico | Modulo Backend | Paginas Frontend |
|----|-------|----------------|------------------|
| FM 7.1.4.1 (Aves) | Epic 01 | `slaughter-report/` | `pages/slaughter/` |
| FM 7.1.4.2 (Bovino) | Epic 01 | `slaughter-report/` | `pages/slaughter/` |
| FM 7.1.3.1 (Producao) | Epic 02 | `production-report/` | `pages/production/` |
| FM 7.1.8.x (Especial) | Epic 02 | `production-report/` | `pages/production/` |
| FM 7.1.7.1 (Exportacao) | Epic 03 | `shipping-report/` | `pages/shipping/` |
| FM 7.1.7.4 (Venda) | Epic 03 | `shipping-report/` | `pages/shipping/` |
| DCPOA (Transferencia) | Epic 03 | `shipping-report/` | `pages/shipping/` |
| FM 7.1.6.1 (NC) | Epic 04 | `non-conformity/` | `pages/non-conformity/` |
| - (Escala) | Epic 05 | `schedule/` | `pages/schedule/` |
| - (Dashboard) | Epic 06 | `dashboard/` | `pages/Dashboard.tsx` |
| FM 7.1.5.1 (Carne) | Epic 07 | `inventory/meat/` [futuro] | `pages/inventory/` [futuro] |
| FM 7.1.5.6 (Lotes) | Epic 07 | `inventory/batch/` [futuro] | `pages/inventory/` [futuro] |
| FM 7.1.3.6 (Rotulagem) | Epic 07 | `inventory/labeling/` [futuro] | `pages/inventory/` [futuro] |

---

## 4.3 Resumo por Epico

### Epic 01: Relatorios de Abate

**FM**: 7.1.4.1 (Aves) + 7.1.4.2 (Bovino)
**Prioridade**: Must Have (P0)

Digitaliza os relatorios de acompanhamento de abate Halal. Cobre aves e bovinos com um unico modelo (`SlaughterReport`) diferenciado por especie. Bovinos possuem secao adicional de insensibilizacao (stunning).

**Componentes-chave**:
- 14 itens de verificacao C/NC (fixos, nao configuraveis)
- Secao de insensibilizacao (bovino): avaliacao de pressao + 2 conferencias/turno
- Contagem: total, aprovados, rejeitados + sequencial de rejeicao
- Camaras de resfriamento, subprodutos
- Numero serial automatico (SIF/ANO/SEQ)
- Workflow: rascunho → enviado → revisado → aprovado/rejeitado

**User Stories**: 7 | **Story Points**: 47

---

### Epic 02: Relatorios de Producao

**FM**: 7.1.3.1 (Industrializados) + 7.1.8.x (Producao Especial)
**Prioridade**: Must Have (P0)

Digitaliza o acompanhamento de fabricacao de produtos industrializados a base de carne Halal. Inclui rastreabilidade completa de materias-primas carneas e ingredientes aprovados.

**Componentes-chave**:
- 5 itens de verificacao C/NC (fixos)
- Tabela de materias-primas carneas (frigorifico, SIF, data abate, CSN, certificado Halal)
- Tabela de ingredientes aprovados (nao-carneos: fornecedor, lote, validade)
- Dados do produto final (codigo, lote, datas, pesos, embalagem)
- Flag `specialProduction` para FM 7.1.8.x

**User Stories**: 6 | **Story Points**: 40

---

### Epic 03: Relatorios de Embarque, Venda e Transferencia

**FM**: 7.1.7.1 (Exportacao) + 7.1.7.4 (Venda Interna) + DCPOA (Transferencia)
**Prioridade**: Must Have (P0)

Unifica 3 tipos de movimentacao de produtos em um unico modelo (`ShippingReport`) diferenciado por `shippingType`. Exportacao e o mais completo com dados de importador, container, portos e lacre.

**Componentes-chave**:
- 2 itens de verificacao C/NC (fixos: exclusividade Halal no container + selo)
- Tabela de produtos padrao (produto, codigo, lote, datas, pesos, temperatura)
- Campos condicionais por tipo: exportacao (importer, container, ports) vs. venda interna vs. transferencia
- Dados de transporte (tipo, veiculo, container, lacre)

**User Stories**: 6 | **Story Points**: 38

---

### Epic 04: Nao-Conformidades

**FM**: 7.1.6.1
**Prioridade**: Must Have (P0)

Gestao completa de nao-conformidades identificadas durante a supervisao. Pode ser criada a partir de qualquer relatorio (abate, producao, embarque) ou de forma avulsa. Implementa o prazo de 7 dias corridos conforme PR 7.1.

**Componentes-chave**:
- Vinculo opcional a relatorios de origem (1 NC pode vir de qualquer tipo)
- Severidade: critica, maior, menor, observacao
- Categorias: higiene, processo, equipamento, materia-prima, rotulagem, etc.
- Evidencias (fotos/descricoes)
- Workflow: aberta → em_tratamento → resolvida → verificada → encerrada
- Prazo automatico de 7 dias com alertas
- Acoes corretivas e preventivas

**User Stories**: 6 | **Story Points**: 35

---

### Epic 05: Escala de Supervisores

**Prioridade**: Should Have (P1)

Gestao da escala de trabalho dos supervisores nas plantas industriais. Permite ao coordenador distribuir supervisores por planta, turno e tipo de escala.

**Componentes-chave**:
- Calendario visual mensal
- Alocacao: supervisor + planta + data + turno
- Tipos: regular, substituicao, extra, folga
- Restricao: um supervisor por planta/data/turno (unique constraint)
- Visao por supervisor e por planta

**User Stories**: 4 | **Story Points**: 20

---

### Epic 06: Dashboard e Relatorios

**Prioridade**: Should Have (P1)

Dashboard em tempo real com indicadores operacionais e de conformidade. Visualizacoes diferentes por persona (supervisor basico, coordenador completo, gestor executivo).

**Componentes-chave**:
- Contadores: relatorios do dia/semana/mes por tipo e status
- NCs ativas por severidade e planta
- Relatorios pendentes de revisao
- Produtividade por supervisor
- Graficos de tendencia

**User Stories**: 4 | **Story Points**: 22

---

### Epic 07: Inventario (FUTURO)

**FM**: 7.1.5.1 (Carne) + 7.1.5.6 (Lotes) + 7.1.3.6 (Rotulagem)
**Prioridade**: Nice to Have (P2) - Implementacao futura

Modulo de inventario baseado no conceito de **conta corrente** (saldo = entrada - saida). Modelo de dados ja documentado para evitar retrabalho. Inclui 3 tipos distintos de inventario com volumes de dados significativos (1.000+ linhas/mes).

**Componentes-chave** (documentados):
- Conta corrente de carne: recebido vs. utilizado em producao
- Inventario de lotes: gerado vs. transferido entre unidades
- Inventario de rotulagem: sem rotulo → rotulado → embarcado/descartado
- Referencias cruzadas entre inventario, relatorios e certificados

**User Stories**: 6 | **Story Points**: TBD (sera estimado quando implementado)

---

## 4.4 Dependencias entre Epicos

```
[Auth Compartilhada] ← Prerequisito para todos
       │
       ├── Epic 01: Abate ──────┐
       ├── Epic 02: Producao ───┤──→ Epic 04: NCs (vinculo a relatorios)
       ├── Epic 03: Embarque ───┘
       │
       ├── Epic 05: Escala (independente, usa plantas + supervisores)
       │
       └── Epic 06: Dashboard (depende de dados dos epicos 01-05)
              │
              └── Epic 07: Inventario [FUTURO] (depende de 01-03 para referencias cruzadas)
```

---

## 4.5 Componentes Compartilhados

Os seguintes componentes frontend sao reutilizados entre multiplos epicos:

| Componente | Usado por | Descricao |
|------------|-----------|-----------|
| `VerificationChecklist` | Epics 01, 02, 03 | Renderiza itens C/NC com checkboxes. Recebe lista de itens como prop (diferentes por tipo FM). |
| `ProductTable` | Epics 02, 03 | Tabela editavel de produtos (produto, codigo, lote, datas, pesos, temperatura). |
| `ReportHeader` | Epics 01, 02, 03 | Cabecalho padrao: numero FM, serial, planta, supervisor, data. |

---

## 4.6 Contagem Total

| Item | Quantidade |
|------|-----------|
| Epicos v1.0 | 6 |
| Epicos futuros | 1 |
| User Stories v1.0 | 33 |
| User Stories futuras | 6 |
| **Story Points v1.0** | **202** |
