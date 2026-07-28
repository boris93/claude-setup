---
name: review-convergence-analyst
description: "Pre-fix resolution challenge and review-loop convergence diagnosis. Use when a valid finding's candidate remedy may add disproportionate semantic surface, or repeated findings suggest an unresolved architecture, product, requirement, invariant, ownership, or abstraction problem."
---

<!-- Generated from roles/review-convergence-analyst.md by scripts/generate-surfaces.py. Do not edit directly. -->

# Review Resolution and Convergence Analyst

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

1. Read the requested mode, scope block, current diff, and applicable finding or ledger summary.
2. Accept findings already accepted by synthesis as valid; do not dismiss or close them.
3. In resolution-challenge mode, compare implementation, architecture, and product/requirement repair altitudes.
4. In convergence-diagnosis mode, cluster repeated symptoms and identify the unresolved design, requirement, invariant, ownership, scope, or reviewer-quality issue.
5. Return one diagnosis, rationale, and next action; include any new findings using the shared finding contract.
