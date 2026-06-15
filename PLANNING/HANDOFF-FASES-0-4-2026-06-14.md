# HANDOFF — Plano Faseado FAMBRAS: Fases 0–4 entregues (2026-06-14)

> Base do plano: [PLANO-FASEADO-COBERTURA-FAMBRAS-2026-06-14.md](./PLANO-FASEADO-COBERTURA-FAMBRAS-2026-06-14.md)
> Cobertura do processo real: [COBERTURA-SIH-PROCESSO-EMISSAO-JBS-EXPORTACAO-2026-06-14.md](./COBERTURA-SIH-PROCESSO-EMISSAO-JBS-EXPORTACAO-2026-06-14.md)
> Workflow: branch `release` (push dispara CI/CD). Remote = `ecohalal`. Migrations validadas em prod pelo PO.

---

## 1. Estado por fase

| Fase | Escopo | Estado |
|------|--------|--------|
| **0** | Código sanitário flexível (`sifCode` → `sanitaryCode` + enum BR) | ✅ deployado, migration validada |
| **1** | Documento sanitário CSI/CSN/DCPOA + anexos DCPOA/Croqui | ✅ deployado, migration validada |
| **2** | Produção estruturada (`ProductionRawMaterial` dual-write + lote-mãe) | ✅ deployado, migration validada; backfill NO-OP (base vazia) |
| **3** | **NÚCLEO** — vínculo Embarque⇄Produção (M:N, derivação, snapshot, UI) | ✅ deployado, migration validada |
| **4** | Tabela de produtos por tipo de expedição | ✅ deployado (frontend; sem migration) |
| **5** | Cadastros base (catálogo de produtos + MP/fornecedores FAM-0017) | ⏭️ não iniciada — ver [PLANO-FASE-5-CADASTROS-BASE-2026-06-14.md](./PLANO-FASE-5-CADASTROS-BASE-2026-06-14.md) |

---

## 2. Migrations criadas (todas validadas em prod)

| Migration | Fase | O que faz |
|-----------|------|-----------|
| `20260614150000_fase0_sanitary_code` | 0 | enum `SanitaryCodeType`; `Plant.sanitaryCode/sanitaryCodeType/internalCode`; backfill SIF; DROP `sifCode` |
| `20260614160000_fase1_sanitary_doc` | 1 | enum `SanitaryDocType`; `ShippingReport.sanitaryDocType/sanitaryDocNumber`; backfill por `shippingType` |
| `20260614170000_fase2_production_raw_materials` | 2 | tabela `production_raw_materials`; `ProductionReport.version` |
| `20260614180000_fase3_shipping_production_link` | 3 | tabela `shipping_report_productions` (M:N); `ShippingReport.productionSnapshot` |

Backfill manual (rodado/avaliado pelo PO, NO-OP por base vazia): [BACKFILL-FASE2-PRODUCTION-RAW-MATERIALS.sql](./BACKFILL-FASE2-PRODUCTION-RAW-MATERIALS.sql).

---

## 3. Commits

**sih-backend (`release`):**
- `996247a` Fase 0 — código sanitário
- `b20ff0d` Fase 1 — documento sanitário
- `31aaaa2` Fase 2a/2b — MP relacional dual-write
- `3df6f85` Fase 2c-core — PDF lê relacional/fallback
- `0472218` Fase 3a — fundação M:N
- `9e3ff9b` Fase 3b — derivação + endpoint `derivable-productions` + snapshot
- `22c33af` chore — regenera `sih-api.*.json`

**sih-frontend (`release`):**
- `4dcf990` Fase 0 — frontend (helper `formatSanitaryCode`, PlantForm)
- `efcd225` Fase 1 — bloco Documento Sanitário + anexos
- `291e199` / `17e712b` Fase 2c-core / 2d — MP estruturada (form padrão + heparina/gelatina/fracionamento)
- `b1470c9` fix — filtro de planta por tipo de produção (desbloqueou desossa em frigorífico)
- `a425dcf` / `c56cf22` Fase 3c / 3c+ — UI de vínculo + aplicar derivação
- `a6303d4` Fase 4 — tabela de produtos por tipo

---

## 4. Notas de deploy / infra

- **API Gateway usa `{proxy+}` por módulo.** Rota nova que é **sub-path de módulo já existente** (ex.: `GET /shipping-reports/:id/derivable-productions`) **já fica roteável sem apply estrutural** — `sih-api.*.json` nem muda (segue 34 paths). Só adicionar **prefixo/módulo de topo novo** exige regenerar+aplicar (`npm run generate:swagger` → `node scripts/generate-api-gateway.js` → CI roda `apigateway.sh`).
- **Sem mudança de deps** nas fases 0–4 → lockfiles intactos.
- Roadmap público (halalsphere-backend `roadmap-content.ts`): o item "SIF/SIE" lá é do **GC**, não do SIH — não tocar.

---

## 5. Pendências e follow-ups (não bloqueiam)

1. **Tipos de produção especializados restantes** (mucosa, raspa, couro, tripas, desossa) ainda guardam MP só em `customFields` — estruturar (emitir `rawMaterials[]`) sob demanda. Desossa já tem origens-como-Planta em `customFields.origins`.
2. **Tabela de produtos do embarque é flat** — não representa multi-origem. A composição derivada (Fase 3) fica visível no card "Relatórios de Produção Vinculados" e há botão para puxar identidade+séries Halal; o enriquecimento multi-origem na própria tabela é evolução futura.
3. **Validação condicional por perfil (Fase 4)** entregue como **leve/não-bloqueante** (decisão do plano). Endurecer (campos obrigatórios bloqueando salvar) = etapa dedicada se a FAMBRAS pedir.
4. **RevisionLog (ISO 17065)** — `version` já existe em `ProductionReport`; um log dedicado (quem/quando/o quê) é decisão de escopo.
5. **Config (não é código):** supervisor **Sameh Kamal** só tem frigoríficos vinculados → para **produção industrial** (heparina/gelatina) ele precisa de uma planta tipo **`processamento`** vinculada no cadastro. Para **desossa** já funciona.

---

## 6. Como validar (funcional)

- **Fase 3 (núcleo), via UI:** editar um embarque rascunho → card "Relatórios de Produção Vinculados" → selecionar produções da mesma planta → ver composição derivada (séries Halal, origens multi-SIF) → botão "Preencher produtos e séries Halal". Assinar congela `productionSnapshot`.
- **Fase 3, via SQL (sem assinar):** após vincular, `GET /shipping-reports/:id` retorna `derivedComposition`. Ou ver `productionSnapshot` após assinar:
  `SELECT jsonb_pretty("productionSnapshot") FROM shipping_reports WHERE id='<id>';`
- **Fase 4:** trocar o tipo de expedição no form e conferir que as colunas da tabela de produtos mudam (exportação=completa, transferência=reduzida, subprodutos=mínima).
