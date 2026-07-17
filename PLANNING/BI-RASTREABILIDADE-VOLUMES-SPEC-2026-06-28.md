# BI de Rastreabilidade & Volumes (abate → produção → embarque) — SPEC

> **Data:** 2026-06-28
> **Origem:** discussão pós-Item A (A1 abate→produção, A2 fontes no embarque). O PO decidiu **manter o vínculo flexível (sem trava de saldo)** e evidenciar volumes por **BI/auditoria**, não por enforcement.
> **Status:** desenho para avaliação — nada implementado.

---

## 1. Objetivo

Painel de **evidência quantitativa** da cadeia **abate → produção → embarque**, usando os vínculos que o A1 (`ProductionRawMaterial.slaughterReportId`) e o A2 (`ShippingReportSource`) acabaram de criar. **Não** é controle/trava — é leitura para a Controladoria/auditoria enxergar volumes, reuso e anomalias.

---

## 2. Premissas de domínio (o que torna isto NÃO-trivial)

### 2.1 Unidades diferentes entre as pernas
- **Relatório de abate** mede **animais (cabeças)** — `totalAnimals` / `approvedAnimals`.
- **Produção/fabricação** consome **kg de matéria-prima** — `quantityKg`.
- Não há conversão direta: animal → kg exige **fator de rendimento** variável (peso médio de carcaça × rendimento de desossa). Portanto a perna **abate→produção só admite ESTIMATIVA**, nunca fechamento.

### 2.2 Produção ≥ Comercialização halal (regra-chave)
- O **selo halal** é **obrigatório para vender** ao mercado halal, mas **não obriga** a vender toda a produção como halal.
- Logo **produção halal ≥ embarque halal**: é **comum e normal** produzir mais do que se embarca (excedente vai a mercado não-halal/interno).
- E **embarcado ≤ produzido** sempre (não se vende o que não se produziu).
- **Consequência para o BI:** a perna produção→embarque é um **check de UM LADO SÓ** — não fecha em zero. **Sobra (produzido − embarcado ≥ 0) é esperada.** A **anomalia** é só **saldo negativo** (embarcado > produzido).

### 2.3 Cardinalidades
- 1 abate → N matérias-primas → N produções (reuso permitido; sem trava — decisão PO).
- 1 produção → N embarques (parcial ao longo do tempo) + parcela não-halal.
- Logo a reconciliação rigorosa é **cumulativa por produção**, não por embarque isolado.

---

## 3. As duas pernas

| Perna | Unidades | O que dá pra fazer | Natureza |
|---|---|---|---|
| **Abate → Produção** | animais → kg | contagem de reuso + **kg estimado** (banda de sanidade via fator de rendimento) | **Estimativa** |
| **Produção → Embarque** | kg → kg | **embarcado vs produzido** (cumulativo) | **Rigoroso, um lado só (embarcado ≤ produzido)** |

---

## 4. Modelo de dados disponível (já existe pós A1/A2)

- `SlaughterReport`: `approvedAnimals`, `species`, `plant.sanitaryCode` (SIF), `date`.
- `ProductionRawMaterial`: `slaughterReportId` (A1), `sanitaryCode`, `slaughterDate*`, `quantityKg`.
- `ProductionReport`: `netWeightKg`, `productName`, `plant`, datas.
- `ShippingReportSource` (A2): vínculo `{sourceType, sourceReportId}` do embarque.
- `ShippingReport`: peso líquido/bruto (nos `products` / snapshot), contêiner, destino.

➡️ Os relacionamentos da cadeia inteira **já estão no banco** — o BI é uma camada de **agregação/leitura**, sem novo schema (a princípio).

---

## 5. Métricas / visões propostas

### 5.1 Perna Abate → Produção (contagem + estimativa)
- **Reuso por abate:** nº de produções/MPs que consomem cada abate (flag visual quando reuso alto → revisão humana).
- **kg reivindicado por abate:** soma de `quantityKg` das MPs vinculadas àquele abate.
- **Banda estimada de kg (opcional, configurável):** `approvedAnimals × pesoMédioCarcaça × rendimentoDesossa` → faixa de referência. Mostrar kg reivindicado **dentro/fora** da banda — só como **sinal**, nunca trava. Parâmetros (peso médio, rendimento) configuráveis por espécie.

### 5.2 Perna Produção → Embarque (kg vs kg, um lado só)
- **Por produção (cumulativo):** `kg_produzido` vs **Σ kg_embarcado** de todos os embarques que a vinculam.
  - **Saldo = produzido − embarcado_acumulado.**
  - **Esperado:** saldo ≥ 0 (excedente halal não-exportado é normal).
  - **🔴 Anomalia:** saldo **< 0** (embarcou mais do que produziu) → destaque/alerta.
  - **% exportado halal:** embarcado/produzido (indicador de quanto da produção halal virou exportação).
- **Por embarque (sanity rápido):** peso líquido do embarque vs Σ `netWeightKg` das produções vinculadas (visão pontual; a rigorosa é a cumulativa por produção).

### 5.3 Visão de cadeia (drill-down)
- Embarque → fontes (abate/produção) → (produção) suas MPs → abates de origem. Navegável (reusa os links do Item C).

---

## 6. Regras de alerta (evidência, não bloqueio)

| Situação | Tratamento |
|---|---|
| Produzido > embarcado (sobra) | ✅ **Normal** — não alertar |
| Embarcado > produzido (saldo negativo) | 🔴 **Alerta** (impossível fisicamente → erro de vínculo/lançamento) |
| Reuso alto de um mesmo abate | 🟡 **Sinal** p/ revisão (não bloqueia) |
| kg reivindicado fora da banda estimada do abate | 🟡 **Sinal** (estimativa, depende de parâmetros) |

---

## 7. Onde mora
Encaixa na **Controladoria** (o controlador já revisa relatórios) como aba/dashboard de volumes, ou um dashboard dedicado. Read-only.

---

## 8. Fora de escopo
- **Enforcement / trava de saldo** (decisão PO: manter flexível).
- **Balanço de massa rigoroso animal→kg** (inviável sem rendimento medido; aqui é só banda estimada).
- Controle de estoque/decremento.

---

## 9. Perguntas abertas (p/ avaliação)
1. Os **parâmetros de rendimento** (peso médio carcaça, % desossa) por espécie — quem define e mantém? (config no sistema vs tabela FAMBRAS)
2. O "produzido" de referência é o `netWeightKg` da produção, ou um campo específico de saída? Confirmar a granularidade.
3. Granularidade do painel: por **empresa/SIF**, por **período**, por **produto**? (provável os três como filtros)
4. Inclui a parcela **não-halal** (produção total) ou só o universo halal certificado? (afeta o indicador "% exportado")
