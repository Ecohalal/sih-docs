# Prompt para iniciar a próxima sessão (Fase 5)

Cole o texto abaixo no início da próxima sessão (com o VS Code aberto no
compartimento Ecohalal, workspace SIH).

---

```
Retomar SIH — Fase 5 (cadastros de base). Contexto: Fases 0–4 do plano faseado
FAMBRAS já entregues, deployadas em `release` e com migrations validadas em prod.
Leia primeiro:
- sih-docs/PLANNING/HANDOFF-FASES-0-4-2026-06-14.md (estado, migrations, commits, pendências)
- sih-docs/PLANNING/PLANO-FASE-5-CADASTROS-BASE-2026-06-14.md (plano 5A + 5B)
- sih-docs/PLANNING/PLANILHA-MP-FORNECEDORES-FAM-0017-SCHEMA.md (schema 5B já desenhado)

Regras desta dupla (confirmadas na sessão anterior):
- Trabalhar em branch `release`, remote `ecohalal`; push dispara CI/CD.
- Cada fase: aditivo → migration → ETL/seed idempotente → backend → frontend,
  PARANDO para eu validar a migration em prod antes de empilhar a próxima.
- A cada migration, me entregar a query de validação (read-only, com critério PASS).
- Builds + `tsc -b` antes de pushar. Sem termos haram em nenhum artefato.
- Rota nova de MÓDULO DE TOPO exige regenerar API Gateway
  (generate:swagger + generate-api-gateway.js); sub-rota de módulo existente NÃO.

Começar por: 5A (Catálogo de Produtos Halal). Antes de codar, me faça as
perguntas de decisão do PO da Fase 5 (cadência da Lista v143; e as 5 decisões
em aberto da FAM-0017 para o 5B). Depois implemente 5A-1 (schema + migration
aditiva) e pare para validação.
```

---

## Decisões de PO a coletar logo no início

**5A (catálogo de produtos):**
1. A Lista de Produtos Halal v143 (~519 itens) é a fonte única?
2. Cadência de atualização: versão periódica (reimport) vs edição contínua na tela?

**5B (FAM-0017) — 5 decisões ainda em aberto** (3 já confirmadas: RawMaterialMaster global,
Manufacturer global, RevisionLog Opção C). Revisar a lista completa em
`PLANILHA-MP-FORNECEDORES-FAM-0017-SCHEMA.md` / análise mai/2026.

## Lembretes de armadilhas conhecidas (já documentadas em memória)
- Zod v4 `.partial()` quebra com `.refine()` → separar Base/Refined nos DTOs.
- Enum migration idempotente (`ADD VALUE IF NOT EXISTS`).
- Checklist pré-deploy SIH (migrations aplicadas + swagger/API GW se rota de topo + `tsc -b` + build).
- Não presumir resultado de query — pedir output literal.
- Config pendente: supervisor Sameh precisa de planta `processamento` vinculada p/ produção industrial.
