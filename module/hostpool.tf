# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
#terraform {
#  required_providers {
#    azurerm = {
#      source  = "hashicorp/azurerm"
#      version = "=2.91.0"
#    }
#  }
#}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  tenant_id = var.tenant_id
  subscription_id = var.subscription_id
#  client_id = "b0edca60-b84d-4e34-a607-77191770decd"
#  client_secret = "SUw~S964SZdLwIYG_psSYwwo9pRVOL5cnu"
}

# Create a resource group
resource "azurerm_resource_group" "RG-AVD-HOSTPOOL" {
  name     = "RG-US-AVD-HOSTPOOL-WEST"
  location = "${var.region}"
}

# Create time rotating params for AVD token
resource "time_rotating" "wvd_token" {
  rotation_days = 30
}

# Create HostPool
resource "azurerm_virtual_desktop_host_pool" "AVD-HOSTPOOL" {
  location            = azurerm_resource_group.RG-AVD-HOSTPOOL.location
  resource_group_name = azurerm_resource_group.RG-AVD-HOSTPOOL.name

  name                     = "${var.host_pool_name}"
  friendly_name            = "AVD HOSTOOL"
  validate_environment     = false
  start_vm_on_connect      = true
  custom_rdp_properties    = "domain:s:miatech.org;drivestoredirect:s:c\\:;audiomode:i:0;videoplaybackmode:i:1;redirectclipboard:i:1;redirectprinters:i:1;devicestoredirect:s:;redirectcomports:i:1;redirectsmartcards:i:0;usbdevicestoredirect:s:;enablecredsspsupport:i:1;use multimon:i:1;"
  description              = "Deploy from terraform HOSTPOOL"
  type                     = "Pooled"
  maximum_sessions_allowed = 10
  load_balancer_type       = "DepthFirst"

  registration_info {
    expiration_date = time_rotating.wvd_token.rotation_rfc3339
  }

  lifecycle {
    ignore_changes = [
      registration_info,
    ]
  }

}

# Create role for autostart VM
data "azurerm_subscription" "primary" {
}

data "azuread_client_config" "current" {}

data "azuread_application_published_app_ids" "well_known" {}

output "well_know_list" {
  value = data.azuread_application_published_app_ids.well_known.result
}

data "azuread_service_principal" "WindowsVirtualDesktop" {
  application_id = data.azuread_application_published_app_ids.well_known.result.WindowsVirtualDesktop
#  use_existing   = true
}

#data "azuread_application" "WindowsVirtualDesktop" {
#  display_name = "WindowsVirtualDesktop"
#}

resource "azurerm_role_definition" "WVDStartVMonConnect" {
  name               = "WVDAutoStartVMonConnect"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["Microsoft.Compute/virtualMachines/start/action", "Microsoft.Compute/virtualMachines/read", "Microsoft.Compute/virtualMachines/instanceView/read"]
    not_actions = []
  }

  assignable_scopes = [
    data.azurerm_subscription.primary.id,
  ]
}

resource "azurerm_role_assignment" "WVDStartVMonConnect" {
  scope              = data.azurerm_subscription.primary.id
  role_definition_id = azurerm_role_definition.WVDStartVMonConnect.role_definition_resource_id
  principal_id       = data.azuread_service_principal.WindowsVirtualDesktop.id
#  skip_service_principal_aad_check = true
}

#output "SpWindowsVirtualDesktopType" {
#  value = data.azuread_service_principal.WindowsVirtualDesktop.type
#}
#
#output "SpWindowsVirtualDesktopName" {
#  value = data.azuread_service_principal.WindowsVirtualDesktop.display_name
#}
#
#output "SpWindowsVirtualDesktopAppID" {
#  value = data.azuread_service_principal.WindowsVirtualDesktop.application_id
#}
#
#output "SpWindowsVirtualDesktopObjectID" {
#  value = data.azuread_service_principal.WindowsVirtualDesktop.object_id
#}


resource "azurerm_virtual_desktop_application_group" "AVD-MIATECH-1C-APP" {
  name                = "MIATECH-1C-APP"
  location            = azurerm_resource_group.RG-AVD-HOSTPOOL.location
  resource_group_name = azurerm_resource_group.RG-AVD-HOSTPOOL.name

  type          = "RemoteApp"
  host_pool_id  = azurerm_virtual_desktop_host_pool.AVD-HOSTPOOL.id
  friendly_name = "MIATECH 1C APP"
  description   = "MIATECH 1C APP Description"

}

resource "azurerm_virtual_desktop_application_group" "AVD-MIATECH-DEVOPS-APP" {
  name                = "MIATECH-DEVOPS-APP"
  location            = azurerm_resource_group.RG-AVD-HOSTPOOL.location
  resource_group_name = azurerm_resource_group.RG-AVD-HOSTPOOL.name

  type          = "RemoteApp"
  host_pool_id  = azurerm_virtual_desktop_host_pool.AVD-HOSTPOOL.id
  friendly_name = "MIATECH DEVOPS APP TEST"
  description   = "MIATECH DEVOPS APP Description"

}

# Example add application to the group
#resource "azurerm_virtual_desktop_application" "chrome" {
#  name                         = "googlechrome"
#  application_group_id         = azurerm_virtual_desktop_application_group.AVD-MIATECH-1C-APP.id
#  friendly_name                = "Google Chrome"
#  description                  = "Chromium based web browser"
#  path                         = "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe"
#  command_line_argument_policy = "DoNotAllow"
#  command_line_arguments       = "--incognito"
#  show_in_portal               = false
#  icon_path                    = "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe"
#  icon_index                   = 0
#}

resource "azurerm_virtual_desktop_workspace" "workspace" {
  name                = "workspace"
  location            = azurerm_resource_group.RG-AVD-HOSTPOOL.location
  resource_group_name = azurerm_resource_group.RG-AVD-HOSTPOOL.name
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "workspaceremoteapp" {
  workspace_id         = azurerm_virtual_desktop_workspace.workspace.id
  application_group_id = azurerm_virtual_desktop_application_group.AVD-MIATECH-1C-APP.id
}



