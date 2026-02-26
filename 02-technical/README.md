# Documentacao Tecnica

**SIH - Supervisao Industrial Halal**

---

## Controle do Documento

| Campo | Valor |
|-------|-------|
| **Versao** | 1.0 |
| **Data** | 24 de Fevereiro de 2026 |
| **Status** | Em Desenvolvimento |

---

## Indice da Documentacao Tecnica

| # | Documento | Descricao |
|---|-----------|-----------|
| 1 | [Stack Tecnologica](./01-stack.md) | Tecnologias utilizadas no backend (NestJS 11, Prisma 7, PostgreSQL 16) e frontend (React 19, Vite 7, Tailwind CSS 4). Tabela completa de dependencias com versoes. |
| 2 | [Arquitetura do Sistema](./02-system-architecture.md) | Diagrama de alto nivel, estrutura de modulos backend e frontend, padroes de comunicacao REST/JWT, mapeamento de portas e arquitetura de deploy. |
| 3 | [Banco de Dados](./03-database/) | Modelo entidade-relacionamento (ERD), dicionario de dados com todas as tabelas, campos e relacionamentos do schema Prisma. |
| 4 | [APIs](./04-apis.md) | Documentacao dos endpoints REST, padroes de request/response, paginacao, filtros e codigos de erro. |
| 5 | [Seguranca](./05-security.md) | Autenticacao self-contained (bcrypt + JWT HS256), autorizacao RBAC com 4 roles (admin, coordenador, supervisor, operador), protecoes contra ataques. |
| 6 | [Integracao](./06-integration.md) | Ecossistema FAMBRAS (HalalSphere + SIH + SysHalal), entidades compartilhaveis, modelo Collaborator, estrategia de integracao futura. |

---

## Stack Resumida

```
Frontend:  React 19 + Vite 7 + Tailwind CSS 4 + shadcn/ui
Backend:   NestJS 11 + Prisma 7 + PostgreSQL 16 + Redis 7
Auth:      JWT HS256 self-contained (bcrypt + Passport.js)
Infra:     Docker + AWS (ECS, S3, CloudFront)
```

---

## Como Navegar

- **Desenvolvedor novo no projeto**: Comece pelo [Stack Tecnologica](./01-stack.md) e depois [Arquitetura do Sistema](./02-system-architecture.md)
- **Precisa entender o banco**: Veja [Banco de Dados](./03-database/)
- **Vai implementar endpoints**: Consulte [APIs](./04-apis.md) e [Seguranca](./05-security.md)
- **Integracao com HalalSphere**: Veja [Integracao](./06-integration.md)

---

## Documentos Relacionados

- [PRD - Product Requirements Document](../01-prd/README.md) - Requisitos do produto
- [Requisitos Nao-Funcionais](../01-prd/07-non-functional.md) - Performance, escalabilidade, usabilidade
