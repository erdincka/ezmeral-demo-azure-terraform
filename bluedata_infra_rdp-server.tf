/******************* Templates ********************/

data "template_file" "hcp_desktop_link" {
  template = file("${path.module}/${var.downstream_repo_dir}/modules/module-rdp-server-linux/Templates/HCP.admin.desktop.tpl")
  vars = {
    controller_private_ip = azurerm_network_interface.controllernic.private_ip_address
  }
}

data "template_file" "mcs_desktop_link" {
  template = file("${path.module}/${var.downstream_repo_dir}/modules/module-rdp-server-linux/Templates/MCS.admin.desktop.tpl")
  vars = {
    controller_private_ip = azurerm_network_interface.controllernic.private_ip_address
  }
}

data "template_file" "hcp_links_desktop_link" {
  template = file("${path.module}/${var.downstream_repo_dir}/modules/module-rdp-server-linux/Templates/startup.desktop.tpl")
  vars = {
    controller_private_ip = azurerm_network_interface.controllernic.private_ip_address
  }
}
# Password generator
resource "random_password" "rdp_admin_password" {
  length = 16
  special = true
  override_special = "_%@"
}

# Public IP
resource "azurerm_public_ip" "rdp_serverpip" {
    count = var.create_eip_rdp_linux_server ? 1 : 0
    name                         = "rdp_server-pip"
    location                     = azurerm_resource_group.resourcegroup.location
    resource_group_name          = azurerm_resource_group.resourcegroup.name
    allocation_method            = "Static"
    domain_name_label            = "rdp-${var.project_id}"
}

# NIC
resource "azurerm_network_interface" "rdp_servernic" {
    name                        = "rdp_server-nic"
    location                    = azurerm_resource_group.resourcegroup.location
    resource_group_name         = azurerm_resource_group.resourcegroup.name
    ip_configuration {
        name                          = "rdp_server-ip"
        subnet_id                     = azurerm_subnet.internal.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = var.create_eip_rdp_linux_server ? azurerm_public_ip.rdp_serverpip[0].id : null
    }
}

# VM
resource "azurerm_linux_virtual_machine" "rdp_server" {
    count = var.rdp_server_enabled == true ? 1 : 0
    name                  = "rdp-${var.project_id}"
    location              = azurerm_resource_group.resourcegroup.location
    resource_group_name   = azurerm_resource_group.resourcegroup.name
    network_interface_ids = [azurerm_network_interface.rdp_servernic.id]
    size                  = var.rdp_instance_type
    admin_username        = "ubuntu"
    admin_password        = random_password.rdp_admin_password.result
    disable_password_authentication = false
    custom_data           = base64encode(file(pathexpand(var.rdp_cloud_init_file)))
    admin_ssh_key {
        username = "ubuntu"
        public_key = file(pathexpand(var.ssh_pub_key_path))
    }
    os_disk {
        name              = "rdp_server-os-disk"
        caching           = "ReadWrite"
        disk_size_gb      = 100
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
    provisioner "file" {
      connection {
        type        = "ssh"
        user        = "ubuntu"
        host        = data.azurerm_public_ip.rdp_public_ip.ip_address
        private_key = file(var.ssh_prv_key_path)
        agent       = false
      }
      source        = "${path.module}/${var.downstream_repo_dir}/modules/module-rdp-server-linux/Desktop"
      destination   = "/home/ubuntu"
    
    }

    provisioner "file" {
      connection {
        type        = "ssh"
        user        = "ubuntu"
        host        = data.azurerm_public_ip.rdp_public_ip.ip_address
        private_key = file(var.ssh_prv_key_path)
        agent       = false
      }
      content        = data.template_file.mcs_desktop_link.rendered
      destination   = "/home/ubuntu/Desktop/MCS.admin.desktop"
    }

    provisioner "file" {
      connection {
        type        = "ssh"
        user        = "ubuntu"
        host        = data.azurerm_public_ip.rdp_public_ip.ip_address
        private_key = file(var.ssh_prv_key_path)
        agent       = false
      }
      content        = data.template_file.hcp_desktop_link.rendered
      destination   = "/home/ubuntu/Desktop/HCP.admin.desktop"
    }

    provisioner "file" {
      connection {
        type        = "ssh"
        user        = "ubuntu"
        host        = data.azurerm_public_ip.rdp_public_ip.ip_address
        private_key = file(var.ssh_prv_key_path)
        agent       = false
      }
      content        = data.template_file.hcp_links_desktop_link.rendered
      destination   = "/home/ubuntu/Desktop/startup.desktop"
    }

    // 'enable' desktop icons 
    provisioner "remote-exec" {
      connection {
        type        = "ssh"
        user        = "ubuntu"
        host        = data.azurerm_public_ip.rdp_public_ip.ip_address
        private_key = file(var.ssh_prv_key_path)
        agent       = false
      }
      inline = [
        //"sudo chown ubuntu:ubuntu /home/ubuntu/.local/share/gvfs-metadata/home*",
        "while [ ! -d /home/ubuntu/Desktop ]; do sleep 2; echo -n .; done",
        "sudo chmod +x /home/ubuntu/Desktop/*.desktop",
        // set firefox to autostart  
        "sudo cp Desktop/startup.desktop /etc/xdg/autostart/",
      ]
    }

    provisioner "file" {
      connection {
        type        = "ssh"
        user        = "ubuntu"
        host        = data.azurerm_public_ip.rdp_public_ip.ip_address
        private_key = file(var.ssh_prv_key_path)
        agent       = false
      }
      destination   = "/home/ubuntu/hcp-ca-cert.pem"
      content       = var.ca_cert
    }

    provisioner "file" {
      connection {
        type        = "ssh"
        user        = "ubuntu"
        host        = data.azurerm_public_ip.rdp_public_ip.ip_address
        private_key = file(var.ssh_prv_key_path)
        agent       = false
      }
      source        = "${path.module}/${var.downstream_repo_dir}/modules/module-rdp-server-linux/ca-certs-setup.sh"
      destination   = "/tmp/ca-certs-setup.sh"
    }

    provisioner "remote-exec" {
      connection {
        type        = "ssh"
        user        = "ubuntu"
        host        = data.azurerm_public_ip.rdp_public_ip.ip_address
        private_key = file(var.ssh_prv_key_path)
        agent       = false
      }
      inline = [
        "chmod +x /tmp/ca-certs-setup.sh",
        "/tmp/ca-certs-setup.sh ${azurerm_network_interface.controllernic.private_ip_address}",
      ]
    }
}

resource "azurerm_network_security_group" "rdp_servernsg" {
  name                = "allow_rdp_server"
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
    destination_address_prefix = azurerm_network_interface.rdp_servernic.private_ip_address
  }
}

resource "azurerm_network_interface_security_group_association" "nsgforrdp_server" {
  network_interface_id      = azurerm_network_interface.rdp_servernic.id
  network_security_group_id = azurerm_network_security_group.rdp_servernsg.id
}

data "azurerm_public_ip" "rdp_public_ip" {
  name                = azurerm_public_ip.rdp_serverpip[0].name
  resource_group_name = azurerm_resource_group.resourcegroup.name
}
