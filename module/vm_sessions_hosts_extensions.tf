

output "hostpool_token" {
  value = azurerm_virtual_desktop_host_pool.AVD-HOSTPOOL.registration_info[0].token
  sensitive = true
#  depends_on = [azurerm_virtual_desktop_host_pool.AVD-HOSTPOOL]
}


resource "azurerm_virtual_machine_extension" "domainJoin" {
  count                      = "${var.domain_joined ? var.rdsh_count : 0}"
  name                       = "${var.vm_prefix}-${count.index +1}-domainJoin"
  virtual_machine_id         = "${azurerm_virtual_machine.main.*.id[count.index]}"
  publisher                  = "Microsoft.Compute"
  type                       = "JsonADDomainExtension"
  type_handler_version       = "1.3"
  auto_upgrade_minor_version = true

  lifecycle {
    ignore_changes = [
       settings,
       protected_settings,
    ]
  }

  settings = <<SETTINGS
    {
        "Name": "${var.domain_name}",
        "User": "${var.domain_user_upn}@${var.domain_name}",
        "Restart": "true",
        "Options": "3"
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
  {
         "Password": "${var.domain_password}"
  }
PROTECTED_SETTINGS

#  tags {
#    BUC             = "${var.tagBUC}"
#    SupportGroup    = "${var.tagSupportGroup}"
#    AppGroupEmail   = "${var.tagAppGroupEmail}"
#    EnvironmentType = "${var.tagEnvironmentType}"
#    CustomerCRMID   = "${var.tagCustomerCRMID}"
#  }
}


resource "azurerm_virtual_machine_extension" "custom_script_extensions2" {
  count                = "${var.extension_custom_script ? var.rdsh_count : 0}"
  name                 = "${var.vm_prefix}${count.index +1}-custom_script_extensions"
  virtual_machine_id   = "${azurerm_virtual_machine.main.*.id[count.index]}"
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
#  depends_on           = [azurerm_virtual_machine_extension.domainJoin]
  type_handler_version = "1.2"
  auto_upgrade_minor_version = true

  lifecycle {
    ignore_changes = [
      settings,
    ]
  }

  settings = <<SETTINGS
    {
      "fileUris": ["${join("\",\"", var.extensions_custom_script_fileuris)}"],
      "commandToExecute": "${var.extensions_custom_command} -RegistrationToken ${azurerm_virtual_desktop_host_pool.AVD-HOSTPOOL.registration_info[0].token} -FslogixEnable ${var.fslogix_enable} -FslogixShare ${azurerm_storage_share.FSShare.url} -DuoEnable ${var.duo_enable} -DuoIKEY ${var.duo_ikey} -DuoSKEY ${var.duo_skey} -DuoHostAPI ${var.duo_host_api} "
    }
SETTINGS



#  tags {
#    BUC             = "${var.tagBUC}"
#    SupportGroup    = "${var.tagSupportGroup}"
#    AppGroupEmail   = "${var.tagAppGroupEmail}"
#    EnvironmentType = "${var.tagEnvironmentType}"
#    CustomerCRMID   = "${var.tagCustomerCRMID}"
#  }
}