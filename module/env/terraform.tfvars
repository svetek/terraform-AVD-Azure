host_pool_name = "AVD-PRIM-HOSTPOOL"
region = "North Europe"

# Network Subnet Configuration
rg_net_group = "RG-US-AVD-NET-WEST"
subnet_id = ""

# FSLogix Storage Configuration
rg_fslogix = "RG-US-AVD-FSLOGIX-WEST"
fslogix_enable = 1

# VMS
rdsh_count = 1
vm_prefix = "AVD-VM"
vm_resource_group_name = "RG-US-AVD-VM-WEST"
nsg_id = 2
vm_size = "Standard_F2s"
vm_storage_os_disk_size = 128
local_admin_username = "maxi"
vm_timezone = ""

# Get-AzVMImageSku -Location <location> -PublisherName MicrosoftWindowsDesktop -Offer windows-10
vm_image_id = ""
vm_publisher = "MicrosoftWindowsDesktop"
vm_offer = "Windows-10"
vm_sku = "20h2-evd"
vm_version = "latest"
managed_disk_sizes = [""]
managed_disk_type = "Standard_LRS"

# AVD VM
domain_joined ="true"
domain_name = "noname.biz"
domain_user_upn = "admin"
domain_password = "supersecret"
#ou_path = "OU=Computers,DC=Noname,DC=biz"

extension_custom_script = "true"
extensions_custom_script_fileuris = ["https://raw.githubusercontent.com/svetek/terraform-scripts/main/AVD/scripts/script.ps1"]
extensions_custom_command = "powershell -ExecutionPolicy Unrestricted ./script.ps1 "

# Install DUO
duo_enable = 1
duo_ikey = "DI3WU****"
duo_skey = "uMBaEOoI*****"
duo_host_api = "api-*****.duosecurity.com"
