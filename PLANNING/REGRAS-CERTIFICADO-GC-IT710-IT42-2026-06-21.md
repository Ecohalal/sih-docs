# Regras de Emissão do Certificado Halal — Consolidação GC × IT 4.2 × IT 7.10

> **Data:** 2026-06-21
> **Autor:** Renato Ribeiro de Oliveira (PO Ecohalal) + sessão de análise comparativa
> **Contexto:** avaliação dos 15 modelos reais entregues pela FAMBRAS Halal
> (pasta `fambras-references-2026-04/_emails-fonte/Qualidade/Modelos Certificados`,
> Modelos 7.7.1 + 7.7.2, Abr-Out/2025) cruzada com a implementação atual do
> GC (`halalsphere-backend`) e as normas FAMBRAS aplicáveis.
> **Status:** referência durável; usar para auditoria + onboarding de novos
> desenvolvedores no módulo `certificate/`.

---

## 1. Escopo e fontes

| Fonte | Versão | Cobertura |
|---|---|---|
| **IT 4.2** — Numeração de Propostas, Contratos e Certificados | REV 6 | Formato do número, regras de herança, splitting por norma (frigorífico) |
| **IT 7.10** — Preenchimento e emissão do certificado halal | REV 04 (05/05/2022) | Modelos (Único × Habilitação SIF/Sem SIF), variantes COM GAC / SEM GAC, regras de data, protocolo de assinatura |
| **FM 7.7.1 Rev 05** | — | Gabarito "Halal Approval" (Habilitação) |
| **FM 7.7.2 Rev 05** | — | Gabarito "Halal Certificate" (Único) |
| **15 PDFs reais** | Abr-Out/2025 | Validação empírica do padrão atual em produção |

**Localizações no repo:**
- IT 4.2 (resumo): `halalsphere-docs/analise_halal.md:982-1014`
- IT 7.10 (PDF): `halalsphere-docs/CERTIFICATES/IT 7.10 - PREENCHIMENTO E EMISSÃO DO CERTIFICADO HALAL (COMO MONTAR GABARITO) (REV 4) PT.pdf`
- Layouts oficiais: `halalsphere-docs/CERTIFICATES/layouts/`
- Selos: `halalsphere-docs/CERTIFICATES/selos/` (15 PNGs)
- Modelos reais: `fambras-references-2026-04/_emails-fonte/Qualidade/Modelos Certificados/`

---

## 2. Regras consolidadas

### 2.1 Numeração (IT 4.2 REV 6)

**Industrial:** `ABC.SIG.ANOMES.SEQQ.PAIS`
**Frigorífico:** `ABC.SIG.ANOMES.SEQQ.NORMA.PAIS`

| Token | Regra |
|---|---|
| `ABC` | 3 primeiras letras alfabéticas da razão social (sem acento, uppercase) |
| `SIG` | Sigla de 3 letras da cidade da planta (tabela `city_siglas`) |
| `ANOMES` | Ano-mês da **proposta original** (AAMM) — persiste todo o ciclo de 3 anos |
| `SEQQ` | Contador **global FAMBRAS** por ANOMES (4 dígitos), alocado por Halima (Industrial) ou André (Frigorífico) |
| `NORMA` | Slot do bloco de normas (frigorífico apenas) |
| `PAIS` | ISO-3 (BRA, ARG, URU, COL, PAR, …) |

**Regras de bloco NORMA (frigorífico):**
- **Aves:** `.1`=UAE | `.2`=GSO | `.3`=KEPKABAN/SMIIC/MUIS | `.4`=MS 1500
- **Bovinos:** `.1`=GSO+UAE | `.2`=KEPKABAN/SMIIC/MUIS

**Regra de imutabilidade:** "Certificado muda número quando muda escopo. Manutenção sem alteração de escopo NÃO reemite certificado." → Re-emissões anuais de PDF mantêm o mesmo número; apenas a `issueDate` avança.

### 2.2 Modelos (IT 7.10 §3)

3 modelos × 8 variantes:

| Modelo | Quando usar | Sub-variantes |
|---|---|---|
| **Certificado Único** | Industrial sem embarque (açúcar, café, laticínios, químicos, aditivos) | SEM ANEXO (até 6 produtos) / COM ANEXO |
| **Habilitação COM SIF** | Frigoríficos + processados de carne (Hamburguer, Embutidos, Corned Beef) + matérias-primas animais (Gelatina, Heparina Sódica, Pancreatina) | SEM ANEXO / COM ANEXO |
| **Habilitação SEM SIF** | Pão de queijo, sucos com aromas Halal, processos sem proteína animal mas com supervisor muçulmano | SEM ANEXO / COM ANEXO |

Cada um × **COM GAC** (cliente padrão Golfo) / **SEM GAC** (não-Golfo).

### 2.3 Datas (IT 7.10 §V, §VIII)

| Campo | Regra |
|---|---|
| `Certified since` | Primeira certificação histórica da empresa (não muda em renovações) |
| `Initial certification cycle date` | Data do ciclo atual de 3 anos (muda a cada renovação) |
| `Expiry date` | `Initial cycle date + 3 anos` (sempre exatos) |
| `Issue date` | Data atual do PDF; deve ser **igual ou posterior** ao comitê de decisão. Avança em cada manutenção anual; cycle date fica fixo |

### 2.4 Layout — decisão Ecohalal 2026-05-20

**Bilíngue EN+AR é mandatório em 100% dos certificados**, independente do mercado de destino. Confirmado pelo PO em 2026-05-20. Prática observada nos 15 PDFs reais (100%). IT 7.10 não normatiza explicitamente, mas os gabaritos ilustrados na própria IT mostram bilíngue.

### 2.5 Selos (IT 7.10 §3.3)

Regra oficial: apenas **2 variantes** — **COM GAC** (cliente Golfo) ou **SEM selo** (não-Golfo). Selos adicionais de mercado de destino (Saudi Halal Center, ENAS, MUIS, BPJPH, JAKIM, etc.) existem no grid `logos.png` mas são exceções específicas, não a regra do upper-right padrão.

> **Nota — selo WHFC:** aparece em PDFs históricos (UAE puro, MUIS puro, asiático sem GAC) mas **não consta como variante oficial na IT 7.10 REV 04**. Tratar como legado; não modelar no catálogo do GC.

### 2.6 PDF aberto (desvio consciente da IT 7.10 §6)

IT 7.10 manda PDF protegido com senha "Fambras2018" (bloqueia copy/paste, edição). **Decisão Ecohalal+FAMBRAS atual: PDF sempre aberto, autenticidade via QR Code** (GAP-28 cancelado). Este desvio está registrado e foi acordado com a área de Qualidade da FAMBRAS.

---

## 3. Fixes entregues (2026-06-21)

Branch `release` do `halalsphere-backend`, commits `5c49d49e` e `b6d0ade1`.

### Fix #5 — EN+AR default em todas as variantes
- **Arquivo:** [`halalsphere-backend/src/certificate/data/seal-config.ts`](../../halalsphere-backend/src/certificate/data/seal-config.ts)
- **Mudança:** `requiresArabic: true` em todas as 16 `MARKET_VARIANT_CONFIGS` (era apenas em `GAC_ENAS` e `OIC_SMIIC`).
- **Commit:** `5c49d49e fix(seal-config): EN+AR mandatorio em todas variantes de mercado`

### Fix #1 — SEQQ global por ANOMES
- **Arquivo:** [`halalsphere-backend/src/fambras-numbering/fambras-numbering.service.ts`](../../halalsphere-backend/src/fambras-numbering/fambras-numbering.service.ts) — `getNextCertificateSequence`
- **Mudança:** query trocada de `startsWith('${abc}.${sig}.${anoMes}.')` para `contains('.${anoMes}.')`. Devolve `max(SEQQ)+1` sobre todos os certs do mês, qualquer cliente/cidade. Confirma alocação central (Halima/André) descrita na IT 7.10 §IV/§VIII.
- **Commit:** `b6d0ade1 fix(fambras-numbering): SEQQ global + ANOMES herdado da proposta`

### Fix #2 — ANOMES herdado da proposta original
- **Arquivo:** mesmo do #1 — novo método `resolveAnoMesFromProposal(certificationId)`
- **Mudança:** busca `Proposal` aceita → fallback para a mais antiga com `proposalNumber` definido → extrai `parts[2]` (formato `ABC.SIG.ANOMES.SEQ`). Fallback final = `generateAnoMes()` (mês atual) apenas se nenhuma proposal tem número.
- **Commit:** `b6d0ade1` (mesmo do #1)

**Testes:** 26/26 specs do `fambras-numbering.service.spec.ts` + 25/25 do `src/certificate/**` + `tsc -b` zero erros.

---

## 4. Gaps remanescentes (implementação pós go-live)

### Gap #3 — Issue date deve ser independente de cycle date
- **Arquivo:** [`certificate-pdf.service.ts:441`](../../halalsphere-backend/src/certificate/certificate-pdf.service.ts#L441)
- **Bug atual:** `issueDate = new Date(cycleDate)` força os dois sempre iguais.
- **Esperado:** issue date = `new Date()` (data atual do PDF) ou parâmetro independente — IT 7.10 §III: "issue date deve ser igual, ou **posterior**, a data do comitê". Manutenções anuais geram PDF com issue date avançado; cycle date permanece.
- **Severidade:** 🟡 Médio. Crítico se a FAMBRAS começar a re-emitir PDFs anuais antes do go-live.
- **Estimativa:** 1-2h (campo separado já existe — `Certificate.issuedAt`).

### Gap #4 — Splitting NORMA aves/bovinos no `manualEmit`
- **Arquivo:** [`certificate.service.ts::manualEmit`](../../halalsphere-backend/src/certificate/certificate.service.ts) (linha 763+)
- **Atual:** aceita 1 `templateCode` + array `applicableStandards[]` flat → gera 1 cert.
- **Esperado:** aceitar `marketBundles: [{ templateCode, applicableStandards[], normaIndex }]` que dispara `generateSlaughterhouseCertificateNumber` N vezes, criando N PDFs sob a mesma `Certification`. Aplicar tabela IT 4.2 (aves/bovinos) para mapear `applicableStandards[]` → `normaIndex`.
- **Severidade:** 🟢 Baixa pré go-live (operador pode emitir 3 vezes manualmente). Importante pós go-live para frigoríficos.
- **Estimativa:** 4-6h (DTO + service + transação atômica + UI).

### Gap #6 — `detectFormCode` ignorar K com SIF
- **Arquivo:** [`certificate-pdf.service.ts:400-414`](../../halalsphere-backend/src/certificate/certificate-pdf.service.ts#L400-L414)
- **Bug atual:** regra `categoryCode.startsWith('C') || 'D'` exclui Categoria K. Plantas de gelatina/heparina/pancreatina (matéria-prima animal, têm SIF) deveriam cair em **Habilitação COM SIF** (FM 7.7.1) mas vão para FM 7.7.2.
- **Esperado:** adicionar K na condição quando `plant.sanitaryCode && sanitaryCodeType !== 'INTERNAL'`.
- **Severidade:** 🟢 Pequena. Afeta apenas clientes K com SIF (volume baixo).
- **Estimativa:** 30min (incluindo teste).

---

## 5. Pendência externa (FAMBRAS)

🟡 **DT 7.9 (animal feed) e DT 7.11 (food services) ainda no catálogo ativo?**

IT 7.10 REV 04 (2022) lista apenas: DT 7.1, 7.2.1, 7.2.2, 7.3, 7.4, 7.5, 7.6, 7.7, 7.8, 7.10. Backend já tem ambas modeladas em [`dt-code-map.ts`](../../halalsphere-backend/src/certificate/data/dt-code-map.ts). Pode ser refinamento posterior da própria FAMBRAS. **Bater com Elaine** quando houver oportunidade.

**Impacto se forem inativas:** baixo — backend nunca seleciona DT 7.9/7.11 automaticamente (depende de configuração de subcategoria); risco zero de gerar cert com DT ilegítima por engano.

---

## 6. Auditoria — referências cruzadas

- **Memória GC:** [`project_cert_rules_it710_it42`](../../sih-docs/memory/project_cert_rules_it710_it42.md) (resumo executivo dos 6 gaps + 1 desvio consciente)
- **Memória PDF aberto:** [`feedback_pdf_certificado_aberto`](../../sih-docs/memory/feedback_pdf_certificado_aberto.md) (justificativa do desvio da IT 7.10 §6)
- **Memória regras adjacentes:**
  - [`project_certificate_immutability_rule`](../../sih-docs/memory/project_certificate_immutability_rule.md) — PDF imutável, correção = novo número
  - [`project_frigorifico_dual_cert_rule`](../../sih-docs/memory/project_frigorifico_dual_cert_rule.md) — dual cert GSO×SMIIC em abate mecânico
  - [`project_fm_41x_norms_per_market`](../../sih-docs/memory/project_fm_41x_norms_per_market.md) — REV 03 entregue 13/mai/2026

---

## 7. Próximas decisões pendentes

Nenhuma decisão de produto bloqueante. Todos os gaps remanescentes têm regra documentada e podem ser implementados sem nova consulta ao PO ou à FAMBRAS.

Quando a FAMBRAS migrar o processo de emissão para o GC (pós go-live), revisitar:
- **Splitting NORMA** (Gap #4) — vira fluxo principal
- **Issue date** (Gap #3) — vira crítico nas primeiras manutenções anuais
- **Reissue × novo número** — IT 4.2 distingue "manutenção sem mudança de escopo" (preserva número) de "manutenção com escopo alterado" (novo número). Hoje [`reissue()`](../../halalsphere-backend/src/certificate/certificate.service.ts#L668-L750) sempre preserva o número — verificar se isso cobre o segundo caso ou se precisa de função `reissueWithNewScope()`.
