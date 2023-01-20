# Join VM to Active Directory Domain
# based on https://github.com/ghostinthewires/terraform-azurerm-ad-join

resource "azurerm_virtual_machine_extension" "join-domain-dcs" {
  count = var.extra_dc_node_count
  virtual_machine_id   = azurerm_windows_virtual_machine.additional_windows_vm_domaincontroller[count.index].id
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

resource "azurerm_virtual_machine_extension" "disable_fw_dcs" {
  depends_on = [azurerm_virtual_machine_extension.join-domain]
  count = var.extra_dc_node_count
  virtual_machine_id   = azurerm_windows_virtual_machine.additional_windows_vm_domaincontroller[count.index].id
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