
# Gateway Public IP
resource "azurerm_public_ip" "gatewaypip" {
    name                         = "gateway-pip"
    location                     = azurerm_resource_group.resourcegroup.location
    resource_group_name          = azurerm_resource_group.resourcegroup.name
    allocation_method            = "Dynamic"
    domain_name_label            = var.project_id
}

# Gateway NIC
resource "azurerm_network_interface" "gatewaynic" {
    name                        = "gateway-nic"
    location                    = azurerm_resource_group.resourcegroup.location
    resource_group_name         = azurerm_resource_group.resourcegroup.name
    ip_configuration {
        name                          = "gateway-ip"
        subnet_id                     = azurerm_subnet.internal.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.gatewaypip.id
    }
}

# Gateway VM
resource "azurerm_linux_virtual_machine" "gateway" {
    name                  = "gateway-${var.project_id}"
    computer_name         = var.project_id // to avoid gateway name for vnet
    location              = azurerm_resource_group.resourcegroup.location
    resource_group_name   = azurerm_resource_group.resourcegroup.name
    network_interface_ids = [azurerm_network_interface.gatewaynic.id]
    size                  = var.gtw_instance_type
    admin_username        = var.user
    custom_data           = base64encode(file(pathexpand(var.cloud_init_file)))
    admin_ssh_key {
        username = var.user
        public_key = file(pathexpand(var.ssh_pub_key_path))
    }
    os_disk {
        name              = "gateway-os-disk"
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

resource "azurerm_network_security_group" "gatewaynsg" {
  name                = "allow_gateway"
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name
  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "ssh_https"
    priority                   = 100
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*" // TODO: limit to client_cidr_block
    destination_port_ranges    = [22, 443, 8443]
    destination_address_prefix = azurerm_network_interface.gatewaynic.private_ip_address
  }
}

resource "azurerm_network_interface_security_group_association" "nsgforgateway" {
  network_interface_id      = azurerm_network_interface.gatewaynic.id
  network_security_group_id = azurerm_network_security_group.gatewaynsg.id
}
