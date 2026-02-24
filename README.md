# SIH - Supervisao Industrial Halal

**Sistema de digitalizacao dos formularios FM FAMBRAS Halal para supervisao industrial em campo**

---

## Sobre o Projeto

O SIH substitui os formularios em papel (PDFs) utilizados pelos supervisores muculmanos da FAMBRAS Halal por um sistema digital responsivo, otimizado para uso em tablets em campo.

### Formularios Digitalizados

| Familia | FM | Descricao |
|---------|-----|-----------|
| Abate | FM 7.1.4.1 / FM 7.1.4.2 | Relatorios de Abate Halal (Aves e Bovinos) |
| Producao | FM 7.1.3.1 / FM 7.1.8.x | Relatorios de Producao Industrial |
| Embarque | FM 7.1.7.1 / FM 7.1.7.4 / DCPOA | Embarque, Venda e Transferencia |
| NC | FM 7.1.6.1 | Checklist de Nao-Conformidade |
| Inventario | FM 7.1.5.x / FM 7.1.3.6 | Inventario de Carne, Lotes e Rotulagem (futuro) |

### Tech Stack

- **Backend**: NestJS 11 + Prisma 7 + PostgreSQL 16
- **Frontend**: React 19 + Vite 7 + Tailwind CSS + shadcn/ui
- **Auth**: Compartilhada via Gestao de Certificacoes (JWT RS256)
- **Plataforma**: PWA responsivo (tablet-first)

---

## Documentacao

- [PRD - Product Requirements Document](./01-prd/README.md)
- [Documentacao Tecnica](./02-technical/README.md)
- [Guias](./GUIDES/)
- [Planejamento](./PLANNING/)
