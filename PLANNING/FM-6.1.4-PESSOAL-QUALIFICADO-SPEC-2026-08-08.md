# FM 6.1.4 — Pessoal Qualificado no GC (spec)

> **Criada em 08/ago/2026** a partir da avaliação de
> `C:\HalalSphere\Documentos Certificação\Outros\FM 6.1.4_LISTA DO PESSOAL QUALIFICADO (REV 4) 03.12.2025.xlsx`.
> Dono do controle: **equipe de QUALIDADE** (Elaine). Nunca abordado no GC até hoje.
> Base normativa: ISO 17065 §6.1 (competência de pessoal da certificadora) — parente do
> FM 6.1.1 (Matriz de Competência, mesmo diretório).

## 1. O que a planilha contém (medido)

| Aba | Conteúdo | Volume |
|---|---|---|
| **FM 6.1.4** | Pessoal ATIVO qualificado | **307 pessoas** (442 linhas — apontamentos SGQ extras em linhas sem número) |
| **DESLIGADOS** | Histórico de quem saiu (mesmas colunas + observações) | ~215 linhas |
| **DADOS AUDITORES** | Auditores: e-mail + termo de nomeação assinado | 34 |
| **auditores e sheikhs** | Lista p/ convocação de treinamentos | ~44 |
| **Categoria vs Formação** | Matriz de elegibilidade: categoria GSO 2055-2 × SMIIC 2 × formação exigida (Agronomia, Alimentos, Veterinária…) | ~23 linhas |

Colunas da aba principal: nº · nome · posição · **apontamento(s) do SGQ** (N por pessoa —
ex.: Elaine = Representante da Qualidade + Especialista Técnico + Comitê de Reclamação e
Apelo) · classificação (categorias elegíveis) · normas elegíveis p/ auditoria · país ·
**suplente** · Novo Acordo de Confidencialidade · Antigo Confidencialidade · Código de
Ética (valores SIM/NÃO/OK/"Does not need one") · **avaliação periódica: data da última +
data-limite da próxima** (serial Excel) · EAD · SIF · REVISADO · observações.

## 2. Modelo proposto (módulo novo `qualified-personnel`, GC)

- **`QualifiedPerson`** — name, position, country, status (`ativo`/`desligado`),
  deputyId (auto-ref, suplente), sif?, email?, observations, userId? (vínculo OPCIONAL
  com `User` — 307 pessoas × 26 usuários do sistema; a maioria nunca terá login).
- **`PersonSgqAppointment`** (1:N) — appointment (texto do apontamento SGQ),
  classification, eligibleStandards.
- Campos de compliance na própria `QualifiedPerson` — confidentialityAgreement,
  legacyConfidentiality, codeOfEthics (enum `ok`/`nao`/`sim`/`dispensado`),
  ead?, appointmentTermSigned? (auditores), **performanceLastAt / performanceNextDueAt**
  (→ alimenta calendário e badge de vencidos).
- **`CategoryFormationRule`** (ref-data) — grupo, gsoCategory/Sub, smiicCategory/Sub,
  requiredFormation. Espelha a aba "Categoria vs Formação"; futuro gate de alocação de
  auditor por categoria (hoje só informativo).

Desligado = **soft state** (`status`), nunca delete — histórico exigido pela ISO.

## 3. Fases

| Fase | Entrega | Esforço |
|---|---|---|
| **F1** | Migration (tabelas novas, aditiva) + **ETL da planilha** (ativos + desligados + matriz) | ½ dia |
| **F2** | Backend CRUD (`/qualified-personnel`), roles qualidade/gestor/admin, filtros (status, apontamento, vencimento de avaliação) — ⚠️ **rotas novas → regenerar API GW no MESMO commit** | ½ dia |
| **F3** | Tela da qualidade "Pessoal Qualificado": lista c/ filtros + badge "N avaliações vencidas" (padrão MP: **avisar, não travar**) + ficha da pessoa (apontamentos, controles, suplente) + edição | 1 dia |
| **F4** | Avaliações periódicas a vencer → eventos no **Calendário** (tipo novo `avaliacao`) | ¼ dia |
| **F5** (pós-go-live) | Export do FM 6.1.4 (xlsx/PDF no layout oficial) p/ acreditadores — mesmo racional do site público (FM 781/782) | a estimar |

## 4. Decisões em aberto (Renato/FAMBRAS)

1. **Reconciliar os 34 auditores** da planilha com os `User` role `auditor` do GC agora
   (vínculo `userId`) ou deixar para depois do go-live? (recomendação: depois — F1 importa
   sem vínculo).
2. A matriz Categoria×Formação vira **gate** na alocação de auditor em auditoria
   (bloquear auditor sem formação p/ a categoria) ou fica **informativa**?
   (recomendação: informativa no go-live; gate é mudança de comportamento).
3. O FM oficial continua sendo mantido na planilha até o F5 (export) ficar pronto —
   **quem é o master durante a transição?** (recomendação: sistema vira master após
   validação da carga pela Elaine; planilha congela).
