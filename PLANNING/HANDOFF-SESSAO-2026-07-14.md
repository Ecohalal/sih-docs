# Handoff — Sessão 14/jul/2026 (Documentos executivos & contratuais)

> ⚠️ **HISTÓRICO — NÃO É FONTE DA VERDADE.** Este handoff descreve o momento em que foi escrito e **pode estar defasado** (vários afirmavam "feito/commitado" para código que o git desmentia). Para o estado atual, leia **`sih-docs/PLANNING/BACKLOG-ECOHALAL.md`**. Use este arquivo só para entender *por que* uma decisão foi tomada.

Foco: **atualização dos materiais de apresentação/roadmap dos 3 sistemas para o retrato de 14/jul**, com go-live FAMBRAS ancorado em **agosto/2026** e enquadramento estrito de status (§2.5: só **SysHalal** em produção; **GC/SIH pré-go-live**). Sessão de documentação — **sem código, sem deploy, sem SQL**.

> Convenção reforçada nesta sessão: **NUNCA usar "HalalSphere"** em material de cliente/diretoria/comercial (nomenclatura = "Gestão de Certificações"). Regra da Renato, repetida 2× na sessão. Ver `feedback_nomes_completos_sistemas` e `project_email_branding_nomenclatura`.

---

## 1. Roadmap Diretoria (sih-docs) — REVISADO p/ 14/jul
Documento-fonte de maio estava ancorado em go-live julho e dizia "3 sistemas em produção". Criada **revisão de julho** (originais de maio preservados como histórico):
- **Novos:** [`PLANNING/ROADMAP-DIRETORIA-2026-07-14.md`](ROADMAP-DIRETORIA-2026-07-14.md) (fonte) + `.html` (apresentável).
- HTML regenerado no mesmo layout, **brand flipado verde→azul `#118add`** (marca EcoHalal; ver `project_brand_ecohalal_azul`).
- Correções-chave: go-live **agosto/2026**; status honesto (SysHalal 🟢 / GC-SIH pré-go-live); seção 0 consolidando evolução mai→jul (reset 28/mai, piloto SIH, integração GC↔SIH, cargas de dados, emissão manual madura, edição de escopo, recuperação senha, rebrand); roadmap reancorado (5.1 jul → 5.2 ago go-live → 5.3 set porta 4).
- Removido "(HalalSphere)" do nome do sistema.

## 2. Documento de Ecossistema (halalsphere-docs) — ATUALIZADO
Este era **o** material de apresentação dos sistemas que a Renato pediu (não o roadmap acima). Fica em outro repo:
- [`halalsphere-docs/ECOSSISTEMA/ECOSSISTEMA-HALAL-ECOHALAL.md`](../../halalsphere-docs/ECOSSISTEMA/ECOSSISTEMA-HALAL-ECOHALAL.md) — público: Diretoria/Comercial/Marketing/Produto.
- Data → **14/07/2026**; **4× "HalalSphere" removidas**; Status GC/SIH → **pré-go-live (estrito §2.5)** + conquistas de julho (carga da base real, 1ª integração real SIH←GC em prod); quadro comparativo (§6) e nota da porta 4 (§5) atualizados.
- Ficha técnica GC **renomeada via `git mv`**: `FICHA-TECNICA-GC-HALALSPHERE.md` → `FICHA-TECNICA-GC.md` (link no doc principal reapontado). Fichas SIH/SysHalal: status/data.
- **1 menção "halalsphere" mantida de propósito** (linha ~404): caminho literal do repositório de código `halalsphere-backend/...` numa nota técnica de "fonte de verdade" — não é branding. **Decisão pendente da Renato:** abstrair ou manter.
- **PENDENTE:** o **PDF** `ECOSSISTEMA-HALAL-ECOHALAL.pdf` (2 MB, 19/jun) **NÃO foi regenerado** (decisão "só .md por ora"); não há script de geração no repo. Regenerar para bater com o texto novo.
- ⚠️ **`git mv` está staged, nada commitado** — Renato decide o commit.

## 3. Docs contratuais em `C:\SIH\` — ATUALIZADOS IN-PLACE (com backup)
Editados via cirurgia de XML (docx = zip), **preservando 100% da formatação**; `zip` não existe no Git Bash → reempacotado com `zipfile` do Python preservando ordem/nomes das entradas.
- **`C:\SIH\Roadmap_27_05 (2).docx`** (= Anexo I do contrato): rodapé 27/05→**14/07/2026**; Seção 2 "Em produção" → `Mai–Jul/2026` **+6 linhas de julho**; Seções 3 e 4 → `Jul–Ago/2026`. 5 tabelas e estilo (cores por seção) intactos.
- **`C:\SIH\Escopo Serviços.docx`** (contratual, "ESCOPO DOS SERVIÇOS"): **só status** — GC `(em fase de teste)`→`(em fase de homologação/pré-go-live)`; SIH `(em desenvolvimento)`→`(em piloto controlado)`. Conjunto de serviços **inalterado**.
- **Backups:** `Roadmap_27_05 (2).bak-20260714.docx` e `Escopo Serviços.bak-20260714.docx` (mesma pasta). Integridade validada (ZIP OK + XML bem-formado; 27 e 12 entradas = originais).
- **Renato: validar visualmente no Word** (não abri o Word aqui). Backup restaura em 1 comando.

## 3b. Fichas técnicas do SysHalal (reabertura da sessão) — ENTREGUES
- **Correção:** `halalsphere-docs/ECOSSISTEMA/FICHA-TECNICA-SYSHALAL.md` tinha stack errado (Prisma 5) → **Prisma 6** + next-auth/React 18/TanStack/Chart.js (stack real conferido nos `package.json` de `syshalal-api`/`syshalal-web`).
- **Novos arquivos em `C:\SIH\`** (a pedido, ambos):
  - `FICHA-TECNICA-SYSHALAL.md` — 1 página comercial (cópia da canônica, stack corrigido).
  - `FICHA-TECNICA-SYSHALAL-COMPLETA.md` — **técnica completa** (10 seções: arquitetura Clean Arch, domínios/módulos, PDF+QR dual scheme, integrações, ambientes/infra ALB+Fargate :3000, segurança, dados ~3,4k empresas/303 plantas/~3,1k certs, stack detalhado, evoluções). Aterrada no repo real + refs de memória.
- Volumes/integrações externas (SFDA/API v2) marcados como **aproximados/em evolução** — confirmar no banco antes de uso externo.

## 4. Pendências deixadas de propósito (decisão da Renato)
1. Promover para "Em produção" (Seção 2 do Roadmap docx) itens da Seção 3 que já estejam concluídos (ex.: Sprint 5 SIH, integração SIH↔GC) — deixei conservador p/ não superestimar.
2. Regenerar o PDF do Ecossistema.
3. Abstrair (ou não) o caminho `halalsphere-backend` na nota técnica §7 do Ecossistema.
4. Commit do `git mv` da ficha + demais alterações em `halalsphere-docs`.

## 5. Estado
- **sih-docs:** novos arquivos untracked em `PLANNING/` (ROADMAP-DIRETORIA-2026-07-14.*). Nada commitado.
- **halalsphere-docs:** edições + 1 `git mv` staged. Nada commitado.
- **C:\SIH\:** 2 docx sobrescritos + 2 backups. Fora de repositório git.
- Nenhuma alteração de código/infra/dados. Nada a deployar.

---
**Memórias-chave:** `project_docs_apresentacao_executivos_2026-07-14` (nova — localização dos materiais), `project_brand_ecohalal_azul`, `project_email_branding_nomenclatura`, `feedback_nomes_completos_sistemas`, `feedback_atualizar_docx_herdar_estilo_original`.
