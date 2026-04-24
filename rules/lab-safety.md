# Lab Safety Rules

- Do not expose Proxmox directly to the internet.
- Keep router ports `80` and `443` closed for the local-only HTTPS setup.
- Do not store Cloudflare tokens, passwords, SSH keys, or Bitwarden secrets in the repo.
- Keep VM system disks on internal Proxmox storage.
- Use the external enclosure for data only.
- Pass the GPU only to VM `104 ai`.
- Stop migration work if the AI VM cannot run the small Ollama test model.
- Back up HAOS, ZimaOS, hub, and trip-logger before replacing old services.

