## Create a Resource Group for Storage
resource "azurerm_resource_group" "rg_storage" {
  location = "${var.region}"
  name     = "${var.rg_fslogix}"
}

# generate a random string (consisting of four characters)
# https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string
resource "random_string" "random" {
  length  = 4
  upper   = false
  special = false
}

## Azure Storage Accounts requires a globally unique names
## https://docs.microsoft.com/en-us/azure/storage/common/storage-account-overview
## Create a File Storage Account
resource "azurerm_storage_account" "storage" {
  name                     = "stor${random_string.random.id}"
  resource_group_name      = azurerm_resource_group.rg_storage.name
  location                 = azurerm_resource_group.rg_storage.location
  account_tier             = "Premium"
  account_replication_type = "LRS"
  account_kind             = "FileStorage"
#  shared_access_key_enabled = false
#  storage_use_azuread      = true
#  network_rules {
#    default_action             = "Allow"
##    ip_rules                   = ["100.0.0.1"]
#    virtual_network_subnet_ids = [azurerm_subnet.avd_subnet_1.id]
#  }
}



#  dynamic "azure_files_authentication" {
#    content {
#      directory_type = storage.directory_type
#
#      dynamic "active_directory" {
#        for_each = lookup(var.storage_account.azure_files_authentication, "active_directory", false) == false ? [] : [1]
#
#        content {
#          storage_sid         = var.storage_account.azure_files_authentication.active_directory.storage_sid
#          domain_name         = var.storage_account.azure_files_authentication.active_directory.domain_name
#          domain_sid          = var.storage_account.azure_files_authentication.active_directory.domain_sid
#          domain_guid         = var.storage_account.azure_files_authentication.active_directory.domain_guid
#          forest_name         = var.storage_account.azure_files_authentication.active_directory.forest_name
#          netbios_domain_name = var.storage_account.azure_files_authentication.active_directory.netbios_domain_name
#        }
#      }
#    }
#  }
#}

resource "azurerm_storage_share" "FSShare" {
  name                 = "fslogix"
  storage_account_name = azurerm_storage_account.storage.name
  depends_on           = [azurerm_storage_account.storage]

}

## Azure built-in roles
## https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
data "azurerm_role_definition" "storage_role" {
  name = "Storage File Data SMB Share Contributor"
}

data "azurerm_role_definition" "storage_elevated_role" {
  name = "Storage File Data SMB Share Elevated Contributor"
}

data "azurerm_role_definition" "role" { # access an existing built-in role
  name = "Desktop Virtualization User"
}

resource "azuread_group" "aad_group" {
  display_name = var.aad_group_name
  security_enabled = true
}

data "azuread_user" "aad_user" {
  for_each            = toset(var.avd_users)
  user_principal_name = format("%s", each.key)
}

resource "azuread_group_member" "aad_group_member" {
  for_each         = data.azuread_user.aad_user
  group_object_id  = azuread_group.aad_group.id
  member_object_id = each.value["id"]
}

resource "azurerm_role_assignment" "af_role" {
  scope              = azurerm_storage_account.storage.id
  role_definition_id = data.azurerm_role_definition.role.id
  principal_id       = azuread_group.aad_group.id
}

resource "azurerm_role_assignment" "af_role_fslogix_elevated" {
  scope              = azurerm_storage_account.storage.id
  role_definition_id = data.azurerm_role_definition.storage_role.id
  principal_id       = azuread_group.aad_group.id
}

resource "azurerm_role_assignment" "af_role_fslogix" {
  scope              = azurerm_storage_account.storage.id
  role_definition_id = data.azurerm_role_definition.storage_elevated_role.id
  principal_id       = azuread_group.aad_group.id
}

