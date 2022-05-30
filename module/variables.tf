# TENANT
variable tenant_id {
  description = "Azure tenant ID"
}

variable subscription_id {
  description = "Azure subscription ID"
}

# Network Variables
variable ad_resource_group_name {}
variable ad_virtual_network_name {}
variable ad_subnet_name {}
variable ad_vm_local_ip {}

variable rg_net_group {
  description = "Resource group name"
}

variable "rdsh_count" {
  description = "**OPTIONAL**: Number of WVD machines to deploy"
  default     = 1
}

variable "host_pool_name" {
  description = "Name of the RDS host pool"
  default     = ""
}

variable "vm_prefix" {
  description = "Prefix of the name of the WVD machine(s)"
}

#variable "tenant_name" {
#  description = "Name of the RDS tenant associated with the machines"
#}

variable "local_admin_username" {
  description = "**OPTIONAL**: Name of the local admin account"
  default     = "rdshadm"
}

#variable "registration_expiration_hours" {
#  description = "**OPTIONAL**: The expiration time for registration in hours"
#  default     = "48"
#}

variable "domain_joined" {
  description = "**OPTIONAL**: Should the machine join a domain"
  default     = "true"
}

variable "domain_name" {
  description = "**OPTIONAL**: Name of the domain to join"
  default     = ""
}

variable "domain_user_upn" {
  description = "**OPTIONAL**: UPN of the user to authenticate with the domain"
  default     = ""
}

variable "domain_password" {
  description = "**OPTIONAL**: Password of the user to authenticate with the domain"
  default     = ""
}

#variable "tenantLocation" {
#  description = "**OPTIONAL**: Region in which the RDS tenant exists"
#  default     = "eastus"
#}

variable "region" {
  description = "Region in which to deploy these resources"
}

variable "vm_resource_group_name" {
  description = "Name of the Resource Group in which to deploy these resources"
}

#variable "base_url" {
#  description = "**OPTIONAL**: The URL in which the RDS components exist"
#  default     = "https://raw.githubusercontent.com/Azure/RDS-Templates/master/wvd-templates/Create%20and%20provision%20WVD%20host%20pool"
#}
#
#variable "existing_tenant_group_name" {
#  description = "**OPTIONAL**: Name of the existing tenant group"
#  default     = "Default Tenant Group"
#}
#
#variable "host_pool_description" {
#  description = "**OPTIONAL**: Description of the RDS host pool"
#  default     = "Created through Terraform template"
#}
#
variable "vm_size" {
  description = "**OPTIONAL**: Size of the machine to deploy"
  default     = "Standard_F2s"
}

variable "nsg_id" {
  description = "**OPTIONAL**: ID of the NSG to associate the network interface"
  default     = ""
}

variable "subnet_id" {
  description = "ID of the Subnet in which the machines will exist"
}

#variable "RDBrokerURL" {
#  description = "**OPTIONAL**: URL of the RD Broker"
#  default     = "https://rdbroker.wvd.microsoft.com"
#}
#
#variable "tenant_app_id" {
#  description = "ID of the tenant app"
#}
#
#variable "tenant_app_password" {
#  description = "Password of the tenant app"
#}
#
#variable "is_service_principal" {
#  description = "**OPTIONAL**: Is a service principal used for RDS connection"
#  default     = "true"
#}
#
#variable "aad_tenant_id" {
#  description = "ID of the AD tenant"
#}

variable "ou_path" {
  description = "OU path to us during domain join"
}

variable "vm_image_id" {
  description = "**OPTIONAL**: ID of the custom image to use"
  default     = ""
}

variable "vm_publisher" {
  description = "**OPTIONAL**: Publisher of the vm image"
  default     = "MicrosoftWindowsDesktop"
}

variable "vm_offer" {
  description = "**OPTIONAL**: Offer of the vm image"
  default     = "Windows-10"
}

variable "vm_sku" {
  description = "**OPTIONAL**: Sku of the vm image"
  default     = "rs5-evd"
}

variable "vm_version" {
  description = "**OPTIONAL**: Version of the vm image"
  default     = "latest"
}

variable "vm_timezone" {
  description = "The vm_timezone of the vms"
}

#variable "as_platform_update_domain_count" {
#  description = "https://github.com/MicrosoftDocs/azure-docs/blob/master/includes/managed-disks-common-fault-domain-region-list.md"
#  default     = 5
#}
#
#variable "as_platform_fault_domain_count" {
#  description = "https://github.com/MicrosoftDocs/azure-docs/blob/master/includes/managed-disks-common-fault-domain-region-list.md"
#  default     = 3
#}
#
#variable "log_analytics_workspace_id" {
#  description = "Workspace ID of the Log Analytics Workspace to associate the VMs with"
#}
#
#variable "log_analytics_workspace_primary_shared_key" {
#  description = "Primary Shared Key of the Log Analytics Workspace to associate the VMs with"
#}
#
#variable "extension_bginfo" {
#  description = "**OPTIONAL**: Should BGInfo be attached to all servers"
#  default     = "true"
#}
#
#variable "extension_loganalytics" {
#  description = "**OPTIONAL**: Should Log Analytics agent be attached to all servers"
#  default     = "true"
#}

variable "extension_custom_script" {
  description = "**OPTIONAL**: Should a custom script extension be run on all servers"
  default     = "false"
}

variable "extensions_custom_script_fileuris" {
  description = "**OPTIONAL**: File URIs to be consumed by the custom script extension"
  default     = ["https://raw.githubusercontent.com/svetek/terraform-scripts/main/AVD/scripts/script.ps1"]
}

variable "extensions_custom_command" {
  description = "**OPTIONAL**: Command for the custom script extension to run"
  default     = ""
}

variable "vm_storage_os_disk_size" {
  description = "**OPTIONAL**: The size of the OS disk"
  default     = "128"
}

variable "managed_disk_sizes" {
  description = "**OPTIONAL**: The sizes of the optional manged data disks"
  default     = [""]
}

variable "managed_disk_type" {
  description = "**OPTIONAL**: If a manged disks are attached this allows for choosing the type. The dafault value is Standard_LRS"
  default     = "Standard_LRS"
}

variable "rg_fslogix" {
  description = "Resource group name for FSLogix User Profile"
}

variable "fslogix_enable" {
  description = "Resource group name for FSLogix User Profile"
  default = 0
}

variable "duo_ikey" {
  description = "DUO Integration KEY"
  default = "DIXXXXXXXXXXXXXXXXXXXX"
}

variable "duo_skey" {
  description = "DUO Secret KEY"
  default = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
}
variable "duo_host_api" {
  description = "DUO HOST API URL"
  default = "api-xxxxxxxx.duosecurity.com"
}
variable "duo_enable" {
  description = "DUO ENABLE 0 or 1"
  default = 0
}

variable "aad_group_name" {}
variable "avd_users" {}

#variable "backspace" {
#  default =
#}
# Install additional Software
