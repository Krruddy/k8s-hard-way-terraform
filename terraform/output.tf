output "gateway_wan_ip" {
  description = "The DHCP-assigned WAN IP of the Gateway"
  value = var.k8s_gateway_wan_ip
}

output "gateway_lan_ip" {
  description = "The static LAN IP of the Gateway"
  value = var.k8s_gateway_ip
}

output "controller_lan_ips" {
  description = "The static LAN IPs of the Controller nodes"
  value = [
    for vm in proxmox_virtual_environment_vm.controllers :
    vm.initialization[0].ip_config[0].ipv4[0].address
  ]
}

output "worker_lan_ips" {
  description = "The static LAN IPs of the Worker nodes"
  value = [
    for vm in proxmox_virtual_environment_vm.workers :
    vm.initialization[0].ip_config[0].ipv4[0].address
  ]
}
