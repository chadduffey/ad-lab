# Additional Domain Controllers as needed

# network interface - additional DC's
resource "azurerm_network_interface" "dcs_nic" {
  count = var.extra_dc_node_count
  name                = "${var.extra_dc_resource_prefix}-${format("%02d", count.index)}-NIC"
  location            = azurerm_resource_group.main_rg.location
  resource_group_name = azurerm_resource_group.main_rg.name
  tags = var.tags

  ip_configuration {
    name      = "internal"
    subnet_id = azurerm_subnet.main_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.node_address_prefix, 15+count.index)
  }
}

#VM object for the DC
resource "azurerm_windows_virtual_machine" "additional_windows_vm_domaincontroller" {
  count = var.extra_dc_node_count
  name  = "${var.extra_dc_resource_prefix}-${format("%02d", count.index)}"
  location              = azurerm_resource_group.main_rg.location
  resource_group_name   = azurerm_resource_group.main_rg.name
  network_interface_ids = [element(azurerm_network_interface.dcs_nic.*.id, count.index)]
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

  depends_on = [time_sleep.wait_300_seconds]

  tags = var.tags
}

