# ESTADO ATUAL — Ecossistema Halal (GC · SIH · SysHalal)

> **FONTE ÚNICA DA VERDADE.** Retrato **verificado por git em 16/jul/2026 15:43**.
> Handoffs de sessão são **histórico**, não estado (§8). Se este doc e um handoff divergirem, **este vale**.
>
> **Horizonte: go-live FAMBRAS agosto/2026** (~6 semanas).
> Legenda: ✅ feito (com hash) · 🔧 operacional/infra · 🧩 código a fazer · ❓ decisão pendente · 🚧 trilha ativa (não duplicar)

---

## 0. Como usar — LEIA ANTES DE COMEÇAR

**Toda sessão lê este arquivo primeiro.** Depois consulta a spec do seu tema (§8), nunca o contrário.

### As 4 regras que existem porque falharam
1. **"Feito" só vale com hash de commit.** Sem hash, é "em andamento".
   *Por quê:* o handoff de 14/jul afirmava "commitado" — o código estava **solto no working tree** e só foi commitado em 16/jul. O de 13/jul dizia "não deployado" quando já estava em `release`. Handoff relata intenção; git relata fato.
2. **Antes de encerrar a sessão: commite.** WIP não-commitado é trabalho a um `checkout` de sumir. Já aconteceu 2×.
3. **Cada trilha declara os arquivos que toca (§2).** Não edite arquivo de outra trilha. Se precisar, avise no grupo.
4. **Antes de escrever num arquivo, cheque `git status`.** Se houver WIP que não é seu, **pare e pergunte**.
5. **Achou pendência num handoff que não está no §4? ADICIONE ao §4** — não trabalhe fora do mestre.
   *Por quê:* as pendências dos handoffs foram extraídas para o §4 em 16/jul, mas a extração é falível. O banner de "histórico" **não apaga** nada: os arquivos seguem íntegros (§8). Se algo escapou, o conserto é trazer para cá — e não recriar um handoff paralelo. **Este doc só continua sendo a verdade se cada sessão o mantiver.**

### Regras operacionais (valem sempre)
- **`release` = deploy** (push dispara CI/CD). **Pedir OK ao Renato a cada push.**
- **Não iniciar dev server nem tocar `.env.local`** — o Renato sobe local.
- **Renderer/lógica → sem API Gateway. Rota NOVA → regenerar** (swagger + 3 JSONs no MESMO commit).
- **DDL = migration idempotente** com nome MAPEADO da tabela. **Dados/carga = SQL para o Renato rodar no DBeaver** (colar output; nunca presumir resultado).
- **"Revise" = analisar e PARAR.** Não é autorização para executar.
- ⚠️ **Remote não é sempre `origin`:** SIH usa **`ecohalal`**; GC e SysHalal usam `origin`. Auditar com o remote errado dá falso "tudo em dia".

---

## 1. Retrato por repositório — git, 16/jul 15:43

| Repo | Branch | WIP solto | release→base | Último commit |
|---|---|---|---|---|
| **halalsphere-backend** (GC) | `release` | 0 | **3** → develop | 16/jul `49f84b7f` |
| **halalsphere-frontend** (GC) | `release` | 0 | **7** → develop | 16/jul `298a346f` |
| **sih-backend** | `release` | 0 | **4** → development | 13/jul (recuperação de senha) |
| **sih-frontend** | `release` | 0 | **4** → development | 13/jul (telas de senha) |
| **syshalal-api** | 🚩 `carta-correcao-brf-kuwait` | 🚩 **3** | 2 → develop | **30/jun** |
| **syshalal-external-api** | `staging` | 0 | **release 3 atrás de staging** | 06/jul `6d2c2e7` (rotas /integration p/ SIH — staging apenas, NÃO em prod) |
| **syshalal-web** | `release` | 0 | 0 | 22/jun |
| halalsphere-docs | `main` | 0 | — | 16/jul |
| sih-docs | `main` | 0 | — | 16/jul |

🚩 **`syshalal-api` é o ponto de atenção:** parado em branch de feature desde **30/jun** com 3 arquivos soltos (`package.json`, `pnpm-lock.yaml`, template draft `Industrializados_SIS_2020_DRAFT.html`). Tem **8 branches** vivas (4 hotfix + 2 feature). SysHalal é o **único sistema com usuários reais** — WIP solto ali é o de maior risco. **Ação: commitar ou descartar.**

---

## 2. Trilhas ativas — dono e arquivos (ANTI-COLISÃO)

> Duas trilhas **não podem** tocar os mesmos arquivos. Colisão real ocorreu em 16/jul.

| Trilha | Estado | Domínio de arquivos |
|---|---|---|
| **A · Emissão / normas / certificado** (GC) | 🚧 ativa | back: `certificate.service.ts` · `certificate-pdf.service.ts` · `pdf/*-renderer.ts` · `pdf/pdf-protection.ts` · `data/seal-config.ts` · `data/category-display-map.ts` — front: `ManualCertificateEmission.tsx` |
| **B · Normalização de cadastro** (GC) | 🚧 ativa | **dados** (DBeaver): `company_groups` · `companies` · `plants` · `certifications` · `certificates` · `scope_products` · `scope_brands` · `raw_material_*` — código: `/integration/*`, `BulkImportProductsDialog.tsx` |
| **C · Edição de escopo** (GC) | ✅ F1 em prod, aguarda validação | back: `certification-scope.{service,controller}.ts` — front: `ScopeEditor.tsx` · `CertificationDetails.tsx` |
| **D · SIH** | 🧩 aberta | `sih-backend/src/{auth,gc-integration}/` · `sih-frontend/src/pages/{auth,gc-raw-materials}/` |
| **E · SysHalal** | 🚩 WIP solto | `syshalal-api` (ver §1) |

⚠️ **Colisões conhecidas:** `#3 multi-categoria` e `marketScopes` tocam **ambos** `manualEmit` + `ManualCertificateEmission.tsx` → **nunca em paralelo**. `draft→aprovar→travar` conversa com as trilhas **A e C**.

**Bancos (mesmo cluster Aurora — fácil confundir):** `db_ecohalal_halalsphere` = **GC** (DBeaver: `postgres`) · `db_ecohalal_sih` = **SIH** · SysHalal (DBeaver: `HALAL PROD`). Junção GC↔SIH = **`SIF + CNPJ`** (SIH não tem model Company).

---

## 3. 🟥 DESTRAVA JÁ — pronto, esperando 1 ação

1. 🔧 **[SIH] `GC_INTEGRATION_API_KEY` na task def `sih-api-task`** — ⚠️ **PROVAVELMENTE JÁ FEITO (re-verificar antes de executar):** validado em prod em **02/jul** — screenshot Renato `/gc-raw-materials` Rolândia 19/19 aprovados + boot log `Integracao GC configurada` + secret `production.GC_INTEGRATION_API_KEY_SHI_API` criado; revisões :95/:96 (06/jul) herdaram as envs. Item veio de handoff de 28-29/jun. **Checagem de 30s:** CloudWatch log group `/aws/ecs/sih-api-loggroup`, filtro `Integracao` no boot da task atual. Se OK, riscar. **[Renato/AWS]**
2. 🚩 **[SysHalal] Resolver o WIP de `syshalal-api`** — commitar ou descartar (§1). **[Renato decide]**
3. ✅ *(16/jul)* **[GC] Pacote de 16/jul VALIDADO pelo Renato** — `.K.`/normas (número do certificado), PDF protegido, busca por SIF, guard-rail. **Destrava o F3** (§4.2).
4. ✅ *(16/jul)* **Reconciliar `release`→base** — FEITO em GC back+front (`develop`) e SIH back+front (`development`, remote `ecohalal`); todos com `ahead=0`. **Resta só `syshalal-api` (2)** — travado pelo WIP solto do item 2. **[Claude]**
5. 🔧 **Criar 4 usuários FAMBRAS** — GC: Mariana + Elaine · SIH: Karoline (com K) + Osama. **100% destravado, e-mails em mãos.**

---

## 4. Pendente por dono

### 4.1 Renato — validar / infra / operacional
- ✅ *(16/jul)* `CERTIFICATE_PDF_UNLOCK_KEY` na task def do GC.
- 🔧 Validar: `.K.` bovino×aves · OIC/SMIIC **01/2019** · **993** só em abate · PDF protegido (abre livre, não copia, imprime) · busca por SIF · guard-rail (CV+HII bloqueia) · **Edição de escopo F1** (roteiro de 5 passos no handoff 13/jul).
- 🔧 **SIH:** validar recuperação de senha E2E · confirmar **SES fora do sandbox** (se em sandbox, o fluxo quebra em campo) · confirmar migration `20260713120000_password_reset_token` aplicada · validar "Ver PDF" (`d7e9eaa`).
- 🔧 **SIH · espelho GC→SIH (deployado 03-05/jul, NUNCA validado):** abrir planta Rolândia → card do espelho no bloco "Origem da Certificação Halal" (nome canônico + certs vigentes) · badge de cert no destino da transferência. Código: GC `b4337037` + SIH back `0450f78` + SIH front `f76cc8d`, todos em release/prod.
- 🔧 **SysHalal `/integration` (trilha SIH↔SysHalal, spec `SYSHALAL-INTEGRATION-ENDPOINT-SIH-SPEC-2026-07-06`):**
  (i) **SSM staging** `syshalal-external-api-staging.json`: adicionar `SERVICE_API_KEYS` (chave nova p/ o SIH) + `SERVICE_PDF_USER_OWNER/TOKEN` (usuário API do ambiente staging) → **restart do serviço** (configEnv lê SSM só no boot) → passar a chave ao Claude p/ teste;
  (ii) ❓ **destino do `api_sih`** em prod: manter ativo como credencial interna do PDF (sugestão Claude — o download de PDF faz login real no syshalal-api) × criar usuário interno novo · **rotacionar o token** (transitou em texto plano em sessão de 06/jul);
  (iii) rollout prod (após teste staging): SSM prod + merge `staging→release` do syshalal-external-api (staging=`6d2c2e7`) + secret `production.SYSHALAL_INTEGRATION_API_KEY_SIH_API` na task def `sih-api-task`;
  (iv) validação final: buscar **`2607FU7I2`** (grupo ≠ BRF) na UI do SIH → verde; `2607PHJWS` de regressão.
- ⚠️ **Rotacionar a senha do GC (Aurora)** — compartilhada em sessão anterior, em arquivo temp. Pendente desde 10/jul.
- 🔧 Rodar **import IND** em prod (`prisma/import-plantas-ind.ts`, `79b2935`+`91f08fc`) — 23 plantas + vínculos de supervisor.
- 🔧 SQLs de limpeza de teste no DBeaver (4 arquivos em `halalsphere-backend/prisma/`).
- 🔧 `capabilities=processamento` das 4 Seara (admin Lina) — confirmar quais.
- 🔧 Confirmar no console a regra de listener do ALB `/verify/*` (SysHalal QR).
- ❓ Enviar a resposta ao André (4 pontos, todos entregues em 16/jul).

### 4.2 Claude — código
**GC · Trilha A (emissão):**
- ✅ **#3 multi-CATEGORIA — FECHADO (16/jul), nada a fazer.** Decisão: vale o **§5.8** (Clonar manual). O aviso ao operador **já existe** no guard-rail `e1f92785` (`ManualCertificateEmission.tsx`): templates diferentes (7.7.1×7.7.2) **bloqueia** com *"Emita certificados separados usando 'Clonar de um certificado'"*; mesmo template com tipos diferentes **avisa**. O split automático (base `####` por categoria, Minerva 1430×1431) foi **descartado** — é automação, não correção. Se um dia voltar: **não rodar em paralelo com `marketScopes`** (§2).
- 🧩 **`marketScopes` na emissão manual** — não existe no form/DTO; sem ele o PDF usa fallback em vez do catálogo. ❓ depende de FAMBRAS.
- 🧩 **F3 — nº do certificado = nº do CONTRATO** (Lina). ✅ **DESTRAVADO** (16/jul: `.K.` validado — §3.3). É agora o **próximo da Trilha A**. Mexe em numeração: não tocar junto com `.K.`/`marketScopes`.
- 🧩 **F2 — draft→aprovar→travar + audit trail** (ISO 17065). ❓ depende de PO. Toca trilhas A e C.
- ✅ *(16/jul)* **`base-template.renderer.ts` deletado** — `353a0b79` (⚠️ **commit local em `release`, push pendente do OK do Renato**). Zero consumidores confirmado por grep (a classe só aparecia na própria declaração); carregava caminho de `userPassword` e foi a origem da divergência entre renderers.
- 🧩 `main.ts` — último "HalalSphere" interno (Swagger title + log de boot). Baixa.
- ⏸ **Parkeados:** parser xlsx (aguarda arquivo de escopo real da Lina) · emissão assíncrona (rebaixada — o "timeout dos 151" era shadow-copy do OneDrive, não escala) · DSM/IFF cert-de-produto (atrás da digitalização do escopo da indústria).

**GC · Trilha B (normalização):**
- 🧩 **Fallback CNPJ-only no `/integration`** — match GC↔SIH é SIF+CNPJ; planta sem SIF (químico/casing: Kin Master ×2, Minerva Casing) **não casa por definição**. Maior ganho pendente da integração.
- 🧩 Reenriquecer AR/PY/estrangeiras via SysHalal por CUIT/RUC.
- 🧩 Cadastrar no GC: Padoca Maricota + Kin Master Passo Fundo (`…0296`) · merge do dup Kin Master no SIH (**migrar, não deletar** — tem operação).
- 🧩 Lotes MP **N5b** (OUTROS) · **N5c** (GRUPO JBS consolidado) · INTERMEDIÁRIAS — das 28 planilhas FAM-0017 só Rolândia + N5 carregados.
- ⚠️ **Dívida:** os scripts de carga vivem no **scratchpad (efêmero, não versionado)** — as cargas de dado têm número antes/depois, mas **nenhum hash**. Se precisar rastreabilidade, é aqui.

**GC · Trilha C (escopo):** 🧩 **Fase 2** — campos gerais (datas, norma, observações), `industrialCategories` M2M, market scopes. Número segue **travado**.

**GC · FAM-0017:** 🧩 **F4 — FK opcional `ScopeSupplier`/`SupplierHomologation` + RevisionLog** (*prioridade sobre F5/F6* — acreditabilidade ISO 17065) · F5 UI U7 `/homologacao-mp` · F6 import das 29 planilhas · seeds S1 (~40 certificadoras) e S2 (231 intermediários) → DBeaver quando curados.

**SIH:** 🧩 Regenerar swagger das rotas `auth` (já tem `{proxy+}`, não exige resource nova) · 🧩 acoplar MP aprovada à validação de produção/abate (❓ PO) · 🧩 embarque multi-origem **A/B/C** (backend A1 `3114c02` + A2 `47a52dd` já em prod; falta UI N-origens, datas como faixa, vínculo no controlador) · 🧩 NC FM 7.1.6.1 UI · 🧩 catálogo produtos 5A-2 (❓ aguarda .xlsx) · 🧩 destino no PDF de transferência.

**SIH↔SysHalal · integração sem escopo de grupo (código PRONTO, rollout pendente — ver §4.1):**
- ✅ external-api rotas `/integration/{certified,certified_status,certified_pdf}` c/ x-api-key: `25c96a6` (develop `89c6e7e` · staging `6d2c2e7` · **release NÃO — não está em prod**).
- ✅ sih-backend modo dual (`SYSHALAL_INTEGRATION_API_KEY` → /integration; senão legado): `439d4ea` (release, pushado).
- 🧩 [Claude] testes staging quando SSM configurado: certs de **2 grupos** + regressão `/certified` legado (parceiro continua escopado).
- Domínio de arquivos (fora da Trilha D declarada — anti-colisão): `syshalal-external-api/*` · `sih-backend/src/halal-cert/` · `sih-frontend/src/{components/shared/HalalCertField.tsx, services/halal-cert.service.ts}`.

**SIH · QA Nilsa (mai/2026 — o mais stale; confirmar em prod antes de codar):** M2.6/M3.8/M4.13/M5.10/M7.4 (mensagens ausentes) · M11.7 card Supervisores clicável · M11.8 export Analytics · tooltip KPI · sweep de Selects `disabled`→texto plano (só Planta convertida).

### 4.3 FAMBRAS — decisões e entregas
**❓ Decisões de norma (as 3 mais quentes — Soha):**
1. **Mercados nacionais (BPJPH/MUIS/MS) devem derivar GSO?** O alinhamento de 08/jul diz que são baseados em GSO e o sistema **já os trata como GSO** (nomenclatura de categoria + `gsoAuditMode`, *"Default to GSO rules"*) — só a derivação de `standard` não reflete. Se sim, "Sem norma acreditada" quase desaparece.
2. 🚩 **Contradição:** marcar **só UAE.S** → classifica "sem norma acreditada", **mas o PDF imprime o selo ENAS**, que É acreditação.
3. **GSO+OIC juntos → template GCC → só o selo GAC** (o OIC não sai). Coerente com "SMIIC só Turquia" — confirmar.

**❓ Outras decisões:** #3 base por categoria (Minerva 1430×1431) · #9 múltiplos mercados · draft→aprovação existe? · N2b de-para de **14 categorias** · 3 SIFs duplicados (585 FRIGOMARCA×PANTANAL · 4699 LAR×AGROARACA · 2620 FALCAO×BMG) · dedup Hexus×Vidara · REVIEW histórico (7 casos) · overlap couro 7.1.4.5×7.1.4.9 · 5 decisões Fase 5B FAM-0017 (Lina) · certs vencidos-mas-ativos (ex. Gelita).

**📦 Entregas aguardadas:** logos/assinatura em **alta resolução** · lista "certificada desde" · **textos oficiais EN por categoria** (só "K" confirmado) · arquivo de **escopo real** da Lina (destrava o parser xlsx) · .xlsx do catálogo de produtos (destrava 5A-2) · CSVs FM 7.8.1/7.8.2 · certificado real **preenchido** de referência (A2 layout datas EN/AR) · logo Indonésia (Elaine consulta acreditadora) · **aprovar itens de MP** na tela de review (sem isso `approvedOnly=true` volta vazio) · lançar dados reais no FM 20.1 · lista oficial plantas+CNPJ · criticidade halal · códigos reais dos 322 `N5-*` · 16 estrangeiras sem endereço (fonte externa) · Starmilk/Econata (fora do SIGSIF).

---

## 5. Decisões travadas — NÃO re-litigar

**Certificado / layout**
1. **Layout CONGELADO** — fidelidade ao gabarito acreditado; não inovar. Layout novo só após diretoria → Dr. Mohamed → acreditadores.
2. **Selos:** só **GAC, ENAS e OIC/SMIIC** entram. Nacionais (Indonésia/BPJPH, Malásia/JAKIM, Singapura/MUIS, Qatar, Oman, Kuwait, Saudi, IMANOR, Tailândia) **nunca**. *(Allowlist em `seal-config.ts`, `ee23628f`.)*
3. **PDF imutável** — correção = **novo número**. Número **travado** na edição de escopo.
4. **Signatário canônico:** Mohamed Hussein El Zoghbi / Representante Autorizado (`signatory-config.ts`). Nunca inventar.
5. **Cert sempre ABRE sem senha** (autenticidade via QR). Bloqueia-se **cópia**, nunca abertura. `CERTIFICATE_PDF_UNLOCK_KEY` **não é senha de abertura** — é o *owner password*, só destrava restrições.
6. **Bilíngue EN+AR** em 100% dos certs. **Datas date-only = UTC.**
7. **Idioma extra = certificado adicional** separado (não coluna).
8. **Multi-categoria = certificados separados** via Clonar. **Reconfirmado 16/jul** contra o "#3 base por categoria" da reunião de 14/jul: o fluxo é **manual (Clonar)**, não split automático — o #3 foi **rebaixado** (§4.2). Clonar + guard-rail (`e1f92785`) já cobrem o caso.

**Normas (14/jul)**
9. **`.K.` coexiste** com a numeração IT 4.2 · Cert Único = **1 cert por norma-grupo** · **single também leva `.K.`**.
10. Agrupamento por espécie: **bovinos** `.1.`GSO+UAE.S / `.2.`BPJPH+MUIS+MS / `.3.`OIC-SMIIC — **aves** `.1.`UAE.S / `.2.`GSO / `.3.`BPJPH+MUIS / `.4.`MS / `.5.`OIC-SMIIC.
11. **Catálogo `certification_standards_by_market` está CORRETO — NÃO alterar.** A reclamação vinha do fallback.
12. **Taxonomia de categoria:** SMIIC **só** para OIC/SMIIC (Turquia); todo o resto (GSO, BOTH, VOLUNTARY, nacionais) = **GSO**.

**Identidade**
13. **NUNCA "HalalSphere"** visível. Título/remetente = **"Gestão de Certificações"**; identidade = **"Fambras Halal by Ecohalal"**. Marca EcoHalal = **azul `#118add`**.
14. **Cor dos e-mails segue teal** (migração p/ azul = opcional).

**Modelo de dados / arquitetura**
15. `CompanyGroup` = grupo econômico · `Company` = CNPJ da filial · `Plant` = estabelecimento (**1 SIF ↔ 1 CNPJ**, nullable p/ químicos/casing). Unique `(sanitary_code, sanitary_code_type)` está CERTA → **sem migration**. Base DEFINITIVA de cadastro: `C:\HalalSphere\FM78x_atualizados\` (FM 7.8.1 .xlsx + 7.8.2 .xlsb, 25/06) → 652 estabelecimentos (571 BR + 81 estrangeiros).
16. **Cadastro nasce no GC**; SIH **consome** (não cadastra planta). Embarques **permanecem no SysHalal**.
17. **Auditoria por linha obrigatória (ISO 17065)** via `CertificationHistory`; `AuditTrail` genérica dormente. **F4 (RevisionLog) tem prioridade sobre F5/F6.**
18. **Imprimir = `generateAndStore` idempotente** via URL presigned + `window.open` — **nunca XHR→S3** (dá CORS).
19. **Prod do GC tratada como homologação** por ora (FAMBRAS gera sujeira; limpeza depois). Reset final: apagar certs de teste e zerar numeração antes de operar.
20. **M7.4 — NC com relatório-pai: OPCIONAL** (Renato, 22/mai).
21. **Dossiê de exportação** (22/jun): manter o Relatório de Embarque **como está** + construir o Dossiê como **fluxo PARALELO** (rastreabilidade documental completa). O sistema deve **cobrar do supervisor as datas efetivas de abate**.

---

## 6. Divergências doc × git encontradas em 16/jul

> Registradas para justificar a regra do §0.1 — e porque podem se repetir.

| Afirmação do doc | Realidade no git |
|---|---|
| Handoff 14/jul: *"FEITO… commitado no pacote por norma"* | **Não estava.** Solto no working tree por 2 dias; commitado em 16/jul (`827f8adf`, `c396f0a5`). |
| Handoff 13/jul (escopo): *"código pronto, NÃO deployado"* | **Está em `release` e pushado** desde 14/jul (`0f3a9b32`, `a44f9e49`). Falta só validar. |
| SIH: *"`439d4ea` commitado local, SEM push"* | **Está pushado** (`ecohalal/release`). Item fechado. |
| Backlog: WIP do `syshalal-api` na branch `txt_multi_linhas` | Branch **não existe**; o WIP está em `carta-correcao-brf-kuwait`. |
| Backlog 30/jun: *"reconciliação release→develop TODAS feitas"* | Hoje: **3 · 7 · 4 · 4 · 2** pendentes. |
| Backlog 2.1: "front per-Company aberto" × Plano de Ataque: "entregue 28-29/jun" | Contradição interna do próprio doc — **resolver ao tocar FAM-0017**. |
| 7 commits de 16/jul (emissão) | **Nenhum doc os mencionava** antes desta consolidação. |

---

## 7. Entregue em 16/jul (esta consolidação)

**GC — emissão:** guard-rail de categorias por modelo `e1f92785` · selos visíveis na tela em vez do código do template `82a5e2c1` · "Voluntária" → "Sem norma acreditada (GSO/SMIIC)" `2844a9c2` · busca por SIF `298a346f`+`49f84b7f` · PDF com cópia bloqueada, AES-128 `6fed9470` · env renomeada p/ `CERTIFICATE_PDF_UNLOCK_KEY` `9bf9bab0`.
**Recuperados (estavam soltos no working tree):** preset de normas por espécie + SIF na tela `827f8adf` · normas FAMBRAS + `.K.` `c396f0a5`.
**Antes (09/jul):** trava de data `295d274f` · clone typeahead `5de76e6a` · descartar-só-produtos `d5ced92a` · allowlist de selos `ee23628f`.

**Os 4 pontos do André estão fechados** (busca por SIF · guard-rail de categorias · "Voluntária" · templates).

---

## 8. Histórico — handoffs e specs (ponteiro, NÃO verdade)

> ⚠️ Estes arquivos descrevem o momento em que foram escritos. **Vários estão defasados (§6).** Use-os para entender *por que* uma decisão foi tomada — nunca para saber *o que está pronto*.
>
> **Nada foi apagado.** As pendências destes handoffs foram extraídas para o §4 em 16/jul, mas a extração é falível: se você encontrar aqui um item aberto que **não** está no §4, **traga-o para o §4** (regra §0.5). O banner marca "não é estado" — não "não leia".

**Specs (referência técnica — continuam válidas):** `SPEC-EMISSAO-MULTI-CERT-NORMAS-GC-2026-07-14` · `CATEGORIA-POR-NORMA-PICKER-EMISSAO-GC-SPEC-2026-07-08` · `SPEC-EMISSAO-MANUAL-CERTIFICADO-2026-07-06` · `REGRAS-NORMAS-POR-DT-MERCADO-2026-07-06` · `REFERENCIA-TEMPLATES-CERTIFICADO-2026-07-06` · `NORMALIZACAO-CADASTROS-PLANO-MESTRE-2026-07-10` (Anexo A tem os SQL de diagnóstico) · `SYSHALAL-INTEGRATION-ENDPOINT-SIH-SPEC-2026-07-06` (sih-docs).

**Handoffs (histórico):** halalsphere-docs `HANDOFF-SESSAO-2026-07-{08,13,14}` · `HANDOFF-NORMALIZACAO-2026-07-{10,12}` · `EDICAO-ESCOPO-CERTIFICADO-FASE1-HANDOFF-2026-07-13` · `HANDOFF-EMISSAO-MANUAL-2026-07-07` · `HANDOFF-SEED-GC-2026-07-{02}` — sih-docs `HANDOFF-SESSAO-2026-07-14` · `RECUPERACAO-SENHA-SIH-HANDOFF-2026-07-13`.

**Fontes externas (fora de git):** transcrições em `C:\HalalSphere\Alinhamentos de validação\` · gabaritos em `C:\HalalSphere\Gabaritos atualizados\` · `C:\HalalSphere\FM78x_atualizados\` · docx contratuais em `C:\SIH\`.
