terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.116.0"
    }
  }
}

# Root module will supply the provider. No provider block here.

data "azurerm_resource_group" "rg" {
  name = var.rg_name
}

data "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = var.vnet_rg
}

data "azurerm_subnet" "snet" {
  name                 = var.subnet_name
  resource_group_name  = var.vnet_rg
  virtual_network_name = data.azurerm_virtual_network.vnet.name
}

data "azurerm_monitor_data_collection_rule" "dcr" {
  name                = var.dcr_name
  resource_group_name = var.dcr_rg
}

resource "azurerm_user_assigned_identity" "uami" {
  name                = var.uami_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.vm_name}-nic"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = data.azurerm_subnet.snet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                            = var.vm_name
  resource_group_name             = data.azurerm_resource_group.rg.name
  location                        = var.location
  size                            = var.vm_size
  admin_username                  = var.linux_username
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.nic.id]

  admin_ssh_key {
    username   = var.linux_username
    public_key = var.ssh_pub_key
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.uami.id]
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

resource "azurerm_monitor_data_collection_rule_association" "assoc" {
  name                    = "dcrassoc-${var.vm_name}"
  target_resource_id      = azurerm_linux_virtual_machine.vm.id
  data_collection_rule_id = data.azurerm_monitor_data_collection_rule.dcr.id
}

resource "azurerm_role_assignment" "uami_reader_rg" {
  scope                = data.azurerm_resource_group.rg.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.uami.principal_id
}
