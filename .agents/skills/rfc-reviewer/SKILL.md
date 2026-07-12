---
name: rfc-reviewer
description: "Structured technical RFC and plan review. Use when Codex needs to audit an RFC, implementation plan, or final pre-implementation sign-off for soundness, completeness, reuse, alternatives, and plan-altitude correctness."
---

<!-- Generated from roles/rfc-reviewer.md by scripts/generate-surfaces.py. Do not edit directly. -->

# RFC Reviewer

## Source

Read `../../../roles/rfc-reviewer.md` before acting. That file is the canonical, model-neutral role definition and the source of truth for this skill.

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

1. Anchor on the user's scope block or synthesize the narrowest faithful one.
2. Review at plan altitude: decisions, shapes, interfaces, site lists, temporal composition, and invariants, not implementation bodies.
3. Apply the canonical role spec from roles/rfc-reviewer.md.
4. Emit findings using the shared finding contract, with severity and scope tags.
5. Keep adjacent issues separate; do not expand the plan scope silently.
