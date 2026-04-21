# Claude Code Setup

Opinionated Claude Code configuration: layered principles, shared contracts, persona playbooks, and custom subagents.

## Structure

```
CLAUDE.md              # L1 cross-cutting principles (execution mindset, response altitude, scope discipline,
                       #   double-loop feedback, layered abstraction). Imports L2 contracts via @-syntax.
contracts/             # L2 shared contracts — loaded by every session and subagent
  finding-schema.md    #   severity × scope taxonomy, routing matrix, output precedence
  scope-protocol.md    #   problem scope block as a mandatory input to every review
  deferred-policy.md   #   routing for adjacent findings (not absorbed, not dropped)
  vocabulary.md        #   shared glossary: composition blindness, default-by-omission,
                       #     sibling shapes, altitude, double-loop
playbooks/             # L3 persona-specific procedures — loaded on-demand by the main session
  orchestrator.md      #   Plan Review Flow + Code Review Flow
  planner.md           #   plan mode protocol, plan completeness test
  implementer.md       #   implementation discipline, commit gating rules
agents/                # Custom subagents (rfc-reviewer, rfc-red-team, code-review-analyst,
                       #   ux-reviewer, security-researcher) — inherit L1 + L2, keep their own expansion
sidekick-prompts/      # Reusable prompts (gating-review.md)
```

## Usage

Symlink into your `~/.claude` directory so Claude Code picks up the global config:

```bash
mkdir -p ~/.claude
ln -sf /path/to/claude-setup/CLAUDE.md ~/.claude/CLAUDE.md
ln -sfn /path/to/claude-setup/agents ~/.claude/agents
ln -sfn /path/to/claude-setup/contracts ~/.claude/contracts
ln -sfn /path/to/claude-setup/playbooks ~/.claude/playbooks
ln -sfn /path/to/claude-setup/sidekick-prompts ~/.claude/sidekick-prompts
```

The `contracts` and `playbooks` symlinks are required for CLAUDE.md's `@contracts/*.md` imports to resolve regardless of whether Claude Code uses the symlink path or the real path.

That's it. Claude Code picks these up automatically across all projects.

## License

Apache 2.0
