# Define VM extensions to install ADDS and join member and wss
# Promote VM to be a Domain Controller
# based on https://github.com/ghostinthewires/terraform-azurerm-promote-dc

locals { 
  import_command       = "Import-Module ADDSDeployment"
  password_command     = "$password = ConvertTo-SecureString ${var.safemode_password} -AsPlainText -Force"
  install_ad_command   = "Add-WindowsFeature -name ad-domain-services -IncludeManagementTools"
  configure_ad_command = "Install-ADDSForest -CreateDnsDelegation:$false -DomainMode Win2012R2 -DomainName ${var.active_directory_domain} -DomainNetbiosName ${var.active_directory_netbios_name} -ForestMode Win2012R2 -InstallDns:$true -SafeModeAdministratorPassword $password -Force:$true"
  shutdown_command     = "shutdown -r -t 10"
  dns_fwd_command      = "Set-DnsServerForwarder -IPAddress 1.1.1.1 -UseRootHint $true -Timeout 3 -EnableReordering $true"
  powershell_command   = "${local.disable_fw}; ${local.import_command}; ${local.password_command}; ${local.install_ad_command}; ${local.configure_ad_command}; ${local.dns_fwd_command}; ${local.shutdown_command}; ${local.exit_code_hack}"
  
  exit_code_hack       = "exit 0"

  disable_fw          = "Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False"
  powershell_command_disable_fw   = "${local.disable_fw}; ${local.exit_code_hack}"
}

resource "azurerm_virtual_machine_extension" "create-active-directory-forest" {
  name                 = "create-active-directory-forest"
  virtual_machine_id   = azurerm_windows_virtual_machine.windows_vm_domaincontroller.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell.exe -Command \"${local.powershell_command}\""
    }
SETTINGS
}