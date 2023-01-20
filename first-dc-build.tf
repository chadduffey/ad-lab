##########################################################
# Create base infrastructure for DC's
##########################################################

# network interface - dc
resource "azurerm_network_interface" "dc_nic" {
  name = "${var.dc_resource_prefix}-DC-NIC"
  location            = azurerm_resource_group.main_rg.location
  resource_group_name = azurerm_resource_group.main_rg.name
  tags = var.tags

  ip_configuration {
    name      = "internal"
    subnet_id = azurerm_subnet.main_subnet.id
    #private_ip_address_allocation = "Dynamic"
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.node_address_prefix, 10)
  }
}

#VM object for the DC
resource "azurerm_windows_virtual_machine" "windows_vm_domaincontroller" {
  name  = "${var.dc_resource_prefix}"
  location              = azurerm_resource_group.main_rg.location
  resource_group_name   = azurerm_resource_group.main_rg.name
  network_interface_ids = [azurerm_network_interface.dc_nic.id]
  size                  = var.vmsize_dc
  admin_username        = var.domadminuser
  admin_password        = var.domadminpassword

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  tags = var.tags
}

resource "time_sleep" "wait_300_seconds" {
  create_duration = "300s"
  depends_on = [azurerm_virtual_machine_extension.create-active-directory-forest]
}