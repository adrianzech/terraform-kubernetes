provider "vault" {
  address = "https://vault.zech.co"
  skip_child_token = true
  auth_login {
    path = "auth/approle/login"
    parameters = {
      role_id   = var.vault_role_id
      secret_id = var.vault_secret_id
    }
  }
}

ephemeral "vault_kv_secret_v2" "terraform" {
  mount = "kv"
  name  = var.vault_terraform_kv_path
}

locals {
  vault_secrets = ephemeral.vault_kv_secret_v2.terraform.data
  vault_k8s_auth_path = "kubernetes-${var.cluster.name}"
  vault_k8s_role_name = "external-secrets-${var.cluster.name}"
  vault_k8s_policy_name = "k8s-${var.cluster.name}-read"
  vault_k8s_secret_prefix = "${var.vault_k8s_secret_prefix}/${var.cluster.name}"
}
