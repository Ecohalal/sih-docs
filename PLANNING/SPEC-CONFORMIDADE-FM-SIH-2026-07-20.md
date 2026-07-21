# SPEC — Conformidade FM (papel) × SIH (sistema)

**20/jul/2026** · origem: hands-on FAMBRAS 17/jul (Vitor Henrique, André, Nilsa) + documentos reais
enviados pelo Vitor em 20/jul (`C:\SIH\Meetings\handson 1707\Testes`).

> **Para que serve:** até aqui as divergências entre o formulário FM em papel e o sistema foram
> descobertas **ao vivo, na frente do cliente**. Agora temos os FM oficiais **preenchidos e
> assinados** em mãos. Esta spec cruza campo a campo, para que o próximo hands-on valide o que
> foi corrigido em vez de descobrir o que falta.
>
> **Não é backlog.** Os itens acionáveis vão para o §4 do `BACKLOG-ECOHALAL.md` (fonte única).

---

## 0. Fontes

**Documentos oficiais (fora de git — `C:\SIH\Meetings\handson 1707\Testes\`):**

| FM | Rev / Data | Documento real | Planta |
|---|---|---|---|
| **7.1.4.1** — Abate e Controle Halal · AVES | Rev 05 · 03/04/2024 | `Testes AVES/20.04.2026 1T E 2T.pdf` | BRF Dourados **SIF 18** · sup. Ziad Mansour |
| **7.1.4.2** — Abate e Controle da Carcaça · BOVINO | **Rev 06 · 14/01/2026** | `Testes BOVINOS/03.03.2026 com insensibilizao.pdf` | JBS Vilhena SIF 4333 · sup. Abdelhakim Roumadi |
| **7.1.7.1** — Acompanhamento de Embarque · Exportação | Rev 04 · 17/12/2021 | `Testes AVES/TEMU9380381.pdf` · `Testes BOVINOS/CAAU4237772.pdf` | BRF Dourados SIF 18 → Omã · JBS Vilhena → EUA |
| **7.1.7.4** — Expedição: venda mercado interno | Rev 05 · 17/12/2021 | `REL VENDA MERCADO INTERNO PARA EMISSO (5).pdf` | Vale Company SIF 4466 |
| **7.1.7.11** — Transferência: **exclusivo entre BRF** | **Rev 01 · 06/07/2020** | `Testes AVES/image2026-05-26-164618.pdf` *(localizado em 21/jul)* | BRF Dourados SIF 18 → BRF Concórdia SIF 1 · sup. Ziad Mansour |

⚠️ **Falta o FM 7.1.7.3** (transferência) preenchido — é o único dos cinco sem documento oficial em mãos;
o que sabemos dele veio da conversa da reunião de 17/jul.

Documentos de respaldo no pacote: CSI do MAPA, DCPOA, CSN, nota fiscal.

**Código:** `sih-backend` `7bc4768` · `sih-frontend` `9a6e282` (ambos em `ecohalal/release`, 20/jul).

**Método:** leitura dos FM preenchidos (renderizados via PyMuPDF; os escaneados não têm camada de
texto) + inventário de campos no código + consulta ao banco de prod (leitura). Onde não verifiquei,
está marcado **[NÃO VERIFICADO]**.

---

## 1. 🟥 P0 — Verificações de AVES saem trocadas no PDF

**O achado mais grave desta spec. Não é cosmético: o documento assinado atesta item diferente do
que o supervisor marcou.**

O C/NC é casado **por índice posicional** (`slaughter-report-pdf.ts:46-49`, `getVerValue`). A lista
do frontend (`SlaughterReportForm.tsx:123-136`) tem **12** itens; a do PDF
(`slaughter-report-pdf.ts:12-26`) tem **13**.

| Índice | Front — o que o supervisor marca | PDF — o que é impresso | |
|---|---|---|---|
| 0 | Somente animais sadios | A empresa pratica o bem estar animal | 🟥 trocado |
| 1 | Empresa comprometida com bem-estar | Somente animais saudáveis | 🟥 trocado |
| 2–9 | — | — | ✅ alinhados |
| 10 | Carcaças Halal identificadas e carimbadas | **Tempo de sangria ≥ 3 minutos** | 🟥 atesta outra coisa |
| 11 | Carcaças não-Halal descartadas | Carcaças não Halal descartadas | ✅ |
| 12 | *(não existe)* | Produtos finais identificados | 🟥 sempre em branco |

**Quem está certo:** o **PDF**. Os 13 itens batem 1:1 com o FM 7.1.4.1 Rev 05 (pág. 1 traz
*"A empresa pratica o bem estar animal"* como primeiro item; pág. 2 traz os outros 12).

**O frontend está errado em três pontos:**
1. ordem dos dois primeiros invertida;
2. falta *"O tempo de sangria é igual ou superior a 3 minutos…"*;
3. tem *"Todas as carcaças Halal identificadas e carimbadas"*, que **no FM de aves não existe** —
   é item do FM bovino (7.1.4.2, pág. 3), copiado indevidamente.

**Impacto real hoje:** 2 relatórios de aves em prod, ambos `assinado`, ambos com 12 itens gravados —
e são **os dois preenchidos ao vivo na reunião de 17/jul** (data 20/04/2026, 1º e 2º turno). Nenhum
relatório de operação real foi afetado. **A janela fechou por sorte, não por controle.**

**Correção:** fonte única de verdade para as listas de verificação, consumida pelo front e pelo PDF
(a pasta `sih-backend/src/slaughter-report/constants/` existe e está **vazia** — era para isso).
Enquanto houver duas listas mantidas à mão, o desalinhamento volta.

⚠️ **Ao corrigir, atenção aos 2 relatórios já assinados:** eles têm 12 itens gravados contra a lista
antiga. Reimprimir o PDF depois da correção desloca os valores **de novo**, agora ao contrário.
Como são dados de teste, a saída limpa é descartá-los. **[decisão do Renato]**

**Bovino:** 14 × 14, alinhado 1:1. Sem problema.

---

## 2. FM 7.1.4.1 / 7.1.4.2 — Relatório de Abate

### 2.1 O que está correto

| Item do FM | Situação |
|---|---|
| Ordem **Total → Rejeitadas → Aproveitadas** | ✅ corrigido em 20/jul (`9a6e282`). O FM diz, nesta ordem: *"Número total de aves abatidas Halal / Número de aves rejeitadas, mal sangradas, condenadas / Número de aves Halal aproveitadas"* (71.473 / 672 / 70.801) |
| **Horário 1 / Horário 2** da insensibilização | ✅ criado em 20/jul. No FM os horários (`08:00`, `10:45`) ficam na **linha de cabeçalho** da tabela, acima dos parâmetros — foi onde o PDF passou a imprimi-los |
| **Tempo de cuba decimal** (`0.08 s`) | ✅ corrigido em 20/jul (`step="any"`). Era o valor exato que o sistema recusava |
| Identificação das **câmaras** de resfriamento (bovino) | ✅ existe (`coolingCameras`), texto livre. FM usa `5B, 6B`; placeholder da UI sugere `Câmara 1, Câmara 2` — só cosmético |
| **Venda de subprodutos** (bovino) | ✅ existe (`byproductsSold` + `byproductsDescription`) |
| Nota **GSO 993 proíbe insensibilização** p/ o Golfo | ✅ impressa no PDF |

### 2.2 Divergências abertas

| # | FM manda | Sistema faz | Gravidade |
|---|---|---|---|
| A1 | **Tempo de retorno em `m:ss`** — `0:40`, `1:00` | Campo `type="number"`; `m:ss` é indigitável. **Na reunião, `1:04` virou `104`** (o correto em segundos seria 64). O PDF imprime o valor cru, sem unidade | 🟧 **erro de dado já observado ao vivo** |
| A2 | **Observações** — no FM de aves lido, preenchido à mão (*"0 vivo e 0 mal sangrado"*) | Campo existe e é salvo, mas **o PDF nunca imprime o valor** — só o rótulo estático "Observações / Comments:" | 🟧 dado do supervisor se perde na impressão |
| A3 | Declaração: *"Eu, **ZIAD MANSOUR**, portador do **V444820C**…"* | Não existe campo de documento do assinante. O PDF reaproveita `slaughtererDoc` (documento do **degolador**), que **não tem input na UI** desde que o degolador saiu do form ⇒ sempre vazio ⇒ a declaração sai **sem o número do documento** | 🟧 exigência do FM não atendida |
| A4 | *"Nome do Supervisor"* é campo próprio do FM | PDF imprime `report.user.name` — o **criador** do relatório, que pode não ser quem assinou (`signedBy`) | 🟧 |
| A5 | Turno: `1ºTURNO` (aves) e `I` (bovino) | Enum `matutino/vespertino/noturno/integral`, impresso **cru** (sai `matutino`). Na reunião ficou decidido "deixa assim por enquanto", mas o FM real usa numeração | 🟨 |
| A6 | Nota: *"realizar duas verificações por turno, **em horários alternados**"* — vale p/ bovino também | Campo Horário só foi criado no bloco **aves**. Bovino usa "Conferência 1/2" sem hora | 🟨 |
| A7 | Nota: *"Em caso de não conformidade, preencher o check list **FM 7.1.6.1**"* | Marcar NC não vincula nem sugere o relatório de NC. O FM 7.1.6.1 está no backlog, mas **sem esta amarração registrada** | 🟨 |
| A8 | — | `serialNumber` **não sai no PDF** (só na tela) | 🟨 |
| A9 | — | `formNumber` gravado é **ignorado** no PDF (derivado de `species`); backend não valida coerência espécie↔FM | 🟨 |
| A10 | Sequência de rejeitados existe nos dois FM | Input aparece para aves, mas **só é impresso para bovino** | 🟨 |
| A11 | — | `verificationItems` é `z.any()` — dá para **assinar com itens `null`** (nenhuma completude exigida) | 🟧 |

### 2.3 Estrutura difere por espécie — confirmado no papel

- **Aves (7.1.4.1):** 13 verificações · **sem** bloco de câmaras · **sem** subprodutos.
- **Bovino (7.1.4.2):** 14 verificações · **com** câmaras (qtd + quais) · **com** subprodutos.

O sistema já suprime câmaras/subprodutos para aves. ✅

---

## 3. FM 7.1.7.1 — Embarque / Exportação

### 3.1 Cabeçalho

| Campo do FM | Sistema |
|---|---|
| Data do carregamento · Exportador · Frigorífico de abate (nome+end+SIF) · Unidade produtora · Endereço de carregamento · Importador/Consignatário · Tipo de transporte · Porto de embarque · Identificação do navio/caminhão · **Nº do contêiner** · Porto e país destino · Nº do pedido/Invoice · **Nº do CSI** · **Nº do lacre** | ✅ em geral cobertos — **[NÃO VERIFICADO campo a campo]** |
| **Endereço de carregamento** | 🟧 autofill só dispara ao trocar a planta **e** só se o campo estiver vazio → foi o "Passo Fundo" errado da reunião |
| **Nº de série do relatório Halal** | 🟧 ver §5.1 |

### 3.2 Tabela de produtos — colunas oficiais

`Produto · Código · Lote · Data do Abate · Data de Produção · Data de Validade ·`
**`Natureza dos volumes (ex. caixa, saco, tambor)`** `· Número de volumes · Peso Líquido (kg) ·`
`Peso Bruto (kg) · Tº embarque` **+ linha `TOTAL`**

| # | FM manda | Sistema faz | Gravidade |
|---|---|---|---|
| E1 | **"Natureza dos volumes"** — `CAIXAS` (aves), `Peça(s)` (interno) | Existe `packageType` (texto livre) + `quantity`, mas **sem unidade explícita**. Foi o que fez **1.450 caixas serem lançadas como quilos** na reunião | 🟧 |
| E2 | **Linha TOTAL** — `2.688 volumes / 26.880,000 kg` | **Não existe** — nem na tela nem no PDF. Pedido explícito na reunião | 🟧 |
| E3 | **Datas em faixa** — CSI traz `24/02/2026 A 27/02/2026`; o interno empilha 2 datas por item | Modelagem **já existe** (`slaughterDateStart/End`, `productionDateStart/End`, `expiryDateStart/End`) — falta a UI expor como faixa | 🟨 (metade do caminho pronto) |
| E4 | Produto vem do escopo/habilitação (pedido do André: lista suspensa + campo livre de detalhe) | `products` é `z.any()`, nome é **texto livre**, **nenhum campo obrigatório**. E o GC **não expõe endpoint de escopo** — só `raw-materials/by-plant` e `plant-summary` | 🟥 exige rota nova no GC |
| E5 | Checagem final do contêiner: 2 perguntas C/NC (*"carregado exclusivamente com produtos certificados Halal?"* e *"todos identificados com o selo do mercado destino"*) | **[NÃO VERIFICADO]** se existem no SIH | ❓ |
| E6 | Declaração com **nº do documento do supervisor** (`V444820C`, `703.576.482-85`) | Mesmo gap do A3 | 🟧 |

### 3.3 Anexos — a regra está impressa no formulário

> **OBRIGATÓRIO ANEXAR O DOCUMENTO SANITÁRIO (CSI OU DCPOA) E A NOTA FISCAL**

São **dois** anexos obrigatórios, não um. E o formulário ainda avisa:

> ESTE DOCUMENTO NÃO É VÁLIDO COMO CERTIFICADO HALAL. É OBRIGATÓRIA A EMISSÃO DO CERTIFICADO HALAL POR EMBARQUE.

| # | Situação | Gravidade |
|---|---|---|
| E7 | Categorias de anexo **já existem** (`CSI, CSN, DCPOA, INVOICE, BL, NOTA_FISCAL, ROMANEIO, CROQUI, OUTRO`) — ✅ nada a criar | — |
| E8 | **Nenhuma obrigatoriedade** em nenhum ponto: `sign()` e `approve()` não consultam anexos | 🟧 |
| E9 | Anexo só aparece **depois de salvar** (precisa do `report.id`) | 🟨 UX |

> ⚠️ Correção de registro: em 20/jul afirmei que faltava a categoria "DIPOA". Errado — o nome é
> **DCPOA** e ele já existe. Faltava só a regra de obrigatoriedade.

---

## 4. FM 7.1.7.4 — Venda mercado interno

Formulário **distinto** do 7.1.7.1, com campos próprios:

| Campo exclusivo | Sistema |
|---|---|
| **Vendedor** (`1 - VALE COMPANY`) | ✅ existe (`seller`) — *verificado 21/jul* |
| **Cliente** (no lugar de Importador/Consignatário) | ✅ existe (`client`) — *verificado 21/jul* |
| **Endereço destino** | ✅ existe (`destinationAddress`) |
| **Nº do documento sanitário (CSN ou DCPOA)** — campo próprio no cabeçalho, além do anexo | ✅ existe (`sanitaryDocType` + `sanitaryDocNumber`) — *verificado 21/jul* |
| Tipo de transporte: só *terrestre/aéreo* (sem marítimo) | **[NÃO VERIFICADO]** se o enum restringe por tipo de FM |

O título diz **"para emissão do certificado halal"** — este relatório alimenta a emissão, como o
7.1.7.1. Transferência (7.1.7.3) **não gera certificado** (confirmado pelo Vitor na reunião).

---

## 5. Regras transversais descobertas no papel

### 5.1 Número de série do relatório Halal — regra normativa que o sistema não implementa

> **Nota 1.** Número sequencial de relatórios emitidos pela unidade para cada embarque/venda e/ou
> transferência, respeitando o seguinte ID **(SIF, ANO e NÚMERO DE SÉRIE)**.

É **uma sequência única por planta**, cobrindo embarque + venda + transferência juntos.

Hoje: `halalSerialNumber String?` — **opcional, texto livre, sem geração, sem formato, sem unicidade**.

E os três documentos reais preenchem de **três jeitos diferentes**:

| Documento | Valor | Forma |
|---|---|---|
| Aves BRF Dourados | `18/2022/0000200` | sem prefixo · 7 dígitos · **ano 2022 num embarque de jan/2026** ⚠️ |
| Venda interna Vale | `4466/2026/000122` | sem prefixo · 6 dígitos |
| Bovino JBS Vilhena | `SIF 4333/2026/00088` | **com** prefixo "SIF" · 5 dígitos |

⚠️ O campo do documento de aves está apagado no scan — o "2022" pode ser erro de leitura minha
**ou** erro de preenchimento da planta. Vale conferir com o Vitor.

❓ **Decisão FAMBRAS:** qual é o formato canônico, e o sistema passa a **gerar** o número (hoje o
supervisor digita)? Se gerar, ele vira chave natural — e uma âncora bem melhor que `container + data`
para o vínculo com o SysHalal (§5.3).

### 5.2 Correção de relatório — regra própria, análoga à imutabilidade do certificado

> **Nota 2.** Em caso de cancelamento e correção, carimbar **"CANCELADO"** e adicionar um **A
> (alterado)** no novo relatório corrigido, **mantendo a mesma série**. Ex.: `SIF XXXX/ANO/00001A`.

Não existe nada disso no SIH: não há cancelamento com carimbo, nem versionamento por sufixo, nem
vínculo entre o relatório corrigido e o original. Conversa direto com o item **draft→aprovar→travar**
e com a auditoria por linha exigida pela ISO 17065.

### 5.3 Ciclo embarque ⇄ SysHalal — o que a reunião decidiu

**In Natura NÃO trava o Relatório de Embarque** pelo nº do certificado. Razão operacional (André e
Vitor): o supervisor emite o relatório quando a carreta sai lacrada; ~90% dos supervisores não têm
acesso ao SysHalal; o despachante emite 1–2 semanas depois.

**Custo no SIH: zero** — `sign()` e `approve()` não consultam certificado nenhum hoje. A trava vai
para o **SysHalal**: na emissão, casar por `container + data` contra o pool de relatórios **ainda não
vinculados** (container se repete meses depois, então só casa com relatório livre), e vincular.
Subproduto pedido pelo André: relatório de **gap** — embarques declarados no SIH sem certificado
emitido.

⚠️ Isto **inverte** o desenho da reunião de 30/jun, hoje registrado no §4.2 do mestre como
*"🚩 CONFLITA com §5.21 — NÃO CODAR"*. O conflito se dissolve: a reunião de 17/jul escolheu
justamente **manter o embarque como está**, que é o que o §5.21 já mandava.

Pendências antes de codar: (a) confirmar com **Industrializados**, que pediram o oposto;
(b) a Trilha E (SysHalal) segue travada pelo WIP solto desde 30/jun.

### 5.4 Bug de persistência já identificado

`halalCertData` / `halalCertSource` são enviados pelo front, mas **não estão no Zod nem no service**
⇒ o resultado da busca no SysHalal **se perde ao salvar**. O `HalalCertField` também só aparece em
transferência — **não aparece em exportação**, que é justamente onde o certificado importa.
Idem `destinationCnpj`, que vive só em `useState`.

---

## 6. Backlog priorizado (para o §4 do mestre)

> **Status de 21/jul.** P0 e P1 implementados — ver §9. Os demais seguem abertos.

**P0 — conformidade documental**
1. ✅ *(21/jul)* Fonte única das listas de verificação + alinhar aves ao FM (13 itens) — §1
2. ❓ Decidir o destino dos 2 relatórios de aves já assinados com a lista antiga — §1

**P1 — erro de dado observado ao vivo**
3. ✅ *(21/jul)* Tempo de retorno em `m:ss` — A1
4. ✅ *(21/jul)* Imprimir `observations` no PDF (6 templates) — A2
5. ✅ *(21/jul)* "Natureza dos volumes" / "Nº de volumes" + datalist — E1
6. ✅ *(21/jul)* Totalizador de volumes e peso, na tela e no PDF — E2
7. ✅ *(21/jul)* Documento sanitário obrigatório para assinar — E8 · ❓ a nota fiscal também bloqueia?
8. ✅ *(21/jul)* Persistir `halalCertData`/`halalCertSource` — §5.4
   🚩 **`HalalCertField` na exportação ficou de fora, de propósito.** Ele usa
   `halalSerialNumber` como número do certificado, mas esse campo é o **número de série do
   relatório** (§5.1) — são coisas diferentes na mesma coluna. Expor o componente na
   exportação criaria dois inputs gravando no mesmo lugar. Separar exige migration e depende
   da decisão da FAMBRAS sobre o número de série. `destinationCnpj` (só `useState`) também
   segue aberto, pela mesma razão: precisa de coluna.

**P2 — fidelidade ao FM**
9. ✅ *(21/jul)* Nº do documento do supervisor assinante — A3/E6
10. ✅ *(21/jul)* Nome do supervisor = quem assinou, não quem criou — A4
11. ✅ *(21/jul)* Autofill robusto do endereço de origem — §3.1
12. ✅ *(já existia)* Datas como faixa na UI — E3
13. 🧩 Horário também no bloco bovino — A6
14. ✅ *(21/jul)* Vincular NC ao FM 7.1.6.1 — A7
15. ✅ *(21/jul)* Validar `verificationItems` (completude antes de assinar) — A11
16. ✅ turno com rótulo *(21/jul)* · 🧩 `serialNumber` no PDF · 🧩 `formNumber` coerente com espécie — A8/A5/A9
17. 🧩 `rejectedSequence` impresso também em aves — A10

**P3 — depende de terceiros**
17. Produto preso ao escopo — **exige rota nova no GC** — E4
18. Número de série gerado — **depende de decisão FAMBRAS** — §5.1
19. Cancelamento/correção com sufixo `A` — §5.2
20. Ciclo embarque ⇄ SysHalal — **depende de Industrializados + WIP do SysHalal** — §5.3

---

## 7. Perguntas para a FAMBRAS

1. **Formato canônico** do número de série? O sistema passa a gerá-lo?
2. O `18/2022/0000200` da BRF Dourados tem **ano errado**, ou é o scan?
3. Anexo obrigatório bloqueia na **assinatura** (supervisor) ou na **aprovação** (controladoria)?
4. **FM 7.1.7.11** (específico BRF) — criar, ou seguir usando o 7.1.7.3? O Vitor disse que "não muda quase nada"
5. Auto-cálculo de "Aprovados" (`total − rejeitados`, read-only)? A regra já é igualdade estrita, e
   `Decimal(12,2)` cobre a meia carcaça de aves
6. "Nome do pedido" — o documento real não tem, só nota fiscal. Remover da tela?
7. Turno: enum atual (`matutino…`) ou numeração do FM (`1º TURNO`, `I`)?

---

## 8. O que ainda não foi verificado

- FM 7.1.7.4: campos **Vendedor**, **Cliente**, **Nº do documento sanitário** no cabeçalho — §4
- FM 7.1.7.1: as 2 perguntas C/NC da **checagem final do contêiner** — E5
- Cabeçalho do embarque campo a campo — §3.1
- FM 7.1.7.3 (transferência) **não foi lido em documento oficial preenchido** — o que sabemos vem da
  reunião. Vale pedir um ao Vitor.
- Pág. 2 do FM 7.1.7.4 não veio no PDF enviado (o arquivo tem as págs. 1, 3 e 4).

---

## 9. Implementado em 21/jul

| Commit | Repo | Conteúdo |
|---|---|---|
| `9c3ec7f` | sih-backend | `SLAUGHTER_FM` como fonte única + `/fm-metadata/slaughter/*` + PDF usando o rótulo gravado + **primeiro teste do repo** (10 casos) |
| `16afce7` | sih-frontend | Verificações vindas do backend; itens gravam `labelPt`/`labelEn` |
| `f77bb97` | sih-backend | Observações no PDF (6 templates) · linha TOTAL no embarque · anexo sanitário obrigatório para assinar · `halalCertData` persistido |
| `b57a5b0` | sih-frontend | Tempo de retorno `m:ss` · "Natureza dos volumes"/"Nº de volumes" + datalist · totalizador na tela |
| `50bd589` | sih-backend | **Bloco A:** nº de série Halal gerado · FM 7.1.7.11 (enum + migration) · turno com rótulo do FM · pedido/NF no PDF · +9 testes de serial |
| `d1feabc` | sih-frontend | **Bloco A:** "Aprovados" derivado · "Nº do Pedido" fora da tela · turno do FM (3 listas locais removidas) · FM 7.1.7.11 nos 4 pontos |
| `878678d` | sih-backend | Metadados do 7.1.7.11 corrigidos contra o documento oficial |
| `beba85e` | sih-frontend | Tabela de produtos do 7.1.7.11 enxuta, como no documento |
| `b071b75` | sih-backend | **Bloco B:** `products` validado (era `z.any()`) · assinar exige produto com nome · detalhe no PDF |
| `9fc4aac` | sih-frontend | **Bloco B:** endereço de origem sincroniza ao trocar planta · campo "Detalhe do produto" |
| `93a3ae5` | sih-backend | **Bloco C:** `SystemUser.document` + migration · quem assinou no cabeçalho · completude C/NC na assinatura |
| `c36ce0d` | sih-frontend | **Bloco C:** campo de documento no cadastro · aviso do FM 7.1.6.1 ao marcar NC |
| `46e7c42` | sih-backend | *(à parte)* versiona os 5 scripts de junho que estavam soltos |

**Status de deploy de cada bloco:** no **§4.2 do mestre** — não replicado aqui, para não divergir.

### Decisões do Renato aplicadas (21/jul)

| # | Decisão | Como ficou |
|---|---|---|
| 1 | Anexo obrigatório trava na **assinatura** | ✅ implementado. ❓ **a nota fiscal também bloqueia?** Hoje só o documento sanitário |
| 2 | **Auto-cálculo** de "Aprovados" | ✅ derivado, read-only. Das 5 validações restaram 2 |
| 3 | **Descartar** os 2 relatórios de aves | ✅ removidos de prod (zero dependências, em transação) |
| 4 | Remover "nome do pedido" | ✅ fora da tela; coluna preservada, PDF compõe pedido/NF |
| 5 | Turno como nos FM reais | ✅ "1º/2º/3º Turno". **Rótulo trocado, não o valor** — `Shift` também alimenta escala e analytics |
| 10 | Nº de série `SIF/ANO/6 dígitos` | ✅ gerado quando o supervisor não informa; sequência parte do **maior emitido**, não de `count()` |
| 11 | O `18/2022/...` da BRF tem ano errado | ✅ confirmado pelo Renato — erro de preenchimento da planta |
| 12 | Criar o FM 7.1.7.11 | ✅ + metadados **corrigidos** contra o documento oficial (ver §10) |

---

## 10. O FM 7.1.7.11 real — o que ele corrigiu

O documento oficial preenchido (localizado em 21/jul) **desmentiu três suposições** feitas ao criar
o tipo a partir do 7.1.7.3:

| | Inferido do 7.1.7.3 | **Documento real** |
|---|---|---|
| Data da revisão | 17/12/2021 | **06/07/2020** |
| Título | "Relatório de Transferência Halal" | **"…: EXCLUSIVO ENTRE BRF"** |
| Verificações C/NC | as do 7.1.7.3 | **próprias** (produção acompanhada por supervisor FAMBRAS + produtos identificados) |

**Outras diferenças:** tabela bem mais enxuta (`Produto | Data de abate | Quantidade por produto`,
mais `TOTAL` e `Peso total (kg)`) — sem SIF, lote ou embalagem; e **não existe campo de número de
série do relatório Halal**.

🚩 **A coluna do formulário induz erro.** Ela se chama *"Quantidade por produto (**kg**)"*, mas a
planta preenche **caixas** (479 / 201 / 770 → TOTAL 1450, com peso total de 37.800,000 kg à parte).
Foi por isso que o André disse na reunião: *"o documento foi preenchido incorretamente, mas seriam
caixas"*. **O rótulo do FM está errado, não o supervisor** — levar à FAMBRAS.

❓ **A sequência do nº de série deve contar este tipo?** O 7.1.7.11 não tem o campo, mas a geração
hoje roda para todo `shipping_report`.

**Nota de infraestrutura:** o jest estava configurado mas **sem nenhum teste**, porque faltava
o `moduleNameMapper` — os imports `.js` do padrão NodeNext não resolviam. Corrigido em
`9c3ec7f`; a suíte agora roda com `npm test`.

**Efeito colateral desejado:** o `signatureBlock` ganhou um parâmetro opcional de observações,
então **todos os 6 tipos de relatório** passaram a imprimir o campo — não só o abate.

---

## 11. Estado da implementação — onde consultar

> **Estado de sessão NÃO vive aqui.** O que está feito, o que falta, o que está commitado e ainda
> não foi deployado, e as pendências por dono ficam no **`BACKLOG-ECOHALAL.md` §4** — fonte única
> (regra §0.5 do próprio mestre). Esta spec guarda a **análise técnica**: o cruzamento campo a campo
> do FM em papel com o sistema, que não muda de sessão para sessão.
>
> Para saber onde paramos: **§4.2 do mestre, bloco "SIH · Conformidade FM"**.
> A §9 acima lista os commits desta spec, para rastreabilidade.
