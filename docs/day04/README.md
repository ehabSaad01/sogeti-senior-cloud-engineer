# Day04 — Compute Baseline (VM + UAMI + AMA/DCR)

## Objective
Create a secure Linux VM (no Public IP), attach a User-Assigned Managed Identity, and route guest data to Log Analytics via Azure Monitor Agent and a Data Collection Rule.

## Architecture
- VM: `vm04weu` inside Day03 VNet/Subnet.
- Identity: `uami04weu` (User-Assigned), RBAC: Reader at RG scope (start).
- Monitoring: AMA + DCR `dcr-vm04` to LAW `law-dev-weu`.

## Files
- `scripts/day04-compute-az.sh` — Azure CLI (long options, secure-by-default).
- `scripts/day04-compute-ps.ps1` — PowerShell Az equivalent.
- This README.

## Usage (CLI)
```bash
bash scripts/day04-compute-az.sh


Usage (PowerShell)
powershell
Copy code
pwsh -File scripts/day04-compute-ps.ps1
Notes
Replace VNet/Subnet names if they differ from Day03.

SSH only. Consider Bastion or JIT for administrative access.

Increase RBAC only when needed (least privilege).
