# Public IP
resource "azurerm_public_ip" "nfs_serverpip" {
    name                         = "nfs_server-pip"
    location                     = azurerm_resource_group.resourcegroup.location
    resource_group_name          = azurerm_resource_group.resourcegroup.name
    allocation_method            = "Dynamic"
    domain_name_label            = "nfs-${var.project_id}"
}

# NIC
resource "azurerm_network_interface" "nfs_servernic" {
    name                        = "nfs_server-nic"
    location                    = azurerm_resource_group.resourcegroup.location
    resource_group_name         = azurerm_resource_group.resourcegroup.name
    ip_configuration {
        name                          = "nfs_server-ip"
        subnet_id                     = azurerm_subnet.internal.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.nfs_serverpip.id
    }
}

# VM
resource "azurerm_linux_virtual_machine" "nfs_server" {
    count                 = var.nfs_server_enabled ? 1 : 0
    name                  = "nfs-server"
    location              = azurerm_resource_group.resourcegroup.location
    resource_group_name   = azurerm_resource_group.resourcegroup.name
    network_interface_ids = [azurerm_network_interface.nfs_servernic.id]
    size                  = var.nfs_instance_type
    admin_username        = var.user
    custom_data           = base64encode(file(pathexpand(var.nfs_cloud_init_file)))
    admin_ssh_key {
        username = var.user
        public_key = file(pathexpand(var.ssh_pub_key_path))
    }
    os_disk {
        name              = "nfs-server-os-disk"
        caching           = "ReadWrite"
        disk_size_gb      = 400
        storage_account_type = "Standard_LRS"
    }
    source_image_reference {
        publisher = "OpenLogic"
        offer     = "CentOS"
        sku       = "7_8"
        version   = "latest"
    }
    boot_diagnostics {
      storage_account_uri = azurerm_storage_account.storageaccount.primary_blob_endpoint
    }
}

data "azurerm_public_ip" "nfs_public_ip" {
  name                = azurerm_public_ip.nfs_serverpip.name
  resource_group_name = azurerm_linux_virtual_machine.nfs_server[0].resource_group_name
}
