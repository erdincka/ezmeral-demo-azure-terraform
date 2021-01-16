# Setup HPE Ezmeral Container Platform (ECP) demo environment on Azure with Terraform

This aims to create a minimal demo environment in Microsoft Azure to run HPE Ezmeral Container Platform 5.x installation.

Re-utilizing work of https://github.com/bluedata-community/bluedata-demo-env-aws-terraform

## Initial configuration

### Download AzureCLI 

[Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

### Configure AzureCLI
Login to Azure:
```
az login
```

<!-- Query subscription ID
```
az account list --query "[].{name:name, subscriptionId:id, tenantId:tenantId}"
``` -->

Set environment variable to the subscription you want to use (following line works with a single subscription only)
```
SUBSCRIPTION_ID=`az account list --query "[].{sub:id}" -o tsv`
```

Set subscription to use
```
az account set --subscription="${SUBSCRIPTION_ID}"
```

Create a service principle to be used for this deployment
```
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/${SUBSCRIPTION_ID}"
```

The output should be used to fill in provider details in terraform.tfvars
Save appId, password, sp_name & tenant from response

```

AppId                                 DisplayName                    Name                                  Password                              Tenant
------------------------------------  -----------------------------  ------------------------------------  ------------------------------------  ------------------------------------
***REMOVED***  azure-cli-2019-12-10-07-12-40  http://azure-cli-2019-12-10-07-12-40  ***REMOVED***  ***REMOVED***

```
### Download terraform

[Terraform](https://www.terraform.io/downloads.html)

### Update terraform.tfvars for following:
- region: {AZURE_REGION}
- subscription_id: ${SUBSCRIPTION_ID}
- client_id: {AppId}
- client_secret: {Password}
- tenant_id: {Tenant}

### Update cloud-init-ctr.yaml
- PUB_KEY (replace with the contents of ~/.ssh/id_rsa.pub)
- PRV_KEY (replace with the contents of ~/.ssh/id_rsa)
- EPIC_FILENAME
- EPIC_DL_URL (full url to download installation file)

## Plan and Deploy using Terraform

```
terraform init
```

```
terraform plan -o plan.tfout
```

### Deploy
```
terraform apply
```

### Install
```
ssh -o StrictHostKeyChecking=no -T <CTRL_IP> "./bluedata_install.sh"
```


# TODO:

[ ] Disable firewall ports except GW (https) and controller (ssh)

[ ] Full functionality with AWS scripts
