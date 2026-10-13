# ⚙️ configs/ – Beispielkonfigurationen

> ⚠️ **Alles hier ist Vorlage mit `<<PLACEHOLDER>>`.** Blindes Kopieren kann dich aussperren, Netze trennen oder GPUs unbrauchbar machen. Immer zuerst **IPMI-/Konsolen-Zugang** sicherstellen, Konfigurationen mit `--check` / `nft -c` validieren, und Änderungen einzeln anwenden.

## 📂 Inhalt

| Verzeichnis | Zweck | Hauptdateien |
|---|---|---|
| [`sdn/`](sdn/) | Proxmox SDN (VLAN/VXLAN/EVPN) | `zones.cfg`, `vnets.cfg`, `subnets.cfg`, `controllers.cfg`, `pvesh-sdn-setup.sh` |
| [`vfio/`](vfio/) | GPU-Passthrough (IOMMU, Blacklist, GRUB, VM.conf) | siehe [`vfio/README-vfio.md`](vfio/README-vfio.md) |
| [`nftables/`](nftables/) | Edge-Firewall (Default Drop, Sets, VLAN-Policy) | `edge.nft`, `sets-helpers.sh` |
| [`network/`](network/) | `/etc/network/interfaces` Vorlage | `interfaces.example` |
| [`ansible/`](ansible/) | Host-Baseline (ARC, SSH) | `inventory.yml`, `site.yml` |
| [`terraform/`](terraform/) | VM als Code (bpg/proxmox) | `main.tf`, `variables.tf`, `terraform.tfvars.example` |

## 🚨 Warnungen

1. **Ausperr-Risiko:** nftables `policy drop` + falsche Whitelist = kein SSH mehr. IPMI offen halten.
2. **Corosync:** Storage-Traffic nie auf denselben Link wie den einzigen Corosync-Ring.
3. **VFIO:** `allow_unsafe_interrupts=1` schwächt die Isolation – **nie** für Malware-/Honeypot-VMs.
4. **Secrets:** API-Tokens, SSH-Keys, Passwörter **nicht** committen (`terraform.tfvars` ist gitignored).
5. **Rechtliches:** Honeypots und offensive Labs nur isoliert und rechtlich abgesichert betreiben.
6. **Westmere:** Siehe [docs/reality-check.md](../docs/reality-check.md) bevor du GPUs/TB5 erwartest.

## ✅ Empfohlene Reihenfolge

```text
1. network/interfaces.example  →  ifreload -a
2. Cluster bilden (pvecm) mit dediziertem Corosync-Link
3. ZFS-ARC (ansible oder manuell)
4. SDN (pvesh-sdn-setup.sh)
5. nftables (nft -c && nft -f) aus IPMI-Session
6. VFIO (nur auf GPU-Nodes)
7. Terraform/Ansible für Workloads
```
