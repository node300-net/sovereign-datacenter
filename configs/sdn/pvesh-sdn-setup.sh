#!/usr/bin/env bash
# Proxmox VE SDN – Setup via API (pvesh). Auf EINEM Cluster-Node als root ausführen.
# ⚠️ BEISPIEL: Bridges, Tags und Subnetze an deine Umgebung anpassen. Idempotenz ist NICHT garantiert.
set -euo pipefail

BRIDGE="${BRIDGE:-vmbr0}"            # <<PLACEHOLDER>> VLAN-aware Bridge
PEERS="${PEERS:-10.10.40.10,10.10.40.11,10.10.40.12,10.10.40.13}"  # <<PLACEHOLDER>> VXLAN-Peers

echo "==> Zonen"
pvesh create /cluster/sdn/zones --type vlan  --zone lab --bridge "$BRIDGE" --ipam pve
pvesh create /cluster/sdn/zones --type vlan  --zone dmz --bridge "$BRIDGE" --ipam pve
pvesh create /cluster/sdn/zones --type vxlan --zone ovl --peers "$PEERS" --mtu 1450 --ipam pve

echo "==> VNets"
pvesh create /cluster/sdn/vnets --vnet vdmz50  --zone dmz --tag 50     --alias "Honeypot-DMZ"
pvesh create /cluster/sdn/vnets --vnet vlab60  --zone lab --tag 60     --alias "RedTeam-Lab"
pvesh create /cluster/sdn/vnets --vnet vana80  --zone lab --tag 80     --alias "Analytics"
pvesh create /cluster/sdn/vnets --vnet vxadlab --zone ovl --tag 100060 --alias "AD-Overlay"

echo "==> Subnetze (Gateway = SEC-CORE auf NODE 0)"
pvesh create /cluster/sdn/vnets/vdmz50/subnets --type subnet --subnet 10.10.50.0/24 --gateway 10.10.50.1
pvesh create /cluster/sdn/vnets/vlab60/subnets --type subnet --subnet 10.10.60.0/24 --gateway 10.10.60.1

echo "==> Anwenden (reload auf allen Nodes)"
pvesh set /cluster/sdn

echo "==> Status"
pvesh get /cluster/sdn/zones --output-format yaml
pvesh get /cluster/sdn/vnets --output-format yaml
