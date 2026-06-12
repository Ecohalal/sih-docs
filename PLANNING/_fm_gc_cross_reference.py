"""Cruzamento FM 7.8.x consolidado x projeção GC.

Lê:
  - fm_certificados_consolidado_20260528.csv
  - gc_projecao_completa_20260528.csv

Produz:
  - gc_plantas_com_certs_20260528.csv  (1 linha por planta GC + lista de certs)
  - fm_certs_sem_planta_gc_20260528.csv (certs órfãos sem planta correspondente)
  - cruzamento_summary printado no console
"""
import os, csv
from collections import defaultdict
import pandas as pd

DIR = r"C:\Users\ecotrace\OneDrive - ECOTRACE TECNOLOGIA DA INFORMACAO SA\Área de Trabalho\Integra"
FM_FILE = os.path.join(DIR, "fm_certificados_consolidado_20260528.csv")
GC_FILE = os.path.join(DIR, "gc_projecao_completa_20260528.csv")

OUT_PLANTAS = os.path.join(DIR, "gc_plantas_com_certs_20260528.csv")
OUT_ORFAOS = os.path.join(DIR, "fm_certs_sem_planta_gc_20260528.csv")

fm = pd.read_csv(FM_FILE, sep=';', dtype=str, na_filter=False)
gc = pd.read_csv(GC_FILE, sep=';', dtype=str, na_filter=False)
print(f"FM certs:    {len(fm)}")
print(f"GC plantas:  {len(gc)}")

# ----- normalizar chaves -----
def norm_cnpj(c):
    return ''.join(ch for ch in str(c or '') if ch.isdigit())

def norm_sif(s):
    s = str(s or '').strip()
    # remover ".0" sufixo (vinha do xlsb como float)
    if s.endswith('.0'):
        s = s[:-2]
    return s.strip()

fm['cnpj_n'] = fm['cnpj'].apply(norm_cnpj)
fm['sif_n']  = fm['sif'].apply(norm_sif)
gc['cnpj_n'] = gc['tax_id'].apply(norm_cnpj)
gc['sif_n']  = gc['sanitary_code'].apply(norm_sif)

# ----- index FM por cnpj e por (cnpj_root, sif) -----
fm_by_cnpj = defaultdict(list)
fm_by_root_sif = defaultdict(list)
fm_by_root = defaultdict(list)
for _, r in fm.iterrows():
    if r['cnpj_n']:
        fm_by_cnpj[r['cnpj_n']].append(r)
    root = r['cnpj_root'] if r['cnpj_root'] else (r['cnpj_n'][:8] if len(r['cnpj_n']) >= 8 else '')
    if root:
        fm_by_root[root].append(r)
        if r['sif_n']:
            fm_by_root_sif[(root, r['sif_n'])].append(r)

# ----- para cada planta GC, encontrar certs FAMBRAS -----
matched_fm_ids = set()  # rastreio (arquivo, linha) dos certs já casados
plantas_out = []
sem_match = 0
for _, p in gc.iterrows():
    cnpj_completo = p['cnpj_n']
    cnpj_r = (p.get('cnpj_root') or (cnpj_completo[:8] if len(cnpj_completo) >= 8 else ''))
    sif = p['sif_n']
    matched = []
    match_type = ''
    # 1. exato por cnpj completo
    if cnpj_completo and cnpj_completo in fm_by_cnpj:
        matched = fm_by_cnpj[cnpj_completo]
        match_type = 'cnpj_completo'
    # 2. raiz + sif (frequente: cnpj em xls não bate exato mas raiz+sif sim)
    elif cnpj_r and sif and (cnpj_r, sif) in fm_by_root_sif:
        matched = fm_by_root_sif[(cnpj_r, sif)]
        match_type = 'raiz_cnpj_e_sif'
    # 3. fallback: só raiz (pode ter múltiplas filiais misturadas)
    elif cnpj_r and cnpj_r in fm_by_root:
        matched = fm_by_root[cnpj_r]
        match_type = 'raiz_cnpj_apenas'
    else:
        match_type = 'sem_match'
        sem_match += 1
    # estatísticas por planta
    cert_ativos = [c for c in matched if c['status_canonical'] == 'ativo']
    cert_cancelados = [c for c in matched if c['status_canonical'] in ('cancelado', 'cancelado_substituido')]
    cert_suspensos = [c for c in matched if c['status_canonical'] == 'suspenso']
    # registrar IDs casados
    for c in matched:
        matched_fm_ids.add((c['origem_arquivo'], c['origem_linha']))

    plantas_out.append({
        'empresa_id_syshalal': p.get('empresa_id_syshalal'),
        'country_code': p.get('country_code'),
        'tax_id': p.get('tax_id'),
        'cnpj_root': cnpj_r,
        'sanitary_code': sif,
        'legal_name': p.get('legal_name'),
        'grupo_final': p.get('grupo_final'),
        'relationship_sugerido': p.get('relationship_sugerido'),
        'flags_revisar': p.get('flags_revisar'),
        'match_type': match_type,
        'total_certs_fm': len(matched),
        'certs_ativos': len(cert_ativos),
        'certs_cancelados': len(cert_cancelados),
        'certs_suspensos': len(cert_suspensos),
        'cert_ativo_numeros': ' | '.join(sorted({c['cert_num'] for c in cert_ativos if c['cert_num']})),
        'cert_ativo_validades': ' | '.join(sorted({c['cert_validade'] for c in cert_ativos if c['cert_validade']})),
        'cert_ativo_escopos': ' | '.join(sorted({c['escopo'][:50] for c in cert_ativos if c['escopo']})),
        'cert_ativo_normas': ' | '.join(sorted({c['normas'][:50] for c in cert_ativos if c['normas']})),
    })

plantas_df = pd.DataFrame(plantas_out)
plantas_df.to_csv(OUT_PLANTAS, sep=';', index=False, encoding='utf-8', quoting=csv.QUOTE_MINIMAL)

# ----- certs FM que não bateram com nenhuma planta GC -----
fm['casou'] = [(r['origem_arquivo'], r['origem_linha']) in matched_fm_ids for _, r in fm.iterrows()]
orfaos = fm[~fm['casou']].copy()
orfaos = orfaos[[
    'cert_num', 'razao_social', 'cnpj', 'cnpj_root', 'sif', 'cert_pais_code',
    'status', 'status_canonical', 'cert_emissao', 'cert_validade', 'escopo',
    'origem_arquivo', 'origem_aba', 'origem_linha',
]]
orfaos.to_csv(OUT_ORFAOS, sep=';', index=False, encoding='utf-8', quoting=csv.QUOTE_MINIMAL)

# ----- summary -----
sep = '=' * 70
print(f"\n{sep}\nMATCH POR TIPO\n{sep}")
mt_counter = plantas_df['match_type'].value_counts()
for k, v in mt_counter.items():
    print(f"  {k}: {v}")

print(f"\n{sep}\nPLANTAS GC: distribuicao de certs ATIVOS\n{sep}")
print(f"  com >=1 cert ativo: {(plantas_df['certs_ativos'].astype(int) >= 1).sum()}")
print(f"  sem cert ativo (mas tem outros):  {((plantas_df['certs_ativos'].astype(int) == 0) & (plantas_df['total_certs_fm'].astype(int) > 0)).sum()}")
print(f"  sem nenhum cert FM (match_type=sem_match): {(plantas_df['match_type'] == 'sem_match').sum()}")
print(f"  total plantas com qualquer cert: {(plantas_df['total_certs_fm'].astype(int) > 0).sum()}")

print(f"\n{sep}\nFM CERTS - quanto cruzou\n{sep}")
print(f"  casaram com alguma planta GC: {sum(fm['casou'])}")
print(f"  orfaos (sem planta GC):       {(~fm['casou']).sum()}")

print(f"\n{sep}\nORFAOS por status\n{sep}")
print(orfaos['status_canonical'].value_counts().to_string())

print(f"\n{sep}\nORFAOS por pais cert\n{sep}")
print(orfaos['cert_pais_code'].value_counts().head(10).to_string())

print(f"\n{sep}\nTOP 5 PLANTAS por nº de cert ATIVOS\n{sep}")
top = plantas_df.sort_values('certs_ativos', key=lambda s: s.astype(int), ascending=False).head(5)
print(top[['legal_name', 'tax_id', 'sanitary_code', 'certs_ativos', 'total_certs_fm']].to_string(index=False))

print(f"\n{sep}\nTOP 5 ORFAOS - CNPJ por nº de certs\n{sep}")
orf_top = orfaos[orfaos['cnpj'] != ''].groupby(['cnpj', 'razao_social']).size().sort_values(ascending=False).head(5)
print(orf_top.to_string())

print(f"\n{sep}\nARQUIVOS GERADOS\n{sep}")
for p in (OUT_PLANTAS, OUT_ORFAOS):
    sz = os.path.getsize(p) if os.path.exists(p) else 0
    print(f"  {os.path.basename(p)}  ({sz} bytes)")
