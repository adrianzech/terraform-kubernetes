# Proxmox Environment
variable "proxmox_node" {
  type        = string
  description = "The Proxmox node where the VMs will be created (e.g., 'pve')."
}

variable "image_storage" {
  type        = string
  description = "The storage pool for the images (e.g., 'local')."
}

variable "disk_storage" {
  type        = string
  description = "The storage pool for the VM disks (e.g., 'local-lvm')."
}

# Network Configuration
variable "network_bridge" {
  type        = string
  description = "The network bridge for the VMs (e.g., 'vmbr0')."
}

variable "network_gateway" {
  type        = string
  description = "The network gateway IP address for the VMs."
}

variable "network_prefix" {
  type        = number
  description = "The network prefix (CIDR) for the VMs (e.g., 24 for /24)."
  default     = 24
}

variable "network_dns_servers" {
  type = list(string)
  description = "A list of DNS servers for the Talos nodes to use for upstream name resolution."
  default = ["10.0.20.1"]
}

variable "vlan_id" {
  type        = number
  description = "The VLAN ID for the network interface."
}

# Talos Cluster Configuration
variable "cluster" {
  description = "General cluster configuration."
  type = object({
    name          = string
    talos_version = string
    schematic_id  = string
  })
}

variable "cluster_endpoint" {
  type        = string
  description = "Optional stable API endpoint (VIP/DNS). If unset, the first control-plane IP is used."
  default     = null
}

variable "nodes" {
  description = "Configuration for all cluster nodes."
  type = map(object({
    ip           = string
    vm_id        = number
    machine_type = string
  }))
  validation {
    condition = (
      length([for v in var.nodes : v if v.machine_type == "controlplane"]) > 0
      && alltrue([for v in var.nodes : contains(["controlplane", "worker"], v.machine_type)])
    )
    error_message = "nodes must include at least one controlplane, and machine_type must be 'controlplane' or 'worker'."
  }
}

variable "node_labels" {
  type        = map(string)
  description = "Global Kubernetes node labels applied via Talos."
  default     = {}
}

variable "vm_tags" {
  type        = list(string)
  description = "Tags applied to Proxmox VMs."
  default     = ["k8s"]
}

variable "node_resources" {
  description = "Shared sizing for all nodes."
  type = object({
    cpu_cores   = number
    cpu_sockets = number
    cpu_type    = string
    memory_mb   = number
    disk_gb     = number
  })
  default = {
    cpu_cores   = 2
    cpu_sockets = 1
    cpu_type    = "host"
    memory_mb   = 4096
    disk_gb     = 40
  }
}
