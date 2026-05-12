# Briefing — Próxima Sessão SIH (Continuação do Smoke Test)

**Sessão anterior:** 2026-05-11/12 (estendida, ~6h)
**Documento de resultados:** [SMOKE-TEST-2026-05-11-RESULTADOS.md](SMOKE-TEST-2026-05-11-RESULTADOS.md)

---

## Prompt sugerido pra começar a próxima sessão

Cole isto pra dar contexto ao Claude:

```
Continuando o smoke test do SIH em prod. Sessão anterior em 2026-05-11/12 fechou:
- Reset prod feito (admin@sih.com / Teste@2026)
- Setup: 3 plantas, 5 usuários teste (sup-IN, sup-IND, ctrl-IN, ctrl-IND, ctrl-gestor) — todos com senha Teste@2026
- Sprint 1 (TASK-02+03) validada — controladoria + segmentação IN/IND ✅
- Sprint 2 (TASK-01+04) validada — duplo check + workflow rejeição/reabertura ✅
- 4 bugs corrigidos durante o smoke (Plant DTO division, naming refactor companyGroup→division, UserForm limit, canCreate controlador)

Quero continuar do BLOCO 3 do smoke test (Sprint 3 — TASK-05 + TASK-08).
Detalhes completos em sih-docs/PLANNING/SMOKE-TEST-2026-05-11-RESULTADOS.md.
Antes de começar, ler esse doc + sih-docs/PLANNING/SMOKE-TEST-SPRINTS-1-5.md
(blocos 3 a 6) pra contexto.
```

---

## Estado de saída da sessão anterior

### Credenciais

- Admin: `admin@sih.com` (senha antiga do Renato, pode ter trocado pela UI)
- 5 usuários teste: senha `Teste@2026`

### Base prod

- **6 system_users** (1 admin + 5 teste)
- **3 plants** (Planta IN Teste, Planta IND Teste, Planta TESTE Divisão 2)
- **2 abate reports aprovados** (`AB-SIF0001/2026/00001` e `AB-SIF0001/2026/00002`, Planta IN Teste)
- **1 production report assinado** (não aprovado) — Planta IND Teste
- Inventário, NCs, anexos, notificações: zerados

### Schema

- Migration `20260511160000_rename_companygroup_to_division` aplicada (manualmente, registrada em `_prisma_migrations` com checksum 'manual')
- Field `companyGroup` agora se chama `division` em `plants` e `system_users`

---

## Pendências bloqueantes a checar antes de seguir

### 1. AUTO_MIGRATE ainda não funciona

A migration do refactor companyGroup→division foi a 2ª vez que AUTO_MIGRATE
não rodou no deploy. **Investigar antes de qualquer feature nova que mexa
em schema:**

- Conferir Task Definition ECS prod — `AUTO_MIGRATE=true` está sendo passado?
- Conferir buildspec.yml + docker-entrypoint.sh — comando `prisma migrate deploy`
  é executado no startup?
- Se sim, ler logs do ECS pra ver se está falhando silencioso

### 2. PWA cache stale

UX bug recorrente — Controladoria não atualiza sem Ctrl+Shift+R. Não é blocker
do smoke test (continua funcionando), mas trava qualquer demo pro cliente.

**Sugestão de investigação:**
- `vite.config.ts` plugin PWA — desabilitar runtime caching de API ou definir `NetworkFirst`
- Audit das mutations TanStack Query — confirmar `invalidateQueries` com keys corretas
- Considerar `refetchOnMount: 'always'` em queries de dashboard

Memória: `project_sih_cache_stale_bug.md`.

---

## Smoke test restante

### BLOCO 2 (Sprint 2) — itens não testados na sessão anterior

- **2.4** Gestor reatribui — necessita 1 relatório novo + 2 controladores. Cenário: sup-IND cria relatório → ctrl-IND assume mas não aprova → ctrl-gestor reatribui pra ctrl-IN. Esperado: `assignedToId` muda; statusHistory tem evento "reassigned"
- **2.5** Aging visual — só inspeção (cores < 24h = verde, 24-48h = amarelo, > 48h = vermelho)
- **2.6** KPIs — já validados visualmente na 2.1/2.2, marcar como verde

### BLOCO 3 — Sprint 3 (TASK-05 + TASK-08)

**3.1** Origem/destino em transferências de embarque:
- Como sup-IN, cria 1 relatório de embarque em cada subtipo de transferência
  (`transferencia`, `transferencia_industrializados`, `transferencia_in_natura`,
  `transferencia_subprodutos`, `transferencia_generica`) preenchendo origem **e**
  destino
- Gerar PDF de 1 → conferir que inclui ambos endereços

**3.2** Degolador condicional bovino vs ave:
- Como sup-IN, novo relatório de abate → species = **ave** → conferir que seção
  "Degolador" (slaughtererName/Doc) **não aparece**
- PDF não inclui identificação do degolador
- Repetir com species = **bovino** → seção Degolador aparece
- Checklist Tasmya do degolador continua presente em ambos

### BLOCO 4 — Sprint 4 (TASK-06 + TASK-09)

**4.1-4.4** Notificações in-app + email SES:
- Como sup-IN, assina relatório → ctrl-IN deve ver badge no sino do header
- Notificação no dropdown linka pro relatório
- Aprovação dispara notificação pra sup
- Rejeição dispara notificação in-app **+ email SES** (verificar caixa de
  entrada do email real do sup-IN-teste = `r.ribeiro@ecotrace.info`)
- Marcar como lida zera o badge

**4.5-4.6** Anexos em embarque:
- Como sup-IN, cria relatório de embarque tipo `venda_*` ou `transferencia_*`
- Seção "Documentos Anexos" visível em rascunho
- Upload PDF ≤ 10MB, categoria CSI → OK
- Upload > 10MB → erro de validação
- Upload `.exe` → bloqueado
- Download via presigned URL S3 → OK
- Após assinar, "Remover anexo" some
- Em relatório de **abate**, seção de anexos **não existe**

### BLOCO 5 — Sprint 5 (TASK-07 + TASK-11)

**5.1-5.3** Desossa + plantas externas:
- Como admin, cria planta externa com certificadora não-FAMBRAS + upload
  do PDF do certificado externo
- Como sup-IN, cria relatório de Produção tipo **Desossa**
- DesossaFields renderiza campos específicos
- Pode selecionar planta externa como origem da carcaça
- PDF inclui nome + SIF da planta de origem, nome da certificadora externa

**5.4-5.7** Cert SysHalal (integração externa):
- Como sup-IN, no Inventário → Recebimento de Carne → Novo
- `HalalCertField` busca cert FAMBRAS real pelo número → preenche dados
  automaticamente, badge "FAMBRAS verificado"
- Link pro PDF abre via proxy `/halal-cert/pdf`
- Cert externo (número fictício) → fallback manual com upload do PDF
- Mesmo componente em BatchInventoryForm e ShippingReportForm

### BLOCO 6 — Pendências infra (não bloqueantes)

- Manifest ícone PWA — publicar `icon-192x192.png` no S3/CloudFront
- AUTO_MIGRATE — depende da investigação acima

---

## Como retomar

1. Abrir DBeaver e conferir estado da base:
   ```sql
   SELECT name, "division", "isActive" FROM plants ORDER BY name;
   SELECT name, role, "division", "isManager" FROM system_users ORDER BY role, name;
   SELECT "serialNumber", status FROM slaughter_reports;
   SELECT "serialNumber", status FROM production_reports;
   ```
2. Abrir janela anônima do navegador (NÃO usar janela normal — PWA cache
   antigo vai atrapalhar)
3. Login admin e/ou supervisor conforme o bloco
4. Seguir o roteiro de [SMOKE-TEST-SPRINTS-1-5.md](SMOKE-TEST-SPRINTS-1-5.md) BLOCO 3 em diante
5. **Cada interação com Controladoria:** Ctrl+Shift+R obrigatório após
   mutations (até o bug do cache ser corrigido)

---

## Achados que viraram melhorias pendentes (fora do smoke)

1. **Cache stale** (PWA + TanStack Query) — projeto separado
2. **AUTO_MIGRATE** ECS — operação CI/CD
3. **Filtro "Todos os tipos"** na Controladoria não retorna nada — bug menor
4. **Route guard ausente** em `/slaughter-reports/new` etc — controlador
   pode abrir form vazio mas backend 403 ao submeter
5. **Cold start ECS** (~1s primeiro hit) — otimização opcional
6. **PWA icon** — asset não publicado

---

## Integração com GC (HalalSphere) e SysHalal — pergunta levantada

Cliente pode questionar: "essa planta tá no HalalSphere também?". **Hoje, não.**

- Plant CRUD do SIH é **standalone** — só toca o banco do SIH
- Existe uma integração leitura: TASK-11 (Sprint 5) consulta API SysHalal
  pra buscar dados de certificado halal (não dados de planta)
- Sync GC↔SIH↔SysHalal está no roadmap como **Fase Futura D** (não implementado)

Se for prioridade do cliente, abrir tópico em sessão separada — não é
escopo do smoke test atual.
