# Recuperação de senha (self-service) — SIH — Handoff 2026-07-13

> ⚠️ **HISTÓRICO — NÃO É FONTE DA VERDADE.** Este handoff descreve o momento em que foi escrito e **pode estar defasado** (vários afirmavam "feito/commitado" para código que o git desmentia). Para o estado atual, leia **`sih-docs/PLANNING/BACKLOG-ECOHALAL.md`**. Use este arquivo só para entender *por que* uma decisão foi tomada.

Feature: fluxo público **"Esqueci minha senha" → e-mail com link → redefinir senha**
no SIH (Supervisão Industrial Halal). Gap notado na apresentação para a Nilsa (login
sem meio de recuperar senha). Espelha o fluxo forgot/reset do GC.

## Decisões (Renato, 13/jul)
- **Escopo:** só recuperação de senha. **Sem** onboarding/primeiro-acesso (admin
  continua criando usuário já com senha — modelo atual inalterado).
- **Política de senha nova:** simples — mínimo 6 caracteres, sem exigência de
  complexidade (igual ao troca-senha atual `/system-users/me/password`).

## O que foi implementado — ✅ **EM `release`** (back `06ae5ef` · front `a24385b`, remote `ecohalal`)

> Correção de 16/jul: este handoff dizia *"código pronto, NÃO deployado"* — o git desmentia.
> Estado atual sempre em `sih-docs/PLANNING/BACKLOG-ECOHALAL.md` (§4).

### Backend (`sih-backend`)
- **Schema** `prisma/schema.prisma` — `SystemUser` ganhou:
  `passwordResetToken String? @unique @db.VarChar(64)` + `passwordResetExpiresAt DateTime?`.
- **Migration** `prisma/migrations/20260713120000_password_reset_token/migration.sql`
  — aditiva/idempotente (ADD COLUMN IF NOT EXISTS + CREATE UNIQUE INDEX IF NOT EXISTS).
- **DTOs** `src/auth/dto/forgot-password.dto.ts` — `ForgotPasswordSchema` (email) e
  `ResetPasswordSchema` (token + newPassword min 6), Zod.
- **Template** `src/email/templates/password-reset.ts` — HTML inline, marca azul
  `#118add`, "Supervisão Industrial Halal" / "Fambras Halal by Ecohalal".
- **Service** `src/auth/auth.service.ts` — `forgotPassword()` (token `randomBytes(32)`
  hex, TTL **60 min**, cooldown 60s/e-mail, resposta genérica anti-enumeração, e-mail
  best-effort via `EmailService` SES) + `resetPassword()` (valida token+expiração,
  `bcrypt.hash` rounds 10, limpa token, registra `AccessLogEvent.PASSWORD_RESET`).
  Injeta `ConfigService` + `EmailService` (ambos globais — sem mudança de módulo).
- **Controller** `src/auth/auth.controller.ts` — `POST /auth/forgot-password` e
  `POST /auth/reset-password`, ambos `@Public()`.
- ✅ `npx prisma generate` + `tsc --noEmit` **OK**.

### Frontend (`sih-frontend`)
- **Service** `src/services/password-reset.service.ts` — `useForgotPassword` /
  `useResetPassword` (via `authApi`, pré-auth) + export no barrel `services/index.ts`.
- **Shell** `src/pages/auth/AuthShell.tsx` — casca visual compartilhada (identidade do
  Login: azul `#118add`, Poppins, avatar SIH, "voltar para o login").
- **Páginas** `src/pages/ForgotPassword.tsx` + `src/pages/ResetPassword.tsx`
  (lê `?token=` via `useSearchParams`; min 6 + confirmação; estados vazio/sucesso/erro).
- **Rotas** públicas em `App.tsx`: `/esqueci-senha`, `/redefinir-senha`.
- **Login** `src/pages/Login.tsx` — link "Esqueci minha senha" abaixo do campo de
  senha (string em `DICT` pt/en).
- ✅ `tsc -b` **OK**.

Link gerado: `${FRONTEND_URL}/redefinir-senha?token=...` (FRONTEND_URL já em prod =
`https://supervisao-industrial.ecohalal.solutions`).

## Pendências (estado real — o mestre §4 manda)
1. ✅ **SES fora do sandbox — CONFIRMADO pelo Renato** (13/jul e reconfirmado 16/jul).
   Era o risco de bloquear o fluxo em campo; está resolvido.
2. ✅ **Deploy** — feito: push em `release` (back `06ae5ef` · front `a24385b`).
3. 🧩 **Swagger / API Gateway:** as rotas caem sob o prefixo `auth` que **já tem
   `{proxy+}`** → **não exige** resource nova (por isso não bloqueou o deploy). Mas o
   `swagger.json` segue defasado — item aberto no §4.2 do mestre.
4. 🔧 **Migration em prod:** `AUTO_MIGRATE=true` aplica no deploy. Confirmar aplicação
   de `20260713120000_password_reset_token` — aberto no §4.1.
5. 🔧 **Validação E2E** (roteiro abaixo) — aberto no §4.1.

## Validação end-to-end (pós-deploy)
1. Login → "Esqueci minha senha" → informar e-mail de um `SystemUser` ativo → checar
   resposta genérica na tela.
2. Conferir e-mail recebido (remetente "FAMBRAS Halal - SIH", link válido).
3. Abrir link → definir nova senha (testar <6 e senhas divergentes = erro) → sucesso.
4. Logar com a nova senha. Conferir linha `PASSWORD_RESET` em `/access-logs`.
5. Reusar o mesmo link → deve falhar (token de uso único).
