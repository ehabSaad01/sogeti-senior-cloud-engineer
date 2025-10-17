terraform {
  backend "azurerm" {}
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.116.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "compute_day04" {
  source         = "../../modules/compute"

  rg_name        = "rg-day04-compute"
  location       = "westeurope"

  vnet_rg        = "rg-dev-network-monitor-weu"
  vnet_name      = "vnet-dev-weu"
  subnet_name    = "snet-dev-app"

  vm_name        = "vm04weu"
  vm_size        = "Standard_B2s"
  linux_username = "azureuser"
  ssh_pub_key    = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKKs3puJPYFYPmQz//X469XT/OxCtvXv7Q/Gl97+hgHA day04-vm"

  uami_name      = "uami04weu"

  dcr_rg         = "rg-day04-compute"
  dcr_name       = "dcr-vm04"
}
