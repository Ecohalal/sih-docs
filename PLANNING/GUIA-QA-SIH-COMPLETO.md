# Guia de Testes — SIH (Sistema de Supervisão Industrial Halal)

**Para:** Nilza — Qualidade EcoHalal
**Sistema:** https://supervisao-industrial.ecohalal.solutions
**Versão deste guia:** 2026-05-12

---

## 1. Sobre este guia

Este documento orienta a execução de um teste completo do SIH cobrindo todas
as funcionalidades do sistema. O objetivo é validar que tudo funciona como
esperado **antes** da liberação para o cliente FAMBRAS.

A execução é dividida em **12 módulos** que cobrem todo o sistema. Cada
módulo tem cenários numerados (ex.: M3.5 = Módulo 3, cenário 5). Os módulos
devem ser executados na ordem proposta — alguns dependem de dados criados
em módulos anteriores.

Tempo estimado: **4-6 horas**. Pode ser dividido em várias sessões.

---

## 2. Como usar

### 2.1 Marcação

Cada cenário tem `[ ]` no início. Marque com `[x]` ao concluir e adicione
ao final:

- ✅ se passou exatamente como esperado
- ⚠️ se passou parcialmente (anote o que divergiu)
- ❌ se falhou (anote tudo conforme item 2.2)

### 2.2 Em caso de falha — o que reportar

Para cada `❌`, anote em uma planilha ou documento separado:

| Campo | Exemplo |
|---|---|
| Módulo + cenário | M5.3 |
| Descrição curta | "Erro ao salvar relatório de abate" |
| URL completa | `/slaughter-reports/new` |
| Passo onde quebrou | "Após preencher tudo e clicar em 'Salvar Rascunho'" |
| Mensagem de erro (UI) | "Falha ao salvar — tente novamente" |
| Status HTTP (DevTools) | 500 |
| Mensagem de erro (Console) | conteúdo do erro vermelho |
| Screenshot | print da tela com o erro |

**Como abrir DevTools:** tecla `F12` (ou Ctrl+Shift+I). Aba **Network** mostra
as requests; aba **Console** mostra erros JavaScript. Mantenha aberto durante
todo o teste.

### 2.3 O que NÃO precisa testar

- Performance / tempo de resposta (já foi avaliado pela equipe técnica)
- Compatibilidade com navegadores antigos (Internet Explorer, etc.)
- Layout em telas muito pequenas (sistema é desenhado para desktop)

---

## 3. Pré-requisitos

- **Navegador:** Chrome ou Edge atualizado. Recomendamos Chrome.
- **Tela:** mínimo 1280×800. Ideal 1920×1080 ou maior.
- **Email pessoal acessível** para testar notificações por email (cadastre no
  perfil de teste — qualquer email seu serve, incluindo Gmail/Outlook).
- **DevTools aberto:** F12, aba Network.
- **Sem extensões interferindo:** desative bloqueadores de anúncios e antivírus
  navegacionais durante o teste (algumas extensões interferem em popups).

---

## 4. Credenciais de acesso

| Perfil | Email | Senha |
|---|---|---|
| Admin principal | `admin@sih.com` | (a senha do Renato — confirmar com ele antes de começar) |

Durante o setup (Módulo 2.4), você vai criar **seus próprios** usuários de
teste com email à sua escolha. A partir daí, use esses usuários nos módulos
seguintes (não os usuários antigos de teste).

---

## 5. Setup inicial

### 5.1 Confirme acesso

- [ ] Abra https://supervisao-industrial.ecohalal.solutions em uma janela
      anônima (Ctrl+Shift+N no Chrome)
- [ ] Tela de login deve aparecer
- [ ] Faça login com `admin@sih.com`
- [ ] **Esperado:** redireciona para o Dashboard com o menu lateral à esquerda
      e seu nome ("admin@sih.com") no canto superior direito

> Se aparecer página em branco ou erro 500: pare, avise o Renato, NÃO siga.

### 5.2 Reconheça a interface

- [ ] Sidebar à esquerda com os grupos: Dashboard, Analytics, In Natura,
      Industrializados, Subprodutos, Inventário, Não-Conformidades, Escalas,
      Gestão
- [ ] Cabeçalho com sino de notificações 🔔 e seu nome
- [ ] Clique no botão `<` do topo da sidebar — sidebar colapsa para ícones
- [ ] Clique no `>` — expande de volta

---

## MÓDULO 1 — Autenticação e Sessão

### M1.1 Login com credenciais válidas

- [ ] Já validado no Setup 5.1. Marcar ✅ se ali passou.

### M1.2 Login com senha incorreta

- [ ] Faça logout (avatar no canto superior direito → "Sair")
- [ ] Na tela de login, digite `admin@sih.com` + qualquer senha errada
- [ ] **Esperado:** mensagem "Email ou senha inválidos" (ou similar) sem
      redirecionar. **Não** deve dar erro 500 nem tela branca.

### M1.3 Login com email inexistente

- [ ] Digite `nao-existe@teste.com` + qualquer senha
- [ ] **Esperado:** mesma mensagem genérica "Email ou senha inválidos"
- [ ] **Importante (segurança):** a mensagem NÃO deve dizer "usuário não
      existe" — isso vazaria existência de contas. Deve ser sempre genérica.

### M1.4 Login válido após erro

- [ ] Logo após o erro, entre com `admin@sih.com` + senha correta
- [ ] **Esperado:** login normal, vai para Dashboard

### M1.5 Logout

- [ ] Avatar → Sair
- [ ] **Esperado:** volta para tela de login, URL `/login`
- [ ] Tente voltar com botão "voltar" do navegador
- [ ] **Esperado:** continua na tela de login (não deve voltar para Dashboard
      mantendo sessão antiga)

### M1.6 Acesso direto sem login

- [ ] Estando deslogado, cole na URL: `/dashboard` (após o domínio)
- [ ] **Esperado:** redireciona para `/login`. NÃO deve mostrar Dashboard.

---

## MÓDULO 2 — Gestão (Plantas, Usuários, Colaboradores)

> Aqui você prepara os dados de teste para os módulos seguintes.

### M2.1 Listar plantas existentes

- [ ] Logado como admin, vá em Gestão → Plantas
- [ ] **Esperado:** lista com pelo menos 3 plantas (Planta IN Teste, Planta IND
      Teste, Planta IN Teste 2)
- [ ] Cada linha mostra: nome, código SIF, tipo, status ativo/inativo
- [ ] Filtros e busca disponíveis no topo

### M2.2 Criar planta nova

- [ ] Clique em "Nova Planta"
- [ ] Preencha:
  - Nome: `Planta QA Nilza`
  - SIF: `9999`
  - Tipo: Frigorífico
  - Divisão: IN
  - Espécies: marque "bovino" e "ave"
  - Endereço: rua/cidade/estado/CEP (qualquer endereço real)
  - Contato: telefone, email
  - Deixe "Planta Externa" desmarcado
- [ ] Clique em "Salvar"
- [ ] **Esperado:** redireciona para lista; planta aparece como "Ativa"

### M2.3 Editar planta

- [ ] Na lista, clique na planta `Planta QA Nilza`
- [ ] Mude o nome para `Planta QA Nilza (editada)`
- [ ] Salve
- [ ] **Esperado:** retorna à lista com o novo nome

### M2.4 Criar planta externa

- [ ] Nova Planta
- [ ] Preencha:
  - Nome: `Planta Externa QA`
  - SIF: `8888`
  - Tipo: Frigorífico
  - Divisão: IN
  - Marque a flag "Planta Externa" (ou similar)
  - Certificadora: `Outra Cert Halal Inc.`
  - Número do certificado externo: `EXT-001`
  - Data emissão: data atual menos 1 mês
  - Data expiração: data atual mais 1 ano
  - Upload de um PDF qualquer (≤10 MB) — pode ser qualquer PDF
- [ ] Salvar
- [ ] **Esperado:** planta salva. Na lista, deve aparecer com algum indicador
      visual de "Externa" (badge ou ícone diferente).

### M2.5 Criar usuários de teste

Você vai criar 5 perfis de teste com **seus próprios emails** (ou aliases).
Use uma convenção como `nilza+sup@ecohalal.com.br`, `nilza+ctrl@...`, etc.
(Gmail e a maioria dos provedores aceitam o `+xxx` como sufixo no mesmo
inbox.)

Em **Gestão → Usuários → Novo Usuário**, crie:

| # | Nome | Email | Role | Divisão | extraPlantAccess | isManager | Senha |
|---|---|---|---|---|---|---|---|
| 1 | nilza-sup-IN | (email seu sup-IN) | supervisor | — | — | — | `QA@2026` |
| 2 | nilza-sup-IND | (email seu sup-IND) | supervisor | — | — | — | `QA@2026` |
| 3 | nilza-ctrl-IN | (email seu ctrl-IN) | controlador | IN | — | false | `QA@2026` |
| 4 | nilza-ctrl-IND | (email seu ctrl-IND) | controlador | IND | marcar 1 planta IN | false | `QA@2026` |
| 5 | nilza-gestor | (email seu gestor) | controlador | IN | — | **true** | `QA@2026` |

- [ ] Usuário 1 criado — campo "Divisão" não aparece (correto, supervisor não tem)
- [ ] Usuário 2 criado
- [ ] Usuário 3 criado — campo "Divisão" aparece como obrigatório para role=controlador
- [ ] Usuário 4 criado — multiselect "Acesso Extra a Plantas" aparece
- [ ] Usuário 5 criado — checkbox "Gestor de Controladoria" aparece e foi marcado

### M2.6 Validação de email duplicado

- [ ] Tente criar mais um usuário com o email do usuário 1
- [ ] **Esperado:** erro claro "Email já cadastrado" (ou similar). NÃO deve dar
      erro 500.

### M2.7 Validação de senha fraca

- [ ] Tente criar um usuário com senha `123`
- [ ] **Esperado:** erro de validação na hora, antes de enviar.

### M2.8 Inativar / reativar usuário

- [ ] Na lista de usuários, edite o usuário 1
- [ ] Desmarque "Ativo" → salve
- [ ] Faça logout e tente entrar como esse usuário inativo
- [ ] **Esperado:** login negado com mensagem clara (pode ser "Usuário inativo"
      ou "Email ou senha inválidos" — o importante é não permitir login)
- [ ] Volte como admin, reative o usuário, faça login com ele
- [ ] **Esperado:** entra normalmente

### M2.9 Colaboradores (carregadores, supervisores externos, etc.)

- [ ] Vá em Gestão → Colaboradores
- [ ] Liste, deve haver alguns ou estar vazia
- [ ] Clique em "Novo Colaborador"
- [ ] Preencha: nome, documento (CPF/CNPJ), função, planta
- [ ] Salve
- [ ] **Esperado:** colaborador aparece na lista, vinculado à planta escolhida

### M2.10 Remoção / desativação de colaborador

- [ ] Edite o colaborador criado
- [ ] Marque como inativo (ou exclua, se houver opção)
- [ ] Salve
- [ ] **Esperado:** sai da lista de ativos

---

## MÓDULO 3 — Abate (FM 7.1.4)

> Relatório de abate é o coração do sistema. Tem duas variantes: bovinos
> (FM 7.1.4.2) e aves (FM 7.1.4.1). Os campos mudam conforme a espécie.

### M3.1 Listar abates

- [ ] Logado como admin, vá em In Natura → Abate
- [ ] **Esperado:** lista (pode estar vazia ou ter alguns abates anteriores)
- [ ] Filtros disponíveis: planta, status, período, espécie

### M3.2 Criar abate BOVINO como supervisor

- [ ] Faça logout do admin
- [ ] Login como `nilza-sup-IN`
- [ ] Vá em In Natura → Abate → clique em "Novo Relatório"
- [ ] Preencha:
  - Planta: `Planta QA Nilza (editada)` — só plantas tipo abatedouro/frigorífico aparecem
  - Espécie: **bovino**
  - Data: hoje
  - Hora início e fim do abate
  - Número de animais abatidos
  - Aterramento (data e horário)
  - Lote: gerar lote automaticamente (ou digite manualmente)
  - Degolador (slaughtererName e doc) — **deve aparecer**
  - Insensibilização (Bovino — FM 7.1.4.2) — Pressão aplicada, Animal vivo, Sem lesões nos 2 horários
  - Avaliação geral
  - Avaliação das câmaras de resfriamento
  - Verificações checklist (todas C/NC)
  - Observações
- [ ] Clique em "Salvar Rascunho"
- [ ] **Esperado:** salva, redireciona para a tela do relatório com status
      "rascunho"

### M3.3 Editar rascunho

- [ ] Mude qualquer campo (ex.: observações)
- [ ] Salve novamente
- [ ] **Esperado:** atualiza sem criar novo relatório

### M3.4 Assinar abate

- [ ] No mesmo relatório, clique em "Assinar"
- [ ] Confirme no diálogo de assinatura
- [ ] **Esperado:** status muda para "assinado", aparece "Assinado por
      nilza-sup-IN" no topo, com hash da assinatura

### M3.5 Após assinatura, edição bloqueada

- [ ] **Esperado:** todos os campos ficam read-only. Botão "Salvar" não aparece.
- [ ] Botão "Imprimir PDF" aparece (verificar)

### M3.6 Gerar PDF de abate bovino

- [ ] Clique em "Imprimir PDF"
- [ ] **Esperado:** baixa arquivo `abate-XX-XXXX.pdf`
- [ ] Abra o PDF
- [ ] **Confirmar no PDF:**
  - Cabeçalho com logo + número do relatório (formato `AB-SIFXXXX/AAAA/NNNNN`)
  - Dados da planta (nome, SIF, endereço)
  - Espécie: bovino
  - Seção "Degolador" com nome e documento — **deve aparecer**
  - Seção Insensibilização: tabela com Pressão / Animal vivo / Sem lesões
  - Checklist de verificações
  - Assinatura: nome do supervisor, data/hora, hash

### M3.7 Criar abate AVE como supervisor

- [ ] Volte para a lista de abate
- [ ] "Novo Relatório"
- [ ] Planta: a mesma planta criada (ela tem ave e bovino)
- [ ] Espécie: **ave**
- [ ] Data, hora, número de animais (ex.: 50.000)
- [ ] Aterramento
- [ ] **Importante:** seção "Degolador" NÃO deve aparecer (campos
      slaughtererName/slaughtererDoc ocultos)
- [ ] Insensibilização (Aves — FM 7.1.4.1) deve aparecer com:
  - Horário 1: Amperagem, Voltagem, Frequência, Tempo cuba, Vel. linha
  - Horário 2: idem
  - Tempo de retorno - Horário 1 e Horário 2
  - **Conferir:** todos os campos vazios têm placeholder no formato `Ex: 0,30`,
    `Ex: 40`, `Ex: 400`, `Ex: 7`, `Ex: 6000`, `Ex: 60` (cinza claro, não
    parecem valores reais)
- [ ] Preencha todos os campos
- [ ] Verifica seção Checklist — deve incluir item "Tasmya" (tradição halal do
      degolador, mesmo sem identificação individual)
- [ ] Salvar rascunho → Assinar
- [ ] Gerar PDF
- [ ] **Confirmar no PDF:**
  - Espécie: ave
  - Seção Degolador AUSENTE
  - Tabela Insensibilização AVES com os 5 campos
  - Checklist com item Tasmya

### M3.8 Tentar criar abate sem campos obrigatórios

- [ ] Novo relatório, deixe campos obrigatórios em branco (planta, espécie,
      data)
- [ ] Clique em Salvar
- [ ] **Esperado:** validação clara antes de enviar OU mensagem de erro do
      backend. NÃO deve dar erro 500 nem tela em branco.

### M3.9 Filtrar e buscar abates

- [ ] Volte para In Natura → Abate (logado como admin)
- [ ] Filtre por planta → só relatórios dessa planta aparecem
- [ ] Filtre por status "assinado" → só os assinados
- [ ] Filtre por período → só os da data
- [ ] Limpe filtros → todos voltam

### M3.10 Reabrir relatório rejeitado (testado no Módulo 9)

- [ ] Esse cenário será testado quando rodarmos o Módulo 9 (Controladoria).
      Pular aqui.

---

## MÓDULO 4 — Produção

> Cobre 10 tipos diferentes: Desossa, Fabricação, Tripas, Fracionamento,
> Couro, Mucosa, Heparina Bruta, Heparina Purificação, Raspa/Aparas, Gelatina.
> Cada tipo tem campos específicos.

### M4.1 Lista de produção

- [ ] Login como `nilza-sup-IN`
- [ ] Vá em In Natura → Desossa
- [ ] **Esperado:** lista filtrada por `productionType=desossa`
- [ ] Sidebar destaca "Desossa"

### M4.2 Criar relatório de Desossa

- [ ] Clique em "Novo Relatório"
- [ ] Preencha:
  - Planta: alguma planta tipo `processamento` (se não houver, criar uma em
    Gestão → Plantas; ou aceitar erro de "nenhuma planta disponível" e
    reportar)
  - Tipo: Desossa (deve estar pré-selecionado se acessou via "Desossa")
  - Data, hora
  - Planta de origem da carcaça (selecione uma das suas plantas — pode ser
    a `Planta Externa QA` para validar o caminho de planta externa)
  - Cortes produzidos (adicionar pelo menos 1)
  - Rendimento (%)
  - Temperaturas (entrada/saída)
  - Lote
  - Checklist
  - Observações
- [ ] Salvar Rascunho
- [ ] Assinar
- [ ] Imprimir PDF
- [ ] **No PDF, confirmar:**
  - Tipo: Desossa
  - Planta origem com nome + SIF
  - Se origem é Planta Externa: nome da certificadora externa visível
  - Tabela de cortes e rendimento

### M4.3 Criar relatório de Fabricação (Industrializados)

- [ ] Sidebar → Industrializados → Fabricação → Novo Relatório
- [ ] Preencha conforme campos do form. Lote, planta processamento, etc.
- [ ] Salvar Rascunho → Assinar → PDF

### M4.4 Criar relatório de Tripas

- [ ] Industrializados → Tripas → Novo Relatório
- [ ] Mesmo fluxo

### M4.5 Criar relatório de Fracionamento

- [ ] Industrializados → Fracionamento → Novo Relatório
- [ ] Mesmo fluxo

### M4.6 Criar relatório de Couro (Subproduto)

- [ ] Subprodutos → Couro → Novo Relatório
- [ ] Preencha campos específicos de Couro (pode incluir wet blue, salgado, etc.)
- [ ] Salvar → Assinar → PDF

### M4.7 Criar relatório de Mucosa

- [ ] Subprodutos → Mucosa → Novo Relatório
- [ ] Mesmo fluxo

### M4.8 Criar relatório de Heparina Bruta

- [ ] Subprodutos → Heparina Bruta → Novo Relatório
- [ ] Mesmo fluxo

### M4.9 Criar relatório de Heparina Purificação

- [ ] Subprodutos → Heparina Purif. → Novo Relatório
- [ ] Mesmo fluxo

### M4.10 Criar relatório de Raspa/Aparas

- [ ] Subprodutos → Raspa/Aparas → Novo Relatório
- [ ] Mesmo fluxo

### M4.11 Criar relatório de Gelatina

- [ ] Subprodutos → Gelatina → Novo Relatório
- [ ] Mesmo fluxo

### M4.12 Editar rascunho de produção

- [ ] Em qualquer relatório acima ainda em rascunho, edite e salve novamente
- [ ] **Esperado:** atualização sem duplicar

### M4.13 Tentar criar produção sem planta obrigatória

- [ ] Novo relatório, deixe planta vazia
- [ ] **Esperado:** validação bloqueia envio

---

## MÓDULO 5 — Embarque

> 10 subtipos de embarque, todos no mesmo form com `Tipo de Embarque` variando:
> Exportação, Venda Mercado Interno, Transferência, Transf. In Natura,
> Emb. Exp. Industrializados, Venda Industrializados, Transf. Industrializados,
> Venda Subprodutos, Transf. Subprodutos, Transf. Genérica, Venda Couro.

### M5.1 Criar Embarque Exportação

- [ ] Login como `nilza-sup-IN`
- [ ] In Natura → Emb. Exportação → Novo Relatório
- [ ] **Importante (auto-popular Origem):**
  - Selecione a planta primeiro
  - Verifique que os campos "Abatedouro / Frigorífico" e "Endereço de
    Carregamento" foram preenchidos automaticamente com dados da planta
  - Se a planta for tipo `processamento`, o campo populado será "Unidade de
    Produção"
- [ ] Preencha:
  - Tipo Embarque: Exportação
  - Data de carregamento
  - Nº Série Relatório Halal
  - Exportador / Importador
  - Transporte: tipo (terrestre/aéreo/marítimo), veículo/placa, container, lacre
  - Porto de Embarque / Porto de Destino / País de Destino
  - Nº do Pedido / Nº CSI
  - Adicionar pelo menos 1 produto (tabela de Produtos)
  - Checklist de Verificações
  - Observações
- [ ] Salvar Rascunho → Assinar → Imprimir PDF
- [ ] **No PDF, confirmar:**
  - Nº de série (formato `EM-SIFXXXX/AAAA/NNNNN`)
  - Exportador + Importador + Portos + País destino
  - Tabela de produtos com lote, código, validade
  - Checklist
  - Assinatura

### M5.2 Criar Venda Mercado Interno

- [ ] In Natura → Venda Merc. Int. → Novo Relatório
- [ ] Preencha (foco em campos brasileiros: vendedor, cliente, endereço destino)
- [ ] Salvar → Assinar → PDF

### M5.3 Criar Transferência

- [ ] In Natura → Transferência → Novo Relatório
- [ ] **Validar que ambos campos Origem e Destino aparecem** (origem auto-populada,
      destino digitado)
- [ ] Salvar → Assinar → PDF mostra ambos endereços

### M5.4 Criar Transferência In Natura

- [ ] In Natura → Transf. In Natura → Novo Relatório
- [ ] Mesma validação de origem/destino
- [ ] Salvar → Assinar → PDF

### M5.5 Embarque Industrializados

Repita o fluxo do M5.1 nos 3 subtipos abaixo:

- [ ] Industrializados → Emb. Export. Ind. → Novo Relatório → Salvar → Assinar → PDF
- [ ] Industrializados → Venda Ind. → Novo Relatório → Salvar → Assinar → PDF
- [ ] Industrializados → Transf. Ind. → Novo Relatório → Salvar → Assinar → PDF

### M5.6 Embarque Subprodutos

- [ ] Subprodutos → Venda Subprod. → Novo → Salvar → Assinar → PDF
- [ ] Subprodutos → Transf. Subprod. → Novo → Salvar → Assinar → PDF
- [ ] Subprodutos → Transf. Genérica → Novo → Salvar → Assinar → PDF
- [ ] Subprodutos → Venda Couro → Novo → Salvar → Assinar → PDF

### M5.7 Buscar certificado halal SysHalal

- [ ] Em qualquer relatório de embarque de tipo `transferencia_*` (rascunho),
      localize a seção/campo "Certificado Halal" (ou similar)
- [ ] Digite um número de certificado FAMBRAS real conhecido (pedir ao Renato
      um número válido)
- [ ] Clique em "Buscar"
- [ ] **Esperado em ≤3s:**
  - Dados aparecem auto-preenchidos (validade, escopo, status)
  - Badge "Certificado FAMBRAS verificado" (verde)
  - Link para visualizar PDF
- [ ] Clique no link do PDF → abre/baixa
- [ ] Limpe e digite `EXT-FAKE-12345`
- [ ] Clique em Buscar
- [ ] **Esperado:** "Certificado não encontrado", libera fallback de upload
      manual

### M5.8 Anexar documentos em relatório

- [ ] Em rascunho de Venda ou Transferência, procure a seção "Documentos
      Anexos" (CSI, BL, etc.)
- [ ] Upload de um PDF qualquer ≤10 MB, categoria CSI
- [ ] **Esperado:** arquivo aparece na lista. Indicador de progresso durante o
      upload.
- [ ] Tente upload de arquivo > 10 MB
- [ ] **Esperado:** erro claro com mensagem de tamanho
- [ ] Tente upload de arquivo `.exe`
- [ ] **Esperado:** erro de tipo de arquivo
- [ ] Clique em download de um anexo
- [ ] **Esperado:** baixa via link temporário (S3 presigned URL)
- [ ] Assine o relatório
- [ ] **Esperado:** após assinatura, não é mais possível remover anexos

### M5.9 Verificar serial único e crescente

- [ ] Crie 2 embarques de exportação em sequência na mesma planta
- [ ] **Esperado:** seriais consecutivos (`EM-SIFXXXX/AAAA/00001`, `00002`, …)

### M5.10 Form de embarque sem planta

- [ ] Novo embarque sem selecionar planta → tente assinar
- [ ] **Esperado:** validação bloqueia

---

## MÓDULO 6 — Inventário

### M6.1 Inventário de Carne Halal

- [ ] Login como `nilza-sup-IN` (ou admin se necessário)
- [ ] Sidebar → Inventário → Carne Halal
- [ ] **Esperado:** lista de recebimentos (pode estar vazia)

### M6.2 Novo recebimento de carne

- [ ] Clique em "Novo Recebimento"
- [ ] Preencha:
  - Planta receptora (a sua)
  - Data de recebimento
  - Fornecedor / Planta origem
  - **Campo HalalCertField** — número de certificado halal
  - Digite um cert FAMBRAS real → Buscar → preenche automaticamente
  - Produto recebido (descrição, código)
  - Quantidade, unidade, lote, validade
  - Documento fiscal anexo
- [ ] Salvar
- [ ] **Esperado:** entra na lista

### M6.3 Lançamento de uso de carne recebida

- [ ] Na lista, abra um recebimento
- [ ] Clique em "Usar" ou "Lançamento de Uso"
- [ ] Lance saída parcial (ex.: 100 kg de 500 kg recebidos)
- [ ] Salvar
- [ ] **Esperado:** saldo atualizado (500 - 100 = 400)
- [ ] Tente lançar saída maior que saldo (ex.: 500 sobre 400)
- [ ] **Esperado:** validação bloqueia

### M6.4 Inventário de Lotes de Produção

- [ ] Sidebar → Inventário → Lotes de Produção
- [ ] **Esperado:** lista de lotes

### M6.5 Novo lote de produção

- [ ] Clique em "Novo Lote"
- [ ] Preencha lote, produto, quantidade, planta, data produção, validade
- [ ] **HalalCertField** se aplicável — busca FAMBRAS
- [ ] Salvar
- [ ] **Esperado:** entra na lista

### M6.6 Transferência de lote

- [ ] Em um lote existente, clique em "Transferir"
- [ ] Selecione planta destino, quantidade
- [ ] Salvar
- [ ] **Esperado:** movimentação registrada, saldo da planta origem reduz e
      da planta destino aumenta

### M6.7 Rotulagem

- [ ] Sidebar → Inventário → Rotulagem
- [ ] **Esperado:** página de rotulagem (pode estar em desenvolvimento — anote
      o que estiver disponível)

### M6.8 Dashboard de Inventário (admin)

- [ ] Login como admin
- [ ] Sidebar → Inventário → Dashboard Inv. (só aparece se for admin/coordenador)
- [ ] **Esperado:** painel com indicadores de estoque, movimentações,
      vencimentos

---

## MÓDULO 7 — Não-Conformidades (NCs)

### M7.1 Lista de NCs

- [ ] Sidebar → Não-Conformidades
- [ ] **Esperado:** lista (pode estar vazia)

### M7.2 Nova NC

- [ ] Clique em "Nova NC"
- [ ] Preencha:
  - Tipo de relatório (Abate / Produção / Embarque)
  - Relatório associado (selecionar um dos já criados)
  - Descrição da NC
  - Severidade (alta/média/baixa)
  - Ação corretiva proposta
  - Responsável
  - Data limite
- [ ] Salvar
- [ ] **Esperado:** NC aparece na lista vinculada ao relatório

### M7.3 Atualizar NC

- [ ] Abra a NC criada
- [ ] Marque como "Em tratamento" → salve
- [ ] **Esperado:** status atualiza
- [ ] Marque como "Resolvida" com data e descrição da resolução
- [ ] **Esperado:** status final

### M7.4 NC sem relatório associado

- [ ] Tente criar NC sem selecionar relatório
- [ ] **Esperado:** validação bloqueia (NC sempre tem relatório-pai)

---

## MÓDULO 8 — Escalas (Schedules)

### M8.1 Lista de escalas

- [ ] Sidebar → Escalas
- [ ] **Esperado:** lista de escalas registradas

### M8.2 Nova escala

- [ ] Clique em "Nova Escala"
- [ ] Preencha:
  - Período (data início/fim)
  - Planta
  - Turno
  - Supervisor responsável
  - Colaboradores escalados (multiselect)
  - Tipo (Abate / Produção / Embarque)
- [ ] Salvar
- [ ] **Esperado:** entra na lista

### M8.3 Escala futura vs passada

- [ ] Conferir se há filtro/separação visual entre escalas futuras e passadas
- [ ] **Esperado:** comportamento claro (pode ser cor, tab, ou filtro)

---

## MÓDULO 9 — Controladoria (Duplo Check)

> Fluxo de aprovação. Supervisor assina → Controlador analisa → Aprova ou
> Rejeita. Se rejeitar, supervisor reabre e re-assina.

### M9.1 Sidebar mostra "Controladoria" apenas para controlador

- [ ] Login como admin → sidebar **não** deve mostrar item "Controladoria"
- [ ] Logout, login como `nilza-ctrl-IN`
- [ ] **Esperado:** sidebar mostra "Controladoria"
- [ ] Clique → abre dashboard de controladoria

### M9.2 Dashboard de Controladoria

- [ ] Como `nilza-ctrl-IN`, no Controladoria, conferir:
  - KPIs no topo: "Na fila", "Em análise (Meus)", "Aprovados hoje",
    "Rejeitados hoje"
  - Tabs ou seções: Fila Pendente / Meus em Análise / Concluídos
  - Filtros por tipo de relatório, planta, período

### M9.3 Segmentação IN/IND

- [ ] Como sup-IN, crie um abate na sua planta IN → assine
- [ ] Como sup-IND, crie um abate em planta IND → assine
- [ ] Logue como `nilza-ctrl-IN` → Controladoria
- [ ] **Esperado:** vê o relatório IN, **não** vê o relatório IND
- [ ] Logue como `nilza-ctrl-IND` (que tem extraPlantAccess em planta IN)
- [ ] **Esperado:** vê o relatório IND **e também** o IN
- [ ] Logue como `nilza-gestor` (isManager=true)
- [ ] **Esperado:** vê ambos

### M9.4 Controlador NÃO pode criar relatório

- [ ] Como `nilza-ctrl-IN`, vá em In Natura → Abate
- [ ] **Esperado:** botão "Novo Relatório" NÃO aparece (controlador não cria)
- [ ] Abra um relatório existente
- [ ] **Esperado:** todos os campos read-only, sem botão "Salvar"

### M9.5 Fluxo: Assumir → Aprovar

- [ ] Como `nilza-ctrl-IN`, Dashboard → aba "Fila"
- [ ] Clique no relatório assinado pelo sup → botão [Assumir para Análise]
- [ ] **Esperado:** sai da fila, vai para "Meus", status muda para "em análise
      por nilza-ctrl-IN"
- [ ] Clique [Aprovar]
- [ ] **Esperado:** status muda para `aprovado` (badge verde forte)

### M9.6 Fluxo: Assumir → Rejeitar

- [ ] Como sup-IN, crie outro abate → assine
- [ ] Como `nilza-ctrl-IN`, assuma o relatório → clique [Rejeitar]
- [ ] **Esperado:** modal exige motivo (texto). Tente confirmar vazio →
      bloqueia.
- [ ] Preencha motivo "teste rejeição QA" → confirmar
- [ ] **Esperado:** status `rejeitado` (badge vermelho)

### M9.7 Supervisor vê rejeição e reabre

- [ ] Logue como sup-IN (autor do relatório rejeitado)
- [ ] Abra o relatório
- [ ] **Esperado:**
  - Banner no topo "Relatório devolvido pela Controladoria"
  - Motivo da rejeição visível ("teste rejeição QA")
  - Botão [Reabrir para Edição] disponível
- [ ] Clique [Reabrir] → status volta para `rascunho`
- [ ] Edite qualquer campo → re-assine
- [ ] **Esperado:** status `assinado`, retorna para fila do controlador

### M9.8 Histórico de transições (statusHistory)

- [ ] No relatório do M9.7, expanda "Histórico" ou "StatusHistory"
- [ ] **Esperado:** linha do tempo com TODAS as transições:
  - rascunho → assinado (sup, timestamp)
  - assinado → em análise (ctrl, timestamp)
  - em análise → rejeitado (ctrl, com motivo)
  - rejeitado → rascunho (sup, ao reabrir)
  - rascunho → assinado (sup, re-assinatura)

### M9.9 Gestor reatribui análise

- [ ] Como sup-IND, crie um relatório → assine
- [ ] Como `nilza-ctrl-IND`, assuma (não aprove)
- [ ] Logue como `nilza-gestor`
- [ ] No dashboard, encontre o relatório em análise por ctrl-IND
- [ ] Clique [Reatribuir] → selecione outro controlador
- [ ] **Esperado:** assignedToId muda, statusHistory registra "reassigned"

### M9.10 Aging visual (cores)

- [ ] Na fila do dashboard, conferir cores:
  - Verde: relatório criado há < 24h
  - Amarelo: 24-48h
  - Vermelho: > 48h
- [ ] Se não houver relatórios antigos, pular ou anotar como "não testável
      sem dados antigos"

### M9.11 KPIs batem com os números

- [ ] Conferir que o card "Aprovados hoje" tem o número de aprovações feitas
      no dia
- [ ] Mesmo para Rejeitados, Na fila, Em análise

### M9.12 Filtros da Controladoria

- [ ] Tente filtrar por "Todos os tipos" → veja se retorna todos
- [ ] Tente filtrar só por "Abate" → só abates
- [ ] Tente filtrar por planta específica → só dessa planta

---

## MÓDULO 10 — Notificações

### M10.1 Notificação in-app: ao assinar

- [ ] Como sup-IN, assine um relatório novo
- [ ] Em outra aba (ou janela anônima), logue como `nilza-ctrl-IN`
- [ ] **Esperado:** sino 🔔 no header com badge mostrando contagem ≥1
- [ ] Clique no sino → dropdown abre
- [ ] **Esperado:** notificação "Relatório aguardando aprovação" aparece
- [ ] Clique na notificação
- [ ] **Esperado:** navega direto para o relatório

### M10.2 Notificação in-app: ao aprovar

- [ ] Como ctrl-IN, assuma e aprove um relatório do sup-IN
- [ ] Logue como sup-IN
- [ ] **Esperado:** notificação "Relatório aprovado" no sino

### M10.3 Notificação in-app: ao rejeitar

- [ ] Como sup-IN, assine novo relatório
- [ ] Como ctrl-IN, assuma e rejeite com motivo "teste email QA"
- [ ] Logue como sup-IN
- [ ] **Esperado:** notificação "Relatório rejeitado" no sino

### M10.4 Email de rejeição (SES)

- [ ] Continuando do M10.3, confira a caixa de entrada do email do sup-IN
      (incluindo spam)
- [ ] **Esperado em ≤2 min:** email de `noreply@...` com:
  - Assunto contendo número do relatório
  - Conteúdo: serial, planta, motivo "teste email QA"
  - Link clicável para o relatório
- [ ] **Atenção:** se SES não configurado, este passo pode falhar. Reporte
      como bug e siga.

### M10.5 Marcar como lida

- [ ] Dropdown do sino → clique em uma notificação
- [ ] **Esperado:** notificação some ou fica marcada como lida; contagem do
      badge reduz em 1
- [ ] Clique em "Marcar todas como lidas"
- [ ] **Esperado:** badge zera, lista esvazia

### M10.6 Página completa de notificações

- [ ] No dropdown do sino, clique em "Ver todas"
- [ ] **Esperado:** abre página `/notifications` com lista completa de
      notificações (lidas e não lidas), com filtros

---

## MÓDULO 11 — Dashboard e Analytics

### M11.1 Dashboard principal

- [ ] Sidebar → Dashboard
- [ ] **Esperado:** cards com KPIs gerais — total de relatórios do mês,
      pendentes na controladoria, NCs abertas, etc.
- [ ] Gráficos (Recharts) renderizam sem erro

### M11.2 Analytics Overview

- [ ] Sidebar → Analytics
- [ ] **Esperado:** página com visão geral de todos os módulos analíticos

### M11.3 Analytics — Abate

- [ ] Sidebar → Analytics → expandir (se for grupo) ou navegação direta
- [ ] Acesse `/analytics/slaughter`
- [ ] **Esperado:** gráficos de abate (total animais, planta, espécie, período)
- [ ] Filtre por período → gráficos atualizam

### M11.4 Analytics — Produção

- [ ] Acesse `/analytics/production`
- [ ] **Esperado:** gráficos de produção (rendimento, tipos, cortes)

### M11.5 Analytics — Embarque

- [ ] Acesse `/analytics/shipping`
- [ ] **Esperado:** gráficos de embarque (volumes por destino, exportador,
      subtipo)

### M11.6 Analytics — Não-Conformidades

- [ ] Acesse `/analytics/non-conformities`
- [ ] **Esperado:** gráficos de NCs (status, severidade, tempo de resolução)

### M11.7 Analytics — Supervisores

- [ ] Acesse `/analytics/supervisors`
- [ ] **Esperado:** ranking/atividade dos supervisores (relatórios criados,
      taxa de aprovação, NCs geradas)

### M11.8 Exportar / imprimir gráfico

- [ ] Se houver botão de export em qualquer gráfico, teste
- [ ] **Esperado:** baixa imagem ou PDF do gráfico (se a feature existir)

---

## MÓDULO 12 — Lookup SysHalal Halal Cert

> O SIH integra com o SysHalal (sistema externo de certificação FAMBRAS) para
> consultar certificados halal e validar a procedência. Testado em vários
> formulários (Recebimento de Carne, Lotes, Embarques).

### M12.1 Lookup com certificado FAMBRAS válido

- [ ] Em qualquer form com HalalCertField (ex.: Inventário → Carne Halal →
      Novo Recebimento)
- [ ] Digite um número de certificado FAMBRAS REAL (peça ao Renato)
- [ ] Clique em "Buscar"
- [ ] **Esperado em ≤3s:**
  - Campos preenchidos automaticamente: validade, escopo, status
  - Badge verde "Certificado FAMBRAS verificado"
  - Link para PDF do certificado

### M12.2 Visualizar PDF do certificado

- [ ] Clique no link do PDF
- [ ] **Esperado:** PDF abre em nova aba ou baixa

### M12.3 Lookup com número inexistente

- [ ] Limpe e digite `EXT-FAKE-12345`
- [ ] Clique em "Buscar"
- [ ] **Esperado:**
  - Resposta "Certificado não encontrado"
  - Interface oferece fallback: habilita upload manual + campos para preencher
    validade, número, etc.

### M12.4 Preencher cert externo manual (fallback)

- [ ] No fallback, preencha:
  - Número: `EXT-FAKE-12345`
  - Validade: data futura
  - Upload de PDF (qualquer)
- [ ] Salve o relatório
- [ ] **Esperado:** salva com source = `manual`

### M12.5 Lookup em 3 forms diferentes

- [ ] Repita M12.1 em:
  - Inventário → Carne Halal → Novo Recebimento ✅ (já testado)
  - Inventário → Lotes de Produção → Novo Lote
  - Embarque tipo Transferência → seção Certificado Halal
- [ ] **Esperado:** comportamento idêntico nos 3 lugares

### M12.6 Comportamento com SysHalal indisponível

- [ ] (Opcional, se conseguir simular indisponibilidade)
- [ ] **Esperado:** UI mostra erro amigável, libera fallback manual, formulário
      não trava

---

## 13. Anexo A — Como reportar bugs (resumo)

Para cada bug encontrado, preencher uma linha em planilha (Excel ou Google
Sheets) com:

| Coluna | O que colocar |
|---|---|
| Data | data do teste |
| Módulo + cenário | ex.: M3.5 |
| Severidade | 🔴 Bloqueante / 🟠 Alta / 🟡 Média / 🟢 Baixa |
| Descrição | uma linha curta |
| Passos para reproduzir | numerados, claros |
| Resultado esperado | o que deveria ter acontecido |
| Resultado obtido | o que aconteceu |
| URL | URL completa onde quebrou |
| Status HTTP | (do DevTools Network) |
| Mensagem de erro | da UI e do console |
| Screenshot | nome do arquivo ou link |
| Email do usuário usado | qual perfil estava logado |

## 14. Anexo B — Severidades sugeridas

- 🔴 **Bloqueante:** impede uso do sistema (erro 500 ao logar, ao salvar
      relatório principal, ao acessar dashboard).
- 🟠 **Alta:** funcionalidade não funciona mas tem workaround (botão sumiu,
      lista não atualiza, validação faltando).
- 🟡 **Média:** UX ruim, dado errado mostrado, comportamento confuso.
- 🟢 **Baixa:** cosmético (cor, espaçamento, texto típico).

## 15. Anexo C — Conclusão do teste

Ao terminar, mande ao Renato:

1. Planilha com todos os bugs encontrados
2. Estatística geral: X/Y cenários ✅, X/Y ❌, X/Y ⚠️
3. Tempo total gasto no teste
4. Avaliação geral subjetiva: "Sistema usável", "Precisa muitos ajustes",
   "Funcional mas com fricções", etc.
5. Sugestões de melhoria de UX que você notou e não cabiam em "bug"
   (ex.: textos confusos, fluxos longos, etiquetas mal nomeadas)
