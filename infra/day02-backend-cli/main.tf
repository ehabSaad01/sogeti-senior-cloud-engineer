provider "azurerm" {
  features {}
}

# Resource group reference
data "azurerm_resource_group" "backend" {
  name = "rg-day02-backend-cli"
}

# Create a simple User Assigned Managed Identity for test
resource "azurerm_user_assigned_identity" "test_identity" {
  name                = "uami-day02-test-cli"
  location            = data.azurerm_resource_group.backend.location
  resource_group_name = data.azurerm_resource_group.backend.name
}

output "test_identity_id" {
  value = azurerm_user_assigned_identity.test_identity.id
}
