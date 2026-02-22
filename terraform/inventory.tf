resource "local_file" "ansible_inventory" {
  filename = "../ansible/inventory.ini"
  content  = <<EOT
[gateway]
${proxmox_virtual_environment_vm.gateway.name} ansible_host=${split("/", var.k8s_gateway_wan_ip)[0]}

[controllers]
%{ for vm in proxmox_virtual_environment_vm.controllers ~}
${vm.name} ansible_host=${split("/", vm.initialization[0].ip_config[0].ipv4[0].address)[0]}
%{ endfor ~}

[workers]
%{ for vm in proxmox_virtual_environment_vm.workers ~}
${vm.name} ansible_host=${split("/", vm.initialization[0].ip_config[0].ipv4[0].address)[0]}
%{ endfor ~}

[clients]
${proxmox_virtual_environment_vm.gateway.name} ansible_host=${split("/", var.k8s_gateway_wan_ip)[0]}

[k8s_cluster:children]
controllers
workers
EOT
}
