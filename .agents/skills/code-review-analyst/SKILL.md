---
name: code-review-analyst
description: "Scoped implementation review. Use when Codex needs to review completed code changes for correctness, maintainability, codebase cohesion, edge cases, surface-level security, and RFC adherence when an RFC or plan is available."
---

<!-- Generated from roles/code-review-analyst.md by scripts/generate-surfaces.py. Do not edit directly. -->

# Code Review Analyst

## Source

Read `../../../roles/code-review-analyst.md` before acting. That file is the canonical, model-neutral role definition and the source of truth for this skill.

Also read only the needed supporting files:

- `../../../contracts/finding.md`
- `../../../contracts/scope-block.md`
- `../../../policies/synthesis.md`
- `../../../policies/scope-discipline.md`
- `../../../policies/contract-enforcement.md`
- `../../../vocabulary.md`
- `../../../contracts/code-change.md`

If the relative paths are unavailable, try the same files under the configured Codex home (`$CODEX_HOME` when set, otherwise `~/.codex`).

## Procedure

1. Inspect the actual diff and all new files.
2. Anchor review on the scope block, synthesizing one only if the change was a direct dirty-tree edit without a prior plan.
3. Review code quality first; review RFC adherence when an RFC or plan exists.
4. Cite exact file and line locations for findings.
5. Report introduced, actionable issues; route pre-existing adjacent issues according to the synthesis policy.
