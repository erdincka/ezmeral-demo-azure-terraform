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
# Set this to something meaningful.  it is used as a tag in aws 
#

project_id         = "bluedata"
user               = "erdincka"

# specify how many BlueData workers you want
worker_count = 3

# you may need to change the instance types if the ones
# listed below are not available in your region

ctr_instance_type  = "Standard_A4m_v2"
gtw_instance_type  = "Standard_A4m_v2" # "Standard_D16_v3"
wkr_instance_type  = "Standard_A4m_v2" # "Standard_D16_v3"
nfs_instance_type  = "Standard_A4m_v2" # "Standard_D2_v3"
ad_instance_type   = "Standard_A4m_v2" # "Standard_D2_v3"

# Environment
ssh_pub_key_path = "~/.ssh/id_rsa.pub"
ssh_prv_key_path = "~/.ssh/id_rsa"
selinux_disabled = false
cloud_init_file  = "./cloud-init.yaml"

#temp_password = "UxmD4R68nZnvr3Zr"
// pass_auth_disabled = false
bluedata_image_url = "***REMOVED***"
