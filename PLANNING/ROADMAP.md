---
title: Roadmap Detalhado
nav_order: 5
---

# Roadmap Detalhado de Implementação

**Projeto**: SIH - Supervisão Industrial Halal
**Versão**: v1.0
**Última Atualização**: 2026-02-25

---

## Status Atual

| Fase | Descrição | Status | Progresso |
|------|-----------|--------|-----------|
| Fase 1 | Scaffolding (Repos + Configs) | COMPLETA | 4/4 tarefas |
| Fase 2 | Backend Core (Infra) | COMPLETA | 5/5 tarefas |
| Fase 3 | Backend Domínio (Negócio) | COMPLETA | 8/8 módulos |
| Fase 4 | Frontend Core (Base) | COMPLETA | 5/5 tarefas |
| Fase 5 | Frontend Pages (Páginas) | COMPLETA | 7/7 grupos |
| Fase 6 | Finalização (Seed + Builds) | COMPLETA | 4/4 tarefas |
| Fase 7 | Revisão Abrangente (FM FAMBRAS) | COMPLETA | 9/9 tarefas |

**Resumo de User Stories v1.0**: 39 stories | 7 épicos

---

## Fase 1: Scaffolding (COMPLETA)

**Objetivo**: Criar os 3 repositórios com toda a configuração de projeto.

- [x] **1.1** Criar repositório `sih-docs/`
  - Estrutura de documentação criada
  - PRD completo com 39 user stories em 7 épicos
  - Arquitetura de features documentada
  - Roadmap original definido
- [x] **1.2** Criar repositório `sih-backend/`
  - NestJS scaffolding funcional
  - package.json, tsconfig, eslint, prettier configurados
  - Docker e docker-compose preparados
  - Prisma schema completo com todos os modelos v1.0
- [x] **1.3** Criar repositório `sih-frontend/`
  - React + Vite scaffolding funcional
  - Tailwind CSS configurado
  - Estrutura de pastas: components/, hooks/, pages/, services/, types/
  - PWA manifest preparado
- [x] **1.4** Criar workspace VS Code
  - `SupervisaoIndustrialHalal.code-workspace` configurado
  - 3 repos integrados em workspace único

**Verificação**: Repos criados, configs válidas, workspace abre corretamente.

---

## Fase 2: Backend Core (COMPLETA)

**Objetivo**: Infraestrutura funcional do backend (NestJS).

- [x] **2.1** Config Module
  - `config.module.ts` - Módulo de configuração global
  - Variáveis de ambiente validadas
- [x] **2.2** Prisma Module
  - `prisma.module.ts` - Módulo global do Prisma
  - `prisma.service.ts` - Serviço com PrismaPg adapter (Prisma 7)
  - Schema completo com 6 modelos + 11 enums + índices + constraints
- [x] **2.3** Auth Module (self-contained)
  - Auth própria: bcrypt (salt rounds 10) + JWT HS256
  - `jwt-auth.guard.ts` - Guard de autenticação global
  - `roles.guard.ts` - Guard RBAC (admin, coordenador, supervisor, operador)
  - `current-user.decorator.ts`, `roles.decorator.ts`, `public.decorator.ts`
- [x] **2.4** Health + Common
  - `health.controller.ts` - Endpoint `GET /health`
  - `http-exception.filter.ts` - Filtro global de exceções
  - `logging.interceptor.ts` - Interceptor de logging
  - `serial-number.util.ts` - Gerador serial (SIF/ANO/SEQ)
- [x] **2.5** Banco de Dados
  - PostgreSQL 16 com extensões: uuid-ossp, pgcrypto, pg_trgm
  - Migrações: init, add_password_hash, simplify_roles_and_add_signatures

**Verificação**: `npm run start:dev` funciona, `GET /health` retorna OK, Swagger acessível em `/api/docs`.

---

## Fase 3: Backend Domínio (COMPLETA)

**Objetivo**: Todos os 8 módulos de negócio com CRUD completo.

- [x] **3.1** SupervisorProfile Module — CRUD + passwordHash + deactivate
- [x] **3.2** Plant Module — CRUD com type (abatedouro/frigorifico/processamento) + species[]
- [x] **3.3** SlaughterReport Module (FM 7.1.4.x) — CRUD + verificação C/NC + stunning + serial + sign + cancel + PDF
- [x] **3.4** ProductionReport Module (FM 7.1.3.1) — CRUD + raw materials + ingredients + serial + sign + cancel + PDF
- [x] **3.5** ShippingReport Module (FM 7.1.7.x) — CRUD + 3 tipos + products + serial + sign + cancel + PDF
- [x] **3.6** NonConformity Module (FM 7.1.6.1) — CRUD + workflow (aberta→resolvida→verificada→encerrada) + prazo 7 dias
- [x] **3.7** Schedule Module — CRUD + unique constraint (supervisor+date+shift)
- [x] **3.8** Dashboard Module — Endpoints de agregação

**Workflow de relatórios**: rascunho → [supervisor assina] → assinado (final). Sem etapa de aprovação.
**Assinatura eletrônica**: SHA-256 hash de (conteúdo canonicalizado + signedById + signedAt).

**Verificação**: Swagger mostra todos os endpoints, CRUD funciona via Swagger/Postman.

---

## Fase 4: Frontend Core (COMPLETA)

**Objetivo**: Base funcional do frontend com auth e layout.

- [x] **4.1** Axios Instances — `api.ts` com interceptors + token automático
- [x] **4.2** shadcn/ui Components — 16+ componentes base (new-york variant, Poppins font)
- [x] **4.3** Layout — AppLayout + Header + Sidebar (colapsável, agrupada por tipo)
- [x] **4.4** Auth Flow — Login page, useAuth hook, PrivateRoute guard, JWT em localStorage
- [x] **4.5** Shared Components — VerificationChecklist, ProductTable, ReportHeader, StatusBadge, PaginatedTable, SignatureDialog, SignatureBadge, LoadingSpinner

**Verificação**: Login funciona (auth self-contained), layout renderiza, navegação funcional.

---

## Fase 5: Frontend Pages (COMPLETA)

**Objetivo**: Todas as páginas funcionais.

- [x] **5.1** Dashboard — KPI cards por role
- [x] **5.2** Relatórios de Abate — List + Form (com stunning por espécie) + assinatura
- [x] **5.3** Relatórios de Produção — List + Form (com raw materials 8 colunas + ingredients 5 colunas)
- [x] **5.4** Relatórios de Embarque — List + Form (3 subtipos condicionais + tabela expandida)
- [x] **5.5** Não-Conformidades — List + Form (dropdown de relatórios + workflow com botões por status)
- [x] **5.6** Escala de Supervisores — ScheduleForm (admin + coordenador)
- [x] **5.7** Plantas — PlantList + PlantForm

**Verificação**: Navegação completa, formulários funcionam, listagens com filtros, workflow de NCs.

---

## Fase 6: Finalização (COMPLETA)

**Objetivo**: Sistema pronto para uso end-to-end.

- [x] **6.1** Seed Data — 5 plantas, 4 usuários (admin/coordenador/supervisor/operador), relatórios de exemplo
- [x] **6.2** Docker — docker-compose testado (backend + frontend + postgres + redis)
- [x] **6.3** Git — Repos em 2 remotes (personal + Ecohalal org), .gitignore validado
- [x] **6.4** Build Test — npm install + npm run build sem erros em ambos repos

**Verificação**: Sistema completo funcionando end-to-end com dados de teste.

---

## Fase 7: Revisão Abrangente (COMPLETA)

**Objetivo**: Alinhar formulários ao modelo real dos FMs FAMBRAS, ativar papel coordenador, melhorar navegação e adicionar funcionalidades administrativas.

Baseada na análise dos formulários FAMBRAS reais (FM 7.1.4.1, FM 7.1.4.2, FM 7.1.3.1, FM 7.1.7.1, FM 7.1.7.3, FM 7.1.7.4) localizados em `C:\SIH\`.

- [x] **7.1** Papel coordenador ativado
  - Coordenador vê relatórios em modo somente leitura (sem criar/editar/assinar)
  - Pode cancelar relatórios, gerenciar NCs (verificar/encerrar)
  - Pode criar escalas e gerenciar usuários (supervisores + operadores)
  - Backend: `@Roles('admin', 'supervisor', 'operador')` em create/update de relatórios
- [x] **7.2** Sidebar agrupada por tipo + filtro por role
  - Menu: In Natura (Abate, Embarques) / Industrializados (Produção) / Gestão (Escalas, Usuários, Plantas)
  - Visibilidade filtrada por role (Gestão só para admin/coordenador, Plantas só admin)
  - Grupos colapsáveis com tooltips
- [x] **7.3** CRUD de usuários
  - `UserList.tsx` — tabela com busca + filtro por role
  - `UserForm.tsx` — criar/editar com controle de permissão (coordenador cria supervisor/operador, admin cria todos)
- [x] **7.4** NC dropdown para relatório
  - Substituído input UUID por select com tipo de relatório (abate/produção/embarque)
  - Dropdown dinâmico filtra relatórios por planta selecionada
  - Exibe serialNumber + data + status
- [x] **7.5** Abate: lógica por espécie (aves vs bovino)
  - FM 7.1.4.1 (aves): amperagem, voltagem, frequência, tempo cuba, velocidade linha ×2 horários + tempo de retorno
  - FM 7.1.4.2 (bovino): pressão, animal vivo (S/N), sem lesões (S/N) ×2 conferências
  - Verificações diferenciadas: 12 itens aves vs 14 itens bovino
  - Câmaras de resfriamento e subprodutos (bovino only)
  - formNumber dinâmico baseado na espécie
- [x] **7.6** Embarque enriquecido
  - Campos condicionais: vendedor/cliente/endereço destino (venda interna)
  - Nº série relatório Halal (todos os subtipos)
  - ProductTable expandida: datas abate/produção/validade, peso bruto, temperatura, tipo embalagem
- [x] **7.7** Produção enriquecida
  - Tabela matérias-primas: 8 colunas (proteína, frigorífico, SIF, data abate, CSN, cert. Halal, qtd, unidade)
  - Tabela ingredientes: 5 colunas (produto, código, fornecedor, lote, validade)
- [x] **7.8** Vinculação planta → FMs disponíveis
  - Abate filtra plantas por tipo (abatedouro/frigorífico) e espécies por planta
  - Produção filtra plantas por tipo (processamento)
  - formNumber atribuído automaticamente baseado em plant.type + espécie
- [x] **7.9** Geração PDF fiel ao modelo FAMBRAS
  - PDFKit no backend com templates por FM
  - Cabeçalho com logo FAMBRAS Halal + nº FM + revisão
  - Layout bilíngue (português/inglês) conforme originais
  - Hash de assinatura no rodapé
  - Endpoint `GET /:id/pdf` nos 3 controllers de relatório

**Verificação**: Coordenador vê relatórios read-only sem botão assinar/criar, sidebar agrupada, abate aves com 5 parâmetros ×2 horários, embarque com campos vendedor/cliente, produção com 8 colunas, PDF com logo FAMBRAS.

---

## Fases Futuras

### Fase Futura A: Colaboradores (Collaborator + ReportStaff)

**Prerequisito**: v1.0 em produção.

- [ ] Cadastro de colaboradores — CRUD de degoladores, sheiks, auxiliares (não-usuários)
- [ ] Foto do colaborador — Upload de foto (JPEG/PNG, max 2MB)
- [ ] Vinculação N:N com plantas — `CollaboratorPlant`
- [ ] Equipe por relatório — `ReportStaff` N:N entre colaboradores e relatórios
- [ ] Tela "Equipe do dia" — Seleção múltipla ao preencher relatório
- [ ] Campo `externalId` — Preparado para integração com HalalSphere

### Fase Futura B: Offline Completo

**Prerequisito**: v1.0 em produção, PWA base já instalada.

- [ ] IndexedDB (Dexie.js) — Armazena relatórios offline no tablet
- [ ] Background Sync — Envia pendentes ao reconectar
- [ ] Cache de referência — Plantas, templates, perfil do supervisor
- [ ] Indicador visual — Badge online/offline + qtd pendente
- [ ] Resolução de conflitos — Timestamp-based ou merge manual

### Fase Futura C: Inventário (Epic 07)

**Prerequisito**: v1.0 em produção, relatórios gerando dados.

- [ ] Conta corrente de carne (FM 7.1.5.1) — Recebido vs. utilizado
- [ ] Inventário de lotes (FM 7.1.5.6) — Gerado vs. transferido
- [ ] Inventário de rotulagem (FM 7.1.3.6) — Sem rótulo → rotulado → embarcado
- [ ] Dashboard de inventário — Visão consolidada de estoques
- [ ] Migração de dados — Importação de planilhas Excel históricas

### Fase Futura D: Integração entre Sistemas

**Prerequisito**: HalalSphere e SysHalal em produção.

- [ ] Cadastros compartilhados — HalalSphere → SIH (plantas/empresas via API REST)
- [ ] Dados de supervisão — SIH → SysHalal (relatórios → certificados)
- [ ] Notificações — SIH → HalalSphere (webhooks para NCs críticas)
- [ ] SSO — HalalSphere → SIH (autenticação centralizada)

---

## Dependências Externas

| Dependência | Descrição | Status |
|-------------|-----------|--------|
| PostgreSQL 16 | Banco de dados (porta 5433) | Disponível |
| Redis 7 | Cache (porta 6380) | Disponível |
| HalalSphere | Integração futura — cadastros e SSO | Em produção (independente na v1.0) |
| SysHalal | Integração futura — dados de supervisão | Em produção (independente na v1.0) |
| AWS (S3, ECS) | Infraestrutura de deploy (futuro) | Disponível |
