# E-mail Lina — perguntas residuais pós-análise documental

**Data preparação:** 2026-05-07
**Destinatário:** Lina Ramadan (FAMBRAS Halal)
**Assunto sugerido:** Gestão de Certificações EcoHalal — confirmações e perguntas para fechar a próxima fase do projeto

> Este documento é o rascunho do e-mail. Revise e edite antes de enviar.
> O material citado (FM 7.2.1.1, PR 7.1, IT 7.12, DT 7.3, FM 7.4.2.1, FM 7.2.3, FM 4.1.1.1, FM 4.1.1, formulários FM 7.2.1.x, FM 7.4.2.7) é exatamente o que ela nos enviou nas três pastas (visita 15/04, regras de alteração de escopo, escopos e solicitação documental, e o exemplo da ATA Tensoativos da Ayat).

---

## Corpo do e-mail

Bom dia, Lina.

Espero que esteja bem.

Conforme conversamos na visita técnica do dia 15/04, nossa equipe se debruçou sobre todo o material que você compartilhou — corpo dos e-mails, formulários (FM 7.2.1.x, FM 7.4.2.x, FM 7.1.9), procedimentos (PR 7.1) e instruções de trabalho (IT 7.12), além dos exemplos reais (proposta, contrato e diretrizes da ATA Tensoativos enviados pela Ayat). O conteúdo é riquíssimo e nos deu base para fechar a maior parte das decisões de modelagem do sistema.

Para concluir o desenho da próxima fase, gostaríamos de **confirmar três pontos** e **esclarecer cinco questões operacionais** com você. Tudo o que estiver abaixo já tem uma leitura nossa — só queremos validar antes de avançarmos com a implementação.

---

### A. Confirmações rápidas (resposta esperada: "correto" ou "ajustar")

**A.1. Sistema de Garantia Halal (HAS).** Pelo PR 7.1 (item 6) e pelo FM 7.4.2.1 ("enviar o programa do HAS elaborado pela empresa a ser certificada"), entendemos que o **HAS é elaborado pelo cliente certificando**, conforme a DT 7.3, e a FAMBRAS atua como **revisora** do documento durante a auditoria. Está correto?

**A.2. Mercados pretendidos.** Pelo FM 7.2.1.1 (seção "Abrangência de Reconhecimento e Padrão Normativo"), entendemos que o cliente seleciona **um ou mais** mercados destinatários da lista (Arábia Saudita, Emirados Árabes, Indonésia, Malásia, Mercado Interno, Singapura, África do Sul, Demais países do Golfo, Turquia, Outros), e cada mercado mapeia para acreditadores e padrões específicos (GAC/GSO, HAK/SMIIC, BPJPH, MUIS, JAKIM, MOIAT, SFDA). É essa a lógica? A divisão "Golfo / sem Golfo" que mencionamos na visita era uma simplificação, certo?

**A.3. Lista de laboratórios aprovados.** Os 7 laboratórios listados no FM 7.4.2.1 (EUROFINS, FOODCHAIN, CQA, INTECSO, SENAI, UNIANÁLISES, FREITAG), com restrições por tipo de análise (PCR animal, etanol residual), são uma **lista fechada**. Está correto que essa lista é mantida pela FAMBRAS e pode ser atualizada com o tempo? Quem aprova inclusões — qualidade, comitê?

---

### B. Perguntas que destravam o desenho

**B.1. Implantação dos dados existentes.** O PR 7.1 deixa claro que o ciclo é de 3 anos (inicial + manutenção 1 + manutenção 2 + recertificação) e que cada empresa carrega histórico de auditorias, NCs, certificados e aditivos. Para dimensionarmos o esforço de migração com precisão, **podem nos disponibilizar um caso de amostra** com:
- 1 cliente em ciclo completo (idealmente em renovação);
- Todos os anexos do processo (solicitação, escopo, proposta, contrato, plano e relatório de auditoria estágios 1 e 2, FM 9.3, NCs e evidências, FM 7.4.2.7 preenchida, certificado emitido);
- Pelo menos uma alteração de escopo já vivida (inclusão/exclusão de produto, marca de cliente, etc.).

Isso nos permite calibrar com precisão o ETL e o esquema final.

**B.2. Base de matérias-primas com IA.** Vocês mencionaram na visita que o time de analistas usa "pesquisa de IA" e compila planilhas de MP de todos os clientes. Para dimensionarmos a feature corretamente:
- A IA hoje faz **o quê** exatamente? Lookup em positive lists dos acreditadores? Classificação de risco haram? Geração de questionário Halal?
- Quais **fontes** ela consulta? Sites dos acreditadores (GAC, JAKIM, BPJPH, MUIS), bases internas, documentos do cliente?
- Vocês conseguiriam compartilhar **2 ou 3 prompts/casos reais** que a analista usou recentemente? Mesmo que sejam exemplos anônimos.

**B.3. Item crítico por categoria × por país.** No FM 7.4.2.1 e nos seus e-mails de regras de alteração de escopo, vimos que cada categoria tem itens críticos próprios (laticínio: coalho, fermento, enzima, cloreto de cálcio, ácido lático, vitaminas, corante, detergente enzimático). Esses itens são **fixos por categoria de fabricante** ou **variam também por país de destino** (ex: o que é crítico para Arábia Saudita pode não ser para Indonésia)? E há outras categorias com lista própria além de laticínio (carnes processadas, cosméticos, fármacos, embalagens, ração)?

---

### C. Próximos passos

Com as respostas acima, conseguimos fechar:
- O modelo de dados final (especialmente da entidade de Mercado);
- O escopo da migração de dados;
- A primeira onda de implementação (que já mapeamos em 25+ entregáveis).

Se preferir, podemos agendar uma call rápida (30-45 min) para conversar sobre os pontos B.1 e B.2, que são os de maior impacto no cronograma. O ponto B.3 podemos resolver por e-mail mesmo.

Fico no aguardo. Qualquer coisa, estamos à disposição.

Abraços,
Renato Ribeiro
EcoHalal

---

## Notas internas (não enviar)

### Por que cada pergunta importa

| # | Destrava |
|---|---|
| A.1 | Onda 3 — "HAS guiado" vira "Revisor de HAS" (escopo bem menor). |
| A.2 | Modelagem `MarketScope` 1:N + `EligibleStandard` (deixa de ser enum único). |
| A.3 | `Laboratory` com flag `isFambrasApproved` + governance (quem mantém). |
| B.1 | Calibragem do ETL de migração; sem amostra real, prazo é especulação. |
| B.2 | Modelo da `RawMaterialMaster` + `RawMaterialCertVerification`; sem fontes definidas, agente de IA fica genérico. |
| B.3 | `CriticalRawMaterial { categoryCode, countryCode? }` — define se a chave é só categoria ou (categoria × país). |

### Decisões já tomadas (não perguntar à Lina)

- **SysHalal × HalalSphere coexistem em paralelo, integrados.** Propósitos diferentes: SysHalal serve embarques/despachantes; HalalSphere é Gestão de Certificações da EcoHalal (acesso fechado, não há intenção de abrir GC para despachantes). Modelagem: HalalSphere é sistema autônomo, integra com SysHalal via API onde fizer sentido (ex: dados que viram certificado SFDA), sem migrar funcionalidades de embarque.
- **Política de preços fica fora do sistema (não inferir fórmulas).** A FAMBRAS tem múltiplos acordos comerciais e flexibilidade é mandatória. `PricingTable` deve ser parametrizável **por contrato** com valores manuais. Sem cálculo automático de aditivo contratual, sem fórmula de proposta. Comercial cota → registra valor → sistema persiste. Modelo: `Proposal.feeOverride` aceito sem justificativa de fórmula.

### O que **não** estamos perguntando (já temos resposta)

- Tipos de alteração de escopo (6 fluxos) — claro pelas regras enviadas
- SLAs (30d docs, 7d resposta, 90d manutenção, 6m solicitação renovação) — claros no PR 7.1
- Quem aprova aditivo (jurídico → presidente → comitê) — claro no contrato
- Reajuste anual fixo + IPCA na renovação — claro na proposta
- Selo obrigatório/facultativo por mercado — claro na cláusula 4.5 do contrato
- Auditoria não anunciada (regras, prazo de notificação) — claro no PR 7.1 item 10.7.1
- Endereços de e-mail por área (cobranca/qualidade/jurídico/etc.) — claro no contrato
- Categorias UAE.S GSO (A-K) e SMIIC (A-L) — claras nos anexos do PR 7.1

### Tom

Lina escreveu emails relativamente curtos e diretos ("Pessoal, caso tenha esquecido de algo nesses e-mails, podem complementar, por gentileza"). Mantenha o tom cordial mas executivo. Evite jargão técnico de TI; use os códigos dos formulários (FM/PR/DT) que ela domina.
