#!/usr/bin/env bash
# Hilfsskript: dynamische Sets der Edge-Firewall befüllen
# Usage: ./sets-helpers.sh ban 203.0.113.50 [timeout_seconds]
#        ./sets-helpers.sh unban 203.0.113.50
#        ./sets-helpers.sh list
set -euo pipefail
ACTION="${1:-}"; ADDR="${2:-}"; TIMEOUT="${3:-3600}"
case "$ACTION" in
  ban)   nft add element inet filter blacklist4 "{ $ADDR timeout ${TIMEOUT}s }" ;;
  unban) nft delete element inet filter blacklist4 "{ $ADDR }" ;;
  list)  nft list set inet filter blacklist4 ;;
  *) echo "Usage: $0 ban|unban|list [addr] [timeout]" >&2; exit 1 ;;
esac
