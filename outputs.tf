# Output the kubeconfig from the module
output "kubeconfig" {
  description = "Kubernetes client configuration (kubeconfig) for the created cluster."
  value       = module.k8s_cluster.kubeconfig
  sensitive   = true
}

# Output the talosconfig from the module
output "talosconfig" {
  description = "Talos client configuration (talosconfig) for the created cluster."
  value       = module.k8s_cluster.talosconfig
  sensitive   = true
}

# Output control plane IPs from the module
output "control_plane_ips" {
  description = "IP addresses of the control plane nodes in the cluster."
  value       = module.k8s_cluster.control_plane_ips
}

# Output worker IPs from the module
output "worker_ips" {
  description = "IP addresses of the worker nodes in the cluster."
  value       = module.k8s_cluster.worker_ips
}

output "infisical_token_reviewer_token" {
  description = "Token for the infisical-token-reviewer service account (Kubernetes TokenRequest)."
  value       = kubernetes_token_request_v1.infisical_token_reviewer.token
  sensitive   = true
}

output "kubernetes_ca_certificate" {
  description = "Kubernetes cluster CA certificate (decoded PEM)."
  value       = base64decode(module.k8s_cluster.kubeconfig_details.cluster_ca_certificate)
  sensitive   = true
}
