// variables.tf — monitoring module inputs

variable "resource_group_name" {
  description = "Target Resource Group for the Log Analytics workspace."
  type        = string
}

variable "location" {
  description = "Azure region for the workspace, e.g., westeurope."
  type        = string
}

variable "workspace_name" {
  description = "Name of the Log Analytics workspace."
  type        = string
}

variable "retention_in_days" {
  description = "Data retention period to control cost (PerGB2018 requires >= 30)."
  type        = number
  default     = 30
}

variable "sku" {
  description = "Workspace SKU. Use PerGB2018 for pay-as-you-go."
  type        = string
  default     = "PerGB2018"
}
