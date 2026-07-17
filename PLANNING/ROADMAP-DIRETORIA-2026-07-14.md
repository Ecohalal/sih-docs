# Roadmap Ecossistema Halal Ecohalal — Versão Diretoria

**Data publicação inicial:** 2026-05-12
**Última atualização:** 2026-07-14
**Autor:** Renato Ribeiro (Ecohalal)
**Audiência primária:** Diretoria Ecohalal
**Audiência secundária:** FAMBRAS Halal (com mesmo conteúdo, sem necessidade de redação paralela)
**Horizonte:** julho/2026 → julho/2027 (12 meses), com âncora no **go-live FAMBRAS em agosto/2026**

> **Nota de versão (14/jul/2026):** esta é a revisão de julho do roadmap publicado em
> maio/2026. A âncora de entrega moveu de julho para **agosto/2026** (go-live FAMBRAS),
> refletindo a decisão de entrar em produção com a base limpa e o ciclo de certificação
> completo. As seções foram atualizadas ao retrato atual; a seção 0 registra a evolução
> desde maio.

---

## 0. Atualizações desde a publicação inicial

> Esta seção registra a evolução do roadmap após sua publicação inicial. As demais seções
> já refletem o retrato de julho/2026.

### 2026-05-12 a 2026-05-21 — Emissão manual de certificado + selos em produção

A ponte operacional prometida entrou no ar já no dia da publicação. Ao longo de maio:
schema `issuance_mode`, endpoint de emissão manual, tela da Qualidade e página pública de
verificação por QR Code em produção. **15 selos FAMBRAS** integrados ao catálogo (ENAS, OIC,
BPJPH, MUIS, MS, GAC + 9 países). 4 hotfixes pós uso real do PO (link no menu, acesso a
PDF/QR no S3 com URL assinada, endpoint dedicado de download com PDF imutável, telas legadas).

### 2026-05-28 — Reset das bases de produção para go-live limpo (marco de decisão)

Decisão estratégica: **entrar em produção com base limpa**, não com dados de teste
acumulados. As bases de produção de **Gestão de Certificações** e **Supervisão Industrial
Halal** foram zeradas (18 tabelas na Supervisão; base da Gestão resetada preservando 22
tabelas de configuração). A FAMBRAS recadastra via UI a partir do pré-cadastro migrado.

Em seguida foi ingerido o **pré-cadastro ETL** oriundo do SysHalal + formulários FM:
**150 grupos / 299 empresas / 268 plantas**. A partir daí, GC e SIH passam a ser tratados
como **pré-go-live** (deployados em infra de produção, sem usuários/dados reais em operação
contínua) — só o **SysHalal** segue em produção real.

### Junho/2026 — Piloto controlado da Supervisão Industrial Halal + endurecimento

- **Piloto controlado com dados reais** (até 4 empresas), com extensão até meados de julho.
- Novos formulários digitalizados: **transferência de pele bovina (FM 7.1.4.7)** e
  **coleta de amostra (FM 7.6.1)**; ocorrências/NC (FM 7.1.6.1).
- **Cadastro de 9 unidades FAMBRAS** em produção (8 JBS Couros + Acquion).
- **Histórico de acessos** enriquecido (geolocalização + sinais de navegador).
- **Vínculo supervisor ↔ plantas** (M:N) e segmentação In Natura × Industrializados.
- Análise do **dossiê de exportação in natura** (embarque = cabeça; 3 gaps mapeados).

### Junho–Julho/2026 — Integração Gestão de Certificações ↔ Supervisão Industrial Halal

- **A Supervisão passa a consumir da Gestão de Certificações** (matérias-primas homologadas,
  read-only) via API `/integration/raw-materials/by-plant` — chave natural SIF + CNPJ.
  Em produção desde 29/jun. É o primeiro elo real do ecossistema integrado.
- Especificado o endpoint de integração **SysHalal → Supervisão** (x-api-key), fechando o
  desenho da malha de integração entre os 3 sistemas.

### Julho/2026 — Carga massiva de dados reais na Gestão de Certificações

Preparação de dados para o go-live (todos via SQL controlado em produção, schema por migration):

- **Seed de cadastro + certificados + escopo (N0–N5):** 550 grupos / 813 plantas /
  1.253 certificados / ~14,8 mil produtos de escopo.
- **Seed de matérias-primas (N5):** 504 MPs / 869 itens homologados / 26 plantas.
- **Normalização de cadastros (10/jul, em produção):** correção de UF (399 registros ruins →
  19 válidos), SIGSIF por planta, desmembramento de grupos (JBS → JBS/SEARA/AVES);
  re-sourcing de produtos (14.817 → 16.524; nomes numéricos 358 → 0; parser de famílias A/B/C);
  seed de 118 cadastros ausentes (7 empresas/grupos, 10 plantas, 113 certificados-espelho,
  1.617 produtos). Fontes cruzadas: SysHalal + SIGSIF + Receita Federal + FM 7.8.x.

### Julho/2026 — Emissão manual madura + edição de escopo + governança

- **Emissão manual de certificado** amadurecida em 2 reuniões FAMBRAS: comboboxes de
  Grupo/Planta sem truncar clientes grandes (JBS/Minerva/BRF), paginação por altura do
  formulário 7.7.2, modo-teste de impressão, exportação Excel em 2 abas, seleção de selos
  ENAS condicionada ao mercado, colunas dinâmicas e rascunho.
- **Trava de data na emissão manual** (09/jul, em produção): validação de ano e aviso de
  vigência acima de 3 anos.
- **Edição de escopo do certificado (Fase 1, 13/jul):** o analista corrige produtos/marcas do
  espelho na própria tela de detalhe, com auditoria transacional (histórico de certificação)
  e número travado.
- **Recuperação de senha self-service na Supervisão** (13/jul): fluxo esqueci/redefinir senha
  com e-mail transacional.
- **Rebrand para a marca azul EcoHalal (`#118add`)** e padronização da nomenclatura dos
  e-mails/PDFs para **"Gestão de Certificações — Fambras Halal by Ecohalal"**.

### Impacto no roadmap

- Toda a base de dados de produção da Gestão de Certificações está **carregada, normalizada
  e conferida** — a FAMBRAS entra no go-live com o histórico real já dentro do sistema, não
  com cadastro em branco.
- A **primeira integração real do ecossistema** (Supervisão consumindo MP da Gestão) já está
  em produção — a tese das 4 portas deixou de ser slide e tem o primeiro elo funcionando.
- A âncora de entrega consolidou-se em **agosto/2026** (go-live FAMBRAS), com julho dedicado
  a maturação da emissão, carga de dados e governança de escopo.

---

## 1. Sumário executivo

A Ecohalal opera um ecossistema de **3 sistemas** que cobrem a jornada completa do cliente
certificado halal — da pré-venda à exportação do lote. Hoje **um deles (Sys Halal) está em
produção real** com clientes e dados vivos; os outros dois (**Gestão de Certificações** e
**Supervisão Industrial Halal**) estão **deployados em infraestrutura de produção, em fase
pré-go-live**, com as bases zeradas em maio para uma entrada limpa e já recarregadas com o
histórico real da FAMBRAS. Os próximos 12 meses consolidam o ecossistema em torno de uma tese
estratégica que **nenhum concorrente global possui** hoje: a **validação cruzada de 4 portas**
entre certificadora, operação industrial e exportação.

**Compromissos críticos:**

- **Agosto/2026** — **Go-live FAMBRAS** com Supervisão Industrial Halal (operação) + Gestão de
  Certificações (certificação) completos, sobre a base real já carregada.
- **Setembro/2026** — Sys Halal alinhado com Gestão de Certificações (operação cruzada,
  porta 4 ativa).
- **Maio–Julho/2027** — Ecossistema consolidado com camadas de IA, ondas operacionais
  estabilizadas, integração externa com acreditadores quando relevante.

**O que já está de pé (julho/2026):**

- Emissão manual de certificado em produção, com QR Code novo, 15 selos e todos os gabaritos.
- Base de dados real da Gestão de Certificações carregada e normalizada (550 grupos /
  813 plantas / 1.253 certificados / ~16,5 mil produtos / 504 MPs homologadas).
- Supervisão Industrial Halal em **piloto controlado** com dados reais e **primeira integração
  real** consumindo matérias-primas homologadas da Gestão de Certificações.

**Por que esse roadmap é executável:** o desenvolvimento é conduzido por uma equipe pequena
(um líder técnico + automação massiva com IA generativa). Esse modelo já entregou, em uma
única sessão, **17 PRs de schema completos da Onda 1+ FAMBRAS**, validou sprints inteiras da
Supervisão em produção em uma única tarde e executou **cargas de dados reais de dezenas de
milhares de registros** com normalização cruzada de 4 fontes. O ritmo é compatível com prazos
curtos; o gargalo real é decisão de produto e validação com cliente, não código.

---

## 2. Visão: 3 sistemas, 1 jornada

| Sistema | Papel na jornada | Quem usa | Estado hoje |
|---|---|---|---|
| **Gestão de Certificações** | Pré-mercado e ciclo de certificação: solicitação → proposta → contrato → auditoria → comitê → emissão de certificado de habilitação → manutenção/renovação | EcoHalal interna (analistas, auditores, comitê, jurídico, qualidade) + cliente certificado (cadastro, escopo, docs) | **Pré-go-live**: infra de produção no ar, base real carregada e normalizada; emissão manual já em produção; go-live pleno em agosto/2026 |
| **Supervisão Industrial Halal** | Operação diária do supervisor halal em campo: relatórios de abate, produção, embarque, NCs, inventário, duplo check Controladoria | FAMBRAS (supervisores em campo, controladoria, gestão) | **Piloto controlado** com dados reais; consome matérias-primas homologadas da Gestão de Certificações em produção; go-live pleno em agosto/2026 |
| **Sys Halal** | Emissão de certificado de exportação por lote, integração com dados oficiais e públicos | Despachantes + clientes para emissão de certificado de embarque | **Em produção** desde 2025, com dados reais; evolução da API de integração externa (v2) em curso |

**Decisão arquitetural confirmada (mai/2026, em operação desde jun/2026):**
- Gestão de Certificações é o **master** de cadastro de Empresa, Planta, Certificado de
  habilitação, escopo e contratos.
- Supervisão Industrial Halal **consome** da Gestão de Certificações (matérias-primas
  homologadas já em produção) e do Sys Halal via API.
- Sys Halal e Gestão de Certificações **coexistem em paralelo**, com propósitos distintos
  (exportação por embarque vs. certificação de estabelecimento). Não há fusão; há integração.

---

## 3. Tese estratégica: validação cruzada de 4 portas

Para o Sys Halal emitir um certificado de exportação por lote, hoje o mercado mundial valida
apenas 3 portas:

1. **Empresa habilitada** (cadastro)
2. **Certificado de habilitação válido** (vigência)
3. **Produto no escopo** (escopo da habilitação cobre o que está sendo emitido)

A Ecohalal adiciona a **4ª porta — evidência operacional**:

4. **Lote tem rastreabilidade no chão de fábrica** (datas de abate/produção, supervisor halal
   responsável, volumes, NCs do período) — extraída diretamente da Supervisão Industrial Halal.

**Por que isso é diferencial:**

Casos documentados de fraude halal no mercado global (adulteração de QR Code, mistura de
lotes, certificado de papel divergente da operação real) acontecem exatamente porque as portas
1–3 são auditáveis em papel, mas a porta 4 não está ligada digitalmente. O ecossistema da
Ecohalal **fecha esse vão** integrando Supervisão Industrial Halal (operação real) ↔ Gestão de
Certificações (papel/escopo) ↔ Sys Halal (emissão).

**Primeiro elo já em produção:** desde junho/2026 a Supervisão consome matérias-primas
homologadas da Gestão de Certificações — a base técnica da porta 4 está construída e validada.
**Ativação plena da porta 4 (validação lote a lote na emissão):** setembro/2026, após o
go-live FAMBRAS.

---

## 4. Estado atual (julho/2026)

### 4.1 Gestão de Certificações

- **Refactor multi-país** em produção — modelo Empresa + Planta + país de destino + norma de
  acreditação correto desde o dia 1.
- **Base de dados real carregada e normalizada** (jul/2026): 550 grupos / 813 plantas /
  1.253 certificados / ~16,5 mil produtos de escopo / 504 matérias-primas homologadas —
  cruzando SysHalal + SIGSIF + Receita Federal + formulários FM.
- **Emissão manual de certificado em produção**, madura após 2 rodadas de validação com a
  FAMBRAS: QR Code novo, 15 selos, todos os gabaritos, exportação Excel, trava de data,
  comboboxes sem truncar clientes grandes.
- **Edição de escopo do certificado (Fase 1)** entregue: analista corrige produtos/marcas com
  auditoria transacional e número travado.
- **Marca azul EcoHalal** e nomenclatura de e-mails/PDFs padronizadas.
- **Falta para o go-live pleno:** telas operacionais restantes da Onda 1+ (wizard de
  solicitação, hub de alteração de escopo, inbox do analista), aditivo contratual, e a
  validação de aceite da FAMBRAS sobre a base carregada.

### 4.2 Supervisão Industrial Halal

- **Piloto controlado com dados reais** (até 4 empresas), estendido até meados de julho.
- **Duplo check** (supervisor assina → controladoria aprova/rejeita) com motivo obrigatório,
  reabertura e histórico completo; perfil **Controladoria** com permissões restritas.
- Segmentação **In Natura × Industrializados**; transferências com origem + destino;
  formulários de couro/pele bovina, coleta de amostra, ocorrências/NC.
- **Consome matérias-primas homologadas da Gestão de Certificações em produção** (primeiro elo
  real do ecossistema).
- **Recuperação de senha self-service** entregue (13/jul).
- **Falta para o go-live pleno:** conclusão do dossiê de exportação in natura (vínculo
  embarque ⇄ produção), ajustes de UX pós-piloto e treinamento formal FAMBRAS.

### 4.3 Sys Halal

- **Em produção** com dados reais (certificados de exportação/embarque da FAMBRAS).
- **Em curso:** nova versão da API de integração externa (v2) — hoje detalhes de produto,
  datas de abate e de processamento ficam empilhados em campos de texto livre (herança da
  versão anterior); a base já tem colunas segregadas, falta a API e o importador de TXT
  evoluírem. Entrega gradual até agosto/2026.
- **Alinhamento com a Gestão de Certificações (TASK-S0)** — Sys Halal deixa de ter cadastro
  próprio de empresa/planta e passa a consumir da Gestão de Certificações. Programado para
  **depois** do go-live FAMBRAS (ago/2026).

---

## 5. Roadmap por fase

### 5.1 Julho/2026 — Maturação pré-go-live (em curso)

**Objetivo:** chegar em agosto com a base real conferida, emissão sólida e escopo governável.

| Sistema | Entregável | Estado |
|---|---|---|
| Gestão de Certificações | Carga + normalização da base real (cadastro, certificados, escopo, MP) | ✅ em produção |
| Gestão de Certificações | Emissão manual madura (2 rodadas FAMBRAS) + trava de data | ✅ em produção |
| Gestão de Certificações | Edição de escopo do certificado (Fase 1) com auditoria | ✅ entregue |
| Gestão de Certificações | Rebrand azul + nomenclatura de e-mails/PDFs | ✅ em produção |
| Supervisão Industrial Halal | Integração consumindo MP homologada da Gestão de Certificações | ✅ em produção |
| Supervisão Industrial Halal | Recuperação de senha self-service | ✅ entregue |
| Supervisão Industrial Halal | Piloto controlado com dados reais (até 4 empresas) | 🟡 em andamento |
| Sys Halal | API de integração externa v2 — desenvolvimento gradual | 🟡 em andamento |

### 5.2 Agosto/2026 — **Go-live FAMBRAS (entrega-âncora)**

**Objetivo:** FAMBRAS opera produção integral em Gestão de Certificações + Supervisão
Industrial Halal, sobre a base real já carregada; treinamento e acompanhamento.

| Frente | Entregável |
|---|---|
| Implantação | Aceite da FAMBRAS sobre a base carregada (cadastro, certificados, escopo, MP) |
| Implantação | Treinamento FAMBRAS (perfis: cliente, analista, gestão, controladoria) |
| Gestão de Certificações | Telas operacionais restantes da Onda 1+ (wizard de solicitação, hub de escopo, inbox do analista) |
| Gestão de Certificações | Aditivo contratual com PDF + editor de planilha MP/fornecedores |
| Supervisão Industrial Halal | Dossiê de exportação in natura (vínculo embarque ⇄ produção) + smoke final |
| Sys Halal | API de integração externa v2 entregue |

**Marco:** ao fim de agosto, FAMBRAS está em produção com o fluxo de certificação
(solicitação → emissão) digital na Gestão de Certificações e o fluxo operacional (relatórios,
NCs, inventário, duplo check) digital na Supervisão Industrial Halal.

### 5.3 Setembro/2026 — Alinhamento Sys Halal + porta 4

**Objetivo:** ativar a tese estratégica de validação cruzada, lote a lote.

| Sistema | Entregável |
|---|---|
| Sys Halal | TASK-S0: consumir cadastro de Empresa/Planta/Certificado da Gestão de Certificações via API |
| Integração | API de validação cruzada consumida pelo Sys Halal antes de emitir cert de embarque |
| Integração | Supervisão Industrial Halal expõe evidência operacional por lote (porta 4) |
| Gestão de Certificações | Programa de Certificação refinado (mapa de auditores, balanceamento) |
| Gestão de Certificações | Auditoria não-anunciada + imparcialidade do auditor (alerta após 3 anos) |

### 5.4 Outubro–Dezembro/2026 — Onda 3 + IA produtiva

**Objetivo:** aprofundamento, IA em produção, observabilidade.

- **Revisor de HAS em 2 estágios** (cliente envia → analista revisa → auditor revisa em campo).
- **Reconhecimento automático** de certificado halal de matéria-prima via acreditadores
  (GAC, JAKIM, BPJPH, MUIS) — conforme demanda.
- **IA de extração de documentos** (Claude API) em produção na Supervisão.
- **Calendário avançado de auditores** + balanceamento ponderado por complexidade.
- **Dashboards executivos** de receita, ciclo e taxa de aprovação por país.
- **Geolocalização e foto na assinatura** do supervisor (pedido FAMBRAS, pós-implantação).

### 5.5 Janeiro–Julho/2027 — Escala e expansão

**Objetivo:** atender múltiplas certificadoras, posicionar a porta 4 como diferencial vendável.

- Multi-tenant operacional (várias certificadoras no mesmo Gestão de Certificações com
  isolamento estrito).
- Onboarding self-service de novas plantas/empresas.
- Integração com registros externos por país (HAKSIS, SiHalal, MOIAT, halal.gov.sa).
- Marketplace de auditores (qualificação cruzada entre certificadoras).
- API pública de validação cruzada para parceiros (porta 4 como serviço).

---

## 6. Riscos e mitigações

| Risco | Probabilidade | Impacto | Mitigação |
|---|---|---|---|
| Atraso de feedback FAMBRAS em decisões de UX (wizards, hub de escopo) trava entregas de ago | Média | Alto | Sessões periódicas marcadas; decisões residuais respondidas ao longo de jun-jul |
| Aceite da FAMBRAS sobre a base carregada revelar divergências de cadastro/escopo | Média | Médio | Base já normalizada e conferida contra 4 fontes; correção via edição de escopo transacional já entregue |
| Bug crítico de regressão na Supervisão em produção durante uso real FAMBRAS | Baixa | Alto | Piloto controlado + smoke documentado; rollback via release branch |
| Capacidade do time (1 dev + IA) virar gargalo se houver dependência de UI especializada | Média | Médio | Ondas 2/3 mapeadas como "se houver folga"; entregas críticas de ago não dependem delas |
| Sys Halal precisar de mudança que toque a produção ativa antes do alinhamento | Baixa | Alto | TASK-S0 só começa após go-live FAMBRAS; produção congelada até lá |
| Deslize do go-live de agosto por acúmulo de validações de cliente | Média | Alto | Escopo de go-live a ser congelado no início de agosto; o que ficar fora vai para Onda 2 |

---

## 7. Por que esse plano fecha em agosto

O total de "código a escrever" é pequeno; a maior parte do que resta é **validação
operacional e treinamento**, com prazo dependente de FAMBRAS, não da equipe técnica. A carga
e normalização de dados — historicamente o maior risco de uma implantação — **já está feita e
em produção**.

| Frente | Entregue | Falta | Risco de prazo |
|---|---|---|---|
| Gestão de Certificações — schema (banco) | 100% | 0% | Baixo |
| Gestão de Certificações — dados reais (carga + normalização) | 100% | Aceite FAMBRAS | Baixo |
| Gestão de Certificações — backend (lógica/API) | 95% | Ajustes finos Onda 1+ | Baixo |
| Gestão de Certificações — frontend (telas) | 75% | Telas operacionais restantes Onda 1+ | Médio (depende de UX feedback) |
| Supervisão Industrial Halal — backend | 95% | Dossiê in natura (vínculo embarque ⇄ produção) | Baixo |
| Supervisão Industrial Halal — frontend | 90% | UX pós-piloto | Baixo |
| Integração ecossistema | 40% | Porta 4 lote a lote (set) | Baixo (base já em prod) |
| Treinamento FAMBRAS | 0% | Perfis × material × sessões | Médio (depende de agenda) |

---

## 8. Próximos passos imediatos

1. **Julho (resto do mês)** — encerrar o piloto controlado da Supervisão com aceite; fechar as
   telas operacionais restantes da Onda 1+ na Gestão de Certificações; concluir o dossiê de
   exportação in natura.
2. **Início de agosto** — congelar escopo de go-live; agendar treinamento FAMBRAS por perfil;
   obter aceite formal da FAMBRAS sobre a base carregada.
3. **Agosto** — go-live FAMBRAS (entrega-âncora): produção integral em Gestão de Certificações
   + Supervisão Industrial Halal.
4. **Setembro** — alinhamento Sys Halal (TASK-S0) e ativação plena da porta 4 (validação lote
   a lote).
5. **Contínuo** — apresentar esta revisão à diretoria Ecohalal e manter a cadência de sessões
   de validação com a FAMBRAS.

---

## 9. Anexos relacionados

- [BACKLOG-ECOHALAL.md](BACKLOG-ECOHALAL.md) — painel central consolidado dos 3 sistemas.
- [ROADMAP-DIRETORIA-2026-05-12.md](ROADMAP-DIRETORIA-2026-05-12.md) — versão anterior deste
  roadmap (maio/2026), mantida como histórico.
- [ROADMAP-TECNICO-2026-05-12.md](ROADMAP-TECNICO-2026-05-12.md) — versão técnica do roadmap
  (para alinhamento interno de execução).
