# Next Steps

## On The Other PC

1. Clone this repo.
2. Read `handoff/README.md`.
3. Configure SSH for `home-lab` and `lab2`.
4. Power on the new Proxmox host if it is still off.
5. Test SSH to both Proxmox hosts.

## Continue The Migration

1. Inventory old `lab2` again.
2. Confirm target storage on `home-lab`.
3. Decide whether HAOS VM `100` extra `350G` disk is used.
4. Exclude unused or too-large data disks from backups.
5. Stop and back up old HAOS VM `100`.
6. Transfer and verify the HAOS backup.
7. Restore HAOS to temporary VM `121`.
8. Stop and back up old ZimaOS VM `101` system disk only.
9. Transfer and verify the ZimaOS backup.
10. Restore ZimaOS to temporary VM `112`.
11. Test restored VMs one at a time.

## Do Not Do Yet

- Do not overwrite fresh VM `102 zimaos`.
- Do not overwrite fresh LXC `120 ha`.
- Do not migrate the old ZimaOS 7T data disk.
- Do not expose Proxmox to the internet.
- Do not open router ports `80` or `443`.
- Do not commit secrets.

## Later Cutover

After restored HAOS and ZimaOS are verified:

1. Choose which Home Assistant install becomes final: restored HAOS VM or fresh Core LXC.
2. Choose which ZimaOS install becomes final: restored old ZimaOS or fresh ZimaOS VM.
3. Update DHCP reservations or static IPs.
4. Update Nginx Proxy Manager hosts.
5. Configure local HTTPS.
6. Configure backups and test restore.

