# cli-code-setup Repository

This repository maintains a small Codex-primary operating setup with a minimal
Claude compatibility surface.

- `codex/AGENTS.md` is the global Codex instruction file.
- `codex/agents/*.toml` are the only custom Codex agents.
- `CLAUDE.md` and `agents/*.md` provide the equivalent Claude surface.
- Runtime files are intentionally direct and hand-maintained. Do not introduce
  generators, shared contract layers, or new roles unless repeated real work
  proves they are necessary.
- Keep Codex and Claude behavior aligned when changing a shared principle.
- Treat `NEW_CODEX_OPERATING_MODEL.md` and `docs/darkline/` as historical design
  evidence, not runtime instructions.
- Validate shell syntax and run both installers in check mode after changes.
