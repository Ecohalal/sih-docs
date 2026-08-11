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

**Catálogo de Ingredientes Restritos:** o **backend está em produção** (migration + módulo, desde ontem
18:08), mas a **tela não** — o front `4aeadb8b` segue sem push. A funcionalidade existe e é invisível.
⇒ **não abrir esse menu**; ele sobe junto com o próximo push do frontend (B2).

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

## 6. Validado OK ao vivo (base da aprovação formal)

> Preencher conforme o time confirmar cada tela. **Isto é o que André precisa para dar aprovação.**

| ID | Tela / fluxo | Quem validou | Observação |
|---|---|---|---|
| | | | |

---

## 7-A. PLANO DE ATAQUE EM BLOCOS — definido na pausa de 10/ago

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
| 10/ago | **Frigorífico** (André, Giovanna, William) — GC | `empresa` | 🟡 em curso |
| 11-14/ago | a definir (Industrializados / Qualidade / SIH) | — | ⬜ |

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
