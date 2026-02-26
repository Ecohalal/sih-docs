# 6. Integracao e Ecossistema FAMBRAS

---

## 6.1 Visao Geral do Ecossistema

O SIH faz parte de um ecossistema de 3 sistemas que cobrem toda a cadeia Halal da FAMBRAS:

```
┌─────────────────────────────┐    ┌─────────────────────────────┐    ┌─────────────────────────────┐
│  HalalSphere                │    │  SIH                        │    │  SysHalal                   │
│  Gestao de Certificacoes    │    │  Supervisao Industrial Halal│    │  Emissao de Certificados    │
│  (UPSTREAM)                 │    │  (OPERACIONAL)              │    │  (DOWNSTREAM)               │
│                             │    │                             │    │                             │
│  - Certifica empresas       │    │  - Relatorios de abate      │    │  - Emite certificados Halal │
│  - Gerencia auditorias      │    │  - Relatorios de producao   │    │    de exportacao            │
│  - Emite certificados       │    │  - Relatorios de embarque   │    │  - Gera PDFs certificados   │
│  - Gerencia propostas       │    │  - Nao-conformidades        │    │  - QR Code de validacao     │
│  - Workflow 17 fases        │    │  - Escalas de supervisores  │    │  - Gestao de operacoes      │
│  - AI/Chatbot               │    │  - Colaboradores            │    │  - Cartas de correcao       │
│                             │    │  - Geracao de PDF FAMBRAS   │    │                             │
│  NestJS 11 + React 19       │    │  NestJS 11 + React 19      │    │  NestJS 10 + Next.js 14     │
│  Prisma 7 + PostgreSQL 16   │    │  Prisma 7 + PostgreSQL 16  │    │  Prisma 6 + PostgreSQL 16   │
│  Porta: 3333                │    │  Porta: 3334               │    │  Porta: configuravel        │
└─────────────────────────────┘    └─────────────────────────────┘    └─────────────────────────────┘
```

### Fluxo de Dados entre Sistemas

```
HalalSphere (upstream)          SIH (operacional)           SysHalal (downstream)

  Empresa certificada ─────────> Planta (SIF) ─────────────> Empresa (SIF)
  Escopo de produtos             Relatorio de abate          Produtos (JSON)
  Auditoria realizada            Relatorio de producao       Pesos bruto/liquido
  Certificado emitido            Relatorio de embarque       Operacoes (abate/proc)
                                 Colaboradores               BL, Invoice, CSI
                                 NCs                         Porto orig/dest
```

---

## 6.2 Repositorios

| Sistema | Backend | Frontend |
|---------|---------|----------|
| **HalalSphere** | `C:\Projetos\halalsphere-backend` | `C:\Projetos\halalsphere-frontend` |
| **SIH** | `C:\Projetos\sih-backend` | `C:\Projetos\sih-frontend` |
| **SysHalal** | `C:\Projetos\syshalal-api` | `C:\Projetos\syshalal-web` |

---

## 6.3 Entidades Compartilhaveis — Mapeamento Cruzado

### 6.3.1 Plantas/Empresas

| Campo | HalalSphere (`Company`) | SysHalal (`tb_empresa`) | SIH (`Plant`) |
|-------|------------------------|------------------------|---------------|
| ID | UUID | Snowflake BigInt | UUID |
| Nome | `razaoSocial` | `razao_social` | `name` |
| Codigo SIF | `plantCode` + `plantCodeType` | campo `sif` | `sifCode` |
| CNPJ | `cnpj` (14 chars) | via `tb_cliente` | — (nao cadastra) |
| Tipo | `tipoEmpresa` | flags (`typeSlaughterer`, `typeProcessor`, etc.) | `type` (enum: frigorifico, processamento) |
| Grupo | `groupId` → `CompanyGroup` | `cliente_id` → `tb_cliente` | — |
| Endereco | `address` (JSON) | `endereco_id` → `tb_endereco` | `address` (JSON) |
| Especies | — | — | `species[]` (bovino, ave) |
| Vinculo externo | — | — | `externalCompanyId` (preparado para HalalSphere) |

### 6.3.2 Pessoas/Colaboradores

| Aspecto | HalalSphere | SysHalal | SIH |
|---------|-------------|----------|-----|
| Usuarios sistema | 12 roles (admin, empresa, analista, auditor, etc.) | RBAC dinamico | 4 roles (admin, coordenador, supervisor, operador) |
| Colaboradores nao-usuarios | — | `tb_pessoas` (contatos comerciais) | `Collaborator` (equipe operacional: degoladores, sheiks, auxiliares) |
| Auditores | `AuditorCompetency` (completo) | — | — |
| Vinculo com relatorio | — | `cx_certificado_operacao` | `ReportStaff` (N:N) |

### 6.3.3 Certificados

| Campo | HalalSphere (`Certificate`) | SysHalal (`tb_certificado`) | SIH |
|-------|----------------------------|----------------------------|-----|
| Num certificado | `certificateNumber` | `nr_certificado` | — (gera relatorios, nao certificados) |
| Produtos | `ScopeProduct` | `json_produtos` (JSON) | produtos por relatorio (JSON) |
| Pesos | — | `vl_peso_bruto/liquido` | nos relatorios de embarque |
| Operacoes | — | `cx_certificado_operacao` | relatorios de abate/producao |
| CSI/CSN | — | `ds_certificado_sanitario` | `csiNumber` no shipping report |

---

## 6.4 Autenticacao — v1.0 (Atual)

Na v1.0, o SIH opera com **autenticacao propria (self-contained)**:

```
Frontend SIH ──(POST /auth/login)──> Backend SIH ──(bcrypt + JWT HS256)──> Token
```

- **Nao depende** do HalalSphere para autenticar
- Backend gera JWT com HS256 usando `JWT_SECRET`
- Senha armazenada com bcrypt (salt rounds 10)
- JWT contem: `sub` (userId), `email`, `name`, `role`
- Token valido por 7 dias (`JWT_EXPIRES_IN`)
- Guards globais: `JwtAuthGuard` + `RolesGuard`
- Decorators: `@Public()` para pular auth, `@Roles('admin', 'coordenador')` para restringir

### Variaveis de Ambiente (v1.0)

| Variavel | Descricao | Exemplo |
|----------|-----------|---------|
| `JWT_SECRET` | Chave secreta HS256 | `dev-secret-key-minimum-32-chars...` |
| `JWT_EXPIRES_IN` | Validade do token | `7d` |

---

## 6.5 Estrategia de Integracao Futura

### 6.5.1 Fase 1 — Cadastros Compartilhados (HalalSphere como Master)

Quando a integracao for implementada, o HalalSphere sera o **master** dos cadastros de:
- **Plantas/Empresas**: `Company` do HalalSphere (com `plantCode` SIF) → vinculado via `Plant.externalCompanyId` no SIH
- **Colaboradores**: Futuro modulo no HalalSphere → vinculado via `Collaborator.externalId` no SIH

O SIH mantém copias locais com `externalId` para:
- Funcionar independente (sem dependencia de rede)
- Preservar dados historicos mesmo se o master mudar

### 6.5.2 Fase 2 — Dados de Supervisao para SysHalal

O SIH alimenta o SysHalal com dados operacionais para emissao de certificados de exportacao:
- Datas de abate, producao, validades
- Pesos bruto/liquido por produto
- Numeros SIF de origem
- CSI/CSN associados
- Operacoes (abatedouro, processadora)

### 6.5.3 Mecanismo de Sincronizacao

| Direcao | Mecanismo | Dados |
|---------|-----------|-------|
| HalalSphere → SIH | API REST (sob demanda) | Plantas, colaboradores, certificados |
| SIH → SysHalal | API REST ou webhook | Relatorios assinados, dados de produto |
| SIH → HalalSphere | Webhook (evento) | NCs criticas, resumos de supervisao |

---

## 6.6 Modelo Collaborator — Decisao Arquitetural

### 6.6.1 Problema

Os relatorios de abate/producao envolvem diversos profissionais alem do supervisor:
- Degoladores (realizam o abate Halal)
- Sheiks (autoridade religiosa)
- Auxiliares de supervisao
- Veterinarios da planta
- Supervisores da planta

Atualmente o SIH registra apenas `slaughtererName` e `slaughtererDoc` como texto livre no relatorio de abate. Nao ha cadastro centralizado nem vinculo estruturado.

### 6.6.2 Solucao

Criar as entidades `Collaborator` e `ReportStaff` no SIH:

```prisma
model Collaborator {
  id            String   @id @default(uuid())
  externalId    String?  @unique          // Vinculo futuro com HalalSphere
  name          String
  document      String                    // RG, CPF ou passaporte
  documentType  String   @default("rg")   // rg | cpf | passaporte
  role          String                    // degolador | sheik | auxiliar | supervisor_planta | veterinario
  photoUrl      String?                   // URL da foto do colaborador (S3/local)
  phone         String?
  email         String?
  isActive      Boolean  @default(true)
  createdAt     DateTime @default(now())
  updatedAt     DateTime @updatedAt

  plants        CollaboratorPlant[]       // Plantas onde atua (N:N)
  reportStaff   ReportStaff[]

  @@map("collaborators")
}

model CollaboratorPlant {
  collaboratorId String
  plantId        String
  collaborator   Collaborator @relation(fields: [collaboratorId], references: [id])
  plant          Plant        @relation(fields: [plantId], references: [id])

  @@id([collaboratorId, plantId])
  @@map("collaborator_plants")
}

model ReportStaff {
  id             String       @id @default(uuid())
  collaboratorId String
  reportId       String                    // ID do relatorio (abate/producao/embarque)
  reportType     String                    // slaughter | production | shipping
  roleInReport   String                    // Funcao naquele dia especifico
  date           DateTime                  // Data do servico

  collaborator   Collaborator @relation(fields: [collaboratorId], references: [id])

  @@index([reportId, reportType])
  @@index([collaboratorId, date])
  @@map("report_staff")
}
```

### 6.6.3 Foto do Colaborador

- Upload via endpoint `POST /collaborators/:id/photo` (multipart/form-data)
- Armazenamento: pasta local em dev (`uploads/collaborators/`), S3 em producao
- Formato aceito: JPEG, PNG (max 2MB)
- `photoUrl` armazena o path relativo ou URL S3
- Foto exibida no cadastro e opcionalmente nos relatorios impressos

### 6.6.4 Compartilhamento Futuro

- `externalId` permite vincular ao HalalSphere quando integrar
- SIH e o **master** deste cadastro na v1.0 (unico sistema que gerencia colaboradores operacionais)
- Na integracao futura, avalia-se se HalalSphere absorve este cadastro ou se SIH continua como master

### 6.6.5 Impacto nos Relatorios

- Campos `slaughtererName` / `slaughtererDoc` no SlaughterReport passam a ser preenchidos automaticamente a partir do `Collaborator` selecionado
- Tela de relatorio ganha secao "Equipe do dia" com selecao multipla de colaboradores
- PDF impresso pode listar a equipe envolvida

---

## 6.7 Comparativo Tecnico dos Sistemas

| Aspecto | HalalSphere | SIH | SysHalal |
|---------|-------------|-----|----------|
| Framework backend | NestJS 11 | NestJS 11 | NestJS 10 |
| ORM | Prisma 7 | Prisma 7 | Prisma 6 |
| ID strategy | UUID | UUID | Snowflake BigInt |
| Auth | JWT HS256/RS256 + bcrypt + cookies | JWT HS256 + bcrypt | JWT RS256 + bcrypt |
| Frontend | React 19 + Vite 7 | React 19 + Vite 7 | Next.js 14 + React 18 |
| UI | shadcn/ui + Tailwind v4 | shadcn/ui + Tailwind v4 | shadcn/ui + Tailwind v3 |
| State mgmt | React Query | React (local) | Zustand + React Query |
| Database | PostgreSQL 16 + pgvector | PostgreSQL 16 | PostgreSQL 16 |
| PDF | PDFKit | PDFKit | jsPDF + html2canvas |
| Modelos | 42 entidades | 7+3 entidades (v1.0+Collaborator) | ~20 entidades |
| Deploy | AWS (S3, SES, Secrets Manager) | Docker/local | AWS (S3, SES, SNS) |
