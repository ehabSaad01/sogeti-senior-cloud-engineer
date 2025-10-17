// outputs.tf — network module outputs
output "vnet_id" {
  description = "The ID of the Virtual Network."
  value       = azurerm_virtual_network.this.id
}

output "nsg_id" {
  description = "The ID of the Network Security Group."
  value       = azurerm_network_security_group.this.id
}

output "subnet_ids" {
  description = "Map of subnet names to their IDs."
  value       = { for k, s in azurerm_subnet.this : k => s.id }
}
