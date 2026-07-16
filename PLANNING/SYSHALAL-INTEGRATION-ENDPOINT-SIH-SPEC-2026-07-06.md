# SPEC — Endpoint de integração na SysHalal External API (consumo pelo SIH)

> **Data:** 2026-07-06 · **Status:** PLANO — aguardando discussão com Renato (manhã)
> **Decisão de contexto (Renato, 06/jul ~01h40):** Opção 3 escolhida — rota de integração
> dedicada com api-key própria, fora do modelo usuário/grupo. Opção 1 (vincular api_sih a
> todos os grupos) inviável: 100+ grupos. Opção 2 (flag global no usuário) desvia do padrão.

## 1. Problema

O SIH valida certificados halal de **exportação/venda interna** (os que acompanham cargas)
buscando na SysHalal External API. A autenticação atual é por **usuário de API vinculado a
GRUPO** (`user-token` + `user-owner`) — e cada usuário só enxerga certificados do próprio
grupo. O usuário `api_sih` está no Grupo BRF: enxerga `2607PHJWS` (BRF), não enxerga
`2607FU7I2` (outro grupo). O SIH, como supervisão institucional FAMBRAS, precisa validar
certificado de **qualquer** grupo. Evidência: testes manuais 06/jul (curl 200 pro cert BRF,
`count:0` pro cert de outro grupo, mesmas credenciais).

## 2. Desenho proposto

### 2.1 Lado SysHalal External API (repo a localizar — NÃO está no workspace atual)

Namespace novo **`/integration`**, read-only, autenticado por **`x-api-key`** (mesmo padrão
provado GC↔SIH), **sem filtro de grupo**:

| Rota | Espelha | Uso no SIH |
|---|---|---|
| `GET /integration/certified?certificate-number=` | `/certified` | lookup do HalalCertField |
| `GET /integration/certified_pdf?certificate-number=` | `/certified_pdf` | botão "Ver PDF" |
| `GET /integration/certified_status?certificate-number=` | `/certified_status` | (opcional — decidir) |

Diretrizes de implementação:
- **Reusar** os use-cases/queries existentes das rotas públicas, criando **variante sem o
  filtro de grupo** — NUNCA alterar a query que os parceiros usam (100k+ certs em produção,
  parceiros ativos; risco zero para o fluxo atual).
- Guard dedicado `ApiKeyGuard`: header `x-api-key` validado contra env (lista separada por
  vírgula, ex. `SERVICE_API_KEYS`), chave dedicada pro SIH. Secret no Secrets Manager,
  padrão de nomes do repo SysHalal.
- Mesmo shape de resposta das rotas atuais (`{count, certificates:[...]}` /
  `{messages:[{certificate-pdf: base64}]}`) → o parser do SIH (commit `4a51fd9`) já entende.
- Log de auditoria: registrar consumidor (identificador da key) + certificate-number
  consultado (alinhado ao requisito de audit trail ISO 17065).
- Rate-limit básico se o repo já tiver middleware pronto (não inventar; opcional).

### 2.2 Lado SIH (sih-backend — mudança pequena)

`SysHalalService` passa a operar em **modo dual** (rollout sem quebra):
- Se `SYSHALAL_INTEGRATION_API_KEY` presente → chama `/integration/*` com `x-api-key`.
- Senão → modo legado atual (`user-token`/`user-owner` nas rotas públicas).
- `onModuleInit` (autoverificação já existente) passa a logar o MODO ativo.
- `.env.example` atualizado; task def `sih-api-task` ganha o secret novo
  (`production.SYSHALAL_INTEGRATION_API_KEY_SIH_API`, seguindo o padrão).
- Depois da virada validada: remover/desativar o usuário `api_sih` (ou manter como
  contingência — decisão Renato).

### 2.3 O que NÃO muda
- Frontend do SIH (HalalCertField) — zero mudança; o contrato com o sih-backend é o mesmo.
- Rotas públicas da external API e o modelo usuário/grupo dos parceiros.
- GC — fora deste fluxo (cert de estabelecimento ≠ cert de exportação; ver memória
  `project_dois_tipos_certificado_halal`).

## 3. Sequência de execução

| Fase | O quê | Quem | Est. |
|---|---|---|---|
| **F0** | Renato aponta o **repo** da external API + branch flow + onde roda (infra) e decide as 5 questões da seção 4 | Renato | 10min |
| **F1** | Implementar `/integration/*` + guard + auditoria; deploy em **staging** (`syshalal-external-api-staging.ecohalal.technology`); testar com certs de ≥2 grupos diferentes | Claude (código) + Renato (deploy/autorização) | 0,5–1 dia |
| **F2** | sih-backend modo dual + envs; typecheck; commit em `release` (sem push ainda) | Claude | ~2h |
| **F3** | Deploy external API em **produção** (autorização explícita — SysHalal é prod real) + secret/env na task def SIH + push do sih-backend | Renato autoriza cada deploy | ~1h |
| **F4** | Validação fim-a-fim: `2607FU7I2` (grupo ≠ BRF) verde na UI + PDF abrindo; depois `2607PHJWS` de regressão. Atualizar backlog/roadmap/memória; decidir destino do usuário `api_sih` | ambos | 30min |

**Gate de risco:** SysHalal está em produção real (100k+ certs, parceiros integrando).
Todo deploy do lado SysHalal segue o branch flow do repo (GitFlow develop→staging→release,
deploy no merge em release) e só acontece com autorização explícita do Renato, por
ocorrência. A rota nova é aditiva e isolada — rollback = remover rota/key.

## 4. Decisões em aberto (discutir de manhã)

1. **Onde vive o repo** da external API? (não está em `c:\Projetos\Ecohalal\` — preciso de
   acesso pra dimensionar F1 com precisão; a estimativa assume NestJS no padrão dos demais)
2. **Nome do env/secret** no lado SysHalal (`SERVICE_API_KEYS`? seguir o que o repo já usa?)
3. `/integration/certified_status` entra no escopo ou só `certified` + `certified_pdf`?
4. **Auditoria**: log de aplicação basta, ou tabela de auditoria (quem consultou o quê)?
5. **Usuário `api_sih`**: desativar após a virada, ou manter como fallback documentado?

## 5. Estado atual (pré-plano) — para não re-validar

- Lookup + PDF funcionando fim-a-fim no SIH para certs do **Grupo BRF** (validado 06/jul
  ~01h30 com `2607PHJWS`: selo verde, badge Autenticado, BRF/UAE/invoice).
- Infra SIH ok: `SYSHALAL_API_URL` prod + credenciais na task def (revisão :96+), boot-check
  logando `Integracao SysHalal configurada`.
- sih-backend `4a51fd9` (parse formato real + PDF base64 + boot-check) DEPLOYADO.
- sih-frontend `edcf60d` (status real + destino/invoice) DEPLOYADO.
- sih-frontend `d7e9eaa` (fix "Ver PDF" via axios autenticado + datas UTC) **PUSHADO
  06/jul manhã** — falta só validação na UI (clicar Ver PDF e abrir o PDF da BRF).
- **Execução 06/jul:** F1 pushada (`25c96a6`) e mergeada develop (`89c6e7e`) + staging
  (`6d2c2e7`, CI/CD staging disparado). F2 sih-backend `439d4ea` commitada local, SEM push.
