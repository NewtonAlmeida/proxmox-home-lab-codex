# Resume Prompt For Codex On Another PC

Paste this into the other Codex session:

```text
We are continuing the Proxmox home lab migration from this GitHub repo.

Read these files first:
- AGENTS.md
- codex.md
- README.md
- handoff/README.md
- handoff/current-state.md
- handoff/ssh-setup.md
- handoff/backup-plan.md
- handoff/manual-backups.md
- handoff/next-steps.md

Current target Proxmox is home-lab at 192.168.0.10. At last verification it was running VM 102 zimaos, VM 104 codex-agent, LXC 120 ha, LXC 130 pihole, and LXC 131 proxy.

VM 104 codex-agent is the new AI VM project. It is Ubuntu 24.04.4 LTS, IP 192.168.0.23, SSH user root, sudo installed. Browser access is http://ai.home/vnc.html?autoconnect=true&resize=remote. Ollama/GPU validation is not confirmed unless later docs say otherwise.

Pi-hole at 192.168.0.30 works for direct DNS queries. Router/DHCP DNS has not been changed to Pi-hole. Current DNS testing uses local/Windows context and .home records. Confirmed records include ai.home -> 192.168.0.31 and pihole.home -> 192.168.0.30.

Source Proxmox is lab2 at 192.168.0.11. Old HAOS is VM 100 at 192.168.0.176. Old ZimaOS is VM 101 at 192.168.0.163. Use SSH. lab2 uses the Bitwarden SSH agent. home-lab uses ~/.ssh/home-lab-codex.

Next goal: make clean stopped backups of old HAOS and old ZimaOS from lab2, transfer them to home-lab, and restore them side-by-side for testing. Do not overwrite the fresh services. Do not migrate the old ZimaOS 7T data disk yet; handle ZimaOS system/app disk first.

Before mutating anything, inventory both Proxmox hosts and confirm disk scope, storage availability, and temporary restore VM IDs.
```
