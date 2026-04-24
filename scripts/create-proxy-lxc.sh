#!/usr/bin/env bash
set -euo pipefail

CT_ID="${CT_ID:-131}"
HOSTNAME="${HOSTNAME:-proxy}"
IP_CIDR="${IP_CIDR:-192.168.0.31/24}"
GATEWAY="${GATEWAY:-192.168.0.1}"
STORAGE="${STORAGE:-local-lvm}"
ROOTFS_SIZE="${ROOTFS_SIZE:-8}"
MEMORY_MB="${MEMORY_MB:-1024}"
CORES="${CORES:-1}"
PASSWORD="${PASSWORD:-}"
TEMPLATE_STORAGE="${TEMPLATE_STORAGE:-local}"
TEMPLATE="${TEMPLATE:-debian-12-standard_12.7-1_amd64.tar.zst}"

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Run this on the Proxmox host as root." >&2
  exit 1
fi

if pct status "${CT_ID}" >/dev/null 2>&1; then
  echo "CT ${CT_ID} already exists. Leaving it unchanged."
  pct status "${CT_ID}"
  exit 0
fi

if [[ -z "${PASSWORD}" ]]; then
  echo "Set PASSWORD before running, for example: PASSWORD='change-me' ./scripts/create-proxy-lxc.sh" >&2
  exit 1
fi

if [[ ! -f "/var/lib/vz/template/cache/${TEMPLATE}" ]]; then
  echo "Template ${TEMPLATE} not found. Downloading Debian 12 standard template..."
  pveam update
  pveam download "${TEMPLATE_STORAGE}" "${TEMPLATE}"
fi

pct create "${CT_ID}" "${TEMPLATE_STORAGE}:vztmpl/${TEMPLATE}" \
  --hostname "${HOSTNAME}" \
  --cores "${CORES}" \
  --memory "${MEMORY_MB}" \
  --rootfs "${STORAGE}:${ROOTFS_SIZE}" \
  --net0 "name=eth0,bridge=vmbr0,ip=${IP_CIDR},gw=${GATEWAY}" \
  --features nesting=1 \
  --unprivileged 1 \
  --onboot 1 \
  --password "${PASSWORD}" \
  --start 1

echo "Created CT ${CT_ID} (${HOSTNAME}) at ${IP_CIDR}."
echo "Next: ssh root@${IP_CIDR%/*} or run the Ansible playbook from the Codex CLI machine."
