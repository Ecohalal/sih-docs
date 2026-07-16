# Handoff — Sessão 28–29/jun/2026 (GC / HalalSphere)

> ⚠️ **HISTÓRICO — NÃO É FONTE DA VERDADE.** Este handoff descreve o momento em que foi escrito e **pode estar defasado** (vários afirmavam "feito/commitado" para código que o git desmentia). Para o estado atual, leia **`sih-docs/PLANNING/BACKLOG-ECOHALAL.md`**. Use este arquivo só para entender *por que* uma decisão foi tomada.

Foco: **frontend FAM-0017 per-Company**, **integração GC→SIH provada E2E**, **permissões do analista**, polimento de UX e **SQLs de limpeza de dados de teste**. Tudo deployado em `release` e **reconciliado em `develop`** (backend `develop@f851d5c3`, frontend `develop@95152c63`).

> Convenções: estrutura de banco = migration; **carga/limpeza de dados = SQL no DBeaver** (eu gero, Renato roda em PROD). GC trabalha em `release` (remote `origin`); push dispara CI/CD (migrate deploy + `apigateway.sh` aplica o API Gateway). **Prefixo de rota novo no GC = regenerar gateway no mesmo commit** (`npm run generate:swagger` + `node scripts/generate-api-gateway.js`, commitar `swagger.json`+`deploy/halalsphere-api.*.json`). Endpoint service-to-service precisa `@Public()` (há JwtAuthGuard GLOBAL em `auth.module`).

---

## 1. FAM-0017 frontend per-Company (F1–F3) — ENTREGUE
Rota `/homologacao-mp` (abas **MP & Insumos** | **Fornecedores**), no menu de empresa/admin/qualidade/analista:
- **CompanyRawMaterial** (List+Form), **RawMaterialSupplierEntity** (List+Form), **item RawMaterialSupplier** (no detalhe da MP, com review FAMBRAS) + **evidência halal** com **anexo S3** (`StorageService` novo no backend, upload/download presigned).
- Seletor de empresa = **`CompanyCombobox`** (busca server-side nome/CNPJ, mostra cidade) — substituiu o `<select>` de ~560 empresas.
- Form de MP tem **seletor de vínculo "Referência FAMBRAS"** (busca RawMaterialMaster → seta `rawMaterialMasterId`; null desvincula) — resolve o badge "Aguardando vínculo".
- Termo **"Canônica" renomeado para "Referência FAMBRAS"** (era jargão).

**Pendente FAM-0017:** F4 (RevisionLog/integração ScopeSupplier), F5 (U7 `/homologacao-mp` consolidada com grid/import), F6 (import das 28 planilhas restantes), seeds S1 (~40 certificadoras) + S2 (231 intermediários).

## 2. Integração GC→SIH — PROVADA E2E (a continuar no SIH)
- Endpoint **`GET /integration/raw-materials/by-plant?sif=&cnpj=&approvedOnly=`** (auth `x-api-key`, casa planta por **SIF+CNPJ**, devolve MP+fabricante+fornecedor+evidência). Testado em prod (200 + dados Rolândia).
- Auth: segredo `production.SERVICE_API_KEYS_HALALSPHERE_API` (Secrets Manager) → env `SERVICE_API_KEYS` na task def `halalsphere-api-task`.
- ETL piloto **Rolândia** carregado/validado (SEARA, CNPJ `02914460031110`, SIF `1215`): 17 MP / 19 itens / 12 forn / 21 evid / 24 OUTROS. Itens ficam `fambras_review_status=pending` → **`approvedOnly=true` (default) só retorna após a FAMBRAS aprovar** na tela de review.

**PRÓXIMA FATIA (recomendada p/ próxima sessão):**
1. **Cliente HTTP no `sih-backend`** consumindo o endpoint (envs `GC_INTEGRATION_API_KEY` + `GC_INTEGRATION_BASE_URL=https://gestaodecertificacoes-api.ecohalal.solutions`; segredo `production.GC_INTEGRATION_API_KEY_SHI_API` na task def `sih-api-task`). **Decisão pendente do PO: ONDE no SIH** (validação de produção/embarque vs tela read-only). 
2. **Escalar o ETL** p/ as 28 planilhas restantes (heterogêneas: REV 08–11 + JBS/MSP fora do padrão — mapeamento por-REV). Script: `scratchpad/etl_fam0017.py` (uuid5 determinístico).
3. **FAMBRAS aprovar itens** (operacional, via tela de review F3a).

## 3. Permissões do ANALISTA (decisão PO 29/jun) — DEPLOYADO
Analista agora **gerencia (criar/editar/aprovar/rejeitar/EXCLUIR)** todos os cadastros de certificação: Fabricantes, MP de Referência, Intermediários, Certificadoras, Grupos, Empresas/Plantas **e** a homologação MP per-Company. **EXCETO infra** (Armazenamento, Assinatura, Histórico de Acessos, Usuários). Empresa `verify/unverify/hard-delete` seguem admin-only (ops de conta). Backend `@Roles`+analista; frontend `canManage` + itens de menu no perfil analista.

## 4. SQLs de limpeza de TESTE (Renato roda no DBeaver — `halalsphere-backend/prisma/`, helpers não-versionados)
| Arquivo | Apaga | Notas |
|---|---|---|
| `cleanup-test-certifications-full-2026-06-29.sql` | domínio de certificação (52 tabelas, ordem topológica FK) | preserva config (templates/standards = SetNull); transação |
| `cleanup-test-certificates-2026-06-29.sql` | só certificados emitidos | — |
| `delete-test-company-GENERICO.sql` | empresa(s)+grupo(s) por doc/nome | editar 1 linha do filtro; pré-req: certs=0 |
| `delete-test-company-werwerw-2026-06-29.sql` | a Werwerw específica | — |

**Por que não dá pra excluir empresa/grupo pela UI:** hard-delete de empresa é bloqueado em cadeia por `users` (audit trail RESTRICT em ~50 tabelas, ISO 17065). A UI só **desativa** (soft, `isActive=false`) e o grupo exige **0 empresas** (conta inativas). O SQL apaga atividade do user (access_logs/audit_trail/comments/notifications) → users → company (cascade plantas/produtos/FAM-0017) → grupo vazio. (Opção futura: ação admin "Excluir definitivamente" só para empresas Pendentes.)

## 5. Triados (sem ação) 
- `401 /notifications/unread-count` = **expiração de sessão** (some no relogin; não é bug, não é nossa mudança).
- `"message channel closed" / browser-integration.js` = **extensão do navegador** (não é nosso código; some em aba anônima).

## 6. Lições reforçadas (já em memória)
- **Consultar `halalsphere-docs/GUIDES/LICOES-APRENDIDAS.md` SEMPRE** antes de mexer no GC (custou um susto de "CORS" que era gateway não-regenerado).
- GC atrás de API Gateway: prefixo de topo novo → regenerar gateway no mesmo commit (`feedback_gc_apigateway_regen_obrigatorio`).
- JwtAuthGuard GLOBAL → endpoint service precisa `@Public()` (`feedback_gc_global_jwtguard_public`).

## 7. Estado dos branches
- backend: `release@f851d5c3`-ish reconciliado em `develop`. frontend idem (`95152c63`).
- Nada pendente de push. Sem migration nova nesta sessão (StorageService usa colunas já existentes).

---
**Memórias-chave:** `project_sessao_2026-06-29_gc`, `project_gc_sih_integracao_fam0017_2026-06-28`, `project_fam0017_gc_fase1_2026-06-25`, `feedback_gc_apigateway_regen_obrigatorio`, `feedback_gc_global_jwtguard_public`, `feedback_schema_migration_data_dbeaver`.
