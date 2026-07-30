# YouKnowIt — Infra

Terraform infrastructure for the YouKnowIt portfolio project. Provisions all AWS resources and bootstraps the EKS cluster with ArgoCD, which then takes over deploying and managing every workload from the GitOps repo.

**Repositories:** [YouKnowIt-app](https://github.com/Lielik/YouKnowIt-app) · [YouKnowIt-infra](https://github.com/Lielik/YouKnowIt-infra) · [YouKnowIt-gitops](https://github.com/Lielik/YouKnowIt-gitops)

---

## What it provisions

A single `terraform apply` creates:

- VPC with public and private subnets across two AZs, NAT gateways, and route tables
- EKS cluster (v1.36) with a managed node group of `t3.medium` instances
- RDS PostgreSQL 16 (private subnet, not publicly accessible)
- S3 bucket for Loki log storage with 30-day lifecycle expiration
- IRSA roles for ESO, Loki, and the EBS CSI driver
- EBS CSI driver EKS addon (required on EKS 1.27+ — the in-tree EBS provisioner was removed)
- All four application secrets in AWS Secrets Manager (`youknowit/dev/app`, `youknowit/dev/database-url`, `youknowit/grafana/admin`, `youknowit/alertmanager/slack`)
- ArgoCD installed via Helm, seeded with the app-of-apps manifest fetched from the GitOps repo

After apply, ArgoCD manages all further cluster state declaratively.

---

## Module structure

```
modules/
├── vpc/           # VPC, subnets, NAT gateways, route tables
├── eks/           # EKS cluster, node group, OIDC provider
├── rds/           # RDS instance, subnet group, security group
├── irsa/          # Reusable IRSA role + trust policy (called by other modules)
├── loki-storage/  # S3 bucket + lifecycle + IRSA role for Loki
├── eso-iam/       # IRSA role scoped to ESO's controller ServiceAccount
├── ebs-csi/       # AWS-managed EBS CSI driver addon + IRSA role
├── secrets/       # All four AWS Secrets Manager entries
└── argocd/        # Helm install of ArgoCD + kubectl apply of app-of-apps
```

The `irsa` module is a reusable building block — `loki-storage`, `eso-iam`, and `ebs-csi` all call it with different namespaces, service account names, and IAM policy JSON.

---

## Providers

| Provider | Version | Purpose |
|---|---|---|
| `hashicorp/aws` | `~> 6.0` | All AWS resources |
| `hashicorp/helm` | `~> 3.0` | ArgoCD Helm install |
| `hashicorp/kubernetes` | `~> 3.0` | Kubernetes resources |
| `gavinbunney/kubectl` | `~> 1.0` | Raw YAML manifest apply (app-of-apps) |
| `hashicorp/http` | `~> 3.0` | Fetch bootstrap files from GitOps repo at apply time |

The `helm`, `kubernetes`, and `kubectl` providers authenticate to EKS using a short-lived token from `data.aws_eks_cluster_auth` — no static credentials.

---

## State backend

Remote state is stored in S3 with native file-based locking (`use_lockfile = true`). Copy the backend template to configure:

```bash
cp templates/config.s3.tfbackend.template config.s3.tfbackend
# Fill in bucket, key, and region
```

The `config.s3.tfbackend` file is git-ignored. `terraform init` reads it via `-backend-config`.

---

## Setup

**Prerequisites:** Terraform >= 1.11, AWS CLI configured, kubectl.

```bash
# 1. Configure the state backend
cp templates/config.s3.tfbackend.template config.s3.tfbackend
# Edit config.s3.tfbackend — set bucket, key, region

# 2. Configure environment variables
cp templates/terraform.tfvars.template environments/dev.tfvars
# Edit environments/dev.tfvars — see variables reference below

# 3. Initialise
make init

# 4. Plan
make plan

# 5. Apply
make apply
```

After apply, update your kubeconfig:

```bash
aws eks update-kubeconfig --name youknowit-dev --region us-east-1
```

---

## Makefile targets

| Target | Command | Description |
|---|---|---|
| `make init` | `terraform init -backend-config=config.s3.tfbackend -reconfigure` | Initialise and configure backend |
| `make validate` | `terraform validate` | Check syntax and internal consistency |
| `make fmt` | `terraform fmt -recursive` | Format all `.tf` files |
| `make plan` | `terraform plan -var-file=environments/dev.tfvars -out=tfplan` | Generate and save plan |
| `make apply` | `terraform apply tfplan` | Apply the saved plan |
| `make destroy` | `terraform destroy -var-file=environments/dev.tfvars` | Tear down all resources |

Override the environment with `ENV=prod make plan`.

---

## Variables reference

All values go in `environments/dev.tfvars`, which is git-ignored.

| Variable | Description | Example |
|---|---|---|
| `aws_region` | AWS region | `us-east-1` |
| `project_name` | Prefix for all resource names | `youknowit` |
| `environment` | Environment label | `dev` |
| `vpc_cidr` | VPC CIDR block | `10.0.0.0/16` |
| `availability_zones` | Two AZs for multi-AZ deployment | `["us-east-1a", "us-east-1b"]` |
| `public_subnet_cidrs` | Public subnet CIDRs (one per AZ) | `["10.0.1.0/24", "10.0.2.0/24"]` |
| `private_subnet_cidrs` | Private subnet CIDRs (one per AZ) | `["10.0.3.0/24", "10.0.4.0/24"]` |
| `kubernetes_version` | EKS Kubernetes version | `1.36` |
| `node_instance_type` | EC2 instance type for EKS nodes | `t3.medium` |
| `node_desired_size` | Initial node count | `3` |
| `node_min_size` | Minimum node count | `1` |
| `node_max_size` | Maximum node count | `3` |
| `db_instance_class` | RDS instance type | `db.t3.micro` |
| `db_name` | PostgreSQL database name | `youknowit` |
| `db_username` | RDS master username | `youknowit_admin` |
| `db_password` | RDS master password (sensitive) | — |
| `db_allocated_storage` | RDS storage in GB | `20` |
| `secret_key` | JWT signing key for the app | `openssl rand -hex 32` |
| `grafana_admin_password` | Grafana admin password | — |
| `slack_webhook_url` | Alertmanager Slack webhook URL | — |

> **Note on subnet sizing:** Use `/24` CIDRs (251 usable IPs per subnet). The default AWS VPC CNI assigns one VPC IP per pod — a `/27` subnet (27 IPs) exhausts quickly with a full monitoring stack.

---

## Outputs

| Output | Description |
|---|---|
| `eks_cluster_name` | EKS cluster name |
| `eks_cluster_endpoint` | Kubernetes API server URL |
| `eks_cluster_ca_certificate` | Base64-encoded cluster CA (sensitive) |
| `vpc_id` | VPC ID |
| `private_subnet_ids` | Private subnet IDs (EKS nodes, RDS) |
| `public_subnet_ids` | Public subnet IDs (NAT gateways, NLB) |
| `db_endpoint` | RDS endpoint (host:port) |
| `db_name` | Database name |
| `db_port` | Database port |
| `oidc_provider_arn` | EKS OIDC provider ARN (used for IRSA) |
| `oidc_provider_url` | EKS OIDC provider URL |
| `loki_s3_bucket_name` | S3 bucket name for Loki logs |
| `loki_iam_role_arn` | IRSA role ARN for Loki |
| `eso_iam_role_arn` | IRSA role ARN for External Secrets Operator |

---

## ArgoCD bootstrap

The `argocd` module installs ArgoCD via Helm and immediately applies the `app-of-apps` Application manifest. Both files are fetched at apply time from the public `YouKnowIt-gitops` repo using the `http` provider — no local checkout of the GitOps repo is required.

This creates a clean handoff: Terraform creates the cluster and seeds it with ArgoCD, then steps back entirely. From that point on, all cluster state is declared in the GitOps repo and reconciled by ArgoCD.

---

## Destroy pre-flight

Before running `terraform destroy`, always:

```bash
# 1. Delete the LoadBalancer Service so Kubernetes cleans up the NLB
kubectl delete svc ingress-nginx-controller -n ingress-nginx

# 2. Wait ~30s, then confirm the NLB is gone
aws elbv2 describe-load-balancers \
  --query 'LoadBalancers[?VpcId==`<your-vpc-id>`].LoadBalancerArn' \
  --output text

# If still present, delete it manually
aws elbv2 delete-load-balancer --load-balancer-arn <arn>

# 3. Empty the Loki S3 bucket
aws s3 rm s3://youknowit-loki-logs --recursive

# 4. Destroy
make destroy
```

Skipping step 1 will cause `terraform destroy` to hang on subnet deletion for 15–20 minutes, because the NLB creates ENIs that Terraform doesn't manage and can't remove.

---

## Design decisions

**IRSA over node IAM roles.** Each workload that needs AWS access (ESO, Loki, EBS CSI driver) gets its own IAM role with a trust policy scoped to exactly one Kubernetes ServiceAccount in one namespace. No credentials are stored anywhere — pods exchange a Kubernetes-issued OIDC token for a short-lived AWS token at runtime.

**Secret ARNs are deterministic.** IAM role names are chosen in Terraform (`youknowit-dev-eso`, `youknowit-dev-loki`), so their ARNs (`arn:aws:iam::<account-id>:role/<name>`) are fully predictable before apply. These are hardcoded directly into the GitOps manifests rather than wired dynamically, avoiding the complexity of Terraform-writes-to-Git automation.

**Secrets Manager recovery window disabled.** `recovery_window_in_days = 0` on all secrets allows immediate deletion and recreation. This is intentional for a destroy/apply development workflow — without it, recreating secrets with the same name fails until the 7-day recovery window expires.

**EBS CSI driver as an EKS addon.** The EBS CSI driver is installed as an AWS-managed EKS addon rather than via ArgoCD/Helm. Core cluster capabilities (storage, CNI, DNS) belong at the infrastructure layer — ArgoCD manages application workloads, not the cluster's own storage plumbing.

**Terraform bootstraps ArgoCD, then steps back.** The `argocd` module does exactly two things: installs ArgoCD via Helm and applies the app-of-apps manifest. After that, Terraform has no knowledge of or responsibility for anything running in the cluster. This boundary is intentional — it keeps the infra repo concerned only with AWS resources and the initial bootstrap, not with Kubernetes application state.