# SPEC — Cadastro de planta: do GC para o SIH

> **Status:** proposta, aguardando decisão do Renato. Nada implementado.
> **Origem:** chamado do Vitor em 03/ago (BRF Capinzal SIF 466). Detalhe do episódio no §4.2 do `BACKLOG-ECOHALAL.md`.
> **Horizonte:** go-live FAMBRAS agosto/2026 — ver §7 (custo × congelamento de escopo).

---

## 1. O problema, em uma frase

O GC é o cadastro-mestre e **já tinha** a planta que o Vitor pediu — CNPJ, endereço, grupo, certificações — mas **não existe nenhum caminho** para esse dado chegar ao SIH. As 127 plantas do SIH foram digitadas à mão, uma a uma.

O que existe hoje de integração GC→SIH são duas rotas de **leitura sob demanda**, e ambas partem de uma planta **que já existe no SIH**:

| Rota (no GC) | Consumida por | Chave |
|---|---|---|
| `GET /integration/raw-materials/by-plant` | `gc-integration.service.rawMaterialsByPlant` | `sif` + `cnpj` |
| `GET /integration/plant-summary` | `gc-integration.service.plantSummary` | `sif` + `cnpj` (com fallback CNPJ-only) |

Autenticação: header `x-api-key` (`GC_INTEGRATION_API_KEY`). Erros já mapeados: 404 = sem cadastro no GC; demais = GC indisponível.

⇒ **Falta o passo zero: criar a planta no SIH a partir do GC.**

---

## 2. Por que "sincronizar tudo" é a resposta errada

Números de produção em 03/ago:

| | GC | SIH |
|---|---|---|
| plantas | **820** | **127** |
| com CNPJ de 14 dígitos | 725 (**95 sem**) | — |
| com alguma certificação | 656 | — |

Um sync ingênuo despejaria **~693 plantas novas** no SIH. A imensa maioria não tem supervisor em campo e nunca vai ter — o SIH é a operação de supervisão, não o cadastro do mundo. O resultado seria um dropdown inutilizável e a repetição do problema do hands-on de 17/jul (dropdown de abate com 9 de 11 plantas erradas).

### 2.1 E os modelos não são espelho — são parecidos o suficiente para enganar

| Campo | GC | SIH | Problema |
|---|---|---|---|
| `sanitaryCodeType` | **9 valores** em uso: SIF (305), NAO_APLICAVEL (482), IVO_PY, ESTABLECIMIENTO_AR/PY, INVIMA, SENASAG, INTERNAL, GENERIC | **6**: SIF, SIE, SIM, SISBI, INTERNAL, NAO_APLICAVEL | GC é **multi-país**; SIH é **BR-only por decisão do PO (14/jun)**. Os códigos PY/AR/CO/BO **não têm destino**. |
| `plantType` | 4 em uso: `outro` (**495**), `abatedouro` (234), `processamento` (90), `armazenamento` (1) | 8: + `frigorifico`, `laticinio`, `curtume`, `entreposto` | O **SIH é mais rico**. 495 plantas do GC são `outro` = sem informação. Sync sobrescrevendo **destrói curadoria**. |
| `specialtyArea` → `division` | `frigorifico` (246) · `industrial` (453) · **`ambos` (1)** · null (120) | `IN` \| `IND` — **escalar** | ⚠️ **`ambos` não tem representação no SIH.** É exatamente o caso que originou este documento. |
| — | — | `capabilities`, `species`, `isExternal`, `assignedPlants` | **Só existem no SIH.** Um sync que sobrescreve zera o vínculo supervisor↔planta. |

**Conclusão:** não é um problema de sincronização. É de **importação assistida**: o GC entrega o que sabe, um humano completa o que só o SIH sabe.

---

## 3. Proposta — Fatia 1: "Importar do GC" na criação de planta

O fluxo que resolve o caso do Vitor sem despejar 693 registros.

```
SIH · /plantas/nova
┌─────────────────────────────────────────────────┐
│  [ Buscar no GC ]  SIF, CNPJ ou nome            │  ← novo
│                                                  │
│  ○ BRF S.A. — Capinzal/SC (SIF 466)             │
│    CNPJ 01.838.723/0154-00 · GRUPO BRF          │
│    2 certificações vigentes                      │
└─────────────────────────────────────────────────┘
        ↓ selecionar
  formulário atual, PRÉ-PREENCHIDO com o que veio do GC
  (nome, sanitaryCode, tipo, CNPJ, endereço)
        ↓
  humano completa o que o GC não sabe:
  type · division · species · capabilities
        ↓
  [ Salvar ]  → planta criada, com externalCompanyId gravado
```

### 3.1 O que precisa ser construído

**No GC — 1 rota nova** (`/integration/plants/search`):

```
GET /integration/plants/search?q=<sif|cnpj|nome>&limit=20
x-api-key: <GC_INTEGRATION_API_KEY>

200 → [{ id, displayName, legalName, sanitaryCode, sanitaryCodeType,
          taxId, plantType, specialtyArea, address, groupName,
          activeCertifications: 2, existsInSih: false }]
```

> ✅ **Conferido em 03/ago:** o `deploy/halalsphere-api.production.json` já tem `"/integration"` **e** `"/integration/{proxy+}"`. Sub-rota nova sob esse prefixo **não exige** regenerar swagger/gateway. *(Se algum dia a rota subir para um prefixo de topo novo, aí sim — regra do §0 do backlog.)*

**No SIH — backend:**
- `GET /gc-integration/plants/search?q=` — repassa ao GC, reusa `fetchFromGc` (timeout, 404, x-api-key já resolvidos)
- `POST /plants` ganha `externalCompanyId` opcional (o campo **já existe** no model `Plant`, hoje sem uso)

**No SIH — frontend:**
- Passo de busca em `PlantForm.tsx`, pré-preenchendo o form existente

### 3.2 Regras de mapeamento (as decisões que evitam lixo)

| Situação | Regra |
|---|---|
| `sanitaryCodeType` não existe no SIH (PY/AR/CO/BO) | **Bloquear a importação** com mensagem clara. SIH é BR-only; não inventar equivalência. |
| `plantType = outro` no GC (495 casos) | **Não pré-preencher.** Campo fica vazio e obrigatório para o humano. |
| `specialtyArea = ambos` | **Não pré-preencher `division`.** Forçar escolha explícita + aviso de que o SIH não aceita as duas. |
| `specialtyArea = null` (120 casos) | Idem — vazio, humano decide. |
| planta sem CNPJ (95 casos) | Importável, mas avisar que **`/plant-summary` e `/raw-materials` não vão funcionar** (ambos exigem CNPJ). |
| planta já existe no SIH | Marcar `existsInSih: true` e **desabilitar** a seleção — a unique `[sanitaryCode, sanitaryCodeType, cnpj]` rejeitaria de qualquer forma, melhor avisar antes. |
| `species`, `capabilities`, `isActive` | **Nunca vêm do GC.** São operacionais do SIH. |

**Princípio:** o GC pré-preenche, **nunca decide**. Todo campo que o SIH usa para filtrar formulário (`type`, `division`, `capabilities`, `species`) é escolha humana.

---

## 4. Fatia 2 (opcional, depois do go-live) — alerta de divergência

Job diário que compara SIH × GC por SIF+CNPJ e **só reporta** — não corrige:

- razão social mudou no GC
- endereço mudou
- planta desativada no GC mas ativa no SIH
- planta do SIH sem contraparte no GC (dado órfão)

Saída: uma tela de conferência para o admin do SIH decidir caso a caso. **Escrita automática, nunca** — ver §5.

---

## 5. O que esta spec NÃO propõe, e por quê

| Não fazer | Por quê |
|---|---|
| Sync automático de todas as 820 plantas | §2 — polui a operação de campo, quebra dropdown |
| Escrita automática do GC no SIH (job que atualiza) | Zeraria `capabilities`/`species`/`assignedPlants`; o SIH tem curadoria que o GC não tem |
| Escrita do SIH no GC | O GC é o master de cadastro. Fluxo é unidirecional. |
| Model `Company`/`CompanyGroup` no SIH | O SIH não tem e não precisa ter. Junção é `SIF + CNPJ`. Grupo empresarial se resolve exibindo `groupName` vindo do GC, sem persistir. |
| Resolver `division` bi-valorada | **Problema separado** (o `Plant.division` escalar do SIH). Esta spec só evita piorar. |

---

## 6. Ordem de execução

| # | Entrega | Onde | Depende de |
|---|---|---|---|
| 1 | `GET /integration/plants/search` | GC back | — |
| 2 | Repasse `GET /gc-integration/plants/search` | SIH back | 1 |
| 3 | `externalCompanyId` no `POST /plants` | SIH back | — |
| 4 | Passo "Buscar no GC" no `PlantForm` | SIH front | 2, 3 |
| 5 | Regras de bloqueio/aviso do §3.2 | SIH front + back | 4 |
| 6 | *(Fatia 2)* relatório de divergência | GC + SIH | 1 |

Itens 1–5 são a Fatia 1 e entregam valor sozinhos. O item 6 é independente.

---

## 7. Custo × congelamento de escopo

⚠️ **Isto é feature nova, e o escopo congela no início de agosto.** O risco #1 do go-live já é o retrabalho gerado pela validação (§4.1 do backlog).

Contra-argumento honesto: **este é o gargalo que gera os chamados.** Cada planta nova hoje é digitação manual, com o dado correto disponível a um clique de distância — e foi exatamente assim que se perdeu meio dia com a Capinzal.

**Recomendação:** decidir entre

- **(A)** Fatia 1 **depois** do go-live — a FAMBRAS segue digitando à mão em agosto (127 plantas hoje; o volume novo é baixo). **Menor risco.**
- **(B)** Só o item 1+2 (a busca, sem o pré-preenchimento) antes do go-live — permite ao admin **conferir** o dado do GC ao digitar, sem mudar o fluxo de criação. Fatia bem menor.
- **(C)** Fatia 1 completa antes do go-live. **Não recomendo** — mexe em `PlantForm`, que é caminho crítico de cadastro.

❓ **Decisão do Renato.**
