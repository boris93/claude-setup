# Codex-Primary Setup

A deliberately small operating setup for one accountable primary agent with
native subagents and proportional review. It is designed for current Codex
capabilities and keeps a minimal Claude compatibility surface.

The active setup is intentionally boring:

```text
codex/AGENTS.md             primary Codex operating loop
codex/agents/reviewer.toml  independent plan or code review
codex/agents/verifier.toml  final request or plan-to-code closure
CLAUDE.md                   equivalent Claude operating loop
agents/reviewer.md          Claude reviewer
agents/verifier.md          Claude verifier
install-codex.sh            Codex installer and check
install.sh                  Claude installer
```

There are no workflow state machines, review ledgers, artifact contracts,
generated role adapters, or mandatory multi-phase gates. Codex already owns
agent spawning, steering, waiting, permissions, and result collection. This
repository adds only the behavioral defaults that remain useful across projects.

## Operating model

- The user talks to one primary; subagents remain an internal team.
- Voice-like input is synthesized into a usable brief by the primary.
- Workspace evidence is gathered before interpretation when it can answer the
  question.
- Clear action requests proceed without a redundant confirmation.
- Planning and validation scale with risk and change size.
- Native explorer and worker agents handle bounded discovery and implementation.
- The custom reviewer and verifier provide independent quality checks only when
  the work warrants them.
- Repeated review findings trigger scope or design reassessment instead of more
  process machinery.

## Codex installation

```bash
git clone git@github.com:boris93/cli-code-setup.git ~/projects/cli-code-setup
~/projects/cli-code-setup/install-codex.sh
```

The installer links `codex/AGENTS.md` to
`${CODEX_HOME:-~/.codex}/AGENTS.md` and the two custom agents into
`${CODEX_HOME:-~/.codex}/agents/`. It does not overwrite real files.

Validate without changing the installed setup:

```bash
./install-codex.sh --check
./install-codex.sh --dry-run
```

## Claude installation

```bash
~/projects/cli-code-setup/install.sh
```

This links `CLAUDE.md` and the two agent files into `~/.claude`. Validate the
source files without changing the installed setup with `./install.sh --check`.

Both installers remove only legacy symlinks that point back into this checkout;
they do not delete real files or unrelated custom agents.

## Historical design evidence

[`NEW_CODEX_OPERATING_MODEL.md`](NEW_CODEX_OPERATING_MODEL.md) preserves the
voice-first operating-model interview and settled product intent. The
[`docs/darkline/authoritative-host-poc`](docs/darkline/authoritative-host-poc)
archive records the abandoned controller PoC, its evidence, and why its
architecture must not be resumed. Neither is loaded as runtime instruction.

## Maintenance rule

Add a persistent rule or another custom agent only after repeated real work
shows that the primary model plus the current two agents cannot handle the need
reliably. Prefer a short direct instruction over a new layer or framework.

## License

Apache 2.0
