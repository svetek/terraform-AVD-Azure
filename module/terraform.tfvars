#az login
#az account set --subscription="1a06ca66-a14f-4109-a991-437989a7be98"
#az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/1a06ca66-a14f-4109-a991-437989a7be98"
#{
#"appId": "b0edca60-b84d-4e34-a607-77191770decd",  --ClientID
#"displayName": "azure-cli-2021-12-29-08-18-47",
#"name": "b0edca60-b84d-4e34-a607-77191770decd",
#"password": "SUw~S964SZdLwIYG_psSYwwo9pRVOL5cnu", --ClientSecret
#"tenant": "702dc21a-89b2-4594-bc1f-401a518bf3af"
#}
#
# az login --service-principal -u "b0edca60-b84d-4e34-a607-77191770decd" -p "SUw~S964SZdLwIYG_psSYwwo9pRVOL5cnu" --tenant "702dc21a-89b2-4594-bc1f-401a518bf3af"

tenant_id = "702dc21a-89b2-4594-bc1f-401a518bf3af"
subscription_id = "1a06ca66-a14f-4109-a991-437989a7be98"

# AD network
ad_resource_group_name = "WVD-AD"
ad_vm_local_ip = "10.0.0.4"
ad_virtual_network_name = "adVNET"
ad_subnet_name = "adSubnet"

host_pool_name = "AVD-PRIM-HOSTPOOL"
region = "West US 2"

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
domain_name = "russianchurchoregon.org"
domain_user_upn = "alex"
domain_password = "cBUBolsC22836j8JfF1P"
ou_path = ""

extension_custom_script = "true"
extensions_custom_script_fileuris = ["https://raw.githubusercontent.com/svetek/terraform-scripts/main/AVD/scripts/script.ps1"]
extensions_custom_command = "powershell -ExecutionPolicy Unrestricted ./script.ps1 "

# Install DUO
duo_enable = 1
duo_ikey = "DI3WUDOS62L99439O62S"
duo_skey = "uMBaEOoIkLfhYPTYhZepYWXRwyn0oH3PE9x8jgnN"
duo_host_api = "api-5124872e.duosecurity.com"
