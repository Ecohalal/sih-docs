# 6. Roadmap de Implementacao

---

## 6.1 Visao Geral

O SIH sera implementado em **6 fases sequenciais** para a v1.0, mais **2 fases futuras** (offline completo e inventario).

```
Fase 1: Scaffolding ────────→ Repos, configs, workspace           [COMPLETA]
Fase 2: Backend Core ───────→ Infra (Prisma, Auth, Health)        [COMPLETA]
Fase 3: Backend Dominio ────→ Modulos de negocio (8 modulos)      [COMPLETA]
Fase 4: Frontend Core ──────→ Layout, auth, componentes base      [COMPLETA]
Fase 5: Frontend Pages ─────→ Paginas + API hooks + design system [COMPLETA]
Fase 6: Finalizacao ────────→ Seed, Docker, builds                [COMPLETA]
─────────────────────────────────────────────────────
Futuro: Colaboradores ─────→ Cadastro, foto, equipe por relatorio
Futuro: Offline Completo ──→ IndexedDB, Background Sync
Futuro: Inventario ────────→ FM 7.1.5.x, FM 7.1.3.6
Futuro: Integracao ────────→ HalalSphere ↔ SIH ↔ SysHalal
```

---

## 6.2 Detalhamento por Fase

### Fase 1: Scaffolding (Repos + Configs)

**Objetivo**: Criar os 3 repositorios com toda a configuracao de projeto.

| # | Tarefa | Entregavel |
|---|--------|-----------|
| 1 | Criar `sih-docs/` | Estrutura de docs + PRD completo |
| 2 | Criar `sih-backend/` | NestJS scaffolding (package.json, tsconfig, eslint, prettier, docker, prisma schema) |
| 3 | Criar `sih-frontend/` | React scaffolding (package.json, vite, tailwind, tsconfig, eslint, PWA manifest) |
| 4 | Criar workspace | `SupervisaoIndustrialHalal.code-workspace` |

**Verificacao**: Repos criados, configs validas, workspace abre corretamente.

---

### Fase 2: Backend Core

**Objetivo**: Infraestrutura funcional do backend.

| # | Tarefa | Entregavel |
|---|--------|-----------|
| 5 | Config module | `config.module.ts` + `aws-config.service.ts` |
| 6 | Prisma module | `prisma.module.ts` + `prisma.service.ts` + schema completo |
| 7 | Auth module | Auth self-contained (bcrypt + JWT HS256), guards, decorators, strategy |
| 8 | Health + Common | Health check, exception filter, logging interceptor, serial number util |

**Verificacao**: `npm run start:dev` funciona, `GET /health` retorna OK, Swagger acessivel em `/api/docs`.

---

### Fase 3: Backend Dominio

**Objetivo**: Todos os modulos de negocio com CRUD completo.

| # | Tarefa | FM | Entregavel |
|---|--------|-----|-----------|
| 9 | SupervisorProfile | - | CRUD + auto-create on JWT access |
| 10 | Plant | - | CRUD completo |
| 11 | SlaughterReport | 7.1.4.x | CRUD + verificacao C/NC + stunning + serial |
| 12 | ProductionReport | 7.1.3.x / 7.1.8.x | CRUD + raw materials + ingredients + serial |
| 13 | ShippingReport | 7.1.7.x / DCPOA | CRUD + 3 tipos + products + serial |
| 14 | NonConformity | 7.1.6.1 | CRUD + workflow + prazo 7 dias |
| 15 | Schedule | - | CRUD + unique constraint |
| 16 | Dashboard | - | Endpoints de agregacao |

**Verificacao**: Swagger mostra todos os endpoints, CRUD funciona via Swagger/Postman.

---

### Fase 4: Frontend Core

**Objetivo**: Base funcional do frontend com auth e layout.

| # | Tarefa | Entregavel |
|---|--------|-----------|
| 17 | Axios instances | `api.ts` (SIH backend) + `auth-api.ts` (SIH auth) + `utils.ts` |
| 18 | shadcn/ui components | 16 componentes base (Button, Card, Input, etc.) |
| 19 | Layout | AppLayout, Header, Sidebar |
| 20 | Auth flow | Login page, useAuth hook, route guards, JWT cache |
| 21 | Shared components | VerificationChecklist, ProductTable, ReportHeader |

**Verificacao**: Login funciona (auth self-contained no SIH), layout renderiza, navegacao funcional.

---

### Fase 5: Frontend Pages

**Objetivo**: Todas as paginas funcionais.

| # | Tarefa | Paginas |
|---|--------|---------|
| 22 | Dashboard | Dashboard.tsx (3 visoes por persona) |
| 23 | Abate | SlaughterReportList, SlaughterReportForm (com stunning), SlaughterReportDetails |
| 24 | Producao | ProductionReportList, ProductionReportForm (com raw materials), ProductionReportDetails |
| 25 | Embarque | ShippingReportList, ShippingReportForm (3 subtipos), ShippingReportDetails |
| 26 | NCs | NCList, NCForm, NCDetails (com workflow) |
| 27 | Escala | ScheduleCalendar, ScheduleManagement |
| 28 | Plantas | PlantList, PlantForm |

**Verificacao**: Navegacao completa, formularios funcionam, listagens com filtros, workflow de NCs.

---

### Fase 6: Finalizacao

**Objetivo**: Sistema pronto para uso.

| # | Tarefa | Entregavel |
|---|--------|-----------|
| 29 | Seed data | Plantas de teste, supervisores, relatorios de exemplo |
| 30 | Docker | docker-compose testado, Dockerfile multi-stage, init-extensions.sql |
| 31 | Git init | Repos inicializados, .gitignore validado |
| 32 | Build test | `npm install` + `npm run build` sem erros em ambos repos |

**Verificacao**: Sistema completo funcionando end-to-end com dados de teste.

---

## 6.3 Fases Futuras

### Fase Futura A: Colaboradores (Collaborator + ReportStaff)

**Prerequisito**: v1.0 em producao.

| Componente | Descricao |
|-----------|-----------|
| Cadastro de colaboradores | CRUD de degoladores, sheiks, auxiliares, veterinarios (nao-usuarios) |
| Foto do colaborador | Upload de foto (JPEG/PNG, max 2MB) via multipart/form-data |
| Vinculacao N:N com plantas | `CollaboratorPlant` — plantas onde o colaborador atua |
| Equipe por relatorio | `ReportStaff` — vinculacao N:N entre colaboradores e relatorios |
| Tela "Equipe do dia" | Selecao multipla de colaboradores ao preencher relatorio |
| PDF com equipe | Relatorio impresso lista a equipe envolvida |
| Campo `externalId` | Preparado para integracao futura com HalalSphere |

### Fase Futura B: Offline Completo

**Prerequisito**: v1.0 em producao, PWA base ja instalada.

| Componente | Descricao |
|-----------|-----------|
| IndexedDB (Dexie.js) | Armazena relatorios preenchidos offline no tablet |
| Background Sync | Envia relatorios pendentes automaticamente quando reconectar |
| Cache de referencia | Plantas, templates de verificacao, perfil do supervisor |
| Indicador visual | Badge online/offline + qtd pendente de sincronizacao |
| Resolucao de conflitos | Timestamp-based (ultimo ganha) ou merge manual para NCs |

### Fase Futura C: Inventario

**Prerequisito**: v1.0 em producao, relatorios gerando dados.

| Componente | FM | Descricao |
|-----------|-----|-----------|
| Conta corrente de carne | 7.1.5.1 | Recebido vs. utilizado em producao |
| Inventario de lotes | 7.1.5.6 | Gerado vs. transferido entre unidades |
| Inventario de rotulagem | 7.1.3.6 | Sem rotulo → rotulado → embarcado |
| Dashboard de inventario | - | Visao consolidada de estoques |
| Migracao de dados | - | Importacao de planilhas Excel historicas |

### Fase Futura D: Integracao entre Sistemas

**Prerequisito**: HalalSphere e SysHalal em producao.

| Componente | Direcao | Descricao |
|-----------|---------|-----------|
| Cadastros compartilhados | HalalSphere → SIH | Plantas/empresas sincronizadas via API REST |
| Dados de supervisao | SIH → SysHalal | Relatorios assinados alimentam emissao de certificados |
| Notificacoes | SIH → HalalSphere | Webhooks para NCs criticas e resumos |
| SSO | HalalSphere → SIH | Autenticacao centralizada (substituindo self-contained) |

---

## 6.4 Dependencias Externas

| Dependencia | Descricao | Status |
|-------------|-----------|--------|
| PostgreSQL 16 | Banco de dados (porta 5433) | Disponivel |
| Redis 7 | Cache (porta 6380) | Disponivel |
| HalalSphere | Integracao futura — cadastros e SSO | Em producao (independente na v1.0) |
| SysHalal | Integracao futura — dados de supervisao | Em producao (independente na v1.0) |
| AWS (S3, ECS) | Infraestrutura de deploy (futuro) | Disponivel |
