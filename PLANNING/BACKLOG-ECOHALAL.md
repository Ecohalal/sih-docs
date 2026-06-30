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
> Última consolidação: **25/jun/2026**.

---

## Índice
- **SIH** — [1.1 Suporte Gabriel/Seara](#11-suporte-gabrielseara-25jun) · [1.2 Embarque multi-origem](#12-embarque-multi-origem--vínculos) · [1.3 SIH⇄GC consumir MP](#13-sih⇄gc-consumir-mp-homologada)
- **GC** — [2.1 FAM-0017](#21-fam-0017-homologação-mp) · [2.2 Seed cadastro/cert/escopo](#22-seed-cadastrocertescopo-fm-78x) · [2.3 Integração GC→SIH](#23-integração-gcsih-endpoint) · [2.4 Reconciliação/limpeza](#24-reconciliação--sqls-limpeza)
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

---

# SysHalal — Sys Halal (legado, exportação)

## 3.1 Fixes / exportação
> Fonte: memória `project_sessao_2026-06-23_syshalal_fixes`. Vários fixes já deployados + reconciliados.

- [ ] 🧩 Hidratação dos certificados **#418 / #422** (pendente). _(da memória — confirmar)_
- [ ] _(colar demais pendências SysHalal)_

---

> **Adicionar frente:** copie um bloco `## X.Y <Frente>` sob o sistema certo, preencha
> os checkboxes e cite a fonte (handoff/memória). Mantenha o Índice no topo atualizado.
