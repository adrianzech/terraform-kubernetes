# Terraform/OpenTofu - Kubernetes Clusters

This repository uses a single root stack with environment-specific inputs stored
under `envs/development` and `envs/production`.

## Prerequisites

- OpenTofu installed (`tofu`)
- Access to Proxmox API and Vault
- `kubectl` and `talosctl` for config usage (optional but recommended)

## Example files

Copy the example files and fill in your values:
```bash
cp envs/development/backend.hcl.example envs/development/backend.hcl
```
```bash
cp envs/development/vault.auto.tfvars.example envs/development/vault.auto.tfvars
```
```bash
cp envs/development/terraform.tfvars.example envs/development/terraform.tfvars
```

Repeat for production:
```bash
cp envs/production/backend.hcl.example envs/production/backend.hcl
```
```bash
cp envs/production/vault.auto.tfvars.example envs/production/vault.auto.tfvars
```
```bash
cp envs/production/terraform.tfvars.example envs/production/terraform.tfvars
```

## Init

Use `-reconfigure` when switching between dev/prod backends.

Development:
```bash
tofu init -backend-config=envs/development/backend.hcl
```

Production:
```bash
tofu init -backend-config=envs/production/backend.hcl
```

Switch dev -> prod (or prod -> dev):
```bash
tofu init -reconfigure -backend-config=envs/production/backend.hcl
```

## Quick start

Development:
```bash
tofu init -reconfigure -backend-config=envs/development/backend.hcl
```
```bash
tofu plan -var-file=envs/development/terraform.tfvars -var-file=envs/development/vault.auto.tfvars
```
```bash
tofu apply -var-file=envs/development/terraform.tfvars -var-file=envs/development/vault.auto.tfvars
```

Production:
```bash
tofu init -reconfigure -backend-config=envs/production/backend.hcl
```
```bash
tofu plan -var-file=envs/production/terraform.tfvars -var-file=envs/production/vault.auto.tfvars
```
```bash
tofu apply -var-file=envs/production/terraform.tfvars -var-file=envs/production/vault.auto.tfvars
```

Notes:
- The active backend determines which state `tofu output` reads from.
- Use the matching `-var-file` set for each environment.

## Export kubeconfig and talosconfig

These outputs are produced from the currently initialized backend state.

Development:
```bash
tofu init -reconfigure -backend-config=envs/development/backend.hcl
```
```bash
tofu output -raw -no-color kubeconfig > ~/.kube/config-dev && chmod 600 ~/.kube/config-dev
```
```bash
tofu output -raw -no-color talosconfig > ~/.talos/config-dev && chmod 600 ~/.talos/config-dev
```

Production:
```bash
tofu init -reconfigure -backend-config=envs/production/backend.hcl
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
