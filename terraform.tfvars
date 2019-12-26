# Azure Subscription and Service Principle for azurerm provider or use ./setup_azure.sh (please refer to README.md)
subscription_id = "***REMOVED***"
client_id       = "***REMOVED***"
client_secret   = "***REMOVED***"
tenant_id       = "***REMOVED***"

#
# Select an appropriate region
#
region = "westus2"

#
# Set this to something meaningful.  it is used as a tag in aws 
#

project_id         = "ekaya-scratch"
user               = "ekaya"

# specify how many BlueData workers you want
worker_count = 3

# you may need to change the instance types if the ones
# listed below are not available in your region

gtw_instance_type  = "Standard_D1_v3" # "Standard_D16_v3"
ctr_instance_type  = "Standard_D1_v3" # "Standard_D16_v3"
wkr_instance_type  = "Standard_D1_v3" # "Standard_D16_v3"
nfs_instance_type  = "Standard_D1_v3" # "Standard_D2_v3"
ad_instance_type   = "Standard_D1_v3" # "Standard_D2_v3"

# Environment
ssh_pub_key_path = "~/.ssh/id_rsa.pub"
