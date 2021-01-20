#!/usr/bin/env bash

downstream_repodir="./hcp-demo-env-aws-terraform"

# remove ssh keys
grep "ssh -o" ./generated/output.json | cut -d'@' -f2 | cut -d'"' -f1 | xargs -n 1 ssh-keygen -R
# destroy resources
terraform destroy --auto-approve=true -var-file=./etc/bluedata_infra.tfvars -var-file=./etc/my.tfvars
# clean up
rm -rf "./generated"
[ -d ${downstream_repodir} ] && rm -rf "${downstream_repodir}"
