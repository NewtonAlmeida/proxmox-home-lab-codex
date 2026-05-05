# Backup And Transfer Plan

## Goal

Back up the current production Home Assistant OS and ZimaOS from old `lab2`
(`192.168.0.11`), transfer backups to new `home-lab` (`192.168.0.10`), and
restore side-by-side for testing without overwriting fresh services.

## Chosen Strategy

- Use SSH for Proxmox operations.
- Stop each source VM during backup for consistency.
- Back up and transfer one VM at a time.
- Restore to temporary VM IDs on the new host.
- Do not overwrite current fresh services.
- Do not migrate the old ZimaOS 7T data disk yet.

## Preflight Inventory

Run read-only checks first:

```bash
ssh lab2 "qm list && qm config 100 && qm config 101 && pvesm status && zfs list && lsblk"
ssh home-lab "qm list && pct list && pvesm status"
```

Confirm:

- Source VM `100 haos-16.3` exists and can be stopped.
- Source VM `101 ZimaOS` exists and can be stopped.
- Target has enough storage for HAOS system disk and ZimaOS system disk.
- Temporary restore IDs are free on target.

## Backup Scope

HAOS VM `100`:

- Include the 32G OS disk.
- Inspect the 350G extra disk before backup.
- If the extra disk is unused, set `backup=0` on that disk before `vzdump`.
- If the extra disk is used, stop and create a larger storage plan first.

ZimaOS VM `101`:

- Include the about 82G system disk.
- Exclude the about 7T `virtio1` data disk for now.
- Record the original disk config before changing any `backup=0` flags.

## Backup Commands Pattern

Use this pattern, adjusting only after confirming disk scope:

```bash
ssh lab2 "qm shutdown 100 --timeout 120"
ssh lab2 "vzdump 100 --mode stop --compress zstd --storage local --notes-template 'HAOS migration backup'"
ssh lab2 "qm start 100"

ssh lab2 "qm shutdown 101 --timeout 120"
ssh lab2 "vzdump 101 --mode stop --compress zstd --storage local --notes-template 'ZimaOS system migration backup'"
ssh lab2 "qm start 101"
```

Generate checksums:

```bash
ssh lab2 "cd /var/lib/vz/dump && sha256sum vzdump-qemu-100-*.vma.zst > haos-backup.sha256"
ssh lab2 "cd /var/lib/vz/dump && sha256sum vzdump-qemu-101-*.vma.zst > zimaos-backup.sha256"
```

## Transfer To New Host

Use the local PC as the bridge:

```bash
scp -3 lab2:/var/lib/vz/dump/vzdump-qemu-100-*.vma.zst home-lab:/var/lib/vz/dump/
scp -3 lab2:/var/lib/vz/dump/vzdump-qemu-101-*.vma.zst home-lab:/var/lib/vz/dump/
scp -3 lab2:/var/lib/vz/dump/*backup.sha256 home-lab:/var/lib/vz/dump/
```

Verify checksums on target:

```bash
ssh home-lab "cd /var/lib/vz/dump && sha256sum -c haos-backup.sha256"
ssh home-lab "cd /var/lib/vz/dump && sha256sum -c zimaos-backup.sha256"
```

## Restore Side-By-Side

Use temporary IDs:

- HAOS restored VM: `121 haos-migrated`
- ZimaOS restored VM: `112 zimaos-migrated`

Restore examples:

```bash
ssh home-lab "qmrestore /var/lib/vz/dump/<haos-backup-file>.vma.zst 121 --storage local-lvm --unique 1"
ssh home-lab "qm set 121 --name haos-migrated --onboot 0"

ssh home-lab "qmrestore /var/lib/vz/dump/<zimaos-backup-file>.vma.zst 112 --storage local-lvm --unique 1"
ssh home-lab "qm set 112 --name zimaos-migrated --onboot 0"
```

Boot and test one restored VM at a time to avoid IP conflicts.

## Validation

HAOS:

- UI loads.
- Add-ons, Supervisor, integrations, automations, dashboards, and users appear.
- No IP conflict with old HAOS or fresh LXC `120`.

ZimaOS:

- UI loads.
- App list and configuration are visible.
- Apps that need the old 7T data disk may show missing storage until the later
  data migration phase.

Do not delete the source VMs or source backups after the first successful boot.

