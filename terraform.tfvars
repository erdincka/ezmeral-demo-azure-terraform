# Azure Subscription and Service Principle for azurerm provider or use ./setup_azure.sh (please refer to README.md)
subscription_id = "***REMOVED***"
client_id       = "***REMOVED***"
client_secret   = "***REMOVED***"
tenant_id       = "***REMOVED***"

#
# Select an appropriate region
#
region = "eastus2"

#
# Set this to something meaningful.  it is used as a tag in Azure
#
project_id         = "bd-demo"
user               = "bluedata"

# you may need to change the instance types if the ones
# listed below are not available in your region

ctr_instance_type  = "Standard_A4m_v2"
gtw_instance_type  = "Standard_A4m_v2"
wkr_instance_type  = "Standard_A4m_v2"
nfs_instance_type  = "Standard_A4m_v2"
ad_instance_type   = "Standard_A4m_v2"

// bluedata_image_url = "***REMOVED***"
