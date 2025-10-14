# 1) Create Day02 documentation file with full content
mkdir -p ~/clouddrive/sogeti-senior-cloud-engineer-remote/docs && cat > ~/clouddrive/sogeti-senior-cloud-engineer-remote/docs/day02-backend.md <<'MD'
# Day 02 – Terraform Backend, Azure Key Vault & GitHub OIDC

## Goals
- Centralize Terraform state in Azure Storage (remote backend) with locking and recovery.
- Store application secrets in Azure Key Vault using RBAC (data plane).
- Enable keyless CI via GitHub OIDC (federated credentials), scoped by RBAC to a resource group.
- Provide an offline fallback to run Terraform without Azure.

## Repo Structure (today)
- `infra/day02-backend-cli/backend-cli.tf` – azurerm backend config.
- `infra/day02-backend-cli/main.tf` – minimal workload (User Assigned Identity).
- `.github/workflows/day02-backend-cli.yml` – CI workflow with `offline` and `apply` inputs.
- `scripts/day02-backend-cli.sh` – CLI runbook for portal-equivalent steps.

## High-level Architecture (ASCII)
GitHub Actions (OIDC) ──► Entra ID App (Federated Credential)
│ │ RBAC (Contributor @ RG)
│ └──► Azure Resource Group (rg-day02-backend-cli)
│ ├─ Storage (stday02backendcliweu)
│ │ └─ Blob container (tfstate-cli) ⇐ Terraform state
│ └─ Key Vault (kvday02backendcliweu) ⇐ secrets
└─ Terraform backend "azurerm" → reads/writes state in tfstate-cli

bash
Copy code

## Terraform Backend & State
- Why remote: collaboration, state locking (blob lease), recovery (versioning + soft delete).
- Config (`infra/day02-backend-cli/backend-cli.tf`):
```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-day02-backend-cli"
    storage_account_name = "stday02backendcliweu"
    container_name       = "tfstate-cli"
    key                  = "infra/primary.tfstate"
  }
}
key is the blob path within the container; keep it unique per environment.

Azure Storage Hardening
Enabled on the account:

Blob versioning = on

Delete retention = 90 days

Container delete retention = 90 days

Public access disabled, TLS 1.2 minimum

Key Vault (RBAC mode)
Purpose: centralized secret storage with audit and soft delete + purge protection.

Access model: Azure RBAC on data plane.

App (CI OIDC): Key Vault Secrets User (read-only).

Operator (human): Key Vault Secrets Officer (create/update secrets).

RBAC: Management vs Data Plane
Management plane (ARM): e.g., Contributor at RG scope → create/update resources (incl. Storage account, Key Vault).

Data plane:

Storage blobs → Storage Blob Data * roles (Reader/Contributor).

Key Vault secrets → Key Vault Secrets * roles.

Note: Contributor does not grant data access.

GitHub OIDC (Workload Identity Federation)
App registration: gh-oidc-day02-cli (+ service principal).

Federated Credential (exact, case-sensitive since Aug 2024):

bash
Copy code
issuer  : https://token.actions.githubusercontent.com
subject : repo:ehabSaad01/sogeti-senior-cloud-engineer:ref:refs/heads/main
audience: api://AzureADTokenExchange
Repo variables used by azure/login@v2:

AZURE_CLIENT_ID, AZURE_TENANT_ID, AZURE_SUBSCRIPTION_ID

OIDC Troubleshooting
AADSTS700213 → subject/issuer/audience mismatch. Confirm exact case of GITHUB_REPOSITORY and GITHUB_REF.

Missing repo variables → azure/login fails.

Runner lacks container-rm → use data-plane az storage container list --auth-mode login.

CI Workflow (Actions)
File: .github/workflows/day02-backend-cli.yml

Inputs:

offline: default yes to run without Azure (local backend).

apply: gated; only valid when offline=no.

Steps:

Checkout

(Conditional) Azure login via OIDC

Setup Terraform

terraform init (with -backend=false when offline)

validate

plan → upload tfplan.bin

(Conditional) apply

Offline Mode
Purpose: demo-ready without Azure access.

Behavior:

terraform init -backend=false

plan with -lock=false -refresh=false

Use: run workflow with offline = yes, apply = no.

Workload (Day02)
Minimal resource within RG scope:

azurerm_user_assigned_identity.uai-day02-tfcli in rg-day02-backend-cli

Provider config disables RP auto-registration to avoid subscription-level permissions:

hcl
Copy code
provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
}
Validations
State blob exists: infra/primary.tfstate inside tfstate-cli.

Key Vault access from CI: secret read test (no secret value printed).

Next Steps
Day03: tighten networking (private endpoints or firewall allowlist), diagnostic settings, and module structure.

Add README badge and mark Day02 as ready.
MD

2) Stage, commit, and push the documentation file
git -C ~/clouddrive/sogeti-senior-cloud-engineer-remote add docs/day02-backend.md
git -C ~/clouddrive/sogeti-senior-cloud-engineer-remote commit --message "docs(day02): backend, key vault, and OIDC overview with offline CI"
git -C ~/clouddrive/sogeti-senior-cloud-engineer-remote push origin main
