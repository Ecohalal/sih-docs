# User Stories - SIH v1.0

---

## Resumo

| Epico | FM | User Stories | Story Points | Prioridade |
|-------|----|:------------:|:------------:|:----------:|
| [Epic 01: Relatorios de Abate](./epic-01-relatorios-abate.md) | FM 7.1.4.x | 7 | 47 | P0 |
| [Epic 02: Relatorios de Producao](./epic-02-relatorios-producao.md) | FM 7.1.3.x / FM 7.1.8.x | 6 | 40 | P0 |
| [Epic 03: Relatorios de Embarque](./epic-03-relatorios-embarque.md) | FM 7.1.7.x / DCPOA | 6 | 38 | P0 |
| [Epic 04: Nao-Conformidades](./epic-04-nao-conformidades.md) | FM 7.1.6.1 | 6 | 35 | P0 |
| [Epic 05: Escala de Supervisores](./epic-05-escala-supervisores.md) | - | 4 | 20 | P1 |
| [Epic 06: Dashboard e Relatorios](./epic-06-dashboard.md) | - | 4 | 22 | P1 |
| [Epic 07: Inventario](./epic-07-inventario.md) | FM 7.1.5.x / FM 7.1.3.6 | 6 | TBD | P2 (FUTURO) |
| **Total v1.0** | | **33** | **202** | |
| **Total (com futuro)** | | **39** | **202+** | |

---

## Convencoes

### Formato das User Stories

```
Como [persona],
Eu quero [acao],
Para que [beneficio].
```

### Priorizacao

| Nivel | Descricao |
|-------|-----------|
| **P0 - Must Have** | Essencial para v1.0. Sistema nao funciona sem isso. |
| **P1 - Should Have** | Importante para v1.0. Pode ser simplificado se necessario. |
| **P2 - Nice to Have** | Documentado para implementacao futura. |

### Story Points (Fibonacci)

| Pontos | Complexidade |
|--------|-------------|
| 1-2 | Trivial (campo simples, CRUD basico) |
| 3-5 | Simples (formulario padrao, validacoes) |
| 8 | Medio (logica de negocio, secoes condicionais) |
| 13 | Complexo (workflow, calculos, integracao) |
| 21 | Muito complexo (multiplos subsistemas) |

### Nomenclatura

- **SIH-XXX**: Identificador unico da user story
- **FM X.X.X.X**: Referencia ao formulario FAMBRAS
- **PR 7.1**: Referencia ao procedimento Rev 22
