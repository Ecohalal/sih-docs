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
| **halalsphere-backend** (GC) | `release` | 0 | **0** ✅ *(17/jul)* | 17/jul `853ed242` |
| **halalsphere-frontend** (GC) | `release` | 0 | **7** → develop | 16/jul `298a346f` |
| **sih-backend** | `release` | 0 | **0** ✅ *(22/jul)* | 22/jul `94fbe96` (pushado, dev `cba9e66`) — Bloco C fechado |
| **sih-frontend** | `release` | 0 | **0** ✅ *(22/jul)* | 22/jul `39b36fc` (pushado, dev `ff8ed51`) — usabilidade Nilsa A/B/C/F |
| **syshalal-api** | `release` ✅ *(22/jul)* | 0 ✅ *(22/jul)* | 0 | `160a16c` (PR #381 carta-correção mergeada) |
| **syshalal-external-api** | `staging` | 0 | **release 3 atrás de staging** | 06/jul `6d2c2e7` (rotas /integration p/ SIH — staging apenas, NÃO em prod) |
| **syshalal-web** | `release` | 0 | 0 | 22/jun |
| halalsphere-docs | `main` | 0 | — | 16/jul |
| sih-docs | `main` | 0 ✅ *(17/jul)* | — | 17/jul `f4223ca` |

✅ **`syshalal-api` — RESOLVIDO em 22/jul (era alarme falso na substância).** A investigação por git provou que o WIP não tinha **nenhum código de produção**: os 3 tracked modificados eram (a) o template `Industrializados_SIS_2020_DRAFT.html` **byte-idêntico ao `origin/release`** — re-aplicava à mão o fix dos portos que já estava em prod desde 23/jun (`f711d10`); (b) `puppeteer` em `package.json`/`pnpm-lock`, usado **só** pelos scripts soltos (nenhum `src/` importa). Os untracked eram 5 scripts de simulação (mai/jun, backup em scratchpad) + `output/` = **184 MB de PDF gerado**. **Ação executada [Claude]:** restaurados os 3 tracked, removidos scripts+output, `checkout release` + fast-forward → **árvore limpa, 0/0**. Descoberta de bônus: a branch `carta-correcao-brf-kuwait` **já fora mergeada em prod** via PR #381 (`160a16c`) — o trabalho estava no ar, não só "salvo". *(Lição: "WIP solto = maior risco" era hipótese; git desmentiu. Ainda restam ~8 branches locais stale — higiene, não risco.)*

---

## 2. Trilhas ativas — dono e arquivos (ANTI-COLISÃO)

> Duas trilhas **não podem** tocar os mesmos arquivos. Colisão real ocorreu em 16/jul.

| Trilha | Estado | Domínio de arquivos |
|---|---|---|
| **A · Emissão / normas / certificado** (GC) | 🚧 ativa | back: `certificate.service.ts` · `certificate-pdf.service.ts` · `pdf/*-renderer.ts` · `pdf/pdf-protection.ts` · `data/seal-config.ts` · `data/category-display-map.ts` — front: `ManualCertificateEmission.tsx` |
| **B · Normalização de cadastro** (GC) | 🚧 ativa | **dados** (DBeaver): `company_groups` · `companies` · `plants` · `certifications` · `certificates` · `scope_products` · `scope_brands` · `raw_material_*` — código: `/integration/*`, `BulkImportProductsDialog.tsx`, `CompanyCombobox.tsx` |
| **C · Edição de escopo** (GC) | ✅ F1 em prod, aguarda validação | back: `certification-scope.{service,controller}.ts` — front: `ScopeEditor.tsx` · `CertificationDetails.tsx` |
| **D · SIH** | 🧩 aberta | `sih-backend/src/{auth,gc-integration}/` · `sih-frontend/src/pages/{auth,gc-raw-materials}/` |
| **E · SysHalal** | 🚩 WIP solto | `syshalal-api` (ver §1) |

⚠️ **Colisões conhecidas:** `#3 multi-categoria` e `marketScopes` tocam **ambos** `manualEmit` + `ManualCertificateEmission.tsx` → **nunca em paralelo**. `draft→aprovar→travar` conversa com as trilhas **A e C**.

**Bancos (mesmo cluster Aurora — fácil confundir):** `db_ecohalal_halalsphere` = **GC** (DBeaver: `postgres`) · `db_ecohalal_sih` = **SIH** · SysHalal (DBeaver: `HALAL PROD`). Junção GC↔SIH = **`SIF + CNPJ`** (SIH não tem model Company).

🕳️ **Buraco do §2 (achado 17/jul):** as tabelas de dados estão declaradas só sob a **Trilha B (GC)** — **o banco do SIH (`db_ecohalal_sih`) não pertence a nenhuma trilha**. Em 17/jul a Trilha B escreveu em `db_ecohalal_sih.plants` (5 linhas: 3 chaves completadas + Minerva Casing + Ecotrace) **com OK do Renato**, mas sem domínio declarado. **Definir o dono** antes da próxima escrita — candidato natural: Trilha D (SIH), já que o código do SIH é dela.

---

## 3. 🟥 DESTRAVA JÁ — pronto, esperando 1 ação

1. ✅ *(22/jul)* **[SIH] `GC_INTEGRATION_API_KEY` na task def `sih-api-task` — CONFIRMADO FEITO pelo Renato.** (Já vinha validado em prod em 02/jul — `/gc-raw-materials` Rolândia 19/19 + boot log `Integracao GC configurada` + secret `production.GC_INTEGRATION_API_KEY_SHI_API`; revisões :95/:96 herdaram as envs. Renato confirmou em 22/jul.)
2. ✅ *(22/jul)* **[SysHalal] WIP de `syshalal-api` RESOLVIDO** — investigado, descartado (zero-loss, era ferramentaria + 184 MB de PDF gerado; nenhum código de prod), repo em `release` limpo. A feature já estava em prod (PR #381). Detalhe no §1.
3. ✅ *(16/jul)* **[GC] Pacote de 16/jul VALIDADO pelo Renato** — `.K.`/normas (número do certificado), PDF protegido, busca por SIF, guard-rail. **Destrava o F3** (§4.2).
4. ✅ *(16/jul)* **Reconciliar `release`→base** — FEITO em GC back+front (`develop`) e SIH back+front (`development`, remote `ecohalal`); todos com `ahead=0`. **Resta só `syshalal-api` (2)** — travado pelo WIP solto do item 2. **[Claude]**
5. ✅ *(22/jul)* **Criar 4 usuários FAMBRAS — CRIADOS E ATIVOS** (Renato). GC: Mariana + Elaine · SIH: Karoline + Osama.

---

## 4. Pendente por dono

### 4.1 Renato — validar / infra / operacional
- ✅ *(16/jul)* `CERTIFICATE_PDF_UNLOCK_KEY` na task def do GC.
- 🔧 Validar: `.K.` bovino×aves · OIC/SMIIC **01/2019** · **993** só em abate · PDF protegido (abre livre, não copia, imprime) · busca por SIF · guard-rail (CV+HII bloqueia) · **Edição de escopo F1** (roteiro de 5 passos no handoff 13/jul) · **filtro de empresa em `/homologacao-mp`** — selecionar empresa → o **X limpa** → digitar outra → troca (`160b2cdd`; era o bug do filtro "Diana Food": o `[&_svg]:pointer-events-none` do Button engolia o clique no X).
- 🔧 **SIH:** validar recuperação de senha E2E · ✅ *(16/jul)* **SES fora do sandbox — CONFIRMADO pelo Renato** (era o risco de quebrar o fluxo em campo; item fechado) · confirmar migration `20260713120000_password_reset_token` aplicada · validar "Ver PDF" (`d7e9eaa`).
- 🔧 **SIH · espelho GC→SIH (deployado 03-05/jul, NUNCA validado):** abrir planta Rolândia → card do espelho no bloco "Origem da Certificação Halal" (nome canônico + certs vigentes) · badge de cert no destino da transferência. Código: GC `b4337037` + SIH back `0450f78` + SIH front `f76cc8d`, todos em release/prod.
- 🔧 **SysHalal `/integration` (trilha SIH↔SysHalal, spec `SYSHALAL-INTEGRATION-ENDPOINT-SIH-SPEC-2026-07-06`):**
  (i) **SSM staging** `syshalal-external-api-staging.json`: adicionar `SERVICE_API_KEYS` (chave nova p/ o SIH) + `SERVICE_PDF_USER_OWNER/TOKEN` (usuário API do ambiente staging) → **restart do serviço** (configEnv lê SSM só no boot) → passar a chave ao Claude p/ teste;
  (ii) ❓ **destino do `api_sih`** em prod: manter ativo como credencial interna do PDF (sugestão Claude — o download de PDF faz login real no syshalal-api) × criar usuário interno novo · **rotacionar o token** (transitou em texto plano em sessão de 06/jul);
  (iii) rollout prod (após teste staging): SSM prod + merge `staging→release` do syshalal-external-api (staging=`6d2c2e7`) + secret `production.SYSHALAL_INTEGRATION_API_KEY_SIH_API` na task def `sih-api-task`;
  (iv) validação final: buscar **`2607FU7I2`** (grupo ≠ BRF) na UI do SIH → verde; `2607PHJWS` de regressão.
- ⚠️📅 **Rotacionar as senhas GC + SIH (Aurora) — AGENDADO pelo Renato p/ 25/jul.** GC (`db_ecohalal_halalsphere`) pendente desde 10/jul; SIH (`db_ecohalal_sih`, user `db_ecohalal_sih_user`, mesmo cluster) desde 17/jul. Ambas transitaram em texto plano em arquivo temp/scratchpad (`db-conn-sih.json`) no cruzamento GC↔SIH.
- 🔧 **Cadastros do SIH pendentes** *(levantados no diagnóstico de 20/jul, cruzando `db_ecohalal_sih`)*:
  - **Criar o supervisor Ziad Mansour** — assina os FM da BRF Dourados (doc. `V444820C`) e não existe na base. Precisa ser pela UI (hash bcrypt) + vincular à planta. **PENDENTE.**
  - 🔧 **Haitham Mohamed** — supervisor IND **sem nenhuma planta vinculada**: ao logar vê dropdown vazio. **[Renato] vincular ou inativar** (não toquei — é decisão).
  - ✅ *(22/jul, DADO em prod)* **`division` dos supervisores preenchida:** Mussa Mustafa → **IN** · Sameh Kamal → **IN** · Vinicius (Jamal) → **IND**. **"Vitor Sup." (`vitor.franco@sih.com`) INATIVADO** — era conta de teste (38 plantas), confirmado pelo Renato. Resultado: **nenhum supervisor ativo com `division` NULL** → o filtro `7bc4768` passa a recortar corretamente para todos. Script em `scratchpad/fix-supervisores.js` (transação, antes/depois).
- 🔧 Rodar **import IND** em prod (`prisma/import-plantas-ind.ts`, `79b2935`+`91f08fc`) — 23 plantas + vínculos de supervisor.
- 🔧 SQLs de limpeza de teste no DBeaver (4 arquivos em `halalsphere-backend/prisma/`).
- 🔧 `capabilities=processamento` das 4 Seara (admin Lina) — confirmar quais.
- 🔧 Confirmar no console a regra de listener do ALB `/verify/*` (SysHalal QR).
- ❓ Enviar a resposta ao André (4 pontos, todos entregues em 16/jul).

### 4.2 Claude — código
**GC · Trilha A (emissão):**
- ✅ **#3 multi-CATEGORIA — FECHADO (16/jul), nada a fazer.** Decisão: vale o **§5.8** (Clonar manual). O aviso ao operador **já existe** no guard-rail `e1f92785` (`ManualCertificateEmission.tsx`): templates diferentes (7.7.1×7.7.2) **bloqueia** com *"Emita certificados separados usando 'Clonar de um certificado'"*; mesmo template com tipos diferentes **avisa**. O split automático (base `####` por categoria, Minerva 1430×1431) foi **descartado** — é automação, não correção. Se um dia voltar: **não rodar em paralelo com `marketScopes`** (§2).
- ✅ *(16/jul)* **#9 `marketScopes` na emissão manual — FEITO ponta a ponta** (decisão do Renato de seguir). Seção 6 "Emissão e mercados" ganhou **Mercados de destino**; marcar destinos grava `MarketScope(país × normas do grupo)` → `extractRequirements` passa a resolver as normas pelo **CATÁLOGO** (FM 4.1.X, §5.11) em vez do fallback genérico. Ex.: **Indonésia** lista 8 normas; **Brasil (Mercado Interno)** sai **só com a DT** (antes imprimia norma indevidamente).
  - Hashes: back `847006e6` (DTO + persistência) + `d2ec0623` (blindagem `@IsIn`, ISO2 inválido virava 500) · front `ea8e76fa`. **Pushados em `release`.**
  - **Sem destino marcado = comportamento atual** (fallback) → zero regressão.
  - 🚩 **Gap conhecido:** só os **12 países com mapeamento 1:1 verificado** (BR, SA, AE, BH, KW, OM, QA, YE, ID, MY, SG, TR). Os agrupamentos **"Demais países da <região>"** (Américas/Europa/África/Ásia/Oceania) **ficaram de fora** — exigem seletor de país completo; não foi chutado país "representante" (seria dado errado no `MarketScope`). Ao adicionar, estender também o `@IsIn` do DTO.
  - 🔧 **[Renato] Validar:** emitir cert marcando **Indonésia** (deve listar as 8 normas) e outro marcando **Brasil** (deve sair só a DT).
- ❓ **F3 — nº do certificado = nº do CONTRATO** (Lina). Sequenciamento destravado (`.K.` validado, §3.3), **mas o requisito não fecha** — escopado em 16/jul:
  - `Contract.contractNumber` **existe** (unique, FK `certificationId`) e o schema diz *"mesmo número da proposta aceita (**IT 4.2**)"* → encaixa com o `.K.` (base = nº do contrato + `.K.` da norma = padrão Minerva `1430.1`/`1430.2`).
  - 🚩 **Bloqueio 1:** a **emissão manual não tem contrato** (cria `Certification` synthetic pulando proposta→contrato) → sem fonte para o número. Operador digita? Passa a exigir contrato?
  - 🚩 **Bloqueio 2:** Minerva teve **2 bases (1430 × 1431) para 2 categorias**. Se base = nº do contrato, são **2 contratos**? Ou 1 contrato com base por categoria?
  - ⇒ **Perguntar à Lina/FAMBRAS antes de codar.** Mexe em numeração: não tocar junto com `.K.`/`marketScopes`.
- 🧩 **F2 — draft→aprovar→travar + audit trail** (ISO 17065). ❓ depende de PO. Toca trilhas A e C.
- ✅ *(16/jul)* **`base-template.renderer.ts` deletado** — `353a0b79`. Zero consumidores confirmado por grep (a classe só aparecia na própria declaração); carregava caminho de `userPassword` e foi a origem da divergência entre renderers. ⚠️ *(corrigido 17/jul — §6)*: o doc dizia "commit local, push pendente do OK"; **já estava em `origin/release`** (`git branch -r --contains` confirma) e agora também em `origin/develop` pela reconciliação. Mais uma de doc-relata-intenção × git-relata-fato.
- 🧩 `main.ts` — último "HalalSphere" interno (Swagger title + log de boot). Baixa.
- ⏸ **Parkeados:** parser xlsx (aguarda arquivo de escopo real da Lina) · emissão assíncrona (rebaixada — o "timeout dos 151" era shadow-copy do OneDrive, não escala) · DSM/IFF cert-de-produto (atrás da digitalização do escopo da indústria).

**GC · Trilha A — 🎯 KERNEL DE NORMAS + backlog de emissão (reunião 20/jul + testes Giovanna/William + WhatsApp Soha 22/jul).**
> Arquitetura completa: **`halalsphere-docs/ARCHITECTURE/ADR-KERNEL-NORMAS-CERTIFICADO-2026-07-22`** (§8). Decisão travada = **§5.22**. **Nada codado — zero hash.**

_Raiz (stress-test + inventário 22/jul):_ o `Certificate` **não persiste as normas resolvidas** — o PDF re-resolve ao vivo (`certificate-pdf.service.ts:685-737`), lendo catálogo + `category-display-map` (que vaza o rótulo `2055-2` para a linha de norma). É o bug do 2055 **e** uma violação de imutabilidade ISO 17065 já hoje.

- 🧩 **Fatia 0** — `resolved_scope_snapshot` no `Certificate`; cert emitido lê só do snapshot, nunca re-resolve. **Mata a classe do bug + entrega imutabilidade ISO** (independente da matriz). Backfill na janela "prod=homologação".
- 🧩 **Fatia 1** — matriz `certification_standards_by_market` vira **produtor único** da linha de norma; deletar os 2 fallbacks duplicados (`certificate.service.ts:889-906` = `certificate-pdf.service.ts:714-729`); `notes` texto-livre → colunas tipadas; unificar catálogo de país (totalidade, sem `[]` silencioso); guard-rail de normas conflitantes (W11).
- 🧩 **Fatia 2** — effective-dating por norma + provenance (`approved_by`/`source_doc_ref`/`effective_from`) + pin da versão na `Certification` no gate da **auditoria**; tabela **ingrediente restrito × mercado** + flag do operador (long-term via FAM-0017).

_Backlog de emissão (bugs dos testers — render/split, correm em paralelo ao kernel):_
- [ ] **W2/#1** GSO sai `2055-2` na linha de norma (deveria `2055-1`+`993`) — o vazamento; selo GAC mantém `2055-2:2021` (correto). [Fatia 1]
- [ ] **W1** UAE.S classificado "sem norma acreditada" — corrigir (imprime ENAS = é acreditada). [Fatia 1]
- [ ] **G1/W17** Products/Scope: sai só a subcategoria, em PT; deve ser `CATEGORY <G> – <nome>/ SUBCATEGORY <cód> – <nome>` + facility + BRANDS, em **EN** (bloqueado pelos textos EN por categoria, §4.3). [Fatia 1]
- [ ] **G5/W6** Split de norma bugado nos 2 sentidos: "vários por grupo" gera Indonésia+SMIIC não pedidos (G5); habilitação c/ +1 norma sai tudo num arquivo (W6). Frigorífico=split, industrial=único. [bounded context numeração]
- [ ] **W11** 🎯 **trava de normas conflitantes** = enforcement de `mercado ⊆ base ∩ ingrediente ∩ auditor ∩ habilitação` + aviso. [Fatia 1]
- [ ] **W7** picklist de produto conforme FM 7.2.1.2/7.2.1.3 ("ticar" válidos) — em vez de texto livre. Conecta parser xlsx/escopo real.
- [ ] **W15** possível emitir aves só desossa OU só abate — validação de escopo faltando.
- [ ] **W4/W5/W3** seção "6. Emissão e mercados" não auto-seleciona normas ao escolher mercado (W4); "10. Ajustes Avançados" não auto-seleciona DTs (W5); sugestão subir a seção 6 (W3).
- [ ] **G2/W14** marca não centralizada (G2) / não aparece na habilitação (W14). **G4/W8** datas+número desalinhados. **W9** caps só na unidade. **W10** Estado/País como sigla (deveria por extenso). [render — vários rápidos]
- [ ] **Fuad `.1.` — RESOLVIDO por evidência:** cert real mostra `.1.` legítimo em **frigorífico** (índice de grupo `ABC.SIG.ANOMES.SEQQ.NORMA.PAIS`); o bug é `.1.` em **industrial único** (CP Kelco). Não re-perguntar.

**GC · Trilha B (normalização):**
- ✅ *(17/jul)* **Fallback CNPJ-only — FEITO nas DUAS pontas.** Planta sem SIF (químico/casing: Kin Master ×2, Minerva Casing = `NAO_APLICAVEL`) não casava por definição; agora casa por CNPJ.
  - **GC** `853ed242` (**pushado** em `release`, CI/CD disparado): `resolvePlant` — com SIF mantém SIF+CNPJ e devolve null se não casar (**divergência real não se mascara**); sem SIF cai para CNPJ **só se INEQUÍVOCO** (2+ plantas sem SIF no mesmo CNPJ → null, não chuta). Beneficia os 2 endpoints (`raw-materials/by-plant` + `plant-summary`). Rota existente → **sem regen de API GW**.
  - **SIH** `6daeff9` (**pushado** em `ecohalal/release`) — Trilha D tocada com OK do Renato (§0.3): o guard exigia `sanitaryCode` E `cnpj` e **derrubava a chamada dentro do SIH**, antes de sair; agora só CNPJ é obrigatório e o SIF vai vazio.
  - Reconciliado release→base: GC `a8f375b4` (develop) · SIH `0e42e70` (development) → **ahead=0** (§1, §3.4).
  - Validado contra prod: Kin Master e Minerva Casing resolvem 1:1; Rolândia (com SIF) não entra no fallback = **zero regressão**. tsc ok nos 2 repos.
  - 🔧 **[Renato] Validar pós-deploy:** abrir Kin Master/Minerva Casing no SIH → espelho e MP devem aparecer (antes davam "falta SIF e CNPJ").
- ✅ *(12/jul)* **Fix do import de produtos** — `BulkImportProductsDialog` (`parseAoa`/`parseCsv`) assumia ordem posicional sem cabeçalho e gravava a coluna "Nº" como nome (origem dos produtos numéricos). Agora **exige o cabeçalho do modelo** (sem ele: erro claro + 0 linhas, Aplicar desabilitado), **rejeita nome numérico** e tem **cap de 500** linhas. `3c620550` (release) + reconciliado develop `2a53b7ad`. *(não constava no §4 — trazido pela regra §0.5)*
- ✅ *(12/jul)* **Correções de dado no SIH** (`db_ecohalal_sih.plants`, sem hash — é dado): 3 chaves completadas **a partir do GC master** (BRF Nova Mutum +CNPJ `01838723049487` · Minerva Jose Bonifacio +CNPJ `67620377000386` · Curtume Jangadas +SIF `3471`) → **31→34 de 39** casando · **Minerva Casing**: removido **SIF 451 ERRADO** (451 é da Minerva principal `…0386`) · **Ecotrace Teste**: `isActive=false` (**tinha 1 registro → desativada, não deletada**).
- 🧩 Reenriquecer AR/PY/estrangeiras via SysHalal por CUIT/RUC.
- 🧩 Cadastrar no GC: Padoca Maricota + Kin Master Passo Fundo (`…0296`) · merge do dup Kin Master no SIH (**migrar, não deletar** — tem operação: 1 relatório + 1 origem-MP).
- 🧩 Lotes MP **N5b** (OUTROS) · **N5c** (GRUPO JBS consolidado) · INTERMEDIÁRIAS — das 28 planilhas FAM-0017 só Rolândia + N5 carregados.
- ❓ **`scope_brands`: rebuild total (opção b)?** O parse extrai 6.356 marcas mas com **ruído** — o 4º campo do FM é "comercial×marca" ambíguo (ADM = 21 nomes-de-produto × Forno de Minas = 6 marcas reais). Feito só o mínimo (opção c): 12 numéricas apagadas + 109 scopes do seed populados + 7 listas multi-marca splitadas → 2.699. **Rebuild total injetaria ~4 mil nomes-de-produto como marca** → decisão do Renato.
- 🧩 **`_ScopeProductBrands` (marca por produto) está VAZIO** — só há marca por escopo; produto↔marca nunca foi linkado.
- 🧩 **Badge UI da flag "validado FAMBRAS"** = `approved_by_id IS NOT NULL` nos `raw_material_masters` (hoje é derivável, não visível). Baixa.
- ⚠️ **Dívida:** os scripts de carga vivem no **scratchpad (efêmero, não versionado)** — as cargas de dado têm número antes/depois, mas **nenhum hash**. Se precisar rastreabilidade, é aqui.

**GC · Trilha C (escopo):** 🧩 **Fase 2** — campos gerais (datas, norma, observações), `industrialCategories` M2M, ~~market scopes~~. Número segue **travado**.
- 🚩 **REESCOPAR ANTES DE INICIAR (16/jul):** *market scopes* saiu do pacote da Fase 2 — a **Trilha A já entregou `marketScopes`** no lado da emissão (`847006e6` + `d2ec0623` + `ea8e76fa`, §4.2/A #9). E `marketScopes` toca `manualEmit` + `ManualCertificateEmission.tsx` = **domínio da Trilha A**, que o §2 marca como "nunca em paralelo". Se a Fase 2 precisar editar `MarketScope` de um certificado já existente, definir antes **de quem é o arquivo** — senão colide.
- ⚠️ **F2 (draft→aprovar→travar)** do bloco da Trilha A declara que "toca trilhas A e C" → quando andar, coordenar; não iniciar em paralelo.

**GC · FAM-0017:** 🧩 **F4 — FK opcional `ScopeSupplier`/`SupplierHomologation` + RevisionLog** (*prioridade sobre F5/F6* — acreditabilidade ISO 17065) · F5 UI U7 `/homologacao-mp` · F6 import das 29 planilhas · seeds S1 (~40 certificadoras) e S2 (231 intermediários) → DBeaver quando curados.
- 🧩 **Validade/vencimento do certificado de MP visível + alerta ao analista** — *(reunião 30/jun, Soha; trazido ao §4 em 17/jul pela §0.5)*. A **auditoria interna pegou certificados de MP vencidos passando** pelo analista: mostrar a validade na listagem e avisar quando vencido. ⚠️ **≠** do "certs vencidos-mas-ativos (Gelita)" do §4.3 — aquele é **cert de habilitação**, este é **cert de matéria-prima**.
- 🧩 **Subir no menu a tela de busca do catálogo global de MP** — busca por produto/fornecedor + vínculos + documentos/avaliações anexados. A tela **existe**, só não está exposta no menu. Baixa. *(§0.5, 30/jun)*

**SIH:** 🧩 Regenerar swagger das rotas `auth` (já tem `{proxy+}`, não exige resource nova) · 🧩 acoplar MP aprovada à validação de produção/abate (❓ PO — **desenho fechado no bloco abaixo**) · 🧩 embarque multi-origem **A/B/C** (backend A1 `3114c02` + A2 `47a52dd` já em prod; falta UI N-origens, datas como faixa, vínculo no controlador) · 🧩 NC FM 7.1.6.1 UI · 🧩 catálogo produtos 5A-2 (❓ aguarda .xlsx) · 🧩 destino no PDF de transferência.

**SIH · Conformidade FM (hands-on 17/jul + FM oficiais preenchidos recebidos em 20/jul).** Spec: `SPEC-CONFORMIDADE-FM-SIH-2026-07-20` (§8). Cruzamento campo a campo dos FM 7.1.4.1, 7.1.4.2, 7.1.7.1 e 7.1.7.4 contra o código.
- ✅ *(21/jul)* 🟥 **P0 — C/NC de AVES saía no item ERRADO no PDF assinado.** As listas de verificação viviam duplicadas (12 itens no front × 13 no PDF) e o valor era casado por **índice posicional**; em aves elas divergiam, então o documento atestava item diferente do marcado. `SLAUGHTER_FM` virou fonte única servida por `/fm-metadata/slaughter/*` (padrão que produção e embarque já usavam — o abate era a exceção), e o PDF passou a imprimir o **rótulo gravado no relatório**, para que um documento assinado mostre o que foi atestado mesmo se o FM mudar. Back `9c3ec7f` · front `16afce7`. **Atingiu 2 relatórios em prod — os dois preenchidos ao vivo na reunião de 17/jul; nenhum de operação real.**
- ✅ *(21/jul)* **P1:** observações passam a ser impressas (**6 templates** — o bloco só desenhava o rótulo) · **linha TOTAL** na tabela de produtos do embarque (tela + PDF) · **documento sanitário obrigatório** para assinar embarque (CSI/CSN/DCPOA — o FM manda em caixa alta e nada checava) · **tempo de retorno em `m:ss`** (com `type=number` o `1:04` da reunião virou `104`) · "Natureza dos volumes"/"Nº de volumes" com datalist (1.450 caixas foram lançadas como kg) · `halalCertData`/`halalCertSource` **persistidos** (o front enviava, o Zod descartava e o dado se perdia). Back `f77bb97` · front `b57a5b0`.
- ✅ *(21/jul)* **Bloco A — decisões do Renato aplicadas.** "Aprovados" virou **derivado** (`total − rejeitados`, read-only; das 5 validações de coerência restaram 2) · os **2 relatórios de aves de teste foram removidos de prod** · "Nº do Pedido" saiu da tela (no FM o campo é "pedido / NF", não dado próprio; coluna preservada e o PDF compõe) · **turno exibido como no FM** ("1º/2º/3º Turno" — trocamos o **rótulo**, não o valor, porque `Shift` também alimenta escala e analytics; 3 listas locais eliminadas) · **nº de série Halal GERADO** no formato `SIF/ANO/000000`, só quando o supervisor não informa, partindo do **maior emitido** e não de `count()` · **FM 7.1.7.11 criado** (enum + migration idempotente + metadata + labels + perfil). Back `50bd589`+`878678d` · front `d1feabc`+`beba85e`. Corrigida de passagem uma duplicação no PDF de exportação (invoice impresso 2×).
- ✅ *(21/jul)* **FM 7.1.7.11 conferido contra o documento oficial** (o Renato localizou um preenchido: BRF Dourados→Concórdia, 26/05/2026). Ele **desmentiu 3 inferências** que eu fizera a partir do 7.1.7.3: data da revisão (**06/07/2020**), título (**"EXCLUSIVO ENTRE BRF"**) e as verificações C/NC, que são **próprias**. Tabela bem mais enxuta e **sem campo de nº de série**.
- 🚩 **Achado para a FAMBRAS:** no FM 7.1.7.11 a coluna se chama *"Quantidade por produto (**kg**)"* mas a planta preenche **caixas** (479/201/770 → TOTAL 1450, peso total 37.800,000 à parte). **O rótulo do formulário está errado, não o supervisor** — foi o que o André identificou ao vivo na reunião.
- 🔧 **[Renato] Validar:** PDF de abate de aves com os 13 itens na ordem do FM · observações saindo no PDF · linha TOTAL · tentativa de assinar embarque **sem** anexo sanitário deve bloquear · tempo de retorno aceitando `0:40` · **"Aprovados" calculando sozinho** · **turno saindo como "1º Turno"** · **nº de série gerado** (`4567/2026/000001`) · **FM 7.1.7.11 na lista de tipos** · rodar o `VALIDATE.sql` da migration `20260721120000_add_transferencia_brf_7_1_7_11`.
- ❓ **[FAMBRAS] 3 pontos abertos do Bloco A:** a **nota fiscal** também bloqueia a assinatura (hoje só o documento sanitário)? · a sequência do nº de série deve **contar o 7.1.7.11**, que não tem o campo? · falta um **FM 7.1.7.3 preenchido** — único dos cinco sem documento oficial em mãos.
- ✅ *(21/jul, EM PROD)* **Bloco B — fecha a Onda 2 do embarque.** Endereço de carregamento **sincroniza** ao trocar a planta (antes só preenchia se vazio — era o "Passo Fundo" da reunião) · `products` deixa de ser `z.any()` e **assinar com produto sem nome passa a ser bloqueado** · campo **"Detalhe do produto"** por item (metade do pedido do André: o nome ainda é livre porque o GC não expõe escopo) · datas como faixa **já existiam**. Back `b071b75` · front `9fc4aac`.
- 🚧 **Bloco C — COMMITADO, NÃO PUSHADO** (back `93a3ae5` + `46e7c42` · front `c36ce0d`). ⚠️ **Tem migration** `20260721160000_system_user_document` + **duas travas novas** de assinatura. Conferido no banco antes: produto-sem-nome não afeta rascunho nenhum; C/NC-incompleta bloqueia **1 rascunho**, o da planta Ecotrace Teste (desativada).
  - **C1** `SystemUser.document` (RG/CPF/passaporte): o FM exige o número na declaração assinada (*"portador do documento V444820C"*) e o SIH não tinha onde guardar. O PDF do abate reusava `slaughtererDoc` (do **degolador**, sem input desde que virou item de equipe) e o do embarque lia `report.supervisorDoc` — **campo que não existe no modelo**. Ambos saíam sempre em branco.
  - **C2** "Nome do Supervisor" no cabeçalho passa a ser **quem assinou**, não quem criou.
  - **C3** marcar NC exibe o gancho normativo do FM (*"preencher o check list FM 7.1.6.1"*) com link direto — o sistema não dizia isso em lugar nenhum.
  - **C4** assinar exige **verificação C/NC completa** (abate, produção, embarque). Dava para assinar com todos os itens `null` e o PDF saía com a coluna vazia — insustentável na ISO 17065.
  - ✅ *(21/jul)* **Bloco C fechado** — back `94fbe96` · front `31f1a8a`: horário também na insensibilização **bovina** (a nota do FM pede duas verificações "em horários alternados") · **`Registro SIH: <serial>` no cabeçalho de TODOS os PDFs** (aparecia só na tela; o impresso não podia ser reconciliado com o registro) · **`rejectedSequence` impresso também em aves** (a tela sempre ofereceu, só o bovino imprimia — o dado sumia do documento). 🧩 Resta só a coerência `formNumber`×espécie, baixa.
  - ℹ️ `46e7c42` é **commit à parte**: versiona 5 scripts de junho que estavam soltos no working tree (cargas JBS Couros/Acquion/BFB já executadas + 2 `VALIDATE.sql`). Descartável sem afetar o Bloco C.
- 📋 **Próximo bloco: importar a planilha `FRIGORÍFICOS DIVERSOS FUNCIONÁRIOS ALI CHAHINE.xlsx`** (`C:\SIH\`, fora de git). Cruzada com os 2 bancos em 21/jul: **92 plantas existem no GC e faltam no SIH** (hoje a carteira IN tem só 3 ativas — era a causa do dropdown vazio na reunião) · **46 supervisores + 54 degoladores, nenhum cadastrado** (base tem 37 usuários) · **19 das 96 plantas têm marcador de status** ("sem produção", "fechou", "Ali verificar") e precisam de curadoria antes de virar cadastro ativo. Degolador vira **`Collaborator`**, não `SystemUser`. Só **2 e-mails** são `@fambrashalal.com.br` — os outros 99 são pessoais (gmail/hotmail), o que importa para o disparo de primeiro acesso.
  - ⚠️ **Toca o GC:** a planilha traz **nome real + município** para 94 plantas que no GC estão como "BRF S.A." / "JBS S/A" — insumo pronto para a normalização de nomes, sem depender de nova entrega da FAMBRAS.
- ❓ **[Renato] Os 2 relatórios de aves assinados** têm 12 itens gravados sem rótulo; com o fallback, seguem imprimindo **como antes** (deslocado). Não corrigi retroativamente de propósito — mexer no que um documento assinado mostra é pior que o defeito. Sendo teste, a saída limpa é **descartá-los**.
- 🧩 **Abertos da spec (P2/P3):** nº do documento do supervisor assinante (o FM exige na declaração; hoje o PDF reusa `slaughtererDoc` do degolador, que não tem input e é sempre vazio) · nome do supervisor = quem **assinou**, não quem criou · autofill robusto do endereço de origem · datas como faixa na UI (modelagem já existe) · horário também no bloco bovino · **vincular NC ao FM 7.1.6.1** (o FM manda: *"em caso de não conformidade, preencher o check list FM 7.1.6.1"*) · validar `verificationItems` antes de assinar (hoje `z.any()`) · `serialNumber` no PDF · turno com rótulo · produto preso ao escopo (**exige rota nova no GC**).
- 🚩 **Número de série do relatório Halal — regra normativa não implementada.** A Nota 1 impressa no FM define `SIF/ANO/SEQUENCIAL`, **sequência única por planta** cobrindo embarque + venda + transferência. Hoje é `halalSerialNumber`, texto livre opcional, sem geração nem unicidade — e os 3 documentos reais usam 3 formatos diferentes (`18/2022/0000200` · `4466/2026/000122` · `SIF 4333/2026/00088`). ❓ **FAMBRAS:** formato canônico + o sistema passa a gerar? Se gerar, vira chave natural e âncora melhor que `container + data` para o vínculo com o SysHalal.
- 🚩 **Correção de relatório (Nota 2 do FM):** cancelar = carimbar **"CANCELADO"** e emitir o novo com sufixo **`A`**, *mantendo a mesma série*. Não existe nada disso no SIH. Conversa com `draft→aprovar→travar` e com a auditoria por linha da ISO 17065.
- ⚠️ **`HalalCertField` na exportação NÃO foi exposto, de propósito:** ele usa `halalSerialNumber` como nº do certificado, mas esse campo é o **nº de série do relatório** — dois conceitos na mesma coluna. Separar exige migration e depende da decisão acima. `destinationCnpj` (hoje só `useState`) idem.

**SIH · Usabilidade (Google Doc "SIH - usabilidade", Nilsa, 14/jul — lido via Drive 21/jul).** Fonte: `docs.google.com/document/d/1YCGcECIZZNvNb-APufGSgU9QZPxfdixJpetC8nBRlf4` (n.almeida@ecotrace.info). 9 prints anexos. **Metade dos pontos já caiu** entre 20 e 21/jul (o doc é anterior aos Blocos P0/P1/A/B/C) — cruzamento feito por git em 21/jul:
- ✅ *(20/jul, `9a6e282`)* **Decimal nos tempos de insensibilização** — faltava `step="any"` em 6 campos; sem `step` o HTML assumia `step=1` e rejeitava `0,08 s`. Era exatamente a queixa *"não está aceitando número decimal"*.
- ✅ *(20/jul, `9a6e282`)* **Campo Horário da insensibilização** (`type=time` por verificação) — não existia no print dela; havia só o rótulo derivado do índice.
- ✅ *(21/jul, `b57a5b0`)* **Tempo de retorno em `m:ss`** (o print mostrava `(s) / Ex: 60`, build velho).
- ✅ *(21/jul, `b57a5b0`)* **Totalizador de produtos** — linha TOTAL em `ProductTable.tsx` (componente compartilhado → exportação, transferência e venda).
- ✅ *(21/jul, P1 `f77bb97`)* **Anexo DCPOA/CSN obrigatório** na transferência (já vinha do Gabriel/FAMBRAS 23/jun).
- ✅ *(22/jul, `39b36fc`)* **A · Acentuação de labels** — 18 arquivos, só strings de exibição (nenhum identificador/rota/enum/query param). Cobre os apontados + irmãos do mesmo defeito achados na varredura: `Sidebar.tsx` (13 itens + 2 grupos), `DateRangeFilter.tsx` (Últimos/Mês/Período), `fm-metadata.service.ts` (5 labels FM), `ProductionReportForm.tsx` (Tipo de Produção), `ControladoriaDashboard.tsx`, `GcRawMaterialsList.tsx`, `MeatInventoryList.tsx`, `CouroFields.tsx`, Tripas/Fracionamento/Heparina (Dt. Fabricação, Lote-mãe), `StatusHistory.tsx`, e o toast "Não foi possível salvar" em 5 telas. `tsc -b` verde.
- ✅ *(22/jul, `39b36fc`)* **B · Menu lateral perde a seleção ao entrar em `/new` ou `/:id`.** `isLinkActive` passou a casar as rotas-filhas por **prefixo** mantendo a checagem dos query params. ⚠️ **Efeito colateral conhecido:** em `/production-reports/new?productionType=couro` acendem **2 itens** (Couro + atalho "Venda/Prod. Couro 7.1.4.5", ambos couro) — cosmético, só no couro; não adicionei "match mais longo vence".
- ✅ *(22/jul, `39b36fc`)* **C · Largura dos formulários** — relatórios padronizados em `max-w-5xl` (Abate/Ocorrência saíam de 3xl, Coleta de 4xl; Produção/Embarque já em 5xl).
- ✅ *(22/jul, `39b36fc`)* **F · Copy do texto de ajuda da MP** em `LinkedSlaughtersField.tsx` — reescrito conforme a Nilsa.
- ❓ **[Nilsa] D1 · validação obrigatória do horário?** O campo Horário existe (`9a6e282`) mas segue **fora** da trava de obrigatoriedade (exige amperagem/voltagem/frequência/cuba/velocidade, **não** `checkTime`). Se a anotação *"validação"* era "obrigar o preenchimento", segue aberto; se era "não tinha onde botar a hora", está fechado.
- ❓ **[Nilsa] G · "Relatório de acompanhamento de embarque"** — título sem texto no doc; conteúdo (se houver) está só no print. Perguntar o que era.
- 🔧 **[Renato] Pedir à Nilsa retestar com o build atual** antes de reabrir — 5 dos pontos já caíram.

**SIH · Fluxo de homologação de MP + travas (reunião FAMBRAS 30/jun):** *(trazido ao §4 em 17/jul pela regra §0.5 — vivia só na ATA/fluxograma de 30/jun, commitados em `1db4442`; nenhuma linha estava no mestre)*. Desenho: `FLUXOGRAMA-RELATORIO-FABRICACAO-MP-2026-06-30` + `ATA-ALINHAMENTO-FAMBRAS-2026-06-30` (§8). **Nada codado — zero hash.**
- 🧩 **Trava na ASSINATURA, não no registro** — supervisor só enxerga MP do escopo (read-only do GC). MP fora do escopo → **alerta no preenchimento** → salva rascunho → **não assina** (pendente de validação). É o detalhamento do "acoplar MP aprovada" acima. ❓ depende de PO.
- 🧩 **3 casos quando falta MP:** (1) já no escopo → segue · (2) **já homologada na base/catálogo global** → analista só **inclui no escopo** (reuso, **sem** homologação nova) · (3) MP nova → homologação completa (cliente alimenta a planilha + analista avalia). ⚠️ O **supervisor não cadastra MP** — sinaliza e orienta o cliente (coerente com §5.16, mas ver o gap de sync no §6).
- 🧩 **Lista viva** — após homologar, a lista suspensa precisa refletir **na hora**; senão trava o supervisor em campo (Elaine: *"a atualização tem que ser simultânea"*).
- 🧩 **Tela de pendências** (controladoria/analistas) — relatórios travados por MP não homologada.
- 🧩 **Liberação sempre REGISTRADA** (quem autorizou) — auditável. Critério de quem destrava = ❓ FAMBRAS (§4.3).
- 🧩 **Roteamento industrializado × In Natura** — cert/relatório de **industrializado** foi classificado na divisão **In Natura** e "ninguém acha" (Lina, 30/jun). Garantir roteamento correto por divisão + relatório localizável independentemente da divisão.
- 🧩 **Dashboard de Ocorrências (qualidade)** — decisão da reunião: ocorrências ficam **centralizadas no SIH**, espelhando o Power BI do time da Elaine. 📦 bloqueado pelo Power BI atualizado (§4.3).
- 🧩 **Perfil "Qualidade" no SIH** — não existe; criar (acesso Elaine/time).
- 🔧 **E-mails de acesso não chegaram** (Elaine e Soha, 30/jun) — investigar envio; encosta no §3.5.
- 🚩 **Ciclo embarque ⇄ nº do cert SysHalal — CONFLITA com o §5.21. NÃO CODAR.** A reunião propôs **travar o Relatório de Embarque** (só avança com o nº do cert) e **travar a emissão no SysHalal** até o embarque ser aprovado. O §5.21 trava o oposto: **manter o embarque como está** e pôr a rastreabilidade no **Dossiê paralelo**. ⇒ ❓ **Decisão [Renato/FAMBRAS] antes de qualquer código:** a trava entra no Dossiê (paralelo) ou re-litiga o §5.21?

**SIH↔SysHalal · integração sem escopo de grupo (código PRONTO, rollout pendente — ver §4.1):**
- ✅ external-api rotas `/integration/{certified,certified_status,certified_pdf}` c/ x-api-key: `25c96a6` (develop `89c6e7e` · staging `6d2c2e7` · **release NÃO — não está em prod**).
- ✅ sih-backend modo dual (`SYSHALAL_INTEGRATION_API_KEY` → /integration; senão legado): `439d4ea` (release, pushado).
- 🧩 [Claude] testes staging quando SSM configurado: certs de **2 grupos** + regressão `/certified` legado (parceiro continua escopado).
- Domínio de arquivos (fora da Trilha D declarada — anti-colisão): `syshalal-external-api/*` · `sih-backend/src/halal-cert/` · `sih-frontend/src/{components/shared/HalalCertField.tsx, services/halal-cert.service.ts}`.

**SIH · QA Nilsa (mai/2026 — o mais stale; confirmar em prod antes de codar):** M2.6/M3.8/M4.13/M5.10/M7.4 (mensagens ausentes) · M11.7 card Supervisores clicável · M11.8 export Analytics · tooltip KPI · sweep de Selects `disabled`→texto plano (só Planta convertida).

**SysHalal · tela de validação:** 🧩 **erros de hidratação React #418/#422** — *(trazido para o §4 em 17/jul pela regra §0.5; estava só no handoff de 23/jun e escapou da extração)*. **Adiado pelo Renato** na época, nunca fechado. Ocorre na tela `certificadovalidate/[id]` do `syshalal-web`. Suspeita registrada: **skew de cache pós-deploy** → testar **hard refresh** primeiro; se persistir, reproduzir em `next dev` para ter a mensagem não-minificada (suspeita secundária: i18next em SSR). **Não é regressão** dos fixes de 23/jun (`#516`/`#517`) — a UI nova só renderiza pós-fetch. ⚠️ Toca a **Trilha E** (SysHalal), hoje travada pelo WIP solto (§1/§3.2) — **não iniciar antes de resolver o WIP**.

### 4.3 FAMBRAS — decisões e entregas
**❓ Decisões de norma (as 3 mais quentes — Soha):**
1. **Mercados nacionais (BPJPH/MUIS/MS) devem derivar GSO?** O alinhamento de 08/jul diz que são baseados em GSO e o sistema **já os trata como GSO** (nomenclatura de categoria + `gsoAuditMode`, *"Default to GSO rules"*) — só a derivação de `standard` não reflete. Se sim, "Sem norma acreditada" quase desaparece.
2. ✅ *(22/jul)* ~~Contradição UAE.S → "sem norma acreditada" × imprime ENAS~~ — **RESOLVIDO (Soha):** UAE.S **tem norma acreditada própria** (imprime ENAS); corrigir a classificação. Vira decisão **§5.22**.
3. **GSO+OIC juntos → template GCC → só o selo GAC** (o OIC não sai). Coerente com "SMIIC só Turquia" — confirmar.

**✅ Respondido pela Soha (WhatsApp 22/jul) — vira decisão §5.22:**
- **A auditoria governa a versão da norma** (update prospectivo, a partir da próxima auditoria; não retroage).
- **Mercado no cert ⊆ mercado auditado por auditor ELEGÍVEL** (Indonésia = grupo de auditores dedicado).
- **2055-2 = norma do organismo (selo GAC) · 2055-1(+993) = norma da planta (linha)** — anos divergentes são normais.
- **Ingrediente restrito filtra mercado** (conchonilha: Ásia Amarela aceita, GSO/UAE não) — modelamos **tabela geral** (decisão Renato).

**✅ *(resolvido — Elaine, reunião anterior)* Selo por grupo-de-norma:** cert de **Indonésia (e nacionais) NÃO leva selo** — nem o nacional, nem GAC/ENAS (que são acreditação do **Golfo**). **Confirma o §5.2** (nacionais nunca) e resolve W12 (GAC/ENAS fora da Indonésia = correto) + W13 (sem selo Indonésia = correto). Modelo: **selo por grupo** — GSO/Golfo→GAC(+ENAS p/ UAE) · OIC/SMIIC→HAK · **nacionais→conjunto vazio**. W16 (Saudi sem GAC) segue bug: Saudi=GSO **deve** levar GAC.

**❓ Outras decisões:** #3 base por categoria (Minerva 1430×1431) · #9 múltiplos mercados · draft→aprovação existe? · N2b de-para de **14 categorias** · 3 SIFs duplicados (585 FRIGOMARCA×PANTANAL · 4699 LAR×AGROARACA · 2620 FALCAO×BMG) · dedup Hexus×Vidara · REVIEW histórico (7 casos) · overlap couro 7.1.4.5×7.1.4.9 · 5 decisões Fase 5B FAM-0017 (Lina) · certs vencidos-mas-ativos (ex. Gelita).

**❓ Matriz de criticidade de travas — quem destrava o relatório (reunião 30/jun):** *(trazido ao §4 em 17/jul pela §0.5)*. Pré-requisito do fluxo de homologação de MP (§4.2/SIH). Desenho proposto na reunião, **falta a FAMBRAS fechar**:
- **Documento vencido** (ex.: nitrito de sódio) → **controlador libera** (Lina: *"já confiam que ele faça"*).
- **MP fora do escopo** → **trava** até incluir/homologar no GC; caso **emergencial** sobe a **gestor**.
- ❓ **Critério de MP crítica × não-crítica** (sugestão da Soha) — o que trava direto vs. o que libera.
- ❓ **Quem é "gestor"** para liberação emergencial + formato do registro/escalonamento.
- ❓ **SLA da atualização "simultânea"** da lista após homologar (o que é aceitável p/ não travar o supervisor).
- Invariante já acordado: **toda liberação fica registrada** (quem autorizou) — Lina: *"pelo menos a gente sabe de onde veio"*.

**📋 Correção na FONTE (relatório pronto — `halalsphere-docs/PLANNING/RELATORIO-ESCOPO-CORRECAO-FAMBRAS-2026-07-12.xlsx`, `7f565b7`):** *(novo 17/jul)* **3 produtos** cujo nome é **código DSM na própria planilha FM** (`8001 D/P`, `8008 C/U`) · **30 marcas** que são produto/embalagem/lista no lugar da marca. O parser refinado recuperou **312 dos 315** casos automaticamente (315→3); o resíduo é dado ausente/trocado no FM, só a FAMBRAS resolve.

**❓ Curadoria do catálogo de MP (N5 v2):** *(novo 17/jul)* catálogo refeito → **335 masters, 0 nome numérico** (v1 tinha 56 numéricos + blobs de fórmula). **7 famílias ficaram em `pending`** aguardando a FAMBRAS decidir a fusão (ex.: `Ácido Cítrico` × `Ácido Cítrico Anidro` × `Acidulante Ácido Cítrico Pó`) — **não fundi no automático porque em halal a forma/origem importa** (cítrico sintético × microbiano difere). Propostas em `scratchpad/n5v2-merge-propostas.txt`. Também: **7 `company_raw_materials` em `awaiting_matching`** cujo "nome" é **fórmula inteira** ("Açúcar cristal, açúcar mascavo, sal, especiarias…") = receita de produto final, não MP → corrigir na origem.

**📦 Entregas aguardadas:** logos/assinatura em **alta resolução** · lista "certificada desde" · **textos oficiais EN por categoria** (só "K" confirmado) · arquivo de **escopo real** da Lina (destrava o parser xlsx) · .xlsx do catálogo de produtos (destrava 5A-2) · CSVs FM 7.8.1/7.8.2 · certificado real **preenchido** de referência (A2 layout datas EN/AR) · logo Indonésia (Elaine consulta acreditadora) · **aprovar itens de MP** na tela de review (sem isso `approvedOnly=true` volta vazio) · lançar dados reais no FM 20.1 · lista oficial plantas+CNPJ · criticidade halal · códigos reais dos 322 `N5-*` · 16 estrangeiras sem endereço (fonte externa) · Starmilk/Econata (fora do SIGSIF) · **Power BI de qualidade atualizado** (Elaine — destrava o dashboard de Ocorrências do §4.2/SIH; o que está em mãos é a versão de **abril**) *(§0.5, 30/jun)*.

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
14. ✅ **Cor dos e-mails migrada para o azul Ecohalal `#118add`** *(16/jul, `e953c21b`)* — a opção que estava aberta ("segue teal, migração opcional") foi **exercida pelo Renato**. Eram **2 cores**, não 1: verde `#1a5c2e` + subtítulo `#a7d5b5` (4 templates) e teal `#0f766e` (notificações) → tudo `#118add` (subtítulo `#bfe3fa`). Zero cor antiga em `src/email` e `src/notification`. 🔧 **[Renato] Validar** um e-mail real (ex.: Primeiro Acesso) e uma notificação. ⚠️ Esta pendência vinha do handoff 13/jul e **não estava no §4** — gap da extração, fechado aqui (regra §0.5).

**Modelo de dados / arquitetura**
15. `CompanyGroup` = grupo econômico · `Company` = CNPJ da filial · `Plant` = estabelecimento (**1 SIF ↔ 1 CNPJ**, nullable p/ químicos/casing). Unique `(sanitary_code, sanitary_code_type)` está CERTA → **sem migration**. Base DEFINITIVA de cadastro: `C:\HalalSphere\FM78x_atualizados\` (FM 7.8.1 .xlsx + 7.8.2 .xlsb, 25/06) → 652 estabelecimentos (571 BR + 81 estrangeiros).
16. **Cadastro nasce no GC**; SIH **consome** (não cadastra planta). Embarques **permanecem no SysHalal**.
17. **Auditoria por linha obrigatória (ISO 17065)** via `CertificationHistory`; `AuditTrail` genérica dormente. **F4 (RevisionLog) tem prioridade sobre F5/F6.**
18. **Imprimir = `generateAndStore` idempotente** via URL presigned + `window.open` — **nunca XHR→S3** (dá CORS).
19. **Prod do GC tratada como homologação** por ora (FAMBRAS gera sujeira; limpeza depois). Reset final: apagar certs de teste e zerar numeração antes de operar.
20. **M7.4 — NC com relatório-pai: OPCIONAL** (Renato, 22/mai).
21. **Dossiê de exportação** (22/jun): manter o Relatório de Embarque **como está** + construir o Dossiê como **fluxo PARALELO** (rastreabilidade documental completa). O sistema deve **cobrar do supervisor as datas efetivas de abate**.

**Kernel de normas (22/jul — ADR em `halalsphere-docs/ARCHITECTURE/ADR-KERNEL-NORMAS-CERTIFICADO-2026-07-22`, §8)**
22. **Kernel de normas = snapshot-first + tabela plana effective-dated + produtor único.** Regras confirmadas com a Soha (22/jul):
    - **(a)** A **auditoria** governa a versão da norma; update é **prospectivo** (próxima auditoria), não retroage.
    - **(b)** Mercado no cert **⊆ mercado auditado por auditor elegível** para a norma (Indonésia = grupo dedicado). Inativa no modo emissão-manual.
    - **(c)** **2055-2 = norma do OC (selo GAC)** × **2055-1(+993) = norma da planta (linha de norma)** — nunca se cruzam; anos divergentes são normais. UAE.S **tem** norma acreditada (não é "sem norma").
    - **(d)** Elegibilidade de mercado = **base ∩ ingrediente ∩ auditor ∩ habilitação**; **ingrediente restrito × mercado = tabela geral** (conchonilha é a 1ª linha).
    - **(e)** `Certificate` **congela** as normas resolvidas na emissão (satisfaz imutabilidade §5.3); PDF de cert emitido **nunca re-resolve**.
    - **(f)** Kernel **não funde** numeração/audit-days/competência de auditor (bounded contexts próprios); liga a competência **por validação**, não por fusão.
    - **(g)** ✅ **Selo por grupo-de-norma** (Elaine): GSO/Golfo→GAC(+ENAS p/ UAE) · OIC/SMIIC→HAK · **nacionais (Indonésia/BPJPH, MS, MUIS)→SEM selo** (não contradiz §5.2; refina o enforcement — hoje o código põe GAC/ENAS em tudo).

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
| §4.2: *"`353a0b79` commit local em `release`, push pendente do OK"* | **Já estava em `origin/release`** — `git branch -r --contains` confirma. Corrigido 17/jul. |
| §5.16: *"SIH **não cadastra planta**"* | **O SIH tem `model Plant` próprio** (39 plantas) e **toda a operação pendura nele** (abate/produção/embarque/NC/supervisor/inventário/escala); a UI **permite cadastrar**. A integração é **read-through de uma via, SEM sync** (o `TASK-07` do schema do SIH diz que o sync GC→SIH é **planejado, não feito**). O §5.16 descreve o **alvo**, não o estado. ⇒ enquanto não houver sync, **os dois cadastros divergem em silêncio** e a junção `SIF+CNPJ` quebra sem avisar. *(Achado 17/jul, cruzando os 2 bancos — foi o que motivou o fallback CNPJ-only.)* |
| §1: *"`sih-docs` — WIP solto **0**"* | Havia **16 caminhos não-rastreados**. Entre eles, **specs que o próprio mestre referencia**: `ITEM-A-B-C-MULTI-ORIGEM-SPEC` + `ITEM-A2` (base do "embarque multi-origem A/B/C" do §4.2/SIH) — o mestre apontava para arquivo **inexistente em git**. Também `ROADMAP-DIRETORIA-2026-07-14` e 20,8 MB de planilhas FM 7.4.2.7 em `Reuniões/` (fonte do F6/N5b/N5c). **Corrigido 17/jul:** 15 docs versionados (`1db4442`); `Reuniões/` → `.gitignore` (`f4223ca`, decisão do Renato: binário pesado segue a política de fontes externas do §8). *(Lição: a auditoria de 16/jul cobriu os repos de **código**; os de **docs** passaram batido — e o mestre vive num deles.)* |

---

## 7. Entregue em 16/jul (esta consolidação)

**GC — emissão:** guard-rail de categorias por modelo `e1f92785` · selos visíveis na tela em vez do código do template `82a5e2c1` · "Voluntária" → "Sem norma acreditada (GSO/SMIIC)" `2844a9c2` · busca por SIF `298a346f`+`49f84b7f` · PDF com cópia bloqueada, AES-128 `6fed9470` · env renomeada p/ `CERTIFICATE_PDF_UNLOCK_KEY` `9bf9bab0`.
**Recuperados (estavam soltos no working tree):** preset de normas por espécie + SIF na tela `827f8adf` · normas FAMBRAS + `.K.` `c396f0a5`.
**Antes (13/jul)** — entregas que não estavam registradas em §4 nem §7 (gap da extração, trazidas pela regra §0.5):
- **GC · fix do filtro de empresa** (`/homologacao-mp`): o X não limpava — `[&_svg]:pointer-events-none` do Button engolia o clique; X e chevron saíram de dentro do gatilho do Popover → `160b2cdd`. 🔧 [Renato] validar (§4.1).
- **GC · Trilha C — Edição de escopo F1** (produtos/marcas na tela de detalhe + auditoria transacional em `CertificationHistory`): back `0f3a9b32` · front `a44f9e49`. 🔧 [Renato] validar (§4.1).
- **SIH · recuperação de senha** (forgot/reset self-service): back `06ae5ef` · front `a24385b`. 🔧 [Renato] validar E2E + SES + migration (§4.1).

**Antes (09/jul):** trava de data `295d274f` · clone typeahead `5de76e6a` · descartar-só-produtos `d5ced92a` · allowlist de selos `ee23628f`.

**Os 4 pontos do André estão fechados** (busca por SIF · guard-rail de categorias · "Voluntária" · templates).

---

## 8. Histórico — handoffs e specs (ponteiro, NÃO verdade)

> ⚠️ Estes arquivos descrevem o momento em que foram escritos. **Vários estão defasados (§6).** Use-os para entender *por que* uma decisão foi tomada — nunca para saber *o que está pronto*.
>
> **Nada foi apagado.** As pendências destes handoffs foram extraídas para o §4 em 16/jul, mas a extração é falível: se você encontrar aqui um item aberto que **não** está no §4, **traga-o para o §4** (regra §0.5). O banner marca "não é estado" — não "não leia".

**Specs (referência técnica — continuam válidas):** **`ARCHITECTURE/ADR-KERNEL-NORMAS-CERTIFICADO-2026-07-22`** (halalsphere-docs — kernel de normas: snapshot-first + matriz effective-dated + as decisões da Soha 22/jul + fatias 0/1/2 + arquivos a consolidar; = decisão §5.22) · **`SPEC-CONFORMIDADE-FM-SIH-2026-07-20`** (sih-docs — cruzamento campo a campo dos FM em papel × SIH, a partir dos formulários oficiais preenchidos e assinados; P0/P1 implementados em 21/jul, §4.2) · `SPEC-EMISSAO-MULTI-CERT-NORMAS-GC-2026-07-14` · `CATEGORIA-POR-NORMA-PICKER-EMISSAO-GC-SPEC-2026-07-08` · `SPEC-EMISSAO-MANUAL-CERTIFICADO-2026-07-06` · `REGRAS-NORMAS-POR-DT-MERCADO-2026-07-06` · `REFERENCIA-TEMPLATES-CERTIFICADO-2026-07-06` · `NORMALIZACAO-CADASTROS-PLANO-MESTRE-2026-07-10` (Anexo A tem os SQL de diagnóstico) · `SYSHALAL-INTEGRATION-ENDPOINT-SIH-SPEC-2026-07-06` (sih-docs) · **`FLUXOGRAMA-RELATORIO-FABRICACAO-MP-2026-06-30`** (sih-docs — fluxo de homologação de MP + travas, Rev 2 com raias por ator; pendências extraídas para o §4.2/SIH em 17/jul).

**Handoffs (histórico):** halalsphere-docs `HANDOFF-SESSAO-2026-07-{08,13,14}` · `HANDOFF-NORMALIZACAO-2026-07-{10,12}` · `EDICAO-ESCOPO-CERTIFICADO-FASE1-HANDOFF-2026-07-13` · `HANDOFF-EMISSAO-MANUAL-2026-07-07` · `HANDOFF-SEED-GC-2026-07-{02}` — sih-docs `HANDOFF-SESSAO-2026-07-14` · `RECUPERACAO-SENHA-SIH-HANDOFF-2026-07-13` · **`ATA-ALINHAMENTO-FAMBRAS-2026-06-30`** (alinhamento dos 3 sistemas: fluxo de homologação de MP, dashboard de qualidade, ciclo embarque⇄cert; pendências extraídas para §4.2/§4.3 em 17/jul).

⚠️ **Gap de registro fechado em 17/jul:** a `ATA-ALINHAMENTO-FAMBRAS-2026-06-30` e o `FLUXOGRAMA-RELATORIO-FABRICACAO-MP-2026-06-30` foram versionados em `1db4442` (o lote dos "15 docs que viviam só na máquina local") mas **nunca foram listados aqui nem tiveram pendências extraídas para o §4** — ficaram invisíveis para o mestre por 17 dias. Mesma classe de falha do §6 (docs passam batido na auditoria de código). *(Regra §0.5 aplicada.)*

**Fontes externas (fora de git):** transcrições em `C:\HalalSphere\Alinhamentos de validação\` · gabaritos em `C:\HalalSphere\Gabaritos atualizados\` · `C:\HalalSphere\FM78x_atualizados\` · docx contratuais em `C:\SIH\` · **Google Doc "SIH - usabilidade"** (Nilsa, `docs.google.com/document/d/1YCGcECIZZNvNb-APufGSgU9QZPxfdixJpetC8nBRlf4`; 9 prints, lido via Drive 21/jul — pendências A/B/C/F extraídas ao §4.2) · **`c:\Projetos\Ecohalal\reunioes_fambras\2007_1100\`** (reunião FAMBRAS 20/jul: transcrição + **FM 4.1.X REV 03** ANEXO 1 [.xlsx, matriz DT×mercado→norma canônica] + DT 7.2.1 aves REV 14 + TXTs de numeração `.N.` aves/bovinos) — insumo do ADR do kernel (§5.22); + thread WhatsApp Soha 22/jul (decisões de norma, não versionado).
