resource "azurerm_resource_group" "AVD-network" {
  name     = "${var.rg_net_group}"
  location = "${var.region}"
}

resource "azurerm_proximity_placement_group" "avd_proximity_placement_group" {
  name                = "AVD_PROXIMITY_PLACEMENT_GROUP"
  location            = azurerm_resource_group.AVD-network.location
  resource_group_name = azurerm_resource_group.AVD-network.name

  tags = {
    environment = "Production"
  }
}

resource "azurerm_network_security_group" "net_avd_vm_nsg" {
  name                = "AVD_NETWORK_NSG"
  location            = azurerm_resource_group.AVD-network.location
  resource_group_name = azurerm_resource_group.AVD-network.name
}

resource "azurerm_network_ddos_protection_plan" "net_avd_vm_ddos" {
  name                = "DDOS_PLAN_1"
  location            = azurerm_resource_group.AVD-network.location
  resource_group_name = azurerm_resource_group.AVD-network.name
}

resource "azurerm_virtual_network" "net_avd_vm" {
  name                = "virtualNetwork1"
  location            = azurerm_resource_group.AVD-network.location
  resource_group_name = azurerm_resource_group.AVD-network.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  ddos_protection_plan {
    id     = azurerm_network_ddos_protection_plan.net_avd_vm_ddos.id
    enable = true
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_subnet" "avd_subnet_1" {
  name           = "avd_subnet_1"
  resource_group_name = azurerm_resource_group.AVD-network.name
  virtual_network_name = azurerm_virtual_network.net_avd_vm.name
#  security_group = azurerm_network_security_group.net_avd_vm_nsg.id
  address_prefixes     = ["10.0.3.0/24"]
}


data "azurerm_subnet" "current_ad_subnet" {
  name                 = var.ad_subnet_name
  virtual_network_name = var.ad_virtual_network_name
  resource_group_name  = var.ad_resource_group_name
}

