# Beginner-Friendly Local HTTPS With Nginx Proxy Manager

This setup gives the home lab friendly HTTPS names on the local network without opening router ports.

## Final Layout

| Service | Type | IP | URL |
|---------|------|----|-----|
| Proxmox | Host | 192.168.0.10 | `https://proxmox.lab.yourdomain.com` |
| Home Assistant | LXC | 192.168.0.20 | `https://ha.lab.yourdomain.com` |
| zimaos | VM | 192.168.0.22 | `https://zima.lab.yourdomain.com` |
| AI / Codex Agent | VM | 192.168.0.23 | `https://ai.lab.yourdomain.com` |
| pihole | LXC | 192.168.0.30 | `https://pihole.lab.yourdomain.com` |
| proxy | LXC | 192.168.0.31 | `http://192.168.0.31:81` |
| hub | VM | TBD | `https://hub.lab.yourdomain.com` |
| trip-logger | LXC | TBD | `https://trip.lab.yourdomain.com` |

Replace `lab.yourdomain.com` with your real Cloudflare-managed domain or subdomain.
Current local testing uses `.home` names. Router/DHCP DNS has not been changed.

## 1. Create The Proxy LXC

Create a Debian LXC in Proxmox:

| Setting | Value |
|---------|-------|
| CT ID | 131 |
| Hostname | proxy |
| IP | 192.168.0.31/24 |
| Gateway | 192.168.0.1 |
| CPU | 1 core |
| RAM | 1GB |
| Disk | 8GB minimum |
| Features | nesting enabled |

For Codex CLI execution over SSH, use:

```text
docs/codex-cli-ssh-execution.md
```

After creating it, confirm nesting is enabled from the Proxmox host:

```bash
pct set 131 -features nesting=1
```

Start the container and enter the shell:

```bash
pct start 131
pct enter 131
```

## 2. Install Docker In The Proxy LXC

Inside the `proxy` LXC:

```bash
apt update
apt install -y ca-certificates curl gnupg
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
. /etc/os-release
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian ${VERSION_CODENAME} stable" > /etc/apt/sources.list.d/docker.list
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

## 3. Install Nginx Proxy Manager

Inside the `proxy` LXC:

```bash
mkdir -p /opt/nginx-proxy-manager
cd /opt/nginx-proxy-manager
```

Create `/opt/nginx-proxy-manager/docker-compose.yml` using the file in `proxy/docker-compose.yml` from this project.

Start it:

```bash
docker compose up -d
docker compose ps
```

Open the admin UI:

```text
http://192.168.0.31:81
```

Default first login:

```text
Email: admin@example.com
Password: changeme
```

Change the email and password immediately.

## 4. Create Cloudflare API Token

In Cloudflare, create an API token for the DNS challenge:

| Permission | Value |
|------------|-------|
| Zone / Zone | Read |
| Zone / DNS | Edit |
| Zone Resources | Include your domain only |

Keep the token private. Do not save it in this repo.

## 5. Request A Wildcard Certificate

In Nginx Proxy Manager:

1. Go to **SSL Certificates**.
2. Choose **Add SSL Certificate**.
3. Choose **Let's Encrypt**.
4. Add these domains:
   - `*.lab.yourdomain.com`
   - `lab.yourdomain.com`
5. Enable **Use a DNS Challenge**.
6. Choose **Cloudflare**.
7. Paste the Cloudflare API token.
8. Accept the Let's Encrypt terms.
9. Save.

## 6. Add Local DNS Records

Current confirmed Pi-hole records:

| DNS Name | IP |
|----------|----|
| `ai.home` | 192.168.0.31 |
| `pihole.home` | 192.168.0.30 |

Recommended `.home` direct local records while router DNS is not cut over:

| DNS Name | IP |
|----------|----|
| `proxmox.home` | 192.168.0.10 |
| `ha.home` | 192.168.0.20 |
| `zima.home` | 192.168.0.22 |
| `ai.home` | 192.168.0.31 |
| `pihole.home` | 192.168.0.30 |
| `proxy.home` | 192.168.0.31 |

For the future HTTPS plan, point each certificate-backed name to the proxy LXC:

| DNS Name | IP |
|----------|----|
| `proxmox.lab.yourdomain.com` | 192.168.0.31 |
| `ha.lab.yourdomain.com` | 192.168.0.31 |
| `zima.lab.yourdomain.com` | 192.168.0.31 |
| `ai.lab.yourdomain.com` | 192.168.0.31 |
| `pihole.lab.yourdomain.com` | 192.168.0.31 |
| `hub.lab.yourdomain.com` | 192.168.0.31 |
| `trip.lab.yourdomain.com` | 192.168.0.31 |

Do not open router ports `80` or `443`.
Do not change router/DHCP DNS to Pi-hole until the operator is ready for network-wide DNS.

## 7. Add Proxy Hosts

In Nginx Proxy Manager, add these proxy hosts:

| Domain | Scheme | Forward Hostname / IP | Port | Notes |
|--------|--------|------------------------|------|-------|
| `ha.lab.yourdomain.com` | `http` | `192.168.0.20` | `8123` | Enable Websockets |
| `zima.lab.yourdomain.com` | `http` | `192.168.0.22` | `80` | Use `https`/`443` if ZimaOS requires it |
| `ai.lab.yourdomain.com` | `http` | `192.168.0.23` | service port | Fill after AI service port is known |
| `pihole.lab.yourdomain.com` | `http` | `192.168.0.30` | `80` | Optional; keep admin local-only |
| `hub.lab.yourdomain.com` | `http` | TBD | service port | Replace after hub migration |
| `trip.lab.yourdomain.com` | `http` | TBD | service port | Replace after trip-logger migration |
| `proxmox.lab.yourdomain.com` | `https` | `192.168.0.10` | `8006` | Advanced config below |

For each host:

1. Go to the **SSL** tab.
2. Select the wildcard certificate.
3. Enable **Force SSL**.
4. Enable **HTTP/2 Support**.

For Proxmox, add this in the **Advanced** tab:

```nginx
proxy_ssl_verify off;
```

## 8. Home Assistant Reverse Proxy Setting

If Home Assistant rejects proxy traffic, add this to `configuration.yaml`:

```yaml
http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 192.168.0.31
```

Restart Home Assistant after changing it.

## 9. Test

From a device on the home network:

```text
https://ha.lab.yourdomain.com
https://zima.lab.yourdomain.com
https://ai.lab.yourdomain.com
https://pihole.lab.yourdomain.com
https://hub.lab.yourdomain.com
https://trip.lab.yourdomain.com
https://proxmox.lab.yourdomain.com
```

From mobile data outside the home, these should not work yet. That is expected for local-only HTTPS.

## Safety Rules

- Do not expose Proxmox directly to the internet.
- Do not open router ports `80` or `443` for this local-only setup.
- Do not commit Cloudflare tokens or passwords.
- Keep the proxy LXC on `192.168.0.31`.
- Keep VM IPs in `.20-.29` and container IPs in `.30-.39`.
