# Controller Public IP
resource "azurerm_public_ip" "controllerpip" {
    count = var.create_eip_controller ? 1 : 0
    name                         = "controller-pip"
    location                     = azurerm_resource_group.resourcegroup.location
    resource_group_name          = azurerm_resource_group.resourcegroup.name
    allocation_method            = "Dynamic"
    domain_name_label            = "ctr-${var.project_id}"
}

# Controller NIC
resource "azurerm_network_interface" "controllernic" {
    name                        = "controller-nic"
    location                    = azurerm_resource_group.resourcegroup.location
    resource_group_name         = azurerm_resource_group.resourcegroup.name
    ip_configuration {
        name                          = "controller-ip"
        subnet_id                     = azurerm_subnet.internal.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = var.create_eip_controller ? azurerm_public_ip.controllerpip[0].id : null
    }
}

# Controller VM
resource "azurerm_linux_virtual_machine" "controller" {
    name                  = "controller"
    location              = azurerm_resource_group.resourcegroup.location
    resource_group_name   = azurerm_resource_group.resourcegroup.name
    network_interface_ids = [azurerm_network_interface.controllernic.id]
    size                  = var.ctr_instance_type
    admin_username        = var.user
    custom_data           = base64encode(file(pathexpand(var.cloud_init_file)))
    admin_ssh_key {
        username = var.user
        public_key = file(pathexpand(var.ssh_pub_key_path))
    }
    os_disk {
        name              = "controller-os-disk"
        caching           = "ReadWrite"
        disk_size_gb      = "512"
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

/********** Data Disks **********/
resource "azurerm_managed_disk" "ctrdatadisk" {
  count                = 2
  name                 = "controller-disk${count.index + 1}"
  location             = azurerm_resource_group.resourcegroup.location
  resource_group_name  = azurerm_resource_group.resourcegroup.name
  create_option        = "Empty"
  disk_size_gb         = 512
  storage_account_type = "Standard_LRS"
}
resource "azurerm_virtual_machine_data_disk_attachment" "ctrdatadisk-attach" {
  count              = 2
  virtual_machine_id = azurerm_linux_virtual_machine.controller.id
  managed_disk_id    = azurerm_managed_disk.ctrdatadisk.*.id[count.index]
  lun                = count.index + 1
  caching            = "ReadWrite"
}
