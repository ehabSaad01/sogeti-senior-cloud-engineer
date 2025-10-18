#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Day05 — Secure Storage Baseline (CLI, long options only)
# Goal: StorageV2 + Private Endpoint (blob) + Diagnostics + RBAC (UAMI) + Data Protection
# NOTE: Replace all <PLACEHOLDER> values before running.
# -----------------------------------------------------------------------------

# --- 0) Prereqs (login & subscription) ---
# az login
# az account set --subscription "<SUBSCRIPTION_ID>"

# --- 1) Resource Group (idempotent) ---
# Creates rg-day05-storage if it does not exist.
az group create \
  --name rg-day05-storage \
  --location westeurope \
  --tags env=dev day=05 security=rbac-first

# --- 2) Storage Account (secure-by-default) ---
# StorageV2, Standard LRS, TLS 1.2+, disable public & shared-key access.
az storage account create \
  --name stday05weu \
  --resource-group rg-day05-storage \
  --location westeurope \
  --sku Standard_LRS \
  --kind StorageV2 \
  --min-tls-version TLS1_2 \
  --default-action Deny

# Disable Shared Key auth and allow only Azure AD (RBAC) auth for data plane.
az storage account update \
  --name stday05weu \
  --resource-group rg-day05-storage \
  --enable-shared-key-access false \
  --allow-blob-public-access false \
  --https-only true

# --- 3) Data Protection (Blob Versioning + Soft delete) ---
az storage account blob-service-properties update \
  --account-name stday05weu \
  --resource-group rg-day05-storage \
  --enable-versioning true \
  --enable-delete-retention true \
  --delete-retention-days 14

az storage account blob-service-properties update \
  --account-name stday05weu \
  --resource-group rg-day05-storage \
  --container-delete-retention \
  --container-delete-retention-days 14

# --- 4) Diagnostics to Log Analytics (LAW) ---
# Sends metrics and logs to existing LAW: law-dev-weu
az monitor diagnostic-settings create \
  --name ds-stday05weu \
  --resource "$(az storage account show --name stday05weu --resource-group rg-day05-storage --query id --output tsv)" \
  --workspace "$(az monitor log-analytics workspace show --resource-group <RG_OF_LAW_DAY03> --workspace-name law-dev-weu --query id --output tsv)" \
  --logs '[{"category":"StorageRead","enabled":true},{"category":"StorageWrite","enabled":true},{"category":"StorageDelete","enabled":true},{"category":"Transaction","enabled":true}]' \
  --metrics '[{"category":"AllMetrics","enabled":true}]'

# --- 5) Private DNS Zone (privatelink.blob.core.windows.net) + Link to VNet Day03 ---
# Create zone if missing, then link the Day03 VNet.
az network private-dns zone create \
  --resource-group rg-day05-storage \
  --name privatelink.blob.core.windows.net

az network private-dns link vnet create \
  --resource-group rg-day05-storage \
  --zone-name privatelink.blob.core.windows.net \
  --name link-day03 \
  --virtual-network "/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RG_OF_VNET_DAY03>/providers/Microsoft.Network/virtualNetworks/<VNET_NAME_DAY03>" \
  --registration-enabled false

# --- 6) Private Endpoint (blob sub-resource) + DNS zone group ---
az network private-endpoint create \
  --name pe-stday05weu-blob \
  --resource-group rg-day05-storage \
  --location westeurope \
  --subnet "/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RG_OF_VNET_DAY03>/providers/Microsoft.Network/virtualNetworks/<VNET_NAME_DAY03>/subnets/<SUBNET_NAME_FOR_PE>" \
  --private-connection-resource-id "$(az storage account show --name stday05weu --resource-group rg-day05-storage --query id --output tsv)" \
  --group-ids blob \
  --connection-name pe-stday05weu-blob-conn

# Bind PE to Private DNS zone (zone group)
az network private-endpoint dns-zone-group create \
  --resource-group rg-day05-storage \
  --endpoint-name pe-stday05weu-blob \
  --name default \
  --private-dns-zone "privatelink.blob.core.windows.net" \
  --zone-name "privatelink.blob.core.windows.net"

# --- 7) RBAC: Grant UAMI data access on blobs ---
# Assign Storage Blob Data Contributor to uami04weu at the storage account scope.
az role assignment create \
  --assignee-object-id "$(az identity show --name uami04weu --resource-group <RG_OF_UAMI_DAY04> --query principalId --output tsv)" \
  --assignee-principal-type ServicePrincipal \
  --role "Storage Blob Data Contributor" \
  --scope "$(az storage account show --name stday05weu --resource-group rg-day05-storage --query id --output tsv)"

# --- 8) Minimal functional test (container create) [optional]
# Requires Azure CLI on a VM inside VNet with UAMI attached and:
# az login --identity --username <UAMI_CLIENT_ID>
# az storage container create --name day05test --account-name stday05weu --auth-mode login

# End of script.
