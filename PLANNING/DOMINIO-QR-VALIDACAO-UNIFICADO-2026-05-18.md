# Unificação do domínio público de validação de certificados halal

**Status:** Proposta para reunião técnica — aguarda decisão
**Data:** 2026-05-18
**Domínio-alvo:** `cert.fambrashalal.com.br`
**Sistemas envolvidos:** SysHalal, HalalSphere/GC, SIH

---

## 1. Problema

Há **3 sistemas FAMBRAS Halal** que emitem PDFs com QR Code para validação pública. Cada um aponta hoje para um domínio diferente — o cliente quer que **todo QR FAMBRAS** termine em `cert.fambrashalal.com.br`, sem absorver os sistemas (a coexistência SysHalal × HalalSphere/GC é decisão firmada).

| Sistema | URL no QR hoje | Tela de validação |
|---|---|---|
| SysHalal | `https://cert.fambrashalal.com.br/certificadovalidate/{n}` | Next.js — `syshalal-web/src/app/(qrcode)/certificadovalidate/[id]/page.tsx` |
| HalalSphere/GC | `https://gestaodecertificacoes.ecohalal.solutions/verify/{n}` | Vite/SPA — `halalsphere-frontend/src/pages/VerifyCertificate.tsx` |
| SIH | — (emissão manual em construção, go-live jul/2026) | a definir |

---

## 2. Achados que mudam o desenho

### 2.1 Números de cert são distinguíveis por regex

- **GC**: padrão `ABC.SIG.YYMM.NNNN.PAIS` (5 segmentos separados por ponto, ex.: `NES.SOC.2603.0042.BRA`)
- **SysHalal**: id numérico puro (`^\d+$`)

Regra de roteamento confiável sem ambiguidade:
```
^\d+$              → SysHalal
^[A-Z]{3}\.        → GC
qualquer outra      → 404 unificado
```

### 2.2 PDFs em circulação que NÃO podem quebrar

- **SysHalal**: milhares de PDFs apontando para `cert.fambrashalal.com.br/certificadovalidate/...` há anos.
- **GC**: **1023 certificados** espelhados em prod desde 2026-05-14, todos apontando para `gestaodecertificacoes.ecohalal.solutions/verify/...`.

A solução tem que cobrir as duas URLs legadas.

### 2.3 Telas têm UX totalmente diferente

GC mostra ciclo M1/M2/renovação, selos, plantas, categorias, produtos (~745 linhas). SysHalal mostra slaughterers/processors/products + weights + datas BL + carta de correção (~270 linhas). **Modelos de dados divergem** — não é viável "unificar a tela", só o domínio.

### 2.4 Hardcodes localizados

Backend GC (1 ponto):
- `halalsphere-backend/src/certificate/pdf/qrcode-generator.ts:18`
  Construtor aceita override `verificationBaseUrl`, mas hoje nenhum caller passa.

Backend SysHalal (3 pontos):
- `syshalal-api/src/domain/certification/application/use-cases/create-certification-pdf.ts:296` (cert final, OK)
- `syshalal-api/src/domain/certification/application/use-cases/create-certification-pdf.ts:200` (draft — **bug**: path duplicado `/certificadovalidate//certificadovalidate/`)
- `syshalal-api/src/domain/certification/application/use-cases/create-correction-letter-pdf.ts:219` (carta correção, OK)
- Existe `FRONTEND_URL` no ConfigService que é lido mas **nunca aplicado** → refactor óbvio.

### 2.5 Infra atual (inferida)

- **syshalal-web**: containerizado (Docker + ECR). Provável **ECS Fargate atrás de ALB + CloudFront** (necessário p/ HTTPS no domínio + Next SSR). **Confirmar com infra.**
- **halalsphere-frontend**: SPA estático, build `aws s3 cp dist s3://... && cloudfront invalidation`. **S3 + CloudFront clássico.**

---

## 3. Opções avaliadas

### Opção A — Path-based routing no CloudFront (multi-origin behaviors) ✅ RECOMENDADA

Uma única distribuição CloudFront para `cert.fambrashalal.com.br` com **dois behaviors**:
- `/certificadovalidate/*` → origin ECS/ALB do syshalal-web (atual, intocado)
- `/verify/*` → origin S3 do halalsphere-frontend (novo)

```
Cliente do QR Code
        │
        ▼
DNS Route53: cert.fambrashalal.com.br ──► CloudFront Distribution (reused)
                                                  │
                                ┌─────────────────┼──────────────────┐
                                ▼                                    ▼
                  /certificadovalidate/*                       /verify/*
                  Origin: ALB → ECS (syshalal-web)             Origin: S3 (halalsphere-frontend)
                  SSR Next.js                                  SPA com SPA fallback p/ index.html
```

E no domínio antigo:
```
gestaodecertificacoes.ecohalal.solutions/verify/*
└── CloudFront Function → 301 redirect → cert.fambrashalal.com.br/verify/$1
```

**Mudanças por repo:**

| Repo | Arquivo | Mudança |
|---|---|---|
| `halalsphere-backend` | `src/certificate/pdf/qrcode-generator.ts:17-19` | Trocar default hardcoded por env `QR_VERIFICATION_BASE_URL`. |
| `halalsphere-backend` | Renderers que instanciam `CertificateQrCodeGenerator` | Injetar URL via `ConfigService`. |
| `halalsphere-frontend` | `vite.config.ts` + `App.tsx` | Adicionar `base: '/verify/'` e `<BrowserRouter basename="/verify">` (ou usar `import.meta.env.BASE_URL`). |
| `syshalal-api` | `create-certification-pdf.ts:200,296` + `create-correction-letter-pdf.ts:219` | Extrair URL para env `QR_VERIFICATION_BASE_URL` + corrigir bug do path duplicado linha 200. |
| Infra | CloudFront `cert.fambrashalal.com.br` | Adicionar behavior `/verify/*` com origin S3 + CloudFront Function p/ SPA fallback. |
| Infra | CloudFront `gestaodecertificacoes.ecohalal.solutions` | CloudFront Function 301 em behavior `/verify/*`. |

**Custo:** < US$ 5/mês (apenas behavior extra + S3, sem L@E)
**Esforço:** 3-5 dias úteis
**Reversibilidade:** Alta (rollback em minutos)
**Drift visual GC ↔ novo:** Zero (continua a mesma SPA)
**PDFs antigos SysHalal:** OK (domínio igual)
**PDFs antigos GC:** OK via redirect 301

**Ponto de atenção crítico — subpath SPA:**
O Vite/SPA precisa funcionar tanto em `gestaodecertificacoes.ecohalal.solutions/verify/...` (autenticado) quanto em `cert.fambrashalal.com.br/verify/...` (público). Soluções:
1. Build único com `basename` dinâmico via `import.meta.env.BASE_URL`.
2. Dois builds separados com env diferente.

A decisão depende se o `gestaodecertificacoes.*` continua hospedando rotas autenticadas além de `/verify`. (Sim, continua.)

---

### Opção B — CloudFront Function com roteamento por regex

URL canônica curta `/c/{n}`, CFF inspeciona padrão e reescreve internamente:
```
cert.fambrashalal.com.br/c/{n}
       │
       ▼
CloudFront Function (viewer-request)
   ├── if /^\d+$/.test(n)        → reescreve /certificadovalidate/{n}  → ECS syshalal
   ├── if /^[A-Z]{3}\./.test(n)  → reescreve /verify/{n}              → S3 GC
   └── else                      → 404 unificado
```

**Vantagem:** QR mais curto e branded (importa em etiquetas físicas pequenas).
**Custo:** Baixo (CFF ~US$ 0.10/1M req).
**Esforço:** 4-6 dias (1 a mais que A).
**Reversibilidade:** Alta.

**Por que NÃO agora:** B é estritamente superset de A. Começa por A, mede, evolui se o ganho da URL curta importar. PDFs antigos continuam funcionando porque seus paths legados nunca passam pela CFF.

---

### Opção C — Reverse proxy SSR no syshalal-web (Next.js) ❌

syshalal-web adiciona `/verify/[n]/page.tsx` que faz fetch na API GC e renderiza HTML.

**Custo:** baixo
**Esforço:** 6-10 dias (portar tela GC inteira)
**Riscos:** drift visual garantido em 3 meses; latência +50-100ms; acoplamento novo (syshalal-web depende da API GC).

Fere coexistência sem absorção. **Não recomendado.**

---

### Opção D — Migrar `VerifyCertificate` para o syshalal-web ❌

Porta o componente React Router (745 linhas, com 5 cards ricos) para Next 14 + React 18.

**Esforço:** 10-15 dias
**Reversibilidade:** Baixa
**Riscos:** drift visual + conflito de ownership (time GC perde controle de "sua" tela) + bundle Next inflado.

**Não recomendado.**

---

### Opção E — Lambda@Edge (variante de B com lógica rica)

Lambda@Edge para decisões além de regex (ex.: consultar API para descobrir tipo de cert).

**Custo:** Médio (US$ 0.60/1M req + execução; +30-80ms de cold start ocasional)
**Esforço:** 7-9 dias

**Só faz sentido se a regex de B não bastar** — improvável dado o desenho atual.

---

## 4. Comparativo

| Critério | A (path) | B (CFF regex) | C (proxy SSR) | D (migração) | E (L@E) |
|---|---|---|---|---|---|
| QR Code mais curto | Não | **Sim** | Não | Não | **Sim** |
| Mantém ownership GC | Sim | Sim | Não | Não | Sim |
| Drift visual | Nenhum | Nenhum | Alto | Alto | Nenhum |
| Latência adicional | 0 | <1ms | +50-100ms | 0 | +30-80ms |
| Custo infra | Baixo | Baixo | Baixo | Baixo | Médio |
| Esforço (dias) | **3-5** | 4-6 | 6-10 | 10-15 | 7-9 |
| Reversibilidade | Alta | Alta | Média | Baixa | Alta |
| Aproveita infra existente | **Sim** | Sim | Parcial | Não | Sim |

---

## 5. Recomendação: Opção A

### Justificativa
1. Não fere a diretriz de coexistência: cada sistema continua dono da sua tela e do seu modelo.
2. Esforço mais baixo e maior reversibilidade — rollback em minutos.
3. Aproveita exatamente a infra que já existe (distribuição CloudFront do `cert.fambrashalal.com.br` rodando, bucket S3 do halalsphere-frontend rodando).
4. PDFs antigos cobertos: SysHalal por identidade de domínio, GC por redirect 301.
5. **Caminho evolutivo limpo para B**: se daqui a 6 meses quiserem URLs canônicas mais curtas (`/c/{n}`), basta adicionar uma CloudFront Function — toda a base da A continua válida.
6. **SIH (jul/2026)**: ao entrar, basta apontar para `/verify/{n}` (se usar API GC) ou `/sih-verify/{n}` (se tiver API própria), adicionando terceiro behavior no mesmo CloudFront.

---

## 6. Roadmap de implementação (caso aprovada Opção A)

### Fase 0 — Pré-requisitos (antes de codar)
Confirmações com time de infra:
- Distribuição CloudFront de `cert.fambrashalal.com.br` está na AWS account dos Ecohalal/FAMBRAS?
- Origin atual é ALB-ECS direto ou há nginx/proxy intermediário?
- ACM cert cobre `cert.fambrashalal.com.br`?

### Fase 1 — Backend GC respeita env (1 dia)
- `halalsphere-backend/src/certificate/pdf/qrcode-generator.ts`: ler `process.env.QR_VERIFICATION_BASE_URL` (default mantém valor antigo p/ não quebrar staging).
- Variáveis por ambiente:
  - prod: `QR_VERIFICATION_BASE_URL=https://cert.fambrashalal.com.br/verify`
  - staging: `https://gestaodecertificacoes-staging.ecohalal.solutions/verify`

**Critério pronto:** novo PDF gerado em staging tem QR apontando para `cert.fambrashalal.com.br/verify/{n}` (mesmo que ainda 404).

### Fase 2 — Frontend GC servível em subpath (1 dia)
- `halalsphere-frontend/vite.config.ts`: `base: '/verify/'` quando build target = produção FAMBRAS.
- `halalsphere-frontend/src/App.tsx`: `<BrowserRouter basename="/verify">`.
- Build dual ou env dinâmico (a decidir).

**Critério pronto:** bundle em S3 acessível em `https://cert.fambrashalal.com.br/verify/{n}` sem 404 (após Fase 3).

### Fase 3 — CloudFront com novo behavior (1 dia)
- Adicionar Origin 2: S3 bucket halalsphere-frontend.
- Adicionar Behavior: `path pattern /verify/*`, target Origin 2, cache "CachingOptimized", redirect HTTP→HTTPS.
- CloudFront Function (viewer-request) para SPA fallback: se path = `/verify/{n}` e não é asset → reescreve `/verify/index.html`.

**Critério pronto:** `curl https://cert.fambrashalal.com.br/verify/NES.SOC.2603.0042.BRA` retorna 200 com bundle GC; SPA hidrata, chama API, mostra dados.

### Fase 4 — Redirect 301 do domínio antigo (0.5 dia)
- CloudFront Function no behavior `/verify/*` de `gestaodecertificacoes.ecohalal.solutions` que retorna 301 com `Location: https://cert.fambrashalal.com.br/verify/{n}`.
- **Importante:** só roda no path `/verify/*`. O resto do domínio (rotas autenticadas) intocado.

**Critério pronto:** `curl -I https://gestaodecertificacoes.ecohalal.solutions/verify/NES.SOC.2603.0042.BRA` retorna `HTTP/2 301` com `Location` correto.

### Fase 5 — Correção de hardcodes SysHalal (0.5 dia)
- Corrigir bug `/certificadovalidate//certificadovalidate/` na linha 200 do `create-certification-pdf.ts`.
- Extrair URL p/ env `QR_VERIFICATION_BASE_URL=https://cert.fambrashalal.com.br/certificadovalidate` nos 3 pontos.

**Critério pronto:** PDFs novos do SysHalal com URL correta, sem path duplicado.

### Fase 6 — Testes E2E e monitoramento (1 dia)
- Scan real iPhone + Android dos 3 cenários:
  - PDF SysHalal antigo
  - PDF GC antigo (deve redirecionar)
  - PDF GC novo
- 48h monitorando CloudFront logs (esperado: <0.1% de 5xx em `/verify/*`).

### Critério geral de "pronto para produção"
- [ ] Todas as fases validadas em staging.
- [ ] 100 scans manuais (50 GC antigos + 50 SysHalal antigos + 10 GC novos) sem falha.
- [ ] Logs CloudFront mostram <0.1% de 5xx em `/verify/*` por 24h.
- [ ] Backup do estado anterior do CloudFront documentado (JSON da distribuição) p/ rollback rápido.

---

## 7. Perguntas em aberto

1. **Topologia atual do CloudFront** de `cert.fambrashalal.com.br` — ALB → ECS direto, ou nginx intermediário? Quem opera (Ecohalal interno ou parceiro FAMBRAS)?
2. **Regerar PDFs dos 1023 certs GC já em prod** ou só novos usam a nova URL? Recomendação: **não regerar** — 301 cobre.
3. **`gestaodecertificacoes.ecohalal.solutions` continuará no ar** para uso interno autenticado, correto? Em algum momento futuro este domínio também muda para FAMBRAS-branded?
4. **SIH (jul/2026)** — qual padrão de número? Distinguível de SysHalal (numérico) e GC (`ABC.SIG.YYMM.NNNN.PAIS`)? Se sim, entra como terceiro behavior. Se ambíguo, força prefixo no path.
5. **Política de cache para o SPA do GC** — recomendação padrão: `index.html` `Cache-Control: no-cache`, assets com hash `max-age=31536000, immutable`.
6. **TTL do redirect 301** do domínio antigo: permanente ou janela definida (ex.: 12 meses)? Recomendação: permanente.
7. **WAF/rate-limit em `cert.fambrashalal.com.br`** — bloqueia o novo path? PDFs são scaneados do exterior (importadores árabes); cuidar bloqueio geo.
8. **SEO**: páginas são públicas mas não-indexáveis. Confirmar se há expectativa de indexação.
9. **Alinhamento visual** das duas telas (SysHalal × GC) para reforço de branding FAMBRAS — fora do escopo arquitetural, mas worth flag.

---

## 8. Resumo executivo (1 página)

- **Problema:** dois domínios públicos para QRs FAMBRAS Halal. Cliente quer um só: `cert.fambrashalal.com.br`.
- **Constraint:** SysHalal e HalalSphere/GC continuam separados (coexistência sem absorção).
- **Recomendação:** Opção A — path-based routing no CloudFront. Adicionar behavior `/verify/*` no CloudFront existente apontando para o S3 do halalsphere-frontend; manter `/certificadovalidate/*` no syshalal-web. Backend GC passa a escrever URL nova. Redirect 301 no domínio antigo cobre os 1023 PDFs já circulando.
- **Esforço:** 3-5 dias úteis.
- **Custo infra adicional:** < US$ 5/mês.
- **Risco:** baixo. Reversível em minutos.
- **Bônus:** corrige bug existente `/certificadovalidate//certificadovalidate/` em `syshalal-api/.../create-certification-pdf.ts:200`.
- **Evolução futura:** se quiserem URLs canônicas curtas (`/c/{n}`), transição não-destrutiva para Opção B.

---

## 9. Arquivos críticos para implementação

- `halalsphere-backend/src/certificate/pdf/qrcode-generator.ts`
- `halalsphere-frontend/vite.config.ts`
- `halalsphere-frontend/src/App.tsx`
- `syshalal-api/src/domain/certification/application/use-cases/create-certification-pdf.ts`
- `syshalal-api/src/domain/certification/application/use-cases/create-correction-letter-pdf.ts`
- Infra: distribuição CloudFront `cert.fambrashalal.com.br` + distribuição `gestaodecertificacoes.ecohalal.solutions`

---

**Próximo passo:** levar para reunião técnica, responder às 9 perguntas em aberto, decidir entre A e B, escalonar implementação.
