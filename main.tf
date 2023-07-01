variable "service_password" {
  type      = string
  sensitive = true
  default   = "P4ssw0rd!"
}

variable "db_password" {
  type      = string
  sensitive = true
  default   = "thiZ_is_v&ry_s3cret"
}

data "scaleway_baremetal_os" "proxmox" {
  name    = "Proxmox"
  version = "VE 8 | Debian 12 (Bookworm)"
}

data "scaleway_baremetal_offer" "size" {
  name = "EM-A315X-SSD"
}

data "scaleway_baremetal_option" "private_network" {
  name = "Private Network"
}

resource "scaleway_vpc_private_network" "pn" {
  name        = "baremetal_private_network"
  is_regional = true
  tags        = ["Demo"]
}

resource "scaleway_baremetal_server" "cluster" {
  count            = 3
  offer            = data.scaleway_baremetal_offer.size.offer_id
  os               = data.scaleway_baremetal_os.proxmox.os_id
  ssh_key_ids      = [] # Mandatory field but not needed with Proxmox
  service_password = var.service_password
  options {
    id = data.scaleway_baremetal_option.private_network.option_id
  }
  private_network {
    id = scaleway_vpc_private_network.pn.id
  }
  tags = ["Demo"]
}

resource "scaleway_rdb_instance" "demo" {
  name           = "pn-rdb"
  node_type      = "DB-DEV-S"
  engine         = "PostgreSQL-14"
  is_ha_cluster  = true
  disable_backup = true
  user_name      = "username"
  password       = var.db_password
  private_network {
    pn_id = scaleway_vpc_private_network.pn.id
  }
  tags = ["Demo"]
}

resource "scaleway_lb_ip" "lb" {}

resource "scaleway_lb" "demo" {
  ip_id = scaleway_lb_ip.lb.id
  name  = "demo-lb"
  type  = "LB-S"
  private_network {
    private_network_id = scaleway_vpc_private_network.pn.id
    dhcp_config        = true
  }
  tags = ["Demo"]
}
