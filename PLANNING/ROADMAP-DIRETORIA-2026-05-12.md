# Roadmap Ecossistema Halal Ecohalal — Versão Diretoria

**Data publicação inicial:** 2026-05-12 (manhã)
**Última atualização:** 2026-05-13
**Autor:** Renato Ribeiro (Ecohalal)
**Audiência primária:** Diretoria Ecohalal
**Audiência secundária:** FAMBRAS Halal (com mesmo conteúdo, sem necessidade de redação paralela)
**Horizonte:** maio/2026 → maio/2027 (12 meses), com âncora na entrega FAMBRAS em **julho/2026**

---

## 0. Atualizações desde a publicação inicial

> Esta seção registra a evolução do roadmap após sua publicação inicial. Conteúdo das seções 1-9 abaixo permanece válido salvo onde explicitamente atualizado.

### 2026-05-12 (mesmo dia da publicação) — Sprint inicial em produção

Compromisso original era ter a emissão manual de certificado disponível **até 18/mai**. Na prática, **a base funcional ficou em produção no mesmo dia** da publicação:

| Entregável | Status |
|---|---|
| Schema `issuance_mode` no banco | ✅ deployed + migration confirmada em prod via SQL no dia seguinte |
| Endpoint backend `POST /certificates/manual-emit` | ✅ deployed |
| Tela `/qualidade/emissao-manual-certificado` (role Qualidade) | ✅ deployed |
| Página pública de verificação QR Code | ✅ já existia, confirmada |

### 2026-05-13 — Selos FAMBRAS integrados + 4 hotfixes pós uso real do PO

**Selos entregues antes do prazo:** Elaine (Qualidade FAMBRAS) enviou os 15 selos em arquivo único (`logos.png`) — antes do prazo de 14/mai. Foram recortados via script automatizado em 15 PNGs individuais. **Descoberta positiva:** o selo que mapeamos como "OIC/SMIIC" é o **oficial do Halal Accreditation Agency** (não placeholder). Resultado: 15 selos no catálogo (ENAS, OIC, BPJPH, MUIS, MS, GAC e mais 9 países) + tela manual com 17 opções de template no dropdown.

**4 hotfixes corrigidos no mesmo dia** (descobertos em uso real do PO):
- Link no menu lateral para acessar a tela manual (ausente após o primeiro deploy — corrigido em < 30min)
- Bug crítico de acesso ao PDF/QR no S3 (bucket privado, links públicos retornavam *AccessDenied*) — resolvido com URLs assinadas temporárias
- Endpoint dedicado para baixar PDF a qualquer momento — cliente clica, sistema gera link fresco em milissegundos, **PDF original permanece imutável no S3** indefinidamente
- Hotfix em outras telas legadas (`/certificados/:id`, `/certificacoes/:id`) que também usavam links diretos do S3 — todas migradas para o novo endpoint

**Pendências conhecidas (fora do escopo da sprint atual):**
- Módulo de **Contratos** (`/juridico/contratos`) também armazena PDFs no mesmo bucket privado e usa links diretos — se foram emitidos com a URL legada, vão dar *AccessDenied* até receberem o mesmo tratamento. Tratar em sprint separada do jurídico.

**Pendências operacionais para 14-18/mai:**
- Smoke pessoal do PO com 4 gabaritos diferentes (sanity check antes da FAMBRAS validar)
- Janela de validação visual com a FAMBRAS abre **15/mai**
- Treinamento da operadora Qualidade FAMBRAS em **18/mai**

**Impacto no roadmap:**
- Seção 5.0 (Sprint imediata) considerada **substancialmente entregue**; remanesce só validação operacional com cliente (não-código).
- O compromisso de jul/2026 (go-live FAMBRAS GC + SIH) ganhou folga: parte do escopo da Onda 1+ que estava em maio já está em produção. Service layer Onda 1+ (hooks re-emissão, fee override, SLA reverso) continua como próximo bloco da semana.

---

## 1. Sumário executivo

A Ecohalal opera um ecossistema de **3 sistemas integrados** que cobrem a jornada
completa do cliente certificado halal — da pré-venda à exportação do lote. Hoje
os 3 sistemas estão **em produção** com clientes reais. Os próximos 12 meses
consolidam o ecossistema em torno de uma tese estratégica que **nenhum
concorrente global possui** hoje: a **validação cruzada de 4 portas** entre
certificadora, operação industrial e exportação.

**Compromissos críticos:**

- **18/mai/2026 (6 dias)** — Disponibilizar emissão manual de certificados com
  o **novo QR Code** desenhado pela Ecohalal, atendendo todos os gabaritos de
  layout. Ponte operacional até a plataforma nova entrar em julho.
- **Julho/2026** — Go-live FAMBRAS com SIH (operação) + GC (certificação)
  completos.
- **Setembro/2026** — SysHalal alinhado com GC (operação cruzada porta 4 ativa).
- **Maio/2027** — Ecossistema consolidado com camadas de IA, ondas operacionais
  estabilizadas, integração externa com acreditadores quando relevante.

**Por que esse roadmap é executável:** o desenvolvimento é conduzido por uma
equipe pequena (um líder técnico + automação massiva com IA generativa). Esse
modelo já entregou, em maio/2026, **17 PRs de schema completos da Onda 1+ FAMBRAS
em uma única sessão** e validou 2 sprints inteiras do SIH em produção em uma
única tarde. O ritmo é compatível com prazos curtos; o gargalo real é decisão
de produto e validação com cliente, não código.

---

## 2. Visão: 3 sistemas, 1 jornada

| Sistema | Papel na jornada | Quem usa | Estado hoje |
|---|---|---|---|
| **GC** (HalalSphere — Gestão de Certificações) | Pré-mercado e ciclo de certificação: solicitação → proposta → contrato → auditoria → comitê → emissão de certificado de habilitação → manutenção/renovação | EcoHalal interna (analistas, auditores, comitê, jurídico, qualidade) + cliente certificado (cadastro, escopo, docs) | Em produção; Onda 1+ FAMBRAS com 17/20 itens de schema entregues |
| **SIH** (Supervisão Industrial Halal) | Operação diária do supervisor halal em campo: relatórios de abate, produção, embarque, NCs, inventário, duplo check Controladoria | FAMBRAS (supervisores em campo, controladoria, gestão) | Em produção; sprints 1-4 validadas em prod, sprint 5 em validação |
| **SysHalal** | Emissão de certificado de exportação por lote, integração SFDA (Saudi Halal Center) e dados públicos | Despachantes + clientes para emissão de certificado de embarque | Em produção desde agosto/2025; sem alterações em curso |

**Decisão arquitetural confirmada (mai/2026):**
- GC é o **master** de cadastro de Empresa, Planta, Certificado de habilitação,
  escopo, contratos.
- SIH **consome** do GC e do SysHalal via API.
- SysHalal e GC **coexistem em paralelo**, com propósitos distintos (despachante
  vs certificadora). Não há fusão; há integração.

---

## 3. Tese estratégica: validação cruzada de 4 portas

Para o SysHalal emitir um certificado de exportação por lote, hoje o mercado
mundial valida apenas 3 portas:

1. **Empresa habilitada** (cadastro)
2. **Certificado de habilitação válido** (vigência)
3. **Produto no escopo** (escopo da habilitação cobre o que está sendo emitido)

A Ecohalal adiciona a **4ª porta — evidência operacional**:

4. **Lote tem rastreabilidade no chão de fábrica** (datas de abate/produção,
   supervisor halal responsável, volumes, NCs do período) — extraída diretamente
   do SIH.

**Por que isso é diferencial:**

Casos documentados de fraude halal no mercado global (adulteração de QR Code,
mistura de lotes, certificado de papel divergente da operação real) acontecem
exatamente porque as portas 1-3 são auditáveis em papel, mas a porta 4 não está
ligada digitalmente. O ecossistema da Ecohalal **fecha esse vão** integrando
SIH (operação real) ↔ GC (papel/escopo) ↔ SysHalal (emissão).

**Onde a porta 4 entra no roadmap:** out/2026 (após go-live FAMBRAS), entra em
operação real validando lote por lote.

---

## 4. Estado atual (maio/2026)

### 4.1 GC — HalalSphere

- **Refactor multi-país** entregue e em produção (mai/2026) — modelo Empresa +
  Planta + país de destino + norma de acreditação correto desde o dia 1.
- **Onda 1+ FAMBRAS — 17/20 itens de schema entregues** em produção, todos
  aditivos, sem regressão. Inclui:
  - Modelagem de mercado (multi-país × multi-norma)
  - Categorias industriais GSO/SMIIC
  - Alteração de escopo (6 tipos discriminantes)
  - Certificados (4 tipos: único, habilitação, embarque exportação, embarque
    interno)
  - Subcontratação, marca própria/licenciada, declaração de conformidade
  - Auditoria com estágios (1, 2, manutenção, recertificação, especial)
- **Falta da Onda 1+:** camada de serviço (3 hooks: re-emissão de certificado,
  preço por contrato, SLA reverso), ETL de migração da pasta de cliente real
  (IFF-FAR), reforma do wizard de solicitação e 10 telas operacionais.

### 4.2 SIH — Supervisão Industrial

- **Sprints 1 a 4 validadas em produção** com o reset da base FAMBRAS feito em
  mai/2026:
  - Perfil **Controladoria** com permissões restritas
  - Segmentação **IN (in natura)** × **IND (industrializados)** funcionando
  - Workflow **duplo check** (supervisor assina → controladoria aprova/rejeita)
    com motivo obrigatório, reabertura, histórico completo
  - Transferências com origem + destino (5 subtipos)
  - Notificações in-app
- **Falta validar:** Sprint 5 (relatório de Desossa bovina + integração de
  cert halal com SysHalal — TASK-11).
- **4 bugs críticos mapeados** no smoke test (anexos não renderizam, PDF some
  após aprovação, sessão vaza entre logout/login, email SES não chega) —
  todos fixáveis na primeira semana de junho.

### 4.3 SysHalal

- Em produção desde agosto/2025. Não há alteração em curso.
- Próximo trabalho (TASK-S0) é o **alinhamento com GC**: SysHalal deixa de ter
  cadastro próprio de empresa/planta e passa a consumir do GC. Programado para
  agosto/2026, **depois** do go-live FAMBRAS.

---

## 5. Roadmap por fase

### 5.0 12-18/mai/2026 — **Sprint imediata: emissão manual com QR Code (ponte até julho)**

**Objetivo:** dar à FAMBRAS, em 6 dias, a capacidade de emitir novos
certificados halal já com o **QR Code novo** (desenhado pela Ecohalal) e
todos os gabaritos finalizados — sem depender do fluxo completo de
certificação que entra apenas em julho.

**Contexto:** o GC já tem 4 renderers de PDF prontos (FM 7.7.1 e FM 7.7.2
em variantes Standard e Arabic bilingue), gerador de QR Code com logo
FAMBRAS, persistência S3 e endpoint público de verificação. Falta a porta
de entrada manual — uma tela que aceite os dados sem exigir o fluxo
completo solicitação → proposta → contrato → auditoria → comitê.

**Entregáveis:**

| Frente | Entregável | Janela |
|---|---|---|
| GC | Tela "Emissão Manual de Certificado" (role **qualidade**) — formulário com Empresa, Planta, escopo de produtos, mercados, número do certificado, datas, flags granel/álcool | 12-15/mai |
| GC | Validação fim-a-fim dos 4 gabaritos (Standard portrait, Standard landscape, Arabic portrait, Arabic landscape) em produção com dados reais — janela de validação aberta **a partir de 15/mai** | 15-17/mai |
| GC | Selos reais pendentes (ENAS, OIC, BPJPH, MUIS, MS) integrados — **dependência: solicitar ao depto. Qualidade FAMBRAS (Elaine)** | 14-17/mai |
| GC | QR Code novo validado em todos os 4 gabaritos com URL de verificação pública funcionando — validação visual a partir de 15/mai | 15-17/mai |
| GC | Apresentação à FAMBRAS + treinamento curto (1h) para operador (Qualidade) emitir manualmente | 18/mai |

**Decisão de produto:** PDF emitido **sem senha** (aberto). GAP-28 fica
desativado também no go-live de julho — não reabilitar.

**Bridge até julho:** essa tela continua válida até o go-live FAMBRAS, quando
o fluxo completo passa a emitir certificados de forma automatizada via
proposta → contrato → comitê. A tela manual permanece disponível como
"emissão de exceção" pós go-live.

**Dependências externas:**
- **Elaine (depto. Qualidade FAMBRAS)** entregar PNGs dos 5 selos faltantes
  (ENAS, OIC, BPJPH, MUIS, MS) — pedido formal a disparar até 14/mai.
- Validação visual do QR Code e dos gabaritos com a FAMBRAS aberta a partir
  de **15/mai** — janela de 3 dias antes do go-live operacional do 18.

### 5.1 Maio/2026 (resto do mês) — Estabilização SIH + serviços Onda 1+ GC

**Objetivo:** SIH 100% validado em produção + camada de serviço da Onda 1+
fechada no GC.

| Sistema | Entregável | Janela |
|---|---|---|
| SIH | Fechar 4 bugs críticos do smoke test (anexos, PDF aprovado, sessão entre logins, email SES) | 3ª semana mai |
| SIH | Validar sprint 5 (Desossa + cert halal externo) | 4ª semana mai |
| SIH | Corrigir cache PWA stale (Controladoria precisa de Ctrl+Shift+R) | 4ª semana mai |
| GC | Service layer Onda 1+ (hook re-emissão, preço por contrato, SLA reverso) | 3-4ª semana mai |
| GC | Fix gap TargetMarketsStep (wizard captura países mas não persistia) | 3ª semana mai |
| GC | Backfill MarketDestination com config Golfo | 4ª semana mai |

### 5.2 Junho/2026 — Frontend Onda 1+ GC + endurecimento SIH

**Objetivo:** chegar em julho com GC operacional na nova jornada e SIH com UX
arredondada.

| Sistema | Entregável | Janela |
|---|---|---|
| GC | Wizard de solicitação 5 passos ramificado por categoria (U1) | 1-2ª semana jun |
| GC | Hub de alteração de escopo (5 cards + wizard parametrizado U3/U4) | 2-3ª semana jun |
| GC | Tela split-view do analista FM 7.1.9 (cálculo de tempo de auditoria) U2 | 2ª semana jun |
| GC | FM 9.3 unificado (auditoria em campo, mobile, com colapsáveis carimbados) U5 | 3-4ª semana jun |
| GC | Inbox do analista U8 + Hub permanente de docs IT 7.12 U6 | 4ª semana jun |
| GC | Catálogo de Laboratórios + role Qualidade (7 labs FAMBRAS seed) | 1ª semana jun |
| GC | Templates de proposta/contrato em PDF via pdfkit (U10) | 3ª semana jun |
| SIH | Auto-popular Origem/Destino do form de embarque a partir da planta | 1ª semana jun |
| SIH | Route guards por role + clear queryClient no logout | 1ª semana jun |
| SIH | Notificações: badge consistente + página `/notifications` | 2ª semana jun |

### 5.3 Julho/2026 — **Go-live FAMBRAS (entrega-âncora)**

**Objetivo:** FAMBRAS opera produção integral em GC + SIH; treinamento e
acompanhamento.

| Frente | Entregável | Janela |
|---|---|---|
| Implantação | ETL pasta IFF-FAR (cliente real, alteração FAR) — caso piloto de migração de dados legados | 1ª semana jul |
| Implantação | Seed de HomologationProfile FAMBRAS (laticínio, armazém, frigorífico, industrial) | 1ª semana jul |
| Implantação | Treinamento FAMBRAS (3 perfis: cliente, analista, gestão) | 2-3ª semana jul |
| GC | Editor inline planilha MP/fornecedores Airtable-like (U7) — fecha o ciclo de homologação | 1-2ª semana jul |
| GC | Aditivo contratual com PDF preview (U9) | 2ª semana jul |
| GC | Tela Programa de Certificação 3 modos (Executivo/Operacional/Colaborador) — Onda 2 antecipada | 3-4ª semana jul |
| GC | IA Matérias-primas básica (criticidade + origem animal) — Onda 2 antecipada | 4ª semana jul |
| SIH | Smoke final + ajustes pós-treinamento | continuous |
| SIH | POC IA — extração de dados de documentos (Claude API) — começo | 4ª semana jul |

**Marco:** ao fim de julho, FAMBRAS está em produção com:
- 100% do fluxo de certificação (solicitação → emissão) digital no GC.
- 100% do fluxo operacional (relatórios, NCs, inventário, duplo check) digital
  no SIH.
- Acompanhamento ao vivo do programa de certificação em uma só tela.

### 5.4 Agosto-setembro/2026 — Alinhamento SysHalal + porta 4

**Objetivo:** ativar a tese estratégica de validação cruzada.

| Sistema | Entregável | Janela |
|---|---|---|
| SysHalal | TASK-S0: consumir cadastro de Empresa/Planta/Certificado do GC via API | ago |
| Integração | API `/cross-validation/:lot` consumida pelo SysHalal antes de emitir cert de embarque | ago |
| Integração | SIH expõe `/operational-evidence/:lot` para alimentar a porta 4 | ago |
| GC | Programa de Certificação refinado (mapa de calor de auditores, balanceamento) | set |
| GC | Auditoria não-anunciada — workflow (notificação 90d, janela 15d, blackout 5d) | set |
| GC | Imparcialidade do auditor — alerta após 3 anos com mesmo cliente | set |
| SIH | POC IA documentos — entrega beta (extração estruturada de PDFs) | set |

### 5.5 Outubro-dezembro/2026 — Onda 3 GC + estabilização

**Objetivo:** funcionalidades de aprofundamento, IA produtiva, observabilidade.

- **Revisor de HAS em 2 estágios** (cliente envia HAS → analista revisa
  superficialmente → auditor revisa em campo).
- **Reconhecimento automático** de certificado halal de matéria-prima via links
  dos acreditadores (GAC, JAKIM, BPJPH, MUIS) — opcional, conforme demanda.
- **Calendário avançado de auditores** + balanceamento de carga ponderado por
  complexidade.
- **Tradução formal** de documentos (workflow de pedido + entrega).
- **Dashboards executivos** de receita, ciclo, taxa de aprovação por país.
- **Geolocalização e foto na assinatura** do supervisor SIH (pedido FAMBRAS
  adiado para pós-implantação).

### 5.6 Janeiro-maio/2027 — Escala e expansão

**Objetivo:** atender múltiplas certificadoras, posicionar a porta 4 como
diferencial vendável.

- Multi-tenant operacional (várias certificadoras no mesmo GC com isolamento
  estrito).
- Onboarding self-service de novas plantas/empresas.
- Integração com **HAKSIS, SiHalal, MOIAT, halal.gov.sa** (registros externos
  por país de destino).
- Marketplace de auditores (qualificação cruzada entre certificadoras).
- API pública de validação cruzada para parceiros (porta 4 como serviço).

---

## 6. Riscos e mitigações

| Risco | Probabilidade | Impacto | Mitigação |
|---|---|---|---|
| **Elaine (Qualidade FAMBRAS) não entregar selos reais até 17/mai** | Média | Alto (atrasa emissão manual prometida 18/mai) | Pedido formal à Elaine até 14/mai listando ENAS/OIC/BPJPH/MUIS/MS em PNG transparente; fallback: emitir com placeholders em cinza neutro + QR Code funcionando, selos hot-swapáveis depois sem regerar PDFs |
| Atraso de feedback FAMBRAS em decisões de UX (wizards, hub de escopo) | Média | Alto (trava entregas de jun-jul) | Sessões quinzenais marcadas com Lina Ramadan; perguntas residuais já respondidas em mai/2026 |
| Migração de dados legados (pasta IFF-FAR) revelar campos faltantes no schema | Média | Médio | ETL é dry-run em staging antes de prod; schema permite extensão aditiva sem breaking change |
| Bug crítico de regressão no SIH em produção durante uso real FAMBRAS | Baixa | Alto | 4 perfis de usuário teste + smoke documentado; rollback via release branch |
| Capacidade do time (1 dev + IA) virar gargalo se houver dependência de UI especializada | Média | Médio | Onda 2/3 já mapeadas como "se houver folga"; entregas críticas de jul não dependem delas |
| Cliente FAMBRAS questionar "minha planta tá no GC?" antes de set/2026 | Alta | Baixo | SIH e GC continuam operando como hoje; integração leitura via TASK-11 já existe; sync GC↔SIH é Onda futura (D) |
| SysHalal precisar de mudança antes de ago/2026 | Baixa | Alto (toca prod ativa) | TASK-S0 só começa após go-live FAMBRAS; congelado até lá |

---

## 7. Por que esse plano fecha em julho

A tabela abaixo mostra o que **já está pronto** vs. o que falta, separado por
tipo de trabalho. O total de "código a escrever" é pequeno; a maior parte é
**integração e validação operacional**, que tem prazo dependente de FAMBRAS,
não da equipe técnica.

| Frente | Entregue | Falta | Risco de prazo |
|---|---|---|---|
| GC schema (banco de dados) | 100% | 0% (3 hooks de serviço) | Baixo |
| GC backend (lógica/API) | 90% | Service layer Onda 1+ + tela Programa de Certificação | Baixo |
| GC frontend (telas) | 60% | 10 telas Onda 1+ + 1 tela Onda 2 | Médio (depende de UX feedback) |
| SIH backend | 95% | 4 bugs + auto_migrate infra | Baixo |
| SIH frontend | 90% | UX (cache, route guards, anexos auto-popular) | Baixo |
| Migração dados FAMBRAS | 0% | ETL IFF-FAR + seed Homologação | Médio (depende de cliente) |
| Treinamento FAMBRAS | 0% | 3 perfis × material + sessões | Médio (depende de agenda) |

---

## 8. Próximos passos imediatos

1. **Esta semana (mai/12-18) — TOP PRIORIDADE** — entregar a emissão manual
   de certificados com QR Code novo + 4 gabaritos completos (seção 5.0).
   Em paralelo: corrigir os 4 bugs críticos do smoke SIH e fechar os 3 hooks
   de service layer da Onda 1+ GC.
2. **Próxima semana (mai/19-25)** — validar sprint 5 SIH + arrancar wizard
   solicitação GC (U1) e Hub de alteração de escopo (U3).
3. **Última semana de mai (mai/26-31)** — apresentar este roadmap formalmente
   à diretoria Ecohalal e disparar agendamento FAMBRAS para sessões quinzenais
   de jun-jul.
4. **Primeira semana de jun** — primeira sessão FAMBRAS de validação UX (com
   Lina Ramadan + Fuad Arisheh) sobre os wizards.
5. **Começo de jul** — congelar escopo de go-live; tudo que ficar de fora vai
   para Onda 2 (ago em diante).

---

## 9. Anexos relacionados

- [FAMBRAS-VISITA-1504-ONDA-1+.md](FAMBRAS-VISITA-1504-ONDA-1+.md) — plano
  consolidado da Onda 1+ FAMBRAS (~25 entregáveis)
- [SMOKE-TEST-2026-05-11-RESULTADOS.md](SMOKE-TEST-2026-05-11-RESULTADOS.md) —
  status do smoke SIH com bugs e pendências mapeados
- [DECISOES-LINA-2026-05-09.md](DECISOES-LINA-2026-05-09.md) — respostas
  formais da Lina Ramadan que destravaram a Onda 1+
- [CADASTRO-EMPRESA-PLANTA-NOVO-MODELO.md (halalsphere-docs)](../../halalsphere-docs/PLANNING/CADASTRO-EMPRESA-PLANTA-NOVO-MODELO.md) —
  design do refactor multi-país do GC
- [ROADMAP-TECNICO-2026-05-12.md](ROADMAP-TECNICO-2026-05-12.md) — versão
  técnica deste roadmap (para alinhamento interno de execução)
