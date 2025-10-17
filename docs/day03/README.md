# Day03 — Network + Monitoring (dev)

## Objective
Deploy baseline **Network** (VNet, Subnets, NSG) and **Monitoring** (Log Analytics, Diagnostics) for **dev** using modular Terraform.

## Architecture (dev)
- **RG**: `rg-dev-network-monitor-weu` (existing)
- **LAW**: `law-dev-weu` (PerGB2018, retention 30d)
- **VNet**: `vnet-dev-weu` — `10.10.0.0/16`
  - Subnets:
    - `snet-dev-web`  → `10.10.1.0/24` (NSG attached)
    - `snet-dev-app`  → `10.10.2.0/24`
    - `snet-dev-data` → `10.10.3.0/24`
    - `snet-dev-mgmt` → `10.10.10.0/24`
- **NSG**: `nsg-dev-web`
- **Diagnostics**:
  - VNet → LAW: metrics enabled
  - NSG → LAW: logs only (`NetworkSecurityGroupEvent`, `NetworkSecurityGroupRuleCounter`)

## Terraform layout
infra/day03/terraform/
modules/
monitoring/ { variables.tf, main.tf, outputs.tf }
network/ { variables.tf, main.tf, outputs.tf }
envs/dev/
{ versions.tf, main.tf, outputs.tf }
docs/day03/README.md

markdown
Copy code

## Modules
**monitoring**
- Creates `azurerm_log_analytics_workspace`
- Inputs: `resource_group_name`, `location`, `workspace_name`, `sku=PerGB2018`, `retention_in_days=30`
- Outputs: `workspace_id`, `workspace_name`

**network**
- Creates `azurerm_virtual_network`, `azurerm_subnet` (for-each), `azurerm_network_security_group`
- Associates NSG to `snet-dev-web`
- Adds `azurerm_monitor_diagnostic_setting` for VNet (metrics) and NSG (logs only)
- Inputs: RG, location, `vnet_name`, `address_space`, `subnets{}`, `nsg_name`, `workspace_id`
- Outputs: `vnet_id`, `nsg_id`, `subnet_ids{}`

## Dev environment wiring
- `envs/dev/main.tf` calls both modules and passes values for **dev**.
- `versions.tf` pins Terraform and AzureRM provider.
- `outputs.tf` prints `workspace_id`, `vnet_id`, `subnet_ids`.

## Run (from `infra/day03/terraform/envs/dev`)
```bash
terraform init -reconfigure -backend-config="../../backend.hcl"
terraform plan -out=day03-dev.plan
terraform apply "day03-dev.plan"
terraform output
Notes
Retention: PerGB2018 requires ≥ 30 days.

NSG metrics are not supported → logs only.

Imports used when resources were created in Portal:

LAW, NSG, and Diagnostics where applicable.

Next steps (Day04 preview)
Add compute baseline (VM), User-Assigned Managed Identity, and NSG rules for SSH/HTTP minimal.

Optional: UDRs and alert rules (KQL + action groups).
