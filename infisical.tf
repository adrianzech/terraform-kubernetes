resource "kubernetes_namespace_v1" "infisical" {
  metadata {
    name = "infisical"
  }
}

resource "kubernetes_service_account_v1" "infisical_token_reviewer" {
  metadata {
    name      = "infisical-token-reviewer"
    namespace = kubernetes_namespace_v1.infisical.metadata[0].name
  }
}

resource "kubernetes_cluster_role_binding_v1" "infisical_token_reviewer" {
  metadata {
    name = "infisical-token-reviewer-role-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.infisical_token_reviewer.metadata[0].name
    namespace = kubernetes_namespace_v1.infisical.metadata[0].name
  }
}

resource "kubernetes_cluster_role_binding_v1" "infisical_service_account_token_reviewer" {
  metadata {
    name = "infisical-service-account-token-reviewer-role-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "infisical-service-account"
    namespace = kubernetes_namespace_v1.infisical.metadata[0].name
  }
}

resource "kubernetes_token_request_v1" "infisical_token_reviewer" {
  metadata {
    name      = kubernetes_service_account_v1.infisical_token_reviewer.metadata[0].name
    namespace = kubernetes_namespace_v1.infisical.metadata[0].name
  }

  spec {
  }
}
