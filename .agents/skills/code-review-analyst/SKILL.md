---
name: code-review-analyst
description: "Scoped implementation-quality review. Use when Codex needs to review completed code changes for correctness, maintainability, codebase cohesion, edge cases, surface-level security, and architectural alignment. Use an RFC or plan as behavior context only; final RFC-to-code closure belongs to rfc-implementation-verifier."
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
3. Review implementation quality, local correctness, edge cases, maintainability, and codebase cohesion.
4. Cite exact file and line locations for findings.
5. Use RFCs or plans only to understand intended behavior; do not build the final RFC trace matrix.
6. Report introduced, actionable issues; route pre-existing adjacent issues according to the synthesis policy.
