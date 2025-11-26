packer {
  required_plugins {
    azure = {
      version = ">= 1.4.0"
      source  = "github.com/hashicorp/azure"
    }
    windows-update = {
        source  = "github.com/rgl/windows-update"
        version = ">= 0.17.1"
    }
  }
}

variable "azure_subscription_id" {
  type    = string
  default = env("AZURE_SUBSCRIPTION_ID")
}

variable "azure_client_id" {
  type    = string
  default = env("AZURE_CLIENT_ID")
}

variable "azure_client_secret" {
  type    = string
  default = env("AZURE_CLIENT_SECRET")
  sensitive = true
}

variable "azure_tenant_id" {
  type    = string
  default = env("AZURE_TENANT_ID")
}

variable "build_resource_group_name" {
  type    = string
  default = env("BUILD_RESOURCE_GROUP_NAME")
}

variable "image_name" {
  type    = string
  default = env("IMAGE_NAME")
}

variable "image_sku" {
  type    = string
  default = env("IMAGE_SKU")
}

variable "image_version" {
  type    = string
  default = env("IMAGE_VERSION")
}

variable "location" {
  type    = string
  default = env("LOCATION")
}

variable "managed_image_resource_group_name" {
  type    = string
  default = env("MANAGED_RESOURCE_GROUP_NAME")
}

variable "os_name" {
  type    = string
  default = env("OS_NAME")
}

variable "vm_size" {
  type    = string
  default = env("VM_SIZE")
}

source "azure-arm" "windows_server" {
  subscription_id                   = var.azure_subscription_id
  client_id                         = var.azure_client_id
  client_secret                     = var.azure_client_secret
  tenant_id                         = var.azure_tenant_id

  build_resource_group_name         = var.build_resource_group_name
  managed_image_resource_group_name = var.managed_image_resource_group_name
  managed_image_name                = var.image_name
  
  os_type                           = "Windows"
  image_publisher                   = "MicrosoftWindowsServer"
  image_offer                       = "WindowsServer"
  image_sku                         = var.image_sku
  image_version                     = var.image_version

  vm_size                           = var.vm_size
  
  communicator                      = "winrm"
  winrm_use_ssl                     = true
  winrm_insecure                    = true
  winrm_timeout                     = "30m"
  winrm_username                    = "packer"
  
  azure_tags = {
    Environment = "Production"
    CreatedBy   = "Packer"
    BuildDate   = formatdate("YYYY-MM-DD", timestamp())
  }
}

build {
  sources = ["source.azure-arm.windows_server"]
  
  # Wait for WinRM to be ready
  provisioner "powershell" {
    inline = ["Write-Host 'Waiting for WinRM...'"]
  }
  
  # Install Windows updates
  provisioner "windows-update" {
    search_criteria = "IsInstalled=0"
    filters = [
      "exclude:$_.Title -like '*Preview*'",
      "include:$true",
    ]
    update_limit = 25
  }

  # Reboot after updates
  provisioner "windows-restart" {
    check_registry = true
    restart_timeout = "10m"
  }

  # Apply OS configurations
  provisioner "powershell" {
    script = "packer/scripts/configure-os.ps1"
  }

  # Install software
  provisioner "powershell" {
    script = "packer/scripts/install-software.ps1"
  }
  
  # Apply security hardening
  provisioner "powershell" {
    script = "packer/scripts/security-hardening.ps1"
  }
  
  # Generalize the image (sysprep)
  provisioner "powershell" {
    inline = [
      "Write-Host 'Running Sysprep to generalize image...'",
      "& $env:SystemRoot\\System32\\Sysprep\\Sysprep.exe /oobe /generalize /quiet /quit",
      "while($true) { $imageState = Get-ItemProperty HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Setup\\State | Select ImageState; if($imageState.ImageState -ne 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE') { Write-Output $imageState.ImageState; Start-Sleep -s 10 } else { break } }"
    ]
  }
}
