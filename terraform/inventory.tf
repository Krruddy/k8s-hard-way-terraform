resource "local_file" "ansible_inventory" {
  filename = "../ansible/inventory.ini"
  content  = <<EOT
[gateway]
${proxmox_virtual_environment_vm.gateway.name} ansible_host=${split("/", var.k8s_gateway_wan_ip)[0]}

[controllers]
%{ for vm in proxmox_virtual_environment_vm.controllers ~}
${vm.name} ansible_host=${split("/", vm.initialization[0].ip_config[0].ipv4[0].address)[0]}
%{ endfor ~}

[etcd_nodes]
%{ for vm in proxmox_virtual_environment_vm.controllers ~}
${vm.name} ansible_host=${split("/", vm.initialization[0].ip_config[0].ipv4[0].address)[0]}
%{ endfor ~}

[workers]
%{ for vm in proxmox_virtual_environment_vm.workers ~}
${vm.name} ansible_host=${split("/", vm.initialization[0].ip_config[0].ipv4[0].address)[0]}
%{ endfor ~}

[clients]
${proxmox_virtual_environment_vm.gateway.name} ansible_host=${split("/", var.k8s_gateway_wan_ip)[0]}

[local]
localhost ansible_connection=local

[vault_pki]
localhost ansible_connection=local

[k8s_cluster:children]
controllers
workers
etcd_nodes
EOT
}

resource "local_file" "ansible_vault_pki_vars" {
  filename = "../ansible/group_vars/all/terraform.yml"
  content  = <<-EOT
---
aggregation_layer_k8s_component:
  vault_role: ${vault_pki_secret_backend_role.k8s_role_aggregation_layer.name}
  cert_final_path: "/var/lib/kubernetes"
  cn: "kubernetes-aggregation-layer"

certificate_authorities:
  kubernetes_ca: 
    path: ${vault_mount.kubernetes_pki.path}
    name: ca.pem
  kubernetes_aggregation_layer_ca: 
    path: ${vault_mount.aggregation_layer_pki.path}
    name: ca-aggregation-layer.pem
EOT
}
