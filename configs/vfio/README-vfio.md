# 🎮 VFIO / GPU-Passthrough – Schritt für Schritt

> ⚠️ Westmere-Plattform (Intel 5520, PCIe 2.0). Siehe [Reality Check RC-2/RC-3/RC-4/RC-10](../../docs/reality-check.md).

| # | Schritt | Befehl / Datei |
|---|---|---|
| 1 | BIOS: **VT-d** + **VT-x** aktivieren | IPMI-KVM |
| 2 | Kernel-Cmdline | [`grub-default.snippet`](grub-default.snippet) → `update-grub` |
| 3 | Module laden | [`modules`](modules) → an `/etc/modules` anhängen |
| 4 | Host-Treiber blacklisten | [`blacklist-gpu.conf`](blacklist-gpu.conf) → `/etc/modprobe.d/` |
| 5 | GPU-IDs an vfio-pci | [`vfio.conf`](vfio.conf) → IDs mit `lspci -nn` einsetzen |
| 6 | initramfs neu bauen | `update-initramfs -u -k all` → Reboot |
| 7 | Prüfen | `dmesg \| grep -e DMAR -e IOMMU -e "remapping"` · `lspci -nnk -s <<BUS>>` → `Kernel driver in use: vfio-pci` |
| 8 | IOMMU-Gruppen | [`iommu-groups.sh`](iommu-groups.sh) |
| 9 | Nur falls IR deaktiviert | [`iommu-unsafe-interrupts.conf.disabled`](iommu-unsafe-interrupts.conf.disabled) – **Sicherheits-Tradeoff lesen!** |
| 10 | VM konfigurieren | [`vm-210-gpu-ml.conf.example`](vm-210-gpu-ml.conf.example) |

### 🧯 Typische Probleme auf alter Hardware

| Symptom | Ursache | Ansatz |
|---|---|---|
| `No IOMMU groups` | VT-d aus / BIOS-Bug | BIOS-Option, DMAR-Tabelle (`dmesg`) |
| `Interrupt remapping disabled` + vfio-Fehler | 5520-Erratum | `allow_unsafe_interrupts=1` (nur vertrauenswürdige Gäste) |
| GPU zeigt `LnkSta: x1` oder `2.5GT/s` | Riser-Signalqualität | Riser reseaten, kürzer, Gen1 im BIOS testen |
| VM bootet nicht mit OVMF + GPU | GPU-VBIOS ohne UEFI-GOP (ältere Karten) | `bios: seabios` testen oder ROM-File (`romfile=`) |
| Reset-Probleme nach VM-Neustart | GPU-Reset-Bug | VM einmalig, Host-Reboot; bei NVIDIA selten |
| `Code 43` (Windows) | Sehr alte NVIDIA-Treiber | Aktueller Treiber (seit R465 offiziell VM-tauglich) |
