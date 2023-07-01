output "cluster" {
  value = zipmap(scaleway_baremetal_server.cluster.*.name, formatlist("https://%s:8006",scaleway_baremetal_server.cluster.*.ipv4.0.address))
}

output "vlan_ids" {
  value = zipmap(scaleway_baremetal_server.cluster.*.name, [ for pn in scaleway_baremetal_server.cluster.*.private_network: tolist(pn)[0].vlan ])
}

output "db_endpoint" {
  value = format("%s:%s", scaleway_rdb_instance.demo.private_network.0.ip, scaleway_rdb_instance.demo.private_network.0.port)
}

output "loadbalancer" {
  value = scaleway_lb_ip.lb.ip_address
}

output "pn_subnet" {
  value = scaleway_vpc_private_network.pn.ipv4_subnet.0.subnet
}
