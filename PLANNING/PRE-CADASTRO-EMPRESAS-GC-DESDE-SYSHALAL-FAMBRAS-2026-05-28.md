# Pré-cadastro de Empresas no GC a partir de SysHalal + FM 7.8.x

> **Versão:** 1.0 — 2026-05-28
> **Status:** Projeção concluída, aguarda revisão FAMBRAS antes da ingestão
> **Sessão de origem:** Análise iniciada em 2026-05-27, consolidação em 2026-05-28

---

## 1. Resumo executivo

O GC (Gestão de Certificações / HalalSphere) é o **master** de cadastro de Empresa+Planta+Certificação no ecossistema halal Ecohalal, mas hoje a base do GC está vazia. Os dados reais vivem em duas fontes:

- **SysHalal** (sistema operacional de emissão de cert de exportação por lote) — cadastro ativo de empresas+plantas.
- **FM 7.8.1 / FM 7.8.2 / SUSPENSOS+CANCELADOS** — planilhas FAMBRAS com certificados emitidos.

Este documento descreve o processo de extração/normalização/cruzamento dessas duas fontes para gerar um **pré-cadastro** consolidado pronto para ingestão no GC, com workflow de validação FAMBRAS (`pendingValidation=true`) antes de virar cadastro oficial.

**Números finais:**

| Métrica | Quantidade |
|---|---:|
| Plantas-candidato extraídas do SysHalal | **303** |
| CompanyGroups inferidos (após merge por token) | **150** |
| Companies (1 por CNPJ/taxId completo) | **299** |
| Plants (com sanitary_code FAMBRAS-rastreável) | **271** |
| Certs FAMBRAS consolidados das 3 planilhas | **3.122** |
| Certs ativos | 1.383 |
| Plantas GC com ≥1 cert ativo encontrado | **268** (88%) |
| Match plantas × certs por CNPJ exato | 263 (87%) |
| Plantas sem nenhum cert FAMBRAS | 13 |
| **Certs ATIVOS órfãos** (suppliers FM sem planta no SysHalal) | **814** |

---

## 2. Contexto e decisão arquitetural

### 2.1 Arquitetura halal Ecohalal (ver `project_arquitetura_halal_ecosistema.md`)

```
GC (master de cadastro + cert)  ───►  SIH (operação)
       │                                  │
       └──► SysHalal (cert de exportação por lote)
            só emite se: cert ativa no GC + relatórios em dia no SIH
```

### 2.2 Estado inverso da meta

Hoje o GC está vazio. A fonte da verdade dos cadastros vive em:

| Dado | Onde está hoje | Onde deveria estar |
|---|---|---|
| Cadastro de empresas/plantas | **SysHalal** (cliente Ecotrace, base ativa) | GC |
| Lista de certs emitidos FAMBRAS | **Excel FM 7.8.1 / 7.8.2 / SUSPENSOS** | GC |
| Cert ativa de habilitação | espalhado entre fontes | GC |
| Relatórios de supervisão | SIH | SIH ✓ |

### 2.3 Decisão: pré-cadastro em duas fases

- **Fase 1 — ETL de pré-cadastro** *(este documento)*. Extrair de SysHalal + FM 7.8.x, normalizar, projetar nos modelos do GC (`CompanyGroup`, `Company`, `Plant`, `Certification`). Saída = CSVs para revisão FAMBRAS.
- **Fase 2 — Sync GC→SIH**. Depois que o GC estiver populado e validado, replicação local SIH (`GcSyncService` espelhando padrão do `SysHalalService`). Detalhado em doc separado (a criar).

---

## 3. Fontes

### 3.1 SysHalal (database direto via DBeaver)

API SysHalal prod: `https://syshalal-external-api.ecohalal.solutions/` — limitada (filtros restritos, timeouts em `/certified`).

DB direto via DBeaver superou a API. Schema relevante (`syshalal-api/prisma/schema.prisma`):

| Tabela | Conteúdo |
|---|---|
| `tb_empresa` | Empresa-planta (uma row por CNPJ de filial) |
| `tb_empresa_docs` | Documentos da empresa em rows individuais: `nome_doc` ∈ `{CNPJ, SIF, RUC, IVO, CUIT, NIT-COLOMBIA, NIT-BOLIVIA, INVIMA, SENASAG, IE, IM, RE}` |
| `cx_empresa_aux_tipo` | Tipos da empresa (N:N): ABATEDOURO, PROCESSADORA, EXPORTADOR, IMPORTADOR, TRADING, OUTROS |
| `cx_empresa_grupo_dados` | **Vínculo comercial**, não holding (ver §5.1) |
| `adm_tb_grupo_dados` | Grupos/clientes operadores SysHalal: tipo ∈ `{DESPACHANTE, EMPRESA, TRADING}` |
| `tb_endereco` + `aux_tb_cidades` + `aux_tb_estados` + `aux_tb_paises` | Endereço estruturado |
| `aux_tb_status_empresa` | Status: ATIVO / INATIVO / BLOQUEADO / MIGRANDO |

**Query principal de extração** (Q2 da sessão — pivot multi-país):

```sql
WITH empresa_docs AS (
  SELECT empresa_id,
    MAX(CASE WHEN nome_doc = 'CNPJ'         THEN nr_doc END) AS cnpj,
    MAX(CASE WHEN nome_doc = 'SIF'          THEN nr_doc END) AS sif,
    MAX(CASE WHEN nome_doc = 'RUC'          THEN nr_doc END) AS ruc,
    MAX(CASE WHEN nome_doc = 'IVO'          THEN nr_doc END) AS ivo,
    MAX(CASE WHEN nome_doc = 'CUIT'         THEN nr_doc END) AS cuit,
    MAX(CASE WHEN nome_doc = 'NIT-COLOMBIA' THEN nr_doc END) AS nit_colombia,
    MAX(CASE WHEN nome_doc = 'INVIMA'       THEN nr_doc END) AS invima,
    MAX(CASE WHEN nome_doc = 'NIT-BOLIVIA'  THEN nr_doc END) AS nit_bolivia,
    MAX(CASE WHEN nome_doc = 'SENASAG'      THEN nr_doc END) AS senasag,
    MAX(CASE WHEN nome_doc IN ('IE','IM','RE') THEN nr_doc END) AS doc_outro
  FROM tb_empresa_docs GROUP BY empresa_id
), empresa_tipos AS (
  SELECT cx.empresa_id,
    BOOL_OR(t.nome='ABATEDOURO')   AS is_slaughterhouse,
    BOOL_OR(t.nome='PROCESSADORA') AS is_processor
  FROM cx_empresa_aux_tipo cx
  JOIN aux_tb_tipo_empresa t ON t.id = cx.aux_tipo_empresa_id
  GROUP BY cx.empresa_id
)
SELECT e.id::text, s.nome, e.razao_social, e.fantasia, e.nacionalidade,
       d.*, t.*, ...
FROM tb_empresa e
LEFT JOIN aux_tb_status_empresa s ON s.id = e.flag_status_id
LEFT JOIN empresa_docs        d   ON d.empresa_id = e.id
LEFT JOIN empresa_tipos       t   ON t.empresa_id = e.id
WHERE e.deleted_at IS NULL
  AND e.tipo_pessoa = 'J'
  AND (t.is_slaughterhouse OR t.is_processor)
ORDER BY e.razao_social;
```

Resultado: **303 linhas** (276 BR + 12 PY + 7 AR + 3 CO + 1 BO + 1 INATIVO BR).

### 3.2 Planilhas FAMBRAS (`c:\Projetos\Ecohalal\fambras-references-2026-04\_emails-fonte\Qualidade\Lista de clientes\`)

| Arquivo | Linhas úteis | Formato |
|---|---:|---|
| `FM 7.8.1 - CERTIFICATED PRODUCTS INDUSTRIAL_ATIVOS - 14.05.2026.xlsx` | 909 | .xlsx |
| `FM 7.8.2 - CERTIFICATED PRODUCTS LIST SLAUGHTERHOUSE - 08.04.2026.xlsb` | 451 + 98 + 1192 (3 abas) | **.xlsb** (datas em serial Excel) |
| `SUSPENSOS E CANCELADOS_IND E FRIG_26.03.2026.xlsx` | 126 + 212 + 134 (3 abas) | .xlsx |
| `X FM 7.8.1.S` / `X FM 7.8.2.S` | versão pública resumida (não usada) | .xlsx |

Headers identificados (canônicos): `razao_social`, `cnpj`, `sif`, `endereco`, `cat_gso`, `cat_smiic`, `produto_pt`, `produto_en`, `escopo`, **`cert_num`**, `cert_emissao`, `cert_validade`, `reconhece_golfo`, `normas`, `plataformas` (HAKSIS/BPJPH), `status`, `motivo`.

**Padrão do número de certificado FAMBRAS:**

```
BRF.CNZ.2510.1304.1.BRA
└┬┘ └┬┘ └┬─┘ └┬─┘ │ └┬┘
 │   │   │    │   │  └─ Código país emitente (3 letras: BRA/PAR/COL/ARG/URU/PER/CHI/ECU/BOL)
 │   │   │    │   └─── Revisão (opcional)
 │   │   │    └────── Sequencial
 │   │   └─────────── Ano-mês de emissão (AAMM)
 │   └─────────────── Código da unidade (ex.: CNZ = Capinzal)
 └─────────────────── Código curto da empresa (3-4 letras)
```

Regex de parser:
```python
CERT_RE = re.compile(
    r'^([A-Z]{2,5})\.([A-Z]{2,5})\.(\d{4})\.(\d{2,5})(?:\.(\d+))?\.([A-Z]{2,4})\.?$',
    re.IGNORECASE
)
```

Aplicado a 3.115 cert_num: **3.051 parseados OK (97.9%)**, 64 falham (formatos não-padrão), 7 vazios.

---

## 4. Schema mapping SysHalal → GC

Modelo alvo do GC (`halalsphere-backend/prisma/schema.prisma:946+`):

```
CompanyGroup  1─N  Company  1─N  Plant  1─N  CountryHabilitation
                                       1─N  Certification
```

### 4.1 Mapeamento de fontes para destinos

| Campo GC | Fonte SysHalal | Notas |
|---|---|---|
| `Company.country` | `aux_tb_paises.codigo` → ISO2 (BR/AR/PY/CO/BO) | Mapeado em `COUNTRY_MAP` |
| `Company.taxId` | `tb_empresa_docs.nr_doc` filtrado por `nome_doc` correspondente | CNPJ (BR), CUIT (AR), RUC (PY), NIT (CO/BO) |
| `Company.taxIdType` | derivado do país | enum GC: CNPJ, CUIT, RUC, NIT, … |
| `Company.legalName` | `razao_social_limpa` (após limpeza heurística) | ver §5.3 |
| `Company.tradeName` | `fantasia` | |
| `Company.groupId` | inferido via heurística self-named | ver §5.2 |
| `Company.relationship` | derivado (client / supplier / supplier_industrial / partner_or_client) | ver §5.4 |
| `Company.pendingValidation` | **`true`** (todo pré-cadastro entra pendente) | FAMBRAS valida via workflow G-115 |
| `Plant.companyId` | FK (via dedupe) | |
| `Plant.sanitaryCode` | `tb_empresa_docs` por país (SIF / SENASAG / INVIMA / IVO / Establecimiento_AR) | ver §5.5 |
| `Plant.sanitaryCodeType` | derivado do país + tipo doc | precisa enum atualizado no GC |
| `Plant.name` | `razao_social_limpa` por default (Plant.name no GC é "Unidade X" mas no pré-cadastro usar legalName) | revisar manualmente |
| `Certification.plantId` | join por CNPJ+SIF entre FM cert e Plant projetada | ver §6 |

### 4.2 Tabela origem (SysHalal) → destino (GC)

| Origem SysHalal | Destino GC | Cardinalidade |
|---|---|---|
| `adm_tb_grupo_dados` (subset, com tipo `EMPRESA`) | (não migra direto — só usa pra inferir holding) | — |
| `tb_empresa` (303 plantas-candidato) | 1× `Company` + 1× `Plant` (quando tem SIF) | 1:1 ou 1:1+1 |
| `tb_empresa_docs` | absorvido em `Company.taxId`+`Plant.sanitaryCode` | N:1 colapsado em pivot |
| `cx_empresa_aux_tipo` | informa `relationship` + `Plant.plantType` | — |
| `cx_empresa_grupo_dados` | **DESCARTADO** — é vínculo comercial (ver §5.1) | — |

---

## 5. Heurísticas aplicadas

### 5.1 `cx_empresa_grupo_dados` é vínculo comercial, não holding

**Descoberta na Q3 (2026-05-28):** todas as 4.193 relações em `cx_empresa_grupo_dados` são `tipo='EMPRESA'`, mas a relação NÃO modela "empresa pertence a holding". Modela **"esta planta é origem de produto em certificados de embarque emitidos por essas trading/operadores SysHalal"**.

Evidência:
- **JBS S/A** (planta `…505920`) associada a 10 "grupos" incluindo **Minerva, Fortefrigo, Frigomarca, Better Beef** — concorrentes da JBS, não donos.
- **Pampeano Alimentos** com 27 "grupos" incluindo Frigochaco (PY) e Victoria (PY).
- Padrão: a "associação" reflete que o despachante/trading X emitiu cert de exportação SysHalal apontando essa planta como origem.

**Consequência**: ignoramos o vínculo direto e inferimos CompanyGroup por outras heurísticas (§5.2).

### 5.2 Heurística "self-named group"

Para cada planta, extrair **token significativo** da razão social (1ª palavra ≥3 letras que não esteja em STOPWORDS) e buscar entre os `grupos_cliente` o grupo cujo nome contém esse token.

```python
STOPWORDS = {
  'SA', 'S/A', 'LTDA', 'EIRELI', 'ME', 'EPP',
  'INDUSTRIA', 'INDUSTRIAL', 'COMERCIO', 'ALIMENTOS', 'ALIMENTICIA',
  'ENERGIA', 'SUCOS', 'COURO', 'COUROS', 'CURTUME',
  'CENTRAL', 'COOPERATIVA', 'COOP',
  'AGROINDUSTRIAL', 'CARNES', 'AVES', 'BOVINOS', 'PRODUTOS',
  'CONSERVAS', 'GENEROS', 'DERIVADOS', 'SERVICOS',
  'PROCESSADORA', 'PROCESSADOS', 'PROCESSAMENTO',
  'FRIGORIFICO', 'FRIGORIFICA', 'ABATEDOURO',
  'COMPANY', 'CIA', 'INC', 'CORP',
  'DO', 'DA', 'DE', 'E', 'BRASIL', 'BRAZIL',
  'INTERNACIONAL', 'GROUP', 'GRUPO',
}

def significant_token(name):
    n = strip_pj_suffix(name)
    for tok in normalize_split(n):
        if len(tok) >= 3 and tok not in STOPWORDS and not tok.isdigit():
            return tok
    return None
```

Match: case-insensitive, sem acentos, substring no nome do grupo.

**Resultado**: 247 plantas (81.5%) resolveram com `self_named_match`. Os 56 restantes caíram em `solo_fallback`, dos quais **52 são `provavel_aquisicao_revisar`** (tinham `grupos_cliente` populated mas o token não bateu — candidatos a aquisição tipo `FRIGORIFICO NICOLINI LTDA` → `Grupo BRF`).

### 5.3 Limpeza de razão social poluída (internacionais)

Razões sociais internacionais no SysHalal frequentemente contêm CUIT, endereço e "Establecimiento N" embutidos.

Ex.: `"Elcor S.A. CUIT 30-70023835-7 - Caudillos Federales, 1899 - Villa María - Córdoba - Argentina"`

Heurística em camadas, **mantendo o original**:
1. Corte no `" - "` (primeira ocorrência).
2. Corte em `", "` seguido de dígito.
3. Corte em palavra-chave (`CUIT|AVENIDA|RUA|RUTA|CAMINO|MANZANA|ESTABLECIMIENTO|…`).
4. Se nenhum corte aplica e a string contém ruído → `flag='ambigua_corte_curto'`.

Resultado: **0 razões internacionais ficaram ambíguas**. Distribuição: 12× `corte_palavra_chave`, 7× `fantasia_limpa`, 3× `corte_traco`, 2× `corte_virgula_digito`.

### 5.4 Derivar `Company.relationship`

```python
def derive_relationship(row):
    if row.nacionalidade == 'internacional':
        return 'partner_or_client'      # revisar caso a caso
    if row.is_slaughterhouse or has_sanitary_code(row):
        return 'client'
    if name_matches(INDUSTRIAL_NON_FRIG, row):  # AÇÚCAR|ENERGIA|SUCOS|COURO|BIOQUIMICA|…
        return 'supplier_industrial'
    if row.is_processor and not has_sanitary_code(row):
        return 'supplier'
    return 'client'
```

Resultado: 250 `client` + 24 `partner_or_client` + 18 `supplier_industrial` + 11 `supplier`. Total 303.

### 5.5 Pós-merge por token (resolve "JBS Aves → Grupo JBS")

Caso: `JBS AVES LTDA` (CNPJ raiz `08199996`, distinto de JBS S/A `02916265`) é PJ separada mas pertence à mesma holding. Self-named match não unifica porque os `grupos_cliente` da JBS Aves não contêm `"Grupo JBS"`.

**Pós-processamento**: agrupar por `significant_token`. Se múltiplos `grupo_final` compartilham o mesmo token E pelo menos um veio de `self_named_match`, o canonical é o `grupo_final` daquele self-named com mais plantas. Re-rotular os demais.

Resultado: 13 plantas re-rotuladas, `Grupo JBS` cresceu de 45 → 49 plantas (absorveu JBS Aves), CompanyGroups totais caíram de 161 → 150.

### 5.6 Parser do número de cert FAMBRAS

Ver §3.2. Decompõe em `cert_empresa_code`, `cert_unidade_code`, `cert_anomes`, `cert_seq`, `cert_revisao`, `cert_pais_code`. 97.9% de parsing OK.

### 5.7 Cruzamento FM × GC

Match hierárquico por chave decrescente de confiança:
1. **`cnpj_completo`** (14 dígitos exatos) — 263 plantas (87%).
2. **`raiz_cnpj_e_sif`** (raiz 8 dígitos + sanitary_code) — 6 plantas.
3. **`raiz_cnpj_apenas`** (fallback, pode causar spillover entre filiais) — 21 plantas.
4. **`sem_match`** — 13 plantas.

Total: **290 plantas (96%) com algum cert FAMBRAS associado**, **268 (88%)** com ≥1 cert ATIVO.

---

## 6. Resultados (arquivos gerados em `Integra/`)

| Arquivo | Linhas | Descrição |
|---|---:|---|
| `_cadastro_GC_enriquecido_20260528.csv` | 303 | CSV inicial enriquecido com flags |
| `gc_company_groups_20260528.csv` | 150 | CompanyGroups inferidos |
| `gc_companies_20260528.csv` | 299 | Companies (1 por CNPJ) |
| `gc_plants_20260528.csv` | 271 | Plants (com sanitary_code) |
| `gc_projecao_completa_20260528.csv` | 303 | Projeção full join |
| `gc_revisar_20260528.csv` | 133 | Linhas com qualquer flag pra revisão FAMBRAS |
| `fm_certificados_consolidado_20260528.csv` | 3.122 | Certs FAMBRAS unificados |
| `gc_plantas_com_certs_20260528.csv` | 303 | Plantas + agregados de certs |
| `fm_certs_sem_planta_gc_20260528.csv` | 1.184 | Certs órfãos (sem planta GC correspondente) |

Scripts: `sih-docs/PLANNING/_etl_pre_cadastro_gc_v1.py`, `_etl_pre_cadastro_gc_v2_projecao.py`, `_fm_planilhas_probe.py`, `_fm_parser_consolidado.py`, `_fm_gc_cross_reference.py`.

---

## 7. Decisões pendentes

### 7.1 `Plant.sanitaryCode` opcional no GC ✅ APROVADO (PO Renato, 2026-05-28)

**Problema**: 814 certs ATIVOS FM são órfãos (suppliers tipo IFF Essências 165 certs, DSM 151 certs, Lapiendrius 20, Synergy Aromas 13, …). São fornecedores de aditivos/aromas/nutrição halal **sem SIF** (não são frigorífico). Hoje `Plant.sanitaryCode` é `NOT NULL` no GC.

**Decisão**: opção 1 aprovada — **migration aditiva tornando `Plant.sanitaryCode` nullable** + adicionar `Plant.internalCode` opcional. Também aprova expansão do enum `SanitaryCodeType` (ver §7.2 que faz parte do mesmo escopo).

**Opções avaliadas:**
1. ✅ **Migration: tornar `Plant.sanitaryCode` nullable** + adicionar `Plant.internalCode` (sintético opcional). **Escolhida.**
2. Plant com sanitaryCode sintético (`CNPJ-${cnpj}` ou `SUPPLIER-${seq}`). Feio. Descartada.
3. Supplier no GC fica só como `Company` sem `Plant`. Perde rastreabilidade do cert. Descartada.

### 7.2 Enum `SanitaryCodeType` no GC

Precisa cobrir os tipos reais:
- BR: **SIF** (federal)
- BR: **SIE** (estadual, ex.: `PR 000289-5`, `SP 000564-9` — Louis Dreyfus)
- AR: **ESTABELECIMENTO_AR**
- PY: **IVO_PY** (Establecimiento PY)
- CO: **INVIMA**
- BO: **SENASAG**
- (?) **NULL** ou **NAO_APLICAVEL** para suppliers sem fiscalização sanitária

Verificar enum atual em `halalsphere-backend/prisma/schema.prisma` e propor migration aditiva idempotente (ver `feedback_migration_enum_idempotent.md`).

### 7.3 13 plantas sem_match

Não bateram com nenhum cert FAMBRAS pelos critérios (CNPJ+SIF). Possíveis causas:
- Cadastradas no SysHalal mas **nunca tiveram cert FAMBRAS** (clientes potenciais ou cadastros antigos).
- Cert FAMBRAS existe mas com CNPJ/SIF diferente do SysHalal (erro de cadastro).

**Ação**: revisão manual FAMBRAS dos 13 — confirmar se entram no pré-cadastro ou viram backlog.

### 7.4 52 prováveis aquisições (`provavel_aquisicao_revisar`)

Heurística self-named falhou mas `grupos_cliente` tinha conteúdo. Provável aquisição (Ex.: `FRIGORIFICO NICOLINI LTDA` → `Grupo BRF`). Revisão manual FAMBRAS pra confirmar caso a caso. Cair em `solo_fallback` quando não for aquisição real.

### 7.5 ~300 suppliers de ingredientes (órfãos FM)

Suppliers com cert FAMBRAS ativo mas **não no SysHalal** (porque SysHalal só cadastra frigorífico/processadora-exportador). Estimativa: ~300-400 empresas extras (BRA 1057 certs órfãos / ~3 certs por empresa).

Esses **precisam ser cadastrados no GC** com `relationship='supplier'`. Caminhos:
1. **Aproveitar a planilha FM como fonte** — extrair `(razao_social, cnpj, endereco)` único dos 814 certs ativos órfãos e popular GC como suppliers. Não passa pelo SysHalal.
2. Adicionar lookup CNPJ via cnpj.ws (já mencionado em `feedback_cnpj_lookup_direto.md` do contexto SIH) para enriquecer endereço e razão social.

### 7.6 Plantas JBS/BRF com 85 certs ativos cada

Suspeita de spillover do `raiz_cnpj_apenas` na lógica de match. Validar refinando a heurística: dar prioridade absoluta a `cnpj_completo`, marcar `raiz_apenas` como evidência fraca, exibir pra revisão.

---

## 8. Próximos passos

### Curto prazo (próxima sessão)

1. **Revisão FAMBRAS** dos CSVs gerados (especialmente `gc_revisar_20260528.csv`, `fm_certs_sem_planta_gc_20260528.csv`, `gc_company_groups_20260528.csv`).
2. **Decisão sobre 7.1 e 7.2** (Plant.sanitaryCode nullable + enum). Se aprovado, migration aditiva no GC.
3. **Refinar heurística de match FM × GC** (não fazer spillover `raiz_apenas`).
4. **Extrair suppliers FM órfãos** como Companies-supplier independentes (script v3).

### Médio prazo

5. **Script de ingestão idempotente** no GC (upsert por `(country, taxId, taxIdType)` em Company; upsert por `(sanitaryCode, sanitaryCodeType)` em Plant). Status inicial: `pendingValidation=true`.
6. **Workflow de validação FAMBRAS** (G-111/G-115 já existem no GC) — operacionalizar a transição `pending → verified`.
7. **Cruzamento com CountryHabilitation FAMBRAS** (HAKSIS/BPJPH/SFDA/ESMA — coluna `plataformas` das FM) → popular `CountryHabilitation` por planta.

### Longo prazo

8. **Fase 2 — Sync GC → SIH** (doc separado).
9. **Cleanup SysHalal** — após GC populado, considerar SysHalal como source-only-for-export-certs (não mais master de cadastro).

---

## 9. Apêndice

### 9.1 Stack de scripts

- `_etl_pre_cadastro_gc_v1.py` — enriquecimento inicial do CSV (heurísticas razão social, flags).
- `_etl_pre_cadastro_gc_v2_projecao.py` — projeção CSV→GC (3 tabelas-alvo).
- `_fm_planilhas_probe.py` — inspeção de estrutura das planilhas FM.
- `_fm_parser_consolidado.py` — parser unificado das 3 planilhas FAMBRAS.
- `_fm_gc_cross_reference.py` — cruzamento bidirecional FM × GC.

### 9.2 Credenciais SysHalal API (rotacionar após uso!)

URL prod: `https://syshalal-external-api.ecohalal.solutions/`
Headers obrigatórios:
- `user-token`: <rotacionar após sessão de 2026-05-27/28>
- `user-owner`: `r.ribeiro@ecotrace.com.br`
- Em produção, mover para AWS Secrets Manager.

### 9.3 Referências cruzadas

- `feedback_gc_validationpipe_forbid_nonwhitelisted.md` — validação class-validator no GC.
- `feedback_gc_global_jwtguard_public.md` — guard global JwtAuthGuard.
- `project_arquitetura_halal_ecosistema.md` — papéis dos 3 sistemas.
- `project_conceito_grupo_categoria.md` — modelo conceitual Grupo × Empresa × Categoria.
- `project_refactor_empresa_planta_caminho_a.md` — refator do GC já concluído.
- `reference_syshalal_api.md` — endpoints SysHalal externos.
