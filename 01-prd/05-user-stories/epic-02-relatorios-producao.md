# Epic 02: Relatorios de Producao Industrial

**FM 7.1.3.1 (Industrializados) + FM 7.1.8.x (Producao Especial)**
**6 User Stories | 40 Story Points | Prioridade P0**

---

## Contexto

Os relatorios de producao acompanham a fabricacao de produtos industrializados a base de carne Halal. O supervisor registra as materias-primas carneas utilizadas (com rastreabilidade completa), os ingredientes aprovados (nao-carneos), os dados do produto final e os itens de verificacao C/NC.

### Modelo de Dados: `ProductionReport`

- `formNumber`: "FM 7.1.3.1" (regular) ou "FM 7.1.8.x" (especial)
- `isSpecialProduction`: Boolean para distinguir producao especial
- `meatRawMaterials`: JSON com rastreabilidade completa
- `approvedIngredients`: JSON com ingredientes nao-carneos
- 5 itens de verificacao C/NC fixos
- Serial automatico: `SIF/ANO/SEQUENCIAL`

### Codigo Relacionado

- Backend: `src/production-report/` (module, controller, service, DTOs)
- Backend: `src/production-report/constants/verification-items.ts`
- Frontend: `src/pages/production/` (List, Form, Details)
- Componentes: `VerificationChecklist`, `ProductTable`, `ReportHeader`

---

## User Stories

### Feature 2.1: CRUD de Relatorio de Producao

#### SIH-008: Criar Relatorio de Producao Industrial

```
Como supervisor muculmano,
Eu quero criar um novo relatorio de producao industrial,
Para que eu registre o acompanhamento da fabricacao de produtos Halal.
```

**Prioridade**: P0 - Must Have
**Estimativa**: 8 story points

**Criterios de Aceitacao**:

- [ ] **Sistema gera numero serial automaticamente**:
  - Formato: `{SIF_PLANTA}/{ANO}/{SEQUENCIAL_6_DIGITOS}`
  - `formNumber` preenchido como "FM 7.1.3.1" (ou "FM 7.1.8.x" se producao especial)

- [ ] **Campos de periodo de producao**:
  - Data/hora inicio da producao (obrigatorio)
  - Data/hora fim da producao (obrigatorio)
  - Quantidade de turnos operados (inteiro > 0)

- [ ] **Campos do produto final**:
  - Nome do produto fabricado (obrigatorio)
  - Codigo do produto
  - Lote
  - Data de fabricacao
  - Data de validade
  - Tipo de embalagem (caixa, saco, tambor)
  - Numero de volumes
  - Peso liquido (kg, decimal 12,3)
  - Peso bruto (kg, decimal 12,3)
  - Quantidade total produzida (decimal 12,3)

- [ ] **Flag de producao especial**:
  - Toggle para marcar como FM 7.1.8.x
  - Quando ativado, `formNumber` muda para "FM 7.1.8.x"

- [ ] **Salva como rascunho por padrao**

---

#### SIH-009: Registrar Materias-Primas Carneas

```
Como supervisor muculmano,
Eu quero registrar as materias-primas carneas utilizadas na producao,
Para que haja rastreabilidade completa da origem da carne Halal.
```

**Prioridade**: P0 - Must Have
**Estimativa**: 8 story points
**Dependencias**: SIH-008

**Criterios de Aceitacao**:

- [ ] **Tabela editavel de materias-primas carneas** com campos por linha:
  - Tipo de proteina (texto: "Bovino CMS", "Mecanicamente Separada", etc.)
  - Nome do frigorifico/abatedouro de origem
  - Numero SIF do frigorifico
  - Periodo de abate (data inicio - data fim)
  - Numero CSN (Certificado Sanitario Nacional)
  - Numero do certificado Halal ou controle interno
  - Peso total (kg)

- [ ] **Operacoes na tabela**:
  - Adicionar nova linha
  - Remover linha (com confirmacao)
  - Editar campos inline
  - Minimo 1 materia-prima para envio (validacao)

- [ ] **Armazenamento**: JSON no campo `meatRawMaterials`

- [ ] **Interface otimizada para tablet**:
  - Scroll horizontal na tabela se necessario
  - Campos com teclado numerico para SIF e pesos
  - Autocomplete para frigorificos ja cadastrados (historico)

---

#### SIH-010: Registrar Ingredientes Aprovados

```
Como supervisor muculmano,
Eu quero registrar os ingredientes nao-carneos aprovados,
Para que eu documente todos os insumos utilizados na producao.
```

**Prioridade**: P0 - Must Have
**Estimativa**: 5 story points
**Dependencias**: SIH-008

**Criterios de Aceitacao**:

- [ ] **Tabela editavel de ingredientes aprovados** com campos por linha:
  - Nome do produto/ingrediente
  - Codigo do produto
  - Nome do fornecedor
  - Numero do lote
  - Data de validade

- [ ] **Operacoes na tabela**:
  - Adicionar, remover, editar inline
  - Campo opcional (pode nao ter ingredientes nao-carneos)

- [ ] **Armazenamento**: JSON no campo `approvedIngredients`

---

### Feature 2.2: Verificacao e Workflow

#### SIH-011: Preencher Itens de Verificacao C/NC da Producao

```
Como supervisor muculmano,
Eu quero preencher os 5 itens de verificacao C/NC da producao,
Para que eu registre a conformidade dos processos produtivos.
```

**Prioridade**: P0 - Must Have
**Estimativa**: 3 story points

**Criterios de Aceitacao**:

- [ ] **Sistema exibe os 5 itens fixos de verificacao** (conforme FM 7.1.3.1):
  1. Limpeza e higiene da area de producao e equipamentos
  2. Materias-primas carneas com documentacao Halal valida
  3. Documentacao de producao e rastreabilidade completa
  4. Armazenamento adequado (temperatura, separacao Halal)
  5. Rotulagem conforme requisitos Halal

- [ ] **Mesmo componente `VerificationChecklist`** do Epic 01:
  - Selecao C/NC por item
  - Notas obrigatorias se NC
  - JSON retornado no formato padrao

---

#### SIH-012: Enviar e Revisar Relatorio de Producao

```
Como supervisor muculmano,
Eu quero enviar meu relatorio de producao para revisao,
Para que o coordenador avalie a conformidade do registro.
```

**Prioridade**: P0 - Must Have
**Estimativa**: 8 story points
**Dependencias**: SIH-008, SIH-009, SIH-011

**Criterios de Aceitacao**:

- [ ] **Validacao completa antes do envio**:
  - Campos de periodo preenchidos (inicio e fim)
  - Pelo menos 1 materia-prima carnea registrada
  - Todos os 5 itens de verificacao respondidos
  - Dados do produto final preenchidos (nome obrigatorio)

- [ ] **Workflow identico ao Epic 01**:
  - `rascunho` → `enviado` → `revisado` → `aprovado`/`rejeitado`
  - Declaracao do supervisor antes do envio
  - Revisao pelo coordenador com aprovar/rejeitar

- [ ] **Cancelamento e substituicao**:
  - Mesmo mecanismo do Epic 01 (serial + sufixo "A")

---

### Feature 2.3: Listagem e Consulta

#### SIH-013: Listar e Filtrar Relatorios de Producao

```
Como supervisor ou coordenador,
Eu quero listar e filtrar relatorios de producao,
Para que eu encontre registros especificos de fabricacao.
```

**Prioridade**: P0 - Must Have
**Estimativa**: 8 story points

**Criterios de Aceitacao**:

- [ ] **Listagem paginada** com colunas:
  - Serial | Periodo | Planta | Produto | Supervisor | Status
  - Ordenacao padrao: data de inicio descrescente

- [ ] **Filtros disponiveis**:
  - Planta (select)
  - Status (multi-select)
  - Periodo (date range)
  - Producao especial (checkbox)
  - Supervisor (select - coordenador/gestor)
  - Produto (busca por nome)

- [ ] **Detalhes expandidos**:
  - Tabela de materias-primas visivel no detalhe
  - Tabela de ingredientes visivel no detalhe
  - Itens C/NC com destaque visual para NCs

- [ ] **Responsivo**: Adaptado para tablet e desktop
