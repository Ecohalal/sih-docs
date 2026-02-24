# 2. Objetivos e Metricas de Sucesso

---

## 2.1 Objetivo Principal

**Digitalizar 100% dos formularios FM da FAMBRAS Halal utilizados em campo**, eliminando o preenchimento em papel e permitindo rastreabilidade em tempo real das atividades de supervisao industrial.

---

## 2.2 Objetivos Especificos

### O1: Eficiencia Operacional
Reduzir o tempo de preenchimento e consolidacao dos relatorios de supervisao.

| Metrica | Atual | Meta | Reducao |
|---------|-------|------|---------|
| Tempo de preenchimento por relatorio | 15-25 min | 5-10 min | 60% |
| Tempo de consolidacao (campo → escritorio) | 2-5 dias | Tempo real | 100% |
| Tempo de busca de relatorio especifico | 10-30 min | < 10 seg | 99% |

### O2: Qualidade dos Dados
Eliminar erros de preenchimento e garantir consistencia dos registros.

| Metrica | Atual | Meta |
|---------|-------|------|
| Taxa de erros de preenchimento | ~15% | < 2% |
| Campos obrigatorios em branco | ~10% | 0% |
| Seriais duplicados | Ocorrem | 0 |
| Dados estruturados e pesquisaveis | 0% | 100% |

### O3: Rastreabilidade e Conformidade
Garantir rastreabilidade completa da cadeia de supervisao conforme PR 7.1 Rev 22.

| Metrica | Atual | Meta |
|---------|-------|------|
| Relatorios rastreavels por planta/data | Parcial (papel) | 100% digital |
| NCs com prazo monitorado (7 dias) | Nao monitorado | 100% com alertas |
| Vinculo relatorio ↔ supervisor ↔ planta | Manual | Automatico |
| Historico de alteracoes | Inexistente | Audit trail completo |

### O4: Visibilidade para Gestao
Fornecer dashboards e indicadores em tempo real para tomada de decisao.

| Metrica | Atual | Meta |
|---------|-------|------|
| Visibilidade de relatorios pendentes | Nenhuma | Tempo real |
| Indicadores de NCs ativas por planta | Inexistente | Dashboard |
| Produtividade por supervisor | Nao medida | Metricas automaticas |
| Status de relatorios (rascunho/enviado/aprovado) | Nao existe | Workflow completo |

---

## 2.3 KPIs do Sistema

### KPIs Operacionais

| KPI | Descricao | Meta |
|-----|-----------|------|
| **Relatorios/dia** | Media de relatorios preenchidos por dia no sistema | Baseline + monitoramento |
| **Tempo medio de preenchimento** | Tempo entre abertura e envio do relatorio | < 10 min |
| **Taxa de aprovacao** | % de relatorios aprovados sem rejeicao | > 90% |
| **NCs resolvidas no prazo** | % de NCs resolvidas dentro dos 7 dias | > 85% |
| **Cobertura digital** | % de relatorios feitos no SIH vs. papel | 100% em 3 meses |

### KPIs Tecnicos

| KPI | Descricao | Meta |
|-----|-----------|------|
| **Uptime** | Disponibilidade do sistema | > 99.5% |
| **Tempo de resposta** | P95 de latencia das APIs | < 500ms |
| **Tempo de carregamento (mobile)** | First Contentful Paint em 3G | < 3s |
| **Erros de sistema** | Taxa de erros 5xx | < 0.1% |

---

## 2.4 Criterios de Sucesso do Projeto

### Curto Prazo (Lancamento)
- [ ] Todos os 8 tipos de formulario FM digitalizados e funcionais
- [ ] Login via Gestao de Certificacoes funcionando
- [ ] Pelo menos 1 planta piloto usando o sistema
- [ ] Zero erros criticos em producao

### Medio Prazo (3 meses apos lancamento)
- [ ] 100% das plantas migraram do papel para o SIH
- [ ] Dashboard operacional sendo usado pela gestao
- [ ] Reducao mensuravel no tempo de consolidacao
- [ ] NCs com tracking automatico de prazos

### Longo Prazo (6-12 meses)
- [ ] Modulo de inventario implementado (FM 7.1.5.x)
- [ ] Modo offline funcional para uso em campo sem internet
- [ ] Integracao completa com Gestao de Certificacoes (dados compartilhados)
- [ ] Relatorios e analytics avancados
