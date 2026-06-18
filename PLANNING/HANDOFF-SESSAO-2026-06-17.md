# Handoff — Sessão SIH 2026-06-17

> Fechamento da sessão. Tudo de código está **commitado e pushado** em `release`
> (e `development` reconciliado) nos repos `sih-backend` e `sih-frontend`; o roadmap
> público (`halalsphere-backend`) foi atualizado. Nenhuma alteração ficou pendente de commit.

## Entregue e em produção nesta sessão

### FM 20.1 — Ocorrência Aves (registro diário)
- **Schema** `BirdOccurrenceReport` + filhas `BirdDiscTest`/`BirdStunningParam` (decimais); migration `20260616190000` (validada em prod).
- **Backend** módulo de topo `/bird-occurrence-reports` (CRUD + assinatura + workflow controladoria; serial prefixo "OC"); **API Gateway** regenerado.
- **Frontend** lista + form com as 10 seções (pares Sim/Não + 2 tabelas; decimais); menu "Ocorrência Aves" (ícone frango).
- **PDF** template próprio bilíngue.

### Roteamento de notificação por grupo (FM 20.1)
- Tabela `notification_routes` (migration `20260617130000`, validada) + seed das rotas FAMBRAS.
- `EmailService` (AWS SES, espelha o GC) + disparo no `sign()` (resolução por **CNPJ → SIF → default**).
- **CRUD admin** `/notification-routes` (tela Gestão) para a FAMBRAS editar destinatários/membership sem SQL.
- ✅ SES fora do sandbox confirmado → e-mails saem de verdade.

### Histórico de acessos — enriquecimento
- Geolocalização por IP (ip-api) + sinais do navegador; **bug Florianópolis→Barretos corrigido** (flag `ACCESS_LOG_GEO_ENRICH=true`, decisão do PO: free tier no piloto).
- **Loader de SSM no boot** (`parameters.<env>.json` → `process.env`): a partir daqui, **env não-secreta é dirigida por commit→deploy** (não precisa editar a task def na mão). Ver memória `reference_sih_env_vars_source`.
- **Logout** corrigido (race do token no interceptor) — passa a registrar.

### Fase 5A-4 — Frontend do Catálogo de Produtos Halal
- Tela admin `/halal-products` (lista com busca nome/código + filtros; form com EditableTable de códigos). Backend já existia (5A-1/5A-3).

### Padronização de UI — tabelas editáveis em cartões
- Novo `EditableCardList` (layout em cartões, **fim do scroll horizontal**; tipos text/number/date/select/checkbox/time + autocomplete do catálogo).
- Migradas **todas** as tabelas dos relatórios de produção (fabricação, Fracionamento, Gelatina, Heparina Bruta/Purificação, Raspa, Tripas, **Desossa**, **Mucosa**) + `bird-occurrence` + `halal-products`.
- **Autocomplete do catálogo** ligado nos campos de **produto** (nome do produto do relatório, entrada/saída do Fracionamento, produto final da Raspa).
- `EditableTable` virou legado (sem uso). Ver memória `reference_editable_card_list`.

## Verificações concluídas (PO/infra)
- CI/CodeBuild verde (sih-backend `dc34126`, sih-frontend `becce25`, GC roadmap).
- Migrations aplicadas em prod (FM 7.1.6.1, FM 20.1, notification_routes, access_logs enrichment).
- SES fora do sandbox; `[ssm-env]` carregando; logout registrando; geo correta (Barretos).

## Pendências (não dependem de código novo do dev)

### Operação FAMBRAS (pela UI)
- Popular **rotas de notificação** (`matchCnpjs`/`matchSifs` por grupo — hoje só SIF 1155 do JBS).
- Popular **catálogo de produtos por planta** (senão o autocomplete vem vazio).

### Aguarda arquivo da FAMBRAS
- **Fase 5A-2** — ETL em massa do catálogo (aguarda `.xlsx`).

### Aguarda decisão do PO
- **Fase 5B** — Matérias-Primas/Fornecedores (FAM-0017): GC × SIH + 5 decisões. *(destrava autocomplete de Fornecedor/Insumo.)*
- **Vínculo embarque⇄produção (FM 7.1.7.1)** — núcleo entregue; falta análise multi-origem + decisões.
- **Pendências da demo In Natura** — "outros" códigos sanitários; modelos de cert de outras certificadoras (IA da desossa); exceção JBS (NF); versionamento de embarque (Fase 2); travas de documento prévio (couro/raspa).

## Já resolvido (de sessões anteriores, não confundir como pendente)
- Cache stale (12/jun); tratamento de sessão expirada (401→login).
