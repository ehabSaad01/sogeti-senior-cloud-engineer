// variables.tf — network module inputs
variable "resource_group_name" {
  description = "Target Resource Group for the virtual network."
  type        = string
}

variable "location" {
  description = "Azure region for the virtual network."
  type        = string
}

variable "vnet_name" {
  description = "Name of the Virtual Network."
  type        = string
}

variable "address_space" {
  description = "Address space for the Virtual Network."
  type        = list(string)
}

variable "subnets" {
  description = "Map of subnets with name and address_prefix."
  type = map(object({
    address_prefix = string
  }))
}

variable "nsg_name" {
  description = "Name of the Network Security Group."
  type        = string
}

variable "workspace_id" {
  description = "ID of the Log Analytics Workspace for diagnostics."
  type        = string
}
