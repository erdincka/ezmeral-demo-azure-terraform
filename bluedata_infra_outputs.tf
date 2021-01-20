# outputs

# Using workaround for getting public IPs, it cannot be read before attaching to an online VM 
# https://github.com/terraform-providers/terraform-provider-azurerm/issues/764#issuecomment-365019882

## From AWS scripts
output "project_dir" {
  value = abspath(path.module)
}

output "user" {
  value = var.user
}

output "aws_profile" {
  value = var.profile
}

output "aws_region" {
  value = var.region
}

output "subnet_cidr_block" {
  value = var.subnet_cidr_block
}

output "vpc_cidr_block" {
  value = var.vpc_cidr_block
}

## Not used in Azure
# output "deployment_uuid" {
#   value = random_uuid.deployment_uuid.result
# }

output "selinux_disabled" {
  value = var.selinux_disabled
}

output "ssh_pub_key_path" {
  value = var.ssh_pub_key_path
}

output "ssh_prv_key_path" {
  value = var.ssh_prv_key_path
}

output "install_with_ssl" {
  value = var.install_with_ssl
}

output "ca_cert" {
  value = var.ca_cert
}

output "ca_key" {
  value = var.ca_key
}

output "epic_dl_url" {
  value = var.epic_dl_url
}

output "epid_dl_url_needs_presign" {
  value = var.epid_dl_url_needs_presign
}

output "epic_dl_url_presign_options" {
  value = var.epic_dl_url_presign_options
}

output "epic_options" {
  value = var.epic_options
}

output "client_cidr_block" {
 value = var.client_cidr_block
}

output "create_eip_controller" {
  value = var.create_eip_controller
}

output "create_eip_gateway" {
  value = var.create_eip_gateway
}

output "create_eip_rdp_linux_server" {
  value = var.create_eip_rdp_linux_server
}

output "create_eks_cluster" {
  value = var.create_eks_cluster
}

//// Gateway
output "gateway_instance_id" {
    value = azurerm_linux_virtual_machine.gateway.id
}
output "gateway_private_ip" {
    value = azurerm_network_interface.gatewaynic.private_ip_address
}
data "azurerm_public_ip" "gtw_public_ip" {
  name                = azurerm_public_ip.gatewaypip.name
  resource_group_name = azurerm_linux_virtual_machine.gateway.resource_group_name
}
output "gateway_public_ip" {
  value = var.create_eip_gateway ? data.azurerm_public_ip.gtw_public_ip.ip_address : "no public ip for gateway"
}
output "gateway_public_dns" {
    value = var.create_eip_gateway ? "${var.project_id}.${var.region}.cloudapp.azure.com" : "no public dns for gateway"
}
output "gateway_private_dns" {
  value = "${var.project_id}.internal.cloudapp.net"
}

//// Controller
output "controller_instance_id" {
  value = azurerm_linux_virtual_machine.controller.id
}
output "controller_private_ip" {
    value = azurerm_network_interface.controllernic.private_ip_address
}
output "controller_private_dns" {
  value = azurerm_network_interface.controllernic.internal_domain_name_suffix
}
data "azurerm_public_ip" "ctr_public_ip" {
  ### Workaround if create_eip_controller is false (return gateway public ip)
  name                = var.create_eip_controller ? azurerm_public_ip.controllerpip[0].name : azurerm_public_ip.gatewaypip.name
  resource_group_name = azurerm_linux_virtual_machine.controller.resource_group_name
}
output "controller_public_ip" {
  value = data.azurerm_public_ip.ctr_public_ip.ip_address
}
output "controller_public_url" {
  value = var.create_eip_controller ? "https://${data.azurerm_public_ip.ctr_public_ip.fqdn}" : "no public ip for controller"
}
output "controller_public_dns" {
  value = var.create_eip_controller ? data.azurerm_public_ip.ctr_public_ip.fqdn : "no public dns for controller"
}

/// workers
output "workers_instance_id" {
  value = [azurerm_linux_virtual_machine.workers.*.id]
}
output "workers_private_ip" {
  value = [azurerm_network_interface.workernics.*.private_ip_address]
}
output "workers_private_dns" {
  value = [azurerm_network_interface.workernics.*.internal_domain_name_suffix]
}
data "azurerm_public_ip" "wrks_public_ip" {
  count = var.worker_count
  name                = azurerm_public_ip.workerspip[count.index].name
  resource_group_name = azurerm_linux_virtual_machine.workers[count.index].resource_group_name
}
output "workers_public_ip" {
  value = [data.azurerm_public_ip.wrks_public_ip.*.ip_address]
}
output "worker_count" {
  value = [var.worker_count]
}

### TODO: Not implemented
/// GPU workers 
# output "workers_gpu_instance_id" {
#   value = [aws_instance.workers_gpu.*.id]
# }
# output "workers_gpu_public_ip" {
#   value = [aws_instance.workers_gpu.*.public_ip]
# }
# output "workers_gpu_public_dns" {
#   value = [aws_instance.workers_gpu.*.public_dns]
# }
# output "workers_gpu_private_ip" {
#   value = [aws_instance.workers_gpu.*.private_ip]
# }
# output "workers_gpu_private_dns" {
#   value = [aws_instance.workers_gpu.*.private_dns]
# }
output "gpu_worker_count" {
  value = [var.gpu_worker_count]
}

## TODO: Not implemented
# //// MAPR Cluster 1

# output "mapr_cluster_1_hosts_instance_id" {
#   value = [aws_instance.mapr_cluster_1_hosts.*.id]
# }
# output "mapr_cluster_1_hosts_public_ip" {
#   value = [aws_instance.mapr_cluster_1_hosts.*.public_ip]
# }
# output "mapr_cluster_1_hosts_public_dns" {
#   value = [aws_instance.mapr_cluster_1_hosts.*.public_dns]
# }
# output "mapr_cluster_1_hosts_private_ip" {
#   value = [aws_instance.mapr_cluster_1_hosts.*.private_ip]
# }
# output "mapr_cluster_1_hosts_private_ip_flat" {
#   value = join("\n", aws_instance.mapr_cluster_1_hosts.*.private_ip)
# }
# output "mapr_cluster_1_hosts_public_ip_flat" {
#   value = join("\n", aws_instance.mapr_cluster_1_hosts.*.public_ip)
# }
# output "mapr_cluster_1_hosts_private_dns" {
#   value = [aws_instance.mapr_cluster_1_hosts.*.private_dns]
# }
output "mapr_cluster_1_count" {
  value = [var.mapr_cluster_1_count]
}
# output "mapr_cluster_1_name" {
#   value = [var.mapr_cluster_1_name]
# }

# /// MAPR Cluster 2

# output "mapr_cluster_2_hosts_instance_id" {
#   value = [aws_instance.mapr_cluster_2_hosts.*.id]
# }
# output "mapr_cluster_2_hosts_public_ip" {
#   value = [aws_instance.mapr_cluster_2_hosts.*.public_ip]
# }
# output "mapr_cluster_2_hosts_public_dns" {
#   value = [aws_instance.mapr_cluster_2_hosts.*.public_dns]
# }
# output "mapr_cluster_2_hosts_private_ip" {
#   value = [aws_instance.mapr_cluster_2_hosts.*.private_ip]
# }
# output "mapr_cluster_2_hosts_private_ip_flat" {
#   value = join("\n", aws_instance.mapr_cluster_2_hosts.*.private_ip)
# }
# output "mapr_cluster_2_hosts_public_ip_flat" {
#   value = join("\n", aws_instance.mapr_cluster_2_hosts.*.public_ip)
# }
# output "mapr_cluster_2_hosts_private_dns" {
#   value = [aws_instance.mapr_cluster_2_hosts.*.private_dns]
# }
output "mapr_cluster_2_count" {
  value = [var.mapr_cluster_2_count]
}
# output "mapr_cluster_2_name" {
#   value = [var.mapr_cluster_2_name]
# }

output "controller_ssh_command" {
  value = var.create_eip_controller ? "ssh -o StrictHostKeyChecking=no -i \"${var.ssh_prv_key_path}\" ${var.user}@${data.azurerm_public_ip.ctr_public_ip.ip_address}" : "no public ip for controller"
}

output "gateway_ssh_command" {
  value = var.create_eip_gateway ? "ssh -o StrictHostKeyChecking=no -i \"${var.ssh_prv_key_path}\" ${var.user}@${data.azurerm_public_ip.gtw_public_ip.ip_address}" : "no public ip for gateway"
}

output "workers_ssh" {
  value = {
    for instance in data.azurerm_public_ip.wrks_public_ip:
    instance.ip_address => "ssh -o StrictHostKeyChecking=no -i '${var.ssh_prv_key_path}' centos@${instance.fqdn}"
  }
}

# output "mapr_cluster_1_hosts_ssh" {
#   value = {
#     for instance in data.azurerm_public_ip.mapr_cluster1_hosts_public_ip:
#     instance.private_ip => "ssh -o StrictHostKeyChecking=no -i '${var.ssh_prv_key_path}' centos@${instance.public_ip}" 
#   }
# }

// NFS Server Output
output "nfs_server_enabled" {
  value = var.nfs_server_enabled
}
output "nfs_server_instance_id" {
  value = var.nfs_server_enabled ? azurerm_linux_virtual_machine.nfs_server[0].id : "nfs server not enabled"
}
output "nfs_server_private_ip" {
  value = var.nfs_server_enabled ? azurerm_network_interface.nfs_servernic.private_ip_address : "nfs server not enabled"
}
output "nfs_server_folder" {
  value = var.nfs_server_enabled ? "/nfsroot" : "nfs server not enabled"
}
output "nfs_server_ssh_command" {
  value = var.nfs_server_enabled ? "ssh -o StrictHostKeyChecking=no -i \"${var.ssh_prv_key_path}\" centos@${data.azurerm_public_ip.nfs_public_ip.ip_address}" : "nfs server not enabled"
}
// AD Server Output
output "ad_server_enabled" {
  value = var.ad_server_enabled
}
output "ad_server_instance_id" {
  value = var.ad_server_enabled ? azurerm_linux_virtual_machine.ad_server[0].id : "ad server not enabled"
}
output "ad_server_private_ip" {
  value = var.ad_server_enabled ? azurerm_network_interface.ad_servernic.private_ip_address : "ad server not enabled"
}
output "ad_server_public_ip" {
  value = var.ad_server_enabled ? data.azurerm_public_ip.ad_public_ip.ip_address : "ad server not enabled"
}
output "ad_server_ssh_command" {
  value = var.ad_server_enabled ? "ssh -o StrictHostKeyChecking=no -i \"${var.ssh_prv_key_path}\" centos@${data.azurerm_public_ip.ad_public_ip.ip_address}" : "ad server not enabled"
}

// RDP Server Output
output "rdp_server_enabled" {
  value = var.rdp_server_enabled
}
output "rdp_server_instance_id" {
  value = var.rdp_server_enabled ? azurerm_linux_virtual_machine.rdp_server[0].id : "rdp server not enabled"
}
output "rdp_server_operating_system" {
  value = var.rdp_server_enabled ? var.rdp_server_operating_system : "rdp server not enabled"
}
output "rdp_server_public_ip" {
  value = var.create_eip_rdp_linux_server ? data.azurerm_public_ip.rdp_public_ip.ip_address : "no public ip for rdp server"
}
output "rdp_public_dns_name" {
    value = var.create_eip_rdp_linux_server ? "${var.project_id}.${var.region}.cloudapp.azure.com" : "no public dns for rdp server"
}
output "rdp_ssh_command" {
  value = var.create_eip_rdp_linux_server ? "ssh -o StrictHostKeyChecking=no -i \"${var.ssh_prv_key_path}\" ubuntu@${data.azurerm_public_ip.rdp_public_ip.fqdn}" : "no public ip for rdp server"
}
output "rdp_server_private_ip" {
    value = var.rdp_server_enabled ? azurerm_network_interface.rdp_servernic.private_ip_address : "rdp server not enabled"
}
output "rdp_server_admin_password" {
  value = var.rdp_server_enabled ? random_password.rdp_admin_password.result : "rdp server not enabled"  
}