# 1. Visao Geral do Produto

**SIH - Supervisao Industrial Halal v1.0**

---

## 1.1 Problema que Resolvemos

A FAMBRAS Halal utiliza um conjunto de **formularios padronizados (FM)** para registrar as atividades de supervisao industrial em plantas de abate, producao e embarque. Esses formularios sao a base documental que comprova a conformidade Halal dos produtos.

### Situacao Atual

- **Formularios em papel/PDF**: Supervisores preenchem manualmente em campo, gerando problemas de legibilidade, extravio e demora na consolidacao
- **Sem rastreabilidade em tempo real**: Gestores so tem visibilidade dos dados quando os formularios fisicos chegam ao escritorio
- **Dados nao estruturados**: Informacoes ficam presas em PDFs, impossibilitando analises, dashboards e cruzamento de dados
- **Risco de inconsistencia**: Sem validacao automatica, erros de preenchimento passam despercebidos
- **Dificuldade de auditoria**: Localizar um formulario especifico entre centenas de papeis e lento e impreciso
- **Nao-conformidades sem prazo**: Sem tracking sistematico, prazos de 7 dias corridos (PR 7.1) podem ser perdidos

### Impacto

| Metrica | Atual (Papel) | Esperado (SIH) |
|---------|---------------|-----------------|
| Tempo de preenchimento | 15-25 min | 5-10 min |
| Tempo de consolidacao | 2-5 dias | Tempo real |
| Erros de preenchimento | ~15% | <2% |
| Rastreabilidade | Manual/parcial | 100% digital |
| Tracking de NCs | Planilha/email | Automatico com alertas |

---

## 1.2 Solucao Proposta

O **SIH (Supervisao Industrial Halal)** e um sistema web responsivo (PWA) que digitaliza todos os formularios FM da FAMBRAS Halal, otimizado para uso em **tablets em campo**.

### Diferenciais

- **Formularios digitais fieis ao original**: Cada tipo de formulario mantem seus campos e itens de verificacao C/NC especificos, garantindo conformidade com o PR 7.1
- **Validacao em tempo real**: Campos obrigatorios, formatos e regras de negocio validados no momento do preenchimento
- **Numero serial automatico**: Formato `SIF/ANO/SEQUENCIAL` gerado automaticamente sem risco de duplicidade
- **Rastreabilidade completa**: Cada relatorio vinculado a planta, supervisor, data e turno
- **Workflow de nao-conformidades**: Registro, acompanhamento e verificacao com prazos automaticos de 7 dias
- **Dashboard em tempo real**: Visao consolidada para gestores e coordenadores
- **Autenticacao compartilhada**: Mesmo login do Gestao de Certificacoes (JWT RS256)
- **PWA preparado para offline**: Estrutura pronta para funcionar sem internet no futuro

---

## 1.3 Catalogo de Formularios FM FAMBRAS

O SIH digitaliza os seguintes formularios da FAMBRAS Halal, baseados no **PR 7.1 Rev 22**:

### Formularios v1.0 (Implementados)

| Familia | FM | Nome Oficial | Modulo no SIH | Tipo |
|---------|-----|-------------|----------------|------|
| Abate | FM 7.1.4.1 | Rel. Abate Halal - Aves | SlaughterReport | species=ave |
| Abate | FM 7.1.4.2 | Rel. Abate e Controle de Carcaca - Bovino | SlaughterReport | species=bovino |
| Producao | FM 7.1.3.1 | Rel. Acomp. Fabricacao Prod. Industrializados (Carne) | ProductionReport | regular |
| Producao | FM 7.1.8.x | Rel. Producao Especial | ProductionReport | specialProduction=true |
| Embarque | FM 7.1.7.1 | Rel. Acomp. Embarque - Exportacao | ShippingReport | type=exportacao |
| Venda | FM 7.1.7.4 | Rel. Venda Mercado Interno | ShippingReport | type=venda_interna |
| Transferencia | DCPOA | Documento de Transferencia | ShippingReport | type=transferencia |
| NC | FM 7.1.6.1 | Checklist de Nao-Conformidade | NonConformity | - |

### Formularios Futuros (Modelo de dados documentado)

| Familia | FM | Nome Oficial | Modulo no SIH | Observacao |
|---------|-----|-------------|----------------|------------|
| Inventario | FM 7.1.5.1 | Inventario Carne Halal (Conta Corrente) | MeatInventory | Recebido vs. utilizado |
| Inventario | FM 7.1.5.6 | Inventario Lotes de Producao (Batch) | BatchInventory | Gerado vs. transferido |
| Rotulagem | FM 7.1.3.6 | Inventario Acomp. Rotulagem | LabelingInventory | Sem rotulo → rotulado → embarcado |

---

## 1.4 Estrutura Padrao dos Formularios FM

Todos os formularios FAMBRAS compartilham uma estrutura padrao:

### Cabecalho

1. **Identificacao do formulario**: Numero FM, revisao, data de emissao
2. **Logo FAMBRAS Halal**: Identidade visual institucional
3. **Numero serial**: Formato `SIF/ANO/SEQUENCIAL` (ex: `451/2026/000001`)

### Identificacao

4. **Planta industrial**: Nome, endereco, numero SIF/SIE/SIM
5. **Supervisor**: Nome completo, registro/documento

### Corpo (especifico por tipo FM)

6. **Dados operacionais**: Campos especificos de cada tipo de formulario
7. **Itens de verificacao C/NC**: Checklist de conformidade/nao-conformidade
   - **NAO sao genericos** - cada tipo FM tem seus proprios itens fixos
   - Abate bovino: 14 itens (bem-estar animal, degola, sangria, insensibilizacao, etc.)
   - Producao industrial: 5 itens (limpeza, materias-primas, documentacao, armazenamento, rotulagem)
   - Embarque exportacao: 2 itens (exclusividade Halal no container, selo de garantia)

### Encerramento

8. **Observacoes**: Campo texto livre
9. **Declaracao do supervisor**: Texto padrao bilingue (PT/EN)
10. **Assinatura**: Supervisor muculmano + data

### Cancelamento

- Relatorio cancelado recebe selo "CANCELADO" e motivo
- Novo relatorio e emitido com sufixo "A" no serial (ex: `451/2026/000001A`)

---

## 1.5 Descobertas-Chave da Analise de Dominio

A analise detalhada dos formularios FM preenchidos e das planilhas de inventario revelou:

### Sobre os Relatorios

1. **Checklists NAO sao genericos**: Cada tipo de relatorio tem seus proprios itens C/NC fixos, definidos pelo PR 7.1. Nao ha templates configuraveis - os itens sao constantes do sistema.

2. **Secao de insensibilizacao (stunning)** e exclusiva do abate bovino (FM 7.1.4.2):
   - Avaliacao da pressao/parametros do equipamento
   - 2 conferencias por turno: animal vivo no momento do abate + sem lesoes craniais

3. **Tabela de produtos** e padrao em embarque/venda/producao:
   - Produto, codigo, lote, datas (abate/producao/validade), embalagem, pesos, temperatura

4. **Materias-primas carneas** (exclusivo producao industrial):
   - Rastreabilidade completa: frigorifico de origem, SIF, data abate, CSN, certificado Halal

5. **Ingredientes aprovados** (exclusivo producao industrial):
   - Lista de insumos nao-carneos verificados: fornecedor, lote, validade

### Sobre o Inventario (Futuro)

6. **Conta corrente** e o conceito central do inventario:
   - Saldo = Entrada - Saida (recebido - usado / gerado - transferido / sem rotulo - rotulado)
   - Aplica-se aos 3 tipos de inventario (carne, lotes, rotulagem)

7. **Alto volume de dados**: Planilhas reais mostram 1.000+ linhas/mes em inventario de lotes, 8.000+ linhas por produto em rotulagem

8. **Referencias cruzadas**: O inventario conecta toda a cadeia - do abate ao embarque - via certificados Halal, CSN, codigos de produto e numeros de lote

---

## 1.6 Integracao com Gestao de Certificacoes

O SIH e um sistema **independente** que se integra ao Gestao de Certificacoes (HalalSphere) em dois pontos:

### Autenticacao Compartilhada
- Usuarios fazem login via API do Gestao de Certificacoes
- SIH valida JWT localmente (RS256 public key - sem chamada remota)
- JWT com validade estendida (7 dias) para uso em campo
- Ao primeiro acesso, cria perfil local (`SupervisorProfile`) automaticamente

### Dados Compartilhados (Futuro)
- Plantas industriais: `Plant.externalCompanyId` → Company do Gestao
- Certificados Halal: referencia nos relatorios de producao e inventario
- Usuarios: `SupervisorProfile.externalUserId` → User do Gestao

### Independencia
- Banco de dados proprio (PostgreSQL separado, porta 5433)
- Backend proprio (NestJS, porta 3334)
- Frontend proprio (React, porta 5174)
- Deploy independente (AWS separado)
