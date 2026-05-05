# CODEX CLI TODO - Desktop-server-codex-05-05

Use this checklist for the current desktop server build on `home-lab` at
`192.168.0.10`.

## Current Facts

| Item | Value |
|------|-------|
| Project | `Desktop-server-codex-05-05` |
| Proxmox hostname | `home-lab` |
| Proxmox IP/CIDR | `192.168.0.10/24` |
| Gateway | `192.168.0.1` |
| DNS | `192.168.0.30` (Pi-hole) |
| ZimaOS VM | `102 zimaos` at `192.168.0.22` |
| Home Assistant | `120 ha` at `192.168.0.20` |
| Pi-hole | `130 pihole` at `192.168.0.30` |
| Nginx Proxy Manager | `131 proxy` at `192.168.0.31` |
| AI VM | `104 codex-agent` at `192.168.0.23` |
| VM range | `192.168.0.20-29` |
| LXC range | `192.168.0.30-39` |
| USB enclosure | Not attached/detected yet |

## Current Deployment Status - 2026-05-05

| Component | Status | Notes |
|-----------|--------|-------|
| Proxmox host | Done | `home-lab` is reachable over SSH and web UI at `192.168.0.10`. |
| Codex SSH | Done | SSH key auth works through the `home-lab` SSH config entry. |
| Proxmox packages | Done | No-subscription apt repos enabled; Ansible and ShellCheck installed on the Proxmox control side. |
| ZimaOS | Done | VM `102 zimaos` is installed from `zimaos-x86_64-1.6.1_installer.img` and reachable at `http://192.168.0.22`. |
| Home Assistant | Done | LXC `120 ha` serves Home Assistant at `http://192.168.0.20:8123`. |
| Pi-hole | Done | LXC `130 pihole` serves DNS and web UI at `http://192.168.0.30/admin/`; direct DNS queries work. Router/DHCP DNS cutover is not done. |
| Nginx Proxy Manager | Done | LXC `131 proxy` serves NPM at `http://192.168.0.31:81`; change the default admin login if not already done. |
| Local DNS | Partial | `.home` is current local testing. Confirmed through Pi-hole: `ai.home -> 192.168.0.31`, `pihole.home -> 192.168.0.30`. Windows/local testing is in use; router DNS is unchanged. |
| Local HTTPS | Pending | Cloudflare DNS challenge, local DNS records, and proxy hosts are not configured yet. |
| AI VM | Done / needs app setup | VM `104 codex-agent` runs at `192.168.0.23`; browser access is `http://ai.home/vnc.html?autoconnect=true&resize=remote`; Ubuntu 24.04.4 LTS, root SSH user, sudo installed. Ollama/GPU validation is not confirmed. |
| External USB storage | Pending | No external storage device was detected on the Proxmox host during deployment. |

## 0. SSH Setup (Required Before Codex)

Two options:

### Option A: Auto-setup script (recommended)

```bash
# Run the setup script - does everything automatically
bash scripts/setup-codex-env.sh
```

This script:
- Creates SSH key if not exists
- Adds SSH config
- Copies public key to Proxmox
- Tests connectivity
- Sets up Ansible inventory

### Option B: Manual steps

- [ ] Create dedicated SSH key for Codex:

  ```bash
  ssh-keygen -t ed25519 -f ~/.ssh/home-lab-codex -C "codex-home-lab"
  ```

- [ ] Copy public key to Proxmox:

  **Go to Proxmox Shell** (not Datacenter SSH Keys):

  1. Go to: **https://192.168.0.10:8006**
  2. Select node → **Shell**
  3. Run:
  ```bash
  mkdir -p ~/.ssh
  echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL7WmQhDV2sLllzUHpaDDGITxu7hOL9yK6OirjKX15lw codex-home-lab" >> ~/.ssh/authorized_keys
  ```

  Or use `ssh-copy-id`:
  ```bash
  ssh-copy-id -i ~/.ssh/home-lab-codex.pub root@192.168.0.10
  ```

- [ ] Add SSH config to avoid prompts (no SSH agent needed):

  Create `~/.ssh/config`:

  ```
  Host home-lab
    HostName 192.168.0.10
    User root
    IdentityFile ~/.ssh/home-lab-codex
    BatchMode yes
    StrictHostKeyChecking accept-new
  ```

- [ ] Test connectivity:

  ```bash
  ssh -o BatchMode=yes home-lab "hostname && pveversion"
  ```

  Expected output: hostname and Proxmox version

- [ ] Setup Ansible inventory:

  ```bash
  cp ansible/inventory.example.ini ansible/inventory.ini
  ```

## 1. Confirm Codex CLI Environment

- [ ] Confirm Codex CLI can reach Proxmox:

```bash
ping -c 3 192.168.0.10
```

- [ ] Confirm Proxmox web UI is reachable:

```bash
curl -Ik https://192.168.0.10:8006
```

- [ ] Create or confirm the dedicated SSH key for Codex CLI:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/home-lab-codex -C "codex-home-lab"
```

- [ ] Install the public key on Proxmox:

```bash
ssh-copy-id -i ~/.ssh/home-lab-codex.pub root@192.168.0.10
```

- [ ] Add this SSH config entry on the Codex CLI machine:

```sshconfig
Host home-lab
  HostName 192.168.0.10
  User root
  IdentityFile ~/.ssh/home-lab-codex
  BatchMode yes
  StrictHostKeyChecking accept-new
```

- [ ] Confirm noninteractive SSH to Proxmox works:

```bash
ssh -o BatchMode=yes home-lab "hostname && pveversion"
```

- [ ] If `home-lab` does not resolve through SSH config or DNS, continue using this explicit form:

```bash
ssh -i ~/.ssh/home-lab-codex -o BatchMode=yes root@192.168.0.10 "hostname && pveversion"
```

- [ ] After the first successful connection, change `StrictHostKeyChecking accept-new` to `StrictHostKeyChecking yes` in SSH config.

## 2. Confirm Proxmox Is Ready

- [ ] Check storage:

```bash
ssh home-lab "pvesm status"
```

- [ ] Check network bridge:

```bash
ssh home-lab "ip addr show vmbr0 && ip route"
```

- [ ] Check available LXC templates:

```bash
ssh home-lab "pveam update && pveam available --section system | grep debian-12"
```

## 3. Prepare Ansible

- [ ] Install Ansible on the Codex CLI machine if missing.

Debian/Ubuntu:

```bash
sudo apt update
sudo apt install -y ansible
```

macOS:

```bash
brew install ansible
```

- [ ] Create Ansible inventory:

```bash
cp ansible/inventory.example.ini ansible/inventory.ini
```

- [ ] Test the future proxy inventory entry after the proxy LXC exists.
- [ ] Test the AI inventory entry after the AI VM exists.

## 4. AI VM / Codex Agent VM

Current status: VM `104 codex-agent` exists and is running at `192.168.0.23`.
It is Ubuntu 24.04.4 LTS, uses SSH user `root`, has `sudo` installed, and the
QEMU guest agent responds. It is the current AI VM project.

Browser access:

```text
http://ai.home/vnc.html?autoconnect=true&resize=remote
```

Known config:

- [x] Create VM `104 codex-agent` at `192.168.0.23`.
- [x] Use Ubuntu 24.04 LTS.
- [x] Assign initial resources:
  - 4 vCPU
  - 6GB RAM
  - 40GB disk
- [ ] Pass the whole GPU only to VM `104 codex-agent`, if GPU passthrough is revisited.
- [ ] Do not attach the GPU to any other VM or LXC.
- [ ] Confirm direct SSH to the AI VM works from the operator machine:

```bash
ssh root@192.168.0.23 "hostname && uname -a"
```

- [ ] Add `ai` to the Ansible inventory:

```ini
[ai]
ai ansible_host=192.168.0.23 ansible_user=root
```

This is already present in `ansible/inventory.example.ini`. Confirm it exists in `ansible/inventory.ini`.

- [ ] Test Ansible connection to `ai`:

```bash
ansible ai -m ping
```

- [ ] Install Ollama and run the small model test:

```bash
ansible-playbook ansible/install-ollama-ai.yml
```

- [ ] Confirm Ollama is listening:

```bash
curl http://192.168.0.23:11434/api/tags
```

- [ ] Stop here if `qwen2.5:0.5b-base` does not run successfully.

## 5. Create Proxy LXC

Current status: done. LXC `131 proxy` is running at `192.168.0.31`.

- [x] Copy the LXC creation script:

```bash
scp scripts/create-proxy-lxc.sh home-lab:/root/create-proxy-lxc.sh
```

- [x] Run the script on Proxmox:

```bash
ssh home-lab "chmod +x /root/create-proxy-lxc.sh && PASSWORD='replace-this-password' /root/create-proxy-lxc.sh"
```

- [x] Verify LXC `131 proxy`:

```bash
ssh home-lab "pct status 131 && pct config 131"
```

- [x] Confirm SSH to the proxy LXC works:

```bash
ssh root@192.168.0.31 "hostname && cat /etc/os-release"
```

## 6. Confirm Proxy Ansible Connection

- [x] Test Ansible connection to `proxy`:

```bash
ansible proxy -m ping
```

## 7. Install Nginx Proxy Manager

Current status: done. Nginx Proxy Manager is reachable at `http://192.168.0.31:81`.
Change the default login if it has not already been changed.

- [x] Run the playbook:

```bash
ansible-playbook ansible/install-nginx-proxy-manager.yml
```

- [x] Verify Docker Compose stack:

```bash
ssh root@192.168.0.31 "docker compose -f /opt/nginx-proxy-manager/docker-compose.yml ps"
```

- [x] Confirm Nginx Proxy Manager UI:

```bash
curl -I http://192.168.0.31:81
```

Open:

```text
http://192.168.0.31:81
```

Default login:

```text
Email: admin@example.com
Password: changeme
```

Change this login immediately.

## 8. Manual HTTPS Setup

- [ ] Create Cloudflare API token with:
  - Zone / Zone / Read
  - Zone / DNS / Edit
  - Zone Resources: only the lab domain
- [ ] In Nginx Proxy Manager, request wildcard certificate:
  - `*.lab.yourdomain.com`
  - `lab.yourdomain.com`
- [ ] Use DNS challenge provider: Cloudflare.
- [ ] Do not save Cloudflare token in git.

## 9. Local DNS Records

Current status: router/DHCP DNS has not been changed. Use direct Pi-hole tests
or local Windows DNS configuration for now.

Current `.home` records confirmed through Pi-hole:

| DNS Name | IP | Status |
|----------|----|--------|
| `ai.home` | `192.168.0.31` | Confirmed |
| `pihole.home` | `192.168.0.30` | Confirmed |

Recommended next `.home` records for local testing:

| DNS Name | IP | Notes |
|----------|----|-------|
| `proxmox.home` | `192.168.0.10` | Direct Proxmox UI, self-signed HTTPS warning expected |
| `ha.home` | `192.168.0.20` | Direct Home Assistant |
| `zima.home` | `192.168.0.22` | Direct ZimaOS |
| `proxy.home` | `192.168.0.31` | Nginx Proxy Manager |
| `pihole.home` | `192.168.0.30` | Pi-hole admin |
| `ai.home` | `192.168.0.31` | Current record points to proxy; use `192.168.0.23` if direct AI VM access is preferred |

Future HTTPS plan: point these names to `192.168.0.31` in router, Pi-hole, or local DNS:

| DNS Name | IP |
|----------|----|
| `proxmox.lab.yourdomain.com` | `192.168.0.31` |
| `ha.lab.yourdomain.com` | `192.168.0.31` |
| `zima.lab.yourdomain.com` | `192.168.0.31` |
| `pihole.lab.yourdomain.com` | `192.168.0.31` |
| `hub.lab.yourdomain.com` | `192.168.0.31` |
| `trip.lab.yourdomain.com` | `192.168.0.31` |

Keep router ports `80` and `443` closed.
Do not cut router/DHCP DNS over to Pi-hole until the operator is ready.

## 10. Add NPM Proxy Hosts

Add these in Nginx Proxy Manager:

| Domain | Scheme | Forward Host / IP | Port | Notes |
|--------|--------|-------------------|------|-------|
| `proxmox.lab.yourdomain.com` | `https` | `192.168.0.10` | `8006` | Add `proxy_ssl_verify off;` in Advanced |
| `ha.lab.yourdomain.com` | `http` | `192.168.0.20` | `8123` | Enable Websockets |
| `zima.lab.yourdomain.com` | `http` | `192.168.0.22` | `80` | Adjust if ZimaOS uses HTTPS |
| `pihole.lab.yourdomain.com` | `http` | `192.168.0.30` | `80` | Optional; keep admin local-only |
| `hub.lab.yourdomain.com` | `http` | `TBD` | `TBD` | Fill after hub migration |
| `trip.lab.yourdomain.com` | `http` | `TBD` | `TBD` | Fill after trip-logger migration |

For all hosts:

- [ ] Select wildcard certificate.
- [ ] Enable Force SSL.
- [ ] Enable HTTP/2.

## 11. Verification

- [ ] Proxmox direct:

```bash
curl -Ik https://192.168.0.10:8006
```

- [ ] Nginx Proxy Manager direct:

```bash
curl -I http://192.168.0.31:81
```

- [ ] Ollama AI VM:

```bash
curl http://192.168.0.23:11434/api/tags
ssh root@192.168.0.23 "ollama run qwen2.5:0.5b-base 'Reply with exactly: AI OK'"
```

- [ ] HTTPS names after DNS/cert setup:

```bash
curl -Ik https://proxmox.lab.yourdomain.com
curl -Ik https://ha.lab.yourdomain.com
curl -Ik https://zima.lab.yourdomain.com
```

- [ ] Confirm from mobile data outside home that local-only HTTPS names do not work unless remote access was intentionally added.

## 12. Next Migration Tasks

- [ ] Back up current HAOS from old lab2.
- [ ] Back up current ZimaOS app data from old lab2.
- [ ] Back up current hub VM from old lab1.
- [ ] Back up current trip-logger LXC from old lab1.
- [ ] Create new VMs in `.20-.29` range.
- [ ] Create new LXCs in `.30-.39` range.
- [ ] Restore HAOS first.
- [ ] Restore trip-logger second.
- [ ] Restore hub third.
- [ ] Restore or rebuild ZimaOS last.

## Important Safety Rules

- Do not expose Proxmox directly to the internet.
- Do not open router ports `80` or `443` for the local-only HTTPS setup.
- Do not store Cloudflare tokens in this repo.
- Keep VM system disks on internal storage.
- Keep the external enclosure for data only.
- Use SSH + Ansible for this phase; do not introduce Proxmox MCP yet.
- Codex-run SSH commands must be noninteractive and use key auth.

## 13. Deploy ZimaOS VM

Current status: done. VM `102 zimaos` is running at `192.168.0.22` with 4 vCPU,
6144MB RAM, a 64GB system disk, UEFI boot, and boot from `scsi0`. The installer
media was removed after install. The uploaded image remains on Proxmox at
`/root/zimaos-x86_64-1.6.1_installer.img`.

- [ ] Review `docs/home-lab-structure.md` for ZimaOS requirements.
- [x] Create VM `102 zimaos` at `192.168.0.22`:
  - OS: ZimaOS installer image
  - 4 vCPU
  - 6144MB RAM
  - 64GB disk
  - UEFI boot
- [ ] Pass USB storage to ZimaOS VM. Pending; no external storage detected yet.
- [x] Boot VM and install ZimaOS from installer image.
- [x] Complete ZimaOS initial setup via web UI.
- [x] Confirm ZimaOS is reachable:

```bash
curl -I http://192.168.0.22
```

## 14. Deploy Pi-hole

Current status: done. LXC `130 pihole` is running at `192.168.0.30` with Pi-hole
Core v6.4.2, Web v6.5, and FTL v6.6.1. DNS queries resolve through Pi-hole.
The web UI is `http://192.168.0.30/admin/`. Router DNS cutover is still manual.

- [x] Create LXC `130 pihole` at `192.168.0.30`.
- [x] Use Debian 12 template.
- [x] Assign resources:
  - 1 vCPU
  - 512MB RAM
  - 2GB disk
- [x] Run the Pi-hole install playbook:

```bash
ansible-playbook -i ansible/inventory.ini ansible/install-pihole.yml
```

- [x] Configure Pi-hole admin password:

```bash
ssh home-lab "cat /root/pihole-admin-password.txt"
```

- [x] Verify Pi-hole:

```bash
curl -I http://192.168.0.30/admin/
dig +short @192.168.0.30 google.com
dig +short @192.168.0.30 pihole.home
```

- [ ] Point router/firewall DNS to `192.168.0.30`.

## 15. Deploy Home Assistant

Current status: done. LXC `120 ha` is running at `192.168.0.20`. Home Assistant
is installed in `/opt/homeassistant`, uses `/opt/homeassistant-config`, and runs
under the `home-assistant` systemd service. The web onboarding UI is available at
`http://192.168.0.20:8123`.

- [x] Create LXC `120 ha` at `192.168.0.20`.
- [x] Use Debian 12 template.
- [x] Assign resources:
  - 2 vCPU
  - 1GB RAM (2GB recommended)
  - 8GB disk
- [x] Install Home Assistant with the playbook:

```bash
ansible-playbook -i ansible/inventory.ini ansible/install-home-assistant.yml
```

- [x] Enable onboot and keep running:

```bash
ssh home-lab "pct set 120 -- onboot 1"
```

- [x] Verify Home Assistant:

```bash
curl -I http://192.168.0.20:8123
```

## 16. Configure ZimaOS Apps

After ZimaOS is running at `192.168.0.22`:

Current status: pending. ZimaOS base setup is complete, but Vaultwarden,
Cloudflare Tunnel, Immich, app storage paths, and backups still need configuration.

### 16.1 Vaultwarden

- [ ] Open ZimaOS web UI:

```text
http://192.168.0.22
```

- [ ] Go to App Market.
- [ ] Search and install "Vaultwarden" or "Bitwarden".
- [ ] Configure admin token.
- [ ] Set vault location to USB storage.
- [ ] Verify:

```bash
curl -I http://192.168.0.22:80
```

### 16.2 Cloudflare Tunnel

- [ ] In ZimaOS App Market, install "Cloudflare Tunnel".
- [ ] Add Cloudflare tunnel token.
- [ ] Configure tunnel for remote access.
- [ ] Do not expose ports publicly.

### 16.3 Immich (Photo Backup)

- [ ] In ZimaOS App Market, install "Immich".
- [ ] Configure:
  - Photo storage: USB enclosure
  - Database: Local storage (NOT USB)
- [ ] Verify:

```bash
curl -I http://192.168.0.22:2283
```

- [ ] Set up backup for:
  - `UPLOAD_LOCATION` (photos) to NAS
  - Database backup to NAS

## 17. Backup Setup

- [ ] Configure Proxmox backup to NAS:
  - Schedule daily VM/LXC backups
  - Retention: 7 daily, 4 weekly
- [ ] Configure ZimaOS backup:
  - Photos via Immich to NAS
  - Database via Immich backup job
- [ ] Configure Pi-hole backup:
  - Export gravity.db to NAS weekly
- [ ] Configure Home Assistant backup:
  - Export config to NAS daily
- [ ] Test restore from backup.

## 18. AI VM Follow-Up

- [x] Create VM `104 codex-agent` at `192.168.0.23`.
- [ ] Confirm direct SSH from the operator machine.
- [ ] Assign exclusive GPU passthrough if needed.
- [ ] Install Ollama.
- [ ] Test small model: `qwen2.5:0.5b-base`.
- [ ] Do not rely on the AI VM for larger local models until the small model test passes.

---

## Updated Network Reference

| ID | Name | Type | IP | Purpose |
|----|------|------|-----|---------|
| 102 | `zimaos` | VM | `192.168.0.22` | NAS + apps |
| 120 | `ha` | LXC | `192.168.0.20` | Home Assistant |
| 130 | `pihole` | LXC | `192.168.0.30` | DNS + DHCP |
| 131 | `proxy` | LXC | `192.168.0.31` | Nginx Proxy Manager |
| 104 | `codex-agent` | VM | `192.168.0.23` | AI/Codex agent project |
