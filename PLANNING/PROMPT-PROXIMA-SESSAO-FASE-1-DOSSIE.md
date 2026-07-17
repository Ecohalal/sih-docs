# Prompt — Próxima sessão: Fase 1 do Dossiê de Exportação (empoderar o Embarque)

> Cole o bloco abaixo numa sessão Claude Code aberta na pasta do SIH (workspace `Ecohalal`, repos `sih-backend` + `sih-frontend`). É uma sessão de **implementação paralela**, independente das demais frentes.

---

Implementar a **Fase 1 do Dossiê de Exportação** no SIH: empoderar o **Relatório de Embarque (FM 7.1.7.1)** como agregador ("mini-dossiê"), sem criar entidade nova.

**Leia primeiro (fonte da verdade, já escrita):**
- `sih-docs/PLANNING/FASE-1-DOSSIE-EMPODERAR-EMBARQUE-SPEC-2026-06-22.md` ← SPEC completa, é o que implementar
- `sih-docs/PLANNING/DOSSIE-EXPORTACAO-IN-NATURA-ANALISE-2026-06-22.md` ← contexto/visão geral
- Memória `project_dossie_exportacao` ← resumo + decisões

**Contexto-chave:** a base JÁ tem container/lacre/csiNumber/sanitaryDoc*/orderNumber/destinationType(entreposto)/halalCertData+Source/linkedProductions(M:N)/productionSnapshot/attachments(category). NÃO reconstruir nada disso. O delta da Fase 1 é só:

1. **NF-e estruturada** — adicionar `nfeNumber` + `nfeAccessKey` ao `ShippingReport` (≠ `orderNumber`, que é o invoice comercial).
2. **N documentos sanitários** — `sanitaryDocuments Json?` `[{type:'CSI'|'CSN'|'DCPOA', number}]` (caso real aves: 2 CSI). Espelhar o 1º nos campos legados (`sanitaryDocType`/`sanitaryDocNumber`/`csiNumber`) p/ compat + **backfill** dos embarques antigos.
3. **Categorias de anexo padronizadas** — `CSN/CSI/NFE/HALAL_CERT/OUTRO` (campo `category` já existe; padronizar valores + dropdown no upload).
4. **Endpoint agregador read-only** `GET /shipping-reports/:id/dossier` (monta dado existente: docs oficiais + relatórios vinculados + nº cert SysHalal + anexos por categoria) + **Painel do Dossiê** read-only na tela do embarque.

**Comece por:** migration aditiva idempotente (`ADD COLUMN IF NOT EXISTS` + backfill SQL da seção 3.1 da SPEC) → DTO Zod (Create + Update via Base+`.partial()`) → service (persistir + espelhar + allowlist update) → endpoint → frontend.

**Gotchas obrigatórios (checklist pré-deploy):** migration confirmada no DB de prod (não só push); **swagger → API Gateway regenerado** p/ o novo GET; rodar `tsc -b` local antes de pushar; Zod v4 sem `.refine()` no base que sofre `.partial()`; trabalhar na branch `release` (push dispara CI/CD), reconciliar `release→development` depois; **sem termos haram** em mocks/seeds/testes.

**Fora de escopo (é Fase 2, NÃO fazer):** reconciliação multi-origem (pesos/lotes/datas), encadeamento transferência→embarque do entreposto, entidade Dossiê própria. Tudo que a Fase 1 grava no embarque será **lido** (não substituído) pela Fase 2.

**Aceite:** ver seção 5 da SPEC (2+ CSI persistem; NF-e salvo/exibido distinto do invoice; anexos categorizados; `/dossier` retorna tudo numa resposta; painel read-only na tela; backfill OK).
