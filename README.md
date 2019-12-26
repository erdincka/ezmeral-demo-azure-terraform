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


