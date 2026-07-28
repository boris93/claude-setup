# Codex / Claude Setup

Codex-primary, Claude-compatible coding-agent configuration: layered
principles, shared contracts and policies, persona playbooks, canonical role
definitions, generated Codex skill adapters, and generated Claude Code
subagents.

## Structure

```
AGENTS.md                     # Repo-local Codex instructions for maintaining this setup repo.
codex/AGENTS.md               # Primary Codex L1 cross-cutting principles, adapted to
                              #   Codex's explicit file loading and skill mechanisms.
CLAUDE.md                     # Claude-compatible L1 principles. Imports L2 via @-syntax.
contracts/                    # L2 — shapes of artifacts flowing between agents
  finding.md                  #   finding shape (severity × scope tags, required fields)
  scope-block.md              #   Problem / In scope / Out of scope shape
  plan.md                     #   plan artifact shape (scope block + plan altitude + site list +
                              #     conditional temporal composition)
  code-change.md              #   code change artifact shape (scope block + diff + context)
  review-ledger.md            #   cumulative review history for resolution and convergence
  rfc-implementation-closure.md # final RFC-to-code traceability closure
policies/                     # L2 — shared behavioral rules across roles
  synthesis.md                #   routing matrix, output precedence, deferred capture
  scope-discipline.md         #   scope-tagging obligations, scope-change requests, anti-patterns
  contract-enforcement.md     #   orchestrator = sole gate; reviewers trust the gate
vocabulary.md                 # L2 — shared glossary (composition blindness, default-by-omission,
                              #   sibling shapes, altitude, double-loop, contract vs policy vs vocab)
roles/                        # Canonical model-neutral role definitions and surface metadata
playbooks/                    # L3 — persona-specific procedures, loaded on-demand
  orchestrator.md             #   Plan Review Flow + Code Review Flow (owns contract enforcement)
  planner.md                  #   plan mode protocol, plan completeness test, authoring guidance
  implementer.md              #   implementation discipline, commit gating
.agents/skills/               # Generated Codex skill adapters (do not edit directly)
agents/                       # Generated Claude Code subagents (do not edit directly)
  rfc-reviewer.md             #   structured plan audit (soundness)
  rfc-red-team.md             #   adversarial plan scenarios (robustness)
  rfc-minimizer.md            #   plan minimality audit (subtractive findings, post-convergence)
  rfc-implementation-verifier.md # final RFC-to-code closure
  code-review-analyst.md      #   implementation-quality review
  ux-reviewer.md              #   user-facing flows through persona lenses
  security-researcher.md      #   attack surface decomposition
  review-convergence-analyst.md # pre-fix resolution challenge + convergence diagnosis
sidekick-prompts/             # Reusable prompts (gating-review.md)
scripts/generate-surfaces.py  # Generates agents/ and .agents/skills/ from roles/
```

### Layer discipline

- **Contract** = shape of an artifact that flows between agents. Enforced at boundaries (the orchestrator gate).
- **Policy** = behavioral rule within or across roles. Self-policed within the role.
- **Vocabulary** = shared definition that neither prescribes behavior nor specifies a shape.

See `vocabulary.md` for the full decomposition and how to decide where a new rule lives.

### Generated surfaces

`roles/*.md` is the source of truth for reusable reviewer roles. The generated
runtime surfaces are:

- `.agents/skills/*` for Codex skills.
- `agents/*.md` for Claude Code subagents.

After editing `roles/*.md`, regenerate and validate:

```bash
scripts/generate-surfaces.py
scripts/generate-surfaces.py --check
```

Both installers run `scripts/generate-surfaces.py --check` and fail if the
generated surfaces are stale.

## Codex Usage

Clone and run the Codex installer from the repo root:

```bash
git clone git@github.com:boris93/cli-code-setup.git ~/projects/cli-code-setup
~/projects/cli-code-setup/install-codex.sh
```

For fresh machines or CI-style checks, validate without installing:

```bash
~/projects/cli-code-setup/install-codex.sh --check
~/projects/cli-code-setup/install-codex.sh --dry-run
```

The Codex installer first checks that generated surfaces are current, then
symlinks `codex/AGENTS.md` to `${CODEX_HOME:-~/.codex}/AGENTS.md` and symlinks
`vocabulary.md`, `roles/`, `agents/`, `contracts/`, `policies/`, `playbooks/`,
and `sidekick-prompts/` into `${CODEX_HOME:-~/.codex}`. It also symlinks each
Codex skill adapter from `.agents/skills/` into `~/.agents/skills/`.

Codex then picks up the global `AGENTS.md` on startup and exposes the role
adapters as skills such as `$rfc-reviewer`, `$rfc-red-team`,
`$rfc-implementation-verifier`, `$code-review-analyst`, `$ux-reviewer`,
`$security-researcher`, `$review-convergence-analyst`, and `$gating-review`.

## Claude Usage

Claude Code remains a supported compatibility surface. Clone and run its
installer from the repo root:

```bash
git clone git@github.com:boris93/cli-code-setup.git ~/projects/cli-code-setup
~/projects/cli-code-setup/install.sh
```

The installer first checks that generated surfaces are current, then symlinks
`CLAUDE.md`, `vocabulary.md`, `roles/`, `agents/`, `contracts/`,
`policies/`, `playbooks/`, and `sidekick-prompts/` into `~/.claude`. It is
idempotent — re-run it after `git pull` whenever the repo's structure changes
(new directories, renamed files). Existing correct symlinks are left alone;
stale symlinks are updated. A real file or directory blocking a target is
reported but never overwritten.

Claude Code picks these up automatically across all projects once the symlinks
are in place.

## License

Apache 2.0
