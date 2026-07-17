# ATA / Alinhamento FAMBRAS — 30/jun/2026

> Reunião de alinhamento (transcrição). **Toca os 3 sistemas** (GC · SIH · SysHalal).
> Tema-âncora: **fluxo de homologação de matéria-prima** (cadastro no GC → consumo
> read-only no SIH → liberação do certificado no SysHalal) e as **regras de trava**.
>
> Status: ✅ feito/em prod · 🔧 operacional (UI/infra/dados) · 🧩 código a fazer ·
> ❓ decisão FAMBRAS · 🎯 ação imediata desta reunião.
>
> **Participantes:** Renato · Soha Chabrawi · Lina Ramadan · Elaine Franco (qualidade) ·
> Dib Ahmad El Tarrass · André (controladoria/indústria).

---

## 0. Entregável imediato combinado na reunião
- 🎯 **Renato monta um FLUXOGRAMA visual** (caixinhas: quem faz o quê, onde trava, quem
  destrava, onde tem aprovação) do **fluxo do relatório de fabricação** com MP fora de
  escopo → compartilha **hoje após o almoço**.
- 🎯 **Reunião curta (~30 min)** hoje à tarde ou amanhã de manhã p/ validar o fluxograma
  com todos os envolvidos antes de virar regra no sistema.
- 🎯 **Elaine envia Power BI de qualidade atualizado** (Renato só tem a versão de abril) —
  vira base do dashboard de ocorrências no SIH.

---

## 1. Conceito-base reafirmado (papel de cada sistema)
- **GC (Gestão de Certificações) = base central** de cadastro, homologação de MP/produtos,
  escopo e emissão de certificado. **Toda manutenção de cadastro vive aqui.**
- **SIH (Supervisão Industrial) = operacional.** Registro de relatórios + dashboard de
  qualidade. **MP/produtos entram read-only** (consumidos do GC). Cadastro no SIH só do
  que é puramente operacional (ex.: NC, ocorrência).
- **SysHalal = exportação/embarque.** Recebe o vínculo do relatório de embarque e só
  autoriza o certificado quando o embarque está aprovado.
- **Catálogo global de MP (GC):** MP de referência homologada **uma vez por produto×fabricante**,
  e **vinculada** ("semeada") ao escopo de cada cliente — "duplica sem duplicar". Quem
  cadastra é o cliente; quem **homologa/valida é o analista**.

---

## 2. SIH — Supervisão Industrial Halal

### Já implementado / em teste (relatado na reunião)
- ✅ **Autosave/rascunho por sessão** — se cai sessão/energia, ao reabrir o supervisor vê
  aviso "você começou a preencher X, deseja continuar?" (restaurar rascunho). _(já em prod)_
- ✅ **Vínculo de datas de relatórios prévios** ao montar o relatório de exportação (busca
  datas de abate/relatórios anteriores). _(relacionado a backlog 1.2 Itens A/B)_
- 🔧 **Vínculo nº certificado SysHalal no relatório de embarque** — já dá p/ informar; ainda
  **sem trava** (só informativo). _(ver §4 fluxo do ciclo)_

### Novos itens desta reunião
- 🧩 **Perfil "Qualidade" no SIH** — não existe; Renato vai criar (acesso da Elaine/time).
- 🔧 **Bug: e-mails de acesso não chegam** — Elaine e Soha não receberam o e-mail de
  criação de usuário. Investigar envio. _(workaround: senha padrão temp + trocar em "Meu perfil")._
- 🧩 **Dashboard de Qualidade (Ocorrências diárias) DENTRO do SIH** — decisão: ocorrências
  ficam centralizadas no SIH (onde o supervisor preenche). Renato cria dashboard espelhando
  o **Power BI do time da Elaine** (mantido hoje pela Bárbara; abastecido por Carol/Sam;
  Victor liberado p/ ajudar). Permissões internas definidas pela FAMBRAS.
- 🧩 **Lista suspensa de MP no relatório de fabricação** — supervisor seleciona MP **somente
  do escopo homologado** (read-only, vindo do GC). _(ver §4)_
- 🧩 **Personalizar menu por grupo de acesso** (analistas, qualidade, controladoria,
  supervisor) — cada um vê só o que foi definido, mexendo ou só consultando.
- 🧩 **Tela de consulta read-only de MP homologada por planta** no SIH (espelha o catálogo
  do GC; supervisor/controladoria consultam, não cadastram).

---

## 3. GC — Gestão de Certificações

> **Base de certificação PERSISTENTE** (feedback Lina 16:16) — o MP/produto/escopo **já existem
> na base do analista, antes e independentemente do embarque**. O relatório de fabricação (SIH) e
> o certificado de embarque (SysHalal) apenas **consomem** essa base; ela não nasce no momento do
> embarque. Por isso, quando falta uma MP, há **3 casos** (não 2):
> 1. **Já está no escopo da planta** → supervisor seleciona e segue.
> 2. **Já existe homologada na base/catálogo global** (validada p/ outra planta — ponto Soha) →
>    o **analista só inclui no escopo** da planta (**reuso, sem homologação nova**).
> 3. **MP nova** (não existe na base) → **homologação completa**: cliente alimenta a planilha +
>    analista avalia risco/doc.

### Catálogo global de MP / homologação
- 🧩 **Importação de MP/insumos em massa** (a partir das planilhas que a controladoria enviar):
  importar **tudo como HOMOLOGADO** para não travar o supervisor (que só enxerga MP homologada),
  **porém marcado para REVISÃO**. _(parte-se do princípio: se está na doc da FAMBRAS, está OK)._
- 🧩 **Tela/campo de REVISÃO** — responsáveis revisam item a item e marcam "revisado";
  sistema mede o progresso da revisão. **1ª leva exige revisão** (decisão Dib); levas
  seguintes podem entrar como homologadas automaticamente (RGB). _(encaixa em FAM-0017 F4 / RevisionLog ISO 17065)._
- 🧩 **Código único por produto×fornecedor** — o mesmo insumo (ex.: amido de batata) de
  fornecedores diferentes mantém **códigos distintos** (importante p/ Soha/Dib). A homologação
  é da **MP daquele fornecedor mediante a avaliação específica**, não do nome genérico.
- 🧩 **Tela de busca do catálogo global** — buscar por **produto** e por **fornecedor**,
  ver vínculos (fornecedores homologados p/ um produto) e os **documentos/avaliações anexados**.
  Tela existe, **falta subir no menu**. _(relaciona com Catálogo Produtos 5A-2)._
- 🧩 **Avaliação por produto** — cada produto tem sua avaliação (risco → pede certificado
  halal, ficha técnica, etc.) com identificação própria, visível no catálogo global.
- 🧩 **Validade/vencimento do certificado de MP visível + ALERTA** (pedido Soha) — mostrar
  data de validade na listagem e **avisar o analista quando vencido** (auditoria interna pegou
  certs vencidos passando). MP/cert ficam no banco com data de validade.

### Manutenção / responsabilidade
- ❓→✅ **Manutenção do catálogo = analistas** (controladores indiretamente podem solicitar).
  Cliente cadastra → analista homologa/valida.

---

## 4. Fluxo MP fora de escopo + TRAVAS (núcleo da reunião)

> Tema mais debatido. Decisão final convergiu para: **trava real, mas com fluxo "azeitado"**.

- 🧩 **Supervisor só enxerga MP do escopo** (read-only). Se a MP **não está no escopo**:
  - O supervisor **não cadastra a MP** — ele **sinaliza a falta e orienta o cliente**; o
    **analista** resolve no GC (ver os **3 casos** em §3: reuso da base × homologação nova).
  - No **momento do preenchimento**, o sistema já mostra alerta: _"MP fora do escopo —
    iniciar homologação de matéria-prima?"_ (nome correto = "homologação", não "avaliação").
  - O supervisor **salva o relatório como rascunho, mas NÃO consegue ASSINAR** — relatório fica
    **pendente de validação** (não cancela, só para o fluxo).
  - 🧩 **Tela de status** p/ controladoria/analistas: quais relatórios estão **pendentes de
    homologação/inclusão de MP**.
- 🧩 **Lista viva / atualização simultânea** (Elaine) — a lista de MP muda a qualquer momento
  (cliente adiciona insumo na hora da produção). Ex.: "farinha de empanamento da Alina não
  habilitada". Quando o supervisor não acha a MP → highlight/alerta → analista negocia com a
  empresa → **a atualização da lista suspensa precisa refletir em tempo quase real**, senão
  trava o supervisor. Double-check: supervisor confere ao preencher + analista faz crosscheck.
- 🧩 **Vínculo escopo ⇄ certificado de embarque** (Lina, "melhor dos mundos") — o certificado de
  embarque é o **portão final** que **consome a base persistente**: **sem o produto no escopo, não
  libera**. A validação acontece **a montante e continuamente** (na base do analista), não no embarque.

### Escalonamento de criticidade de travas — ❓ FAMBRAS define internamente
- 🧩 Sistema precisa de **níveis de trava + quem pode destravar** (a desenhar com base no fluxograma):
  - **Documento vencido** (ex.: nitrito de sódio vencido): pode ser liberado pelo **controlador**
    (já confiam que ele faça) — não trava direto.
  - **MP fora do escopo:** **trava direto** (cliente resolve rápido; foi ele que não anexou).
    Liberação emergencial sobe a um gestor.
  - 🧩 **Toda liberação fica REGISTRADA** (quem autorizou — Lina/Dib/gestor). Auditável.
- ❓ Soha sugeriu diferenciar **MP crítica × não-crítica** p/ decidir o que trava (assunto
  estava sendo discutido no fim da reunião — confirmar critério).
- 🎯 FAMBRAS estuda internamente a **matriz de criticidade × destravador** e devolve no
  alinhamento do fluxograma.

---

## 5. SysHalal — Exportação / Embarque

- 🔧 **Ciclo fechado embarque ⇄ certificado** (em teste / a implementar a trava):
  1. Monta relatório de exportação no SIH + anexa documentos.
  2. Informa o **nº do certificado halal** (draft/prévia que existe no SysHalal) — alguns SIF exigem.
  3. SIH **só deixa avançar o embarque** se essa informação estiver presente.
  4. SysHalal **só autoriza/emite o certificado** se o relatório de embarque estiver **aprovado**.
- 🔧 **No SysHalal:** vínculo do nº cert entra **nesta semana, sem trava** (só informativo
  por enquanto, p/ validar antes de amarrar).
- 🧩 **Caso "industrializado roteado como In Natura"** (Lina) — semana passada um cert/relatório
  de **industrializado** foi parar na divisão **In Natura** (roteamento/classificação errada entre
  as duas divisões do SIH) e ninguém localiza os relatórios. Garantir **roteamento correto por
  categoria/divisão** + rastreabilidade (tela de status/pendências). O ciclo acima ajuda a evitar o buraco.

---

## 6. Ações imediatas (donos)
| # | Ação | Dono | Sistema |
|---|------|------|---------|
| 1 | Montar fluxograma do relatório de fabricação c/ MP fora de escopo + travas; compartilhar pós-almoço | Renato | Cross |
| 2 | Agendar reunião ~30 min p/ validar fluxograma | Renato + FAMBRAS | Cross |
| 3 | Criar perfil "Qualidade" no SIH + investigar e-mails de acesso (Elaine/Soha) | Renato | SIH |
| 4 | Enviar Power BI de qualidade atualizado | Elaine | SIH |
| 5 | Definir matriz de criticidade de travas + quem destrava (MP crítica × não-crítica) | FAMBRAS (Lina/Dib/Elaine) | Cross |
| 6 | Subir tela de busca do catálogo global no menu | Renato | GC |
| 7 | Colocar validade/vencimento de cert MP + alerta de vencido | Renato | GC |
| 8 | Implementar nº cert no SysHalal (sem trava) nesta semana | Renato | SysHalal |

---

## 7. Encaixe no BACKLOG-ECOHALAL
- §4 (fluxo MP fora de escopo + travas) **estende** [1.2 Embarque](#) e [1.3 SIH⇄GC consumir MP] —
  o consumo read-only de MP (1.3, já em prod) é a base da **lista suspensa** do supervisor.
- Importação/revisão de MP (§3) **encaixa em FAM-0017 F4 (RevisionLog ISO 17065)** — prioridade já sinalizada.
- Validade/alerta de cert MP (§3) e busca do catálogo (§3) **complementam Catálogo Produtos 5A-2**.
- Ciclo embarque⇄cert (§5) **conecta** o Dossiê de Exportação (Fase 1/2) com o SysHalal.
- **Novo bloco** a refletir no backlog: **"Fluxo de homologação MP + escalonamento de travas"**
  (cross GC/SIH/SysHalal) — aguarda fluxograma + decisão FAMBRAS.
