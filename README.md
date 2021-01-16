# Setup HPE Ezmeral Container Platform (ECP) demo environment on Azure with Terraform

This aims to create a minimal demo environment in Microsoft Azure to run HPE Ezmeral Container Platform 5.x installation.

Re-utilizing work of https://github.com/bluedata-community/bluedata-demo-env-aws-terraform

## Initialize

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
00000000-0000-0000-0000-000000000000  azure-cli-2019-12-10-07-12-40  http://azure-cli-2019-12-10-07-12-40  00000000-0000-0000-0000-000000000000  00000000-0000-0000-0000-000000000000

```
### Download terraform

[Terraform](https://www.terraform.io/downloads.html)

### Update terraform.tfvars for following:
- region: {AZURE_REGION}
- subscription_id: ${SUBSCRIPTION_ID}
- client_id: {AppId}
- client_secret: {Password}
- tenant_id: {Tenant}

### Update cloud-init.yaml
- PUB_KEY (replace with the contents of ~/.ssh/id_rsa.pub)

## Plan and Deploy using Terraform

```
terraform init
```

```
terraform plan -o plan.tfout
```

### Deploy
```
terraform apply -auto-approve "plan.tfout"
```

### Save results
```
terraform output > terraform.output
```

## Prepare for Installation

### Update scripts

#### Edit scripts/jumphost_init.sh

Replace PASSWORD with the *jumphost_password* from terraform.output file.

**Replace bluedata if you changed user parameter if terraform.tfvars file**

Replace DOMAINS with "internal.cloudapp.net,localhost, *jumphost_public_dns_name*" (replace with value from terraform.output file)

Replace IPS with "*jumphost_public_ip*,*jumphost_private_ip*,*controller_private_ip*,*gateway_private_ip*,*worker_private_ips(comma separated list)*,127.0.0.1" (replace with values from terraform.output file)

**DOMAINS and IPS should be separated by comma and not space**

#### Edit scripts/bluedata_install.sh

Replace all occurances of these placeholders with corresponding values

- EPIC_FILENAME
- EPIC_DL_URL (full url to download installation file)
- CONTROLLER_IP (from terraform.output file **controller_private_ip**)

### Prepare hosts for Installation

- Copy your (or generated) private key to Jumphost

```
scp ~/.ssh/id_rsa.pub bluedata@<jumphost_public_ip>:~/private.key
```

- Copy scripts/jumphost_init.sh to Jumphost
```
scp scripts/jumphost_init.sh bluedata@>jumphost_public_ip>:~/
```

- Execute init script at Jumphost (and set file permissions)

```
ssh -T bluedata@<jumphost_public_ip> "chmod 600 ~/private.key; chmod +x ./*.sh; ./jumphost_init.sh"
```

- Copy and run host_init.sh on all other hosts (from Jumphost)

Replace IPs with values from terraform.output (use private IPs)
```
for host in [<controller_private_ip>, <gateway_private_ip>, *<worker_private_ips>]; 
do; 
  scp -i ./private.key private.key ${host}:~/private.key
  scp -i ./private.key host_init.sh ${host}:~/
  ssh -i ./private.key "chmod +x ~/*.sh; chmod 600 ~/private.key; ./host_init.sh"
done;
```

- Init controller (from Jumphost)

Copy certificate files and run install script

```
scp internal.cloudapp.net/*.pem <controller_private_ip>:~/
ssh <controller_private_ip> <<EOF
  mv cert.pem cacert.pem
  mv key.pem cakey.pem
  chmod 600 *.pem
  sudo ./bluedata_install.sh
EOF

```

# TODO:

[ ] Disable firewall ports except GW (https) and controller (ssh)

[ ] Download AWS repo and run scripts directly within
