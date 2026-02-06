# Terraform/OpenTofu - Kubernetes Clusters

This repository uses a single root stack with environment-specific inputs stored
under `envs/development` and `envs/production`.

## Prerequisites

- OpenTofu installed (`tofu`)
- Access to Proxmox API and Infisical CLI (configured via `infisical init`)
- `kubectl` and `talosctl` for config usage (optional but recommended)


## Infisical secrets

Secrets are injected via Infisical CLI. Name them as TF vars:
- `TF_VAR_proxmox_api_token`
- `TF_VAR_github_token`

S3 backend auth):
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`

## Init

Use `-reconfigure` when switching between dev/prod backends.

Development (Infisical env slug `dev`):
```bash
infisical run --env=dev -- tofu init -backend-config=envs/development/backend.hcl
```

Production (Infisical env slug `prod`):
```bash
infisical run --env=prod -- tofu init -backend-config=envs/production/backend.hcl
```

Switch dev -> prod (or prod -> dev):
```bash
infisical run --env=prod -- tofu init -reconfigure -backend-config=envs/production/backend.hcl
```

## Quick start

Development (Infisical env slug `dev`):
```bash
infisical run --env=dev -- tofu init -reconfigure -backend-config=envs/development/backend.hcl
```
```bash
infisical run --env=dev -- tofu plan -var-file=envs/development/terraform.tfvars
```
```bash
infisical run --env=dev -- tofu apply -var-file=envs/development/terraform.tfvars
```

Production (Infisical env slug `prod`):
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
- Use the matching `-var-file` set for each environment.

## Export kubeconfig and talosconfig

These outputs are produced from the currently initialized backend state.

Development (Infisical env slug `dev`):
```bash
infisical run --env=dev -- tofu init -reconfigure -backend-config=envs/development/backend.hcl
```
```bash
tofu output -raw -no-color kubeconfig > ~/.kube/config-dev && chmod 600 ~/.kube/config-dev
```
```bash
tofu output -raw -no-color talosconfig > ~/.talos/config-dev && chmod 600 ~/.talos/config-dev
```

Production (Infisical env slug `prod`):
```bash
infisical run --env=prod -- tofu init -reconfigure -backend-config=envs/production/backend.hcl
```
```bash
tofu output -raw -no-color kubeconfig > ~/.kube/config-prod && chmod 600 ~/.kube/config-prod
```
```bash
tofu output -raw -no-color talosconfig > ~/.talos/config-prod && chmod 600 ~/.talos/config-prod
```

## Keep both clusters available without re-exporting

### Kubernetes contexts (kubectl)

Merge both kubeconfigs into the default location:
```bash
KUBECONFIG=~/.kube/config-dev:~/.kube/config-prod kubectl config view --merge --flatten > ~/.kube/config
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
