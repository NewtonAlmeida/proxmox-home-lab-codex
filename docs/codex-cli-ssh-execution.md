# Codex CLI SSH Execution Guide

This guide is for running the HTTPS plan from Codex CLI over SSH.

## What Codex CLI Should Do

Use SSH for Proxmox-specific work, then use Ansible for the repeatable Linux setup inside the proxy LXC.

| Step | Tool | Why |
|------|------|-----|
| Create LXC `131 proxy` | SSH to Proxmox + `pct` | Proxmox owns container creation |
| Install Docker and NPM | Ansible over SSH to `192.168.0.31` | Repeatable, readable, rerunnable |
| Configure NPM UI | Browser/manual | Needs Cloudflare token and service-specific ports |

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
scp scripts/create-proxy-lxc.sh root@192.168.0.10:/root/create-proxy-lxc.sh
```

Run it on Proxmox:

```bash
ssh root@192.168.0.10 "chmod +x /root/create-proxy-lxc.sh && PASSWORD='change-this-password' /root/create-proxy-lxc.sh"
```

Replace `change-this-password` before running.

## 2. Confirm The Proxy LXC Exists

```bash
ssh root@192.168.0.10 "pct status 131 && pct config 131"
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
   - `haos.lab.yourdomain.com`
   - `zima.lab.yourdomain.com`
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
curl -Ik https://haos.lab.yourdomain.com
curl -Ik https://zima.lab.yourdomain.com
curl -Ik https://proxmox.lab.yourdomain.com
```

## Notes

- Ansible is useful here because Docker/NPM installation is package-heavy and should be rerunnable.
- Proxmox LXC creation stays as an SSH script because `pct` is native to the Proxmox host.
- Keep router ports `80` and `443` closed for this local-only setup.
