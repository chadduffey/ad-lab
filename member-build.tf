##########################################################
# Create base infrastructure for member servers
##########################################################

# network interface - member server
resource "azurerm_network_interface" "member_nic" {
  count = var.member_node_count
  name                = "${var.member_resource_prefix}-${format("%02d", count.index)}-NIC"
  location            = azurerm_resource_group.main_rg.location
  resource_group_name = azurerm_resource_group.main_rg.name
  tags = var.tags

  ip_configuration {
    name      = "internal"
    subnet_id = azurerm_subnet.main_subnet.id
    #private_ip_address_allocation = "Dynamic"
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.node_address_prefix, 100+count.index)
    #public_ip_address_id          = element(azurerm_public_ip.member_public_ip.*.id, count.index)
  }
}

# VM object for member server - will create X server based on the member_node_count variable in terraform.tfvars
resource "azurerm_windows_virtual_machine" "member_vm" {
  count = var.member_node_count
  name  = "${var.member_resource_prefix}-${format("%02d", count.index)}"
  #name = "${var.member_resource_prefix}-VM"
  location              = azurerm_resource_group.main_rg.location
  resource_group_name   = azurerm_resource_group.main_rg.name
  network_interface_ids = [element(azurerm_network_interface.member_nic.*.id, count.index)]
  size                  = var.vmsize_member
  admin_username        = var.adminuser
  admin_password        = var.adminpassword

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
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