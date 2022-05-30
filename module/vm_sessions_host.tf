resource "azurerm_resource_group" "RG-AVD-VM" {
  name     = "${var.vm_resource_group_name}"
  location = "${var.region}"
}

#resource "random_password" "wvd-local-password" {
#  count            = "${var.rdsh_count}"
#  length           = 20
#  special          = true
#}

resource "random_string" "wvd-local-password" {
  count            = "${var.rdsh_count}"
  length           = 16
  special          = true
  min_special      = 2
  override_special = "*!@#?"
#  sensitive = true
}

#output "random_password_result" {
#  count            = "${var.rdsh_count}"
#  value = random_string.wvd-local-password.result
#  sensitive = true
#}

resource "azurerm_key_vault_secret" "save_password_vault" {
  count        = "${var.rdsh_count}"
  name         = "${var.vm_prefix}-${count.index + 1}-${var.local_admin_username}"
  value        = "${random_string.wvd-local-password[count.index].result}"
  key_vault_id = azurerm_key_vault.avd_vault.id

  depends_on = [azurerm_role_assignment.role-secret-officer]
}


resource "azurerm_network_interface" "rdsh" {
  count                     = "${var.rdsh_count}"
  name                      = "${var.vm_prefix}-${count.index +1}-nic"
  location                  = "${var.region}"
  resource_group_name       = azurerm_resource_group.RG-AVD-VM.name
#  network_security_group_id = "${length(var.nsg_id) > 0 ? var.nsg_id : ""}"
  enable_accelerated_networking = true
  dns_servers = [var.ad_vm_local_ip,"8.8.8.8"]

  ip_configuration {
    name                      = "${var.vm_prefix}-${count.index +1}-nic-01"
#    subnet_id                     = azurerm_subnet.avd_subnet_1.id
    subnet_id = data.azurerm_subnet.current_ad_subnet.id
    private_ip_address_allocation = "dynamic"
  }

#  tags {
#    BUC             = "${var.tagBUC}"
#    SupportGroup    = "${var.tagSupportGroup}"
#    AppGroupEmail   = "${var.tagAppGroupEmail}"
#    EnvironmentType = "${var.tagEnvironmentType}"
#    CustomerCRMID   = "${var.tagCustomerCRMID}"
#  }
}

resource "azurerm_virtual_machine" "main" {
  count                 = "${var.rdsh_count}"
  name                  = "${var.vm_prefix}-${count.index + 1}"
  location              = "${var.region}"
  resource_group_name   = "${var.vm_resource_group_name}"
  network_interface_ids = ["${azurerm_network_interface.rdsh.*.id[count.index]}"]
  vm_size               = "${var.vm_size}"
#  availability_set_id   = "${azurerm_availability_set.main.id}"
  proximity_placement_group_id = azurerm_proximity_placement_group.avd_proximity_placement_group.id

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    id        = "${var.vm_image_id != "" ? var.vm_image_id : ""}"
    publisher = "${var.vm_image_id == "" ? var.vm_publisher : ""}"
    offer     = "${var.vm_image_id == "" ? var.vm_offer : ""}"
    sku       = "${var.vm_image_id == "" ? var.vm_sku : ""}"
    version   = "${var.vm_image_id == "" ? var.vm_version : ""}"
  }

  storage_os_disk {
    name              = "${lower(var.vm_prefix)}-${count.index +1}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
    disk_size_gb      = "${var.vm_storage_os_disk_size}"
  }

  os_profile {
    computer_name  = "${var.vm_prefix}-${count.index +1}"
    admin_username = "${var.local_admin_username}"
    admin_password = "${random_string.wvd-local-password.*.result[count.index]}"
  }

  os_profile_windows_config {
    provision_vm_agent        = true
    enable_automatic_upgrades = true
    timezone                  = "${var.vm_timezone}"
  }

#  tags {
#    BUC               = "${var.tagBUC}"
#    SupportGroup      = "${var.tagSupportGroup}"
#    AppGroupEmail     = "${var.tagAppGroupEmail}"
#    EnvironmentType   = "${var.tagEnvironmentType}"
#    CustomerCRMID     = "${var.tagCustomerCRMID}"
#    ExpirationDate    = "${var.tagExpirationDate}"
#    Tier              = "${var.tagTier}"
#    MaintenanceWindow = "${var.tagMaintenanceWindow[count.index]}"
#    OnHours           = "${var.tagOnHours[count.index]}"
#    SolutionCentralID = "${var.tagSolutionCentralID}"
#    SLA               = "${var.tagSLA}"
#    Description       = "${var.tagDescription}"
#  }
}

resource "azurerm_managed_disk" "managed_disk" {
  count                = "${var.managed_disk_sizes[0] != "" ? (var.rdsh_count * length(var.managed_disk_sizes)) : 0 }"
  name                 = "${var.vm_prefix}-${(count.index / length(var.managed_disk_sizes)) + 1}-disk-${(count.index % length(var.managed_disk_sizes)) + 1}"
  location             = "${var.region}"
  resource_group_name  = "${var.vm_resource_group_name}"
  storage_account_type = "${var.managed_disk_type}"
  create_option        = "Empty"
  disk_size_gb         = "${var.managed_disk_sizes[count.index % length(var.managed_disk_sizes)]}"

#  tags {
#    BUC             = "${var.tagBUC}"
#    SupportGroup    = "${var.tagSupportGroup}"
#    AppGroupEmail   = "${var.tagAppGroupEmail}"
#    EnvironmentType = "${var.tagEnvironmentType}"
#    CustomerCRMID   = "${var.tagCustomerCRMID}"
#    NPI             = "${var.tagNPI}"
#    ExpirationDate  = "${var.tagExpirationDate}"
#    SLA             = "${var.tagSLA}"
#  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "managed_disk" {
  count              = "${var.managed_disk_sizes[0] != "" ? (var.rdsh_count * length(var.managed_disk_sizes)) : 0 }"
  managed_disk_id    = "${azurerm_managed_disk.managed_disk.*.id[count.index]}"
  virtual_machine_id = "${azurerm_virtual_machine.main.*.id[count.index / length(var.managed_disk_sizes)]}"
  lun                = "10"
  caching            = "ReadWrite"
}


