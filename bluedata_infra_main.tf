provider "azurerm" {
    features {}
    subscription_id = var.subscription_id
    client_id = var.client_id
    client_secret = var.client_secret
    tenant_id = var.tenant_id
}

/***************** config ********************/
data "template_file" "cli_logging_config_template" {
  template = file("etc/hpecp_cli_logging.conf")
  vars = {
    hpecp_cli_log_file = "${abspath(path.module)}/generated/hpecp_cli.log"
  }
}

resource "local_file" "cli_logging_config_file" {
  filename = "${path.module}/generated/hpecp_cli_logging.conf"
  content =  data.template_file.cli_logging_config_template.rendered
}

resource "local_file" "ca-cert" {
  filename = "${path.module}/generated/ca-cert.pem"
  content =  var.ca_cert
}

resource "local_file" "ca-key" {
  filename = "${path.module}/generated/ca-key.pem"
  content =  var.ca_key
}

/***************** config ********************/


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
    name                = "${var.project_id}-network"
    location            = azurerm_resource_group.resourcegroup.location
    resource_group_name = azurerm_resource_group.resourcegroup.name
    address_space       = ["10.0.0.0/16"]
}

# Create the subnet
resource "azurerm_subnet" "internal" {
    name                 = "${var.project_id}-internal"
    resource_group_name  = azurerm_resource_group.resourcegroup.name
    virtual_network_name = azurerm_virtual_network.network.name
    address_prefixes       = ["10.0.1.0/24"]
}

# resource "azurerm_network_security_group" "nsg" {
#     name                = "${var.project_id}-nsg"
#     location            = azurerm_resource_group.resourcegroup.location
#     resource_group_name = azurerm_resource_group.resourcegroup.name
    
#     security_rule {
#       name = "AllowAll"
#       priority = 100
#       direction = "Inbound"
#       access         = "Allow"
#       protocol = "Tcp"
#       source_port_range       = "*"
#       destination_port_ranges     = [22, 80, 443, 3389]
#       source_address_prefix      = "Internet"
#       destination_address_prefix = "*"
#     }
# }

# Random ID generator for storage account
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.resourcegroup.name
    }
    byte_length = 8
}

# Storage account for all resources
resource "azurerm_storage_account" "storageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.resourcegroup.name
    location                    = azurerm_resource_group.resourcegroup.location
    account_replication_type    = "LRS"
    account_tier                = "Standard"
}
