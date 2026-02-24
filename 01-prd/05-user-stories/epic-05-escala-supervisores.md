# Epic 05: Escala de Supervisores

**4 User Stories | 20 Story Points | Prioridade P1**

---

## Contexto

A escala de supervisores controla a alocacao de supervisores muculmanos nas plantas industriais. Cada supervisor e designado para uma planta em uma data e turno especificos. O coordenador monta a escala e pode fazer substituicoes, escalas extras ou registrar folgas.

### Modelo de Dados: `SupervisorSchedule`

- Relacao: supervisor + planta + data + turno (unique constraint)
- Tipos: regular, substituicao, extra, folga
- Restricao: um supervisor por planta/data/turno

### Codigo Relacionado

- Backend: `src/schedule/` (module, controller, service, DTOs)
- Frontend: `src/pages/schedule/` (ScheduleCalendar, ScheduleManagement)

---

## User Stories

### Feature 5.1: Gestao de Escala

#### SIH-026: Criar Alocacao de Supervisor na Escala

```
Como coordenador de supervisores,
Eu quero alocar um supervisor em uma planta para uma data e turno,
Para que a cobertura de supervisao Halal esteja organizada.
```

**Prioridade**: P1 - Should Have
**Estimativa**: 5 story points

**Criterios de Aceitacao**:

- [ ] **Campos da alocacao**:
  - Supervisor (select entre supervisores ativos)
  - Planta (select entre plantas ativas)
  - Data (date picker)
  - Turno: matutino, vespertino, noturno, integral
  - Tipo: regular (padrao), substituicao, extra, folga
  - Notas (texto livre, opcional)

- [ ] **Validacoes**:
  - Nao permite duplicata: mesmo supervisor + planta + data + turno
  - Alerta se supervisor ja esta alocado em outra planta na mesma data/turno
  - Nao permite alocar supervisor inativo

- [ ] **Criacao em lote** (nice to have):
  - Selecionar range de datas para criar escalas recorrentes
  - Copiar escala da semana anterior

---

#### SIH-027: Visualizar Escala em Calendario

```
Como coordenador de supervisores,
Eu quero visualizar a escala em formato de calendario,
Para que eu tenha visao clara da cobertura de todas as plantas.
```

**Prioridade**: P1 - Should Have
**Estimativa**: 8 story points

**Criterios de Aceitacao**:

- [ ] **Calendario mensal interativo**:
  - Visao por mes (padrao)
  - Cada dia mostra alocacoes com nome do supervisor e planta
  - Cores por tipo: regular (azul), substituicao (amarelo), extra (verde), folga (cinza)

- [ ] **Dois modos de visualizacao**:
  - **Por planta**: Calendario de uma planta, mostrando qual supervisor esta alocado em cada dia/turno
  - **Por supervisor**: Calendario de um supervisor, mostrando em quais plantas esta alocado

- [ ] **Interacao**:
  - Clicar em dia vazio: criar nova alocacao
  - Clicar em alocacao existente: editar/remover
  - Drag-and-drop (nice to have): mover alocacao entre datas

- [ ] **Responsivo**: Funciona em tablet (modo landscape recomendado)

---

#### SIH-028: Editar e Remover Alocacao da Escala

```
Como coordenador de supervisores,
Eu quero editar ou remover alocacoes da escala,
Para que eu ajuste a cobertura conforme necessidade.
```

**Prioridade**: P1 - Should Have
**Estimativa**: 3 story points

**Criterios de Aceitacao**:

- [ ] **Edicao**:
  - Trocar supervisor (substituicao)
  - Mudar turno
  - Mudar tipo (regular → substituicao, etc.)
  - Adicionar/editar notas

- [ ] **Remocao**:
  - Confirmacao antes de remover
  - Nao permite remover se supervisor ja tem relatorios na data/planta

---

### Feature 5.2: Consulta de Escala

#### SIH-029: Supervisor Consulta Propria Escala

```
Como supervisor muculmano,
Eu quero consultar minha escala de trabalho,
Para que eu saiba em quais plantas devo comparecer.
```

**Prioridade**: P1 - Should Have
**Estimativa**: 4 story points

**Criterios de Aceitacao**:

- [ ] **Visao simplificada**:
  - Lista cronologica das proximas alocacoes
  - Filtro por mes
  - Informacoes: data, planta (nome + SIF), turno, tipo

- [ ] **Destaque**:
  - Alocacao de hoje em destaque
  - Proxima alocacao em evidencia

- [ ] **Acesso rapido**:
  - Da escala, clicar na planta leva aos relatorios daquela planta
  - Atalho para criar novo relatorio na planta da escala de hoje
