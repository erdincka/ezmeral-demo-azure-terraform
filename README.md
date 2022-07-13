# ECP Azure-Terraform

## No longer maintained, replaced with [Ezdemo](https://github.com/HewlettPackard/ezdemo)


## Overview

### Setup HPE Ezmeral Container Platform (ECP) demo environment on Azure with Terraform

This project makes it easy to setup HPE Container Platform demo/trial environments on Azure, using [AWS demo scripts](https://github.com/bluedata-community/bluedata-demo-env-aws-terraform) to enable same learning/trial functionality.

### Pre-requisities

- Azure CLI [download](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

- Terraform [download](https://www.terraform.io/downloads.html)

### Initialize with your Azure credentials

- Login to Azure

```
az login
```
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
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/${SUBSCRIPTION_ID}" -o table
```

The output should be used to fill in provider details in ./etc/bluedata_infra.tfvars
Save appId, password, sp_name & tenant from response

```

AppId                                 DisplayName                    Name                                  Password                              Tenant
------------------------------------  -----------------------------  ------------------------------------  ------------------------------------  ------------------------------------
00000000-0000-0000-0000-000000000000  azure-cli-2019-12-10-07-12-40  http://azure-cli-2019-12-10-07-12-40  00000000-0000-0000-0000-000000000000  00000000-0000-0000-0000-000000000000

```

### Update variables for your environment

#### Update ./etc/bluedata_infra.tfvars

- region: {AZURE_REGION}
- subscription_id: ${SUBSCRIPTION_ID}
- client_id: {AppId}
- client_secret: {Password}
- tenant_id: {Tenant}
- epic_dl_url: 
- (OPTIONAL)
  - Change project_id (which will be used as resource_group_name and prefix for created resources)
  - Change options (create AD server, NFS server, External MapR cluster (not implemented yet), add GPU nodes (not implemented yet) etc)
  - Change Azure VM sizes to fit in your region availability

## Deploy
```
./bin/azure_create_new.sh
```
This step might take somewhere between 45 minutes to 2 hours, please monitor the script output, and follow up guides in upstream [repo](https://github.com/hpe-container-platform-community/hcp-demo-env-aws-terraform#further-documentation).

## Customizing resources and scenarios

You can edit ./etc/bluedata_infra.tfvars to choose some options, such as enabling RDP server, AD server, NFS server etc.

If you want clean installation and not all the demo scenarios, comment out following line in ./bin/azure_create_new.sh:
```
mv "./etc/postcreate.sh_template" "./etc/postcreate.sh"
```

If you wish to re-configure, make changes and run ```terraform apply``` to reflect these changes in the resources.

Alternatively, you can switch to "./hcp-demo-env-aws-terraform" folder and run scripts in ./bin directory (please run scripts on this upstream repo top level directory, ie, within ./hcp-demo-env-aws-terraform).

For example to install all available catalog images, you can run:
./bin/experimental/epic_catalog_image_install_all.sh


## TODO
- [ ] Enable GPU nodes
- [ ] Enable MapR cluster creation
- [ ] Enable AKS creation

Please send comments/issues/suggestions through github (as we are not monitoring other places, such as Stackoverflow etc).

