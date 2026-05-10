# Smoke Test — Plant CRUD + refactor multi-país (2026-05-08)

Deploy disparado nesta data: backend `37edd301` (release) + frontend `1f37b395` (release).

Conta de teste criada via API:
- email: `smoke-test+plant-1778246852@ecohalal.solutions`
- taxId: `99888777000852` (`99.888.777/0008-52`)
- userId: `0f4ec767-682f-4908-80c2-4986a2af216e`
- legalName enviado no payload: `Smoke Test LTDA — Plant CRUD 1778246852`
- tradeName: `SmokeTest 1778246852`
- address: `Rua de Teste, 123, São Paulo, SP, 01000-000`

---

## Achados

### #1 — Caracteres especiais corrompidos (não-ASCII)

**Sintoma (visto em `/admin/empresas-pendentes` → modal "Detalhes da Empresa"):**
- `Smoke Test LTDA — Plant CRUD 1778246852` virou `Smoke Test LTDA � Plant CRUD 1778246852`
  (em-dash `—` U+2014 virou replacement char `�`)
- `São Paulo` virou `S�o Paulo` (acento `ã` virou `�`)
- Endereço inteiro: `Rua de Teste, 123, S�o Paulo, SP`

**Hipótese provável (caminho A):** o `curl` que rodei no shell Windows enviou
o body sem garantir charset UTF-8 — ou o shell converteu os caracteres
no parsing antes do curl encodar. Comando usado:
```
curl ... -H "Content-Type: application/json" -d "{... \"São Paulo\" ... \"—\" ...}"
```
Sem `; charset=utf-8` explícito e sem `--data-binary`.

**Hipótese alternativa (caminho B — defeito real do app):**
backend/DB não preservam UTF-8 corretamente — caracteres acentuados normais
(`São Paulo`) não deveriam quebrar em uso normal do frontend.

**Como distinguir (próximos passos):**

1. Cadastrar via **frontend logado** (browser) uma empresa com `São Paulo` no
   address e ver se o admin renderiza correto. Se SIM: bug é só do curl/teste,
   sistema OK em uso normal. Se NÃO: bug real.
2. Verificar no DB direto:
   ```sql
   SELECT legal_name, address->>'city' AS city
   FROM "Company"
   WHERE tax_id = '99888777000852';
   ```
   - Se vier `S�o Paulo` na coluna: está corrompido NO BANCO (gravamos errado).
   - Se vier `São Paulo` na coluna: backend OK, frontend OK, foi só meu curl.

**Decisão sobre correção:**
- Se for o caso (B), provável fix está no `app.use(express.json())` /
  Nest validation pipe → garantir `charset=utf-8` no parser, e/ou
  conferir collation/encoding das colunas (`UTF8` é default em Postgres
  moderno, mas pode estar diferente).
- Se for o caso (A), nenhum fix necessário — só ajustar o smoke test
  (futuro: enviar JSON via `--data-binary @file.json` com arquivo UTF-8 puro).

---

### #2 — Aba "Plantas" não existe no modal de validação admin

**Sintoma:** em `/admin/empresas-pendentes` → modal "Detalhes da Empresa"
**não tem** aba Plantas. Tem só dados básicos (Razão Social, Nome Fantasia,
CNPJ, Status, Endereço, Data de Cadastro) + botões Fechar/Rejeitar/Aprovar.

**Análise:** comportamento esperado pelo design da PR atual.
A aba "Plantas" foi adicionada em **`GroupCompanyDetail.tsx`** (rota
`/grupo/empresa/:companyId`), que é a página de gestão da empresa pelo
próprio grupo dono — não no fluxo admin de validação.

`/admin/empresas-pendentes` (CompanyValidation page) é um modal compacto
para o admin FAMBRAS aprovar/rejeitar — propositalmente enxuto.

**Decisão a tomar:**
- **Opção A** (status quo): manter como está. Admin valida pelos dados
  fiscais; gestão de plantas fica com o grupo dono via `/grupo`.
- **Opção B** (melhoria UX para admin): adicionar uma seção "Plantas
  cadastradas" dentro desse mesmo modal (read-only) ou um link
  "Ver detalhes completos →" que abre `/grupo/empresa/:id`. Útil
  porque admin pode querer ver se a planta tem código sanitário válido
  antes de aprovar.

**Onde encontrar a aba Plantas hoje:**
- Logado como user do grupo: `/grupo` → clicar em uma empresa do grupo
  → aba **"Plantas"** (primeira aba, antes de Certificações e Documentos).
- Logado como admin: pode navegar direto para `/grupo/empresa/{companyId}`
  se souber o ID. Verificar se existe role guard bloqueando admin nessa
  rota — se sim, melhorar.

---

### #3 — REGRESSÃO em `AdminGroupDetail.tsx` (rota `/admin/grupos/:id`)

**Sintomas vistos pelo PO em 2026-05-08:**
- Coluna **CNPJ** mostra `—` (vazio) na tabela "Empresas do Grupo".
- Coluna **Localização** mostra `—` (vazio).
- Card de stats **Certificações** mostra 0 (correto pra essa empresa
  específica, mas o `_count.certifications` foi renomeado para
  `_count.plants` no backend — número podia estar errado em outras
  empresas).
- Empresa na lista NÃO é clicável (sem `onClick`/`<Link>`) — não tem
  caminho pra ir do grupo pra `GroupCompanyDetail` (que tem aba Plantas).

**Causa raiz (lendo o JSX):**
[AdminGroupDetail.tsx:174-188](c:/Projetos/Ecohalal/halalsphere-frontend/src/pages/admin/AdminGroupDetail.tsx#L174-L188)
ainda lê campos legacy primeiro com fallback:
```tsx
{company.razaoSocial || company.legalName}
{company.cnpj || '—'}                              // taxId
{company.cidade || company.city, company.estado || company.state}  // address.city/state
{company._count?.certifications ?? 0}              // _count.plants
```
Como o backend só emite os nomes novos, todos os fallbacks legacy caem
em `undefined`/0. **Esse arquivo escapou do sweep do refactor.**

**Fix necessário (5-10 min):**
- Trocar fallbacks: `legalName ?? razaoSocial`, `taxId ?? cnpj`,
  `address?.city ?? cidade`, `address?.state ?? estado`,
  `_count?.plants ?? _count?.certifications`.
- Tornar a linha clicável: `<Link to={`/grupo/empresa/${company.id}`}>`.
  Isso resolve o achado #2 também (admin chega na aba Plantas).

**Possível impacto em outros lugares:** o sweep do refactor passou nas
páginas que tsc apontava com erro, mas essa página tem campos como
`any` ou interface tolerante, então tsc deixou passar. Vale fazer mais
um grep `razaoSocial|nomeFantasia|cidade|estado|cnpj` filtrando só por
acessos a `company.X` em `.tsx` antes de fechar o smoke.

---

### #1 (ATUALIZAÇÃO) — encoding `�` confirmado em **2 telas distintas**

`Smoke Test LTDA � Plant CRUD 1778246852` aparece tanto em
`/admin/empresas-pendentes` (modal) quanto em `/admin/grupos/:id`
(tabela). Isso significa que o caractere está **gravado errado no
banco** (ou no JSON da resposta) — não é renderização.

A 2ª empresa (`SmokeUTF-8 1778247324`) foi cadastrada com
`--data-binary` + `Content-Type: application/json; charset=utf-8` +
arquivo `/tmp/payload.json` UTF-8 puro. Recarregar o admin e checar
se ela mostra `Acentuação` correto resolverá: se vier OK, o defeito
era do meu primeiro curl. Se vier `Acentua��o`, é do app.

---

## Hotfixes aplicados em release (2026-05-08)

### Hotfix 1 — `1f37b395` pin pnpm@10 no buildspec
CodeBuild estava instalando pnpm v11 (sem `pnpm.onlyBuiltDependencies`)
e travando em ERR_PNPM_IGNORED_BUILDS. Pin garante alinhamento dev local.

### Hotfix 2 — `250d00bd` fix regressões pós refactor multi-país
Sweep inicial deixou 13+ arquivos com leitura só dos campos legacy
(razaoSocial/cnpj/cidade/etc.). Backend só emite os novos nomes —
silenciosamente nada renderizava. Tsc deixou passar porque eram
tipados `any` ou inline. Inverteu fallbacks em todas as telas:

- **components:** CompanyValidationCard, CompanySearchForAccess,
  GroupCompanyList, GroupUsersManager
- **pages admin:** AdminGroupDetail (+linha clicável → `/grupo/empresa/:id`),
  StorageSettings, UserForm, UserList
- **pages operacionais:** ComercialDashboard, ProposalList,
  JuridicoDashboard, ComplaintsDashboard, CompanyDashboard, AcceptInvitePage
- **types:** GroupCompany ganhou taxId/taxIdType/country/_count.plants;
  PendingCompany ganhou shape multi-país completo

Após CodeBuild publicar (deve completar ~2-5 min após push), recarregar
o admin com hard-refresh (Ctrl+Shift+R) e revalidar:

- [ ] `/admin/grupos/:id` mostra CNPJ + cidade + estado preenchidos
- [ ] Linha da empresa abre `/grupo/empresa/:id` (= aba Plantas)
- [ ] Coluna "Plantas" (era "Certificações")
- [ ] `/admin/empresas-pendentes` modal mostra dados sem `—` vazios
- [ ] Encoding `�` deve continuar igual (encoding é decisão à parte)

---

## Próximos achados

(adicionar conforme o usuário for testando)
