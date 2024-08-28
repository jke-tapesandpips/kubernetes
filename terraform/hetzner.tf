# Create fallback SSH key
resource "hcloud_ssh_key" "kubernetes-fallback" {
    name            = "kubenetes-fallback"
    public_key      = file("kubernetes-fallback.pub")
}

# Create Placement groups
resource "hcloud_placement_group" "placement-location-1" {
    name   = "placement-group-1"
    type   = "spread"
}

resource "hcloud_placement_group" "placement-location-2" {
    name   = "placement-group-2"
    type   = "spread"
}

## Networking
resource "hcloud_network" "kube-net" {
    name            = "kube-net"
    ip_range        = "10.69.0.0/16"
}

resource "hcloud_network_subnet" "kube-subnet" {
    type            = "cloud"
    network_id      = hcloud_network.kube-net.id
    network_zone    = "eu-central"
    ip_range        = "10.69.0.0/16"
}

resource "hcloud_server" "master-nodes-1" {
    count           = 2

    name            = "master-${var.location-1}-${count.index}"
    image           = var.operating-system
    server_type     = var.arm-small
    ssh_keys        = [hcloud_ssh_key.kubernetes-fallback.id]
    #firewall_ids    = [hcloud_firewall.allowdefault.id, hcloud_firewall.allow-kubectl.id]
    placement_group_id = hcloud_placement_group.placement-location-1.id
    location        = var.location-1

    network {
      network_id = hcloud_network.kube-net.id
      ip         = "10.69.0.1${count.index}"
    }

   public_net {
      ipv4_enabled = false
      ipv6_enabled = true
    }  

   user_data = file("cloud-init.yaml")
}

resource "hcloud_server" "master-nodes-2" {
    count           = 1

    name            = "master-${var.location-2}-${count.index}"
    image           = var.operating-system
    server_type     = var.arm-small
    ssh_keys        = [hcloud_ssh_key.kubernetes-fallback.id]
    #firewall_ids    = [hcloud_firewall.allowdefault.id, hcloud_firewall.allow-kubectl.id]
    placement_group_id = hcloud_placement_group.placement-location-2.id
    location        = var.location-2

    network {
      network_id = hcloud_network.kube-net.id
      ip         = "10.69.0.2${count.index}"
    }

   public_net {
      ipv4_enabled = false
      ipv6_enabled = true
    }  

   user_data = file("cloud-init.yaml")
}

resource "hcloud_server" "worker-nodes-nbg" {
    count           = 2

    name            = "worker-${var.location-1}-${count.index}"
    image           = var.operating-system
    server_type     = var.arm-small
    ssh_keys        = [hcloud_ssh_key.kubernetes-fallback.id]
    #firewall_ids    = [hcloud_firewall.allowdefault.id, hcloud_firewall.allow-kubectl.id]
    placement_group_id = hcloud_placement_group.placement-location-1.id
    location        = var.location-1

    network {
      network_id = hcloud_network.kube-net.id
      ip         = "10.69.1.1${count.index}"
    }

   public_net {
      ipv4_enabled = false
      ipv6_enabled = true
    }  

   user_data = file("cloud-init.yaml")
}

resource "hcloud_server" "worker-nodes-2" {
    count           = 2

    name            = "worker-${var.location-2}-${count.index}"
    image           = var.operating-system
    server_type     = var.arm-small
    ssh_keys        = [hcloud_ssh_key.kubernetes-fallback.id]
    #firewall_ids    = [hcloud_firewall.allowdefault.id, hcloud_firewall.allow-kubectl.id]
    placement_group_id = hcloud_placement_group.placement-location-2.id
    location        = var.location-2

    network {
      network_id = hcloud_network.kube-net.id
      ip         = "10.69.1.2${count.index}"
    }

   public_net {
      ipv4_enabled = false
      ipv6_enabled = true
    }  

   user_data = file("cloud-init.yaml")
}

# Create Load Balancer
resource "hcloud_load_balancer" "kube-lb" {
  name               = "kube-lb"
  load_balancer_type = "lb11"
  location           = var.location-1
}

# Attach master nodes as targets to the load balancer
resource "hcloud_load_balancer_target" "kube-lb-target-master-1" {
  load_balancer_id = hcloud_load_balancer.kube-lb.id
  type             = "server"
  server_id        = hcloud_server.master-nodes-1[0].id
  use_private_ip   = true
}

resource "hcloud_load_balancer_target" "kube-lb-target-master-2" {
  load_balancer_id = hcloud_load_balancer.kube-lb.id
  type             = "server"
  server_id        = hcloud_server.master-nodes-1[1].id
  use_private_ip   = true
}

resource "hcloud_load_balancer_target" "kube-lb-target-master-3" {
  load_balancer_id = hcloud_load_balancer.kube-lb.id
  type             = "server"
  server_id        = hcloud_server.master-nodes-2[0].id
  use_private_ip   = true
}

resource "hcloud_load_balancer_service" "kube-lb-service" {
  load_balancer_id  = hcloud_load_balancer.kube-lb.id
  protocol          = "tcp"
  listen_port       = 6443
  destination_port  = 6443
  proxyprotocol     = false

  health_check {
    protocol = "tcp"
    port     = 6443
    interval = 15
    timeout  = 10
    retries  = 3
  }
}

