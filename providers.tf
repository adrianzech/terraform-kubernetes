# Proxmox provider configuration
provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = var.proxmox_api_token
  insecure  = true

  ssh {
    username = "root"
    agent    = true
  }
}

# Kubernetes provider configuration
provider "kubernetes" {
  host                   = module.k8s_cluster.kubeconfig_details.host
  cluster_ca_certificate = base64decode(module.k8s_cluster.kubeconfig_details.cluster_ca_certificate)
  client_key             = base64decode(module.k8s_cluster.kubeconfig_details.client_key)
  client_certificate     = base64decode(module.k8s_cluster.kubeconfig_details.client_certificate)
}
