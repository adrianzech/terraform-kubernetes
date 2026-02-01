# Proxmox API Credentials
variable "proxmox_endpoint" {
  type        = string
  description = "The URL of the Proxmox API (e.g., https://pve.example.com/api2/json)."
}


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

# Flux Configuration

variable "github_org" {
  description = "GitHub organization"
  type        = string
}

variable "github_repository" {
  description = "GitHub repository"
  type        = string
}

variable "flux_git_path" {
  description = "Git path for Flux sync (e.g., clusters/production)."
  type        = string
}

variable "flux_git_branch" {
  description = "Git branch for Flux bootstrap."
  type        = string
  default     = "main"
}

variable "vault_role_id" {
  description = "Vault AppRole role_id used by the Vault provider."
  type        = string
  sensitive   = true
}

variable "vault_secret_id" {
  description = "Vault AppRole secret_id used by the Vault provider."
  type        = string
  sensitive   = true
}

variable "vault_terraform_kv_path" {
  description = "Vault KV v2 path for Terraform secrets (e.g., terraform/k8s-development)."
  type        = string
}

variable "vault_k8s_namespace" {
  description = "Namespace used for Vault Kubernetes auth service account."
  type        = string
  default     = "vault"
}

variable "vault_k8s_token_policies" {
  description = "Vault policies attached to tokens issued by the Kubernetes auth role."
  type        = list(string)
  default     = ["default"]
}

variable "vault_k8s_kv_mount" {
  description = "KV v2 mount name used by Kubernetes workloads (e.g., secret)."
  type        = string
  default     = "kv"
}

variable "vault_k8s_secret_prefix" {
  description = "Base prefix under the KV mount for cluster secrets."
  type        = string
  default     = "kubernetes"
}
