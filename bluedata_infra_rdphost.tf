# RDPhost Public IP
resource "azurerm_public_ip" "rdphostpip" {
    count = var.create_eip_rdp_linux_server ? 1 : 0
    name                         = "rdphost-pip"
    location                     = azurerm_resource_group.resourcegroup.location
    resource_group_name          = azurerm_resource_group.resourcegroup.name
    allocation_method            = "Dynamic"
    domain_name_label            = "rdp-${var.project_id}"
}

# RDPhost NIC
resource "azurerm_network_interface" "rdphostnic" {
    name                        = "rdphost-nic"
    location                    = azurerm_resource_group.resourcegroup.location
    resource_group_name         = azurerm_resource_group.resourcegroup.name
    ip_configuration {
        name                          = "rdphost-ip"
        subnet_id                     = azurerm_subnet.internal.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = var.create_eip_rdp_linux_server ? azurerm_public_ip.rdphostpip[0].id : null
    }
}

# RDPhost VM
resource "azurerm_linux_virtual_machine" "rdphost" {
    count = var.rdp_server_enabled == true ? 1 : 0
    name                  = "rdphost"
    location              = azurerm_resource_group.resourcegroup.location
    resource_group_name   = azurerm_resource_group.resourcegroup.name
    network_interface_ids = [azurerm_network_interface.rdphostnic.id]
    size                  = var.rdp_instance_type
    admin_username        = "ubuntu"
    custom_data           = base64encode(file(pathexpand(var.rdp_cloud_init_file)))
    admin_ssh_key {
        username = "ubuntu"
        public_key = file(pathexpand(var.ssh_pub_key_path))
    }
    os_disk {
        name              = "rdphost-os-disk"
        caching           = "ReadWrite"
        disk_size_gb      = "100"
        storage_account_type = "Standard_LRS"
    }
    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }
    boot_diagnostics {
      storage_account_uri = azurerm_storage_account.storageaccount.primary_blob_endpoint
    }
}

resource "azurerm_network_security_group" "rdphostnsg" {
  name                = "allow_rdphost"
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name
  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "ssh_rdp"
    priority                   = 100
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*" // TODO: limit to client_cidr_block
    destination_port_ranges    = [22, 3389]
    destination_address_prefix = azurerm_network_interface.rdphostnic.private_ip_address
  }
}

resource "azurerm_network_interface_security_group_association" "nsgforrdphost" {
  network_interface_id      = azurerm_network_interface.rdphostnic.id
  network_security_group_id = azurerm_network_security_group.rdphostnsg.id
}
