# Proxmox provider configuration
provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = local.vault_secrets.proxmox_api_token
  insecure  = true

  ssh {
    username = "root"
    agent    = true
  }
}

# Kubernetes provider configuration
provider "kubernetes" {
  host = module.k8s_cluster.kubeconfig_details.host
  cluster_ca_certificate = base64decode(module.k8s_cluster.kubeconfig_details.cluster_ca_certificate)
  client_key = base64decode(module.k8s_cluster.kubeconfig_details.client_key)
  client_certificate = base64decode(module.k8s_cluster.kubeconfig_details.client_certificate)
}

# Flux provider configuration
provider "flux" {
  kubernetes = {
    host = module.k8s_cluster.kubeconfig_details.host
    cluster_ca_certificate = base64decode(module.k8s_cluster.kubeconfig_details.cluster_ca_certificate)
    client_key = base64decode(module.k8s_cluster.kubeconfig_details.client_key)
    client_certificate = base64decode(module.k8s_cluster.kubeconfig_details.client_certificate)
  }
  git = {
    url = "https://github.com/${var.github_org}/${var.github_repository}.git"
    branch = var.flux_git_branch
    http = {
      username = "git"
      password = local.vault_secrets.github_token
    }
  }
}

# GitHub provider configuration
provider "github" {
  owner = var.github_org
  token = local.vault_secrets.github_token
}
