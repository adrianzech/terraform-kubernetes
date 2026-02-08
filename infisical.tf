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

  secret {
    name = "infisical-token-reviewer-token"
  }
}

resource "kubernetes_secret_v1" "infisical_token_reviewer_token" {
  metadata {
    name      = "infisical-token-reviewer-token"
    namespace = kubernetes_namespace_v1.infisical.metadata[0].name
    annotations = {
      "kubernetes.io/service-account.name" = "infisical-token-reviewer"
    }
  }

  type                           = "kubernetes.io/service-account-token"
  wait_for_service_account_token = true

  depends_on = [
    kubernetes_service_account_v1.infisical_token_reviewer,
  ]
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

locals {
  infisical_token_reviewer_token_raw = try(kubernetes_secret_v1.infisical_token_reviewer_token.data["token"], "")
  infisical_token_reviewer_token     = can(base64decode(local.infisical_token_reviewer_token_raw)) ? base64decode(local.infisical_token_reviewer_token_raw) : local.infisical_token_reviewer_token_raw
}
