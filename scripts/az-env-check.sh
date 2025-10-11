#!/usr/bin/env bash
# Purpose: Minimal environment check for Azure CLI usage
# Notes:
# - Uses long options for clarity
# - Exits non-zero on failures to be CI-friendly

set -euo pipefail

info() { printf '%s\n' "$*"; }

# 1) Ensure Azure CLI is installed
if ! command -v az >/dev/null 2>&1; then
  info "Azure CLI (az) is not installed or not in PATH."
  info "Install: https://learn.microsoft.com/cli/azure/install-azure-cli"
  exit 127
fi

# 2) Show Azure CLI version (no jq required)
info "Azure CLI version:"
az version --only-show-errors --output table || {
  info "Failed to read Azure CLI version."; exit 1;
}

# 3) Ensure the user is logged in
if ! az account show --only-show-errors --output none >/dev/null 2>&1; then
  info "You are not logged in. Run: az login"
  exit 1
fi

# 4) Print current subscription summary
info "Current subscription:"
az account show \
  --only-show-errors \
  --query "{name:name, id:id, tenantId:tenantId}" \
  --output table

info "Environment check completed."
