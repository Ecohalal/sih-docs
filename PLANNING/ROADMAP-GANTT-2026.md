# Roadmap Ecohalal — Gantt 2026

**Última atualização:** 2026-05-21
**Horizonte:** fev/2026 → mai/2027
**Go-live FAMBRAS:** agosto/2026 (Gestão de Certificações + Supervisão Industrial Halal em operação plena)

Este documento espelha em formato de Gantt o conteúdo do roadmap público
servido por `GET /public/roadmap` (`halalsphere-backend/src/roadmap/roadmap-content.ts`).
Quando o roadmap público mudar, este Gantt deve ser atualizado no mesmo ciclo.

---

## Visão consolidada

```mermaid
gantt
    title Roadmap Ecohalal — fev/2026 → mai/2027
    dateFormat YYYY-MM-DD
    axisFormat %b/%y

    section Gestão de Certificações
    Aggregate root + UI FAMBRAS premium       :done,  gc01,  2026-02-01, 2026-02-28
    Workflow completo de certificação digital :done,  gc02,  2026-03-01, 2026-04-30
    Auditoria FAMBRAS (Epics A–C)             :done,  gc03,  2026-03-01, 2026-03-31
    Modelo dual GSO/SMIIC + IA pré-auditoria  :done,  gc04,  2026-03-01, 2026-04-30
    Reclamações + selo + tipif. (Epics D–G)   :done,  gc05,  2026-03-01, 2026-04-30
    Engine de PDFs (árabe RTL + multi-país)   :done,  gc06,  2026-03-01, 2026-04-30
    Onboarding + gestão usuários do grupo     :done,  gc07,  2026-03-01, 2026-03-31
    Cadastro multi-país + Onda 1+ schema      :done,  gc08,  2026-05-01, 2026-05-15
    Emissão Manual + Catálogo de 15 selos     :done,  gc09,  2026-05-08, 2026-05-17
    Verificação pública QR (página dedicada)  :done,  gc10,  2026-05-08, 2026-05-17
    Service layer Onda 1+ (hooks)             :active, gc11, 2026-05-21, 2026-05-31
    Wizard solicitação 5 passos               :       gc12,  2026-06-01, 2026-06-14
    Hub de alteração de escopo                :       gc13,  2026-06-08, 2026-06-21
    FM 9.3 unificado mobile                   :       gc14,  2026-06-15, 2026-06-30
    Inbox analista + Hub docs IT 7.12         :       gc15,  2026-06-22, 2026-06-30
    Catálogo de Laboratórios                  :       gc16,  2026-06-01, 2026-06-07
    Editor planilha MP (Airtable-like)        :       gc17,  2026-07-08, 2026-07-21
    Programa Certificação (3 modos)           :       gc18,  2026-07-15, 2026-07-31
    IA matérias-primas                        :       gc19,  2026-07-22, 2026-07-31

    section Supervisão Industrial Halal
    Sprints 1–5 (duplo check + colaboradores) :done,  sih01, 2026-04-01, 2026-04-30
    Módulo Inventário (Carne + Lotes)         :done,  sih02, 2026-04-01, 2026-04-30
    Fase A.2 (20 tipos FM) + Infra AWS        :done,  sih03, 2026-03-01, 2026-03-31
    Lote de hotfixes pós-teste preliminar     :done,  sih04, 2026-05-15, 2026-05-21
    Sprint 5 final (Desossa + TASK-11 cert)   :active, sih05, 2026-05-22, 2026-05-31
    Piloto controlado (até 4 empresas)        :       sih_p, 2026-06-01, 2026-06-30
    Auto-popular endereços + UX               :       sih06, 2026-06-01, 2026-06-07
    Route guards + queryClient clear          :       sih07, 2026-06-01, 2026-06-07
    POC IA documentos (Claude)                :       sih08, 2026-08-01, 2026-10-31

    section Sys Halal
    Em produção desde ago/2025                :done,  sh01,  2025-08-01, 2026-04-30
    API v2 (kickoff + design)                 :active, sh02, 2026-05-22, 2026-08-31
    TASK-S0 (consumir GC)                     :       sh03,  2026-09-01, 2026-09-30
    Validação Cruzada de 4 Portas (ativação)  :       sh04,  2026-09-01, 2026-10-31

    section Migração & Treinamento
    Validação visual com FAMBRAS              :done,  m01,   2026-05-15, 2026-05-17
    Treinamento FAMBRAS (emissão manual)      :done, milestone, m02, 2026-05-20, 0d
    Migração piloto IFF (ETL)                 :       m03,   2026-07-01, 2026-07-14
    Seed HomologationProfile FAMBRAS          :       m04,   2026-07-01, 2026-07-07
    Estabilização + treinamento operacional   :       m05,   2026-08-01, 2026-08-14
    Go-live FAMBRAS                           :crit, milestone, m06, 2026-08-15, 0d

    section Pós Go-live
    Onda 3 (HAS + auditoria não-anunciada)    :       pg01,  2026-11-01, 2027-01-31
    Multi-tenant + API pública                :       pg02,  2027-02-01, 2027-05-31
```

---

## Recortes por sistema

### Apenas Gestão de Certificações (HalalSphere)

```mermaid
gantt
    title Gestão de Certificações — fev/2026 → ago/2026
    dateFormat YYYY-MM-DD
    axisFormat %b/%y

    section Base operacional
    Aggregate root + UI FAMBRAS     :done, b1, 2026-02-01, 2026-02-28
    Onboarding + grupo + login      :done, b2, 2026-03-01, 2026-03-31

    section Workflow certificação
    Workflow digital completo       :done, w1, 2026-03-01, 2026-04-30
    Cadastro multi-país             :done, w2, 2026-05-01, 2026-05-10
    Onda 1+ schema FAMBRAS          :done, w3, 2026-05-01, 2026-05-15
    Service layer Onda 1+           :active, w4, 2026-05-21, 2026-05-31
    Wizard 5 passos ramificado      :       w5, 2026-06-01, 2026-06-14
    Hub alteração de escopo         :       w6, 2026-06-08, 2026-06-21

    section Auditoria & qualidade
    Epics A–C (checklists+PCCH+lab) :done, a1, 2026-03-01, 2026-03-31
    Modelo dual GSO/SMIIC + IA pré  :done, a2, 2026-03-01, 2026-04-30
    Epics D–G (reclama+selo+contr)  :done, a3, 2026-03-01, 2026-04-30
    FM 9.3 unificado mobile         :       a4, 2026-06-15, 2026-06-30
    Inbox analista + IT 7.12        :       a5, 2026-06-22, 2026-06-30
    Catálogo Laboratórios           :       a6, 2026-06-01, 2026-06-07

    section Emissão & verificação
    Engine PDF árabe + multi-país   :done, e1, 2026-03-01, 2026-04-30
    Emissão Manual + 15 selos       :done, e2, 2026-05-08, 2026-05-17
    Verificação pública QR          :done, e3, 2026-05-08, 2026-05-17

    section Pré go-live
    ETL piloto IFF                  :       p1, 2026-07-01, 2026-07-14
    Editor planilha MP              :       p2, 2026-07-08, 2026-07-21
    Programa Cert (3 modos)         :       p3, 2026-07-15, 2026-07-31
    IA matérias-primas              :       p4, 2026-07-22, 2026-07-31
    Treinamento FAMBRAS             :done, milestone, p5, 2026-05-20, 0d
    Go-live                         :crit, milestone, p6, 2026-08-15, 0d
```

### Apenas Supervisão Industrial Halal

```mermaid
gantt
    title Supervisão Industrial Halal — mar/2026 → ago/2026
    dateFormat YYYY-MM-DD
    axisFormat %b/%y

    section Base
    Fase A.2 (20 tipos FM)          :done, sb1, 2026-03-01, 2026-03-20
    Infra AWS 3 ambientes           :done, sb2, 2026-03-15, 2026-03-31

    section Sprints 1–5
    Sprint 1 (Controladoria + IN/IND) :done, ss1, 2026-04-01, 2026-04-07
    Sprint 2 (Duplo check + dash)     :done, ss2, 2026-04-08, 2026-04-15
    Sprint 3 (Transferências)         :done, ss3, 2026-04-15, 2026-04-22
    Sprint 4 (Notificações + anexos)  :done, ss4, 2026-04-22, 2026-04-29
    Sprint 5 (Cert Sys Halal)         :done, ss5, 2026-04-29, 2026-05-05
    Sprint 5 final (Desossa)        :active, ss6, 2026-05-22, 2026-05-31
    Piloto controlado (ate 4 emp)   :       ssp, 2026-06-01, 2026-06-30

    section Inventário (Epic 07)
    Fatias 1+2 (Carne + Lotes)      :done, sin1, 2026-04-01, 2026-04-30
    Fatia 3 (Rotulagem)             :       sin2, 2026-06-15, 2026-06-30
    Fatia 4 (Dashboard inventário)  :       sin3, 2026-07-01, 2026-07-14
    Fatia 5 (Import Excel)          :       sin4, 2026-07-15, 2026-07-31

    section Estabilização
    Hotfixes pós-teste preliminar   :done, st1, 2026-05-15, 2026-05-21
    Bugs SES + sessão + cache PWA   :       st2, 2026-05-26, 2026-05-31
    UX final + treinamento ops      :       st3, 2026-08-01, 2026-08-14
    Go-live FAMBRAS                 :crit, milestone, st4, 2026-08-15, 0d

    section Pós go-live
    POC IA em documentos (Claude)   :       sp1, 2026-08-01, 2026-10-31
```

---

## Legenda

- `done` (preenchido): entregue em produção.
- `active` (em curso): trabalho ativo nesta semana.
- (sem marcação): próxima entrega, ainda não iniciada.
- `crit` + `milestone`: marco contratual.
- Datas usam **mês/ano** como granularidade primária; **N ª semana/mês** quando o intervalo é menor que 4 semanas.

## Como atualizar

1. Quando uma linha do roadmap público mudar de status, atualize aqui também.
2. Quando uma entrega de uma seção for concluída, mude `:` (vazio) → `:active` → `:done`.
3. Mantenha as cores das seções alinhadas com o roadmap público (Gestão de Certificações, Supervisão Industrial Halal, Sys Halal, Migração & Treinamento, Pós Go-live).
4. O Mermaid é renderizado nativamente pelo GitHub, GitLab e VS Code (extensão Mermaid).

## Fonte de verdade

- **Conteúdo textual:** `halalsphere-backend/src/roadmap/roadmap-content.ts` (servido em `/public/roadmap`).
- **Gantt visual:** este arquivo.

Para divergências entre os dois, o textual prevalece.
