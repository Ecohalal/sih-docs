# Dossiê de Exportação (In Natura) — Análise de Aptidão do SIH

> **Data:** 2026-06-22
> **Autor:** Renato / time SIH
> **Interlocutor-alvo:** especialista da **área de Frigoríficos / In Natura** da FAMBRAS (NÃO é pauta da Qualidade)
> **Base:** 2 processos completos enviados pela FAMBRAS (1 aves + 1 bovino), em `C:\SIH\IN Natura Processos`
> **Objetivo:** avaliar se o SIH está apto a montar processos integrados de exportação como os que a FAMBRAS arma hoje manualmente — e definir o backlog para chegar lá.

---

## 1. Definição: o que é o "Dossiê de Exportação"

A partir desta análise, passamos a chamar de **Dossiê de Exportação** o **conjunto integrado de documentos** que comprova, de ponta a ponta, que uma carga in natura exportada é Halal e está apta sanitariamente. Hoje a FAMBRAS monta esse maço **manualmente**, reunindo papéis de origens diferentes (supervisor de campo, MAPA, ERP do frigorífico, SysHalal).

O alvo do SIH é **montar e manter esse dossiê de forma estruturada**, com o **Relatório de Embarque (FM 7.1.7.1) como "cabeça"** do processo, agregando todos os demais elementos.

---

## 2. Anatomia de um Dossiê — o que os 2 processos revelam

### 2.1 Processo AVES — BRF / Frigorífico Nicolini (SIF 3169)

| # | Documento | Quem emite | Form | Onde nasce no SIH |
|---|---|---|---|---|
| 1 | Certificado de Abate Halal `2603ME3DD` (fatura `0020051E26`) | **SysHalal** | FM 7.7.3 Rev 06 | SysHalal (não SIH) |
| 2 | Relatório de Abate e Controle Halal – Aves (04/02, 2º turno, 132.347 aves) | Supervisor FAMBRAS | FM 7.1.4.1 | SIH — Relatório de Abate |
| 3 | Relatório de Transferência p/ Entreposto (Nicolini → Martini Meat, SIF 554, 16/04) | Supervisor FAMBRAS | FM 7.1.7.7 | SIH — Relatório de Transferência (flag entreposto) |
| 4 | Relatório de Acompanhamento de Embarque (contêiner BMOU9015739, 27/03) | Supervisor FAMBRAS | FM 7.1.7.1 | SIH — Relatório de Embarque |
| 5 | CSN nacional `N0-00209798/3169/26` | **MAPA / gov.br** | CSN | Anexo (S3) |
| 6 | CSI internacional `I0-00173944` + `I0-00173962` (bilíngue PT/EN) | **MAPA / gov.br** | CSI | Anexo (S3) |
| 7 | DANFE BRF `233.289` e `232.275` | **ERP do frigorífico** | NF-e | Anexo (S3) |

### 2.2 Processo BOVINO — JBS (abate SIF 4121 / SIF 42, Barra do Garças)

| # | Documento | Quem emite | Form | Onde nasce no SIH |
|---|---|---|---|---|
| 1 | Certificado de Abate Halal `2604C60FS` (fatura `64684130-1`) | **SysHalal** | FM 7.7.3 Rev 06 | SysHalal (não SIH) |
| 2 | Relatório de Abate e Controle da Carcaça – Bovino (01/04, 1.416 cabeças; **subprodutos tripa + couro**; câmaras 03/05/07/08/10/11/12) | Supervisor FAMBRAS | FM 7.1.4.2 | SIH — Relatório de Abate |
| 3 | Relatório de Acompanhamento de Embarque (contêiner BMOU9282720, 24/04) | Supervisor FAMBRAS | FM 7.1.7.1 | SIH — Relatório de Embarque |
| 4 | DANFE JBS `543226` (2.122 cartons file mignon) | **ERP do frigorífico** | NF-e | Anexo (S3) |
| 5 | CSI internacional `I0-00232891/42/26` (bilíngue) | **MAPA / gov.br** | CSI | Anexo (S3) |
| 6 | Arquivo `NF-420567` — fluxo de **matéria-prima** SIF 49 → SIF 337: FM 7.1.7.3 (transf. mesmo grupo) + **ANEXO V Rastreabilidade** + Carregamento por Rastreabilidade + **Carta de Garantia de MP** + 3 CSN | FAMBRAS + MAPA + ERP | FM 7.1.7.3 | SIH — Transferência + anexos |

---

## 3. Observação honesta sobre o material recebido

As pastas **não são, cada uma, um único embarque "limpo" de ponta a ponta** — são **coletâneas representativas de tipos de documento**, e em alguns pontos misturam movimentações distintas. Isso é perfeitamente útil para avaliar capacidade, mas precisa ser dito:

- **Aves:** o embarque do contêiner BMOU9015739 (27/03, cert `2603ME3DD`) é o processo principal. Já a **transferência para entreposto** (16/04, série `SIF3169/26/0090`, 2.250 cx) é uma **movimentação posterior e separada** — entrou como exemplo do *tipo* "transferência p/ entreposto", não como elo daquele embarque.
- **Bovino:** o arquivo `NF-420567` é de **outro fluxo** (matéria-prima de **industrializados**, carne industrial para cocção, SIF 49 Nova Andradina → SIF 337 Lins) — não pertence à exportação in natura. Entrou para exemplificar os documentos de **rastreabilidade** e **carta de garantia**.

➡️ **Pergunta para o especialista:** quando vocês falam em "processo completo", o alvo é **um embarque (1 contêiner / 1 certificado)** com todos os seus documentos amarrados? É essa a unidade que o SIH deve montar como Dossiê. (Nossa premissa é que **sim**.)

---

## 4. O fio que costura tudo

O dossiê tem uma **chave de amarração natural**: o **número do Certificado de Abate Halal** emitido pelo SysHalal. Evidência no próprio CSI bovino:

> *"s) A carne é acompanhada pelo Certificado Halal de Abate nº **2604C60FS**."*

Ou seja, o documento oficial do MAPA **já referencia** o certificado SysHalal. Esse número é o elo que liga **SIH (evidência de campo)** ↔ **documentos oficiais (CSN/CSI/NF)** ↔ **SysHalal (certificado)**. Outras chaves secundárias presentes em todos os documentos: **nº do contêiner**, **nº do lacre**, **invoice/pedido**, **série do relatório Halal**.

---

## 5. Cobertura do SIH hoje — temos os tijolos

| Bloco do processo | SIH tem? | Observação |
|---|---|---|
| Abate aves (FM 7.1.4.1) | ✅ | módulo Relatório de Abate |
| Abate bovino — carcaça, subprodutos, câmaras (FM 7.1.4.2) | ✅ | validar campos de subprodutos (tripa/couro) e câmaras de resfriamento |
| Produção / desossa / tripas / couro / mucosa (FM 7.1.3.x, 7.1.4.x) | ✅ | módulo Relatório de Produção |
| Embarque exportação (FM 7.1.7.1) — contêiner, lacre, CSI nº, invoice | ✅ | campos-chave já existem |
| Transferência mesmo grupo (FM 7.1.7.3) | ✅ | módulo Relatório de Transferência |
| **Transferência p/ entreposto** | ✅ **flag já entregue (demo 15/jun)** | `destinationType = entreposto` no relatório de transferência — exatamente o que a FAMBRAS pediu em reunião |
| Não Conformidade (FM 7.1.6.1) e Ocorrência diária aves (FM 20.1) | ✅ | módulos NC e Ocorrência |
| Vínculo Embarque ⇄ Produção (M:N, snapshot) | ✅ | entregue nas Fases 0–4 |
| Anexar CSN / CSI / NF-e | ✅ infra | bucket S3 de anexos já em produção |
| Certificado final FM 7.7.3 | ➡️ **SysHalal** | por arquitetura, o certificado permanece no SysHalal; SIH integra |

**Conclusão da cobertura:** o SIH **já possui todos os formulários-base** e a integração com o SysHalal. **Não faltam formulários novos.** O que falta é a **camada de "dossiê"** que amarra tudo num único processo navegável.

---

## 6. Os 3 gaps para o SIH ficar "apto"

### 🔴 Gap 1 — Agregação multi-origem (prioridade máxima)
Um embarque **consolida muitos dias de produção e, às vezes, vários SIFs**:
- **Bovino:** o certificado declara abate de **03/03 a 21/04** e o embarque lista 3 produtos com lotes de **05/03 a 21/04**; o Relatório de Abate de 01/04 é apenas **um** dos dias. Abate em **2 SIFs** (4121 Água Boa + 42 Barra do Garças).
- **Aves:** o embarque lista 4 linhas de produto com lotes de **23 a 26/03**.

➡️ Um embarque **≠** um abate. É **N relatórios de abate/produção, com faixas de data e possivelmente N plantas**. O vínculo Embarque⇄Produção já existe, mas precisa fechar o caso **N origens com intervalos de data**. (Já mapeado em `EMBARQUE-EXPORTACAO-VINCULO-RELATORIOS`.)

### 🟠 Gap 2 — O "salto" pelo entreposto
Cadeia do aves: **abate (SIF 3169) → transferência p/ entreposto (Martini Meat, SIF 554) → embarque a partir do entreposto**. A planta de **origem do embarque ≠ planta de abate**. O flag de entreposto já existe; falta **encadear** a transferência ao embarque dentro do dossiê (rastrear a carga de uma planta para a outra até o contêiner).

### 🟡 Gap 3 — Documentos externos estruturados
CSN, CSI e NF-e **não são gerados pelo SIH** (vêm do MAPA e do ERP do frigorífico). O anexo em S3 já existe; o que falta é **capturar os números-chave de forma estruturada** (nº CSI, nº NF, lacre, contêiner) — não só guardar o PDF — para o dossiê ficar **pesquisável e cruzável** (e permitir conferência automática contra o que o supervisor lançou). Bom sinal: o Relatório de Embarque já tem esses campos.

---

## 7. Modelo proposto (para discussão)

**Entidade "Dossiê de Exportação"**, tendo o **Relatório de Embarque (FM 7.1.7.1) como cabeça**, agregando:

```
DOSSIÊ DE EXPORTAÇÃO  (chave: nº do certificado SysHalal + contêiner)
├── Relatório(s) de Abate          (1..N — multi-data, multi-SIF)   [SIH]
├── Relatório(s) de Produção/Desossa (1..N)                          [SIH]
├── Transferência(s)               (entreposto / mesmo grupo)        [SIH]
├── Relatório de Embarque          (cabeça — contêiner/lacre/CSI/invoice) [SIH]
├── Anexos oficiais                (CSN, CSI, NF-e — nº estruturado) [MAPA/ERP → S3]
└── Certificado de Abate Halal     (ponteiro p/ nº SysHalal)         [SysHalal]
```

---

## 7-bis. Estratégia de implementação faseada (recomendada)

**Premissa de negócio:** a FAMBRAS **já usa o Relatório de Embarque (FM 7.1.7.1) como agregador de fato** do processo. Logo, a evolução natural é **empoderar primeiro o Relatório de Embarque** com o que já vemos nos exemplos, e só depois formalizar o **Dossiê** como entidade própria.

**Por que é seguro fasear assim (sem retrabalho):** como o **embarque é a "cabeça" do dossiê**, tudo que for adicionado ao Relatório de Embarque na Fase 1 é **reaproveitado** na Fase 2. A entidade Dossiê, quando vier, **lê** o embarque enriquecido — não o substitui.

### Fase 1 — Empoderar o Relatório de Embarque ("mini-dossiê")
Escopo incremental, baixo risco, sobre o que já existe:
- **Documentos oficiais estruturados (Gap 3):** capturar nº CSN, nº CSI, nº NF-e, lacre e contêiner como **campos** no embarque (não só PDF) — o embarque já tem parte desses campos.
- **Anexos no embarque:** parkear CSN/CSI/NF-e em S3 **diretamente no embarque** (infra de anexos já existe).
- **Painel de agregação (read-only):** exibir no embarque os **relatórios de abate/produção já vinculados** (vínculo Embarque⇄Produção das Fases 0–4) + **ponteiro para o nº do certificado SysHalal**.
- Resultado: o Embarque vira um **mini-dossiê navegável** sem nova entidade.

### Fase 2 — Dossiê de Exportação como entidade (evolução)
Ataca o que é estrutural, após confirmação das regras com o especialista:
- **Agregação multi-origem (Gap 1):** N abates/produções com faixas de data e multi-SIF, com **reconciliação** (conferência de pesos/lotes, alertas de inconsistência).
- **Salto pelo entreposto (Gap 2):** encadeamento rastreado transferência→embarque a partir do entreposto.
- **Dossiê como processo de 1ª classe:** status, completude, navegação, e a chave de amarração (nº certificado SysHalal + contêiner).

> **Mapa gap × fase:** Gap 3 → Fase 1 (inteiro). Gap 1 → parcial na Fase 1 (exibir vínculos), completo na Fase 2 (reconciliação). Gap 2 → Fase 2.

---

## 8. Perguntas para o especialista de Frigoríficos

1. **Unidade do dossiê:** confirma que o alvo é **1 embarque = 1 contêiner = 1 certificado de abate**? (com seus N abates/produções por trás)
2. **Multi-SIF:** com que frequência um mesmo embarque junta carne de **mais de um SIF de abate** (como o bovino: 4121 + 42)? É regra ou exceção?
3. **Entreposto:** qual a frequência de embarques que passam por **entreposto/armazém geral** antes do porto (como o aves via Martini Meat)? Há alguma regra documental específica do entreposto que o supervisor precisa registrar?
4. **Faixa de datas:** o certificado bovino cobre abate de **03/03 a 21/04** (≈7 semanas). Como vocês hoje relacionam o embarque a todos esses dias de produção? (planilha? manual? sistema do frigorífico?)
5. **Documentos externos:** quais documentos a FAMBRAS **recebe pronto** (CSN, CSI, NF) e quais ela **produz** (relatórios FM)? Confirmação da fronteira.
6. **Industrializados vs in natura:** o fluxo do `NF-420567` (carne industrial + rastreabilidade + carta de garantia) entra no escopo deste dossiê de **exportação in natura**, ou é tema separado?

---

## 9. Próximos passos

**Abordagem adotada:** faseada — **Fase 1 empodera o Relatório de Embarque** como agregador; **Fase 2 formaliza o Dossiê** como entidade (ver seção 7-bis).

**Fase 1 (pode começar sem depender do especialista):**
1. Definir os **campos estruturados** dos documentos externos (CSN/CSI/NF/lacre/contêiner) a capturar no embarque.
2. Habilitar **anexos S3 no embarque** (CSN/CSI/NF).
3. **Painel de agregação read-only** no embarque: relatórios vinculados + nº do certificado SysHalal.

**Fase 2 (depende das respostas da seção 8):**
4. Validar este documento com o **especialista de Frigoríficos** (responder seção 8).
5. Detalhar o **Gap 1 (multi-origem)** como spec — agregação multi-data/multi-SIF com reconciliação.
6. Especificar o **encadeamento transferência→embarque** para o caso entreposto (Gap 2).

**Transversal:**
7. Confirmar campos de **subprodutos e câmaras** no Relatório de Abate bovino (FM 7.1.4.2).
