#!/usr/bin/env bash
set -euo pipefail

# Day02 Backend & Key Vault (CLI track)
# All commands use long options and inline values. No variables.

# 1) Resource Group (CLI)
az group create --name rg-day02-backend-cli --location westeurope --tags project=sogeti-ce env=shared origin=cli

# 2) Storage Account for Terraform state
az storage account create --name stday02backendcliweu --resource-group rg-day02-backend-cli --location westeurope --sku Standard_LRS --kind StorageV2 --min-tls-version TLS1_2 --allow-blob-public-access false --public-network-access Enabled --tags project=sogeti-ce env=shared origin=cli

# 3) Data protection: versioning + soft delete
az storage account blob-service-properties update \
  --resource-group rg-day02-backend-cli \
  --account-name stday02backendcliweu \
  --enable-versioning true \
  --enable-delete-retention true \
  --delete-retention-days 90 \
  --enable-container-delete-retention true \
  --container-delete-retention-days 90

# 4) Blob container for Terraform state (management plane)
az storage container-rm create --resource-group rg-day02-backend-cli --storage-account stday02backendcliweu --name tfstate-cli --public-access off

# 5) Key Vault (RBAC mode)
az keyvault create --name kvday02backendcliweu --resource-group rg-day02-backend-cli --location westeurope --enable-rbac-authorization true --retention-days 90 --enable-purge-protection true --public-network-access Enabled --sku standard --tags project=sogeti-ce env=shared origin=cli

# 6) App registration for GitHub OIDC
az ad app create --display-name gh-oidc-day02-cli --sign-in-audience AzureADMyOrg

# 7) Service principal for the app
az ad sp create --id $(az ad app list --display-name gh-oidc-day02-cli --query "[0].appId" --output tsv)

# 8) Federated credential: GitHub repo main branch
az ad app federated-credential create \
  --id $(az ad app list --display-name gh-oidc-day02-cli --query "[0].appId" --output tsv) \
  --parameters '{
    "name": "gh-main-oidc-cli",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:ehabSaad01/sogeti-senior-cloud-engineer:ref:refs/heads/main",
    "audiences": ["api://AzureADTokenExchange"]
  }'

# 9) RBAC: Contributor on RG scope
az role assignment create \
  --role "Contributor" \
  --assignee $(az ad app list --display-name gh-oidc-day02-cli --query "[0].appId" --output tsv) \
  --scope /subscriptions/$(az account show --query id --output tsv)/resourceGroups/rg-day02-backend-cli

# 10) RBAC (data): Storage Blob Data Contributor on storage
az role assignment create \
  --role "Storage Blob Data Contributor" \
  --assignee $(az ad app list --display-name gh-oidc-day02-cli --query "[0].appId" --output tsv) \
  --scope /subscriptions/$(az account show --query id --output tsv)/resourceGroups/rg-day02-backend-cli/providers/Microsoft.Storage/storageAccounts/stday02backendcliweu

# 11) RBAC (data): Key Vault Secrets User for the app
az role assignment create \
  --role "Key Vault Secrets User" \
  --assignee $(az ad app list --display-name gh-oidc-day02-cli --query "[0].appId" --output tsv) \
  --scope /subscriptions/$(az account show --query id --output tsv)/resourceGroups/rg-day02-backend-cli/providers/Microsoft.KeyVault/vaults/kvday02backendcliweu

# 12) RBAC (operator): Secrets Officer for the signed-in user to create secrets
az role assignment create \
  --role "Key Vault Secrets Officer" \
  --assignee $(az ad signed-in-user show --query id --output tsv) \
  --scope /subscriptions/$(az account show --query id --output tsv)/resourceGroups/rg-day02-backend-cli/providers/Microsoft.KeyVault/vaults/kvday02backendcliweu

# 13) Seed secret for testing CI reads
az keyvault secret set --vault-name kvday02backendcliweu --name app-conn-string --value Dummy-Conn-String-For-CI
