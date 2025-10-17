// main.tf — environment: dev

module "monitoring" {
  source              = "../../modules/monitoring"
  resource_group_name = "rg-dev-network-monitor-weu"
  location            = "westeurope"
  workspace_name      = "law-dev-weu"
  retention_in_days   = 30
  sku                 = "PerGB2018"
}

module "network" {
  source              = "../../modules/network"
  resource_group_name = "rg-dev-network-monitor-weu"
  location            = "westeurope"
  vnet_name           = "vnet-dev-weu"
  address_space       = ["10.10.0.0/16"]
  nsg_name            = "nsg-dev-web"
  workspace_id        = module.monitoring.workspace_id

  subnets = {
    "snet-dev-web"  = { address_prefix = "10.10.1.0/24" }
    "snet-dev-app"  = { address_prefix = "10.10.2.0/24" }
    "snet-dev-data" = { address_prefix = "10.10.3.0/24" }
    "snet-dev-mgmt" = { address_prefix = "10.10.10.0/24" }
  }
}
