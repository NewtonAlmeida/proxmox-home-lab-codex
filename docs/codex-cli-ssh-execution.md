# Codex CLI SSH Execution Guide

This guide is for running the setup plan from Codex CLI over SSH.

## What Codex CLI Should Do

Use SSH for Proxmox-specific work, then use Ansible for repeatable Linux setup inside VMs and LXCs.

Do not use a Proxmox MCP/API layer for this phase. SSH + Ansible is the chosen path because it is transparent, easy to audit, and already supported by the repo.

| Step | Tool | Why |
|------|------|-----|
| Create LXC `131 proxy` | SSH to Proxmox + `pct` | Proxmox owns container creation |
| Check VM `104 codex-agent` | SSH to Proxmox + `qm` | Proxmox owns VM config and guest-agent checks |
| Install Docker and NPM | Ansible over SSH to `192.168.0.31` | Repeatable, readable, rerunnable |
| Install Ollama | Ansible over SSH to `192.168.0.23` | Repeatable, readable, rerunnable |
| Configure NPM UI | Browser/manual | Needs Cloudflare token and service-specific ports |

## Noninteractive SSH Baseline

Codex CLI should not depend on password prompts or interactive SSH sessions.

Create a dedicated key:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/home-lab-codex -C "codex-home-lab"
ssh-copy-id -i ~/.ssh/home-lab-codex.pub root@192.168.0.10
```

Recommended `~/.ssh/config`:

```sshconfig
Host home-lab
  HostName 192.168.0.10
  User root
  IdentityFile ~/.ssh/home-lab-codex
  BatchMode yes
  StrictHostKeyChecking accept-new
```

Verify:

```bash
ssh -o BatchMode=yes home-lab "hostname && pveversion"
```

After first successful connection, change `StrictHostKeyChecking accept-new` to `StrictHostKeyChecking yes`.

## Files

| File | Purpose |
|------|---------|
| `scripts/create-proxy-lxc.sh` | Creates Debian LXC `131 proxy` on Proxmox |
| `ansible/inventory.example.ini` | Example Ansible inventory for `192.168.0.31` |
| `ansible/install-nginx-proxy-manager.yml` | Installs Docker + Nginx Proxy Manager |
| `docs/https-local-npm.md` | Human runbook for final UI and DNS steps |

## 1. Copy The LXC Script To Proxmox

From the Codex CLI machine:

```bash
scp scripts/create-proxy-lxc.sh home-lab:/root/create-proxy-lxc.sh
```

Run it on Proxmox:

```bash
ssh home-lab "chmod +x /root/create-proxy-lxc.sh && PASSWORD='change-this-password' /root/create-proxy-lxc.sh"
```

Replace `change-this-password` before running.

## 2. Confirm The Proxy LXC Exists

```bash
ssh home-lab "pct status 131 && pct config 131"
```

Expected:

- CT ID: `131`
- hostname: `proxy`
- IP: `192.168.0.31/24`
- nesting enabled
- onboot enabled

## 3. Prepare Ansible Inventory

Copy the example:

```bash
cp ansible/inventory.example.ini ansible/inventory.ini
```

If SSH uses a non-root user or key, edit `ansible/inventory.ini`.

This repo includes `ansible.cfg`, so from the project root Codex CLI can run the playbook without passing `-i` after `ansible/inventory.ini` exists.

## 4. Run Ansible

From the project root:

```bash
ansible-playbook -i ansible/inventory.ini ansible/install-nginx-proxy-manager.yml
```

Or, using the repo `ansible.cfg`:

```bash
ansible-playbook ansible/install-nginx-proxy-manager.yml
```

If SSH host keys are not known yet:

```bash
ssh root@192.168.0.31 "hostname"
```

Then rerun the playbook.

## 5. Open Nginx Proxy Manager

```text
http://192.168.0.31:81
```

Default login:

```text
Email: admin@example.com
Password: changeme
```

Change the login immediately.

## 6. Manual Steps That Should Not Be Automated Yet

Do these manually in the Nginx Proxy Manager UI:

1. Add your Cloudflare DNS API token.
2. Request wildcard certificate for:
   - `*.lab.yourdomain.com`
   - `lab.yourdomain.com`
3. Add proxy hosts for:
   - `ha.lab.yourdomain.com`
   - `zima.lab.yourdomain.com`
   - `ai.lab.yourdomain.com`
   - `pihole.lab.yourdomain.com`
   - `hub.lab.yourdomain.com`
   - `trip.lab.yourdomain.com`
   - `proxmox.lab.yourdomain.com`

Do not put the Cloudflare token in git.

## 7. Verification Commands

From Codex CLI:

```bash
ssh root@192.168.0.31 "docker compose -f /opt/nginx-proxy-manager/docker-compose.yml ps"
curl -I http://192.168.0.31:81
```

After local DNS and certificates are configured:

```bash
curl -Ik https://ha.lab.yourdomain.com
curl -Ik https://zima.lab.yourdomain.com
curl -Ik https://ai.lab.yourdomain.com
curl -Ik https://pihole.lab.yourdomain.com
curl -Ik https://proxmox.lab.yourdomain.com
```

## Notes

- Ansible is useful here because Docker/NPM/Ollama installation is package-heavy and should be rerunnable.
- Proxmox LXC creation stays as an SSH script because `pct` is native to the Proxmox host.
- Proxmox VM creation and GPU passthrough should stay in guided SSH/`qm` scripts until the process is stable.
- Avoid interactive commands such as `pct enter` in Codex automation.
- Keep router ports `80` and `443` closed for this local-only setup.

---

## 8. Deploy ZimaOS VM

ZimaOS runs as a VM on Proxmox. Create it via `qm` over SSH.

### Create VM

```bash
ssh home-lab "qm create 102 \
  --name zimaos \
  --cores 2 \
  --memory 4096 \
  --net0 virtio,bridge=vmbr0 \
  --scsihw virtio-scsi-single \
  --boot order=scsi0 \
  --bios ovmf \
  --machine q35 \
  --ostype l26 \
  --onboot 1"
```

### Attach Disk

```bash
ssh home-lab "qm set 102 --scsi0 local:25,format=qcow2"
```

### Configure Network

```bash
ssh home-lab "qm set 102 --ipconfig0 ip=192.168.0.22/24,gw=192.168.0.1"
```

### USB Passthrough (Optional)

If passing through USB storage:

```bash
ssh home-lab "qm set 102 --hostpci0 01:00"
```

### Start VM

```bash
ssh home-lab "qm start 102"
```

### Install ZimaOS

1. Attach ZimaOS ISO to VM.
2. Boot and follow installer.
3. Access at `http://192.168.0.22`.

---

## 9. Deploy Pi-hole LXC

Create Pi-hole at `192.168.0.30`.

### Create LXC

```bash
ssh home-lab "pct create 130 \
  local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst \
  --hostname pihole \
  --cores 1 \
  --memory 512 \
  --rootfs local-lvm:2 \
  --net0 name=eth0,bridge=vmbr0,ip=192.168.0.30/24,gw=192.168.0.1 \
  --features nesting=1 \
  --unprivileged 1 \
  --onboot 1 \
  --start 1"
```

### Install Pi-hole

```bash
ssh home-lab "pct start 130"
ssh home-lab "pct exec 130 -- curl -sSL https://install.pi-hole.net | bash -s -- --unattended"
```

### Set Admin Password

```bash
ssh home-lab "pct exec 130 -- pihole -a -p 'your-secure-password'"
```

---

## 10. Deploy Home Assistant LXC

Create Home Assistant at `192.168.0.20`.

### Create LXC

```bash
ssh home-lab "pct create 120 \
  local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst \
  --hostname ha \
  --cores 2 \
  --memory 2048 \
  --rootfs local-lvm:8 \
  --net0 name=eth0,bridge=vmbr0,ip=192.168.0.20/24,gw=192.168.0.1 \
  --features nesting=1 \
  --unprivileged 1 \
  --onboot 1 \
  --start 1"
```

### Install Dependencies

```bash
ssh home-lab "pct exec 120 -- apt update"
ssh home-lab "pct exec 120 -- apt install -y python3 python3-venv python3-pip git"
```

### Install Home Assistant

```bash
ssh home-lab "pct exec 120 -- bash -c 'cd /opt && python3 -m venv ha && /opt/ha/bin/pip install homeassistant'"
```

### Start Home Assistant

```bash
ssh home-lab "pct exec 120 -- bash -c 'source /opt/ha/bin/activate && nohup hass > /var/log/ha.log 2>&1 &'"
```

---

## 11. ZimaOS App Configuration

After ZimaOS VM is running at `192.168.0.22`:

### Access ZimaOS

```text
http://192.168.0.22
```

### Install Apps via Market

1. Open ZimaOS web UI.
2. Go to App Market.
3. Search and install:
   - Vaultwarden
   - Cloudflare Tunnel
   - Immich

### Vaultwarden Setup

- Set admin token
- Configure storage to USB
- Access at `http://192.168.0.22`

### Cloudflare Tunnel Setup

- Add tunnel token
- Configure remote access
- Do NOT open ports publicly

### Immich Setup

- Configure:
  - Photo storage: USB
  - Database: Local storage
- Set up backup to NAS

---

## 12. Network DNS Configuration

Point router/firewall to use Pi-hole at `192.168.0.30`:

```bash
ssh home-lab "pct exec 130 -- pihole -a ip 192.168.0.30"
```

Or configure router DHCP to serve `192.168.0.30` as DNS.
