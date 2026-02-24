# Epic 03: Relatorios de Embarque, Venda e Transferencia

**FM 7.1.7.1 (Exportacao) + FM 7.1.7.4 (Venda Interna) + DCPOA (Transferencia)**
**6 User Stories | 38 Story Points | Prioridade P0**

---

## Contexto

Os relatorios de embarque cobrem 3 tipos de movimentacao de produtos Halal: exportacao, venda no mercado interno e transferencia entre unidades industriais. Todos compartilham um modelo unico (`ShippingReport`) diferenciado pelo campo `shippingType`. Exportacao e o mais completo, com dados de importador, container, portos e lacre.

### Modelo de Dados: `ShippingReport`

- `shippingType`: exportacao | venda_interna | transferencia
- `formNumber`: "FM 7.1.7.1" (exportacao), "FM 7.1.7.4" (venda), "DCPOA" (transferencia)
- `products`: JSON com tabela de produtos padrao
- 2 itens de verificacao C/NC fixos
- Campos condicionais por tipo de embarque
- Serial automatico: `SIF/ANO/SEQUENCIAL`

### Codigo Relacionado

- Backend: `src/shipping-report/` (module, controller, service, DTOs)
- Backend: `src/shipping-report/constants/verification-items.ts`
- Frontend: `src/pages/shipping/` (List, Form, Details)
- Componentes: `VerificationChecklist`, `ProductTable`, `ReportHeader`

---

## User Stories

### Feature 3.1: CRUD de Relatorio de Embarque

#### SIH-014: Criar Relatorio de Embarque/Venda/Transferencia

```
Como supervisor muculmano,
Eu quero criar um novo relatorio de embarque, venda ou transferencia,
Para que eu registre a movimentacao de produtos Halal na planta.
```

**Prioridade**: P0 - Must Have
**Estimativa**: 8 story points

**Criterios de Aceitacao**:

- [ ] **Selecao do tipo de movimentacao**:
  - Exportacao (FM 7.1.7.1)
  - Venda Mercado Interno (FM 7.1.7.4)
  - Transferencia (DCPOA)
  - `formNumber` preenchido automaticamente conforme o tipo

- [ ] **Campos comuns (todos os tipos)**:
  - Planta
  - Data do carregamento (obrigatorio)
  - Tabela de produtos (ver SIH-015)
  - Observacoes

- [ ] **Campos exclusivos de Exportacao** (FM 7.1.7.1):
  - Exportador (nome da empresa)
  - Frigorifico de abate (nome + SIF)
  - Unidade produtora (nome + SIF)
  - Endereco do carregamento
  - Importador/Consignatario
  - Tipo de transporte (terrestre, aereo, maritimo)
  - Porto de embarque
  - Identificacao do veiculo (navio, caminhao, cia aerea)
  - Numero do container
  - Porto de destino
  - Pais de destino
  - Numero do pedido/Invoice
  - Numero CSI (Certificado Sanitario Internacional)
  - Numero do lacre

- [ ] **Campos condicionais ocultos para outros tipos**:
  - Venda interna: apenas campos comuns
  - Transferencia: apenas campos comuns

- [ ] **Gera serial automaticamente** e salva como rascunho

---

#### SIH-015: Registrar Tabela de Produtos do Embarque

```
Como supervisor muculmano,
Eu quero registrar os produtos sendo embarcados/vendidos/transferidos,
Para que haja rastreabilidade completa da carga.
```

**Prioridade**: P0 - Must Have
**Estimativa**: 8 story points
**Dependencias**: SIH-014

**Criterios de Aceitacao**:

- [ ] **Tabela editavel de produtos** (`ProductTable` componente) com campos por linha:
  - Nome do produto (obrigatorio)
  - Codigo do produto
  - Lote
  - Periodo de abate (data inicio - data fim)
  - Periodo de producao (data inicio - data fim)
  - Periodo de validade (data inicio - data fim)
  - Tipo de embalagem
  - Numero de volumes
  - Peso liquido (kg, decimal 12,3)
  - Peso bruto (kg, decimal 12,3)
  - Temperatura de embarque (graus C)

- [ ] **Operacoes na tabela**:
  - Adicionar, remover, editar inline
  - Minimo 1 produto para envio
  - Totais automaticos: soma de volumes, peso liquido, peso bruto

- [ ] **Armazenamento**: JSON no campo `products`

- [ ] **Componente `ProductTable` reutilizavel**:
  - Mesmo componente usado no Epic 02 (producao)
  - Props configuraveis: quais colunas exibir por contexto
  - Scroll horizontal em tablet

---

#### SIH-016: Preencher Verificacao C/NC do Embarque

```
Como supervisor muculmano,
Eu quero preencher os itens de verificacao do embarque,
Para que eu confirme a conformidade Halal da carga.
```

**Prioridade**: P0 - Must Have
**Estimativa**: 3 story points

**Criterios de Aceitacao**:

- [ ] **Sistema exibe os 2 itens fixos de verificacao** (conforme FM 7.1.7.1):
  1. Container/veiculo contem exclusivamente produtos Halal
  2. Selo de garantia Halal aplicado corretamente

- [ ] **Mesmo componente `VerificationChecklist`** dos Epics 01 e 02:
  - Selecao C/NC por item
  - Notas obrigatorias se NC

---

### Feature 3.2: Workflow e Gestao

#### SIH-017: Enviar e Revisar Relatorio de Embarque

```
Como supervisor muculmano,
Eu quero enviar meu relatorio de embarque para revisao,
Para que o coordenador aprove o registro da movimentacao.
```

**Prioridade**: P0 - Must Have
**Estimativa**: 5 story points
**Dependencias**: SIH-014, SIH-015, SIH-016

**Criterios de Aceitacao**:

- [ ] **Validacao antes do envio**:
  - Tipo de embarque selecionado
  - Data de carregamento preenchida
  - Pelo menos 1 produto na tabela
  - Ambos itens de verificacao respondidos
  - Para exportacao: campos obrigatorios adicionais (importador, container, pais destino)

- [ ] **Workflow identico aos Epics 01 e 02**:
  - `rascunho` → `enviado` → `aprovado`/`rejeitado`
  - Declaracao do supervisor + cancelamento com serial "A"

---

### Feature 3.3: Listagem e Consulta

#### SIH-018: Listar e Filtrar Relatorios de Embarque

```
Como supervisor ou coordenador,
Eu quero listar e filtrar relatorios de embarque,
Para que eu encontre registros de movimentacao especificos.
```

**Prioridade**: P0 - Must Have
**Estimativa**: 8 story points

**Criterios de Aceitacao**:

- [ ] **Listagem paginada** com colunas:
  - Serial | Data | Planta | Tipo | Destino/Cliente | Supervisor | Status
  - Ordenacao padrao: data descrescente

- [ ] **Filtros disponiveis**:
  - Planta (select)
  - Tipo de embarque (exportacao, venda_interna, transferencia)
  - Status (multi-select)
  - Periodo (date range)
  - Pais de destino (apenas exportacao)
  - Supervisor (coordenador/gestor)

- [ ] **Detalhes expandidos**:
  - Tabela de produtos completa
  - Dados de exportacao (quando aplicavel)
  - Itens C/NC com destaque visual

- [ ] **Responsivo**: Adaptado para tablet e desktop

---

#### SIH-019: Visualizar Detalhes do Relatorio de Embarque

```
Como coordenador ou gestor,
Eu quero visualizar os detalhes completos de um relatorio de embarque,
Para que eu revise todas as informacoes da movimentacao.
```

**Prioridade**: P0 - Must Have
**Estimativa**: 6 story points

**Criterios de Aceitacao**:

- [ ] **Tela de detalhes organizada em secoes**:
  - Cabecalho (FM, serial, planta, supervisor, data)
  - Dados do embarque (tipo-especifico)
  - Tabela de produtos (com totais)
  - Itens de verificacao (com destaque NC)
  - Observacoes
  - Status e historico de revisao

- [ ] **Acoes disponiveis por role**:
  - Supervisor (proprio): editar rascunho
  - Coordenador: aprovar/rejeitar (se enviado)
  - Todos: ver detalhes (somente leitura)

- [ ] **Impressao/PDF** (futuro): Layout preparado para geracao de PDF
