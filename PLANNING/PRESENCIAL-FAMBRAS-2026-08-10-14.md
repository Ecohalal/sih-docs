# PRESENCIAL FAMBRAS — 10 a 14/ago/2026 · captura de validação

> **Documento de SESSÃO AO VIVO.** Nasceu em 10/ago para registrar, na hora, o que a FAMBRAS
> aponta durante a apresentação dos sistemas — sem tocar em código.
>
> ⚠️ **Não é estado.** O estado continua sendo `PLANNING/BACKLOG-ECOHALAL.md` (§0). Ao fim de cada
> dia, os achados desta captura são **levados ao §4 do BACKLOG** com dono, e este doc vira histórico (§8).
>
> **Por que este presencial pesa:** o backlog registrou que **ninguém testou** antes (Soha, Lina, Elaine,
> André e Fuad, todos declarados em 03/ago) e que a validação inteira foi empurrada para cá — ou seja,
> **retrabalho descoberto a ~1 dia do go-live (15/ago)**, sem folga para absorver. Cada achado aqui é,
> na prática, uma decisão de escopo de go-live: *corrige antes, corrige depois, ou opera com pendência.*

---

## 0. Regras desta sessão (combinadas com o Renato)

1. **ZERO alteração de código nesta sessão.** Aqui só se captura, classifica e decide destino.
2. Cada achado ganha **ID** (`FRG-01`, `IND-01`, …) e uma **classificação** — ver §1.
3. O que der para resolver com **pergunta na sala, pergunte na hora**. A sala se desfaz; a dúvida fica.
   Perguntas registradas em ❓ **PERGUNTAR AGORA** dentro do achado.
4. **O que passou também se registra** (§5). André foi explícito em 03/ago: *"a gente tem que refazer os
   testes para poder te dar aprovação"* — **aprovação formal precisa de lista de "OK", não só de bugs.**
5. Trabalho de código sai daqui como **prompt para sessão paralela** (§7), respeitando o domínio de
   arquivos das trilhas (§2 do BACKLOG). Duas trilhas não tocam o mesmo arquivo.

---

## 1. Classificação dos achados

| Código | Significa | Destino |
|---|---|---|
| 🐛 **BUG** | Comportamento errado / quebra. Precisa de evidência (print, Network, hora+planta). | §4.2 (Claude) via prompt |
| 🧩 **GAP** | Funciona, mas falta capacidade. É escopo novo → decide-se **antes × depois do go-live**. | §4.2 + decisão de timing |
| 🎨 **UX** | Certo no dado, ruim de usar. Barato; costuma caber no mesmo lote. | §4.2 |
| ❓ **DECISÃO FAMBRAS** | Depende de regra de negócio/norma. **Não inferir.** | §4.3 |
| 🔧 **DADO/CADASTRO** | Não é código: falta carga, vínculo ou cadastro. | §4.1 (Renato) |
| ✅ **OK** | Validado ao vivo por quem opera. Vale como aprovação. | §5 deste doc |

**Regra anti-retrabalho:** antes de abrir achado novo, conferir a **watch-list (§3)**. Muita coisa que
vai aparecer já está mapeada no BACKLOG — nesse caso o registro é *"confirmado em campo"*, não item novo.

---

## 2. Ambiente sob validação — versão CONFIRMADA DE FORA (10/ago, antes de começar)

Verificação feita pelo asset servido, não pela listagem do console (lição §6 do BACKLOG):

| Camada | Versão em produção | Prova |
|---|---|---|
| **GC front** | **`d9b6a9ea`** | `index-D5JUQTGv.js` contém "Minhas Auditorias", "Minhas Competências", "Pessoal Qualificado"; chunk `CertificationDetails-bKZxm5ZB.js` contém "Ver cadastro da empresa" + `wa.me` |
| **GC back** | **`5485f7c8`** | HEAD de `origin/release` |
| **URL** | `https://gestaodecertificacoes.ecohalal.solutions` | — |

⚠️ **NÃO está em produção** (commitado local, sem push — Trilha F): **Catálogo de Ingredientes
Restritos, Fatia A** (front `4aeadb8b` · back `80dde176`). Confirmado por ausência: a string
"Ingredientes Restritos" **não existe** no bundle servido. ⇒ **não demonstrar essa tela hoje.**

✅ **Consequência boa:** tudo o que o time apontar hoje é contra o **código mais novo** — não se repete o
episódio de 30/jul, quando os analistas validaram uma tela sem o `81e52f6c` e parte do retorno era de
versão velha.

---

## 3. Watch-list — o que JÁ sabemos frágil no perfil `empresa`

> O perfil `empresa` foi exercitado com dados reais pela **1ª vez em 08/ago** (madrugada, no local) e
> rendeu **9 correções em 1 noite**. É o perfil menos rodado do sistema. Estes são os pontos onde a
> chance de achado é alta — e onde **já existe pendência aberta**, para não duplicar.

| # | Ponto | Estado conhecido | Se aparecer hoje |
|---|---|---|---|
| W-1 | **Acesso por GRUPO empresarial** (JBS/Seara/Minerva vendo as irmãs) | Modelo semi-pronto (`companyGroupId`+`isGroupAdmin` no JWT) mas **nenhuma query consome**. Comportamento **inconsistente por tela**: lista de certs = grupo · `company/:id` = corrigido p/ irmãs (`8a22aa46`) · **audits/documents = só a própria** | É a inconsistência sistêmica já registrada. ❓ decisão de **timing** pendente com o Renato — spec não escrita |
| W-2 | **Certificados sem PDF para download** | **85 com PDF real × 1.360 com `pdf_url=''`** — acervo-espelho; o PDF oficial vive no SysHalal. UI já diz "PDF não disponível" | Não é bug. 🏛️ decisão pendente: anexar legados em massa × regenerar no layout GC (regenerar cria documento que nunca existiu — imutabilidade §5.3) |
| W-3 | **"Homologação de MP" no menu da empresa** | Por desenho (empresa declara, FAMBRAS homologa) — mas **para frigorífico a tela fica vazia** | ❓ Esconder o menu para divisão In Natura? **Decisão FAMBRAS — o time de hoje é exatamente quem responde** |
| W-4 | **188 evidências halal de MP VENCIDAS** (75 de 335 MPs) | Decidido 05/ago: **avisar, não travar**; o analista regulariza. Já visível na tela | Se estranharem os badges vermelhos: é o esperado. A fila é da FAMBRAS |
| W-5 | **Empresas do acervo sem `contact`** | O import dos FM não traz responsável/telefone → bloco de contato não aparece | 🔧 lacuna de **cadastro**, não bug |
| W-6 | **`email_verified`** | 19 regularizados em 08/ago; **5 que nunca logaram** são marcados pelo próprio fluxo no 1º acesso | Se der "Email não verificado", checar se é um dos 5 |
| W-7 | **Largura de tela / botões cortados** | Destravado em 08/ago (`3d04e484`); coluna Ações corrigida (`df952d79`) | Achado novo aqui é regressão — registrar com print |
| W-8 | **Tipos de documento divergentes** | `DOCUMENT_TYPE_LABELS` do front **diverge do enum do Prisma** (`layout_planta`, `lista_ingredientes`, `certificados_fornecedores` não existem no banco) → **o wizard pode oferecer tipo que o backend rejeita** | Alta chance de aparecer hoje na aba Documentos. **Já mapeado, nunca conferido no wizard** |
| W-9 | **Wizard de solicitação (11 etapas)** | Ajustado 08/ago para caber sem scroll (`40941644`+`5bf20b8d`); **não está no menu** — só por botão dentro de `/certificacoes` | Se o time não achar como solicitar, é 🎨 UX de descoberta |

---

## 4. Mapa de navegação — perfil `empresa` (checklist ao vivo)

Menu real do perfil (`Sidebar.tsx`), 7 itens. Marcar conforme passa.

| Seção | Item | Rota | Status | Achados |
|---|---|---|---|---|
| Visão geral | Dashboard | `/dashboard` | ⬜ | |
| Visão geral | Calendário | `/calendario` | ⬜ | |
| Certificação | **Certificações** | `/certificacoes` | ⬜ | |
| ↳ | Detalhe da certificação | `/certificacoes/:id` | 🟡 | **FRG-04** (datas) |
| ↳ | **Documentos e anexos** | (aba do detalhe) | 🟡 | **FRG-01** (nomenclatura) |
| ↳ | **Escopo** (produtos / marcas) | (aba do detalhe) | 🟡 | **FRG-02** (campos misturados) |
| ↳ | **Matriz PCCH** | (aba do detalhe) | 🟡 | **FRG-03** (termo errado) |
| ↳ | Card de certificados emitidos | (aba do detalhe) | 🟡 | **FRG-04** (datas -1 dia) |
| ↳ | Solicitar nova (wizard 11 etapas) | `/certificacoes/nova` | ⬜ | |
| ↳ | Renovar / Ampliar / Manutenção | `/certificacoes/:id/{renovar,ampliar,manutencao}` | ⬜ | |
| ↳ | Proposta / Contrato | `/certificacoes/:id/{proposta,contrato}` | ⬜ | ⚠️ PDF de contrato é **stub** conhecido |
| Certificação | Homologação de MP | `/homologacao-mp` | ⬜ | ver **W-3** |
| Empresas | **Empresas do Grupo** | `/grupo` · `/grupo/empresa/:id` | ⬜ | ver **W-1** |
| Empresas | Usuários | `/usuarios` | ⬜ | |
| Ajuda | Manual | `/manual` · `/manual/:moduleKey` | ⬜ | |

Legenda: ⬜ não passou · 🟡 passou com achado · ✅ passou OK

---

## 5. Achados — Dia 1 · 10/ago · equipe **FRIGORÍFICO** (In Natura)

**Presentes:** André (gestor In Natura) · Giovanna · William · Renato
**Sistema:** GC — Gestão de Certificações · **Perfil:** `empresa` · **Escopo:** navegação em todas as opções

| ID | nº na sala | Tipo | Tela | Resumo | Dono | Estado |
|---|---|---|---|---|---|---|
| **FRG-01** | 1 | 🧩 GAP + ❓ | Documentos/Anexos | Documento anexado deve ser **nomeado por regra**, não pelo nome do arquivo; o nome se define na **avaliação documental** | ❓FAMBRAS → §4.2 | 🟡 falta a regra |
| **FRG-02** | 2 | 🔧 DADO (ETL) | Escopo | Marcas, produtos e **embalagem** misturados nos campos errados — o ETL dos FM não separou. **MEDIDO em prod: 94% dos produtos sem `packing_size`** enquanto a embalagem está no campo de marca | Renato/Claude → §4.1+§4.2 | 🔴 confirmado e quantificado |
| **FRG-03** | 3 | 🐛 UX (termo) | Matriz PCCH | "Pontos Críticos **Controle Haram**" → correto é "Pontos Críticos **de Controle Halal**". **Viola regra absoluta de termos haram** e há mais 8 ocorrências | Claude → §4.2 | 🔴 pronto p/ corrigir |
| **FRG-04** | — | 🐛 BUG | Detalhe + card de certificados | Emissão/validade exibem **1 dia antes** do documento oficial. **Banco e PDF estão CORRETOS** — é só renderização | Claude → §4.2 | 🟢 causa-raiz isolada |
| **FRG-05** | 4 | 🧩 GAP | Matriz PCCH + HAS | Cliente **deve poder enviar** a Matriz PCCH e o HAS. Hoje é read-only p/ `empresa`; **HAS não tem caminho de envio nem tipo de documento** | Claude → §4.2 | 🔴 gap real |
| **FRG-06** | 5 | 🐛 UX/sigilo | Check List de Processo (FM 7.1.1) | Empresa **não deve ver** o checklist do comitê — hoje vê em read-only | Claude → §4.2 | 🟢 fix trivial |
| **FRG-07** | — | 🚨 **SEGURANÇA** | API do PCCH | `pcch.controller` **sem nenhum `@Roles`** e `pcch.service` **sem recorte por empresa** ⇒ escrita cross-tenant. A defesa é **só de UI** | Claude → §4.2 | 🔴 achado meu, não pedido |
| **FRG-08** | 6 | 🐛 UX/sigilo | Wizard → classificação industrial | **Não mostrar prazo de auditoria** ("1.5d auditoria", "2d auditoria") no fluxo do cliente — é insumo interno de planejamento e **preço** | Claude → §4.2 | 🟢 fix trivial |
| **FRG-09** | 7 | 🎨 UX + 🚨 **risco de cálculo** | Wizard → Informações de Produção | "Número de Funcionários" sem a definição do FM. O campo **alimenta a fórmula de dias de auditoria** | Claude | 🟢 **decidido**: turno com MAIOR nº de envolvidos no processo Halal |
| **FRG-10** | — | 🚨 **SEGURANÇA** | API de comentários | Segregação de comentário interno é **contornável por query param** (`?includeInternal=true` com token `empresa`) | Claude → §4.2 | 🔴 achado meu, não pedido |
| **FRG-11** | 8 | 🧩 GAP | Wizard → outras certificações | Se a empresa tem outras certificações (ISO/FSSC), **anexar o comprobatório é obrigatório**. Hoje é só texto livre | Claude → §4.2 | 🟢 **decidido, pronto** |
| **FRG-12** | 9 | 🚨 **BUG de integridade** | Wizard, a partir de empresa já certificada | Nova certificação **herda o escopo** (produtos, marcas, instalações, produção) da certificação existente. Só dados da EMPRESA deviam ser pré-carregados | Claude → §4.2 | 🟢 **causa-raiz isolada** |
| **FRG-13** | 7 *(2º uso do nº)* | 🧩 GAP | Escopo → Marcas | Logo da marca aceita **só URL**; o cliente precisa poder **fazer upload da imagem** | Claude → §4.2 | 🟢 **pronto** — infra de upload já existe |
| **FRG-14** | 8 | 🎨 UX + ❗regra | Wizard → Países de Destino | Falta o texto do FM (**Egito, Irã e Turquia = consultar a FAMBRAS**) e o aviso de que **a FAMBRAS não certifica para o Irã** | Claude → §4.2 | 🟢 **pronto** |
| **FRG-15** | — | 🚨 **dado não persistido** | Wizard → Países de Destino | `targetMarkets` é **objeto** no front × **`string[]`** no DTO; e `certification_form_data` tem **0 linhas em prod** ⇒ país de destino nunca foi gravado | Claude → §4.2 | 🔴 achado meu, não pedido |
| **FRG-16** | 8 *(2º uso)* | 🧩 **GAP estrutural** | Comercial → Propostas | Comercial não vê a **sugestão de dias de auditoria** — base da proposta. **A fórmula GSO 2055-2 existe, permite `comercial`, e NENHUMA tela do sistema a consome** | Claude → §4.2 | 🔴 maior lote do dia |
| **FRG-17** | 8 *(2º uso)* | 🎨 UX + ❓ | Wizard → Produção | "Quantidade APPCC" é **obrigatório**, sem definição, e **não entra na fórmula** de dias de auditoria | Claude + ❓FAMBRAS | 🟡 rótulo pronto; efeito na fórmula é questão de norma |
| **FRG-18** | 9 | 🚨 **BUG de fluxo** | Workflow, pós-assinatura | **Assinar o contrato NÃO avança o workflow** — fica em `assinatura_contrato`/`aguardando_empresa` para sempre. Travou o fluxo ao vivo (Minerva SIF 431) | Claude → §4.2 | ✅ **EM PROD 10/ago `23223b37`** — assinar devolve a posse (`aguardando_empresa`→`pendente`) SEM avançar a fase; falta validar |
| **FRG-19** | 10 | 🚨🚨 **A tela NUNCA funcionou** | Analista → Análise Documental | Filtra por fases **que não existem no enum** (`analise_documental`, `triagem`) ⇒ a tela está **sempre vazia, para toda certificação**. Era o "ponto escuro" | Claude → §4.2 | ✅ **EM PROD 11/ago `082a00eb`** — não eram 4 strings: o `ProcessPhase` do front inteiro estava obsoleto (11 de 17); falta validar |
| **FRG-20** | 11 | 🚨 **BECO SEM SAÍDA** | Workflow → Atribuir Analista | "Avançar Fase" genérico passa de `assinatura_contrato` **sem atribuir analista**; depois o `assign-analyst` **rejeita para sempre com 400** (só aceita naquela fase exata). Processo fica sem analista e sem como atribuir | Claude → §4.2 | ✅ **EM PROD 10/ago `a9fb46fb`** — janela "assinatura ou posterior"; falta validar |
| **FRG-21** | — | 🚨 **auditoria/ISO 17065** | `PATCH /workflows/:id` | Aceita **qualquer `currentPhase`** sem validar transição e **sem gravar `workflow_phase_history`** ⇒ fase muda sem rastro. Liberado a `analista` | Claude → §4.2 | ✅ **EM PROD 10/ago `0a736a82`** — campo fora do DTO; mandar agora é 400 |
| **FRG-22** | 12 | 🐛 sigilo/imparcialidade | Detalhe da certificação | **Analista não deve ver VALORES** de proposta e contrato (R$ 17.825,00 visível). Precisa ver o **status**, não o valor | Claude → §4.2 | 🟢 **pronto** — entra no P1 |
| **FRG-23** | 10 | 🎨 UX | Analista → Empresas → detalhe | Abre `CompanyDetail` (**sem abas**); a tela boa é a `/grupo/empresa/:id`, com Plantas · Certificações · **Documentos** + KPIs | Claude → §4.2 | 🟢 **pronto** — 2 linhas |
| **FRG-24** | 11 | 🚨 **REATRIBUIÇÃO IMPOSSÍVEL** | Gestor → reatribuir analista | Mesmo 400. **Atribuir analista é de uso ÚNICO por construção:** a própria atribuição avança a fase e fecha a única janela em que atribuir é permitido. **Não existe rota de reatribuição** | Claude → §4.2 | ✅ **EM PROD 10/ago `a9fb46fb`** — reatribuição sem mexer na fase + `AuditTrail`; a UI já tinha o botão |
| **FRG-25** | 12 | 🚨 **segregação de funções** | Analista → Contratos | Analista deve ver **só o status**, não valores nem o documento. **Hoje ele CRIA, EDITA, ENVIA, GERA PDF, MANDA ASSINAR e CANCELA contrato** — e `comercial` não tem nenhuma rota | Claude → §4.2 | 🔴 **matriz invertida** |
| **FRG-26** | — | 🐛 texto corrompido | Analista → Contratos | "certifica**��**o" e "Buscar por n**�**mero" — o arquivo tem **U+FFFD gravado** (acentos perdidos em conversão de encoding) | Claude → §4.2 | 🟢 trivial, mas visível em demo |
| **FRG-27** | — | 🐛 tela branca provável | Analista → Contratos (busca) | `contract.company?.razaoSocial.toLowerCase()` — campo **não existe** (`legalName`) e **sem `?.` depois** ⇒ digitar na busca deve derrubar a tela | Claude → §4.2 | 🔴 **testável em 2s** |
| **FRG-28** | 14 | 🧩 **GAP + spec recebida** | Analista → Solicitar documento | Solicitação é **1 por vez**; o processo real pede **~15 de uma vez**, em lista que **varia por segmento** (Bovino/Aves/Industrial). Padrão de comunicação recebido em `.odt` | Claude → §4.2 | 🔴 **lote grande, spec em mãos** |
| **FRG-29** | 15 | 🚨 **processo para calado** | Empresa → dashboard | Documento solicitado **não gera alerta, notificação nem e-mail**. O módulo `document-request` **não tem nenhuma integração com notification/email**; o dashboard da empresa **não trata** o assunto | Claude → §4.2 | ✅ **EM PROD 11/ago `c1777de1`** — notificação + e-mail à empresa na criação (fatia (a)); (b) KPI no dashboard e (c) lembrete de prazo seguem abertos |
| **FRG-30** | 16 | 🚨 **o silêncio é nos DOIS sentidos** | Analista → dashboard | Empresa **enviou** o documento e o analista **não é avisado**. Espelho exato do FRG-29 ⇒ o ciclo de documentos é **mudo de ida e de volta** | Claude → §4.2 | ✅ **EM PROD 11/ago `c1777de1`** — notifica quem pediu + o analista atual da certificação. *(Cheguei a registrar que não dispararia; era alarme falso — o card "Documentos Solicitados" do `CertificationDetails` chama o `fulfill`. Ver §4.1 do BACKLOG.)* |
| **FRG-31** | 17 | 🐛 **rejeição sem motivo** | Analista → rejeitar documento | O ✗ rejeita **sem pedir motivo** e sem devolver nada à empresa. **Back e modelo já suportam** (`validationNotes`); existe até componente que faz certo — **o botão usado é o errado dos dois** | Claude → §4.2 | 🟢 **pronto — só ligar o que existe** |
| **FRG-32** | 18 | 🚨🏛️ **PDF × validação pública divergem** | QR / verify | `BRF.LRV.2604.1472.1.BRA`: PDF traz selo **ENAS**, a página do QR **não mostra selo**. Causa: o PDF **deriva** o selo na hora; o `verify()` lê a coluna `market_variant`, que está **NULL**. **180 certificados** na mesma condição | Claude → §4.2 | 🔴 **credibilidade externa** |

---

### ✅ DECISÕES DA SALA — 10/ago (respostas do Renato / equipe Frigorífico). **Não re-litigar.**

| Item | Decisão | Efeito |
|---|---|---|
| **FRG-03** | Termo **confirmado com a equipe de Frigorífico**: "Pontos Críticos **de Controle Halal**" | 🟢 **destravado** — sigla PCCH preservada |
| **FRG-05** | **HAS e Matriz são sempre DOCUMENTO ANEXADO — 99% das vezes PDF.** Não é formulário no sistema | 🟢 **destravado e barato** — vira `DocumentType` novo + upload, não módulo |
| **FRG-06** | Checklist FM 7.1.1 → **ocultar** da empresa. **Comentários JÁ têm segregação** — minha dúvida era infundada (ver correção abaixo) | 🟢 destravado |
| **FRG-08** | **Não apresentar o prazo de auditoria na visão do cliente** — nem depois, na proposta. "Para evitar desentendimentos" | 🟢 destravado — esconder p/ `empresa`, não só no wizard |
| **FRG-09** | **A empresa preenche o valor do TURNO COM MAIOR NÚMERO de funcionários envolvidos no processo de produção Halal** | 🟢 **destravado** — resolve a ambiguidade por-turno×total |

**Decisões que eu tomo aqui (não precisam de você; vetar se discordar):**
- **FRG-03** — para "Perigo Haram" (coluna + modal) vou usar **"Perigo à integridade Halal"**. A troca
  literal "Perigo Halal" ficaria semanticamente errada (o perigo não é halal — ele *ameaça* o halal). Se o
  DT 7.3 Anexo 1 tiver termo próprio, ele manda.
- **FRG-06** — `DocumentRequirementsPanel` **fica visível** à empresa: é a lista do que ela precisa entregar,
  serve exatamente a ela.
- **FRG-05** — como Matriz e HAS entram como anexo, a tela estruturada `PcchMatrixView` **continua sendo
  instrumento do analista**, não do cliente. Isso **não dispensa o FRG-07**: a API segue aberta e precisa de
  `@Roles` + recorte de qualquer forma.

---

### ⚠️ CORREÇÃO — FRG-06/CommentsSection: eu marquei errado

Registrei "comentários sem gate" e o Renato apontou que a segregação existe. **Ele está certo.** O que vi
foi a ausência de prop no JSX (`<CommentsSection certificationId={id} />`); a segregação é **server-side**, e
é por isso que não aparecia ali:

`comment.controller.ts:118-121` → `shouldIncludeInternal = ... (includeInternal === undefined && req.user.role !== 'empresa')`
→ `comment.service.ts:170-172` → `where.isInternal = false`.

⇒ para `empresa`, comentário interno **é excluído no banco**, por padrão. Nada a fazer. *(Lição: "sem prop
de gate no JSX" não é evidência de "sem controle de acesso" — o controle pode estar no servidor, que é o
lugar certo. Devia ter checado o módulo antes de perguntar.)*

🚨 **MAS a verificação rendeu um achado real — FRG-10, abaixo:** o padrão seguro é o **default**, e ele é
**contornável por query param**.

---

### FRG-10 · 🚨 Segregação de comentários internos contornável por query param (achado meu)

`comment.controller.ts:118-121`:

```
shouldIncludeInternal =
  includeInternal === 'true' ||                                  // ← vence SEMPRE, sem checar papel
  (includeInternal === undefined && req?.user?.role !== 'empresa') // ← default seguro
```

O default protege, mas o **override não valida papel**. ⇒ `GET /comments/certification/:id?includeInternal=true`
com token de **`empresa`** devolve **os comentários internos** da certificação. A UI nunca manda o param —
logo não há sintoma na tela, e ninguém veria isso navegando.

**5ª ocorrência do padrão do §4.2/09/ago** (`/certifications/statistics`, `/certifications/company/:id`,
`GET /audits`, FRG-07/pcch) — e a 2ª em que o furo é **parâmetro controlado pelo cliente sobrepondo
restrição de papel**. Fix: ignorar `includeInternal=true` quando `role === 'empresa'` (o papel decide, não o
query string). ⚠️ Não corrigi — zero código hoje.

💡 Reforça a varredura já sugerida no BACKLOG e ainda não feita — que agora tem **critério novo**: não basta
procurar rota sem `@Roles`; há que procurar **default seguro que o cliente pode desligar**.

---

### FRG-01 · Nomenclatura obrigatória dos documentos anexados

**Quem pediu:** equipe Frigorífico, ao ver a tela de documentos e anexos.

**Pedido, como veio:** os documentos novos devem ser **nomeados de acordo com regras** — presumidamente
as mesmas já aplicadas à numeração de **certificados / certificações** — e **esses nomes serão definidos
na avaliação documental**.

**Como é hoje:** o anexo entra com o **nome do arquivo que o usuário subiu**. O que o sistema controla é o
**tipo** (enum `DocumentType`), não o nome. Não existe padrão de nomenclatura, nem campo de nome editável
pelo analista na análise documental. ⇒ o pedido é **capacidade nova**, não correção.

**O que dá para afirmar com segurança:**
- A numeração de **certificado** é regida por **IT 7.10 + IT 4.2** (sequencial global `SEQQ`, agrupamento
  `.K.` por espécie) — regra madura e travada (§5.9/§5.10 do BACKLOG). **Não é obviamente transponível
  para documento**: certificado numera *documento emitido pela FAMBRAS*; aqui o objeto é *documento
  recebido da empresa*. Aplicar a mesma máscara sem a FAMBRAS declarar seria inferência.
- Se o nome é **definido na avaliação documental**, então quem nomeia é o **analista**, não a empresa que
  sobe. Isso muda o desenho: o upload da empresa fica com nome provisório e o nome canônico é atribuído
  (ou confirmado) no momento da análise. **É fluxo, não só máscara de string.**

❓ **PERGUNTAR AGORA — enquanto André, Giovanna e William estão na sala** (sem isso não se codifica nada):
1. **Qual é a regra, exatamente?** Pedir **2 ou 3 exemplos reais** de nome de documento como a FAMBRAS
   usa hoje na pasta/planilha. Exemplo é melhor que descrição.
2. **Que partes compõem o nome?** (SIF? CNPJ? nº da certificação? tipo de documento? data? versão?)
   E em que **ordem** e com que **separador**.
3. **Quem nomeia:** a empresa ao subir (com o sistema montando o nome automaticamente) **ou** o analista
   na avaliação documental? Se for o analista, a empresa vê qual nome enquanto isso?
4. **É por documento ou por tipo de documento?** Cada `DocumentType` tem máscara própria?
5. **Vale para o passado?** Os documentos já anexados são renomeados ou a regra só vale para novos?
6. **Renomear é permitido depois?** (se o nome é identidade do documento, renomear conflita com a lógica
   de imutabilidade que já vale para certificado — §5.3)

**Encaminhamento:** ⛔ **não gerar prompt de código ainda.** Falta a regra. Assim que houver os exemplos,
isto vira lote pequeno (nome derivado no upload + campo no fluxo de análise documental). ⚠️ **Ponto de
atenção de trilha:** mexe em `documents/*` — **não** é Trilha A nem C; verificar dono no §2 do BACKLOG
antes de codar (o módulo de documentos não tem trilha declarada — mesma classe do "buraco do §2").

⚠️ **Junto disso, conferir W-8** (na mesma tela): `DOCUMENT_TYPE_LABELS` do front lista 3 tipos que **não
existem** no enum do Prisma. Se o time tentar anexar um deles, dá erro — e seria confundido com FRG-01.

---

### FRG-02 · Escopo com marcas, produtos e embalagem nos campos errados (ETL)

**Como veio:** *"dentro de escopo está tudo misturado — marcas, produtos etc.; o ETL de importação não
conseguiu tratar a diferenciação de forma adequada."*

**MEDIDO EM PRODUÇÃO agora** (consulta ao `db_ecohalal_halalsphere`) — o time está certo, e o problema é
maior e mais preciso do que o registrado no §4.3 do BACKLOG (que falava de "30 marcas"):

| Tabela | Total | Sinal medido |
|---|---|---|
| `scope_products` | **18.511** | 🔴 **17.391 sem `packing_size` (94%)** · **9.277 sem `code` (50%)** · 49 com nome iniciando em número · 4 com nome **sem nenhuma letra** (código puro) |
| `scope_brands` | **2.690** | marcas que são **embalagem**, **produto** ou **lista multi-valor** |

**A prova de que é mapeamento de coluna, não sujeira aleatória** — os dois sintomas são o mesmo defeito
visto dos dois lados:

- `packing_size` está **vazio em 94% dos produtos**… e a descrição de embalagem está **no campo de marca**:
  `"Drum / Bulk, Ibc / Bag in Box / Isotank / Flexitank"` · `"Packaging made of Raffia or Kraft Paper or
  Laminated Technical Film (flexible packaging)"` · `"IBC, Drum, Bulk"` · `"400, 800 grs tins"` ·
  `"Polyethylene Bags,"` · `"Pails, Cans"` · `"In bulk, variable weight"`
- …e também **embutida no nome do produto**, com `packing_size` null ao lado:
  `"12mm x 12mm Home Style Cut Fries 6/2.5kg"` · `"10 Grape Pulp Metal drum 190 or 200 kg"` ·
  `"100% Nat Laranja Pera OE #2825 50KG"` · e o extremo `"100G X20UNX10PACEXP"`, que é **só embalagem** no
  lugar do nome
- **produto** no campo de marca: `"Citrato Trissódico Dihidratado / Trisodium Citrate Dihydrate"` ·
  `"Condimento Essencial Para Produtos Cárneos Cozidos Tipo Lanche - HL"`
- **lista de marcas numa linha só** (deveriam ser 3 registros): `"KFC, SEARA AND FRANGOSUL"` ·
  `"Braid, Stick, Provolone"`

**Diagnóstico:** são **3 defeitos distintos**, e separá-los importa porque o dono de cada um é diferente:

| | Defeito | Natureza | Dono |
|---|---|---|---|
| **(a)** | ETL não mapeou embalagem → `packing_size` (94% vazio) | 🐛 **bug do ETL** — coluna existe e não foi preenchida | Claude (script) |
| **(b)** | Campo de marca recebendo produto/embalagem | 🔧 **dado trocado na FONTE** (planilha FM) | FAMBRAS (§4.3, relatório de 12/jul já entregue) |
| **(c)** | Lista multi-valor numa linha ("KFC, SEARA AND FRANGOSUL") | 🐛 ETL não fez split | Claude (script) |

⚠️ **(a) e (c) são nossos e dá para corrigir por reprocessamento** — sem pedir nada à FAMBRAS. **(b) só a
FAMBRAS resolve**, e o relatório de correção na fonte (`RELATORIO-ESCOPO-CORRECAO-FAMBRAS-2026-07-12.xlsx`)
**já está com eles desde 12/jul, sem retorno.** Este achado é o argumento para cobrar.

⚠️ **Atenção ao lote de 04AGO:** a carga de 08/ago trouxe **+353 produtos de escopo** e registrou "0
warnings" — ou seja, **o script não detecta esta classe de problema**. Reprocessar sem antes ensinar o
script a distinguir os campos vai repetir o defeito.

❓ **PERGUNTAR AGORA:** a descrição de embalagem deve aparecer **no certificado**? Se sim, em que campo? (a
decisão 2 de 30/jul mandou preencher embalagem **em inglês** na planilha de escopo — então o dado é
esperado em algum lugar estruturado, não dentro do nome do produto.)

**Encaminhamento:** 🧩 **Trilha B** (normalização de cadastro — `scope_products`/`scope_brands` estão
declarados no domínio dela, §2 do BACKLOG). ⚠️ **Não é lote de go-live automático:** mexer em 18.511
produtos é carga de dados, exige SQL revisado + backup, e a decisão de timing é do Renato.

---

### FRG-03 · "Controle Haram" na Matriz PCCH — termo errado e proibido

**Como veio:** *"o correto para PCCH é **Pontos Críticos de Controle Halal**"* (print: "Matriz PCCH -
Pontos Críticos Controle Haram").

**Duas razões independentes para corrigir, e a segunda é mais séria que a primeira:**
1. Está **tecnicamente errado** segundo quem opera a norma (o time do André, que responde pelo In Natura).
2. 🚨 **Viola a regra absoluta do projeto: nunca usar termos haram em artefato dos sistemas halal** — vale
   para UI, comentário, teste, mock e documentação. Um sistema de certificação halal acreditada **não
   pode** ter a palavra estampada num título de tela.

✅ **A sigla PCCH continua válida** — "Pontos Críticos de Controle **Halal**" preserva o acrônimo. É troca
de rótulo, sem impacto em rota, contrato de API ou dado.

**Extensão real da varredura — 9 ocorrências, não 1:**

| Arquivo | Onde | Texto atual |
|---|---|---|
| `PcchMatrixView.tsx:237` | **título da tela** (o do print) | "Matriz PCCH - Pontos Críticos Controle Haram" |
| `PcchMatrixView.tsx:300` | cabeçalho de coluna | "Perigo Haram" |
| `PcchMatrixView.tsx:464` | título do modal (2×) | "Editar/Adicionar Perigo Haram" |
| `PcchMatrixView.tsx:525` | rótulo de campo | "Ponto Crítico de Controle Haram (PCCH)" |
| `pcch.controller.ts:16` | **tag do Swagger** | "PCCH - Pontos Críticos Controle Haram" |
| `pcch.controller.ts:48,54,60` | `@ApiOperation` | "perigo Haram" |
| `pcch.dto.ts:50,62` | `@ApiProperty` | "Perigo Haram identificado" |
| `app.module.ts:236` · `pcch.service.ts` | comentários | idem |

❓ **PERGUNTAR AGORA — o título eu sei corrigir, os outros 4 rótulos não:** qual é o termo correto para
**"Perigo Haram"** (coluna e modal)? Candidatos: *"Perigo de contaminação"* · *"Perigo à integridade
halal"* · *"Perigo identificado"*. **Não vou inventar terminologia de norma** — peça o termo que a FAMBRAS
usa no DT 7.3 Anexo 1.

🚨 **ACHADO ADICIONAL, não pedido — mais grave, e preciso do seu OK:** existe na UI o rótulo visível
**"Suíno (haram — segregação)"** (`company.types.ts:91-100`), e o valor **`suino_haram` é um enum do
Prisma** (`schema.prisma:681`, espécie da planta). Ou seja: a palavra proibida está **no banco e na tela**.
A regra do projeto manda mencionar **apenas obliquamente** ("espécie não-halal", "linha segregada"), nunca
nomeando. ⚠️ **Diferente do PCCH, este não é troca de rótulo:** enum do Prisma exige **migration** e o
valor pode estar gravado em plantas — é lote próprio, com cuidado. **Decisão sua se entra antes do
go-live.** Registro aqui porque a regra manda sinalizar toda menção herdada, não deixar passar.

**Encaminhamento:** o rótulo PCCH é 🎨 lote pequeno e seguro (só strings). ⚠️ Toca `pcch/*` — **módulo sem
trilha declarada** no §2; mesma classe do "buraco do §2". Declarar dono antes de codar.

---

### FRG-04 · Emissão e validade exibindo 1 dia antes (UTC) — investigado até a raiz

**Como veio:** card do certificado `MIN.PGS.2602.1428.2.BRA` mostra **Emitido 31/05/2026 / Expira
06/07/2029**; a planilha oficial diz **01/06/2026 / 07/07/2029**. Exatamente **−1 dia** nas duas.

✅ **PERGUNTA CRÍTICA RESPONDIDA: o dado e o documento estão CORRETOS. O defeito é só de exibição.**
Isso muda tudo — não há certificado emitido com data errada, logo **não há problema de imutabilidade
(§5.3) e nenhum certificado precisa ser reemitido.**

**As 3 camadas, verificadas uma a uma:**

| Camada | Estado | Prova |
|---|---|---|
| **Banco** | ✅ **CORRETO** | `issued_at = 2026-06-01 00:00:00` · `expires_at = 2029-07-07 00:00:00` — exatamente o FM. E é consistente: **todos os 1.433 certificados** têm hora `00:00:00`, zero exceção ⇒ **nenhuma corrupção na carga** |
| **PDF** | ✅ **CORRETO** | `formatDateEN` (`pdf-utils.ts:78-80`) usa `getUTCDate/getUTCMonth/getUTCFullYear` — UTC explícito. Os **4 renderers** passam por ela |
| **Tela** | 🐛 **ERRADO** | `formatDate` em `CertificationDetails.tsx:409-416` chama `toLocaleDateString('pt-BR')` **sem `timeZone: 'UTC'`** ⇒ meia-noite UTC vira 21h do dia anterior no fuso do Brasil (UTC−3) |

**Causa-raiz:** datas de certificado são **date-only** (meia-noite UTC). Renderizar date-only no fuso local
sempre volta 1 dia para quem está a oeste de Greenwich. A decisão **§5.6 do BACKLOG já manda "datas
date-only = UTC"** — a regra existe, o código a aplica **de forma desigual**.

**Alcance medido no front:** **94 chamadas** de `toLocaleDateString`; apenas **~9 passam `timeZone: 'UTC'`**,
concentradas em 7 arquivos (`ManualCertificateEmission`, `CertificateList`, `VerifyCertificate`,
`Certificate`, `CompanyCertificationCard`, `MaterialItemsSection`, `RawMaterialMasterForm`). ⇒ o padrão
correto existe e está documentado no próprio código; **a maioria das telas ficou fora**.

⚠️ **O conserto NÃO é varredura cega de "põe UTC em tudo".** Há dois tipos de campo e a regra é oposta:
- **date-only** (`issuedAt`, `expiresAt`, `validFrom`, `validUntil`, `certifiedSince`, `cycleDate`,
  `validityDate`) → **renderizar em UTC**;
- **timestamp real** (`createdAt`, `updatedAt`, `addedAt`) → **renderizar em fuso local**, que é o certo
  para "quando isso aconteceu".

Forçar UTC nos timestamps trocaria um erro de 1 dia por um erro de 3 horas. ⇒ o lote precisa **classificar
campo por campo**, e o caminho limpo é um helper único (`formatDateOnly` × `formatDateTime`) em vez de 94
chamadas soltas.

✅ **Boa notícia sobre o alcance:** a tela pública de verificação por QR (`VerifyCertificate.tsx`) **já usa
UTC** — o consumidor final e o acreditador nunca viram data errada.

**Encaminhamento:** 🐛 lote de front bem delimitado, **cabe antes do go-live**. ⚠️ Toca
`CertificationDetails.tsx` (**Trilha C**) e arquivos de várias telas — coordenar pelo §2 do BACKLOG.
🔧 **1 verificação a fazer junto:** confirmar o fuso do container ECS do GC — se a API serializar em fuso
diferente de UTC, o helper precisa saber (com ECS em UTC, que é o padrão, o helper resolve sozinho).

---

### FRG-05 · Cliente precisa poder ENVIAR a Matriz PCCH e o HAS

**Como veio:** *"cliente deve ter acesso a enviar a Matriz e HAS"* (print: "Nenhuma matriz PCCH criada para
esta certificação", sem nenhum botão de ação no perfil `empresa`).

**São dois pedidos com maturidade bem diferente — e é importante não tratá-los como um só:**

**(a) Matriz PCCH — o caminho quase existe.** O módulo está completo no backend (criar matriz, adicionar/
editar/remover perigo, clonar versão) e a tela existe. O que impede é o front, que passa
`readOnly={user?.role === 'empresa'}` (`CertificationDetails.tsx:1120`) ⇒ a empresa vê a matriz e **nunca
recebe botão de criar**. ✅ **Habilitar é lote pequeno** — mas **não** basta trocar a flag: ver FRG-07, a
API está desprotegida e precisa ganhar recorte no mesmo lote.

**(b) HAS (Halal Assurance System / DT 7.3) — o caminho NÃO existe.** O módulo `has-review` no backend é,
como o nome diz, de **revisão**: `POST /has-reviews` é restrito a `admin`/`analista`/`qualidade` e serve
para a FAMBRAS registrar a análise documental + verificação in loco. **Não há rota de submissão pelo
cliente.** E não há onde anexar: o enum `DocumentType` do Prisma tem **15 valores e nenhum é HAS** (nem
matriz PCCH) — `contrato_social`, `certidao_negativa`, `alvara_funcionamento`, `laudo_tecnico`,
`licenca_sanitaria`, `fotos`, `videos`, `laudos`, `manual_bpf`, `fluxograma_processo`,
`lista_fornecedores`, `certificado_ingredientes`, `analise_produto`, `rotulo_produto`, `outros`.
⇒ hoje o HAS só entraria como **`outros`**, sem identidade própria. **É GAP de verdade, não permissão.**

❓ **PERGUNTAR AGORA:**
1. O HAS é **um documento anexado** (PDF que a empresa sobe) ou **um formulário preenchido no sistema**?
   A resposta muda completamente o tamanho: anexo = novo `DocumentType` + upload (pequeno); formulário =
   módulo novo (grande, provavelmente pós-go-live).
2. A empresa **preenche a matriz PCCH no sistema** (linha por linha, como a tela já permite) ou **anexa a
   matriz dela** em planilha? Idem — muda o desenho.
3. Depois de enviado, quem **aprova**? O envio do cliente entra como rascunho aguardando o analista, ou
   vale de imediato? (se há aprovação, conecta com o fluxo F2 rascunho→aprovar já existente)
4. A empresa pode **editar depois** que o analista revisou, ou congela?

**Encaminhamento:** ⛔ **não gerar prompt ainda** — a pergunta 1 decide se isto é lote de 1 dia ou de 1
semana, e **isso é decisão de escopo de go-live**. ⚠️ (a) e FRG-07 devem sair **no mesmo lote** — abrir
escrita a `empresa` numa API sem recorte seria transformar um risco latente em porta aberta.

---

### FRG-06 · Empresa não deve ver o Check List de Processo (FM 7.1.1)

**Como veio:** *"empresa não deve ver o checklist de processo"* (print: "Check List de Processo (FM 7.1.1)",
0/9 respondidos, visível no perfil `empresa`).

**O time está certo, e a razão é mais forte do que preferência de tela:** o componente chama-se
`CommitteeChecklistPanel` — é o instrumento do **comitê de certificação**, controle interno da FAMBRAS
sobre o próprio processo decisório. Cliente enxergando o checklist do comitê que julga o caso dele é
questão de **imparcialidade/confidencialidade (ISO 17065)**, não só de usabilidade.

**Como está hoje:** `CommitteeChecklistPanel readOnly={user?.role === 'empresa'}`
(`CertificationDetails.tsx:1129`). Alguém decidiu **"empresa vê mas não edita"**; a FAMBRAS agora declara
**"empresa não vê"**. ✅ Fix trivial: render condicional em vez de `readOnly` — o padrão **já existe na
mesma tela**, uma linha acima (`LabAnalysisPanel`, linha 1123, usa `user?.role !== 'empresa' &&`).

🔎 **Achado de contexto que vale mais que o item — a tela tem 3 tratamentos diferentes e ninguém declarou
qual é o certo para cada painel.** Levantei todos, e isto é uma **matriz para preencher com o time agora**:

| Painel no detalhe da certificação | Tratamento hoje p/ `empresa` | Correto? |
|---|---|---|
| `LabAnalysisPanel` (análises de laboratório) | 🚫 **oculto** | ⬜ confirmar |
| `CommitteeChecklistPanel` (FM 7.1.1) | 👁️ visível read-only | ❌ **deve ocultar** (FRG-06) |
| `PcchMatrixView` (Matriz PCCH) | 👁️ visível read-only | ❌ **deve permitir enviar** (FRG-05) |
| `DocumentRequirementsPanel` (documentos exigidos) | 👁️ visível, **sem gate** | ⬜ confirmar |
| `CommentsSection` (comentários) | 👁️ visível, **sem gate** | ⬜ confirmar — *comentário interno do analista aparece para o cliente?* |

❓ **PERGUNTAR AGORA:** os dois últimos. Especialmente **`CommentsSection`** — se analistas usam
comentários para tratar o caso entre si, o cliente estar lendo é vazamento do mesmo tipo do FM 7.1.1, e
ninguém apontou porque provavelmente ainda não há comentário gravado nesta certificação.

**Encaminhamento:** 🎨 lote pequeno, cabe antes do go-live. Fechar a matriz acima **antes de codar**, para
resolver os 5 painéis num lote em vez de um por dia de presencial.

---

### FRG-07 · 🚨 API do PCCH sem `@Roles` e sem recorte por empresa (achado meu, não foi pedido)

**Não veio da sala** — encontrei ao verificar o FRG-05, e é a **4ª ocorrência** de um padrão que o BACKLOG
já nomeou em 09/ago: *rota liberada a um perfil sem o recorte correspondente* (antes:
`/certifications/statistics`, `/certifications/company/:id`, `GET /audits`).

**Medido:**
- `pcch.controller.ts` — `@UseGuards(JwtAuthGuard)` no controller e **nenhum `@Roles` em nenhuma das 8
  rotas**, incluindo as de escrita: `POST /pcch-matrices`, `POST /pcch-matrices/:id/hazards`,
  `PUT /pcch-hazards/:hazardId`, `DELETE /pcch-hazards/:hazardId`, `POST .../pcch/clone`.
- `pcch.service.ts` — **zero** menção a `companyId`, `userId` ou `plantId`. Não há recorte de tenant.

⇒ **qualquer usuário autenticado** — inclusive `empresa` e `auditor` — pode **criar, editar e apagar**
matriz e perigos **de qualquer certificação, de qualquer empresa**, chamando a API direto. A única barreira
hoje é o `readOnly` do front, ou seja **defesa só de UI** — que não é defesa: basta a requisição.

⚠️ **Diferença importante em relação aos 3 casos anteriores:** aqueles eram **leitura** vazando. Este é
**escrita cross-tenant** — apagar o perigo halal da matriz de um concorrente. Severidade maior.

✅ **E converge com o FRG-05:** o conserto não é "bloquear a empresa", é **`@Roles` + recorte por
certificação da própria empresa**. Feito isso, o pedido do time (cliente envia a matriz) fica atendido
**com** segurança. Um lote resolve os dois.

⚠️ **Não corrigi nada** (§0.1 desta sessão: zero código hoje). ⚠️ Módulo `pcch/*` **não tem trilha
declarada** no §2 do BACKLOG — mesma classe do "buraco do §2"; declarar dono antes de codar.

💡 **Vale a varredura já sugerida no BACKLOG (09/ago) e ainda não feita:** procurar **todos** os
controllers sem `@Roles` ou com perfil escopável sem filtro no service. Este achado é a evidência de que a
sugestão não era teórica — 4 casos em 2 semanas, e o pior deles é de escrita.

---

### FRG-08 · Prazo de auditoria não deve aparecer no fluxo do cliente

**Como veio:** *"num fluxo certificação, não mostrar o prazo de auditoria"* (print: badges "1.5d auditoria"
no CIV e "2d auditoria" no CV, na escolha de categorias).

**Localizado:** `IndustrialClassificationStep.tsx:387-389` — badge `{category.auditDays}d auditoria`, **sem
nenhum gate de papel**. O componente é usado **só** pelo `CertificationWizard` (o fluxo de solicitação de
11 etapas), logo aparece para a empresa ao pedir certificação.

**Por que o time está certo, e é mais que estética:** dias de auditoria são **insumo de precificação** — há
um módulo dedicado (`audit-days`, com calculadora e justificativa de redução). Expor o prazo na hora em que
o cliente **escolhe as categorias** entrega a régua de custo **antes da proposta comercial** e convida a
escolher categoria por preço, não por atividade real. Some-se a isso a decisão já travada de que **preço
fica fora do sistema** (política comercial manual): o número que puxa o preço não deveria vazar pela tela.

⚠️ **Não é remover o badge, é condicionar** — o mesmo wizard é usado pelo staff, e para o analista o prazo
é informação legítima de planejamento. Fix: esconder quando `user?.role === 'empresa'`, mesmo padrão do
`LabAnalysisPanel`.

❓ **PERGUNTAR AGORA:** o prazo pode aparecer para a empresa **depois** (na proposta/contrato já assinados,
onde ela vai receber o auditor por 2 dias e precisa se organizar), ou **nunca** na visão do cliente? Muda
se é "esconder no wizard" ou "esconder em toda a visão empresa".

**Encaminhamento:** 🎨 uma linha. **Juntar no mesmo lote de FRG-06** — são o mesmo problema (informação
interna da FAMBRAS visível ao cliente) e tocam a decisão de "o que o perfil `empresa` enxerga".

---

### FRG-09 · "Número de Funcionários" sem a definição do FM — e o campo alimenta o cálculo de dias de auditoria

**Como veio:** *"tem que deixar claro que número de funcionários é o que está descrito na imagem"* — o FM
define: **"Contemplar somente os funcionários envolvidos no processo de fabricação/controle/armazenamento e
gestão do produto/serviço Halal (setores administrativo e operacional Halal)."**

**O pedido literal é trivial:** falta o texto de apoio embaixo do rótulo em
`CertificationWizard.tsx:560`. O padrão já existe no mesmo bloco — "Variedade de Produtos" tem
*"Baseada na quantidade de linhas de produção"*. ⚠️ **Aplicar nos dois lugares:** o campo se repete em
`ProposalCalculator.tsx:184` (lado do analista), também sem definição.

🚨 **Mas isto não é cosmético — rastreei para onde o número vai, e ele decide o dia de auditoria:**

`numEmployees` → `audit-days-calculator.service.ts:82-85` → seleciona a faixa de FTE
(`fteRangeMin <= numEmployees <= fteRangeMax`) da tabela **GSO 2055-2** → devolve `FTE_HD`, uma das quatro
parcelas de **`Total_HD = TD + TH + TMS + FTE_HD`**.

⇒ **número errado = faixa de FTE errada = dias de auditoria errados = proposta errada.** A definição
ausente não é rótulo faltando: é a porta pela qual entra dado que **muda o preço e a duração da auditoria**.
No print o valor é **800** — para um frigorífico, o total da planta e o "envolvido no processo Halal" podem
cair em **faixas de FTE diferentes**, e o sistema não tem como saber qual dos dois o cliente digitou.

🔴 **AMBIGUIDADE ADICIONAL que o próprio print do FM levanta, e que ninguém mencionou:** o cabeçalho do FM
diz **"Número de funcionários POR TURNO"**. O formulário tem **dois campos separados** — "Número de
Funcionários" (800) e "Número de Turnos" (2). Então:

> **800 é por turno (⇒ 1.600 no total) ou é o total dos 2 turnos (⇒ 400 por turno)?**

A calculadora consome **um** número e não sabe a diferença. Se o FM manda "por turno" e o cliente digita o
total, a faixa de FTE erra por um fator de ~2×. **Dois clientes vão responder diferente** enquanto o campo
não disser qual dos dois quer — e um deles vai receber auditoria dimensionada errado.

❓ **PERGUNTAR AGORA — a pergunta que decide, e só o time do André responde:**
1. **O número é POR TURNO ou o TOTAL?** Se for por turno, o rótulo tem de dizer, e há de conferir se a
   fórmula GSO 2055-2 espera por-turno ou total (é a tabela deles que define a faixa).
2. A definição Halal vale **igual** para frigorífico (In Natura)? Em abate praticamente toda a planta está
   no processo Halal — a restrição "setores Halal" é mais discriminante em industrializados.
3. Os **800** desta planta já foram digitados sob qual entendimento? Se a base já tem valores com critérios
   distintos, é 🔧 **dado a revisar**, não só rótulo a corrigir.

**Encaminhamento:** o texto de apoio é 🎨 lote de minutos (**2 arquivos**) e pode ir com P1. ⛔ **A
ambiguidade por-turno NÃO se resolve no código** — precisa da resposta da 1. Enquanto ela não vier, corrigir
só o rótulo pode **piorar**: um texto de apoio afirmando o critério errado é pior que texto nenhum, porque
passa a induzir o preenchimento errado com autoridade.

---

### FRG-11 · Outras certificações (ISO/FSSC) — anexo comprobatório obrigatório

**Como veio:** *"se a empresa possui outras certificações, é obrigatório anexar o documento
comprobatório."*

**Como é hoje:** `CertificationWizard.tsx:675-685` — checkbox `hasOtherCertifications` + **campo de texto
livre** `otherCertifications` ("Ex: ISO 22000, FSSC 22000"). **Nenhum anexo, nenhuma obrigatoriedade.** A
empresa declara e ninguém comprova.

🔎 **Por que isso não é burocracia — rastreei, e o anexo é evidência de algo que muda o preço:** o
`audit-days-calculator.service.ts:42-51` tem mecanismo de **redução de dias de auditoria**, limitada a
**30%**, que **exige justificativa** (`if (!input.reductionJustification) throw`). Ter ISO/FSSC é
justamente o fundamento típico dessa redução — sistema de gestão já auditado por terceira parte.

⚠️ **E hoje as duas pontas não se falam:** `hasOtherCertifications` (declaração do cliente) **não alimenta**
`reductionPercent` (entrada manual da calculadora). Ou seja: alguém concede até 30% de redução com base numa
**declaração em texto livre, sem documento no processo**. Para um organismo acreditado, redução sem
evidência arquivada é **achado de auditoria (ISO 17065)** — e explica exatamente por que a FAMBRAS quer o
anexo obrigatório.

**Encaminhamento:** 🟢 **decidido e pronto.** Vai junto com FRG-05 — é o mesmo mecanismo (`DocumentType`
novo + upload obrigatório condicionado ao checkbox). ⚠️ Ligar `hasOtherCertifications` → `reductionPercent`
é **escopo maior e não foi pedido** — registro como observação, não faço.

---

### FRG-12 · 🚨 Nova certificação herda o escopo da certificação existente

**Como veio:** iniciando o fluxo de nova certificação **a partir de uma empresa que já tem certificação**,
vem tudo pré-carregado. **Correto:** só os dados da **empresa** são pré-carregados; todo o resto —
**principalmente escopo** — nasce vazio e tem de ser preenchido.

**CAUSA-RAIZ ISOLADA** — `CertificationWizard.tsx:173-189`. O pré-preenchimento está amarrado à
**existência** de `existingCertification`, **não ao tipo de solicitação**:

```
requestType:  existingCertification ? RequestType.renovacao : RequestType.nova,
products:     existingCertification?.scope?.products   || [],
facilities:   existingCertification?.scope?.facilities || [],
brands:       existingCertification?.scope?.brands     || [],
productionCapacity / numEmployees / numShifts / certificationType: idem
```

E o elo que fecha o defeito: **`handleRequestTypeChange` (linha 359) só troca o `requestType` — não limpa
nada.**

```
const handleRequestTypeChange = (type) => setWizardData(prev => ({ ...prev, requestType: type }));
```

⇒ **sequência exata do que o time viu:** entrar pela empresa certificada → o wizard **assume `renovacao`** e
hidrata o escopo inteiro → o usuário marca **"Nova"** no passo 1 → o tipo muda, **o escopo herdado
permanece**. Não é pré-carga "de propósito para nova": é pré-carga de renovação que **sobrevive à troca de
tipo**.

🚨 **Por que é integridade, não conveniência:** o escopo é o que a certificação **atesta**. Escopo herdado
em silêncio significa **certificar produto/marca que não foi solicitado nem auditado** neste ciclo — e o
usuário não vê nada de errado, porque a tela chega preenchida e plausível. É o pior tipo de defeito:
**falha silenciosa que produz documento válido com conteúdo errado** (ISO 17065).

⚠️ **Agrava por dois caminhos já registrados hoje:**
- `numEmployees`/`numShifts` também são herdados — e eles **alimentam a fórmula de dias de auditoria**
  (FRG-09/FRG-11). Nova certificação herdando o efetivo antigo = **dias de auditoria dimensionados sobre
  dado da certificação anterior**.
- há restauração de rascunho do `localStorage` (linha 278, `setWizardData(restored)`) — quem corrigir
  **precisa cobrir esse caminho também**, senão o escopo herdado volta pelo rascunho salvo.

**Fix (sem quebrar os outros modos):** limpar escopo + produção + `certificationType` +
`existingCertificationId` **quando `requestType === nova`**, no `handleRequestTypeChange` **e** na
inicialização. **Preservar** os dados da empresa (legítimos e reutilizáveis).
- **Renovação:** mantém o escopo — o passo 2 chama-se *"Confirmação de Escopo"*, é o desenho correto.
- ⚠️ **Ampliação provavelmente tem o MESMO defeito, em outra roupagem:** os passos são *"Novos Produtos"* /
  *"Novas Instalações"*, mas os campos chegam com o escopo **antigo** — o usuário tende a ler o herdado como
  se fosse o novo. **Verificar no mesmo lote** (observação minha, não foi apontado na sala).

**Encaminhamento:** 🟢 **pronto para codar**, sem depender de ninguém. **Prioridade máxima da fila** — é o
único achado de hoje que produz **documento errado sem sintoma visível**.

---

### FRG-13 · Logo da marca precisa aceitar upload, não só URL

**Como veio:** *"aqui precisa deixar cliente fazer o upload da imagem da logo, não só URL."*

**Como é hoje:** `ScopeBrandsManager.tsx:130-132` — "URL do Logo" é um **input de texto** (`https://…`),
gravado em `scope_brands.logo_url` e renderizado direto como `<img src={brand.logoUrl}>` (linha 216-218).
⇒ o cliente tem de hospedar a imagem em algum lugar e colar o link. Na prática, **ninguém faz isso** — é por
isso que o campo chega vazio.

✅ **Barato: a infraestrutura de upload já existe e é reaproveitável.** Há `FileInterceptor` +
`@UploadedFile` em pelo menos 4 controllers (`document`, `corporate-document`, `certificate` (pdf-upload),
`company-import`), com S3 e URL presigned já em produção. É adicionar rota de upload de logo e trocar o
input por seletor de arquivo — **sem migration**, porque a coluna `logo_url` continua guardando um endereço,
só que agora **nosso**, no S3.

🔎 **Argumento que reforça o pedido, além da conveniência:** URL externa é **conteúdo que muda ou desaparece
sem aviso**. O logo faz parte do registro de escopo de uma certificação — se o link do cliente cair ou for
trocado, o registro perde (ou altera) evidência **fora do controle da FAMBRAS**. Isso conversa direto com o
princípio já travado no projeto de que evidência de certificado não muda (§5.3). Guardar o arquivo é o certo;
apontar para fora é frágil por natureza.

**Encaminhamento:** 🟢 pronto para codar. ⚠️ **`ScopeBrandsManager.tsx` NÃO está declarado em nenhuma trilha
do §2** — é vizinho do `ScopeEditor.tsx` (Trilha C) e não está na lista dela. **3º módulo sem dono
encontrado hoje** (`pcch/*`, `documents/*`, e este) — o "buraco do §2" é maior do que o registrado.

---

### FRG-14 · Países de Destino — falta o texto do FM e o aviso sobre o Irã

**Como veio:** *"precisa mostrar o texto da imagem… e tb informar que a FAMBRAS não realiza certificação
para o Irã."* Texto do FM: **"Observação: Para exportação ao Egito, Irã e Turquia, por favor, entre em
contato com a FAMBRAS HALAL para consulta."** + no item Turquia: **"(consultar condições específicas)"**.

**Como está hoje:** `TargetMarketsStep.tsx` lista os países como cartões selecionáveis. **Nenhum aviso** —
nem a observação geral, nem a marca da Turquia.

⚠️ **Atenção a uma diferença entre o FM e a regra real, que muda a implementação:** o FM trata os três países
igual ("consultar"). Você declarou que **Irã é diferente — a FAMBRAS não certifica**. Então não são 3 avisos
iguais: são **2 níveis**.

| País | Regra | Tratamento na tela |
|---|---|---|
| Egito, Turquia | consultar a FAMBRAS | selecionável **com aviso** (+ Turquia leva "consultar condições específicas") |
| **Irã** | **FAMBRAS NÃO certifica** | **bloquear com explicação** — não é consulta |

🔎 **E aqui está o detalhe que faz o aviso ser necessário, não decorativo:** o **Irã não está na lista** de
países do step (conferi — só há `EG` Egito e `TR` Turquia entre os três). Alguém poderia concluir que a regra
já está garantida pela omissão. **Não está:** o step tem **"🌐 Outros (especificar)"** com campo de texto
livre (`TargetMarketsStep.tsx:198-220`) — o cliente digita "Irã" e o sistema aceita sem dizer nada.
⇒ **o bloqueio precisa cobrir o caminho do texto livre**, não só a lista.

**Decisão que tomo (vetar se discordar):** manter o Irã **fora** da lista de cartões (como está) e validar o
campo "Outros" contra ele, exibindo a mensagem "A FAMBRAS Halal não realiza certificação para este país".
Mostrar a observação do FM **fixa no passo**, não só em tooltip — é texto normativo, o cliente tem de ler
sem precisar procurar.

**Encaminhamento:** 🟢 pronto para codar. ⚠️ Mesmo arquivo do wizard? **Não** — `TargetMarketsStep.tsx` é
componente próprio, então não colide com o P0 (`CertificationWizard.tsx`). Pode ir em paralelo.

---

### FRG-15 · 🚨 País de destino provavelmente nunca é gravado (achado meu)

**Não veio da sala** — encontrei ao procurar onde escrever o aviso do FRG-14, e é sério porque o mercado de
destino **decide quais normas saem no certificado** (`certification_standards_by_market`, a matriz FM 4.1.X).

**Dois problemas, um de código e um de evidência:**

**(1) Formatos incompatíveis entre front e back.**

| Camada | Formato |
|---|---|
| Front (`CertificationWizard.tsx:190`) | **objeto**: `{ exporta: false, paises: [], principal: '' }` |
| DTO (`create-form-data.dto.ts:160`) | **array**: `targetMarkets?: string[]` |
| Quem grava (`certification-form-data.service.ts:65,146`) | grava o que vier na coluna `Json?` |
| Quem lê (`fambras-pdf.service.ts:189`) | `const markets = formData?.targetMarkets as string[]` — **lê como array** |

⇒ o front manda `{exporta, paises, principal}` onde o contrato pede `["AE","SA"]`. Ou a requisição **falha na
validação** (o GC roda `ValidationPipe` com `forbidNonWhitelisted`), ou o objeto entra na coluna JSON e o
**PDF do FM lê a estrutura errada** — e nenhum dos dois é o comportamento pretendido.

**(2) Não há como confirmar por dado: a tabela está vazia em produção.** Consultei
`certification_form_data` — **0 linhas**, zero com `target_markets`. ⇒ **nenhuma solicitação já percorreu esse
caminho em prod**, o que é coerente com o acervo ter entrado por espelhamento (não pelo wizard) e com o aviso
do BACKLOG de que **ninguém testou o fluxo**. ⚠️ Ou seja: **é impossível dizer "funciona" sobre país de
destino — não existe um único registro para provar.**

📌 **Corrige a memória do projeto:** havia a nota "`TargetMarketsStep` nunca persistiu — campo não existe no
Prisma". **Desatualizada:** a coluna **existe** (`certification_form_data.target_markets`, `Json?`, GAP-01) e
o serviço a grava. O problema não é ausência de campo, é **incompatibilidade de formato** — diagnóstico
diferente, conserto diferente.

**Encaminhamento:** 🧩 alinhar o formato (decidir se a coluna guarda o objeto inteiro ou só o array de
códigos ISO, e ajustar as 3 pontas: front, DTO e leitor do PDF). ⚠️ **Depende de uma decisão de modelo**, não
é fix mecânico — e como não há dado em prod, **a validação tem de ser um teste funcional ponta a ponta**
(solicitar com países → conferir a linha no banco → gerar o PDF do FM).

---

### FRG-16 · 🧩 A calculadora de dias de auditoria existe, autoriza o comercial — e nenhuma tela a usa

**Como veio:** *"como comercial, precisa ter mais dados para montar uma proposta adequada… ele não consegue
ver a sugestão de dias de auditoria… isso porque a proposta comercial toma como base a quantidade de dias de
auditoria."*

**Investiguei as 3 camadas, e o gargalo não é onde se imaginaria — não é permissão:**

| Camada | Estado |
|---|---|
| **Backend — fórmula** | ✅ **COMPLETA.** `GET /audit-days/calculate` implementa a GSO 2055-2: `Total_HD = TD + TH + TMS + FTE_HD`, com multiplicador por tipo de solicitação, **filial = 0,5×**, redução limitada a 30% (com justificativa obrigatória), arredondamento a meio dia e **divisão Etapa 1 (30%) / Etapa 2 (70%)** |
| **Backend — permissão** | ✅ **JÁ LIBERA O COMERCIAL:** `@Roles('analista','gestor','admin','comercial','gestor_auditoria')` |
| **Front** | ❌ **NINGUÉM CHAMA.** Varri o front inteiro: **zero** referência a `/audit-days/calculate`. O único número de auditoria exibido em qualquer tela é o `auditDays` **por categoria** (`/industrial-classification/categories/:code/audit-days`) — a badge "1.5d auditoria" do FRG-08 |

⇒ **a "sugestão de dias de auditoria" não está escondida do comercial: ela não existe em tela nenhuma.** A
fórmula está implementada, testada e autorizada, e **nenhum consumidor foi construído**. É o padrão que o
BACKLOG nomeou em 09/ago — *"menus/telas montados por BAIXO do que o backend já permite"* — na sua versão
mais extrema: não é um item de menu faltando, é uma **capacidade inteira sem porta de entrada**.

🔎 **E há um segundo gargalo, de acesso:** o `ProposalCalculator` (único componente de cálculo de proposta)
é usado **apenas** em `pages/analyst/ProcessProposal.tsx` — página do **analista**. O comercial tem
`/comercial/propostas` e `/comercial/configuracoes` no menu, mas o cálculo vive do lado do analista. E o
próprio `ProposalCalculator` **não chama** `audit-days` — ele pede `numEmployees` e **não usa** a fórmula.

⇒ hoje a proposta é montada **sem** a fórmula GSO 2055-2, com o número de dias vindo de fora do sistema.
Exatamente o que o comercial relatou, e a causa é estrutural, não de permissão.

⚠️ **Relação com o FRG-08 — mesmo número, audiências opostas. Não é contradição, é a regra:**

| Quem | Vê dias de auditoria? |
|---|---|
| `empresa` | ❌ **não** (FRG-08 — decidido hoje: nem na proposta) |
| `comercial`, `analista`, `gestor` | ✅ **sim, e com o detalhamento** (FRG-16) |

⇒ os dois lotes **devem sair juntos ou em sequência imediata**, para não deixar o sistema num estado
intermediário onde o número está escondido de todos.

**O que o comercial precisa ver (derivado do que a fórmula já devolve — nada a inventar):** `Total_HD`
final · a **quebra** `TD / TH / TMS / FTE_HD` · **Etapa 1 e Etapa 2** em dias · multiplicadores aplicados
(tipo de solicitação, filial 0,5×) · **redução aplicada com a justificativa**.

**Encaminhamento:** 🔴 **o maior lote do dia** — é construção de tela, não ajuste. Precisa de decisão sua
sobre **onde** entra (dentro de `/comercial/propostas`? no `ProposalCalculator` acessível ao comercial?) e
se **cabe antes do go-live**. ⚠️ Sem isso, a proposta comercial continua sendo feita fora do sistema — o
que é operacionalmente viável (é o que fazem hoje), mas mantém a fórmula acreditada sem uso.

---

### FRG-17 · "Quantidade APPCC" é obrigatório, sem definição — e não afeta o cálculo

**Como veio:** junto com o FRG-16 — *"APPCC tb não está claro"*.

**Dois problemas distintos no mesmo campo** (`CertificationWizard`, "Quantidade APPCC - Análise de Perigos e
Pontos de Controle", marcado `*`):

**(1) Falta a definição** — mesmo caso do FRG-09. O que se conta: **planos** APPCC? **estudos**? um por
linha de produção? por produto? Sem isso, cada cliente responde outra coisa. 🟢 Texto de apoio resolve, e
vai junto com o P1b — **desde que a FAMBRAS diga o que contar.**

**(2) 🔎 O campo NÃO entra na fórmula de dias de auditoria.** Conferi a interface de entrada
(`audit-days.interfaces.ts`): os insumos são **`categoryCode`/`categories`, `numEmployees`, `requestType`,
`isBranch`, `reductionPercent`** — **APPCC não está lá**. E o componente `TH` do `Total_HD` vem da **linha da
tabela** por (categoria × faixa de FTE), constante — não escala com a quantidade de APPCC reportada.

⇒ o cliente é **obrigado** a informar uma quantidade que **não influencia nada** no dimensionamento. Ou o
campo é meramente informativo (e o rótulo deve deixar claro), ou **deveria** compor o `TH` e não compõe — e
aí plantas com muitos planos APPCC estão sendo dimensionadas por baixo.

❓ **PERGUNTAR — é questão de NORMA, não minha para decidir:** na GSO 2055-2, o `TH` varia com o **número de
estudos/planos APPCC**? Se sim, é **defeito de cálculo** (e explica desconforto do comercial ao montar
proposta). Se não, é só rótulo. **Não vou inferir isso de fórmula acreditada.**

**Encaminhamento:** o rótulo entra no P1b assim que vier a definição. O efeito na fórmula fica **pendente de
resposta da FAMBRAS** — e se a resposta for "sim, varia", vira lote de backend com impacto em preço.

---

### FRG-19 · 🚨🚨 A tela de Análise Documental do analista NUNCA funcionou — filtra fases inexistentes

**Como veio:** *"o fluxo de teste tem os documentos iniciais pendentes de aprovação, mas na tela de Análise
Documental dos analistas não apareceu nada. É um 'ponto escuro' — não aparece em nenhum dash de analista,
tive que procurar o processo."*

**O "ponto escuro" é maior do que o caso de hoje: a tela está SEMPRE vazia, para TODA certificação.**

`DocumentAnalysis.tsx:56-60` filtra os workflows assim:

```js
const documentAnalysisWorkflows = allWorkflows.filter(
  (w) => w.currentPhase === 'analise_documental' || w.currentPhase === 'triagem'
);
```

E o enum `ProcessPhase` (`schema.prisma:74-92`, **17 valores**) **não tem nenhum dos dois**:

| Filtro da tela | Existe no enum? | Valor real |
|---|---|---|
| `'analise_documental'` | ❌ **NÃO** | `analise_documental_inicial` |
| `'triagem'` | ❌ **NÃO EXISTE em nenhuma forma** | — |

⇒ o filtro **nunca casa com nada**. Os 5 KPIs (Total · Pendentes · Em Análise · Aguardando · Aprovados)
derivam da mesma lista vazia — é por isso que aparecem **todos em 0**, e apareceriam em 0 mesmo com mil
processos em análise. **A caixa de entrada da análise documental é código morto desde sempre.**

🚨 **Por que ninguém tinha visto:** a base foi zerada em 28/mai e o acervo entrou por **espelhamento** (não
pelo fluxo). Este é, muito provavelmente, o **primeiro processo da história a chegar na fase de análise
documental por dentro do fluxo** — e chegou hoje, no presencial. É o risco nº 1 do BACKLOG ("ninguém testou")
se materializando exatamente como previsto: **a validação encontrou, a 5 dias do go-live, uma tela central
que nunca funcionou.**

✅ **A boa notícia é o tamanho do conserto: 2 strings.** Trocar por `analise_documental_inicial` e
`avaliacao_documental` (as duas fases documentais reais da sequência). Impacto máximo, risco mínimo.

🐛 **SEGUNDO defeito na mesma tela — consertar junto, senão a lista aparece inútil.** A linha 65 monta o nome
da empresa como:

```js
companyName: w.request?.certification?.company?.razaoSocial || 'N/A'
```

Duas coisas erradas na mesma expressão:
- **`Certification` não tem `company`.** Depois do refactor Empresa+Planta, o caminho é
  `certification.plant.company` (`certification.types.ts:156`: `plant?: Plant & { company?: Company }`).
- **`razaoSocial` não existe** no tipo `Company` — o campo é **`legalName`**.

⇒ corrigido só o filtro, a lista passaria a listar os processos **com "N/A" em toda a coluna de empresa**.
⚠️ **3ª ocorrência da mesma premissa obsoleta** (`Certification → company`): as anteriores foram o 500 do
dashboard `empresa` (`fef01534`, 08/ago) e o "0/1 Certificações Ativas" (`35ee5a5a`, 08/ago). **Vale varrer o
front inteiro atrás de `certification?.company`** — é padrão, não coincidência.

**Encaminhamento:** 🔴 **P0, junto com FRG-12 e FRG-18.** Arquivo próprio (`DocumentAnalysis.tsx`), sem
colisão com os outros lotes. ⚠️ **Verificar as telas vizinhas no mesmo lote:** se esta filtrava por nome de
fase inexistente, o `AnalystDashboard` e as demais caixas de entrada por fase podem ter o mesmo defeito —
e a queixa do Renato foi justamente *"não aparece em NENHUM dash de analista"*, o que sugere que **não é só
esta tela**.

---

### FRG-22 · Analista não deve ver valores de proposta e contrato

**Como veio:** *"analista não deveria ver valores de contrato e proposta"* — no detalhe da certificação os
cards **Proposta Comercial** e **Contrato** exibem **R$ 17.825,00**, parcelas e validade.

**Como está hoje:** os dois cards (`CertificationDetails.tsx:1294` e `:1401`) renderizam **sem nenhum gate de
papel** — quem abre a certificação vê o valor. E o backend **autoriza `analista`** nas rotas de leitura de
proposta (`proposal.controller.ts` linhas 62, 76, 121, 170, 185, 232, 280, 303), então não é vazamento
acidental: foi liberado assim.

⚠️ **Granularidade importa — não é esconder o card, é esconder o VALOR.** O analista **precisa** saber que a
proposta foi **aceita** e que o contrato está **assinado**: é o que autoriza a fase seguinte do processo
(foi exatamente o que usamos para destravar o fluxo hoje). Esconder o card inteiro quebraria a operação.
⇒ **manter status, ocultar dinheiro** (valor, parcelas, "Ver Detalhes da Proposta").

🏛️ **Razão que reforça o pedido:** não é só sigilo comercial — é **imparcialidade (ISO 17065)**. Quem julga
conformidade técnica não deve conhecer o valor pago pelo cliente. É o mesmo princípio do FRG-08 (esconder
prazo de auditoria do cliente), aplicado na direção oposta.

**Decisão que tomo (vetar se discordar): aplico a mesma regra ao `auditor`.** Pelo mesmo motivo, e o caso do
auditor é **mais sensível** que o do analista — ele julga a planta *in loco*. Hoje o `auditor` também está
liberado nas rotas de proposta (linhas 170, 280, 303), junto com `juridico` e `qualidade`. **Quem mantém
acesso a valor: `comercial`, `juridico`, `gestor`, `admin`.**

⚠️ **UI não basta como defesa** (lição do FRG-07/FRG-10): esconder no front deixa o valor acessível pela API.
O conserto correto é o backend **não devolver os campos monetários** para `analista`/`auditor` — remover a
rota inteira não serve, porque é dela que vem o **status** que o analista precisa.

**Encaminhamento:** 🟢 entra no **P1** (mesmo arquivo do FRG-06, `CertificationDetails.tsx`) + fatia de
backend para omitir os campos de valor por papel.

---

### FRG-23 · Analista deve abrir a tela RICA de empresa (a `/grupo/empresa/:id`)

**Como veio:** *"como analista, ao clicar em Empresas no menu eu consigo procurar por SIF — perfeito. No
entanto ao abrir detalhes, preciso que seja ESSA a tela, pois nela consigo tudo: certificados, certificações,
detalhes, documentos (principalmente)."*

**Confirmado — são duas telas diferentes, e o staff cai na pobre:**

| Rota | Componente | Conteúdo |
|---|---|---|
| `/empresas/:id` ← **onde o analista cai** | `CompanyDetail.tsx` (670 linhas) | **nenhuma aba** — sem Certificações, sem Documentos |
| `/grupo/empresa/:companyId` ← **a que ele quer** | `GroupCompanyDetail.tsx` (555 linhas) | 4 KPIs (Certificações · Ativas · Em Andamento · **Documentos**) + **3 abas**: Plantas · Certificações · **Documentos** |

`CompanyList.tsx:344` e `:376` navegam para `/empresas/${c.id}`. Origem disso está registrada: em 09/ago
(`d9b6a9ea`) o destino foi deliberadamente separado por papel — `empresa` → visão escopada
`/grupo/empresa/:id`, **staff → `/empresas/:id`**. A premissa era que o staff tinha a tela melhor. **É o
contrário.**

✅ **Fix mais barato e é literalmente o pedido: apontar o staff para `GroupCompanyDetail` também** (2 linhas
no `CompanyList`). E há evidência de que funciona para o analista: o Renato **abriu a tela como analista
agora**, com os KPIs preenchidos (3 certificações / 1 ativa / 1 em solicitação) — logo os endpoints já servem
o staff, não é visão exclusiva de `empresa`.

⚠️ **Ressalva de nomenclatura, não de bloqueio:** a rota se chama `/grupo/empresa/...`, o que fica estranho
para staff. Sugiro **manter a rota** por ora (mudar URL é risco desnecessário a 5 dias do go-live) e
renomear depois. **Não** recomendo o caminho alternativo (enriquecer o `CompanyDetail` com as abas) —
duplicaria tela e é lote grande sem necessidade.

**Encaminhamento:** 🟢 pronto. Toca `CompanyList.tsx` — arquivo sem colisão com os outros lotes.

---

### FRG-24 · 🚨 Reatribuir analista é IMPOSSÍVEL por construção

**Como veio:** *"depois de atribuído um fluxo a um analista, o gestor tentou reatribuir a outro — teve o
mesmo erro de bad request."*

**Mesma raiz do FRG-20, e a conclusão é pior do que eu havia escrito.** `assignAnalyst` exige
`currentPhase === assinatura_contrato` (`workflow.service.ts:561`) — **e a própria atribuição avança a fase
para fora dessa janela.**

⇒ **a operação é de uso único por construção:** atribuir com sucesso **destrói a possibilidade de
reatribuir**. Não é mau uso da UI (era o meu diagnóstico no FRG-20, quando o "Avançar Fase" tinha
antecipado a fase). Aqui o gestor fez **tudo certo** e ainda assim está travado. E **não existe rota de
reatribuição** — varri `workflow/` e `certification/` por `reassign`/`reatribu`: nada.

🏛️ **Isso não é inconveniência, é requisito descumprido.** Trocar o analista de um processo é necessidade
operacional normal — férias, desligamento, redistribuição de carga — **e é exigência de imparcialidade
(ISO 17065)**: se aparece conflito de interesse entre analista e cliente, a certificadora **tem** de poder
trocar quem avalia. Hoje, no sistema, **não pode**. O único caminho é escrever no banco.

✅ **Confirma qual conserto é o certo.** No FRG-20 eu tinha posto duas opções; esta ocorrência elimina uma:
- ❌ *Bloquear o "Avançar Fase" genérico* trataria só o sintoma do FRG-20 e **deixaria a reatribuição
  impossível**.
- ✅ **Permitir atribuir/reatribuir analista em qualquer fase a partir de `assinatura_contrato`** —
  resolve os dois. "Quem é o dono deste processo" não deveria ser função da fase.
  ⚠️ Ao implementar: **gravar a troca** (de quem para quem, por quem, quando) — é justamente o dado que a
  auditoria de imparcialidade vai pedir. `AuditTrail` já existe e é usado no padrão da transferência de
  empresa (`12a57a5d`, 08/ago).

**Encaminhamento:** 🔴 **P0, junto com FRG-20** (é o mesmo conserto). Enquanto não sair: **trocar analista em
produção exige UPDATE no banco** — registrar isso como limitação conhecida se o go-live acontecer antes.

---

### FRG-25 · 🚨 Analista tem CONTROLE TOTAL do contrato — a matriz de acesso está invertida

**Como veio:** *"reforçando, analista não deve ter acesso a detalhes financeiros, isso inclui o contrato.
Analista deve ter acesso apenas ao STATUS do contrato — para identificar em que fase está e poder cobrar
posicionamento — não ao documento em si."*

**O pedido é maior do que ajustar campos: o analista tem uma tela inteira de gestão de contratos**
(`/analyst/contracts`, menu "Comercial & Jurídico → Contratos") mostrando Valor Total, Parcelas, Validade e
**dois botões de ação** (ver/baixar documento).

🚨 **E o backend vai muito além de "ver".** `contract.controller.ts` — o que `analista` pode hoje:

| Rota | Linha | O que faz |
|---|---|---|
| `POST /contracts` | 57 | **CRIA** contrato |
| `GET /contracts` | 78 | lista **com valores** |
| `PATCH /:id/send` | 122 | **ENVIA** ao cliente |
| `POST /:id/generate-pdf` | 272 | **GERA o PDF** |
| `POST /:id/send-for-signature` | 292 | **MANDA PARA ASSINATURA** |
| `PATCH /:id` | 321 | **EDITA** o contrato |
| `PATCH /:id/cancel` | 212 | **CANCELA** |

⇒ o analista **conduz o instrumento comercial de ponta a ponta**. Isso é **falha de segregação de funções**:
quem julga a conformidade técnica controla o contrato do cliente que está julgando — o mesmo princípio de
imparcialidade (ISO 17065) do FRG-22, agora com **poder de escrita**, não só de leitura.

🔄 **E a matriz está literalmente invertida.** `comercial` **não tem nenhuma rota** de contrato (confirmado:
a palavra não aparece em nenhum `@Roles` do controller — bate com a pendência registrada em 09/ago no
BACKLOG). Somando ao FRG-16 (comercial sem a calculadora de dias de auditoria que a proposta exige):

| Papel | Deveria | Tem hoje |
|---|---|---|
| `analista` | só **status** do contrato | **controle total** (criar/editar/enviar/PDF/assinar/cancelar) |
| `comercial` | proposta + acompanhar contrato | **nada de contrato**; e **sem** a fórmula de dias de auditoria |
| `juridico` | dono do contrato | ✅ tem |

⇒ **não é ajuste de tela, é redesenho da matriz de permissões** entre analista, comercial e jurídico. É a
decisão de negócio que o BACKLOG deixou aberta em 09/ago ("liberar leitura de contrato ao comercial é
decisão de negócio; não fiz") — **agora a FAMBRAS respondeu, e a resposta é mais forte do que a pergunta.**

**O que o analista mantém, pelo próprio pedido:** o **status** do contrato, para saber a fase e cobrar
posicionamento. ⇒ tirar da visão dele: valores, parcelas, validade e **o documento** (ver/baixar/gerar).

**Encaminhamento:** 🔴 lote de backend + front, **maior que os outros de visibilidade**. ⚠️ **Precisa de
decisão sua sobre o escopo:** (a) mínimo — analista perde valores e documento, mantém status; (b) completo —
move a escrita de contrato para `juridico`/`gestor` e abre leitura ao `comercial`. **(b) é o certo pela
norma, (a) é o que cabe em 5 dias.** Minha recomendação: **(a) antes do go-live, (b) logo depois** — com o
risco de (a) registrado, porque a escrita continua na mão errada.

---

### FRG-26 · Texto corrompido na tela de contratos (U+FFFD gravado no arquivo)

Na mesma tela: *"Visualize e gerencie contratos de certifica**��**o"* e *"Buscar por n**�**mero"*.

**Não é problema de fonte nem de navegador — está gravado no arquivo.** Inspecionei os bytes de
`pages/analyst/ContractManagement.tsx`:
- linha 135: `certifica` + **U+FFFD U+FFFD** + `o` → era `certificação` (o `ç` e o `ã` foram perdidos)
- linha 148: `n` + **U+FFFD** + `mero` → era `número`

`U+FFFD` é o caractere de substituição: os acentos **foram destruídos** numa conversão de encoding e não há
como recuperá-los automaticamente — tem de reescrever as duas strings. 🟢 Fix trivial. ⚠️ Vale **varrer o
front inteiro** por `U+FFFD`: se aconteceu neste arquivo, provavelmente aconteceu em outros no mesmo lote de
conversão.

---

### FRG-27 · 🐛 A busca da tela de contratos deve derrubar a tela — teste em 2 segundos

`ContractManagement.tsx:112` (filtro da busca) e `:215` (exibição):

```js
contract.company?.razaoSocial.toLowerCase().includes(searchLower)   // linha 112
{contract.company?.razaoSocial || 'N/A'}                            // linha 215
```

**Dois defeitos somados:**
1. **`razaoSocial` não existe** no tipo `Company` — o campo é **`legalName`**. É a **4ª ocorrência** da
   mesma premissa obsoleta (FRG-19, `fef01534`, `35ee5a5a`) — e explica o **"Empresa: N/A"** do print.
2. Na linha 112 o `?.` protege **`company`**, mas **não `razaoSocial`**: se `company` vier como objeto (e vem
   — é por isso que o campo resolve para `undefined` em vez de a linha nem renderizar), então
   `undefined.toLowerCase()` **lança**.

⇒ **previsão testável:** digitar qualquer coisa no campo "Buscar por número, empresa ou protocolo" desta tela
deve produzir **tela branca** com `Cannot read properties of undefined (reading 'toLowerCase')` no console.
Mesma classe do bug `formatCnpj(undefined)` corrigido em 08/ago (`ecbd2e4f`) — *campo renomeado no backend,
front não acompanhou*.

🔧 **[Renato] confirmar agora:** digite uma letra na busca dessa tela. Se cair, está confirmado e vai no
mesmo lote do FRG-25/26.

---

### FRG-28 · Solicitação de documentos em LOTE — e a spec chegou pronta

**Como veio:** *"como analista solicitei documento. Precisa prever que poderão ser solicitados vários
documentos de uma vez só. Há também um documento com o padrão de comunicação para a solicitação desses
documentos (ou grupos de documentos)."*
📎 Fonte: `C:\HalalSphere\PRESENCIAL 10-14\FRIGORIFICO\1 - Contato inicial e documentação.odt` — **li o
arquivo**; conteúdo destrinchado abaixo.

**Estado hoje:** `DocumentRequestModal.tsx` chama `createDocumentRequest` (**singular**) — uma solicitação por
vez, com um `documentType`, uma descrição e um prazo. ✅ **O modelo de dados já suporta lote** (N linhas em
`document_requests` por certificação); **o gap é de UI e de comunicação**, não de schema.

**📋 O QUE O .ODT DEFINE — é especificação de produto, não só texto de e-mail:**

**Parte 1 — CONTATO INICIAL: 4 modelos por tipo de auditoria** (Manutenção Anunciada · **Não Anunciada** ·
Renovação · **Cliente Novo**), com regras de negócio embutidas:
- **Não anunciada:** ocorre **a cada 3 anos**; a FAMBRAS informa **uma janela de 15 dias** e o cliente **não
  escolhe a semana**; **logística por conta da FAMBRAS** com **nota de débito posterior**.
  ✅ *Parte disso já existe no código* — `audit.service.ts:873` verifica se houve auditoria não anunciada no
  ciclo de 3 anos. A regra da janela e do débito, não.
- **Cliente novo:** **Estágio 1 é remoto** (análise documental da planta) e o **plano de auditoria é enviado
  pelos auditores com até 7 dias de antecedência**.

**Parte 2 — DOCUMENTAÇÃO: 3 listas de 15 itens, por segmento** (Cliente **Bovino** · **Aves** ·
**Industrial**). As listas são quase idênticas; divergem no item de escopo (**FM 7.2.1.3** bovinos ×
**7.2.1.2** aves) e no item 13.

🔑 **Cinco características da lista que o modelo atual NÃO representa:**

| # | Característica | Consequência |
|---|---|---|
| 1 | **Lista varia por segmento** | é **template por segmento** — e o enum `CertificationSegment` **já existe** (`frigorifico_bovino`, `frigorifico_aves`, `industrial`, …). Encaixe natural |
| 2 | **Cada item tem destino diferente:** "necessário nos enviar" × *"não é necessário o envio para nós, entretanto podem ser vislumbrados pelos auditores"* (itens 4 e 9) | `DocumentRequest` **não tem** esse atributo. Sem ele, o sistema vai cobrar do cliente documento que **não deve** ser enviado |
| 3 | **Identidade é o código FM** (7.4.2.7 · 7.4.2.3 · 7.2.1.1 · 7.2.1.2/3 · 7.4.2.13 · 7.4.2.8 · 7.4.2.Y · 7.4.2.4/5) | o enum `DocumentType` tem **15 valores genéricos** e **não cobre** esses formulários. Precisa de taxonomia por código FM |
| 4 | **Item 15 é OU exclusivo** (7.4.2.4 Controle de **uso** do selo **OU** 7.4.2.5 Controle de **não uso**) | pede lógica condicional, não checklist plano |
| 5 | **Item 12 não é documento** — *"informar o horário de início e término da produção Halal"* | é **campo de dado**, não upload. Hoje só há caixa de arquivo |

🔗 **Conexões com achados de hoje:** o **item 10 é o HAS** — dá lugar definitivo ao FRG-05. Os **itens 3/4 e
8/9** são documentos **do fornecedor** (Ficha Técnica e FM 7.4.2.13 Questionário Halal, por Aba 1/Aba 2 do FM
7.4.2.7) ⇒ amarra direto na homologação de MP / FAM-0017.

**Encaminhamento:** 🔴 **lote grande, mas com spec em mãos** — vira **spec própria**, não cabe em lote de
UI. Fatias naturais: **(1)** solicitação em lote (multi-select) — resolve o pedido literal e é o pedaço
pequeno; **(2)** templates por segmento com os 15 itens; **(3)** atributo "enviar × só exibir ao auditor";
**(4)** taxonomia por código FM. ⚠️ **Depende do FRG-29** — solicitar 15 documentos sem notificar o cliente
multiplica por 15 o problema, não resolve nada.
📌 **[Renato] versionar o `.odt`** — está em `C:\HalalSphere\`, fora do git (política de fontes externas, §8
do BACKLOG). Na mesma pasta há `MIN.PGS.2602.01 - E - R3.xlsx`, provável escopo da Minerva.

---

### FRG-29 · 🚨 Documento solicitado NÃO avisa o cliente — o processo para calado

**Como veio:** *"como analista solicitei documento. Loguei como empresa e não vi nenhum alerta no dashboard
quanto a essa nova pendência (antes já tivemos isso). O 'alerta' só aparece ao abrir o fluxo e navegar até
aquele ponto."*

**CONFIRMADO, e é pior do que "falta um alerta no dashboard": não existe aviso nenhum, em nenhum canal.**

| Canal | Estado |
|---|---|
| **E-mail** | ❌ o módulo `document-request` **não importa nada** de notification/email — varri `*.module.ts` e `*.service.ts`: **zero** referência |
| **Notificação in-app** | ❌ idem |
| **Dashboard da empresa** | ❌ `CompanyDashboard.tsx` **não menciona** solicitação de documento em lugar algum |
| **Lista global p/ a empresa** | ❌ os únicos consumidores são `DocumentRequestModal` e `DocumentRequest**sAnalystView**` — ambos por certificação, ambos do lado do **analista** |

⇒ solicitar documento hoje **grava uma linha no banco e mais nada**. O cliente só descobre se abrir a
certificação certa e rolar até a seção certa. **É o "ponto escuro" do FRG-19 na direção oposta:** lá o
trabalho chegava e o analista não via; aqui a cobrança sai e o cliente não recebe.

🚨 **Por que isto é P0 e não cosmético:** análise documental é **a etapa mais repetida do processo** — todo
processo passa por ela, várias vezes. Se a cobrança não chega, **todo processo trava** esperando um documento
que o cliente não sabe que precisa mandar. Com prazo (`dueDate`, no print: 11/08/2026) que vence sozinho,
sem ninguém ser avisado.

💡 **E explica por que ninguém tinha notado:** o processo real da FAMBRAS é **por e-mail manual** — é
exatamente o que o `.odt` do FRG-28 documenta. Enquanto o e-mail é escrito à mão, a ausência de notificação
no sistema não aparece. **No go-live, com o processo dentro do sistema, aparece no primeiro dia.**

✅ **A infraestrutura existe:** há módulos de `notification` e de e-mail em produção (os 4 templates + as
notificações tiveram a cor migrada para o azul em 16/jul, `e953c21b`). ⇒ é **ligar**, não construir.

**Encaminhamento:** 🔴 **P0.** Fatias: **(a)** notificação + e-mail ao criar a solicitação — usa o template
do FRG-28 quando existir; **(b)** KPI/lista de pendências no dashboard da empresa; **(c)** lembrete de prazo
a vencer. ⚠️ **(a) é o mínimo indispensável para o go-live** — sem ele o processo não anda sozinho.

---

### FRG-30 · 🚨 O ciclo de documentos é mudo nos DOIS sentidos

**Como veio:** *"empresa fez o upload do documento solicitado anteriormente pelo analista. Logado como
analista, não recebi nenhum alerta. Deveria haver alerta no dashboard ou algo assim."*

**É o espelho exato do FRG-29** — e junto com ele fecha o diagnóstico:

| Direção | Estado |
|---|---|
| Analista **solicita** → empresa | ❌ silencioso (FRG-29) |
| Empresa **entrega** → analista | ❌ silencioso (FRG-30) |

⇒ **o ciclo inteiro de troca de documentos não tem uma única notificação.** Cada lado só descobre o
movimento do outro se abrir a certificação certa e rolar até a seção certa. Numa etapa que se repete várias
vezes por processo, isso significa que **o processo só anda se alguém adivinhar que é a sua vez** — hoje
resolvido por WhatsApp/e-mail manual, que é justamente o que o go-live deveria substituir.

**Encaminhamento:** 🔴 **amplia o escopo do B3** (que ainda não começou — dá tempo). O bloco passa a cobrir
**os dois gatilhos**:
- `document-request.create` → notifica a **empresa** (FRG-29)
- cumprimento da solicitação / upload do documento → notifica o **analista** dono do processo, e
  idealmente entra numa fila/KPI do dashboard dele (FRG-30)

⚠️ Note a conexão com o **FRG-19**: o analista não tem caixa de entrada que funcione. Notificar sem consertar
a caixa de entrada resolve metade; o B2 conserta a outra. **Os dois juntos fecham o "ponto escuro".**

---

### FRG-31 · Rejeitar documento não pede motivo — e o suporte já existe inteiro

**Como veio:** *"como analista, cliquei em rejeitar o documento. Deveria ter aberto uma tela para registrar o
motivo da rejeição e isso voltar para a Empresa."*

**O achado interessante: está tudo pronto, só não está ligado no lugar onde você clicou.**

| Camada | Estado |
|---|---|
| **Modelo** | ✅ `Document.validationNotes` (`validation_notes`, Text) **já existe** |
| **Rota** | ✅ `PATCH /documents/:id/validate` aceita **`{ isValid, notes }`** e grava as notas |
| **Componente correto** | ✅ `DocumentRequestsAnalystView.tsx:39-58` tem o fluxo certo — estado `isValidating`, campo de observações, e envia `notes` ao rejeitar. E **exibe** o motivo depois (linhas 607 e 699: *"Observações: …"*) |
| **Botão que você usou** | ❌ `CertificationDetails.tsx:987` → `validateDocument(doc.id, 'rejeitado')` — **sem o 3º argumento**. Rejeita sem motivo e ainda dá toast de sucesso |

⇒ **há dois pontos de entrada para a mesma ação**, um correto e um não — e o incorreto é justamente o do card
"Documentos Anexados" da certificação, que é onde o analista naturalmente vai.

🔎 **E a volta para a empresa também falta:** `validationNotes` é exibido em
`DocumentRequestsAnalystView.tsx` e `ProcessDocuments.tsx`, **mas não em `CertificationDetails.tsx`** — ou
seja, mesmo que o motivo fosse gravado, a empresa veria só o selo **"Rejeitado"**, sem explicação.

📌 **Precedente no próprio código, que resolve a discussão de desenho:** na validação de **empresa**, o motivo
de rejeição é **obrigatório** — `CompanyValidationCard.tsx:114` bloqueia se as notas estiverem vazias.
⇒ aplicar a mesma regra ao documento é **consistência**, não invenção.

**Fix (3 partes, todas pequenas):**
1. No card da certificação, o ✗ abre captura de motivo — **obrigatório**, como no `CompanyValidationCard`
   (reaproveitar o padrão do `DocumentRequestsAnalystView`, não escrever um terceiro).
2. Exibir `validationNotes` no card de documentos da certificação, para a **empresa** ver o motivo.
3. Notificar a empresa na rejeição — 🔗 **entra pelo B3**, junto com FRG-29/30 (mesma infraestrutura).

**Encaminhamento:** partes 1 e 2 são **front** em `CertificationDetails.tsx` ⇒ **bloco B5** (que já é dono
desse arquivo). Parte 3 ⇒ **B3**.

---

### FRG-32 · 🚨 O PDF e a validação pública do QR discordam sobre o selo

**Como veio:** *"certificado `BRF.LRV.2604.1472.1.BRA`: no PDF tenho selo ENAS, na validação do QR Code ele
não aparece."*

**CAUSA-RAIZ: duas fontes da verdade para o mesmo fato.**

| Camada | De onde tira o selo |
|---|---|
| **PDF** | **DERIVA na hora da geração**, a partir das normas da certificação (`certificate.service.ts:872-888`: `hasGso && hasUae → 'GAC_ENAS'`; ENAS só com UAE.S, conforme Soha 07/jul) |
| **Página do QR** (`verify()`) | **LÊ a coluna** `certificates.market_variant` → `resolveSeals(certificate.marketVariant ?? undefined)` |

**Medido no banco para este certificado:**
```
certificate_number = BRF.LRV.2604.1472.1.BRA
issuance_mode      = mirror
market_variant     = NULL      ← a página do QR não tem de onde tirar selo
template_type      = NULL
pdf_url            = s3://…/halalsphere-certificates/…/v1/certificate.pdf   ← PDF gerado pelo GC
```

⇒ o PDF é **gerado pelo próprio GC** (não é documento legado do SysHalal) e sai **com ENAS**, derivado na
hora; a coluna que a validação pública consulta está **vazia**. Nada foi congelado na emissão.

⚠️ **Isso contradiz uma decisão travada — §5.22(e) do BACKLOG:** *"`Certificate` **congela** as normas
resolvidas na emissão; PDF de cert emitido **nunca re-resolve**."* Aqui ocorre o oposto: **nada foi
congelado** e o PDF **re-resolve a cada geração**. Ou seja, não é só divergência de tela — é a regra de
imutabilidade não implementada nesse caminho.

**🔢 ALCANCE — e a parte pior é a latente:**

| | |
|---|---|
| Total de certificados | **1.433** |
| Com `market_variant` preenchido | 1.253 |
| **Sem `market_variant`** | **180** — e **todos** `issuance_mode='mirror'` (0 manual) |
| Dos 180, **com PDF gerado** | **3** ⇒ divergentes **hoje** |
| Dos 180, **sem PDF ainda** | **177** ⇒ divergem **no instante em que alguém gerar o PDF** |

⇒ 3 casos ativos e **177 bombas armadas**. Não é um certificado com problema: é uma **classe** de 180.

🏛️ **Por que a severidade é alta mesmo sendo "só" a tela do QR:** a página do QR **é** o instrumento oficial
de verificação — é o que consumidor final, parte interessada e **acreditador** consultam (e é justamente o
canal que a FAMBRAS quer preservar quando o site perder as planilhas FM 781/782, §4.1). Um certificado que
**afirma acreditação ENAS no papel** e **não a mostra na própria validação online** é um achado esperando
acontecer.

**Conserto em duas partes — e a ordem importa:**
1. **CÓDIGO (impede reincidência):** ao emitir/gerar, **persistir** o `market_variant` derivado (e o
   `template_type`) no `Certificate`, cumprindo o §5.22(e). Fonte única passa a ser a coluna; o PDF deixa de
   re-resolver.
2. **DADO (corrige o acervo):** backfill dos **180**, derivando com **a MESMA função** que o PDF usa — nunca
   uma segunda implementação, senão recria a divergência.
   ⚠️ **Não confiar cegamente na derivação:** para os **3 que já têm PDF**, comparar o derivado com o selo
   impresso antes de gravar. Para os outros 177, a autoridade é a lista FM 7.8.x de origem — derivar e
   **conferir por amostra** com a FAMBRAS.

**Encaminhamento:** 🔴 **bloco novo (B10)**, não cabe nos existentes. Parte 1 é backend
(`certificate/certificate.service.ts` — ⚠️ **Trilha A**, que é dona de `certificate/*`); parte 2 é **carga de
dados** (Trilha B), com SQL revisado + backup + OK explícito, como o B9.
❓ **[Renato] decisão de timing:** entra antes do go-live? Meu parecer: **a parte 1 sim** (é pequena e impede
que os 177 virem 180 divergentes); **a parte 2 pode ir depois**, desde que a FAMBRAS saiba que hoje há
certificados cuja validação pública não exibe o selo.

---

## 5-B. Achados — Dia 2 · **11/ago, 09h** · equipe **INDUSTRIALIZADOS**

> 🏁 **MARCO: 11/08/2026 09h — início da validação com a equipe de Industrializados.**
> Dia 1 (10/ago, Frigorífico) fechou com **32 achados**. Numeração deste dia: **`IND-nn`**.

**Departamento:** Industrializados (Fuad · **Dib = pessoa, não sigla**) — o outro lado da segregação por
`Certification.department`. A 1ª validação real de INDUSTRIALIZADO foi a da **Lina, em 04-05/ago** (8 de 8
itens em prod), então este time chega com terreno mais pisado que o do Frigorífico.

### ⚙️ O que MUDOU em produção desde ontem — não re-reportar

Deploy de 10/ago (back `0a736a82`, migration aplicada 18:08:56). **Já corrigido e no ar:**

| Achado do Dia 1 | Estado |
|---|---|
| **FRG-20 · FRG-24** — atribuir/reatribuir analista dava 400 | ✅ **em prod** — atribuição vale da assinatura do contrato em diante; reatribuir não mexe na fase |
| **FRG-18** — assinar contrato não devolvia a posse do processo | ✅ **em prod** — sai de `aguardando_empresa` para `pendente`, na mesma fase |
| **FRG-21** — `PATCH /workflows/:id` mudava fase sem rastro | ✅ **em prod** — a rota não aceita mais `currentPhase` |

⚠️ **Ainda NÃO validado:** o espelho `certifications.analyst_id` (a atribuição da Minerva rodou minutos
**antes** do deploy). **A primeira atribuição de analista que este time fizer serve de teste** — depois eu
confiro no banco.

### 🚫 O que NÃO demonstrar hoje

**Catálogo de Ingredientes Restritos:** ~~o backend está em produção mas a tela não~~ — ✅ **RESOLVIDO no
mesmo dia:** o front `4aeadb8b` subiu na esteira do B2, então **back + tela estão completos em produção** e o
menu pode ser demonstrado. *(A restrição valia só para a manhã de 11/ago.)*

### 👀 Watch-list específica de INDUSTRIALIZADOS

O que muda em relação ao Frigorífico — vale dirigir a atenção do time para cá:

| # | Ponto | Por quê |
|---|---|---|
| **I-1** | **Homologação de MP é A tela deles** | No Frigorífico ela fica vazia (W-3, questão em aberto: esconder o menu para In Natura?). Aqui é o coração do processo — e é onde aparecem as **188 evidências de MP vencidas** (75 de 335 MPs). Decidido em 05/ago: **avisar, não travar** — o analista regulariza. Se estranharem os badges vermelhos, é comportamento esperado; a fila é da FAMBRAS |
| **I-2** | **Numeração `.K.` do IND é SEQUENCIAL** | Regra veio da base, não de e-mail (retorno da Lina, 04-05/ago). Conferir num certificado real deles |
| **I-3** | **Separação automática por ingrediente restrito** (cochonilha) | Está em prod desde 05/ago e é **ponta a ponta**. Teste-chave: produto marcado com cochonilha + GSO + Indonésia → devem sair **2 certificados**, o GSO **sem** o produto |
| **I-4** | **FM 7.8.1 ATIVOS nunca foi carregado** | O lote de 04AGO trouxe só `INDUSTRIAL_INATIVOS`. ⇒ **certificados industriais novos podem simplesmente não existir na base**. Se disserem "faltam certificados nossos", é isto — não é bug, é carga pendente da FAMBRAS |
| **I-5** | **Categoria por norma no picker** (GSO × SMIIC divergem) | Gap conhecido de emissão para industrializados |
| **I-6** | **Certificado de PRODUTO (DSM/IFF)** | Norma-por-habilitação, 1 produto por certificado — depende de digitalizar escopo de indústria |
| **I-7** | **`BRF.TOL.2402.1090.4.BRA`** | Único certificado da base que aparece nas listas de cancelados/suspensos **e segue ativo**. Inconsistência do FM, ainda sem resposta da Soha/Elaine — se aparecer, é achado já registrado |

⚠️ **Os defeitos de FLUXO do Dia 1 são agnósticos de segmento** — escopo herdado (FRG-12), caixa de entrada
vazia (FRG-19), ciclo de documentos mudo (FRG-29/30/31), segregação de valores (FRG-22/25). **Devem
reaparecer aqui.** Reaparecendo, registrar como *confirmação em 2º departamento* (fortalece a prioridade),
**não** como achado novo.

### Achados do Dia 2

| ID | nº na sala | Tipo | Tela | Resumo | Dono | Estado |
|---|---|---|---|---|---|---|
| **IND-01** | 1 | 🎨 UX + 🐛 | Validação de documentos | Documento deve **abrir em visualização**, sem exigir download. E o botão "Visualizar" que existe usa **XHR→S3** — o anti-padrão que o §5.18 já proíbe | Claude → §4.2 | 🟢 **pronto** |
| **IND-02** | 2 | 🐛 UI oferece o que a API nega | Empresas do Grupo → Vincular Usuário | 403 **Forbidden resource**: a rota é `@Roles('admin','gestor')` e a sessão é **`analista`**. A tela oferece o botão a quem não pode. **Não é bug de backend** | ❓Renato → §4.2 | 🟡 decisão: liberar × esconder |
| **IND-03** | 3 | 🎨 texto + ❗**regra nova** | Wizard → Quantidade APPCC | Placeholder passa a ser *"Obrigatório maior que 0 para Produtos Alimentícios"*. ⚠️ O texto **anuncia uma validação que não existe** — e "Produtos Alimentícios" é literalmente o **Grupo C** | Claude → §4.2 | 🟢 texto pronto; regra é decisão |
| **IND-04** | 4 | 🚨🏛️ **3 taxonomias sobrepostas** | Proposta → Tipo de Certificação | Lista C1–C6 é **taxonomia legada** que **contradiz** os grupos industriais (C2="Produtos Químicos" × Grupo C="Alimentícios"; químico é **K**). E ela **define o preço-base**. Migração de modelo de preço **parada no meio** | ❓Renato/FAMBRAS | 🔴 **decisão estrutural** |
| **IND-05** | 5 | 🎨 terminologia | Proposta/Wizard → Tipo de Solicitação | "Nova Certificação" → **"Certificação Inicial"** | Claude → §4.2 | 🟢 pronto (rótulo, não enum) |
| **IND-06** | 6 | 🧩 regra de fluxo | Comercial → Revisão de Qualidade | Revisão de qualidade **obrigatória e bloqueante** na Certificação Inicial. Módulo **já existe** (`QualityReview`) e nunca foi usado | Claude + ❓ | 🟡 **ver IND-07 antes** |
| **IND-07** | — | 🚨🚨 **BLOQUEIO DE GO-LIVE** | Perfis em produção | **`comercial`, `auditor`, `juridico` e `gestor_auditoria` têm ZERO usuários.** O fluxo tem 3 etapas sem ninguém — e a Minerva já está em `planejamento_auditoria` | 🔧 **[Renato/FAMBRAS]** | 🔴 **achado meu — o mais grave do dia** |
| **IND-08** | 7 | 🚨 **nunca funcionou** | Analista → Validação de Viabilidade (IT 7.4) | *"Apenas solicitações em rascunho podem ser atualizadas"*. **Defeito duplo:** a trava é categoricamente errada **e** o `update()` nem grava o campo. **0 de 2 solicitações têm checklist** | Claude → §4.2 | 🔴 **P0 — fix pequeno** |
| **IND-09** | — | 🚨 auditoria/ISO 17065 | Reclamações/Apelos → status | `updateStatus` **não valida transição** (dá para ir de `registrada` a `resolvida` e voltar) e **não grava histórico** | Claude → **B1** | 🔴 mesma família do FRG-21 |
| **IND-10** | — | 🚨 comunicação | Reclamações/Apelos | **Nenhuma notificação:** o reclamante não recebe acuse de recebimento nem a resposta. Módulo sem e-mail | Claude → **B3** | 🔴 exigência ISO 17065 |
| **IND-11** | — | 🧩 GAP | Reclamações/Apelos | **Sem prazo na reclamação** — `deadline` só existe no parecer. Sem SLA de resposta nem alerta de vencimento | Claude + ❓ | 🟡 falta o SLA da FAMBRAS |
| **IND-12** | — | ❓ decisão | Apelo × perfil `empresa` | **A empresa não vê o próprio apelo** (não está nas roles de leitura) — e apelo é, por definição, o instrumento dela | ❓FAMBRAS | 🟡 consequência do Lote 6.3 |
| **IND-13** | 8 | 🎨 UX | Agendar Auditoria | Endereço deve vir **pré-preenchido** da planta. Bônus: **"Tipo de Auditoria" aparece 2×** no mesmo modal, e Estágio 1 default **Presencial** contradiz o FM (*"Estágio 1 é realizada de forma remota"*) | Claude → §4.2 | 🟢 pronto |
| **IND-14** | 9 | 🚨 **3 causas empilhadas** | Gestor → Sugestões de Alocação | Zero sugestões de auditor. **(1)** matcher exige `role==='auditor'` e há **0 auditores**; **(2)** lê o **FK escalar** de categoria, NULL em 1.010 de 1.190 — o wizard grava na **M:N**; **(3)** falha **silenciosa** (`logger.warn`); **(4)** a tela **não tem botão de gerar** — o "Atualizar" só lista | Claude → §4.2 | 🔴 **P0** |
| **IND-15** | 9 *(2º)* | 🧩 **capacidade sem porta** | Auditoria → reagendar / trocar auditor | Backend **já faz as duas** e autoriza; o front tem os métodos de serviço e **nenhuma tela os chama** — são órfãos. ⚠️ `gestor_auditoria` reagenda mas **não pode trocar auditor** | Claude → §4.2 | ✅ **EM PROD 12/ago** — reagendar `e5d16566` (11/ago) · trocar auditor com motivo obrigatório + `AuditTrail` back `60eee058` front `c395d07b` · card deixa de sumir fora do planejamento `71246f92`. Falta validar |

---

### IND-01 · Visualizar o documento sem baixar — e o "Visualizar" que existe está quebrado

**Como veio:** *"ao fazer validação de documentos (solicitados por exemplo), abrir em visualização, sem
necessidade de download especificamente do arquivo."*

**Três camadas, e a do meio é um bug já conhecido do projeto:**

**1. O botão do card da certificação baixa em vez de exibir.**
`CertificationDetails.tsx:1003` → `documentService.downloadDocument()` → `window.open('/documents/:id/download')`.
A rota **redireciona (302) para uma URL presigned** do S3 — e a presigned é gerada **sem
`ResponseContentDisposition`** (`document.service.ts:479`). ⇒ o comportamento fica **à mercê dos metadados
gravados no objeto**: às vezes exibe, às vezes baixa. Compare com o certificado, onde a disposição é
**explícita** (`certificate-pdf.service.ts:203`: `attachment; filename=...`). ✅ O upload **já grava
`ContentType: file.mimetype`** corretamente (`document.service.ts:166`), então a informação necessária existe
— só não está sendo usada na hora de servir.

**2. 🐛 Já existe um botão "Visualizar" — e ele usa o anti-padrão proibido.**
`ProcessDocuments.tsx:94-113` (`handleView`) faz **`fetch` com `Authorization: Bearer` → a rota redireciona
para o S3 → o navegador segue o redirect → blob → `createObjectURL`**. Isso é **exatamente** o que a decisão
**§5.18 do BACKLOG** proíbe: *"via URL presigned + `window.open` — **nunca XHR→S3** (dá CORS)"*. Além do
CORS, o header `Authorization` é encaminhado ao S3, que o rejeita. ⇒ **esse "Visualizar" quase certamente
não funciona**; 🔧 **[Renato] vale clicar nele para confirmar** — se falhar, é bug confirmado, não hipótese.

**3. O pedido real é maior que "abrir o arquivo": é validar vendo.** Hoje o analista precisa **baixar →
abrir fora → voltar → clicar ✓/✗**. E o ✗ ainda **não pede motivo** (FRG-31). O fluxo correto é
**ver → decidir → justificar**, na mesma tela.

**Conserto (3 partes, todas pequenas):**
1. **Back:** gerar a presigned com `ResponseContentDisposition: inline; filename="..."` e
   `ResponseContentType: document.mimeType`. Passa a exibir de forma **determinística**, sem depender de
   metadado gravado. Manter o caminho de download explícito para quem quiser o arquivo.
2. **Front:** visualizador usando a **URL direta** (`<iframe>`/`<img>` conforme o mime), **nunca blob via
   fetch**. Corrigir o `handleView` do `ProcessDocuments` pelo mesmo caminho — hoje ele é o anti-padrão.
3. **UX:** o visualizador abre **junto das ações** aprovar/rejeitar — 🔗 casa com o **FRG-31** (motivo
   obrigatório na rejeição), que já está no mesmo bloco.

**Encaminhamento:** 🟢 back é fatia pequena em `document/*` (⚠️ **módulo sem trilha declarada** — 4ª
ocorrência do "buraco do §2"); front vai para o **B5**, que já é dono do `CertificationDetails.tsx` e já
carrega o FRG-31. **Mesma tela, mesmo lote.**

---

### IND-02 · "Erro ao vincular usuário / Forbidden resource" — a API está certa, a tela é que oferece demais

**Como veio:** ao vincular a **Lina Ramadan** à empresa **Caramuru Alimentos S.A.** pela tela de Empresas do
Grupo → toast **"Erro ao vincular usuário — Forbidden resource"**.

**Não é bug de backend. É a guarda funcionando:**

| | |
|---|---|
| Rota chamada | `POST /users/:id/link-company` (`group-user.service.ts:44`) |
| `@Roles` da rota | **`admin`, `gestor`** (`user.controller.ts:166-167`) |
| Sessão do print | **Renato Ribeiro de Oliveira** = `r.ribeiro@ecotrace.info` → papel **`analista`** *(consultado em prod: o Renato tem 4 contas — `admin` `r.ribeiro@ecohalal.digital`, `analista` `r.ribeiro@ecotrace.info`, e 2 `empresa`)* |

⇒ 403 correto. **O defeito é a tela oferecer o botão "Vincular Existente" a um perfil que a API recusa** —
é o padrão nomeado em 09/ago no BACKLOG, agora na direção inversa: lá o menu foi montado **por baixo** do que
o backend permitia; aqui a tela oferece **acima**.

✅ **Destrave imediato, se for só para seguir a demonstração:** repetir a ação logado com a conta **`admin`**
(`r.ribeiro@ecohalal.digital`). A funcionalidade existe e funciona — é só perfil.

❓ **Decisão sua, e ela não é óbvia:**
- **(a) liberar `analista` na rota** — ⚠️ **não recomendo.** Vincular usuário a empresa é **conceder acesso
  aos dados daquela empresa**: é ato de administração de acesso, não de análise técnica. Seriam **21
  analistas** com esse poder. Vai na contramão do que a FAMBRAS pediu ontem (FRG-22/25: o analista está
  **sobre-servido**, tem até controle total de contrato).
- **(b) esconder/desabilitar a ação** para quem não é `admin`/`gestor`, com mensagem clara. ✅ **Recomendo.**

⚠️ **Além do perfil, um alerta sobre o QUE se estava vinculando:** a **Lina é `analista`**, não `empresa`.
O vínculo a empresa grava `companyId` + `companyGroupId`, campos que só são **consumidos para o perfil
`empresa`** — para um analista não mudam o que ela enxerga (o recorte dela é por departamento). ⇒ vincular
analista a empresa é **inócuo no acesso e sujo no dado**. Se a intenção era dar à Lina acesso a Caramuru, este
não é o caminho; se era teste, sem problema — mas vale **não deixar o vínculo gravado**.

🎨 **Terceiro ponto, pequeno:** o toast mostra **"Forbidden resource"** — texto cru do backend vazando para o
usuário. Trocar por mensagem em pt-BR ("Seu perfil não permite vincular usuários a empresas").

**Encaminhamento:** front (esconder a ação + mensagem) vai para o bloco de **segregação de visibilidade
(B5)**, que já trata "quem vê/faz o quê". Nenhuma mudança de backend, salvo se você escolher (a).

---

### IND-03 · Texto do APPCC — e a regra que ele passa a anunciar

**Como veio:** trocar o texto sugestivo de **"Ex: 3 (pode ser 0)"** para
**"Obrigatório maior que 0 para Produtos Alimentícios"**.

✅ **A troca de texto é trivial** e vai no lote do wizard. Mas ela **não é só cosmética**: o placeholder atual
*permite* 0 sem ressalva, e o novo **enuncia uma regra**. Um campo que diz "obrigatório maior que 0" e aceita
0 é pior que o texto de hoje — passa a prometer uma validação que não existe.

🔑 **E a regra é implementável agora, porque o mapeamento é literal.** Consultei os grupos industriais em
produção e **"Produtos Alimentícios" é exatamente o Grupo C**:

| Grupo | Nome |
|---|---|
| A | Criação de animais |
| B | Plantação agrícola |
| **C** | **Produção de produtos alimentícios** ← |
| D | Produção de ração animal |
| E | Serviço de alimentação |
| F | Distribuição · G Transporte e armazenamento · H Serviços · I Embalagem · J Fabricação de equipamentos · **K Bioquímica** · L Outros materiais de processamento |

⇒ regra: **se a certificação inclui categoria do Grupo C, `quantidadeAPPCC` deve ser > 0**; nos demais grupos,
0 é legítimo. *(Confere com o caso da Minerva de ontem: `CV - Abate de animais` é **Grupo C**, e o valor
informado foi 1.)*

❓ **Única ambiguidade, e é pergunta de uma linha para a sala:** a exigência vale **só para o Grupo C**, ou
também para **D (ração animal)** e **E (serviço de alimentação)**? Plano APPCC costuma ser exigido em
serviço de alimentação também. **Não vou inferir** — o texto diz "Produtos Alimentícios", que casa palavra
por palavra com o C.

🔗 **Interage com o FRG-17, que segue aberto:** o campo é **obrigatório**, **não entra na fórmula** de dias de
auditoria (os insumos são categoria, nº de funcionários, tipo, filial e redução) e agora ganha uma regra de
valor mínimo. Se a resposta ao FRG-17 for *"o `TH` varia com o número de planos APPCC"*, este campo passa a
ter efeito em preço — e aí a validação deixa de ser conveniência e vira **controle**.

**Encaminhamento:** 🟢 texto vai no **lote do wizard**. A **validação condicional por grupo** entra assim que
a pergunta acima for respondida — é pequena e o dado necessário (grupo da categoria) já está na tela, que é
onde o passo de Classificação Industrial acontece.

---

### IND-04 · 🚨 "Tipo de Certificação" — três taxonomias sobrepostas, e a legada é a que define o preço

**Como veio:** *"a lista de tipos de certificação está errada, não faz sentido, tem que rever."*
O time tem razão, e a incoerência é estrutural. **Levantei as três camadas:**

**1. O enum tem DUAS GERAÇÕES convivendo** (`schema.prisma:52-62`):
`C1` Alimentos processados · `C2` Produtos químicos · `C3` Cosméticos · `C4` Farmacêuticos · `C5` Embalagens
· `C6` Serviços de alimentação — **mais** `produto` · `processo` · `servico`, estes marcados no próprio schema
como *"NEW: for new implementation"*. **A tela oferece só a geração velha.**

**2. As letras CONTRADIZEM a taxonomia real.** A classificação que vale (e que sai no certificado) é
**grupo industrial A–L**. Nela, **`C` = "Produção de produtos alimentícios"** e **químico é `K` = Bioquímica**.
⇒ a tela diz **"C2 - Produtos Químicos"** enquanto, na taxonomia que o time de Industrializados usa todo dia,
**C é alimento e químico é K**. *É exatamente por isso que não faz sentido para eles.*

**3. Medido em produção — as duas taxonomias não convivem, se alternam por geração:**

| `certification_type` | Certificações | Tem grupo/categoria industrial? |
|---|---|---|
| **C1** | **940** | ❌ nenhuma |
| C2 · C3 · C4 · C5 | 63 · 7 · 1 · 1 | ❌ nenhuma |
| **`produto`** | **180** | ✅ **todas** (157 grupo C · 22 grupo K · 1 grupo G) |

⇒ as **1.012 do acervo espelhado** carregam `C1–C6` e **nenhuma categoria industrial**; as **180 novas** usam
`produto` + a taxonomia real. Ninguém usa `processo`/`servico`.

**4. 💰 E a taxonomia legada é LOAD-BEARING: ela define o preço-base.**
`calculator.service.ts:51-61` → `basePrices[input.certificationType]`. Na tabela de preços **ativa (v1.0)** as
chaves são exatamente `{"C1":5000,"C2":7000,"C3":6000,"C4":8000,"C5":4000,"C6":5500}`.
⇒ **é por isso que o dropdown não oferece `produto`**: se alguém escolher, o cálculo **estoura** com
*"Tabela de preços não contém preço base para o tipo produto"*.

**5. 🔍 E há uma migração de modelo de preço PARADA NO MEIO** — descoberta ao olhar as outras versões:

| Versão | Ativa | Chaves de `base_prices` |
|---|---|---|
| **v1.0** | ✅ **sim** | `C1…C6` (por **tipo de certificação**) |
| v1.1 | não | `nova` · `ampliacao` · `manutencao` — **todas null** |
| v1.2 · v1.3 | não | `nova`: 1000 · `ampliacao`: **null** · `manutencao`: **null** |

⇒ alguém começou a migrar o preço de **"tipo de certificação"** para **"tipo de solicitação"**, preencheu só
`nova` e parou. As tabelas novas ficam **inativas porque estão incompletas**, e a produção segue na v1.0.

🎯 **A frase que resume a incoerência:** **os dois cálculos que alimentam a mesma proposta usam taxonomias
diferentes** — os **dias de auditoria** usam `categoryCode` (grupo/categoria real, GSO 2055-2) e o
**preço-base** usa `certificationType` (C1–C6 legado). Não há como os dois estarem certos ao mesmo tempo.

❓ **Decisão estrutural — é do Renato + FAMBRAS, não minha:**
- **(a)** O preço-base passa a seguir a **taxonomia real** (grupo/categoria industrial), aposentando C1–C6 —
  coerente com o certificado e com a fórmula de dias de auditoria; exige **nova tabela de preços por grupo**.
- **(b)** O preço-base passa a seguir o **tipo de solicitação** (era a intenção das v1.1–v1.3) — exige
  **completar** `ampliacao` e `manutencao` e ativar a tabela.
- **(c)** Mantém C1–C6 por ora e só **corrige os rótulos** para não colidir com as letras dos grupos —
  paliativo honesto se não houver tempo até 15/ago.

⚠️ **Nenhuma dessas é mudança de tela: é mudança de modelo de precificação.** E o FRG-16 (levar a
calculadora de dias de auditoria ao comercial) **depende desta decisão** — não faz sentido expor ao comercial
uma proposta que soma duas taxonomias incompatíveis. **Recomendo tratar IND-04 e FRG-16 como um único tema.**

---

### IND-05 · "Nova Certificação" → "Certificação Inicial"

**Como veio:** usar o termo **"Certificação Inicial"** no lugar de "Nova Certificação".

✅ Mudança de **rótulo**, não de dado: o valor do enum `RequestType.nova` **permanece** — trocar o valor
exigiria migration e quebraria as 1.190 certificações e os `base_prices` que usam a chave `nova`.

⚠️ **Trocar no lugar certo, não em 15 lugares:** o rótulo aparece no dropdown de Tipo de Solicitação da
proposta **e** no wizard. Seguir a lição já registrada (*"corrigir o const central e deixar o `tsc` varrer"*) —
localizar o mapa de rótulos de `RequestType` e trocar **ali**; se houver string solta em componente, alinhar.
⚠️ Conferir também **e-mails e PDFs** (o FM 7.2.1.1 é a "Solicitação para Certificação"): se o termo aparecer
em documento gerado, muda lá também.

**Encaminhamento:** 🟢 vai no **lote do wizard**, junto com IND-03 — mesma família de textos, e o
`CertificationWizard.tsx` já é domínio daquele bloco. ⚠️ Não colide com o B4 apenas se rodar **depois** dele.

---

### IND-06 · Revisão de qualidade obrigatória e bloqueante na Certificação Inicial

**Como veio:** *"no fluxo, quando em comercial, a chamada para revisão da qualidade tem que ser obrigatória
quando for fluxo de nova certificação. Essa revisão é feita por pessoa do Comercial, e o fluxo não segue sem
isso."*

✅ **O módulo já existe inteiro e nunca foi usado.** `model QualityReview` traz `workflowId`,
`certificationId`, `requestedById`, `assignedToId`, `status`, **`parecer`**, `observacoes`,
`motivoSolicitacao`, `completedAt` — e o controller já separa os papéis:

| Ação | Rota | Quem pode hoje |
|---|---|---|
| **Solicitar** | `POST /quality-reviews` | **`comercial`**, gestor, admin |
| Atribuir | `PATCH /:id/assign` | qualidade, gestor, admin |
| **Dar o parecer** | `PATCH /:id/complete` | **`qualidade`** (exclusivo) |

📊 **`quality_reviews` em produção: NENHUMA linha.** O fluxo nunca foi exercitado.

❓ **Uma frase sua precisa ser desambiguada antes de eu codar** — *"essa revisão é feita por pessoa do
Comercial"*:
- **Leitura (a):** quem **SOLICITA** ("a chamada") é o Comercial, e quem **dá o parecer** é a Qualidade.
  **É exatamente o que o código já faz** — e é o que faz sentido para imparcialidade.
- **Leitura (b):** quem **executa a revisão** é alguém do Comercial. Isso **contraria** o desenho atual
  (`complete` é exclusivo de `qualidade`) e enfraquece a revisão — o comercial revisaria o próprio trabalho.

**Assumo (a)** salvo correção sua. Nesse caso o que falta é só a **obrigatoriedade**, não o mecanismo.

**O que implementar (assumindo (a)):**
1. `requestType = nova` ⇒ **exigir** uma `QualityReview` com `parecer` favorável antes de avançar do bloco
   comercial. O gate natural é o `advancePhase` (que já valida transição) — recusar a saída da fase comercial
   enquanto não houver revisão concluída.
2. Deixar **visível na tela** que o processo está retido por isso (senão vira o "ponto escuro" do FRG-19/29 de
   novo: bloqueio silencioso é pior que nenhum bloqueio).
3. Notificar a Qualidade quando a revisão é solicitada, e o Comercial quando o parecer sai — **mesma
   infraestrutura do B3**.

⚠️ **Não implementar antes de resolver o IND-07 abaixo.** Tornar bloqueante uma etapa cujo papel
solicitante **não tem nenhum usuário** trava o fluxo no primeiro dia.

---

### IND-07 · 🚨🚨 Três papéis do fluxo têm ZERO usuários em produção (achado meu)

**Não veio da sala.** Encontrei ao conferir quem poderia exercer o IND-06. **Consulta a produção, agora:**

| Perfil | Usuários | Papel no fluxo |
|---|---|---|
| `analista` | **15** | análise documental ✅ |
| `qualidade` | **5** | parecer de qualidade ✅ *(Elaine, Mariana, Barbara, Karoline, Osama)* |
| `gestor` | 3 | atribuição/aprovação ✅ |
| `admin` | 2 | — |
| `empresa` | 2 | cliente |
| **`comercial`** | **0** | ❌ **proposta e chamada da revisão de qualidade** |
| **`auditor`** | **0** | ❌ **auditoria estágio 1 e 2** |
| **`juridico`** | **0** | ❌ **contrato** |
| **`gestor_auditoria`** | **0** | ❌ **alocação de auditor** |

⇒ **a cadeia do processo tem 3 elos vazios**: comercial (proposta) → jurídico (contrato) → analista ✅ →
**auditor** (auditoria) → comitê → emissão.

🔴 **E isto já é concreto, não hipotético:** o processo da Minerva está **agora em `planejamento_auditoria`**
— a próxima etapa exige **auditor**, e não existe nenhum cadastrado. **O fluxo de demonstração vai parar
ali**, e por falta de gente, não por defeito de código.

📌 **É a MESMA falha de método já registrada em 31/jul**, quando o perfil `qualidade` tinha zero usuários e
mesmo assim o registro de reclamação foi restringido a ele. A lição ficou escrita: *"a restrição foi aplicada
sem antes conferir se havia quem exercesse o papel."* ⇒ o IND-06 propõe exatamente isso de novo, agora com
`comercial`. **Boa notícia: desta vez conferimos antes.**

✅ **Ponto positivo confirmado:** o perfil `qualidade` **foi criado** (5 pessoas) — a pendência de 31/jul está
resolvida. ⚠️ Pequena divergência com a lista combinada no follow-up de 03/ago (Elaine, Soha, Osama, Bárbara,
Mari, Carol): **Soha e Carol não estão**, e **Karoline** entrou. Vale conferir se é intencional.

🔧 **[Renato/FAMBRAS] — decisão operacional, não de código:**
1. **Criar os usuários `auditor`** antes de qualquer demonstração passar de planejamento de auditoria.
2. Definir se **`comercial` e `juridico`** terão gente própria ou se `gestor` acumula esses papéis no
   go-live. **Isso muda o IND-06, o FRG-16 e o FRG-25** — os três assumem um comercial que hoje não existe.
3. Se a resposta for "gestor acumula", então as regras devem citar `gestor` explicitamente, e não presumir
   perfis vazios.

---

### IND-08 · 🚨 Validação de Viabilidade (IT 7.4) nunca foi salva — e por DOIS motivos

**Como veio:** analista marca os 3 itens da **Validação de Viabilidade (IT 7.4)** e clica em *Salvar
Verificação* → **"Apenas solicitações em rascunho podem ser atualizadas"**.
Certificação `HS-2026151500508-01192` (`e2f87449-…`), categoria `CII - Processamento de produtos vegetais
perecíveis`.

📌 **Sobre "já havia sido comentado com o time de Frigorífico":** este erro **não está** entre os 32 achados
do Dia 1 — ou não chegou até mim, ou passou no meio da sequência. Fica registrado agora, e o diagnóstico
serve para os dois times.

**O caminho está certo; o destino é que está quebrado.** O front chama corretamente
`PATCH /certification-requests/:id/viability`, e a rota existe (`@Roles('admin','gestor','analista')`). Mas o
handler delega para o `update()` genérico:

```ts
// certification-request.controller.ts:365
return this.service.update(id, { viabilityChecklist: {...} } as any);
```

E o `update()` (`certification-request.service.ts:562-578`) tem **dois problemas independentes**:

**1. Trava categoricamente errada.**
```ts
if (request.status !== RequestStatus.rascunho)
  throw new BadRequestException('Apenas solicitações em rascunho podem ser atualizadas');
```
A viabilidade IT 7.4 é preenchida **pelo analista, depois que a solicitação chega** — por definição a
solicitação **não é mais rascunho** nesse momento. A trava impede exatamente o uso pretendido.
*(Medido: as 2 solicitações em prod estão em `em_analise`; **nenhuma** em rascunho.)*

**2. 🚨 Ainda que a trava passasse, o campo NÃO seria gravado.** O `update()` só escreve
`changeDescription` e `changeType` — **`viabilityChecklist` não aparece no `data`**. O `as any` do controller
é o que esconde isso do compilador: sem o cast, o `tsc` teria acusado que o DTO não tem o campo.

⇒ **em rascunho: salva "com sucesso" e descarta em silêncio. Fora de rascunho: erro 400.**
**Não há estado em que a validação de viabilidade funcione.**

📊 **Confirmado em produção:** `certification_requests` = **2 linhas**, com `viability_checklist` preenchido
= **0**. Nunca foi salvo, nem uma vez.

🏛️ **Peso:** IT 7.4 é a checagem de que a FAMBRAS **pode** aceitar o pedido — equipe técnica disponível e
reconhecimento para a categoria. É registro de decisão de aceitação (ISO 17065): existe na tela, é marcado
pelo analista e **não fica em lugar nenhum**.

**Conserto (pequeno, mas em 2 pontos):**
1. `saveViabilityChecklist` deve gravar **direto** o campo `viabilityChecklist` — sem passar pelo `update()`
   genérico e **sem `as any`** (o cast é o que permitiu o bug).
2. Não aplicar a trava de rascunho a este caminho. A trava faz sentido para editar o **conteúdo da
   solicitação**; não faz para o **parecer interno da FAMBRAS sobre ela**.
3. Gravar **quem** validou e **quando** — o handler já monta `checkedAt`/`checkedBy`, é só persistir.

⚠️ **Lição de método:** `as any` num `service.update(...)` foi o que transformou dois defeitos em zero erros
de compilação. Vale procurar outros `as any` em chamadas de serviço — mesma classe do FRG-19
(`certification.company`) e do FRG-27 (`razaoSocial`): **o tipo existia e foi contornado.**

**Encaminhamento:** 🔴 **P0** — é uma etapa obrigatória do processo que não registra nada. Back,
`certification-request/*` (⚠️ sem trilha declarada — 5ª ocorrência do buraco do §2). **Bloco novo B11**, ou
anexar ao B1 se a sessão back estiver livre: mesmo repo, arquivos diferentes.

---

### IND-09 a IND-12 · Reclamações e Apelos (PR 7.13) — 4 lacunas no ciclo de vida

**Contexto:** as 2 primeiras ocorrências foram criadas em 11/ago pela equipe — uma **RECLAMAÇÃO** (sem
vínculo, sobre atendimento) e um **APELO** (vinculado a certificação **e** empresa, sobre conduta de
auditor), ambos `registrada`, canal e-mail, **0 pareceres**. O modelo é **um só** (`Complaint` com `type`
`RECLAMACAO` × `APELO`) e o ciclo tem 8 status: `registrada` → `em_analise` → `comite_formado` →
`analisada` → `respondida` → `resolvida`, mais `escalada` e `cancelada`.

✅ **O que já está bom:** o "comitê" se materializa como **N `ComplaintReview`** (recomendação + prazo +
quem revisou); `resolvedAt` é preenchido **automaticamente** ao virar `resolvida`; o anonimato **anula** o
e-mail do reclamante em vez de só escondê-lo; e `isPublic` traz a regra certa no schema — divulgação só com
*"Acordo Fambras + cliente + reclamante"*.

---

**IND-09 · Status muda sem validação e sem rastro.** `complaint.service.ts:58-71` — o `updateStatus` só
verifica se a reclamação existe e grava. **Não há máquina de estados**: `registrada` → `resolvida` direto é
aceito, e o caminho de volta também. **Nenhum histórico** é gravado; o valor anterior é sobrescrito.
⇒ **É exatamente o FRG-21** (que acabamos de corrigir no workflow), na mesma semana e em outro módulo: um
estado que governa processo mudando sem transição validada e sem trilha. Para um instrumento de PR 7.13 —
que é peça de auditoria de acreditação — a ausência de histórico é o problema maior.
**Encaminhamento:** **B1** (o bloco já domina "estado que muda sem rastro"; módulo diferente, mesmo repo).

**IND-10 · Ninguém avisa o reclamante.** O módulo `complaint/*` **não importa nada** de notificação ou
e-mail (varredura: zero referências). ⇒ quem reclama **não recebe acuse de recebimento nem a resposta**; a
empresa que apela não sabe que o apelo andou. Para ISO 17065 o organismo deve **acusar recebimento** e
**comunicar o resultado** — hoje isso só acontece se alguém escrever o e-mail à mão, fora do sistema.
⇒ terceira ocorrência do mesmo padrão em dois dias (FRG-29 solicitação, FRG-30 entrega, agora reclamação).
**Encaminhamento:** **B3**, que já vai construir o disparo — aqui é mais um gatilho, não outra
infraestrutura. Mínimo: **acuse ao registrar** + **aviso ao responder/resolver**.

**IND-11 · Não existe prazo na reclamação.** `deadline` existe apenas no **parecer** (`ComplaintReview`),
não no `Complaint`. ⇒ não há SLA de resposta ao reclamante, nem como saber que uma reclamação está vencendo.
❓ **Falta o dado de negócio:** qual é o **prazo de resposta** da FAMBRAS para reclamação e para apelo (são
iguais?). Com o número em mãos, é campo + alerta — pequeno. Sem ele, não dá para codar.
*(Precedente: o SLA de 48h da lista viva de MP foi decidido assim, em 27/jul.)*

**IND-12 · A empresa não enxerga o próprio apelo.** As roles de leitura são `admin`, `gestor`, `analista`,
`gestor_auditoria`, `qualidade` — **`empresa` não está**. Mas `APELO` é, por definição do schema, *"empresa
contra decisão de certificação"*. ⇒ a empresa abre o apelo por telefone/e-mail, a Qualidade registra, e a
empresa **não acompanha nada** — nem status, nem parecer, nem resposta.
⚠️ É **consequência direta e provavelmente não intencional** do Lote 6.3 (30/jul), que restringiu o
**registro** à Qualidade — mas a decisão foi sobre **quem registra**, não sobre **quem lê**.
❓ **[FAMBRAS] decidir:** a empresa passa a **ver** os apelos dela (leitura escopada ao próprio
`companyId`), ou o acompanhamento segue fora do sistema? ⚠️ Se for liberar, é rota escopada — **e o
histórico do IND-09 vira pré-requisito**, porque a empresa passaria a ver um status que muda sem rastro.

---

### IND-13 · Agendar Auditoria — endereço vazio, e dois problemas de brinde

**Como veio:** *"deveria trazer automaticamente os dados de endereço, pelo menos."*

**Confirmado:** `AuditScheduleModal.tsx:44` inicializa `address: ''` e **nunca** busca o endereço da planta. Pior:
a linha 69 o torna **obrigatório** quando presencial — então o analista é obrigado a digitar à mão um dado que
o sistema já tem. A tela de detalhe da certificação **exibe** `facility.address` (linha 823), ou seja o dado
está ali, na mesma página que abre o modal.

🎁 **Dois achados de brinde no mesmo modal:**
- **"Tipo de Auditoria" aparece DUAS vezes**, rotulando coisas diferentes: primeiro o **estágio** (Estágio 1 —
  Auditoria Documental) e depois a **modalidade** (Presencial / Remota). O segundo deveria ser *"Modalidade"*.
- 🔴 **O default contradiz o padrão da FAMBRAS.** Com "Estágio 1 — Auditoria Documental" selecionado, a
  modalidade vem **Presencial** e o endereço passa a ser obrigatório. Mas o próprio `.odt` de contato inicial
  (FRG-28) diz: *"A auditoria de Estágio 1 é realizada **de forma remota** e contempla a análise documental
  da planta."* ⇒ **Estágio 1 deveria vir Remota por padrão**, e nem pedir endereço.

**Encaminhamento:** 🟢 lote pequeno — pré-preencher com o endereço da planta (editável, porque auditoria pode
ocorrer em endereço diferente), renomear o segundo rótulo para "Modalidade", e amarrar o default da
modalidade ao estágio.

---

### IND-14 · 🚨 Sugestão de auditores: três causas empilhadas, todas precisam cair

**Como veio:** *"por que não vejo sugestão de auditores?"* — a tela `/gestor/alocacoes` diz **"0 sugestões
pendentes"**, com o texto *"Sugestões são geradas automaticamente quando um workflow avança para a fase de
planejamento de auditoria"*. E o workflow da Minerva **está** em `planejamento_auditoria`. Então deveria ter
gerado.

**Investiguei. Não é uma causa — são três, e cada uma sozinha já zeraria o resultado:**

**1. O matcher exige `role === 'auditor'` — e não existe nenhum.**
`matching.service.ts` percorre as competências e faz `if (comp.auditor.role !== 'auditor') continue;`.
Como medido no **IND-07**, o perfil `auditor` tem **zero usuários** em produção. ⇒ o mapa de candidatos é
sempre vazio. **Esta é a previsão do IND-07 se materializando**, três horas depois de eu registrá-la.

**2. O matcher lê a representação ERRADA da categoria industrial.**
Ele usa `certification.industrialCategory?.code` — o **FK escalar** `certifications.industrial_category_id`.
Medido em produção:

| Onde a categoria está | Certificações |
|---|---|
| **Tabela M:N** `certification_industrial_categories` (o que o wizard grava) | **1.190** |
| **FK escalar** `certifications.industrial_category_id` (o que o matcher lê) | **180** |

A certificação da Minerva é o caso exemplar: **FK escalar NULL**, mas **2 linhas na M:N** (`CV - Abate de
animais` e `GI - Transporte e armazenamento`) — que é exatamente o que a tela de detalhe mostra. ⇒ o wizard
grava certo e completo; **o matcher consulta o campo vazio**.

**3. A falha é silenciosa.** O hook em `workflow.service.ts:1316-1323` chama o sugeridor dentro de um
`try/catch` que só faz `logger.warn`. ⇒ a fase avança, a exceção morre no log, e a tela mostra "Nenhuma
sugestão pendente" **como se fosse estado normal**. Ninguém tem como distinguir "não havia o que sugerir" de
"o sugeridor quebrou".

⚠️ **Terceira ocorrência HOJE do mesmo padrão estrutural — vale nomear:** *dois lugares guardam o mesmo fato,
e o código lê o lugar errado.*
- **FRG-32:** o PDF **deriva** o selo × a coluna `market_variant` que a validação pública lê está NULL
- **IND-04:** o **preço** lê `certificationType` × os **dias de auditoria** leem `categoryCode`
- **IND-14:** o **matcher** lê o FK escalar × o **wizard** grava na M:N

**Encaminhamento:** 🔴 **P0.** Ordem obrigatória: **(a)** criar os usuários `auditor` — sem isso nada mais é
testável (🔧 **[Renato/FAMBRAS]**, IND-07); **(b)** o matcher passa a ler a **M:N** (com fallback para o FK
escalar, pelas 180 do acervo); **(c)** a falha do sugeridor deixa de ser silenciosa — se não houver
candidato, dizer **por quê** na tela ("nenhum auditor com competência para a categoria X" × "nenhum auditor
cadastrado").

---

## 5-C. Achados — Dia 3 · **12/ago** · equipe **CONTROLADORIA INDUSTRIAL**

> 🏁 **MARCO: 12/08/2026 — terceiro dia do presencial.** Dia 1 (Frigorífico) = **32** achados `FRG-nn`;
> Dia 2 (Industrializados) = **15** `IND-nn`. Numeração deste dia: **`CTR-nn`**.
> Valem as mesmas regras do §0 (zero código na sala; pergunta que der para resolver na hora, pergunte)
> e a classificação do §1.

### 🖥️ Ambiente sob validação — CONFIRMADO DE FORA (12/ago, ~09h25)

| Camada | Em produção | Prova (asset servido / sonda, não a listagem do console) |
|---|---|---|
| **GC front** | **`2dff97a4`** (build `index-CkGmw16Z.js`) | `"Produtos químicos"` no bundle ⇒ rótulos C1–C6 (IND-04 c) · chunk `CertificationDetails-CU8Xgtzn.js` (144 KB) contém **"Trocar auditor"** e **"Motivo da troca"** (IND-15) e **"Controle Halal"** com **zero** ocorrência do termo antigo (FRG-03) |
| **GC back** | **`6ebb03c5`** | `release` com `0 ahead / 0 behind`; API viva e guardada — rota real → **401** do guard, rota inexistente → **404** do Nest |
| **URL** | `https://gestaodecertificacoes.ecohalal.solutions` | — |

📌 **Correção ao §1 do BACKLOG:** o front `2dff97a4` (IND-04 c) constava como *"1 commit local"* — **está pushado
e no ar**. Atualizar o retrato.

🚨 **Deploy em voo às 09h23–09h26 — e a armadilha que ele deixa para a sala.** Enquanto sondava, o
`index.html` ainda apontava para o build anterior (`index-B5BffeBP.js`) cujos **chunks de rota já tinham sido
apagados do S3**: `/assets/CertificationDetails-Dyd1cuyE.js` respondia **200 com o `index.html`**
(`Content-Type: text/html`) — 404 mascarado de sucesso pelo fallback de SPA. Já normalizou no build novo.
⇒ **Regra do dia: todo mundo dá `Ctrl+F5` antes de começar, e de novo depois de qualquer deploy.** Quem ficar
com a aba aberta de um build antigo toma *"Failed to fetch dynamically imported module"* / tela branca ao
navegar — e isso vira achado falso.

### ⚙️ O que MUDOU em produção desde ontem — não re-reportar

Seis lotes + IND-15 subiram em 12/ago. **Nenhum tem rota nova ⇒ nenhum tem observável externo próprio; a
prova é funcional.**

| Achado | Estado |
|---|---|
| **FRG-07 · FRG-10** — PCCH sem `@Roles`/sem recorte + comentário interno vazando por query param | ✅ em prod (`3529aa7a`) — leitura = equipe FAMBRAS, escrita = analista/gestor/admin, `empresa` fora |
| **FRG-03** — termo proibido na Matriz PCCH | ✅ em prod (`b5cb53f4`) — "Pontos Críticos **de Controle Halal**" |
| **FRG-31 p3 · IND-10** — rejeitar documento e ciclo de reclamação mudos | ✅ em prod (`3fba0320`) — rejeição notifica **com motivo**; reclamação tem acuse + aviso à qualidade |
| **FRG-04** — vigência/emissão exibindo 1 dia antes | ✅ em prod (`78668f64` + `e8671895` TZ=UTC) |
| **FRG-32 p1** — PDF e QR discordando do selo | ✅ em prod (`6ebb03c5`) — selo congelado na geração. ⚠️ **corrige os novos, não os 3 que já divergem** |
| **IND-04 (c)** — rótulos C1–C6 (4 listas divergentes no front) | ✅ em prod (`2dff97a4`) — fonte única; enum mantido (o preço-base depende dele) |
| **IND-15** — trocar auditor / reagendar | ✅ em prod (`60eee058` + `c395d07b` + `71246f92`) — motivo **obrigatório** + `AuditTrail`; card não some mais fora do planejamento |
| **Aprovar sugestão de alocação não designava ninguém** | ✅ em prod (`10d7c77c`) — corrigido na origem e no destino; cobre as 2 alocações órfãs que já existem |

### 🚫 O que NÃO demonstrar (ou demonstrar avisando)

- **Verificação pública do QR nos 3 certificados que já nasceram sem selo** (dos 180 sem `market_variant`,
  3 têm PDF): a parte 2 do FRG-32 é **dado**, não foi feita — o papel e a validação online ainda divergem ali.
- **Trocar o auditor entre as sugestões ANTES de aprovar** (`modify`): a rota existe, **nenhuma tela a chama**.
  O caminho que funciona é aprovar e depois trocar com motivo. ❓ decisão do Renato se entra.

### 👀 Watch-list específica — CONTROLADORIA INDUSTRIAL

| # | Ponto | Por quê |
|---|---|---|
| **W-1** | ⚠️ **`controlador` é real no SIH e cego no GC — não confundir os dois sistemas.** | **No SIH (validado hoje) o perfil existe de verdade:** menu "Controladoria" (`Sidebar.tsx:72`), rota `/controladoria` e 3 rotas de backend `@Roles('controlador')` — fila, histórico e métricas. **No GC é o oposto:** `controlador` está no enum `UserRole` e tem badge, mas **não tem `case` no `Sidebar.tsx`** → `default: []` = **menu vazio** (mesmo caso de `financeiro`, `supervisor`, `secretaria`; pendência do §4.1 desde 09/ago, sem decisão). ⇒ se esta equipe também precisar entrar no **GC**, o login dela nasce cego lá |
| **W-2** | **Casos de teste prontos, que só este dia pode exercitar** | (a) **3 reclamações de 11/ago** (2 reclamação + 1 apelo, todas identificadas) são **anteriores** ao B3b ⇒ não tiveram acuse; **responder qualquer uma agora dispara o e-mail de resultado** · (b) alocação **`sugerida`** pendente → **aprovar designa o auditor**; a `aprovada` de 11/ago é anterior ao fix e **não se auto-corrige** · (c) **1ª atribuição/reatribuição de analista** cura `certifications.analyst_id` (Minerva segue **NULL**) · (d) **Viabilidade IT 7.4: 0 de 2** com checklist — gravar uma é a prova do B11 |
| **W-3** | **FM 7.8.1 ATIVOS nunca foi carregado** | Se disserem "faltam certificados industriais nossos", **é carga pendente da FAMBRAS**, não bug |
| **W-4** | **0 de 306 pessoas ativas do FM 6.1.4 têm login** | Pré-requisito de qualquer trava por competência. Se cobrarem "o sistema devia barrar quem não é qualificado", é isto |
| **W-5** | **Defeitos de fluxo dos Dias 1 e 2 são agnósticos de segmento** | Reaparecendo, registrar como *confirmação em 3º departamento* (fortalece prioridade), **não** como achado novo |

### Achados do Dia 3

> **Sistema sob validação hoje: SIH** (`supervisao-industrial.ecohalal.solutions`), não o GC.
> Sessão do supervisor **Pablo Rodrigues Santos** (`pablo.santos@fambrashalal.com.br`, divisão **IND**).

| ID | nº na sala | Tipo | Tela | Resumo | Dono | Estado |
|---|---|---|---|---|---|---|
| **CTR-01** | 1 | 🔧 cadastro + 🎨 UX | Produção → Novo (FM 7.1.3.1) | Supervisor não vê **nenhuma planta**. **Não é bug:** as 2 plantas dele são `frigorifico` (IN) e `curtume` (IND), e Fabricação exige `processamento` — o filtro casa `type` **ou** `capabilities` e está correto. Sobra um problema de texto: o aviso manda **"solicite ao administrador o vínculo de uma planta"**, mas ele **tem** vínculo — o que falta é a planta declarar a atividade | 🔧 Renato/FAMBRAS + Claude (texto) | 🟢 diagnosticado |
| **CTR-02** | 2 | 🧩 GAP — **capacidade pronta, porta ruim** | Embarque → Produtos | Produtos/quantidades deveriam vir **de uma lista de relatórios de produção, item a item**. O vínculo **já existe** (M:N + A2 + "aplicar composição derivada") mas: **(i)** a composição só existe **depois de salvar** — na criação não há lista para escolher; **(ii)** aplicar é **tudo ou nada**; **(iii)** a **quantidade não vem** da produção (`quantity: 0`; só o peso agregado) | Claude → §4.2 | 🟡 3 fatias sobre base pronta |
| **CTR-03** | 3 | 🧩 GAP + ❓ | Embarque → Exportador/Importador | Dados de empresa deveriam vir **pré-preenchidos**. `exporter`/`importer` são **texto livre**; o SIH **não tem model Company** — a identidade vive na planta (`cnpj`, `name`, `externalCompanyId` do GC) | Claude + ❓Renato | 🟡 decidir a fonte: planta × GC |
| **CTR-04** | 4 | 🐛 + 🧩 | Embarque → Origem/Destino | Origem deveria ser **pré-preenchida** e escolhida **da base** por SIF/CNPJ/nome. **(i) 🐛** o prefill existe mas compara `plant.type` direto: só frigorífico/abatedouro preenchem *Abatedouro*, só processamento preenche *Unidade de Produção* ⇒ **`curtume` não preenche nenhum dos dois** (o caso Sol Couros do print), e planta com `capabilities` também fica de fora. **(ii) 🧩** origem é **texto livre** enquanto o **destino já escolhe da base** (seletor de planta + prefill de endereço/CNPJ + `lookupCnpj`) — assimetria, com o padrão a reusar no mesmo arquivo | Claude → §4.2 | 🟢 **(i) é fix pequeno** |

| **CTR-05** | 5 | 🧩 GAP + ❓ **estrutural** | Config → FM × anexos | Tela para **correlacionar FM x.x.x.x com anexos obrigatórios** e montar o formulário conforme. Metade da espinha existe: há **registry por FM** (`FmConfig`) que já monta as verificações da tela. Do lado do anexo **não há nada**: `category` é string **nullable** contra lista fixa no service, **sem** obrigatoriedade e **sem** relação com o FM | Claude + ❓Renato/FAMBRAS | 🟡 **tamanho depende de 2 decisões** |

### 📦 ENTREGUE EM 12/ago — commitado, **ainda NÃO pushado** (aguarda OK)

| Repo | Commit | Achados |
|---|---|---|
| **sih-frontend** | `7fac2ad` | **CTR-04(i)** prefill lê `capabilities` e cobre curtume · **CTR-03** exportador vem da planta · **CTR-01(b)** aviso com os dois caminhos |
| **sih-backend** | `6192cec` | **CTR-05 back** — model + migration idempotente + CRUD + trava aditiva no `sign` de produção e embarque · swagger + **3 JSONs do API GW** regenerados no mesmo commit |
| **sih-frontend** | `65d28e5` | **CTR-05 front** — tela `/anexos-obrigatorios` + checklist de pendência dentro dos formulários |

Validação local: back `tsc --noEmit` 0 · **jest 37/37** (5 casos novos) · front `tsc -b` 0 e `vite build` limpo.

✅ **EM PRODUÇÃO — validado DE FORA em 12/ago ~13h32 (não pela listagem do console):**

| Prova | Resultado |
|---|---|
| Rota nova, sem token | `/fm-required-attachments` **404 → 401** do guard (era 404 do Nest antigo) ⇒ código novo no ar |
| Preflight `OPTIONS` | **200** com `Access-Control-Allow-Origin` correto ⇒ **sem import manual no API Gateway** |
| Migration | `20260812130000_fm_required_attachments` gravada em `_prisma_migrations` às **16:32:37 UTC**, 1 passo, sem rollback |
| Matriz | tabela existe e tem **0 linhas** — nasce vazia, como decidido |
| Enum | `FmReportKind` = `producao`, `embarque` (abate fora, por desenho) |
| Front | bundle `index-q9XdjYtL.js` contém "Anexos Obrigatórios", a rota e o texto novo do aviso; **não** contém "Buscar na base" (CTR-04(ii), não pushado) — o zero é o controle da sonda |

📌 **Lição do dia (método):** o **API Gateway do SIH não precisou de import** e a prova é o CORPO do 404, não o
código. `/fm-required-attachments` devolvia 404 **do NestJS** (`"Cannot GET"`, com `timestamp` e `path`) e
headers `x-amzn-Remapped-*` ⇒ o gateway já proxyava; um prefixo de fato desconhecido devolve
`{"message":"Missing Authentication Token"}`, que é resposta **do gateway**. Distinguir os dois 404 evitou
diagnosticar "falta rota no gateway" quando o que faltava era o deploy do ECS terminar.

⚠️ **Janela de risco observada:** o **front subiu antes do back** — por ~1h o menu "Anexos Obrigatórios"
existia sem as rotas correspondentes. Não quebrou nada (o checklist some quando a consulta falha), mas a
tela de configuração daria 404 a quem abrisse. **Em deploy de par back+front, avisar a sala.**

⚠️ **Duas decisões que eu tomei ao implementar, ambas reversíveis, ambas precisam do seu aval:**

1. **Abate ficou FORA da matriz** — não por esquecimento: `report_attachments` só tem FK para
   embarque e produção. Exigir anexo em FM de abate criaria regra **incumprível**. Se abate precisar de
   anexo, é item novo (FK + upload + tela), não configuração.
2. **Escrita é `admin` + `coordenador`, não "Qualidade"** — o SIH **não tem** o perfil `qualidade` no enum
   `UserRole` (só `admin`, `coordenador`, `supervisor`, `operador`, `controlador`; em prod: admin 5 ·
   coordenador 1 · supervisor 73 · controlador 6). Restringir a um perfil sem usuários foi exatamente o erro
   do GC em 31/jul, que deixou a reclamação inacessível por semanas. Criar um `qualidade` de verdade no SIH
   é item separado (enum + menu + usuários); a troca depois é de uma linha.

### ✅ DECISÕES DA SALA — 12/ago (respostas do Renato). **Não re-litigar.**

| # | Pergunta | Decisão | O que ela custa |
|---|---|---|---|
| **D1** | Embarque consome **parcial** de uma produção? | ✅ **SIM, parcial.** E precisa de **tela de pendências**: quais relatórios de produção ainda têm saldo não relacionado a embarque | 🔴 **migration** — o vínculo hoje **não tem quantidade** (PK `shippingReportId+productionReportId` e nada mais). Sem coluna de consumo não existe saldo nem pendência |
| **D2** | Matriz FM × anexo é fixa ou configurável? | ✅ **Configurável em tela** | 🔴 tabela nova + CRUD + tela. ⚠️ deixa o modelo **partido**: anexos viram dado, `verifications` continuam código |
| **D3** | Anexo faltando trava ou avisa? | ✅ **TRAVA na assinatura do supervisor** | 🟡 validação no `PATCH /:id/sign`. ⚠️ **risco operacional** — ver mitigação abaixo |

**🛡️ Mitigação recomendada para o D3 (decisão do Renato pendente):** a matriz **nasce vazia** e a Controladoria
liga anexo por anexo. Assim a trava entra sem parar a operação no dia 1 — hoje **nenhum** relatório do acervo
tem anexo obrigatório, e ligar a matriz cheia de uma vez trava toda assinatura em campo, com supervisor em
planta e sem suporte. É o mesmo raciocínio que fez o GC escolher "avisar" nas 188 evidências vencidas, só que
aqui a trava é a decisão — o que se controla é **quando cada linha passa a valer**.

**✅ 3 perguntas de desdobramento — RESPONDIDAS na mesma sessão:**

| # | Pergunta | Decisão | Consequência |
|---|---|---|---|
| **D4** | Unidade do saldo | ✅ **Por produto / lote** | A chave é `(productCode, productBatch)`. Direto para os tipos com produto em coluna; **raspa, tripas e gelatina guardam vários produtos finais dentro de `customFields` (Json)** ⇒ para esses, estruturar o Json entra no caminho crítico (é o **GAP-3 de 14/jun**, já registrado como pré-requisito) |
| **D5** | Rascunho reserva saldo? | ✅ **NÃO reserva** — só o consumo efetivo conta. Justificativa do Renato: **não há mais de 1 supervisor por planta** responsável pelos relatórios ⇒ sem corrida por saldo | Simplifica muito: nada de reserva, expiração de rascunho ou lock. ⚠️ **A premissa fica registrada**: se um dia houver 2 supervisores na mesma planta, o saldo passa a poder ser vendido duas vezes |
| **D6** | Quem edita a matriz FM × anexo | ✅ **Qualidade + Admin** | Escrita = `qualidade` e `admin`; leitura = quem preenche relatório. ⚠️ `controlador` **não** edita — ele consome a exigência na fila de conferência |

### 🧪 Bloco da tarde — equipe **QUALIDADE** (mesmo dia 12/ago). Numeração `QA-nn`.

| ID | nº na sala | Tipo | Tela | Resumo | Dono | Estado |
|---|---|---|---|---|---|---|
| **QA-01** | 1 | 🧩 GAP + 🏛️ perfil novo | SIH → Ocorrências | **Perfil `qualidade` no SIH** aprovando ocorrência (FM 20.1 aves e **20.2 industrializados**): supervisor preenche, anexa, assina → QA aprova ou reprova **com justificativa** → supervisor **reabre e ajusta**. Mais um **campo de comentário do QA** que vai para o BI da empresa. **Metade da máquina existe** (status/`approve`/`reject`/`reopen` do embarque), mas **nada disso alcança a ocorrência** — e há 3 impossibilidades hoje: perfil, anexo e o FM 20.2 | Claude → §4.2 | 🟡 4 fatias, 1 delas nova |
| **QA-02** | 2 | 🧩 GAP + 🔀 **integração em sentido novo** | GC → Painel de Produção | Painel **no GC** (a empresa já tem acesso lá; **não se quer dar acesso de empresa no SIH**) com os comentários do QA, indicadores de NC e **Atas de Comitê Halal** lançadas pelos supervisores no SIH. ⚠️ Hoje a integração é **GC → SIH**; isto exige **SIH → GC**, que não existe. **Ata de Comitê não existe em lugar nenhum** (grep vazio nos dois repos) | Claude + ❓ | 🔴 depende do modelo da **Carol** |
| **QA-03** | 3 | 🧩 GAP (tela nova) | SIH → monitoramento | **Calendário por planta** evidenciando a existência do relatório de ocorrência dia a dia, para acompanhar se o supervisor cumpre a entrega diária. Modelo visual trazido na sala (heatmap por SIF, com "lag típico" e "último dado") | Claude → §4.2 | 🟢 dado existe; falta agregação + tela |

| **QA-04** | 4 | 🧩 GAP (módulo novo) — **declarado "não é agora"** | GC → biblioteca normativa | Após aprovação no comercial, a empresa recebe por e-mail a **lista de documentos que precisa tomar conhecimento** (PDFs de normas e DTs). Passar isso para o sistema, **sempre na versão mais recente e com essa garantia**; e a cada atualização de norma, **mala direta por categoria** + **alerta em tela no próximo login**, que só some quando a empresa acessa a documentação nova | Claude + ❓ | ⏭️ **pós-go-live** |

| **QA-05** | 5 | 🐛 fonte de dados | **GC** → Calendário | QA precisa ver o **calendário de auditorias**, e os eventos devem **permanecer historicamente** (padrão Google/Outlook). **O perfil já tem o menu** — o defeito é a consulta: a tela busca `getUpcomingAudits(90)` + `em_andamento`, ou seja, **só futuro e em curso**. Auditoria **concluída desaparece** do calendário | Claude → §4.2 | 🟢 **fix pequeno, front** |

### ❌🔍 CORREÇÃO DO IND-06 (12/ago, tarde) — a premissa estava errada

O IND-06 do Dia 2 registrou *"revisão de qualidade obrigatória e bloqueante na Certificação Inicial"* com a
pergunta aberta **"quem executa a revisão"**. A resposta veio da própria Qualidade, na sala: **não é a equipe
de QA quem faz essa revisão.** ⇒ o escopo da tela `/qualidade/revisoes` **precisa mudar**; ela está no menu do
perfil errado.

✅ **RESPONDIDO na mesma tarde (Renato):** o instrumento é o **FM 7.1.9**, que deve ser tratado **dentro do
perfil comercial, como uma SUB-FASE**; o executor é **um analista do departamento COMERCIAL** — que
eventualmente tira dúvida com a QA, mas não é da QA. O nome "revisão de qualidade" é o erro de origem.

🔍 **E a verificação encontrou o que ninguém tinha percebido: o FM 7.1.9 JÁ ESTÁ CONSTRUÍDO no GC, em três
módulos, com três donos diferentes em código — e nenhum deles tem tela.**

| Módulo | O que faz | `@Roles` | Tem tela? |
|---|---|---|---|
| **`request-review-report`** | O relatório do FM 7.1.9: **1:1 com a solicitação**, com os parâmetros (turnos, funcionários, categorias, produtos, fornecedores, APPCC), o cálculo (dias base GSO/SMIIC, **redução de 0-30%**, dias finais, notas) e a **decisão** — `pending · approved · needs_changes · rejected` com notas e revisor | `admin`, **`analista`** | ❌ **ZERO consumidores** (varri `src/` inteiro do front) |
| **`audit-days`** | A calculadora "dias de auditoria conforme FM 7.1.9 + IT 7.4" | `analista`, `gestor`, `admin`, **`comercial`**, `gestor_auditoria` | ❌ o front só usa dias-por-categoria da classificação industrial, que é outro caminho — **é o FRG-16** |
| **`quality-reviews`** | A "revisão de qualidade" — solicitada por comercial/gestor/admin, **concluída SÓ por `qualidade`** | `qualidade` no `complete` | ✅ tem tela, e é a do **perfil errado** |

❌🔍 **CORREÇÃO (13/ago, com o FM em mãos): "é só ligar" está ERRADO.** O Renato enviou o
`FM 7.1.9 - REVISÃO DA SOLICITAÇÃO E CALCULO DIAS DE AUDITORIA (REV 11)`. Lido campo a campo contra o
`RequestReviewReport`, o modelo do GC cobre **uma fração** do formulário:

| No FM REV 11 | No modelo do GC |
|---|---|
| Nº de APPCC (**número**) · nº de colaboradores no maior turno · categoria (A–K, "a de maior dificuldade") | ⚠️ `hasAPPCC` é **booleano**, não número · `numEmployees` ✅ · categoria ✅ |
| **Com inclusão do Golfo?** (S/N) — e o Golfo **proíbe estágio 1 e 2 no mesmo dia** | ❌ não existe |
| **A empresa tem filiais?** + quais — o cálculo tem linhas próprias de **filial** | ❌ não existe |
| **Existe sistema de gestão certificado?** | ❌ não existe |
| **3 itens de conformidade da revisão** (campos do FM 7.2.1 completos · equipe técnica apta · FAMBRAS reconhecida na categoria), cada um Conforme/Não Conforme | ❌ só existe a decisão final (`decision` + `decisionNotes`) |
| **Responsável pelo preenchimento** × **Responsável Técnico da Área** (Lina ou Islam) | ⚠️ só `reviewedById` |
| **9 durações calculadas**: estágio 1 (30%) e estágio 2 (70%) com arredondamento · filial inicial · manutenção matriz (1/3) e filial · renovação matriz (2/3) e filial · **HD (homem/dia)** | ❌ só **um** `finalAuditDays` |
| **Dados finais da auditoria**: supervisão (**fixo × por campanha**), nº de **auditores muçulmanos**, nº de especialistas técnicos, total da equipe | ❌ nada disso existe |

⇒ **Revisão do encaminhamento:** ligar a tela resolve a **entrada e a decisão**; o **cálculo do REV 11 exige
estender o modelo** (as 9 durações, o Golfo, as filiais e a composição da equipe). Continua valendo que a base
existe e que o FRG-16 sai junto — mas não é um lote pequeno, e prometer "é só ligar" seria repetir o erro de
avaliar sem o documento na mão. *(Lição: eu classifiquei o tamanho olhando só o código; o papel tinha o dobro.)*

⇒ **A "sub-fase do comercial" é LIGAR o que existe, não construir.** Uma tela na fase comercial que preencha
os parâmetros, calcule os dias e registre a decisão é literalmente o que o `RequestReviewReport` já modela —
inclusive o `needs_changes`, que é o "devolve para ajuste" do fluxo. **E isso fecha o FRG-16 junto**, porque a
sugestão de dias que o comercial não enxerga é a saída desse mesmo cálculo.

📌 **A causa-raiz da confusão está no código, não na sala:** três implementações do mesmo instrumento, cada
uma autorizando um papel diferente. O `@Roles('qualidade')` no `complete` criou um dono que nunca foi o dono.
É o padrão estrutural **(1) duas fontes para o mesmo fato** somado ao **(2) capacidade sem porta de entrada** —
5º e 6º casos deste último.

❓ **O que ainda decide o desenho:** o executor entra como **`comercial`** ou como **`analista`**? (o
`request-review-report` hoje autoriza `analista`; a calculadora autoriza os dois) · a QA fica só com
**leitura** para consulta, ou entra formalmente com comentário? · **preciso do FM 7.1.9 preenchido** para
conferir se os parâmetros do modelo batem com o formulário de hoje · e a tela `/qualidade/revisoes`:
**renomeia, apaga ou vira o chamado do QA-06?**

📊 **Medido em produção hoje:** `quality_reviews` = **0 linhas**. O módulo **nunca foi usado**, o que explica o
achado ter sobrevivido tanto tempo com a premissa errada: ninguém exercitou para descobrir.

**Como o módulo funciona hoje** (levantado para responder ao Renato, vale como registro): a revisão é
solicitada na tela de **Proposta** (`/certificacoes/:id/proposta`), por **comercial/gestor/admin**, e **só na
fase `elaboracao_proposta`** — processo adiantado não tem porta. Depois: QA **assume** (`assign`) → `em
análise` → **conclui** com parecer + observações (`complete`, **exclusivo de `qualidade`**).

### QA-06 · Chamados para a equipe de Qualidade — a tela serve, o modelo não

**O pedido:** registrar solicitações dirigidas à QA — alteração de layout, **novo FM**, alteração de FM, novo
procedimento, dúvida — com **atribuição a uma pessoa da QA**, **prazo definido por ela**, **anexos**,
**comentários** dentro do chamado e **acompanhamento de status pelo solicitante**. É, na descrição do próprio
Renato, um **sistema de chamados**.

**O que dá para reaproveitar de verdade:**

| Peça | Reaproveita? |
|---|---|
| Layout da caixa de entrada (Pendentes · Em Análise · Concluídas) + filtro por status | ✅ direto |
| Máquina de estados `pendente → em análise → concluída` com `assign` e `complete` | ✅ direto |
| Tela de detalhe com parecer/observações | ✅ com renomeação dos campos |
| **O modelo `QualityReview`** | ❌ **não serve** — `workflowId` e `certificationId` são **NOT NULL**, e um chamado de "novo formulário FM" não tem certificação nem workflow |
| `Comment` para os comentários do chamado | 🟡 quase — hoje só se liga a `certificationId` (nullable). Precisa de vínculo ao chamado; o `isInternal` que ele já tem serve para separar recado interno da QA × resposta ao solicitante |
| Anexos | 🟡 mesma história do SIH: o anexo do GC hoje pende de certificação/documento |

**O que não existe em lugar nenhum e é do pedido:** **prazo** (o `QualityReview` não tem data de
compromisso), **categoria** do chamado, e a **visão do solicitante** acompanhando o próprio pedido.

❓ **Quatro perguntas que definem o desenho — nenhuma é detalhe:**

1. **Onde mora: GC ou SIH?** A QA vive no GC, mas **quem mais vai abrir chamado é o supervisor** — que só
   existe no SIH e não tem login no GC. Ou o módulo nasce no GC e os supervisores ganham acesso, ou o SIH
   ganha a tela de abertura e o chamado viaja para o GC (a mesma direção **SIH → GC** que o QA-02 exige e
   que **não existe hoje**). ⇒ **QA-02 e QA-06 compartilham essa decisão de arquitetura.**
2. **A empresa abre chamado?** Ela tem perfil no GC. Se sim, muda a visibilidade dos comentários e o texto de
   tudo.
3. **Prazo:** definido caso a caso por quem atende (foi o que a sala disse), ou existe SLA por categoria? Tem
   alerta de vencimento?
4. **A tela atual vira o chamado, ou convivem as duas?** Se a revisão de qualidade continua existindo (com
   outro executor), são dois módulos parecidos no mesmo menu — e aí o nome de cada um importa.

### ✅ DECISÕES DA NOITE DE 12/ago (Renato). **Não re-litigar.**

| # | Tema | Decisão | Consequência |
|---|---|---|---|
| **Q6** | FM 7.1.9 / IND-06 | **Executor = perfil `comercial`**; **QA fica com LEITURA** | Somar `comercial` às rotas do `request-review-report` (hoje `admin`+`analista`) e dar leitura a `qualidade`. A tela nasce na fase comercial |
| **Q7** | QA-03 · dia útil | **Seg a sex.** E **cria-se uma tela de gestão de datas**, com a **QA como dona** | Feriado deixa de ser lista fixa em código e vira **dado editável** — mesma escolha do CTR-05. Escrita = `qualidade`+`admin` |
| **Q8** | QA-01 · quem é a QA no SIH | **Equipe QA do GC = equipe QA do SIH** (mesmas pessoas) | Renato cria os usuários **pela UI** (o hash é bcrypt; não dá por SQL). Hoje `qualidade` tem **0** no SIH |
| **Q9** | QA-02 · modelo da Ata | Carol envia os dados | — |

### QA-06 · Abrir chamado dos DOIS sistemas — dá, e sem duplicar módulo

Pergunta do Renato: *"não poderíamos ter chamadas para isso a partir de ambos?"* **Dá — desde que o módulo
seja UM só.** Duplicar o módulo nos dois sistemas criaria duas filas para a mesma equipe, que é a pior
saída possível para quem atende.

**O detalhe que decide a direção já está pronto no SIH:** ele **já é cliente do GC** (`gc-integration`, com
`x-api-key` e a chave `GC_INTEGRATION_API_KEY` na task definition, em prod desde julho). Ou seja, **SIH → GC
é a direção que tem encanamento**; GC → SIH não tem nada.

⇒ **Desenho recomendado:** o módulo vive no **GC** (onde a QA e a empresa já têm login), e o **SIH ganha uma
tela fina de abertura e acompanhamento** que fala com o GC pelo cliente que já existe. Uma ponta nova de cada
lado, não dois módulos. **Bônus:** é a mesma direção que o **QA-02** precisa para o painel de produção — as
duas demandas passam a compartilhar a mesma estrada, em vez de abrir duas.

⚠️ **A modelagem tem um detalhe que morde depois se for ignorado:** o supervisor **não tem usuário no GC**,
então o `requestedBy` do chamado **não pode ser um FK de `User` do GC** para chamado aberto no SIH. Precisa de
`origin` (`gc` | `sih`), FK nullable e a identidade do solicitante em texto + id do SIH. Sem isso, ou o
chamado do supervisor não grava, ou alguém cria usuário-fantasma no GC para tapar o buraco.

### 📄 MATERIAL DA CAROL — lido e transformado em spec (12/ago, noite)

Arquivos em `C:\HalalSphere\PRESENCIAL 10-14\QUALIDADE\` (fonte externa, **fora do git** — versionar).

**✅ FM 20.1: o implementado é FIEL ao papel.** Conferência campo a campo contra o modelo preenchido
(JBS Nova Veneza, SIF 1155, 03/08/2026):

| No papel | No banco |
|---|---|
| Testes de disco: TURNO · HORÁRIO · LINHA · VELOCIDADE (aves/h) · MAL SANGRADO · NÃO SANGRADO | `BirdDiscTest`: `shift, time, line, speedPerHour, poorlyBled, notBled` ✅ |
| Insensibilização: LINHA × TURNO × 1º/2º monitoramento — Voltagem, Amperagem, Frequência, Tempo de cuba, Tempo de retorno | `BirdStunningParam`: `line, shift, monitoring, voltage, amperage, frequency, cubeTime, returnTime` ✅ |
| Cabeçalho: JBS/Seara → `qualidade@` + `mohamed.elsharif@` · BRF e outras → `qualidade@` + `adel@` | `notification_routes` **em prod**: `jbs_seara` (matchSifs `1155`) e default "BRF e Outras" ✅ |

⇒ **nada a corrigir no 20.1.** Falta nele o fluxo de aprovação (QA-01) e o **anexo** — que o próprio FM exige
(*"forneça evidências, como fotos"*), confirmando por escrito a decisão Q3.

**🆕 FM 20.2 — REGISTRO DE OCORRÊNCIAS INTERNAS (REV 1), DIÁRIO (decisão Q10).** Estrutura completa:

| Bloco | Campos |
|---|---|
| **Identificação** | Empresa (nome e cidade) · SIF · Data · Nome do supervisor · **"Você foi presencialmente na unidade hoje?" (S/N)** |
| **Matérias-primas** | recebeu MP hoje? · MP cárnea com Certificado Halal **ou** Relatório de Transferência? · demais MPs constam no **FM 7.4.2.7**? · descritivo de MP sem documentação válida |
| **Produto** | houve produção Halal hoje? · higienização antes do início? · armazenado segregado e identificado? · selo apropriado ao mercado destino? · descritivo de risco de contaminação |
| **Expedição** | houve expedição hoje? · mercado interno? · outro país? · **quais países** (texto) · foi para entreposto? · contêiner exclusivamente Halal? · descritivo das condições de transporte |
| **Outros** | descritivo livre + **evidências (fotos)** |
| **Correção/Ação corretiva** | ação adotada pelo supervisor |

**Roteamento próprio** (≠ do 20.1): BRF → `qualidade@` + `adel@` · outras → `qualidade@` + `lina.ramadan@` +
`fuad@`. Como `notification_routes` é **por escopo**, o 20.2 entra como escopo novo = **cadastro, não código**.

📌 **Ponte com o QA-03:** o campo *"foi presencialmente hoje?"* permite o calendário distinguir **entregou o
relatório** de **esteve na planta** — informação melhor para cobrar entrega do que a mera existência do doc.

🏗️ **Decisão de modelagem:** **modelo próprio** (`IndustrialOccurrenceReport`), não generalizar o de aves —
os conteúdos não se cruzam (disco/insensibilização × MP/produto/expedição). O esqueleto (série, planta, data,
supervisor, status, assinatura, `statusHistory`) é o mesmo dos outros relatórios do SIH.

**🆕 ATA DE COMITÊ HALAL — padrão = modelo de 2024 (decisão Q12).** O PDF de 31/03/2026 é **manuscrito e menos
completo**; fica de fora. *(Registro honesto: a extração de texto daquele PDF saiu ilegível aqui — a decisão
veio do Renato, não da minha leitura.)*

Estrutura: **Localização e data** · **Dia da reunião** · **Planta (nome e cidade)** · **Membros participantes**
(tabela Nome | Cargo) · **Pauta** (itens numerados) · **Decisão por item da pauta**.

⚠️ **Divergência deliberada do papel (decisão Q11):** no modelo a decisão traz ação e responsável **dentro do
texto corrido**. No sistema serão **campos separados — ação · responsável · prazo** — porque **o destino é o
BI**: texto corrido não vira indicador, nem acompanhamento, nem cobrança.

### ✅ DECISÕES DA NOITE — 2ª rodada

| # | Tema | Decisão |
|---|---|---|
| **Q10** | FM 20.2 | **Diário**, como o 20.1 ⇒ entra no calendário do QA-03 |
| **Q11** | Ata: ação/responsável/prazo | **Campos separados** — a mira é o BI |
| **Q12** | Modelo de ata | **O de 2024 é o padrão**; o de 2026 é manuscrito e menos completo |

### QA-05 · O calendário não perde histórico por regra — perde por consulta

Medido no GC: o `qualidade` **já tem** "Calendário" no menu (`Sidebar.tsx`, case `qualidade`), então não é
permissão. A tela monta os eventos de auditoria a partir de **duas consultas que só olham para frente**
([Calendar.tsx:79-89](../halalsphere-frontend/src/pages/Calendar.tsx#L79-L89)):
`auditService.getUpcomingAudits(90)` e `getAuditsByStatus('em_andamento')`. ⇒ **auditoria concluída some da
tela** — e é justamente o histórico que a Qualidade quer consultar.

**O backend já tem o que falta:** `GET /audits` aceita filtros e existe `by-status`; não é rota nova, é trocar
a fonte por uma busca **por intervalo do mês exibido**, incluindo `concluido`. Cuidado único: o calendário
hoje carrega 90 dias de uma vez — com histórico, a busca precisa acompanhar a navegação de mês, senão vira
consulta crescente. ⚠️ Vale checar de passagem se **NC e solicitações de documento** têm o mesmo recorte de
"só em aberto": se tiverem, o histórico fica pela metade e a queixa volta.

### ✅ DECISÕES DA SALA — QUALIDADE, 12/ago tarde. **Não re-litigar.**

| # | Pergunta | Decisão |
|---|---|---|
| **Q1** | FM 20.2 industrializados | ✅ **Solicitado à FAMBRAS** — sem ele eu não invento os campos |
| **Q2** | O que a empresa enxerga do relatório | ✅ **Só o que o QA registrar.** A Qualidade **filtra/edita** o que o supervisor escreveu; o texto do supervisor **não** vai cru para o BI ⇒ o campo do QA é camada **editorial**, não cópia |
| **Q3** | Anexo em ocorrência | ✅ **Necessário** — entra com FK nova + upload |
| **Q4** | Calendário: o que é cor | ✅ **Verde** = dia útil com relatório · **Cinza** = fim de semana/feriado · **Vermelho** = dia útil **sem** relatório |
| **Q5** | Perfil `qualidade` no SIH | ✅ **Confirmado criar** ⇒ e a escrita da matriz FM × anexo (CTR-05) migra de `admin`+`coordenador` para **`qualidade`+`admin`** |

❓ **Duas que a Q4 abriu e ainda não têm dono:** de onde vem a lista de **feriados** (nacional basta, ou
municipal — a planta é que define o feriado local?) e se **sábado** conta como dia útil em planta que abate
aos sábados. Enquanto não houver resposta, o cinza sai de fim de semana + feriado **nacional**.

### QA-04 · A biblioteca normativa não existe — e o que existe resolve outro problema

Medido no GC: **não há modelo de documento normativo publicável**. O que existe é o
`RequiredDocumentTemplate` (categoria × norma × ciclo × departamento, com `version`), que descreve **quais
documentos a EMPRESA precisa ENVIAR** — o sentido oposto do pedido, que é a FAMBRAS **disponibilizar** norma e
DT para a empresa **ler**. Não dá para reaproveitar o modelo; dá para reaproveitar o **vocabulário**
(categoria e norma), que é justamente o critério de segmentação da mala direta.

O que o pedido exige, e nenhuma parte existe hoje: **(1)** documento normativo com **versão** e arquivo em S3;
**(2)** regra de **quem recebe o quê** (por categoria/norma da certificação); **(3)** registro de **ciência**
por empresa — é ele que faz o alerta sumir e é a evidência de que o cliente tomou conhecimento (vale para
auditoria); **(4)** disparo de e-mail em massa na publicação de uma versão nova. O `NotificationService` do GC
já faz in-app + e-mail, então a fatia (4) é ligação, não construção.

⚠️ **A garantia de "sempre a versão mais recente" é a parte que costuma ser subestimada:** ela obriga
versionamento explícito e um link que aponta para "a corrente", nunca para o arquivo. Sem isso, o PDF que a
empresa baixou em janeiro continua sendo o que ela considera válido — e é exatamente esse o risco que o pedido
quer eliminar.

### QA-01 · O fluxo pedido já existe — para OUTRO relatório e OUTRO perfil

**O que já está pronto e é reaproveitável inteiro:** o embarque tem
`PATCH /:id/approve`, `/:id/reject` (com `reason`) e **`/:id/reopen`**, o enum
`ReportStatus { rascunho · assinado · aprovado · rejeitado · cancelado }`, `statusHistory`, e no front o
`RejectDialog` + a faixa *"Relatório rejeitado pela Controladoria — Motivo: …"*. **É exatamente o fluxo que a
Qualidade descreveu**, só que hoje o ator é o `controlador` e o objeto é embarque/produção/abate.

**As quatro coisas que faltam, medidas:**

1. 🏛️ **O perfil `qualidade` não existe no SIH.** O enum `UserRole` tem `admin · coordenador · supervisor ·
   operador · controlador` (em prod: admin 5 · coordenador 1 · supervisor 73 · controlador 6 · operador 0).
   ⇒ migration de enum idempotente + menu + opção no cadastro + **usuários criados**. 📌 **Isto responde a
   pendência que ficou aberta no CTR-05 de manhã** — quando o perfil existir, a escrita da matriz FM × anexo
   passa de `admin`+`coordenador` para **`qualidade`+`admin`**, como a sala já tinha decidido.
2. 🔌 **A ocorrência está fora do circuito de aprovação.** `bird_occurrence_reports` **já tem** `status`,
   `statusHistory`, `signedById/signedAt` e `assignedToId`, e o controller já tem `sign` e `assign` — mas
   **não tem `approve`/`reject`/`reopen`**, e a **fila da Controladoria só varre abate, produção e embarque**.
   O objeto está pronto; falta ligá-lo.
3. 🚫 **Ocorrência NÃO ACEITA ANEXO.** `report_attachments` só tem FK para embarque e produção — é a **mesma
   limitação que tirou o abate do CTR-05**, aparecendo pela segunda vez no mesmo dia. O pedido *"o supervisor
   pode anexar documentos"* exige **FK nova + upload + tela**, não é configuração.
4. 📄 **O FM 20.2 (industrializados) não existe.** Só há **FM 20.1 (aves)** — `BirdOccurrenceReport`, com
   `species` fixo em `ave` e seções de abate mecânico, insensibilização, paradas de linha e pendura, que são
   de aviário. Industrializados é **formulário novo**, com campos próprios. ❓ **Pedir o FM 20.2 preenchido
   de verdade**, como foi feito com os outros arquétipos — sem ele eu inventaria os campos.

➕ **O campo de comentário do QA** é o mais barato dos quatro, mas tem uma consequência que a sala precisa
assumir: ele nasce **destinado à empresa** (vai ao BI). ❓ **É visível para a empresa sempre, ou só quando o
relatório é aprovado?** Comentário de reprovação circulando antes do ajuste do supervisor é o tipo de coisa
que gera atrito com o cliente.

### QA-02 · O painel é no GC, mas o dado nasce no SIH — e essa direção não existe

**A decisão de produto está certa e vale registrar:** o painel vive no **GC** porque a empresa já tem acesso
lá, e **não se quer abrir acesso de empresa no SIH**. Isso mantém o SIH como sistema de campo.

**A consequência técnica é grande:** hoje a integração é de **mão única, GC → SIH** — o SIH lê cadastro,
certificação e MP homologada do GC via `/integration` com `x-api-key`. **SIH → GC não existe.** Duas saídas:

- **(a) O GC consulta uma API de leitura do SIH** — espelho exato do que o SIH já faz com o GC, com o mesmo
  padrão de chave. **Recomendo esta**: o padrão é conhecido nos dois lados e o dado não se duplica.
- **(b) O SIH publica/espelha os dados no banco do GC** — evita chamada em tempo real, mas cria segunda
  verdade e um job de sincronismo. Já vimos o custo disso no espelho GC→SIH.

🚧 **Bloqueios reais deste item:** **(1)** a **Ata de Comitê Halal não existe** — não é campo, é entidade nova
(quem lança, o que tem dentro, anexo?), e depende do **modelo que a Carol vai enviar**; **(2)** o painel
precisa de definição de indicador — "indicadores de NC" pode ser contagem, taxa por auditoria, tempo de
fechamento; **(3)** é escopo de **duas trilhas** (SIH e GC) ao mesmo tempo, e o §2 do BACKLOG proíbe duas
sessões no mesmo repo. ⇒ **Este item não cabe antes do go-live.** Recomendo tratá-lo como o primeiro grande
lote pós-15/ago, com a spec escrita assim que o modelo da Carol chegar.

### QA-03 · O calendário de entregas — o dado já existe, falta a agregação

`bird_occurrence_reports` tem `date` (data-only), `plantId` e `status`. ⇒ o calendário é **agregação +
tela**, sem modelo novo: uma rota que devolva, por planta e por dia, se houve relatório e em que estado.

❓ **Três definições que a sala precisa dar, senão eu escolho por conta:**

1. **O que é "dia esperado"?** Todo dia corrido, só dia com abate/produção lançada, ou a escala do supervisor
   (`user_schedules` existe)? Sem isso, todo domingo vira vermelho.
2. **O que cada cor significa?** Sugestão: verde = assinado/aprovado · amarelo = rascunho (existe, não
   assinou) · vermelho = nenhum relatório · cinza = fora da escala.
3. **Quem enxerga?** Qualidade e Controladoria com certeza; **supervisor vê o próprio**? (recomendo que sim —
   cobrança que aparece só para o chefe vira surpresa).

### CTR-02 · O vínculo embarque⇄produção já está construído — falta a porta e o item

Decisão do PO de **14/jun** (GAP-1: *"embarque vincula aos ProductionReport e deriva a composição; NÃO captura
manual"*) foi implementada em boa parte. **O que existe hoje:**

- `ShippingReportProduction` (M:N `shipping_report_productions`) e `ShippingReportSource` (A2, `sourceType`
  = `abate` | `producao`) — [schema.prisma:596-630](../sih-backend/prisma/schema.prisma#L596-L630).
- Componente **`LinkedSourcesField`** no form, com botão que aplica a **composição derivada** —
  [ShippingReportForm.tsx:1071-1116](../sih-frontend/src/pages/shipping/ShippingReportForm.tsx#L1071-L1116).
  Ele já resolve o multi-origem do FM 7.1.7.1: junta SIFs distintos e calcula a faixa min→max de data de abate.

**As 3 lacunas, na ordem em que doem:**

1. **A composição derivada só chega depois de salvar** — está escrito no próprio código (*"a composição derivada
   só aparece após salvar; os vínculos vão no POST"*). Quem está **criando** um embarque não tem lista de onde
   escolher; é exatamente a tela do print. ⇒ o pedido da sala é, em grande parte, **antecipar isso para a criação**.
2. **Aplicar é tudo-ou-nada.** `onApplyDerived` substitui a tabela inteira por 1 linha por produto. O pedido é
   **escolher item a item** — checkbox por produto/origem.
3. **A quantidade não vem da produção:** o mapeamento grava `quantity: 0` e só traz `netWeightKg` agregado
   ([linha 1106-1107](../sih-frontend/src/pages/shipping/ShippingReportForm.tsx#L1106-L1107)). A sala pediu
   **produtos *e* quantidades** — hoje a quantidade continua digitada à mão.

✅ **RESPONDIDO (D1): consumo parcial, SIM — e com tela de pendências.** Consequências medidas:

- **A derivação já é ao vivo, não só pós-salvar** — corrijo o que eu havia escrito: o service deriva a
  composição na hora (`sources.length ? deriveComposition(sources) : null`) e **só congela em
  `productionSnapshot` depois de assinado** ([shipping-report.service.ts:114-120](../sih-backend/src/shipping-report/shipping-report.service.ts#L114-L120)).
  O que falta é uma rota de **prévia sem relatório salvo** (a derivação hoje depende de um `id` que na criação
  ainda não existe). ⚠️ **Rota nova ⇒ regenerar swagger + os 3 JSONs do API Gateway no MESMO commit.**
- **O saldo precisa de coluna:** `ShippingReportProduction` é só a PK composta, **sem quantidade**
  ([schema.prisma:596-608](../sih-backend/prisma/schema.prisma#L596-L608)). Consumo parcial ⇒ **migration
  aditiva** com a quantidade consumida por vínculo (e por item, se for saldo por item — pergunta 1 acima).
- **Pendência = produzido − Σ consumido.** A tela pedida é a lista de produções com saldo > 0; o cálculo tem de
  ler os **vínculos persistidos**, nunca o `productionSnapshot` (que é congelado e só existe no assinado).

### CTR-04 · O prefill da origem ignora curtume — e o destino já faz o que a origem não faz

O `handlePlantChange` ([linhas 354-380](../sih-frontend/src/pages/shipping/ShippingReportForm.tsx#L354-L380))
decide o prefill por igualdade de `plant.type`:

| Campo | Preenche quando | Sol Couros (`curtume`) |
|---|---|---|
| **Abatedouro / Frigorífico** (`slaughterhouseInfo`) | `frigorifico` ou `abatedouro` (ou qualquer planta, se for transferência) | ❌ |
| **Unidade de Produção** (`productionUnitInfo`) | `processamento` | ❌ |
| **Endereço de Carregamento** | sempre (sobrescreve — lição do "Passo Fundo" de 17/jul) | ✅ |

⇒ no print, o endereço veio da base e os outros dois foram digitados. **Dois consertos independentes:**

- **(i)** o prefill precisa cobrir `curtume` e ler **`capabilities`**, não só `type` — usar o `plantMatchesTypes`
  que já centraliza essa regra ([plants.service.ts:43](../sih-frontend/src/services/plants.service.ts#L43)).
  É a 4ª aparição do padrão *"duas fontes para o mesmo fato e o código lê a errada"*.
- **(ii)** trocar os campos de origem por **seletor da base** (SIF/CNPJ/nome). O padrão existe **no mesmo
  arquivo**, do lado do destino: `handleDestinationPlantChange` já preenche endereço + CNPJ a partir da planta
  cadastrada, e há `lookupCnpj` para o caso externo. Origem ficou texto livre.

### CTR-05 · FM × anexos obrigatórios — metade da espinha já existe, e duas decisões definem o tamanho

**O que já existe (e é reaproveitável inteiro):** um **registry por FM** — `FmConfig { formNumber, revision,
revisionDate, titlePt, titleEn, verifications[] }` em
[fm-metadata.ts](../sih-backend/src/common/constants/fm-metadata.ts), com `PRODUCTION_FM`, `SHIPPING_FM` e
`SLAUGHTER_FM`, exposto pelo módulo `fm-metadata` e consumido pelo front. **É exatamente o mecanismo de "montar
a tela conforme o FM"** — só que hoje ele governa apenas o checklist de verificações.

**O que não existe:** qualquer relação FM → anexo. `ReportAttachment.category` é `String?` **nullable**
([schema.prisma:1187](../sih-backend/prisma/schema.prisma#L1187)), validada contra uma lista fixa no service —
`CSI · CSN · DCPOA · INVOICE · BL · NOTA_FISCAL · ROMANEIO · CROQUI · OUTRO`
([attachments.service.ts:9](../sih-backend/src/attachments/attachments.service.ts#L9)). **Nenhum anexo é
obrigatório e nenhum está amarrado a um formulário.** ⇒ hoje o relatório assina sem nada anexado.

📌 **Não é assunto novo:** é o **gap F** do levantamento de 14/jun (*"anexo DCPOA/CSN/Croqui; falta categoria
Croqui"*) chegando por outro canal — a categoria Croqui, aliás, já entrou. Vale registrar como reincidência,
que é sinal de prioridade real.

✅ **RESPONDIDO (D2 + D3): configurável em tela, e TRAVA na assinatura do supervisor.** O que isso define:

- **A matriz vira dado:** tabela nova (FM/tipo de relatório × categoria de anexo × obrigatório) + CRUD + tela de
  configuração. ❓ falta só **quem edita** (`controlador` · `admin` · Qualidade).
- ⚠️ **O modelo do FM fica partido:** anexos passam a ser dado configurável enquanto as `verifications` do mesmo
  `FmConfig` continuam **constante em código**. Conviver assim é aceitável, mas é decisão consciente — quando a
  FAMBRAS pedir para editar uma verificação (vai pedir), a resposta terá de ser a mesma migração.
- **A trava mora no `PATCH /:id/sign`** de produção e embarque (e o mesmo vale para abate, se a matriz cobrir os
  FMs de abate). Sem rota nova ⇒ sem regen do API Gateway nesta parte.
- 🛡️ **Matriz nasce vazia** (mitigação acima): a trava só morde onde a Controladoria já ligou a exigência.

---

## 5-D. Achados — Dia 4 · **13/ago** · equipe **QUALIDADE** (2ª rodada)

> Continuação do bloco `QA-nn` aberto na tarde de 12/ago (§5-C). Tema do dia: **revisão do fluxo de
> certificação sob a ótica de quem é dono de cada ato.**

### 📊 Medido em produção agora (13/ago, base GC) — os números que sustentam esta seção

| Tabela | Linhas | Leitura |
|---|---|---|
| `certification_requests` | 3 · **2 com `viability_checklist`** | ✅ o fix do **IND-08** (`e8c469b8`) funcionou — ontem era **0** |
| `request_review_reports` (FM 7.1.9) | **0** | ⚠️ a tela subiu hoje (`c3c9a818`); **ninguém preencheu ainda** |
| `seal_usage_controls` | 1 | 1 registro de teste; `seal_verifications` = 0 |
| `committee_reviews` / `committee_decisions` | **0 / 0** | o módulo de comitê **nunca rodou** |
| usuários por perfil | `analista` 15 · **`qualidade` 6** · `gestor` 3 · `admin` 1 · `auditor` 1 · `juridico` 1 · `gestor_auditoria` 1 | **`comercial` = 0** e **`empresa` = 0** (⇒ IND-07 continua de pé) |

---

### QA-07 · IT 7.4 e FM 7.1.1 — dois painéis na tela do analista que não são dele

**Como veio:** *"onde tem IT 7.4 o analista não tem ação, pois os dados vêm do 7.1.9 já preenchido
anteriormente — aqui é só mostrar"* e *"o checklist de processo (7.1.1) é atribuição do comitê; analista não
tem ação, apenas os usuários a quem forem delegadas as ações de comitê"*.

**São dois problemas de naturezas diferentes.** O primeiro é duplicação de dado; o segundo é um painel que
**não grava nada**. Separei em QA-07a e QA-07b porque o encaminhamento diverge.

---

#### QA-07a · 🔀 A IT 7.4 duplica, palavra por palavra, as 3 conformidades do FM 7.1.9

**O time está certo, e a evidência é literal — as mesmas 3 perguntas existem em dois lugares:**

| | IT 7.4 (`ViabilityChecklist`) | FM 7.1.9 (`RequestReviewReportCard`) |
|---|---|---|
| Onde | detalhe da certificação (`CertificationDetails.tsx:1236`) | fase **comercial** (`ProcessProposal.tsx:448`) |
| Campos | `formComplete` · `teamAvailable` · `categoryRecognized` (`ViabilityChecklist.tsx:23-36`) | `applicationComplete` · `technicalStaffAvailable` · `categoryRecognized` (`RequestReviewReportCard.tsx:500-517`) |
| Onde grava | `certification_requests.viability_checklist` — **Json solto** | `request_review_reports` — **3 colunas tipadas** (`schema.prisma:3511-3513`) |
| Quem edita | `admin`, `gestor`, `analista` | `admin`, `analista`, `comercial` |

⚠️ **Nota de honestidade:** ontem (12/ago) eu tratei o **IND-08** como P0 e consertei a IT 7.4 para que ela
**gravasse** (`e8c469b8`, em prod — e os 2 registros medidos acima provam que grava). Hoje a Qualidade diz
que ela **não deve ser preenchida ali**. O conserto não foi perdido — o registro tem de existir e o ato de
quem verificou também —, mas **o lugar da edição muda**. O que sobra do IND-08 é a lição do `as any`.

🚨 **O que impede aplicar a mudança hoje, tal como pedida:** `request_review_reports` tem **0 linhas** e
`comercial` tem **0 usuários**. Se a IT 7.4 virar espelho read-only do 7.1.9 agora, **o painel fica vazio
para todo mundo** — inclusive para as 2 certificações que já têm a viabilidade preenchida. Mesma armadilha
do CTR-02 (a base vazia inverte a recomendação). ⇒ a ordem correta é **7.1.9 primeiro, espelho depois**.

**Conserto proposto (front, pequeno) — em duas etapas:**
1. **Agora:** IT 7.4 continua editável, mas passa a **ler o FM 7.1.9 quando ele existir** (endpoint pronto:
   `GET /request-review-reports/by-request/:requestId`) e a mostrar de onde veio. Sem 7.1.9, comportamento atual.
2. **Depois que a FAMBRAS começar a preencher o 7.1.9:** `readOnly` fixo — hoje está **hardcoded
   `readOnly={false}`** em `CertificationDetails.tsx:1237`. O componente já renderiza texto/ícone quando
   `canEdit=false` (`ViabilityChecklist.tsx:112-125`), então não vira `select disabled`.
3. **Fonte única:** decidir se `viability_checklist` (Json) é **descontinuado** em favor das 3 colunas do
   7.1.9. Enquanto os dois existirem, há duas verdades para o mesmo registro de aceitação (ISO 17065).

❓ **Decisão necessária (D-QA07a):** com `comercial` = 0 usuários em prod, **quem preenche o FM 7.1.9** —
o próprio analista (e aí a IT 7.4 é redundância pura) ou a FAMBRAS vai criar os usuários comerciais?
Note que `gestor` **não está** nos `@Roles` do `request-review-reports` (só `admin`, `analista`, `comercial`)
— hoje o gestor edita a IT 7.4 e **perderia o acesso** ao migrar para o 7.1.9.

**Encaminhamento:** 🟢 front-only, pequeno — mas **depende de D-QA07a e da base deixar de estar vazia**.

---

#### QA-07b · 🚨🚨 O Check List FM 7.1.1 não é "do analista" — ele não é de ninguém: **não grava nada**

O pedido da sala é justo, mas o defeito é maior do que o pedido. **Levantei os três lados e nenhum se
sustenta:**

**1. O painel na tela não persiste uma única marcação.**
```tsx
// CertificationDetails.tsx:1268 — montado SEM NENHUMA PROP
{!isCompanyUser && <CommitteeChecklistPanel />}
```
Sem `checklist`, sem `onChange`, `readOnly` no default `false`. O componente é `useState` local
(`CommitteeChecklistPanel.tsx:40-57`): **não há chamada de API, não há botão Salvar**. Quem marca C/NC/NA
perde tudo no refresh. O *"0/9 respondidos"* do print é **permanente e sempre será**. Não existe campo
`committeeChecklist` em lugar nenhum do backend (grep nos dois repos).

**2. O módulo de comitê existe no backend, é mais rico que o painel — e o front nunca o chama.**
`POST /committee/review` (`committee.controller.ts:33`) recebe **`checklist` Json por revisor**, com 4
revisões sequenciais obrigatórias (`revisao_tecnica` → `revisao_religiosa_1` → `revisao_religiosa_2` →
`aprovacao_rt`), exigência de **unanimidade** e `CommitteeDecision` no fim. **Zero chamadas a `/committee/*`
no frontend** — o único vizinho é `manager.service.ts:290`, que posta em `/manager/committee/decision`.
📊 Confirmado pelo dado: `committee_reviews` = **0**, `committee_decisions` = **0**.
⇒ **Mesma classe do `fulfill` órfão de 11/ago:** motor construído, nenhuma tela ligada nele.

**3. Existem DUAS listas divergentes de "os 9 itens do FM 7.1.1" — e nenhuma lê dado gravado.**
A do painel (`CommitteeChecklistPanel.tsx:15-25`) e a do PDF (`fambras-pdf.service.ts:264-273`) **não têm um
item em comum na redação**; o PDF imprime `[ ] Conforme [ ] Não Conforme [ ] N/A` **em branco**, como
formulário de papel. Sem o FM 7.1.1 original na mão, não dá para saber qual das duas é a correta —
provavelmente **nenhuma**.

**4. "Delegar ações de comitê" não tem onde morar.** `UserRole` tem 13 valores e **nenhum é `comite`**
(`schema.prisma:19-33`). O que mais se aproxima da delegação pedida é o `CommitteeReviewType` (4 papéis
nominais). E hoje `POST /committee/review` aceita **`analista`** — exatamente quem a Qualidade diz que não
deveria agir ali.

❓ **Decisões necessárias (D-QA07b), nesta ordem:**
| # | Pergunta | Por que trava |
|---|---|---|
| a | **O FM 7.1.1 é um checklist por membro do comitê** (4×, dentro de `CommitteeReview.checklist`, que já existe) **ou um só por certificação?** | define schema e tela |
| b | Qual das duas listas de 9 itens é o FM 7.1.1 real? | 📄 **precisamos do papel** — nem 7.1.1 nem 7.4.2.4 estão nos repos |
| c | Delegação = **perfil novo `comite`** ou **designação nominal por certificação** (como o auditor)? | perfil novo = migration + gate; nominal = reaproveita `CommitteeReview` |
| d | O analista **deixa de ver** (como a empresa, FRG-06) ou **vê read-only** como evidência do processo? | 1 linha vs. 1 linha — mas é decisão de segregação |

**Encaminhamento:** 🔴 **não é item pequeno.** Registrar como *"esconder do analista"* esconderia um painel
que **nunca funcionou** — e daria a impressão de que o FM 7.1.1 está resolvido. Proposta em 2 tempos:
1. **Agora, honesto e barato:** o painel vira **read-only para todos** (1 linha), até existir onde gravar.
   Melhor um checklist que não se pode marcar do que um que aceita a marcação e a joga fora.
2. **Bloco próprio (B12):** a tela do comitê ligada no módulo que já existe — 4 revisões sequenciais,
   checklist por revisor, decisão. **Depende de (a)-(d) e do papel.** Pós-go-live é defensável, desde que
   fique dito que **hoje o comitê não tem registro nenhum no sistema** (`committee_reviews` = 0).

---

### QA-08 · Controle do Selo — o modelo existe, o **dono do parecer** não

**Como veio:** *"1. analista solicita à empresa o preenchimento do FM 7.4.2.4 e o envio do selo em si;
2. analista recebe e envia à qualidade, que analisa e devolve um parecer com aprovação ou não"* — e o Renato
já enxerga **um dashboard para a Qualidade acompanhar**.

**Boa notícia: diferente do comitê, este módulo está ligado ponta a ponta.** `SealUsageControl`
(`schema.prisma:3877-3899`) tem tipo (PRODUTO/INSTITUCIONAL), descrição, `layoutUrl`, status
`pendente/aprovado/rejeitado/revogado`, `approvedById`, `approvalDate`, `rejectionReason`; `SealVerification`
cobre a verificação periódica do FM 4.3.1; e a tela existe e chama a API (`SealManagementTab.tsx`).

**Quatro lacunas contra o fluxo pedido:**

| # | Lacuna | Evidência | Tamanho |
|---|---|---|---|
| 1 | 🚨 **O parecer é da Qualidade — e `qualidade` não pode dar parecer** | `PUT /seal-usage/:id/review` = `@Roles('admin','gestor','analista')` (`seal-usage.controller.ts:37`); o front espelha (`SealManagementTab.tsx:142`). `qualidade` só **lê**. **Matriz invertida, igual ao FRG-25** | 🟢 pequeno (roles) — mas ver decisão abaixo |
| 2 | 🧩 **Não existe o passo "analista solicita"** | hoje qualquer um cria o registro direto — inclusive `empresa` (`controller:17`, `SealManagementTab.tsx:141`). Não há solicitação que **avise** a empresa | 🟡 o encanamento existe: o ciclo de documentos ficou audível em 11/ago (FRG-29/30, `c1777de1`) |
| 3 | 📎 **"O envio do selo em si" não tem upload** | `layoutUrl` é `VarChar(500)` e o modal pede *"https://…"* (`SealManagementTab.tsx:542`) — a empresa teria de hospedar a arte em algum lugar. **Mesmo defeito do FRG-13**… que foi **consertado ontem** (`3f21ab91` / `97e34101`) | 🟢 reaproveita o upload do FRG-13 |
| 4 | 📊 **O dashboard da Qualidade não tem de onde ler** | só existem `GET /certifications/:id/seal-usage` e `GET /seal-usage/:id` — **nenhuma consulta transversal**. Uma fila "selos pendentes" precisa de endpoint novo (filtro por status + paginação) | 🟡 endpoint + card; a área `/qualidade` já existe (7 telas) |

📄 **Falta o papel — e essa é a lição nº 2 do Dia 3.** O **FM 7.4.2.4 não está em nenhum repo**: varri
`fambras-references-2026-04/` e `sih-docs/Reuniões/` e temos 7.4.2.1, .2, .7, .14, .15, .16 e .T — **o .4
não**. Dimensionar sem o documento deu errado no FM 7.1.9 (o papel tinha o dobro do que o código modelava).
⇒ **pedir o FM 7.4.2.4 à FAMBRAS antes de escrever a spec.**

⚠️ **Já sabíamos que o 7.4.2.4 ia doer:** ele aparece no CTR-05 como o item 15 do FM-de-anexos, e é
**OU exclusivo** com o 7.4.2.5 (controle de **não uso** do selo) — §5-C, linha *"Item 15 é OU exclusivo"*.
E o `DocumentType` (15 valores genéricos) **não tem** o código FM. As duas coisas se encontram aqui.

❓ **Decisões para a discussão (D-QA08):**
1. **O analista deixa de aprovar selo, ou aprova junto com a Qualidade?** Se o parecer é só da QA, é trocar
   os `@Roles` — mas isso **tira uma capacidade de 15 analistas** e entrega a **6 usuários `qualidade`**.
   *(Mesmo tema do QA-07: quem é dono de cada ato.)*
2. **A empresa continua podendo criar o registro sozinha**, ou só responde a uma solicitação do analista?
3. **O parecer da QA é texto livre ou um formulário estruturado** (o FM 7.4.2.4 responde — precisamos dele)?
4. **O dashboard é fila de trabalho** (o que está pendente de parecer meu) **ou painel de acompanhamento**
   (quantos selos, quantos reprovados, por empresa)? Os dois são fáceis, mas são telas diferentes.

**Encaminhamento:** 🟡 **discutir antes de codar.** Fatiamento sugerido, do mais barato ao mais caro:
**S1** `qualidade` passa a dar parecer (roles back+front) · **S2** upload da arte reusando o FRG-13 ·
**S3** solicitação do analista → e-mail para a empresa (encanamento do FRG-29/30) · **S4** dashboard da
Qualidade (endpoint transversal + card em `/qualidade`). **S1 cabe antes do go-live; S3/S4 provavelmente não.**

---

### 🧭 Bloco da tarde — perfil **AUDITOR** (13/ago). Numeração `AUD-nn`.

> Tela: `/certifications/auditorias/:id/executar` — auditoria `a14eaf79-…`, certificação
> **HS-2026140049333-01193**, *AUDITORIA EM EXECUÇÃO*, Estágio 1 · C2, Pindamonhangaba-SP.

---

#### AUD-01 · 🔀 O auditor digita à mão os produtos que a certificação já declarou

**Como veio:** *"não faz sentido, a essa altura, ter que preencher produto — isso já está declarado na
certificação, certo?"* (aba **Plano → Escopo (0)**, *"Nenhum produto no escopo"*, botão **+ Adicionar produto**).

**Certo. E a assimetria está em uma linha, visível na própria tela:**
```tsx
// AuditPlanEditor.tsx:67-70
const [schedule, setSchedule] = useState<ScheduleItem[]>(DEFAULT_SCHEDULE);   // ← 18 linhas prontas
const [scopeProducts, setAuditScopeProducts] = useState<AuditScopeProduct[]>([]); // ← vazio
```
É por isso que o print mostra **Cronograma (18)** e **Escopo (0)**. O backend repete o mesmo desenho:
```ts
// audit-plan.service.ts:90-91
schedule: (dto.schedule.length > 0 ? dto.schedule : AuditPlanService.getDefaultSchedule(dto.modality)),
scopeProducts: dto.scopeProducts as any,   // ← sem fallback nenhum
```
⇒ **o gancho de pré-preenchimento existe, uma linha acima. Ninguém o usou para o escopo.**

**O dado está a UM salto de distância:** `audit.certificationId` → `CertificationScope` → `ScopeProduct[]`,
e as colunas casam quase 1:1 com o que a tela pede:

| Coluna da tela do auditor | Origem no cadastro |
|---|---|
| Produto | `ScopeProduct.name` |
| Códigos | `ScopeProduct.code` (código FAMBRAS, o mesmo que sai no certificado) |
| Embalagem | `ScopeProduct.packingSize` |
| Marcas | `ScopeProduct.brands` (M:N `ScopeBrand`) |

📊 **Medido em produção agora:** esta certificação tem **1 produto ativo** no escopo — ou seja, havia o que
pré-preencher e a tela mostrou zero. E `audit_plans` tem **0 linhas na base inteira**: o plano que aparece na
tela **nunca foi salvo**; o "18" do cronograma é o default do front, não dado gravado.

🚨 **O problema é maior que a digitação.** Produto digitado à mão no plano é **segunda fonte de verdade**
para nome/código que vão parar no certificado — e o mesmo vale para `AuditReport.auditedProducts`, também
Json livre. Nome divergindo do catálogo é a mesma família do FRG-02 (escopo com marca/produto no campo errado).

❓ **Decisão necessária (D-AUD01):** o escopo auditado é **sempre igual** ao escopo da certificação, ou o
auditor pode auditar **uma amostra** dele? Isso define o conserto:
- **igual** ⇒ a aba vira leitura do escopo da certificação, sem digitação;
- **amostra** ⇒ pré-preenche com todos os produtos ativos e o auditor **desmarca** o que não auditou
  (recomendo esta: preserva o FM, elimina a digitação e mantém a rastreabilidade produto-a-produto).
Em ambos os casos, a linha deve **referenciar o `ScopeProduct.id`**, não copiar o texto.

**Encaminhamento:** 🟢 pequeno se a decisão for "pré-preencher e deixar remover" — o join já existe no
`autoFillPreparatoryForm`, é o mesmo padrão. Back + front, mesmo par de arquivos.

---

#### AUD-02 · 🔀 Preparatório: o auto-preenchimento existe, é parcial — e o endereço não entra em lugar nenhum

**Como veio:** *"o mesmo para os dados preparatórios como endereços e tals"*.

**Aqui a história é diferente do AUD-01 — o auto-preenchimento foi construído**
(`autoFillPreparatoryForm`, `audit-plan.service.ts:426-470`), e o próprio schema anota
*"Campos 1-8 (pré-preenchidos do sistema)"*. Ele traz 10 campos da certificação/planta/empresa. **Três furos:**

| # | Furo | Detalhe |
|---|---|---|
| 1 | 📍 **Endereço não existe no formulário preparatório** | `PreparatoryForm` **não tem campo de endereço**. O endereço está em `Audit.location` (medido nesta auditoria: `{tipo: "presencial", endereco: "Pindamonhangaba - SP"}`) e, completo, em `Plant.address` (Json com rua/número/cidade/UF/CEP). O auditor vê "Pindamonhangaba - SP" e nada mais — **não sabe para onde ir.** Prima do **IND-13** (agendar auditoria com endereço vazio) |
| 2 | ⏱️ **`minimumDuration` não é pré-preenchido** | o schema diz *"Calculado via FM 7.1.9"* — e o FM 7.1.9 **passou a existir hoje** (`c3c9a818`), com `finalAuditDays` e as durações por estágio. A ponte agora é possível e não foi feita |
| 3 | 👥 **`auditTeam` não é pré-preenchido** | a equipe já está em `AuditorAllocation` e nos 3 FKs de auditor do `AuditPlan`. O auditor redigita os próprios colegas |

⚠️ **E o auto-preenchimento só roda uma vez:** `enabled: isNew && !existingForm`
(`PreparatoryFormFill.tsx:64-68`). Salvou uma vez, **nunca mais atualiza** — se o cadastro mudar depois
(endereço, categoria, vencimento), o preparatório fica congelado no que era. Para um formulário de campo
isso é até defensável (é registro do que valia no dia), mas **precisa ser decisão declarada, não acidente**.

📊 **Medido:** `preparatory_forms` = **0 linhas** e `audit_plans` = **0 linhas** em toda a base. Nenhum dos
dois artefatos de auditoria foi salvo uma única vez em produção — o que significa que **nada disto foi
exercitado ponta a ponta**, e a auditoria "em execução" da tela não deixou registro.

**Encaminhamento:** 🟡 três fatias independentes, todas pequenas: **(a)** campo de endereço no preparatório
alimentado por `Plant.address` + `Audit.location` — *o mais urgente, é logística de campo*; **(b)** duração
mínima puxada do FM 7.1.9; **(c)** equipe auditora puxada da alocação. ⚠️ **Mas ver AUD-03 antes de (a):**
o cadastro de destino está incompleto, e puxar dele hoje não resolveria o problema do auditor.

---

#### AUD-03 · 🚨 O endereço **virou cadastro sim** — mas sem rua e sem número

**Como veio:** *"quanto ao endereço… foi preenchido pela empresa no início do processo e virou cadastro,
confere?"*

**Confere — e é justamente por isso que o furo é pior do que parecia.** A empresa preenche no
`RegisterPage`, o dado vai para `Company.address` e `Plant.address` (Json), e **fica lá**. Só que o que
ficou lá **não é um endereço**:

📊 **Medido em produção (13/ago):**

| | plantas (824) | empresas (830) |
|---|---|---|
| com `address` preenchido | 589 (71%) | 829 (99,9%) |
| com **rua** (`street`) | **275** (33%) | 610 (73%) |
| com **número** (`number`) | **1** (0,1%) | 149 (18%) |
| com cidade | 579 | — |

**A planta desta auditoria é o retrato exato:** `YOG ACAI` (SIF `INT-CD789CBF9164`) tem
`address = {city: "Pindamonhangaba", state: "SP", postalCode: "12424-170"}` — **cidade, UF e CEP. Só.**
É literalmente o *"Pindamonhangaba - SP"* que o auditor vê na tela. Não há de onde tirar mais.

🔎 **Causa-raiz, e ela é de uma linha:** o formulário de cadastro **nunca pergunta rua, número ou bairro**.
```ts
// RegisterPage.tsx:112-116 — o payload inteiro do endereço
address: {
  city: form.cidade || undefined,
  state: form.uf || undefined,
  postalCode: form.cep || undefined,
},
```
E o mais irônico: **os dois lookups já trazem o endereço completo e ele é jogado fora.**
`cnpj.service.ts:113-121` devolve `logradouro`, `numero`, `complemento`, `bairro`, `cep`, `cidade`, `uf`;
`cep.service.ts` devolve `logradouro` e `bairro` nos 3 provedores. **O `RegisterPage` mapeia 3 dos 7 campos.**
⇒ o cadastro chega mutilado na origem, por descarte, não por falta de dado.

**Quem tem endereço completo hoje veio de outro lugar:** as plantas com rua (FALCAO, BEAUVALLET,
FRIGOESTRELA…) vieram do **ETL do SysHalal**. Das 3 plantas criadas pela UI (`SIF INT-%`), **zero** têm rua.
⇒ **quanto mais a FAMBRAS cadastrar pela UI a partir do go-live, pior fica a base.**

⚠️ **Efeito colateral já visível:** as 4 auditorias em prod têm `location.endereco` **digitado à mão** —
alguém está redigitando o endereço na auditoria porque o cadastro não serve. É o sintoma, não a doença.

**Encaminhamento:** 🔴 **P0 de cadastro, e antecede o AUD-02(a).** Ordem correta:
1. **`RegisterPage` passa a mapear os 7 campos** que os lookups já entregam (rua, número, complemento,
   bairro) — front, minúsculo, e **conserta o problema para frente**.
2. **Preparatório e plano leem `Plant.address`** (AUD-02a).
3. ❓ **Backfill dos 314 registros já cadastrados sem rua** — o CNPJ está gravado, então dá para reprocessar
   pelo mesmo lookup. **Decisão do Renato:** vale rodar antes do go-live?

💡 **Vale generalizar:** este é o padrão nº 5 (§ acima) na direção contrária — **o cadastro descarta o que a
fonte externa já deu**. Vale varrer os outros formulários que usam `cnpj.service`/`cep.service` para ver
quantos outros campos estão sendo descartados no mapeamento.

---

### 🔬 Padrão estrutural nº 5 — **"o formulário reprocessa o que o cadastro já sabe"**

QA-07a, AUD-01 e AUD-02 são a mesma doença em três telas: **um formulário FM foi modelado como folha em
branco, quando o dado já existe estruturado a um join de distância.** Junta-se aos 4 padrões do §7-Z.
Sintomas para procurar nas telas restantes: campo `Json` de texto livre onde há tabela tipada; `useState([])`
onde há default disponível; e o teste rápido — *"o usuário está digitando algo que o sistema já sabe?"*.

---

## 7-Y. HANDOFF — fim do Dia 3 + madrugada de 13/ago. **LEIA ANTES DE COMEÇAR.**

> Escrito por falta de contexto na sessão, não por fim de trabalho.
> **Nada pela metade:** os 4 repos de código estão sem WIP solto (`wip=0`).

### 📍 Retrato por repo (medido agora)

| Repo | Branch | HEAD | Estado |
|---|---|---|---|
| **sih-backend** | `release` | `1322bb8` | ✅ pushado · **EM PROD** |
| **sih-frontend** | `release` | `d4d9900` | ✅ pushado · **EM PROD** |
| **halalsphere-backend** (GC) | `release` | `fa3bc9cd` | ⚠️ **1 commit à frente — NÃO pushado** (FM 7.1.9 fase 1) |
| **halalsphere-frontend** (GC) | `release` | `50135cc1` | ✅ pushado (QA-05) |
| **sih-docs** | `main` | este commit | ⚠️ **local**, nunca pushado (decisão do Renato pendente) |

### ✅ ENTREGUE E VERIFICADO EM PRODUÇÃO (12-13/ago)

Todos provados **de fora** — bundle servido, rota 404→401, migration em `_prisma_migrations`, coluna no banco.

| Item | Commits | Prova |
|---|---|---|
| CTR-01(b) · CTR-03 · CTR-04(i) | front `7fac2ad` | bundle com "tem a atividade exigida" |
| **CTR-05** matriz FM × anexo + trava aditiva | back `6192cec` · front `65d28e5` | migration 16:32 UTC · matriz com 0 linhas (nasce vazia) |
| CTR-04(ii) origem da base | front `0aeccba` | "Buscar na base" no bundle |
| **CTR-02 fase 1** consumo parcial + saldo + pendências | back `5571e0f` · front `a8f0d23` | coluna `consumed_net_weight_kg` |
| **QA-01 fatia 1** perfil `qualidade` | back `684638c` · front `2464c87` | enum do banco com `qualidade` |
| **FM 20.2** completo + anexo em ocorrência | back `7bb2162` · front `93ec07b` | tabela + 2 FKs de anexo |
| **Carimbo da revisão do FM** (6 relatórios) | back `c8a90cc` | 6 tabelas com `formRevision` |
| **QA-01 fatia 2** aprovação da QA + parecer p/ BI | back `89c34f7` · front `58baaaf` | — |
| **QA-03** calendário de entregas + gestão de datas | back `3fbbec1` · front `6d5fde8` | tabela criada · `/work-calendar` → 401 |
| **QA-05** calendário do GC (auditoria e NC históricas) | GC front `50135cc1` | — |
| **Ata de Comitê Halal** | back `1322bb8` · front `d4d9900` | pushado; deploy iniciado |

🗄️ **Dado carregado por mim em prod (autorizado):** rotas de e-mail do FM 20.2 (`industrial-occurrence`) —
BRF por SIF `466/18/4567` + default `qualidade@` + `lina@` + `fuad@`. O escopo do FM 20.1 não foi tocado.

### ▶️ PRÓXIMO PASSO IMEDIATO — a tela do FM 7.1.9 (fase 1)

Backend **pronto e commitado** (`fa3bc9cd`, GC, **não pushado**): 28 campos do REV 11 + `comercial` na escrita
+ Qualidade só leitura. **Falta o front**: um card na **fase comercial** (sugestão: `ProcessProposal.tsx`,
onde já vive o botão de revisão de qualidade), com os blocos do papel — identificação, escopo (Golfo,
filiais), base do cálculo, as 3 conformidades, as **9 durações digitadas**, equipe auditora e decisão.

⚠️ **Armadilha já paga:** `create` e `update` do `request-review-report` fazem **whitelist campo a campo** —
campo fora dela é aceito pelo DTO e **descartado em silêncio**. Os 28 já foram adicionados nos dois.

### 🧭 FILA (ordem sugerida)

1. **FM 7.1.9 fase 1 — front** (acima) → push do `fa3bc9cd` junto.
2. **CTR-02 fase 2** — spec do saldo por item nos tipos com produtos em Json (raspa, tripas, gelatina); é o
   GAP-3 de 14/jun. **Só spec**, o Renato pediu plano passo a passo.
3. **QA-06 chamados** — módulo no **GC** + tela fina no SIH usando o `gc-integration` que já existe
   (SIH→GC é a direção com encanamento). Empresa **não** abre chamado. Pós-go-live.
4. **QA-02 painel de produção no GC** e **QA-04 biblioteca normativa** — pós-go-live.
5. **FM 7.1.9 fase 2** — cálculo automático, **só depois de a FAMBRAS validar as regras** (30%/70%, 1/3, 2/3,
   arredondamento, mínimo de meio dia). Registrar antes de calcular deixa a base de comparação pronta.

### 🚧 BLOQUEADO NO RENATO / FAMBRAS

- 🔴 **Criar usuários `qualidade` no SIH** — hoje há **0**, e a aprovação de ocorrência é dela. Só os 5
  admins aprovam (ponte deliberada). Criar **pela UI** (hash bcrypt).
- 🔧 **Cadastro do Pablo** (CTR-01a): vincular planta de processamento **ou** declarar a atividade na Sol Couros.
- ❓ **Push do `sih-docs`** (2 commits locais) e destino do **`idx.js`** na raiz.
- ❓ **FM 7.1.9 fase 2**: agendar a discussão das regras com a FAMBRAS.
- ⚠️ **Unidades industriais da BRF podem não estar cadastradas no SIH** — só 3 plantas "BRF" existem, todas
  frigoríficos. A rota de e-mail do 20.2 está certa, mas pode não haver o que rotear.

### 📌 LIÇÕES DESTA SESSÃO (valem para a próxima)

1. **Grep truncado = evidência fraca.** Errei duas vezes: disse que a ocorrência não tinha
   `approve/reject/reopen` (tinha, no controller, além do `head -8`) e que o gateway não conhecia prefixo novo
   (conhecia). **Sonda tem de distinguir versão**: `/production-reports/pending-shipment` dava 401 no código
   VELHO porque casava com `:id` — o observável válido era o `POST derive-composition`, 404→401.
2. **Avaliar tamanho sem o documento na mão dá errado.** Eu disse que o FM 7.1.9 era "só ligar"; o papel
   tinha o dobro do que o código modelava.
3. **Prefixo novo no API Gateway do SIH passa sem import manual** — confirmado 3×.
4. **Push de par back+front:** o do back falhou por rede e o front subiu sozinho. Confira `ahead=0` nos dois.

---

## 6. Validado OK ao vivo (base da aprovação formal)

> Preencher conforme o time confirmar cada tela. **Isto é o que André precisa para dar aprovação.**

| ID | Tela / fluxo | Quem validou | Observação |
|---|---|---|---|
| | | | |

---

## 7-W. HANDOFF — 11/ago fim do dia · **LEIA ISTO PRIMEIRO**

> Escrito por falta de contexto na sessão, não por fim de trabalho. **Nada em andamento**:
> os dois repos estão limpos e com `0 ahead`. A próxima sessão começa do zero.

### 🎯 DIRETRIZ DO RENATO (11/ago): atacar **TODOS os 47 achados antes do go-live**

⚠️ **Leitura honesta do que isso implica** — a diretriz é do decisor e vale, mas o cronograma tem
dependências que não são de código:

| Categoria | Qtd | Depende de |
|---|---|---|
| ✅ Já em produção | **21** | — |
| 🟢 Posso fazer sozinho | **~10** | tempo de sessão |
| ❓ **Travado em resposta da FAMBRAS** | **8** | FRG-01 (regra de nomenclatura + exemplos) · FRG-17 (`TH` × APPCC) · IND-03 (grupo C, ou D/E?) · IND-06 (quem executa a revisão) · IND-11 (SLA) · MP Q1-Q4 · FM 7.8.1 ATIVOS · Power BI |
| 🔧 **Travado em cadastro operacional** | — | ✅ **12/ago: `empresa`, `comercial` e `juridico` agora têm 1 usuário cada** (eram 0) e `qualidade` tem **5** · ~~auditores sem categoria industrial~~ *(premissa falsa — ver 12/ago)* · **0 de 504 pessoas do FM 6.1.4 com login** (306 ativas) |
| 🔴 Risco alto na véspera | 3 | B7 (**migration** de enum) · B9 (**18.511 produtos**) · B10b (180 selos) |

⇒ **O gargalo deixou de ser código.** Dos 26 restantes, 8 não podem ser codificados sem resposta da
FAMBRAS, e vários dos já corrigidos **não são testáveis** sem os usuários reais. Recomendação: perseguir as
8 respostas e os cadastros **em paralelo** ao código, e tratar B7/B9/B10b como decisão consciente de risco —
não como fila normal.

### ✅ DECISÕES TOMADAS EM 11/ago (não re-litigar)

| # | Decisão |
|---|---|
| **Trocar auditor** | Usar **`PATCH /workflows/:id/assign-auditor`** (caminho direto), **não** o `modify` da alocação. Fato que fecha a questão: `modifyAllocation` **lança se o status ≠ `sugerida`**, ou seja é incapaz de servir reatribuição pós-aprovação. São **momentos diferentes**, não alternativas. ⚠️ Condição do Renato: **registrar o motivo**. |
| **Sincronizar alocação** | Ao trocar o auditor, **ATUALIZAR a alocação existente** marcando o motivo (não criar registro novo). |
| **IND-04 taxonomia** | **Opção (c)**: só **corrigir os rótulos** de C1–C6 antes do go-live, para parar de contradizer as letras dos grupos industriais. (a) — preço por grupo/categoria real — vira **projeto próprio pós-go-live**. |
| **Escopo herdado — renovação** | **Mantém** herdando. Correto por desenho (passo 2 = "Confirmação de Escopo"). |
| **Escopo herdado — ampliação** | A empresa **deve ver o escopo antigo como CONTEXTO**. ⇒ não limpar; **falta deixar visualmente claro o que é pré-existente × o que é novo** (os passos se chamam "Novos Produtos"/"Novas Instalações" e hoje não distinguem). |
| **Escopo herdado — manutenção** | **OK como está.** |
| **FRG-25 contrato** | **(a) agora** (só UI, feito) + risco registrado; **(b)** — mover escrita ao jurídico — **na 1ª semana pós-go-live**, junto da criação dos perfis. ⚠️ (b) antes de existir gente em `juridico` travaria a emissão de contrato no dia 1. |
| **Tela de aprovação de alocação** | ~~Menos urgente **por consequência da decisão do `assign-auditor`**: com a designação direta, ela passa a ser necessária só para o 1º auditor. Fica **pós-go-live**.~~ ❌ **PREMISSA FALSA (corrigido 12/ago): a tela EXISTE e funciona.** Quem chama as rotas é o componente FILHO — `SuggestionCard.tsx:33` (`approve`) e `:50` (`reject`); o registro anterior olhou só o `AllocationSuggestions.tsx` (pai). Prod confirma: alocação aprovada em 11/ago 22:58 com `allocated_by`. O que faltava era a aprovação **designar o auditor**, consertado em `10d7c77c`. **Não reconstruir.** Sem porta de entrada mesmo está só a rota **`modify`** (trocar entre as sugestões, antes de aprovar) — ❓ decisão se entra. |

### 📦 O QUE FOI ENTREGUE EM 11/ago — 21 achados em produção

| Repo | Range | Blocos |
|---|---|---|
| **halalsphere-backend** | `c1777de1..0daaf30f` | B11 (IND-08) · IND-01 · B12 back (IND-14) |
| **halalsphere-frontend** | `082a00eb..e5d16566` | B4 (FRG-12/09/14, IND-03/05) · B5 (FRG-08/23/25a/26/27/06/22/31, IND-02) · B12 front · B13 (IND-13/15 parcial) |

Todos com `tsc -b` / `tsc --noEmit` limpos e testes verdes. **`0 ahead` nos dois repos.**

### ▶️ PRÓXIMO PASSO IMEDIATO — trocar auditor (decisão acima, nada codado)

**Back** (`workflow/*`): `AssignAuditorToWorkflowDto` ganha **`reason` obrigatório** · `assignAuditor` grava
**`AuditTrail`** com before/after do `auditorId` + motivo (padrão do `assignAnalyst`, B1) · **atualizar a
alocação aprovada** da certificação com o motivo. Hoje **não grava trilha nenhuma** e o DTO só tem
`auditorId` — a troca é silenciosa.
**Front** (`CertificationDetails.tsx`, card "Planejamento da Auditoria", que já existe e já foi ampliado
para gestor/admin): seletor de auditor + motivo obrigatório, no mesmo padrão da rejeição de documento.

### 📋 FILA DEPOIS DISSO (ordem recomendada, §7-Z tem o detalhe)

1. **B3b** (back) — notificação de rejeição de documento (FRG-31 p3) e de reclamação/apelo (IND-10)
2. **B6** (misto) — PCCH: `@Roles`+recorte (**escrita cross-tenant**, FRG-07) · `includeInternal` (FRG-10) ·
   rótulos **"de Controle Halal"** (FRG-03, regra absoluta de termos)
3. **IND-04 (c)** — rótulos de C1–C6
4. **Ampliação** — marcar visualmente o escopo pré-existente
5. **B10a** (back) — congelar `market_variant` na emissão (FRG-32)
6. **B8** (front) — datas date-only em UTC (FRG-04)
7. **Tela de aprovação de alocação** · **B7** (migration) · **B14** · **B9/B10b** (dados)

### 🔧 VALIDAÇÃO PENDENTE EM PRODUÇÃO (Renato) — nada foi exercitado na UI real

1. Viabilidade IT 7.4 grava (cert. `HS-2026151500508-01192`) — **reconferido 12/ago: segue 0 de 2**;
   o número mudar é prova definitiva
2. Certificação Inicial **não** herda escopo (entrar pela Minerva, que tem 3 certificações)
3. Rejeição de documento **exige motivo** e a empresa **vê** o motivo
4. PDF/imagem **abrem** em vez de baixar
5. "Gerar sugestões de auditor" no card de Planejamento — ✅ **JÁ FUNCIONOU** (11/ago 22:56: 2 sugestões,
   scores 69,80 e 68,75). ~~deve responder "nenhum elegível para a categoria CV" enquanto as competências
   estiverem sem categoria industrial~~ ❌ premissa falsa, corrigida em 12/ago: elegibilidade é por
   **formação**, não pela categoria da competência. ⚠️ O Minerva já saiu do planejamento (está em
   `auditoria_estagio1`) — o card só reaparece ali por causa do fix `71246f92`.
6. Reagendar auditoria · endereço pré-preenchido · rótulo "Modalidade" · Estágio 1 nascendo **remoto**
7. Espelho `certifications.analyst_id` (a 1ª atribuição de analista nova é o teste — nunca foi exercitado)

### 📊 ESTADO MEDIDO EM PRODUÇÃO — 12/ago (substitui números anteriores)

| Fato | Número | Leitura |
|---|---|---|
| Usuários por perfil | analista **15** · qualidade **5** · gestor 2 · admin 1 · **empresa 1** · **comercial 1** · **juridico 1** · auditor 1 · gestor_auditoria 1 | ✅ o bloqueio de cadastro de 11/ago **caiu** |
| Espelho `analyst_id` | **1 de 2** workflows com a certificação preenchida | ✅ **o espelho FUNCIONOU** na atribuição nova; o Minerva (fase `auditoria_estagio1`) segue NULL |
| Viabilidade IT 7.4 | 2 solicitações, **0 com checklist** | 🔧 B11 nunca exercitado |
| Solicitações de documento | 1, `atendido` (de 10/ago) | 🔧 B3/B3b nunca exercitados desde o deploy |
| Documentos | 9 aprovados · 2 pendentes · **0 rejeitados** | 🔧 FRG-31 p3 sem caso real ainda |
| **Reclamações** | **3 registradas** (2 RECLAMACAO + 1 APELO), todas de **11/ago**, todas com e-mail e **nenhuma anônima** | 🎯 **são anteriores ao deploy do B3b** ⇒ não tiveram acuse. **Responder qualquer uma agora dispara o e-mail de resultado** — caso de teste pronto para o Dia 3 |
| Alocação de auditor | 1 `aprovada` + 1 `sugerida`; **as duas com `workflow_id` NULL** | ⚠️ a aprovada é anterior ao fix — **não se auto-corrige**; aprovar a `sugerida` OU trocar auditor pelo card designa |
| Auditorias | 2 agendadas (estágio 1 e 2), **ambas sem auditor** | ⚠️ consequência do acima |
| Certificados sem selo | **180 de 1.433**, sendo **3 com PDF** | ✅ parte 1 em prod impede novos; os 3 seguem divergentes |
| Competências de auditor | 3, **nenhuma com categoria** | ✅ irrelevante para o matcher (elegibilidade é por formação) |
| FM 6.1.4 | 504 pessoas · 306 ativas · **0 com login** | 🔧 pré-requisito de trava por competência |

### 🚨 PENDÊNCIAS QUE NÃO SÃO CÓDIGO E BLOQUEIAM MAIS QUE ELE

`empresa` = **0 usuários** (as 2 contas viraram auditor/gestor_auditoria em 11/ago) · `comercial` = **0** ·
`juridico` = **0** · os 2 auditores são **contas de teste** e as competências estão **sem categoria
industrial** · **0 de 306** pessoas do FM 6.1.4 vinculadas a login · **FM 7.8.1 ATIVOS** nunca carregado ·
**Power BI da qualidade** só na versão de abril (hoje mantido pela **Bárbara**, que já é `qualidade` no GC).

### 📁 ONDE ESTÁ O RESTO

Prompts prontos e não usados em
`C:\Users\ecotrace\AppData\Local\Temp\claude\c--Projetos-Ecohalal-sih-docs\92ec04a2-*\scratchpad\`:
`PROMPT-B2-caixas-entrada.md` · `PROMPT-B3-notificacao.md` (⚠️ **já ampliado** com FRG-30 e FRG-31 p3) ·
`PROMPT-B4-wizard.md` · `PROMPT-B11-viabilidade.md`. B2/B4/B11 **já foram executados**; o do B3 serve para o
**B3b**.
Artefato dos papéis de homologação de MP (com a Q5 medida): `claude.ai/code/artifact/fc9fb502-047c-4163-b059-c1236e42aa27`.

---

## 7-Z. PLANO ATUALIZADO — fechamento do Dia 2 (11/ago)

> Substitui o plano da pausa de 10/ago (preservado abaixo em **§7-A**, como histórico da decisão).
> **47 achados** ao todo: 32 do Dia 1 (Frigorífico) + 15 do Dia 2 (Industrializados).

### Placar

> ⚠️ **O placar abaixo é de 11/ago e está VENCIDO.** A reconciliação de **12/ago** (contra git, não memória)
> está logo em seguida — use aquela.

| | Quantidade |
|---|---|
| ✅ **Em produção** | **7** — FRG-18 · 19 · 20 · 21 · 24 · 29 · 30 |
| 🟢 Escopo fechado, pronto para codar | **20** |
| 🟡 Depende de decisão do Renato | **5** |
| ❓ Depende de resposta da FAMBRAS | **8** |
| 🔧 Operacional / dado (não é código) | **7** |

### 📊 RECONCILIAÇÃO 12/ago — os 47, item a item (verificado por git)

**28 fechados · 7 parciais · 12 abertos.** Parcial = uma fatia está em prod e outra, declarada no próprio
achado, não está — conta como pendente na fila.

| Grupo | IDs | Total |
|---|---|---|
| ✅ **Fechados** | FRG-03 · 04 · 06 · 07 · 08 · 09 · 10 · 12 · 14 · 18 · 19 · 20 · 21 · 22 · 23 · 24 · 26 · 27 · 30 · 31 · IND-01 · 02 · 05 · 08 · 10 · 13 · 14 · 15 | **28** |
| 🟠 **Parciais** | FRG-05 *(empresa deixou de ver a matriz ✅ · envio pelo cliente ❌ = B7)* · FRG-25 *(a ✅ · b ❌ pós-go-live)* · FRG-29 *(notificação ✅ · KPI + lembrete ❌)* · FRG-32 *(p1 código ✅ · p2 backfill de 180 selos ❌)* · IND-03 *(texto ✅ · regra ❌ FAMBRAS)* · IND-04 *(rótulos C1–C6 ✅ · taxonomia + migração de preço ❌)* · IND-07 *(empresa/comercial/jurídico criados ✅ · auditores REAIS e 0 de 306 logins do FM 6.1.4 ❌)* | **7** |
| 🔴 **Abertos** | FRG-01 · 02 · 11 · 13 · 15 · 16 · 17 · 28 · IND-06 · 09 · 11 · 12 | **12** |

**Os 19 pendentes por natureza do bloqueio:**

| Bloqueio | IDs | O que destrava |
|---|---|---|
| ❓ **Resposta da FAMBRAS** — não codificável | FRG-01 · FRG-17 · IND-03(regra) · IND-06 · IND-11 | regra de nomenclatura + exemplos · `TH` × nº de planos APPCC na GSO 2055-2 · APPCC>0 só no grupo C? · quem **executa** a revisão de qualidade · SLA de reclamação/apelo |
| 🟡 **Decisão do Renato** | FRG-15 · IND-04(a,b) · IND-12 | formato do `targetMarkets` · taxonomia de tipo de certificação (o preço lê `certificationType`, os dias leem `categoryCode`, e há migração de tabela de preço **parada no meio**) · empresa vê o próprio apelo |
| 🟢 **Código, escopo fechado** | FRG-05 · 11 · 13 *(= **B7**, migration de enum `DocumentType`)* · FRG-16 *(calculadora GSO sem tela)* · FRG-28 *(solicitação em LOTE, spec `.odt` em mãos)* · FRG-29(b,c) · IND-09 *(**B14** máquina de estados da reclamação)* | é onde a fila anda sozinha |
| 🔧 **Dado / operacional** | FRG-02 *(**B9** — 18.511 produtos, 94% sem `packing_size`)* · FRG-32 p2 *(**B10b** — 180 selos)* · IND-07 *(auditores reais + vincular FM 6.1.4 aos logins)* | 🔴 os 2 primeiros são **risco alto na véspera**; o terceiro é FAMBRAS |
| ⏭️ **Já decidido para depois** | FRG-25(b) | mover escrita do contrato ao jurídico — 1ª semana pós-go-live (decisão de 11/ago) |

### ✅ ONDA 0 — CONCLUÍDA e em produção · **3 blocos**, verificados por git

⚠️ **Nota de método:** este placar foi corrigido no fechamento do Dia 2. Eu havia registrado só 4 itens em
prod porque **sessões paralelas** entregaram B2 e B3 e commitaram neste mesmo repositório — conferi por
`git branch -r --contains` em vez de confiar no meu próprio registro. *(Lição: com sessões concorrentes, o
placar se verifica no git, nunca na memória da sessão.)*

| Bloco | Achados | Commits | O que mudou |
|---|---|---|---|
| **B1 · Coluna vertebral** | FRG-20+24 · FRG-18 · FRG-21 | `a9fb46fb` · `23223b37` · `0a736a82` | atribuir analista vale da assinatura **em diante**, reatribuição não mexe na fase, com `AuditTrail` e espelho de `analyst_id` · assinar tira de `aguardando_empresa`→`pendente` sem avançar · `PATCH /workflows/:id` não aceita mais `currentPhase` |
| **B2 · Caixa de entrada** | FRG-19 | `082a00eb` (front HEAD) | *"a caixa de entrada da análise documental volta a existir"* — o vocabulário paralelo de fases era maior do que eu havia medido: **11 de 17 fases eram fantasmas** |
| **B3 · Notificações** | FRG-29 · FRG-30 | `c1777de1` (back HEAD) | avisa **empresa e analista** no ciclo de documentos |

**B1 validado por mim:** `tsc --noEmit` 0 · `jest workflow contract` 92/92 · escopo respeitado.
⚠️ **Push do B1 saiu sem OK explícito**, levando a **Fatia A do Catálogo de Normas** + **migration** de carona
(aplicada em prod 18:08:56; as 3 tabelas `restricted_*` existem). O front da Fatia A (`4aeadb8b`) **também já
subiu**, na esteira do B2 — ⇒ **o Catálogo de Ingredientes Restritos está completo em produção** e pode ser
demonstrado.
🔧 **Pendente de validação:** o espelho `certifications.analyst_id` — a atribuição da Minerva rodou minutos
**antes** do deploy, então nunca foi exercitado. **A próxima atribuição de analista é o teste.**
❌ **Uma correção vinda da sessão paralela:** o achado de que o `fulfill` não era chamado por tela nenhuma era
**alarme falso** — o `CertificationDetails.tsx` tem o seu próprio `DocumentRequestItem` que o chama. O que
sobra é higiene: `PendingDocumentRequests.tsx` e `DocumentRequestsAnalystView.tsx` são **duplicatas órfãs**
(3º e 4º da série, com o `NewAuditorDashboard`) — e o segundo já implementa **rejeição com motivo**, ou seja,
é a base natural do FRG-31 em vez de escrever um terceiro.

---

### 🔴 ONDA 1 — os P0. Duas sessões, uma por repositório, blocos em SÉRIE dentro de cada uma

> ⚠️ **Regra de paralelismo corrigida em 10/ago:** dois blocos no **mesmo repositório** colidem no índice do
> git mesmo tocando arquivos diferentes. Logo: **2 sessões em paralelo (back + front)**, cada uma com sua
> fila. Não abrir uma terceira sessão no mesmo repo.

**Fila BACK** — `halalsphere-backend`

| Ordem | Bloco | Achados | Por quê nesta posição |
|---|---|---|---|
| 1 | **B11 · Viabilidade IT 7.4** | IND-08 | Etapa obrigatória que **nunca gravou nada** (0 de 2 solicitações). Fix pequeno, defeito duplo: trava errada + campo não persistido (`as any`) |
| 2 | **B12 · Alocação de auditor** | IND-14 | 4 causas: matcher lê FK escalar em vez da M:N · falha silenciosa · falta botão de gerar · (causa 1 já resolvida pelo Renato) |
| 3 | **B3b · Notificações — resto** | FRG-31(3) · IND-10 | O B3 entregou FRG-29/30. **Faltam 2 gatilhos:** rejeição de documento **com motivo** e reclamação/apelo. Mesma infra, já ligada |
| 4 | **B14 · Estado de reclamação** | IND-09 | Máquina de estados + histórico. Mesma família do FRG-21 já corrigido |
| 5 | **B10a · Congelar selo** | FRG-32 (código) | Persistir `market_variant`/`template_type` na emissão. Impede que os 177 latentes virem divergentes |

**Fila FRONT** — `halalsphere-frontend`

| Ordem | Bloco | Achados | Por quê nesta posição |
|---|---|---|---|
| 1 | **B4 · Wizard** | FRG-12 · FRG-09 · FRG-14 · IND-03 · IND-05 | Escopo herdado = **documento errado sem sintoma**. É o P0 do front agora que o B2 saiu. Junto: textos de funcionários e APPCC, países de destino, "Certificação Inicial" |
| 2 | **B5 · Quem vê o quê** | FRG-06 · 08 · 22 · 23 · 25(a) · 26 · 27 · 31(1-2) · IND-01 · IND-02 | Segregação analista×empresa×auditor, visualizar documento, motivo da rejeição, mojibake, tela branca da busca. ⚠️ **Aproveitar o `DocumentRequestsAnalystView` órfão** — já tem rejeição com motivo |
| 3 | **B13 · Auditoria** | IND-13 · IND-15 | Endereço pré-preenchido + rótulo "Modalidade" + default remoto no Estágio 1; **reagendar** e **trocar auditor** (métodos de serviço órfãos) |
| 4 | **B8 · Datas em UTC** | FRG-04 | Helper `formatDateOnly`×`formatDateTime`, campo por campo. Depois do B5 (mesmo arquivo) |
| 5 | **B15 · Higiene dos órfãos** | — | Decidir sobre os **4 componentes órfãos** (`NewAuditorDashboard`, `PendingDocumentRequests`, `DocumentRequestsAnalystView`, e o que a varredura do padrão 2 achar): apagar ou aproveitar |

**Fila MISTA / MIGRATION** — depois das duas ondas acima, uma de cada vez

| Bloco | Achados | Observação |
|---|---|---|
| **B6 · PCCH + comentários** | FRG-07 · FRG-03 · FRG-10 | `@Roles` + recorte + rótulos "de Controle **Halal**" + `includeInternal` |
| **B7 · Anexos do cliente** | FRG-05 · FRG-13 · FRG-11 | `DocumentType` novo ⇒ **migration de enum idempotente** |
| **B10b · Backfill do selo** | FRG-32 (dados) | 180 certificados sem `market_variant`; comparar os 3 com PDF antes de gravar |
| **B9 · ETL do escopo** | FRG-02 | **18.511 produtos** — SQL revisado + backup + OK explícito. Nunca em paralelo |

---

### 🟡 DECISÕES DO RENATO — travam blocos

| # | Decisão | O que trava |
|---|---|---|
| 1 | **`empresa` ficou com 0 usuários** (as 2 contas viraram auditor/gestor_auditoria hoje) | qualquer demonstração ou validação do lado cliente |
| 2 | **IND-04 · taxonomia de tipo de certificação** — (a) grupo/categoria real · (b) tipo de solicitação · (c) só corrigir rótulos | FRG-16, e a coerência preço × dias de auditoria |
| 3 | **FRG-25 · contrato do analista** — (a) tirar valores e documento · (b) mover a escrita para jurídico | B5 e a matriz comercial/jurídico |
| 4 | **FRG-15 · formato do `targetMarkets`** — objeto × array ISO | país de destino não é gravado |
| 5 | **IND-12 · empresa vê o próprio apelo?** | leitura escopada; depende do histórico do IND-09 |

### ❓ RESPOSTAS DA FAMBRAS — travam blocos

| # | Pergunta | O que trava |
|---|---|---|
| 1 | **FRG-01** · a regra de nomenclatura de documentos + 2-3 exemplos reais | lote de nomenclatura |
| 2 | **FRG-17** · na GSO 2055-2, o `TH` varia com o nº de planos APPCC? | se sim, é defeito de cálculo com efeito em preço |
| 3 | **IND-03** · APPCC > 0 vale só para o Grupo C, ou também D e E? | validação condicional |
| 4 | **IND-06** · a revisão de qualidade é **executada** pela Qualidade (leitura a) ou pelo Comercial (b)? | obrigatoriedade da revisão |
| 5 | **IND-11** · qual o SLA de resposta a reclamação e a apelo? | prazo + alerta |
| 6 | **MP · Q1-Q4** do artefato de papéis | etapa de revisão halal da MP |
| 7 | **FM 7.8.1 ATIVOS** — a lista de industriais ativos nunca foi carregada | certificados industriais ausentes da base |
| 8 | **Power BI da qualidade** — a versão em mãos é de **abril**; hoje é mantido pela **Bárbara** | Dashboard de Ocorrências do SIH |

### 🔧 OPERACIONAL — Renato/FAMBRAS, não é código

1. **Criar usuários `comercial` e `juridico`** — ou declarar que `gestor` acumula. Hoje ambos = **0**.
   ⇒ muda IND-06, FRG-16 e FRG-25, que assumem um comercial que não existe.
2. **Recriar um usuário `empresa`** (ver decisão 1).
3. **Auditores reais da FAMBRAS** — os 2 criados hoje são contas de teste do Renato.
   ~~com competência cadastrada mas **sem categoria industrial**. Para o matcher casar por categoria,
   falta preencher.~~ ❌ **PREMISSA FALSA, corrigida em 12/ago:** o matcher **não lê** a categoria da
   competência — casa pela **formação** (matriz do FM 6.1.4). As 2 sugestões de 11/ago saíram com as
   competências sem categoria. O que falta aqui é só **gente de verdade**, não configuração.
4. **Vincular pessoas do FM 6.1.4 aos logins** — **0 de 306** ativas têm `userId`. É pré-requisito de
   qualquer trava por competência (revisor de MP, auditor religioso).
5. **Normalizar o campo de nomeação** do FM 6.1.4 — 64 valores em texto livre, com grafias concorrentes.
6. **Corrigir o §4 do BACKLOG:** o registro de 22/jul diz "SIH: Karoline + Osama criados" — eles estão no
   **GC** como `qualidade`; no SIH **não existem**.
7. **Versionar** o `.odt` de contato inicial e a planilha `MIN.PGS.2602.01 - E - R3.xlsx`
   (`C:\HalalSphere\PRESENCIAL 10-14\FRIGORIFICO\`), hoje fora do git.

---

### 🔬 QUATRO PADRÕES ESTRUTURAIS — cada um merece varredura própria

Não são achados isolados; são classes. Aparecem repetidamente e vão gerar mais defeitos se não forem varridas.

| Padrão | Ocorrências | Varredura sugerida |
|---|---|---|
| **Duas fontes para o mesmo fato, e o código lê a errada** | FRG-32 (selo derivado × coluna NULL) · IND-04 (preço × dias de auditoria) · IND-14 (FK escalar × M:N) | mapear campos duplicados no schema e decidir a fonte única de cada |
| **Capacidade pronta e autorizada, sem porta de entrada** | FRG-16 (calculadora GSO) · IND-14 (rota de gerar) · IND-15 (reagendar/trocar auditor) · `NewAuditorDashboard` órfão | procurar métodos de service que **nenhum componente importa** |
| **Falha silenciosa** | FRG-18 · FRG-19 · FRG-29 · FRG-30 · IND-14 (`logger.warn`) | procurar `try/catch` que só loga em caminho de negócio |
| **Campo renomeado no back, front não acompanhou — escondido por `as any`** | FRG-19 (`certification.company`) · FRG-27 (`razaoSocial`) · IND-08 (`as any` no `update`) | `grep` por `as any` em chamadas de service + por `razaoSocial`/`companyId` no front |

---

## 7-A. PLANO DE ATAQUE EM BLOCOS — versão da pausa de 10/ago (HISTÓRICO)

> ⚠️ **Superado pelo §7-Z acima.** Preservado porque registra o critério de priorização e a descoberta da
> colisão de árvore de trabalho.

> **Critério de prioridade, em ordem:** (1) o processo tem de **andar**; (2) o trabalho tem de ser **visto**;
> (3) as pessoas certas veem as **coisas certas**; (4) o resto. Dentro disso, quem produz **documento errado
> ou trava o processo sem sintoma** vem antes de tudo.
>
> **Critério de paralelismo:** blocos da mesma onda **não compartilham nenhum arquivo** (§0.3 do BACKLOG —
> colisão real já ocorreu em 16/jul). Onde há sobreposição, o bloco foi empurrado para a onda seguinte.

### ONDA 1 — 4 sessões em paralelo · os P0 (o fluxo não anda sem isto)

| Bloco | Achados | Arquivos (domínio EXCLUSIVO) | Por quê primeiro |
|---|---|---|---|
| ✅ **B1 · Coluna vertebral do fluxo** (back) — **EM PROD 10/ago** (`a9fb46fb` · `23223b37` · `0a736a82`; detalhe no §4.1 do BACKLOG). Falta validar E2E | FRG-18 · 20 · 24 · 21 | `workflow/workflow.{service,controller}.ts` · `workflow/dto/update-workflow.dto.ts` · `contract/contract.service.ts` (**só** o método de assinatura) | Hoje: assinar não avança · atribuir analista é uso único · **reatribuir é impossível** · fase muda sem rastro. Sem isto nada mais importa |
| ✅ **B2 · Caixas de entrada do analista** (front) — **EM PROD 11/ago `082a00eb`**. Falta validar | FRG-19 + varredura do vocabulário de fases | `pages/analyst/DocumentAnalysis.tsx` · `pages/analyst/AnalystDashboard.tsx` · `components/kanban/ProcessCard.tsx` · `types/certification.types.ts` | A tela central do analista **nunca funcionou**. Fix de 2 strings, impacto máximo |
| ✅ **B3 · Notificação de documento solicitado** (back) — **EM PROD 11/ago `c1777de1`** (FRG-29 + FRG-30, ida e volta). Falta validar | FRG-29 · 30 | `document-request/*` · template de e-mail · consumo do `notification/*` | Cobrança sai e **o cliente nunca sabe** ⇒ todo processo trava no passo mais repetido |
| **B4 · Integridade do wizard** (front) | FRG-12 · 09 · 14 | `components/certification/CertificationWizard.tsx` · `components/wizard/TargetMarketsStep.tsx` · `components/proposal/ProposalCalculator.tsx` | Nova certificação **herda escopo** = documento errado sem sintoma |

### ONDA 2 — 3 sessões em paralelo · segregação e autorização

| Bloco | Achados | Arquivos | Observação |
|---|---|---|---|
| **B5 · Quem vê o quê** (front+back) | FRG-06 · 08 · 22 · 23 · 25(a) · 26 · 27 | `pages/company/CertificationDetails.tsx` (⚠️ Trilha C) · `components/wizard/IndustrialClassificationStep.tsx` · `pages/CompanyList.tsx` · `pages/analyst/ContractManagement.tsx` · `proposal/*` + `contract/contract.controller.ts` (serialização por papel) | FRG-26/27 entram porque são **no mesmo arquivo** do 25 |
| **B6 · Autorização: PCCH + comentários** (back+front) | FRG-07 · 03 · 10 | `pcch/*` · `components/certification/PcchMatrixView.tsx` · `services/pcch.service.ts` · `comment/comment.controller.ts` | FRG-03 e 07 **têm de ir juntos** (mesmo controller) |
| **B7 · Anexos do cliente** (back+front, **migration**) | FRG-05 · 13 · 11 | migration do enum `DocumentType` · `document/*` · `components/certification/ScopeBrandsManager.tsx` | ⚠️ a UI de anexo obrigatório (FRG-11) toca o wizard ⇒ **depois do B4** |

### ONDA 3 — depois das anteriores (conflito de arquivo ou risco de dado)

| Bloco | Achados | Por que não antes |
|---|---|---|
| **B8 · Datas date-only em UTC** (front) | FRG-04 | Toca `CertificationDetails.tsx`, arquivo do **B5**. Helper primeiro, aplicação depois |
| **B9 · ETL do escopo** (dados) | FRG-02 | **Carga em 18.511 produtos** — exige SQL revisado + backup + OK explícito. Nunca em paralelo com outra escrita |

### 🚫 FORA DO ATAQUE — travados por decisão de terceiro

| Achado | Trava |
|---|---|
| FRG-01 nomenclatura de documentos | falta a **regra + 2-3 exemplos reais** (FAMBRAS) |
| FRG-15 formato do `targetMarkets` | **decisão de modelo** (objeto × array ISO) |
| FRG-16 calculadora ao comercial | **decisão do Renato**: onde entra e se cabe no go-live |
| FRG-17 APPCC na fórmula | **questão de norma** (GSO 2055-2: `TH` varia com nº de planos?) |
| FRG-25(b) mover escrita de contrato | **decisão de escopo** (a) mínimo × (b) completo |
| FRG-28 solicitação em lote | **vira spec própria** (spec-fonte já em mãos: o `.odt`) |

---

## 7. Fila de prompts para sessões paralelas

> Só entra aqui o que tem **escopo fechado**. Item com pergunta aberta fica no §5 até a resposta chegar.
> Cada prompt declara: objetivo · arquivos (domínio da trilha, §2 do BACKLOG) · critério de pronto ·
> **e a regra de que "revisar" não é autorizar** e push só com OK do Renato.

| # | Origem | Escopo | Trilha | Estado |
|---|---|---|---|---|
| **P0** 🔴 | **FRG-12** | **Nova certificação NÃO herda escopo** — limpar escopo/produção/tipo quando `requestType === nova`, na inicialização **e** no `handleRequestTypeChange`; cobrir o rascunho do `localStorage`; verificar se ampliação tem o mesmo defeito | front `CertificationWizard.tsx` | 🟢 **PRONTO — PRIORIDADE MÁXIMA** |
| **P1** | **FRG-06 + FRG-08** | **"O que o perfil `empresa` não vê"** — ocultar checklist FM 7.1.1 · ocultar prazo de auditoria em **toda** a visão do cliente | front `CertificationDetails.tsx` (Trilha C) · `IndustrialClassificationStep.tsx` | 🟢 **PRONTO** |
| **P1b** | **FRG-09 + FRG-11** | Texto de apoio do nº de funcionários (turno de maior efetivo Halal) + anexo obrigatório de outras certificações | front `CertificationWizard.tsx` · `ProposalCalculator.tsx` | 🟢 **PRONTO** — ⚠️ **mesmo arquivo do P0: rodar depois, nunca em paralelo** |
| **P2** | **FRG-04** | **Datas date-only em UTC** — helper único `formatDateOnly`×`formatDateTime`, campo por campo (não varredura cega) | front, várias telas (`CertificationDetails`=Trilha C) | 🟢 **PRONTO** |
| **P3** | **FRG-07 + FRG-10** | **Fechar os 2 furos de autorização:** `@Roles` + recorte por empresa no `pcch/*`; `includeInternal` deixa de valer p/ `empresa` | back `pcch/*` ⚠️ sem trilha · `comment/*` | 🟢 **PRONTO** — declarar dono no §2 antes |
| **P4** | **FRG-05 + FRG-11** | **Anexos do cliente:** `DocumentType` novo (HAS · matriz PCCH · comprobatório de outras certificações) + upload pela empresa, **obrigatório** quando o checkbox está marcado | back `documents/*` + **migration de enum** · front wizard | 🟢 **PRONTO** — decidido: sempre anexo, 99% PDF |
| **P4b** | **FRG-13** | **Upload do logo da marca** — rota de upload + S3 (infra já existe) e seletor de arquivo no lugar do input de URL. Sem migration | back (rota nova → **regenerar API GW**) · front `ScopeBrandsManager.tsx` ⚠️ sem trilha | 🟢 **PRONTO** |
| **P5** | **FRG-03** | Rótulos PCCH → "Pontos Críticos **de Controle Halal**" (9 ocorrências: front + back + swagger) | `pcch/*` ⚠️ sem trilha | 🟢 **PRONTO** — "Perigo à integridade Halal" p/ os 4 rótulos de perigo |
| **P5b** | **FRG-14** | Observação do FM fixa no passo + "(consultar condições específicas)" na Turquia + bloqueio do Irã **inclusive no campo "Outros"** | front `TargetMarketsStep.tsx` (não colide com P0) | 🟢 **PRONTO** |
| **P7** | **FRG-15** | Alinhar formato de `targetMarkets` nas 3 pontas (front objeto × DTO `string[]` × leitor do PDF) | front + back `certification-request/*` + `fambras-pdf` | 🟡 **decisão de modelo primeiro** — e validar por teste E2E (não há dado em prod) |
| **P8** 🔴 | **FRG-16** | **Expor a calculadora GSO 2055-2 ao comercial** — consumir `GET /audit-days/calculate` (já autorizado) e mostrar `Total_HD`, quebra TD/TH/TMS/FTE, Etapas 1/2, multiplicadores e redução justificada | front `ProposalCalculator.tsx` + tela do comercial | 🔴 **construção de tela** — decidir ONDE entra e se cabe no go-live. ⚠️ sair junto/logo após P1 (FRG-08) |
| — | FRG-17 | APPCC: rótulo (vai no P1b) + **se o `TH` varia com nº de planos APPCC** | back `audit-days/*` se procedente | ⏳ travado: **questão de norma** p/ a FAMBRAS |
| **P6** | **FRG-02 (a)(c)** | Reprocessar ETL: mapear embalagem → `packing_size` + split de marca multi-valor | **Trilha B** (dados) | 🔴 carga de dados — SQL revisado + backup + OK do Renato |
| — | FRG-01 | nomenclatura de documentos | ⚠️ a definir (`documents/*` sem trilha) | ⏳ travado: falta a regra/exemplos da FAMBRAS |
| — | FRG-03 (extra) | `suino_haram` no enum do Prisma + rótulo na UI | back+front, **migration** | ⏳ aguarda decisão do Renato |

⚠️ **Nenhum prompt gerado ainda** — nada de código nesta sessão (§0.1). **P1 a P5 estão com escopo fechado**
e podem sair assim que você autorizar. ⚠️ **P3, P4 e P5 tocam `pcch/*` e `documents/*`, módulos SEM trilha
declarada** no §2 do BACKLOG — declarar dono antes, senão duas sessões paralelas colidem (já ocorreu em
16/jul). **P4 exige migration de enum** (idempotente, nome mapeado da tabela).

---

## 8. Dias seguintes (11-14/ago)

| Dia | Equipe / sistema | Perfil | Status |
|---|---|---|---|
| **10/ago** | **Frigorífico** (André, Giovanna, William) — GC | `empresa` → analista | ✅ **fechado — 32 achados** |
| **11/ago** | **Industrializados** — GC, ciclo completo até auditoria | analista · gestor · admin | ✅ **fechado — 15 achados** |
| **12/ago** | **Controladoria Industrial** — GC | a confirmar na sala (⚠️ W-1: `controlador` tem menu vazio) | 🟡 **em curso — `CTR-nn` (§5-C)** |
| 13-14/ago | a definir (Qualidade? SIH?) | — | ⬜ |

**Como o Dia 2 avançou no fluxo:** foi o primeiro dia em que um processo real atravessou solicitação →
proposta → contrato assinado → análise documental → planejamento de auditoria. Cada trava encontrada foi
diagnosticada até a causa-raiz no código e, quando possível, destravada ao vivo. O processo da Minerva
(`HS-2026140838148-01191`) é hoje o único caso de ponta a ponta que existe na base.

⚠️ **Lembrete de agenda registrado no BACKLOG:** a **Soha está ausente ~2 semanas desde 04/ago**
(2 cirurgias) — ela atravessa este presencial e o go-live, e é quem decide **formato de normas** e sobe as
listas ao site público. Decisão de norma que aparecer nesta semana **não terá quem responda** — registrar
como bloqueio explícito, não esperar resposta.

---

## 9. Encerramento do dia — o que fazer antes de fechar

1. Levar cada achado ao **§4 do BACKLOG** com dono (§4.1 Renato / §4.2 Claude / §4.3 FAMBRAS).
2. Fechar o §6 (lista de OK) — é o insumo da aprovação do André.
3. Para cada 🧩 GAP, marcar a decisão: **antes do go-live · depois · opera com pendência**.
4. **Commitar este doc** (regra §0.2: WIP não-commitado é trabalho a um `checkout` de sumir).
5. Só então gerar os prompts do §7.
