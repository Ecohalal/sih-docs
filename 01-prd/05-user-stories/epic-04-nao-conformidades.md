# Epic 04: Gestao de Nao-Conformidades

**FM 7.1.6.1 - Checklist de Nao-Conformidade**
**6 User Stories | 35 Story Points | Prioridade P0**

---

## Contexto

As nao-conformidades (NCs) sao registradas quando o supervisor identifica desvios nos processos industriais. Podem ser criadas a partir de qualquer relatorio (abate, producao, embarque) ou de forma avulsa. O PR 7.1 Rev 22 determina prazo de **7 dias corridos** para resolucao.

### Modelo de Dados: `NonConformity`

- Vinculo opcional a `SlaughterReport`, `ProductionReport` ou `ShippingReport`
- `severity`: critica, maior, menor, observacao
- `category`: higiene, processo, equipamento, materia-prima, rotulagem, etc.
- Workflow: aberta → em_tratamento → resolvida → verificada → encerrada
- Prazo automatico: 7 dias corridos (PR 7.1)
- Acoes corretivas e preventivas

### Codigo Relacionado

- Backend: `src/non-conformity/` (module, controller, service, DTOs)
- Frontend: `src/pages/non-conformity/` (NCList, NCForm, NCDetails)

---

## User Stories

### Feature 4.1: Registro de Nao-Conformidade

#### SIH-020: Registrar Nao-Conformidade a partir de Relatorio

```
Como supervisor muculmano,
Eu quero registrar uma nao-conformidade vinculada a um relatorio,
Para que o desvio identificado seja formalmente documentado com rastreabilidade.
```

**Prioridade**: P0 - Must Have
**Estimativa**: 8 story points

**Criterios de Aceitacao**:

- [ ] **Vinculo ao relatorio de origem**:
  - Botao "Registrar NC" disponivel na tela de detalhes de qualquer relatorio
  - Preenche automaticamente: planta, supervisor, referencia ao relatorio
  - Campos `slaughterReportId`, `productionReportId` ou `shippingReportId` (mutuamente exclusivos)

- [ ] **Campos obrigatorios**:
  - Descricao da nao-conformidade (texto, min 20 caracteres)
  - Severidade: critica | maior | menor | observacao
  - Categoria (select): higiene, processo, equipamento, materia-prima, rotulagem, documentacao, infraestrutura, outro

- [ ] **Campos opcionais**:
  - Evidencias: array de descricoes e/ou fotos (JSON)
  - Acao corretiva sugerida
  - Acao preventiva sugerida

- [ ] **Prazo automatico**:
  - `deadline` calculado como data_criacao + 7 dias corridos
  - Exibido de forma proeminente no formulario

- [ ] **Status inicial**: `aberta`

---

#### SIH-021: Registrar Nao-Conformidade Avulsa

```
Como supervisor muculmano,
Eu quero registrar uma nao-conformidade sem vincular a um relatorio,
Para que eu documente desvios observados fora do contexto de um relatorio especifico.
```

**Prioridade**: P0 - Must Have
**Estimativa**: 5 story points

**Criterios de Aceitacao**:

- [ ] **Formulario independente**:
  - Acessivel via menu principal + botao de acao rapida
  - Selecao de planta obrigatoria (nao pre-preenchida)
  - Sem vinculo a relatorios (IDs de relatorio = null)
  - Mesmos campos de SIH-020

- [ ] **Mesma logica de prazo e status**

---

### Feature 4.2: Workflow de Tratamento

#### SIH-022: Tratar e Resolver Nao-Conformidade

```
Como supervisor ou coordenador,
Eu quero registrar o tratamento e resolucao de uma NC,
Para que as acoes corretivas sejam documentadas dentro do prazo.
```

**Prioridade**: P0 - Must Have
**Estimativa**: 8 story points

**Criterios de Aceitacao**:

- [ ] **Transicoes de status**:
  - `aberta` → `em_tratamento`: Supervisor inicia o tratamento
    - Campo `correctiveAction` obrigatorio (o que foi feito)
  - `em_tratamento` → `resolvida`: Supervisor marca como resolvida
    - Campo `preventiveAction` opcional (o que sera feito para prevenir)
    - Registra `resolvedAt` e `resolvedBy`

- [ ] **Indicadores visuais de prazo**:
  - Verde: > 3 dias restantes
  - Amarelo: 1-3 dias restantes
  - Vermelho: vencida ou ultimo dia
  - Badge com dias restantes

- [ ] **Alerta de prazo**:
  - Coordenador ve NCs proximas do vencimento no dashboard
  - NCs vencidas destacadas no topo da lista

---

#### SIH-023: Verificar e Encerrar Nao-Conformidade

```
Como coordenador ou gestor,
Eu quero verificar e encerrar uma NC resolvida,
Para que eu confirme que as acoes corretivas foram eficazes.
```

**Prioridade**: P0 - Must Have
**Estimativa**: 5 story points
**Dependencias**: SIH-022

**Criterios de Aceitacao**:

- [ ] **Transicoes de status** (apenas coordenador/gestor):
  - `resolvida` → `verificada`: Coordenador confirma resolucao
    - Registra `verifiedAt` e `verifiedBy`
    - Pode adicionar comentarios na verificacao
  - `verificada` → `encerrada`: Gestor encerra definitivamente
  - `resolvida` → `em_tratamento`: Coordenador devolve (resolucao insuficiente)
    - Obriga comentario explicando o que falta

- [ ] **Historico de transicoes**: Registro de todas as mudancas de status com data/hora e usuario

---

### Feature 4.3: Listagem e Consulta

#### SIH-024: Listar e Filtrar Nao-Conformidades

```
Como supervisor ou coordenador,
Eu quero listar e filtrar nao-conformidades,
Para que eu acompanhe o status de todas as NCs registradas.
```

**Prioridade**: P0 - Must Have
**Estimativa**: 5 story points

**Criterios de Aceitacao**:

- [ ] **Listagem paginada** com colunas:
  - # | Planta | Severidade | Categoria | Prazo | Status | Supervisor
  - Ordenacao padrao: NCs vencidas primeiro, depois por prazo crescente

- [ ] **Filtros disponiveis**:
  - Planta (select)
  - Severidade (multi-select: critica, maior, menor, observacao)
  - Status (multi-select: aberta, em_tratamento, resolvida, verificada, encerrada)
  - Periodo de criacao (date range)
  - Supervisor (coordenador/gestor)
  - Origem (com relatorio / avulsa)

- [ ] **Indicadores visuais**:
  - Badges de severidade com cores (vermelho=critica, laranja=maior, amarelo=menor, cinza=observacao)
  - Badges de status com cores
  - Icone de alerta para NCs proximas do prazo/vencidas

---

#### SIH-025: Visualizar Detalhes de Nao-Conformidade

```
Como coordenador ou gestor,
Eu quero visualizar os detalhes completos de uma NC,
Para que eu acompanhe todo o historico de tratamento.
```

**Prioridade**: P0 - Must Have
**Estimativa**: 4 story points

**Criterios de Aceitacao**:

- [ ] **Tela de detalhes organizada em secoes**:
  - Cabecalho: planta, supervisor, data, severidade, categoria
  - Relatorio de origem (link clicavel, se vinculada)
  - Descricao da NC
  - Evidencias
  - Acao corretiva (se preenchida)
  - Acao preventiva (se preenchida)
  - Prazo com indicador visual
  - Status atual com workflow visual (stepper)
  - Historico de transicoes (timeline)

- [ ] **Acoes disponveis por role e status**:
  - Supervisor: tratar (aberta → em_tratamento), resolver (em_tratamento → resolvida)
  - Coordenador: verificar, devolver, encerrar
  - Gestor: encerrar
