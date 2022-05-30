# Create Vault
data "azurerm_client_config" "current" {}

output "object_id" {
  value = data.azurerm_client_config.current
}

resource "azurerm_key_vault" "avd_vault" {
  name                       = "AVD-VM"
  location                   = azurerm_resource_group.RG-AVD-HOSTPOOL.location
  resource_group_name        = azurerm_resource_group.RG-AVD-HOSTPOOL.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  enabled_for_disk_encryption = true
  enable_rbac_authorization   = true
  enabled_for_deployment      = true
  purge_protection_enabled    = false
}

resource "azurerm_key_vault_access_policy" "avd_vault_sp_access" {
  key_vault_id = azurerm_key_vault.avd_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "get", "list", "update", "create", "import", "delete", "recover", "backup", "restore",
  ]

  secret_permissions = [
    "get", "list", "delete", "recover", "backup", "restore", "set",
  ]

  certificate_permissions = [
    "get", "list", "update", "create", "import", "delete", "recover", "backup", "restore", "deleteissuers", "getissuers", "listissuers", "managecontacts", "manageissuers", "setissuers",
  ]
}

resource "azurerm_role_assignment" "role-secret-officer" {
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
  scope                = azurerm_key_vault.avd_vault.id
}

