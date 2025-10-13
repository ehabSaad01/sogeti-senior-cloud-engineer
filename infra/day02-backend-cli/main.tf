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

resource "azurerm_resource_group" "tfcli" {
  name     = "rg-day02-tfcli"
  location = "westeurope"
  tags = {
    project = "sogeti-ce"
    origin  = "terraform"
    track   = "cli"
  }
}
