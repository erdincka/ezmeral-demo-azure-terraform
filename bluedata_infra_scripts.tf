resource "local_file" "ssh_controller" {
  filename = "${path.module}/generated/ssh_controller.sh"
  content = <<-EOF
     #!/bin/bash
     source "${path.module}/${var.downstream_repo_dir}/scripts/variables.sh"
     ssh -o StrictHostKeyChecking=no -i "${var.ssh_prv_key_path}" centos@$CTRL_PUB_IP "$@"
  EOF
}

resource "local_file" "ssh_controller_private" {
  filename = "${path.module}/generated/ssh_controller_private.sh"
  content = <<-EOF
     #!/bin/bash
     source "${path.module}/${var.downstream_repo_dir}/scripts/variables.sh"
     ssh -o StrictHostKeyChecking=no -i "${var.ssh_prv_key_path}" centos@$CTRL_PRV_IP "$@"
  EOF
}

resource "local_file" "ssh_gateway" {
  filename = "${path.module}/generated/ssh_gateway.sh"
  content = <<-EOF
     #!/bin/bash
     source "${path.module}/${var.downstream_repo_dir}/scripts/variables.sh"
     ssh -o StrictHostKeyChecking=no -i "${var.ssh_prv_key_path}" centos@$GATW_PUB_IP "$@"
  EOF
}

resource "local_file" "ssh_ad" {
  filename = "${path.module}/generated/ssh_ad.sh"
  content = <<-EOF
     #!/bin/bash
     source "${path.module}/${var.downstream_repo_dir}/scripts/variables.sh"
     ssh -o StrictHostKeyChecking=no -i "${var.ssh_prv_key_path}" centos@$AD_PUB_IP "$@"
  EOF
}

resource "local_file" "ssh_worker" {
  count = var.worker_count

  filename = "${path.module}/generated/ssh_worker_${count.index}.sh"
  content = <<-EOF
     #!/bin/bash
     source "${path.module}/${var.downstream_repo_dir}/scripts/variables.sh"
     ssh -o StrictHostKeyChecking=no -i "${var.ssh_prv_key_path}" centos@$${WRKR_PUB_IPS[${count.index}]} "$@"
  EOF
}

resource "local_file" "ssh_worker_gpu" {
  count = var.gpu_worker_count

  filename = "${path.module}/generated/ssh_worker_gpu_${count.index}.sh"
  content = <<-EOF
     #!/bin/bash
     source "${path.module}/${var.downstream_repo_dir}/scripts/variables.sh"
     ssh -o StrictHostKeyChecking=no -i "${var.ssh_prv_key_path}" centos@$${WRKR_GPU_PUB_IPS[${count.index}]} "$@"
  EOF
}

resource "local_file" "ssh_mapr_cluster_1_host" {
  count = var.mapr_cluster_1_count

  filename = "${path.module}/generated/ssh_mapr_cluster_1_host_${count.index}.sh"
  content = <<-EOF
     #!/bin/bash
     source "${path.module}/${var.downstream_repo_dir}/scripts/variables.sh"
     ssh -o StrictHostKeyChecking=no -i "${var.ssh_prv_key_path}" ubuntu@$${MAPR_CLUSTER1_HOSTS_PUB_IPS[${count.index}]} "$@"
  EOF
}

resource "local_file" "ssh_mapr_cluster_2_host" {
  count = var.mapr_cluster_2_count

  filename = "${path.module}/generated/ssh_mapr_cluster_2_host_${count.index}.sh"
  content = <<-EOF
     #!/bin/bash
     source "${path.module}/${var.downstream_repo_dir}/scripts/variables.sh"
     ssh -o StrictHostKeyChecking=no -i "${var.ssh_prv_key_path}" ubuntu@$${MAPR_CLUSTER2_HOSTS_PUB_IPS[${count.index}]} "$@"
  EOF
}

resource "local_file" "ssh_workers" {
  count = var.worker_count
  filename = "${path.module}/generated/ssh_worker_all.sh"
  content = <<-EOF
     #!/bin/bash
     source "${path.module}/${var.downstream_repo_dir}/scripts/variables.sh"
     if [[ $# -lt 1 ]]
     then
        echo "You must provide at least one command, e.g."
        echo "./generated/ssh_worker_all.sh CMD1 CMD2 CMDn"
        exit 1
     fi
     for HOST in $${WRKR_PUB_IPS[@]}; 
     do
      ssh -o StrictHostKeyChecking=no -i "${var.ssh_prv_key_path}" centos@$HOST "$@"
     done
  EOF
}

resource "local_file" "ssh_all" {
  count = var.worker_count
  filename = "${path.module}/generated/ssh_all.sh"
  content = <<-EOF
     #!/bin/bash
     source "${path.module}/${var.downstream_repo_dir}/scripts/variables.sh"
     if [[ $# -lt 1 ]]
     then
        echo "You must provide at least one command, e.g."
        echo "./generated/ssh_worker_all.sh CMD1 CMD2 CMDn"
        exit 1
     fi
     ssh -o StrictHostKeyChecking=no -i "${var.ssh_prv_key_path}" centos@$CTRL_PUB_IP "$@"
     ssh -o StrictHostKeyChecking=no -i "${var.ssh_prv_key_path}" centos@$GATW_PUB_IP "$@"
     for HOST in $${WRKR_PUB_IPS[@]};
     do
        ssh -o StrictHostKeyChecking=no -i "${var.ssh_prv_key_path}" centos@$HOST "$@"
     done
  EOF
}

resource "local_file" "mcs_credentials" {
  filename = "${path.module}/generated/mcs_credentials.sh"
  content = <<-EOF
     #!/bin/bash
     source "${path.module}/${var.downstream_repo_dir}/scripts/variables.sh"
     echo 
     echo ==== MCS Credentials ====
     echo 
     echo IP Addr:  $CTRL_PUB_IP
     echo Username: admin
     echo Password: $(ssh -o StrictHostKeyChecking=no -i "${var.ssh_prv_key_path}" centos@$CTRL_PUB_IP "cat /opt/bluedata/mapr/conf/mapr-admin-pass")
     echo
  EOF
}

resource "local_file" "fix_restart_auth_proxy" {
  filename = "${path.module}/generated/fix_restart_auth_proxy.sh"
  content = <<-EOF
     #!/bin/bash
     source "${path.module}/${var.downstream_repo_dir}/scripts/variables.sh"
     ssh -o StrictHostKeyChecking=no -i "${var.ssh_prv_key_path}" centos@$CTRL_PUB_IP 'docker restart $(docker ps | grep "epic/authproxy" | cut -d " " -f1); docker ps'
  EOF
}

resource "local_file" "fix_restart_webhdfs" {
  filename = "${path.module}/generated/fix_restart_webhdfs.sh"
  content = <<-EOF
     #!/bin/bash
     source "${path.module}/${var.downstream_repo_dir}/scripts/variables.sh"
     ssh -o StrictHostKeyChecking=no -i "${var.ssh_prv_key_path}" centos@$CTRL_PUB_IP 'docker restart $(docker ps | grep "epic/webhdfs" | cut -d " " -f1); docker ps'
  EOF
}

resource "local_file" "platform_id" {
  filename = "${path.module}/generated/platform_id.sh"
  content = <<-EOF
     #!/bin/bash
     source "${path.module}/${var.downstream_repo_dir}/scripts/variables.sh"
     curl -s -k https://$CTRL_PUB_IP:8080/api/v1/license | python3 -c 'import json,sys;obj=json.load(sys.stdin);print (obj["uuid"])'
  EOF
}

resource "local_file" "rdp_linux_credentials" {
  filename = "${path.module}/generated/rdp_credentials.sh"
  count = var.rdp_server_enabled == true && var.rdp_server_operating_system == "LINUX" ? 1 : 0
  content = <<-EOF
    #!/bin/bash
    HIDE_WARNINGS=$${HIDE_WARNINGS:-0}
    source "${path.module}/${var.downstream_repo_dir}/scripts/variables.sh"
    echo 
    if [[ $RDP_PUB_IP == "" && $HIDE_WARNINGS == 0 ]]; then
      echo "WARNING: Unable to display RDP credentials because RDP_PUB_IP could not be retrieved - is the instance running?"
      exit
    fi
    echo ================================= RDP Credentials  =====================================
    echo 
    if [[ "$CREATE_EIP_RDP_LINUX_SERVER" == "False" ]]; then
    echo Note: The RDP IP addresses listed below change each time the RDP instance is restarted.
    else
    echo Note: The RDP IP addresses listed below are provided by an EIP and are static.
    fi
    echo
    echo Host IP:   "$RDP_PUB_IP"
    echo Web Url:   "https://$RDP_PUB_IP (Chrome is recommended)"
    echo RDP URL:   "rdp://full%20address=s:$RDP_PUB_IP:3389&username=s:ubuntu"
    echo Username:  "ubuntu"
    echo Password:  "${random_password.rdp_admin_password.result}"
    echo 
    echo ========================================================================================
    echo
  EOF
}

resource "local_file" "rdp_over_ssh" {
  filename = "${path.module}/generated/rdp_over_ssh.sh"
  count = var.rdp_server_enabled == true && var.rdp_server_operating_system == "LINUX" ? 1 : 0
  content = <<-EOF
    #!/bin/bash
    source "${path.module}/${var.downstream_repo_dir}/scripts/variables.sh"
    echo "Portforwarding 3389 on 127.0.0.1 to RDP Server [CTRL-C to cancel]"
    ssh -o StrictHostKeyChecking=no -i "${var.ssh_prv_key_path}" ubuntu@$RDP_PUB_IP "$@" -L3389:localhost:3389 -N
  EOF
}

resource "local_file" "rdp_post_setup" {
  filename = "${path.module}/generated/rdp_post_provision_setup.sh"
  count = var.rdp_server_enabled == true && var.rdp_server_operating_system == "LINUX" ? 1 : 0
  content = <<-EOF
    #!/bin/bash
    source "${path.module}/${var.downstream_repo_dir}/scripts/variables.sh"
    ssh -o StrictHostKeyChecking=no -i "${var.ssh_prv_key_path}" ubuntu@$RDP_PUB_IP "sudo fastdd"  
  EOF
}

resource "local_file" "ssh_rdp_linux" {
  filename = "${path.module}/generated/ssh_rdp_linux_server.sh"
  count = var.rdp_server_enabled == true && var.rdp_server_operating_system == "LINUX" ? 1 : 0
  content = <<-EOF
    #!/bin/bash
    source "${path.module}/${var.downstream_repo_dir}/scripts/variables.sh"
    ssh -o StrictHostKeyChecking=no -i "${var.ssh_prv_key_path}" ubuntu@$RDP_PUB_IP "$@"    
  EOF
}

resource "local_file" "sftp_rdp_linux" {
  filename = "${path.module}/generated/sftp_rdp_linux_server.sh"
  count = var.rdp_server_enabled == true && var.rdp_server_operating_system == "LINUX" ? 1 : 0
  content = <<-EOF
    #!/bin/bash
    source "${path.module}/${var.downstream_repo_dir}/scripts/variables.sh"
    sftp -o StrictHostKeyChecking=no -i "${var.ssh_prv_key_path}" ubuntu@$RDP_PUB_IP    
  EOF
}

resource "local_file" "whatismyip" {
  filename = "${path.module}/generated/whatismyip.sh"

  content = <<-EOF
     #!/bin/bash
     echo $(curl -s http://ifconfig.me/ip)/32
  EOF
}

resource "local_file" "get_public_endpoints" {
  filename = "${path.module}/generated/get_public_endpoints.sh"
  content  = <<-EOF
    #!/usr/bin/env bash
    az vm list -d -o table
    ## TODO: better output and useful details
  EOF
}
