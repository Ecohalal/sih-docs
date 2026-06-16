# Prompt — próxima sessão (Ocorrências FM 20.1) — 2026-06-16

> Cole o bloco abaixo para retomar. Contexto e regras já condensados.

---

```
Retomar SIH — Prioridade #1, passo 3: FM 20.1 (Ocorrência diária — aves).

Contexto: a Não Conformidade (FM 7.1.6.1) já está COMPLETA em produção
(schema + backend + frontend). Falta só o FM 20.1, que é OUTRO formulário:
a "ocorrência = mapa do que aconteceu no dia" (registro diário de abate de
aves), distinto da NC. Decisões da Elaine e o schema proposto estão em:
- sih-docs/PLANNING/SPEC-OCORRENCIAS-NC-FM716-FM201-2026-06-16.md (§B + Respostas Elaine)
- memória: project_ocorrencias_nc_progress, project_demo_sih_in_natura_2026-06-15

Regras desta dupla (confirmadas):
- Branch `release`, remote `ecohalal`; push dispara CI/CD (AUTO_MIGRATE aplica migrations).
- Ritmo: aditivo → migration → ETL/seed → backend → frontend, PARANDO a cada
  migration para eu validar em prod (você me entrega a query read-only com
  critério PASS) antes de empilhar a próxima.
- Builds + `tsc -b` (frontend) e `npm run build` (backend) antes de pushar.
- Sem termos haram em nenhum artefato.
- Rota de MÓDULO DE TOPO novo exige regenerar API Gateway
  (generate:swagger + generate-api-gateway.js); sub-rota de módulo existente NÃO.
- Migrations à mão (SQL), conferidas com `prisma migrate diff`. Decimal:
  z.coerce.number no DTO + Number() na leitura no front (Prisma Decimal → string).

Tarefa (FM 20.1), nesta ordem, parando para validar a migration:
1. Schema: `BirdOccurrenceReport` (espécie fixa = ave; workflow padrão dos
   relatórios: serialNumber, status, signed/hash, assigned, statusHistory,
   version) + filhas `BirdDiscTest` (testes de disco) e `BirdStunningParam`
   (insensibilização, 1º/2º monitoramento, decimais). Migration aditiva. PARAR.
2. Backend: módulo de topo `/bird-occurrence-reports` (CRUD + reusa
   report-workflow.util + generateSerialNumber, prefixo p.ex. "OC"); DTOs Zod.
   → REGENERAR API GATEWAY (módulo de topo novo).
3. Frontend: form com as seções do FM 20.1 — pares S/N com contagem/descrição
   condicional (reusar padrão do abate) + 2 EditableTable (disco; parâmetros de
   insensibilização) com decimais; tópicos fixos = seções do form (não categorias).
4. PDF: template próprio (reusa pdf-helpers).
5. Notificação por grupo (Seara/JBS → Mohamed; BRF/Outras → Adel) é metadado de
   notificação, não do relatório — modelar à parte/depois.

Comece pelo schema (passo 1) e pare para eu validar a migration.
```

---

## Estado em 16/jun (para referência)

**Em produção hoje:** transferência (destino/entreposto + CNPJ + PDF), self-service
de senha, histórico de acessos (+LOGOUT, sessão 8h), Fase 5A catálogo de produtos,
cadastros de planta (tipos curtume/entreposto, espécies bubalino/ovino/caprino,
`Plant.cnpj`, unique+cnpj), import de 23 plantas IND + supervisores (via SQL no
DBeaver), filtro de divisão em Usuários, Abate (decimais, degolador removido,
insensibilização obrigatória), Embarque (SIF por produto + PDF), e **NC FM 7.1.6.1
completo**. Roadmap público atualizado.

## Backlog (fora do FM 20.1)
- **Fase 5A-2/5A-4** — ETL (aguarda .xlsx FAMBRAS) + frontend do catálogo (em hold).
- **Fase 5B** — MP/Fornecedores (FAM-0017): decidir GC × SIH + reconfirmar 5 decisões.
- **SESSION_EXPIRED** no histórico de acessos — best-effort (follow-up).
- Relabel cosmético "Nº do Relatório Halal" (= serialNumber) — opcional.
- Pendências do PO da demo ainda abertas: lista de "outros" códigos sanitários,
  1-2 modelos de cert de outras certificadoras (IA desossa), exceção JBS (NF),
  versionamento de embarque (Fase 2), travas de documento prévio (couro/raspa).
