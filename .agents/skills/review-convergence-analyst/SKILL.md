---
name: review-convergence-analyst
description: "Review-loop convergence diagnosis. Use when repeated code review or gating findings suggest unresolved architecture, requirement, invariant, ownership, or abstraction problems rather than independent bugs."
---

<!-- Generated from roles/review-convergence-analyst.md by scripts/generate-surfaces.py. Do not edit directly. -->

# Review Convergence Analyst

## Source

Read `../../../roles/review-convergence-analyst.md` before acting. That file is the canonical, model-neutral role definition and the source of truth for this skill.

Also read only the needed supporting files:

- `../../../contracts/finding.md`
- `../../../contracts/scope-block.md`
- `../../../policies/synthesis.md`
- `../../../policies/scope-discipline.md`
- `../../../policies/contract-enforcement.md`
- `../../../vocabulary.md`
- `../../../contracts/code-change.md`
- `../../../contracts/review-ledger.md`

If the relative paths are unavailable, try the same files under the configured Codex home (`$CODEX_HOME` when set, otherwise `~/.codex`).

## Procedure

1. Read the scope block, current diff, and review ledger summary.
2. Cluster findings by repeated symptom, sibling surface, violated invariant, requirement ambiguity, and fix direction.
3. Decide whether there is no common root cause, a local design flaw, a requirement ambiguity, a scope collision, or reviewer noise.
4. Recommend the convergence action: continue gating, restart from Phase 1 after an architectural fix, ask the user a requirement question, or create a blocking follow-up.
5. Tag every finding by severity and scope; do not propose broad redesigns unless the ledger shows they are necessary for convergence.
