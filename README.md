## How to setup BlueData demo environment on Azure with Terraform

Query subscription ID
az account list --query "[].{name:name, subscriptionId:id, tenantId:tenantId}"

Set environment variable to the subscription you want to use (following line works with a single subscription only)
SUBSCRIPTION_ID=`az account list --query "[].{sub:id}" -o tsv`

Set subscription to use
az account set --subscription="${SUBSCRIPTION_ID}"

Create a service principle to be used for this deployment
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/${SUBSCRIPTION_ID}"

The output should be used to fill in provider details in terraform.tfvars
Save appId, password, sp_name & tenant from response

AppId                                 DisplayName                    Name                                  Password                              Tenant
------------------------------------  -----------------------------  ------------------------------------  ------------------------------------  ------------------------------------
***REMOVED***  azure-cli-2019-12-10-07-12-40  http://azure-cli-2019-12-10-07-12-40  ***REMOVED***  ***REMOVED***


create id_rsa.pub ("ssh-keygen -t rsa") to be copied to the VMs (will be used for ssh connectivity)

Once VMs created, create ssh keys on controller & copy over to other nodes
"ssh-keygen -t rsa" "ssh_copy_id user@gateway/workerN"
Update security (disable pass auth)
Disable firewall ports except GW (https) and controller (ssh)

Disable services?

Setup se_linux?

Copy install image

Setup bluedata controller & workers

