#!/bin/bash
# ============================================================
# File: scripts/day04-compute-az.sh
# Purpose: Day04 - Secure VM baseline with UAMI + DCR association
# Notes:
# - Replace VNet/Subnet names if different from Day03 (vnet03weu/subnet03weu).
# - Assumes DCR "dcr-vm04" and LAW "law-dev-weu" already exist (created via Portal).
# - Uses long options only. Secure-by-default (no Public IP).
# ============================================================

set -euo pipefail

# 1) Create RG
az group create \
  --name rg-day04-compute \
  --location westeurope

# 2) Create User-Assigned Managed Identity
az identity create \
  --name uami04weu \
  --resource-group rg-day04-compute \
  --location westeurope

# 3) Create NIC without Public IP (attach to Day03 VNet/Subnet)
az network nic create \
  --name nic04weu \
  --resource-group rg-day04-compute \
  --vnet-name vnet03weu \
  --subnet subnet03weu \
  --ip-forwarding false

# 4) Create VM (no Public IP, SSH key auth, agent enabled)
az vm create \
  --name vm04weu \
  --resource-group rg-day04-compute \
  --image Ubuntu2204 \
  --size Standard_B2s \
  --admin-username azureuser \
  --ssh-key-values "<your_ssh_public_key>" \
  --nics nic04weu \
  --assign-identity "" \
  --enable-agent true

# 5) Attach only the User-Assigned identity
UAMI_ID=$(az identity show \
  --name uami04weu \
  --resource-group rg-day04-compute \
  --query id --output tsv)

az vm identity assign \
  --name vm04weu \
  --resource-group rg-day04-compute \
  --identities "$UAMI_ID"

# 6) Least-privilege RBAC (Reader on RG for start)
az role assignment create \
  --assignee-object-id $(az identity show --name uami04weu --resource-group rg-day04-compute --query principalId -o tsv) \
  --role "Reader" \
  --scope $(az group show --name rg-day04-compute --query id -o tsv)

# 7) Associate existing DCR to VM (AMA path)
VM_ID=$(az vm show --name vm04weu --resource-group rg-day04-compute --query id -o tsv)
DCR_ID=$(az monitor data-collection rule show --name dcr-vm04 --resource-group rg-day04-compute --query id -o tsv)

az monitor data-collection rule association create \
  --name dcrassoc-vm04 \
  --resource "$VM_ID" \
  --data-collection-rule-id "$DCR_ID"
