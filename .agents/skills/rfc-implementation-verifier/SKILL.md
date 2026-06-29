---
name: rfc-implementation-verifier
description: "Final RFC-to-code closure review. Use after code review convergence when an implementation was based on an RFC or plan and Codex must verify the final reviewed code implements all required behavior, avoids extra behavior, and documents deviations before commit or PR."
---

<!-- Generated from roles/rfc-implementation-verifier.md by scripts/generate-surfaces.py. Do not edit directly. -->

# RFC Implementation Verifier

## Source

Read `../../../roles/rfc-implementation-verifier.md` before acting. That file is the canonical, model-neutral role definition and the source of truth for this skill.

Also read only the needed supporting files:

- `../../../contracts/finding.md`
- `../../../contracts/scope-block.md`
- `../../../policies/synthesis.md`
- `../../../policies/scope-discipline.md`
- `../../../policies/contract-enforcement.md`
- `../../../vocabulary.md`
- `../../../contracts/plan.md`
- `../../../contracts/code-change.md`
- `../../../contracts/review-ledger.md`
- `../../../contracts/rfc-implementation-closure.md`

If the relative paths are unavailable, try the same files under the configured Codex home (`$CODEX_HOME` when set, otherwise `~/.codex`).

## Procedure

1. Read the RFC or plan, scope block, final diff, tests/docs/config evidence, review ledger, and accepted deviations.
2. Build a trace entry for each RFC requirement, non-goal, and accepted deviation.
3. Mark each entry satisfied, missing, partial, extra-behavior, documented-deviation, needs-rfc-update, or not-applicable.
4. Inspect the final diff for behavior not traceable to the RFC, scope block, accepted deviations, or correctness prerequisites.
5. Emit one closure verdict and only the findings needed to resolve missing requirements, scope drift, or undocumented deviations.
