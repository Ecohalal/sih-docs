# Handoff — Sessão 24–25/jun/2026

Resumo do que foi **entregue em produção** e do que fica **pendente**. Convenção firmada nesta sessão: **mudança de estrutura de banco = migration**; **inserção/carga de dados = SQL manual no DBeaver** (gerado aqui, Renato executa).

---

## 1. Reunião FAMBRAS 24/jun (Industrializados)
Transcrição: `sih-docs/Reuniões/alinhamento_2406.md`. Interlocutor: controladoria (Ayman, Gabriel, Walid). E-mail do Gabriel (24/jun) com dados/escopo; anexos em `sih-docs/Reuniões/MP E ESCOPO/` (29 planilhas FM 7.4.2.7) e `sih-docs/Reuniões/` (FM 7.1.4.7, FM 7.6.1).

Usuários criados na call (perfil **Coordenador**): Gabriel, Walid, Ayman. Senha provisória `SIH@2026`.

## 2. Cadastro de unidades FAMBRAS — EXECUTADO em PROD (DBeaver)
SQL gerado em `sih-backend/prisma/` (helpers, não versionados):
- `import-curtumes-jbs-2026-06-24.sql` → **9 unidades** (8 JBS Couros `type=curtume` + Acquion `processamento`), todas IND/bovino.
- `import-fambras-extra-2026-06-25.sql` → **3 unidades** (BFB SIF 5423; Way Solutions Boi Santo+Pepcol = **1 cadastro**, mesmo CNPJ 55.407.134/0001-13; Padoca/Maricota **sem SIF** = NAO_APLICAVEL).
- **Pendente FAMBRAS:** ~39 empresas de couro (FM 7.1.4.5), sem MP/escopo — Gabriel envia depois.

## 3. SIH — 2 formulários novos (deployados via `release` + reconciliados em `development`)
| Form | Modelagem | Migration | Commits (back/front) |
|---|---|---|---|
| **FM 7.1.4.7** Produção e Transferência (Pele Bovina) | variante `ShippingType=transferencia_pele_bovina` (reuso máximo) | `20260624140000_add_transferencia_pele_bovina` | `31e07f0` / `25cf14c` |
| **FM 7.6.1** Coleta de Amostra | **entidade nova** `SampleCollectionReport` (+ item filho), espelha BirdOccurrence | `20260625120000_fm761_sample_collection` | `2bba7cc` / `e7e2b64` |

## 4. GC (HalalSphere) — FAM-0017 (homologação de MP e fornecedores, FM 7.4.2.7)
**Decisão do PO (25/jun): caminho COMPLETO, no GC** (não SIH, não enxuto). SPEC: `sih-docs/PLANNING/PLANILHA-MP-FORNECEDORES-FAM-0017-{,SCHEMA,UI}.md`. Branch `release` (remote `origin`) → reconciliado em `develop`. RevisionLog: começar **sem particionamento** (manter `version:Int`).

**Schema backend FAM-0017 FECHADO (F1+F2+F3):**
| Fase | Conteúdo | Migration | Commit |
|---|---|---|---|
| F1 | catálogos globais: HalalCertifyingBody, Manufacturer, RawMaterialMaster, PreApprovedIntermediateMaterial (+ CRUD, workflow approve/reject) | `20260625130000_fam0017_phase1_global_catalogs` | `ff150cd5` |
| F1b | telas admin dos 4 catálogos (frontend) | — | `082e2963` |
| F2 | per-Company: CompanyRawMaterial, RawMaterialSupplierEntity (+ CRUD, escopo por empresa) | `20260625150000_fam0017_phase2_company_layer` | `ae2801d7` |
| F3 | vínculos + evidência: RawMaterialSupplier (item + review), RawMaterialHalalCertification (define vigente), RawMaterialUseInFinalProduct, NonFoodInput | `20260625170000_fam0017_phase3_links_evidence` | schema `b73088d2` / endpoints `c8923bc5` |

Endpoints novos GC: `/halal-certifying-bodies`, `/manufacturers`, `/raw-material-masters`, `/pre-approved-intermediate-materials`, `/company-raw-materials`, `/raw-material-supplier-entities`, `/raw-material-suppliers` (+`/:id/review`), `/raw-material-halal-certifications`, `/raw-material-uses`, `/non-food-inputs`. Roadmap público atualizado em `halalsphere-backend/src/roadmap/roadmap-content.ts`.

## 5. PENDENTE FAM-0017
- **Frontend per-Company (F2/F3)** — telas no dashboard da empresa (CompanyRawMaterial, fornecedores, item+evidência). [maior valor demoável]
- **F5 — UI U7** `/homologacao-mp` (tela única de homologação).
- **F4** — FK opcional em `ScopeSupplier`/`SupplierHomologation` (sync one-way) + **RevisionLog** (audit ISO 17065).
- **F6** — import das 29 planilhas → carga via DBeaver (quando definido o mapeamento).
- **Seeds** — S1 (~40 certificadoras dedup de 77) + S2 (231 intermediários) → DBeaver quando curados.

## 6. Memórias relacionadas
`project_fam0017_gc_fase1_2026-06-25`, `project_sih_forms_couro_coleta_2026-06-24`, `project_cadastro_unidades_fambras_2026-06-24`, `feedback_schema_migration_data_dbeaver`.

---

# Sessão SUPORTE 25/jun (tarde) — Gabriel + reunião rápida

> Suporte ao Gabriel (FAMBRAS) via mensagens + reunião rápida. Vários ajustes
> **deployados** (push em `release` dos dois repos). Transcrição da reunião na conversa.

## 7. Deploys (push em `release`)
- **sih-backend** `2bba7cc..6e5f43d` — roda **2 migrations** no deploy:
  - `20260625160000_plant_capabilities`
  - `20260625170000_shipping_invoice_number` (backfill + limpeza de customFields)
- **sih-frontend** `f6c9de9..c6c851b` (CodePipeline).
- Também antes: frontend `f6c9de9` — removeu campos sanitários duplicados de "Campos Adicionais".
- **Validar publicação na AWS + smoke test** (pipelines não acompanháveis daqui).

## 8. O que entrou nesta sessão

### Planta multi-atividade — `Plant.capabilities[]` (caso Seara)
Planta que faz **abate E processamento no mesmo SIF/CNPJ** (Seara: Montenegro, Itapiranga,
Rolândia + 4ª) não cabia (type escalar; unique `[sanitaryCode,sanitaryCodeType,cnpj]` barra 2
registros). Decisão Renato: `capabilities PlantType[]`; filtros dos forms casam **type UNIÃO
capabilities** (helper `plantMatchesTypes()`). Cadastro com multi-select "Também atua como";
lista com badges. **Pendência:** marcar as 4 Seara com capability `processamento` **pela UI**
(admin da Lina) — SQL descartado por decisão; orientação ao usuário já entregue. Marfrig Hulha
Negra: atividade única → Renato trocou para `processamento` na UI (sem capability).

### Busca de Plantas + ordenação
- **Bug corrigido:** busca de plantas — cláusula de CNPJ virava `contains:''` para termo sem
  dígitos e casava todas, anulando o filtro. Agora só entra com dígitos.
- Ordenação: **Plantas** e **Usuários** → `name asc` (alinha com Colaboradores/Produtos).
  Relatórios seguem `createdAt desc`.

### Item 5 — Nota Fiscal no bloco "Documentos" (embarque)
`ShippingReport.invoiceNumber` virou campo estruturado de 1ª classe (todos os tipos), ao lado
do Número do Pedido. PDF atualizado. Migration faz **backfill** do `customFields.invoiceNumber`
e remove a chave (sem perda). Removidas cópias duplicadas (ShippingExtraFields,
TransferenciaPeleBovinaFields).

### Item 8 — Autosave local anti-perda
`useFormDraft` + `DraftRestoreBanner`: salva rascunho em **localStorage** enquanto preenche,
restaura ao reabrir, avisa ao sair. **Zero custo de banco.** Aplicado em Embarque, Produção,
Abate. (Premissa corrigida: o sistema **não** salvava local antes.)

### Item 3 — Couro FM 7.1.4.5 no embarque/venda
Form de produção aceita **`?productionType=`** (deep-link). Sidebar (Subprodutos) ganhou
**"Venda/Prod. Couro (7.1.4.5)"** → abre o form de produção couro. ⚠️ **A confirmar com
Gabriel:** overlap com `venda_subprod_couro` (FM 7.1.4.9) — se o 7.1.4.5 cobre tudo, avaliar
remover o 7.1.4.9.

### Suporte (sem código)
- Diferença "Documentos" × "Campos Adicionais" explicada ao Gabriel.
- Marfrig Hulha Negra não aparecia em Fabricação por ser frigorífico (filtro por tipo) — não
  era bug; resolvido via capabilities/troca de tipo.

## 9. Decisões 25/jun (tarde)
Item 5 → estruturado+consolida (feito). Item 3 → expor 7.1.4.5 no embarque (feito).
Item 8 → autosave localStorage (feito). Planta dual-tipo → `capabilities[]` (feito).

## 10. Pendências da reunião (pacote do Renato "saindo hoje" — NÃO mexidos aqui)
- **Múltiplos SIF de origem** no embarque (FM 7.1.7.1) — vínculo embarque⇄ProductionReport M:N.
- **Range de datas** (abate/produção/validade) no "Adicionar Produto".
- **Vínculo embarque⇄produção visível no controlador** (Gabriel: produção 7.1.8.5 Cacoal +
  embarque 7.1.4.9, não achou o vínculo).

## 11. Follow-ups
- [ ] Validar deploys na AWS + smoke test.
- [ ] Renato: configurar capabilities das 4 Seara pela UI.
- [ ] Confirmar com Gabriel overlap couro 7.1.4.5 × 7.1.4.9.
- [ ] Reconciliar `release → development` (backend e frontend) conforme fluxo.
