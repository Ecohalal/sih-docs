# Roadmap Detalhado de Implementacao

**Projeto**: SIH - Supervisao Industrial Halal
**Versao**: v1.0
**Ultima Atualizacao**: 2026-02-24

---

## Status Atual

| Fase | Descricao | Status | Progresso |
|------|-----------|--------|-----------|
| Fase 1 | Scaffolding (Repos + Configs) | COMPLETA | 4/4 tarefas |
| Fase 2 | Backend Core (Infra) | COMPLETA | 4/4 tarefas |
| Fase 3 | Backend Dominio (Negocio) | COMPLETA | 8/8 modulos |
| Fase 4 | Frontend Core (Base) | PROXIMO | 0/5 tarefas |
| Fase 5 | Frontend Pages (Paginas) | PENDENTE | 0/7 grupos |
| Fase 6 | Finalizacao (Deploy) | PENDENTE | 0/4 tarefas |

**Resumo de User Stories v1.0**: 33 stories | 202 story points | 6 epicos

---

## Fase 1: Scaffolding (COMPLETA)

**Objetivo**: Criar os 3 repositorios com toda a configuracao de projeto.

- [x] **1.1** Criar repositorio `sih-docs/`
  - Estrutura de documentacao criada
  - PRD completo com 39 user stories em 7 epicos
  - Arquitetura de features documentada
  - Roadmap original definido
- [x] **1.2** Criar repositorio `sih-backend/`
  - NestJS scaffolding funcional
  - package.json, tsconfig, eslint, prettier configurados
  - Docker e docker-compose preparados
  - Prisma schema completo com todos os modelos v1.0
- [x] **1.3** Criar repositorio `sih-frontend/`
  - React + Vite scaffolding funcional
  - Tailwind CSS configurado
  - Estrutura de pastas: components/, hooks/, pages/, services/, types/
  - PWA manifest preparado
- [x] **1.4** Criar workspace VS Code
  - `SupervisaoIndustrialHalal.code-workspace` configurado
  - 3 repos integrados em workspace unico

**Verificacao**: Repos criados, configs validas, workspace abre corretamente.

---

## Fase 2: Backend Core (COMPLETA)

**Objetivo**: Infraestrutura funcional do backend (NestJS).

- [x] **2.1** Config Module
  - `config.module.ts` - Modulo de configuracao global
  - `aws-config.service.ts` - Servico de configuracao AWS (Cognito, S3, etc.)
  - Variaves de ambiente validadas
- [x] **2.2** Prisma Module
  - `prisma.module.ts` - Modulo global do Prisma
  - `prisma.service.ts` - Servico com lifecycle hooks
  - Schema completo com 6 modelos + 11 enums + indices + constraints
  - **Nota**: Resolvido problema de migracao Prisma 7 usando provider `prisma-client-js` com adapter `PrismaPg`
- [x] **2.3** Auth Module
  - `jwt.strategy.ts` - Validacao JWT RS256/HS256 (via Gestao de Certificacoes/HalalSphere)
  - `jwt-auth.guard.ts` - Guard de autenticacao global
  - `roles.guard.ts` - Guard de autorizacao por role (admin, coordenador, supervisor, gestor)
  - `current-user.decorator.ts` - Decorator para extrair usuario do JWT
  - `roles.decorator.ts` - Decorator para definir roles permitidas
  - `public.decorator.ts` - Decorator para rotas publicas
  - `jwt-payload.type.ts` - Tipagem do payload JWT
- [x] **2.4** Health + Common
  - `health.controller.ts` - Endpoint `GET /health` funcional
  - `http-exception.filter.ts` - Filtro global de excecoes
  - `logging.interceptor.ts` - Interceptor de logging de requests
  - `serial-number.util.ts` - Gerador de numero serial (SIF/ANO/SEQ)
- [x] **2.5** Banco de Dados
  - PostgreSQL 16 com extensoes: uuid-ossp, pgcrypto, pg_trgm
  - Migracoes aplicadas com sucesso
  - Tabelas criadas conforme schema Prisma

**Verificacao**: `npm run start:dev` funciona, `GET /health` retorna OK, Swagger acessivel em `/api/docs`.

---

## Fase 3: Backend Dominio (COMPLETA)

**Objetivo**: Todos os 8 modulos de negocio com CRUD completo e logica de dominio.

### 3.1 SupervisorProfile Module

- [ ] **DTOs**
  - `create-supervisor-profile.dto.ts` - name, email, phone?, registration?, qualifications?, preferences?
  - `update-supervisor-profile.dto.ts` - PartialType do create
  - `supervisor-profile-query.dto.ts` - Filtros: role, isActive, search (nome/email)
  - `supervisor-profile-response.dto.ts` - Resposta com campos formatados
- [ ] **Service** (`supervisor-profile.service.ts`)
  - `findOrCreateFromJwt(payload)` - Auto-cria perfil no primeiro acesso via JWT
  - `findAll(query)` - Listagem com filtros e paginacao
  - `findOne(id)` - Busca por ID
  - `update(id, dto)` - Atualizacao parcial
  - `deactivate(id)` - Soft delete (isActive = false)
  - `updateLastLogin(id)` - Atualiza timestamp de ultimo login
- [ ] **Controller** (`supervisor-profile.controller.ts`)
  - `GET /supervisor-profiles` - Lista com filtros (coordenador+)
  - `GET /supervisor-profiles/me` - Perfil do usuario autenticado
  - `GET /supervisor-profiles/:id` - Busca por ID
  - `PATCH /supervisor-profiles/:id` - Atualiza perfil
  - `PATCH /supervisor-profiles/:id/deactivate` - Desativa (admin)
- [ ] **Testes** - Unitarios do service + e2e do controller

**Epico relacionado**: Prerequisito para todos os epicos (autoria de relatorios)

---

### 3.2 Plant Module

- [ ] **DTOs**
  - `create-plant.dto.ts` - name, sifCode, type, address?, contact?, species[]
  - `update-plant.dto.ts` - PartialType do create
  - `plant-query.dto.ts` - Filtros: type, species, isActive, search (nome/SIF)
  - `plant-response.dto.ts` - Resposta com contadores de relatorios
- [ ] **Service** (`plant.service.ts`)
  - `create(dto)` - Cria planta com validacao de SIF unico
  - `findAll(query)` - Listagem com filtros e paginacao
  - `findOne(id)` - Busca por ID com contadores
  - `update(id, dto)` - Atualizacao parcial
  - `deactivate(id)` - Soft delete
- [ ] **Controller** (`plant.controller.ts`)
  - `POST /plants` - Cria planta (coordenador+)
  - `GET /plants` - Lista com filtros (todos)
  - `GET /plants/:id` - Detalhes (todos)
  - `PATCH /plants/:id` - Atualiza (coordenador+)
  - `PATCH /plants/:id/deactivate` - Desativa (admin)
- [ ] **Testes** - Unitarios + e2e

**Epico relacionado**: Prerequisito para todos os epicos (local dos relatorios)

---

### 3.3 SlaughterReport Module (FM 7.1.4.x)

- [ ] **DTOs**
  - `create-slaughter-report.dto.ts` - Todos os campos do modelo + validacoes
  - `update-slaughter-report.dto.ts` - PartialType (somente status=rascunho)
  - `slaughter-report-query.dto.ts` - Filtros: plantId, date range, species, status, shift
  - `submit-slaughter-report.dto.ts` - Transicao rascunho -> enviado
  - `review-slaughter-report.dto.ts` - Transicao enviado -> revisado/aprovado/rejeitado
  - `slaughter-verification-item.dto.ts` - 14 itens C/NC (fixos)
  - `stunning-verification.dto.ts` - Avaliacao de insensibilizacao (bovinos)
- [ ] **Service** (`slaughter-report.service.ts`)
  - `create(dto, supervisorId)` - Cria com serial automatico (SIF/ANO/SEQ)
  - `findAll(query)` - Listagem com filtros, paginacao e includes
  - `findOne(id)` - Detalhes completos com plant e supervisor
  - `update(id, dto)` - Somente rascunhos
  - `submit(id)` - Valida e envia para revisao
  - `review(id, dto, reviewerId)` - Coordenador revisa/aprova/rejeita
  - `cancel(id, reason)` - Cancela com motivo
  - `generateSerialNumber(plantSif, year)` - SIF/ANO/SEQ sequencial
  - `validateVerificationItems(items)` - Valida 14 itens obrigatorios
  - `validateStunning(species, data)` - Valida dados de stunning para bovinos
- [ ] **Controller** (`slaughter-report.controller.ts`)
  - `POST /slaughter-reports` - Cria relatorio (supervisor+)
  - `GET /slaughter-reports` - Lista com filtros (todos)
  - `GET /slaughter-reports/:id` - Detalhes (todos)
  - `PATCH /slaughter-reports/:id` - Atualiza rascunho (autor)
  - `POST /slaughter-reports/:id/submit` - Envia para revisao (autor)
  - `POST /slaughter-reports/:id/review` - Revisa (coordenador+)
  - `POST /slaughter-reports/:id/cancel` - Cancela (coordenador+)
- [ ] **Testes** - Unitarios + e2e + validacao de itens C/NC

**Epico**: Epic 01 - Relatorios de Abate | **Stories**: 7 | **Points**: 47 | **Prioridade**: P0

---

### 3.4 ProductionReport Module (FM 7.1.3.x / FM 7.1.8.x)

- [ ] **DTOs**
  - `create-production-report.dto.ts` - Todos os campos + materias-primas + ingredientes
  - `update-production-report.dto.ts` - PartialType (somente rascunho)
  - `production-report-query.dto.ts` - Filtros: plantId, date range, status, isSpecialProduction
  - `submit-production-report.dto.ts` - Transicao rascunho -> enviado
  - `review-production-report.dto.ts` - Transicao enviado -> revisado/aprovado/rejeitado
  - `production-verification-item.dto.ts` - 5 itens C/NC (fixos)
  - `meat-raw-material.dto.ts` - frigorifico, SIF, data abate, CSN, certificado Halal
  - `approved-ingredient.dto.ts` - fornecedor, lote, validade
- [ ] **Service** (`production-report.service.ts`)
  - `create(dto, supervisorId)` - Cria com serial automatico
  - `findAll(query)` - Listagem com filtros e paginacao
  - `findOne(id)` - Detalhes completos
  - `update(id, dto)` - Somente rascunhos
  - `submit(id)` - Valida e envia
  - `review(id, dto, reviewerId)` - Coordenador revisa
  - `cancel(id, reason)` - Cancela com motivo
  - `validateRawMaterials(materials)` - Valida materias-primas obrigatorias
  - `validateIngredients(ingredients)` - Valida ingredientes aprovados
- [ ] **Controller** (`production-report.controller.ts`)
  - `POST /production-reports` - Cria relatorio (supervisor+)
  - `GET /production-reports` - Lista com filtros (todos)
  - `GET /production-reports/:id` - Detalhes (todos)
  - `PATCH /production-reports/:id` - Atualiza rascunho (autor)
  - `POST /production-reports/:id/submit` - Envia para revisao (autor)
  - `POST /production-reports/:id/review` - Revisa (coordenador+)
  - `POST /production-reports/:id/cancel` - Cancela (coordenador+)
- [ ] **Testes** - Unitarios + e2e + validacao de materias-primas

**Epico**: Epic 02 - Relatorios de Producao | **Stories**: 6 | **Points**: 40 | **Prioridade**: P0

---

### 3.5 ShippingReport Module (FM 7.1.7.x / DCPOA)

- [ ] **DTOs**
  - `create-shipping-report.dto.ts` - Campos base + campos condicionais por tipo
  - `update-shipping-report.dto.ts` - PartialType (somente rascunho)
  - `shipping-report-query.dto.ts` - Filtros: plantId, date range, shippingType, status
  - `submit-shipping-report.dto.ts` - Transicao rascunho -> enviado
  - `review-shipping-report.dto.ts` - Transicao enviado -> revisado/aprovado/rejeitado
  - `shipping-verification-item.dto.ts` - 2 itens C/NC (exclusividade Halal + selo)
  - `shipping-product.dto.ts` - produto, codigo, lote, datas, pesos, temperatura
- [ ] **Service** (`shipping-report.service.ts`)
  - `create(dto, supervisorId)` - Cria com serial automatico
  - `findAll(query)` - Listagem com filtros e paginacao
  - `findOne(id)` - Detalhes completos
  - `update(id, dto)` - Somente rascunhos
  - `submit(id)` - Valida campos condicionais por tipo e envia
  - `review(id, dto, reviewerId)` - Coordenador revisa
  - `cancel(id, reason)` - Cancela com motivo
  - `validateByType(type, data)` - Valida campos obrigatorios por shippingType:
    - exportacao: importer, container, ports, sealNumber obrigatorios
    - venda_interna: campos simplificados
    - transferencia: DCPOA campos minimos
  - `validateProducts(products)` - Valida lista de produtos
- [ ] **Controller** (`shipping-report.controller.ts`)
  - `POST /shipping-reports` - Cria relatorio (supervisor+)
  - `GET /shipping-reports` - Lista com filtros (todos)
  - `GET /shipping-reports/:id` - Detalhes (todos)
  - `PATCH /shipping-reports/:id` - Atualiza rascunho (autor)
  - `POST /shipping-reports/:id/submit` - Envia para revisao (autor)
  - `POST /shipping-reports/:id/review` - Revisa (coordenador+)
  - `POST /shipping-reports/:id/cancel` - Cancela (coordenador+)
- [ ] **Testes** - Unitarios + e2e + validacao por tipo

**Epico**: Epic 03 - Relatorios de Embarque | **Stories**: 6 | **Points**: 38 | **Prioridade**: P0

---

### 3.6 NonConformity Module (FM 7.1.6.1)

- [ ] **DTOs**
  - `create-non-conformity.dto.ts` - description, severity, category, evidence?, vinculo a relatorio?
  - `update-non-conformity.dto.ts` - PartialType (somente aberta/em_tratamento)
  - `non-conformity-query.dto.ts` - Filtros: plantId, severity, status, category, date range, overdue
  - `treat-non-conformity.dto.ts` - correctiveAction, preventiveAction (aberta -> em_tratamento)
  - `resolve-non-conformity.dto.ts` - Resolucao com evidencia (em_tratamento -> resolvida)
  - `verify-non-conformity.dto.ts` - Verificacao final (resolvida -> verificada -> encerrada)
- [ ] **Service** (`non-conformity.service.ts`)
  - `create(dto, supervisorId)` - Cria NC com prazo automatico de 7 dias
  - `findAll(query)` - Listagem com filtros, paginacao e flag de vencidas
  - `findOne(id)` - Detalhes com relatorio de origem e timeline
  - `update(id, dto)` - Somente aberta/em_tratamento
  - `treat(id, dto)` - Adiciona acao corretiva/preventiva
  - `resolve(id, dto, resolverId)` - Marca como resolvida
  - `verify(id, dto, verifierId)` - Coordenador verifica e encerra
  - `reopen(id, reason)` - Reabre NC (verificacao falhou)
  - `findOverdue()` - Lista NCs que ultrapassaram prazo de 7 dias
  - `calculateDeadline(createdAt)` - Calcula data limite (+7 dias corridos)
  - **Workflow**: aberta -> em_tratamento -> resolvida -> verificada -> encerrada
- [ ] **Controller** (`non-conformity.controller.ts`)
  - `POST /non-conformities` - Cria NC (supervisor+)
  - `GET /non-conformities` - Lista com filtros (todos)
  - `GET /non-conformities/overdue` - Lista vencidas (coordenador+)
  - `GET /non-conformities/:id` - Detalhes (todos)
  - `PATCH /non-conformities/:id` - Atualiza (autor/coordenador)
  - `POST /non-conformities/:id/treat` - Inicia tratamento (supervisor+)
  - `POST /non-conformities/:id/resolve` - Resolve (supervisor+)
  - `POST /non-conformities/:id/verify` - Verifica e encerra (coordenador+)
  - `POST /non-conformities/:id/reopen` - Reabre (coordenador+)
- [ ] **Testes** - Unitarios + e2e + workflow completo + prazo 7 dias

**Epico**: Epic 04 - Nao-Conformidades | **Stories**: 6 | **Points**: 35 | **Prioridade**: P0

---

### 3.7 Schedule Module

- [ ] **DTOs**
  - `create-schedule.dto.ts` - supervisorId, plantId, date, shift, type, notes?
  - `update-schedule.dto.ts` - PartialType
  - `schedule-query.dto.ts` - Filtros: supervisorId, plantId, date range, shift, type
  - `bulk-create-schedule.dto.ts` - Criacao em lote (escala mensal)
- [ ] **Service** (`schedule.service.ts`)
  - `create(dto)` - Cria alocacao com validacao de unique constraint
  - `bulkCreate(dtos)` - Criacao em lote para escala mensal
  - `findAll(query)` - Listagem com filtros e paginacao
  - `findByMonth(year, month, plantId?)` - Calendario mensal
  - `findBySupervisor(supervisorId, dateRange)` - Escala do supervisor
  - `findByPlant(plantId, dateRange)` - Escala da planta
  - `update(id, dto)` - Atualiza alocacao
  - `delete(id)` - Remove alocacao
  - `checkConflict(supervisorId, date, shift)` - Verifica conflito de horario
- [ ] **Controller** (`schedule.controller.ts`)
  - `POST /schedules` - Cria alocacao (coordenador+)
  - `POST /schedules/bulk` - Cria em lote (coordenador+)
  - `GET /schedules` - Lista com filtros (todos)
  - `GET /schedules/month/:year/:month` - Calendario mensal (todos)
  - `GET /schedules/supervisor/:id` - Escala do supervisor (supervisor proprio ou coordenador+)
  - `GET /schedules/plant/:id` - Escala da planta (coordenador+)
  - `PATCH /schedules/:id` - Atualiza (coordenador+)
  - `DELETE /schedules/:id` - Remove (coordenador+)
- [ ] **Testes** - Unitarios + e2e + unique constraint + bulk

**Epico**: Epic 05 - Escala de Supervisores | **Stories**: 4 | **Points**: 20 | **Prioridade**: P1

---

### 3.8 Dashboard Module

- [ ] **DTOs**
  - `dashboard-query.dto.ts` - Filtros: plantId?, dateRange, supervisorId?
  - `dashboard-summary.dto.ts` - Resposta com todos os indicadores
- [ ] **Service** (`dashboard.service.ts`)
  - `getSummary(query, userRole)` - Indicadores consolidados por persona:
    - **Supervisor**: seus relatorios, suas NCs, sua escala
    - **Coordenador**: todos os relatorios, todas as NCs, todas as escalas
    - **Gestor**: visao executiva com tendencias
  - `getReportCounts(query)` - Contadores por tipo e status (dia/semana/mes)
  - `getNCCounts(query)` - NCs ativas por severidade e planta
  - `getPendingReviews(query)` - Relatorios pendentes de revisao
  - `getProductivity(query)` - Relatorios por supervisor por periodo
  - `getTrends(query)` - Dados para graficos de tendencia (30/60/90 dias)
  - `getOverdueNCs(query)` - NCs que ultrapassaram prazo de 7 dias
- [ ] **Controller** (`dashboard.controller.ts`)
  - `GET /dashboard/summary` - Resumo consolidado (todos, filtrado por role)
  - `GET /dashboard/reports` - Contadores de relatorios
  - `GET /dashboard/non-conformities` - Indicadores de NCs
  - `GET /dashboard/pending-reviews` - Pendentes de revisao (coordenador+)
  - `GET /dashboard/productivity` - Produtividade (coordenador+)
  - `GET /dashboard/trends` - Tendencias (gestor+)
- [ ] **Testes** - Unitarios + e2e + visoes por persona

**Epico**: Epic 06 - Dashboard e Relatorios | **Stories**: 4 | **Points**: 22 | **Prioridade**: P1

---

### Ordem de Implementacao da Fase 3

A ordem recomendada leva em conta dependencias entre modulos:

```
Semana 1:  SupervisorProfile + Plant (prerequisitos, sem dependencia externa)
Semana 2:  SlaughterReport (P0, modulo mais complexo, 47 SP)
Semana 3:  ProductionReport (P0, similar ao SlaughterReport)
Semana 4:  ShippingReport (P0, 3 tipos condicionais)
Semana 5:  NonConformity (P0, vinculado aos 3 relatorios anteriores)
Semana 6:  Schedule + Dashboard (P1, dependem de dados existentes)
```

**Verificacao da Fase 3**: Swagger mostra todos os endpoints, CRUD funciona via Swagger/Postman, workflows testados.

---

## Fase 4: Frontend Core (PENDENTE)

**Objetivo**: Base funcional do frontend com auth e layout.

- [ ] **4.1** Axios Instances
  - `services/api.ts` - Instancia Axios para SIH backend (baseURL, interceptors, token)
  - `services/auth-api.ts` - Instancia Axios para Gestao de Certificacoes (autenticacao)
  - `services/utils.ts` - Helpers: error handling, retry logic, response parsing
  - Interceptors: token automatico no header, refresh token, redirect 401
- [ ] **4.2** shadcn/ui Components (16 componentes base)
  - Button, Card, Input, Label, Select, Textarea
  - Table, Dialog, Sheet, Tabs
  - Badge, Alert, Toast (Sonner)
  - Calendar, Popover, DropdownMenu
  - Configuracao de tema Halal (cores: verde, dourado, branco)
- [ ] **4.3** Layout
  - `components/layout/AppLayout.tsx` - Layout principal com sidebar + header + content
  - `components/layout/Header.tsx` - Barra superior: logo, nome do usuario, notificacoes, logout
  - `components/layout/Sidebar.tsx` - Menu lateral: navegacao por modulo, collapse em mobile
  - Responsividade: sidebar -> bottom nav em mobile/tablet
- [ ] **4.4** Auth Flow
  - `pages/Login.tsx` - Tela de login (redirect para Gestao de Certificacoes)
  - `hooks/useAuth.ts` - Hook de autenticacao: login, logout, isAuthenticated, user
  - `components/guards/PrivateRoute.tsx` - Guard de rota autenticada
  - `components/guards/RoleRoute.tsx` - Guard de rota por role
  - Cache de JWT no localStorage com validacao de expiracao
  - Refresh token automatico
- [ ] **4.5** Shared Components (reutilizados entre epicos)
  - `components/shared/VerificationChecklist.tsx` - Renderiza itens C/NC com checkboxes (parametrizavel)
  - `components/shared/ProductTable.tsx` - Tabela editavel de produtos (add/edit/remove linhas)
  - `components/shared/ReportHeader.tsx` - Cabecalho padrao: FM, serial, planta, supervisor, data
  - `components/shared/StatusBadge.tsx` - Badge colorido por status de relatorio/NC
  - `components/shared/PaginatedTable.tsx` - Tabela com paginacao, sort e filtros
  - `components/shared/ConfirmDialog.tsx` - Dialog de confirmacao reutilizavel
  - `components/shared/LoadingSpinner.tsx` - Spinner de carregamento
  - `components/shared/EmptyState.tsx` - Estado vazio com ilustracao e acao

**Verificacao**: Login funciona (com Gestao de Certificacoes rodando), layout renderiza, navegacao funcional.

---

## Fase 5: Frontend Pages (PENDENTE)

**Objetivo**: Todas as paginas funcionais com integracao completa ao backend.

- [ ] **5.1** Dashboard (Epic 06)
  - `pages/Dashboard.tsx` - Pagina principal com 3 visoes por persona
  - Componentes: KPI cards, graficos de tendencia, lista de pendencias
  - Filtros: planta, periodo, tipo de relatorio
  - Auto-refresh a cada 30 segundos
- [ ] **5.2** Relatorios de Abate (Epic 01)
  - `pages/slaughter/SlaughterReportList.tsx` - Listagem com filtros avancados
  - `pages/slaughter/SlaughterReportForm.tsx` - Formulario com:
    - 14 itens de verificacao C/NC
    - Secao de insensibilizacao (bovinos): avaliacao de pressao + conferencias
    - Contagem: total, aprovados, rejeitados + sequencial
    - Camaras de resfriamento, subprodutos
  - `pages/slaughter/SlaughterReportDetails.tsx` - Visualizacao + acoes de workflow
- [ ] **5.3** Relatorios de Producao (Epic 02)
  - `pages/production/ProductionReportList.tsx` - Listagem com filtros
  - `pages/production/ProductionReportForm.tsx` - Formulario com:
    - 5 itens de verificacao C/NC
    - Tabela de materias-primas carneas (frigorifico, SIF, data abate, CSN, cert Halal)
    - Tabela de ingredientes aprovados (fornecedor, lote, validade)
    - Dados do produto final (codigo, lote, datas, pesos, embalagem)
    - Flag producao especial (FM 7.1.8.x)
  - `pages/production/ProductionReportDetails.tsx` - Visualizacao + acoes de workflow
- [ ] **5.4** Relatorios de Embarque (Epic 03)
  - `pages/shipping/ShippingReportList.tsx` - Listagem com filtros + tipo
  - `pages/shipping/ShippingReportForm.tsx` - Formulario com:
    - 2 itens de verificacao C/NC
    - Selecao de tipo: exportacao, venda interna, transferencia
    - Campos condicionais por tipo (exportacao: importer, container, portos, lacre)
    - Tabela de produtos (produto, codigo, lote, datas, pesos, temperatura)
  - `pages/shipping/ShippingReportDetails.tsx` - Visualizacao + acoes de workflow
- [ ] **5.5** Nao-Conformidades (Epic 04)
  - `pages/non-conformity/NCList.tsx` - Listagem com filtros + indicador vencidas
  - `pages/non-conformity/NCForm.tsx` - Formulario com:
    - Vinculo opcional a relatorio de origem
    - Severidade (critica, maior, menor, observacao)
    - Categoria (higiene, processo, equipamento, materia-prima, rotulagem, etc.)
    - Evidencias (descricoes/fotos)
    - Acoes corretivas e preventivas
  - `pages/non-conformity/NCDetails.tsx` - Visualizacao com:
    - Timeline do workflow completo
    - Prazo de 7 dias com countdown
    - Botoes de transicao de status conforme role
- [ ] **5.6** Escala de Supervisores (Epic 05)
  - `pages/schedule/ScheduleCalendar.tsx` - Calendario visual mensal
    - Visao por planta ou por supervisor
    - Drag-and-drop para alocacao
    - Cores por tipo (regular, substituicao, extra, folga)
  - `pages/schedule/ScheduleManagement.tsx` - Gestao da escala
    - Criacao individual e em lote (mensal)
    - Validacao de conflitos em tempo real
- [ ] **5.7** Plantas (Cadastro)
  - `pages/plants/PlantList.tsx` - Listagem com filtros e busca
  - `pages/plants/PlantForm.tsx` - Formulario CRUD completo

**Verificacao**: Navegacao completa, formularios funcionam, listagens com filtros, workflow de NCs.

---

## Fase 6: Finalizacao (PENDENTE)

**Objetivo**: Sistema pronto para uso end-to-end.

- [ ] **6.1** Seed Data
  - 5 plantas de teste (abatedouro, frigorifico, processamento, etc.)
  - 10 supervisores com diferentes roles
  - 20+ relatorios de exemplo (todos os tipos e status)
  - 10+ NCs em diferentes estagios do workflow
  - Escala de 1 mes para todas as plantas
- [ ] **6.2** Docker
  - `docker-compose.yml` testado e funcional (backend + frontend + postgres + redis)
  - `Dockerfile` multi-stage para backend (build + prod)
  - `Dockerfile` multi-stage para frontend (build + nginx)
  - `init-extensions.sql` - Cria extensoes PostgreSQL automaticamente
  - Health checks em todos os servicos
- [ ] **6.3** Git
  - Repos inicializados com historico limpo
  - `.gitignore` validado (node_modules, .env, dist, .prisma)
  - Branches: main, develop
  - Tags de versao: v1.0.0
- [ ] **6.4** Build Test
  - `npm install` sem erros em ambos os repos
  - `npm run build` sem erros em ambos os repos
  - `npm run lint` sem warnings em ambos os repos
  - Smoke test: login -> criar relatorio -> submeter -> revisar -> dashboard

**Verificacao**: Sistema completo funcionando end-to-end com dados de teste.

---

## Fases Futuras

### Fase Futura A: Offline Completo

**Prerequisito**: v1.0 em producao, PWA base ja instalada.

- [ ] IndexedDB (Dexie.js) - Armazena relatorios preenchidos offline no tablet
- [ ] Background Sync - Envia relatorios pendentes automaticamente quando reconectar
- [ ] Cache de referencia - Plantas, templates de verificacao, perfil do supervisor
- [ ] Indicador visual - Badge online/offline + quantidade pendente de sincronizacao
- [ ] Resolucao de conflitos - Timestamp-based (ultimo ganha) ou merge manual para NCs

**Impacto**: Permite uso em plantas sem internet estavel (realidade de muitos frigorificos).

---

### Fase Futura B: Inventario (Epic 07)

**Prerequisito**: v1.0 em producao, relatorios gerando dados.

- [ ] Conta corrente de carne (FM 7.1.5.1) - Recebido vs. utilizado em producao
- [ ] Inventario de lotes (FM 7.1.5.6) - Gerado vs. transferido entre unidades
- [ ] Inventario de rotulagem (FM 7.1.3.6) - Sem rotulo -> rotulado -> embarcado/descartado
- [ ] Dashboard de inventario - Visao consolidada de estoques
- [ ] Migracao de dados - Importacao de planilhas Excel historicas

**User Stories**: 6 | **Story Points**: TBD

---

## Dependencias entre Fases

```
                    +-------------------+
                    |   Fase 1:         |
                    |   Scaffolding     |
                    |   [COMPLETA]      |
                    +---------+---------+
                              |
                              v
                    +-------------------+
                    |   Fase 2:         |
                    |   Backend Core    |
                    |   [COMPLETA]      |
                    +---------+---------+
                              |
                              v
                    +-------------------+
                    |   Fase 3:         |
                    |   Backend Dominio |
                    |   [PROXIMO]       |
                    +---------+---------+
                              |
                    +---------+---------+
                    |                   |
                    v                   v
          +-------------------+  +-------------------+
          |   Fase 4:         |  |                   |
          |   Frontend Core   |  |   (pode iniciar   |
          |   [PENDENTE]      |  |    em paralelo    |
          +---------+---------+  |    com Fase 3)    |
                    |            +-------------------+
                    v
          +-------------------+
          |   Fase 5:         |
          |   Frontend Pages  |
          |   [PENDENTE]      |
          +---------+---------+
                    |
                    v
          +-------------------+
          |   Fase 6:         |
          |   Finalizacao     |
          |   [PENDENTE]      |
          +---------+---------+
                    |
          +---------+---------+
          |                   |
          v                   v
+-------------------+  +-------------------+
|   Futuro A:       |  |   Futuro B:       |
|   Offline         |  |   Inventario      |
+-------------------+  +-------------------+
```

### Dependencias Internas da Fase 3

```
+---------------------+     +---------------------+
| SupervisorProfile   |     |       Plant          |
| (prerequisito)      |     | (prerequisito)       |
+----------+----------+     +----------+----------+
           |                           |
           +-------------+-------------+
                         |
           +-------------+-------------+
           |             |             |
           v             v             v
  +--------+---+  +------+------+  +--+----------+
  | Slaughter  |  | Production  |  |  Shipping   |
  | Report     |  | Report      |  |  Report     |
  +--------+---+  +------+------+  +--+----------+
           |             |             |
           +-------------+-------------+
                         |
                         v
              +----------+----------+
              |   NonConformity     |
              |   (vinculada aos 3  |
              |    relatorios)      |
              +----------+----------+
                         |
           +-------------+-------------+
           |                           |
           v                           v
  +--------+--------+     +-----------+---------+
  |    Schedule      |     |     Dashboard       |
  |  (independente,  |     |  (depende de dados  |
  |   usa Plant +    |     |   dos outros)       |
  |   Supervisor)    |     |                     |
  +-----------------+      +---------------------+
```

### Nota sobre Paralelismo

- **Fase 4 pode iniciar em paralelo com Fase 3**: O Frontend Core (layout, auth, componentes) nao depende dos endpoints de dominio. Pode ser desenvolvido simultaneamente.
- **Fase 5 depende de Fase 3 + 4**: As paginas precisam tanto dos endpoints backend quanto dos componentes frontend.
- **Fase 6 depende de Fase 5**: A finalizacao so faz sentido com todas as paginas prontas.

---

## Dependencias Externas

| Dependencia | Descricao | Status |
|-------------|-----------|--------|
| Gestao de Certificacoes (HalalSphere) | API de autenticacao JWT RS256 | Em producao |
| AWS (S3, ECS, CloudFront) | Infraestrutura de deploy | Disponivel |
| PostgreSQL 16 | Banco de dados com extensoes | Configurado |
| Redis 7 | Cache de sessoes e dados frequentes | Disponivel |

---

## Metricas do Projeto

| Metrica | Valor |
|---------|-------|
| Epicos v1.0 | 6 |
| Epicos futuros | 1 (Inventario) |
| User Stories v1.0 | 33 |
| User Stories futuras | 6 |
| Story Points v1.0 | 202 |
| Modulos backend | 8 (Fase 3) |
| Paginas frontend | 22+ (Fase 5) |
| Componentes compartilhados | 8+ (Fase 4) |
| Modelos Prisma | 6 |
| Enums Prisma | 11 |
