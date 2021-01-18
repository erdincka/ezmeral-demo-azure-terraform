# outputs

# Using workaround since public IP cannot be get before attaching to an online VM 
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
data "azurerm_public_ip" "gtw_ip" {
  name                = azurerm_public_ip.gatewaypip.name
  resource_group_name = azurerm_linux_virtual_machine.gateway.resource_group_name
}
output "gateway_public_ip" {
  value = var.create_eip_gateway ? data.azurerm_public_ip.gtw_ip.ip_address : ""
}
output "gateway_public_dns" {
    value = var.create_eip_gateway ? "${var.project_id}.${var.region}.cloudapp.azure.com" : ""
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
  value = azurerm_network_interface.controllernic.internal_dns_name_label
}
data "azurerm_public_ip" "ctr_ip" {
  ### Workaround if create_eip_controller is false (return gateway public ip)
  name                = var.create_eip_controller ? azurerm_public_ip.controllerpip[0].name : azurerm_public_ip.gatewaypip.name
  resource_group_name = azurerm_linux_virtual_machine.controller.resource_group_name
}
output "controller_public_ip" {
  value = data.azurerm_public_ip.ctr_ip.ip_address
}
output "controller_public_url" {
  value = var.create_eip_controller ? "https://${azurerm_public_ip.controllerpip[0].fqdn}" : ""
}
output "controller_public_dns" {
  value = var.create_eip_controller ? azurerm_public_ip.controllerpip[0].fqdn : ""
}

/// workers
output "workers_instance_id" {
  value = [azurerm_linux_virtual_machine.workers.*.id]
}
output "workers_private_ip" {
  value = [azurerm_network_interface.workernics.*.private_ip_address]
}
# output "workers_private_dns" {
#   value = [aws_instance.workers.*.private_dns]
# }
output "workers_public_ip" { # workaround as we don't create public ip for workers
  value = [azurerm_network_interface.workernics.*.private_ip_address]
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
# output "gpu_worker_count" {
#   value = [var.gpu_worker_count]
# }

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
# output "mapr_cluster_1_count" {
#   value = [var.mapr_cluster_1_count]
# }
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
# output "mapr_cluster_2_count" {
#   value = [var.mapr_cluster_2_count]
# }
# output "mapr_cluster_2_name" {
#   value = [var.mapr_cluster_2_name]
# }

output "controller_ssh_command" {
  value = var.create_eip_controller ? "ssh -o StrictHostKeyChecking=no -i \"${var.ssh_prv_key_path}\" ${var.user}@${data.azurerm_public_ip.ctr_ip.ip_address}" : ""
}

output "gateway_ssh_command" {
  value = var.create_eip_gateway ? "ssh -o StrictHostKeyChecking=no -i \"${var.ssh_prv_key_path}\" ${var.user}@${data.azurerm_public_ip.gtw_ip.ip_address}" : ""
}

# output "workers_ssh" {
#   value = {
#     for instance in aws_instance.workers:
#     instance.private_ip => "ssh -o StrictHostKeyChecking=no -i '${var.ssh_prv_key_path}' centos@${instance.public_ip}" 
#   }
# }

# output "mapr_cluster_1_hosts_ssh" {
#   value = {
#     for instance in aws_instance.mapr_cluster_1_hosts:
#     instance.private_ip => "ssh -o StrictHostKeyChecking=no -i '${var.ssh_prv_key_path}' centos@${instance.public_ip}" 
#   }
# }

// NFS Server Output
output "nfs_server_enabled" {
  value = var.nfs_server_enabled
}
# output "nfs_server_instance_id" {
#   value = module.nfs_server.instance_id
# }
# output "nfs_server_private_ip" {
#   value = module.nfs_server.private_ip
# }
# output "nfs_server_folder" {
#   value = module.nfs_server.nfs_folder
# }
# output "nfs_server_ssh_command" {
#   value = module.nfs_server.ssh_command
# }

// AD Server Output
# output "ad_server_instance_id" {
#   value = module.ad_server.instance_id
# }
# output "ad_server_private_ip" {
#   value = module.ad_server.private_ip
# }
# output "ad_server_public_ip" {
#   value = module.ad_server.public_ip
# }
# output "ad_server_ssh_command" {
#   value = module.ad_server.ssh_command
# }
output "ad_server_enabled" {
  value = var.ad_server_enabled
}

// RDP Server Output
output "rdp_server_enabled" {
  value = var.rdp_server_enabled
}
# output "rdp_server_private_ip" {
#   value = var.rdp_server_operating_system == "WINDOWS" ? module.rdp_server.private_ip : module.rdp_server_linux.private_ip
# }
# output "rdp_server_public_ip" {
#   value = var.rdp_server_operating_system == "WINDOWS" ? module.rdp_server.public_ip : module.rdp_server_linux.public_ip
# }
output "rdp_server_instance_id" {
  value = var.rdp_server_enabled ? azurerm_linux_virtual_machine.rdphost[0].id : ""
}
output "rdp_server_operating_system" {
  value = var.rdp_server_operating_system
}
# output "softether_rdp_ip" {
#   value = var.softether_rdp_ip
# }
data "azurerm_public_ip" "rdp_ip" {
  name                = azurerm_public_ip.rdphostpip[0].name
  resource_group_name = azurerm_linux_virtual_machine.rdphost[0].resource_group_name
}
output "rdp_server_public_ip" {
  value = var.create_eip_rdp_linux_server ? data.azurerm_public_ip.rdp_ip.ip_address : ""
}
output "rdp_public_dns_name" {
    value = var.create_eip_rdp_linux_server ? "${var.project_id}.${var.region}.cloudapp.azure.com" : ""
}
output "rdp_ssh_command" {
  value = var.create_eip_rdp_linux_server ? "ssh -o StrictHostKeyChecking=no -i \"${var.ssh_prv_key_path}\" ${var.user}@${data.azurerm_public_ip.rdp_ip.ip_address}" : ""
}
output "rdp_server_private_ip" {
    value = azurerm_network_interface.rdphostnic.private_ip_address
}
