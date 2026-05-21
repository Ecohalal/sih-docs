# Roadmap Ecohalal — Gantt 2026

**Última atualização:** 2026-05-21
**Horizonte:** fev/2026 → mai/2027
**Go-live FAMBRAS:** agosto/2026 (Gestão de Certificações + Supervisão Industrial Halal em operação plena)

Este documento espelha em formato de Gantt o conteúdo do roadmap público
servido por `GET /public/roadmap` (`halalsphere-backend/src/roadmap/roadmap-content.ts`).
Quando o roadmap público mudar, este Gantt deve ser atualizado no mesmo ciclo.

> **Numeração:** o prefixo `#N` em cada tarefa corresponde ao número global do item
> na lista pública. O número **13 é propositalmente pulado** (decisão do cliente).
> Para imprimir em PDF sem cortes de paginação, abra `ROADMAP-GANTT-PRINT-2026-05-21.html`.

---

## Visão consolidada

```mermaid
gantt
    title Roadmap Ecohalal — fev/2026 → mai/2027
    dateFormat YYYY-MM-DD
    axisFormat %b/%y

    section Gestão de Certificações
    #1 Aggregate root + UI FAMBRAS premium       :done,  g01,  2026-02-01, 2026-02-28
    #3 Auditoria FAMBRAS (Epics A–C)             :done,  g03,  2026-03-01, 2026-03-31
    #7 Onboarding + gestão usuários do grupo     :done,  g07,  2026-03-01, 2026-03-31
    #2 Workflow completo de certificação digital :done,  g02,  2026-03-01, 2026-04-30
    #4 Modelo dual GSO/SMIIC + IA pré-auditoria  :done,  g04,  2026-03-01, 2026-04-30
    #5 Reclamações + selo + tipif. (Epics D–G)   :done,  g05,  2026-03-01, 2026-04-30
    #6 Engine de PDFs (árabe RTL + multi-país)   :done,  g06,  2026-03-01, 2026-04-30
    #11 Cadastro multi-país                      :done,  g11,  2026-05-01, 2026-05-15
    #12 Modelo de dados FAMBRAS (Onda 1+)        :done,  g12,  2026-05-01, 2026-05-15
    #14 Emissão Manual de Certificado            :done,  g14,  2026-05-08, 2026-05-21
    #15 Catálogo de 15 selos de acreditadores    :done,  g15,  2026-05-08, 2026-05-17
    #16 Verificação pública QR (página dedicada) :done,  g16,  2026-05-08, 2026-05-17
    #20 Camada de serviço Onda 1+                :active, g20, 2026-05-21, 2026-05-31
    #28 Catálogo de Laboratórios                 :       g28,  2026-06-01, 2026-06-07
    #24 Wizard de solicitação (5 passos)         :       g24,  2026-06-01, 2026-06-14
    #25 Hub de alteração de escopo               :       g25,  2026-06-08, 2026-06-21
    #26 FM 9.3 unificado mobile                  :       g26,  2026-06-15, 2026-06-30
    #27 Inbox analista + Hub docs IT 7.12        :       g27,  2026-06-22, 2026-06-30
    #33 Editor planilha MP (Airtable-like)       :       g33,  2026-07-08, 2026-07-21
    #34 Programa Certificação (3 modos)          :       g34,  2026-07-15, 2026-07-31
    #35 IA matérias-primas                       :       g35,  2026-07-22, 2026-07-31

    section Supervisão Industrial Halal
    #10 Fase A.2 (20 tipos FM) + Infra AWS       :done,  s10,  2026-03-01, 2026-03-31
    #8 Sprints 1–5 (duplo check + colaboradores) :done,  s08,  2026-04-01, 2026-04-30
    #9 Módulo Inventário (Carne + Lotes)         :done,  s09,  2026-04-01, 2026-04-30
    #17 Controladoria com duplo check            :done,  s17,  2026-05-01, 2026-05-15
    #18 Lote de hotfixes pós-teste preliminar    :done,  s18,  2026-05-15, 2026-05-21
    #21 Sprint 5 final (Desossa + cert externo)  :active, s21, 2026-05-22, 2026-05-31
    #22 Piloto controlado (até 4 empresas)       :       s22,  2026-06-01, 2026-06-30
    #40 POC IA em documentos                     :       s40,  2026-08-01, 2026-10-31

    section Sys Halal
    #19 Em produção desde ago/2025               :done,  y19,  2025-08-01, 2026-04-30
    #23 API v2 (integração externa)              :active, y23, 2026-05-22, 2026-08-31
    #38 Sys Halal alinhado com GC                :       y38,  2026-09-01, 2026-09-30
    #39 Validação Cruzada de 4 Portas            :       y39,  2026-09-01, 2026-10-31

    section Migração & Treinamento
    #37 Espelhamento FAMBRAS (FM 7.8.x)          :done,  m37,  2026-05-01, 2026-05-21
    #29 Validação visual com FAMBRAS             :done,  m29,  2026-05-15, 2026-05-17
    #30 Treinamento FAMBRAS (hands-on)           :done, milestone, m30, 2026-05-20, 0d
    #32 Migração piloto IFF (ETL)                :       m32,  2026-07-01, 2026-07-14
    #36 Estabilização + treinamento operacional  :       m36,  2026-08-01, 2026-08-14
    #31 Go-live FAMBRAS                          :crit, milestone, m31, 2026-08-15, 0d

    section Pós Go-live
    #41 Onda 3 (HAS + auditoria não-anunciada)   :       p41,  2026-11-01, 2027-01-31
    #42 Multi-tenant + API pública               :       p42,  2027-02-01, 2027-05-31
```

---

## Legenda

- `done` (preenchido): entregue em produção.
- `active` (em curso): trabalho ativo nesta semana.
- (sem marcação): próxima entrega, ainda não iniciada.
- `crit` + `milestone`: marco contratual.
- `#N`: número global do item (corresponde à lista pública). O #13 é pulado.

## Como atualizar

1. Quando uma linha do roadmap público mudar de status, atualize aqui também.
2. Quando uma entrega de uma seção for concluída, mude `:` (vazio) → `:active` → `:done`.
3. Mantenha as cores das seções alinhadas com o roadmap público (Gestão de Certificações, Supervisão Industrial Halal, Sys Halal, Migração & Treinamento, Pós Go-live).
4. O Mermaid é renderizado nativamente pelo GitHub, GitLab e VS Code (extensão Mermaid).
5. Para imprimir em PDF, use a página HTML dedicada `ROADMAP-GANTT-PRINT-2026-05-21.html`.

## Fonte de verdade

- **Conteúdo textual:** `halalsphere-backend/src/roadmap/roadmap-content.ts` (servido em `/public/roadmap`).
- **Gantt visual:** este arquivo.
- **Gantt em PDF:** `ROADMAP-GANTT-PRINT-2026-05-21.html` (Mermaid + print CSS A4 paisagem).

Para divergências entre os dois primeiros, o textual prevalece.
