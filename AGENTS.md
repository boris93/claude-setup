# claude-setup Repo Instructions

This repo maintains shared agent setup for Claude Code and Codex.

- Canonical reusable role definitions live in `roles/*.md`.
- Generated runtime surfaces live in `agents/*.md` for Claude and
  `.agents/skills/*` for Codex.
- Do not hand-edit generated files. Edit `roles/*.md`, then run
  `scripts/generate-surfaces.py`.
- Validate generated surfaces before installing with
  `scripts/generate-surfaces.py --check`.
- The global Codex instruction file lives at `codex/AGENTS.md` and is symlinked
  to `${CODEX_HOME:-~/.codex}/AGENTS.md` by `install-codex.sh`.
