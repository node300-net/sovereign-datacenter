#!/usr/bin/env bash
# Listet IOMMU-Gruppen mit Geräten. Eine GPU sollte (mit ihrer Audio-Funktion) allein in ihrer Gruppe sein.
set -euo pipefail
shopt -s nullglob
groups=(/sys/kernel/iommu_groups/*)
if [ ${#groups[@]} -eq 0 ]; then
  echo "Keine IOMMU-Gruppen gefunden → VT-d im BIOS aktiv? intel_iommu=on gesetzt? dmesg | grep -e DMAR -e IOMMU" >&2
  exit 1
fi
for g in $(printf '%s\n' "${groups[@]}" | sort -V); do
  echo "IOMMU Group ${g##*/}:"
  for d in "$g"/devices/*; do
    echo -e "\t$(lspci -nns "${d##*/}")"
  done
done
