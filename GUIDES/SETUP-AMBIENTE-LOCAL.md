# Guia de Setup do Ambiente Local

> **Projeto:** SIH - Supervisao Industrial Halal
>
> **Stack Backend:** NestJS 11 + Prisma 7 + PostgreSQL 16 + Redis 7
>
> **Stack Frontend:** React 19 + Vite 7 + TailwindCSS + React Query

---

## Sumario

1. [Pre-requisitos](#1-pre-requisitos)
2. [Clonar Repositorios](#2-clonar-repositorios)
3. [Backend Setup](#3-backend-setup)
4. [Frontend Setup](#4-frontend-setup)
5. [Portas do Sistema](#5-portas-do-sistema)
6. [Comandos Uteis](#6-comandos-uteis)
7. [Troubleshooting](#7-troubleshooting)

---

## 1. Pre-requisitos

Antes de comecar, certifique-se de ter instalado:

| Ferramenta       | Versao Minima | Como verificar          | Link                                              |
| ---------------- | ------------- | ----------------------- | ------------------------------------------------- |
| **Node.js**      | 22.x+         | `node -v`               | https://nodejs.org/                                |
| **npm**          | 10.x+         | `npm -v`                | (incluso com Node.js)                              |
| **Docker Desktop** | Mais recente | `docker -v`            | https://www.docker.com/products/docker-desktop/    |
| **Git**          | 2.40+         | `git --version`         | https://git-scm.com/                               |
| **VSCode**       | Mais recente  | -                       | https://code.visualstudio.com/ (recomendado)       |

### Extensoes recomendadas para VSCode

- **Prisma** - Syntax highlighting e formatacao do schema
- **ESLint** - Linting integrado
- **Prettier** - Formatacao de codigo
- **Thunder Client** ou **REST Client** - Testes de API
- **Tailwind CSS IntelliSense** - Autocomplete para classes Tailwind

---

## 2. Clonar Repositorios

O projeto SIH e composto por 3 repositorios. Recomenda-se clonar todos na mesma pasta raiz:

```bash
# Criar pasta raiz (opcional, ajuste conforme preferencia)
mkdir ~/Projetos && cd ~/Projetos

# 1. Documentacao
git clone <url-do-repo>/sih-docs.git

# 2. Backend (NestJS API)
git clone <url-do-repo>/sih-backend.git

# 3. Frontend (React SPA)
git clone <url-do-repo>/sih-frontend.git
```

Estrutura esperada:

```
Projetos/
  sih-docs/         # Documentacao, PRD, guias
  sih-backend/      # API NestJS + Prisma
  sih-frontend/     # SPA React + Vite
```

---

## 3. Backend Setup

### 3.1 Configurar variaveis de ambiente

```bash
cd sih-backend

# Copiar o arquivo de exemplo
cp .env.example .env
```

O arquivo `.env` ja vem configurado com valores padrao para desenvolvimento local. As principais variaveis sao:

```env
PORT=3334
NODE_ENV=development
DATABASE_URL=postgresql://admin:secret123@localhost:5433/sih
REDIS_URL=redis://localhost:6380
JWT_SECRET=dev-secret-key-minimum-32-characters-for-hs256-local-development
JWT_EXPIRES_IN=7d
FRONTEND_URL=http://localhost:5174
CORS_ORIGIN=http://localhost:5174
GESTAO_API_URL=http://localhost:3333
```

> **Nota:** Na v1.0, o SIH usa autenticacao self-contained com JWT HS256. O `JWT_SECRET` deve ter no minimo 32 caracteres.

### 3.2 Subir infraestrutura com Docker

Certifique-se de que o **Docker Desktop esta rodando**, depois execute:

```bash
# Sobe PostgreSQL (porta 5433) e Redis (porta 6380)
docker compose up -d
```

Aguarde os containers ficarem saudaveis:

```bash
# Verificar status dos containers
docker compose ps
```

Saida esperada:

```
NAME            STATUS                  PORTS
sih-postgres    Up (healthy)            0.0.0.0:5433->5432/tcp
sih-redis       Up (healthy)            0.0.0.0:6380->6379/tcp
```

> **Detalhes da infraestrutura:**
> - **PostgreSQL 16 Alpine** - Banco de dados principal com extensoes `uuid-ossp`, `pgcrypto` e `pg_trgm`
> - **Redis 7 Alpine** - Cache e filas (futuro)

### 3.3 Instalar dependencias

```bash
npm install
```

### 3.4 Gerar o Prisma Client

```bash
npx prisma generate
```

> **IMPORTANTE - Prisma 7:** A partir do Prisma 7, o comando `prisma generate` utiliza o arquivo `prisma.config.ts` que carrega a `DATABASE_URL` via `dotenv/config`. Por isso, e obrigatorio que o arquivo `.env` exista na raiz do projeto **antes** de rodar este comando. Caso contrario, voce recebera um erro de conexao.
>
> O arquivo `prisma.config.ts` do projeto:
> ```typescript
> import 'dotenv/config';
> import { defineConfig, env } from 'prisma/config';
>
> export default defineConfig({
>   schema: 'prisma/schema.prisma',
>   migrations: {
>     path: 'prisma/migrations',
>     seed: 'tsx prisma/seed.ts',
>   },
>   datasource: {
>     url: env('DATABASE_URL'),
>   },
> });
> ```

### 3.5 Executar migrations

```bash
npx prisma migrate dev --name init
```

Este comando:
1. Cria as tabelas no banco de dados conforme o `schema.prisma`
2. Gera o historico de migrations em `prisma/migrations/`
3. Regenera o Prisma Client automaticamente

As tabelas criadas serao:
- `supervisor_profiles` - Perfis de supervisores
- `plants` - Plantas industriais (abatedouros, frigorificos, etc.)
- `slaughter_reports` - Relatorios de abate (FM 7.1.4.x)
- `production_reports` - Relatorios de producao (FM 7.1.3.x / FM 7.1.8.x)
- `shipping_reports` - Relatorios de embarque/venda (FM 7.1.7.x / DCPOA)
- `non_conformities` - Nao-conformidades (FM 7.1.6.1)
- `supervisor_schedules` - Escala de supervisores

### 3.6 Popular o banco com dados de teste (seed)

```bash
npx prisma db seed
```

> **Nota:** O seed do SIH utiliza **tsx** (nao ts-node). Isso esta configurado no `package.json`:
> ```json
> "prisma": {
>   "seed": "tsx prisma/seed.ts"
> }
> ```
> Certifique-se de que o `tsx` esta instalado (ele ja e uma devDependency do projeto).

### 3.7 Iniciar o servidor de desenvolvimento

```bash
npm run start:dev
```

O servidor NestJS ira iniciar em modo watch (reinicia automaticamente a cada alteracao de codigo).

Saida esperada:

```
[Nest] LOG [NestApplication] Nest application successfully started
[Nest] LOG Application is running on: http://localhost:3334
```

### 3.8 Verificar se tudo esta funcionando

**Health Check:**

```bash
curl http://localhost:3334/health
```

Ou acesse no navegador: [http://localhost:3334/health](http://localhost:3334/health)

**Swagger (documentacao da API):**

Acesse: [http://localhost:3334/api/docs](http://localhost:3334/api/docs)

A documentacao Swagger lista todos os endpoints disponiveis, schemas de request/response, e permite testar a API diretamente pelo navegador.

---

## 4. Frontend Setup

### 4.1 Configurar variaveis de ambiente

```bash
cd sih-frontend

# Copiar o arquivo de exemplo
cp .env.example .env.local
```

> **Nota:** O frontend usa `.env.local` (padrao Vite) para configuracao local. Todas as variaveis devem ter o prefixo `VITE_` para serem acessiveis no codigo.

Conteudo do `.env.local`:

```env
VITE_API_URL=http://localhost:3334
VITE_AUTH_API_URL=http://localhost:3333
VITE_ENV=development
```

| Variavel             | Descricao                                       |
| -------------------- | ----------------------------------------------- |
| `VITE_API_URL`       | URL da API do SIH Backend                       |
| `VITE_AUTH_API_URL`  | URL da API de Gestao de Certificacoes (autenticacao) |
| `VITE_ENV`           | Ambiente de execucao                             |

### 4.2 Instalar dependencias

```bash
npm install
```

### 4.3 Iniciar o servidor de desenvolvimento

```bash
npm run dev
```

O Vite ira iniciar o servidor de desenvolvimento com HMR (Hot Module Replacement).

Acesse: [http://localhost:5174](http://localhost:5174)

> **Nota:** O frontend depende do backend estar rodando para funcionar corretamente. Certifique-se de que o backend esta acessivel em `http://localhost:3334` antes de testar funcionalidades que dependem da API.

---

## 5. Portas do Sistema

### Mapa de portas do SIH

| Servico          | Porta  | Container/Processo   | URL de Acesso                   |
| ---------------- | ------ | -------------------- | ------------------------------- |
| **Backend API**  | `3334` | NestJS (local)       | http://localhost:3334           |
| **PostgreSQL**   | `5433` | sih-postgres         | `localhost:5433`                |
| **Redis**        | `6380` | sih-redis            | `localhost:6380`                |
| **Frontend**     | `5174` | Vite dev server      | http://localhost:5174           |
| **Swagger Docs** | `3334` | NestJS (rota)        | http://localhost:3334/api/docs  |
| **Prisma Studio** | `5555` | Prisma (sob demanda) | http://localhost:5555           |

### Separacao do HalalSphere (Gestao de Certificacoes)

As portas do SIH foram **intencionalmente separadas** para permitir que ambos os sistemas rodem simultaneamente na mesma maquina de desenvolvimento:

| Servico      | HalalSphere   | SIH           |
| ------------ | ------------- | ------------- |
| Backend API  | `3333`        | `3334`        |
| PostgreSQL   | `5432`        | `5433`        |
| Redis        | `6379`        | `6380`        |
| Frontend     | `5173`        | `5174`        |

> **Dica:** Voce pode rodar ambos os projetos ao mesmo tempo sem conflitos de porta. Isso e util para testar a integracao de autenticacao entre o SIH e o Gestao de Certificacoes.

---

## 6. Comandos Uteis

### Prisma (Banco de Dados)

```bash
# Abrir Prisma Studio (interface visual para o banco)
npx prisma studio

# Criar nova migration apos alterar o schema.prisma
npx prisma migrate dev --name descricao_da_alteracao

# Resetar banco e re-executar todas as migrations
npx prisma migrate reset

# Popular o banco com dados de teste
npx prisma db seed

# Gerar/regenerar o Prisma Client
npx prisma generate

# Ver status das migrations
npx prisma migrate status

# Formatar o schema.prisma
npx prisma format
```

### NestJS (Backend)

```bash
# Desenvolvimento com hot-reload
npm run start:dev

# Desenvolvimento com debug
npm run start:debug

# Build para producao
npm run build

# Iniciar em modo producao
npm run start:prod

# Linting (com auto-fix)
npm run lint

# Formatacao de codigo
npm run format

# Rodar testes unitarios
npm run test

# Rodar testes em modo watch
npm run test:watch

# Rodar testes com cobertura
npm run test:cov

# Rodar testes end-to-end
npm run test:e2e
```

### Frontend (React/Vite)

```bash
# Desenvolvimento com HMR
npm run dev

# Build para producao
npm run build

# Build para staging
npm run build:staging

# Preview do build de producao
npm run preview

# Linting
npm run lint
```

### Docker

```bash
# Subir infraestrutura (PostgreSQL + Redis)
docker compose up -d

# Parar infraestrutura
docker compose down

# Parar e remover volumes (APAGA DADOS DO BANCO)
docker compose down -v

# Ver logs dos containers
docker compose logs

# Ver logs em tempo real
docker compose logs -f

# Ver logs de um servico especifico
docker compose logs postgres
docker compose logs redis

# Verificar status dos containers
docker compose ps

# Subir tudo (infra + backend containerizado)
docker compose --profile full up -d
```

---

## 7. Troubleshooting

### Conflito de portas

**Sintoma:** Erro `EADDRINUSE` ou `port already in use` ao subir containers ou iniciar o backend/frontend.

**Solucao:**

```bash
# Verificar o que esta usando a porta (exemplo: 5433)
# Windows (PowerShell)
netstat -ano | findstr :5433

# Linux/Mac
lsof -i :5433

# Se for um container antigo, pare-o
docker compose down

# Se for outro processo, encerre-o ou altere a porta no .env e docker-compose.yml
```

### Erro no `prisma generate` - DATABASE_URL nao encontrada

**Sintoma:**

```
Error: Environment variable not found: DATABASE_URL
```

**Causa:** O arquivo `.env` nao existe na raiz de `sih-backend/`, ou a variavel `DATABASE_URL` nao esta definida.

**Solucao:**

```bash
# Verificar se o .env existe
ls -la .env

# Se nao existir, copiar do exemplo
cp .env.example .env

# Verificar se a variavel esta no arquivo
grep DATABASE_URL .env
```

> **Lembrete:** No Prisma 7, o `prisma.config.ts` usa `import 'dotenv/config'` para carregar o `.env`. Diferente de versoes anteriores, o Prisma 7 nao le o `.env` automaticamente do `schema.prisma`.

### Docker nao esta rodando

**Sintoma:**

```
Cannot connect to the Docker daemon at unix:///var/run/docker.sock
```

Ou no Windows:

```
error during connect: ... docker daemon is not running
```

**Solucao:**

1. Abra o **Docker Desktop**
2. Aguarde ate o icone na bandeja ficar verde (status: "running")
3. Verifique com `docker info`
4. Tente novamente: `docker compose up -d`

### Erro de conexao com o banco de dados

**Sintoma:**

```
Can't reach database server at `localhost:5433`
```

**Solucao:**

```bash
# 1. Verificar se o container esta rodando
docker compose ps

# 2. Se nao estiver rodando, subir novamente
docker compose up -d

# 3. Verificar os logs do PostgreSQL
docker compose logs postgres

# 4. Testar conexao direta
docker exec -it sih-postgres psql -U admin -d sih -c "SELECT 1"
```

### Erro no seed - tsx nao encontrado

**Sintoma:**

```
Error: Cannot find module 'tsx'
```

**Solucao:**

```bash
# Reinstalar dependencias
npm install

# Verificar se tsx esta instalado
npx tsx --version

# Rodar seed novamente
npx prisma db seed
```

### Containers saudaveis mas API nao responde

**Sintoma:** Os containers `sih-postgres` e `sih-redis` estao `healthy`, mas o backend da erro ao conectar.

**Solucao:**

```bash
# Verificar se a DATABASE_URL aponta para localhost:5433 (nao 5432)
grep DATABASE_URL .env

# Valor correto:
# DATABASE_URL=postgresql://admin:secret123@localhost:5433/sih

# Verificar se a REDIS_URL aponta para localhost:6380 (nao 6379)
grep REDIS_URL .env

# Valor correto:
# REDIS_URL=redis://localhost:6380
```

> **Atencao:** As portas `5433` e `6380` sao as portas mapeadas no host. Dentro dos containers Docker, os servicos rodam nas portas padrao (`5432` e `6379`). Se voce estiver usando o profile `full` (backend containerizado), a `DATABASE_URL` deve apontar para `postgres:5432` (nome do servico Docker).

### Frontend nao conecta na API

**Sintoma:** Erros de CORS ou `Network Error` no console do navegador.

**Solucao:**

1. Verifique se o backend esta rodando em `http://localhost:3334`
2. Verifique o `VITE_API_URL` no `.env.local` do frontend
3. Verifique se `CORS_ORIGIN` no `.env` do backend inclui `http://localhost:5174`
4. Reinicie o backend se alterou variaveis de ambiente

---

## Resumo - Passo a Passo Rapido

Para quem quer subir tudo rapidamente:

```bash
# 1. Backend
cd sih-backend
cp .env.example .env
docker compose up -d
npm install
npx prisma generate
npx prisma migrate dev --name init
npx prisma db seed
npm run start:dev

# 2. Frontend (em outro terminal)
cd sih-frontend
cp .env.example .env.local
npm install
npm run dev
```

Acesse:
- **Frontend:** http://localhost:5174
- **Backend API:** http://localhost:3334
- **Swagger Docs:** http://localhost:3334/api/docs
- **Health Check:** http://localhost:3334/health
