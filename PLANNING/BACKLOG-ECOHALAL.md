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
> Última consolidação: **30/jun/2026** (incorpora reunião FAMBRAS 22/jun: cert layout/regras + usuários + dossiê + Apêndice de auditoria; **sessão emissão manual FM 7.7.2 Rev 05 + cabeçalho −10% → [2.5.1](#251-emissão-manual-fm-772-rev-05--cabeçalho-10-sessão-30jun)**). **+ Auditoria git dos 6 repos (30/jun): reconciliações release→develop/development TODAS feitas; código 1.3 e endpoint 2.3 já em prod; A1/A2 embarque no backend → [🎯 Plano de Ataque](#-plano-de-ataque--priorizado-consolidação-30jun-via-auditoria-git-dos-3-sistemas).**

---

## Índice
- **SIH** — [1.1 Suporte Gabriel/Seara](#11-suporte-gabrielseara-25jun) · [1.2 Embarque multi-origem](#12-embarque-multi-origem--vínculos) · [1.3 SIH⇄GC consumir MP](#13-sih⇄gc-consumir-mp-homologada) · [1.4 QA Nilsa (sessão 19-22/mai)](#14-qa-nilsa-sih--sessão-19-22mai-3-rodadas)
- **GC** — [2.1 FAM-0017](#21-fam-0017-homologação-mp) · [2.2 Seed cadastro/cert/escopo](#22-seed-cadastrocertescopo-fm-78x) · [2.3 Integração GC→SIH](#23-integração-gcsih-endpoint) · [2.4 Reconciliação/limpeza](#24-reconciliação--sqls-limpeza) · [2.5 Emissão manual cert — layout/regras (22/jun)](#25-emissão-manual-de-certificado--layoutregras-reunião-22jun) · [2.5.1 Emissão manual FM 7.7.2 + cabeçalho −10% (30/jun)](#251-emissão-manual-fm-772-rev-05--cabeçalho-10-sessão-30jun)
- **Cross** — [4.1 Usuários FAMBRAS](#41-usuários-fambras-criar)
- **SysHalal** — [3.1 Fixes / exportação](#31-fixes--exportação)
- **Apêndice — Auditoria 30/jun (esta sessão)** — [A.1 SIH código residual](#a1-sih--código-residual-a-confirmar) · [A.2 SIH operacional](#a2-sih--operacional-residual) · [A.3 GC bloqueios externos](#a3-gc--bloqueios-fora-deste-backlog) · [A.4 SysHalal Caminho B](#a4-syshalal--infra-qr-verify) · [A.5 Cross dados FAMBRAS](#a5-cross--dados-fambras-aguardando-entrega)

---

# 🎯 PLANO DE ATAQUE — priorizado (consolidação 30/jun via auditoria git dos 3 sistemas)

> **Verificado por git em 30/jun** (não "da memória"): nos 4 repos GC+SIH a **reconciliação
> `release → develop/development` JÁ ESTÁ FEITA** (release ahead = 0 em todos). O **código da
> [1.3](#13-sih⇄gc-consumir-mp-homologada)** (SIH consome MP do GC) **já está pushado** em
> release (back `ab0314c`+`91016d8`, front `9c1efb3`+3 melhorias). Os **Itens A1+A2** do embarque
> multi-origem **já estão no backend** (`3114c02` A1, `47a52dd` A2). ⇒ Restou **muito menos
> código** do que o backlog sugeria; o gargalo real é **infra/operacional + bloqueios FAMBRAS**.

**Horizonte: go-live FAMBRAS agosto/2026 (~6 semanas a partir de hoje).**

### 🟥 Sprint imediato — destrava o que JÁ ESTÁ PRONTO esperando 1 ação (dias)
1. **[INFRA] task def `sih-api-task`** — adicionar secret `production.GC_INTEGRATION_API_KEY_SHI_API` + envs `GC_INTEGRATION_API_KEY` / `GC_INTEGRATION_BASE_URL` (nova revisão da task def, manual na AWS). **Sem isso a tela 1.3 — já em prod — dá 503.** [Renato/AWS] → desbloqueia [1.3](#13-sih⇄gc-consumir-mp-homologada).
2. **[UI] Validar deploys SIH** — smoke [1.1](#11-suporte-gabrielseara-25jun) (busca/ordenação/NF/banner/Seara/couro) + tela read-only [1.3](#13-sih⇄gc-consumir-mp-homologada) após (1).
3. **[OPERAÇÃO] Capabilities=`processamento` das 4 Seara** pela UI (admin Lina) — confirmar quais ([1.1](#11-suporte-gabrielseara-25jun)).
4. **[OPERAÇÃO] Criar 4 usuários FAMBRAS** — Mariana+Elaine no GC, Karoline+Osama no SIH ([4.1](#41-usuários-fambras-criar)). **100% destravado, e-mails em mãos.**
5. **[HIGIENE] Limpar working trees** — rodar SQLs de limpeza GC no DBeaver (`cleanup-test-*`); **decidir branch `syshalal-api` `txt_multi_linhas`** (tem WIP não commitado: `package.json`, `pnpm-lock`, draft `Industrializados_SIS_2020_DRAFT.html` + scripts) — commitar ou descartar; commitar 3 docs soltos em `sih-docs` ([A.2](#a2-sih--operacional-residual)).

### 🟧 Curto prazo — código de maior valor demoável (1–2 semanas)
6. **Embarque multi-origem [1.2](#12-embarque-multi-origem--vínculos)** — backend A1+A2 já pushado; falta **UI N-origens + PDF multi-SIF (Item A)**, **datas-range no "Adicionar Produto" (Item B)**, **vínculo embarque⇄produção no controlador (Item C)**. ⚠️ confirmar se a "outra sessão" já avançou antes de tocar.
7. **FAM-0017 [2.1](#21-fam-0017-homologação-mp)** — front per-Company entregue (28-29/jun); falta **F5 (U7 consolidada)** e **F4 (RevisionLog ISO 17065)** — F4 é requisito de acreditabilidade, prioridade sobre F5/F6.
8. **Catálogo Produtos 5A-2 [A.1](#a1-sih--código-residual-a-confirmar)** — autocomplete de produto nos forms (ETL em massa aguarda `.xlsx`).
9. **Render destino no PDF transferência [A.1](#a1-sih--código-residual-a-confirmar)** — campo `destinationType` já no schema; só o render.

### 🟨 Validações não-código (confirmar console/PROD)
10. **Caminho B QR verify [A.4](#a4-syshalal--infra-qr-verify)** — confirmar regra de listener no ALB (memória diz "no ar", auditoria não achou IaC; é console/IaC, não código).
11. **Rodar import IND em prod [A.2](#a2-sih--operacional-residual)** — script commitado, NÃO executado (23 plantas IND).
12. **NC FM 7.1.6.1 — UI criação/aprovação [A.1](#a1-sih--código-residual-a-confirmar)** — schema deployado; confirmar UX completa em prod.

### ⛔ Bloqueado em FAMBRAS — COBRAR, não codar
- **A2 layout datas EN/AR** ([2.5](#25-emissão-manual-de-certificado--layoutregras-reunião-22jun)) — precisa **cert real preenchido** de referência.
- **Logo Indonésia** — Elaine consulta acreditadora.
- **CSVs FM 7.8.1/7.8.2 (~3122 certs)** ([A.5](#a5-cross--dados-fambras-aguardando-entrega)) — destrava seed [2.2](#22-seed-cadastrocertescopo-fm-78x).
- **3 SIFs duplicados** ([A.3](#a3-gc--bloqueios-fora-deste-backlog)) — decisão razão social; pré-req de [2.2 N1a](#22-seed-cadastrocertescopo-fm-78x).
- **5 decisões Fase 5B FAM-0017 (Lina)** ([A.3](#a3-gc--bloqueios-fora-deste-backlog)) — bloqueia parte de [2.1](#21-fam-0017-homologação-mp).
- **Validação quatro-mãos normas FM 41X** ([2.5](#25-emissão-manual-de-certificado--layoutregras-reunião-22jun)) — emitir certs reais espelhando existentes.
- **Lista plantas+CNPJ oficial · 1-2 modelos cert outras certificadoras (IA desossa)** ([A.5](#a5-cross--dados-fambras-aguardando-entrega)).

> **Caminho crítico p/ go-live:** itens 1–4 (dias) → demo estável do consumo MP + usuários ativos.
> Em paralelo cobrar os bloqueios FAMBRAS (sem eles a [2.2](#22-seed-cadastrocertescopo-fm-78x)/seed não anda).

---

# SIH — Supervisão Industrial Halal

## 1.1 Suporte Gabriel/Seara (25/jun)
> Deploy: sih-backend `6e5f43d`, sih-frontend `c6c851b` (antes `f6c9de9`).
> Fonte: `PLANNING/HANDOFF-SESSAO-2026-06-25.md` §7-11 · memória `project_pendencias_sessao_suporte_seara_2026-06-25`.

**✅ Deployado:** capabilities multi-atividade (Seara) · busca de plantas corrigida · ordenação Plantas/Usuários `name asc` · NF estruturada no bloco Documentos + consolidação · autosave local nos 3 forms · couro 7.1.4.5 no embarque · remoção de campos sanitários duplicados.

**🔧 Operacional**
- [ ] Validar deploys na AWS + smoke test (busca, ordenação, NF, banner rascunho, Seara em Fabricação, atalho couro).
- [ ] Configurar `capabilities=processamento` das **4 Seara** pela UI (admin da Lina) — confirmar quais (Montenegro, Itapiranga, Rolândia + ?).
- [x] ~~Reconciliar `release → development` (back e front).~~ **✅ VERIFICADO 30/jun por git:** release ahead of development = 0 nos dois repos SIH (já reconciliado).

**❓ Decisão (Gabriel)**
- [ ] Overlap couro **7.1.4.5 × 7.1.4.9** — se 7.1.4.5 cobre tudo, remover/aposentar `venda_subprod_couro` (7.1.4.9).

## 1.2 Embarque multi-origem / vínculos
> 🚧 Em outra sessão (pacote "saindo hoje"). NÃO duplicar — confirmar antes.
> **⚠️ PARCIAL em prod (verificado 30/jun por git):** o **backend dos vínculos genéricos já saiu** —
> sih-backend `3114c02 feat(producao): vincula relatorio de abate a materia-prima (A1)` +
> `47a52dd feat(embarque): fontes vinculadas genericas abate|producao (A2)`. ⇒ o que falta abaixo é
> sobretudo **UI + PDF**. **Confirmar com a outra sessão o que já foi à UI antes de tocar.**

- [ ] **Item A — múltiplos SIF de origem no embarque (FM 7.1.7.1):** carne de vários frigoríficos no mesmo embarque. Base: `ShippingReport.linkedProductions` (M:N) + `productionSnapshot` (backend A1/A2 já em prod). Falta **UI N-origens + snapshot multi-SIF + PDF**.
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
> **✅ CÓDIGO EM PROD (verificado 30/jun por git):** back `ab0314c` (consumo read-only) + `91016d8`
> (503 informa qual env falta); front `9c1efb3` + 3 melhorias (busca/ordenação/agrupamento/resumo,
> limite plantas, seletor com busca SIF/CNPJ). **Só falta infra + validação.**

- [ ] 🔧 **PRÉ-REQ infra (item 1 do Plano de Ataque):** task def `sih-api-task` precisa de secret `production.GC_INTEGRATION_API_KEY_SHI_API` + envs `GC_INTEGRATION_API_KEY`/`GC_INTEGRATION_BASE_URL=https://gestaodecertificacoes-api.ecohalal.solutions` senão a tela dá **503**.
- [ ] Validar boot/tela read-only após config.

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
> ⭐ **Fonte da verdade: `halalsphere-docs/PLANNING/HANDOFF-SEED-GC-2026-07-02.md`** (limpo; supera o de 30/jun) + memória `project_seed_gc_cadastro_cert_escopo_2026-06-29`. Tooling/SQL em `halalsphere-backend/scripts/etl-fam0017/`.
>
> **Modelo CONFIRMADO (30/jun):** `CompanyGroup`=grupo econômico · `Company`=CNPJ da filial · `Plant`=estabelecimento (SIF estável, **1 SIF↔1 CNPJ** estrito, nullable p/ químicos/casing). Unique GC `(sanitary_code, sanitary_code_type)` está CERTA → **sem migration**. Base DEFINITIVA = `C:\HalalSphere\FM78x_atualizados\` FM 7.8.1(.xlsx)+7.8.2(.xlsb) 25/06 → **652 estab** (571 BR + 81 estrangeiros).

**✅ Feito e COMMITADO em prod (GC):**
- [x] **N0** migration `20260629140000_plant_friendly_qa_seed` (`Plant.displayName` + `qaReviewed`/`qaReviewedAt`/`qaReviewedById`/`seedSource`) — `release@4eb0aeee`, reconciliado develop.
- [x] **N1 enrichment** (652 estab, `load_n1_enrichment.sql`): **619 casaram** → enriquecidos (displayName "Razão — Cidade/UF (SIF n)" + cidade/UF + `seed_source='fm_7_8_25jun'` + `qa_reviewed=false`).
- [x] **Consolidação grupos por NOME** (`merge_grupos.sql`): **579→547** (25 clusters: Marfrig×5, JBS×4, Minerva+DawnFarms, Seara×3, Tereos×3…; reatribui companies/users/shared_suppliers/corporate_documents + delete vazios).
- [x] **N1b-create BR** (`load_n1b_create_br.sql`): **25 criados** (grupos_a_criar=0 → anexados a grupos existentes; SIF-conflito→NULL). Conflitos SIF: 4400/451=casing sem-SIF (correto); 3505/4086=FRIGOMARCA duplicata.

**✅ Feito e COMMITADO em prod (GC) — cont. (sessão 01-02/jul):**
- [x] **fix_frigomarca** executado (removeu duplicata `...000103`). **SIF multi-CNPJ fechado.**
- [x] **Merge ECONÔMICO** (`merge_grupos_economico.sql`, por NOME contra banco vivo): 554→**550** grupos. Seara+FrigSeara→JBS(67), Fortunceres→Minerva(22), Pampeano→Marfrig(15). DawnFarms/JBS Aves/Couros já no merge por nome.
- [x] **N1c** (`load_n1c_missing_plants.sql`+`cleanup_n1c.sql`): 23 plantas faltando criadas (açúcar/álcool 0-planta + 2 traps FRIGOMARCA 4687/MINERVA 2240) + 11 SIFs federais preenchidos. **813 plantas.**
- [x] **N2-core** (`load_n2_certifications.sql`): **1010 Certification** (base×planta) + **1253 Certificate** (mirror) + **4954 MarketScope** (=N3) + CertificationScope shell. Resolução planta em camadas (pri1 SIF/pri2 CNPJ+SIF/pri3 planta única). Estrangeiros excluídos (HOLD).
- [x] **N4** (`load_n4_scope_products.sql`, refresh): **14.817 ScopeProduct** + **2.144 ScopeBrand** (free-text). Parser trata formato tab e lista+Brand.
- [x] **N1d endereços** (`load_n1d_addresses_from_sys.sql`+`cleanup_n1d_addresses.sql`): 291 sobrescritos do **SysHalal** (autoritativo) + ~52 parseados; 16 sem-fonte→QA.
- [x] **Fix market_variant** (`fix_certificate_market_variant.sql`): selos da /verify por mercado (GAC_ENAS 435/BPJPH 371/…).
- [x] **Frontend deployado** (release+staging): crash null sanitaryCode · verify URL `cert.fambrashalal.com.br/verify` + rodapé FAMBRAS + tooltip sidebar · logo FAMBRAS no cert · sweep "HalalSphere"→"Gestão de Certificações".
- [x] **Verificação pública OK** + validações Renato feitas (endereços=0 vírgula, /verify IFF, contador 377).
- [x] **Blindagem de chunk pós-deploy** (02/jul): auto-reload único em `vite:preloadError` (main.tsx) + buildspec sem `rm` antecipado (`s3 sync --delete`) + `Cache-Control` correto (assets `immutable` 1 ano / index.html `no-cache`). _(Commit local em release; push pendente de autorização.)_
- [x] **E-mails demo removidos da tela de Login** (decisão Renato 02/jul, handoff §6). _(Mesmo commit.)_

**✅ N5 (MP/homologação) EXECUTADO EM PROD 02/jul** (memória `project_seed_n5_mp_decisoes_2026-07-02`):
- **26 plantas** carregadas (`plant_map.csv` definitivo, resolvido no banco vivo via `find_n5_plants*.sql`): **504 CompanyRawMaterial · 869 RawMaterialSupplier (100% `approved`, flip do piloto Rolândia incluso) · 785 evidências halal · 28 certificadoras canonicalizadas · ~466 fabricantes · ~579 fornecedores**. Conferência batida (504/504 mps, 869/869 itens).
- Decisões PO 02/jul: lote `approved` (SIH usa `approvedOnly=true` default) · flip Rolândia · só aba MP (OUTROS=N5b) · 322 códigos sintéticos `N5-*` (planilha sem código; `internal_code` NOT NULL).
- **HOLD (complemento N5):** Kinmaster (empresa não cadastrada no GC) · Montenegro (planta empanados ex-Frangosul não localizada) · arquivo `GRUPO JBS` consolidado (SKIP do parser) · aba OUTROS (N5b, estender parser).
- Tooling commitado em `release` (`6b8d779c`+`37bfe38a`); `load_n5_mp.sql` fica fora do git (`.gitignore *.sql`) — regenerável com `python gen_n5.py`.
- **QA FAMBRAS (novo):** HCQ/HGQ/SHC prováveis typos de HQC · certificadora kosher listada como evidência halal no dado cru · planta dup "JBS S/A Pedra Preta" (CNPJ 06945520000153, sem SIF, nome com quebra de linha) · códigos `N5-*`.

**⭐ PRÓXIMO (pós-N5):** espelho GC→SIH de cadastro/cert (`Plant.displayName` + flag cert vigente — handoff 02/jul §7) · complemento N5 (HOLD acima).

**⏸️ Pendente FAMBRAS (NÃO bloqueia N5):**
- [ ] ❓ **N2b categoria M2M** (`n2b_depara_categorias_FAMBRAS.csv`): 9 códigos casam direto (C/CI/CII/DI/G/GI/GII/I/K); **14 a mapear** (C1/CV/D1/L1…; L1/L2=couro talvez criar categoria). Com de-para → gerar `CertificationIndustrialCategory`.
- [ ] ❓ **REVIEW histórico** (`REVIEW-N2-HISTORICO-FAMBRAS.md`): 7 casos (2 casing + 5 transferências) confirmar.
- [ ] ❓ **Certs vencidos-mas-ativos** (ex. Gelita) — revisar validade × lista ATIVOS.
- [ ] ❓ **Estrangeiros (81)** — `n1b_foreign_pending.csv` — **HOLD.**

## 2.3 Integração GC→SIH (endpoint)
> Fonte: memória `project_gc_sih_integracao_fam0017_2026-06-28` + **HANDOFF-SESSAO-2026-06-29 §2**. SIH LÊ do GC; chave SIF+CNPJ.

- [x] ~~Endpoint `/integration/raw-materials/by-plant` + x-api-key — pendente push + env.~~ **✅ FEITO (handoff 28-29/jun §2):** endpoint testado em **prod (200 + dados Rolândia)**; secret `production.SERVICE_API_KEYS_HALALSPHERE_API` → env `SERVICE_API_KEYS` na task def `halalsphere-api-task`. O lado **SIH** desse pipeline = [1.3](#13-sih⇄gc-consumir-mp-homologada).

## 2.4 Reconciliação / SQLs limpeza
> Fonte: memória `project_sessao_2026-06-29_gc`.

- [x] ~~Reconciliar `release → develop` (GC).~~ **✅ VERIFICADO 30/jun por git:** release ahead of develop = 0 (back e front GC já reconciliados; develop = `f851d5c3`/`95152c63`-ish + merges).
- [ ] 🔧 SQLs de limpeza em `halalsphere-backend/prisma/` (untracked, confirmados no working tree 30/jun) — rodar via DBeaver: `cleanup-test-certifications-full-2026-06-29.sql`, `cleanup-test-certificates-2026-06-29.sql`, `delete-test-company-GENERICO.sql`, `delete-test-company-werwerw-2026-06-29.sql`. _(`import-rolandia-fam0017` saiu da lista: já executado 28/jun — piloto — e commitado 02/jul.)_

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

### 2.5.1 Emissão manual FM 7.7.2 Rev 05 + cabeçalho −10% (sessão 30/jun)
> Fonte: esta sessão. Base de comparação: `C:\HalalSphere\Modelos para comparação\` (cert FAMBRAS real × emitido GC).
> Commits **backend** `33b5b3ba` + `10e58856`; **frontend** `1df3bddf`. Migration `20260615140000_manual_cert_code_and_overrides`
> **VALIDADA em PROD** (`scope_products.code` + `certificates.requirements_override`).

**✅ Deployado (release)**
- Datas **Certified since** e **Initial certification cycle date** agora aceitam valor **manual (opcional)** na emissão — PDF
  prefere o salvo; deriva quando vazio. Resolve o gap de certs migrados/históricos (caso real: 2017/2023 saindo como data de emissão).
- Coluna **Code** (código FAMBRAS) por produto — schema + DTO + service + ambos renderers (EN+AR) + form + import CSV.
- **Override** manual de DT / linhas de normas / rótulo "Product type" (`requirementsOverride`) p/ casos onde o mapeamento automático diverge.
- Fix endereço — rua vazia não gera mais `"- – Cidade – Estado"`.
- Fallback **BPJPH** com texto completo (`KEPKABAN 20:2023 / PEPRES 6:2023 / KEPKABAN 78:2023`).
- **Cabeçalho FM 7.7.2 −10%** (título "HALAL CERTIFICATE" + árabe + logo redondo FAMBRAS, centralizados) → elimina o overlap do
  selo **ENAS** no combo **GAC_ENAS** (2 selos empilhados). Validado no cert real `ASDFASEVAWSEC` (render local com bg novo, sem tocar PROD/S3).

**🔧 Operacional / validação**
- [ ] Validar deploy AWS + tela de emissão manual com os campos novos (datas, Code por produto, seção "Ajustes avançados"/override).
- [ ] Confirmar em PROD um cert no **novo cabeçalho** após o deploy. A folga ENAS ficou **justa** — se quiser respiro maior,
  aumentar a redução do título p/ ~13-15% **ou** deslocar os selos ~10pt à direita no código.
- [ ] **Regenerar (forçar)** os certs **já emitidos** que devam exibir o novo cabeçalho — asset estático só vale p/ regerados; novos já saem certos.
- [x] ~~Reconciliar `release → develop` (GC) — ver [2.4](#24-reconciliação--sqls-limpeza).~~ **✅ VERIFICADO 30/jun por git** (release ahead of develop = 0).

**❓ Decisão / follow-up**
- [ ] **Product type em inglês:** entregue como **override manual** (`categoryDisplayOverride`) — NÃO traduzi todo o
  `category-display-map` p/ EN (risco de chutar o texto oficial FAMBRAS por categoria; só o "K" está confirmado:
  "Category K – Production of (Bio) Chemicals"). Se a FAMBRAS quiser EN automático em **todas** as categorias, **precisamos dos textos oficiais por categoria**.
- [ ] **DT 7.1 × 7.4 (categoria K):** mapeamento já refina K→7.1 com subcategoria K-01/K-02; sem subcategoria, default 7.4. Na
  emissão manual o `dtCodesOverride` cobre. Decidir se o form deve permitir **escolher subcategoria** ou se o override basta.
- [ ] **Catálogo `CertificationStandardByMarket`:** popular o texto oficial das normas (BPJPH e demais) via DBeaver, p/ que
  marcar a norma renderize sozinho **sem** override manual. Cruza com **FM 41X** (validação quatro-mãos da [2.5](#25-emissão-manual-de-certificado--layoutregras-reunião-22jun)).

**📌 Notas de reconciliação**
- A decisão inicial desta sessão de **"manter ambas"** (Code + Packing size) foi **superada** pela reconciliação de gabaritos
  (NC 22/jun, `b9102bd9`): ambos os renderers FM 7.7.2 ficaram com **4 colunas** `Nº | Product Name | Code | Product Brand` (sem Packing).
  Code preservado; sem divergência EN×AR.
- **Landscape FM 7.7.1** (`bg-approval-landscape.png`): **não tocado** — Renato confirmou que não tinha o overlap (N/A, registrado p/ rastreio).

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
