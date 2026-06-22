# Unificação do domínio público de validação de certificados halal

**Status:** Proposta para reunião técnica — aguarda decisão
**Data:** 2026-05-18 · *atualizado 2026-06-18 (premissa de não-titularidade + runbook AWS)*
**Domínio-alvo:** `cert.fambrashalal.com.br`
**Sistemas envolvidos:** SysHalal, HalalSphere/GC, SIH

---

## 0. Premissa de titularidade do domínio (adendo 2026-06-18)

**Premissa do PO:** a EcoHalal **não tem a titularidade** de `fambrashalal.com.br`
(o domínio é registrado pela FAMBRAS). A EcoHalal tem apenas o **uso** já
existente: o QR Code dos certificados do SysHalal aponta para
`cert.fambrashalal.com.br/certificadovalidate/...`.

### 0.1 "Titularidade" trava menos do que parece

Para servir o GC em `cert.fambrashalal.com.br/verify/...` **não é necessário ser
dono do domínio**. É necessário controle sobre três recursos *separados* — e só
um deles é "titularidade":

| Recurso | Quem controla | Necessário p/ a feature? |
|---|---|---|
| Registro do domínio `fambrashalal.com.br` | FAMBRAS (registrador) | ❌ Não |
| Zona DNS (responde por `cert.fambrashalal.com.br`) | operador de DNS da FAMBRAS | ⚠️ Só uma vez, se criar hostname novo |
| Certificado TLS (ACM) válido p/ o hostname | quem emitiu o cert | ⚠️ Já existe p/ `cert.*` |
| **Distribuição CloudFront / origem** | **provavelmente a EcoHalal** | ✅ **É aqui que mora a solução** |

### 0.2 Virada de chave

**SysHalal é um sistema da própria EcoHalal** (`syshalal-api`/`syshalal-web` são
repos internos) e já serve `cert.fambrashalal.com.br/certificadovalidate/...` há
anos. Logo, com altíssima probabilidade **a EcoHalal já opera a distribuição
CloudFront por trás desse hostname**, e a FAMBRAS apenas apontou o DNS (CNAME)
para ela e validou o TLS uma vez. Se confirmado, adicionar o behavior
`/verify/*` é **100% interno à EcoHalal — sem pedir nada novo à FAMBRAS** —
porque o DNS já aponta e o TLS já cobre o hostname.

**Pergunta decisiva (gargalo único):** *a EcoHalal opera a distribuição
CloudFront e detém o cert ACM de `cert.fambrashalal.com.br` hoje?* Ver runbook de
verificação na **seção 10**.

### 0.3 Espectro de opções por cooperação exigida da FAMBRAS

| Cenário | Quem opera `cert.*` | Cooperação FAMBRAS | Hostname | Acoplamento | Veredito |
|---|---|---|---|---|---|
| **1** | EcoHalal | **Zero** | `cert.*` (exato) | Nenhum | ✅ **Ideal** — é a Opção A abaixo |
| **2a** | terceiro | 1 mudança de config no operador | `cert.*` (exato) | Médio (depende do terceiro p/ mudanças futuras) | OK se 1 inviável |
| **2b** | terceiro / indisponível | 1 CNAME + 1 validação ACM (one-time) | `validar.fambrashalal.com.br` ou `gc.fambrashalal.com.br` (irmão, **mesmo domínio registrado**) | Baixo — EcoHalal 100% autônoma depois | ✅ Melhor fallback |
| **2c** | terceiro | rota de proxy no SysHalal | `cert.*` (exato) | Alto (runtime SysHalal→GC) | ❌ Fere coexistência |

**Nota sobre 2b:** não é o hostname literal `cert.fambrashalal.com.br`, mas é o
**mesmo domínio registrado** `fambrashalal.com.br`. Organismos internacionais
avaliam o domínio registrado, não o label do subdomínio — a credibilidade se
mantém. É o melhor equilíbrio entre "mesmo domínio" e mínimo acoplamento
operacional, caso o cenário 1 não se confirme e o 2a tenha atrito.

**Recomendação atualizada:** confirmar a pergunta decisiva (seção 10) →
se EcoHalal opera, executar **Opção A** (nada a negociar) → se não, preferir
**2a**, fallback **2b**, evitar **2c**.

### 0.4 Achado de stack (2026-06-18): SysHalal é ECS/ALB, provavelmente SEM CloudFront

Inspeção dos repos `syshalal-web`/`syshalal-api`:
- `syshalal-web` é **Next.js 14 SSR em container** (`next.config.mjs` → `output: 'standalone'`; `Dockerfile` → `CMD ["node","server.js"]`).
- Pipeline (`codepipeline/buildspec-fambrashalal.yml`) faz `docker build → push ECR → imagedefinitions.json` (container `fambrashalal-cert-web`) — artefato típico de **deploy ECS**.
- **Não há** `aws s3 cp` nem `cloudfront create-invalidation` em nenhum buildspec do SysHalal (ao contrário do `halalsphere-frontend`, que tem ambos). Nada no SysHalal toca S3/CloudFront.

**Conclusão provável:** borda = **Route53 → ALB (HTTPS:443, ACM regional) → ECS Fargate**, sem CloudFront. A confirmar pelo alvo do CNAME (seção 10, Passo 1): `.elb.amazonaws.com` = ALB puro; `.cloudfront.net` = há CloudFront.

**Impacto na Opção A:** a Opção A (adicionar behavior `/verify/*`) pressupõe CloudFront
existente. **Se a borda for ALB puro, a Opção A não se aplica diretamente** — um
**ALB não serve SPA de S3** (targets só ECS/EC2/IP/Lambda). Reordenação das opções
sob ALB-puro:

| Opção (ALB-puro) | Envolve | Toca borda viva SysHalal? | Esforço/risco |
|---|---|---|---|
| **2b — subdomínio irmão delegado** (`validar.fambrashalal.com.br` → CloudFront próprio EcoHalal + S3) | 1 CNAME + 1 validação ACM (one-time) FAMBRAS; EcoHalal monta CloudFront+S3+ACM us-east-1 só do verify GC | **Não** | **Baixo** ✅ recomendado |
| CloudFront na frente de `cert.*` | nova distribuição 2 origens (ALB+S3) + cutover DNS + ACM p/ us-east-1 + WAF/headers | **Sim** (cutover em domínio de terceiro) | Médio + risco |
| Regra ALB → verify GC container/Lambda | empacotar verify GC como container/Lambda + target group + regra `/verify/*` | **Sim** | Médio-alto + acoplamento |
| 2c — proxy no Next do SysHalal | rota `/verify/[id]` no app SysHalal | host idêntico, acopla runtime | ❌ fere coexistência |

**Recomendação se ALB-puro confirmado:** preferir **2b** (subdomínio irmão delegado,
CloudFront próprio da EcoHalal) — deixa SysHalal 100% intocado, autonomia total,
mesmo domínio registrado. Só forçar o host literal `cert.fambrashalal.com.br` se
houver exigência formal (custo = cutover de borda em domínio de terceiro).

### 0.5 TOPOLOGIA CONFIRMADA via console AWS (2026-06-18) → decisão: Caminho B (regra ALB)

Console AWS confirmou (prints do PO):

```
cert.fambrashalal.com.br ──(A record)──► ALB  ecohalal-fambrashalal-web
   conta 767397935861 · us-east-1 · vpc-0d47cab0d440d5de5 (CIDR 10.10.20.0/23) · internet-facing
   listener HTTPS:443  ── TLS  *.fambrashalal.com.br  (cert WILDCARD instalado NA ALB)
      └─ default → TG fambrashalal-cert-web-tg (target type IP)
                    → 10.10.20.229:3000 + 10.10.20.87:3000  (ECS Fargate, Next SSR)
   listener HTTP:80 → redirect 301 → HTTPS
```

**Três destravamentos decisivos:**
1. **A ALB é da própria EcoHalal** (conta 767397935861, nome `ecohalal-*`). Controle total — adicionar regra de listener é interno, sem terceiros.
2. **Cert wildcard `*.fambrashalal.com.br` JÁ instalado na ALB.** EcoHalal já serve qualquer `*.fambrashalal.com.br` com TLS válido — **sem nova validação ACM, sem pedir nada à FAMBRAS.**
3. **Sem CloudFront, sem necessidade de cutover de DNS** (`cert.*` já aponta pra essa ALB).

→ Caem as ressalvas do Caminho A/2b. **Decisão: Caminho B** — unificar adicionando
regra de listener na ALB que a EcoHalal já opera. CloudFront sai de cena (traria
cutover p/ ganho de cache que página de baixo tráfego não precisa). NestJS+SPA
proxy descartado (a ALB já é o reverse proxy que oculta origem).

#### Plano Caminho B

Conceito:
```
ALB ecohalal-fambrashalal-web · HTTPS:443 (wildcard cobre)
  ├─ regra prio 10   /verify/*                       → TG gc-verify-tg (novo: container nginx+SPA verify GC)
  └─ default         /certificadovalidate/* + resto  → TG fambrashalal-cert-web-tg (SysHalal, INTOCADO)
```
Regra `/verify/*` acima do default não afeta `/certificadovalidate/*` nem o SysHalal. Reversível (deletar a regra).

**Recursos AWS novos** (conta 767397935861, us-east-1, mesma VPC `vpc-0d47cab0d440d5de5`):
- ECR `gc-verify-web` (nginx servindo build do verify GC).
- ECS service `gc-verify` no mesmo cluster, Fargate, 2 tasks (HA), subnets privadas já usadas.
- Target group `gc-verify-tg` tipo **IP**, porta 80, health check `/verify/`.
- 1 regra de listener HTTPS:443: `path /verify/*` → forward `gc-verify-tg`.

**Mudanças por repo:**
- `halalsphere-frontend`: `vite.config` `base: '/verify/'` + `<BrowserRouter basename="/verify">`; API base relativa `/verify/api`. Adicionar `Dockerfile`(nginx) + `nginx.conf` (estático + SPA fallback p/ `/verify/index.html` + **proxy `/verify/api/* → API GC server-side**). Buildspec espelhando o do `syshalal-web` (push ECR `gc-verify-web`).
- `halalsphere-backend`: parametrizar `qrcode-generator.ts` por env `QR_VERIFICATION_BASE_URL`; prod = `https://cert.fambrashalal.com.br/verify`.
- `gestaodecertificacoes.*/verify`: **NÃO precisa de redirect 301.** O GC **não tem PDFs antigos em circulação** (base de prod zerada 28/mai; os "~1023 certs" eram dados de espelhamento, não documentos emitidos). `cert.*/verify` serve **apenas certificados novos do GC, emitidos a partir do go-live**.

**Repositórios: nenhum repo Git novo.** Tudo cabe nos existentes:
- `halalsphere-backend` (existente) → env `QR_VERIFICATION_BASE_URL`.
- `halalsphere-frontend` (existente) → reaproveita `VerifyCertificate.tsx`; só adiciona `Dockerfile`+`nginx.conf`+buildspec (novo alvo de entrega = container, além do deploy S3/CloudFront atual). Mesma fonte da verdade, sem duplicação.
- `gc-verify-web` é **repositório ECR** (imagem Docker, recurso AWS) — **não** é repo Git.

> **Consideração opcional (não obrigatória agora):** a tela de verify é **pública**;
> empacotá-la junto com o SPA autenticado faz a imagem carregar o bundle do app inteiro
> (mesmo a ALB roteando só `/verify/*`). Se no futuro quiserem **isolar a superfície
> pública** da privada por segurança, aí sim um build/repo dedicado só do verify se
> justifica. Para o mínimo ajuste de agora, reaproveitar o `halalsphere-frontend` é o
> caminho — evolução para build isolado depois é sem retrabalho.

**Ocultar URL interna:** `nginx.conf` faz proxy de `/verify/api/*` → API GC no lado
servidor; browser só vê `cert.fambrashalal.com.br`. Same-origin elimina CORS. Stack
SPA do GC reaproveitada inteira.

**Esforço:** ~2-3 dias. **Custo:** 1 container Fargate pequeno. **Risco:** baixo, reversível.

**SIH (jul/2026):** entra como 4ª regra `/sih-verify/*` (ou path próprio) no mesmo listener — mesmo padrão.

#### Garantia: SysHalal (`/certificadovalidate/*`) continua sem outage

**Como a ALB roteia:** regras do listener são avaliadas por prioridade; a **primeira
que casa** vence; se nenhuma casa, aplica a **ação default**. Hoje o HTTPS:443 tem só
a default → SysHalal (`fambrashalal-cert-web-tg`). Adicionamos uma regra
`path-pattern /verify/*` → `gc-verify-tg`. Resultado:
- `/certificadovalidate/...` **não casa** `/verify/*` → cai na default → **SysHalal, idêntico a hoje**.
- `/verify/...` → GC. Qualquer outro path → default → SysHalal.

A regra é **aditiva e disjunta**: só captura `/verify/*`, nunca toca o tráfego do SysHalal.

**Por que não há outage:**
- Adicionar regra de listener é **operação online** da ALB — não reinicia listener, não dropa conexões, não drena targets.
- **Sem mudança de DNS** (`cert.*` segue na mesma ALB) → zero propagação.
- **Sem mudança de cert** (wildcard `*.fambrashalal.com.br` já cobre) → zero disrupção TLS.
- Falha no serviço novo do GC afeta **só `/verify/*`**; `/certificadovalidate/*` fica blindado.
- **Reversível:** deletar a regra restaura exatamente o estado de hoje.

**Regras de ouro na execução (condições para a garantia valer):**
1. **Só ADICIONAR** a regra `/verify/*`. **NUNCA** editar a ação default, o certificado, nem o protocolo/porta do listener — é aí que se quebraria o SysHalal.
2. Condição da regra **específica**: `/verify/*` (e `/verify/api/*` se houver). Nada genérico que pegue outros paths.
3. Validar a regra em path de teste **antes** de qualquer QR real apontar pra ela.

#### TODO — Caminho B (sequência de execução; pré-go-live, requer autorização)

**Fase 0 — pré-requisitos / confirmações**
- [ ] Confirmar autorização explícita do PO para mexer na ALB de prod (escrita em prod).
- [ ] Identificar o cluster ECS e a task definition do `syshalal-web` (mesmo cluster/VPC reaproveitados pelo `gc-verify`).
- [ ] Confirmar URL interna da API do GC que o nginx vai proxiar em `/verify/api/*`.

**Fase 1 — backend GC (isolado, baixo risco)**
- [ ] Parametrizar `qrcode-generator.ts` para ler `QR_VERIFICATION_BASE_URL` (default mantém valor atual p/ não quebrar staging).
- [ ] Definir env de prod `QR_VERIFICATION_BASE_URL=https://cert.fambrashalal.com.br/verify` (na task definition do backend GC).
- [ ] Validar: novo cert gerado tem QR apontando pra `cert.*/verify/{n}` (mesmo que ainda 404 até a Fase 3).

**Fase 2 — frontend GC servível em subpath + container**
- [ ] `vite.config`: `base: '/verify/'`.
- [ ] `App.tsx`: `<BrowserRouter basename="/verify">`.
- [ ] API base do SPA → caminho relativo `/verify/api`.
- [ ] Criar `Dockerfile` (nginx) + `nginx.conf`: servir estático, **SPA fallback** p/ `/verify/index.html`, **proxy `/verify/api/* → API GC** (server-side, oculta origem).
- [ ] Criar buildspec espelhando o do `syshalal-web` (push p/ ECR `gc-verify-web`).

**Fase 3 — infra AWS (aditiva)**
- [ ] Criar ECR `gc-verify-web`.
- [ ] Criar ECS service `gc-verify` (Fargate, 2 tasks, mesma VPC/subnets).
- [ ] Criar target group `gc-verify-tg` (tipo IP, porta 80, health check `/verify/`).
- [ ] **Adicionar** regra de listener HTTPS:443 `path /verify/*` → `gc-verify-tg` (NÃO tocar default/cert/listener).

**Fase 4 — validação E2E**
- [ ] `curl https://cert.fambrashalal.com.br/verify/{num-teste}` → 200, SPA hidrata, chama API via `/verify/api`, mostra dados.
- [ ] Confirmar `/certificadovalidate/{n}` do SysHalal **inalterado** (scan real + curl).
- [ ] Scan real iPhone+Android de um cert GC novo.
- [ ] Documentar estado anterior da regra (p/ rollback = deletar a regra).

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

- **SysHalal**: milhares de PDFs apontando para `cert.fambrashalal.com.br/certificadovalidate/...` há anos. **Essa URL precisa continuar funcionando** (e continua — mesmo host).
- **GC**: ⚠️ **CORREÇÃO 2026-06-18 (PO):** o GC **NÃO tem PDFs antigos em circulação**. A base de prod foi zerada em 28/mai; os "1023 certs espelhados" eram dados de espelhamento e **os certificados que estão na base hoje são de teste**. Documentos emitidos são imutáveis e nunca são regenerados; certificados legados importados mantêm o QR próprio que já possuem (outra ação) e **não passam a validar pelo GC**. ⇒ **Nenhuma URL legada do GC a cobrir; sem redirect 301.** `cert.*/verify` serve só certificados novos do GC (pós go-live).

A solução só precisa cobrir a URL legada do **SysHalal** (já coberta por identidade de host).

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

- **syshalal-web**: containerizado (Docker + ECR), Next SSR `output: standalone`. Padrão de deploy ECS (`imagedefinitions.json`). Borda **provavelmente ALB-puro (ACM regional), SEM CloudFront** — ver seção 0.4. ALB faz HTTPS sozinho; CloudFront NÃO é necessário p/ TLS. **Confirmar pelo alvo do CNAME (seção 10, Passo 1).**
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

---

## 10. Runbook — verificar CloudFront e ACM de `cert.fambrashalal.com.br` (adendo 2026-06-18)

Objetivo: responder à **pergunta decisiva** (seção 0.2) — *a EcoHalal opera a
distribuição CloudFront e detém o cert ACM desse hostname?* 10-15 min.

### Passo 0 — Pré-requisito: saber em qual conta AWS olhar
A EcoHalal pode ter mais de uma conta AWS. A distribuição que serve o SysHalal
está na conta onde o SysHalal foi deployado. Em dúvida, comece pela conta de
produção do SysHalal/HalalSphere.

> ⚠️ CloudFront e ACM-para-CloudFront são **globais**, mas o ACM precisa estar na
> região **us-east-1 (N. Virginia)** para ser usável pelo CloudFront. Sempre
> selecione `us-east-1` ao procurar o certificado.

### Passo 1 — Resolver o DNS (não precisa de login AWS; faça primeiro)
No PowerShell:
```powershell
Resolve-DnsName cert.fambrashalal.com.br -Type CNAME
Resolve-DnsName cert.fambrashalal.com.br -Type A
```
Ou no Bash:
```bash
dig +short cert.fambrashalal.com.br
dig +short CNAME cert.fambrashalal.com.br
```
**Interpretação (o alvo do CNAME revela a topologia):**
- Termina em **`.cloudfront.net`** (ex.: `d1234abcd.cloudfront.net`) → servido por **CloudFront**. Anote a etiqueta `dXXXX.cloudfront.net` e siga os Passos 3-5 (achar distribuição + ACM). Opção A viável.
- Termina em **`.elb.amazonaws.com`** (ex.: `syshalal-alb-123.us-east-1.elb.amazonaws.com`) → **ALB puro, SEM CloudFront** (cenário da seção 0.4). Opção A NÃO se aplica direto (ALB não serve S3). Ir para a tabela ALB-puro da seção 0.4 → recomendado **2b** (subdomínio irmão). Para confirmar o ALB no console: EC2 → Load Balancers → achar o de DNS = esse alvo; o ACM dele estará no **listener HTTPS:443**, na **região do ALB** (não us-east-1).
- Resolve direto p/ IPs fixos / outro CDN → mapear topologia real antes de decidir.

### Passo 2 — Login no Console AWS
Entrar em https://console.aws.amazon.com com uma conta/role que tenha pelo menos
permissão de leitura de CloudFront e ACM (`cloudfront:List*`, `cloudfront:Get*`,
`acm:List*`, `acm:Describe*`). Role read-only já basta.

### Passo 3 — Achar a distribuição CloudFront
1. Console → serviço **CloudFront** → **Distributions**.
2. Procure a distribuição cujo **Domain name** = o `dXXXX.cloudfront.net` do Passo 1,
   **ou** cujo campo **Alternate domain names (CNAMEs)** contenha
   `cert.fambrashalal.com.br`.
3. **Se encontrar → a EcoHalal (essa conta) opera a distribuição = Cenário 1 ✅.**
   **Se NÃO encontrar em nenhuma conta sua → terceiro opera = Cenário 2.**

Por CLI (alternativa ao console):
```powershell
aws cloudfront list-distributions `
  --query "DistributionList.Items[?contains(Aliases.Items, 'cert.fambrashalal.com.br')].{Id:Id,Domain:DomainName,Aliases:Aliases.Items}" `
  --output json
```

### Passo 4 — Inspecionar a distribuição (se encontrada)
Abrir a distribuição e anotar, para o plano da Opção A:
- **Aba General → Settings:**
  - *Alternate domain names (CNAMEs):* deve listar `cert.fambrashalal.com.br`.
  - *Custom SSL certificate:* clique — leva ao ACM (ver Passo 5). Anote o ARN.
- **Aba Origins:** quais origens existem hoje (provavelmente o ALB/ECS do
  syshalal-web). Para a Opção A vamos **adicionar** uma origem S3 do
  `halalsphere-frontend` — confirme que ainda não existe.
- **Aba Behaviors:** confirme que existe `/certificadovalidate/*` (ou Default `*`)
  apontando para o SysHalal. O novo behavior `/verify/*` será adicionado aqui —
  confirme que `/verify/*` ainda **não** existe.

### Passo 5 — Confirmar o certificado ACM
1. Console → **Certificate Manager (ACM)** → **trocar a região para `us-east-1`**
   (canto superior direito) — CloudFront só enxerga certs dessa região.
2. Procurar o certificado cujo **Domain** seja `cert.fambrashalal.com.br` ou um
   wildcard `*.fambrashalal.com.br`.
3. Verificar:
   - **Status = Issued** (válido).
   - **In use by:** deve referenciar a distribuição do Passo 3.
   - **Domains:** cobre `cert.fambrashalal.com.br`.
4. **Se o cert está nesta conta e Issued → a EcoHalal controla o TLS = reforça Cenário 1 ✅.**

Por CLI:
```powershell
aws acm list-certificates --region us-east-1 `
  --query "CertificateSummaryList[?contains(DomainName, 'fambrashalal')]" --output json
```

### Passo 6 — Conclusão (qual cenário?)
| Achado | Cenário | Próxima ação |
|---|---|---|
| Distribuição **e** ACM nas contas da EcoHalal | **1** | Executar Opção A (seção 6). Nada a pedir à FAMBRAS. |
| DNS aponta p/ CloudFront, mas **não** acha distribuição em nenhuma conta sua | **2** | Identificar o operador (perguntar à FAMBRAS quem hospeda o SysHalal público). Seguir 2a → fallback 2b. |
| DNS **não** é CloudFront | revisar | Mapear topologia real antes de decidir. |

### Passo 7 — Registrar a resposta
Anotar no campo **Pergunta #1** da seção 7 deste doc: conta AWS, ID da
distribuição, ARN do ACM, e o cenário confirmado. Isso destrava o roadmap da
seção 6.
