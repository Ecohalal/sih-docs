# Product Requirements Document v1.0

**SIH - Supervisao Industrial Halal**
**Sistema de Digitalizacao dos Formularios FM FAMBRAS Halal**

---

## Controle do Documento

| Campo | Valor |
|-------|-------|
| **Versao** | 1.0 |
| **Data** | 24 de Fevereiro de 2026 |
| **Autor** | Product Manager - SIH Team |
| **Status** | Em Desenvolvimento |

---

## Indice do PRD

### Parte 1: Fundamentos do Produto

1. **[Visao Geral do Produto](./01-overview.md)**
   - Problema que resolvemos
   - Solucao proposta
   - Catalogo de formularios FM FAMBRAS
   - Estrutura padrao dos formularios

2. **[Objetivos e Metricas de Sucesso](./02-objectives.md)**
   - Objetivos do projeto
   - KPIs de negocio
   - Metricas operacionais

3. **[Personas e Jornadas](./03-personas.md)**
   - Supervisor Muculmano (preenche e assina relatorios)
   - Operador (preenche relatorios, nao assina)
   - Coordenador de Supervisores (gestao de equipe, read-only em relatorios)

4. **[Arquitetura de Features](./04-architecture.md)**
   - 7 Epicos organizados
   - Priorizacao e dependencias
   - Mapeamento FM → Modulo

### Parte 2: User Stories

5. **[User Stories por Epico](./05-user-stories/)**
   - [Epic 01: Relatorios de Abate](./05-user-stories/epic-01-relatorios-abate.md) - FM 7.1.4.x
   - [Epic 02: Relatorios de Producao](./05-user-stories/epic-02-relatorios-producao.md) - FM 7.1.3.x / FM 7.1.8.x
   - [Epic 03: Relatorios de Embarque](./05-user-stories/epic-03-relatorios-embarque.md) - FM 7.1.7.x / DCPOA
   - [Epic 04: Nao-Conformidades](./05-user-stories/epic-04-nao-conformidades.md) - FM 7.1.6.1
   - [Epic 05: Escala de Supervisores](./05-user-stories/epic-05-escala-supervisores.md)
   - [Epic 06: Dashboard e Relatorios](./05-user-stories/epic-06-dashboard.md)
   - [Epic 07: Inventario](./05-user-stories/epic-07-inventario.md) - FM 7.1.5.x / FM 7.1.3.6 **[FUTURO]**

### Parte 3: Planejamento

6. **[Roadmap](./06-roadmap.md)**
   - Fases de implementacao
   - Marcos e entregas

7. **[Requisitos Nao-Funcionais](./07-non-functional.md)**
   - Performance e escalabilidade
   - Seguranca e autenticacao
   - Usabilidade e acessibilidade
   - PWA e preparacao offline
