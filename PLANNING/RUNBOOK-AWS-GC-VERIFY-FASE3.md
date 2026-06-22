# Runbook — Provisionamento AWS do halalsphere-verify-web (Caminho B, Fase 3)

**Objetivo:** servir o verify do GC em `cert.fambrashalal.com.br/verify/*` adicionando
uma regra de listener na ALB existente, sem tocar no SysHalal.
**Conta:** 767397935861 · **Região:** us-east-1
**Requer:** credencial com permissão de ECR + ECS + ELBv2 + EC2(SG) + Logs.
⚠️ O usuário de CI `system_ecohalal` **NÃO tem** essas permissões — executar com role/console privilegiado.

> Código já pronto e validado (Fases 1 e 2): `halalsphere-backend` (env `QR_VERIFICATION_BASE_URL`)
> e `halalsphere-frontend` (`Dockerfile.verify` + `deploy/verify/default.conf.template` +
> `deploy/codebuild/buildspec-verify.yml` + `.dockerignore`).

---

## Parâmetros conhecidos (CONFIRMADOS nos prints do console, 2026-06-21)
```bash
REGION=us-east-1
ACCOUNT=767397935861
VPC=vpc-0d47cab0d440d5de5
GC_API_UPSTREAM=https://gestaodecertificacoes-api.ecohalal.solutions
ALB_NAME=ecohalal-fambrashalal-web
CLUSTER=ecohalal-cluster-fambrashalal-web
L443_ARN=arn:aws:elasticloadbalancing:us-east-1:767397935861:listener/app/ecohalal-fambrashalal-web/f1a8105ebba087bb/37771d8ee1783b51
TASK_SUBNETS=subnet-0f8c9eac25e08b0a4,subnet-0d36ec0075e79e5fc   # subnets das tasks (reuso do cert-web)
TASK_SG=sg-013a70ccd4c44e4b8                                     # MESMO SG da ALB (reuso do cert-web)
ASSIGN_PUBLIC_IP=ENABLED                                         # tasks em subnet publica, sem NAT
CONTAINER_PORT=3000                                              # espelha o cert-web; SG ja libera 3000
PRIORITY=10                                                      # listener 443 so tem a default hoje
EXEC_ROLE=arn:aws:iam::767397935861:role/fambrashalal-cert-web_production_task_execution_role  # reuso do cert-web
# Fallback: se a task falhar ao puxar imagem/escrever logs, criar execution role dedicada
# com a policy gerenciada AmazonECSTaskExecutionRolePolicy.
```

> **Decisão de rede:** espelhar exatamente o service `fambrashalal-cert-web` —
> mesmas subnets, mesmo SG, IP publico ON, **porta 3000**. Assim NÃO se cria SG novo
> e a task não fica exposta na internet (porta 3000 só é alcançável pela ALB via o SG
> compartilhado). A Etapa 3.3 (SG novo) fica **CANCELADA**.

## 0. Discovery (read-only) — preencher os 5 valores que faltam
```bash
# ALB ARN + SG + VPC
aws elbv2 describe-load-balancers --region $REGION --names $ALB_NAME \
  --query 'LoadBalancers[0].{Arn:LoadBalancerArn,SGs:SecurityGroups,VpcId:VpcId}'
LB_ARN=<...>
ALB_SG=<...>                          # SG da ALB (origem do ingress do halalsphere-verify-web)

# Listener 443 ARN
aws elbv2 describe-listeners --region $REGION --load-balancer-arn $LB_ARN \
  --query 'Listeners[?Port==`443`].ListenerArn' --output text
L443_ARN=<...>

# Prioridades já em uso no listener 443 (escolher uma livre p/ a nova regra)
aws elbv2 describe-rules --region $REGION --listener-arn $L443_ARN \
  --query 'Rules[].Priority'

# Cluster + networkConfiguration do serviço syshalal-web (reaproveitar subnets + execution role)
aws ecs list-clusters --region $REGION
CLUSTER=<...>
aws ecs describe-services --region $REGION --cluster $CLUSTER --services <syshalal-web-svc> \
  --query 'services[0].networkConfiguration.awsvpcConfiguration'   # subnets + assignPublicIp
SUBNETS=<subnet-a,subnet-b>           # reusar as do syshalal-web
aws ecs describe-task-definition --region $REGION --task-definition <syshalal-web-taskdef> \
  --query 'taskDefinition.executionRoleArn'
EXEC_ROLE=<arn execution role>        # reusar
```

## 3.1 — ECR
```bash
aws ecr create-repository --region $REGION --repository-name halalsphere-verify-web \
  --image-scanning-configuration scanOnPush=true
```

## (build da imagem) — escolher 1
- **Recomendado (pipeline):** criar CodeBuild project espelhando o do `syshalal-web`,
  apontando para `deploy/codebuild/buildspec-verify.yml`, env `ECR_REPOSITORY_NAME=halalsphere-verify-web`,
  `AWS_DEFAULT_REGION`/`AWS_REGION=us-east-1`, `BRANCH_NAME=release`, privilegiado (docker).
  Encadear num CodePipeline com deploy ECS (action ECS, usa `imagedefinitions.json`).
- **Manual (one-off, precisa Docker daemon + push ECR):**
```bash
aws ecr get-login-password --region $REGION | docker login --username AWS \
  --password-stdin $ACCOUNT.dkr.ecr.$REGION.amazonaws.com
docker build -f Dockerfile.verify -t $ACCOUNT.dkr.ecr.$REGION.amazonaws.com/halalsphere-verify-web:1 .
docker push $ACCOUNT.dkr.ecr.$REGION.amazonaws.com/halalsphere-verify-web:1
```

## 3.2 — CloudWatch Logs
```bash
aws logs create-log-group --region $REGION --log-group-name /aws/ecs/halalsphere-verify-web
```

## 3.3 — Security Group — ❌ CANCELADA
Não criar SG novo. Reusar `TASK_SG=sg-013a70ccd4c44e4b8` (o mesmo do cert-web), que
já permite ALB → tasks na porta 3000.

## 3.4 — Task Definition (arquivo halalsphere-verify-web-taskdef.json)
```json
{
  "family": "halalsphere-verify-web",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "<EXEC_ROLE>",
  "containerDefinitions": [
    {
      "name": "halalsphere-verify-web",
      "image": "<ACCOUNT>.dkr.ecr.us-east-1.amazonaws.com/halalsphere-verify-web:1",
      "essential": true,
      "portMappings": [{ "containerPort": 3000, "protocol": "tcp" }],
      "environment": [
        { "name": "GC_API_UPSTREAM", "value": "https://gestaodecertificacoes-api.ecohalal.solutions" }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/aws/ecs/halalsphere-verify-web",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "halalsphere-verify-web"
        }
      }
    }
  ]
}
```
```bash
aws ecs register-task-definition --region $REGION --cli-input-json file://halalsphere-verify-web-taskdef.json
```
> Nome do container `halalsphere-verify-web` **deve** bater com o `imagedefinitions.json` do buildspec.

## 3.5 — Target Group
```bash
TG_ARN=$(aws elbv2 create-target-group --region $REGION --name halalsphere-verify-web-tg \
  --protocol HTTP --port 3000 --vpc-id $VPC --target-type ip \
  --health-check-path /verify/health --matcher HttpCode=200 \
  --query 'TargetGroups[0].TargetGroupArn' --output text)
```

## 3.6 — ECS Service
```bash
aws ecs create-service --region $REGION --cluster $CLUSTER --service-name halalsphere-verify-web \
  --task-definition halalsphere-verify-web --desired-count 2 --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[$TASK_SUBNETS],securityGroups=[$TASK_SG],assignPublicIp=ENABLED}" \
  --load-balancers "targetGroupArn=$TG_ARN,containerName=halalsphere-verify-web,containerPort=3000"
# Esperar tasks ficarem HEALTHY no target group antes do passo 3.7.
```

## 3.7 — ⚠️ Regra de listener (única alteração em recurso existente)
```bash
# SÓ ADICIONAR. NÃO tocar na ação default, no cert, nem na porta/protocolo do listener.
aws elbv2 create-rule --region $REGION --listener-arn $L443_ARN --priority 10 \
  --conditions Field=path-pattern,Values='/verify/*' \
  --actions Type=forward,TargetGroupArn=$TG_ARN
```
Regras de ouro: condição específica `/verify/*`; validar em path de teste antes de QR real.

## Rollback
```bash
aws elbv2 describe-rules --region $REGION --listener-arn $L443_ARN  # achar RULE_ARN da /verify/*
aws elbv2 delete-rule --region $REGION --rule-arn <RULE_ARN>        # restaura o estado de hoje
```

## Deploy do backend (Fase 1.5) — separado, requer autorização
- Repos `halalsphere-backend` e `halalsphere-frontend` estão na branch **`release`** (push = CI/CD).
- Setar `QR_VERIFICATION_BASE_URL=https://cert.fambrashalal.com.br/verify` na **task definition de prod do backend GC** (nova revisão + `update-service --force-new-deployment`). Afeta só QR de certs **novos**.
- Sincronizar lockfile npm se mexer em deps (não é o caso aqui).
