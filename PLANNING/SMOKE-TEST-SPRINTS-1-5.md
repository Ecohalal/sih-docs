# Roteiro de Smoke Test — Sprints 1 a 5 em Produção

> **Objetivo:** validar end-to-end as 5 Sprints já deployadas (TASK-01 a TASK-11)
> com usuários reais antes de liberar para o cliente.
>
> **Data alvo:** 2026-05-07 em diante.
> **Executor:** Renato (PO).
> **Tempo estimado:** 90–120 min se tudo correr bem.

---

## Como usar este roteiro

1. Marque cada `[ ]` com `[x]` ao concluir.
2. Em qualquer falha, **pare** e copie:
   - URL exata acessada
   - Status HTTP (DevTools → Network)
   - Mensagem de erro (UI + console)
   - Body da request quando aplicável
3. Reporte no chat — eu interpreto e a gente decide entre fix em release ou rollback parcial.

**Critério de aceite global:** todos os blocos verdes = pronto para liberar Sprints 1–5
para uso pleno do cliente.

---

## Pré-requisitos

- [ ] URL do frontend prod aberta no navegador
- [ ] DevTools (F12) aberto na aba Network — ajuda a capturar erros
- [ ] Acesso admin no SIH prod (para criar usuários e plantas)
- [ ] Um certificado **FAMBRAS real** com número conhecido (para TASK-11)
- [ ] Um documento simulando **certificado de outra certificadora** (PDF qualquer, ≤10MB)
- [ ] Um e-mail real seu (para validar notificação de rejeição via SES)

---

## BLOCO 0 — Setup (criar usuários e plantas)

> Sem isso o resto não roda. Plantas precisam de `companyGroup` (IN/IND) e
> os controladores precisam ser segmentados.

### 0.1 — Plantas com grupo IN/IND

- [ ] Logar como **admin**
- [ ] Ir em Plantas → editar 1 planta existente → setar **companyGroup = IN** → salvar
- [ ] Editar outra planta → setar **companyGroup = IND** → salvar
- [ ] **Esperado:** o campo "Grupo Empresarial" aparece no PlantForm e persiste

### 0.2 — Usuários de teste (5 perfis)

Criar em Usuários → Novo Usuário:

| # | Nome | Role | companyGroup | extraPlantAccess | isManager |
|---|---|---|---|---|---|
| 1 | sup-IN-teste | supervisor | — (não aplica) | — | — |
| 2 | sup-IND-teste | supervisor | — (não aplica) | — | — |
| 3 | ctrl-IN-teste | controlador | IN | (vazio) | false |
| 4 | ctrl-IND-teste | controlador | IND | 1 planta IN | false |
| 5 | ctrl-gestor-teste | controlador | IN | (vazio) | **true** |

- [ ] Usuário 1 criado
- [ ] Usuário 2 criado
- [ ] Usuário 3 criado — **validar:** dropdown companyGroup aparece quando role=controlador
- [ ] Usuário 4 criado — **validar:** multiselect de plantas extras (do grupo IND, mas selecionar uma IN) aparece
- [ ] Usuário 5 criado — **validar:** checkbox "Gestor de Controladoria" aparece

> Use o seu e-mail real no usuário 1 (sup-IN-teste) — vai ser o destinatário do email de rejeição.

---

## BLOCO 1 — Sprint 1 (TASK-02 + TASK-03)

> Perfil controladoria + segmentação por grupo.

### 1.1 — Controlador NÃO pode editar relatórios

- [ ] Logar como **ctrl-IN-teste**
- [ ] Ir em Abate → abrir um relatório qualquer
- [ ] **Esperado:** todos os campos read-only, sem botão "Salvar" / "Editar"
- [ ] Tentar criar novo relatório de abate
- [ ] **Esperado:** botão "Novo" oculto OU rota retorna 403

### 1.2 — Sidebar mostra item "Controladoria"

- [ ] Como **ctrl-IN-teste**, conferir sidebar
- [ ] **Esperado:** aparece item "Controladoria" (com ícone shield/check)
- [ ] Clicar → abre dashboard

### 1.3 — Segmentação IN/IND

- [ ] Como **sup-IN-teste**, criar 1 relatório de abate na planta IN → assinar
- [ ] Como **sup-IND-teste**, criar 1 relatório de abate na planta IND → assinar
- [ ] Logar como **ctrl-IN-teste** → Dashboard Controladoria
- [ ] **Esperado:** vê o relatório IN, **não** vê o relatório IND
- [ ] Logar como **ctrl-IND-teste** → Dashboard
- [ ] **Esperado:** vê o relatório IND **e também** o relatório IN (porque tem extraPlantAccess pra essa planta)
- [ ] Logar como **ctrl-gestor-teste** → Dashboard
- [ ] **Esperado:** vê ambos (gestor enxerga tudo)

---

## BLOCO 2 — Sprint 2 (TASK-01 + TASK-04)

> Duplo check + dashboard controladoria.

### 2.1 — Fluxo Aprovação

- [ ] Como **sup-IN-teste**, criar relatório de abate → assinar (fica em "assinado")
- [ ] Logar como **ctrl-IN-teste** → Dashboard → aba "Na fila"
- [ ] **Esperado:** relatório aparece com aging verde (recém-criado)
- [ ] Clicar [Assumir para Análise]
- [ ] **Esperado:** sai da fila, vai pra "Meus", status muda para "em análise por ctrl-IN-teste"
- [ ] Clicar [Aprovar]
- [ ] **Esperado:** status muda para `aprovado` (badge verde forte)

### 2.2 — Fluxo Rejeição + Reabertura

- [ ] Como **sup-IN-teste**, criar segundo relatório → assinar
- [ ] Como **ctrl-IN-teste** → assumir → clicar [Rejeitar]
- [ ] **Esperado:** modal exige motivo. Tentar enviar vazio → bloqueado
- [ ] Preencher motivo "teste de rejeição" → confirmar
- [ ] **Esperado:** status `rejeitado` (badge vermelho)
- [ ] Logar como **sup-IN-teste** → abrir o relatório rejeitado
- [ ] **Esperado:** banner "Relatório devolvido pela Controladoria" com motivo visível
- [ ] **Esperado:** botão [Reabrir para Edição] disponível
- [ ] Clicar [Reabrir] → editar algum campo → re-assinar
- [ ] **Esperado:** volta para `assinado`, aparece de novo na fila do controlador

### 2.3 — Histórico de transições (statusHistory)

- [ ] Como qualquer role, abrir o relatório do passo 2.2
- [ ] Expandir componente "Histórico" / "StatusHistory"
- [ ] **Esperado:** linha do tempo com:
  - rascunho → assinado (sup)
  - assinado → assumido (ctrl)
  - assinado → rejeitado (ctrl, com motivo)
  - rejeitado → rascunho (sup, ao reabrir)
  - rascunho → assinado (sup, re-assinatura)
  - assinado → aprovado (ctrl)

### 2.4 — Gestor pode reatribuir

- [ ] Como **sup-IND-teste**, criar relatório → assinar
- [ ] Como **ctrl-IND-teste**, assumir o relatório (não aprovar ainda)
- [ ] Logar como **ctrl-gestor-teste** → Dashboard
- [ ] **Esperado:** vê o relatório com "em análise por ctrl-IND-teste"
- [ ] Clicar [Reatribuir] → escolher outro controlador
- [ ] **Esperado:** assignedToId muda; statusHistory registra "reassigned"

### 2.5 — Aging visual

- [ ] Na fila do dashboard, conferir cores:
  - Verde: < 24h
  - Amarelo: 24–48h
  - Vermelho: > 48h
- [ ] **Esperado:** cores corretas (relatórios novos = verde)

### 2.6 — KPIs

- [ ] No dashboard, conferir cards de KPI: Na fila / Meus / Aprovados hoje / Rejeitados hoje
- [ ] **Esperado:** números batem com o que foi feito nos passos anteriores

---

## BLOCO 3 — Sprint 3 (TASK-05 + TASK-08)

> Bug transferências + degolador condicional.

### 3.1 — Origem/destino em todos os subtipos de transferência

- [ ] Como **sup-IN-teste**, criar relatório de embarque (Shipping)
- [ ] Para CADA subtipo abaixo, abrir o form e conferir presença dos campos origem + destino:
  - [ ] `transferencia`
  - [ ] `transferencia_industrializados`
  - [ ] `transferencia_in_natura`
  - [ ] `transferencia_subprodutos`
  - [ ] `transferencia_generica`
- [ ] Criar UM relatório de transferência preenchendo origem E destino → salvar → gerar PDF
- [ ] **Esperado:** PDF inclui ambos endereços

### 3.2 — Degolador some no abate de aves

- [ ] Como **sup-IN-teste**, novo relatório de abate → escolher species = **ave**
- [ ] **Esperado:** seção "Degolador" (slaughtererName / slaughtererDoc) **não aparece**
- [ ] **Esperado:** checklist mantém item "Tasmya" do degolador
- [ ] Salvar → gerar PDF
- [ ] **Esperado:** PDF não tem seção de identificação do degolador
- [ ] Repetir com species = **bovino**
- [ ] **Esperado:** seção Degolador APARECE normalmente

---

## BLOCO 4 — Sprint 4 (TASK-06 + TASK-09)

> Notificações + anexos.

### 4.1 — Notificação in-app: assinatura

- [ ] Como **sup-IN-teste**, assinar um relatório novo
- [ ] Logar como **ctrl-IN-teste** (em outra aba ou após logout)
- [ ] **Esperado:** badge no sino do header com contagem ≥1
- [ ] Clicar no sino → dropdown abre
- [ ] **Esperado:** notificação "Relatório aguardando aprovação" aparece
- [ ] Clicar na notificação → navega direto para o relatório

### 4.2 — Notificação in-app: aprovação

- [ ] Como **ctrl-IN-teste**, assumir e aprovar um relatório do **sup-IN-teste**
- [ ] Logar como **sup-IN-teste**
- [ ] **Esperado:** notificação "Relatório aprovado" no sino

### 4.3 — Notificação in-app + EMAIL: rejeição

- [ ] Como **sup-IN-teste**, assinar relatório novo
- [ ] Como **ctrl-IN-teste**, assumir → rejeitar com motivo "teste smoke email"
- [ ] Logar como **sup-IN-teste**
- [ ] **Esperado:** notificação "Relatório rejeitado" no sino
- [ ] **Conferir caixa de e-mail** do sup-IN-teste (incluir spam)
- [ ] **Esperado em ≤2 min:** e-mail do AWS SES com:
  - serial do relatório
  - planta
  - motivo "teste smoke email"
  - link clicável para o relatório
- [ ] **Atenção:** se SES não configurado, fluxo NÃO deve quebrar (best-effort) — mas notificação in-app tem que aparecer

### 4.4 — Marcar como lida

- [ ] No dropdown do sino, clicar em uma notificação → ela some/fica marcada
- [ ] Clicar em "Marcar todas como lidas" → badge zera

### 4.5 — Anexos em relatório de venda/transferência

- [ ] Como **sup-IN-teste**, criar relatório de embarque tipo `venda_*` ou `transferencia_*`
- [ ] **Esperado:** seção "Documentos Anexos" visível no form (rascunho)
- [ ] Upload de um PDF ≤10MB, escolher categoria **CSI**
- [ ] **Esperado:** arquivo aparece na lista; upload com indicador de progresso
- [ ] Tentar upload de arquivo > 10MB
- [ ] **Esperado:** erro de validação clara
- [ ] Tentar upload de arquivo `.exe`
- [ ] **Esperado:** erro (apenas PDF/JPG/PNG)
- [ ] Clicar em "Download" no anexo
- [ ] **Esperado:** abre/baixa o arquivo via presigned URL S3
- [ ] Assinar o relatório → conferir que botão "Remover anexo" some
- [ ] **Esperado:** anexos só editáveis em rascunho

### 4.6 — Anexos NÃO aparecem em abate

- [ ] Abrir form de relatório de abate
- [ ] **Esperado:** seção "Documentos Anexos" **não existe**

---

## BLOCO 5 — Sprint 5 (TASK-07 + TASK-11)

> Desossa bovinos + plantas externas + cert halal SysHalal.

### 5.1 — Plantas externas (cert não-FAMBRAS)

- [ ] Como **admin**, em Plantas → Nova Planta
- [ ] **Esperado:** checkbox/flag "Planta externa" disponível
- [ ] Marcar como externa → preencher:
  - Certificadora: "Outra Halal Cert Inc."
  - Número do certificado externo
  - Data de emissão
  - Data de expiração
  - Upload do PDF do certificado externo
- [ ] **Esperado:** salva sem erro
- [ ] Conferir lista de plantas
- [ ] **Esperado:** badge/indicador visual "Externa" na lista

### 5.2 — Tipo "Desossa" disponível

- [ ] Como **sup-IN-teste**, criar novo Relatório de Produção
- [ ] **Esperado:** dropdown de tipo inclui "Desossa"
- [ ] Selecionar Desossa
- [ ] **Esperado:** componente `DesossaFields` renderiza campos específicos
- [ ] Preencher:
  - Planta de origem da carcaça (selecionar uma planta — pode ser interna OU a externa criada em 5.1)
  - Demais campos obrigatórios (rendimento, cortes, temperaturas, etc.)
- [ ] Salvar como rascunho → assinar
- [ ] **Esperado:** salva sem erro 500/400
- [ ] Gerar PDF
- [ ] **Esperado:** PDF de desossa inclui:
  - Nome + SIF da planta de origem
  - Se origem é planta externa: nome da certificadora externa visível
  - Cortes e rendimento
  - Checklist de verificação específico

### 5.3 — Sidebar item Desossa

- [ ] Conferir sidebar como supervisor ou admin
- [ ] **Esperado:** item "Desossa" aparece no menu (commit `e21fb4c` adicionou)

### 5.4 — Lookup de cert FAMBRAS real (TASK-11)

- [ ] Como **sup-IN-teste**, ir em Inventário → Recebimento de Carne → Novo
- [ ] Localizar componente `HalalCertField`
- [ ] Digitar o número do **certificado FAMBRAS real** que você tem
- [ ] Clicar [Buscar]
- [ ] **Esperado em ≤3s:**
  - Dados preenchidos automaticamente (validade, escopo, status vigente)
  - Badge "Certificado FAMBRAS verificado" (verde)
  - Link para visualizar o PDF (proxy via `/halal-cert/pdf`)
  - Source = `syshalal`
- [ ] Clicar no link do PDF
- [ ] **Esperado:** PDF abre / baixa corretamente

### 5.5 — Fallback manual (cert externo)

- [ ] Mesmo form, novo registro
- [ ] Digitar número fictício "EXT-FAKE-12345" → Buscar
- [ ] **Esperado:**
  - SysHalal retorna vazio
  - UI mostra "Certificado não encontrado — fazer upload manual"
  - Habilita campos: número (manual), validade (manual), upload PDF
- [ ] Preencher manual + upload do PDF que você tem
- [ ] **Esperado:** salva com source = `manual`

### 5.6 — HalalCertField em outros forms

Repetir 5.4 (busca FAMBRAS) em:

- [ ] **BatchInventoryForm** (Inventário → Lotes → Novo)
- [ ] **ShippingReportForm** subtipo `transferencia_*`
- [ ] **Esperado:** componente funciona igual em todos os 3 lugares

### 5.7 — API SysHalal indisponível não trava o fluxo

- [ ] (opcional, se conseguir simular) — bloquear acesso ao SysHalal e tentar buscar
- [ ] **Esperado:** UI mostra erro amigável, libera fallback manual, fluxo do formulário não trava

---

## BLOCO 6 — Pendências de infra (não bloqueantes)

### 6.1 — Ícone PWA

- [ ] Em qualquer página, abrir DevTools → Application → Manifest
- [ ] **Esperado:** sem warning sobre `icon-192x192.png` (era warning antigo)
- [ ] Se ainda houver: anotar que precisa publicar o ícone no S3/CloudFront

### 6.2 — Migrations auto-aplicadas

- [ ] Conferir se algum endpoint que toca tabela nova retorna 401 (não 500)
- [ ] **Sugestão de teste rápido:** abrir Inventário → carregar lista (toca `meat_inventory_receipts`)
- [ ] **Esperado:** lista carrega ou 401 — nunca 500
- [ ] Se 500: rodar `feedback_checklist_predeploy_sih.md` item 1 (verificar logs ECS)

---

## Reportar resultados

Ao concluir, me passa:

1. **Resumo:** "X/Y blocos verdes"
2. **Lista de falhas:** para cada `[ ]` que não passou — passo, status HTTP, msg de erro
3. **Decisão pendente:** se algo deu erro, decidir entre:
   - hotfix em `release` (rápido, vai pra prod)
   - rollback de um commit específico
   - aceitar como bug conhecido e fixar em próxima sprint

Eu interpreto e a gente segue daí.
