# Define local variables for cluster configuration
locals {
  # Find the IP of the first control plane node to use as the bootstrap endpoint
  control_plane_endpoint = [for v in var.nodes : v.ip if v.machine_type == "controlplane"][0]
  api_endpoint_host      = var.cluster_endpoint != null ? var.cluster_endpoint : local.control_plane_endpoint

  # Create dynamic lists of IPs for health checks
  control_plane_ips = [for v in var.nodes : v.ip if v.machine_type == "controlplane"]
  worker_ips        = [for v in var.nodes : v.ip if v.machine_type == "worker"]
}

# Generate machine secrets for the Talos cluster
resource "talos_machine_secrets" "machine_secrets" {}

# Generate machine configurations for all nodes dynamically
data "talos_machine_configuration" "machine_config" {
  for_each = var.nodes

  cluster_name     = var.cluster.name
  cluster_endpoint = "https://${local.api_endpoint_host}:6443"
  machine_type     = each.value.machine_type
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets
  talos_version    = "v${var.cluster.talos_version}"

  config_patches = [
    yamlencode({
      machine = {
        network = {
          nameservers = var.network_dns_servers
        }
        nodeLabels = var.node_labels
      }
    })
  ]
}

# Apply the Talos configuration to each node after it has been created
resource "talos_machine_configuration_apply" "apply_config" {
  for_each = var.nodes

  # This depends on the respective VM being created by Proxmox
  depends_on = [proxmox_virtual_environment_vm.k8s_nodes]

  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.machine_config[each.key].machine_configuration
  node                        = each.value.ip
}

# Bootstrap the Talos cluster on the first control plane node
resource "talos_machine_bootstrap" "bootstrap" {
  depends_on = [talos_machine_configuration_apply.apply_config]

  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = local.control_plane_endpoint
}

# Check the health of the Talos cluster
data "talos_cluster_health" "health" {
  depends_on = [talos_machine_bootstrap.bootstrap]

  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  control_plane_nodes  = local.control_plane_ips
  worker_nodes         = local.worker_ips
  endpoints            = [local.control_plane_endpoint]

  timeouts = {
    read = "10m"
  }
}

# Generate the talosconfig for client access
data "talos_client_configuration" "talosconfig" {
  depends_on = [data.talos_cluster_health.health]

  cluster_name         = var.cluster.name
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  endpoints            = [local.control_plane_endpoint]
}

# Generate the Kubeconfig for Kubernetes cluster access
resource "talos_cluster_kubeconfig" "kubeconfig" {
  depends_on = [data.talos_cluster_health.health]

  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = local.control_plane_endpoint
}
