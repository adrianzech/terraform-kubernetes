# Terraform/OpenTofu - Kubernetes Clusters

This repository manages Kubernetes clusters via a single root stack with environment-specific inputs in
`envs/development` and `envs/production`.

## Prerequisites

- OpenTofu (`tofu`)
- Proxmox API access
- Infisical CLI configured (`infisical init`)
- `kubectl` and `talosctl`

## Infisical Secrets

Secrets are injected via Infisical. Provide them as Terraform variables:
- `TF_VAR_proxmox_api_token`

S3 backend auth:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`

## Initialize

Use `-reconfigure` when switching between dev and prod backends.

Development:
```bash
infisical run --env=dev -- tofu init -backend-config=envs/development/backend.hcl
```

Production:
```bash
infisical run --env=prod -- tofu init -backend-config=envs/production/backend.hcl
```

## Switch backends

Switch dev -> prod:
```bash
infisical run --env=prod -- tofu init -reconfigure -backend-config=envs/production/backend.hcl
```

Switch prod -> dev:
```bash
infisical run --env=dev -- tofu init -reconfigure -backend-config=envs/development/backend.hcl
```

## Plan and Apply

Development:
```bash
infisical run --env=dev -- tofu init -reconfigure -backend-config=envs/development/backend.hcl
```
```bash
infisical run --env=dev -- tofu plan -var-file=envs/development/terraform.tfvars
```
```bash
infisical run --env=dev -- tofu apply -var-file=envs/development/terraform.tfvars
```

Production:
```bash
infisical run --env=prod -- tofu init -reconfigure -backend-config=envs/production/backend.hcl
```
```bash
infisical run --env=prod -- tofu plan -var-file=envs/production/terraform.tfvars
```
```bash
infisical run --env=prod -- tofu apply -var-file=envs/production/terraform.tfvars
```

Notes:
- The active backend determines which state `tofu output` reads from.
- Always use the matching `-var-file` for the environment.

## Infisical Kubernetes Auth (Token Reviewer)

The Token Reviewer service account is managed by OpenTofu. Retrieve its JWT from state outputs using
the correct backend.

Development:
```bash
infisical run --env=dev -- tofu init -reconfigure -backend-config=envs/development/backend.hcl
```
```bash
infisical run --env=dev -- tofu output -raw -no-color infisical_token_reviewer_token
```
```bash
infisical run --env=dev -- tofu output -raw -no-color kubernetes_ca_certificate
```

Production:
```bash
infisical run --env=prod -- tofu init -reconfigure -backend-config=envs/production/backend.hcl
```
```bash
infisical run --env=prod -- tofu output -raw -no-color infisical_token_reviewer_token
```
```bash
infisical run --env=rpod -- tofu output -raw -no-color kubernetes_ca_certificate
```

Infisical configuration:
- Kubernetes Host / Base Kubernetes API URL (dev): `https://k8s-dev-api.local.zech.co:6443`
- Kubernetes Host / Base Kubernetes API URL (prod): `https://k8s-prod-api.local.zech.co:6443`
- Token Reviewer JWT: token from `infisical-token-reviewer`
- Allowed Namespaces: `infisical`
- Allowed Service Account Names: `infisical-service-account`
- Advanced > CA Certificate: from OpenTofu output

## Export kubeconfig and talosconfig

These outputs are produced from the currently initialized backend state.

Development:
```bash
infisical run --env=dev -- tofu init -reconfigure -backend-config=envs/development/backend.hcl
```
```bash
infisical run --env=dev -- tofu output -raw -no-color kubeconfig > ~/.kube/config-dev && chmod 600 ~/.kube/config-dev
```
```bash
infisical run --env=dev -- tofu output -raw -no-color talosconfig > ~/.talos/config-dev && chmod 600 ~/.talos/config-dev
```

Production:
```bash
infisical run --env=prod -- tofu init -reconfigure -backend-config=envs/production/backend.hcl
```
```bash
infisical run --env=prod -- tofu output -raw -no-color kubeconfig > ~/.kube/config-prod && chmod 600 ~/.kube/config-prod
```
```bash
infisical run --env=prod -- tofu output -raw -no-color talosconfig > ~/.talos/config-prod && chmod 600 ~/.talos/config-prod
```

## Use Both Clusters Without Re-exporting

### Kubernetes contexts (kubectl)

Merge both kubeconfigs into the default location:
```bash
KUBECONFIG=$HOME/.kube/config-dev:$HOME/.kube/config-prod kubectl config view --merge --flatten > $HOME/.kube/config
```
```bash
chmod 600 ~/.kube/config
```

List and switch contexts:
```bash
kubectl config get-contexts
```
```bash
kubectl config use-context <context-name>
```

### Talos contexts (talosctl)

Talos supports multiple contexts in a single config:
```bash
talosctl config merge ~/.talos/config-dev
```
```bash
talosctl config merge ~/.talos/config-prod
```

List and switch contexts:
```bash
talosctl config contexts
```
```bash
talosctl config use-context <context-name>
```
