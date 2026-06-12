"""ETL v2 — projeta CSV enriquecido em 3 tabelas-alvo do GC.

Entrada: _cadastro_GC_enriquecido_20260528.csv (saída do v1)
Saída:
  - gc_company_groups_20260528.csv (1 por holding inferido)
  - gc_companies_20260528.csv      (1 por CNPJ/taxId completo)
  - gc_plants_20260528.csv         (1 por sanitary code; quando há)
  - gc_revisar_20260528.csv        (consolidado de tudo que pede revisão humana)

Sem escrita em base. Para revisão antes de qualquer ingestão.
"""
import os, re, sys, csv, unicodedata
import pandas as pd

INPUT = os.environ.get('ENRICHED_CSV') or sys.argv[1]
OUT_DIR = os.path.dirname(INPUT)
TS = '20260528'

df = pd.read_csv(INPUT, sep=';', dtype=str, na_filter=False)
print(f"Carregado: {len(df)} linhas\n")

# --- helpers ---
STOPWORDS = {
    'SA', 'S/A', 'S.A.', 'LTDA', 'LTDA.', 'EIRELI', 'ME', 'EPP',
    'INDUSTRIA', 'INDUSTRIAS', 'INDÚSTRIA', 'INDÚSTRIAS', 'INDUSTRIAL',
    'COMERCIO', 'COMÉRCIO', 'COM', 'IND',
    'ALIMENTOS', 'ALIMENTICIA', 'ALIMENTÍCIA', 'ALIMENTICIOS',
    'ENERGIA', 'SUCOS', 'COURO', 'COUROS', 'CURTUME',
    'CENTRAL', 'COOPERATIVA', 'COOP',
    'IMP', 'EXP', 'IMPORTACAO', 'EXPORTACAO', 'IMPORTAÇÃO', 'EXPORTAÇÃO',
    'AGROINDUSTRIAL', 'AGROINDUSTRIA', 'AGROINDÚSTRIA',
    'CARNES', 'AVES', 'BOVINOS', 'PRODUTOS', 'PRODUCTOS',
    'COMPANY', 'CO', 'CIA', 'CIA.', 'INC', 'CORP',
    'DO', 'DA', 'DE', 'E', 'BRASIL', 'BRAZIL',
    'FRIGORIFICO', 'FRIGORÍFICO', 'FRIGORIFICA', 'FRIGORÍFICA', 'ABATEDOURO',
    'CONSERVAS', 'GENEROS', 'GÊNEROS', 'DERIVADOS', 'SERVICOS', 'SERVIÇOS',
    'PROCESSADORA', 'PROCESSADOS', 'PROCESSADAS', 'PROCESSAMENTO',
    'INTERNACIONAL', 'INTERNATIONAL', 'GROUP', 'GRUPO',
}

def normalize(s):
    if not s:
        return ''
    s = unicodedata.normalize('NFKD', s).encode('ASCII', 'ignore').decode()
    return s.upper().strip()

def significant_token(name):
    """Primeiro token de >=3 letras que não esteja em STOPWORDS."""
    if not name:
        return None
    n = re.sub(r'\b(S\.?A\.?|S/A|LTDA\.?|EIRELI|ME|EPP)\b\.?', ' ', name, flags=re.IGNORECASE)
    n = normalize(n)
    tokens = re.split(r'[\s/.,\-]+', n)
    for t in tokens:
        if len(t) >= 3 and t not in STOPWORDS and not t.isdigit():
            return t
    # Fallback: primeiro token não vazio
    for t in tokens:
        if t and not t.isdigit():
            return t
    return None

def significant_phrase_for_group(legal_name, max_tokens=3):
    """Frase Title Case com até max_tokens significativos. Pra nomear grupo solo."""
    if not legal_name:
        return None
    n = re.sub(r'\b(S\.?A\.?|S/A|LTDA\.?|EIRELI|ME|EPP|CIA\.?|INC|CORP)\b\.?', ' ', legal_name, flags=re.IGNORECASE)
    n = normalize(n)
    tokens = re.split(r'[\s/.,\-]+', n)
    out = []
    for t in tokens:
        if len(out) >= max_tokens:
            break
        if len(t) >= 3 and t not in STOPWORDS and not t.isdigit():
            out.append(t.title())
    if not out:
        for t in tokens:
            if t and not t.isdigit():
                return t.title()
        return legal_name.title()
    return ' '.join(out)


def match_group(token, grupos_cliente):
    """Procura o grupo cujo nome contém o token (case-insensitive, sem acentos)."""
    if not token or not grupos_cliente:
        return None, []
    grupos = [g.strip() for g in grupos_cliente.split('|') if g.strip()]
    matches = []
    for g in grupos:
        if token in normalize(g):
            matches.append(g)
    if matches:
        return matches[0], grupos  # primeiro match
    return None, grupos

COUNTRY_MAP = {
    'BRAZIL': ('BR', 'CNPJ'),
    'ARGENTINA': ('AR', 'CUIT'),
    'PARAGUAY': ('PY', 'RUC'),
    'COLOMBIA': ('CO', 'NIT'),
    'BOLIVIA': ('BO', 'NIT'),
}

# Não-frigorífico padrão: nome contém qualquer dessas
INDUSTRIAL_NON_FRIG = re.compile(
    r"\b(ACUCAR|AÇÚCAR|ETANOL|ENERGIA|SUCOS|COURO|COUROS|BIOQUIMICA|BIOQUÍMICA|"
    r"QUIMICA|QUÍMICA|AROMA|ADITIVO|TEMPERO|ESSÊNCIA|ESSENCIA|MASSAS|"
    r"FOODTECH|BIOTECN|EXTRATO|TENSOATIV|INGREDIENT|FRUIT|GLOBALFRUIT|"
    r"FORNO DE MINAS|HIPER MASSAS|ALCOOL|ÁLCOOL|TENSOATIVO)\b",
    re.IGNORECASE,
)

def derive_relationship(row):
    """Sugere CompanyRelationship pro GC."""
    nac = row.get('nacionalidade') or ''
    has_san = bool(row.get('codigo_sanitario_inferido'))
    is_sl = row.get('is_slaughterhouse') == 'true'
    is_pr = row.get('is_processor') == 'true'
    name = (row.get('razao_social_limpa') or row.get('razao_social') or '') + ' ' + (row.get('nome_fantasia') or '')

    if nac == 'internacional':
        return 'partner_or_client'  # internacionais precisam de revisão (partner vs client externo)
    if is_sl or has_san:
        return 'client'
    if INDUSTRIAL_NON_FRIG.search(name):
        return 'supplier_industrial'
    if is_pr and not is_sl and not has_san:
        return 'supplier'
    return 'client'

def cnpj_root(cnpj):
    """8 primeiros dígitos do CNPJ (raiz da pessoa jurídica)."""
    c = (cnpj or '').strip()
    if len(c) >= 8 and c.isdigit():
        return c[:8]
    return None

def map_sanitary_type(t):
    """Mapeia tipo_sanitario_inferido pro nome enum esperado no GC."""
    return {
        'SIF_BR': 'SIF',
        'ESTABELECIMENTO_AR': 'ESTABELECIMENTO_AR',
        'IVO_PY': 'IVO_PY',
        'ESTABELECIMENTO_PY': 'ESTABELECIMENTO_PY',
        'SENASAG_BO': 'SENASAG',
        'INVIMA_CO': 'INVIMA',
        'INDEFINIDO': 'INDEFINIDO',
        '': None,
    }.get(t or '', t)

# --- Enrich rows ---
results = []
for i, row in df.iterrows():
    legal_name = row['razao_social_limpa'] or row['razao_social']
    fantasia = row['nome_fantasia']
    pais = row['pais_consolidado']
    country_code, default_tax_type = COUNTRY_MAP.get(pais, (None, None))

    # Pick taxId by country
    if country_code == 'BR':
        tax_id = row['cnpj']; tax_id_type = 'CNPJ'
    elif country_code == 'AR':
        tax_id = row['cuit'] or row['cuit_extraido']; tax_id_type = 'CUIT'
    elif country_code == 'PY':
        tax_id = row['ruc'] or row['ivo']; tax_id_type = 'RUC' if row['ruc'] else 'IVO'
    elif country_code == 'CO':
        tax_id = row['nit_colombia']; tax_id_type = 'NIT'
    elif country_code == 'BO':
        tax_id = row['nit_bolivia']; tax_id_type = 'NIT'
    else:
        tax_id = ''; tax_id_type = ''

    # Group inference
    token = significant_token(legal_name)
    grupo_match, grupos_all = match_group(token, row['grupos_cliente'])
    if grupo_match:
        grupo_final = grupo_match
        grupo_source = 'self_named_match'
    else:
        phrase = significant_phrase_for_group(legal_name) or legal_name
        grupo_final = f"Grupo {phrase}"
        # Flag aquisição: solo MAS havia grupos_cliente populated
        if row['grupos_cliente'].strip():
            grupo_source = 'solo_fallback_revisar_aquisicao'
        else:
            grupo_source = 'solo_fallback'

    # Dedup helper via CNPJ root
    cnpj_r = cnpj_root(tax_id) if country_code == 'BR' else None

    relationship = derive_relationship(row)

    sanitary_code = row.get('codigo_sanitario_inferido') or ''
    sanitary_type = map_sanitary_type(row.get('tipo_sanitario_inferido', ''))

    # Reviewable flags
    flags = []
    if grupo_source == 'solo_fallback_revisar_aquisicao':
        flags.append('provavel_aquisicao_revisar')
    if row.get('flag_multi_grupo') == 'True' and grupo_source == 'self_named_match':
        flags.append('multi_grupo_resolvido')
    elif row.get('flag_multi_grupo') == 'True':
        flags.append('multi_grupo_nao_resolvido')
    if row.get('flag_sem_grupo') == 'True':
        flags.append('sem_grupo_solo')
    if row.get('flag_sem_codigo_sanitario') == 'True':
        flags.append('sem_codigo_sanitario')
    if not tax_id:
        flags.append('sem_tax_id')
    if not legal_name:
        flags.append('sem_legal_name')
    if relationship == 'supplier_industrial' or relationship == 'partner_or_client':
        flags.append('relationship_revisar')

    results.append({
        'empresa_id_syshalal': row['empresa_id_syshalal'],
        'situacao': row['situacao'],
        'country_code': country_code,
        'country_name': pais,
        'tax_id': tax_id,
        'tax_id_type': tax_id_type,
        'cnpj_root': cnpj_r,
        'legal_name': legal_name,
        'trade_name': fantasia,
        'grupo_final': grupo_final,
        'grupo_source': grupo_source,
        'grupo_token_usado': token,
        'grupos_originais': row['grupos_cliente'],
        'sanitary_code': sanitary_code,
        'sanitary_type': sanitary_type,
        'is_slaughterhouse': row['is_slaughterhouse'],
        'is_processor': row['is_processor'],
        'is_exporter': row['is_exporter'],
        'is_importer': row['is_importer'],
        'relationship_sugerido': relationship,
        'flags_revisar': '|'.join(flags),
        'precisa_revisar': bool(flags),
        # Endereço útil
        'cep': row['cep'], 'rua': row['rua'], 'numero': row['numero'],
        'bairro': row['bairro'], 'cidade': row['cidade'],
        'uf': row['uf'], 'estado': row['estado'],
        'pais_endereco': row['pais_endereco'],
    })

proj = pd.DataFrame(results)

# --- Pós-processamento: merge de CompanyGroups por token significativo ---
# Caso real: "Grupo JBS" (45 plantas, self_named) + "Grupo Jbs Aves" (solo) -> ambos têm token "JBS"
# Regra: se múltiplos grupo_final compartilham o MESMO grupo_token_usado E pelo menos UM veio
# de self_named_match, o canonical é o nome do self_named_match (mais N plantas).
proj['grupo_original_pre_merge'] = proj['grupo_final']
proj['grupo_merge_applied'] = False

canonical_by_token = {}
for token, group_df in proj.groupby('grupo_token_usado'):
    if not token:
        continue
    finals_in_group = group_df['grupo_final'].unique()
    if len(finals_in_group) <= 1:
        continue
    self_named = group_df[group_df['grupo_source'] == 'self_named_match']
    if len(self_named) > 0:
        # Canonical = grupo_final do self_named_match com mais plantas
        counts = self_named['grupo_final'].value_counts()
        canonical = counts.index[0]
        canonical_by_token[token] = canonical

for i, row in proj.iterrows():
    tok = row['grupo_token_usado']
    if tok in canonical_by_token and row['grupo_final'] != canonical_by_token[tok]:
        proj.at[i, 'grupo_final'] = canonical_by_token[tok]
        proj.at[i, 'grupo_merge_applied'] = True
        # adicionar flag informativo
        cur = proj.at[i, 'flags_revisar']
        proj.at[i, 'flags_revisar'] = (cur + '|merged_by_token') if cur else 'merged_by_token'

n_merged = int(proj['grupo_merge_applied'].sum())

# --- Projeção 1: CompanyGroups únicos ---
groups = (
    proj.groupby('grupo_final')
    .agg(
        plantas_count=('empresa_id_syshalal', 'count'),
        countries=('country_code', lambda x: '|'.join(sorted(set(c for c in x if c)))),
        sources=('grupo_source', lambda x: '|'.join(sorted(set(x)))),
        cnpj_roots=('cnpj_root', lambda x: '|'.join(sorted(set(c for c in x if c)))),
    )
    .reset_index()
    .sort_values('plantas_count', ascending=False)
)

# --- Projeção 2: Companies (1 por taxId completo) ---
companies = proj.copy()
companies = companies.drop_duplicates(subset=['country_code', 'tax_id', 'tax_id_type'], keep='first')
companies = companies[[
    'country_code', 'tax_id', 'tax_id_type', 'cnpj_root',
    'legal_name', 'trade_name', 'grupo_final', 'relationship_sugerido',
    'situacao', 'cep', 'rua', 'numero', 'bairro', 'cidade', 'uf', 'estado', 'pais_endereco',
    'flags_revisar', 'precisa_revisar', 'empresa_id_syshalal',
]]

# --- Projeção 3: Plants (1 por sanitary_code, quando há) ---
plants = proj[proj['sanitary_code'] != ''].copy()
plants = plants[[
    'empresa_id_syshalal', 'country_code', 'tax_id', 'tax_id_type', 'legal_name', 'grupo_final',
    'sanitary_code', 'sanitary_type',
    'is_slaughterhouse', 'is_processor',
    'situacao', 'flags_revisar',
]]

# --- Salvar ---
group_path = os.path.join(OUT_DIR, f'gc_company_groups_{TS}.csv')
company_path = os.path.join(OUT_DIR, f'gc_companies_{TS}.csv')
plant_path = os.path.join(OUT_DIR, f'gc_plants_{TS}.csv')
review_path = os.path.join(OUT_DIR, f'gc_revisar_{TS}.csv')
full_proj_path = os.path.join(OUT_DIR, f'gc_projecao_completa_{TS}.csv')

groups.to_csv(group_path, sep=';', index=False, encoding='utf-8', quoting=csv.QUOTE_MINIMAL)
companies.to_csv(company_path, sep=';', index=False, encoding='utf-8', quoting=csv.QUOTE_MINIMAL)
plants.to_csv(plant_path, sep=';', index=False, encoding='utf-8', quoting=csv.QUOTE_MINIMAL)
proj[proj['precisa_revisar']].to_csv(review_path, sep=';', index=False, encoding='utf-8', quoting=csv.QUOTE_MINIMAL)
proj.to_csv(full_proj_path, sep=';', index=False, encoding='utf-8', quoting=csv.QUOTE_MINIMAL)

# --- Summary ---
sep = '=' * 70
print(sep); print(f'PROJECAO COMPLETA: {len(proj)} linhas'); print(sep)
print(f'  CompanyGroups inferidos (apos merge): {len(groups)} (unique)')
print(f'    self_named_match: {(proj["grupo_source"] == "self_named_match").sum()} ({100*(proj["grupo_source"] == "self_named_match").sum()/len(proj):.1f}%)')
print(f'    solo_fallback:    {(proj["grupo_source"] == "solo_fallback").sum()}')
print(f'    solo_fallback_revisar_aquisicao: {(proj["grupo_source"] == "solo_fallback_revisar_aquisicao").sum()}')
print(f'    merged_by_token (pos-processamento): {n_merged}')
print(f'  Companies (CNPJ/taxId distintos): {len(companies)}')
print(f'  Plants (com sanitary_code): {len(plants)}')
print(f'  Para revisao manual: {proj["precisa_revisar"].sum()}')
print()

print(sep); print('RELATIONSHIP SUGERIDO'); print(sep)
print(proj['relationship_sugerido'].value_counts().to_string())
print()

print(sep); print('FLAGS DE REVISAO (distribuicao)'); print(sep)
flag_counter = {}
for f in proj['flags_revisar']:
    for x in (f.split('|') if f else []):
        if x: flag_counter[x] = flag_counter.get(x, 0) + 1
for k in sorted(flag_counter, key=lambda x: -flag_counter[x]):
    print(f'  {k}: {flag_counter[k]}')
print()

print(sep); print('TOP 15 COMPANY GROUPS POR PLANTAS'); print(sep)
print(groups.head(15).to_string(index=False, max_colwidth=50))
print()

print(sep); print('SANITARY TYPE - DISTRIBUICAO'); print(sep)
print(plants['sanitary_type'].fillna('(VAZIO)').value_counts().to_string())
print()

print(sep); print('CONTAGENS POR PAIS - COMPANIES X PLANTS'); print(sep)
pais_summary = pd.DataFrame({
    'companies': companies['country_code'].value_counts(),
    'plants': plants['country_code'].value_counts(),
}).fillna(0).astype(int)
print(pais_summary.to_string())
print()

print(sep); print('AMOSTRA - solo_fallback (top 10)'); print(sep)
solo = proj[proj['grupo_source'] == 'solo_fallback'].head(10)[
    ['legal_name', 'country_code', 'grupos_originais', 'grupo_token_usado']
]
print(solo.to_string(index=False, max_colwidth=60))
print()

print(sep); print('ARQUIVOS GERADOS'); print(sep)
for p in (group_path, company_path, plant_path, review_path, full_proj_path):
    sz = os.path.getsize(p) if os.path.exists(p) else 0
    print(f'  {os.path.basename(p)}  ({sz} bytes)')
