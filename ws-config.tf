# Join ws VMs to Active Directory Domain
# based on https://github.com/ghostinthewires/terraform-azurerm-ad-join

resource "azurerm_virtual_machine_extension" "join-domain-ws" {
  count = var.workstation_node_count
  virtual_machine_id   = azurerm_windows_virtual_machine.ws_vm[count.index].id
  name                 = "join-domain"
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"
  

  settings = <<SETTINGS
    {
        "Name": "${var.active_directory_domain}",
        "OUPath": "",
        "User": "${var.active_directory_domain}\\${var.domadminuser}",
        "Restart": "true",
        "Options": "3"
    }
SETTINGS

  protected_settings = <<SETTINGS
    {
        "Password": "${var.domadminpassword}"
    }
SETTINGS
}

resource "azurerm_virtual_machine_extension" "disable_fw_ws" {
  depends_on = [azurerm_virtual_machine_extension.join-domain-ws]
  count = var.workstation_node_count
  virtual_machine_id   = azurerm_windows_virtual_machine.ws_vm[count.index].id
  name                 = "disable_fw"
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell.exe -Command \"${local.powershell_command_disable_fw}\""
    }
SETTINGS
}