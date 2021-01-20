provider "azurerm" {
    features {}
    subscription_id = var.subscription_id
    client_id = var.client_id
    client_secret = var.client_secret
    tenant_id = var.tenant_id
}

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

# Create a resource group
resource "azurerm_resource_group" "resourcegroup" {
  name     = "${var.project_id}-rg"
  location = var.region
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "network" {
    name                = "${var.project_id}-network"
    location            = azurerm_resource_group.resourcegroup.location
    resource_group_name = azurerm_resource_group.resourcegroup.name
    address_space       = [var.vpc_cidr_block]
}

# Create the subnet
resource "azurerm_subnet" "internal" {
    name                 = "${var.project_id}-internal"
    resource_group_name  = azurerm_resource_group.resourcegroup.name
    virtual_network_name = azurerm_virtual_network.network.name
    address_prefixes       = [var.subnet_cidr_block]
}

# Storage account for all resources
resource "azurerm_storage_account" "storageaccount" {
    name                        = "${replace(lower(var.project_id), "/[^a-z]/", "")}storage"
    resource_group_name         = azurerm_resource_group.resourcegroup.name
    location                    = azurerm_resource_group.resourcegroup.location
    account_replication_type    = "LRS"
    account_tier                = "Standard"
}
