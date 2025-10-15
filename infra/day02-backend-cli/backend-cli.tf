terraform {
  backend "azurerm" {
    resource_group_name  = "rg-day02-backend-cli"
    storage_account_name = "stday02tfstatecli"
    container_name       = "tfstate"
    key                  = "infra/day02-cli/terraform.tfstate"
    use_azuread_auth     = true
  }
}
provider "azurerm" {
  features {}
}
