terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.94.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.10.1"
    }
    flux = {
      source  = "fluxcd/flux"
      version = "1.7.6"
    }
    github = {
      source  = "integrations/github"
      version = "6.11.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
    }
  }
}
