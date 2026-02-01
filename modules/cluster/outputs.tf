# Individual Kubernetes connection details for provider configuration.
output "kubeconfig_details" {
  description = "Individual Kubernetes connection details for provider configuration."
  value = {
    host                   = talos_cluster_kubeconfig.kubeconfig.kubernetes_client_configuration.host
    cluster_ca_certificate = talos_cluster_kubeconfig.kubeconfig.kubernetes_client_configuration.ca_certificate
    client_key             = talos_cluster_kubeconfig.kubeconfig.kubernetes_client_configuration.client_key
    client_certificate     = talos_cluster_kubeconfig.kubeconfig.kubernetes_client_configuration.client_certificate
  }
  sensitive = true
}

# Talos client configuration (talosconfig)
output "talosconfig" {
  description = "Talos client configuration (talosconfig)."
  value       = data.talos_client_configuration.talosconfig.talos_config
  sensitive   = true
}

# Kubernetes client configuration (kubeconfig)
output "kubeconfig" {
  description = "Kubernetes client configuration (kubeconfig)."
  value       = talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
  sensitive   = true
}

# IP addresses of the control plane nodes.
output "control_plane_ips" {
  description = "IP addresses of the control plane nodes."
  value       = local.control_plane_ips
}

# IP addresses of the worker nodes.
output "worker_ips" {
  description = "IP addresses of the worker nodes."
  value       = local.worker_ips
}
