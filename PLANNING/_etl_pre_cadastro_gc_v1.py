"""ETL pré-cadastro GC — análise + enriquecimento do CSV do SysHalal.
Roda offline. Não toca em produção. Usado em 2026-05-28."""
import os, re, csv, sys
import pandas as pd

INPUT = os.environ.get('INPUT_FILE') or sys.argv[1]
OUT_DIR = os.path.dirname(INPUT)
OUT_FILE = os.path.join(OUT_DIR, '_cadastro_GC_enriquecido_20260528.csv')

df = pd.read_csv(INPUT, sep=';', dtype=str, na_filter=False)
print(f"Linhas: {len(df)}  | Colunas: {len(df.columns)}\n")

ADDR_KEYWORDS = re.compile(
    r"\b(CUIT|CNPJ|RUC|NIT|IVO|SENASAG|INVIMA|CIUDAD|AVENIDA|AV\.|RUA|R\.|ROUTE|RUTA|KM|"
    r"CAMINO|MANZANA|ESTABLECIMIENTO|ESTABELECIMIENTO|ESTAB\.?|SIF|BARRIO|BAIRRO|"
    r"PROVINCIA|ESTADO|DEPARTAMENTO)\b",
    re.IGNORECASE
)
CUIT_RE = re.compile(r"\b(\d{2}-\d{8}-\d)\b")
ESTAB_RE = re.compile(r"\b(?:Establecimiento|Estab\.?|SIF)\s+(?:N[º°o]\.?\s*)?(\d{1,5})\b", re.IGNORECASE)
SUPPLIER_RE = re.compile(
    r"\b(BIOQU[IÍ]MICA|QU[IÍ]MICA|AROMA|INGREDIENT|ADITIVO|TEMPERO|ENZIMA|"
    r"FOODTECH|BIOTECN|EXTRATO|ESS[EÊ]NCIA|CORANTE|CONSERVANTE)\b",
    re.IGNORECASE
)

def clean_razao(rs, fantasia, nacionalidade):
    rs = (rs or '').strip()
    if not rs:
        return rs, 'vazia'
    if (nacionalidade or '') != 'internacional':
        return rs, 'nacional_passa_direto'
    if (fantasia or '').strip() and rs == fantasia.strip() and not ADDR_KEYWORDS.search(rs) and not CUIT_RE.search(rs):
        return rs, 'fantasia_limpa'
    candidates = []
    p = rs.find(' - ')
    if p > 0:
        candidates.append((p, 'corte_traco'))
    m = re.search(r",\s+\d", rs)
    if m:
        candidates.append((m.start(), 'corte_virgula_digito'))
    m = ADDR_KEYWORDS.search(rs)
    if m:
        candidates.append((m.start(), 'corte_palavra_chave'))
    if not candidates:
        return rs, 'limpa_sem_corte'
    cut_pos, flag = min(candidates)
    cleaned = rs[:cut_pos].rstrip(' ,-.').strip()
    if len(cleaned) < 3:
        return rs, 'ambigua_corte_curto'
    return cleaned, flag

def extract_estab(rs):
    if not rs: return None
    m = ESTAB_RE.search(rs)
    return m.group(1) if m else None

def extract_cuit(rs):
    if not rs: return None
    m = CUIT_RE.search(rs)
    return m.group(1).replace('-', '') if m else None

df['razao_social_limpa'] = ''
df['razao_social_flag'] = ''
df['establecimiento_extraido'] = ''
df['cuit_extraido'] = ''
df['flag_multi_grupo'] = False
df['flag_sem_grupo'] = False
df['flag_sem_codigo_sanitario'] = False
df['flag_supplier_suspect'] = False
df['codigo_sanitario_inferido'] = ''
df['tipo_sanitario_inferido'] = ''
df['revisar'] = False

for i, row in df.iterrows():
    rs = row.get('razao_social') or ''
    fant = row.get('nome_fantasia') or ''
    nac = row.get('nacionalidade') or ''
    cleaned, flag = clean_razao(rs, fant, nac)
    df.at[i, 'razao_social_limpa'] = cleaned
    df.at[i, 'razao_social_flag'] = flag

    if not (row.get('sif') or '').strip() and not (row.get('ivo') or '').strip():
        ex = extract_estab(rs)
        if ex:
            df.at[i, 'establecimiento_extraido'] = ex
    if not (row.get('cuit') or '').strip():
        ec = extract_cuit(rs)
        if ec:
            df.at[i, 'cuit_extraido'] = ec

    grupos = (row.get('grupos_cliente') or '').strip()
    if '|' in grupos:
        df.at[i, 'flag_multi_grupo'] = True
    if not grupos:
        df.at[i, 'flag_sem_grupo'] = True

    has_sanit = any((row.get(c) or '').strip() for c in ('sif', 'ivo', 'senasag', 'invima'))
    if not has_sanit:
        df.at[i, 'flag_sem_codigo_sanitario'] = True

    cnpj = (row.get('cnpj') or '').strip()
    cuit = (row.get('cuit') or '').strip()
    ruc = (row.get('ruc') or '').strip()
    sen = (row.get('senasag') or '').strip()
    inv = (row.get('invima') or '').strip()
    ivo = (row.get('ivo') or '').strip()
    sif = (row.get('sif') or '').strip()

    if cnpj and sif:
        df.at[i, 'codigo_sanitario_inferido'] = sif
        df.at[i, 'tipo_sanitario_inferido'] = 'SIF_BR'
    elif sen:
        df.at[i, 'codigo_sanitario_inferido'] = sen
        df.at[i, 'tipo_sanitario_inferido'] = 'SENASAG_BO'
    elif inv:
        df.at[i, 'codigo_sanitario_inferido'] = inv
        df.at[i, 'tipo_sanitario_inferido'] = 'INVIMA_CO'
    elif ivo:
        df.at[i, 'codigo_sanitario_inferido'] = ivo
        df.at[i, 'tipo_sanitario_inferido'] = 'IVO_PY'
    elif cuit and sif:
        df.at[i, 'codigo_sanitario_inferido'] = sif
        df.at[i, 'tipo_sanitario_inferido'] = 'ESTABELECIMENTO_AR'
    elif ruc and sif:
        df.at[i, 'codigo_sanitario_inferido'] = sif
        df.at[i, 'tipo_sanitario_inferido'] = 'ESTABELECIMENTO_PY'
    elif sif:
        df.at[i, 'codigo_sanitario_inferido'] = sif
        df.at[i, 'tipo_sanitario_inferido'] = 'INDEFINIDO'

    is_proc = row.get('is_processor') == 'true'
    is_sl = row.get('is_slaughterhouse') == 'true'
    if nac == 'nacional' and is_proc and not is_sl and SUPPLIER_RE.search(rs + ' ' + fant):
        df.at[i, 'flag_supplier_suspect'] = True

    needs_review = (
        (df.at[i, 'razao_social_flag'] in ('ambigua_corte_curto', 'limpa_sem_corte') and nac == 'internacional')
        or df.at[i, 'flag_multi_grupo']
        or df.at[i, 'flag_sem_grupo']
        or df.at[i, 'flag_sem_codigo_sanitario']
        or df.at[i, 'flag_supplier_suspect']
    )
    df.at[i, 'revisar'] = needs_review

df.to_csv(OUT_FILE, sep=';', index=False, encoding='utf-8', quoting=csv.QUOTE_MINIMAL)
print(f"Enriquecido salvo em: {OUT_FILE}\n")

sep = "=" * 70
print(sep); print("RESUMO POR PAIS CONSOLIDADO"); print(sep)
print(df.groupby(['pais_consolidado', 'situacao'], dropna=False).size().to_string())
print()

print(sep); print("DISTRIBUICAO DE TIPOS (booleanos)"); print(sep)
for col in ('is_slaughterhouse', 'is_processor', 'is_exporter', 'is_importer', 'is_trading', 'is_outros'):
    print(f"  {col}: {(df[col] == 'true').sum()}")
print()

print(sep); print("BUCKETS DE REVISAO"); print(sep)
buckets = {
    'flag_multi_grupo': int(df['flag_multi_grupo'].sum()),
    'flag_sem_grupo': int(df['flag_sem_grupo'].sum()),
    'flag_sem_codigo_sanitario': int(df['flag_sem_codigo_sanitario'].sum()),
    'flag_supplier_suspect': int(df['flag_supplier_suspect'].sum()),
    'revisar (qualquer)': int(df['revisar'].sum()),
}
for k, v in buckets.items():
    print(f"  {k}: {v}  ({100*v/len(df):.1f}%)")
print(f"  TOTAL = {len(df)}")
print()

print(sep); print("RAZAO SOCIAL - FLAGS"); print(sep)
print(df['razao_social_flag'].value_counts().to_string())
print()

print(sep); print("TIPO SANITARIO INFERIDO"); print(sep)
print(df['tipo_sanitario_inferido'].replace('', '(VAZIO/SEM_CODIGO)').value_counts().to_string())
print()

print(sep); print("CODIGOS EXTRAIDOS DA RAZAO SOCIAL"); print(sep)
print(f"  establecimiento_extraido (sif/ivo vazios na origem): {(df['establecimiento_extraido'] != '').sum()}")
print(f"  cuit_extraido (cuit vazio na origem): {(df['cuit_extraido'] != '').sum()}")
print()

print(sep); print("AMOSTRA - multi_grupo (top 8)"); print(sep)
mg = df[df['flag_multi_grupo']].head(8)[['razao_social_limpa', 'pais_consolidado', 'grupos_cliente']]
print(mg.to_string(index=False, max_colwidth=80))
print()

print(sep); print("AMOSTRA - sem_codigo_sanitario (top 10)"); print(sep)
sc = df[df['flag_sem_codigo_sanitario']].head(10)[
    ['razao_social_limpa', 'pais_consolidado', 'cnpj', 'cuit', 'ruc', 'is_slaughterhouse', 'is_processor']
]
print(sc.to_string(index=False, max_colwidth=60))
print()

print(sep); print("AMOSTRA - supplier_suspect (top 10)"); print(sep)
ss = df[df['flag_supplier_suspect']].head(10)[['razao_social_limpa', 'cnpj', 'sif']]
print(ss.to_string(index=False, max_colwidth=70))
print()

print(sep); print("AMOSTRA - establecimiento_extraido (top 5)"); print(sep)
ex = df[df['establecimiento_extraido'] != ''].head(5)[
    ['razao_social', 'establecimiento_extraido', 'pais_consolidado']
]
print(ex.to_string(index=False, max_colwidth=90))
