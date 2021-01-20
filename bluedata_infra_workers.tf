# Workers Public IP
resource "azurerm_public_ip" "workerspip" {
  count                   = var.worker_count
  name                    = "worker${count.index + 1}-pip"
  location                = azurerm_resource_group.resourcegroup.location
  resource_group_name     = azurerm_resource_group.resourcegroup.name
  allocation_method       = "Dynamic"
  domain_name_label       = "worker${count.index + 1}-${var.project_id}"
}

# Worker NICs
resource "azurerm_network_interface" "workernics" {
    count                = var.worker_count
    name                 = "worker${count.index + 1}-nic"
    location             = azurerm_resource_group.resourcegroup.location
    resource_group_name  = azurerm_resource_group.resourcegroup.name
    ip_configuration {
        name                          = "worker${count.index + 1}-nic-ip"
        subnet_id                     = azurerm_subnet.internal.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.workerspip[count.index].id
    }
}

# Worker VMs
resource "azurerm_linux_virtual_machine" "workers" {
    count                 = var.worker_count
    name                  = "worker${count.index + 1}"
    location              = azurerm_resource_group.resourcegroup.location
    resource_group_name   = azurerm_resource_group.resourcegroup.name
    network_interface_ids = [element(azurerm_network_interface.workernics.*.id, count.index)]
    size                  = var.wkr_instance_type
    admin_username        = var.user
    custom_data           = base64encode(file(pathexpand(var.cloud_init_file)))
    admin_ssh_key {
        username = var.user
        public_key = file(pathexpand(var.ssh_pub_key_path))
    }
    os_disk {
        name              = "worker${count.index + 1}-disk0"
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

/********** Data Disks **********/

locals {
  datadisks_count_map = { for k in toset(azurerm_linux_virtual_machine.workers.*.name) : k => 2 } // 2 disks per VM
  luns                      = { for k in local.datadisk_lun_map : k.datadisk_name => k.lun }
  datadisk_lun_map = flatten([
    for vm_name, count in local.datadisks_count_map : [
      for i in range(count) : {
        datadisk_name = format("%s-disk%01d", vm_name, i + 1)
        lun           = i + 1
      }
    ]
  ])
}

resource "azurerm_managed_disk" "wrkdatadisk" {
  for_each             = toset([for j in local.datadisk_lun_map : j.datadisk_name])
  name                 = each.key
  location             = azurerm_resource_group.resourcegroup.location
  create_option        = "Empty"
  disk_size_gb         = 1024
  resource_group_name  = azurerm_resource_group.resourcegroup.name
  storage_account_type = "Standard_LRS"
}
resource "azurerm_virtual_machine_data_disk_attachment" "wrkdatadisk-attach" {
  for_each           = toset([for j in local.datadisk_lun_map : j.datadisk_name])
  managed_disk_id    = azurerm_managed_disk.wrkdatadisk[each.key].id
  virtual_machine_id = azurerm_linux_virtual_machine.workers[parseint(element(regex("^worker(\\d)-\\w*$", each.key), 0), 10) - 1].id
  lun                = lookup(local.luns, each.key)
  caching            = "ReadWrite"
}
