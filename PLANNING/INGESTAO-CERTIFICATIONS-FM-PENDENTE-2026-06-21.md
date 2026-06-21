# Ingestão de Certifications FM no GC — pendente

> **Status:** 🟡 Parked — aguardando dados atualizados da FAMBRAS antes de prosseguir.
> **Última verificação:** 2026-06-21
> **Origem:** sessão 28/mai/2026 (preparação go-live); pendência identificada na auditoria de retomada em 21/jun.

---

## TL;DR

Existem 3122 certs no consolidado FAMBRAS de 2026-05-28 que **nunca foram ingeridos no GC**. Em prod hoje há só 8 `certifications` (testes de UI). Os ~766 Plants estão sem cert vinculada. Para o go-live FAMBRAS de **agosto/2026** isso precisa fechar, mas **os CSVs de 28/mai já estão com ~25 dias** — vale pedir dados frescos pra FAMBRAS antes da ingestão pra não meter cert cancelada/substituída desde então.

---

## Estado atual de prod GC (verificado 2026-06-21 via DBeaver)

| Tabela | Contagem | Comentário |
|---|---|---|
| `company_groups` | ~650 | 150 ETL v2 + ~498 self-named v3 |
| `companies` | ~797 | 299 ETL v2 + 498 v3 (suppliers FM órfãos) |
| `plants` | ~766 | 268 com SIF/IVO/etc. (v2) + 498 `NAO_APLICAVEL` (v3 suppliers) |
| `certifications` | **8** | só testes manuais — fonte FM nunca ingerida |

Confirmação Mustang Pluron (caso representativo de supplier):
```sql
SELECT id, legal_name, validation_notes
FROM companies
WHERE tax_id = '47078704000140';
-- id 4ea3bbc2-2403-4ef6-a725-70320dcbeb44, com nota
-- "supplier FM órfão (sem cadastro no SysHalal) | endereço FM bruto:
--  Catanduva – São Paulo – Brazil | cnpj_root: 47078704
--  [bulk-approve 2026-05-28] aprovada em massa por admin@halalsphere.solutions"
```

---

## ❓ O que pedir pra FAMBRAS antes de prosseguir

Idealmente uma exportação atualizada das mesmas 3 planilhas que originaram o CSV consolidado de 28/mai:

1. **FM 7.8.1 — Certificados Industrial Ativos** (xlsx) — última versão
2. **FM 7.8.2 — Certificados In Natura Ativos** (xlsx) — última versão
3. **FM 7.8.x — Certificados Cancelados / Substituídos** (se houver lista separada) — pra não recriar certs que sumiram

Perguntar também:
- Houve emissão / cancelamento / substituição de cert entre 14/mai/2026 (data da FM 7.8.1 anterior) e hoje? Quantas, em média?
- Os 3 SIFs duplicados (585 / 4699 / 2620) — qual planta é a correta em cada par? (ver §3 abaixo)
- Tem alguma cert que **não pode** ser ingerida agora (em revisão interna, suspensa por motivo confidencial, etc.)?

Reprocessar o ETL local com a nova base usando os scripts Python que já temos em `sih-docs/PLANNING/_fm_*.py` — saem novos `fm_certificados_consolidado_<data>.csv` + `fm_certs_sem_planta_gc_<data>.csv` mais 1 versão deles cruzando com o estado atual do GC (já com os 498 suppliers — antes só tinha 268 plants).

---

## 1. Pendência principal — script v4 `ingest-certifications-fm`

### Source
- `fm_certificados_consolidado_<data>.csv` (3122 linhas em 28/mai — provavelmente bem próximo disso em qualquer refresh)
- Headers conhecidos (do CSV de 28/mai):
  `origem_arquivo, origem_aba, origem_linha, razao_social, cnpj, cnpj_root, sif, endereco, pais, cat_gso, cat_smiic, categoria_unica, produto_pt, produto_en, tipos_animais, escopo, cert_num, cert_empresa_code, cert_unidade_code, cert_anomes, cert_seq, cert_revisao, cert_pais_code, cert_emissao, cert_validade, reconhece_golfo, normas, plataformas, status, status_canonical, motivo, data_exclusao`

### Lógica de match Plant→Cert (3 níveis)

Pra cada linha do CSV, achar o `Plant` certo no GC:

```
1. Match forte:  Plant WHERE company.taxId = cnpj_normalizado
                       AND sanitary_code = sif  (quando sif != 'N.A')
                 → Plant client com SIF batendo (caso normal v2)

2. Match supplier: Plant WHERE company.taxId = cnpj_normalizado
                        AND sanitary_code_type = 'NAO_APLICAVEL'
                  → Plant supplier (caso v3 — IFF, DSM, Mustang Pluron, etc.)

3. Sem match: log + skip (cert que aponta pra empresa que nem v2 nem v3 trouxeram)
              → revisar manualmente; provavelmente cert antiga ou de planta que sumiu
```

### Mapeamentos pro `Certification` Prisma

- `plantId` ← resolvido pelo match acima
- `certificationNumber` ← `cert_num` (UNIQUE — usar como chave de idempotência)
- `certificationType` ← inferir da `categoria_unica` (K=C2 químico, AI=C2 aditivo, CI=C1 alimentos, etc. — montar mapa)
- `status` ← do enum `CertificationStatus`:
  - `status_canonical = 'ativo'` → `ativa`
  - `status_canonical = 'cancelado'` → `cancelada`
  - `status_canonical = 'cancelado_substituido'` → `cancelada` + nota
  - `status_canonical = 'suspenso'` → `suspensa`
  - `status_canonical = 'unknown' | 'outro'` → skip + log
- `validFrom` ← `cert_emissao` (parseDate)
- `validUntil` ← `cert_validade` (parseDate)
- `standard` ← do enum `CertificationStandard`:
  - `reconhece_golfo = true` → `GSO_2055_2`
  - `categoria_unica` em lista turca → `SMIIC_02`
  - ambos → `BOTH`
  - nenhum → `VOLUNTARY`
- Anotar `standardNotes` com `normas` + `plataformas` + `motivo` (free text auditoria)

### Idempotência
- Upsert por `certificationNumber` (UNIQUE no schema)
- Re-rodar 2x não duplica

### Padrão do script
Mesmo template dos anteriores: `prisma/scripts/ingest-certifications-fm-<data>.ts`, com:
- `--dry-run` (default) / `--commit`
- `--only=match|skipped|all` (default all) — pra debug
- `--csv-dir=` configurável
- `--status-filter=ativo,suspenso,cancelado` (default `ativo` pra começar conservador)
- Resumo final com contagens (created/updated/skipped) + log dos skipped por motivo

### Tamanho esperado
- 3122 entradas no CSV → ~2000-2500 certs vão dar match (estimativa baseada em 88% do CSV original ter match em pelo menos uma Plant)
- 600-1000 vão pra skip (cert antigos, plantas que sumiram, suppliers que ainda não foram trazidos)
- Rodada: ~5-10 min em WAN (3122 queries de match + 3122 upserts)

---

## 2. Pendência secundária — 3 SIFs duplicados (585 / 4699 / 2620)

Identificados na ingestão v2 (28/mai). O UNIQUE constraint forçou dedupe; cada par perdeu 1 Company que ficou sem Plant.

| SIF | Plant **no DB hoje** (sobrescreveu) | Plant **órfã** (Company sem Plant) | Flag CSV |
|---|---|---|---|
| 585 | FRIGORIFICO PANTANAL / Grupo Pantanal (**INATIVO**) | FRIGOMARCA LTDA / Grupo Frigomarca (ATIVO) | multi_grupo_resolvido |
| 4699 | AGROARACA / Grupo Agroaraca | LAR COOPERATIVA / Grupo Lar | provavel_aquisicao_revisar |
| 2620 | BMG FOODS / Grupo BMG | FALCAO INDUSTRIA / Grupo Falcão | multi_grupo_resolvido |

### SIF 585 — solução óbvia
A planta DEVERIA estar associada a FRIGOMARCA (ATIVO). O DB tem PANTANAL (INATIVO). Confirmar com FAMBRAS e rodar:

```sql
-- Pseudo (precisa montar o UPDATE certo após confirmar)
UPDATE plants
SET company_id = (SELECT id FROM companies WHERE tax_id = '<CNPJ_FRIGOMARCA>')
WHERE sanitary_code = '585' AND sanitary_code_type = 'SIF';
```

### SIF 4699 e 2620 — decisão FAMBRAS necessária
- 4699: flag `provavel_aquisicao_revisar` — pode ser que LAR adquiriu AGROARACA ou vice-versa. Qual é a operadora atual?
- 2620: flag `multi_grupo_resolvido` — qual grupo é o real?

### Implicação pra ingest de certs (script v4)
Se o cert do SIF 585 sair com `cnpj = <Frigomarca>` no FM, ele NÃO vai bater com a Plant no DB (que tem `companyId = Pantanal`). Resultado: cert vai pra skip "sem match".

**Recomendação:** resolver os 3 SIFs **antes** de rodar o script v4. Senão vai logar 3-6 skips "sem match" só por causa disso (e cada uma exige investigação manual depois).

---

## 3. Artefatos já existentes (não reinventar)

- **Schema GC**: `halalsphere-backend/prisma/schema.prisma` — modelos `Certification`, `Plant`, `Company`, `CompanyGroup`, enums `CertificationStatus`, `CertificationStandard`, `CertificationType`, `SanitaryCodeType` (com `IVO_PY` + `NAO_APLICAVEL`)
- **Migration sanitaryCode opcional**: `prisma/migrations/20260528120000_plant_sanitary_code_optional/` (já aplicada em prod)
- **Script v2 (referência de padrão)**: `prisma/scripts/ingest-pre-cadastro-2026-05-28.ts` — leitura CSV, Prisma adapter-pg, dry-run, mapping tables
- **Script v3 (referência mais próxima)**: `prisma/scripts/ingest-suppliers-fm-2026-05-28.ts` — usa enrichment do `fm_certificados_consolidado` + dedupe por CNPJ
- **Scripts Python do ETL FAMBRAS**: `sih-docs/PLANNING/_etl_*.py` e `_fm_*.py` — rerodar com refresh pra gerar CSVs novos
- **CSVs source (OneDrive)**: `C:\Users\ecotrace\OneDrive - ECOTRACE TECNOLOGIA DA INFORMACAO SA\Área de Trabalho\Integra\fm_*.csv` (provavelmente datados de 28/mai — pedir refresh)
- **PLANNING completo do pré-cadastro**: `sih-docs/PLANNING/PRE-CADASTRO-EMPRESAS-GC-DESDE-SYSHALAL-FAMBRAS-2026-05-28.md`

---

## 4. Checklist mental pra próxima sessão

Quando retomar:

- [ ] FAMBRAS forneceu CSVs atualizados? Se sim, copiar pra `OneDrive\Integra\`
- [ ] Rerodar `_fm_consolidador*.py` (provavelmente) pra regerar `fm_certificados_consolidado_<data>.csv`
- [ ] Cruzar com Plants em prod (que agora têm 268 client + 498 supplier = 766) usando script Python rápido — quantos certs ainda ficam órfãos depois desse cruzamento?
- [ ] Decisão dos 3 SIFs duplicados — UPDATE SQL pra corrigir SIF 585 antes da ingest
- [ ] Escrever `ingest-certifications-fm-<data>.ts` seguindo padrão dos v2/v3
- [ ] Dry-run primeiro (vai retornar contagens esperadas)
- [ ] Commit run em prod com `--status-filter=ativo` (não trazer cancelados de cara)
- [ ] Validação: `SELECT COUNT(*) FROM certifications` deve subir de 8 pra ~2000-2500

---

## 5. Por que estamos esperando

- CSVs de 28/mai já têm 24+ dias quando este doc é escrito (21/jun)
- Mês de junho costuma ter movimentação de cert (FAMBRAS emite/renova continuamente)
- Ingerir baseado em dados velhos = importar certs já canceladas ou perder certs novas emitidas no período
- Custo de pedir dados frescos é baixo; custo de re-ingestar e reconciliar é alto
- Vale também pra alinhar timing com a janela de go-live de agosto/2026 — quanto mais perto do go-live, mais "verdade" o snapshot reflete

Quando FAMBRAS confirmar o refresh, retomar este doc + abrir sessão dedicada.
