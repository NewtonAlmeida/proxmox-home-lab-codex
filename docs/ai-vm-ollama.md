# AI VM With GPU Passthrough And Ollama

VM `104 codex-agent` now exists and is the AI VM project. Use this document to
validate or extend it.

## Target

| Item | Value |
|------|-------|
| VM ID | 104 |
| Name | codex-agent |
| IP | 192.168.0.23 |
| OS | Ubuntu 24.04.4 LTS |
| SSH user | root |
| Sudo | yes |
| Browser access | `http://ai.home/vnc.html?autoconnect=true&resize=remote` |
| CPU | 4 vCPU |
| RAM | 6GB |
| Disk | 40GB |
| GPU | Not confirmed |
| First model | `qwen2.5:0.5b-base` |

## Rules

- If GPU passthrough is enabled, the GPU belongs only to VM `104 codex-agent`.
- Do not attach the GPU to HAOS, ZimaOS, hub, trip-logger, proxy, or any other VM/container.
- Test `qwen2.5:0.5b-base` before using larger local models.
- If the test fails, fix Ollama/GPU before relying on the AI VM for migration work.

## Proxmox GPU Passthrough Notes

Use Proxmox PCI passthrough for the whole GPU. The exact PCI device ID must be discovered on the Proxmox host:

```bash
lspci -nn | grep -Ei 'vga|3d|display|audio'
```

The GPU often has at least two functions:

- VGA/3D/display controller
- HDMI/DP audio device

Pass all GPU-related functions to VM `104 codex-agent`.

## Ollama Install

After SSH works, use Ansible:

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
