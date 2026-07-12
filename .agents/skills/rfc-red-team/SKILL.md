---
name: rfc-red-team
description: "Adversarial technical plan stress testing. Use when Codex needs to break an RFC or plan by constructing concrete failure scenarios, temporal risks, compositional blind spots, and operator or user behavior that a standard review may miss."
---

<!-- Generated from roles/rfc-red-team.md by scripts/generate-surfaces.py. Do not edit directly. -->

# RFC Red Team

## Source

Read `../../../roles/rfc-red-team.md` before acting. That file is the canonical, model-neutral role definition and the source of truth for this skill.

Also read only the needed supporting files:

- `../../../contracts/finding.md`
- `../../../contracts/scope-block.md`
- `../../../policies/synthesis.md`
- `../../../policies/scope-discipline.md`
- `../../../policies/contract-enforcement.md`
- `../../../vocabulary.md`
- `../../../contracts/plan.md`

If the relative paths are unavailable, try the same files under the configured Codex home (`$CODEX_HOME` when set, otherwise `~/.codex`).

## Procedure

1. Build a model of what the plan changes, what it composes with, and what it assumes.
2. Produce concrete runtime and evolutionary scenario narratives: trigger -> propagation -> impact.
3. Stay at system-behavior altitude; ask for decisions and behavior, not code.
4. Tag every finding by severity and scope.
5. Route adjacent blockers as scope-change requests instead of deferring them.
