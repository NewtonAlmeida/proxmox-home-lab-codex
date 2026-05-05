# Next Steps

## On The Other PC

1. Clone this repo.
2. Read `handoff/README.md`.
3. Configure SSH for `home-lab` and `lab2`.
4. Test SSH to both Proxmox hosts.
5. Confirm current guest state with `qm list && pct list`.

## Continue The Migration

1. Inventory old `lab2` again.
2. Confirm target storage on `home-lab`.
3. Confirm Pi-hole direct DNS works and router/DHCP DNS is still unchanged.
4. Confirm VM `104 codex-agent` SSH/tooling requirements.
5. Decide whether HAOS VM `100` extra `350G` disk is used.
6. Exclude unused or too-large data disks from backups.
7. Stop and back up old HAOS VM `100`.
8. Transfer and verify the HAOS backup.
9. Restore HAOS to temporary VM `121`.
10. Stop and back up old ZimaOS VM `101` system disk only.
11. Transfer and verify the ZimaOS backup.
12. Restore ZimaOS to temporary VM `112`.
13. Test restored VMs one at a time.

## Do Not Do Yet

- Do not overwrite fresh VM `102 zimaos`.
- Do not overwrite fresh LXC `120 ha`.
- Do not migrate the old ZimaOS 7T data disk.
- Do not expose the AI VM's raw VNC or noVNC directly to the LAN.
- Do not expose Proxmox to the internet.
- Do not open router ports `80` or `443`.
- Do not cut router/DHCP DNS over to Pi-hole until the operator is ready.
- Do not commit secrets.

## Later Cutover

After restored HAOS and ZimaOS are verified:

1. Choose which Home Assistant install becomes final: restored HAOS VM or fresh Core LXC.
2. Choose which ZimaOS install becomes final: restored old ZimaOS or fresh ZimaOS VM.
3. Update DHCP reservations or static IPs.
4. Complete `.home` local DNS records for local testing.
5. Update Nginx Proxy Manager hosts.
6. Configure local HTTPS.
7. Configure backups and test restore.
