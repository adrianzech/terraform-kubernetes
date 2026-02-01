# Download the Talos OS image
resource "proxmox_virtual_environment_download_file" "talos_image" {
  content_type            = "iso"
  datastore_id            = var.image_storage
  node_name               = var.proxmox_node
  file_name               = "talos-${var.cluster.name}-${var.cluster.talos_version}-nocloud-amd64.img"
  url                     = "https://factory.talos.dev/image/${var.cluster.schematic_id}/${var.cluster.talos_version}/nocloud-amd64.raw.gz"
  decompression_algorithm = "gz"
  overwrite               = true
}

# Create Proxmox virtual machines for Kubernetes nodes
resource "proxmox_virtual_environment_vm" "k8s_nodes" {
  for_each = var.nodes

  depends_on = [proxmox_virtual_environment_download_file.talos_image]

  # General VM settings
  name      = each.key
  vm_id     = each.value.vm_id
  node_name = var.proxmox_node
  started   = true
  on_boot   = true
  tags        = var.vm_tags

  boot_order = ["virtio0"]

  operating_system {
    type = "l26"
  }

  # Hardware resources
  agent {
    enabled = true
    type    = "virtio"
  }

  cpu {
    cores   = var.node_resources.cpu_cores
    sockets = var.node_resources.cpu_sockets
    type    = var.node_resources.cpu_type
  }

  memory {
    dedicated = var.node_resources.memory_mb
  }

  vga {
    type = "qxl"
  }

  # Storage configuration
  disk {
    datastore_id = var.disk_storage
    file_id      = proxmox_virtual_environment_download_file.talos_image.id
    file_format  = "raw"
    interface    = "virtio0"
    size         = var.node_resources.disk_gb
  }

  # Network configuration
  network_device {
    bridge  = var.network_bridge
    model   = "virtio"
    vlan_id = var.vlan_id
  }

  # Cloud-Init configuration
  initialization {
    datastore_id = var.disk_storage
    ip_config {
      ipv4 {
        address = "${each.value.ip}/${var.network_prefix}"
        gateway = var.network_gateway
      }
    }
  }
}
