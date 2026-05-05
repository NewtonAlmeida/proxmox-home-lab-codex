# Manual Backup Suggestions

Use these if you prefer to restore settings into fresh installs instead of
restoring whole Proxmox VM backups.

## Home Assistant OS Manual Backup

Best option:

1. Open old HAOS at `http://192.168.0.176:8123`.
2. Go to Settings.
3. Open System.
4. Open Backups.
5. Create a full backup.
6. Download the backup to your PC.
7. Store another copy outside both Proxmox hosts.

This is the best manual path because it preserves:

- Home Assistant configuration.
- Automations and scripts.
- Dashboards.
- Users.
- Integrations.
- Add-ons and add-on data when using a full HAOS backup.

Fresh install restore path:

1. Install a fresh HAOS VM on the new Proxmox.
2. On the first onboarding screen, choose restore from backup.
3. Upload the full backup file.
4. Let HAOS restore and reboot.

Avoid restoring a HAOS full backup into Home Assistant Core LXC `120`. HAOS
backups are designed for HAOS/Supervised installs and may not cleanly restore
add-ons or Supervisor state into Core-only installs.

## ZimaOS Manual App Backup

ZimaOS apps are usually Docker/container-backed, so manual backup means saving
each app's configuration and data directories. Do this before deleting or
reinstalling apps.

Priority apps:

- Vaultwarden / Bitwarden.
- Immich.
- Cloudflare Tunnel.
- Any app with irreplaceable user data.

General approach:

1. In the old ZimaOS UI, list installed apps and note exposed ports.
2. For each app, find its storage path or app data location.
3. Stop the app before copying its data.
4. Copy the app folder to an external drive, NAS, or another safe location.
5. Restart the app and verify it still works.

Vaultwarden:

- Back up the Vaultwarden data directory.
- Make sure the database file and attachments are included.
- Save environment settings separately, but do not commit admin tokens or secrets.

Immich:

- Back up the Immich upload/library directory.
- Back up the Immich database separately.
- Keep photo storage and database backups together with the same timestamp.
- Do not put the database on slow or unreliable USB storage in the final install.

Cloudflare Tunnel:

- Record tunnel name and public hostnames.
- Save the tunnel credentials/config only in a secure password manager.
- Do not commit tunnel tokens or credentials.

## ZimaOS 7T Data Disk Warning

The old ZimaOS has a large about 7T data disk. Do not try to copy all of it to
the new Proxmox internal storage. The new host does not have enough internal
space.

Recommended manual path:

1. Back up only app settings and databases first.
2. Prepare external storage or NAS on the new system.
3. Copy selected data folders later.
4. Verify each app after restoring its data.

