terraform {
  backend "azurerm" {
    resource_group_name  = "rg-day02-backend-cli"
    storage_account_name = "stday02backendcliweu"
    container_name       = "tfstate-cli"
    key                  = "infra/primary.tfstate"
  }
}
