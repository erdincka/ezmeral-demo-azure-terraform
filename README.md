## How to setup BlueData demo environment on Azure with Terraform

This aims to create a minimal demo environment in Microsoft Azure to run BlueData 4.0 installation.

Taken from the work of https://github.com/bluedata-community/bluedata-demo-env-aws-terraform

Run terraform to deploy resources in Azure, and then ssh to controller & run "bluedata_install.sh" script to continue with installation.

Query subscription ID
az account list --query "[].{name:name, subscriptionId:id, tenantId:tenantId}"

Set environment variable to the subscription you want to use (following line works with a single subscription only)
SUBSCRIPTION_ID=`az account list --query "[].{sub:id}" -o tsv`

Set subscription to use
[code] az account set --subscription="${SUBSCRIPTION_ID}" [/code]

Create a service principle to be used for this deployment
[code] az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/${SUBSCRIPTION_ID}" [/code]

The output should be used to fill in provider details in terraform.tfvars
Save appId, password, sp_name & tenant from response

AppId                                 DisplayName                    Name                                  Password                              Tenant
------------------------------------  -----------------------------  ------------------------------------  ------------------------------------  ------------------------------------
***REMOVED***  azure-cli-2019-12-10-07-12-40  http://azure-cli-2019-12-10-07-12-40  ***REMOVED***  ***REMOVED***


TODO:

Disable firewall ports except GW (https) and controller (ssh)

