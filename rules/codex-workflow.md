# Codex Workflow Rules

- Read `AGENTS.md` and `codex.md` first.
- Use `docs/codex-cli-todo.md` as the operator checklist.
- Prefer small, reversible edits to docs and automation.
- Keep command examples copy/paste friendly.
- Use Ansible for repeatable Linux guest setup.
- Use Proxmox `pct`/`qm` commands only through SSH to the Proxmox host.
- If a command changes infrastructure state, document the verification step beside it.
- Update docs when scripts or playbooks change behavior.
