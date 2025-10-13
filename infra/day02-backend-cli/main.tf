terraform {
  required_version = ">= 1.7.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create a simple resource within the existing RG to match current RBAC (RG-level Contributor)
resource "azurerm_user_assigned_identity" "tfcli" {
  name                = "uai-day02-tfcli"
  resource_group_name = "rg-day02-backend-cli"
  location            = "westeurope"
  tags = {
    project = "sogeti-ce"
    origin  = "terraform"
    track   = "cli"
  }
}
