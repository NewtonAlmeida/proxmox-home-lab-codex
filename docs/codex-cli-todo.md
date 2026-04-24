# CODEX CLI TODO - Proxmox Prep And Local HTTPS

Use this checklist after Proxmox has been installed bare metal as `home-lab` at `192.168.0.10`.

## Current Facts

| Item | Value |
|------|-------|
| Proxmox hostname | `home-lab` |
| Proxmox IP/CIDR | `192.168.0.10/24` |
| Gateway | `192.168.0.1` |
| DNS | `192.168.0.1` |
| HTTPS proxy target | LXC `131 proxy` at `192.168.0.31` |
| AI VM target | VM `104 ai` at `192.168.0.23` |
| VM range | `192.168.0.20-29` |
| LXC range | `192.168.0.30-39` |

## 1. Confirm Codex CLI Environment

- [ ] Confirm Codex CLI can reach Proxmox:

```bash
ping -c 3 192.168.0.10
```

- [ ] Confirm Proxmox web UI is reachable:

```bash
curl -Ik https://192.168.0.10:8006
```

- [ ] Confirm SSH to Proxmox works:

```bash
ssh root@192.168.0.10 "hostname && pveversion"
```

- [ ] If `home-lab` should resolve locally, test it:

```bash
ping -c 3 home-lab
ssh root@home-lab "hostname"
```

If `home-lab` does not resolve, continue using `192.168.0.10`.

## 2. Confirm Proxmox Is Ready

- [ ] Check storage:

```bash
ssh root@192.168.0.10 "pvesm status"
```

- [ ] Check network bridge:

```bash
ssh root@192.168.0.10 "ip addr show vmbr0 && ip route"
```

- [ ] Check available LXC templates:

```bash
ssh root@192.168.0.10 "pveam update && pveam available --section system | grep debian-12"
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

## 4. Create And Test AI VM First

Do this before changing the rest of the lab.

- [ ] Create VM `104 ai` at `192.168.0.23`.
- [ ] Use Ubuntu Server LTS or Debian.
- [ ] Assign initial resources:
  - 4 vCPU
  - 6GB RAM
  - 64GB disk minimum
- [ ] Pass the whole GPU only to VM `104 ai`.
- [ ] Do not attach the GPU to any other VM or LXC.
- [ ] Confirm SSH to the AI VM works:

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

- [ ] Copy the LXC creation script:

```bash
scp scripts/create-proxy-lxc.sh root@192.168.0.10:/root/create-proxy-lxc.sh
```

- [ ] Run the script on Proxmox:

```bash
ssh root@192.168.0.10 "chmod +x /root/create-proxy-lxc.sh && PASSWORD='replace-this-password' /root/create-proxy-lxc.sh"
```

- [ ] Verify LXC `131 proxy`:

```bash
ssh root@192.168.0.10 "pct status 131 && pct config 131"
```

- [ ] Confirm SSH to the proxy LXC works:

```bash
ssh root@192.168.0.31 "hostname && cat /etc/os-release"
```

## 6. Confirm Proxy Ansible Connection

- [ ] Test Ansible connection to `proxy`:

```bash
ansible proxy -m ping
```

## 7. Install Nginx Proxy Manager

- [ ] Run the playbook:

```bash
ansible-playbook ansible/install-nginx-proxy-manager.yml
```

- [ ] Verify Docker Compose stack:

```bash
ssh root@192.168.0.31 "docker compose -f /opt/nginx-proxy-manager/docker-compose.yml ps"
```

- [ ] Confirm Nginx Proxy Manager UI:

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

Point these names to `192.168.0.31` in router, Pi-hole, or local DNS:

| DNS Name | IP |
|----------|----|
| `proxmox.lab.yourdomain.com` | `192.168.0.31` |
| `haos.lab.yourdomain.com` | `192.168.0.31` |
| `zima.lab.yourdomain.com` | `192.168.0.31` |
| `hub.lab.yourdomain.com` | `192.168.0.31` |
| `trip.lab.yourdomain.com` | `192.168.0.31` |

Keep router ports `80` and `443` closed.

## 10. Add NPM Proxy Hosts

Add these in Nginx Proxy Manager:

| Domain | Scheme | Forward Host / IP | Port | Notes |
|--------|--------|-------------------|------|-------|
| `proxmox.lab.yourdomain.com` | `https` | `192.168.0.10` | `8006` | Add `proxy_ssl_verify off;` in Advanced |
| `haos.lab.yourdomain.com` | `http` | `192.168.0.21` | `8123` | Enable Websockets |
| `zima.lab.yourdomain.com` | `http` | `192.168.0.22` | `80` | Adjust if ZimaOS uses HTTPS |
| `hub.lab.yourdomain.com` | `http` | `192.168.0.20` | `TBD` | Fill real hub port |
| `trip.lab.yourdomain.com` | `http` | `192.168.0.30` | `TBD` | Fill real trip-logger port |

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
curl -Ik https://haos.lab.yourdomain.com
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
