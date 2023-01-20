# virtual network within the resource group
resource "azurerm_virtual_network" "main_vnet" {
  name                = "main-vnet"
  resource_group_name = azurerm_resource_group.main_rg.name
  location            = var.node_location_dc
  address_space       = var.node_address_space
  dns_servers         = [cidrhost(var.node_address_prefix, 10)]
  tags = var.tags
}

# subnet within the virtual network
resource "azurerm_subnet" "main_subnet" {
  name                 = "${var.dc_resource_prefix}-main-subnet"
  resource_group_name  = azurerm_resource_group.main_rg.name
  virtual_network_name = azurerm_virtual_network.main_vnet.name
  address_prefixes       = [var.node_address_prefix]
}

# NSG
resource "azurerm_network_security_group" "main_nsg" {

  name                = "${var.dc_resource_prefix}-NSG"
  location            = azurerm_resource_group.main_rg.location
  resource_group_name = azurerm_resource_group.main_rg.name

  # Security rule can also be defined with resource azurerm_network_security_rule, here just defining it inline.
  security_rule {
    name                       = "Inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = var.tags

}

# Subnet and NSG association
resource "azurerm_subnet_network_security_group_association" "subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.main_subnet.id
  network_security_group_id = azurerm_network_security_group.main_nsg.id
}

# DNS configuration for subnet
resource "azurerm_virtual_network_dns_servers" "main_dns" {
  depends_on = [time_sleep.wait_300_seconds]
  virtual_network_id = azurerm_virtual_network.main_vnet.id
  dns_servers        = ["10.0.0.10"] # The first domain controller. 
}
