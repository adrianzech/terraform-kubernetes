resource "kubernetes_namespace_v1" "vault" {
  metadata {
    name = var.vault_k8s_namespace
  }

  depends_on = [module.k8s_cluster]
}

resource "kubernetes_service_account_v1" "vault_token_reviewer" {
  metadata {
    name      = "vault-token-reviewer"
    namespace = kubernetes_namespace_v1.vault.metadata[0].name
  }
}

resource "kubernetes_cluster_role_binding_v1" "vault_auth_delegator" {
  metadata {
    name = "vault-auth-delegator-${var.cluster.name}"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.vault_token_reviewer.metadata[0].name
    namespace = kubernetes_namespace_v1.vault.metadata[0].name
  }
}

resource "kubernetes_secret_v1" "vault_token_reviewer" {
  metadata {
    name      = "vault-token-reviewer"
    namespace = kubernetes_namespace_v1.vault.metadata[0].name
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account_v1.vault_token_reviewer.metadata[0].name
    }
  }

  type = "kubernetes.io/service-account-token"
}

data "kubernetes_secret_v1" "vault_token_reviewer" {
  metadata {
    name      = kubernetes_secret_v1.vault_token_reviewer.metadata[0].name
    namespace = kubernetes_namespace_v1.vault.metadata[0].name
  }

  depends_on = [kubernetes_secret_v1.vault_token_reviewer]
}

resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
  path = local.vault_k8s_auth_path
}

resource "vault_kubernetes_auth_backend_config" "k8s" {
  backend            = vault_auth_backend.kubernetes.path
  kubernetes_host    = module.k8s_cluster.kubeconfig_details.host
  kubernetes_ca_cert = base64decode(module.k8s_cluster.kubeconfig_details.cluster_ca_certificate)
  token_reviewer_jwt = data.kubernetes_secret_v1.vault_token_reviewer.data["token"]
}

resource "vault_policy" "k8s_read" {
  name = local.vault_k8s_policy_name
  policy = <<EOF
path "${var.vault_k8s_kv_mount}/data/${local.vault_k8s_secret_prefix}/*" {
  capabilities = ["read"]
}
path "${var.vault_k8s_kv_mount}/metadata/${local.vault_k8s_secret_prefix}/*" {
  capabilities = ["list"]
}
EOF
}

resource "vault_kubernetes_auth_backend_role" "k8s" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = local.vault_k8s_role_name
  bound_service_account_names      = ["external-secrets"]
  bound_service_account_namespaces = ["external-secrets"]
  token_policies                   = concat(var.vault_k8s_token_policies, [vault_policy.k8s_read.name])
}
