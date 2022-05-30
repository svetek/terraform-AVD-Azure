# terraform-AVD-Azure

## How to use
### Terraforms files

Before start on your system will be installed terraform and azure-cli.  
Create directory with name organization and inside new directory create 3 files.

https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt
https://www.terraform.io/downloads

terraform.tfvars

    tenant_id = "<Azure tenant ID>"
    subscription_id = "<Azure subscription ID>"

terraform.tf

    terraform {
        required_providers {
            azurerm = {
                source  = "hashicorp/azurerm"
                version = "2.88.1"
            }
        }
    }
    
    variable "tenant_id" {}
    variable "subscription_id" {}

avd.tf
    
    module "AVD" {
        source          = "../../Modules/AVD"
        tenant_id       = "${var.tenant_id}"
        subscription_id = "${var.subscription_id}"
        
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
        aad_group_name = "AVD-GROUP-TEST"
        avd_users = ["alex@russianchurchoregon.org"]
        
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
        domain_name = "churchoregon.local"
        domain_user_upn = "maxi"
        domain_password = "DQ7Lkz123"
        ou_path = "OU=Computers,DC=churchoregon,DC=local"
        
        extension_custom_script = "true"
        extensions_custom_script_fileuris = ["https://raw.githubusercontent.com/svetek/terraform-scripts/main/Modules/AVD/scripts/script.ps1"]
          extensions_custom_command = "powershell -ExecutionPolicy Unrestricted ./script.ps1 "
        
        # Install DUO
        duo_enable = 1
        duo_ikey = "DI3WUDOS62L99439O62S"
        duo_skey = "uMBaEOoIkLfhYPTYhZepYWXRwyn0oH3PE9x8jgnN"
        duo_host_api = "api-5124872e.duosecurity.com"
    }

### Run deploy
You need auth in your original tenant on Azure after that make switch to subscribtion

    az login --use-device-code
    az account list --output table
    az account set --subscription  <Azure subscribtion where you want to deploy>
    az account show
    az account list-locations -o table
    az vm list-skus --size Standard_B --all --output table

Inside directory with terraform files run next command:

    # Download modules and packages for deploy 
    terraform get 
    terraform init 
    # Plan deploy (see what changes planed by deploy scripts)
    terraform plan 
    # Run deploy process 
    terraform apply 

All passwords and ssh keys you can see on Azure vault on resource group 
    