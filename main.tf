# Originally based on the work by Christoph Falta in https://github.com/cfalta/activedirectory-lab

# Using the Azure Provider
provider "azurerm" {
  features {}
}

# resource group
resource "azurerm_resource_group" "main_rg" {
  name     = "AD-LAB-RG"
  location = var.node_location_dc
  tags = var.tags
}