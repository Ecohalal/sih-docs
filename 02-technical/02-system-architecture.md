# 2. Arquitetura do Sistema

**SIH - Supervisao Industrial Halal**

---

## 2.1 Diagrama de Alto Nivel

```
                              ┌────────────────────────────────┐
                              │  Ecossistema FAMBRAS (futuro)  │
                              │  HalalSphere ↔ SIH ↔ SysHalal │
                              └────────────────────────────────┘

┌──────────────────────────┐    REST API     │     ┌─────────────────────────┐
│                          │   (JSON/JWT)    │     │                         │
│   Frontend (React PWA)   │◄──────────────►│◄───►│    Backend API (NestJS) │
│                          │                       │                         │
│  - React 19              │  porta 5174           │  - NestJS 11            │
│  - Vite 7                │  (dev)         porta  │  - Prisma 7             │
│  - Tailwind CSS 4        │                3334   │  - Passport JWT         │
│  - shadcn/ui             │                       │  - Swagger /api/docs    │
│  - React Query           │                       │                         │
│  - React Router          │                       │  GET  /health           │
│  - PWA (Service Worker)  │                       │  POST /auth/login       │
│                          │                       │  GET  /api/v1/*         │
└──────────────────────────┘                       └───────┬───────┬─────────┘
                                                           │       │
                                                           │       │
                                              ┌────────────┘       └────────────┐
                                              │                                 │
                                    ┌─────────▼──────────┐          ┌───────────▼─────────┐
                                    │                    │          │                     │
                                    │   PostgreSQL 16    │          │     Redis 7         │
                                    │                    │          │                     │
                                    │  - Banco: sih      │          │  - Cache de sessao  │
                                    │  - Porta: 5433     │          │  - Rate limiting    │
                                    │  - Extensoes:      │          │  - Porta: 6380      │
                                    │    uuid-ossp       │          │                     │
                                    │    pgcrypto        │          └─────────────────────┘
                                    │    pg_trgm         │
                                    │                    │
                                    └────────────────────┘
```

---

## 2.2 Mapeamento de Portas

O SIH usa portas diferentes do HalalSphere (Gestao de Certificacoes) para permitir execucao simultanea em ambiente de desenvolvimento.

| Servico | Porta SIH | Porta HalalSphere | Protocolo |
|---------|:---------:|:-----------------:|-----------|
| Frontend (dev server) | **5174** | 5173 | HTTP |
| Backend API | **3334** | 3333 | HTTP |
| PostgreSQL | **5433** | 5432 | TCP |
| Redis | **6380** | 6379 | TCP |

### URLs de Desenvolvimento

| Recurso | URL |
|---------|-----|
| Frontend | `http://localhost:5174` |
| Backend API | `http://localhost:3334` |
| Swagger/OpenAPI | `http://localhost:3334/api/docs` |
| Health Check | `http://localhost:3334/health` |

---

## 2.3 Estrutura do Backend

### Modulos NestJS

O backend segue a arquitetura modular do NestJS. Os modulos atuais sao de infraestrutura; os modulos de dominio serao adicionados conforme os epicos forem implementados.

```
sih-backend/src/
│
├── main.ts                          # Bootstrap: CORS, Swagger, pipes, filtros
├── app.module.ts                    # Modulo raiz (importa todos os modulos)
├── app.controller.ts                # Controller raiz (rota /)
├── app.service.ts                   # Service raiz
│
├── config/                          # [AppConfigModule] Configuracao
│   ├── config.module.ts             #   Modulo de configuracao (@nestjs/config)
│   ├── aws-config.service.ts        #   Acesso a Secrets Manager e SSM
│   └── index.ts                     #   Re-export
│
├── prisma/                          # [PrismaModule] ORM
│   ├── prisma.module.ts             #   Modulo Prisma (global)
│   ├── prisma.service.ts            #   Service com PrismaPg adapter
│   └── index.ts                     #   Re-export
│
├── auth/                            # [AuthModule] Autenticacao e Autorizacao
│   ├── auth.module.ts               #   Modulo de autenticacao
│   ├── strategies/
│   │   └── jwt.strategy.ts          #   Estrategia JWT (HS256 self-contained)
│   ├── guards/
│   │   ├── jwt-auth.guard.ts        #   Guard de autenticacao JWT
│   │   └── roles.guard.ts           #   Guard de autorizacao RBAC
│   ├── decorators/
│   │   ├── current-user.decorator.ts #  @CurrentUser() - extrai usuario do JWT
│   │   ├── roles.decorator.ts       #   @Roles() - define roles permitidas
│   │   └── public.decorator.ts      #   @Public() - marca rota como publica
│   ├── types/
│   │   └── jwt-payload.type.ts      #   Tipagem do payload JWT
│   └── index.ts                     #   Re-export
│
├── health/                          # [HealthModule] Health Check
│   ├── health.module.ts             #   Modulo de health check (@nestjs/terminus)
│   └── health.controller.ts         #   GET /health (banco, Redis, app)
│
└── common/                          # Utilitarios compartilhados
    ├── filters/
    │   └── http-exception.filter.ts #   Filtro global de excecoes
    ├── interceptors/
    │   └── logging.interceptor.ts   #   Interceptor de logging (todas as requests)
    ├── utils/
    │   └── serial-number.util.ts    #   Gerador de serial SIF/ANO/SEQUENCIAL
    └── index.ts                     #   Re-export
```

### Modulos de Dominio (Futuros)

Conforme os epicos forem implementados, os seguintes modulos serao adicionados:

| Modulo | Epico | Descricao |
|--------|-------|-----------|
| `slaughter-report/` | Epic 01 | Relatorios de abate (aves e bovinos) |
| `production-report/` | Epic 02 | Relatorios de producao industrial |
| `shipping-report/` | Epic 03 | Relatorios de embarque, venda e transferencia |
| `non-conformity/` | Epic 04 | Gestao de nao-conformidades |
| `schedule/` | Epic 05 | Escala de supervisores |
| `dashboard/` | Epic 06 | Dashboard e relatorios gerenciais |
| `plant/` | Compartilhado | CRUD de plantas industriais |
| `supervisor-profile/` | Compartilhado | Perfil local do supervisor |

### Pipeline de Requisicao

Toda requisicao HTTP ao backend passa pelo seguinte pipeline configurado em `main.ts`:

```
Request
  │
  ├── 1. cookie-parser          → Parse de cookies
  ├── 2. CORS                   → Validacao de origem (allowedOrigins)
  ├── 3. LoggingInterceptor     → Log de entrada (metodo, URL, IP)
  ├── 4. JwtAuthGuard           → Validacao do token JWT (exceto @Public)
  ├── 5. RolesGuard             → Verificacao de roles RBAC
  ├── 6. ValidationPipe         → Validacao de DTOs (whitelist, transform)
  ├── 7. Controller/Service     → Logica de negocio
  ├── 8. AllExceptionsFilter    → Tratamento de erros (se houver)
  └── 9. LoggingInterceptor     → Log de saida (status, tempo)
  │
Response
```

### Configuracao de Validacao

O `ValidationPipe` global esta configurado com:

| Opcao | Valor | Efeito |
|-------|-------|--------|
| `whitelist` | `true` | Remove propriedades nao declaradas no DTO |
| `forbidNonWhitelisted` | `true` | Retorna erro 400 para propriedades desconhecidas |
| `transform` | `true` | Transforma payloads no tipo do DTO automaticamente |
| `enableImplicitConversion` | `true` | Converte tipos primitivos (string → number) |

---

## 2.4 Estrutura do Frontend

### Organizacao de Arquivos

```
sih-frontend/src/
│
├── main.tsx                         # Entrypoint React
├── App.tsx                          # Componente raiz (rotas, providers)
├── App.css                          # Estilos globais da aplicacao
├── index.css                        # Estilos base (Tailwind directives)
│
├── lib/                             # Utilitarios e configuracoes
│   ├── api.ts                       #   Instancia Axios configurada (baseURL, interceptors)
│   ├── auth-api.ts                  #   Funcoes de autenticacao (login, refresh)
│   ├── utils.ts                     #   Utilitarios gerais (cn, formatadores)
│   └── offline/                     #   Preparacao para modo offline (stubs)
│       ├── index.ts                 #     Re-export
│       ├── db.ts                    #     IndexedDB via Dexie.js (futuro)
│       └── sync-queue.ts           #     Fila de sincronizacao (futuro)
│
├── types/                           # Definicoes de tipos TypeScript
│   ├── index.ts                     #   Re-export
│   └── auth.types.ts                #   Tipos de autenticacao (User, JWT, Roles)
│
├── components/                      # Componentes reutilizaveis [futuro]
│   ├── ui/                          #   Componentes shadcn/ui (Button, Input, etc.)
│   ├── layout/                      #   Layout (Sidebar, Header, Breadcrumb)
│   └── shared/                      #   Componentes compartilhados entre paginas
│       ├── VerificationChecklist    #     Checklist C/NC (Epics 01, 02, 03)
│       ├── ProductTable             #     Tabela de produtos (Epics 02, 03)
│       └── ReportHeader             #     Cabecalho padrao (Epics 01, 02, 03)
│
└── pages/                           # Paginas por dominio [futuro]
    ├── auth/                        #   Login, logout
    ├── slaughter/                   #   Relatorios de abate (Epic 01)
    ├── production/                  #   Relatorios de producao (Epic 02)
    ├── shipping/                    #   Relatorios de embarque (Epic 03)
    ├── non-conformity/              #   Nao-conformidades (Epic 04)
    ├── schedule/                    #   Escala de supervisores (Epic 05)
    └── Dashboard.tsx                #   Dashboard principal (Epic 06)
```

### Padroes do Frontend

| Padrao | Implementacao | Observacao |
|--------|---------------|------------|
| Estado do servidor | React Query (`@tanstack/react-query`) | Cache automatico, revalidacao, staleTime: 5min |
| Estado local | React Hooks (`useState`, `useReducer`) | Para estado de UI (modais, formularios) |
| Formularios | React Hook Form + Zod | Validacao inline, autosave de rascunho (30s) |
| Roteamento | React Router v7 | Lazy loading por rota (code splitting) |
| HTTP Client | Axios | Interceptors para JWT e tratamento de erros |
| Estilizacao | Tailwind CSS + CVA | Utility-first com variantes de componentes |
| Componentes | shadcn/ui (Radix UI) | Copiados para o projeto, customizados com tema FAMBRAS |

---

## 2.5 Padroes de Comunicacao

### REST API

Toda comunicacao entre frontend e backend e via REST API com JSON.

```
Frontend (React)                    Backend (NestJS)
     │                                    │
     │  POST /auth/login                  │
     │  { email, password }               │
     │ ──────────────────────────────────► │ → Valida credenciais
     │                                    │ → Gera JWT
     │ ◄────────────────────────────────  │
     │  { token, user }                   │
     │                                    │
     │  GET /api/v1/slaughter-reports     │
     │  Authorization: Bearer <JWT>       │
     │ ──────────────────────────────────► │ → JwtAuthGuard valida token
     │                                    │ → RolesGuard verifica permissao
     │ ◄────────────────────────────────  │ → Retorna dados paginados
     │  { data: [...], meta: { page } }   │
     │                                    │
```

### Fluxo de Autenticacao JWT

```
┌──────────────┐     ┌──────────────────┐     ┌──────────────────┐
│   Usuario    │     │   SIH Frontend   │     │   SIH Backend    │
│  (Navegador) │     │   (React PWA)    │     │   (NestJS)       │
└──────┬───────┘     └────────┬─────────┘     └────────┬─────────┘
       │                      │                         │
       │  1. Email + Senha    │                         │
       │ ────────────────────►│                         │
       │                      │                         │
       │                      │  2. POST /auth/login    │
       │                      │ ───────────────────────►│
       │                      │                         │
       │                      │  3. bcrypt verifica     │
       │                      │     JWT HS256 (7 dias)  │
       │                      │ ◄───────────────────────│
       │                      │                         │
       │  4. Armazena token   │                         │
       │  (localStorage)      │                         │
       │ ◄────────────────────│                         │
       │                      │                         │
       │  5. Requisicao API   │                         │
       │  com Bearer token    │                         │
       │ ────────────────────►│                         │
       │                      │  6. GET /api            │
       │                      │  + Bearer JWT           │
       │                      │ ───────────────────────►│
       │                      │                         │
       │                      │  7. Valida JWT HS256    │
       │                      │  (JWT_SECRET)           │
       │                      │                         │
       │                      │  8. Dados               │
       │                      │ ◄───────────────────────│
       │  9. Renderiza UI     │                         │
       │ ◄────────────────────│                         │
```

**Pontos importantes**:
- Na v1.0, o login e feito diretamente no **backend SIH** (`POST /auth/login`)
- Autenticacao **self-contained**: bcrypt para senhas + JWT HS256 para tokens
- O JWT tem validade de **7 dias** (estendida para uso em campo)
- NAO depende do HalalSphere para autenticar (integracao futura via SSO)

### Padroes de Resposta da API

#### Sucesso (lista paginada)

```json
{
  "data": [
    { "id": "uuid", "serial": "451/2026/000001", ... }
  ],
  "meta": {
    "page": 1,
    "perPage": 20,
    "total": 150,
    "totalPages": 8
  }
}
```

#### Sucesso (item unico)

```json
{
  "data": {
    "id": "uuid",
    "serial": "451/2026/000001",
    ...
  }
}
```

#### Erro

```json
{
  "statusCode": 400,
  "message": "Validation failed",
  "errors": [
    { "field": "plantId", "message": "plantId should not be empty" }
  ],
  "timestamp": "2026-02-24T10:30:00.000Z",
  "path": "/api/v1/slaughter-reports"
}
```

---

## 2.6 Arquitetura de Deploy

### Desenvolvimento Local

```
┌─────────────────────────────────────────────────────────────────┐
│                     Docker Compose                              │
│                                                                 │
│  ┌───────────────┐  ┌───────────────┐  ┌─────────────────────┐ │
│  │  PostgreSQL   │  │    Redis      │  │   Backend (NestJS)  │ │
│  │  :5433        │  │    :6380      │  │   :3334             │ │
│  │  sih-postgres │  │  sih-redis    │  │   sih-backend       │ │
│  │  (always on)  │  │  (always on)  │  │   (profile: full)   │ │
│  └───────────────┘  └───────────────┘  └─────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                     Host (fora do Docker)                        │
│                                                                 │
│  ┌─────────────────────┐       ┌──────────────────────────────┐│
│  │  Frontend (Vite)    │       │  Backend (nest start --watch)││
│  │  :5174              │       │  :3334 (alternativa local)   ││
│  │  npm run dev        │       │  npm run start:dev           ││
│  └─────────────────────┘       └──────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

**Modos de execucao**:
- `docker compose up -d` → Sobe apenas infraestrutura (PostgreSQL + Redis)
- `docker compose --profile full up -d` → Sobe tudo (infra + backend em container)
- O frontend sempre roda no host via `npm run dev` (Vite dev server)
- O backend pode rodar no host (`npm run start:dev`) ou em container (profile full)

### Producao (AWS)

```
┌─────────────────────────────────────────────────────────────────┐
│                          AWS Cloud                              │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │                     CloudFront (CDN)                        ││
│  │         dominio-sih.fambras.org.br                         ││
│  └────────────────┬────────────────────────────────────────────┘│
│                   │                                             │
│    ┌──────────────▼──────────────┐                              │
│    │          S3 Bucket          │                              │
│    │   Frontend Build (static)   │                              │
│    │   index.html, assets/*.js   │                              │
│    └─────────────────────────────┘                              │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │                    VPC Privada                              ││
│  │                                                             ││
│  │  ┌─────────────────┐  ┌──────────────┐  ┌───────────────┐ ││
│  │  │  ECS (Fargate)  │  │  RDS         │  │ ElastiCache   │ ││
│  │  │  Backend NestJS │──│  PostgreSQL  │  │ Redis         │ ││
│  │  │  (containers)   │  │  16          │  │               │ ││
│  │  └─────────────────┘  └──────────────┘  └───────────────┘ ││
│  │                                                             ││
│  │  ┌─────────────────┐  ┌──────────────────────────────────┐ ││
│  │  │  S3 Bucket      │  │  Secrets Manager + SSM           │ ││
│  │  │  Evidencias/    │  │  (credenciais e configuracao)    │ ││
│  │  │  uploads        │  │                                  │ ││
│  │  └─────────────────┘  └──────────────────────────────────┘ ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

**Fluxo de deploy**:
1. Frontend: Build Vite → upload para S3 → invalidacao CloudFront
2. Backend: Build Docker → push para ECR → deploy no ECS Fargate
3. Banco: Migracao Prisma executada antes do deploy (via CI/CD)
4. Configuracao: Secrets Manager (credenciais) + SSM Parameter Store (config)

---

## 2.7 Ecossistema FAMBRAS

O SIH faz parte de um ecossistema de 3 sistemas independentes. Na v1.0, o SIH opera de forma **totalmente autonoma**.

```
┌──────────────────────────┐         ┌──────────────────────────┐         ┌──────────────────────────┐
│   HalalSphere            │         │          SIH             │         │   SysHalal               │
│   (Certificacoes)        │         │  (Supervisao Industrial) │         │   (Cert. Exportacao)     │
│                          │  futuro │                          │  futuro │                          │
│  Empresas, auditorias    │ · · · ►│  Relatorios de campo     │ · · · ►│  Certificados Halal      │
│  Certificados Halal      │         │  NCs, escalas            │         │  PDFs, QR Code           │
│                          │         │                          │         │                          │
│  Porta: 3333             │         │  Porta: 3334             │         │  Porta: configuravel     │
│  (PostgreSQL :5432)      │         │  (PostgreSQL :5433)      │         │  (PostgreSQL :5432)      │
└──────────────────────────┘         └──────────────────────────┘         └──────────────────────────┘
```

| Ponto de Integracao | Direcao | Status |
|---------------------|---------|--------|
| Autenticacao | Self-contained (SIH proprio) | Implementado (v1.0) |
| SSO centralizado | HalalSphere → SIH | Futuro |
| Cadastros compartilhados | HalalSphere → SIH (plantas, empresas) | Futuro (`externalCompanyId`) |
| Dados de supervisao | SIH → SysHalal (relatorios, produtos, pesos) | Futuro |
| NCs criticas | SIH → HalalSphere (webhook) | Futuro |

Consulte [06-integration.md](./06-integration.md) para detalhes completos do ecossistema.

---

## 2.8 Resumo de Decisoes Arquiteturais

| Decisao | Escolha | Justificativa |
|---------|---------|---------------|
| Monolito vs. Microservicos | **Monolito modular** (NestJS) | Equipe pequena, complexidade baixa na v1.0, modulos podem ser extraidos futuramente |
| ORM | **Prisma 7** com PrismaPg adapter | Schema-first, migracao automatica, tipagem forte, deploy menor sem query engine binario |
| Frontend state | **React Query** (server state) + hooks (local state) | Cache automatico, revalidacao inteligente, sem Redux/Zustand |
| Autenticacao | **Self-contained** (bcrypt + JWT HS256) | Independencia total na v1.0, sem dependencia de sistemas externos |
| Formularios frontend | **React Hook Form + Zod** | Performance (uncontrolled inputs), validacao robusta, autosave |
| Estilizacao | **Tailwind CSS + shadcn/ui** | Utility-first, componentes acessiveis (Radix), customizaveis com tema FAMBRAS |
| Banco de dados | **PostgreSQL separado** (porta 5433) | Independencia total do HalalSphere, deploy separado |
| PWA | **Preparado** (manifest + SW basico) | Instalavel no tablet, offline completo na v2.0 |
| Deploy | **AWS ECS Fargate** | Containers sem gerenciar servidores, escalabilidade automatica |
| CDN | **CloudFront + S3** | Frontend estatico com cache global, baixa latencia |
