# Day05 — Secure Storage Baseline (Blob + Private Endpoint + RBAC)

## Goal
Hardened Storage Account (StorageV2, Standard LRS) with:
- Public network disabled, Shared Key disabled
- Private Endpoint (blob) + Private DNS zone
- RBAC data-plane for UAMI (uami04weu)
- Diagnostics to Log Analytics (law-dev-weu)
- Blob Versioning + Soft/Container delete

## Architecture
- VNet from Day03
- VM (Day04) uses UAMI to access blobs over PE
- Private DNS zone: `privatelink.blob.core.windows.net`
- LAW: `law-dev-weu`

## Prerequisites
- Subscription with Network Watcher enabled
- `law-dev-weu` exists (Day03)
- Day03 VNet and a subnet for PE
- `uami04weu` created and attached to VM (Day04)

## Portal Steps (Summary)
1. RG: `rg-day05-storage`
2. Storage Account: `stday05weu` (StorageV2, LRS, TLS1.2+, https only)
3. Disable public network + Shared Key; keep `allowBlobPublicAccess=false`
4. Data protection: Versioning **On**, Soft delete **On** (14d), Container soft delete **On** (14d)
5. Diagnostics → send logs/metrics to `law-dev-weu`
6. Private Endpoint (blob) in Day03 VNet; bind DNS zone
7. RBAC: `Storage Blob Data Contributor` to `uami04weu` at SA scope

## CLI & PowerShell
- CLI script: [`scripts/day05-storage-az.sh`](../../scripts/day05-storage-az.sh)
- PowerShell: [`scripts/day05-storage-ps.ps1`](../../scripts/day05-storage-ps.ps1)

## Terraform (Planned)
- Module: `infra/day05/terraform/modules/storage/{main.tf,variables.tf,outputs.tf}`
- Env: `infra/day05/terraform/envs/dev/{providers.tf,versions.tf,backend.tf,main.tf}`
- Use Portal **Export template → Terraform** as a starter, then refactor to:
  - `azurerm_storage_account`, `azurerm_private_endpoint`, `azurerm_private_dns_zone_group`
  - `azurerm_monitor_diagnostic_setting`, `azurerm_role_assignment`
  - Data sources for LAW, VNet/Subnet, UAMI

## Validation
- From VM (Day04):
  - DNS: `nslookup stday05weu.blob.core.windows.net` ⇒ private IP (e.g., 10.10.x.x)
  - Access: use `AzCopy` with `--identity` or Azure CLI with `--auth-mode login`
- Container check:
  - Create `day05test`, upload `day05.txt`, list blobs

## Security Notes
- Keep public network disabled
- Prefer RBAC over Shared Key
- Restrict PE subnet NSG to VNet-only traffic on TCP/443
- Monitor with LAW dashboards/alerts

## Commit
`day05: add secure storage baseline (private endpoint + RBAC)`
