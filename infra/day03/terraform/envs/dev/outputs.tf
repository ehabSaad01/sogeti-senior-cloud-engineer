// outputs.tf — environment outputs

output "workspace_id" {
  description = "Log Analytics Workspace ID from monitoring module."
  value       = module.monitoring.workspace_id
}

output "vnet_id" {
  description = "Virtual Network ID from network module."
  value       = module.network.vnet_id
}

output "subnet_ids" {
  description = "Map of subnet names to their IDs from network module."
  value       = module.network.subnet_ids
}
