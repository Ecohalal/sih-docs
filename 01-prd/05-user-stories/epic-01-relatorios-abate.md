# Epic 01: Relatorios de Abate Halal

**FM 7.1.4.1 (Aves) + FM 7.1.4.2 (Bovino)**
**7 User Stories | 47 Story Points | Prioridade P0**

---

## Contexto

Os relatorios de abate sao preenchidos diariamente pelos supervisores muculmanos em plantas de abate (abatedouros e frigorificos). Cada relatorio registra os dados de um turno de abate, incluindo contagens de animais, itens de verificacao C/NC, e para bovinos, a secao de insensibilizacao (stunning).

### Modelo de Dados: `SlaughterReport`

- Diferenciado por `species` (ave vs. bovino)
- `formNumber`: "FM 7.1.4.1" (aves) ou "FM 7.1.4.2" (bovino)
- 14 itens de verificacao C/NC fixos
- Secao de stunning exclusiva para bovinos
- Serial automatico: `SIF/ANO/SEQUENCIAL`

### Codigo Relacionado

- Backend: `src/slaughter-report/` (module, controller, service, DTOs)
- Backend: `src/slaughter-report/constants/verification-items.ts`
- Frontend: `src/pages/slaughter/` (List, Form, Details)
- Componentes: `VerificationChecklist`, `ReportHeader`

---

## User Stories

### Feature 1.1: CRUD de Relatorio de Abate

#### SIH-001: Criar Relatorio de Abate

```
Como supervisor muculmano,
Eu quero criar um novo relatorio de abate Halal,
Para que eu registre digitalmente os dados do turno de abate na planta.
```

**Prioridade**: P0 - Must Have
**Estimativa**: 8 story points

**Criterios de Aceitacao**:

- [ ] **Sistema permite selecionar especie** (ave, bovino, ovino, caprino, bubalino):
  - Formulario ajusta campos condicionais baseado na especie
  - Para bovino: exibe secao de insensibilizacao
  - Para outros: oculta secao de insensibilizacao

- [ ] **Sistema gera numero serial automaticamente**:
  - Formato: `{SIF_PLANTA}/{ANO}/{SEQUENCIAL_6_DIGITOS}`
  - Exemplo: `451/2026/000001`
  - Sequencial unico por planta/ano, sem duplicatas
  - `formNumber` preenchido automaticamente ("FM 7.1.4.1" ou "FM 7.1.4.2")

- [ ] **Sistema exibe campos de identificacao**:
  - Planta (selecionada ou pre-definida pela escala)
  - Data do abate
  - Turno (matutino, vespertino, noturno, integral)
  - Nome do degolador
  - Registro/documento do degolador

- [ ] **Sistema exibe campos de contagem**:
  - Total de animais abatidos (obrigatorio, inteiro > 0)
  - Animais aprovados (obrigatorio, inteiro >= 0)
  - Animais rejeitados (default 0)
  - Sequencial das cabecas rejeitadas (texto livre, se rejeitados > 0)
  - Validacao: aprovados + rejeitados = total

- [ ] **Sistema salva como rascunho por padrao**:
  - Status inicial: `rascunho`
  - Pode ser editado e retomado posteriormente
  - Nao exige todos os campos obrigatorios para salvar como rascunho

---

#### SIH-002: Preencher Itens de Verificacao C/NC do Abate

```
Como supervisor muculmano,
Eu quero preencher os 14 itens de verificacao C/NC do formulario de abate,
Para que eu registre a conformidade de cada item conforme o PR 7.1.
```

**Prioridade**: P0 - Must Have
**Estimativa**: 5 story points

**Criterios de Aceitacao**:

- [ ] **Sistema exibe os 14 itens fixos de verificacao** (conforme FM 7.1.4.x):
  1. Limpeza e higiene do local de abate
  2. Condicao dos equipamentos
  3. Identificacao dos animais
  4. Bem-estar animal no curral de espera
  5. Conducao dos animais a area de abate
  6. Posicionamento para degola
  7. Invocacao do nome de Allah (Bismillah)
  8. Degola com instrumento afiado
  9. Corte das veias jugulares e arteria carotida
  10. Sangria completa
  11. Tempo de espera antes do processamento
  12. Separacao Halal/Nao-Halal
  13. Identificacao das carcacas aprovadas
  14. Armazenamento adequado

- [ ] **Cada item permite selecao C (Conforme) ou NC (Nao-Conforme)**:
  - Checkbox ou toggle para cada item
  - Campo de notas/observacao opcional por item
  - Se NC selecionado: campo de notas se torna obrigatorio

- [ ] **Componente `VerificationChecklist` reutilizavel**:
  - Recebe lista de itens como prop
  - Retorna JSON: `[{ id, description, result: "C"|"NC", notes? }]`
  - Interface otimizada para tablet (targets grandes, facil de clicar)

---

#### SIH-003: Registrar Insensibilizacao (Stunning) - Bovino

```
Como supervisor muculmano em planta de abate bovino,
Eu quero registrar os dados de insensibilizacao (stunning),
Para que eu documente a avaliacao de conformidade deste processo critico.
```

**Prioridade**: P0 - Must Have
**Estimativa**: 8 story points
**Dependencias**: SIH-001 (apenas quando species=bovino)

**Criterios de Aceitacao**:

- [ ] **Secao exibida apenas para bovinos** (species=bovino):
  - Oculta para aves e outras especies
  - Posicionada apos os itens de verificacao C/NC

- [ ] **Campo de avaliacao geral**:
  - `stunningUsed`: Boolean (sim/nao) - se o frigorifico utiliza insensibilizacao
  - `stunningEvaluation`: Texto livre para avaliacao de pressao/parametros do equipamento

- [ ] **2 conferencias por turno** (conforme FM 7.1.4.2):
  - Conferencia 1 (inicio do turno):
    - Animal estava vivo no momento do abate? (Sim/Nao)
    - Animal apresentou lesoes craniais? (Sim/Nao)
  - Conferencia 2 (meio/fim do turno):
    - Mesmos campos da conferencia 1
  - Armazenado em `stunningVerifications`: JSON array

- [ ] **Campos de camaras de resfriamento**:
  - `coolingCarcasses`: Qtd de carcacas enviadas ao resfriamento (inteiro)
  - `coolingCameras`: Identificacao das camaras utilizadas (texto, ex: "C-10-11-09-14")

- [ ] **Campos de subprodutos**:
  - `byproductsSold`: Boolean - subprodutos foram comercializados?
  - `byproductsDescription`: Descricao dos subprodutos (se vendidos)

---

### Feature 1.2: Workflow e Gestao

#### SIH-004: Enviar Relatorio de Abate para Revisao

```
Como supervisor muculmano,
Eu quero enviar meu relatorio de abate para revisao,
Para que o coordenador possa avaliar e aprovar meu registro.
```

**Prioridade**: P0 - Must Have
**Estimativa**: 5 story points
**Dependencias**: SIH-001, SIH-002

**Criterios de Aceitacao**:

- [ ] **Validacao completa antes do envio**:
  - Todos os campos obrigatorios preenchidos
  - Todos os 14 itens de verificacao respondidos (C ou NC)
  - Para bovinos: secao de insensibilizacao preenchida
  - Contagem valida: aprovados + rejeitados = total
  - Se tem rejeitados: sequencial de rejeicao preenchido

- [ ] **Transicao de status**: `rascunho` → `enviado`
  - Data/hora de envio registrada
  - Relatorio nao pode mais ser editado pelo supervisor apos envio
  - Apenas coordenador/gestor pode devolver para edicao (rejeicao)

- [ ] **Declaracao do supervisor**:
  - Texto padrao bilingue (PT/EN) exibido antes do envio
  - Supervisor confirma ciencia/assinatura digital (aceite)

---

#### SIH-005: Revisar e Aprovar/Rejeitar Relatorio de Abate

```
Como coordenador de supervisores,
Eu quero revisar e aprovar ou rejeitar relatorios de abate,
Para que eu garanta a qualidade dos registros antes da aprovacao final.
```

**Prioridade**: P0 - Must Have
**Estimativa**: 8 story points
**Dependencias**: SIH-004

**Criterios de Aceitacao**:

- [ ] **Lista de relatorios pendentes de revisao**:
  - Filtro por status `enviado`
  - Ordenacao por data (mais antigos primeiro)
  - Filtros: planta, supervisor, especie, periodo

- [ ] **Tela de revisao detalhada**:
  - Visualizacao completa do relatorio (somente leitura)
  - Destaque visual para itens NC
  - Historico de alteracoes (se houve rejeicao anterior)

- [ ] **Acoes de revisao**:
  - **Aprovar**: `enviado` → `aprovado` (registra reviewedBy + reviewedAt)
  - **Rejeitar**: `enviado` → `rejeitado` (obriga comentario do motivo)
  - Relatorio rejeitado volta como editavel para o supervisor

---

#### SIH-006: Cancelar Relatorio de Abate

```
Como supervisor muculmano,
Eu quero cancelar um relatorio de abate com erro grave,
Para que eu emita um novo relatorio corrigido com rastreabilidade.
```

**Prioridade**: P1 - Should Have
**Estimativa**: 5 story points

**Criterios de Aceitacao**:

- [ ] **Cancelamento com motivo obrigatorio**:
  - Status → `cancelado`
  - Campo `cancelledReason` obrigatorio
  - Relatorio cancelado permanece no sistema (nao e excluido)

- [ ] **Emissao de relatorio substituto**:
  - Novo relatorio criado com serial sufixo "A" (ex: `451/2026/000001A`)
  - Campo `replacedBy` no relatorio cancelado aponta para o novo serial
  - Dados do relatorio cancelado copiados para o novo (editavel)

---

### Feature 1.3: Listagem e Consulta

#### SIH-007: Listar e Filtrar Relatorios de Abate

```
Como supervisor ou coordenador,
Eu quero listar e filtrar relatorios de abate,
Para que eu encontre rapidamente relatorios especificos.
```

**Prioridade**: P0 - Must Have
**Estimativa**: 8 story points

**Criterios de Aceitacao**:

- [ ] **Listagem paginada** com colunas:
  - Serial | Data | Planta | Especie | Supervisor | Total Animais | Status
  - Ordenacao padrao: data descrescente

- [ ] **Filtros disponiveis**:
  - Planta (select)
  - Especie (select)
  - Status (multi-select: rascunho, enviado, revisado, aprovado, rejeitado, cancelado)
  - Periodo (date range)
  - Supervisor (select - apenas para coordenador/gestor)

- [ ] **Busca por serial**: Campo de busca rapida por numero serial

- [ ] **Acoes na lista**:
  - Clicar para ver detalhes
  - Editar (apenas rascunhos proprios ou coordenador)
  - Badge visual de status (cores diferenciadas)

- [ ] **Responsivo**: Layout adaptado para tablet (cards em mobile, tabela em desktop)
