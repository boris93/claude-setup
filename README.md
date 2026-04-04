# Claude Code Setup

Opinionated Claude Code configuration: custom agents, review workflows, and sidekick prompts.

## What's Inside

```
CLAUDE.md              # Global instructions (plan review flow, code review flow, feedback processing)
agents/                # Custom subagents (rfc-reviewer, rfc-red-team, ux-reviewer, security-researcher, code-review-analyst)
sidekick-prompts/      # Reusable prompts (gating-review.md)
```

## Usage

Symlink into your `~/.claude` directory:

```bash
mkdir -p ~/.claude
ln -sf /path/to/claude-setup/CLAUDE.md ~/.claude/CLAUDE.md
ln -sfn /path/to/claude-setup/agents ~/.claude/agents
ln -sfn /path/to/claude-setup/sidekick-prompts ~/.claude/sidekick-prompts
```

That's it. Claude Code picks these up automatically across all projects.

## License

Apache 2.0
