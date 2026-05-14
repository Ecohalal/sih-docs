# Sessão 2026-05-14 — Publicação do Roadmap Unificado + Hotfix CI/CD

**Duração:** ~6h
**PO:** Renato Ribeiro
**Audiência:** time técnico Ecohalal (referência para continuidade)

---

## TL;DR

1. Roadmap público agora **publicado e unificado** entre Gestão de Certificações e Supervisão Industrial Halal, consumindo de um endpoint único no backend.
2. **CI/CD do halalsphere-backend desentupido** — 4 builds estavam falhando há ~10h por `package-lock.json` dessincronizado; corrigido com `npm install --package-lock-only` + push.
3. **Regra de auto-update obrigatória** do roadmap registrada em memória persistente (atualiza a cada commit de tarefa listada).

---

## Entregas técnicas

### Backend `halalsphere-backend`

- **Módulo `roadmap`** novo em `src/roadmap/`:
  - `roadmap-content.ts` — source-of-truth do conteúdo público (meta + grupos)
  - `roadmap.controller.ts` — endpoint `GET /public/roadmap` com `@Public()` e cache 60s no edge
  - `roadmap.module.ts` — módulo standalone
- **CORS estendido** em `main.ts` para aceitar origens do SIH frontend (production + staging + dev + localhost:5174)
- Commit: `9e447c98` (release)
- Hotfix CI/CD: `4e52cf9e` (lockfile sync, release)

### Frontend `halalsphere-frontend`

- `src/pages/PublicRoadmap.tsx` refatorado para consumir via `useQuery` do backend (não mais import local)
- `src/content/roadmap-public.ts` **removido** — source-of-truth migrou para o backend
- Loading state + error state + suporte ao status novo `in_progress`
- Commit: `cb6bf08f` (release)

### Frontend `sih-frontend`

- `src/pages/PublicRoadmap.tsx` novo — réplica visual idêntica do roadmap, consome do mesmo endpoint
- Nova rota pública `/roadmap` em `App.tsx` (sem `PrivateRoute`)
- URL do backend halalsphere hardcoded em prod (`https://gestaodecertificacoes-api.ecohalal.solutions`); sobrescrevível via `VITE_HALALSPHERE_API_URL`
- Commit: `eba6f73` (release)

### Conteúdo do roadmap

Novo grupo **"Backlog Técnico em Andamento"** com status `in_progress` (azul) para frentes técnicas surgidas durante execução. Primeira entrada: Espelhamento FAMBRAS (FM 7.8.x).

---

## URLs públicas finais

| Sistema | URL |
|---|---|
| Gestão de Certificações | https://gestaodecertificacoes.ecohalal.solutions/roadmap |
| Supervisão Industrial Halal | https://supervisao-industrial.ecohalal.solutions/roadmap |
| Endpoint API (debug) | https://gestaodecertificacoes-api.ecohalal.solutions/public/roadmap |

Mesma fonte; mesma renderização; URL distinta por sistema. Cache 60s no edge.

---

## Bug encontrado e corrigido

### CI/CD halalsphere-backend (builds 188-191 falhando)

**Causa raiz:** `xlsx@0.18.5` foi adicionado em `package.json` no commit `b758ebdd` (mirror-fambras) sem regenerar `package-lock.json`. Dockerfile usa `npm ci` em prod (não pnpm); 4 builds em cascata falharam com "Missing: xlsx from lock file".

**Correção:** `npm install --package-lock-only` para sincronizar. Commit `4e52cf9e`.

**Regra durável registrada** em memória: ao adicionar/remover deps no `halalsphere-backend`, rodar `npm install --package-lock-only` em paralelo ao pnpm. `sih-backend` pode ter o mesmo padrão latente — vale checar preventivamente.

---

## Fluxo de atualização do roadmap (daqui em diante)

1. Editar `halalsphere-backend/src/roadmap/roadmap-content.ts`
2. Atualizar `ROADMAP_META.updatedAt` para a data de hoje
3. Commitar (incluir no commit da tarefa OU commit imediato após)
4. `git push origin release` — CI/CD redeploy do backend em ~3min
5. Ambos os frontends mostram a nova versão sem rebuild (apenas reload)

**Regra obrigatória registrada em memória persistente:** toda entrega/alteração de item listado no roadmap atualiza o array no mesmo ciclo. Não opcional.

---

## Memórias persistidas nesta sessão

- `feedback_roadmap_publico_auto_update.md` (reforçada como **OBRIGATÓRIA**) — fonte de verdade no backend; auto-update a cada commit de tarefa listada
- `feedback_lockfile_dual_npm_pnpm.md` — manter `package-lock.json` sincronizado no halalsphere-backend ao mexer em deps; `sih-backend` requer verificação

---

## Pendências (não bloqueantes)

| Item | Quando atacar |
|---|---|
| Verificar se `sih-backend` tem o mesmo padrão dual pnpm/npm e se já está sincronizado | Próxima sessão técnica do SIH |
| Ícone PWA `icon-192x192.png` do SIH (warning de manifest) | Backlog SIH — bug #6 do smoke test (não-bloqueante) |
| Mudar `halalsphere-backend/Dockerfile` para usar pnpm — eliminaria a fonte do bug do lockfile | Sprint técnica separada (refactor de infra) |

---

## Commits relevantes (release)

| Repo | Hash | Descrição |
|---|---|---|
| halalsphere-backend | `9e447c98` | feat(roadmap): endpoint /public/roadmap |
| halalsphere-backend | `4e52cf9e` | fix(build): package-lock.json sincronizado |
| halalsphere-frontend | `cb6bf08f` | refactor(roadmap): consume /public/roadmap do backend |
| sih-frontend | `eba6f73` | feat(roadmap): publica /roadmap no SIH |
