---
layout: default
title: SIH - Supervisao Industrial Halal
---

# SIH - Supervisao Industrial Halal

**Sistema de digitalizacao dos formularios FM FAMBRAS Halal para supervisao industrial em campo**

![Version](https://img.shields.io/badge/version-1.0-green)
![Status](https://img.shields.io/badge/status-em_desenvolvimento-yellow)

---

## Sobre

O SIH digitaliza os formularios FM da FAMBRAS Halal utilizados por supervisores muculmanos em plantas industriais. O sistema e otimizado para uso em tablets em campo e opera com autenticacao propria (self-contained). Faz parte do ecossistema FAMBRAS junto com HalalSphere (certificacoes) e SysHalal (emissao de certificados).

---

## Documentacao

### PRD - Product Requirements Document

| Documento | Descricao |
|-----------|-----------|
| [Visao Geral](./01-prd/01-overview.md) | Problema, solucao e catalogo de formularios FM |
| [Objetivos e KPIs](./01-prd/02-objectives.md) | Metricas de sucesso do projeto |
| [Personas](./01-prd/03-personas.md) | Supervisor, operador, coordenador, admin |
| [Arquitetura de Features](./01-prd/04-architecture.md) | Epicos e priorizacao |
| [User Stories](./01-prd/05-user-stories/) | 7 epicos com user stories detalhadas |
| [Roadmap](./01-prd/06-roadmap.md) | Fases de desenvolvimento |
| [Requisitos Nao-Funcionais](./01-prd/07-non-functional.md) | Performance, seguranca, usabilidade |

### Documentacao Tecnica

| Documento | Descricao |
|-----------|-----------|
| [Stack Tecnologica](./02-technical/01-stack.md) | NestJS 11 + React 19 + PostgreSQL 16 |
| [Arquitetura do Sistema](./02-technical/02-system-architecture.md) | Componentes e integracao |
| [Banco de Dados](./02-technical/03-database/) | ERD e dicionario de dados |
| [APIs](./02-technical/04-apis.md) | Endpoints REST |
| [Seguranca](./02-technical/05-security.md) | JWT, RBAC, estrategia offline |
| [Integracao](./02-technical/06-integration.md) | Gestao de Certificacoes |

### Guias e Planejamento

| Documento | Descricao |
|-----------|-----------|
| [Setup Ambiente Local](./GUIDES/SETUP-AMBIENTE-LOCAL.md) | Configuracao do ambiente de desenvolvimento |
| [Roadmap Detalhado](./PLANNING/ROADMAP.md) | Cronograma de implementacao |
