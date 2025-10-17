// versions.tf — pin Terraform and AzureRM provider

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100" // stable 3.x line
    }
  }
}

provider "azurerm" {
  features {}
}
