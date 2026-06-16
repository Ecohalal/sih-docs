# Spec — Ocorrências / NC: FM 7.1.6.1 + FM 20.1 (Aves) — 2026-06-16

> Origem: arquivos enviados pela **Elaine (Qualidade FAMBRAS)** em `C:\SIH\Qualidade`
> atendendo à pendência #4 da [ATA-DEMO-SIH-IN-NATURA-2026-06-15](ATA-DEMO-SIH-IN-NATURA-2026-06-15.md).
> Confirma a distinção feita na reunião: **Não Conformidade / Ocorrência são formulários
> próprios e diferentes dos relatórios operacionais** (abate/desossa/embarque).

---

## ⭐ RESPOSTAS DA ELAINE (WhatsApp 16/jun) — DECISÕES QUE REGEM A IMPLEMENTAÇÃO

> Estas respostas **invertem o rótulo** que a 1ª versão desta spec usou (tratava FM 7.1.6.1
> como "ocorrência"). Vale o que está aqui.

1. **FM 7.1.6.1 = NÃO CONFORMIDADE (NC).** Existe **só esse** para NC; é "quando tem problema",
   para couro **ou** problemas do frigorífico. → mapeia no **`NonConformity` que já existe**.
2. **Ocorrência = "um mapa do que aconteceu no dia" = registro diário** → é o **FM 20.1 (aves)**
   (e o conceito de registro diário). Modelo **novo**.
3. **Categorias:** **NC = temas AMPLOS/abertos** (ex.: problema no refeitório, não fez o comitê
   Halal) — **não** é dropdown fixo. **Ocorrência = sempre os mesmos tópicos** = as **seções
   fixas do formulário** (FM 20.1), não categorias livres.
4. **Workflow da NC (FM 7.1.6.1): "a empresa recebe e responde com o plano de ação"** — 2 atores.
   **Decisão do PO (opção a, 16/jun):** empresa **não** tem login no SIH; FAMBRAS envia a NC,
   recebe a resposta por fora, e a **controladoria/supervisor lança a resposta** (causa §4 +
   ação corretiva §5) no sistema. Status: `aberta` → **`em_tratamento` (= aguardando/recebendo
   resposta da empresa)** → `resolvida`/`verificada`/`encerrada`. Sem novo ator "empresa" no piloto.

**Impacto no schema desta spec:**
- §A (FM 7.1.6.1) → **estender `NonConformity`** segue válido; `category` fica **string livre/ampla**
  (NÃO virar enum fixo das categorias extraídas). Os campos §4/§5 são preenchidos no estágio de
  resposta da empresa (lançados pela controladoria/supervisor).
- §B (FM 20.1) → modelo novo permanece; os "tópicos" são as **seções do form** (não categorias).
- A lista de "categorias candidatas" abaixo vira **referência de tópicos da ocorrência (FM 20.1)**,
  não dropdown de NC.

## Arquivos recebidos

| Arquivo | Formulário | Caso |
|---|---|---|
| `2025 FM 7.1.6.1 CHECK LIST DIÁRIO DE REGISTRO DE OCORRÊNCIAS_PRIMA 177 - couro...docx` | FM 7.1.6.1 Rev 05 (20/09/2021) | Prima Foods / SIF 177 — couro Halal e não Halal misturado |
| `Registro de Ocorrência e Evidencias_250530_132326.pdf` | FM 7.1.6.1 Rev 05 | Minerva / SIF 421 — mesmo caso (com anexos: lista de presença de treinamento + evidências) |
| `FM 20.1 - OCORRÊNCIA AVES (REV 5) PT -12-06-2026.docx` | FM 20.1 Rev 5 | BRF Lajeado/RS — SIF 1449 |
| `FM 20.1 - OCORRÊNCIA AVES (REV 5) PTx.docx` | FM 20.1 Rev 5 | JBS Nova Veneza/SC — SIF 1155 (abate mecânico) |
| `OCORRÊNCIA AVES- 10-06-2026 -.docx` | FM 20.1 Rev 5 | BRF Serafina Corrêa/RS — SIF 103 |

---

## A) FM 7.1.6.1 — Registro de Ocorrências (Externas) / NC

Formulário bilíngue PT/EN. Cabeçalho fixo: *"ENVIAR ESTE CHECK LIST SEMPRE QUE PREENCHIDO À FAMBRAS HALAL"*.
Estrutura em **8 seções**, com responsável de preenchimento explícito por seção (supervisor × empresa):

| # | Seção | Responsável | Tipo |
|---|---|---|---|
| 1 | Identificação da empresa | — | nome+localização, **SIF**, **nº da ocorrência** (sequencial p/ empresa), **data**, **turno** |
| 2 | Descrição da ocorrência | Supervisor | texto longo |
| 3 | Correção da ocorrência – ação imediata | Supervisor | texto longo |
| 4 | Razão da ocorrência (causa) | **Empresa** | texto longo |
| 5 | Ação corretiva p/ evitar reincidência | **Empresa** | texto longo |
| 6 | Conclusão – a ação corretiva evitará a reincidência? | Supervisor | texto longo |
| 7 | Verificação da eficácia | Supervisor | **enum**: Satisfatória / Insatisfatória |
| 8 | Comentários | Supervisor | texto longo |
| — | Anexos / evidências | — | fotos, lista de presença de treinamento, documentos de lote |

**Observações de modelagem:**
- Workflow de 2 atores (supervisor ↔ empresa) — diferente do fluxo supervisor→controladoria dos relatórios. Avaliar se "empresa" preenche pelo SIH ou se é texto consolidado pelo supervisor.
- `nº da ocorrência` é sequencial **por empresa/SIF** (ex.: "02").
- Eficácia é o único campo enum; o resto é texto livre + anexos.
- Caso de uso aqui é **couro Halal/não Halal misturado** — relevante p/ o relatório de couro/raspa e p/ as travas de documento prévio (item 7 da ata).

---

## B) FM 20.1 — Ocorrência Aves (diário)

Formulário **específico de abate de frango** (não é o relatório de abate bovino).
Muito mais estruturado que o FM 7.1.6.1. Cabeçalho define **roteamento de e-mail por unidade**:
- Seara/JBS → `qualidade@fambrashalal.com.br` + `mohamed.elsharif@fambrashalal.com.br`
- BRF e Outras → `qualidade@fambrashalal.com.br` + `adel@fambrashalal.com.br`

### Identificação
- Empresa (nome e cidade), **SIF**, **Data**, **Nome do supervisor**

### Seções de avaliação

**1. Abate mecânico** — `Sim/Não` + descrição. Se sim, tabela **Testes de eficiência do disco** (mín. 2 testes por linha por turno):
- colunas: Turno · Horário · Linha · Velocidade (aves/hora) · **Mal sangrado** · **Não sangrado**

**2. Insensibilização** — `Sim/Não` + descrição. Se sim, tabela **Parâmetros** (mín. 2 monitoramentos por linha por turno), por (Linha × Turno) com 1º e 2º monitoramento:
- **Voltagem · Amperagem · Frequência · Tempo de cuba · Tempo de retorno**

**3. Paradas de linha**
- Quantas paradas (número)
- Parada por processo Halal? `S/N`
- Morte de ave na cuba por duração da parada? `S/N`
- Possui mecanismo de abaixar a cuba (ou abaixam manualmente)? `S/N`
- Se animal morreu, foram removidos? `S/N`
- Descrição (quantos morreram, responsável pela retirada)

**4. Aves vivas / mal sangradas**
- Passou ave viva pelo tanque de escaldagem? `S/N` + quantidade
- Retiradas aves mal sangradas antes do tanque? `S/N` + quantidade
- Descrição + motivo + auto de infração? + identificadas pelo SIF?
- OBS regra: sempre que passar ave viva → treinar sangradores + enviar lista de presença

**5. Pendura e lote desuniforme**
- Mais de uma ave no mesmo gancho? `S/N`
- Ave pendurada por uma perna / outra parte? `S/N`
- Lote desuniforme? `S/N`
- Descrição

**6. Falhas tecnológicas** — qtd total de ocorrências + descrição sucinta

**7. Funcionários**
- Falta de sangradores? `S/N` + quantidade
- Hora-extra? `S/N`
- Acidente de trabalho? `S/N`
- Atraso/saída antes da troca de turno? `S/N`
- Respeitam BPF/normas/EPIs? `S/N`
- Inclusão de funcionários novos? `S/N` + data(s) + quantidade
- Descrição

**8. Mercado** — Sabe o país de destino da produção de hoje? `S/N` + quais países

**9. Outros** — campo livre (relatos estruturais, conversas, etc.)

**10. Correção / Ação corretiva** — ação adotada pelo supervisor

**Observações de modelagem:**
- É um **registro diário** (1 por dia/unidade), não por evento — difere do FM 7.1.6.1.
- Forte uso de pares `S/N` com **quantidade condicional** e **descrição condicional** → reaproveitar o padrão de "abrir campo quando habilitado" já usado no abate (insensibilização).
- Tabelas dinâmicas: testes de disco e parâmetros de insensibilização são **N linhas × N turnos** com 2 monitoramentos cada (EditableTable).
- Campos numéricos com decimal (tempo de cuba 7.8, amperagem 1,51) — reaproveitar lição decimal do abate.
- Roteamento de e-mail por grupo (Seara/JBS × BRF/Outras) é metadado de **notificação**, não de dados.
- Termos halal seguros confirmados (couro Halal/não Halal, abate islâmico, sangria) — sem termos haram.

---

## Reconciliação com a ata (15/jun) e pendências

- **Pendência #4 (modelos de NC e Registro de Ocorrência):** ATENDIDA para os modelos de
  **ocorrência** (FM 7.1.6.1 externa/couro + FM 20.1 aves). **Gap:** confirmar se existe um
  formulário de **Não Conformidade** distinto destes dois, ou se "NC" = FM 7.1.6.1. Elaine
  afirmou na reunião que NC e ocorrência são formulários diferentes → **pedir o modelo de NC
  separadamente** se não for o FM 7.1.6.1.
- **Pendência #3 (categorias de NC):** ainda **não** vieram como lista — extrair candidatos
  destes formulários (ex.: couro misturado, ave viva no escaldão, lote desuniforme, falta de
  sangrador, falha tecnológica) e validar com a Elaine.
- A tela de NC mostrada na demo (planta, severidade, categoria, prazo, vínculo abate/produção/
  embarque, descrição, evidências, ação corretiva/preventiva) cobre bem o **FM 7.1.6.1**;
  o **FM 20.1 (aves)** é um formulário próprio e estruturado → provavelmente um **tipo de
  relatório dedicado** (não cabe no form genérico de NC).

## Próximos passos sugeridos
1. Confirmar com Elaine: FM 7.1.6.1 = "Não Conformidade" ou existe form de NC separado?
2. Confirmar lista oficial de **categorias de ocorrência/NC**.
3. Modelar FM 20.1 (Aves) como tipo de relatório/ocorrência próprio (espécie = aves).
4. Modelar FM 7.1.6.1 como NC com workflow supervisor↔empresa + enum eficácia + anexos.
5. Definir roteamento de notificação por grupo (Seara/JBS × BRF/Outras).

---

## Proposta de schema (alinhada ao código atual)

> Achado relevante (varredura `sih-backend` 16/jun): o modelo **`NonConformity` JÁ EXISTE**
> e operacional, com plant/user, severity (enum critica|maior|menor|observacao),
> category (String), evidence (JSON), correctiveAction, preventiveAction, deadline,
> status (aberta|em_tratamento|resolvida|verificada|encerrada), vínculo triplo
> (slaughterReportId|productionReportId|shippingReportId) e endpoints resolve/verify/close.
> → **FM 7.1.6.1 é majoritariamente EXTENSÃO do que já existe.** O trabalho novo real é o **FM 20.1 (Aves)**.

### A) FM 7.1.6.1 → estender `NonConformity` (migration aditiva)

Campos a acrescentar (mapeando as 8 seções):

```prisma
model NonConformity {
  // ...campos existentes (description=§2, correctiveAction=§5, evidence, severity, category, deadline, status)...
  occurrenceNumber     Int?                  // §1 nº sequencial por planta/SIF (ex.: "02")
  shift                Shift?                // §1 turno
  immediateAction      String?               // §3 correção imediata (supervisor)
  cause                String?               // §4 razão/causa (preenchido pela EMPRESA)
  conclusion           String?               // §6 conclusão (supervisor)
  effectivenessResult  EffectivenessResult?  // §7 enum
  comments             String?               // §8 comentários (supervisor)
  isExternal           Boolean  @default(false) // "ocorrência externa" (ex.: couro em curtume terceiro)
}

enum EffectivenessResult {
  satisfatoria
  insatisfatoria
}
```

Notas:
- **Workflow supervisor↔empresa**: §4 e §5 são "preenchido pela empresa"; demais pelo supervisor.
  No SIH não há ator "empresa" hoje — modelar como campos editáveis num estágio do fluxo
  (ex.: NC fica "em_tratamento" aguardando causa+ação da empresa) ou simplesmente campos de texto
  preenchidos pelo supervisor consolidando a resposta da empresa. **Decisão de PO.**
- **Anexos**: hoje `evidence` é JSON; avaliar reusar `ReportAttachment` (S3) p/ fotos + lista de
  presença de treinamento (ver [[reference_sih_s3_attachments_infra]]).
- **Audit trail**: acrescentar `version: Int` + RevisionLog (requisito ISO 17065).
- **Categorias**: hoje `category` é String livre — virar enum/tabela ref quando a lista oficial chegar.

### B) FM 20.1 (Aves) → novo modelo `BirdOccurrenceReport` + 2 tabelas filhas

Segue os padrões dos relatórios (serialNumber, plant/user, status, signed/hash, assigned, statusHistory, version).
Espécie fixa = `ave`. Forte uso de pares `Boolean + contagem condicional + descrição condicional`.

```prisma
model BirdOccurrenceReport {
  id            String  @id @default(uuid())
  serialNumber  String  @unique          // padrão EM/OC + CIF + ano + sequencial
  formNumber    String  @default("FM 20.1")
  plantId       String
  userId        String
  date          DateTime
  supervisorName String?                 // §Identificação (ou derivar de filledBy)

  // Abate mecânico
  mechanicalSlaughter       Boolean
  mechanicalSlaughterNotes  String?
  discTests   BirdDiscTest[]             // tabela filha (mín. 2 por linha/turno)

  // Insensibilização
  stunning        Boolean
  stunningNotes   String?
  stunningParams  BirdStunningParam[]    // tabela filha (1º/2º monitoramento por linha/turno)

  // Paradas de linha
  lineStops               Int?
  lineStopHalalRelated    Boolean?
  lineStopCausedDeath     Boolean?
  hasCageLoweringMechanism Boolean?
  deadAnimalsRemoved      Boolean?
  lineStopNotes           String?

  // Aves vivas / mal sangradas
  liveBirdScalding        Boolean?
  liveBirdScaldingCount   Int?
  poorlyBledRemoved       Boolean?
  poorlyBledRemovedCount  Int?
  liveBirdNotes           String?
  infractionNotice        Boolean?
  sifIdentified           Boolean?

  // Pendura e lote desuniforme
  multipleBirdsPerHook    Boolean?
  birdHungByOneLeg        Boolean?
  nonUniformBatch         Boolean?
  hangingNotes            String?

  // Falhas tecnológicas
  technologicalFailuresCount  Int?
  technologicalFailuresNotes  String?

  // Funcionários
  bleedersAbsent       Boolean?
  bleedersAbsentCount  Int?
  overtimeNeeded       Boolean?
  workAccident         Boolean?
  bleedersLateOrEarly  Boolean?
  bpfCompliance        Boolean?
  newEmployees         Boolean?
  newEmployeesNotes    String?           // datas + qtd
  staffNotes           String?

  // Mercado
  destinationKnown     Boolean?
  destinationCountries String?

  // Outros + ação
  otherNotes        String?
  correctiveAction  String?

  // Workflow padrão (igual demais relatórios)
  status         ReportStatus @default(rascunho)
  statusHistory  Json?
  filledById     String?
  signedById     String?
  signedAt       DateTime?
  signatureHash  String?
  assignedToId   String?
  assignedAt     DateTime?
  version        Int @default(1)         // ISO 17065
  attachments    ReportAttachment[]      // fotos de evidência
  createdAt      DateTime @default(now())
  updatedAt      DateTime @updatedAt
}

model BirdDiscTest {
  id        String @id @default(uuid())
  reportId  String
  shift     Shift?
  time      String?      // horário (ex.: "21:00")
  line      String?      // linha
  speedPerHour Int?      // velocidade aves/hora
  poorlyBled   Int?      // mal sangrado
  notBled      Int?      // não sangrado
}

model BirdStunningParam {
  id          String @id @default(uuid())
  reportId    String
  line        String?
  shift       Shift?
  monitoring  Int      // 1 ou 2 (1º/2º monitoramento)
  voltage     Decimal? @db.Decimal(10,2)
  amperage    Decimal? @db.Decimal(10,2)
  frequency   Decimal? @db.Decimal(10,2)
  cubeTime    Decimal? @db.Decimal(10,2)   // tempo de cuba (ex.: 7.8)
  returnTime  Decimal? @db.Decimal(10,2)   // tempo de retorno
}
```

Notas:
- **Roteamento de e-mail por grupo** (Seara/JBS × BRF/Outras) é metadado de **notificação**, não de
  dados do relatório — modelar em config de notificação por grupo/planta, não no report.
- **Decisão de PO**: FM 20.1 é (a) novo tipo "Ocorrência Aves" dedicado [recomendado — estrutura muito
  diferente do abate bovino], ou (b) variante-aves do relatório de abate? Recomendo (a).
- Decimais (tempo de cuba, amperagem) — reusar lição decimal do abate ([[project_m4_producao_schema_gap]]).
- Reusar utilitários `report-workflow.util.ts` (assign/release/approve/reject) e `generateSerialNumber()`.

### Categorias candidatas (extraídas dos modelos — validar com Elaine)
couro Halal/não Halal misturado · ave viva no tanque de escaldagem · ave mal sangrada ·
lote desuniforme · pendura incorreta · parada de linha (Halal) · falha tecnológica ·
falta de sangrador · insensibilização fora de parâmetro · contaminação cruzada Halal/não Halal.

### Checklist pré-deploy (ver [[feedback_checklist_predeploy_sih]])
- Migration aditiva idempotente (NonConformity novos campos + 3 modelos novos + 1 enum).
- Enum `EffectivenessResult` e novos valores via `ADD VALUE IF NOT EXISTS` se aplicável.
- Regenerar API Gateway (swagger+proxy+) após novos endpoints.
- DTOs em Zod v4 (Base+Refined separados — [[feedback_zod_v4_partial_refine]]).
