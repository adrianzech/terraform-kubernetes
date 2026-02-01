# Call the Proxmox and Talos cluster module
module "k8s_cluster" {
  source = "./modules/cluster"

  # Proxmox Environment
  proxmox_node  = var.proxmox_node
  image_storage = var.image_storage
  disk_storage = var.disk_storage

  # Network Configuration
  network_bridge      = var.network_bridge
  network_gateway     = var.network_gateway
  network_prefix      = var.network_prefix
  network_dns_servers = var.network_dns_servers
  vlan_id = var.vlan_id

  # Talos Cluster Configuration
  cluster = var.cluster
  cluster_endpoint = var.cluster_endpoint
  nodes = var.nodes
  node_labels = var.node_labels
  vm_tags = var.vm_tags
  node_resources = var.node_resources

}

resource "kubernetes_namespace_v1" "flux_system" {
  metadata {
    name = "flux-system"
  }

  depends_on = [module.k8s_cluster]
}

resource "flux_bootstrap_git" "this" {
  path = var.flux_git_path

  depends_on = [module.k8s_cluster, kubernetes_namespace_v1.flux_system]
}
