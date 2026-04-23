# Claude Code Setup

Opinionated Claude Code configuration: layered principles, shared contracts and policies, persona playbooks, and custom subagents.

## Structure

```
CLAUDE.md                     # L1 cross-cutting principles (execution mindset, response altitude,
                              #   scope discipline, double-loop, layered abstraction, plan altitude).
                              #   Imports L2 via @-syntax.
contracts/                    # L2 — shapes of artifacts flowing between agents
  finding.md                  #   finding shape (severity × scope tags, required fields)
  scope-block.md              #   Problem / In scope / Out of scope shape
  plan.md                     #   plan artifact shape (scope block + plan altitude + site list)
  code-change.md              #   code change artifact shape (scope block + diff + context)
policies/                     # L2 — shared behavioral rules across roles
  synthesis.md                #   routing matrix, output precedence, deferred capture
  scope-discipline.md         #   scope-tagging obligations, scope-change requests, anti-patterns
  contract-enforcement.md     #   orchestrator = sole gate; reviewers trust the gate
vocabulary.md                 # L2 — shared glossary (composition blindness, default-by-omission,
                              #   sibling shapes, altitude, double-loop, contract vs policy vs vocab)
playbooks/                    # L3 — persona-specific procedures, loaded on-demand
  orchestrator.md             #   Plan Review Flow + Code Review Flow (owns contract enforcement)
  planner.md                  #   plan mode protocol, plan completeness test, authoring guidance
  implementer.md              #   implementation discipline, commit gating
agents/                       # Custom subagents (inherit L1 + L2, keep their own expansion)
  rfc-reviewer.md             #   structured plan audit
  rfc-red-team.md             #   adversarial plan scenarios
  code-review-analyst.md      #   code quality + RFC adherence
  ux-reviewer.md              #   user-facing flows through persona lenses
  security-researcher.md      #   attack surface decomposition
sidekick-prompts/             # Reusable prompts (gating-review.md)
```

### Layer discipline

- **Contract** = shape of an artifact that flows between agents. Enforced at boundaries (the orchestrator gate).
- **Policy** = behavioral rule within or across roles. Self-policed within the role.
- **Vocabulary** = shared definition that neither prescribes behavior nor specifies a shape.

See `vocabulary.md` for the full decomposition and how to decide where a new rule lives.

## Usage

Clone and run the installer from the repo root:

```bash
git clone https://github.com/<you>/claude-setup.git ~/projects/claude-setup
~/projects/claude-setup/install.sh
```

The installer symlinks `CLAUDE.md`, `vocabulary.md`, `agents/`, `contracts/`, `policies/`, `playbooks/`, and `sidekick-prompts/` into `~/.claude`. It is idempotent — re-run it after `git pull` whenever the repo's structure changes (new directories, renamed files). Existing correct symlinks are left alone; stale symlinks are updated. A real file or directory blocking a target is reported but never overwritten.

Claude Code picks these up automatically across all projects once the symlinks are in place.

## License

Apache 2.0
