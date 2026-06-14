# Cobertura do SIH vs. Processo de Emissão de Certificado Halal — JBS Exportação

> Análise: 2026-06-14. Base: processo real cedido pelo cliente em
> `C:\SIH\Exemplos\processo de emissão do certificado Halal da JBS`
> (embarque marítimo JBS Lins SIF 337 → JBS Toledo NV, Bélgica;
> CSI I0-00024442/337/26; certificado Halal final 2604UODG3).

## 1. O processo completo (documentos envolvidos)

| # | Documento | Origem | Papel | É dado do SIH? |
|---|-----------|--------|-------|----------------|
| 1 | **FM 7.1.7.1** Rel. Embarque Exportação (Rev.04) | Supervisor FAMBRAS | Consolida o embarque; exige CSI junto | **SIM** (relatório próprio) |
| 2 | **FM 7.1.3.1** Rel. Acomp. Fabricação Prod. Industrializados (Rev.04) | Supervisor FAMBRAS | 1+ por lote/produção; detalha MP cárnea e produto final | **SIM** (relatório próprio) |
| 3 | **FM 7.1.5.1** Inventário de Carne Halal (Rev.03) | Supervisor FAMBRAS | Entrada/saída de MP cárnea halal, saldo | **SIM** (relatório próprio) |
| 4 | **Planilha MP e Fornecedores** (FM 7.4.2.7 / FAM-0017) | FAMBRAS | Cadastro de insumos/MP aprovados (~640 itens) | **SIM** (base/cadastro) |
| 5 | **Lista de Produtos Halal** v143 (519 produtos) | FAMBRAS | Catálogo de produtos aprovados (código, marca, embalagem, selo) | **SIM** (base/cadastro) |
| 6 | **Certificado Halal final** (2604UODG3) | FAMBRAS (Gestão de Certificações) | Saída do processo; consolida 1-5 | NÃO — emitido no **HalalSphere/GC** |
| 7 | **CSI** I0-00024442 | MAPA/DIPOA (governo) | Cert. Sanitário Internacional; obrigatório p/ emitir o Halal | NÃO — **anexo externo** |
| 8 | **NF / DANFE** 376032 | JBS (fiscal) | Nota fiscal de exportação | NÃO — **anexo externo** |
| 9 | **Croqui** (ex. 0153/337) | JBS | Especificação de rótulo/selo Halal | Anexo (ou base de produto) |

**Insight central:** o embarque (FM 7.1.7.1) referencia **4 números de série
de relatório Halal** (337/2026/0010–0013) — que SÃO os relatórios de produção
(FM 7.1.3.1) já existentes na base. O embarque é o documento guarda-chuva que
**consolida dados que o SIH já tem** + **anexa documentos externos** (CSI, NF).

## 2. Cobertura atual do SIH por relatório

| Relatório | Modelo SIH | Cobertura | Observação |
|-----------|-----------|-----------|------------|
| FM 7.1.7.1 Embarque | `ShippingReport` + `ProductTable` | 🟡 **Parcial** | Cabeçalho OK; tabela de produtos com gap estrutural (ver §3) |
| FM 7.1.3.1 Produção | `ProductionReport` (fabricacao) | 🟡 **Parcial** | MP cárnea multi-origem em `meatRawMaterials Json` não estruturado |
| FM 7.1.5.1 Inventário | `MeatInventoryReceipt/Usage/Cut` | 🟢 **Boa** | Cobre recebimento (SIF, CSN, datas abate, cert, peso) e uso |
| Planilha MP/Fornecedores | — | 🔴 **Ausente** | Schema FAM-0017 proposto em mai/2026, não implementado |
| Lista de Produtos Halal | — | 🔴 **Ausente** | Não há catálogo de produtos; produto é texto livre |
| Certificado final | (HalalSphere) | N/A | Fora do SIH |
| CSI / NF (anexos) | `ReportAttachment` (S3) | 🟢 **OK** | Categorias CSI, NOTA_FISCAL; Croqui cai em OUTRO |

## 3. Gaps estruturais (prioridade)

### 🔴 GAP-1 (crítico) — Composição multi-origem por produto no embarque
No FM 7.1.7.1, a coluna **"Data do Abate da carne ou matéria-prima usada"**
lista, por produto, **vários SIFs com várias faixas de datas de abate**.
Ex.: produto 373477 (Língua Bov.) = 7 frigoríficos (42, 51, 337, 385, 615,
3225, 4400), cada um com sua faixa de datas. Idem múltiplas datas de
produção/validade por produto.
- **SIH hoje:** `ProductTable.slaughterDate` é **um** campo de data única;
  `productionDate`/`expiryDate` idem.
- **Necessário:** por linha de produto, uma sub-lista de origens
  `{ sif, slaughterDateStart, slaughterDateEnd }` + múltiplas datas de
  produção/validade. Idealmente derivada do inventário (FM 7.1.5.1).

### 🟡 GAP-2 — Múltiplos relatórios Halal / invoices no embarque
- `halalSerialNumber String?` guarda 1 valor; o embarque real referencia **4**
  (337/2026/0010–0013). `orderNumber String?` idem (4 invoices).
- **Necessário:** vínculo M:N do embarque a **relatórios de produção da base**
  (não texto), e lista de invoices. Isso é o "documento de suporte que está na
  base do próprio SIH".

### 🟡 GAP-3 — MP cárnea estruturada no FM 7.1.3.1
Tabela com colunas: Tipo proteína, Frigorífico, **SIF**, Data abate (range),
**CSN**, **Nº Certificado Halal/Pedido**, Quant. kg.
- **SIH hoje:** `meatRawMaterials Json` (livre).
- **Necessário:** estruturar (ideal: referência ao inventário de carne halal,
  que já tem SIF/CSN/datas/peso).

### 🟢 GAP-4 — Cadastros de base ausentes
- **Catálogo de Produtos Halal** (código, nome, marca, embalagem, selo,
  validade aprovação) — hoje produto é digitado livre, sem validação.
- **Cadastro de MP/Fornecedores** (FAM-0017) — proposto, pendente.
- Esses cadastros permitiriam autocompletar/validar produto e MP no embarque
  e na produção em vez de redigitar.

### 🟢 GAP-5 — Categoria de anexo "Croqui/Rótulo"
Croqui cai em OUTRO. Pequeno: adicionar categoria.

## 4. Visão arquitetural recomendada

O embarque NÃO deve ser digitação isolada + PDF anexado. Deve:
1. **Consolidar da base:** vincular aos relatórios de produção (FM 7.1.3.1) e
   ao inventário (FM 7.1.5.1) que originam a carga → daí derivam produto,
   código, lote, SIFs de origem, datas de abate, pesos.
2. **Anexar externos:** CSI (obrigatório), NF, croqui — via S3 (já pronto).
3. **Validar contra cadastros:** produto contra Lista de Produtos Halal; MP
   contra cadastro de fornecedores.

## 4.1 DECISÃO DO PO (2026-06-14): vínculo, não captura manual

O embarque **vinculará aos relatórios de produção (FM 7.1.3.1) já lançados no
SIH** e derivará deles a composição por produto (código, lote, SIFs de origem,
faixas de data de abate, pesos) — em vez de redigitação manual + PDF.
- `ShippingReport` ⇄ M:N `ProductionReport` (e, conforme o caso, inventário de
  carne / abate).
- Os "números de série de relatório Halal" do embarque (ex.: 337/2026/0010–13)
  passam a SER os relatórios vinculados (não `halalSerialNumber` texto).
- **Dependência:** o vínculo só entrega as datas de abate multi-origem se o
  FM 7.1.3.1 tiver a MP cárnea ESTRUTURADA (GAP-3). Logo GAP-3 é pré-requisito
  de GAP-1/GAP-2 — define a ordem de implementação.
- Aguardando análises adicionais do PO antes de fechar o plano de implementação.

## 5. Próximos passos sugeridos (a priorizar com PO)

1. **GAP-1 + GAP-2** (núcleo do embarque de exportação) — sub-tabela de
   origens por produto + vínculo a relatórios de produção. É o que torna o
   FM 7.1.7.1 fiel ao documento real.
2. **GAP-3** — estruturar MP cárnea do FM 7.1.3.1 (idealmente via inventário).
3. **GAP-4** — catálogo de produtos + cadastro MP (FAM-0017) como base.
4. **GAP-5** — categoria Croqui (trivial).

> Decisão de modelagem relacionada: alinhamento `sanitaryCode` (nullable +
> `SanitaryCodeType`) com o GC — necessário para SIFs e plantas sem SIF
> (ver análise COLABORADORES INDUSTRIAL / import 2026-06).

---

# 6. Subprodutos — Couro, Mucosa, Tripa (mercado interno, 2026-06-14)

Análise de 3 processos completos (pastas `C:\SIH\Exemplos\{Couro,Mucosa,Tripa}`).
Cada processo = relatório de produção + relatório de expedição + DCPOA + NF +
certificado Halal final.

## 6.1 Formulários FM mapeados (novos)

| FM | Título | Tipo | SIH cobre? |
|----|--------|------|-----------|
| **FM 7.1.4.5** | Produção/Venda/Emissão cert — Pele Bovina (couro) | Produção | `ProductionReport` type=couro + `CouroFields` |
| **FM 7.1.4.6** | Acomp. Fabricação de Mucosa em Tanques | Produção | type=mucosa + `MucosaFields` |
| **FM 7.1.3.3** | Produção de Tripas Calibradas e Salgadas | Produção | type=tripas + `TripasFields` |
| **FM 7.1.7.4** | Expedição venda mercado interno — carne/cárneos | Expedição | `ShippingReport` (venda_interna) |
| **FM 7.1.7.12** | Venda interna Mucosa/Timo/Pâncreas/Placenta/Fígado | Expedição | `ShippingReport` (venda_subprodutos) |
| **FM 7.7.3** | Certificado de Abate Halal (final) | Certificado | **HalalSphere/GC** (não SIH) |

## 6.2 Boa notícia — cobertura de tipos é forte

- **Campos específicos por subproduto JÁ existem**: `MucosaFields`
  (rulerStartMarked/rulerEndMarked = "marcação de régua do tanque"),
  `TripasFields` (casingType "Tipo Tripa", drumsCount "Nro Bombonas"),
  `CouroFields` (preservativeProduct/Batch = "conservante"). Salvos em
  `customFields Json`.
- **Número de série no formato correto**: `serial-number.util` gera
  `SIF{code}/{year}/{seq}` (ex.: SIF337/2026/00001) — bate com os documentos
  reais ("337/2026/0010", "SIF 49/2026/00003").
- **Tipos de expedição cobertos** (venda_interna, venda_subprodutos,
  transferencia_subprodutos, venda_subprod_couro...).

## 6.3 Os mesmos gaps estruturais se repetem — e o vínculo resolve TODOS

Todos os relatórios de expedição (FM 7.1.7.1 exportação, 7.1.7.4 interno,
7.1.7.12 subprodutos) compartilham a MESMA estrutura: informações de
expedição + tabela de produtos (datas de abate/produção como **range**) +
checagem final C/NC + **número de série do relatório Halal** (= o relatório
de produção da base). Logo:
- **GAP-1/GAP-2 são transversais** — a DECISÃO DE VÍNCULO (§4.1) resolve
  exportação E subprodutos de uma vez. A solução é unificada, não por tipo.
- Nos subprodutos a multi-origem é mais simples que no exportação (range de
  datas por produto, não N SIFs por produto), mas a modelagem é a mesma.

## 6.4 Novo gap — DCPOA (mercado interno)

**DCPOA = Declaração de Conformidade de Produtos de Origem Animal** (MAPA/SIF,
governo). É o documento sanitário **obrigatório do mercado interno**, análogo
ao CSI da exportação. Aparece nos 3 subprodutos como pré-requisito do
certificado Halal.
- **SIH hoje:** `ShippingReport` tem `csiNumber`, `sealNumber`; **não tem**
  campo DCPOA/CSN dedicado. `csnNumber` existe só em inventário/lote.
- **Necessário:** campo DCPOA/CSN no embarque interno + **categoria de anexo
  DCPOA** (hoje cairia em OUTRO; já temos CSI, CSN, INVOICE, BL, NF, ROMANEIO).

## 6.5 Cadeia de documentos (igual nos 3 subprodutos)

INTERNO (SIH gera): relatório de produção (FM 7.1.x) → relatório de expedição
(FM 7.1.7.x, referencia a produção pelo nº série Halal).
EXTERNO (anexar): **DCPOA** (MAPA, obrigatório), **NF/DANFE** (frigorífico),
**Croqui** (rótulo), eventual **CCE** (carta de correção da NF).
SAÍDA: Certificado Halal final (FM 7.7.3) emitido no **GC/HalalSphere**.

## 6.6 Conclusão consolidada

O SIH **cobre bem os tipos** de subproduto (produção e expedição, com campos
próprios). Os gaps são os **mesmos do embarque exportação** (multi-origem +
vínculo aos relatórios de produção) — resolvidos pela decisão de vínculo já
tomada — **mais** o DCPOA (campo + categoria de anexo) específico do mercado
interno. Nenhum tipo de processo está descoberto; o trabalho é estrutural
(vínculo) + incremental (DCPOA), não criar relatórios novos do zero.

---

# 7. In Natura — Abate, Embarque, Venda Interna, Transferência (2026-06-14)

Relatórios reais preenchidos (`C:\SIH\Relatórios Preenchidos InNatura`).

## 7.1 ABATE — 🟢 bem coberto (valida o piloto atual!)

| FM | Título | SIH |
|----|--------|-----|
| **FM 7.1.4.2** Rev 06 | Abate e Controle da Carcaça Halal — BOVINO | `SlaughterReport` (species=bovino) |
| **FM 7.1.4.1** Rev 05 | Abate e Controle Halal — AVES | `SlaughterReport` (species=ave) |

Campos do FM 7.1.4.2 (bovino) batem com o `SlaughterReport`:
- contagem (total/rejeitadas/sequencial/aproveitadas) ✓
- insensibilização sim/não + avaliação ✓ (`stunningVerifications`)
- avaliação das câmaras (qtd carcaças + IDs câmaras) ✓ (`coolingCarcasses`/`coolingCameras`)
- venda de subprodutos sim/não + descrição ✓ (`byproductsSold`/`byproductsDescription`)
- 14 itens de verificação C/NC ✓ (`verificationItems`)

**Diferença AVES (FM 7.1.4.1):** insensibilização é uma **tabela de parâmetros
elétricos** (amperagem, voltagem, frequência, tempo de cuba, velocidade da
linha, tempo de retorno) × **2 horários/turno**; não tem câmaras nem
subprodutos; 13 itens C/NC (inclui transporte/gaiolas). O SIH guarda stunning
em `Json` + `makeAvesStunning()` no form. **Verificar:** completude dos 6
parâmetros × 2 horários de aves e os 13/14 itens C/NC por espécie.
> O abate é o relatório do piloto (Sameh/Minerva) — esta cobertura confirma
> que a tela em uso está fiel ao FM. ✅

## 7.2 EXPEDIÇÃO — família de 3 tipos (1 novo)

| FM | Tipo | Doc. sanitário | Nº série Halal |
|----|------|----------------|----------------|
| **FM 7.1.7.1** | Embarque exportação | **CSI** (I0-…) | SIF/ANO/SEQ |
| **FM 7.1.7.4** | Venda mercado interno | **CSN** (N0-…) | SIF/ANO/SEQ |
| **FM 7.1.7.3** Rev 01 | **Transferência entre mesmo grupo** | DCPOA (opcional) | SEQ/SIF/AA |

- Os 3 compartilham o miolo (informações de expedição + tabela de produtos +
  nº série Halal) → **vínculo resolve a multi-origem nos 3**.
- **FM 7.1.7.3 (transferência mesmo grupo) é estruturalmente diferente:**
  expedidor/destinatário do grupo (SIF origem→destino), **verificação do
  veículo**, **temperatura tripla** (início/meio/fim), perguntas **S/N** (não
  C/NC), validade 30 dias, assinatura eletrônica. O SIH tem
  `shippingType=transferencia*`, mas **os campos próprios do 7.1.7.3 precisam
  ser verificados** (provável cobertura parcial via customFields).

## 7.3 Documento sanitário tem 3 "sabores" → generalizar

CSI (exportação) · CSN (mercado interno) · DCPOA (transferência/trânsito) —
todos do MAPA, mesma família. O SIH só tem `csiNumber` dedicado no embarque.
**Necessário (consolida o GAP-6):** um campo de documento sanitário com
**tipo** (CSI/CSN/DCPOA) no `ShippingReport`, e **categorias de anexo CSN e
DCPOA** (já temos CSI). Cada tipo de expedição exige o seu.

## 7.4 Conclusão In Natura

- **Abate:** cobertura forte; valida o piloto. Só conferir completude do
  stunning de aves e dos itens C/NC por espécie.
- **Expedição:** exportação e venda interna seguem o padrão (vínculo resolve);
  **transferência entre mesmo grupo (FM 7.1.7.3) é o tipo que mais diverge** e
  merece checagem dedicada de campos.
- **Sanitário:** generalizar para CSI/CSN/DCPOA (campo + anexos).

---

# 8. Industrializados — derivados e fracionamento (2026-06-14)

21 relatórios reais (`C:\SIH\Relatórios Preenchidos Industrializados`),
cobrindo a família 7.1.8.x (heparina, raspa, gelatina) + 7.1.3.x.

## 8.1 Produção de derivados — 🟢 componentes do SIH batem

| FM | Produto | Campos próprios | SIH |
|----|---------|-----------------|-----|
| **FM 7.1.8.2** | Heparina sódica (etapa bruta) | MP=mucosa; recebimento; doc halal | `HeparinaBrutaFields` ✓ (rawMaterial/slaughterhouse/sif/receivingNumber/halalDocument/qtd) |
| **FM 7.1.8.3** | Heparina (purificação) | **lote-mãe** (torta da etapa 2); etapa | `HeparinaPurificacaoFields` (verificar lote-mãe) |
| **FM 7.1.8.5** | Couro/Raspa/Apara | checkbox tipo; MP com **DCPOA** | `RaspaFields` ✓ |
| **FM 7.1.8.6** | Gelatina | **BLOOM/MESH**; origem **curtume** (não SIF abate); descarte inicial | `GelatinaFields` ✓ (lote curtume + distribuidora) |
| **FM 7.1.3.5** | Fracionamento corned beef | **entrada vs saída** (2 tabelas); lote-mãe | `FracionamentoFields` (verificar entrada/saída) |
| **FM 7.1.3.1** | Fígado em pó | = industrializados à base de carne | `ProductionReport` type=fabricacao |

> Confirmação por código: os componentes de produção do SIH capturam os campos
> específicos de cada derivado. Cobertura de produção é forte.

Particularidades a lembrar na modelagem:
- **Heparina:** rastreabilidade lote-mãe→lote-filho entre 7.1.8.2 e 7.1.8.3
  (vínculo entre dois relatórios de produção).
- **Gelatina:** MP vem de **curtume** (origem não é SIF de abate) — o modelo de
  origem não pode assumir sempre SIF/frigorífico.
- **Fracionamento:** modelo entrada(bulk)→saída(embalado), com SIF da unidade
  de embalagem.

## 8.2 Expedição/transferência — muitas variações, 2 arquétipos

Os ~9 formulários de expedição/transferência reduzem-se a **2 arquétipos** que
o SIH já modela (ShippingReport + shippingType + ShippingExtraFields):
- **EMBARQUE/EXPEDIÇÃO** (tabela completa): 7.1.7.1, 7.1.7.2 (gelatina), 7.1.7.5
  (raspa s/ cárneo). Verificação "contêiner carregado exclusivamente Halal".
- **TRANSFERÊNCIA** (tabela reduzida): 7.1.7.3 (mesmo grupo), 7.1.7.9 (Seara/JBS),
  7.1.4.8.B (projeto Genu-in/Novapron), 7.1.8.4 (heparina), 7.1.8.x (gelatina).
  Verificação "somente produtos transferidos são Halal".

Variações observadas (parametrizáveis por tipo):
- **Doc sanitário:** CSI / CSN / DCPOA / nenhum (transferência interna).
- **Tabela:** completa (produto+código+lote+datas+volumes+pesos+temp) vs
  **reduzida** (produto+lote+volumes+data fab+peso) vs **mínima** (7.1.7.9:
  só produto+data abate+qtd, com CSN anexo fazendo o detalhe).
- **Nº série Halal:** presente em alguns (7.1.7.1, 7.1.7.4, 7.1.7.9), ausente
  em outros.

## 8.3 Conclusão Industrializados

O SIH **espelha bem os dois arquétipos** (produção com tipos+componentes;
expedição com tipos+extra fields). Nenhum derivado está descoberto. Gaps =
os mesmos transversais (vínculo, doc sanitário CSI/CSN/DCPOA), **mais** dois
refinamentos: (a) **variação da tabela de produtos por tipo de expedição**
(completa/reduzida/mínima — hoje `ProductTable` é fixa); (b) **origem não-SIF**
(curtume na gelatina) e **vínculo entre relatórios de produção** (lote-mãe da
heparina, entrada/saída do fracionamento).

---

# 9. SÍNTESE FINAL — cobertura de TODO o ecossistema FAMBRAS

Analisados: In Natura (abate, embarque, venda, transferência), Subprodutos
(couro, mucosa, tripa), Industrializados (heparina, raspa, gelatina,
fracionamento, fígado) + processo completo de exportação JBS.

**Todos os ~30 formulários FM reduzem-se a 4 arquétipos que o SIH já modela:**
1. **ABATE** (FM 7.1.4.1/4.2) → `SlaughterReport` — 🟢 forte (piloto validado).
2. **PRODUÇÃO** (FM 7.1.3.x, 7.1.4.x, 7.1.8.x) → `ProductionReport` + tipo +
   componente — 🟢 forte (componentes batem).
3. **EXPEDIÇÃO/TRANSFERÊNCIA** (FM 7.1.7.x) → `ShippingReport` + tipo — 🟡
   parcial (miolo OK; faltam vínculo, doc sanitário, variação de tabela).
4. **CERTIFICADO final** (FM 7.7.3) → **GC/HalalSphere**, não SIH.

**Gaps consolidados (poucos, transversais):**
| # | Gap | Alcance | Status |
|---|-----|---------|--------|
| A | **Vínculo** produção/MP → expedição (multi-origem) | Todos os embarques/transf. | Decidido (§4.1) |
| B | **Doc sanitário** CSI/CSN/DCPOA (campo+tipo+anexos) | Todas as expedições | A fazer |
| C | **Variação da tabela** de produtos por tipo de expedição | Expedição/transf. | A fazer |
| D | **Origem não-SIF** (curtume) + vínculo entre produções (lote-mãe) | Gelatina, heparina, fracionamento | A fazer |
| E | **Cadastros de base** (catálogo produtos + MP/fornecedores FAM-0017) | Validação geral | A fazer |
| F | **DCPOA/CSN como categoria de anexo** + Croqui | Anexos | Trivial |

**Conclusão:** nenhum tipo de relatório do ecossistema está descoberto. O SIH
tem a arquitetura certa (4 arquétipos). O trabalho restante é **estrutural**
(vínculo + doc sanitário) e **incremental** (variações de tabela, cadastros,
categorias de anexo) — não há relatório a criar do zero.
