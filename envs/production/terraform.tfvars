# Proxmox API Credentials
proxmox_endpoint = "https://pve.local.zech.co:8006/"

# Proxmox Environment
proxmox_node  = "pve"
image_storage = "local"
disk_storage = "local-lvm"

# Network Configuration
network_bridge  = "vmbr0"
network_gateway = "10.0.20.1"
network_prefix  = 24
vlan_id = 20
network_dns_servers = ["10.0.20.1"]

# Talos Cluster Configuration
cluster = {
  name          = "production"
  talos_version = "1.12.2"
  schematic_id  = "88d1f7a5c4f1d3aba7df787c448c1d3d008ed29cfb34af53fa0df4336a56040b"
}

vm_tags = ["k8s", "production"]

node_resources = {
  cpu_cores   = 2
  cpu_sockets = 2
  cpu_type    = "host"
  memory_mb   = 4096
  disk_gb     = 40
}

nodes = {
  "k8s-prod-control-1" = {
    vm_id        = 20011
    ip           = "10.0.20.11"
    machine_type = "controlplane"
  },
  "k8s-prod-control-2" = {
    vm_id        = 20012
    ip           = "10.0.20.12"
    machine_type = "controlplane"
  },
  "k8s-prod-control-3" = {
    vm_id        = 20013
    ip           = "10.0.20.13"
    machine_type = "controlplane"
  },
  "k8s-prod-worker-1" = {
    vm_id        = 20021
    ip           = "10.0.20.21"
    machine_type = "worker"
  },
  "k8s-prod-worker-2" = {
    vm_id        = 20022
    ip           = "10.0.20.22"
    machine_type = "worker"
  },
  "k8s-prod-worker-3" = {
    vm_id        = 20023
    ip           = "10.0.20.23"
    machine_type = "worker"
  }
}

node_labels = {
  "topology.kubernetes.io/region" = "pve"
  "topology.kubernetes.io/zone"   = "pve"
}
