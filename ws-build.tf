##########################################################
# Create base infrastructure for workstations
##########################################################

# public ip - workstation
resource "azurerm_public_ip" "ws_public_ip" {
  count = var.workstation_node_count
  name  = "${var.ws_resource_prefix}-${format("%02d", count.index)}-PublicIP"
  location            = azurerm_resource_group.main_rg.location
  resource_group_name = azurerm_resource_group.main_rg.name
  allocation_method   = "Dynamic"
  tags = var.tags
}

# network interfaces - ws
resource "azurerm_network_interface" "ws_nic" {
  count = var.workstation_node_count
  name                = "${var.ws_resource_prefix}-${format("%02d", count.index)}-NIC"
  location            = azurerm_resource_group.main_rg.location
  resource_group_name = azurerm_resource_group.main_rg.name
  tags = var.tags

  ip_configuration {
    name      = "internal"
    subnet_id = azurerm_subnet.main_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.node_address_prefix, 200+count.index)
    public_ip_address_id          = element(azurerm_public_ip.ws_public_ip.*.id, count.index)
  }
}

# VM object for wss - will create X wss based on the workstation_node_count variable in terraform.tfvars
resource "azurerm_windows_virtual_machine" "ws_vm" {
  count = var.workstation_node_count
  name  = "${var.ws_resource_prefix}-${format("%02d", count.index)}"
  #name = "${var.ws_resource_prefix}-VM"
  location              = azurerm_resource_group.main_rg.location
  resource_group_name   = azurerm_resource_group.main_rg.name
  network_interface_ids = [element(azurerm_network_interface.ws_nic.*.id, count.index)]
  size                  = var.vmsize_ws
  admin_username        = var.adminuser
  admin_password        = var.adminpassword

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "19h2-pro-g2"
    version   = "latest"
  }

  depends_on = [time_sleep.wait_300_seconds]

  tags = var.tags
}