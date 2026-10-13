# OpenTofu / Terraform – minimale Proxmox-VM (Provider: bpg/proxmox)
# ⚠️ BEISPIEL mit Platzhaltern. Niemals Tokens committen!
# Docs: https://registry.terraform.io/providers/bpg/proxmox/latest/docs

terraform {
  required_version = ">= 1.6.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.66"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox_endpoint          # z. B. https://10.10.10.10:8006/
  api_token = var.proxmox_api_token        # "user@pam!tokenid=geheim" via TF_VAR_ / *.tfvars (nicht committen)
  insecure  = var.proxmox_tls_insecure     # Lab: true, wenn selbstsigniertes Zertifikat
}

resource "proxmox_virtual_environment_vm" "cowrie" {
  name      = "cowrie-01"
  node_name = "pve-n1-defense"
  vm_id     = 150

  agent { enabled = true }
  cpu {
    cores = 2
    type  = "host"
  }
  memory { dedicated = 2048 }

  disk {
    datastore_id = "local-zfs"
    interface    = "scsi0"
    size         = 16
    discard      = "on"
    iothread     = true
  }

  network_device {
    bridge  = "vdmz50"     # SDN-VNet (siehe configs/sdn/)
    model   = "virtio"
    firewall = true
  }

  initialization {
    user_account {
      username = "debian"
      keys     = [var.ssh_public_key]
    }
    ip_config {
      ipv4 {
        address = "10.10.50.20/24"
        gateway = "10.10.50.1"
      }
    }
  }

  operating_system { type = "l26" }
  # clone { vm_id = <<TEMPLATE_VMID>>  full = false }   # Linked Clone vom Template
}
