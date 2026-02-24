# Epic 06: Dashboard e Relatorios Gerenciais

**4 User Stories | 22 Story Points | Prioridade P1**

---

## Contexto

O dashboard fornece visao consolidada das atividades de supervisao industrial. Cada persona tem uma visao diferente: supervisor ve seus proprios indicadores, coordenador ve indicadores de toda a equipe, e gestor ve indicadores executivos.

### Codigo Relacionado

- Backend: `src/dashboard/` (module, controller, service)
- Frontend: `src/pages/Dashboard.tsx`

---

## User Stories

### Feature 6.1: Dashboard por Persona

#### SIH-030: Dashboard do Supervisor

```
Como supervisor muculmano,
Eu quero ver um dashboard com meus indicadores pessoais,
Para que eu acompanhe minha produtividade e pendencias.
```

**Prioridade**: P1 - Should Have
**Estimativa**: 5 story points

**Criterios de Aceitacao**:

- [ ] **Cards de resumo**:
  - Relatorios do dia (por tipo: abate, producao, embarque)
  - Relatorios da semana
  - Relatorios pendentes (rascunhos nao enviados)
  - NCs abertas sob minha responsabilidade

- [ ] **Lista de acoes pendentes**:
  - Rascunhos para finalizar
  - NCs para tratar (proximas do prazo em destaque)
  - Escala de hoje/proxima

- [ ] **Acesso rapido**:
  - Botao "Novo Relatorio" com selecao de tipo
  - Link direto para a planta da escala de hoje

---

#### SIH-031: Dashboard do Coordenador

```
Como coordenador de supervisores,
Eu quero ver um dashboard com indicadores da equipe,
Para que eu monitore a operacao e tome acoes rapidamente.
```

**Prioridade**: P1 - Should Have
**Estimativa**: 8 story points

**Criterios de Aceitacao**:

- [ ] **Cards de resumo operacional**:
  - Total de relatorios hoje/semana/mes (por tipo)
  - Relatorios pendentes de revisao (fila)
  - NCs ativas por severidade (critica, maior, menor, observacao)
  - NCs proximas do prazo (< 3 dias) / vencidas
  - Supervisores em campo hoje (escala)

- [ ] **Filtros**:
  - Periodo (hoje, semana, mes, custom)
  - Planta (select ou "todas")

- [ ] **Tabela de relatorios pendentes de revisao**:
  - Top 10 mais antigos
  - Link direto para revisar
  - Badge de tipo (abate, producao, embarque)

- [ ] **Mapa de NCs por planta**:
  - Lista de plantas com contagem de NCs ativas
  - Cores: verde (0), amarelo (1-2), vermelho (3+)

---

#### SIH-032: Dashboard do Gestor

```
Como gestor de certificacao,
Eu quero ver um dashboard executivo com indicadores estrategicos,
Para que eu tenha visibilidade da operacao de supervisao.
```

**Prioridade**: P1 - Should Have
**Estimativa**: 5 story points

**Criterios de Aceitacao**:

- [ ] **Indicadores executivos**:
  - Total de relatorios no periodo (grafico de tendencia)
  - Taxa de conformidade: % de relatorios sem NCs
  - NCs por severidade (grafico pizza/barra)
  - Plantas com mais NCs (ranking)
  - Cobertura de supervisao: % de turnos cobertos vs. programados

- [ ] **Graficos de tendencia**:
  - Relatorios por semana (ultimas 12 semanas)
  - NCs por semana
  - Taxa de resolucao de NCs no prazo

- [ ] **Filtros**: Periodo, planta

---

### Feature 6.2: Relatorios e Exportacao

#### SIH-033: Exportar Dados do Dashboard

```
Como coordenador ou gestor,
Eu quero exportar dados e indicadores,
Para que eu use em apresentacoes e relatorios externos.
```

**Prioridade**: P1 - Should Have
**Estimativa**: 4 story points

**Criterios de Aceitacao**:

- [ ] **Exportacao de listagens**:
  - Relatorios filtrados → CSV
  - NCs filtradas → CSV
  - Escalas do periodo → CSV

- [ ] **Exportacao de indicadores**:
  - Resumo do dashboard → PDF (futuro)
  - Dados brutos → JSON (para integracao)

- [ ] **Filtros aplicados na exportacao**: Mesmos filtros do dashboard ativo
