# 3. Personas e Jornadas

---

## 3.1 Personas do Sistema

O SIH atende 3 personas principais, mapeadas a partir dos papeis definidos no **PR 7.1 Rev 22, Secao 10.10**.

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
- Revisar e aprovar/rejeitar relatorios enviados
- Monitorar nao-conformidades e prazos
- Garantir cobertura de todas as plantas
- Reportar indicadores a gestao

#### Necessidades

- Visao consolidada de todos os relatorios pendentes de revisao
- Gestao de escala com visualizacao por calendario
- Alertas de NCs proximas do vencimento (7 dias)
- Filtros e busca rapida por planta, supervisor, periodo
- Aprovacao/rejeicao rapida com feedback ao supervisor

#### Dores Atuais

- Relatorios chegam com dias de atraso
- Dificuldade de montar escala otimizada
- Sem visibilidade de NCs pendentes em tempo real
- Consolidacao manual de dados para reportar a gestao

---

### Persona 3: Gestor de Certificacao

**Role no sistema**: `gestor`

| Atributo | Descricao |
|----------|-----------|
| **Quem e** | Responsavel pela area de certificacao Halal na FAMBRAS, toma decisoes estrategicas |
| **Onde trabalha** | Escritorio |
| **Dispositivo** | Desktop |
| **Conectividade** | Estavel |
| **Frequencia de uso** | Semanal/sob demanda |

#### Responsabilidades

- Supervisionar o programa de supervisao industrial
- Analisar indicadores de conformidade
- Tomar decisoes sobre NCs criticas
- Reportar ao comite de certificacao
- Planejar auditorias baseado nos dados de campo

#### Necessidades

- Dashboard executivo com indicadores-chave
- Relatorios de NCs por severidade e planta
- Historico e tendencias de conformidade
- Exportacao de dados para apresentacoes
- Visao de cobertura de supervisao (escalas cumpridas)

#### Dores Atuais

- Dados chegam atrasados e fragmentados
- Sem indicadores consolidados para decisao
- Dificuldade de identificar plantas problematicas
- Informacoes dependem de relatos verbais

---

## 3.2 Matriz de Permissoes por Persona

| Funcionalidade | Supervisor | Coordenador | Gestor | Admin |
|----------------|:----------:|:-----------:|:------:|:-----:|
| Criar relatorios | Sim | Sim | - | Sim |
| Editar relatorios (rascunho) | Proprios | Todos | - | Todos |
| Enviar relatorios | Proprios | Todos | - | Todos |
| Revisar/Aprovar relatorios | - | Sim | Sim | Sim |
| Registrar NCs | Sim | Sim | - | Sim |
| Resolver NCs | Sim | Sim | Sim | Sim |
| Verificar NCs | - | Sim | Sim | Sim |
| Ver dashboard | Basico | Completo | Executivo | Completo |
| Gerenciar escala | - | Sim | Sim | Sim |
| Gerenciar plantas | - | - | Sim | Sim |
| Gerenciar usuarios | - | - | - | Sim |

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

### Jornada do Coordenador - Revisao Diaria

```
08:00 - Abre dashboard, ve relatorios pendentes de revisao
08:10 - Filtra por "enviados hoje" → 15 relatorios
08:15 - Revisa relatorio de abate: dados completos, aprova
08:20 - Revisa relatorio de producao: falta CSN → rejeita com comentario
08:30 - Ve 3 NCs proximas do prazo de 7 dias → notifica supervisores
09:00 - Monta escala da proxima semana no calendario
09:30 - Exporta indicadores semanais para reuniao com gestao
```
