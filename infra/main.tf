terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.53.0"
    }
  }
}

variable "subscription_id" {
  type    = string
}

variable "vm_size" {
  type    = string
}

variable "admin_username" {
  type    = string
}

variable "admin_password" {
  type    = string
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = var.subscription_id
}

# Create resource group for infrastructure
resource "azurerm_resource_group" "infra" {
   name     = "osimages-infra-rg-eastus"
   location = "eastus"
 }

# Create resource group to store the images
resource "azurerm_resource_group" "store" {
   name     = "osimages-store-rg-eastus"
   location = "eastus"
 }

# Create resource group when building images
resource "azurerm_resource_group" "build" {
   name     = "osimages-build-rg-eastus"
   location = "eastus"
 }

# Create a virtual network
resource "azurerm_virtual_network" "infra" {
  name                = "build-osimages-vnet-eastus"
  address_space       = ["10.100.0.0/16"]
  location            = azurerm_resource_group.infra.location
  resource_group_name = azurerm_resource_group.infra.name
}

# Create a subnet
resource "azurerm_subnet" "infra" {
  name                 = "build-osimages-subnet-eastus"
  resource_group_name  = azurerm_resource_group.infra.name
  virtual_network_name = azurerm_virtual_network.infra.name
  address_prefixes     = ["10.100.0.0/24"]
}

# Create a network security group
resource "azurerm_network_security_group" "infra" {
  name                = "build-osimages-nsg"
  location            = azurerm_resource_group.infra.location
  resource_group_name = azurerm_resource_group.infra.name

  security_rule {
    name                       = "AllowRDPInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "73.53.107.79"
    destination_address_prefix = "10.100.0.0/24"
  }

  security_rule {
    name                       = "AllowSSHInbound"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "73.53.107.79"
    destination_address_prefix = "10.100.0.0/24"
  }

  tags = {
    environment = "buildosimages"
  }
}

# Create network interface card (NIC) for OSImages build server
resource "azurerm_network_interface" "buildserver" {
  name                = "build-osimages-nic-buildserver-eastus"
  location            = azurerm_resource_group.infra.location
  resource_group_name = azurerm_resource_group.infra.name

  ip_configuration {
    name                          = "buildserver"
    subnet_id                     = azurerm_subnet.infra.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create a virtual machine for build server
resource "azurerm_linux_virtual_machine" "buildserver" {
  name                  = "buildserver"
  resource_group_name   = azurerm_resource_group.infra.name
  location              = azurerm_resource_group.infra.location
  size                  = var.vm_size
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  disable_password_authentication = false
  network_interface_ids = [azurerm_network_interface.buildserver.id]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    }
    source_image_reference {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-jammy"
      sku       = "22_04-lts"
      version   = "latest"
    }
    tags = {
      environment = "BuildOSImages"
    }
}

# Create network interface card (NIC) for OSImages jump server
resource "azurerm_network_interface" "jumpserver" {
  name                = "build-osimages-nic-jumpserver-eastus"
  location            = azurerm_resource_group.infra.location
  resource_group_name = azurerm_resource_group.infra.name

  ip_configuration {
    name                          = "jumpserver"
    subnet_id                     = azurerm_subnet.infra.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create a virtual machine for jump server
resource "azurerm_windows_virtual_machine" "jumpserver" {
  name                  = "jumpserver"
  resource_group_name   = azurerm_resource_group.infra.name
  location              = azurerm_resource_group.infra.location
  size                  = var.vm_size
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.jumpserver.id]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    }
    source_image_reference {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2022-Datacenter"
      version   = "latest"
    }
    tags = {
      environment = "BuildOSImages"
    }
}
