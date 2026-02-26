# 4. APIs REST

---

## 4.1 Visao Geral

O SIH expoe uma API REST construida com **NestJS 11** e documentada via **Swagger/OpenAPI**.

| Item | Valor |
|------|-------|
| Base URL | `http://localhost:3334` |
| Documentacao Swagger | `http://localhost:3334/api/docs` |
| Formato | JSON |
| Autenticacao | Bearer JWT (header `Authorization`) |
| Versionamento | Sem versionamento na URL (v1 implicito) |

---

## 4.2 Endpoints de Infraestrutura

Os endpoints abaixo fazem parte da infraestrutura base do backend.

### GET /

**Descricao**: Informacoes basicas da API.
**Autenticacao**: Publica (`@Public()`)

```json
{
  "name": "SIH API",
  "version": "1.0.0",
  "description": "Supervisao Industrial Halal"
}
```

### GET /health

**Descricao**: Health check do servico.
**Autenticacao**: Publica (`@Public()`)

```json
{
  "status": "ok",
  "timestamp": "2026-01-15T10:30:00.000Z"
}
```

---

### POST /auth/login

**Descricao**: Autenticacao de usuario (self-contained).
**Autenticacao**: Publica (`@Public()`)

**Request**:
```json
{
  "email": "ahmad@supervisao.com",
  "password": "SihDev@2026"
}
```

**Response**:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "id": "uuid",
    "name": "Ahmad Hassan",
    "email": "ahmad@supervisao.com",
    "role": "supervisor"
  }
}
```

---

## 4.3 Endpoints de Dominio

Todos os endpoints abaixo estao implementados e requerem autenticacao JWT.

---

### 4.3.1 /supervisor-profiles

Gerenciamento de perfis de supervisores. O perfil e criado automaticamente no primeiro acesso JWT.

| Metodo | Rota | Descricao | Roles |
|--------|------|-----------|-------|
| GET | `/supervisor-profiles` | Lista todos os perfis | admin, coordenador |
| GET | `/supervisor-profiles/:id` | Busca perfil por ID | admin, coordenador, supervisor (proprio) |
| POST | `/supervisor-profiles` | Cria perfil manualmente | admin |
| PATCH | `/supervisor-profiles/:id` | Atualiza perfil | admin, coordenador, supervisor (proprio) |
| DELETE | `/supervisor-profiles/:id` | Desativa perfil (soft delete) | admin |
| GET | `/supervisor-profiles/me` | Perfil do usuario autenticado | todos |

---

### 4.3.2 /plants

Gerenciamento de plantas industriais (abatedouros, frigorificos, etc.).

| Metodo | Rota | Descricao | Roles |
|--------|------|-----------|-------|
| GET | `/plants` | Lista todas as plantas | todos |
| GET | `/plants/:id` | Busca planta por ID | todos |
| POST | `/plants` | Cria nova planta | admin, coordenador |
| PATCH | `/plants/:id` | Atualiza planta | admin, coordenador |
| DELETE | `/plants/:id` | Desativa planta (soft delete) | admin |

---

### 4.3.3 /slaughter-reports

Relatorios de abate Halal (FM 7.1.4.x). Suporta aves e bovinos com secao adicional de stunning para bovinos.

| Metodo | Rota | Descricao | Roles |
|--------|------|-----------|-------|
| GET | `/slaughter-reports` | Lista relatorios com filtros | todos |
| GET | `/slaughter-reports/:id` | Busca relatorio por ID | todos |
| POST | `/slaughter-reports` | Cria novo relatorio (gera serial) | supervisor, operador |
| PATCH | `/slaughter-reports/:id` | Atualiza relatorio (rascunho) | supervisor (autor), operador (autor) |
| PATCH | `/slaughter-reports/:id/sign` | Assina relatorio (gera hash SHA-256) | supervisor (autor) |
| PATCH | `/slaughter-reports/:id/cancel` | Cancela relatorio (com motivo) | coordenador, admin |
| GET | `/slaughter-reports/:id/pdf` | Gera PDF fiel ao FM FAMBRAS | todos (relatorio assinado) |
| GET | `/slaughter-reports/serial/next` | Retorna proximo numero serial | supervisor, operador |

**Filtros de listagem**:
- `?plantId=uuid` - Filtrar por planta
- `?supervisorId=uuid` - Filtrar por supervisor
- `?status=enviado` - Filtrar por status
- `?species=ave` - Filtrar por especie
- `?dateFrom=2026-01-01&dateTo=2026-01-31` - Filtrar por periodo
- `?page=1&limit=20` - Paginacao

**Numero serial**: Formato `SIF/ANO/SEQ` (ex: `001/2026/00001`). Gerado automaticamente pelo backend.

---

### 4.3.4 /production-reports

Relatorios de producao de industrializados (FM 7.1.3.x / FM 7.1.8.x).

| Metodo | Rota | Descricao | Roles |
|--------|------|-----------|-------|
| GET | `/production-reports` | Lista relatorios com filtros | todos |
| GET | `/production-reports/:id` | Busca relatorio por ID | todos |
| POST | `/production-reports` | Cria novo relatorio (gera serial) | supervisor, operador |
| PATCH | `/production-reports/:id` | Atualiza relatorio (rascunho) | supervisor (autor), operador (autor) |
| PATCH | `/production-reports/:id/sign` | Assina relatorio (gera hash SHA-256) | supervisor (autor) |
| PATCH | `/production-reports/:id/cancel` | Cancela relatorio (com motivo) | coordenador, admin |
| GET | `/production-reports/:id/pdf` | Gera PDF fiel ao FM FAMBRAS | todos (relatorio assinado) |
| GET | `/production-reports/serial/next` | Retorna proximo numero serial | supervisor, operador |

**Filtros de listagem**:
- `?plantId=uuid` - Filtrar por planta
- `?supervisorId=uuid` - Filtrar por supervisor
- `?status=rascunho` - Filtrar por status
- `?isSpecialProduction=true` - Filtrar producao especial (FM 7.1.8.x)
- `?dateFrom=2026-01-01&dateTo=2026-01-31` - Filtrar por periodo
- `?page=1&limit=20` - Paginacao

**Materias-primas**: O campo `meatRawMaterials` e um array JSON com: frigorifico, SIF, data de abate, CSN e certificado Halal.

---

### 4.3.5 /shipping-reports

Relatorios de embarque, venda interna e transferencia (FM 7.1.7.x / DCPOA).

| Metodo | Rota | Descricao | Roles |
|--------|------|-----------|-------|
| GET | `/shipping-reports` | Lista relatorios com filtros | todos |
| GET | `/shipping-reports/:id` | Busca relatorio por ID | todos |
| POST | `/shipping-reports` | Cria novo relatorio (gera serial) | supervisor, operador |
| PATCH | `/shipping-reports/:id` | Atualiza relatorio (rascunho) | supervisor (autor), operador (autor) |
| PATCH | `/shipping-reports/:id/sign` | Assina relatorio (gera hash SHA-256) | supervisor (autor) |
| PATCH | `/shipping-reports/:id/cancel` | Cancela relatorio (com motivo) | coordenador, admin |
| GET | `/shipping-reports/:id/pdf` | Gera PDF fiel ao FM FAMBRAS | todos (relatorio assinado) |
| GET | `/shipping-reports/serial/next` | Retorna proximo numero serial | supervisor, operador |

**Filtros de listagem**:
- `?plantId=uuid` - Filtrar por planta
- `?supervisorId=uuid` - Filtrar por supervisor
- `?status=aprovado` - Filtrar por status
- `?shippingType=exportacao` - Filtrar por tipo (exportacao, venda_interna, transferencia)
- `?dateFrom=2026-01-01&dateTo=2026-01-31` - Filtrar por periodo
- `?page=1&limit=20` - Paginacao

**Tipos de embarque**:
- `exportacao`: Campos completos (importador, container, portos, lacre, pais destino)
- `venda_interna`: Campos reduzidos (transporte, veiculo, destino nacional)
- `transferencia`: Campos minimos (unidade destino, DCPOA)

---

### 4.3.6 /non-conformities

Gestao de nao-conformidades (FM 7.1.6.1). Pode ser vinculada a qualquer tipo de relatorio.

| Metodo | Rota | Descricao | Roles |
|--------|------|-----------|-------|
| GET | `/non-conformities` | Lista NCs com filtros | todos |
| GET | `/non-conformities/:id` | Busca NC por ID | todos |
| POST | `/non-conformities` | Cria nova NC | supervisor, coordenador |
| PATCH | `/non-conformities/:id` | Atualiza NC | supervisor (autor), coordenador |
| DELETE | `/non-conformities/:id` | Remove NC (apenas se aberta) | admin |
| PATCH | `/non-conformities/:id/status` | Avanca workflow | coordenador, admin |
| GET | `/non-conformities/overdue` | Lista NCs com prazo vencido | coordenador, admin |

**Filtros de listagem**:
- `?plantId=uuid` - Filtrar por planta
- `?supervisorId=uuid` - Filtrar por supervisor
- `?status=aberta` - Filtrar por status
- `?severity=critica` - Filtrar por severidade
- `?category=higiene` - Filtrar por categoria
- `?overdue=true` - Filtrar apenas vencidas
- `?page=1&limit=20` - Paginacao

**Workflow de status**: `aberta` -> `em_tratamento` -> `resolvida` -> `verificada` -> `encerrada`

**Prazo**: 7 dias corridos a partir da criacao (conforme PR 7.1). Alertas automaticos ao se aproximar do vencimento.

---

### 4.3.7 /schedules

Escala de supervisores nas plantas industriais.

| Metodo | Rota | Descricao | Roles |
|--------|------|-----------|-------|
| GET | `/schedules` | Lista escalas com filtros | todos |
| GET | `/schedules/:id` | Busca escala por ID | todos |
| POST | `/schedules` | Cria alocacao de escala | coordenador, admin |
| PATCH | `/schedules/:id` | Atualiza alocacao | coordenador, admin |
| DELETE | `/schedules/:id` | Remove alocacao | coordenador, admin |
| GET | `/schedules/calendar` | Visao calendario mensal | todos |
| GET | `/schedules/by-supervisor/:id` | Escala por supervisor | todos |
| GET | `/schedules/by-plant/:id` | Escala por planta | todos |

**Filtros de listagem**:
- `?supervisorId=uuid` - Filtrar por supervisor
- `?plantId=uuid` - Filtrar por planta
- `?month=2026-01` - Filtrar por mes
- `?shift=matutino` - Filtrar por turno
- `?type=regular` - Filtrar por tipo de escala

**Restricao unica**: Um supervisor por planta/data/turno (`@@unique([supervisorId, plantId, date, shift])`).

---

### 4.3.8 /dashboard

Endpoints de agregacao para o dashboard operacional.

| Metodo | Rota | Descricao | Roles |
|--------|------|-----------|-------|
| GET | `/dashboard/summary` | Contadores gerais (dia/semana/mes) | todos |
| GET | `/dashboard/reports-by-status` | Relatorios agrupados por status | todos |
| GET | `/dashboard/ncs-by-severity` | NCs ativas por severidade | todos |
| GET | `/dashboard/ncs-by-plant` | NCs ativas por planta | coordenador, admin |
| GET | `/dashboard/pending-reviews` | Relatorios pendentes de revisao | coordenador, admin |
| GET | `/dashboard/supervisor-productivity` | Produtividade por supervisor | coordenador, admin |
| GET | `/dashboard/trends` | Graficos de tendencia (periodo) | todos |

**Filtros comuns**:
- `?period=day|week|month|custom` - Periodo de agregacao
- `?dateFrom=2026-01-01&dateTo=2026-01-31` - Periodo customizado
- `?plantId=uuid` - Filtrar por planta

---

## 4.4 Autenticacao

Todos os endpoints (exceto os marcados com `@Public()`) exigem um token JWT valido no header:

```
Authorization: Bearer <jwt-token>
```

Na v1.0, o token e emitido pelo **proprio backend SIH** via `POST /auth/login` (autenticacao self-contained com bcrypt + JWT HS256). NAO depende do HalalSphere.

Consulte o documento [05-security.md](./05-security.md) para detalhes completos do fluxo de autenticacao.

---

## 4.5 Validacao

O SIH utiliza `class-validator` com `ValidationPipe` global configurado em `main.ts`:

```typescript
app.useGlobalPipes(
  new ValidationPipe({
    whitelist: true,            // Remove campos nao declarados no DTO
    forbidNonWhitelisted: true, // Retorna erro se campo nao declarado for enviado
    transform: true,            // Converte tipos automaticamente
    transformOptions: {
      enableImplicitConversion: true,
    },
  }),
);
```

**Comportamento**:
- Campos nao declarados no DTO sao rejeitados com erro 400
- Tipos sao convertidos automaticamente (ex: `"1"` -> `1` para numeros)
- Mensagens de erro detalham qual campo falhou e qual validacao

---

## 4.6 Formato de Resposta de Erro

O `AllExceptionsFilter` padroniza todas as respostas de erro:

```json
{
  "statusCode": 400,
  "timestamp": "2026-01-15T10:30:00.000Z",
  "path": "/slaughter-reports",
  "message": "Bad Request",
  "error": ["species must be a valid enum value"]
}
```

**Codigos de status HTTP comuns**:

| Codigo | Significado | Quando |
|--------|------------|--------|
| 200 | OK | Requisicao bem-sucedida |
| 201 | Created | Recurso criado com sucesso |
| 400 | Bad Request | Validacao falhou (campos invalidos) |
| 401 | Unauthorized | Token JWT ausente ou invalido |
| 403 | Forbidden | Role do usuario nao tem permissao |
| 404 | Not Found | Recurso nao encontrado |
| 409 | Conflict | Violacao de constraint unica |
| 500 | Internal Server Error | Erro interno (stack trace omitido em producao) |

---

## 4.7 Padrao de Paginacao (Planejado)

Todos os endpoints de listagem seguirao o padrao:

**Request**:
```
GET /slaughter-reports?page=1&limit=20&sort=createdAt&order=desc
```

**Parametros de query**:

| Parametro | Tipo | Padrao | Descricao |
|-----------|------|--------|-----------|
| `page` | number | 1 | Numero da pagina (1-based) |
| `limit` | number | 20 | Itens por pagina (max: 100) |
| `sort` | string | `createdAt` | Campo de ordenacao |
| `order` | string | `desc` | Direcao: `asc` ou `desc` |

**Response**:
```json
{
  "data": [...],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "totalPages": 8,
    "hasNextPage": true,
    "hasPreviousPage": false
  }
}
```

---

## 4.8 Swagger

A documentacao interativa da API esta disponivel em `/api/docs` com as seguintes configuracoes:

- **Autorizacao persistente**: O token JWT e mantido entre recarregamentos da pagina
- **Filtro de busca**: Permite buscar endpoints por nome
- **Duracao de request**: Exibe o tempo de resposta de cada chamada
- **Servidor padrao**: `http://localhost:3334` (Local Development)

Para autenticar no Swagger, clique em "Authorize" e insira o token JWT no formato:
```
<seu-token-jwt>
```

---

## 4.9 Enums da API

Os seguintes enums sao utilizados nos endpoints:

| Enum | Valores | Nota |
|------|---------|------|
| UserRole | `admin`, `coordenador`, `supervisor`, `operador` | `gestor` existe no enum mas NAO e usado na v1.0 |
| Species | `bovino`, `ave` | Demais especies suprimidas na v1.0 (sem FM implementado) |
| Shift | `matutino`, `vespertino`, `noturno`, `integral` | |
| PlantType | `abatedouro`, `frigorifico`, `laticinio`, `processamento`, `armazenamento`, `outro` | |
| ReportStatus | `rascunho`, `assinado`, `cancelado` | Workflow: rascunho → assinado (final). Sem etapa de aprovacao |
| ShippingType | `exportacao`, `venda_interna`, `transferencia` | |
| TransportType | `terrestre`, `aereo`, `maritimo` | |
| Severity | `critica`, `maior`, `menor`, `observacao` | |
| NCStatus | `aberta`, `em_tratamento`, `resolvida`, `verificada`, `encerrada` | |
| ScheduleType | `regular`, `substituicao`, `extra`, `folga` | |

---

## 4.10 Endpoints de Exportacao PDF

Cada tipo de relatorio possui um endpoint de geracao de PDF fiel ao modelo FAMBRAS:

| Endpoint | FM | Descricao |
|----------|----|-----------|
| `GET /slaughter-reports/:id/pdf` | FM 7.1.4.1 (aves) / FM 7.1.4.2 (bovino) | PDF de relatorio de abate |
| `GET /production-reports/:id/pdf` | FM 7.1.3.1 | PDF de relatorio de producao |
| `GET /shipping-reports/:id/pdf` | FM 7.1.7.1 / 7.1.7.3 / 7.1.7.4 | PDF de relatorio de embarque |

**Caracteristicas do PDF gerado**:
- Cabecalho com logo FAMBRAS Halal + numero FM + revisao + data + paginacao
- Textos bilingues (portugues/ingles) conforme formularios originais
- Tabelas formatadas conforme layout FM FAMBRAS
- Area de assinatura com declaracao bilingue do supervisor
- Hash SHA-256 da assinatura digital exibido no rodape
- Gerado via **PDFKit** no backend (servidor)
- Retorna `Content-Type: application/pdf`

---

## 4.11 Endpoints Planejados — Collaborator (Futuro)

Cadastro de colaboradores operacionais (degoladores, sheiks, auxiliares) que atuam nas plantas mas nao sao usuarios do sistema.

| Metodo | Rota | Descricao | Roles |
|--------|------|-----------|-------|
| GET | `/collaborators` | Lista colaboradores com filtros | todos |
| GET | `/collaborators/:id` | Busca colaborador por ID | todos |
| POST | `/collaborators` | Cria novo colaborador | admin, coordenador |
| PATCH | `/collaborators/:id` | Atualiza colaborador | admin, coordenador |
| PATCH | `/collaborators/:id/deactivate` | Desativa colaborador | admin, coordenador |
| POST | `/collaborators/:id/photo` | Upload de foto (multipart/form-data) | admin, coordenador |

**Filtros de listagem**:
- `?plantId=uuid` - Filtrar por planta vinculada
- `?role=degolador` - Filtrar por funcao (degolador, sheik, auxiliar, supervisor_planta, veterinario)
- `?isActive=true` - Filtrar ativos/inativos
- `?search=nome` - Busca por nome
