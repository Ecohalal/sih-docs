# 3. Personas e Jornadas

---

## 3.1 Personas do Sistema

O SIH atende 4 personas principais, mapeadas a partir dos papeis definidos no **PR 7.1 Rev 22, Secao 10.10**.

> **Nota**: O role `gestor` existia no enum original mas foi **removido na v1.0**. Gestores utilizam o HalalSphere para visao executiva. O SIH foca nos papeis operacionais.

---

### Persona 1: Supervisor Muculmano

**Role no sistema**: `supervisor`

| Atributo | Descricao |
|----------|-----------|
| **Quem e** | Profissional muculmano qualificado, designado pela FAMBRAS Halal para acompanhar processos industriais em plantas certificadas |
| **Onde trabalha** | Em campo - plantas de abate, producao industrial e embarque |
| **Dispositivo** | Tablet (uso principal) ou celular |
| **Conectividade** | Variavel - pode estar em areas com internet limitada |
| **Frequencia de uso** | Diario, durante todo o turno de trabalho |
| **Volume** | 3-10 relatorios por dia, dependendo do tipo de planta |

#### Responsabilidades (PR 7.1 Sec. 10.10)

- Supervisionar processos de abate conforme requisitos Halal
- Acompanhar producao industrial de produtos certificados
- Verificar embarques para exportacao e mercado interno
- Registrar nao-conformidades e acompanhar acoes corretivas
- Garantir rastreabilidade da carne Halal (origem, CSN, certificado)
- Assinar e declarar conformidade de cada relatorio

#### Necessidades

- Preenchimento rapido e intuitivo (esta em campo, muitas vezes de pe)
- Interface grande e legivel (tela de tablet, uso com luvas possivel)
- Formularios que guiem o preenchimento (campos condicionais, validacoes)
- Acesso rapido ao historico de relatorios da planta
- Possibilidade de salvar rascunho e continuar depois

#### Dores Atuais

- Preencher formularios em papel e demorado e propenso a erros
- Numeros seriais precisam ser controlados manualmente
- PDFs se perdem ou ficam ilegives
- Sem feedback imediato sobre erros de preenchimento
- Demora para informar NCs a gestao

---

### Persona 2: Coordenador de Supervisores

**Role no sistema**: `coordenador`

| Atributo | Descricao |
|----------|-----------|
| **Quem e** | Profissional que coordena a equipe de supervisores, distribui escalas e revisa relatorios |
| **Onde trabalha** | Escritorio + visitas a campo |
| **Dispositivo** | Desktop (escritorio) e tablet (campo) |
| **Conectividade** | Estavel no escritorio |
| **Frequencia de uso** | Diario |
| **Volume** | Revisa 10-30 relatorios por dia |

#### Responsabilidades

- Distribuir supervisores entre as plantas (escala)
- Criar, editar e desativar supervisores e operadores
- Visualizar todos os relatorios das plantas sob sua coordenacao (somente leitura)
- Cancelar relatorios quando necessario
- Gerenciar nao-conformidades (verificar, encerrar)
- Garantir cobertura de todas as plantas
- **NAO assina relatorios** — a assinatura e exclusiva do supervisor

#### Necessidades

- Visao consolidada de todos os relatorios (somente leitura)
- Gestao de escala com visualizacao por calendario
- CRUD de usuarios (supervisores e operadores)
- Alertas de NCs proximas do vencimento (7 dias)
- Filtros e busca rapida por planta, supervisor, periodo

#### Dores Atuais

- Relatorios chegam com dias de atraso
- Dificuldade de montar escala otimizada
- Sem visibilidade de NCs pendentes em tempo real
- Consolidacao manual de dados para reportar a gestao

---

### Persona 3: Operador

**Role no sistema**: `operador`

| Atributo | Descricao |
|----------|-----------|
| **Quem e** | Profissional de apoio que preenche relatorios sob orientacao de um supervisor, mas nao tem autoridade para assinar |
| **Onde trabalha** | Em campo - plantas de abate, producao industrial e embarque |
| **Dispositivo** | Tablet (uso principal) ou celular |
| **Conectividade** | Variavel |
| **Frequencia de uso** | Diario |
| **Volume** | 3-10 relatorios por dia |

#### Responsabilidades

- Preencher relatorios de abate, producao e embarque
- Registrar dados operacionais com precisao
- Registrar nao-conformidades
- **NAO pode assinar relatorios** — salvam como rascunho para assinatura do supervisor

#### Necessidades

- Interface rapida e intuitiva (igual ao supervisor)
- Acesso a historico de relatorios para referencia
- Possibilidade de salvar rascunho

#### Dores Atuais

- Mesmas dores do supervisor quanto ao preenchimento em papel

---

## 3.2 Matriz de Permissoes por Persona

| Funcionalidade | Supervisor | Operador | Coordenador | Admin |
|----------------|:----------:|:--------:|:-----------:|:-----:|
| Criar relatorios | Sim | Sim | - | Sim |
| Editar relatorios (rascunho) | Proprios | Proprios | - | Todos |
| **Assinar relatorios** | **Proprios** | **NAO** | **NAO** | **NAO** |
| Cancelar relatorios | - | - | Sim | Sim |
| Visualizar relatorios | Proprios | Proprios | Todos (read-only) | Todos |
| Registrar NCs | Sim | Sim | Sim | Sim |
| Resolver NCs | Sim | Sim | Sim | Sim |
| Verificar/Encerrar NCs | - | - | Sim | Sim |
| Ver dashboard | Basico | Basico | Completo | Completo |
| Gerenciar escala | Ver propria | Ver propria | Sim | Sim |
| Gerenciar plantas | - | - | - | Sim |
| Gerenciar usuarios | - | - | Sim (sup+oper) | Sim (todos) |
| Gerar PDF relatorio | Sim | Sim | Sim | Sim |

---

## 3.3 Jornadas Tipicas

### Jornada do Supervisor - Dia Tipico em Planta de Abate

```
06:00 - Chega na planta, abre SIH no tablet
06:05 - Seleciona planta + turno, inicia novo relatorio de abate (FM 7.1.4.x)
06:10 - Preenche cabecalho (dados do degolador, especie)
06:15 - Inicia supervisao do abate
       → Verifica itens C/NC durante o processo
       → Registra contagens (total, aprovados, rejeitados)
       → Para bovinos: avalia insensibilizacao
11:00 - Primeira conferencia de stunning (bovino)
12:00 - Pausa - salva rascunho
13:00 - Retoma preenchimento
14:00 - Segunda conferencia de stunning
15:00 - Finaliza contagens e camaras de resfriamento
15:10 - Revisa, assina e envia relatorio
15:15 - Se NC identificada: registra NC com foto e descricao
15:30 - Fim do turno
```

### Jornada do Supervisor - Dia Tipico em Planta de Producao Industrial

```
07:00 - Chega na planta, abre SIH
07:05 - Inicia relatorio de producao (FM 7.1.3.1)
07:10 - Registra materias-primas carneas (SIF origem, CSN, certificado Halal)
07:20 - Registra ingredientes aprovados (nao-carneos)
07:30 - Inicia acompanhamento da producao
       → Verifica 5 itens C/NC (limpeza, materias-primas, documentacao, armazenamento, rotulagem)
12:00 - Registra dados do produto final (codigo, lote, quantidades)
12:10 - Envia relatorio de producao
14:00 - Acompanha embarque: inicia relatorio de embarque (FM 7.1.7.1)
14:10 - Preenche dados de exportacao (importador, container, lacre)
14:20 - Adiciona tabela de produtos
14:25 - Verifica 2 itens C/NC (exclusividade Halal, selo)
14:30 - Envia relatorio de embarque
```

### Jornada do Coordenador - Gestao Diaria

```
08:00 - Abre dashboard, ve resumo geral dos relatorios
08:10 - Filtra relatorios assinados do dia anterior → revisa visualmente
08:15 - Identifica relatorio com NC pendente → abre NC para verificacao
08:30 - Ve 3 NCs proximas do prazo de 7 dias → contacta supervisores
09:00 - Monta escala da proxima semana no calendario
09:30 - Cadastra novo operador que iniciara na planta
10:00 - Gera PDFs de relatorios assinados para arquivo da auditoria
```
