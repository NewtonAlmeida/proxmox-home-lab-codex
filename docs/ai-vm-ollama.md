# AI VM With GPU Passthrough And Ollama

Create and validate this VM before changing the rest of the lab.

## Target

| Item | Value |
|------|-------|
| VM ID | 104 |
| Name | ai |
| IP | 192.168.0.23 |
| OS | Ubuntu Server LTS or Debian |
| CPU | 4 vCPU |
| RAM | 6GB |
| Disk | 64GB minimum |
| GPU | Pass through the whole GPU only to this VM |
| First model | `qwen2.5:0.5b-base` |

## Rules

- The GPU belongs only to VM `104 ai`.
- Do not attach the GPU to HAOS, ZimaOS, hub, trip-logger, proxy, or any other VM/container.
- Test `qwen2.5:0.5b-base` before continuing the rest of the migration.
- If the test fails, stop and fix GPU/Ollama before changing anything else.

## Proxmox GPU Passthrough Notes

Use Proxmox PCI passthrough for the whole GPU. The exact PCI device ID must be discovered on the Proxmox host:

```bash
lspci -nn | grep -Ei 'vga|3d|display|audio'
```

The GPU often has at least two functions:

- VGA/3D/display controller
- HDMI/DP audio device

Pass all GPU-related functions to VM `104 ai`.

## Ollama Install

After the VM boots and SSH works, use Ansible:

```bash
ansible-playbook ansible/install-ollama-ai.yml
```

The playbook installs Ollama using the official installer and runs:

```bash
ollama pull qwen2.5:0.5b-base
ollama run qwen2.5:0.5b-base "Reply with exactly: AI OK"
```

## Verification

From Codex CLI:

```bash
curl http://192.168.0.23:11434/api/tags
ssh root@192.168.0.23 "ollama run qwen2.5:0.5b-base 'Reply with exactly: AI OK'"
```

Optional GPU checks inside the VM:

```bash
lspci | grep -Ei 'vga|3d|display|nvidia|amd|radeon'
nvidia-smi || true
rocm-smi || true
```

## References

- Ollama Linux installer: https://ollama.com/install.sh
- Ollama `qwen2.5:0.5b-base`: https://ollama.com/library/qwen2.5:0.5b-base
- Proxmox PCI passthrough: https://pve.proxmox.com/wiki/PCI_Passthrough
