# Deployment variables
variable "project_id" { }

# AzureRM variables
variable "region" { }
variable "subscription_id" { }
variable "client_id" { }
variable "client_secret" { }
variable "tenant_id" { }

# BlueData cluster variables
#variable "controller" { }
#variable "gateway" { }
#variable "worker1" { }
variable "worker_count" { default = 3 }
variable "user" { }
variable "bluedata_image_url" { }
variable "selinux_disabled" { default = false }

# Azure VM Sizes
variable "gtw_instance_type" { default = "Standard_D16_v3" }
variable "ctr_instance_type" { default = "Standard_D16_v3" }
variable "wkr_instance_type" { default = "Standard_D16_v3" }
variable "nfs_instance_type" { default = "Standard_D2_v3" }
variable "ad_instance_type" { default = "Standard_D2_v3" }

# environment
variable "ssh_pub_key_path" { default = "~/.ssh/id_rsa.pub" }
variable "ssh_prv_key_path" { default = "~/.ssh/id_rsa" }
// variable "temp_password" { }
variable "pass_auth_disabled" { default = true }

provider "azurerm" {
    version = "=1.38.0"
    subscription_id = var.subscription_id
    client_id = var.client_id
    client_secret = var.client_secret
    tenant_id = var.tenant_id
}

# Create a resource group
resource "azurerm_resource_group" "resourcegroup" {
  name     = "${var.project_id}-rg"
  location = var.region
  tags = {
        environment = var.project_id,
        user = var.user
    }
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "network" {
    name                = "${var.project_id}-vnet"
    address_space       = ["10.1.0.0/16"]
    location            = var.region
    resource_group_name = azurerm_resource_group.resourcegroup.name

    tags = {
        environment = var.project_id,
        user = var.user
    }
}

# Create the subnet
resource "azurerm_subnet" "subnet" {
    name                 = "${var.project_id}-subnet"
    resource_group_name  = azurerm_resource_group.resourcegroup.name
    virtual_network_name = azurerm_virtual_network.network.name
    address_prefix       = "10.1.1.0/24"
}

# Create a Network Security Group 
# allow ssh

resource "azurerm_network_security_group" "nsg" {
    name                = "${var.project_id}-nsg"
    location            = var.region
    resource_group_name = azurerm_resource_group.resourcegroup.name
    
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "10.1.1.0/24"
    }

    tags = {
        environment = var.project_id,
        user = var.user
    }
}

# Controller Public IP
resource "azurerm_public_ip" "controllerpublicip" {
    name                         = "controller-ip"
    location                     = var.region
    resource_group_name          = azurerm_resource_group.resourcegroup.name
    allocation_method            = "Dynamic"

    tags = {
        environment = var.project_id,
        user = var.user
    }
}

# Gateway Public IP
resource "azurerm_public_ip" "gatewaypublicip" {
    name                         = "gateway-ip"
    location                     = var.region
    resource_group_name          = azurerm_resource_group.resourcegroup.name
    allocation_method            = "Dynamic"

    tags = {
        environment = var.project_id,
        user = var.user
    }
}

# Controller NIC
resource "azurerm_network_interface" "controllernic" {
    name                        = "controller-nic"
    location                    = var.region
    resource_group_name         = azurerm_resource_group.resourcegroup.name
    network_security_group_id   = azurerm_network_security_group.nsg.id

    ip_configuration {
        name                          = "controller-nic-configuration"
        subnet_id                     = azurerm_subnet.subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.controllerpublicip.id
    }

    tags = {
        environment = var.project_id,
        user = var.user
    }
}

# Gateway NIC
resource "azurerm_network_interface" "gatewaynic" {
    name                        = "gateway-nic"
    location                    = var.region
    resource_group_name         = azurerm_resource_group.resourcegroup.name
    network_security_group_id   = azurerm_network_security_group.nsg.id

    ip_configuration {
        name                          = "gateway-nic-configuration"
        subnet_id                     = azurerm_subnet.subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.gatewaypublicip.id
    }

    tags = {
        environment = var.project_id,
        user = var.user
    }
}

# Worker NICs
resource "azurerm_network_interface" "workernics" {
    count                       = var.worker_count
    name                        = "worker${count.index + 1}-nic"
    location                    = var.region
    resource_group_name         = azurerm_resource_group.resourcegroup.name
    network_security_group_id   = azurerm_network_security_group.nsg.id

    ip_configuration {
        name                          = "worker${count.index + 1}-nic-configuration"
        subnet_id                     = azurerm_subnet.subnet.id
        private_ip_address_allocation = "Dynamic"
    }

    tags = {
        environment = var.project_id,
        user = var.user
    }
}

# Random ID generator for storage account
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.resourcegroup.name
    }
    byte_length = 8
}

resource "azurerm_storage_account" "storageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.resourcegroup.name
    location                    = var.region
    account_replication_type    = "LRS"
    account_tier                = "Standard"

    tags = {
        environment = var.project_id,
        user = var.user
    }
}

/******************* ssh pub key content ********************/

data "local_file" "ssh_pub_key" {
    filename = pathexpand(var.ssh_pub_key_path)
}


# Create VMs

# Controller VM
resource "azurerm_virtual_machine" "controller-vm" {
    name                  = "controller-vm"
    location              = var.region
    resource_group_name   = azurerm_resource_group.resourcegroup.name
    network_interface_ids = [azurerm_network_interface.controllernic.id]
    vm_size               = var.ctr_instance_type

    storage_os_disk {
        name              = "controller-os-disk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        disk_size_gb      = "512" # "400"
        managed_disk_type = "Standard_LRS"
    }

    storage_data_disk {
        name              = "controller-data-disk0"
        caching           = "ReadWrite"
        create_option     = "Empty"
        managed_disk_type = "Standard_LRS"
        disk_size_gb      = "512"
        lun               = 1
    }

    storage_data_disk {
        name              = "controller-data-disk1"
        caching           = "ReadWrite"
        create_option     = "Empty"
        managed_disk_type = "Standard_LRS"
        disk_size_gb      = "512"
        lun               = 2
    }

    storage_image_reference {
        publisher = "OpenLogic"
        offer     = "CentOS"
        sku       = "7.5"
        version   = "latest"
    }

    os_profile {
        computer_name  = "controller"
        admin_username = var.user
        // admin_password = var.temp_password
    }

    os_profile_linux_config {
        disable_password_authentication = var.pass_auth_disabled
        ssh_keys {
            path     = "/home/${var.user}/.ssh/authorized_keys"
            key_data = file(var.ssh_pub_key_path) # data.local_file.ssh_pub_key.content
        }
    }

    // provisioner "remote-exec" {
    //     inline = [
    //         "wget ${bluedata_image_url}",
    //         "sudo yum update -y",
    //         // "nohup sudo reboot </dev/null &"
    //     ]
    // }

    boot_diagnostics {
        enabled     = "true"
        storage_uri = azurerm_storage_account.storageaccount.primary_blob_endpoint
    }

    tags = {
        environment = var.project_id,
        user = var.user
    }
}

resource "azurerm_virtual_machine" "gateway-vm" {
    name                  = "gateway-vm"
    location              = var.region
    resource_group_name   = azurerm_resource_group.resourcegroup.name
    network_interface_ids = [azurerm_network_interface.gatewaynic.id]
    vm_size               = var.gtw_instance_type

    storage_os_disk {
        name              = "gateway-os-disk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    storage_image_reference {
        publisher = "OpenLogic"
        offer     = "CentOS"
        sku       = "7.5"
        version   = "latest"
    }

    os_profile {
        computer_name  = "gateway"
        admin_username = var.user
        // admin_password = var.temp_password
    }

    os_profile_linux_config {
        disable_password_authentication = var.pass_auth_disabled
        ssh_keys {
            path     = "/home/${var.user}/.ssh/authorized_keys"
            key_data = file(var.ssh_pub_key_path) # data.local_file.ssh_pub_key.content
        }
    }

    boot_diagnostics {
        enabled     = "true"
        storage_uri = azurerm_storage_account.storageaccount.primary_blob_endpoint
    }

    tags = {
        environment = var.project_id,
        user = var.user
    }
}

# Worker VMs
resource "azurerm_virtual_machine" "workers" {
    name                  = "worker${count.index + 1}-vm"
    count                 = var.worker_count
    location              = var.region
    resource_group_name   = azurerm_resource_group.resourcegroup.name
    network_interface_ids = [element(azurerm_network_interface.workernics.*.id, count.index)]
    vm_size               = var.wkr_instance_type

    storage_os_disk {
        name              = "worker${count.index + 1}-os-disk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        disk_size_gb      = "400"
        managed_disk_type = "Standard_LRS"
    }

    // storage_data_disk {
    //     name              = "worker${count.index + 1}-data-disk0"
    //     caching           = "ReadWrite"
    //     create_option     = "Empty"
    //     managed_disk_type = "Standard_LRS"
    //     disk_size_gb      = "1024"
    //     lun               = 1
    // }

    // storage_data_disk {
    //     name              = "worker${count.index + 1}-data-disk1"
    //     caching           = "ReadWrite"
    //     create_option     = "Empty"
    //     managed_disk_type = "Standard_LRS"
    //     disk_size_gb      = "1024"
    //     lun               = 2
    // }


    storage_image_reference {
        publisher = "OpenLogic"
        offer     = "CentOS"
        sku       = "7.5"
        version   = "latest"
    }

    os_profile {
        computer_name  = "worker${count.index + 1}"
        admin_username = var.user
        // admin_password = var.temp_password
    }

    os_profile_linux_config {
        disable_password_authentication = var.pass_auth_disabled
        ssh_keys {
            path     = "/home/${var.user}/.ssh/authorized_keys"
            key_data = file(var.ssh_pub_key_path) # data.local_file.ssh_pub_key.content
        }
    }

    boot_diagnostics {
        enabled     = "true"
        storage_uri = azurerm_storage_account.storageaccount.primary_blob_endpoint
    }

    tags = {
        environment = var.project_id,
        user = var.user
    }
}

# outputs

# workaround since public IP cannot be get before attaching to an online VM 
# https://github.com/terraform-providers/terraform-provider-azurerm/issues/764#issuecomment-365019882

data "azurerm_public_ip" "ctr_ip" {
  name                = azurerm_public_ip.controllerpublicip.name
  resource_group_name = azurerm_virtual_machine.controller-vm.resource_group_name
}

output "controller_public_ip" {
  value = data.azurerm_public_ip.ctr_ip.ip_address
}

output "controller_private_ip" {
    value = azurerm_network_interface.controllernic.private_ip_address
}

output "workers_private_ip" {
    value = azurerm_network_interface.workernics.*.private_ip_address
}

output "controller_ssh_command" {
  value = "ssh -o StrictHostKeyChecking=no -i ${var.ssh_prv_key_path} ${var.user}@${data.azurerm_public_ip.ctr_ip.ip_address}"
}

data "azurerm_public_ip" "gw_ip" {
  name                = azurerm_public_ip.gatewaypublicip.name
  resource_group_name = azurerm_virtual_machine.gateway-vm.resource_group_name
}

output "gateway_public_ip" {
  value = data.azurerm_public_ip.gw_ip.ip_address
}

output "gateway_private_ip" {
    value = azurerm_network_interface.gatewaynic.private_ip_address
}

// output "gateway_private_dns" {
//     value = azurerm_network_interface.gatewaynic.internal_dns_name_label
// }

// output "gateway_public_dns" {
//     value = azurerm_virtual_machine.gateway-vm.public_ip_dns_name
// }

output "gateway_ssh_command" {
  value = "ssh -o StrictHostKeyChecking=no -i ${var.ssh_prv_key_path} ${var.user}@${data.azurerm_public_ip.gw_ip.ip_address}"
}

output "selinux_disabled" {
  value = "${var.selinux_disabled}"
}

output "ssh_pub_key_path" {
  value = "${var.ssh_pub_key_path}"
}

output "ssh_prv_key_path" {
  value = "${var.ssh_prv_key_path}"
}

output "bluedata_image_url" {
  value = "${var.bluedata_image_url}"
}