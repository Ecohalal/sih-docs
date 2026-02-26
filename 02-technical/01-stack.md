# 1. Stack Tecnologica

**SIH - Supervisao Industrial Halal**

---

## 1.1 Visao Geral

O SIH utiliza uma stack moderna baseada em TypeScript end-to-end, com NestJS no backend e React no frontend. O sistema e containerizado com Docker para desenvolvimento local e implantado na AWS para producao.

```
┌─────────────────────────────────────────────────────────────┐
│                        FRONTEND                             │
│  React 19 + Vite 7 + Tailwind CSS 4 + shadcn/ui            │
├─────────────────────────────────────────────────────────────┤
│                        BACKEND                              │
│  NestJS 11 + Prisma 7 + Passport.js + Swagger              │
├──────────────────────────┬──────────────────────────────────┤
│      PostgreSQL 16       │           Redis 7                │
│   (dados persistentes)   │    (cache + rate limiting)       │
└──────────────────────────┴──────────────────────────────────┘
```

---

## 1.2 Backend

### Framework e Runtime

| Tecnologia | Versao | Proposito |
|------------|--------|-----------|
| **NestJS** | 11.x | Framework principal do backend (modular, com DI) |
| **Node.js** | 22+ | Runtime JavaScript server-side |
| **TypeScript** | 5.7.x | Tipagem estatica em todo o backend |
| **Express** | via @nestjs/platform-express | HTTP server subjacente ao NestJS |

### ORM e Banco de Dados

| Tecnologia | Versao | Proposito |
|------------|--------|-----------|
| **Prisma** | 7.x | ORM principal (schema-first, migracao, seed) |
| **@prisma/client** | 7.2.x | Cliente gerado para queries tipadas |
| **@prisma/adapter-pg** | 7.2.x | Adaptador PrismaPg para conexao nativa com PostgreSQL |
| **pg** | 8.17.x | Driver PostgreSQL nativo (usado pelo adapter) |
| **PostgreSQL** | 16+ | Banco de dados relacional principal |
| **Redis** | 7+ | Cache de sessao e rate limiting |
| **ioredis** | 5.9.x | Cliente Redis para Node.js |

#### Prisma 7 - Configuracao Especifica

O SIH utiliza Prisma 7 com as seguintes particularidades:

- **Provider**: `prisma-client-js` (gerador padrao)
- **Adapter PrismaPg**: Usa `@prisma/adapter-pg` para conexao direta via driver `pg`, sem o query engine binario do Prisma. Isso resulta em deploys menores e melhor compatibilidade com containers.
- **Arquivo de configuracao**: `prisma.config.ts` (TypeScript nativo, substituindo configuracoes do `schema.prisma`)
- **Seed**: Executado via `tsx prisma/seed.ts` (configurado no `package.json` na chave `prisma.seed`)
- **Extensoes do PostgreSQL**: `uuid-ossp`, `pgcrypto`, `pg_trgm` (inicializadas via script Docker)

### Autenticacao e Seguranca

| Tecnologia | Versao | Proposito |
|------------|--------|-----------|
| **@nestjs/jwt** | 11.x | Modulo JWT para NestJS |
| **@nestjs/passport** | 11.x | Integracao Passport.js com NestJS |
| **passport** | 0.7.x | Middleware de autenticacao |
| **passport-jwt** | 4.0.x | Estrategia JWT para Passport |
| **bcrypt** | 6.x | Hash de senhas |
| **cookie-parser** | 1.4.x | Parse de cookies nas requisicoes |

#### Estrategia JWT (v1.0)

Na v1.0, o SIH usa autenticacao self-contained (nao depende do HalalSphere):

| Algoritmo | Variavel | Observacao |
|-----------|----------|------------|
| **HS256** (simetrico) | `JWT_SECRET` | Backend SIH emite e valida tokens via `POST /auth/login` |

### Validacao e Documentacao

| Tecnologia | Versao | Proposito |
|------------|--------|-----------|
| **class-validator** | 0.14.x | Decorators de validacao em DTOs |
| **class-transformer** | 0.5.x | Transformacao de objetos (serialization) |
| **zod** | 4.3.x | Validacao de schemas (complementar) |
| **zod-validation-error** | 5.x | Formatacao de erros Zod |
| **@nestjs/swagger** | 11.2.x | Documentacao OpenAPI/Swagger automatica |

### Infraestrutura e Observabilidade

| Tecnologia | Versao | Proposito |
|------------|--------|-----------|
| **@nestjs/terminus** | 11.x | Health checks (banco, Redis, app) |
| **@nestjs/config** | 4.x | Gerenciamento de configuracao por ambiente |
| **@aws-sdk/client-secrets-manager** | 3.x | Acesso ao AWS Secrets Manager |
| **@aws-sdk/client-ssm** | 3.x | Acesso ao AWS Systems Manager Parameter Store |
| **dotenv** | 17.x | Variaveis de ambiente em desenvolvimento |
| **reflect-metadata** | 0.2.x | Suporte a decorators TypeScript |
| **rxjs** | 7.8.x | Programacao reativa (core do NestJS) |

---

## 1.3 Frontend

### Framework e Build

| Tecnologia | Versao | Proposito |
|------------|--------|-----------|
| **React** | 19.2.x | Biblioteca de UI principal |
| **React DOM** | 19.2.x | Renderizacao DOM |
| **Vite** | 7.2.x | Build tool e dev server |
| **@vitejs/plugin-react** | 5.1.x | Plugin Vite para React (Fast Refresh) |
| **TypeScript** | ~5.9.x | Tipagem estatica em todo o frontend |

### Estilizacao e Componentes

| Tecnologia | Versao | Proposito |
|------------|--------|-----------|
| **Tailwind CSS** | 3.4.x (v4 config) | Framework CSS utility-first |
| **shadcn/ui** | - | Componentes UI baseados em Radix (copiados para o projeto) |
| **@radix-ui/react-dialog** | 1.1.x | Componente Dialog acessivel |
| **@radix-ui/react-alert-dialog** | 1.1.x | Componente Alert Dialog acessivel |
| **@radix-ui/react-dropdown-menu** | 2.1.x | Componente Dropdown Menu acessivel |
| **@radix-ui/react-tabs** | 1.1.x | Componente Tabs acessivel |
| **class-variance-authority** | 0.7.x | Variantes de estilos para componentes |
| **clsx** | 2.1.x | Concatenacao condicional de classes CSS |
| **tailwind-merge** | 2.6.x | Merge inteligente de classes Tailwind |
| **lucide-react** | 0.468.x | Biblioteca de icones (Lucide) |

### Roteamento e Estado

| Tecnologia | Versao | Proposito |
|------------|--------|-----------|
| **react-router-dom** | 7.2.x | Roteamento SPA |
| **@tanstack/react-query** | 5.62.x | Gerenciamento de estado do servidor (cache, fetch, sync) |
| **axios** | 1.7.x | Cliente HTTP para chamadas a API |

### Formularios e Validacao

| Tecnologia | Versao | Proposito |
|------------|--------|-----------|
| **react-hook-form** | 7.54.x | Gerenciamento de formularios performatico |
| **@hookform/resolvers** | 3.10.x | Integracao de schemas de validacao (Zod) |
| **zod** | 3.23.x | Validacao de schemas no frontend |

### UX e Feedback

| Tecnologia | Versao | Proposito |
|------------|--------|-----------|
| **react-hot-toast** | 2.6.x | Notificacoes toast |

### PWA

| Tecnologia | Versao | Proposito |
|------------|--------|-----------|
| **vite-plugin-pwa** | 0.21.x | Geracao de manifest.json e Service Worker via Vite |

---

## 1.4 Ferramentas de Desenvolvimento

### Backend DevDependencies

| Tecnologia | Versao | Proposito |
|------------|--------|-----------|
| **@nestjs/cli** | 11.x | CLI do NestJS (build, generate, etc.) |
| **@nestjs/schematics** | 11.x | Templates de codigo NestJS |
| **@nestjs/testing** | 11.x | Utilitarios de teste NestJS |
| **Jest** | 30.x | Framework de testes unitarios |
| **ts-jest** | 29.x | Transformador TypeScript para Jest |
| **supertest** | 7.x | Testes de integracao HTTP |
| **ESLint** | 9.x | Linter de codigo |
| **eslint-config-prettier** | 10.x | Desativa regras ESLint que conflitam com Prettier |
| **eslint-plugin-prettier** | 5.x | Executa Prettier como regra ESLint |
| **typescript-eslint** | 8.x | Regras ESLint para TypeScript |
| **Prettier** | 3.4.x | Formatacao de codigo |
| **tsx** | 4.21.x | Executor de TypeScript (usado para seed do Prisma) |
| **ts-node** | 10.x | Executor TypeScript para Node.js |
| **ts-loader** | 9.x | Loader TypeScript para Webpack (build NestJS) |
| **tsconfig-paths** | 4.x | Resolve path aliases do tsconfig |
| **source-map-support** | 0.5.x | Source maps para debugging |

### Frontend DevDependencies

| Tecnologia | Versao | Proposito |
|------------|--------|-----------|
| **ESLint** | 9.x | Linter de codigo |
| **eslint-plugin-react-hooks** | 7.x | Regras de lint para React Hooks |
| **eslint-plugin-react-refresh** | 0.4.x | Regras para React Fast Refresh |
| **typescript-eslint** | 8.x | Regras ESLint para TypeScript |
| **PostCSS** | 8.5.x | Processador CSS (pipeline Tailwind) |
| **Autoprefixer** | 10.x | Adiciona vendor prefixes automaticamente |
| **Terser** | 5.x | Minificador JavaScript para build de producao |

---

## 1.5 Infraestrutura

### Containerizacao

| Tecnologia | Versao | Proposito |
|------------|--------|-----------|
| **Docker** | 24+ | Containerizacao de servicos |
| **Docker Compose** | 2.x | Orquestracao de containers locais |

### Containers Docker (Desenvolvimento)

| Container | Imagem | Porta Host | Porta Interna |
|-----------|--------|:----------:|:-------------:|
| `sih-postgres` | `postgres:16-alpine` | 5433 | 5432 |
| `sih-redis` | `redis:7-alpine` | 6380 | 6379 |
| `sih-backend` | Build local (profile: full) | 3334 | 3334 |

### AWS (Producao)

| Servico | Proposito |
|---------|-----------|
| **ECS (Fargate)** | Execucao de containers do backend |
| **RDS (PostgreSQL)** | Banco de dados gerenciado |
| **ElastiCache (Redis)** | Cache gerenciado |
| **S3** | Armazenamento de arquivos estaticos e evidencias |
| **CloudFront** | CDN para frontend e assets |
| **Secrets Manager** | Armazenamento seguro de credenciais |
| **SSM Parameter Store** | Configuracoes de ambiente |

---

## 1.6 Tabela Consolidada de Dependencias

### Backend - dependencies

| Pacote | Versao | Categoria |
|--------|--------|-----------|
| `@aws-sdk/client-secrets-manager` | ^3.969.0 | Infraestrutura AWS |
| `@aws-sdk/client-ssm` | ^3.969.0 | Infraestrutura AWS |
| `@nestjs/common` | ^11.0.1 | Framework Core |
| `@nestjs/config` | ^4.0.2 | Configuracao |
| `@nestjs/core` | ^11.0.1 | Framework Core |
| `@nestjs/jwt` | ^11.0.2 | Autenticacao |
| `@nestjs/passport` | ^11.0.5 | Autenticacao |
| `@nestjs/platform-express` | ^11.0.1 | HTTP Server |
| `@nestjs/swagger` | ^11.2.5 | Documentacao API |
| `@nestjs/terminus` | ^11.0.0 | Health Check |
| `@prisma/adapter-pg` | ^7.2.0 | ORM - Adapter |
| `@prisma/client` | ^7.2.0 | ORM - Client |
| `bcrypt` | ^6.0.0 | Seguranca |
| `class-transformer` | ^0.5.1 | Validacao |
| `class-validator` | ^0.14.3 | Validacao |
| `cookie-parser` | ^1.4.7 | HTTP |
| `dotenv` | ^17.3.1 | Configuracao |
| `ioredis` | ^5.9.1 | Cache (Redis) |
| `passport` | ^0.7.0 | Autenticacao |
| `passport-jwt` | ^4.0.1 | Autenticacao |
| `pg` | ^8.17.0 | Driver PostgreSQL |
| `prisma` | ^7.2.0 | ORM - CLI/Engine |
| `reflect-metadata` | ^0.2.2 | Runtime |
| `rxjs` | ^7.8.1 | Runtime |
| `zod` | ^4.3.5 | Validacao |
| `zod-validation-error` | ^5.0.0 | Validacao |

### Backend - devDependencies

| Pacote | Versao | Categoria |
|--------|--------|-----------|
| `@eslint/eslintrc` | ^3.2.0 | Linting |
| `@eslint/js` | ^9.18.0 | Linting |
| `@nestjs/cli` | ^11.0.0 | Tooling |
| `@nestjs/schematics` | ^11.0.0 | Tooling |
| `@nestjs/testing` | ^11.0.1 | Testes |
| `@types/bcrypt` | ^6.0.0 | Tipagem |
| `@types/cookie-parser` | ^1.4.10 | Tipagem |
| `@types/express` | ^5.0.0 | Tipagem |
| `@types/jest` | ^30.0.0 | Tipagem |
| `@types/node` | ^22.10.7 | Tipagem |
| `@types/passport-jwt` | ^4.0.1 | Tipagem |
| `@types/pg` | ^8.16.0 | Tipagem |
| `@types/supertest` | ^6.0.2 | Tipagem |
| `eslint` | ^9.18.0 | Linting |
| `eslint-config-prettier` | ^10.0.1 | Linting |
| `eslint-plugin-prettier` | ^5.2.2 | Linting |
| `globals` | ^16.0.0 | Linting |
| `jest` | ^30.0.0 | Testes |
| `prettier` | ^3.4.2 | Formatacao |
| `source-map-support` | ^0.5.21 | Debug |
| `supertest` | ^7.0.0 | Testes |
| `ts-jest` | ^29.2.5 | Testes |
| `ts-loader` | ^9.5.2 | Build |
| `ts-node` | ^10.9.2 | Runtime |
| `tsconfig-paths` | ^4.2.0 | Build |
| `tsx` | ^4.21.0 | Runtime (Seed) |
| `typescript` | ^5.7.3 | Linguagem |
| `typescript-eslint` | ^8.20.0 | Linting |

### Frontend - dependencies

| Pacote | Versao | Categoria |
|--------|--------|-----------|
| `@hookform/resolvers` | ^3.10.0 | Formularios |
| `@radix-ui/react-alert-dialog` | ^1.1.15 | Componentes UI |
| `@radix-ui/react-dialog` | ^1.1.15 | Componentes UI |
| `@radix-ui/react-dropdown-menu` | ^2.1.16 | Componentes UI |
| `@radix-ui/react-tabs` | ^1.1.13 | Componentes UI |
| `@tanstack/react-query` | ^5.62.0 | Estado/Cache |
| `axios` | ^1.7.0 | HTTP Client |
| `class-variance-authority` | ^0.7.1 | Estilizacao |
| `clsx` | ^2.1.1 | Estilizacao |
| `lucide-react` | ^0.468.0 | Icones |
| `react` | ^19.2.0 | Framework UI |
| `react-dom` | ^19.2.0 | Framework UI |
| `react-hook-form` | ^7.54.1 | Formularios |
| `react-hot-toast` | ^2.6.0 | UX/Feedback |
| `react-router-dom` | ^7.2.0 | Roteamento |
| `tailwind-merge` | ^2.6.0 | Estilizacao |
| `zod` | ^3.23.8 | Validacao |

### Frontend - devDependencies

| Pacote | Versao | Categoria |
|--------|--------|-----------|
| `@eslint/js` | ^9.39.1 | Linting |
| `@types/node` | ^24.10.0 | Tipagem |
| `@types/react` | ^19.2.2 | Tipagem |
| `@types/react-dom` | ^19.2.2 | Tipagem |
| `@vitejs/plugin-react` | ^5.1.0 | Build |
| `autoprefixer` | ^10.4.20 | CSS |
| `eslint` | ^9.39.1 | Linting |
| `eslint-plugin-react-hooks` | ^7.0.1 | Linting |
| `eslint-plugin-react-refresh` | ^0.4.24 | Linting |
| `globals` | ^16.5.0 | Linting |
| `postcss` | ^8.5.1 | CSS |
| `tailwindcss` | ^3.4.17 | CSS |
| `terser` | ^5.46.0 | Build |
| `typescript` | ~5.9.3 | Linguagem |
| `typescript-eslint` | ^8.46.3 | Linting |
| `vite` | ^7.2.2 | Build |
| `vite-plugin-pwa` | ^0.21.1 | PWA |

---

## 1.7 Observacoes sobre Versoes

### TypeScript

- **Backend**: TypeScript 5.7.x (versao estavel para NestJS 11)
- **Frontend**: TypeScript ~5.9.x (versao mais recente, compativel com Vite 7)
- Ambos os projetos usam `strict: true` no `tsconfig.json`

### Zod

- **Backend**: Zod 4.x (versao mais recente, com breaking changes do v3)
- **Frontend**: Zod 3.x (versao estavel, compativel com `@hookform/resolvers`)
- A diferenca de versoes e intencional: o frontend depende de resolvers que ainda nao suportam Zod 4

### ESLint

- Ambos os projetos usam ESLint 9.x com flat config (novo formato de configuracao)
- O backend usa `eslint-plugin-prettier` para integracao com Prettier
- O frontend usa plugins especificos para React Hooks e React Refresh
