# Public IP
resource "azurerm_public_ip" "ad_serverpip" {
    name                         = "ad_server-pip"
    location                     = azurerm_resource_group.resourcegroup.location
    resource_group_name          = azurerm_resource_group.resourcegroup.name
    allocation_method            = "Static"
    domain_name_label            = "ad-${var.project_id}"
}

# NIC
resource "azurerm_network_interface" "ad_servernic" {
    name                        = "ad_server-nic"
    location                    = azurerm_resource_group.resourcegroup.location
    resource_group_name         = azurerm_resource_group.resourcegroup.name
    ip_configuration {
        name                          = "ad_server-ip"
        subnet_id                     = azurerm_subnet.internal.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.ad_serverpip.id
     }
}

# VM
resource "azurerm_linux_virtual_machine" "ad_server" {
    count = var.ad_server_enabled ? 1 : 0
    name                  = "ad-server"
    location              = azurerm_resource_group.resourcegroup.location
    resource_group_name   = azurerm_resource_group.resourcegroup.name
    network_interface_ids = [azurerm_network_interface.ad_servernic.id]
    size                  = var.ad_instance_type
    admin_username        = var.user
    custom_data           = base64encode(file(pathexpand(var.ad_cloud_init_file)))
    admin_ssh_key {
        username = var.user
        public_key = file(pathexpand(var.ssh_pub_key_path))
    }
    os_disk {
        name              = "ad-server-os-disk"
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
    provisioner "file" {
        connection {
            type        = "ssh"
            user        = "centos"
            host        = data.azurerm_public_ip.ad_public_ip.ip_address
            private_key = file(var.ssh_prv_key_path)
            agent   = false
        }
        source        = "${path.module}/${var.downstream_repo_dir}/modules/module-ad-server/files/"
        destination   = "/home/centos/"
  }
}
data "azurerm_public_ip" "ad_public_ip" {
  name                = azurerm_public_ip.ad_serverpip.name
  resource_group_name = azurerm_resource_group.resourcegroup.name
}
