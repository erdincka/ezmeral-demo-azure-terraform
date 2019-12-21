# Deployment variables
variable "project" { }

# AzureRM variables
variable "region" { }
variable "subscription_id" { }
variable "client_id" { }
variable "client_secret" { }
variable "tenant_id" { }

# BlueData cluster variables
variable "controller" { }
variable "gateway" { }
variable "worker1" { }
variable "workercount" { default = 3 }


provider "azurerm" {
    version = "=1.38.0"
    subscription_id = var.subscription_id
    client_id = var.client_id
    client_secret = var.client_secret
    tenant_id = var.tenant_id
}

# Create a resource group
resource "azurerm_resource_group" "myresourcegroup" {
  name     = "${var.project}-rg"
  location = var.region
  tags = {
        environment = var.project
    }
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "mynetwork" {
    name                = "${var.project}-net"
    address_space       = ["10.1.0.0/16"]
    location            = var.region
    resource_group_name = azurerm_resource_group.myresourcegroup.name

    tags = {
        environment = var.project
    }
}

# Create the subnet
resource "azurerm_subnet" "mysubnet" {
    name                 = "${var.project}-subnet"
    resource_group_name  = azurerm_resource_group.myresourcegroup.name
    virtual_network_name = azurerm_virtual_network.mynetwork.name
    address_prefix       = "10.0.2.0/24"
}

# Create public IP address
resource "azurerm_public_ip" "mypublicip" {
    name                         = "${var.project}-PublicIP"
    location                     = var.region
    resource_group_name          = azurerm_resource_group.myresourcegroup.name
    allocation_method            = "Dynamic"

    tags = {
        environment = var.project
    }
}

# Create a Network Security Group 
# allow ssh

resource "azurerm_network_security_group" "mynsg" {
    name                = "${var.project}-NSG"
    location            = var.region
    resource_group_name = azurerm_resource_group.myresourcegroup.name
    
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = var.project
    }
}

resource "azurerm_network_interface" "mycontrollernic" {
    name                        = "${var.controller}-NIC"
    location                    = var.region
    resource_group_name         = azurerm_resource_group.myresourcegroup.name
    network_security_group_id   = azurerm_network_security_group.mynsg.id

    ip_configuration {
        name                          = "${var.controller}-NicConfiguration"
        subnet_id                     = azurerm_subnet.mysubnet.id
        private_ip_address_allocation = "Dynamic"
        # public_ip_address_id          = azurerm_public_ip.mypublicip.id # not using public IP for controller
    }

    tags = {
        environment = var.project
    }
}

# Random ID generator for storage account
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.myterraformgroup.name
    }
    byte_length = 8
}

resource "azurerm_storage_account" "storageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.myresourcegroup.name
    location                    = var.region
    account_replication_type    = "LRS"
    account_tier                = "Standard"

    tags = {
        environment = var.project
    }
}

resource "azurerm_virtual_machine" "controllervm" {
    name                  = "${var.project}-controllervm"
    location              = var.region
    resource_group_name   = azurerm_resource_group.myresourcegroup.name
    network_interface_ids = [azurerm_network_interface.mycontrollernic.id]
    vm_size               = "Standard_DS1_v2"

    storage_os_disk {
        name              = "${var.controller}-OsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "bluedata-controller"
        admin_username = "admin"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "~/.ssh/authorized_keys"
            key_data = "ssh-rsa AAAAB3Nz{snip}hwhqT9h"
        }
    }

    boot_diagnostics {
        enabled     = "true"
        storage_uri = "azurerm_storage_account.${var.project}-storageaccount.primary_blob_endpoint"
    }

    tags = {
        environment = var.project
    }
}