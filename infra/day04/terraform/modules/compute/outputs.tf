output "uami_id" { value = azurerm_user_assigned_identity.uami.id }
output "vm_id"   { value = azurerm_linux_virtual_machine.vm.id }
output "nic_id"  { value = azurerm_network_interface.nic.id }
