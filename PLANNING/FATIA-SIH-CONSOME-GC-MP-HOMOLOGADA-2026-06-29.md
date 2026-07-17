# Fatia — SIH consome MP homologada do GC (tela read-only) — 29/jun/2026

Continuação da **Fatia 2.1** do `HANDOFF-SESSAO-2026-06-29.md`: o SIH passa a **ler**
(read-only) a MP/fornecedores homologados no GC (Gestão de Certificações), que já
expõe o endpoint service-to-service provado E2E (Rolândia, 200 OK).

Decisão de PO desta sessão: **começar pela tela read-only** (menor risco), antes de
acoplar a MP do GC à validação de produção/embarque.

---

## O que foi implementado (código)

### `sih-backend` (branch `release`)
- Novo módulo **`src/gc-integration/`**:
  - `gc-integration.types.ts` — espelha a resposta do GC.
  - `gc-integration.service.ts` — resolve **SIF (`plant.sanitaryCode`) + CNPJ (`plant.cnpj`)**
    a partir do `plantId` do SIH e chama o GC via `fetch` nativo + `AbortSignal.timeout`
    + header **`x-api-key`** (padrão `ip-geo.service`, sem dep nova). Propaga 404
    (planta sem cadastro no GC), 503 (GC indisponível/não configurado), 400 (planta
    sem SIF/CNPJ). `onModuleInit` loga o estado efetivo da config (autoverificação de deploy).
  - `gc-integration.controller.ts` — `GET /gc-integration/raw-materials/by-plant?plantId=&approvedOnly=`,
    JWT global + `@Roles('admin','coordenador','supervisor','operador','controlador')`.
  - `gc-integration.module.ts`, registrado em `app.module.ts`.
- `.env.example`: removido `GESTAO_API_URL` (órfão) → **`GC_INTEGRATION_BASE_URL`** +
  **`GC_INTEGRATION_API_KEY`** (+ `GC_INTEGRATION_TIMEOUT_MS` opcional).
- `deploy/parameters.production.json`: **`GC_INTEGRATION_BASE_URL=https://gestaodecertificacoes-api.ecohalal.solutions`**
  (carregado no boot via `load-ssm-env.ts` → não precisa editar task def p/ a base URL).
- **API Gateway regenerado** (rota de topo nova): `npm run generate:swagger` +
  `node scripts/generate-api-gateway.js` → commitar os 3 `deploy/sih-api.*.json`
  (prefixo `gc-integration/{proxy+}`). `swagger.json` é gitignored no SIH (o CI aplica
  os JSONs já commitados via `apigateway.sh`).
- **Sem migration** (passthrough, não persiste).

### `sih-frontend` (branch `release`)
- `src/services/gc-raw-materials.service.ts` — hook `useGcRawMaterials(plantId, approvedOnly)`
  (axios `api` existente; `retry:false` p/ mostrar 404 na hora).
- `src/pages/gc-raw-materials/GcRawMaterialsList.tsx` — seletor de planta (`usePlants scope:'all'`),
  toggle "Somente aprovados | Todos os status" (default aprovados), tabela shadcn
  read-only com Evidência halal + badge de status; estados loading/erro/vazio.
- Rota `/gc-raw-materials` em `App.tsx`; item de menu **"MP Homologada (GC)"** no `Sidebar.tsx`.
- `tsc -b` limpo.

---

## ⚠️ Pré-requisito de INFRA (manual — Renato/AWS, antes de valer em prod)

Sem isto, o endpoint responde **503 "Integração com o GC não está configurada"**
(o deploy do código é seguro mesmo assim — só não retorna dados até a infra existir).

A **base URL** já vai versionada (`parameters.production.json` → SSM → boot). A **única
parte manual** é o **segredo** (não vai no JSON; secrets vêm da task def via `valueFrom`):

1. **Chave**: reutilize uma das chaves já em `production.SERVICE_API_KEYS_HALALSPHERE_API`
   (lista CSV que o GC valida no `x-api-key`). Reutilizar evita redeploy do GC.
2. **Secret** no Secrets Manager (us-east-1): criar `production.GC_INTEGRATION_API_KEY_SHI_API`
   tipo *plaintext* = a chave do passo 1. Copiar o ARN.
3. **Task def `sih-api-task`** → nova revisão → container `sih-api` → adicionar **secret**
   (ValueFrom): nome `GC_INTEGRATION_API_KEY`, value = ARN do passo 2.
4. **IAM**: garantir que o *execution role* da task tem `secretsmanager:GetSecretValue`
   nesse ARN (se o escopo for por prefixo `production.*`, já está coberto).
5. **ECS service** do sih-api → Update → selecionar a revisão nova → **Force new deployment**.
   Fazer isto ANTES do push, para a revisão com o secret virar a "corrente" — o deploy do
   CI cria a próxima revisão em cima dela (só troca a imagem), preservando o secret.

---

## Próximas fatias (continuam o handoff)
- Acoplar a MP aprovada do GC à **validação de produção/abate** (autocomplete/trava de
  escopo) e/ou ao **embarque** — decisão de PO posterior.
- Escalar o ETL FAM-0017 p/ as 28 planilhas restantes (lado GC).
- FAMBRAS aprovar itens via tela de review (operacional).
