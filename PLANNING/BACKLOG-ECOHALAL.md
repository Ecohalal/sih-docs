# BACKLOG-ECOHALAL — Consolidação de pendências (SIH + GC + SysHalal)

> **Painel central, vivo.** Reúne as pendências das frentes em paralelo nos três
> sistemas. Cada sessão/memória aponta pra cá; aqui fica a visão consolidada.
>
> **Status:** ✅ feito/deployado · 🔧 operacional (UI/infra/dados) · 🧩 código a fazer ·
> ❓ decisão pendente · 🚧 em outra sessão (não duplicar).
>
> **Como usar:** uma seção por **frente**, agrupada por **sistema**. Marque `[x]` ao
> concluir e cite a fonte (handoff/memória). Itens pré-preenchidos da memória vêm
> marcados _(da memória — confirmar)_ quando não validados nesta consolidação.
>
> Última consolidação: **30/jun/2026** (incorpora reunião FAMBRAS 22/jun: cert layout/regras + usuários + dossiê + Apêndice de auditoria desta sessão).

---

## Índice
- **SIH** — [1.1 Suporte Gabriel/Seara](#11-suporte-gabrielseara-25jun) · [1.2 Embarque multi-origem](#12-embarque-multi-origem--vínculos) · [1.3 SIH⇄GC consumir MP](#13-sih⇄gc-consumir-mp-homologada) · [1.4 QA Nilsa (sessão 19-22/mai)](#14-qa-nilsa-sih--sessão-19-22mai-3-rodadas)
- **GC** — [2.1 FAM-0017](#21-fam-0017-homologação-mp) · [2.2 Seed cadastro/cert/escopo](#22-seed-cadastrocertescopo-fm-78x) · [2.3 Integração GC→SIH](#23-integração-gcsih-endpoint) · [2.4 Reconciliação/limpeza](#24-reconciliação--sqls-limpeza) · [2.5 Emissão manual cert — layout/regras (22/jun)](#25-emissão-manual-de-certificado--layoutregras-reunião-22jun)
- **Cross** — [4.1 Usuários FAMBRAS](#41-usuários-fambras-criar)
- **SysHalal** — [3.1 Fixes / exportação](#31-fixes--exportação)
- **Apêndice — Auditoria 30/jun (esta sessão)** — [A.1 SIH código residual](#a1-sih--código-residual-a-confirmar) · [A.2 SIH operacional](#a2-sih--operacional-residual) · [A.3 GC bloqueios externos](#a3-gc--bloqueios-fora-deste-backlog) · [A.4 SysHalal Caminho B](#a4-syshalal--infra-qr-verify) · [A.5 Cross dados FAMBRAS](#a5-cross--dados-fambras-aguardando-entrega)

---

# SIH — Supervisão Industrial Halal

## 1.1 Suporte Gabriel/Seara (25/jun)
> Deploy: sih-backend `6e5f43d`, sih-frontend `c6c851b` (antes `f6c9de9`).
> Fonte: `PLANNING/HANDOFF-SESSAO-2026-06-25.md` §7-11 · memória `project_pendencias_sessao_suporte_seara_2026-06-25`.

**✅ Deployado:** capabilities multi-atividade (Seara) · busca de plantas corrigida · ordenação Plantas/Usuários `name asc` · NF estruturada no bloco Documentos + consolidação · autosave local nos 3 forms · couro 7.1.4.5 no embarque · remoção de campos sanitários duplicados.

**🔧 Operacional**
- [ ] Validar deploys na AWS + smoke test (busca, ordenação, NF, banner rascunho, Seara em Fabricação, atalho couro).
- [ ] Configurar `capabilities=processamento` das **4 Seara** pela UI (admin da Lina) — confirmar quais (Montenegro, Itapiranga, Rolândia + ?).
- [ ] Reconciliar `release → development` (back e front).

**❓ Decisão (Gabriel)**
- [ ] Overlap couro **7.1.4.5 × 7.1.4.9** — se 7.1.4.5 cobre tudo, remover/aposentar `venda_subprod_couro` (7.1.4.9).

## 1.2 Embarque multi-origem / vínculos
> 🚧 Em outra sessão (pacote "saindo hoje"). NÃO duplicar — confirmar antes.

- [ ] **Item A — múltiplos SIF de origem no embarque (FM 7.1.7.1):** carne de vários frigoríficos no mesmo embarque. Base: `ShippingReport.linkedProductions` (M:N) + `productionSnapshot`. Falta UI N-origens + snapshot multi-SIF + PDF.
- [ ] **Item B — datas como faixa (início–fim) em "Adicionar Produto":** abate/produção/validade viram range. Componente `ProductTable`; JSON `products` + PDF.
- [ ] **Item C — vínculo embarque⇄produção visível no controlador:** dado existe (`linkedProductions`); falta expor em `/controladoria`/detalhe do embarque com link p/ `/production-reports/:id`.

> **Decisão reunião 22/jun (Dossiê):** manter o **Relatório de Embarque como está** (parcial, suficiente p/ liberar o
> cert RALAU) **+ construir o Dossiê como fluxo PARALELO** ("plus") = agregação completa da rastreabilidade documental
> (N abates por data + transferências/desossa + CSI/CSN/NF + cert SysHalal). Apresentar depois de estabilizar. O sistema deve
> **cobrar do supervisor as datas efetivas de abate** (não permitir emitir com dia faltando). Spec Fase 2:
> `PLANNING/ITEM-A-B-C-MULTI-ORIGEM-SPEC-2026-06-25.md` · Fase 1: `FASE-1-DOSSIE-EMPODERAR-EMBARQUE-SPEC-2026-06-22.md`.
> **FM 20.1 (ocorrência aves) já está em prod** — falta só a FAMBRAS lançar dados reais p/ espelhar.

## 1.3 SIH⇄GC consumir MP homologada
> Fonte: memória `project_sih_consome_gc_mp_homologada_2026-06-29`.

- [ ] 🔧 **PRÉ-REQ infra:** task def `sih-api-task` precisa de secret + envs (BASE_URL/API_KEY) senão a tela dá **503**. _(da memória — confirmar)_
- [ ] Validar boot/tela read-only após config. _(da memória — confirmar)_

## 1.4 QA Nilsa SIH — sessão 19-22/mai (3 rodadas)
> Fonte: memórias `project_qa_nilsa_2026-05-19_results`, `project_qa_nilsa_2026-05-21_results` + commits 19-22/mai.
> Placar (Total 96): 19/mai (45 OK / 7 Parcial / 17 Falhou) → 21/mai (53/4/15) → **22/mai (55/13/4)**.
> Lição-âncora da sessão: bug "Planta vazia em edit/view" tinha 2 causas distintas — Select Radix com race em view-only (resolvido virando texto plano d039c3f) + estado inicial vazio em edit-rascunho (resolvido com hydration flag 167c54d). Ver memórias `feedback_select_disabled_em_view_only` + `feedback_evidencia_antes_de_fix`.

**✅ Deployado (12 commits nas 3 rodadas):**

| Commit | Cobre |
|---|---|
| `d039c3f` | Planta texto plano em view-only nos 4 forms (M3.3/M4.12/M7.4 view) |
| `167c54d` | Hydration flag em edit de rascunho |
| `caab479` | Fallback `report.plant` quando paginação `/plants` exclui |
| `269b6bf` | NCForm fallback `nc.plant` |
| `781e15b` | Backend `z.coerce.number()` (Prisma Decimal × Zod) M4.4-M4.11 |
| `0911be7`+`960deba` | Dates obrigatórios em 9 tipos Produção + Couro M4.2-M4.6 |
| `a2a47c5` | Pós-save navega para lista filtrada + ReportHeader em rascunho + toast (M5.6) |
| `c6106db` | Validação client Fracionamento (M4.5) |
| `d2a908a` | Toast destructive + scroll-to-top em erro nos 4 forms (raiz "duplo clique" universal) |
| `746775d` | Mensagens humanizadas em validações Produção+Embarque (sem nome de campo interno) |
| `6ffc6bb` | NotificationsPage `/notifications` criada (M10.6) |
| `735d7cb` | Filtros consistência 3 listas (M3.9: Limpar sempre visível + aprovado/rejeitado) |
| `b91d32b` | Validação backend datas plant (M2.4 defense-in-depth) |
| `4329d72` | Admin reabre rejeitado (alinha back ao front) |
| `47be5d1` | Mensagem específica usuário inativo (M2.8) |

**🧩 Identificados na QA 22/mai mas não atacados (próxima rodada):**

_Mensagens ausentes em validação client (mesmo padrão):_
- [ ] M2.6 — email duplicado bloqueia salvar sem mensagem
- [ ] M3.8 — validação só em campo data
- [ ] M4.13 — planta obrigatória em produção sem msg
- [ ] M5.10 — embarque sem planta, sem msg
- [ ] M7.4 — lista de relatórios de abate vazia ao criar NC mesmo tendo abate assinado

_UX residual a investigar com repro:_
- [ ] M3.4 — "não encontrei opção assinar abate" (UX vs bug real)
- [ ] M7.3 — "não encontrei campo/tela/botão para atualizar NC"
- [ ] M9.12 — filtro por planta na Controladoria não encontrado
- [ ] M3.2 — "aprovados+rejeitados < total ainda deixa gravar" — fix A3 (22d1d8b) deveria ter resolvido. Suspeita: bundle stale na máquina da Nilsa. Confirmar em re-teste.

**❓ Decisão produto / aguarda confirmação visual (Renato 22/mai afirmou OK em outras sessões; código atual da base SIH-frontend NÃO mostra os fixes — confirmar em prod):**

- [ ] **M11.7 Card Supervisores clicável** — Renato: feito. Verificado: `AnalyticsOverview` não tem KPICard com `onClick` para `/analytics/supervisors`, e Sidebar não tem entrada. Página `SupervisorAnalytics` existe e renderiza. **Pendente:** confirmar visualmente em prod OU adicionar entry point.
- [ ] **M11.8 Export Analytics** — Renato: feito. Verificado: grep sem matches para `exportCsv`/`html2canvas`/`saveAs` em `/pages/analytics`. **Pendente:** confirmar OU implementar.
- [ ] **Tooltip KPI Taxa de Aprovação** — Renato: feito. Verificado: `KPICard.tsx` não tem prop `tooltip` nem renderiza `<Tooltip>`. **Pendente:** confirmar OU implementar (fórmula `Σ approvedAnimals / Σ totalAnimals` documentada).
- [ ] **Sweep outros Selects readOnly → texto plano** — Renato: feito. Verificado: só **Planta** convertida no `d039c3f` (4 forms). Turno/Espécie/Tipo Embarque/Tipo Transporte/Severidade ainda usam `<Select disabled={readOnly}>`. **Pendente:** confirmar OU completar sweep.

**✅ Confirmado fechado pela palavra do PO (não verificável no código):**
- [x] M10.4 — Email rejeição SES — resolvido (Renato 22/mai).

**❓ Decisão pendente:**
- [ ] **M3.10 / M9.7** — Reabrir rejeitado: fluxo permite supervisor original + admin (pós-4329d72). Validar com PO se cobre os casos reais.
- [x] **M7.4** — NC obrigar relatório-pai: **decidido manter opcional** (Renato 22/mai).

---

# GC — Gestão de Certificações (HalalSphere)

## 2.1 FAM-0017 (homologação MP)
> Fonte: `PLANNING/HANDOFF-SESSAO-2026-06-25.md` §4-5 · memória `project_fam0017_gc_fase1_2026-06-25`. Schema backend FECHADO (F1+F2+F3 deployados).

- [ ] 🧩 **Frontend per-Company (F2/F3)** — telas no dashboard da empresa (CompanyRawMaterial, fornecedores, item+evidência). [maior valor demoável]
- [ ] 🧩 **F5 — UI U7** `/homologacao-mp` (tela única de homologação).
- [ ] 🧩 **F4** — FK opcional em `ScopeSupplier`/`SupplierHomologation` (sync one-way) + **RevisionLog** (audit ISO 17065).
- [ ] 🧩 **F6** — import das 29 planilhas FM 7.4.2.7 → carga via DBeaver (quando definido o mapeamento).
- [ ] 🔧 **Seeds** — S1 (~40 certificadoras dedup de 77) + S2 (231 intermediários) → DBeaver quando curados.

## 2.2 Seed cadastro/cert/escopo (FM 7.8.x)
> Fonte: memória `project_seed_gc_cadastro_cert_escopo_2026-06-29`. N0 DEPLOYADO (Plant.displayName + flags QA).

- [ ] 🔧 **N1a** — rodar no DBeaver (438 estabelecimentos, enriquece por CNPJ; chave CNPJ+SIF). _(da memória — confirmar)_
- [ ] ⏳ Aguarda **FM 7.8.1 atualizado** (espinha cadastral) + frigorífico completo. _(da memória — confirmar)_
- [ ] N2–N5 (cert + escopo) — _(detalhar/colar)_

## 2.3 Integração GC→SIH (endpoint)
> Fonte: memória `project_gc_sih_integracao_fam0017_2026-06-28`. SIH LÊ do GC; chave SIF+CNPJ; ETL piloto Rolândia carregado/validado.

- [ ] 🔧 Endpoint `/integration/by-plant` + x-api-key — **pendente push + env**. _(da memória — confirmar se já saiu)_

## 2.4 Reconciliação / SQLs limpeza
> Fonte: memória `project_sessao_2026-06-29_gc`.

- [ ] 🔧 Reconciliar `release → develop` (GC).
- [ ] 🔧 SQLs de limpeza em `prisma/` — rodar via DBeaver. _(da memória — confirmar)_

## 2.5 Emissão manual de certificado — layout/regras (reunião 22/jun)
> Fonte: ata/transcrição `Downloads\Google-Chrome-7d023074-0b8f.md` (Renato/Elaine/Dibe/Lina/Fuad/André) ·
> memória `project_sessao_2026-06-23_fidelidade_renderers`. **Regra dura:** layout do certificado
> **CONGELADO** — "o Nizar não deixa mudar uma vírgula sem validar com o acreditador". Renderers devem ser
> **idênticos aos gabaritos acreditados**, não inovar.

**✅ Já deployado (23/jun, `b9102bd9`):** surveillance em vermelho (EN+AR) · linha verde removida (FM 7.7.2) ·
rodapé duplicado FM 7.7.1 resolvido · coluna Packing size removida · **trava de selos** (JAKIM/MS, MUIS, Singapura
nunca saem; WHFC extinto removido; Indonésia/kepkaban mantida) · download de cert proibido (anti-falsificação, confirmado) ·
QR `cert.fambrashalal.com.br/verify` confirmado OK.

**⏸️ Bloqueado em retorno FAMBRAS**
- [ ] ❓ **A2 — layout das datas EN/AR** (Elaine: "PT e árabe só de lado, titinho mudado"). **Diferido de propósito** —
  precisa de **certificado real PREENCHIDO** de referência (gabarito em branco não mostra posição). Não mexer às cegas.
- [ ] ❓ **Logo Indonésia** — Elaine vai **consultar a acreditadora** (na pauta dela); só então decidir se entra no cert.

**🔧 Validação em quatro-mãos (com Lina/Fuad/André + Mariana)**
- [ ] **Regras de norma** — `GSO **ou** AI` (não os dois; sem AI isolado) · norma **não é 2055-2** ("melhor nem colocar") ·
  casar **categoria × produto × escopo × norma × selo × acreditadora** (relação **FM 41X**; Indonésia ~10 normas).
  Validar **emitindo certs reais** espelhando os existentes — não por chute.
- [ ] **Roteiro de teste** p/ FAMBRAS: pegar cert real → montar no sistema → comparar pontos (DT, selo, norma, layout) → reportar.
- [ ] Gabaritos atualizados **recebidos (Mariana)** — base real ~4–7 modelos, resto variação. _(confirmar nº recebido vs frigorífico completo)_

**📌 Nota:** prod sendo tratada como **homologação** por ora (FAMBRAS gera "sujeira", limpeza depois).

---

# SysHalal — Sys Halal (legado, exportação)

## 3.1 Fixes / exportação
> Fonte: memória `project_sessao_2026-06-23_syshalal_fixes`. Vários fixes já deployados + reconciliados.

- [ ] 🧩 Hidratação dos certificados **#418 / #422** (pendente). _(da memória — confirmar)_
- [ ] _(colar demais pendências SysHalal)_

---

# Cross — itens que cruzam sistemas

## 4.1 Usuários FAMBRAS (criar)
> Fonte: reunião 22/jun. **Único item 100% destravado do nosso lado** (e-mails já recebidos).

- [ ] 🔧 **GC** — criar **Mariana** + **Elaine** (Elaine hoje só tem SIH; pediu GC p/ apresentar à Indonésia).
- [ ] 🔧 **SIH** — criar **Karoline** + **Osama** (recebem ocorrência). _(grafia: **Karoline**, não "Carol")._
- [x] **Lina** já cadastrada no SIH.
- _Obs.:_ Vitor e Lina já tinham acesso ao SIH; Fuad/André já atuam na divisão de certificado.

---

> **Adicionar frente:** copie um bloco `## X.Y <Frente>` sob o sistema certo, preencha
> os checkboxes e cite a fonte (handoff/memória). Mantenha o Índice no topo atualizado.

---

# Apêndice A — Auditoria 30/jun (consolidação inter-sessões pendente)

> Esta sessão (aberta 14/mai p/ entregar telas de visualização + upload PDF; retomada 30/jun)
> auditou 6 itens reportados inicialmente como "bloqueadores" e fez um cross-check com as
> memórias do projeto. Os itens abaixo **sobreviveram à auditoria** — alguns confirmam
> pendências já mapeadas (referência cruzada), outros não estão claramente cobertos nas
> seções 1–4. Cada item precisa de **análise inter-sessões** antes de virar frente firme:
> pode estar duplicado, parcialmente coberto em outra sessão, ou já em curso.
>
> **Veredito da auditoria:** ✅ resolvido em outra sessão · 🟡 parcial (algo entregue, algo aberto)
> · 🔴 pendente · ⏳ aguardando entrega externa.
>
> A entrega original desta sessão (CertificateList + CompanyList + CompanyCombobox + upload
> manual de PDF no GC) está **em produção desde 14/mai** — ver release `9655e05e` (front) e
> `787a498b` (back); não há resíduo de código dela.

## A.1 SIH — código residual a confirmar

- [ ] 🟡 **NC FM 7.1.6.1 — UI completa** (criação/aprovação): schema + módulo deployados 16-17/jun
  (memória `project_ocorrencias_nc_progress`); a UX completa de criação/aprovação ainda precisa
  ser confirmada em prod. **Análise:** ver se já foi entregue em alguma sessão pós 17/jun.
- [ ] 🟡 **Catálogo Produtos 5A-2** — ETL em massa do `.xlsx` FAMBRAS (aguarda arquivo) +
  autocomplete de produto em formulários de embarque/produção.
  Fonte: memória `project_fase5a_catalogo_produtos` ("Falta 5A-2 (ETL, aguarda .xlsx) + autocomplete nos forms").
- [ ] 🟡 **Exibir destino no PDF do relatório de transferência** — campo `destinationType` já
  está no schema (memória `project_transfer_report_destino` 15/jun); render no PDF é o follow-up.

## A.2 SIH — operacional residual

- [ ] 🟡 **Rodar import IND em prod** — script `prisma/import-plantas-ind.ts` (commits
  `79b2935` + `91f08fc` de 16-17/jun) está **commitado mas NÃO executado em prod**.
  23 plantas IND + vínculos de supervisores pendentes.
  Fonte: memória `project_import_colaboradores_industrial_pendente`.
- [ ] 🔧 Commitar/pushar **3 docs em `sih-docs`** que estavam uncommitted no audit:
  `DOMINIO-QR-VALIDACAO-UNIFICADO-2026-05-18.md`, `ROADMAP-GANTT-2026.md`, + 1 commit local
  ahead do `origin/main`. Cosmético; tira ruído do `git status`.

## A.3 GC — bloqueios fora deste backlog

- [ ] ❓ **5 decisões abertas Fase 5B FAM-0017** (Lina) — análise da planilha
  (memória `project_planilha_mp_fam0017_analisada` 25/mai) confirmou 3 das 8 perguntas;
  faltam 5 (GC×SIH, supply-chain integration). Bloqueia implementação dos itens de
  [2.1](#21-fam-0017-homologação-mp). **Análise:** confirmar se Lina já respondeu em
  alguma reunião pós 25/mai antes de cobrar de novo.
- [ ] 🔴 **3 SIFs duplicados em prod GC** — 585 FRIGOMARCA×PANTANAL · 4699 LAR×AGROARACA ·
  2620 FALCAO×BMG. Gera 3 Companies órfãs. Aguarda decisão FAMBRAS qual razão social fica
  em cada. Pré-requisito de [2.2 N1a](#22-seed-cadastrocertescopo-fm-78x).
  Fonte: memória `project_ingestao_pre_cadastro_executada_2026-05-28`.

## A.4 SysHalal — infra QR verify

- [ ] 🔧 **Caminho B (decisão 18/jun, status a confirmar)** — regra de listener no ALB
  `ecohalal-fambrashalal-web`: `/verify/*` → container nginx+SPA verify do GC.
  Memória `project_qrcode_verify_domain_pending` diz "NO AR 22/jun" mas a auditoria
  do código `syshalal-api` não encontrou IaC refletindo a regra. **Análise:** confirmar
  se está aplicada na infra AWS (não é evidência de código — é de console/IaC).

## A.5 Cross — dados FAMBRAS aguardando entrega

> Aguardando FAMBRAS entregar pra destravar frentes de ingestão/IA. Bloqueio externo
> consolidado (cada item já tem fonte na seção principal — aqui só agrupa pra visibilidade).

- [ ] ⏳ **CSVs atualizados FM 7.8.1 + 7.8.2 (certs)** — ~3122 certs FM nunca ingeridos.
  Script v4 nunca escrito. Bloqueia [2.2](#22-seed-cadastrocertescopo-fm-78x).
  Fonte: memória `project_ingestao_certifications_fm_parked` (21/jun, status "🟡 Parked").
- [ ] ⏳ **Lista plantas+CNPJ FAMBRAS oficial** — comparar com SysHalal antes de popular
  via UI/script. Fonte: ATA demo SIH In Natura 15/jun.
- [ ] ⏳ **1-2 modelos de certificado de outras certificadoras** (PDFs) — treinar IA p/
  reconhecimento de desossa. Fonte: ATA demo SIH In Natura 15/jun.
- [ ] ⏳ (Fase 2 pós-go-live) **Travas de documento prévio** em couro/raspa/transferência
  — alinhar com Alina.
- [ ] ⏳ (Fase 2 pós-go-live) **Decisão corporativa NF em transferência** (caso JBS).
