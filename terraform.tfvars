# Azure Subscription and Service Principle for azurerm provider https://docs.microsoft.com/en-us/azure/developer/terraform/get-started-cloud-shell
subscription_id = ""
client_id       = ""
client_secret   = ""
tenant_id       = ""

#
# Select an appropriate region
#
region = "eastus2"

#
# Set this to something meaningful.  it is used as a tag in Azure
#
project_id         = "ecp-demo"
user               = "bluedata"
ssh_pub_key_path   = ""
hcpdomain          = "" # leave empty to use default (or configure terraform to create private DNS resolver and link to private network

# you may need to change the instance types if the ones
# listed below are not available in your region

ctr_instance_type  = "Standard_A4m_v2"
gtw_instance_type  = "Standard_B1ms"
wkr_instance_type  = "Standard_A4m_v2"
jh_instance_type   = "Standard_B2ms"
# nfs_instance_type  = "Standard_A4m_v2"
# ad_instance_type   = "Standard_A4m_v2"
