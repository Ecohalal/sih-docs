# Ata — Demo SIH (divisão In Natura) — 2026-06-15

> Origem: transcrição de áudio da reunião (~16:00 → ~01:15, ≈1h).
> Apresentação do SIH ao time de In Natura da FAMBRAS, levantamento de dúvidas e
> sugestões de melhoria.

## Participantes
- **Renato** (apresentando / desenvolvimento)
- **Elaine** — líder / PO de In Natura (principais decisões)
- **André** — In Natura (libera industrializado de Avivar e BRF)
- **Vitor Augusto** — Controladoria, divisão In Natura

> Nota: a gravação continuou após o fim da reunião e capturou conversas pessoais
> não relacionadas (descartadas).

---

## 1. Cadastro de Planta

| # | Item | Decisão / Ação | Resp. |
|---|---|---|---|
| 1.1 | Tipo de planta | **Incluir `Entreposto`** (≠ armazenamento) | Dev |
| 1.2 | Espécies | **Incluir `Bubalino` (búfalo)**. Manter bovino/caprino/ovino/aves | Dev |
| 1.3 | Código sanitário | PO envia **lista de "outros" códigos** (ex.: `CIP Agro` — interno PR, entra como ração). **Não** criar campo "outros" genérico (quebra integração SysHalal) — manter enumerado e expandir sob demanda | PO + Dev |
| 1.4 | CNPJ | **Liberar campo CNPJ** na tela de planta + busca automática (Receita/cnpj.ws), reaproveitando lookup de origem/destino. É identificação; chave continua o código sanitário | Dev |
| 1.5 | Origem de certificação externa | Campo de selo/certificadora já previsto | OK |

## 2. Relatório de Abate

| # | Item | Decisão / Ação |
|---|---|---|
| 2.1 | Nome do regulador/degolador | **Remover** — não consta no relatório de abate; só o supervisor importa p/ rastreabilidade |
| 2.2 | Animais / carcaças | **Permitir casa decimal** (meia carcaça, 3/4). Manter "animais" em cima e "carcaças" embaixo; **não** mudar unidade de medida (supervisores se confundiriam) |
| 2.3 | Aprovados/rejeitados | Ter todos os campos; (desejável) rejeitado como cálculo |
| 2.4 | Insensibilização | Quando habilitada, **todos os campos obrigatórios** (pressão + conferência 1 e 2). Precisa de opção explícita **"animal vivo (sem lesão)" vs "com lesão"** para forçar preenchimento |
| 2.5 | Observação / avaliação geral | **Opcional** (se obrigar, escrevem só um ponto) |
| 2.6 | Verificações | Botão **"todos conforme"** + remover não-conformes: **aprovado** |

## 3. Desossa (Desal)

| # | Item | Decisão / Ação |
|---|---|---|
| 3.1 | Datas de lote | 1 data por relatório (relatório por dia/turno) |
| 3.2 | Certificado de outra certificadora | Quando origem da carcaça **não é FAMBRAS** → campo **obrigatório** p/ anexar certificado Halal; **IA analisa/compara**; nesse caso só **salvar rascunho, não assinar**. → PO envia **1-2 modelos de certificado** (caso típico: "JA recebe de frigorífico certificado pela Halal Approval") |

## 4. Embarque / Exportação / Transferência

| # | Item | Decisão / Ação |
|---|---|---|
| 4.1 | Nº Relatório Halal | = nº de controle do supervisor; **sequencial automático sugerido**, formato `ano + CIF + sequencial`. Em aberto: quando não há CIF ("a maioria tem") |
| 4.2 | Exportador / importador | Exportador nem sempre é a planta → **deixar aberto**. **Sem cadastro de importador** (deixar aberto) — crítica ao modelo aberto do SysHalal |
| 4.3 | Entreposto como destino | Trocado de checkbox → **opção selecionável** (melhor p/ BI). Buscar destino por CNPJ; **adicionar campo "nome" além do endereço** |
| 4.4 | Campo "certificado" em Transferência | **Remover** — transferência não gera certificado |
| 4.5 | Produto | **Adicionar CIF ao produto** (faltava) |
| 4.6 | Exceção JBS (transferência) | CSN/e-DSPOA às vezes não prontos a tempo; pedem aceitar **NF como respaldo só p/ grupo JBS**. Dev **relutante** (hardcode = dívida técnica tipo BRF/SysHalal); avaliar custo e falar com corporativo JBS antes |

## 5. Edição / Versionamento de relatório — **FASE 2**

- Caso real: **revenda muda o importador no meio do caminho**.
- Decisão: **não alterar — versionar** (nova versão/adendo registrando importador A→B),
  por causa do **blockchain futuro** (imutável).
- Fluxo: supervisor reabre → preenche o que muda → **volta para a controladoria**.

## 6. Não Conformidade × Registro Diário de Ocorrência

- **São formulários totalmente diferentes** (Elaine enfática) — não confundir.
- NC sai em **V2**.
- → PO envia **os dois modelos preenchidos** + **categorias de NC** (p/ dropdown).

## 7. Travas de documento prévio (pendente)

- Relatórios (couro/raspa, transferência) exigem **documento anterior obrigatório
  antes de assinar** (ex.: CSN do SIPOA/e-DSPOA, GTA).
- Estratégia: **gerar relatórios primeiro, colocar travas depois**.
- Couro/raspa: alinhar com a **Alina**.

## 8. Controladoria / fluxo de aprovação

- Validado sem objeções: fila pendente → "assumir para análise" →
  **aprovar / rejeitar (texto obrigatório + notificação ao supervisor) / devolver à fila**;
  tela read-only; hash de integridade.
- **Adicionar nº de container ao lado do serial** (não dentro — abate não tem container).
  Serial = `EM + CIF + ano + sequencial`.
- Controlador **não** vê cadastros (gestão) — permissões a refinar depois.

---

## Pendências do PO (FAMBRAS)

1. Lista dos **"outros" códigos sanitários** (CIP Agro etc.)
2. **1-2 modelos de certificado** de outras certificadoras (IA da desossa)
3. **Categorias de não conformidade** — ⏳ parcial: candidatas extraídas dos modelos, falta lista oficial
4. ✅ **Modelos preenchidos de NC e de Registro Diário de Ocorrência** — entregues 16/jun (Elaine, `C:\SIH\Qualidade`): FM 7.1.6.1 (ocorrências externas/couro) + FM 20.1 (ocorrência aves). Spec em [SPEC-OCORRENCIAS-NC-FM716-FM201-2026-06-16](SPEC-OCORRENCIAS-NC-FM716-FM201-2026-06-16.md). **Gap:** confirmar se há form de NC distinto do FM 7.1.6.1
5. **Lista de empresas/plantas com CNPJ** (André) — comparar com SysHalal e popular plantas
6. Documentos prévios obrigatórios de **couro/raspa** (com Alina)
7. Definir **quem controla escalas e criação de usuários** (muda muito no frigorífico)

## Combinados / próximos passos

- **Industrializado**: reunião com a **Lina** (dia seguinte) — **incluir o André**.
- **Cadastro de produto** entra na pauta com a Lina (in natura mais aberto que industrializado).
- Liberar acessos (usuário/senha) no grupo de WhatsApp p/ time testar.
- Reset agressivo da base + cadastrar plantas do SysHalal.

---

## Backlog derivado (itens novos vs. já mapeados)

**Novos / a transformar em follow-up rastreável:**
- [ ] `Bubalino` nas espécies (1.2)
- [ ] Remover "nome do regulador" no abate (2.1)
- [ ] Casa decimal em animais/carcaças no abate (2.2)
- [ ] Opção "animal vivo com/sem lesão" na insensibilização (2.4)
- [ ] Remover campo certificado em Transferência (4.4)
- [ ] Adicionar CIF ao produto de embarque (4.5)
- [ ] Campo "nome" no destino por CNPJ (4.3)
- [ ] Nº container ao lado do serial na controladoria (8)
- [ ] Exceção JBS por NF — avaliar custo/decisão (4.6)
- [ ] Versionamento de embarque (revenda/importador) — **Fase 2** (5)
- [ ] NC vs Registro Diário de Ocorrência como formulários distintos — **V2** (6)
- [ ] Travas de documento prévio (couro/transferência) (7)

**Já cobertos por trabalho existente (confirmados na demo):**
- Entreposto/destino, CNPJ na planta, vínculo embarque⇄produção, FAM-0017 / cadastro de produto.
