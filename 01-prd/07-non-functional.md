# 7. Requisitos Nao-Funcionais

---

## 7.1 Performance

| Requisito | Meta | Justificativa |
|-----------|------|---------------|
| Tempo de resposta API (P95) | < 500ms | Uso em campo com possivel 3G/4G |
| Tempo de resposta API (P99) | < 2s | Picos de uso no inicio de turno |
| First Contentful Paint (3G) | < 3s | Carregamento rapido em mobile |
| Time to Interactive (3G) | < 5s | Interacao rapida apos abertura |
| Tamanho do bundle (gzip) | < 500KB | Economia de dados moveis |
| Queries de listagem | < 200ms | Paginacao eficiente |

### Estrategias

- **Paginacao** em todas as listagens (20 itens/pagina padrao)
- **Indices de banco** nos campos de busca mais frequentes (plantId, date, status, supervisorId)
- **Lazy loading** de paginas no frontend (code splitting por rota)
- **Cache** de dados de referencia (plantas, perfil) no React Query (staleTime: 5min)

---

## 7.2 Seguranca

### Autenticacao (v1.0 — Self-Contained)

| Requisito | Implementacao |
|-----------|---------------|
| Algoritmo JWT | HS256 (self-contained — SIH emite e valida tokens) |
| Hash de senha | bcrypt (salt rounds 10) |
| Validade do token | 7 dias (estendida para uso em campo) |
| Armazenamento do token | localStorage (v1.0), IndexedDB (futuro offline) |
| CORS | Configurado por ambiente (localhost:5174 / dominio prod) |

### Autorizacao (RBAC)

| Role | Permissoes |
|------|-----------|
| `supervisor` | Cria/edita/assina relatorios (proprios), registra NCs, ve escala propria |
| `operador` | Cria/edita relatorios (proprios), registra NCs — NAO pode assinar |
| `coordenador` | Visualiza relatorios (read-only), cancela relatorios, gerencia escalas/usuarios/NCs — NAO assina |
| `admin` | Acesso total: CRUD completo, gerenciamento de usuarios e plantas |

### Protecoes

| Protecao | Implementacao |
|----------|---------------|
| Injecao SQL | Prisma ORM (parametrized queries) |
| XSS | React (escape automatico) + Content-Security-Policy |
| CSRF | Cookie-based tokens (quando aplicavel) |
| Rate limiting | Configuravel por endpoint (via middleware) |
| Dados sensiveis | Campos de senha nunca retornados na API |
| Audit trail | `createdAt`/`updatedAt` em todas as tabelas |

---

## 7.3 Usabilidade

### Responsividade

| Dispositivo | Breakpoint | Prioridade |
|-------------|-----------|:----------:|
| Tablet (landscape) | >= 1024px | **Principal** |
| Tablet (portrait) | >= 768px | Alta |
| Desktop | >= 1280px | Media |
| Mobile | < 768px | Baixa (funcional) |

### Acessibilidade em Campo

| Requisito | Justificativa |
|-----------|---------------|
| Touch targets >= 44x44px | Uso com luvas ou maos umidas |
| Fontes legiveis (min 16px body) | Leitura em ambientes com iluminacao variavel |
| Contraste alto (WCAG AA) | Uso ao ar livre / sob sol |
| Feedback visual de acoes | Confirmacao clara de envio/salvamento |
| Formularios com validacao inline | Erros visiveis sem scroll |
| Autosave de rascunho | Prevenir perda de dados (intervalo 30s) |

### Navegacao

| Requisito | Implementacao |
|-----------|---------------|
| Sidebar responsiva | Colapsavel em tablet, drawer em mobile |
| Breadcrumbs | Navegacao contextual em paginas internas |
| Atalhos de acao | Botao flutuante "Novo Relatorio" sempre visivel |
| Busca rapida | Campo de busca por serial no header |

---

## 7.4 PWA e Preparacao Offline

### v1.0 (Preparado)

| Item | Status |
|------|--------|
| `manifest.json` | Incluso (nome, icones, theme-color, display: standalone) |
| Service Worker basico | Via vite-plugin-pwa (cache de assets estaticos) |
| Meta tags PWA | theme-color, apple-mobile-web-app-capable, viewport tablet |
| Icones PWA | 192x192, 512x512 (identidade FAMBRAS) |
| Instalavel no tablet | Sim (manifest + service worker) |
| Pasta `src/lib/offline/` | Stubs criados (db.ts, sync-queue.ts) |

### Futuro (A implementar)

| Item | Descricao |
|------|-----------|
| Cache de dados (IndexedDB) | Via Dexie.js - relatorios, plantas, perfil |
| Background Sync | Envio automatico de relatorios pendentes |
| Indicador online/offline | Badge visual no header |
| Fila de sincronizacao | Relatorios pendentes com contador |
| Resolucao de conflitos | Timestamp-based ou merge manual |
| Service Worker avancado | Workbox com estrategias de cache por rota |

---

## 7.5 Escalabilidade

| Requisito | Meta |
|-----------|------|
| Usuarios simultaneos | 50+ supervisores |
| Relatorios/mes | 5.000+ |
| Tamanho do banco (1 ano) | < 5GB |
| NCs ativas simultaneas | 500+ |

### Estrategias

- **Paginacao em todas as listagens** (nunca retornar datasets completos)
- **Indices compostos** nos campos mais filtrados (plantId + date, status + date)
- **JSON para dados variavels** (verification items, products, raw materials) - evita joins complexos
- **Particionamento futuro** para inventario de alto volume (FM 7.1.5.6)

---

## 7.6 Disponibilidade

| Requisito | Meta |
|-----------|------|
| Uptime | > 99.5% |
| RTO (Recovery Time Objective) | < 1 hora |
| RPO (Recovery Point Objective) | < 15 minutos |
| Backup do banco | Diario automatico (AWS RDS) |

---

## 7.7 Observabilidade

| Item | Implementacao |
|------|---------------|
| Logs estruturados | `LoggingInterceptor` em todas as requisicoes |
| Health check | `GET /health` (banco, redis, app) |
| Metricas de erro | Exception filter global com logging |
| Swagger/OpenAPI | Documentacao automatica de todos os endpoints |

---

## 7.8 Compatibilidade de Navegadores

| Navegador | Versao Minima | Prioridade |
|-----------|:------------:|:----------:|
| Chrome (Android/Desktop) | 100+ | **Principal** |
| Safari (iOS/iPadOS) | 15+ | Alta |
| Samsung Internet | 20+ | Media |
| Firefox | 100+ | Media |
| Edge | 100+ | Baixa |

---

## 7.9 Infraestrutura

### Portas (sem conflito com HalalSphere)

| Servico | Porta SIH | Porta HalalSphere |
|---------|:---------:|:-----------------:|
| Backend API | 3334 | 3333 |
| Frontend Dev | 5174 | 5173 |
| PostgreSQL | 5433 | 5432 |
| Redis | 6380 | 6379 |

### Banco de Dados

| Item | Valor |
|------|-------|
| SGBD | PostgreSQL 16+ |
| Nome do banco | `sih` |
| Extensoes | uuid-ossp, pgcrypto, pg_trgm |
| ORM | Prisma 7.x |

### Cache

| Item | Valor |
|------|-------|
| Engine | Redis 7+ |
| Uso principal | Cache de sessao, rate limiting |

### Design System

| Item | Valor |
|------|-------|
| Cores primarias | Verde FAMBRAS #0A6847, Dourado #D4A853 |
| Fontes | Playfair Display (titulos), DM Sans (corpo), JetBrains Mono (codigo) |
| Componentes | shadcn/ui com tema FAMBRAS |
| Icones | Lucide React |
