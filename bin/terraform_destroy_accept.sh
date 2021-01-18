#!/usr/bin/env bash
aws_repodir="./hcp-demo-env-aws-terraform"

terraform destroy -var-file=./etc/bluedata_infra.tfvars -var-file=./etc/my.tfvars -auto-approve=true \
  && rm -rf "${aws_repodir}/generated"
