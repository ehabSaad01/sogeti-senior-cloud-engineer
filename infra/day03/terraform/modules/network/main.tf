// main.tf — network module logic
// Creates VNet, subnets, NSG, and diagnostics integration.

resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
}

resource "azurerm_subnet" "this" {
  for_each             = var.subnets
  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [each.value.address_prefix]
}

resource "azurerm_network_security_group" "this" {
  name                = var.nsg_name
  location            = var.location
  resource_group_name = var.resource_group_name
}

// Associate NSG with the WEB subnet only (example)
resource "azurerm_subnet_network_security_group_association" "assoc_web" {
  subnet_id                 = azurerm_subnet.this["snet-dev-web"].id
  network_security_group_id = azurerm_network_security_group.this.id
}

// Diagnostics for VNet → LAW
resource "azurerm_monitor_diagnostic_setting" "vnet_diag" {
  name                       = "ds-vnet-to-law"
  target_resource_id         = azurerm_virtual_network.this.id
  log_analytics_workspace_id = var.workspace_id

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

// Diagnostics for NSG → LAW (logs only)
resource "azurerm_monitor_diagnostic_setting" "nsg_diag" {
  name                       = "ds-nsg-to-law"
  target_resource_id         = azurerm_network_security_group.this.id
  log_analytics_workspace_id = var.workspace_id

  enabled_log {
    category = "NetworkSecurityGroupEvent"
  }

  enabled_log {
    category = "NetworkSecurityGroupRuleCounter"
  }
}
