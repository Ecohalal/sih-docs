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
> Última consolidação: **30/jun/2026** (incorpora reunião FAMBRAS 22/jun: cert layout/regras + usuários + dossiê).

---

## Índice
- **SIH** — [1.1 Suporte Gabriel/Seara](#11-suporte-gabrielseara-25jun) · [1.2 Embarque multi-origem](#12-embarque-multi-origem--vínculos) · [1.3 SIH⇄GC consumir MP](#13-sih⇄gc-consumir-mp-homologada)
- **GC** — [2.1 FAM-0017](#21-fam-0017-homologação-mp) · [2.2 Seed cadastro/cert/escopo](#22-seed-cadastrocertescopo-fm-78x) · [2.3 Integração GC→SIH](#23-integração-gcsih-endpoint) · [2.4 Reconciliação/limpeza](#24-reconciliação--sqls-limpeza) · [2.5 Emissão manual cert — layout/regras (22/jun)](#25-emissão-manual-de-certificado--layoutregras-reunião-22jun)
- **Cross** — [4.1 Usuários FAMBRAS](#41-usuários-fambras-criar)
- **SysHalal** — [3.1 Fixes / exportação](#31-fixes--exportação)

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
